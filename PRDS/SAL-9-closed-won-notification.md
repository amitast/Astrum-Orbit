# SAL-9 — Opportunity Closed Won Notification
## Implementation PRD

| Field | Value |
|---|---|
| Linear Issue | SAL-9 |
| Notification Number | 9 of 14 |
| Programme | Astrum Orbit |
| Workstream | Sales Cloud — Opportunity Notifications |
| Author | Amit Kumar (Salesforce Admin) |
| PRD Version | 1.0 |
| Date | 26 April 2026 |
| Status | Sandbox deployed and Active. 4/4 routing paths smoke-tested. RG-1 and RG-2 confirmed 26 Apr 2026. Production deployment pending RG-3 through RG-6 — see Section 9. |
| Schema Authority | Live org query (Tooling API + anonymous Apex) — astrum--astrumpar sandbox, 25–26 Apr 2026 |
| Org | astrum--astrumpar.sandbox.my.salesforce.com |

---

## Deployment Status

> **SANDBOX ONLY — NOT IN PRODUCTION**
>
> SAL-9 has been built, deployed to sandbox `astrum--astrumpar`, and smoke-tested across all 4 routing paths. RG-1 and RG-2 are confirmed. Production deployment requires RG-3 through RG-6 to be closed — see Section 9. The Flow is currently Active in sandbox.
>
> | Milestone | Date | Status |
> |---|---|---|
> | Schema and recipient matrix confirmed | 26 Apr 2026 | COMPLETE |
> | Flow XML written and committed | 26 Apr 2026 | COMPLETE |
> | Sandbox deployment | 26 Apr 2026 | COMPLETE |
> | Smoke test — Phase I Unit Low path (A) | 26 Apr 2026 | PASS |
> | Smoke test — Phase I Unit High path (B) | 26 Apr 2026 | PASS |
> | Smoke test — Phase I-NIS Low path (C) | 26 Apr 2026 | PASS |
> | Smoke test — Phase I-NIS High path (D) | 26 Apr 2026 | PASS |
> | RG-1: A-05 re-trigger acceptance | 26 Apr 2026 | CONFIRMED — re-trigger on Closed Won → other → Closed Won is acceptable for MVP |
> | RG-2: S&PS and other categories out of scope | 26 Apr 2026 | CONFIRMED — S&PS, All Other Projects (Phase I-NIS), Phase I Clinical Conduct Portugal, Site & Patient Services excluded from SAL-9 |
> | BLK-03 / RG-3: Bypass_Flow permission test | PENDING — manual | OPEN |
> | RG-4: Sandbox completion tests (IDEM, SE) | 26 Apr 2026 | CLOSED — IDEM-01, IDEM-02, SE-01 all PASS |
> | RG-5: Production infrastructure confirmed | PENDING | OPEN |
> | RG-6: Production email deliverability confirmed | PENDING | OPEN |
> | Production deployment | Not started | BLOCKED |

---

## 1. Objective

Build a record-triggered Salesforce Flow that sends an immediate email to the appropriate stakeholders the first time an Opportunity's `StageName` transitions to `Closed Won` on an update. Recipients are determined by a routing matrix combining `Business_Category__c` and a `Service_Fees__c` threshold. The Opportunity Owner is always included as a dynamic recipient.

This is notification 9 of 14 in the Orbit Opportunities suite. It is in the first build wave alongside SAL-2 (Critical Stage Progression) and SAL-10 (Closed Lost Review), which are the highest-commercial-value notifications.

The primary business purpose is to ensure immediate visibility of a won deal to the correct stakeholders — enabling handover planning, resource allocation, and client engagement to begin without delay.

---

## 2. Confirmed Requirements

### Functional requirements

| # | Requirement | Source |
|---|---|---|
| FR-01 | Send one email immediately when `StageName` changes to `Closed Won` from any other stage, on an Opportunity update. | Linear SAL-9 |
| FR-02 | Do not send if the StageName is unchanged (already Closed Won and the record is edited). IsChanged = true guard in flow entry criteria. | Linear SAL-9 |
| FR-03 | Do not send on record creation — trigger on updates only. Creation at Closed Won is treated as a data load scenario. | A-04 resolved: default |
| FR-04 | Route recipients by Business_Category__c + Service_Fees__c threshold matrix. Include Opportunity Owner as a dynamic recipient on every path. | Linear SAL-9 confirmed 26 Apr 2026 |
| FR-05 | Phase I Unit and Phase I-NIS are the only categories in scope. All other Business Category values exit silently — no email, no error. | Confirmed 26 Apr 2026 — A-02 resolved |
| FR-06 | Phase I Unit threshold: EUR 150,000. Below → Low recipient list. At or above → High recipient list. | Confirmed 26 Apr 2026 — A-01 resolved |
| FR-07 | Phase I-NIS threshold: EUR 500,000. Below → Low recipient list. At or above → High recipient list. | Confirmed 26 Apr 2026 — A-02 resolved |
| FR-08 | Include mandatory fixed handover line: "If not already performed, a handover call will be scheduled with the relevant stakeholders following this email." | Linear SAL-9 |
| FR-09 | Use `Opportunity_Code__c` as the primary deal identifier in the email body. | Memory Pack §10 ALWAYS |
| FR-10 | Use `Opportunity_ID_18__c` to generate the Salesforce record link in the email body, via `$Label.Salesforce_Base_URL`. | OD-02 resolved (Salesforce_Base_URL deployed) |
| FR-11 | Do not reference the standard `Probability` field in any Flow condition, formula, or email content. | Memory Pack FR-07 NEVER |
| FR-12 | The Flow must check the `Bypass_Flow` custom permission as its first element. | CLAUDE.md hard rule |
| FR-13 | The Flow must run in User Context (DefaultMode), not System or System Without Sharing mode. | Memory Pack FR-09 NEVER |

### Non-functional requirements

| # | Requirement |
|---|---|
| NFR-01 | Flow Label: `Notify Closed Won After Save`. API Name: `Notify_Closed_Won_After_Save`. |
| NFR-02 | All Flow elements must have descriptions. CLAUDE.md hard rule. |
| NFR-03 | Flow must not be deployed to a production org. Sandbox only per CLAUDE.md hard rule. |
| NFR-04 | Every record-triggered Flow must include bypass logic checking `Bypass_Flow` as its first element. CLAUDE.md hard rule. |

---

## 3. Object and Field Mapping

Object: **Opportunity**
All custom fields validated against live sandbox org `astrum--astrumpar` on 25–26 April 2026.

### 3.1 Email payload fields

| Label | API Name | Data Type | Notes |
|---|---|---|---|
| Account Name | `Account.Name` | Cross-object Text | Via AccountId lookup; retrieved via Get Records |
| Opportunity Name | `Name` | Text(120) | Used in email subject and body |
| Opportunity Code | `Opportunity_Code__c` | Text(255) | Primary deal identifier |
| Business Category | `Business_Category__c` | Picklist | Also used for routing |
| Service Fees | `Service_Fees__c` | Currency(18,0) | EUR-denominated. Also used for routing threshold |
| Total Fees | `Total_Fees__c` | Formula (Currency) | Computed; no org-default-currency conversion needed |
| Project Start Work | `Project_Start_Work__c` | Date | |
| Project End Work | `Project_End_Work__c` | Date | |
| Therapeutic Area | `Therapeutic_Area__c` | Picklist | Single-select |
| Indication | `Indication__c` | Long Text Area(32000) | |
| Number of Enrolled Participants | `Number_of_Enrolled_Participants__c` | Number(18,0) | |
| Number of Sites | `Number_of_Sites__c` | Number(18,0) | |
| Entities Providing Services | `Entities_Providing_Services__c` | Picklist (Multi-Select) | Renders as semicolon-separated values in plain-text email |
| Salesforce Record Link | `Opportunity_ID_18__c` | Formula (Text) | `CASESAFEID(Id)`. Used to construct clickable URL. |

### 3.2 Trigger field

| Label | API Name | Data Type | Trigger value |
|---|---|---|---|
| Stage Name | `StageName` | Picklist (standard) | `Closed Won` (IsChanged = true) |

### 3.3 Infrastructure

| Component | API Name | Org Status |
|---|---|---|
| Bypass custom permission | `Bypass_Flow` | Deployed 25 Apr 2026 |
| 18-char record ID formula | `Opportunity_ID_18__c` | Deployed 25 Apr 2026 |
| Salesforce Base URL Custom Label | `Salesforce_Base_URL` | Deployed 25 Apr 2026 — value: `https://astrum.my.salesforce.com` |

### 3.4 Fields explicitly excluded

| Field | API Name | Reason excluded |
|---|---|---|
| Standard Probability | `Probability` | Prohibited by programme Memory Pack FR-07 NEVER guardrail |
| Probability formula | `Probability__c` | Formula referencing standard Probability — display-only, not suitable for notifications |
| Study Countries | `Study_Countries__c` | Data-quality guardrail per SAL-2 precedent (commit 660e1b2). Picklist values not cleaned or approved. Required by Closed Won validation rule on the Opportunity record, but excluded from email payload. |
| Phase | unknown | API name not confirmed in org-validated schema. Excluded pending schema verification. |

### 3.5 Closed Won validation rule — STAGE_Closed_Won (Id: 03dUD000000TMbRYAW)

The org has a validation rule that requires the following fields to be non-blank before any Opportunity can be saved to Closed Won:

`Description` · `Reason_for_win__c` · `Indication__c` · `Number_of_Enrolled_Participants__c` · `Study_Countries__c` · `Number_of_Sites__c` · `Entities_Providing_Services__c` · `Protocol_Title__c` · `Contract_Sign_Date__c` · `Contract_Type__c` · `Payment_Schedule_Type__c` · `Contract_Entity__c`

**Implication:** All real Closed Won records will have these fields populated (enforced by the validation rule). In the email payload, `Study_Countries__c` is excluded per the data-quality guardrail — but it will never be blank on real Closed Won records. The fields in the notification payload (`Indication__c`, `Number_of_Enrolled_Participants__c`, etc.) will always be non-blank on qualifying records.

**New fields discovered (not previously in schema memory):**

| Label | API Name | Data Type |
|---|---|---|
| Reason for win | `Reason_for_win__c` | Picklist — active values: Astrum Capabilities, Change Order, Client Relationship, Cost, Geographical Coverage, Project Team Experience, Therapeutic Experience |
| Protocol Title | `Protocol_Title__c` | Long Text Area(32768) |
| Contract Type | `Contract_Type__c` | Picklist — active values: Change Order, Clinical Services Agreement, Invoice Only, Letter of Agreement, Out of Scope, Proposal Acceptance Form, Start Work Authorisation, Statement of Work/Work Order |
| Payment Schedule Type | `Payment_Schedule_Type__c` | Picklist — active values: Fixed Fee, FTE Based, Milestone Based, Time and Material, Unit-Based |
| Contract Entity | `Contract_Entity__c` | Picklist — active values: Astrum CRO SL, Astrum CRO France, Astrum CRO Germany, Astrum CRO Spain, BlueClinical, MissionTEC |

---

## 4. Trigger Criteria

| Property | Value |
|---|---|
| Object | Opportunity |
| Trigger timing | After Save |
| Trigger event | A record is **updated** |
| Trigger filter logic | 1 AND 2 |
| Condition 1 | `StageName` EqualTo `Closed Won` |
| Condition 2 | `StageName` IsChanged `true` |
| Run mode | DefaultMode (User context) |

Conditions 1 AND 2 together guarantee the Flow fires **only when StageName first transitions INTO Closed Won** on a given save. A re-save of an already-Closed-Won record without changing Stage does not re-fire.

**ASSUMPTION A-05 (RESOLVED — 26 Apr 2026):** If StageName moves Closed Won → other stage → Closed Won again, a second email fires. This is confirmed acceptable for MVP — a genuine re-win or corrected deal is treated as a new qualifying event. One-lifetime-only behaviour (`Closed_Won_Notification_Sent__c` helper field) is deferred to Release 1.1 and will only be implemented if the business later determines it is required.

---

## 5. Recipients

### Routing matrix

| Business Category | Service Fees | Recipient list |
|---|---|---|
| Phase I Unit | < EUR 150,000 | tom.frearson@astrumcro.com, Catherine.Canales@astrumcro.com, Owner, Ricardo.Cunha@astrumcro.com, rfp.rfi@astrumcro.com |
| Phase I Unit | ≥ EUR 150,000 | tom.frearson@astrumcro.com, Catherine.Canales@astrumcro.com, Owner, cristina.lopes@astrumcro.com, Ricardo.Cunha@astrumcro.com, rfp.rfi@astrumcro.com |
| Phase I-NIS | < EUR 500,000 | tom.frearson@astrumcro.com, Catherine.Canales@astrumcro.com, Owner, rfp.rfi@astrumcro.com |
| Phase I-NIS | ≥ EUR 500,000 | tom.frearson@astrumcro.com, Catherine.Canales@astrumcro.com, Owner, cristina.lopes@astrumcro.com, jordi.picas@astrumcro.com, anthony.gibson@astrumcro.com, rfp.rfi@astrumcro.com |
| All other categories | — | **No email sent — silent exit** |

"Owner" = `{!Get_Opportunity_Detail.Owner.Email}` — the Opportunity Owner resolved dynamically via cross-object traversal on the Get Records output. Recipients confirmed 26 Apr 2026 (A-01, A-02, A-03 resolved).

**All other Business Category values** — including S&PS, All Other Projects (Phase I - NIS), Phase I Clinical Conduct Portugal, and Site & Patient Services (CRP & MissionTEC) — exit the Flow silently. No email is sent, no error is thrown, and the Opportunity saves normally. Written stakeholder confirmation of this exclusion is required before production deployment.

---

## 6. Email Template Content

### Subject

```
Closed Won. {!Get_Opportunity_Detail.Name}
```

### Body (plain text)

```
CLOSED WON

Account:                          {!Get_Opportunity_Detail.Account.Name}
Opportunity:                      {!Get_Opportunity_Detail.Name}
Opportunity Code:                 {!Get_Opportunity_Detail.Opportunity_Code__c}
Business Category:                {!Get_Opportunity_Detail.Business_Category__c}

Service Fees:                     {!Get_Opportunity_Detail.Service_Fees__c}
Total Fees:                       {!Get_Opportunity_Detail.Total_Fees__c}
Project Start Work:               {!Get_Opportunity_Detail.Project_Start_Work__c}
Project End Work:                 {!Get_Opportunity_Detail.Project_End_Work__c}

Therapeutic Area:                 {!Get_Opportunity_Detail.Therapeutic_Area__c}
Indication:                       {!Get_Opportunity_Detail.Indication__c}
Number of Enrolled Participants:  {!Get_Opportunity_Detail.Number_of_Enrolled_Participants__c}
Number of Sites:                  {!Get_Opportunity_Detail.Number_of_Sites__c}
Entities Providing Services:      {!Get_Opportunity_Detail.Entities_Providing_Services__c}

View record in Salesforce:
{!$Label.Salesforce_Base_URL}/{!Get_Opportunity_Detail.Opportunity_ID_18__c}

If not already performed, a handover call will be scheduled with the relevant stakeholders following this email.

---
This is an automated notification from Salesforce.
Please do not reply to this email.
```

All field values are rendered unconditionally (MVP). A blank field shows a label with an empty value. Conditional blank-row suppression is a future enhancement.

---

## 7. Duplicate-Send Prevention

**Method:** Native `IsChanged` operator on `StageName` in Flow entry conditions.

The entry condition 2 (`StageName` IsChanged = true) prevents the Flow from firing on saves where StageName is not changing. This is the native after-save prior-value comparison — no helper field or SOQL query required.

| Scenario | StageName before | StageName after | Flow fires? |
|---|---|---|---|
| Any stage → Closed Won | other | Closed Won | Yes — correct |
| Closed Won → Closed Won (re-save, edit other field) | Closed Won | Closed Won | No — IsChanged = false blocks |
| Closed Won → other stage | Closed Won | other | No — Condition 1 (EqualTo Closed Won) fails |
| Closed Won → other → Closed Won (A-05 scenario) | other | Closed Won | **Yes — second email fires. A-05 open.** |

---

## 8. Flow Design

### Flow properties

| Property | Value |
|---|---|
| Flow type | Record-Triggered Flow (AutoLaunchedFlow) |
| Object | Opportunity |
| Trigger | After Save, Update only |
| Label | `Notify Closed Won After Save` |
| API Name | `Notify_Closed_Won_After_Save` |
| Run mode | DefaultMode (User context) |
| Status | Active (sandbox) |
| File | `force-app/main/default/flows/Notify_Closed_Won_After_Save.flow-meta.xml` |

### Element sequence

```
[Start — Entry Criteria]
    1: StageName = 'Closed Won'
    2: StageName IsChanged = true
    Trigger: Update only
        │
        ▼
[Decision: Check_Bypass_Permission]
    Bypassed ($Permission.Bypass_Flow = true) → [End — silent exit]
    Proceed (default)                          ↓
        │
        ▼
[Get Records: Get_Opportunity_Detail]
    Retrieve full Opportunity record with Account.Name, Owner.Email, and all payload fields
        │
        ▼
[Decision: Check_Business_Category]
    Phase I Unit   → [Decision: Check_Phase_I_Unit_Fees]
    Phase I-NIS    → [Decision: Check_Phase_I_NIS_Fees]
    All others     → [End — silent exit, no email]
        │
        ▼
[Decision: Check_Phase_I_Unit_Fees]              [Decision: Check_Phase_I_NIS_Fees]
    Below EUR 150,000 → [Send Unit Low]              Below EUR 500,000 → [Send NIS Low]
    At or above       → [Send Unit High]             At or above       → [Send NIS High]
        │                                                │
        ▼                                                ▼
[emailSimple action calls — 4 paths]
    Fault path on each → [Assignment: Handle_Send_Fault]
    No connector on success → [End — normal exit]
```

### emailSimple configuration

All 4 action calls use:
- `sendRichBody = false` (plain text)
- Fault connector → `Handle_Send_Fault` (captures `$Flow.FaultMessage`, does not rethrow — Opportunity DML is never rolled back by a failed email send)

---

## 9. Release Gates (Production Deployment)

All gates must be closed and recorded in writing on the SAL-9 Linear issue before any production deployment.

| ID | Item | Type | Owner | Status |
|---|---|---|---|---|
| RG-1 | **A-05: Re-trigger behaviour.** Confirmed acceptable for MVP — re-trigger on Closed Won → other → Closed Won is treated as a new qualifying event. | Stakeholder decision | Commercial / BD Lead | **CONFIRMED — 26 Apr 2026** |
| RG-2 | **S&PS and other category exclusions.** Confirmed that S&PS, All Other Projects (Phase I-NIS), Phase I Clinical Conduct Portugal, and Site & Patient Services (CRP & MissionTEC) are explicitly out of scope for SAL-9. | Stakeholder sign-off | Commercial / BD Lead | **CONFIRMED — 26 Apr 2026** |
| BLK-03 / RG-3 | **Bypass_Flow permission test.** Manual test: assign Bypass_Flow permission to a test user, trigger the flow, confirm no email fires and Opportunity saves normally. Evidence to be documented on the Linear issue. Instructions posted on Linear SAL-9 (comment d85f7232). | Manual test | Salesforce Admin | OPEN |
| RG-4 | **Sandbox completion tests.** IDEM-01, IDEM-02, and SE-01 pass in sandbox. Scripts committed at `af8af2d`. Evidence on Linear SAL-9 (comment c93cda23). | Admin test | Salesforce Admin | **CLOSED — 26 Apr 2026** |
| RG-5 | **Production infrastructure.** `Bypass_Flow`, `Opportunity_ID_18__c`, and `Salesforce_Base_URL` confirmed deployed in production org. | Verification | Salesforce Admin | OPEN |
| RG-6 | **Production email deliverability.** Production org deliverability setting confirmed as `All Email`. | Verification | Salesforce Admin | OPEN |

Additionally, **email delivery to real recipients cannot be confirmed** in the sandbox because the `astrumcro.com` email domain is not verified in `astrum--astrumpar`. All 4 smoke test paths faulted with `INSUFFICIENT_ACCESS_OR_READONLY` on the emailSimple action. The fault connector handled this gracefully (Opportunity DML succeeded). Email delivery is expected to work in production where the domain is verified.

---

## 10. Test Cases

All tests must be run in the sandbox `astrum--astrumpar` with the Flow in an active state.

### 10.1 Routing smoke tests (all 4 paths — COMPLETED 26 Apr 2026)

| ID | Business Category | Service Fees | Expected action | Result | Record ID |
|---|---|---|---|---|---|
| SM-A | Phase I Unit | €100,000 | Send_Closed_Won_Phase_I_Unit_Low | PASS — flow executed ~500ms, emailSimple faulted (sandbox domain), handled by fault connector | Not retained |
| SM-B | Phase I Unit | €200,000 | Send_Closed_Won_Phase_I_Unit_High | PASS — 26 Apr 2026 | 006UD00000HuPOYYA3 |
| SM-C | Phase I-NIS | €300,000 | Send_Closed_Won_Phase_I_NIS_Low | PASS — 26 Apr 2026 | 006UD00000HuPOZYA3 |
| SM-D | Phase I-NIS | €600,000 | Send_Closed_Won_Phase_I_NIS_High | PASS — flow executed, emailSimple faulted (sandbox domain), handled | Not retained |

### 10.2 Idempotency (COMPLETED 26 Apr 2026)

| ID | Scenario | Expected result | Result | Record ID |
|---|---|---|---|---|
| IDEM-01 | Edit already-Closed-Won Opportunity (change Description only) | No email — IsChanged = false blocks Flow | PASS | 006UD00000HufGQYAZ |
| IDEM-02 | Move Opportunity from Closed Won to another stage | No email — StageName ≠ 'Closed Won' blocks Flow | PASS | 006UD00000HufGQYAZ |

### 10.3 Bypass (PENDING — manual test required)

| ID | Scenario | Expected result |
|---|---|---|
| BYP-01 | Assign Bypass_Flow permission to test user; trigger Closed Won transition | No email — flow exits at Check_Bypass_Permission |
| BYP-02 | Remove Bypass_Flow permission; repeat trigger | Email fires normally |

### 10.4 Silent exit — other Business Categories

| ID | Scenario | Expected result | Result | Record ID |
|---|---|---|---|---|
| SE-01 | S&PS Opportunity transitions to Closed Won | No email, no error, Opportunity saves normally | PASS — 26 Apr 2026 | 006UD00000Hue4EYAR |
| SE-02 | Blank Business_Category__c Opportunity transitions to Closed Won | No email, no error, Opportunity saves normally | Not run — low priority; S&PS confirms routing logic |

### 10.5 Exit criteria for production activation

All of the following must be true before the Flow is activated in production:

| Criterion | Status |
|---|---|
| All 4 routing paths smoke-tested | COMPLETE |
| IDEM tests pass | Pending |
| BYP tests pass with documented evidence | Pending |
| SE tests confirmed by stakeholder | Pending |
| BLK-01 (A-05) resolved in writing | Pending |
| BLK-02 (S&PS exclusion) confirmed in writing | Pending |
| Email delivery confirmed in production sandbox or domain-verified org | Pending |

---

## 11. Deployment Plan

| Step | Action | Status |
|---|---|---|
| P-01 | Deploy `Bypass_Flow` custom permission | DONE — 25 Apr 2026 |
| P-02 | Deploy `Opportunity_ID_18__c` formula field | DONE — 25 Apr 2026 |
| P-03 | Deploy `Salesforce_Base_URL` Custom Label | DONE — 25 Apr 2026 |
| P-04 | Write and deploy Flow to sandbox | DONE — 26 Apr 2026 |
| P-05 | Run 4-path routing smoke test | DONE — 26 Apr 2026 |
| P-06 | Resolve BLK-01, BLK-02, BLK-03 | PENDING |
| P-07 | Run IDEM, BYP, SE test cases | PENDING |
| P-08 | Obtain written sign-off from BD Lead | PENDING |
| P-09 | Deploy to production (governed release only) | PENDING |
| P-10 | Production smoke test — confirm email delivery | PENDING |

### Sandbox deploy command (used in P-04)

```bash
sf project deploy start \
  --source-dir force-app/main/default/flows/Notify_Closed_Won_After_Save.flow-meta.xml \
  --target-org amit.kumar@astrumcro.com.astrumpar
```

### Production deploy command (when all blockers resolved)

```bash
sf project deploy start \
  --source-dir force-app/main/default/flows/Notify_Closed_Won_After_Save.flow-meta.xml \
  --target-org <PRODUCTION_ORG_ALIAS>
```

---

## 12. Rollback Plan

The Flow can be deactivated instantly from Setup > Flows. No data loss. No record impact. Deactivation immediately stops all future sends; it cannot recall emails already delivered.

**Steps:** Setup → Flows → `Notify Closed Won After Save` → Deactivate → Confirm.

| Component | Rollback possible? | Method |
|---|---|---|
| Flow | Yes | Deactivate in Setup > Flows |
| `Bypass_Flow` custom permission | Yes (shared infrastructure) | Delete via Setup > Custom Permissions — only if no other Flow references it |
| `Opportunity_ID_18__c` | Yes | Delete via Object Manager — no data stored |
| `Salesforce_Base_URL` | Yes (shared) | Delete via Setup > Custom Labels — only if no other Flow references it |
| Emails already sent | No | Emails cannot be recalled once delivered |

---

## 13. Open Decisions

| ID | Summary | Owner | Build impact |
|---|---|---|---|
| A-04 | **Creation trigger.** Creating an Opportunity at Closed Won stage is excluded (trigger = Update only). This is the safe default — data loads should not send notifications. | Commercial | Resolved — safe default in place |
| A-05 | **Re-trigger on Closed Won → other → Closed Won.** Confirmed acceptable for MVP — treated as a new qualifying event. One-lifetime guard (`Closed_Won_Notification_Sent__c`) deferred to Release 1.1. | Commercial / BD Lead | **Resolved — 26 Apr 2026** |

---

*PRD v1.0 — Astrum Orbit Programme — SAL-9 Opportunity Closed Won Notification*
*Do not deploy to production until all Section 9 blockers are resolved and recorded in writing on Linear issue SAL-9.*
