# PRD: AGENT_CreateContact — Autolaunched Flow
## Astrum BD Agent — Subagent 1 (Account and Contact Management)

| Field | Value |
|---|---|
| PRD ID | SAL-BD-S1-AGENT_CreateContact |
| Author | Claude Code (Architect agent) — Astrum Orbit programme |
| Date | 2026-04-28 |
| Status | **Draft — Awaiting Human Approval before Codex build** |
| Source spec | LLM-TXTS/agentforce/Astrum_BD_Agent_S1_AccountContact_Spec.md — Section 3, Action 6 |
| Schema authority | LLM-TXTS/schema/Astrum_Objects_Fields_Schema_Authority.md (generated 2026-04-28T07:11:47Z) |
| Build readiness | validation/agentforce/Astrum_BD_Agent_Build_Readiness_Report.md — Section 6 |
| Target org | astrum--astrumpar.sandbox.my.salesforce.com |
| API version | 66.0 |
| Intended builder | Codex (do not proceed without Human approval of this PRD) |

---

## 1. Summary and Scope

### 1.1 Purpose

`AGENT_CreateContact` is the sole custom-built Salesforce Flow for Subagent 1 of the Astrum BD Agent. It creates a new Contact record linked to a specified Account, guarded by a mandatory duplicate-check query before any DML is executed. The Flow is invoked from Agentforce as an Invocable Action when the running BD user asks to add a new contact to an account.

All other Subagent 1 actions (Get Account Details, Search Accounts, Update Account Field, Get Contact Details, Search Contacts, Update Contact Field) are standard Salesforce Agent Builder actions — **no Flow build is required for those six actions**.

### 1.2 Scope of this PRD

**In scope:**
- Autolaunched Flow `AGENT_CreateContact` — full build specification.
- Duplicate query by name + account and by email.
- Contact Create record element and fault path.
- Input and output variable definitions.
- Permission requirements.
- Unit test scenarios.
- Validation exit criteria.

**Out of scope:**
- Agent Builder configuration for standard actions (Actions 1–5, 7).
- Account Intelligence Summary Prompt Template (Action 8) — separate deliverable.
- `Astrum_BD_Agent_PS` permission set metadata — separate deliverable.
- Subagent 2 or Subagent 3 Flows.
- Any Flow XML generation — this PRD is design-only. Codex generates Flow XML.

### 1.3 Build Readiness Confirmation

Per the build-readiness report (Section 6), all seven input fields for `AGENT_CreateContact` are confirmed in the sandbox org:

| Field | Status |
|---|---|
| `Contact.AccountId` | CONFIRMED in sandbox |
| `Contact.FirstName` | CONFIRMED in sandbox |
| `Contact.LastName` | CONFIRMED in sandbox |
| `Contact.Title` | CONFIRMED in sandbox |
| `Contact.Email` | CONFIRMED in sandbox |
| `Contact.Phone` | CONFIRMED in sandbox |
| `Contact.MobilePhone` | CONFIRMED in sandbox |

**No pre-build blockers exist for this Flow.** This is the first Codex build task in the sequenced build order (Step 8 of 23).

---

## 2. Flow Identity

| Property | Value |
|---|---|
| **Flow API name** | `AGENT_CreateContact` |
| **Flow label** | `AGENT_CreateContact` |
| **Flow type** | Autolaunched Flow — No Trigger |
| **Run mode** | **User context** — "Run Flow As" property set to "User or Queue That Launched the Flow". Never System or System Without Sharing. |
| **Invocation method** | Invocable Action called from Agentforce Agent Builder (Action 6: "Create Contact with Duplicate Check"). |
| **HITL mode at agent level** | **Confirm** — Agentforce platform enforces user confirmation before invoking this Flow. The Flow itself does not implement a screen; HITL is managed at the Agent Builder action configuration layer. |
| **`AGENT_` prefix** | Mandatory. This prefix identifies agent-triggered operations in Salesforce Shield Event Monitoring logs. The API name must not be changed after activation. |
| **Bypass_Flow check** | **Not required.** This is not a record-triggered Flow. Bypass logic (AGENTS.md Section 11) applies only to record-triggered Flows. Do not add a Bypass_Flow Decision element. |
| **Screens** | None. Autolaunched Flow has no screen elements. |
| **Transactions** | Single transaction. |

---

## 3. Input Variables

Define the following variables in the Flow canvas as Input variables. All are type Text unless noted. All are available from the Start element.

| Variable API name | Type | Required | Source | Description |
|---|---|---|---|---|
| `AccountId` | Text | **Yes** | Agent (resolved from user's request) | 18-character Salesforce Record ID of the parent Account. The agent must resolve the Account ID from the user's natural-language reference before invoking this Flow. Do not accept a 15-char ID. |
| `FirstName` | Text | **Yes** | Agent (extracted from user input) | Contact first name. |
| `LastName` | Text | **Yes** | Agent (extracted from user input) | Contact last name. |
| `Title` | Text | No | Agent (extracted from user input) | Job title. May be blank. |
| `Email` | Text | No | Agent (extracted from user input) | Email address. May be blank. If populated, the duplicate check must query by email in addition to name. |
| `Phone` | Text | No | Agent (extracted from user input) | Work phone number. May be blank. |
| `MobilePhone` | Text | No | Agent (extracted from user input) | Mobile phone number. May be blank. |

**Input variable notes:**
- `AccountId` must be validated to resolve to a real Account before reaching the Create element (see Element 3 below).
- `Email` drives a conditional branch in the duplicate check (Element 2). The Flow must handle the case where Email is blank — do not execute the email-based duplicate query if `Email` is blank.
- No email format validation is required inside the Flow. The agent instruction layer handles prompting the user for a valid email.

---

## 4. Output Variables

Define the following variables in the Flow canvas as Output variables. All are returned to the Agentforce agent after Flow execution.

| Variable API name | Type | Populated when | Description |
|---|---|---|---|
| `Success` | Boolean | Always | `true` if the Contact was created successfully. `false` if creation failed or if the Flow exited early due to a duplicate. |
| `CreatedContactId` | Text | `Success = true` only | 18-character Salesforce Record ID of the newly created Contact. Blank on all other paths. |
| `CreatedContactName` | Text | `Success = true` only | Full name of the created Contact (concatenated `FirstName` + `' '` + `LastName`), for use in the agent's confirmation message. Blank on all other paths. |
| `DuplicateFound` | Boolean | Always | `true` if a potential duplicate Contact was found by the query. `false` on all other paths. When `true`, the agent must present the duplicate to the user before offering to proceed. |
| `DuplicateContactName` | Text | `DuplicateFound = true` only | Full name of the first potential duplicate Contact found. Blank if no duplicate. |
| `DuplicateContactId` | Text | `DuplicateFound = true` only | 18-character Salesforce Record ID of the first potential duplicate Contact. Used by the agent to link the user to the existing record. Blank if no duplicate. |
| `ErrorMessage` | Text | `Success = false` and `DuplicateFound = false` | Description of the fault condition. Populated from the fault path. Blank on success and duplicate-found paths. |

**Output variable notes:**
- `DuplicateFound = true` and `Success = false` are not mutually exclusive. When a duplicate is found, the Flow sets `DuplicateFound = true` and exits without attempting a Create. In this case `Success` must be set to `false` and `CreatedContactId` must remain blank.
- The agent's instruction layer is responsible for interpreting the output combination and presenting the appropriate message to the user. The Flow's job is to return accurate signal.

---

## 5. Flow Element Sequence

Implement Flow elements in this exact order. Do not reorder. Do not add screen elements.

### Element 1 — Account Validation Query

| Property | Value |
|---|---|
| Element type | Get Records |
| Element API name | `Get_Account` |
| Element label | Get Account |
| Description | **Verify that the AccountId input resolves to a real Account record accessible to the running user. This prevents a phantom Contact being created with an invalid AccountId.** |
| Object | Account |
| Filter | `Id` Equals `{!AccountId}` |
| How many records | First Record Only |
| Store record in | Record variable: `var_Account` (SObject variable, type Account) |
| If no records found | Route to Element 5 (Set Fault — Account Not Found) |
| Run context | User mode (inherited from Flow run mode) |

**Decision after Element 1:**
- Records found → proceed to Element 2.
- No records found → go to Element 5.

---

### Element 2 — Duplicate Query by Name and Account

| Property | Value |
|---|---|
| Element type | Get Records |
| Element API name | `Get_Duplicate_By_Name` |
| Element label | Query Duplicate by Name and Account |
| Description | **Query for existing Contacts at the same Account with the same last name. This is the primary duplicate detection signal.** |
| Object | Contact |
| Filters | `AccountId` Equals `{!AccountId}` AND `LastName` Equals `{!LastName}` |
| How many records | First Record Only |
| Store record in | Record variable: `var_DuplicateByName` (SObject variable, type Contact) |
| If no records found | Continue (no fault) — proceed to Element 3 |
| Run context | User mode |

---

### Element 3 — Duplicate Query by Email (Conditional)

| Property | Value |
|---|---|
| Element type | Decision |
| Element API name | `Check_Email_Populated` |
| Element label | Check Email Populated |
| Description | **Gate the email-based duplicate query. Only execute if the Email input variable is not blank. An empty Email input must not generate a Get Records query (SOQL with Email = null returns misleading results).** |
| Outcomes | Email Not Blank (`{!Email}` Is Not Null AND `{!Email}` Not Equals `''`) → Element 4. Email Blank (Default) → Element 5. |

---

### Element 4 — Duplicate Query by Email

| Property | Value |
|---|---|
| Element type | Get Records |
| Element API name | `Get_Duplicate_By_Email` |
| Element label | Query Duplicate by Email |
| Description | **Query for any existing Contact across any Account with the same email address. Email uniqueness is a cross-account signal.** |
| Object | Contact |
| Filters | `Email` Equals `{!Email}` |
| How many records | First Record Only |
| Store record in | Record variable: `var_DuplicateByEmail` (SObject variable, type Contact) |
| If no records found | Continue — proceed to Element 5 |
| Run context | User mode |

---

### Element 5 — Evaluate Duplicate Results

| Property | Value |
|---|---|
| Element type | Decision |
| Element API name | `Evaluate_Duplicate_Results` |
| Element label | Evaluate Duplicate Results |
| Description | **Determine if any duplicate signal was detected. If either query returned a record, set duplicate outputs and exit before creating. The name-match signal takes precedence for the duplicate contact display.** |
| Outcomes | Duplicate Found by Name (`{!var_DuplicateByName}` Is Not Null) → Element 6a. Duplicate Found by Email only (`{!var_DuplicateByEmail}` Is Not Null) → Element 6b. No Duplicate (Default) → Element 7. Account Not Found signal → Element 8a (fault). |

> **Implementation note for Codex:** The Decision element should check `var_DuplicateByName` first (outcome priority 1), then `var_DuplicateByEmail` (outcome priority 2). The Account Not Found signal is not a separate outcome here — it was handled by routing in Element 1. By the time flow reaches Element 5, Account has been confirmed.

---

### Element 6a — Set Duplicate Outputs (Name Match)

| Property | Value |
|---|---|
| Element type | Assignment |
| Element API name | `Set_Duplicate_Name_Match` |
| Element label | Set Duplicate Found — Name Match |
| Description | **Populate output variables when a duplicate is detected by name at the same account. Do not proceed to Create.** |
| Assignments | `{!DuplicateFound}` = `true`; `{!Success}` = `false`; `{!DuplicateContactName}` = `{!var_DuplicateByName.FirstName}` + `' '` + `{!var_DuplicateByName.LastName}`; `{!DuplicateContactId}` = `{!var_DuplicateByName.Id}` |
| Next element | End (no Create) |

---

### Element 6b — Set Duplicate Outputs (Email Match)

| Property | Value |
|---|---|
| Element type | Assignment |
| Element API name | `Set_Duplicate_Email_Match` |
| Element label | Set Duplicate Found — Email Match |
| Description | **Populate output variables when a duplicate is detected by email (cross-account match). Do not proceed to Create.** |
| Assignments | `{!DuplicateFound}` = `true`; `{!Success}` = `false`; `{!DuplicateContactName}` = `{!var_DuplicateByEmail.FirstName}` + `' '` + `{!var_DuplicateByEmail.LastName}`; `{!DuplicateContactId}` = `{!var_DuplicateByEmail.Id}` |
| Next element | End (no Create) |

---

### Element 7 — Create Contact Record

| Property | Value |
|---|---|
| Element type | Create Records |
| Element API name | `Create_Contact` |
| Element label | Create Contact |
| Description | **Create the new Contact record. All input variables are mapped to the corresponding Contact fields. Only the fields listed below may be set in this element — do not set any field not listed here.** |
| Object | Contact |
| Fault path | Route to Element 8b (Fault — Create Failed) |
| Run context | User mode (FLS enforced) |

**Field assignments (map exactly as listed):**

| Contact field API name | Source value | Condition |
|---|---|---|
| `AccountId` | `{!AccountId}` | Always |
| `FirstName` | `{!FirstName}` | Always |
| `LastName` | `{!LastName}` | Always |
| `Title` | `{!Title}` | Only if `{!Title}` is not blank |
| `Email` | `{!Email}` | Only if `{!Email}` is not blank |
| `Phone` | `{!Phone}` | Only if `{!Phone}` is not blank |
| `MobilePhone` | `{!MobilePhone}` | Only if `{!MobilePhone}` is not blank |

**Do not set:** `OwnerId`, `ReportsToId`, `RecordTypeId`, or any field not listed above.

Store the created record ID in: Text variable `{!var_CreatedContactId}`.

---

### Element 8a — Set Fault: Account Not Found

| Property | Value |
|---|---|
| Element type | Assignment |
| Element API name | `Set_Fault_Account_Not_Found` |
| Element label | Set Fault — Account Not Found |
| Description | **Set error outputs when the AccountId input does not resolve to an accessible Account record. The running user may lack record access.** |
| Assignments | `{!Success}` = `false`; `{!DuplicateFound}` = `false`; `{!ErrorMessage}` = `'Account not found or not accessible. Verify the account ID and your record access.'` |
| Next element | End |

---

### Element 8b — Set Fault: Create Failed

| Property | Value |
|---|---|
| Element type | Assignment |
| Element API name | `Set_Fault_Create_Failed` |
| Element label | Set Fault — Create Failed |
| Description | **Set error outputs when the Create Records element faults. Do not rethrow the fault — a failed Contact Create must not roll back any upstream DML. Capture the fault message.** |
| Assignments | `{!Success}` = `false`; `{!DuplicateFound}` = `false`; `{!ErrorMessage}` = `{!$Flow.FaultMessage}` |
| Next element | End |

---

### Element 9 — Set Success Outputs

| Property | Value |
|---|---|
| Element type | Assignment |
| Element API name | `Set_Success_Outputs` |
| Element label | Set Success Outputs |
| Description | **Populate output variables on successful Contact creation.** |
| Assignments | `{!Success}` = `true`; `{!CreatedContactId}` = `{!var_CreatedContactId}`; `{!CreatedContactName}` = `{!FirstName}` + `' '` + `{!LastName}`; `{!DuplicateFound}` = `false` |
| Next element | End |

**Flow path from Element 7:** Create Records → (no fault) → Element 9 → End. Fault → Element 8b → End.

---

### Flow Path Summary

```
Start
  │
  ▼
[1] Get Account → No Account found → [8a] Set Fault (Account Not Found) → End
  │ Account found
  ▼
[2] Get Duplicate by Name (LastName + AccountId)
  │
  ▼
[3] Check Email Populated
  │ Email populated          │ Email blank
  ▼                          ▼
[4] Get Duplicate by Email   ─────────────────────┐
  │                                               │
  ▼                                               ▼
[5] Evaluate Duplicate Results ──────────────────[5]
  │ Name match  │ Email match  │ No duplicate
  ▼             ▼              ▼
[6a] Set       [6b] Set       [7] Create Contact
  Dup (Name)     Dup (Email)   │ fault
  │              │             ▼
  │              │           [8b] Set Fault (Create Failed) → End
  │              │             │ success
  │              │             ▼
  │              │           [9] Set Success Outputs → End
  ▼              ▼
  End            End
```

---

## 6. Permitted Fields — Schema Authority Confirmation

All fields used in this Flow are confirmed ✅ CONFIRMED in the sandbox org describe output (2026-04-28T07:11:47Z).

| Object | Field API name | Label | Type | Used in element(s) | Status |
|---|---|---|---|---|---|
| Account | `Id` | Account ID | ID | Element 1 (filter) | CONFIRMED |
| Contact | `AccountId` | Account ID | Reference(Account) | Element 2 (filter), Element 7 (set) | CONFIRMED |
| Contact | `LastName` | Last Name | Text | Element 2 (filter), Element 7 (set) | CONFIRMED |
| Contact | `Email` | Email | Email | Element 3 (gate), Element 4 (filter), Element 7 (set) | CONFIRMED |
| Contact | `FirstName` | First Name | Text | Elements 6a, 6b, 9 (output concat), Element 7 (set) | CONFIRMED |
| Contact | `Id` | Contact ID | ID | Elements 6a, 6b (DuplicateContactId output) | CONFIRMED |
| Contact | `Title` | Job Title | Text | Element 7 (set, conditional) | CONFIRMED |
| Contact | `Phone` | Work Phone | Phone | Element 7 (set, conditional) | CONFIRMED |
| Contact | `MobilePhone` | Mobile | Phone | Element 7 (set, conditional) | CONFIRMED |

**Fields deliberately excluded from this Flow:**
- `Contact.DoNotCall` — FLS-restricted (not in sandbox describe). Not required for contact creation. Resolve before any outreach logic is added.
- `Contact.OwnerId` — Not set on create; defaults to running user. Do not override.
- `Contact.ReportsToId` — Not in scope for initial create.
- `Contact.RecordTypeId` — Not in scope. Default RecordType applies.
- All standard `Probability` and `Probability__c` Opportunity fields — not relevant to Contact creation.

---

## 7. Unit Test Scenarios

Four scenarios required. Codex must implement all four as Flow test records or Apex test methods. All tests must run in user context against a BD test user who does **not** have View All on Contact.

| Scenario | ID | Input conditions | Expected Flow outputs | Pass criteria |
|---|---|---|---|---|
| **No duplicate — contact created** | TC-01 | Valid `AccountId`, unique `FirstName` + `LastName` (no existing Contact with this name at this Account), `Email` blank or unique across org. | `Success = true`, `CreatedContactId` populated, `CreatedContactName` = `FirstName + ' ' + LastName`, `DuplicateFound = false`, `ErrorMessage` blank. | Contact record created in org. Output IDs match created record. |
| **Duplicate found by name at same account** | TC-02 | Valid `AccountId`. Existing Contact at same Account with the same `LastName`. | `DuplicateFound = true`, `DuplicateContactId` = existing Contact ID, `DuplicateContactName` populated, `Success = false`, `CreatedContactId` blank, `ErrorMessage` blank. | No new Contact record created in org. Existing Contact ID returned. |
| **Duplicate found by email** | TC-03 | Valid `AccountId`. No name match at this Account. `Email` input matches an existing Contact (may be at a different Account). | `DuplicateFound = true`, `DuplicateContactId` = existing Contact ID (the email match), `DuplicateContactName` populated, `Success = false`, `CreatedContactId` blank. | No new Contact record created. Email-match Contact ID returned. |
| **AccountId not found — graceful failure** | TC-04 | `AccountId` is a syntactically valid 18-char ID that does not resolve to an accessible Account record (either deleted or outside running user's sharing). `FirstName`, `LastName` populated. | `Success = false`, `DuplicateFound = false`, `ErrorMessage` contains `'Account not found'` text, `CreatedContactId` blank. | No Contact created. Error message returned. Flow does not throw an unhandled fault. |

**Test setup requirements:**
- All tests use the BD test user profile (not System Administrator).
- TC-01: pre-create an Account the test user can access. Assert no Contact with test name at that Account exists before test.
- TC-02: pre-create Account and a Contact with matching LastName at that Account.
- TC-03: pre-create Account and a Contact at any Account with a matching Email.
- TC-04: construct a 18-char ID using `CASESAFEID` of a non-existent Account ID or an Account outside the user's sharing scope.

---

## 8. Known Constraints

| Constraint | Rule | Source |
|---|---|---|
| **User context** | Flow "Run Flow As" must be set to "User or Queue That Launched the Flow." Never System or System Without Sharing. AEA runs in user context; the Flow must inherit this. | AGENTS.md Section 11; S1 Spec Section 3 Action 6 |
| **`AGENT_` prefix** | API name `AGENT_CreateContact` is mandatory. Salesforce Shield Event Monitoring uses this prefix to identify agent-triggered operations. API names cannot be renamed after activation. Build correctly first time. | AGENTS.md Section 11; S1 Spec Section 7 |
| **No Delete actions** | This Flow must not include any Delete Records element. The permission set `Astrum_BD_Agent_PS` must not include Delete on any object. | AGENTS.md Section 11; S1 Spec Section 2.1 |
| **No Account creation** | This Flow must not include a Create Records element for the Account object. Account creation is out of scope. | S1 Spec Section 1.3 |
| **Contact.Email and Contact.Phone — PT exclusion** | Email and Phone are set on the Contact record by this Flow (allowable). However, these fields must never appear as raw inputs in any Prompt Template. This constraint applies to the Account Intelligence Summary PT — not to this Flow. Record it here so the PRD pack is complete. | S1 Spec Section 3 Action 8; Build Readiness Report Section 5 |
| **Bypass_Flow check — not required** | Do not add a `Check_Bypass_Permission` Decision element to this Flow. Bypass_Flow is mandatory only for record-triggered Flows. This is an Autolaunched (no-trigger) Flow. | AGENTS.md Section 11; CLAUDE.md Hard Rules |
| **HITL Confirm at agent level** | HITL Confirm is set on the Agent Builder action configuration, not inside the Flow. The Flow itself has no screen. Do not add any screen elements or platform-level approvals inside the Flow. | S1 Spec Section 3 Action 6 |
| **Fault paths must not rethrow** | The Create Records fault path must set `ErrorMessage` from `{!$Flow.FaultMessage}` and exit cleanly. A failed Contact Create must not roll back any DML. Mirror the fault-path pattern from the SAL notification Flows. | AGENTS.md Section 11 (Fault paths rule) |
| **No deployment without Human approval** | Do not deploy this Flow to any org until Human has reviewed and approved. All deployments to production are Human-only. | AGENTS.md Section 7; CLAUDE.md Hard Rules |

---

## 9. Validation Exit Criteria

This Flow must pass all criteria below before being handed to Salesforce Admin for Agent Builder configuration. Evidence must be documented in `validation/SAL-BD-S1-AGENT_CreateContact.md`.

### Flow-level exit criteria

| # | Criterion | Evidence required |
|---|---|---|
| FC-01 | All four unit test scenarios (TC-01 through TC-04) pass. | Test run log or Apex test class output showing 4/4 pass. |
| FC-02 | Flow API name is `AGENT_CreateContact` — `AGENT_` prefix confirmed. | Metadata file path or deploy log showing correct API name. |
| FC-03 | Flow Run Mode is confirmed as "User or Queue That Launched the Flow" — not System. | Flow XML `<runInMode>` value or Flow property screenshot. |
| FC-04 | TC-02 and TC-03 confirm no Contact record is created when `DuplicateFound = true`. | Test assertion on Contact count before and after Flow execution. |
| FC-05 | TC-04 confirms Flow returns `ErrorMessage` cleanly without unhandled fault. | Test assertion on `ErrorMessage` output value. |
| FC-06 | No element in the Flow has a blank description field. | Code review of Flow XML: every `<description>` tag populated. |

### Agent-level exit criteria (post Agent Builder configuration)

| # | Criterion | Evidence required |
|---|---|---|
| AC-01 | Duplicate check fires on 100% of "Create Contact" invocations from the agent. | Agentforce Testing Center trace confirming Flow is invoked before any DML. |
| AC-02 | Confirm HITL step appears before every invocation — agent presents proposed contact for user approval before the Flow is called. | Testing Center screenshot or trace showing Confirm step. |
| AC-03 | Test case S1-5.3-04 passes: "Add John Smith at Pfizer" surfaces existing John Smith at Pfizer before creating. | Testing Center test run record. |
| AC-04 | Test case S1-5.3-01 passes: "Delete the Pfizer contact" — agent informs user deletion is outside scope. No delete action invoked. | Testing Center test run record. |
| AC-05 | No Contact.Email or Contact.Phone appear as raw inputs in any Prompt Template invocation trace. | Einstein Trust Layer or Testing Center PT input trace. |

---

## Next Operator

- Run next in: **Human**
- Reason: Human must review and approve this PRD before Codex is handed the build prompt. Human confirms: (1) PRD accurately reflects intent, (2) unit test scenarios are sufficient, (3) Codex may proceed.
- Next prompt (issue to Codex after Human approval):

```
Task: Build the AGENT_CreateContact Autolaunched Flow per the approved PRD at
docs/PRDs/SAL-BD-S1-AGENT_CreateContact-PRD.md.

Context files to load:
- docs/PRDs/SAL-BD-S1-AGENT_CreateContact-PRD.md  (approved PRD — authoritative)
- LLM-TXTS/agentforce/Astrum_BD_Agent_S1_AccountContact_Spec.md  (source spec — reference)
- LLM-TXTS/schema/Astrum_Objects_Fields_Schema_Authority.md  (schema authority — field validation)
- AGENTS.md  (governance rules)

Build:
- Flow XML at: force-app/main/default/flows/AGENT_CreateContact.flow-meta.xml
- Implement all elements from PRD Section 5 in the exact order specified.
- Map all input/output variables from PRD Sections 3 and 4.
- Confirm:
  - Flow API name: AGENT_CreateContact (AGENT_ prefix mandatory)
  - Run mode: User context (runInMode = UserMode)
  - No screen elements
  - No Bypass_Flow Decision element (not a record-triggered Flow)
  - No Delete Records element
  - Every element has a non-blank description
  - Fault path on Create Records element routes to Set_Fault_Create_Failed assignment

After build:
- Run unit tests for all 4 scenarios (TC-01 through TC-04 from PRD Section 7).
- Produce validation evidence at: validation/SAL-BD-S1-AGENT_CreateContact.md
- Produce a paste-ready Linear comment for issue SAL-BD-S1.

Constraints:
- Do not touch SAL notification files (SAL-2, SAL-9, SAL-10).
- Do not deploy.
- Do not move any Linear issue to Done, Closed, or Production Ready.
- Do not generate Flow XML for any other agent action (Actions 1-5, 7 are standard — no Flow needed).
```

---

*PRD authored by Claude Code (Architect agent) — Astrum Orbit programme.*
*No Salesforce metadata was created, modified, deployed, activated, or deleted during PRD authoring.*
*SAL-2, SAL-9, and SAL-10 notification files were not touched.*
*Generated: 2026-04-28*
