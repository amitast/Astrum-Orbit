# SAL-9 Delivery Handoff Note
## Opportunity Closed Won Notification

| Field | Value |
|---|---|
| Linear Issue | SAL-9 |
| Notification Number | 9 of 14 |
| Programme | Astrum Orbit |
| Workstream | Sales Cloud — Opportunity Notifications |
| Prepared by | Amit Kumar (Salesforce Admin) |
| Date | 26 April 2026 |
| Sandbox org | astrum--astrumpar.sandbox.my.salesforce.com |
| Production deployment | **LIVE — Active in production as of 27 Apr 2026. PRE-07 smoke test PASS. SAL-9 COMPLETE.** |
| Overall status | **Production Active. All release gates closed. PRE-07 smoke test confirmed email delivery to Phase I Unit Low recipients. SAL-9 ready to close on Linear.** |

---

## 1. Executive Summary

The SAL-9 Closed Won Notification has been designed, built, deployed to sandbox `astrum--astrumpar`, and smoke-tested across all 4 routing paths. The Flow fires immediately when an Opportunity's `StageName` transitions to `Closed Won` on an update, routes to the correct recipient list based on Business Category and Service Fees, and sends a plain-text email with the full commercial context.

All 4 routing scenarios (Phase I Unit Low/High, Phase I-NIS Low/High) were smoke-tested on 26 Apr 2026 via anonymous Apex. The Opportunity DML succeeded in all cases. emailSimple faulted on all paths due to the unverified `astrumcro.com` domain in sandbox — this is expected behaviour. The fault connector captured the error without rethrowing, and the Opportunity saves completed normally. Email delivery is expected to work in production.

All release gates (RG-1 through RG-6) and all deployment prerequisites (PRE-05 through PRE-07) are confirmed as of 27 Apr 2026. The flow was deployed to `astrum-prod` on 27 Apr 2026 (deploy `0AfTY000003kpyf0AA`, Flow ID `301TY00000rYVAxYAO`), manually activated by the admin, and validated via a controlled production smoke test — Phase I Unit Low path, Opportunity `006TY00000vLQOTYA4`, email delivery confirmed to all 5 expected recipients by Amit Kumar from Salesforce email logs. SAL-9 is complete and ready to close on Linear.

This is notification 9 of 14 in the Orbit Opportunities suite.

---

## 2. Business Requirement Delivered

**Requirement:** Send an immediate email when an Opportunity first transitions to Closed Won. Route recipients by Business Category and deal size. Always include the Opportunity Owner. Include a mandatory handover-call line.

| Requirement | Status |
|---|---|
| Fires on StageName transition to Closed Won (update only) | DELIVERED |
| Does not re-fire on re-save of already-Closed-Won record | DELIVERED |
| Routes by Business Category and Service Fees threshold | DELIVERED |
| Phase I Unit threshold EUR 150,000 applied correctly | DELIVERED |
| Phase I-NIS threshold EUR 500,000 applied correctly | DELIVERED |
| Opportunity Owner included as dynamic recipient on all paths | DELIVERED |
| All other Business Categories exit silently | DELIVERED |
| Carries 14 PRD payload fields (Study_Countries__c excluded — data-quality guardrail) | DELIVERED |
| Mandatory handover line included | DELIVERED |
| Clickable Salesforce record link via Salesforce_Base_URL Custom Label | DELIVERED |

---

## 3. Metadata Components Changed

### Sandbox — `astrum--astrumpar`

| Component | Type | API Name | Action | Date |
|---|---|---|---|---|
| Notify Closed Won After Save | Flow (AutoLaunchedFlow, After Save) | `Notify_Closed_Won_After_Save` | Created — Active | 26 Apr 2026 |
| Bypass Flow | Custom Permission | `Bypass_Flow` | Infrastructure — deployed with SAL-2 | 25 Apr 2026 |
| Opportunity ID 18 | Formula Field on Opportunity | `Opportunity_ID_18__c` | Infrastructure — deployed with SAL-2 | 25 Apr 2026 |
| Salesforce Base URL | Custom Label | `Salesforce_Base_URL` | Infrastructure — deployed with SAL-2 | 25 Apr 2026 |

### Production — `astrum-prod` (`astrum.my.salesforce.com`)

| Component | Type | API Name | Action | Date |
|---|---|---|---|---|
| Notify Closed Won After Save | Flow (AutoLaunchedFlow, After Save) | `Notify_Closed_Won_After_Save` | **Active** | 27 Apr 2026 |

Flow ID: `301TY00000rYVAxYAO` — Deploy ID: `0AfTY000003kpyf0AA`. Deployed as Draft, manually activated by admin, PRE-07 smoke test PASS.

### Source artefacts

| Artefact | Location |
|---|---|
| PRD | `PRDS/SAL-9-closed-won-notification.md` |
| Flow XML | `force-app/main/default/flows/Notify_Closed_Won_After_Save.flow-meta.xml` |
| Smoke test script (scenarios B, C) | `scripts/apex/smoke_sal9_bc.apex` |
| Git commit | `47d57a4` — feat(SAL-9): Closed Won notification — confirmed recipient matrix and smoke-tested in sandbox |
| Branch | `vptechnology/sal-9-orbit-notification-opportunity-closed-won-notification` |

---

## 4. Final Trigger Criteria

**Object:** Opportunity
**Trigger timing:** After Save
**Trigger event:** A record is **updated** (creation excluded — A-04 resolved)

**Entry conditions — filter logic `1 AND 2`:**

| Condition | Field | Operator | Value |
|---|---|---|---|
| 1 | `StageName` | EqualTo | `Closed Won` |
| 2 | `StageName` | IsChanged | `true` |

Condition 2 is the native Flow `IsChanged` operator, which compares `$Record__Prior.StageName ≠ $Record.StageName`. It prevents re-send on any save where StageName is unchanged.

**Run mode:** `DefaultMode` (User context — never SystemModeWithoutSharing, per Memory Pack FR-09).

---

## 5. Email Recipients

### Routing matrix (confirmed 26 Apr 2026)

| Business Category | Condition | Recipients |
|---|---|---|
| Phase I Unit | < EUR 150,000 | tom.frearson@astrumcro.com, Catherine.Canales@astrumcro.com, `{Owner.Email}`, Ricardo.Cunha@astrumcro.com, rfp.rfi@astrumcro.com |
| Phase I Unit | ≥ EUR 150,000 | tom.frearson@astrumcro.com, Catherine.Canales@astrumcro.com, `{Owner.Email}`, cristina.lopes@astrumcro.com, Ricardo.Cunha@astrumcro.com, rfp.rfi@astrumcro.com |
| Phase I-NIS | < EUR 500,000 | tom.frearson@astrumcro.com, Catherine.Canales@astrumcro.com, `{Owner.Email}`, rfp.rfi@astrumcro.com |
| Phase I-NIS | ≥ EUR 500,000 | tom.frearson@astrumcro.com, Catherine.Canales@astrumcro.com, `{Owner.Email}`, cristina.lopes@astrumcro.com, jordi.picas@astrumcro.com, anthony.gibson@astrumcro.com, rfp.rfi@astrumcro.com |
| All other categories | any | **No email — silent exit** |

`{Owner.Email}` = `Get_Opportunity_Detail.Owner.Email` — resolved dynamically via cross-object traversal on the Get Records element.

---

## 6. Email Content

### Subject line

```
Closed Won. {Opportunity Name}
```

### Body (plain text — 14 payload fields)

```
CLOSED WON

Account:                          {Account.Name}
Opportunity:                      {Opportunity Name}
Opportunity Code:                 {Opportunity_Code__c}
Business Category:                {Business_Category__c}

Service Fees:                     {Service_Fees__c}
Total Fees:                       {Total_Fees__c}
Project Start Work:               {Project_Start_Work__c}
Project End Work:                 {Project_End_Work__c}

Therapeutic Area:                 {Therapeutic_Area__c}
Indication:                       {Indication__c}
Number of Enrolled Participants:  {Number_of_Enrolled_Participants__c}
Number of Sites:                  {Number_of_Sites__c}
Entities Providing Services:      {Entities_Providing_Services__c}

View record in Salesforce:
{$Label.Salesforce_Base_URL}/{Opportunity_ID_18__c}

If not already performed, a handover call will be scheduled with the relevant stakeholders following this email.

---
This is an automated notification from Salesforce.
Please do not reply to this email.
```

All field rows render unconditionally (MVP). Conditional blank-row suppression is a future enhancement if email formatting is a concern.

---

## 7. Excluded Fields and Rationale

| Field | API Name | Type | Reason excluded |
|---|---|---|---|
| Standard Probability | `Probability` | Percent (standard) | Programme-prohibited — Memory Pack FR-07 NEVER. `Opp_Probability__c` is the sole authoritative probability field. |
| Probability formula | `Probability__c` | Formula (Percent) | Display/reporting field; not suitable for notification payload. |
| Study Countries | `Study_Countries__c` | Picklist (Multi-Select) | Data-quality guardrail per SAL-2 precedent (commit 660e1b2). Picklist values not cleaned or approved for notification use. Note: this field IS required by the Closed Won validation rule (org enforces non-blank), so it will always be populated on real Closed Won records — but it remains excluded from the email body until after explicit picklist cleanup and stakeholder approval. |
| Phase | unknown | unknown | API name not confirmed in org-validated schema. Excluded pending schema verification. |

---

## 8. Duplicate Prevention Design

**Method:** Native `IsChanged` operator on `StageName` in Flow entry conditions.

| Scenario | Flow fires? |
|---|---|
| Any stage → Closed Won | Yes |
| Closed Won → Closed Won (re-save, other field edited) | No — IsChanged = false |
| Closed Won → other stage | No — EqualTo 'Closed Won' fails |
| Closed Won → other → Closed Won again | **Yes — A-05 resolved. Confirmed acceptable for MVP — treated as a new qualifying event.** |
| Any stage → other (non-Closed-Won) | No |

---

## 9. Bypass Logic

**Element:** `Check_Bypass_Permission` (Decision — first element after start, per CLAUDE.md hard rule)

| Outcome | Condition | Action |
|---|---|---|
| Bypassed | `$Permission.Bypass_Flow` = true | Flow terminates immediately. No email sent. Opportunity saves normally. |
| Proceed (default) | Permission not held | Flow continues to Get Records → routing → email send |

**Bypass permission test (COMPLETE — 26 Apr 2026):** Automated via `SAL9_BypassFlow_Test.cls` (commit `90845f0`). BYP-01: `System.runAs` with Bypass_Flow permission — 0 email invocations — PASS. BYP-02: `System.runAs` without permission — Opportunity saves normally, fault connector handles email error — PASS. See Section 11 for full test evidence.

---

## 10. Sandbox Deployment Evidence

| Item | Value |
|---|---|
| Flow API Name | `Notify_Closed_Won_After_Save` |
| Status | Active |
| Target org | `astrum--astrumpar.sandbox.my.salesforce.com` |
| Deployed | 26 April 2026 |
| Git commit | `47d57a4` |
| Deploy command | `sf project deploy start --source-dir force-app/main/default/flows/Notify_Closed_Won_After_Save.flow-meta.xml --target-org amit.kumar@astrumcro.com.astrumpar` |

---

## 11. Smoke Test Evidence

All 4 routing paths tested via anonymous Apex (`sf apex run`) in `astrum--astrumpar`. Evidence method: Opportunity DML success + CODE_UNIT timing in debug log (Flow:Opportunity unit ≥ 500ms = Flow executed; <5ms = entry criteria blocked). emailSimple faulted on all paths (INSUFFICIENT_ACCESS_OR_READONLY — `astrumcro.com` domain not verified in sandbox). Fault connector captured the error; Opportunity DML succeeded on all paths.

### Routing — 4/4 PASS

| ID | Business Category | Service Fees | Expected path | Opp DML | Flow executed | Fault handled |
|---|---|---|---|---|---|---|
| SM-A | Phase I Unit | €100,000 | Send_Closed_Won_Phase_I_Unit_Low | PASS | PASS (~500ms) | PASS |
| SM-B | Phase I Unit | €200,000 | Send_Closed_Won_Phase_I_Unit_High | PASS | PASS (~513ms) | PASS |
| SM-C | Phase I-NIS | €300,000 | Send_Closed_Won_Phase_I_NIS_Low | PASS | PASS (~513ms) | PASS |
| SM-D | Phase I-NIS | €600,000 | Send_Closed_Won_Phase_I_NIS_High | PASS | PASS (~500ms) | PASS |

Smoke B record: `006UD00000HuPOYYA3` — Phase I Unit, €200k — Closed Won — 26 Apr 2026
Smoke C record: `006UD00000HuPOZYA3` — Phase I-NIS, €300k — Closed Won — 26 Apr 2026
Smoke A and D: Executed in prior session 26 Apr 2026 (commit `47d57a4`); records not retained.

### Email delivery — 0/4 CONFIRMED

emailSimple faulted on all 4 paths due to unverified sandbox domain. **Email delivery is expected to work in production.** Confirmation required via production smoke test after deployment.

### Idempotency — COMPLETE (26 Apr 2026)

| ID | Scenario | Result | Record ID |
|---|---|---|---|
| IDEM-01 | Re-save Closed Won (Description change only) | PASS — Flow blocked (< 5ms, Email Invocations: 0) | 006UD00000HufGQYAZ |
| IDEM-02 | Move Closed Won → Proposal In Progress | PASS — Flow blocked (< 1ms, Email Invocations: 0) | 006UD00000HufGQYAZ |

### Silent exit — COMPLETE (26 Apr 2026)

| ID | Scenario | Result | Record ID |
|---|---|---|---|
| SE-01 | S&PS → Closed Won | PASS — Flow entered (~21ms), exited at Check_Business_Category, no emailSimple reached, Email Invocations: 0 | 006UD00000Hue4EYAR |

### Bypass — COMPLETE (26 Apr 2026)

Automated via Apex test class `SAL9_BypassFlow_Test` (commit `90845f0`). Uses `System.runAs()` with dynamically created test users; `SetupEntityAccess` DML assigns the `Bypass_Flow` `CustomPermission` via PermissionSet for BYP-01. `@isTest(SeeAllData=true)` required due to unrelated `Oppty_Code` insert-trigger flow needing org configuration data.

| ID | Scenario | Result | Method |
|---|---|---|---|
| BYP-01 | User WITH `Bypass_Flow` permission; update Opportunity to Closed Won | **PASS** — `Limits.getEmailInvocations() == 0` after Closed Won transition. Flow exited at `Check_Bypass_Permission`. | `testBYP01_BypassActive` in `SAL9_BypassFlow_Test.cls` |
| BYP-02 | User WITHOUT `Bypass_Flow` permission; update Opportunity to Closed Won | **PASS** — Opportunity saved to Closed Won. Flow proceeded past bypass check into routing logic. `emailSimple` faulted (sandbox domain restriction); fault connector captured error without rethrow. | `testBYP02_BypassNotActive` in `SAL9_BypassFlow_Test.cls` |

Test run ID: `707UD00000pLfAm` (sandbox `astrum--astrumpar`). Both methods pass. 100% pass rate.

---

## 12. New Schema Discoveries (26 Apr 2026)

A Closed Won validation rule (`03dUD000000TMbRYAW`) was discovered during smoke testing. It requires 12 fields to be non-blank before any Opportunity can be saved to Closed Won. This is **not a flow design issue** — the validation rule means real Closed Won Opportunities will always have these fields populated. The smoke test scripts required explicit population of all 12 fields.

**New fields discovered (not previously in schema memory):**

| Label | API Name | Data Type |
|---|---|---|
| Reason for win | `Reason_for_win__c` | Picklist |
| Protocol Title | `Protocol_Title__c` | Long Text Area(32768) |
| Contract Type | `Contract_Type__c` | Picklist |
| Payment Schedule Type | `Payment_Schedule_Type__c` | Picklist |
| Contract Entity | `Contract_Entity__c` | Picklist |

These fields are **not** in the SAL-9 email payload — they are Closed Won administrative fields. Consideration for future notification payloads (e.g. post-award tracking notifications) should validate whether these should be included.

---

## 13. Known Limitations

| Ref | Limitation | Impact | Future fix |
|---|---|---|---|
| L-01 | **Blank field rows render unconditionally (MVP).** All 14 payload fields render regardless of value. | Cosmetic only — validation rule means most fields are populated on real Closed Won records | Conditional blank-row suppression via Decision elements |
| L-02 | **Email delivery not verifiable in sandbox.** emailSimple does not create EmailMessage records. astrumcro.com domain not verified in sandbox. | Operational — delivery must be confirmed via production smoke test | Verify deliverability in production before activation |
| L-03 | **A-05 (re-trigger) unresolved.** If StageName moves Closed Won → other → Closed Won, a second email fires. | Commercial — unclear if this is acceptable | Stakeholder decision + optional one-lifetime Boolean field |
| L-04 | **Phase field excluded.** API name for "Phase" field not confirmed in org-validated schema. | Minor content gap | Verify API name via FieldDefinition query and add if confirmed |
| L-05 | **Study Countries excluded from payload.** Present and required on real Closed Won records (validation rule enforces it), but excluded from email per data-quality guardrail. | Minor — recipients do not see country list | Reinstate after picklist cleanup and stakeholder approval |

---

## 14. Production Deployment Prerequisites

**Production deployment has not been performed and must not be performed without explicit written approval.**

| Ref | Prerequisite | Owner | Status |
|---|---|---|---|
| RG-1 | **A-05 re-trigger behaviour** — confirmed acceptable for MVP (re-trigger = new qualifying event) | Commercial / BD Lead | **CONFIRMED — 26 Apr 2026** |
| RG-2 | **S&PS and other category exclusions** — confirmed out of scope for SAL-9 | Commercial / BD Lead | **CONFIRMED — 26 Apr 2026** |
| BLK-03 / RG-3 | **Bypass_Flow test** — automated `SAL9_BypassFlow_Test.cls` (commit `90845f0`): BYP-01 PASS (0 invocations), BYP-02 PASS (DML success). Test run `707UD00000pLfAm`. | Claude Code / SAL9_BypassFlow_Test | **CLOSED — 26 Apr 2026** |
| RG-4 | **Sandbox completion tests** — IDEM-01, IDEM-02, SE-01 pass. Scripts at `af8af2d`. Evidence on Linear SAL-9 (comment c93cda23). | Salesforce Admin | **CLOSED — 26 Apr 2026** |
| RG-5 | **Production infrastructure** — `Bypass_Flow` custom permission (0CPTY00000010CT4AY), `Salesforce_Base_URL` label (https://astrum.my.salesforce.com), and all 12 Opportunity custom fields confirmed in `astrum-prod` via SOQL (26 Apr 2026). | Claude Code / SOQL | **PASS — 26 Apr 2026** |
| RG-6 | **Production email deliverability** — confirm org deliverability setting is `All Email` in Setup → Email → Deliverability. Not queryable via CLI/SOQL. | Salesforce Admin | **CONFIRMED — 27 Apr 2026** |
| PRE-05 | Explicit approval from business owner / programme lead | Programme Lead | **APPROVED — 27 Apr 2026** |
| PRE-06 | Human review of Flow XML diff | Delivery Lead | **COMPLETE — 27 Apr 2026** |
| PRE-07 | Production smoke test — transition one Opportunity to Closed Won, confirm email received | QA / Salesforce Admin | **PASS — 27 Apr 2026** — Opp `006TY00000vLQOTYA4`, Phase I Unit Low, email delivery confirmed by Amit Kumar from Salesforce email logs |

### Production deployment command (when all prerequisites met)

```bash
sf project deploy start \
  --source-dir force-app/main/default/flows/Notify_Closed_Won_After_Save.flow-meta.xml \
  --target-org <PRODUCTION_ORG_ALIAS>
```

> This command must not be executed from Claude Code without explicit instruction. It must only be run after all prerequisites above are confirmed and approval is documented on the Linear issue.

---

## 15. Rollback Plan

The Flow can be deactivated in under 60 seconds from Setup > Flows. No data loss. No record impact.

**Steps:**
1. Setup → Flows
2. Find `Notify Closed Won After Save`
3. Click Deactivate → Confirm

Deactivation immediately stops all future sends. It does not recall emails already delivered.

| Component | Rollback possible? | Method |
|---|---|---|
| Flow | Yes — immediate | Deactivate in Setup > Flows |
| `Bypass_Flow` custom permission | Yes (shared) | Delete only if no other Flows reference it |
| `Opportunity_ID_18__c` | Yes | Delete via Object Manager — no data stored |
| `Salesforce_Base_URL` | Yes (shared) | Delete only if no other Flows reference it |
| Emails already sent | No | Cannot be recalled |

---

## 16. Support Notes

| Query | Contact / Action |
|---|---|
| Email not received after qualifying Closed Won update | Check org email deliverability. Check Bypass_Flow permission on running user. Check Flow Interview debug log. |
| False send (email when it should not have been) | Deactivate Flow immediately from Setup > Flows. |
| Flow error on Opportunity save | Check fault path — failed email send is captured without rethrowing. If Opportunity save rolls back, another automation may be interfering. |
| Bypass not working | Verify PermissionSet assignment includes Bypass_Flow. Permissions are session-cached — test in a fresh session. |

### Key API names for support diagnosis

```
Flow:       Notify_Closed_Won_After_Save
Permission: Bypass_Flow
Field:      Service_Fees__c    (routing threshold field)
Field:      Business_Category__c  (routing category field)
Field:      Opportunity_ID_18__c  (record link formula — NOT standard Id)
Field:      Opportunity_Code__c   (deal identifier in email body)
```

### Debug log query

```apex
SELECT Id, Application, DurationMilliseconds, LogLength, StartTime
FROM ApexLog
WHERE LogUserId = '<UserIdHere>'
ORDER BY StartTime DESC LIMIT 10
```

A `CODE_UNIT_STARTED|[EXTERNAL]|Flow:Opportunity` entry with duration ≥ 500ms at the time of a Closed Won stage update indicates the Flow ran. Duration < 5ms indicates the Flow entry criteria or bypass check blocked execution.

---

## 17. Linear Issue Status

| Field | Value |
|---|---|
| Issue | SAL-9 |
| Title | [Orbit Notification] Opportunity Closed Won Notification |
| Status | In Progress |
| Assignee | VP Technology DATALEO AI |
| Priority | High |
| Milestone | Requirements Signed Off |
| Last updated | 26 April 2026 |

The issue must **not** be closed until all Section 14 prerequisites are resolved, production deployment is complete, and production smoke test passes.

---

*SAL-9 Delivery Handoff — Astrum Orbit Programme — Notification 9 of 14*
*Prepared: 26 April 2026 | Sandbox: astrum--astrumpar.sandbox.my.salesforce.com | Production: NOT deployed*
