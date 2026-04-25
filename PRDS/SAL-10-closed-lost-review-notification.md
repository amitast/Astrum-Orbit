# SAL-10 — Opportunity Closed Lost Review Notification
## Implementation PRD

| Field | Value |
|---|---|
| Linear Issue | SAL-10 |
| Notification Number | 10 of 14 |
| Programme | Astrum Orbit |
| Workstream | Sales Cloud — Opportunity Notifications |
| Author | Amit Kumar (Salesforce Admin) |
| PRD Version | 1.0 |
| Date | 25 April 2026 |
| Status | Draft — awaiting BD5 sign-off before build |
| Schema Authority | Astrum__Objects_Fields_1.xlsx |
| Org | astrum--astrumpar.sandbox.my.salesforce.com |

---

## Build Status

> **BLOCKED FOR ACTIVE BUILD / ACTIVATION**
>
> Partially unblocked: Phase I Unit and Phase I-NIS recipient matrices have now been provided. Remaining blockers relate to S&PS routing, other active Business Category values, fallback routing, trigger-stage decision, Lost Reason field confirmation, and production-safe record link design.
>
> No Flow XML, email alert, or deployment-ready automation may be created or activated until all remaining blockers in Section 9 are resolved and signed off in writing.
>
> | Category | Permitted |
> |---|---|
> | Safe work | PRD updates, schema validation, org field queries, documentation, design decisions |
> | Unsafe work | Writing Flow XML, creating email alerts, deploying any automation, activating any Flow |
>
> SAL-10 is not ready for active Flow build. Documentation and design can continue. Active Flow build and activation remain blocked until all recipient coverage and trigger-stage decisions are approved in writing.
>
> See Section 14 (Business Decision Pack) for the exact decisions required before build can proceed.

---

## 1. Objective

Build a record-triggered Salesforce Flow that sends an immediate review email to the correct stakeholders the first time an Opportunity transitions into the `Closed Lost` stage. The email surfaces the key commercial details required for a post-loss review: account, deal value, loss reason, and close date.

This notification is part of a suite of 14 Opportunity pipeline notifications. It sits in the first build wave alongside notifications 2 (Critical Stage Progression) and 9 (Closed Won), which have the cleanest trigger logic and deliver the most immediate commercial value.

The primary commercial purpose is to ensure that every lost Opportunity triggers a timely internal review conversation, prevent losses from being silently filed away, and feed the loss-reason data into pipeline quality improvement over time.

---

## 2. Confirmed Requirements

Source: SAL-10 Linear issue, Astrum Project Memory Pack v1.0, Orbit Opportunities Notification Requirements Specification.

### Functional requirements

| # | Requirement | Source |
|---|---|---|
| FR-01 | Send one email immediately when an Opportunity's StageName first changes to `Closed Lost`. | Linear SAL-10 |
| FR-02 | Do not send if the Opportunity is already at `Closed Lost` and is saved again without a stage change. | Linear SAL-10, Memory Pack §10 NEVER |
| FR-03 | Determine recipients dynamically using the Business Category and Service Fees matrix, plus Opportunity Owner always. | Linear SAL-10 |
| FR-04 | Use `Opportunity_Code__c` as the primary deal identifier in the email body. | Memory Pack §10 ALWAYS |
| FR-05 | Use `Opportunity_ID_18__c` to generate the Salesforce record link in the email body. | Memory Pack §10 ALWAYS |
| FR-06 | Do not reference the standard Probability field. | Memory Pack §§4, 9 NEVER |
| FR-07 | Do not include `Study_Countries__c` in the email payload. | User instruction; Memory Pack §10 NEVER (data quality risk) |
| FR-08 | The Flow must check the `Bypass_Flow` custom permission before executing. If the running user holds this permission, exit without sending. | CLAUDE.md hard rule |
| FR-09 | The Flow must run in User Context, not System or System Without Sharing mode. | Memory Pack §6 NEVER |
| FR-10 | The S&PS Business Category branch must not send until a recipient matrix is formally confirmed. Build a stub branch that exits cleanly. | Memory Pack §10 NEVER; BD5 open decision |

### Non-functional requirements

| # | Requirement |
|---|---|
| NFR-01 | Flow Label: `Notify Closed Lost Review After Save`. API Name: `Notify_Closed_Lost_Review_After_Save`. Naming convention required by CLAUDE.md. |
| NFR-02 | All Flow elements must have descriptions. CLAUDE.md hard rule. |
| NFR-03 | Flow must not be activated in this org until all blockers in Section 9 are resolved. |
| NFR-04 | Flow must never be deployed to a production org. Sandbox only per CLAUDE.md hard rule. |

---

## 3. Object and Field Mapping

Object: **Opportunity**
All fields validated against the live sandbox org on 25 April 2026.

### Email payload fields

| Label | API Name | Data Type | Org Status | Notes |
|---|---|---|---|---|
| Opportunity Name | `Name` | Text(120) | Confirmed | Used in email subject and body |
| Account Name | `Account.Name` | Cross-object Text | Confirmed | Via AccountId lookup |
| Opportunity Code | `Opportunity_Code__c` | Text(255) | Confirmed | Primary deal identifier. Will be blank on Dynamics-migrated records — email must handle gracefully |
| Service Fees | `Service_Fees__c` | Currency(18,0) | Confirmed | Used in recipient routing threshold and email body |
| Loss Reason | `Loss_Reason__c` | Picklist | Confirmed | API name validated. 9 active values confirmed (see Section 3.1) |
| Est. Close Date | `CloseDate` | Date | Confirmed | |
| Description | `Description` | Long Text Area(32000) | Confirmed | Risk: unreviewed free-text content in a business email. See Open Decision OD-04 |
| Salesforce Record Link | `Opportunity_ID_18__c` | Formula Text | Deployed 25 Apr 2026 | `CASESAFEID(Id)`. Used to construct the clickable record URL |
| Opportunity Owner | `OwnerId` / `Owner.Email` | Lookup(User) | Confirmed | Always included in recipient list |
| Business Category | `Business_Category__c` | Picklist | Confirmed | Used for recipient routing only — not in email body |

### Trigger and routing fields

| Label | API Name | Data Type | Org Status | Notes |
|---|---|---|---|---|
| Stage | `StageName` | Picklist | Confirmed | Trigger field. Prior value used for idempotency |
| Business Category | `Business_Category__c` | Picklist | Confirmed | Recipient routing — 6 active values (see Section 3.2) |
| Service Fees | `Service_Fees__c` | Currency(18,0) | Confirmed | Recipient routing threshold |

### Infrastructure

| Component | API Name | Org Status |
|---|---|---|
| Bypass custom permission | `Bypass_Flow` | Deployed 25 Apr 2026 |
| 18-char record ID formula | `Opportunity_ID_18__c` | Deployed 25 Apr 2026 |

> **Currency assumption:** Confirmed org default currency is EUR / Euros. All `Service_Fees__c` threshold values in SAL-10 are EUR-denominated unless explicitly stated otherwise.

### 3.1 Loss_Reason__c confirmed picklist values

All 9 values confirmed active in org:

`Astrum Capabilities` · `Cancelled` · `Cost` · `Declined to Bid` · `Geographical Coverage` · `Lost to Follow-up` · `Lost to Incumbent` · `Project Team Experience` · `Therapeutic Experience`

### 3.2 Business_Category__c confirmed picklist values

**Warning:** The org contains 6 active values. Only 3 are documented in the Memory Pack. All 6 must be handled by the Flow's decision logic.

| Value | Memory Pack | Recipient Matrix Status |
|---|---|---|
| `Phase I Unit` | Documented | Pending — thresholds and email addresses required from business |
| `Phase I-NIS` | Documented | Pending — thresholds and email addresses required from business |
| `S&PS` | Documented | **Blocked — BD5 open decision** |
| `All Other Projects (Phase I - NIS)` | Not documented | **Blocked — no matrix defined** |
| `Phase I Clinical Conduct Portugal` | Not documented | **Blocked — no matrix defined** |
| `Site & Patient Services (CRP & MissionTEC)` | Not documented | **Blocked — no matrix defined** |

### 3.3 StageName values relevant to this notification

| Value | Active | Role |
|---|---|---|
| `Closed Lost` | Yes | **Trigger target** |
| `Lost/Cancelled/Declined to Bid` | Yes | **Ambiguous** — see Open Decision OD-01. May also represent a lost outcome |

---

## 4. Trigger Criteria

### Flow trigger type

- **Object:** Opportunity
- **Trigger timing:** After Save
- **Trigger event:** A record is created or updated

### Entry criteria (Flow entry condition)

Both conditions must be true for the Flow to proceed past the entry check:

| # | Condition | Operator | Value |
|---|---|---|---|
| 1 | `StageName` | Equals | `Closed Lost` |
| 2 | `{!$Record__Prior.StageName}` | Does Not Equal | `Closed Lost` |

**Why both conditions:** Condition 1 confirms the record is now Closed Lost. Condition 2 confirms it was not already Closed Lost before this save, preventing a duplicate send if the record is edited while already closed.

`{!$Record__Prior.StageName}` is a native Flow variable available in after-save record-triggered Flows. No helper field or Field History query is required.

### Bypass check (first element inside the Flow)

Immediately after the entry criteria, before any other logic:

- **Element type:** Decision
- **Label:** Check Bypass Permission
- **API Name:** Check_Bypass_Permission
- **Description:** Exits the Flow without sending if the running user holds the Bypass_Flow custom permission. Prevents unintended sends during data loads and integration runs.
- **Outcome 1 — Bypassed:** `$Permission.Bypass_Flow` Equals `True` → connect to End (no email sent)
- **Default outcome — Proceed:** continue to Business Category decision

---

## 5. Recipient Routing Approach

### Routing logic summary

Recipients are determined by a two-level decision:

1. **Level 1:** Branch on `Business_Category__c`
2. **Level 2 (within Phase I Unit and Phase I-NIS):** Branch on `Service_Fees__c` threshold

Opportunity Owner (`Owner.Email`) is always added to the recipient list regardless of Business Category or Service Fees.

### Phase I Unit recipient matrix

Recipient matrix provided. Pending stakeholder confirmation before build. See Section 5a for full detail.

Threshold: €150,000 on `Service_Fees__c` (EUR).

| Condition | Recipient Set |
|---|---|
| `Service_Fees__c` < €150,000 | tom.frearson, Catherine.Canales, Opportunity Owner, Ricardo.Cunha, rfp.rfi, cristina.lopes, anthony.gibson |
| `Service_Fees__c` >= €150,000 | tom.frearson, Catherine.Canales, Opportunity Owner, cristina.lopes, Ricardo.Cunha, rfp.rfi, anthony.gibson |

**Status: Routing provided. Ready for stakeholder confirmation.**

> **Normalisation note:** `Cristina.lopes@astrumcro.com` and `cristina.lopes@astrumcro.com` are the same mailbox. Normalised to `cristina.lopes@astrumcro.com` throughout. After normalisation, both Phase I Unit routing rules contain an identical recipient list — only the ordering differs. Stakeholder must confirm whether this is intended or whether the threshold distinction should be removed, or whether a different recipient set was intended for the >= €150,000 rule.

### Phase I-NIS recipient matrix

Recipient matrix provided. Pending stakeholder confirmation before build. See Section 5a for full detail.

Threshold: €500,000 on `Service_Fees__c` (EUR).

| Condition | Recipient Set |
|---|---|
| `Service_Fees__c` < €500,000 | tom.frearson, Catherine.Canales, Opportunity Owner, rfp.rfi, jordi.picas, cristina.lopes, anthony.gibson |
| `Service_Fees__c` >= €500,000 | tom.frearson, Catherine.Canales, Opportunity Owner, cristina.lopes, jordi.picas, anthony.gibson, rfp.rfi |

**Status: Routing provided. Ready for stakeholder confirmation.**

> **Normalisation note:** Same casing normalisation applied as Phase I Unit. After normalisation, both Phase I-NIS routing rules contain an identical recipient list — only the ordering differs. Stakeholder must confirm whether this is intended or whether a different recipient set was intended for the >= €500,000 rule.

> **Currency note:** No currency conversion is required. The Flow compares `Service_Fees__c` numeric values directly against `150000` (Phase I Unit) and `500000` (Phase I-NIS). Email display and documentation use €150,000 and €500,000 respectively.
>
> **Multi-currency build note:** If multi-currency is enabled in this org in future, SAL-10 threshold evaluation must be revalidated. The current design assumes the org default currency (EUR) applies to all `Service_Fees__c` values at the point of threshold evaluation.

### S&PS — STUB

**Status: BLOCKED — BD5.** No recipient matrix defined. The Flow will include a stub branch for `S&PS` that exits cleanly without sending an email and without throwing an error. This branch must remain as a stub until BD5 is formally resolved and signed off.

### Undocumented Business Category values — STUB

The three values below are active in the org but have no documented recipient matrix. Each gets a stub branch identical to S&PS: exit cleanly, no email sent, no error thrown.

- `All Other Projects (Phase I - NIS)`
- `Phase I Clinical Conduct Portugal`
- `Site & Patient Services (CRP & MissionTEC)`

**Status: BLOCKED** — these values must be raised with Commercial as part of resolving BD5.

### Default / blank Business Category — STUB

If `Business_Category__c` is blank or contains an unexpected value, the Flow exits cleanly via the default path. No email is sent. This prevents silent failures on records with incomplete data.

---

## 5a. Confirmed Recipient Matrix Provided After PRD Review

Matrix received after initial PRD review. Recorded here verbatim (with normalisation applied) pending formal stakeholder confirmation. This section does not authorise build — it captures the provided routing for design and confirmation purposes only.

### Normalisation applied

| Raw address supplied | Normalised form | Reason |
|---|---|---|
| `Cristina.lopes@astrumcro.com` | `cristina.lopes@astrumcro.com` | Same mailbox as `cristina.lopes@astrumcro.com`. Email addresses are case-insensitive. Lowercase form used throughout. |

All other addresses preserved exactly as supplied.

### Confirmed matrix table

| Business Category | Service Fees condition | Recipients (static) | Dynamic recipient | Build status |
|---|---|---|---|---|
| Phase I Unit | `Service_Fees__c` < €150,000 | tom.frearson@astrumcro.com, Catherine.Canales@astrumcro.com, Ricardo.Cunha@astrumcro.com, rfp.rfi@astrumcro.com, cristina.lopes@astrumcro.com, anthony.gibson@astrumcro.com | Opportunity Owner | Routing provided. Ready for stakeholder confirmation. |
| Phase I Unit | `Service_Fees__c` >= €150,000 | tom.frearson@astrumcro.com, Catherine.Canales@astrumcro.com, cristina.lopes@astrumcro.com, Ricardo.Cunha@astrumcro.com, rfp.rfi@astrumcro.com, anthony.gibson@astrumcro.com | Opportunity Owner | Routing provided. Ready for stakeholder confirmation. |
| Phase I-NIS | `Service_Fees__c` < €500,000 | tom.frearson@astrumcro.com, Catherine.Canales@astrumcro.com, rfp.rfi@astrumcro.com, jordi.picas@astrumcro.com, cristina.lopes@astrumcro.com, anthony.gibson@astrumcro.com | Opportunity Owner | Routing provided. Ready for stakeholder confirmation. |
| Phase I-NIS | `Service_Fees__c` >= €500,000 | tom.frearson@astrumcro.com, Catherine.Canales@astrumcro.com, cristina.lopes@astrumcro.com, jordi.picas@astrumcro.com, anthony.gibson@astrumcro.com, rfp.rfi@astrumcro.com | Opportunity Owner | Routing provided. Ready for stakeholder confirmation. |
| S&PS | Any | Not provided | — | **Blocked — BD5. Stub only.** |
| All Other Projects (Phase I - NIS) | Any | Not provided | — | **Blocked — no matrix defined. Stub only.** |
| Phase I Clinical Conduct Portugal | Any | Not provided | — | **Blocked — no matrix defined. Stub only.** |
| Site & Patient Services (CRP & MissionTEC) | Any | Not provided | — | **Blocked — no matrix defined. Stub only.** |
| Blank / unrecognised | Any | Not provided | — | **Blocked — fallback rule not confirmed. Stub only.** |

### Identical-recipient flag requiring stakeholder confirmation

After normalisation, the two Phase I Unit routing rules produce identical recipient lists (same 6 static addresses + Owner, different ordering only). The same is true for both Phase I-NIS rules.

**Stakeholder must confirm one of:**
- A — The threshold distinction is intentional even though the same people are notified at both levels. The threshold is retained in the Flow for future-proofing.
- B — The threshold distinction should be removed. A single flat recipient list per Business Category is sufficient.
- C — A data entry error occurred. The correct >= threshold recipient list should be resupplied.

Until this is confirmed, the design retains both threshold branches as supplied, with a code comment flagging the duplication.

### Technical design note

The provided recipient matrix should be implemented as configurable routing — preferably using a Custom Metadata Type (e.g. `Notification_Recipient__mdt`) — rather than hard-coded email addresses in Flow Send Email elements. A Custom Metadata approach allows the recipient list to be updated without redeploying the Flow and without a code change request.

A Flow-only MVP (hard-coded addresses in Send Email elements) is acceptable if the project explicitly chooses that pattern for the initial build, provided the limitation is documented and the team accepts that any recipient change requires a Flow edit and redeployment.

This decision must be made before the Flow XML is written.

---

## 6. Email Template Content

### Email subject

```
Closed Lost Review. {!Opportunity.Name}
```

### Email sender

Configured as the Salesforce org-wide email address. Do not send as the running user's personal address.

### Email body (plain text + HTML)

The email body uses only fields confirmed in the org. Blank fields are omitted from the rendered output rather than shown as empty labels.

```
CLOSED LOST REVIEW

Account:           {!Opportunity.Account.Name}
Opportunity:       {!Opportunity.Name}
Opportunity Code:  {!Opportunity.Opportunity_Code__c}
Service Fees:      {!Opportunity.Service_Fees__c}
Loss Reason:       {!Opportunity.Loss_Reason__c}
Close Date:        {!Opportunity.CloseDate}

Description:
{!Opportunity.Description}

View record in Salesforce:
https://astrum--astrumpar.sandbox.my.salesforce.com/{!Opportunity.Opportunity_ID_18__c}

---
This is an automated notification from Salesforce.
Please do not reply to this email.
```

### Field handling rules

| Field | If blank |
|---|---|
| `Opportunity_Code__c` | Omit the label and value row. Will be blank on Dynamics-migrated records. |
| `Loss_Reason__c` | Omit the label and value row. Do not write "blank" or "unknown". |
| `Service_Fees__c` | Display as zero if the field value is 0. Omit only if null. |
| `Description` | Omit the section entirely if blank. See OD-04 for approval status. |

### Record link note

`Opportunity_ID_18__c` is now deployed in the sandbox org. The URL prefix `https://astrum--astrumpar.sandbox.my.salesforce.com/` is sandbox-specific. Before any production deployment, this prefix must be moved to a Custom Label (e.g. `Salesforce_Base_URL`) so the Flow does not require modification when promoted.

---

## 7. Duplicate-Send Prevention Design

### Approach: native prior-value check

The Flow entry criterion uses `{!$Record__Prior.StageName}` to detect whether this is a genuine first transition into `Closed Lost`. This is the native after-save Flow mechanism and requires no additional fields, objects, or SOQL queries.

| Scenario | Prior StageName | New StageName | Flow fires? |
|---|---|---|---|
| First closure | Any stage except `Closed Lost` | `Closed Lost` | Yes — correct |
| Re-save at Closed Lost | `Closed Lost` | `Closed Lost` | No — blocked by entry criterion |
| Field edit on a Closed Lost record | `Closed Lost` | `Closed Lost` | No — blocked by entry criterion |
| Record re-opened then re-closed | Any open stage | `Closed Lost` | Yes — intentional: this is a new closure event |

### Re-opened and re-closed scenario

If an Opportunity is moved from `Closed Lost` back to an open stage and subsequently closed again, the Flow fires on the second closure. This is the correct commercial behaviour — a second closure is a distinct event and stakeholders need to know. If the business requires suppressing second-closure sends, a Boolean helper field (`Closed_Lost_Notif_Sent__c`) can be added as a future enhancement. See Open Decision OD-05.

### No sent-flag field required for MVP

The prior-value approach is sufficient for the MVP. A sent-flag field is not required unless OD-05 is resolved in favour of suppressing re-closure sends.

---

## 8. Flow Design

### Flow properties

| Property | Value |
|---|---|
| Flow type | Record-Triggered Flow |
| Object | Opportunity |
| Trigger | A record is updated (after save) |
| Label | `Notify Closed Lost Review After Save` |
| API Name | `Notify_Closed_Lost_Review_After_Save` |
| Run mode | User (not System or System Without Sharing) |
| Description | After-save Flow. Sends an immediate Closed Lost review email to the configured recipient matrix on first transition to Closed Lost. Checks Bypass_Flow custom permission before executing. Part of the Orbit Opportunities notification suite — notification 10 of 14. |

### Element sequence

```
[Start — Entry Criteria]
    StageName = 'Closed Lost'
    AND Prior StageName ≠ 'Closed Lost'
        │
        ▼
[Decision: Check_Bypass_Permission]
    Bypassed → [End]
    Proceed  ↓
        │
        ▼
[Get Records: Get_Opportunity_Detail]
    Retrieve Opportunity with cross-object fields:
    Account.Name, Owner.Email, Owner.Name
        │
        ▼
[Decision: Route_By_Business_Category]
    Phase I Unit                        → [Decision: Phase_I_Unit_Threshold]
    Phase I-NIS                         → [Decision: Phase_I_NIS_Threshold]
    S&PS                                → [End — stub, no send]
    All Other Projects (Phase I - NIS)  → [End — stub, no send]
    Phase I Clinical Conduct Portugal   → [End — stub, no send]
    Site & Patient Services (CRP & MTC) → [End — stub, no send]
    Default (blank or unknown)          → [End — stub, no send]
        │
        ▼ (Phase I Unit path)
[Decision: Phase_I_Unit_Threshold]
    Below threshold → [Send Email: Phase_I_Unit_Standard]
    At or above     → [Send Email: Phase_I_Unit_Expanded]
        │
        ▼ (Phase I-NIS path)
[Decision: Phase_I_NIS_Threshold]
    Below threshold → [Send Email: Phase_I_NIS_Standard]
    At or above     → [Send Email: Phase_I_NIS_Expanded]
        │
        ▼
[Fault Path on each Send Email element]
    → [End — log fault message, do not rethrow]
```

### Element specifications

**Get_Opportunity_Detail**
- Type: Get Records
- Description: Retrieves Opportunity with cross-object Account.Name and Owner fields needed for the email body. Required because cross-object fields are not always available directly on the trigger record in after-save context.
- Object: Opportunity
- Filter: Id Equals `{!$Record.Id}`
- Store: Automatically store all fields
- Run mode: User context

**Route_By_Business_Category**
- Type: Decision
- Description: Routes to the correct recipient matrix branch based on Business_Category__c. Undocumented and S&PS values route to stub End elements pending BD5 resolution.
- Condition type: Evaluate conditions in order, first true outcome wins

**Phase_I_Unit_Threshold / Phase_I_NIS_Threshold**
- Type: Decision
- Description: Applies the Service Fees threshold to select the standard or expanded recipient set. Phase I Unit threshold: 150000 (€150,000 EUR). Phase I-NIS threshold: 500000 (€500,000 EUR). Thresholds are EUR-denominated numeric values; no currency conversion is performed.
- Condition (Phase I Unit): `{!Get_Opportunity_Detail.Service_Fees__c}` Less Than `150000`
- Condition (Phase I-NIS): `{!Get_Opportunity_Detail.Service_Fees__c}` Less Than `500000`

**Send Email elements (one per routing outcome)**
- Type: Send Email action (core Flow action)
- HITL mode: Autonomous (automated send, no user confirmation)
- Subject: `Closed Lost Review. {!Get_Opportunity_Detail.Name}`
- Body: See Section 6
- Recipient fields: static named recipients for the routing outcome + `{!Get_Opportunity_Detail.Owner.Email}`
- Description on each element: identifies which matrix branch and recipient set this element serves

**Stub End elements (S&PS and undocumented categories)**
- Type: End element with a descriptive label
- Description: Stub for [Business Category value]. No email sent. Recipient matrix pending BD5 resolution. Do not connect to any send action until sign-off is received.

**Fault paths**
- Every Send Email element must have a fault path
- Fault path: End element (do not rethrow — a failed email send should not roll back the Opportunity save)
- Description on fault End: Records fault message for debugging. Does not prevent the Opportunity record save from completing.

---

## 9. Blockers

Nothing in this Flow may be activated until all Critical blockers are resolved.

| ID | Blocker | Severity | Owner | Impact |
|---|---|---|---|---|
| B-01 | **BD5 — S&PS recipient matrix undefined.** Memory Pack NEVER guardrail explicitly blocks build of notifications 9 and 10 until this is resolved. | Critical | Commercial | S&PS branch cannot send. Flow cannot be considered complete until resolved. |
| B-02 | **Three undocumented Business_Category__c values.** `All Other Projects (Phase I - NIS)`, `Phase I Clinical Conduct Portugal`, and `Site & Patient Services (CRP & MissionTEC)` are active in the org but have no recipient matrix defined. Each remains a stub branch. | Critical | Commercial | Same as BD5 — stub branches for all three values. |
| B-03 | **Phase I Unit and Phase I-NIS recipient matrices provided — pending stakeholder confirmation.** Matrices have been supplied (see Section 5a) but have not been formally approved by the business. Additionally, after normalisation both Phase I Unit rules and both Phase I-NIS rules produce identical recipient lists — stakeholder must confirm whether this is intended (see Section 5a identical-recipient flag). | High | Commercial | Cannot activate routing until matrices are confirmed in writing and the identical-recipient question is resolved. |
| B-04 | **`Lost/Cancelled/Declined to Bid` stage value.** This is an active StageName value in the org that is not in the Memory Pack canonical list. Business must confirm whether this value also triggers the Closed Lost review email or is explicitly excluded. | High | Commercial / Sales Ops | If it should trigger, the entry criterion must be updated to `StageName IN ('Closed Lost', 'Lost/Cancelled/Declined to Bid')`. |
| B-05 | **Fallback routing for blank or unrecognised Business_Category__c / Service_Fees__c not confirmed.** Current design exits silently on blank or unrecognised values. Business must confirm whether a fallback send or silent skip is preferred. | High | Commercial | If fallback send is required, a fallback recipient address must be provided. |
| B-06 | **`Lost Reason` field inclusion and blank-handling rule not confirmed.** `Loss_Reason__c` API name is validated in the org. Business must confirm the 9 active values are correct and whether a blank Loss Reason should block the email or allow it to send without that field. | Medium | BD Lead / Commercial | If values need updating, a picklist change is a separate task. Blank-handling rule affects email template logic. |
| B-07 | **`Description` field in email body.** `Description` is a Long Text Area(32000) containing unreviewed free-text content. Business must explicitly approve including it in a notification email before it is added to the template. | Medium | BD Lead / Commercial | If not approved, remove `Description` from the email body. The email is complete without it. |
| B-08 | **Production-safe record link design not confirmed.** Current design hardcodes the sandbox URL. Custom Label approach recommended (see Section 14 BD-07). | Low | Solution Architect | Must be resolved before any production deployment. Does not block sandbox build. |

---

## 10. Test Cases

All tests must be run in the sandbox `astrum--astrumpar` with the Flow in an active but unmonitored state. Do not test against production.

### 10.1 Happy path

| ID | Setup | Action | Expected result | Pass criteria |
|---|---|---|---|---|
| HP-01 | Open Phase I Unit Opportunity, `Service_Fees__c` below threshold, StageName = `Proposal Sent` | Change StageName to `Closed Lost`, save | One email sent to standard Phase I Unit recipient set plus Owner | Exactly one email received. Subject contains Opportunity name. Opportunity_Code__c present in body. Loss_Reason__c present if populated. Record link works. |
| HP-02 | Open Phase I Unit Opportunity, `Service_Fees__c` at or above threshold | Change StageName to `Closed Lost`, save | One email sent to expanded Phase I Unit recipient set plus Owner | Expanded recipient set used, not standard. |
| HP-03 | Open Phase I-NIS Opportunity | Change StageName to `Closed Lost`, save | One email sent to Phase I-NIS recipient set plus Owner | Correct recipient set for Phase I-NIS. |
| HP-04 | Phase I Unit Opportunity with blank `Opportunity_Code__c` (simulates migrated record) | Change StageName to `Closed Lost`, save | Email sent. Opportunity Code row omitted from body, no error | No blank label. No Flow fault. |
| HP-05 | Phase I Unit Opportunity with blank `Loss_Reason__c` | Change StageName to `Closed Lost`, save | Email sent. Loss Reason row omitted from body, no error | No blank label. No Flow fault. |
| HP-06 | Phase I Unit Opportunity with blank `Description` | Change StageName to `Closed Lost`, save | Email sent. Description section omitted, no error | No blank section heading. |

### 10.2 Idempotency — duplicate-send prevention

| ID | Setup | Action | Expected result | Pass criteria |
|---|---|---|---|---|
| IDEM-01 | Opportunity already at `Closed Lost` | Edit any other field (e.g. Description), save | No email sent | Zero emails triggered. Flow entry criterion blocks execution. |
| IDEM-02 | Opportunity already at `Closed Lost` | Save the record with no changes | No email sent | Zero emails triggered. |
| IDEM-03 | Opportunity at `Closed Lost`, re-open to `Proposal In Progress`, then re-close to `Closed Lost` | Re-close | One email sent | Email fires because this is a genuine new closure event. This is intended behaviour. |

### 10.3 Bypass

| ID | Setup | Action | Expected result | Pass criteria |
|---|---|---|---|---|
| BYP-01 | Assign `Bypass_Flow` custom permission to test user. Open Opportunity at `Proposal Sent`. | Log in as bypass user. Change StageName to `Closed Lost`, save. | No email sent | Flow exits at bypass check. Zero emails. Opportunity saves successfully. |
| BYP-02 | Remove `Bypass_Flow` permission from test user | Repeat HP-01 | Email sent normally | Flow proceeds past bypass check and sends correctly. |

### 10.4 Stub branches

| ID | Setup | Action | Expected result | Pass criteria |
|---|---|---|---|---|
| STUB-01 | Opportunity with `Business_Category__c = S&PS` | Change StageName to `Closed Lost`, save | No email sent. No Flow fault. Opportunity saves successfully. | Zero emails. No error on the record. Flow exits via stub path. |
| STUB-02 | Opportunity with `Business_Category__c = All Other Projects (Phase I - NIS)` | Change StageName to `Closed Lost`, save | No email sent. No Flow fault. | Same as STUB-01. |
| STUB-03 | Opportunity with blank `Business_Category__c` | Change StageName to `Closed Lost`, save | No email sent. No Flow fault. | Default path exits cleanly. |

### 10.5 Stage value edge cases

| ID | Setup | Action | Expected result | Pass criteria |
|---|---|---|---|---|
| EDGE-01 | Phase I Unit Opportunity at `Lost/Cancelled/Declined to Bid` | Change StageName to `Closed Lost`, save | Email sent (prior stage was not `Closed Lost`) | Flow fires correctly. |
| EDGE-02 | Opportunity being created with StageName = `Closed Lost` on creation (not an update) | Create record via UI or API at `Closed Lost` | Confirm with business whether this should trigger. Default: Flow entry criterion catches it as prior = null ≠ `Closed Lost`, so it will fire. | Document observed behaviour. Raise with business if creation-time trigger is unwanted. |

### 10.6 Exit criteria for activation

All of the following must be true before the Flow is activated in the sandbox:

| Criterion | Target |
|---|---|
| All HP tests pass | 6 of 6 |
| All IDEM tests pass | 3 of 3 |
| All BYP tests pass | 2 of 2 |
| All STUB tests pass | 3 of 3 |
| Zero unexpected emails in sandbox during a 24-hour monitoring window | 0 unexpected sends |
| BD5 and B-02 resolved (recipient matrices confirmed) | Signed off in writing |
| B-04 resolved (Lost/Cancelled/Declined to Bid decision) | Confirmed by Commercial / Sales Ops |

---

## 11. Deployment Plan

Prerequisites marked ✓ are already complete.

| Step | Action | Owner | Status |
|---|---|---|---|
| P-01 | Deploy `Bypass_Flow` custom permission | Salesforce Admin | ✓ Done — 25 Apr 2026 |
| P-02 | Deploy `Opportunity_ID_18__c` formula field | Salesforce Admin | ✓ Done — 25 Apr 2026 |
| P-03 | Obtain BD5 sign-off: recipient matrix for all 6 Business_Category__c values | Commercial | Blocked |
| P-04 | Obtain B-04 decision: confirm whether `Lost/Cancelled/Declined to Bid` triggers the notification | Commercial / Sales Ops | Blocked |
| P-05 | Obtain B-05 decision: approve or reject `Description` field in email body | BD Lead | Blocked |
| P-06 | Create Flow XML and email template content | Salesforce Admin / Developer | Not started — blocked on P-03 through P-05 |
| P-07 | Deploy Flow in **inactive** state to sandbox | Salesforce Admin | Not started |
| P-08 | Run full test suite (Section 10) in sandbox | QA / Salesforce Admin | Not started |
| P-09 | Obtain sign-off on test results from BD Lead and Solution Architect | BD Lead / Solution Architect | Not started |
| P-10 | Activate Flow in sandbox | Salesforce Admin | Not started |
| P-11 | Monitor first 5 real Closed Lost events in sandbox. Confirm emails received by correct recipients | Salesforce Admin / BD Lead | Not started |
| P-12 | Record activation date, approver names, and first-event confirmation in the validation evidence pack | Salesforce Admin | Not started |

### Deployment command (Step P-07)

```bash
sf project deploy start \
  --source-dir force-app/main/default/flows/Notify_Closed_Lost_Review_After_Save.flow-meta.xml \
  --target-org amit.kumar@astrumcro.com.astrumpar
```

The Flow will be deployed in an inactive state. Activation is a separate manual step in Setup > Flows after testing is complete.

---

## 12. Rollback Plan

### If a problem is found after activation

The Flow can be deactivated instantly from Setup > Flows without any data loss or record impact. A Flow deactivation does not roll back emails already sent, but it immediately stops any further sends.

**Rollback steps:**

1. In Setup, navigate to Flows
2. Find `Notify_Closed_Lost_Review_After_Save`
3. Click Deactivate
4. Confirm deactivation

No data migration, no record changes, and no schema changes are required to roll back. The custom permission and formula field deployed in prerequisites are harmless if left in place — they have no effect on any record or automation until a Flow references them.

### If the deployment itself fails

The `sf project deploy start` command uses `rollbackOnError: true`. If the Flow XML fails to deploy, the org is automatically returned to its pre-deployment state. No manual rollback is needed.

### Rollback scope

| Component | Rollback possible? | Method |
|---|---|---|
| `Notify_Closed_Lost_Review_After_Save` Flow | Yes | Deactivate in Setup > Flows |
| `Bypass_Flow` custom permission | Yes (if needed) | Delete via Setup > Custom Permissions. No impact unless assigned to a Permission Set |
| `Opportunity_ID_18__c` formula field | Yes (if needed) | Delete via Setup > Object Manager > Opportunity > Fields. No data is stored; formula is computed on read |
| Emails already sent | No | Emails cannot be recalled once delivered |

---

## 13. Open Decisions

All open decisions are formally captured in the Business Decision Pack (Section 14), which is the document to share with stakeholders. The table below cross-references each decision to its blocker.

| ID | Summary | Owner | Blocker | Section 14 Ref |
|---|---|---|---|---|
| OD-01 | Does `Lost/Cancelled/Declined to Bid` trigger SAL-10? | Commercial / Sales Ops | B-04 | BD-01 |
| OD-02 | Confirm all 6 active Business_Category__c values are acknowledged | Commercial | B-01, B-02 | BD-02 |
| OD-03 | **Phase I Unit and Phase I-NIS matrices provided — confirm or correct.** Resolve identical-recipient flag (see Section 5a). Provide matrices for S&PS and remaining values. | Commercial | B-03 | BD-03 |
| OD-04 | Fallback recipient logic for blank / unrecognised Business_Category__c or Service_Fees__c | Commercial | B-05 | BD-04 |
| OD-05 | Confirm Loss_Reason__c values correct, confirm blank-handling rule | BD Lead / Commercial | B-06 | BD-05 |
| OD-06 | Confirm Opportunity Owner is always included as a recipient | Commercial | Design decision | BD-06 |
| OD-07 | Production-safe record link design — Custom Label or relative URL | Solution Architect | B-08 | BD-07 |

---

## 14. Business Decision Pack

This section contains every decision the business must make before the Flow can be built. Each decision is written to be shareable directly with BD Lead and Commercial stakeholders. The companion stakeholder document is `handoff/SAL-10-business-decisions-required.md`.

---

### BD-01 — Trigger scope: Lost/Cancelled/Declined to Bid

**Decision required:** The org contains an active Opportunity stage called `Lost/Cancelled/Declined to Bid`. This stage is not in the programme's canonical stage list. Business must confirm whether this stage should also trigger the Closed Lost review email.

**Options:**

| Option | Outcome |
|---|---|
| A — Include it | Entry criterion updated to fire on both `Closed Lost` and `Lost/Cancelled/Declined to Bid`. Both stages send the review email. |
| B — Exclude it | Entry criterion fires on `Closed Lost` only. Opportunities closed via `Lost/Cancelled/Declined to Bid` receive no review email. |
| C — Retire the stage | `Lost/Cancelled/Declined to Bid` is deactivated and all affected records migrated to `Closed Lost`. Notification fires on `Closed Lost` only. This is a separate data migration task. |

**Impact if not decided:** The Flow entry criterion cannot be finalised. Build is blocked.

**Owner:** Commercial / Sales Ops
**Blocks:** Flow entry criterion (Section 4), test cases EDGE-01 and EDGE-02 (Section 10.5)

---

### BD-02 — Business Category values in scope for this notification

**Decision required:** The org contains 6 active `Business_Category__c` values. The programme's Memory Pack documents only 3. Business must confirm which values are in scope for the Closed Lost review notification and which are explicitly out of scope.

**Active values found in org on 25 April 2026:**

| Value | Programme documentation | Decision required |
|---|---|---|
| `Phase I Unit` | Documented | Confirm in scope |
| `Phase I-NIS` | Documented | Confirm in scope |
| `S&PS` | Documented | Confirm in scope or out of scope |
| `All Other Projects (Phase I - NIS)` | Not documented | Confirm in scope or out of scope |
| `Phase I Clinical Conduct Portugal` | Not documented | Confirm in scope or out of scope |
| `Site & Patient Services (CRP & MissionTEC)` | Not documented | Confirm in scope or out of scope |

**Impact if not decided:** Any value not confirmed in scope will remain a stub (no email sent) in the Flow. All 6 values are currently stubbed as out of scope.

**Owner:** Commercial
**Blocks:** BD-03 (recipient matrix), Flow decision logic (Section 8)

---

### BD-03 — Recipient matrix for every in-scope Business Category value

**Decision required:** For every Business Category value confirmed as in scope in BD-02, business must provide:

1. The Service Fees threshold in EUR (confirmed org default currency) that separates the standard recipient set from the expanded recipient set.
2. The named email addresses for the standard recipient set.
3. The named email addresses for the expanded recipient set.

**Required per in-scope value. Template:**

| Business Category | Service Fees threshold | Standard recipients (below threshold) | Expanded recipients (at or above threshold) |
|---|---|---|---|
| Phase I Unit | [€ value] | [email list] | [email list] |
| Phase I-NIS | [€ value] | [email list] | [email list] |
| S&PS | [£ value or N/A] | [email list] | [email list] |
| *(other values if confirmed in scope)* | | | |

Opportunity Owner is always included regardless of threshold. Confirm whether Owner should be excluded in any scenario.

**Note:** These matrices are expected to mirror the Closed Won (notification 9) matrix. If they are identical, please confirm that explicitly so the same values can be used for both notifications.

**Impact if not decided:** No Send Email actions can be populated. The Flow cannot route to any recipient. Build is blocked.

**Owner:** Commercial
**Blocks:** Send Email elements in Flow (Section 8), test cases HP-01 through HP-03 (Section 10.1)

---

### BD-04 — Fallback recipient when Business Category or Service Fees is blank

**Decision required:** Some Opportunity records may have a blank or unrecognised `Business_Category__c`, or a blank `Service_Fees__c`. Business must confirm what happens in these cases.

**Options:**

| Scenario | Option A — Send to fallback | Option B — Do not send |
|---|---|---|
| `Business_Category__c` is blank | Send email to a named fallback recipient (e.g. BD Lead) | Exit Flow silently. No email. |
| `Business_Category__c` is an unrecognised value | Send email to a named fallback recipient | Exit Flow silently. No email. |
| `Service_Fees__c` is blank or zero | Use the standard (lower) recipient set | Exit Flow silently. No email. |

The current design defaults to Option B (exit silently, no email) for all three scenarios. If Option A is preferred for any scenario, a fallback email address must be provided.

**Impact if not decided:** Current design exits silently. If the business expects a fallback send, Opportunities will be silently missed.

**Owner:** Commercial
**Blocks:** Default path in Flow routing decision (Section 8)

---

### BD-05 — Loss Reason values and email payload inclusion

**Decision required:** Two confirmations are needed:

**5a — Values:** The `Loss Reason` field (`Loss_Reason__c`) contains 9 active values, confirmed in the org on 25 April 2026:

`Astrum Capabilities` · `Cancelled` · `Cost` · `Declined to Bid` · `Geographical Coverage` · `Lost to Follow-up` · `Lost to Incumbent` · `Project Team Experience` · `Therapeutic Experience`

Confirm these values are correct and complete. If any value is missing, incorrect, or should be retired, confirm the required changes before build.

**5b — Email inclusion:** `Loss Reason` will be included in the Closed Lost review email body. If the field is blank on a record, the row is omitted from the email (not shown as blank). Confirm this behaviour is acceptable, or confirm that a blank Loss Reason should instead block the email send until the field is populated.

**Impact if not decided:** If the values are wrong, the email will display incorrect loss reasons. If the blank handling is wrong, emails will be sent without the information the review requires.

**Owner:** BD Lead / Commercial
**Blocks:** Email template content (Section 6)

---

### BD-06 — Opportunity Owner always included as a recipient

**Decision required:** The current design always includes the Opportunity Owner as an email recipient regardless of Business Category or Service Fees. Confirm whether this is correct for all scenarios.

**Scenarios to confirm:**

| Scenario | Current design | Confirm or change |
|---|---|---|
| Owner is an active user | Owner receives the email | Confirm |
| Owner has left the organisation (inactive user) | Owner's email address is used; delivery depends on email routing | Confirm acceptable or provide fallback |
| Owner is a system / integration user | Owner's email receives the notification | Confirm acceptable or exclude |

**Impact if not decided:** If Owner should be excluded in some scenarios, the Flow logic must include an additional check before adding the Owner address.

**Owner:** Commercial
**Blocks:** Send Email recipient configuration (Section 5)

---

### BD-07 — Salesforce record link: Custom Label or relative URL

**Decision required:** The review email contains a clickable link to the Salesforce record. The current PRD design constructs this link using the sandbox URL prefix:

```
https://astrum--astrumpar.sandbox.my.salesforce.com/{Opportunity ID}
```

This hardcoded prefix will break if the Flow is ever deployed to a different environment. Solution Architect must confirm the preferred production-safe approach before the Flow is built:

**Option A — Custom Label (recommended)**
Create a Custom Label named `Salesforce_Base_URL` (e.g. `https://astrumcro.my.salesforce.com`). The Flow references `{!$Label.Salesforce_Base_URL}` and concatenates the record ID. The Custom Label value is updated per environment.

**Option B — Relative URL**
Use a relative URL in the email body (`/{Opportunity ID}`). Clicking the link requires the recipient to already be logged into Salesforce. Simpler but less user-friendly.

**Option C — Accept hardcoded sandbox URL for now**
Proceed with the hardcoded sandbox URL. Document that this must be updated manually before any production deployment. Accepted technical debt.

**Impact if not decided:** The Flow will be built with the sandbox URL hardcoded (Option C by default). If a production deployment is planned, this must be resolved before promotion.

**Owner:** Solution Architect
**Blocks:** Email template record link (Section 6); production deployment step P-07 (Section 11)

---

*PRD v1.0 — Astrum Orbit Programme — SAL-10 Closed Lost Review Notification*
*Do not build Flow metadata until blockers B-01 through B-04 are resolved and signed off in writing.*
*Business Decision Pack: Section 14. Stakeholder document: handoff/SAL-10-business-decisions-required.md*
