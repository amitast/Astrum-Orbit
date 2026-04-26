# SAL-2 Memory Update Proposal

**Programme:** Astrum Orbit
**Prepared:** 2026-04-26
**Scope:** Durable knowledge from SAL-2 Critical Stage Progression Alert — design, build, production deployment, and smoke test
**Status of SAL-2:** Complete. Merged to main (`9f9c1f8`). Linear Done (`2026-04-26T05:43:05Z`).
**Prepared by:** Claude Code delivery session — documentation analysis mode only

> This file proposes updates to project memory. It does not edit any primary source document.
> All facts are sourced from committed evidence files or confirmed via read-only production
> Tooling API queries. Uncertain items are marked **ORG-VALIDATION REQUIRED** or **EVIDENCE NOT FOUND**.

---

## 1. Executive Summary

SAL-2 (Critical Stage Progression Alert) is the first completed production notification in the Orbit Opportunities suite. It delivered an after-save record-triggered Flow that fires immediately when `Opp_Probability__c` changes to `75` or `90` on an Opportunity update, sending a plain-text email to five fixed stakeholders.

SAL-2 established the **end-to-end production delivery pattern** for the Orbit notification workstream: PRD-first design, schema validation against the live org, sandbox build and UAT, production check-only validation, explicit approval gate, quick deploy, production smoke test, documentation commit, Linear closure, and merge to main. This pattern is the template for SAL-9, SAL-10, and all subsequent notifications.

Key durable outputs beyond the Flow itself:

- `Salesforce_Base_URL` Custom Label is now live in production and is shared Orbit infrastructure — all future notifications reference it without re-deploying.
- `Bypass_Flow` Custom Permission is confirmed present in production.
- `Opportunity_ID_18__c` formula field is confirmed present in production.
- `{!$Record__Prior.Opp_Probability__c}` is confirmed as a native after-save Flow variable requiring no helper field — **NF6 (`Prior_Probability__c`) is not needed for SAL-2 and should be removed from the net-new field list**.
- `Study_Countries__c` was intentionally excluded from the payload — the Memory Pack NEVER guardrail overrides the original Linear issue requirement.

---

## 2. Confirmed Production Facts

All facts below are confirmed via committed evidence files or read-only Tooling API query performed 2026-04-26.

| Fact | Value | Source |
|---|---|---|
| Flow API Name | `Notify_Critical_Stage_Progression_After_Save` | Committed Flow XML; Tooling API |
| FlowDefinition ID | `300TY00000zHjLtYAK` | Tooling API `FlowDefinition` query — 2026-04-26 |
| Active Version | Version 2 | Tooling API `FlowDefinition.ActiveVersionId` |
| Active Version ID | `301TY00000rVQPaYAO` | Tooling API — confirmed Active |
| Version 1 ID | `301TY00000rVYYPYA4` | Tooling API — Status: Obsolete (initial deploy) |
| Version 3 ID | `301TY00000rVPN9YAO` | Tooling API — Status: Obsolete |
| Custom Label API Name | `Salesforce_Base_URL` | Committed: `force-app/main/default/labels/CustomLabels.labels-meta.xml` |
| Custom Label value | `https://astrum.my.salesforce.com` | Handoff: `handoff/SAL-2-delivery-handoff.md` |
| Custom Label Production ID | `101TY00000rVYYOYA4` | `validation/SAL-2-production-validation-output.md` |
| Custom Permission | `Bypass_Flow` present in production | Deploy output: `validation/SAL-2-production-deploy-output.md` |
| Production Org URL | `https://astrum.my.salesforce.com` | Confirmed throughout deployment evidence |
| Production Org ID | `00Dd100000AMk1dEAD` | `validation/SAL-2-production-validation-output.md` |
| Production deployment timestamp | `2026-04-25T20:10:47Z` | Handoff; deploy output |
| Quick Deploy Job ID | `0AfTY000003kZfN0AU` | Deploy output |
| Validation Job ID | `0AfTY000003kZaX0AU` | `validation/SAL-2-production-validation-output.md` |
| Smoke test result | PASS | `validation/SAL-2-production-smoke-check.md` |
| Smoke test timestamp | `2026-04-25T21:18:22Z` | Smoke check file |
| Smoke test record | Opportunity ADP1005 — Ketamine BE study (Adragos Pharma) | Smoke check file |
| Smoke test Opportunity ID | `006TY00000qpSxEYAU` | Smoke check file |
| Email delivery confirmed via | Setup → Email Log Files | Smoke check execution results |
| Record link confirmed | `https://astrum.my.salesforce.com/006TY00000qpSxEYAU` | Smoke check execution results |
| Linear SAL-2 status | Done | Linear MCP query; `completedAt: 2026-04-26T05:43:05Z` |
| Git merge commit | `9f9c1f8` — merged to `main` | Git log |
| `Study_Countries__c` in payload | **NOT included** — removed pre-production (v1.1, commit `660e1b2`) | PRD v1.1; deploy output guardrail check |

---

## 3. Durable Design Decisions

The following decisions were confirmed during SAL-2 and should inform all subsequent notification builds.

### 3.1 `{!$Record__Prior.Opp_Probability__c}` is native — no helper field required

**Decision:** The after-save Flow system variable `{!$Record__Prior.Opp_Probability__c}` is natively available in record-triggered after-save Flows. It provides the prior picklist value without a helper field, before-save Flow, or SOQL query.

**Impact on Memory Pack:** Net-new field **NF6 (`Prior_Probability__c`)** listed in Memory Pack Section 11 and in the 2026-04-25 Memory Update Section 14 is **not needed for SAL-2**. It should be removed from the net-new field list or downgraded to a note that native prior-value access is confirmed for after-save context.

**Applied in:** SAL-2 entry condition C (`{!$Record__Prior.Opp_Probability__c}` IsChanged = true) and email body (`{!$Record__Prior.Opp_Probability__c}%` for Previous Probability row).

**Also applies to:** SAL-9 and SAL-10 prior-value conditions (StageName prior-value comparison for before/after state detection).

### 3.2 `IsChanged` operator is sufficient for idempotency — no sent-flag field needed

**Decision:** The native `IsChanged` operator in Flow entry conditions correctly evaluates `$Record__Prior.Field ≠ $Record.Field`. It prevents re-send on any save where the probability value is unchanged. All 4 IDEM test cases (IDEM-01–04) passed using this approach.

**No sent-flag Boolean helper field is required for MVP immediate notifications.** A log object is still required for digest notifications (SAL-3, SAL-5, SAL-6, SAL-7, SAL-8) but not for SAL-2, SAL-9, or SAL-10.

### 3.3 `Salesforce_Base_URL` Custom Label is shared Orbit infrastructure — do not re-deploy

**Decision:** `Salesforce_Base_URL` is deployed to production with value `https://astrum.my.salesforce.com` (ID: `101TY00000rVYYOYA4`). All future Orbit notifications that construct record links must reference `{!$Label.Salesforce_Base_URL}` directly. Do not include the label in future SAL-specific deployment manifests.

**Pattern in Flow email body:** `{!$Label.Salesforce_Base_URL}/{!Get_Opportunity_Detail.Opportunity_ID_18__c}`

### 3.4 `Bypass_Flow` Custom Permission is shared Orbit infrastructure — do not re-deploy

**Decision:** `Bypass_Flow` is confirmed present in production (created as part of SAL-2 deployment). SAL-9 and SAL-10 manifests should NOT include it. Simply reference `$Permission.Bypass_Flow` in Flow logic.

### 3.5 `Opportunity_ID_18__c` formula field is shared Orbit infrastructure — do not re-deploy

`Opportunity_ID_18__c` (Formula: `CASESAFEID(Id)`) is confirmed present in sandbox (deployed 25 Apr 2026) and in production. SAL-9 and SAL-10 manifests should NOT include it.

### 3.6 Memory Pack NEVER guardrail overrides original Linear issue requirements

**Decision:** `Study_Countries__c` was listed in the original Linear SAL-2 issue as a required email payload field (PRD v1.0). It was removed before production (PRD v1.1, commit `660e1b2`) because the Memory Pack NEVER guardrail explicitly prohibits using `Study_Countries__c` in email payloads until picklist values are cleaned and approved.

**Rule confirmed:** When a Linear issue requirement conflicts with a Memory Pack NEVER guardrail, the Memory Pack guardrail takes precedence. The PRD must document the deviation with explicit rationale.

### 3.7 Use a SAL-specific production manifest

**Decision:** Deploy each notification to production using a scoped `manifest/package-sal-N-production.xml` containing only the components for that notification. Do not use a generic `manifest/package.xml`. This minimises blast radius, makes deployment evidence traceable per notification, and prevents inadvertent inclusion of in-progress components.

### 3.8 `emailSimple` Flow action: email relay behaviour and governor limits

**Confirmed behaviour** (observed in SAL-2 production smoke test):
- `emailSimple` routes through the org email relay, not through the Salesforce email service
- It does **not** count under the `Number of Email Invocations` governor limit (observed: `Number of Email Invocations: 0` in Apex log — expected behaviour, not an error)
- It does **not** create `EmailMessage` records in Salesforce (no SOQL-based delivery verification is possible)
- **Email delivery verification path:** Setup → Email Log Files — the only reliable confirmation method for `emailSimple` delivery in production

### 3.9 Fault path must not rethrow

**Decision confirmed by UAT and production:** The fault path from the Send Email element must capture `$Flow.FaultMessage` and route to an End element without rethrowing. A failed email send must not roll back the Opportunity DML. This pattern was confirmed during SAL-2 and must be replicated in SAL-9 and SAL-10.

---

## 4. Reusable Build Pattern for Immediate Opportunity Notifications

The following sequence was validated end-to-end by SAL-2. It is the recommended build pattern for SAL-9, SAL-10, and all future immediate record-triggered notifications.

```
Step 1:  PRD first
         Write PRDS/SAL-N-<name>.md before any metadata.
         Include all sections: requirements, schema mapping, trigger criteria, 
         bypass logic, email template, test cases, deployment plan, rollback plan.

Step 2:  Schema validation
         Run Tooling API / SOQL queries against the sandbox org to confirm all 
         field API names, picklist values, and object relationships before building.
         Mark unconfirmed fields as ORG-VALIDATION REQUIRED.

Step 3:  Write Flow XML
         Follow element sequence:
         Start (entry criteria) → Decision (Check_Bypass_Permission) → 
         Get Records (retrieve Opportunity with cross-object fields) → 
         Send Email (emailSimple) with fault path → End elements

Step 4:  Create SAL-specific production manifest
         manifest/package-sal-N-production.xml
         Include ONLY the notification-specific Flow.
         Do NOT include Salesforce_Base_URL, Bypass_Flow, Opportunity_ID_18__c — 
         these are shared infrastructure already in production.

Step 5:  Sandbox deploy and UAT
         Deploy to sandbox. Run full test suite (happy path, idempotency, bypass, 
         creation edge case). All cases must pass before activation.
         Activate Flow in sandbox only after all tests pass.

Step 6:  Production validation (check-only)
         sf project deploy start \
           --manifest manifest/package-sal-N-production.xml \
           --target-org astrum-prod \
           --dry-run \
           --test-level RunLocalTests \
           --wait 60 --json
         Capture validation Job ID. Record in validation/SAL-N-production-validation-output.md.

Step 7:  Explicit approval gate
         Programme lead / business owner must explicitly approve before quick deploy.
         Do not proceed without written approval.

Step 8:  Quick deploy
         sf project deploy quick \
           --job-id <validationJobId> \
           --target-org astrum-prod \
           --wait 60 --json
         Record deploy output in validation/SAL-N-production-deploy-output.md.

Step 9:  Verify active version via Tooling API
         SELECT Id, DeveloperName, ActiveVersionId FROM FlowDefinition 
         WHERE DeveloperName = '<ApiName>'
         Use Tooling API result as authoritative active version ID — 
         do not rely on deploy output alone.

Step 10: Production smoke test
         Execute smoke test per plan. Record results in 
         validation/SAL-N-production-smoke-check.md.
         Confirm email delivery via Setup → Email Log Files.
         Revert the test record after smoke test completes.

Step 11: Documentation commit
         Commit all evidence files, updated handoff, updated PRD status.
         Commit message format: docs(SAL-N): record production deployment and smoke test evidence

Step 12: Linear update and closure
         Add production completion comment to Linear issue.
         Move status to Done.
         Wait for explicit approval before merging to main.

Step 13: Merge to main
         git checkout main
         git merge --no-ff feature/SAL-N-<name> -m "merge(SAL-N): <title>"
         Do not push to remote until approved.
```

---

## 5. Corrections to Earlier Assumptions

| Earlier assumption | What actually happened | Implication |
|---|---|---|
| NF6 (`Prior_Probability__c`) is required for SAL-2 email payload | `{!$Record__Prior.Opp_Probability__c}` is available natively in after-save Flow context. No helper field needed. | **Remove NF6 from net-new field list.** Mark as resolved. |
| SAL-2 would use a single Flow version in production | Three versions were created: v1 (initial deploy), v2 (Study_Countries__c fix), v3 (Obsolete). Active = v2. | Always verify active version via `FlowDefinition` Tooling API query — do not trust initial deploy output alone. |
| Initial deploy output gives the current active version ID | The initial deploy created v1. Subsequent fix deployment created v2. Active version changed. | Active version must be re-confirmed via Tooling API after all post-deploy fixes. |
| `Study_Countries__c` was in the SAL-2 email payload per Linear requirements | Removed pre-production. Memory Pack NEVER guardrail takes precedence over Linear issue contents. | Apply the same guardrail check to SAL-9 and SAL-10 payload field lists — cross-reference against Memory Pack NEVER rules before finalising PRD payload. |
| OD-02 (URL externalisation) would require manual Flow update at deploy time | Resolved cleanly by creating `Salesforce_Base_URL` Custom Label before production validation. Flow XML references `{!$Label.Salesforce_Base_URL}` throughout. | This pattern is confirmed. SAL-9 and SAL-10 Flow XML must reference the label from day one — do not hardcode any org URL in Flow XML. |
| Production deployment had not been performed (handoff note dated 25 Apr 2026) | Production deployment completed 2026-04-25T20:10:47Z. Full smoke test passed same day. | The 2026-04-25 Memory Update Section 8 table row for SAL-2 shows "Backlog" — this is stale. See recommended update in Section 8 below. |
| `Number of Email Invocations: 0` in Apex log indicates email did not send | This is expected behaviour for `emailSimple`. It routes via org email relay, not counted in this governor limit. | Do not treat `Number of Email Invocations: 0` as a failure indicator. Use Setup → Email Log Files for delivery confirmation. |

---

## 6. CLI and Release Lessons

### 6.1 Manifest scoping

- Always create a `manifest/package-sal-N-production.xml` for each notification deployment.
- Scope the manifest to notification-specific components only.
- Shared infrastructure (`Salesforce_Base_URL`, `Bypass_Flow`, `Opportunity_ID_18__c`) must NOT be included after first deployment — they are already in production.

### 6.2 Test level for production validation

- For this org, `--test-level RunLocalTests` was used for production validation.
- This ran 10 standard Salesforce Communities/Sites/Portal test classes — none specific to SAL-2.
- No SAL-2 Apex was deployed; no custom test classes exist. This is correct and expected for a Flow-only deployment.
- Do not reference non-existent Apex test class names in deployment commands.

### 6.3 Quick deploy promotes the validated job — always record both IDs

| ID type | SAL-2 value | Purpose |
|---|---|---|
| Validation Job ID | `0AfTY000003kZaX0AU` | Check-only validation — use with `--job-id` for quick deploy |
| Quick Deploy Job ID | `0AfTY000003kZfN0AU` | Actual deployment record — different ID from validation |

These are different IDs. Document both in the deploy output file. Do not confuse them.

### 6.4 Active version confirmation after deployment

After any production deployment of a Flow, run:
```bash
sf data query \
  --target-org astrum-prod \
  --use-tooling-api \
  --query "SELECT Id, DeveloperName, ActiveVersionId, LatestVersionId FROM FlowDefinition WHERE DeveloperName = '<ApiName>'"
```
Use `ActiveVersionId` from this query as the authoritative ID. Document it in the deployment evidence file.

### 6.5 Flow execution timing as smoke test evidence

UAT-validated timing ranges for `Notify_Critical_Stage_Progression_After_Save` (after-save, Opportunity):

| Scenario | Duration | Interpretation |
|---|---|---|
| Entry criteria not met (no match) | < 5ms | Flow evaluated conditions only — correct |
| Bypass permission held | ~3ms | Flow entered, bypassed, exited — correct |
| Full execution with email send | 179–560ms (UAT); 380ms (production) | Email send via `emailSimple` confirmed |

These timing bands can be used in future smoke tests to confirm whether a Flow executed. A production Opportunity save producing a Flow:Opportunity unit duration of 150ms–600ms is consistent with a SAL-type email send.

### 6.6 Revert approach in smoke tests

After a smoke test that updates `Opp_Probability__c`:
- Revert by setting the field back to its original value (null or prior value).
- Confirm SAL-2 did NOT re-trigger: all Flow units on the revert transaction complete in < 30ms (well below email send range).
- Re-trigger absence is structural: conditions A and B require the value to be 75 or 90 — reverting to null fails both.

### 6.7 Release gate: Linear must not be set to Done until smoke test passes

- SAL-2 was not moved to Done until after the smoke test result was confirmed and documentation was committed.
- The merge to main followed Linear closure.
- This sequence must be maintained for SAL-9 and SAL-10.

### 6.8 XML build lessons (applicable to all future Flow XML)

Two XML errors were encountered during SAL-2 sandbox build:

1. **Double hyphens in XML comments.** The string `--` is illegal inside `<!-- -->` XML comment blocks. The org name `astrum--astrumpar` caused a parse error when included in a comment. **Fix:** Remove org names and environment-specific strings from all XML comments in Flow files.

2. **`<recordTriggerType>` placement.** This element is valid only inside `<start>`, not at the top-level `<Flow>` element. If placed at the top level, the deployment fails. **Fix:** Ensure `<recordTriggerType>` appears only within the `<start>` block.

---

## 7. Evidence Files Created

| File | What it proves | Commit |
|---|---|---|
| `PRDS/SAL-2-critical-stage-progression-alert.md` (v1.1) | Full implementation PRD. PRD v1.1 records Study_Countries__c removal. Deployment Status section updated to LIVE IN PRODUCTION. | `f7cb967` |
| `force-app/main/default/flows/Notify_Critical_Stage_Progression_After_Save.flow-meta.xml` | Deployed Flow XML (with `{!$Label.Salesforce_Base_URL}`, Study_Countries__c removed, Bypass_Flow check as first element) | `1c5f252`, `660e1b2` |
| `force-app/main/default/labels/CustomLabels.labels-meta.xml` | `Salesforce_Base_URL` Custom Label source (`https://astrum.my.salesforce.com`) | `1c5f252` |
| `manifest/package-sal-2-production.xml` | SAL-2 scoped production manifest (3 components: Flow, CustomLabel, CustomPermission) | `1c5f252` |
| `validation/SAL-2-sandbox-deploy-output.md` | Sandbox deployment evidence. Flow ID in sandbox: `301UD00000VgdXnYAJ`. | `885b88a` |
| `validation/SAL-2-UAT-evidence.md` | All 13 test cases PASS (HP-01–06, IDEM-01–04, BYP-01–02, CRE-01). Timing evidence. | `885b88a` |
| `validation/SAL-2-production-validation-output.md` | Check-only validation: job `0AfTY000003kZaX0AU`. 3 components PASS. 10 Apex tests PASS. | `1c5f252` |
| `validation/SAL-2-production-deploy-output.md` | Quick deploy evidence. Flow version history. Active version confirmed via Tooling API. | `f7cb967` |
| `validation/SAL-2-production-smoke-check.md` | Smoke test PASS. Flow 380ms. Email delivery confirmed. Record link confirmed. | `f7cb967` |
| `handoff/SAL-2-delivery-handoff.md` | Full delivery handoff. Production component table. Support notes. Linear status at time of writing. | `f7cb967` |

---

## 8. Recommended Updates to Astrum Project Memory Pack

The following updates are proposed for `LLM-TXTS/Astrum_Project_Memory_Pack_v1.md`. Do not edit the master memory pack until approved.

---

### Update 8.1 — Section 2 (Current Delivery Focus): Update notification status

**Section to update:** Section 2 — NOTE for EMAIL NOTIFICATIONS

**Current text:**
> NOTE: EMAIL NOTIFICATIONS: 14 Opportunity pipeline notifications specified. Build order priority: notifications 2, 9, 10 first (cleanest trigger logic), then 4, 11, 12, 13; digest and historical-change notifications (3, 5, 6, 7, 8) require custom log object or helper fields before build.

**Proposed addition after this note:**
> UPDATE 2026-04-26: SAL-2 (Critical Stage Progression Alert) is COMPLETE — deployed to production (2026-04-25), smoke tested (PASS 2026-04-25T21:18:22Z), Linear Done. SAL-9 and SAL-10 are next. `Salesforce_Base_URL` Custom Label, `Bypass_Flow` Custom Permission, and `Opportunity_ID_18__c` formula field are all confirmed present in production and are shared Orbit infrastructure.

**Reason:** Section 2 still references the 14 notifications as unstarted. SAL-2 is now complete.
**Evidence source:** `handoff/SAL-2-delivery-handoff.md`, `validation/SAL-2-production-smoke-check.md`

---

### Update 8.2 — Section 10 (Email Notification Guardrails): Correct NF6 status and add production infrastructure note

**Section to update:** Section 10 — Guardrails for Email Notification Design

**Proposed addition (new ALWAYS rule):**
> ALWAYS Reference `{!$Label.Salesforce_Base_URL}` for the production org URL in all Flow email record links. This Custom Label (`Salesforce_Base_URL` = `https://astrum.my.salesforce.com`) is deployed in production. Do not hardcode org URLs in Flow XML. Do not re-deploy this label in future notification manifests.

**Proposed addition (new CONFIRMED note):**
> CONFIRMED 2026-04-26: `{!$Record__Prior.Opp_Probability__c}` is natively available in after-save record-triggered Flows. No prior-value helper field is needed for probability-based trigger conditions or email payload rendering. NF6 (`Prior_Probability__c`) is not required for SAL-2 and should be removed from the net-new field list.

**Reason:** The existing guardrails do not capture the Salesforce_Base_URL infrastructure pattern or the NF6 correction.
**Evidence source:** `validation/SAL-2-production-deploy-output.md`, `PRDS/SAL-2-critical-stage-progression-alert.md`, UAT evidence

---

### Update 8.3 — Section 11 (Known Gaps): Remove or retire NF6

**Section to update:** Section 11 — Net-New Fields Required

**Current text:**
> NF6 | Prior_Probability__c (Opportunity) | Text | Previous probability value for notification 2 email payload. Updated by before-save Flow.

**Proposed replacement:**
> NF6 | ~~Prior_Probability__c (Opportunity)~~ | **Not required.** `{!$Record__Prior.Opp_Probability__c}` is natively available in after-save Flows. Confirmed by SAL-2 production delivery (2026-04-26). No before-save Flow or helper field needed.

**Reason:** NF6 is listed as required but SAL-2 confirmed it is not needed. Leaving it as a "required" field will cause confusion in future sessions and may lead to unnecessary schema work.
**Evidence source:** `PRDS/SAL-2-critical-stage-progression-alert.md` Section 10 (FR-10); `handoff/SAL-2-delivery-handoff.md` Section 8

---

### Update 8.4 — Section 9 (Sales Cloud Guardrails): Add Study_Countries__c notification guardrail cross-reference

**Section to update:** Section 9 — BEFORE BUILD note about Study_Countries__c

**Current text:**
> BEFORE BUILD: Study_Countries__c picklist non-standard entries (free-text descriptions, TBD values, compound country descriptions) must be cleaned before this field is used in notification email payloads or Data Cloud segments.

**Proposed addition:**
> ENFORCED 2026-04-26: This guardrail was actively applied during SAL-2. The field was included in the original Linear SAL-2 issue requirements (PRD v1.0) but removed before production deployment (PRD v1.1, commit `660e1b2`) per this guardrail. The Memory Pack guardrail takes precedence over Linear issue requirements when they conflict. Apply the same check to SAL-9 and SAL-10 payload field lists.

**Reason:** Documents that the guardrail has been tested and enforced, and establishes clear precedence rule for future builds.
**Evidence source:** `PRDS/SAL-2-critical-stage-progression-alert.md` Section 3.4; commit `660e1b2`

---

## 9. Recommended Updates to Orbit Notification Requirements Memory

The following updates should inform `LLM-TXTS/Astrum_Orbit_Project_Memory_Update_2026-04-25.md` or a new memory update file.

### 9.1 SAL-2 status in notification delivery table (Section 8)

**Current:** SAL-2 row shows `Status: Backlog`
**Proposed:**

| ID | Title | Pattern | Priority | Status | Key constraint |
|---|---|---|---|---|---|
| SAL-2 | Critical Stage Progression Alert | Record-Triggered Flow (immediate) | High | **COMPLETE — Live in production 2026-04-25** | Flow active as v2 (`301TY00000rVQPaYAO`). Tooling API confirmed 2026-04-26. Linear Done. Merged to main. |

### 9.2 Shared production infrastructure — new standing note for SAL-9 and SAL-10

Add this note before the delivery table or at the start of Section 8:

> **Shared Orbit Infrastructure now in production (as at 2026-04-26):**
> Do NOT include these in future notification deployment manifests — they are already deployed.
>
> | Component | API Name | Type | Notes |
> |---|---|---|---|
> | `Salesforce_Base_URL` | `Salesforce_Base_URL` | Custom Label | Value: `https://astrum.my.salesforce.com`. Reference as `{!$Label.Salesforce_Base_URL}` in all Flow email record links. |
> | `Bypass_Flow` | `Bypass_Flow` | Custom Permission | Reference as `$Permission.Bypass_Flow` in all Flow bypass Decision elements. |
> | `Opportunity_ID_18__c` | `Opportunity_ID_18__c` | Formula Field (Opportunity) | `CASESAFEID(Id)`. Use for all email record link construction. |

### 9.3 NF6 correction (Section 14 of 2026-04-25 update)

**Current:** NF6 `Prior_Probability__c` listed as required for SAL-2.
**Proposed:** Mark NF6 as not required. `{!$Record__Prior.Opp_Probability__c}` is natively available. Remove from active build backlog.

### 9.4 SAL-9 and SAL-10 readiness notes

**SAL-9 (Closed Won):** Still blocked by BD5 (S&PS recipient matrix not provided). When unblocked, the shared infrastructure listed in 9.2 is ready. The production deployment sequence validated by SAL-2 applies directly.

**SAL-10 (Closed Lost):** Still blocked by BD-01 through BD-05 (Section 10 of the 2026-04-25 Memory Update). BD-08 (production-safe record link) is now resolved — `Salesforce_Base_URL` is in production.

---

## 10. Risks and Open Follow-Ups

| Ref | Item | Status | Action required |
|---|---|---|---|
| R-01 | `Salesforce_Base_URL` must be referenced by SAL-9 and SAL-10 from day one | Open | Include `{!$Label.Salesforce_Base_URL}` in all future notification Flow XML from the initial build — do not hardcode any org URL |
| R-02 | SAL-9 blocked on BD5 (S&PS recipient matrix) | Open | Commercial owner must provide recipient matrix for `Business_Category__c = S&PS` before SAL-9 or SAL-10 can be activated |
| R-03 | SAL-10 blocked on BD-01 through BD-05 | Open | See 2026-04-25 Memory Update Section 10 for full blocker list |
| R-04 | `Study_Countries__c` remains excluded from all notification payloads | Ongoing | Do not include `Study_Countries__c` in SAL-9, SAL-10, or any future notification until picklist is cleaned and stakeholder-approved |
| R-05 | `Opportunity_Code__c` blank on Dynamics-migrated records | Ongoing | SAL-2, SAL-9, and SAL-10 email bodies handle blank gracefully (row rendered as empty value). Data backfill remains outstanding before full notification value is realised. |
| R-06 | Production smoke test must be planned for every future notification before Linear closure | Process | Do not move any notification to Done in Linear until production smoke test is executed and confirmed via Setup → Email Log Files |
| R-07 | Version history in production: three Flow versions created for SAL-2 | Informational | v1 (initial deploy, Obsolete), v2 (fix, Active), v3 (Obsolete). Active = v2 `301TY00000rVQPaYAO`. If future fixes create new versions, always re-confirm active version via Tooling API. |
| R-08 | `emailSimple` delivery is not verifiable via SOQL | Ongoing | Email delivery must be confirmed via Setup → Email Log Files for every production smoke test. No SOQL-based email delivery verification is available for `emailSimple`. |
| R-09 | SAL-10 BD-08 (production-safe record link) is now resolved | Closed | `Salesforce_Base_URL` is in production. Remove BD-08 from SAL-10 blocker list. |
| R-10 | OQ-1 (creation trigger exclusion) remains open | Open | Business has not confirmed whether creating an Opportunity at 75% or 90% should trigger SAL-2. Default (exclude creation) is in production. Change requires `<recordTriggerType>CreateAndUpdate</recordTriggerType>` in Flow XML and explicit business sign-off. |

---

*SAL-2 Memory Update Proposal — Astrum Orbit Programme*
*Prepared 2026-04-26 from committed evidence files and read-only Tooling API verification.*
*Do not merge this proposal into the master Memory Pack without review and approval.*
*Source files: PRDS/SAL-2-critical-stage-progression-alert.md, handoff/SAL-2-delivery-handoff.md,*
*validation/SAL-2-production-*.md, LLM-TXTS/Astrum_Project_Memory_Pack_v1.md,*
*LLM-TXTS/Astrum_Orbit_Project_Memory_Update_2026-04-25.md, Tooling API query 2026-04-26.*
