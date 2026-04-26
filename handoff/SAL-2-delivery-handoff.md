# SAL-2 Delivery Handoff Note
## Critical Stage Progression Alert

| Field | Value |
|---|---|
| Linear Issue | SAL-2 |
| Notification Number | 2 of 14 |
| Programme | Astrum Orbit |
| Workstream | Sales Cloud — Opportunity Notifications |
| Prepared by | Amit Kumar (Salesforce Admin) |
| Date | 25 April 2026 |
| Sandbox org | astrum--astrumpar.sandbox.my.salesforce.com |
| Production deployment | **COMPLETE — 2026-04-25T20:10:47Z** |
| Production smoke test | **PASS — 2026-04-25T21:18:22Z** |
| Overall status | **Live in production. Smoke test passed. Awaiting Linear close and merge approval.** |

---

## 1. Executive Summary

The SAL-2 Critical Stage Progression Alert has been designed, built, deployed to sandbox, fully UAT-tested, deployed to production, and smoke-tested. The Flow fires immediately when an Opportunity's `Opp_Probability__c` picklist field is updated to `75` or `90` from any other value, and sends a plain-text email to five fixed stakeholders with the full commercial context required to react quickly.

All 13 SAL-2 test cases pass (HP-01–06, IDEM-01–04, BYP-01–02, CRE-01). The Flow is Active in production as v2 (`301TY00000rVQPaYAO`). Production smoke test passed on 2026-04-25 — email delivery confirmed via Setup → Email Log Files.

This is notification 2 of 14 in the Orbit Opportunities suite and is part of the first build wave alongside SAL-9 (Closed Won) and SAL-10 (Closed Lost).

---

## 2. Business Requirement Delivered

**Requirement:** Send an immediate email to five named stakeholders whenever an Opportunity moves into a critical probability band — specifically, when `Opp_Probability__c` is updated to `75` or `90` from any other value. The email must carry sufficient commercial context (account, deal code, fees, stage, study data, next actions) for recipients to react and prioritise without opening Salesforce.

**Delivered:**

| Requirement | Status |
|---|---|
| Fires on update to 75% | DELIVERED |
| Fires on update to 90% | DELIVERED |
| Fires on 75→90 progression (new alert for new band) | DELIVERED |
| Does not fire on re-save with no probability change | DELIVERED |
| Does not fire on creation (default — OQ-1) | DELIVERED |
| Sends to all five fixed recipients | DELIVERED |
| Carries all 15 PRD payload fields (Study_Countries__c removed v1.1 — data-quality guardrail) | DELIVERED |
| Previous probability shown in email body | DELIVERED |
| Clickable Salesforce record link | DELIVERED |

---

## 3. Metadata Components Changed

### Sandbox

| Component | Type | API Name | Action | Date |
|---|---|---|---|---|
| Notify Critical Stage Progression After Save | Flow (AutoLaunchedFlow, After Save) | `Notify_Critical_Stage_Progression_After_Save` | Created — Active | 25 Apr 2026 |
| Bypass Flow | Custom Permission | `Bypass_Flow` | Deployed as infrastructure | 25 Apr 2026 |
| Opportunity ID 18 | Formula Field on Opportunity | `Opportunity_ID_18__c` | Deployed as infrastructure | 25 Apr 2026 |

### Production — `astrum-prod` (astrum.my.salesforce.com)

Deployed via manifest `manifest/package-sal-2-production.xml`. All three components created in production on 2026-04-25.

| Component | Type | API Name | Production ID | Date |
|---|---|---|---|---|
| Notify Critical Stage Progression After Save | Flow (AutoLaunchedFlow, After Save) | `Notify_Critical_Stage_Progression_After_Save` | `301TY00000rVQPaYAO` (v2, Active) | 25 Apr 2026 |
| Bypass Flow | Custom Permission | `Bypass_Flow` | Created in production | 25 Apr 2026 |
| Salesforce Base URL | Custom Label | `Salesforce_Base_URL` | `101TY00000rVYYOYA4` | 25 Apr 2026 |

`Salesforce_Base_URL` = `https://astrum.my.salesforce.com`. This is shared Orbit infrastructure — all subsequent notifications (SAL-9, SAL-10, etc.) reference it directly; do not re-deploy.

**No new custom objects, fields, or validation rules were created for SAL-2.**

### Source artefacts

| Artefact | Location |
|---|---|
| PRD | `PRDS/SAL-2-critical-stage-progression-alert.md` |
| Flow XML | `force-app/main/default/flows/Notify_Critical_Stage_Progression_After_Save.flow-meta.xml` |
| Custom Label | `force-app/main/default/labels/CustomLabels.labels-meta.xml` |
| Production manifest | `manifest/package-sal-2-production.xml` |
| Production validation output | `validation/SAL-2-production-validation-output.md` |
| Production smoke test | `validation/SAL-2-production-smoke-check.md` |
| Git branch | `feature/SAL-2-critical-stage-progression-alert` |
| Production deploy commit | `1c5f252` |

---

## 4. Final Trigger Criteria

**Object:** Opportunity  
**Trigger timing:** After Save  
**Trigger event:** A record is **updated** (creation excluded — see Section 12, OD-01)

**Entry conditions — custom logic `(A OR B) AND C`:**

| Condition | Field | Operator | Value |
|---|---|---|---|
| A | `Opp_Probability__c` | Equals | `75` |
| B | `Opp_Probability__c` | Equals | `90` |
| C | `Opp_Probability__c` | IsChanged | `true` |

> **Critical implementation note:** `Opp_Probability__c` is a **custom Picklist field** storing bare integer strings (`"75"`, `"90"`). It is the sole authoritative trigger field for all SAL programme notifications. The standard `Opportunity.Probability` (Percent) field is **never used** — see Section 7.

Condition C uses the native Flow `IsChanged` operator, which evaluates `$Record__Prior.Opp_Probability__c ≠ $Record.Opp_Probability__c` without requiring a helper field or SOQL query. It prevents re-send on any save where the probability value is unchanged between the prior and current state.

---

## 5. Email Recipients

Recipients are fixed. All five addresses receive every qualifying alert regardless of Business Category, Stage, or any other field. No dynamic routing matrix is in scope for SAL-2.

| Recipient | Email address |
|---|---|
| RFP / RFI inbox | rfp.rfi@astrumcro.com |
| Jordi Picas | jordi.picas@astrumcro.com |
| Cristina Lopes | cristina.lopes@astrumcro.com |
| Anthony Gibson | anthony.gibson@astrumcro.com |
| Vania Araujo | vania.araujo@astrumcro.com |

The Opportunity Owner is **not** included per the Linear issue specification. Adding the Owner is a one-line change to the Send Email element if the business later requires it.

---

## 6. Email Content

### Subject line

```
Critical Stage Progression. {Opportunity Name} moved to {Opp_Probability__c}%
```

> **Correction from Linear issue:** The Linear-suggested subject referenced `{!Opportunity.Probability}` — the standard prohibited field. The delivered subject uses `{!Get_Opportunity_Detail.Opp_Probability__c}`. The `%` character is a literal suffix because the picklist stores bare integers (`75`, `90`).

### Body (plain text, all 16 payload fields)

```
CRITICAL STAGE PROGRESSION ALERT

Account:                     {Account Name}
Opportunity:                 {Opportunity Name}
Opportunity Code:            {Opportunity_Code__c}

Previous Probability:        {$Record__Prior.Opp_Probability__c}%
New Probability:             {Opp_Probability__c}%
Stage:                       {StageName}
Service Fees:                {Service_Fees__c}
Close Date:                  {CloseDate}

Therapeutic Area:            {Therapeutic_Area__c}
Indication:                  {Indication__c}
Entities Providing Services: {Entities_Providing_Services__c}

Next Specific Action:        {Next_specific_action__c}
Date of Next Action:         {Date_of_next_specific_action__c}
Person Responsible:          {Person_responsible_for_next_action__c}

View record in Salesforce:
https://astrum--astrumpar.sandbox.my.salesforce.com/{Opportunity_ID_18__c}

---
This is an automated notification from Salesforce.
Please do not reply to this email.
```

**Previous Probability** is rendered using `{!$Record__Prior.Opp_Probability__c}`, a native after-save Flow system variable. No helper field is required.

**Record link** is constructed from `Opportunity_ID_18__c` (Formula: `CASESAFEID(Id)`), not the standard 15-char `Id` field. The sandbox URL prefix is currently hardcoded — see OD-02 in Section 13.

### Blank field handling (MVP)

All 15 field rows render unconditionally (Study_Countries__c removed v1.1). A blank field renders as an empty value beside the label. Conditional blank-row suppression is documented as a future enhancement in the PRD.

---

## 7. Excluded Fields and Rationale

| Field | API Name | Type | Reason excluded |
|---|---|---|---|
| Standard Probability | `Probability` | Percent (standard) | **Programme-prohibited.** Memory Pack FR-07 NEVER guardrail: "Do not reference the standard Probability field in any Flow condition, formula, or email body." This field is managed by Salesforce and can be overridden by stage transitions, creating ambiguity. `Opp_Probability__c` is the sole authoritative field. |
| Probability formula | `Probability__c` | Formula (Percent) | Display/reporting field only. Returns 75 for Change Order opps in certain stages; otherwise returns standard Probability. Not suitable as a trigger field and not included in email payload. |
| Study Countries | `Study_Countries__c` | Picklist (Multi-Select) | **Removed from SAL-2 payload (v1.1, 25 Apr 2026).** Originally included per Linear issue requirements (PRD v1.0). Removed before production smoke test per Astrum Orbit data-quality guardrail — picklist values not cleaned or approved for notification use. Memory Pack guardrail overrides the Linear requirement. Can be reinstated after explicit picklist cleanup and stakeholder approval. |
| Opportunity Owner | `OwnerId` | Lookup | Not in the SAL-2 recipient specification. Can be added as a recipient if business requests it. |
| Total Fees | `Total_Fees__c` | Formula (Currency) | Not requested in SAL-2 Linear issue payload. In scope for other notifications (e.g. SAL-9). |

---

## 8. Duplicate Prevention Design

**Method:** Native `IsChanged` operator on `Opp_Probability__c` in Flow entry conditions.

The Flow entry condition C (`Opp_Probability__c` IsChanged = true) uses the Salesforce platform's native prior-value comparison. This evaluates `$Record__Prior.Opp_Probability__c ≠ $Record.Opp_Probability__c` without any SOQL query or helper field.

| Scenario | Prior value | New value | Flow fires? |
|---|---|---|---|
| 50 → 75 | `50` | `75` | Yes |
| 50 → 90 | `50` | `90` | Yes |
| 75 → 90 | `75` | `90` | Yes — new alert for new band |
| 75 → 75 (re-save, no change) | `75` | `75` | No — IsChanged = false |
| 90 → 90 (re-save, no change) | `90` | `90` | No — IsChanged = false |
| 75 → 50 (downward) | `75` | `50` | No — conditions A and B fail |
| 25 → 50 (non-target values) | `25` | `50` | No — conditions A and B fail |

**No sent-flag field required.** No log object required. The prior-value approach is sufficient for MVP.

---

## 9. Bypass Logic

Every record-triggered Flow in the programme must check the `Bypass_Flow` custom permission as its **first element** (CLAUDE.md hard rule). This prevents unintended emails during data loads, bulk migrations, and integration API runs.

**Element:** `Check_Bypass_Permission` (Decision — first element after start)

| Outcome | Condition | Action |
|---|---|---|
| Bypassed | `$Permission.Bypass_Flow` Equals `true` | Flow terminates immediately. No email sent. Opportunity record save completes normally. |
| Proceed (default) | Bypass permission not held | Flow continues to Get Records → Send Email |

**Assigning the bypass:** Create a PermissionSet containing the `Bypass_Flow` custom permission and assign it to the integration/data-load user before running bulk operations.

**UAT confirmation:** BYP-01 confirmed the Flow entered but terminated at the bypass decision (3ms execution vs 179–560ms for full execution). BYP-02 confirmed normal email execution resumed after the PermissionSet assignment was removed.

---

## 10. Sandbox Deployment Evidence

| Item | Value |
|---|---|
| Flow API Name | `Notify_Critical_Stage_Progression_After_Save` |
| Flow ID | `301UD00000VgdXnYAJ` |
| Deploy ID | `0AfUD00000GnvlV0AB` |
| Status | Active |
| Target org | `astrum--astrumpar.sandbox.my.salesforce.com` |
| Deployed | 25 April 2026 |
| CLI command | `sf project deploy start --source-dir force-app/main/default/flows/Notify_Critical_Stage_Progression_After_Save.flow-meta.xml --target-org amit.kumar@astrumcro.com.astrumpar` |

**Tooling API verification:**

```sql
SELECT Id, MasterLabel, Status, ProcessType FROM Flow
WHERE MasterLabel = 'Notify Critical Stage Progression After Save'
-- Result: 301UD00000VgdXnYAJ | Active | AutoLaunchedFlow
```

**XML errors resolved during build** (documented so future builds avoid the same pitfalls):

1. `--` (double hyphen) is illegal inside XML comments (`<!-- -->`). Org name `astrum--astrumpar` in comment text caused a parse error. Fixed by removing the org name from all comments.
2. `<recordTriggerType>` is valid only inside `<start>`, not at the top-level `<Flow>` element. Initial build placed it at the top level, causing a deploy error. Fixed by removing it from the top level (it remains correctly inside `<start>`).

Full deploy log: `validation/SAL-2-sandbox-deploy-output.md`

---

## 11. UAT Evidence Summary

All 13 test cases executed via anonymous Apex (`sf apex run`) against the sandbox. Flow execution confirmed by ApexLog timing analysis (active Flow unit: 179–560ms vs <5ms for entry-criteria fail) and named code unit in limit-check logs (`Notify_Critical_Stage_Progression_After_Save`).

### Happy Path — 6/6 PASS

| ID | Scenario | Result |
|---|---|---|
| HP-01 | 50→75 | PASS — 383ms, named limit-check log confirmed |
| HP-02 | 50→90 | PASS — 209ms |
| HP-03 | 75→90 (inter-band progression) | PASS — 424ms |
| HP-04 | Blank `Opportunity_Code__c`, 50→90 | PASS — 415ms, no fault |
| HP-05 | 7 blank payload fields, 50→75 | PASS — 320ms, no fault |
| HP-06 | 25→75 (non-adjacent jump) | PASS — 179ms |

### Idempotency — 4/4 PASS

| ID | Scenario | Result |
|---|---|---|
| IDEM-01 | Description-only edit on opp at 75 | PASS — <1ms (IsChanged blocked) |
| IDEM-02 | Re-save opp at 90 unchanged | PASS — <1ms |
| IDEM-03 | Downward move 75→50 | PASS — <1ms |
| IDEM-04 | 25→50 (neither value is 75 or 90) | PASS — <1ms |

### Bypass — 2/2 PASS

| ID | Scenario | Result |
|---|---|---|
| BYP-01 | Trigger with `Bypass_Flow` permission active | PASS — 3ms (entered, bypassed, exited) |
| BYP-02 | Trigger after permission removed | PASS — 366ms (full execution resumed) |

### Creation Exclusion — 1/1 PASS

| ID | Scenario | Result |
|---|---|---|
| CRE-01 | Insert new Opportunity with `Opp_Probability__c=75` | PASS — no named limit-check log; `recordTriggerType=Update` excluded insert |

Full evidence: `validation/SAL-2-UAT-evidence.md`

---

## 12. Known Limitations

| Ref | Limitation | Impact | Future fix |
|---|---|---|---|
| L-01 | **Blank field rows are unconditional (MVP).** All 15 payload rows render regardless of whether the field has a value. A blank field shows a label with an empty value. | Cosmetic — emails with many blank fields have empty rows. | Conditional blank-row suppression via Decision elements before each row. Logged as future enhancement. |
| L-02 | **Sandbox URL hardcoded in email body.** The record link uses `https://astrum--astrumpar.sandbox.my.salesforce.com/`. If promoted to production without change, the link will break. | Blocker for production | Externalise to Custom Label `Salesforce_Base_URL` before production deploy (OD-02). |
| L-03 | ~~**Study Countries renders as semicolons.**~~ **Resolved — field removed from payload (v1.1).** `Study_Countries__c` was removed before production smoke test per Astrum Orbit data-quality guardrail. No longer applicable. | N/A — field removed | Reinstate only after picklist cleanup and stakeholder approval. |
| L-04 | **Creation trigger excluded by default (OQ-1).** A new Opportunity created directly at 75% or 90% does not fire the alert. | Commercial — unlikely edge case in practice | Change `<recordTriggerType>Update</recordTriggerType>` to `CreateAndUpdate` after explicit business sign-off. |
| L-05 | **Email delivery not verifiable via SOQL.** The `emailSimple` core action sends via the org email relay and does not create `EmailMessage` records. Flow execution evidence is via debug log timing, not delivery receipt. | Operational — email delivery depends on org email deliverability settings | Verify sandbox deliverability setting is `All Email` in Setup > Deliverability before go-live. |

---

## 13. Production Deployment Prerequisites

**Production deployment has not been performed and must not be performed without explicit written approval.**

The following items must be completed before any production promotion:

| Ref | Prerequisite | Owner | Status |
|---|---|---|---|
| PRE-01 | Explicit approval from business owner / programme lead | Commercial / Programme Lead | Pending |
| PRE-02 | **OD-02:** Externalise sandbox URL to Custom Label `Salesforce_Base_URL`. Update Flow XML to reference `{!$Label.Salesforce_Base_URL}` instead of the hardcoded sandbox prefix. | Solution Architect / Salesforce Admin | Not started |
| PRE-03 | Verify org email deliverability in production is set to `All Email` | Salesforce Admin | Not verified |
| PRE-04 | Human review of Flow XML diff between sandbox and production deployment. Reviewer must sign off that no unintended changes are included. | Delivery Lead | Not started |
| PRE-05 | Confirm recipient email addresses are valid in production (no sandbox-only accounts) | Delivery Lead | Not verified |
| PRE-06 | Confirm `Bypass_Flow` custom permission and `Opportunity_ID_18__c` formula field are deployed in production org | Salesforce Admin | Not verified |
| PRE-07 | Run smoke test in production: update one Opportunity to `Opp_Probability__c = 75`, confirm email received by at least one recipient | QA / Salesforce Admin | Not started |

### Production deployment command (when all prerequisites met)

```bash
sf project deploy start \
  --source-dir force-app/main/default/flows/Notify_Critical_Stage_Progression_After_Save.flow-meta.xml \
  --target-org <PRODUCTION_ORG_ALIAS>
```

> This command must only be executed after all prerequisites above are confirmed and approval is documented. It must not be executed from Claude Code without explicit instruction.

---

## 14. Rollback Plan

### Immediate deactivation (preferred)

The Flow can be deactivated in under 60 seconds from Setup > Flows. No data loss. No record impact. Deactivation stops all future sends immediately; it does not recall emails already delivered.

**Steps:**
1. Setup → Flows
2. Find `Notify Critical Stage Progression After Save`
3. Click Deactivate → Confirm

### Metadata rollback

```bash
# Revert to a specific prior version (if needed)
git checkout <prior-commit> -- force-app/main/default/flows/Notify_Critical_Stage_Progression_After_Save.flow-meta.xml
sf project deploy start \
  --source-dir force-app/main/default/flows/Notify_Critical_Stage_Progression_After_Save.flow-meta.xml \
  --target-org <TARGET_ORG>
```

### Rollback scope

| Component | Rollback possible? | Method | Notes |
|---|---|---|---|
| Flow | Yes | Deactivate in Setup > Flows | Immediate — no data impact |
| `Bypass_Flow` custom permission | Yes | Delete via Setup > Custom Permissions | Only if no other Flows reference it |
| `Opportunity_ID_18__c` formula field | Yes | Delete via Object Manager | No data stored; formula field only |
| Emails already sent | No | Cannot be recalled | Emails are delivered; rollback is forward-looking only |

---

## 15. Support Notes

### Who to contact

| Query | Contact |
|---|---|
| Email not received after qualifying update | Check org email deliverability setting. Check Bypass_Flow permission on running user. Check Flow interview debug log. |
| False send (email sent when it should not have been) | Deactivate Flow immediately. Check IsChanged conditions in Flow XML. |
| Flow error on Opportunity save | Check Flow fault path — a failed email send is captured without rethrowing, so the Opportunity save should complete. If save rolls back, another automation may be interfering. |
| Bypass not working | Verify the user's PermissionSet assignment includes `Bypass_Flow`. Permissions are session-cached; test in a fresh session. |

### Key API names for support diagnosis

```
Flow:       Notify_Critical_Stage_Progression_After_Save
Permission: Bypass_Flow
Field:      Opp_Probability__c  (trigger field — custom Picklist, NOT standard Probability)
Field:      Opportunity_ID_18__c  (record link formula)
Field:      Opportunity_Code__c  (deal identifier in email body)
```

### Debug log query

```apex
// Query ApexLog for Flow execution evidence
SELECT Id, Application, DurationMilliseconds, LogLength, StartTime
FROM ApexLog
WHERE LogUserId = '<UserIdHere>'
ORDER BY StartTime DESC LIMIT 10
```

A log with DurationMilliseconds > 150 from a Flow:Opportunity unit at the time of an Opportunity update indicates the Flow ran. A second log named `Notify_Critical_Stage_Progression_After_Save` in the limit-check position confirms execution.

### Important: do not reference standard Probability

`Opp_Probability__c` (custom Picklist) is the sole trigger field. If support investigation involves checking probability values, always query `Opp_Probability__c`, never `Probability` or `Probability__c`.

---

## 16. Linear Issue Status

| Field | Value |
|---|---|
| Issue | SAL-2 |
| Title | [Orbit Notification] Critical Stage Progression Alert |
| URL | https://linear.app/dataleo/issue/SAL-2/orbit-notification-critical-stage-progression-alert |
| Status | **Backlog** (not moved to Done — awaiting production deployment approval) |
| Assignee | bhutesh.g@dataleo.ai |
| Priority | High |
| Milestone | Requirements Signed Off |
| Last updated | 25 April 2026 |

**The issue has not been closed or marked Done.** A build summary comment was added to the issue on 25 April 2026 (comment ID `9eeb73ed`). Status will be moved to Done only upon explicit approval and confirmed production deployment.

---

*SAL-2 Delivery Handoff — Astrum Orbit Programme — Notification 2 of 14*
*Prepared: 25 April 2026 | Org: astrum--astrumpar.sandbox.my.salesforce.com | Production: Not deployed*
