# SAL-2 — Critical Stage Progression Alert
## Implementation PRD

| Field | Value |
|---|---|
| Linear Issue | SAL-2 |
| Notification Number | 2 of 14 |
| Programme | Astrum Orbit |
| Workstream | Sales Cloud — Opportunity Notifications |
| Author | Amit Kumar (Salesforce Admin) |
| PRD Version | 1.0 |
| Date | 25 April 2026 |
| Status | Ready for active build — one open decision (OQ-1) defaults safely without blocking build |
| Schema Authority | Astrum__Objects_Fields_1.xlsx; live org query 25 April 2026 |
| Org | astrum--astrumpar.sandbox.my.salesforce.com |

---

## Build Status

> **READY FOR ACTIVE FLOW BUILD**
>
> All field API names confirmed against live sandbox. Recipient list fully specified. Trigger field and picklist values confirmed. One open decision (OQ-1 — creation trigger) has a safe default that does not block build or testing. No business sign-off blockers equivalent to SAL-10 BD5.
>
> | Category | Permitted |
> |---|---|
> | Safe work | All — PRD, schema validation, Flow XML, email template, test cases |
> | Flow activation | Permitted in sandbox after test suite passes |
> | Production deployment | Never — sandbox and scratch orgs only per CLAUDE.md hard rule |
>
> OQ-1 (initial creation at 75% / 90%) defaults to **exclude creation** — trigger is set to updated records only. Business must explicitly confirm if creation should also trigger the alert before this default is changed.

---

## 1. Objective

Build a record-triggered Salesforce Flow that sends an immediate email to five named stakeholders the first time an Opportunity's `Opp_Probability__c` picklist field changes into the value `75` or `90` from any other value. The email surfaces the commercial context required for stakeholders to react quickly to a high-probability stage progression: account, deal code, fees, stage, key study data, and next actions.

This notification is part of a suite of 14 Opportunity pipeline notifications. It sits in the first build wave alongside notifications 9 (Closed Won) and 10 (Closed Lost), which have the cleanest trigger logic and deliver the most immediate commercial value.

The primary commercial purpose is to ensure that every Opportunity entering a critical probability band is immediately visible to the right people, enabling rapid prioritisation of proposal support, resource allocation, and client engagement.

---

## 2. Confirmed Requirements

Source: SAL-2 Linear issue, Orbit Opportunities Notification Requirements Specification CSV, SAL-10 PRD programme guardrails, CLAUDE.md hard rules, live sandbox org query 25 April 2026.

### Functional requirements

| # | Requirement | Source |
|---|---|---|
| FR-01 | Send one email immediately when `Opp_Probability__c` changes to `75` or `90` from any other value, on an Opportunity update. | Linear SAL-2 |
| FR-02 | Do not send if `Opp_Probability__c` value is unchanged between saves. | Linear SAL-2 |
| FR-03 | Do not send on record creation unless business explicitly confirms creation counts as progression. Default: trigger on updates only. | Linear SAL-2; OQ-1 |
| FR-04 | Send to all five fixed recipients on every qualifying alert: rfp.rfi@astrumcro.com, jordi.picas@astrumcro.com, cristina.lopes@astrumcro.com, anthony.gibson@astrumcro.com, vania.araujo@astrumcro.com. | Linear SAL-2 |
| FR-05 | Use `Opportunity_Code__c` as the primary deal identifier in the email body. | Memory Pack §10 ALWAYS |
| FR-06 | Use `Opportunity_ID_18__c` to generate the Salesforce record link in the email body. | Memory Pack §10 ALWAYS |
| FR-07 | Do not reference the standard `Probability` field in any Flow condition, formula, or email content. Use `Opp_Probability__c` exclusively. | Memory Pack §§4, 9 NEVER |
| FR-08 | The Flow must check the `Bypass_Flow` custom permission as its first element. If the running user holds this permission, exit without sending. | CLAUDE.md hard rule |
| FR-09 | The Flow must run in User Context, not System or System Without Sharing mode. | Memory Pack §6 NEVER |
| FR-10 | Include Previous Probability in the email body using the prior-value variable `{!$Record__Prior.Opp_Probability__c}`, which is available natively in after-save record-triggered Flows. No helper field is required. | Design decision — org-validated |
| FR-11 | A moving alert from 75% to 90% must send a new email. The entry conditions treat each qualifying change independently. | Linear SAL-2 acceptance criteria |

### Non-functional requirements

| # | Requirement |
|---|---|
| NFR-01 | Flow Label: `Notify Critical Stage Progression After Save`. API Name: `Notify_Critical_Stage_Progression_After_Save`. Naming convention required by CLAUDE.md (flow type appended). |
| NFR-02 | All Flow elements must have descriptions. CLAUDE.md hard rule. No exceptions. |
| NFR-03 | Flow must never be deployed to or activated in a production org. Sandbox only per CLAUDE.md hard rule. |
| NFR-04 | Every new custom field, object, or validation rule introduced as part of this build must include a description. CLAUDE.md hard rule. No new custom metadata is required for SAL-2. |
| NFR-05 | Every record-triggered Flow must include bypass logic checking the `Bypass_Flow` custom permission before executing. CLAUDE.md hard rule. |

---

## 3. Object and Field Mapping

Object: **Opportunity**
All custom fields validated against live sandbox org `astrum--astrumpar` on 25 April 2026 via Tooling API `FieldDefinition` query and anonymous Apex describe.

### 3.1 Email payload fields

| Label | API Name | Data Type | Org Status | Notes |
|---|---|---|---|---|
| Opportunity Name | `Name` | Text(120) | Confirmed — standard | Used in email subject and body |
| Account Name | `Account.Name` | Cross-object Text | Confirmed — standard | Via AccountId lookup; retrieved via Get Records |
| Opportunity Code | `Opportunity_Code__c` | Text(255) | Confirmed — custom | Primary deal identifier. May be blank on Dynamics-migrated records — email must omit row gracefully |
| Previous Probability | `{!$Record__Prior.Opp_Probability__c}` | Flow prior-value variable | Confirmed — available in after-save context | Renders the picklist stored value (e.g. `50`). No helper field required |
| New Probability | `Opp_Probability__c` | Picklist | Confirmed — custom | Trigger field. Active values: 0, 5, 10, 25, 50, **75**, **90**, 100 |
| Stage | `StageName` | Picklist | Confirmed — standard | |
| Service Fees | `Service_Fees__c` | Currency(18,0) | Confirmed — custom | EUR-denominated. Display as zero if value is 0; omit only if null |
| Close Date | `CloseDate` | Date | Confirmed — standard | |
| Study Countries | `Study_Countries__c` | Picklist (Multi-Select) | Confirmed — custom | Renders as semicolon-separated values in Flow email |
| Therapeutic Area | `Therapeutic_Area__c` | Picklist | Confirmed — custom | Single-select |
| Indication | `Indication__c` | Long Text Area(32000) | Confirmed — custom | May be lengthy; omit row if blank |
| Entities Providing Services | `Entities_Providing_Services__c` | Picklist (Multi-Select) | Confirmed — custom | Renders as semicolon-separated values in Flow email |
| Next Specific Action | `Next_specific_action__c` | Text Area(255) | Confirmed — custom | Note: lowercase 's' and 'a' in API name |
| Date of Next Specific Action | `Date_of_next_specific_action__c` | Date | Confirmed — custom | Note: all-lowercase in API name |
| Person Responsible for Next Action | `Person_responsible_for_next_action__c` | Text(255) | Confirmed — custom | Label in org is "Person responsible for next action" |
| Salesforce Record Link | `Opportunity_ID_18__c` | Formula (Text) | Deployed 25 Apr 2026 | `CASESAFEID(Id)`. Used to construct the clickable record URL |

### 3.2 Trigger field

| Label | API Name | Data Type | Trigger values | Org Status |
|---|---|---|---|---|
| Probability | `Opp_Probability__c` | Picklist | `75`, `90` | Confirmed — active values verified via anonymous Apex |

### 3.3 Infrastructure

| Component | API Name | Org Status |
|---|---|---|
| Bypass custom permission | `Bypass_Flow` | Deployed 25 Apr 2026 |
| 18-char record ID formula | `Opportunity_ID_18__c` | Deployed 25 Apr 2026 |

### 3.4 Fields explicitly excluded

| Field | API Name | Reason |
|---|---|---|
| Standard Probability | `Probability` | Prohibited by programme Memory Pack FR-07 NEVER guardrail |
| Probability formula | `Probability__c` | Computed read-only formula referencing standard Probability. Not suitable as a trigger field; not included in email payload |

> **Note on `Probability__c`:** This formula field overrides the standard `Probability` for Change Order opportunities in Proposal in Progress / Proposal Sent / Bid Defence stages (returns 75). It is a display/reporting aid and plays no role in SAL-2 trigger logic or email content.

---

## 4. Trigger Criteria

### Flow trigger type

| Property | Value |
|---|---|
| Object | Opportunity |
| Trigger timing | After Save |
| Trigger event | **A record is updated** (not "Created or Updated" — see OQ-1) |

### Entry conditions

Custom condition logic: **(A OR B) AND C**

| ID | Field | Operator | Value |
|---|---|---|---|
| A | `{!$Record.Opp_Probability__c}` | Equals | `75` |
| B | `{!$Record.Opp_Probability__c}` | Equals | `90` |
| C | `{!$Record__Prior.Opp_Probability__c}` | Does Not Equal | `{!$Record.Opp_Probability__c}` |

**Why A OR B:** Either target probability value independently qualifies the record.
**Why AND C:** Condition C confirms the value actually changed. Without it, any save of an already-75% or already-90% opportunity would re-send the alert. `{!$Record__Prior.Opp_Probability__c}` is a native after-save Flow variable — no helper field or SOQL query is required.

### Bypass check (first element inside the Flow)

Immediately after the entry criteria, before any other logic:

- **Element type:** Decision
- **Label:** Check Bypass Permission
- **API Name:** `Check_Bypass_Permission`
- **Description:** Exits the Flow without sending if the running user holds the Bypass_Flow custom permission. Prevents unintended sends during data loads, migration runs, and integration operations.
- **Outcome 1 — Bypassed:** `$Permission.Bypass_Flow` Equals `True` → connect to End (no email sent)
- **Default outcome — Proceed:** continue to Get Records

---

## 5. Recipients

Recipients are **fixed** — no dynamic routing matrix. All five addresses receive every qualifying alert regardless of Business Category, Service Fees, or any other field.

| Recipient | Email address |
|---|---|
| RFP / RFI inbox | rfp.rfi@astrumcro.com |
| Jordi Picas | jordi.picas@astrumcro.com |
| Cristina Lopes | cristina.lopes@astrumcro.com |
| Anthony Gibson | anthony.gibson@astrumcro.com |
| Vania Araujo | vania.araujo@astrumcro.com |

The Opportunity Owner is **not** included in the SAL-2 recipient list per the Linear issue specification. If the business later decides the Owner should also receive the alert, this is a one-line change to the Send Email element.

---

## 6. Email Template Content

### Email subject

```
Critical Stage Progression. {!Get_Opportunity_Detail.Name} moved to {!Get_Opportunity_Detail.Opp_Probability__c}%
```

> **Correction from Linear issue:** The Linear-suggested subject used `{!Opportunity.Probability}`, which references the standard prohibited field. The corrected subject uses `{!Get_Opportunity_Detail.Opp_Probability__c}`. The `%` suffix is appended as a literal character because the picklist stores bare integers (`75`, `90`).

### Email sender

Configured as the Salesforce org-wide email address. Do not send as the running user's personal address.

### Email body (plain text + HTML)

All fields use values retrieved via the `Get_Opportunity_Detail` Get Records element. The prior-value variable `{!$Record__Prior.Opp_Probability__c}` is referenced directly.

```
CRITICAL STAGE PROGRESSION ALERT

Account:                    {!Get_Opportunity_Detail.Account.Name}
Opportunity:                {!Get_Opportunity_Detail.Name}
Opportunity Code:           {!Get_Opportunity_Detail.Opportunity_Code__c}

Previous Probability:       {!$Record__Prior.Opp_Probability__c}%
New Probability:            {!Get_Opportunity_Detail.Opp_Probability__c}%
Stage:                      {!Get_Opportunity_Detail.StageName}
Service Fees:               {!Get_Opportunity_Detail.Service_Fees__c}
Close Date:                 {!Get_Opportunity_Detail.CloseDate}

Study Countries:            {!Get_Opportunity_Detail.Study_Countries__c}
Therapeutic Area:           {!Get_Opportunity_Detail.Therapeutic_Area__c}
Indication:                 {!Get_Opportunity_Detail.Indication__c}
Entities Providing Services:{!Get_Opportunity_Detail.Entities_Providing_Services__c}

Next Specific Action:       {!Get_Opportunity_Detail.Next_specific_action__c}
Date of Next Action:        {!Get_Opportunity_Detail.Date_of_next_specific_action__c}
Person Responsible:         {!Get_Opportunity_Detail.Person_responsible_for_next_action__c}

View record in Salesforce:
https://astrum--astrumpar.sandbox.my.salesforce.com/{!Get_Opportunity_Detail.Opportunity_ID_18__c}

---
This is an automated notification from Salesforce.
Please do not reply to this email.
```

### Field handling rules

| Field | If blank |
|---|---|
| `Opportunity_Code__c` | Omit the label and value row. Will be blank on Dynamics-migrated records. |
| `Indication__c` | Omit the label and value row. |
| `Next_specific_action__c` | Omit the label and value row. |
| `Date_of_next_specific_action__c` | Omit the label and value row. |
| `Person_responsible_for_next_action__c` | Omit the label and value row. |
| `Service_Fees__c` | Display as zero if the field value is 0. Omit only if null. |
| `Study_Countries__c` | Omit the label and value row if blank. If populated, renders as semicolon-separated picklist values. |
| `Entities_Providing_Services__c` | Omit the label and value row if blank. If populated, renders as semicolon-separated picklist values. |
| `{!$Record__Prior.Opp_Probability__c}` | If prior value is blank (edge case: record moved from a non-probability state), display as `—` or omit. |

### Record link note

`Opportunity_ID_18__c` is deployed in the sandbox org. The URL prefix `https://astrum--astrumpar.sandbox.my.salesforce.com/` is sandbox-specific. Before any production deployment, this prefix must be moved to a Custom Label (e.g. `Salesforce_Base_URL`) so the Flow does not require modification when promoted. See OD-02.

---

## 7. Duplicate-Send Prevention Design

### Approach: native prior-value change detection

The Flow entry criterion C (`{!$Record__Prior.Opp_Probability__c}` Does Not Equal `{!$Record.Opp_Probability__c}`) detects whether the probability value genuinely changed on this save. This is the native after-save Flow mechanism. No helper field, no Boolean sent-flag, and no SOQL query against a log object are required.

| Scenario | Prior `Opp_Probability__c` | New `Opp_Probability__c` | Flow fires? |
|---|---|---|---|
| 50% → 75% | `50` | `75` | Yes — correct |
| 50% → 90% | `50` | `90` | Yes — correct |
| 75% → 90% | `75` | `90` | Yes — correct, new alert for new band |
| 75% → 75% (re-save, no change) | `75` | `75` | No — blocked by condition C |
| 90% → 90% (re-save, no change) | `90` | `90` | No — blocked by condition C |
| 75% → 50% (downward movement) | `75` | `50` | No — blocked by conditions A and B |
| 0% → 25% (non-target values) | `0` | `25` | No — blocked by conditions A and B |

### No sent-flag field required

The prior-value approach is sufficient for the MVP. A sent-flag Boolean field is not required.

---

## 8. Flow Design

### Flow properties

| Property | Value |
|---|---|
| Flow type | Record-Triggered Flow |
| Object | Opportunity |
| Trigger | A record is updated (after save) |
| Label | `Notify Critical Stage Progression After Save` |
| API Name | `Notify_Critical_Stage_Progression_After_Save` |
| Run mode | User (not System or System Without Sharing) |
| Description | After-save Flow. Sends an immediate Critical Stage Progression email to five fixed stakeholders when Opp_Probability__c changes to 75 or 90. Checks Bypass_Flow custom permission before executing. Part of the Orbit Opportunities notification suite — notification 2 of 14. |

### Element sequence

```
[Start — Entry Criteria]
    (A OR B) AND C:
    A: Opp_Probability__c = '75'
    B: Opp_Probability__c = '90'
    C: Prior Opp_Probability__c ≠ Current Opp_Probability__c
    Trigger: A record is updated
        │
        ▼
[Decision: Check_Bypass_Permission]
    Bypassed (Bypass_Flow = true)  → [End: Bypassed]
    Proceed (default)              ↓
        │
        ▼
[Get Records: Get_Opportunity_Detail]
    Retrieve Opportunity with cross-object and custom fields
        │
        ▼
[Send Email: Send_Critical_Stage_Alert]
    To: 5 fixed recipients
    Subject: Critical Stage Progression. {Name} moved to {Opp_Probability__c}%
    Body: all 16 payload fields (see Section 6)
    [Fault Path → End: Send_Fault]
        │
        ▼
[End: Flow_Complete]
```

### Element specifications

**Check_Bypass_Permission**
- Type: Decision
- Description: Exits the Flow without sending if the running user holds the Bypass_Flow custom permission. Prevents unintended sends during data loads and integration runs. Required by CLAUDE.md hard rule.
- Outcome 1 — Bypassed: `$Permission.Bypass_Flow` Equals `True` → End: Bypassed
- Default outcome — Proceed: connect to Get_Opportunity_Detail

**Get_Opportunity_Detail**
- Type: Get Records
- Description: Retrieves the Opportunity record with cross-object Account.Name and all custom fields needed for the email body. Required because cross-object fields are not always reliably available directly on the trigger record in after-save context.
- Object: Opportunity
- Filter: `Id` Equals `{!$Record.Id}`
- Store: Automatically store all fields
- Run mode: User context

**Send_Critical_Stage_Alert**
- Type: Send Email (core Flow action)
- Description: Sends the Critical Stage Progression alert to all five fixed recipients. Fires when Opp_Probability__c has moved into 75 or 90 from any other value on an update.
- Subject: `Critical Stage Progression. {!Get_Opportunity_Detail.Name} moved to {!Get_Opportunity_Detail.Opp_Probability__c}%`
- Body: See Section 6
- Recipients (To): rfp.rfi@astrumcro.com; jordi.picas@astrumcro.com; cristina.lopes@astrumcro.com; anthony.gibson@astrumcro.com; vania.araujo@astrumcro.com
- Sender: Org-wide email address
- Fault path: → End: Send_Fault

**End: Bypassed**
- Description: Flow exited because running user holds the Bypass_Flow custom permission. No email sent. Opportunity save completes normally.

**End: Send_Fault**
- Description: Fault path from Send_Critical_Stage_Alert. Records fault message for debugging. Does not prevent the Opportunity record save from completing. Do not rethrow — a failed email send must not roll back the DML.

**End: Flow_Complete**
- Description: Normal exit after email successfully sent.

---

## 9. Blockers

No blockers prevent the Flow XML from being written or tested in sandbox. The two open questions have safe defaults.

| ID | Item | Severity | Owner | Impact |
|---|---|---|---|---|
| OQ-1 | **Initial creation trigger.** Business has not confirmed whether creating an Opportunity directly at 75% or 90% should fire the alert. Current design: trigger set to "A record is updated" — creation excluded. | Low | Commercial | If creation should trigger, change the Flow trigger event to "A record is created or updated". Entry condition C (`Prior Does Not Equal Current`) will then evaluate `null ≠ '75'` = true, so the Flow fires on creation naturally. No other changes needed. |
| OQ-2 | **Notification log / queue object.** Programme-wide decision on whether a reusable log object is needed for digest-based notifications. Does not affect SAL-2 (immediate alert, no digest staging). | None for SAL-2 | Solution Architect | Digest notifications (SAL-3, SAL-5, SAL-6, SAL-7) will need this decided before they are built. SAL-2 can be activated without it. |

---

## 10. Test Cases

All tests must be run in the sandbox `astrum--astrumpar` with the Flow in an active state. Do not test against production.

### 10.1 Happy path

| ID | Setup | Action | Expected result | Pass criteria |
|---|---|---|---|---|
| HP-01 | Open Opportunity with `Opp_Probability__c = 50` | Change `Opp_Probability__c` to `75`, save | One email sent immediately to all five recipients | Exactly one email received by each of the five addresses. Subject contains Opportunity name and "75%". Body contains Previous Probability 50, New Probability 75. Record link works. |
| HP-02 | Open Opportunity with `Opp_Probability__c = 50` | Change `Opp_Probability__c` to `90`, save | One email sent immediately to all five recipients | Subject shows "90%". Body shows Previous 50, New 90. |
| HP-03 | Open Opportunity with `Opp_Probability__c = 75` | Change `Opp_Probability__c` to `90`, save | One email sent immediately | Subject shows "90%". Body shows Previous 75, New 90. Confirms 75→90 progression sends a new alert. |
| HP-04 | Open Opportunity with `Opp_Probability__c = 75` and blank `Opportunity_Code__c` | Change `Opp_Probability__c` to `90`, save | Email sent. Opportunity Code row omitted from body. No Flow fault. | No blank label row in email. No error on the record. |
| HP-05 | Open Opportunity with `Opp_Probability__c = 50` and several blank fields (Indication, Next Specific Action, Date of Next Action, Person Responsible) | Change `Opp_Probability__c` to `75`, save | Email sent. All blank fields omitted from body. No Flow fault. | No empty label rows. All five populated fields render correctly. |
| HP-06 | Open Opportunity with `Opp_Probability__c = 25` | Change `Opp_Probability__c` to `75`, save | One email sent | Non-adjacent probability jump (25→75) fires alert correctly. |

### 10.2 Idempotency — duplicate-send prevention

| ID | Setup | Action | Expected result | Pass criteria |
|---|---|---|---|---|
| IDEM-01 | Opportunity already at `Opp_Probability__c = 75` | Edit any other field (e.g. Next Specific Action), save | No email sent | Zero emails triggered. Flow entry condition C blocks execution. |
| IDEM-02 | Opportunity already at `Opp_Probability__c = 90` | Save the record with no changes | No email sent | Zero emails triggered. |
| IDEM-03 | Opportunity moves 75% → 50% (downward) | Change `Opp_Probability__c` to `50`, save | No email sent | Downward movement does not trigger. Conditions A and B block execution. |
| IDEM-04 | Opportunity moves 25% → 50% (non-target values) | Change `Opp_Probability__c` to `50`, save | No email sent | Neither trigger value is matched. |

### 10.3 Bypass

| ID | Setup | Action | Expected result | Pass criteria |
|---|---|---|---|---|
| BYP-01 | Assign `Bypass_Flow` custom permission to test user. Open Opportunity at `Opp_Probability__c = 50`. | Log in as bypass user. Change `Opp_Probability__c` to `75`, save. | No email sent | Flow exits at bypass check. Zero emails. Opportunity saves successfully. |
| BYP-02 | Remove `Bypass_Flow` permission from test user | Repeat HP-01 | Email sent normally | Flow proceeds past bypass check and sends correctly. |

### 10.4 Creation edge case (OQ-1)

| ID | Setup | Action | Expected result | Pass criteria |
|---|---|---|---|---|
| CRE-01 | Default design (trigger = "Updated only") | Create a new Opportunity directly at `Opp_Probability__c = 75` via UI or API | No email sent | Flow does not fire on creation. |
| CRE-02 | If OQ-1 is resolved to include creation: change trigger to "Created or Updated" | Create a new Opportunity at `Opp_Probability__c = 75` | One email sent | Flow fires because Prior = null ≠ "75". Document observed behaviour and confirm with business. |

### 10.5 Exit criteria for sandbox activation

All of the following must be true before the Flow is activated in the sandbox:

| Criterion | Target |
|---|---|
| All HP tests pass | 6 of 6 |
| All IDEM tests pass | 4 of 4 |
| All BYP tests pass | 2 of 2 |
| CRE-01 passes (default creation-exclusion design) | 1 of 1 |
| Zero unexpected emails during a 24-hour monitoring window after activation | 0 unexpected sends |

---

## 11. Deployment Plan

Prerequisites marked ✓ are already complete.

| Step | Action | Owner | Status |
|---|---|---|---|
| P-01 | Deploy `Bypass_Flow` custom permission | Salesforce Admin | ✓ Done — 25 Apr 2026 |
| P-02 | Deploy `Opportunity_ID_18__c` formula field | Salesforce Admin | ✓ Done — 25 Apr 2026 |
| P-03 | Write Flow XML: `Notify_Critical_Stage_Progression_After_Save.flow-meta.xml` | Salesforce Admin / Developer | Not started |
| P-04 | Deploy Flow in **inactive** state to sandbox | Salesforce Admin | Not started |
| P-05 | Run full test suite (Section 10) in sandbox | QA / Salesforce Admin | Not started |
| P-06 | Obtain sign-off on test results from BD Lead and Solution Architect | BD Lead / Solution Architect | Not started |
| P-07 | Activate Flow in sandbox | Salesforce Admin | Not started |
| P-08 | Monitor first 5 real qualifying Opportunity updates in sandbox. Confirm emails received by all five recipients. | Salesforce Admin / BD Lead | Not started |
| P-09 | Record activation date, approver names, and first-event confirmation in the validation evidence pack | Salesforce Admin | Not started |

### Deployment command (Step P-04)

```bash
sf project deploy start \
  --source-dir force-app/main/default/flows/Notify_Critical_Stage_Progression_After_Save.flow-meta.xml \
  --target-org amit.kumar@astrumcro.com.astrumpar
```

The Flow will be deployed in an inactive state. Activation is a separate manual step in Setup > Flows after testing is complete.

---

## 12. Rollback Plan

### If a problem is found after activation

The Flow can be deactivated instantly from Setup > Flows without data loss or record impact. Deactivation does not recall emails already sent, but immediately stops any further sends.

**Rollback steps:**

1. In Setup, navigate to Flows
2. Find `Notify_Critical_Stage_Progression_After_Save`
3. Click Deactivate
4. Confirm deactivation

No data migration, no record changes, and no schema changes are required to roll back. The custom permission and formula field deployed in prerequisites are harmless if left in place — they have no effect on any record or automation until a Flow references them.

### If the deployment itself fails

The `sf project deploy start` command uses `rollbackOnError: true`. If the Flow XML fails to deploy, the org is automatically returned to its pre-deployment state. No manual rollback is needed.

### Rollback scope

| Component | Rollback possible? | Method |
|---|---|---|
| `Notify_Critical_Stage_Progression_After_Save` Flow | Yes | Deactivate in Setup > Flows |
| `Bypass_Flow` custom permission | Yes (if needed) | Delete via Setup > Custom Permissions |
| `Opportunity_ID_18__c` formula field | Yes (if needed) | Delete via Setup > Object Manager > Opportunity > Fields. No data stored. |
| Emails already sent | No | Emails cannot be recalled once delivered |

---

## 13. Open Decisions

| ID | Summary | Owner | Build impact |
|---|---|---|---|
| OD-01 | **Creation trigger (OQ-1).** Does creating an Opportunity directly at 75% or 90% trigger the alert? Current default: No (trigger = updated records only). To include creation: change trigger event to "Created or Updated" — no other Flow changes needed. | Commercial | Low — safe default in place. Can change post-activation if business confirms. |
| OD-02 | **Production-safe record link.** Current design hardcodes the sandbox URL prefix. Custom Label `Salesforce_Base_URL` recommended before any production promotion. | Solution Architect | None for sandbox build. Must resolve before production. |
| OD-03 | **Notification log object (OQ-2).** Programme-wide decision on shared log object for digest notifications. Does not affect SAL-2. | Solution Architect | None for SAL-2. |

---

## 14. Business Decision Pack

SAL-2 has no hard blockers requiring business sign-off before build begins. The two decisions below are low-impact confirmations that can be received during or after the sandbox build.

---

### BD-01 — Creation trigger scope

**Decision required:** When a new Opportunity is created directly at `Opp_Probability__c = 75` or `90` (not via an update), should the Critical Stage Progression alert fire?

**Options:**

| Option | Outcome | Flow change required |
|---|---|---|
| A — Exclude creation (default) | Only updates trigger the alert. A brand-new Opportunity at 75% does not send. | None — current design |
| B — Include creation | Creating an Opportunity at 75% or 90% also fires the alert. | Change trigger event from "A record is updated" to "A record is created or updated". Entry condition C (prior ≠ current) evaluates null ≠ "75" = true and fires naturally. |

**Impact if not decided:** Default (Option A — exclude creation) is in effect. No build is blocked.

**Owner:** Commercial

---

### BD-02 — Production record link design

**Decision required:** The email body constructs the Salesforce record link using a hardcoded sandbox URL prefix. Before any production deployment, the prefix must be externalised.

**Options:**

| Option | Approach |
|---|---|
| A — Custom Label (recommended) | Create `Salesforce_Base_URL` Custom Label. Flow references `{!$Label.Salesforce_Base_URL}`. Update label value per environment. |
| B — Accept hardcoded URL for now | Proceed with sandbox URL hardcoded. Document as technical debt. Manual update required before any production promotion. |

**Impact if not decided:** Option B (hardcoded URL) applies by default for the sandbox build. Must be resolved before production.

**Owner:** Solution Architect

---

*PRD v1.0 — Astrum Orbit Programme — SAL-2 Critical Stage Progression Alert*
*Flow may be built and tested in sandbox immediately. Activate only after all Section 10.5 exit criteria are met.*
*Business Decision Pack: Section 14. No external stakeholder document required — no hard blockers.*
