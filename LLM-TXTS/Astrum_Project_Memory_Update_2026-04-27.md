# Astrum Orbit Project Memory Update
**Date:** 27 April 2026
**Scope:** Salesforce notification delivery, schema discoveries, dual-agent operating model
**Prepared by:** Claude Code — documentation mode only (no metadata created, edited, or deployed)
**Supplements:** `LLM-TXTS/Astrum_Project_Memory_Pack_v1.md` and `LLM-TXTS/Astrum_Orbit_Project_Memory_Update_2026-04-25.md`

> This file captures durable project knowledge from delivery work completed on 26–27 April 2026.
> It does not replace primary source documents. Where this file conflicts with a primary source, the primary source takes precedence.
> Evidence hierarchy applied: Memory Pack v1 → org schema files → SAL-specific PRDs and validation files → Linear issue content → Git history.

---

## 1. Executive Summary

### What changed on 26–27 April 2026

**SAL-9 (Closed Won Notification)** moved from sandbox-complete to **production active**. The Flow was deployed to `astrum-prod` on 27 Apr 2026, manually activated by the admin, and smoke-tested (PRE-07 PASS). Email delivery was confirmed to all 5 expected recipients on the Phase I Unit Low path by Amit Kumar from Salesforce email logs. Linear SAL-9 is now Done. This is the second production notification in the Orbit suite.

**SAL-10 (Closed Lost Review Notification)** advanced significantly beyond its 25 Apr 2026 state. The Flow `Notify_Closed_Lost_Review_After_Save` was built and deployed to sandbox `astrum--astrumpar` on 26 Apr 2026. Six of seven smoke test scenarios passed. One scenario (Bypass_Flow manual test) remains pending. Production activation remains blocked on BD-01 through BD-05. The 25 Apr 2026 memory update described SAL-10 as blocked for active build — this is now superseded: the sandbox build is complete.

**New schema fields discovered** during SAL-9 and SAL-10 builds that were not previously in project memory:
- `Loss_Reason_Date__c` (Date) — required by Closed Lost validation rule
- `Reason_for_win__c` (Picklist) — required by Closed Won validation rule
- `Protocol_Title__c` (Long Text Area) — required by Closed Won validation rule
- `Contract_Type__c` (Picklist) — required by Closed Won validation rule
- `Payment_Schedule_Type__c` (Picklist) — required by Closed Won validation rule
- `Contract_Entity__c` (Picklist) — required by Closed Won validation rule

**AGENTS.md, AI_WORKFLOW.md, and .codex** do not exist in this repository as at 27 Apr 2026.

### Which workstreams progressed

| Workstream | Movement 26–27 Apr 2026 |
|---|---|
| SAL-9 Closed Won Notification | Production active. All release gates closed. Linear Done. |
| SAL-10 Closed Lost Review | Sandbox built and 6/7 smoke tests passed. Bypass test pending. Production blocked on BD-01–BD-05. |
| SAL-2 Critical Stage Progression | No new work. Remains production active since 25 Apr 2026. Linear Done. |
| SAL-11 and all other notifications | No movement. Backlog. |
| Agentforce, Marketing Cloud, Data Cloud | No movement. |

### Current branch

Working branch: `chore/dual-agent-codex-setup`
Contains all SAL-9 production deployment commits (b867bb5 back to 90845f0). **Not yet merged to main.** Main is at `0026d44` (SAL-2 memory update proposal commit, 26 Apr 2026).

---

## 2. Salesforce Notification Delivery Status — Full Suite

**Shared production infrastructure (deployed 25 Apr 2026 — do not re-deploy in future manifests):**

| Component | API Name | Type | Production Value / ID |
|---|---|---|---|
| Bypass permission | `Bypass_Flow` | Custom Permission | `0CPTY00000010CT4AY` in prod |
| Record ID formula | `Opportunity_ID_18__c` | Formula Field (Opportunity) | `CASESAFEID(Id)` |
| Org URL label | `Salesforce_Base_URL` | Custom Label | `https://astrum.my.salesforce.com` (ID: `101TY00000rVYYOYA4`) |

All future notification Flows reference these components. Do not include them in deployment manifests.

| ID | Title | Status | Production state | Notes |
|---|---|---|---|---|
| SAL-1 | New Opportunity Created | Backlog | Not deployed | Manual Quick Action — not a blanket automatic email |
| **SAL-2** | **Critical Stage Progression Alert** | **COMPLETE** | **Production Active** | Flow v2 active (`301TY00000rVQPaYAO`). Linear Done 26 Apr 2026. |
| SAL-3 | Opportunity Stalled Alert | Backlog | Not deployed | Scheduled Flow — requires helper fields before build |
| SAL-4 | Opportunity Close Date Risk Alert | Backlog | Not deployed | Scheduled Flow — confirm stage values first |
| SAL-5 | Opportunity Amount Change Alert | Backlog | Not deployed | Requires `Opportunity_Change_Log__c` custom object |
| SAL-6 | Opportunity Close Date Change Alert | Backlog | Not deployed | Requires `Opportunity_Change_Log__c` and push-out counting rule (BD6) |
| SAL-7 | Probability / Forecast Category Change | Backlog | Not deployed | Requires `Opportunity_Change_Log__c` |
| SAL-8 | Missing Key Data Alert | Backlog | Not deployed | Blocked on BD1 (required field list) |
| **SAL-9** | **Closed Won Notification** | **COMPLETE** | **Production Active** | Flow ID `301TY00000rYVAxYAO`. Deploy `0AfTY000003kpyf0AA`. PRE-07 PASS 27 Apr 2026. Linear Done. |
| **SAL-10** | **Closed Lost Review Notification** | **In Progress — Blocked** | **Sandbox Active only** | Flow deployed to sandbox 26 Apr 2026. 6/7 smoke tests pass. Production blocked on BD-01–BD-05. Linear: In Progress with Blocked label. |
| SAL-11 | Large Opportunity Aged in Stage | Backlog | Not deployed | Scheduled Flow — needs time-in-stage tracking design |
| SAL-12 | No Recent Activity on Open Opportunity | Backlog | Not deployed | Confirm `LastActivityDate` reliability |
| SAL-13 | Project Code or Change Order Issue | Backlog | Not deployed | May need helper formula field |
| SAL-14 | Quote Closed Won Notification | Backlog | Not deployed | **Do not build.** Trigger and quote-selection rule undefined. |

---

## 3. Confirmed Project Rules Reinforced by Recent Work

These rules were validated in practice during SAL-2, SAL-9, and SAL-10 builds. All are supported by local evidence.

| Rule | Source / Reinforcement |
|---|---|
| PRD-first delivery is mandatory | SAL-9 and SAL-10 each had full PRDs written before any Flow XML was produced |
| Immediate notifications (SAL-2, SAL-9, SAL-10) are prioritised before digest/historical-change | Build order confirmed — all three now complete or in active build |
| Do not build SAL-5, SAL-6, SAL-7 without `Opportunity_Change_Log__c` and prior-value helper fields | No work started on these. Rule holds. |
| Do not include `Study_Countries__c` in notification email payloads until picklist data is cleaned | Enforced in both SAL-2 (commit `660e1b2`) and SAL-9 (confirmed excluded). Applies to SAL-10. |
| Use `Opp_Probability__c` as authoritative probability field. Do not use standard `Probability`. | SAL-2 trigger uses `Opp_Probability__c`. SAL-9 entry criterion uses `StageName` not probability. Memory Pack NEVER rule applied throughout. |
| Use `Opportunity_Code__c` as commercial deal identifier in all notification emails | Applied in SAL-2, SAL-9, SAL-10 email bodies |
| Use `Opportunity_ID_18__c` and `$Label.Salesforce_Base_URL` for Salesforce record links in email bodies | Applied in SAL-2, SAL-9, SAL-10. Custom Label deployed in production. Do not hardcode org URLs. |
| No hard-coded sandbox URLs in production-bound email templates or Flows | BD-08 resolved by deploying `Salesforce_Base_URL` Custom Label. SAL-10 also uses label pattern. |
| Every notification must prevent duplicate sends for the same qualifying event | SAL-2 uses `IsChanged` on `Opp_Probability__c`. SAL-9 uses `IsChanged` on `StageName`. SAL-10 uses `$Record__Prior.StageName ≠ 'Closed Lost'`. No sent-flag helper field required for MVP immediate notifications. |
| Production deployment requires explicit human approval and post-deployment smoke test evidence | SAL-2: PRE approval, smoke test PASS 25 Apr 2026. SAL-9: PRE-05/PRE-06/PRE-07 all confirmed. Pattern mandatory for SAL-10 and all future notifications. |
| Memory Pack NEVER guardrails take precedence over Linear issue requirements when they conflict | SAL-2 precedent: `Study_Countries__c` removed from payload despite appearing in original Linear issue. Applied to SAL-9 payload review. |
| `{!$Record__Prior.FieldName}` is natively available in after-save record-triggered Flows — no helper field required | Confirmed in SAL-2 (Opp_Probability__c prior value). Confirmed in SAL-9 and SAL-10 (StageName prior value via `$Record__Prior.StageName`). **NF6 (`Prior_Probability__c`) is not needed and should be removed from the net-new field list.** |
| `emailSimple` does not count under `Number of Email Invocations` governor limit | Confirmed in SAL-2 production smoke test. Delivery must be verified via Setup → Email Log Files. No SOQL-based verification is available. |
| Fault path on every Send Email element must capture `$Flow.FaultMessage` and not rethrow | Confirmed in SAL-2, SAL-9, SAL-10 Flow designs. Failed email send must not roll back Opportunity DML. |

---

## 4. SAL-2 Memory — Critical Stage Progression Alert

### Confirmed durable facts

| Fact | Value | Evidence |
|---|---|---|
| Linear status | Done (completedAt: 2026-04-26T05:43:05Z) | Linear MCP — confirmed 27 Apr 2026 |
| Flow API Name | `Notify_Critical_Stage_Progression_After_Save` | Committed Flow XML |
| FlowDefinition ID (production) | `300TY00000zHjLtYAK` | Tooling API query 26 Apr 2026 |
| Active version (production) | v2 — `301TY00000rVQPaYAO` | Tooling API query |
| Production deployment timestamp | 2026-04-25T20:10:47Z | `validation/SAL-2-production-deploy-output.md` |
| Smoke test result | PASS — 2026-04-25T21:18:22Z | `validation/SAL-2-production-smoke-check.md` |
| Smoke test record | Opp ADP1005 (Ketamine BE study, Adragos Pharma) — ID `006TY00000qpSxEYAU` | Smoke check file |
| Git merge to main | Commit `9f9c1f8` | Git log |
| Branch | `feature/SAL-2-critical-stage-progression-alert` | Git log |
| Trigger field | `Opp_Probability__c` (custom picklist) — values 75 and 90 | PRD, Flow XML |
| Trigger condition | `(Opp_Probability__c = 75 OR = 90) AND IsChanged = true` — Update only | PRD |
| Run mode | DefaultMode (User context) | Flow XML |
| Bypass check | `Check_Bypass_Permission` Decision element — first element in Flow | Flow XML |
| Custom Label | `Salesforce_Base_URL` = `https://astrum.my.salesforce.com` — referenced via `{!$Label.Salesforce_Base_URL}` | CustomLabels.labels-meta.xml |
| `Study_Countries__c` in payload | **NOT included** — removed pre-production (v1.1, commit `660e1b2`) | PRD v1.1, deploy output |
| Five fixed recipients | rfp.rfi@astrumcro.com, jordi.picas@astrumcro.com, cristina.lopes@astrumcro.com, anthony.gibson@astrumcro.com, vania.araujo@astrumcro.com | PRD, Linear SAL-2 |
| Email delivery confirmed via | Setup → Email Log Files | Smoke check |

### Key design decisions from SAL-2 applied to all subsequent notifications

- Use `manifest/package-sal-N-production.xml` scoped per notification — do not include shared infrastructure
- Always confirm active version via `FlowDefinition` Tooling API after deployment — do not rely on deploy output alone
- `emailSimple` delivery is NOT verifiable via SOQL — use Email Log Files
- SAL-2 production validation ran `--test-level RunLocalTests` — 10 standard Salesforce test classes; no SAL-2 Apex was deployed
- Quick Deploy Job ID (`0AfTY000003kZfN0AU`) ≠ Validation Job ID (`0AfTY000003kZaX0AU`) — document both

### Documentation files

| File | Purpose |
|---|---|
| `PRDS/SAL-2-critical-stage-progression-alert.md` (v1.1) | Full PRD — deployment status updated to LIVE IN PRODUCTION |
| `force-app/main/default/flows/Notify_Critical_Stage_Progression_After_Save.flow-meta.xml` | Deployed Flow XML |
| `validation/SAL-2-production-smoke-check.md` | Smoke test PASS evidence |
| `validation/SAL-2-production-deploy-output.md` | Deploy evidence including Tooling API version history |
| `handoff/SAL-2-delivery-handoff.md` | Full delivery handoff |
| `LLM-TXTS/SAL-2-memory-update-proposal.md` | Proposed updates to Memory Pack (approved but not yet merged) |

---

## 5. SAL-9 Memory — Opportunity Closed Won Notification

### Purpose

Send an immediate email when an Opportunity's `StageName` first transitions to `Closed Won` on an update. Route recipients by `Business_Category__c` and `Service_Fees__c` threshold. Always include the Opportunity Owner as a dynamic recipient.

### Production deployment evidence

| Fact | Value | Evidence |
|---|---|---|
| Linear status | **Done** (completedAt: 2026-04-27T08:25:42Z) | Linear MCP — confirmed 27 Apr 2026 |
| Flow API Name | `Notify_Closed_Won_After_Save` | Committed Flow XML |
| Production Flow ID | `301TY00000rYVAxYAO` | `handoff/SAL-9-delivery-handoff.md` |
| Production Deploy ID | `0AfTY000003kpyf0AA` | Handoff file |
| Production deployment date | 27 Apr 2026 — deployed as Draft, manually activated by admin | Handoff file, commit `25c9af5` |
| PRE-07 smoke test | **PASS** — Phase I Unit Low path | Commit `b867bb5`, PRD, Handoff |
| Smoke test record | Opp `006TY00000vLQOTYA4` — deleted after test | PRD, Linear SAL-9 |
| Email delivery confirmed | Yes — Amit Kumar from Salesforce production email logs | Linear SAL-9, Handoff |
| Branch | `vptechnology/sal-9-orbit-notification-opportunity-closed-won-notification` | Git log |
| Working branch at 27 Apr 2026 | `chore/dual-agent-codex-setup` — contains all SAL-9 prod commits — **not yet merged to main** | Git log |

### Trigger criteria

| Property | Value |
|---|---|
| Object | Opportunity |
| Trigger timing | After Save, Update only (creation excluded) |
| Condition 1 | `StageName` EqualTo `Closed Won` |
| Condition 2 | `StageName` IsChanged `true` |
| Run mode | DefaultMode (User context) |

### Confirmed recipient routing matrix

| Business Category | Service Fees | Static recipients | Dynamic |
|---|---|---|---|
| Phase I Unit | < EUR 150,000 | tom.frearson, Catherine.Canales, Ricardo.Cunha, rfp.rfi | Opportunity Owner |
| Phase I Unit | ≥ EUR 150,000 | tom.frearson, Catherine.Canales, cristina.lopes, Ricardo.Cunha, rfp.rfi | Opportunity Owner |
| Phase I-NIS | < EUR 500,000 | tom.frearson, Catherine.Canales, rfp.rfi | Opportunity Owner |
| Phase I-NIS | ≥ EUR 500,000 | tom.frearson, Catherine.Canales, cristina.lopes, jordi.picas, anthony.gibson, rfp.rfi | Opportunity Owner |
| All other categories | Any | **No email — silent exit** | — |

"All other categories" includes S&PS, All Other Projects (Phase I-NIS), Phase I Clinical Conduct Portugal, and Site & Patient Services (CRP & MissionTEC). Explicitly confirmed out of scope for SAL-9 (RG-2, 26 Apr 2026).

### Confirmed excluded fields

| Field | Reason |
|---|---|
| `Study_Countries__c` | Data-quality guardrail per SAL-2 precedent. Present and always populated (validation rule), but excluded from email body. |
| Standard `Probability` | Programme-prohibited — `Opp_Probability__c` only |
| `Probability__c` (formula) | Display-only, not suitable for notifications |
| Phase field | API name not confirmed in org schema |

### Key design decisions confirmed during SAL-9

- A-05 (re-trigger): If StageName moves Closed Won → other stage → Closed Won again, a second email fires. **Confirmed acceptable for MVP** (RG-1, 26 Apr 2026). One-lifetime guard (`Closed_Won_Notification_Sent__c`) deferred to Release 1.1.
- Bypass automated test: `SAL9_BypassFlow_Test.cls` (commit `90845f0`). BYP-01 and BYP-02 PASS. Test run ID `707UD00000pLfAm`.
- All 4 sandbox routing paths smoke-tested (SM-A through SM-D) — emailSimple faulted in sandbox due to unverified domain. Fault connector handled correctly.

### New Closed Won validation rule discovered (STAGE_Closed_Won — ID 03dUD000000TMbRYAW)

This validation rule enforces non-blank values on the following fields before any Opportunity can be saved to Closed Won. These fields will always be populated on real Closed Won records:

`Description` · `Reason_for_win__c` · `Indication__c` · `Number_of_Enrolled_Participants__c` · `Study_Countries__c` · `Number_of_Sites__c` · `Entities_Providing_Services__c` · `Protocol_Title__c` · `Contract_Sign_Date__c` · `Contract_Type__c` · `Payment_Schedule_Type__c` · `Contract_Entity__c`

**New fields discovered (not previously in schema memory):**

| Label | API Name | Data Type | Notes |
|---|---|---|---|
| Reason for win | `Reason_for_win__c` | Picklist | Active values: Astrum Capabilities, Change Order, Client Relationship, Cost, Geographical Coverage, Project Team Experience, Therapeutic Experience |
| Protocol Title | `Protocol_Title__c` | Long Text Area(32768) | — |
| Contract Type | `Contract_Type__c` | Picklist | Active values: Change Order, Clinical Services Agreement, Invoice Only, Letter of Agreement, Out of Scope, Proposal Acceptance Form, Start Work Authorisation, Statement of Work/Work Order |
| Payment Schedule Type | `Payment_Schedule_Type__c` | Picklist | Active values: Fixed Fee, FTE Based, Milestone Based, Time and Material, Unit-Based |
| Contract Entity | `Contract_Entity__c` | Picklist | Active values: Astrum CRO SL, Astrum CRO France, Astrum CRO Germany, Astrum CRO Spain, BlueClinical, MissionTEC |

These fields are **not in the SAL-9 email payload** — they are Closed Won administrative fields. Future post-award notifications should validate whether they are relevant.

### Documentation files

| File | Purpose |
|---|---|
| `PRDS/SAL-9-closed-won-notification.md` | Full PRD — status updated to COMPLETE / Production Active |
| `force-app/main/default/flows/Notify_Closed_Won_After_Save.flow-meta.xml` | Deployed Flow XML |
| `handoff/SAL-9-delivery-handoff.md` | Full delivery handoff including all release gate evidence |
| `scripts/apex/smoke_sal9_bc.apex` | Smoke test scripts (scenarios B and C) |
| `force-app/main/default/classes/SAL9_BypassFlow_Test.cls` | Automated bypass gate tests (BYP-01, BYP-02) |

### Next operator for SAL-9

**Human** — Close the Linear issue (SAL-9 status is Done but should be formally reviewed). Merge `chore/dual-agent-codex-setup` to `main` after review.

---

## 6. SAL-10 Memory — Opportunity Closed Lost Review Notification

### Purpose

Send an immediate review email when an Opportunity's `StageName` first transitions to `Closed Lost`. Routes recipients by `Business_Category__c` and `Service_Fees__c` threshold. Always includes Opportunity Owner.

### Current status (27 Apr 2026)

**SANDBOX BUILD COMPLETE. SIX OF SEVEN SMOKE TESTS PASS. PRODUCTION ACTIVATION BLOCKED.**

This supersedes the 25 Apr 2026 memory update, which described SAL-10 as "blocked for active build." The Flow has been built and deployed to sandbox.

| Fact | Value | Evidence |
|---|---|---|
| Linear status | In Progress (Blocked label) | Linear MCP — confirmed 27 Apr 2026 |
| Flow API Name | `Notify_Closed_Lost_Review_After_Save` | Linear SAL-10, Flow XML |
| Sandbox Deploy ID | `0AfUD00000Go6KL0AZ` | Linear SAL-10 |
| Sandbox deployment date | 26 Apr 2026 | Linear SAL-10 |
| Sandbox status | Active | Linear SAL-10 |
| Smoke tests passed | 6 of 7 (Scenarios A–F) | Linear SAL-10 |
| Remaining smoke test | Scenario G — Bypass_Flow manual test — **PENDING** | Linear SAL-10 |
| Production org | **Not touched** | All sources |
| Branch | `vptechnology/sal-10-orbit-notification-opportunity-closed-lost-review` | Git |

### Trigger criteria (confirmed in sandbox build)

| Property | Value |
|---|---|
| Object | Opportunity |
| Trigger timing | After Save |
| Trigger event | A record is updated |
| Condition 1 | `StageName` Equals `Closed Lost` |
| Condition 2 | `{!$Record__Prior.StageName}` Does Not Equal `Closed Lost` |
| Run mode | User context (not System or System Without Sharing) |

### Confirmed recipient routing matrix (provided — pending stakeholder formal confirmation)

| Business Category | Service Fees | Static recipients (6 per path, all normalised) | Dynamic |
|---|---|---|---|
| Phase I Unit | < EUR 150,000 | tom.frearson, Catherine.Canales, Ricardo.Cunha, rfp.rfi, cristina.lopes, anthony.gibson | Opportunity Owner |
| Phase I Unit | ≥ EUR 150,000 | tom.frearson, Catherine.Canales, cristina.lopes, Ricardo.Cunha, rfp.rfi, anthony.gibson | Opportunity Owner |
| Phase I-NIS | < EUR 500,000 | tom.frearson, Catherine.Canales, rfp.rfi, jordi.picas, cristina.lopes, anthony.gibson | Opportunity Owner |
| Phase I-NIS | ≥ EUR 500,000 | tom.frearson, Catherine.Canales, cristina.lopes, jordi.picas, anthony.gibson, rfp.rfi | Opportunity Owner |
| S&PS | Any | Not provided | — |
| All Other Projects (Phase I - NIS) | Any | Not provided | — |
| Phase I Clinical Conduct Portugal | Any | Not provided | — |
| Site & Patient Services (CRP & MissionTEC) | Any | Not provided | — |
| Blank / unrecognised | Any | Not provided — current design: silent exit | — |

**⚠️ Identical-recipient flag (BD-04):** After normalisation, both Phase I Unit routing rules contain the same 6 static recipients (different ordering only). Same is true for both Phase I-NIS rules. Stakeholder must confirm whether this is intentional or a data entry error before production activation.

### Currency

Org default currency: **EUR / Euros** (confirmed 25 Apr 2026). All `Service_Fees__c` threshold comparisons are numeric (150000, 500000). No currency conversion required. If multi-currency is enabled in future, SAL-10 thresholds must be revalidated.

### New schema discoveries from SAL-10 sandbox build

**New field discovered (not previously in schema memory):**

| Label | API Name | Type | Notes |
|---|---|---|---|
| Loss Reason Date | `Loss_Reason_Date__c` | Date | Required by validation rule `STAGE_Closed_Lost`. Always populated on real Closed Lost records. |

**Validation rule STAGE_Closed_Lost** requires all of the following to be non-blank before any Opportunity can be saved to `Closed Lost`:
- `Loss_Reason__c`
- `Loss_Reason_Date__c`
- `Description` (standard field)

Implication: On real Closed Lost records in production, `Loss_Reason__c`, `Loss_Reason_Date__c`, and `Description` will always be populated. Blank-handling rules for these fields in the email template are relevant for test scenarios only.

**`Lost/Cancelled/Declined to Bid` stage confirmed active:** Org has 19 active `StageName` values (confirmed via OpportunityStage SOQL query 26 Apr 2026). `Lost/Cancelled/Declined to Bid` is the full exact picklist value. Smoke test Scenario F confirmed: SAL-10 Flow does **not** fire for this stage. BD-01 (trigger scope decision) remains a production activation blocker.

### BD-08 resolved — record link production-safe

BD-08 (production-safe record link) is resolved. SAL-10 uses `{!$Label.Salesforce_Base_URL}/{!Get_Opportunity_Detail.Opportunity_ID_18__c}`. The `Salesforce_Base_URL` Custom Label is deployed in production. This blocker is closed.

### SAL-10 remaining production activation blockers

| ID | Blocker | Severity | Owner |
|---|---|---|---|
| BD-01 | Does `Lost/Cancelled/Declined to Bid` also trigger SAL-10? Smoke test F confirmed it does NOT currently trigger. | Critical | Commercial / Sales Ops |
| BD-02 | Confirm which of the 6 active `Business_Category__c` values are in scope | Critical | Commercial |
| BD-03 | Provide recipient matrix for S&PS and other undocumented Business Category values, or confirm explicit exclusion | Critical | Commercial |
| BD-04 | Confirm identical-recipient flag for Phase I Unit Low/High and Phase I-NIS Low/High. Confirm or correct. | High | Commercial |
| BD-05 | Fallback routing for blank / unrecognised `Business_Category__c` or `Service_Fees__c` | High | Commercial |
| BYP-G | Bypass_Flow manual test (Scenario G) — pending | High | Salesforce Admin |

**BD-06** (Loss Reason blank handling), **BD-07** (Description field in email body), and **BD-08** (record link) are non-blocking or resolved.

**Recommendation: Do not start any additional Flow build or production activation until BD-01 through BD-05 are resolved in writing. Current sandbox build is complete and waiting.**

### Documentation files

| File | Purpose |
|---|---|
| `PRDS/SAL-10-closed-lost-review-notification.md` | Full PRD v1.0 — note: build status section says "BLOCKED FOR ACTIVE BUILD" — this is now superseded by Linear evidence of sandbox deployment on 26 Apr 2026 |
| `handoff/SAL-10-business-decisions-required.md` | Stakeholder-facing decision document with 5 plain-English questions |

**Note for next session:** The SAL-10 PRD file on disk (`PRDS/SAL-10-closed-lost-review-notification.md`) still shows "BLOCKED FOR ACTIVE BUILD / ACTIVATION" in the build status section. The authoritative current state is in Linear SAL-10 which confirms sandbox deployment. The PRD should be updated to reflect the completed sandbox build when next touched.

---

## 7. Dual-Agent Delivery Model Memory

The repository branch name `chore/dual-agent-codex-setup` indicates this project has been set up for a dual-agent operating model. No `AGENTS.md`, `AI_WORKFLOW.md`, or `.codex/` directory exists in the repo as at 27 Apr 2026. The operating model is inferred from commit messages, PRD structure, and handoff document conventions.

### Current operating model (inferred from local evidence)

| Agent | Role |
|---|---|
| **Claude Code** | Architect, PRD author, reviewer, Linear commenter, documentation updater, memory curator |
| **Codex** | Implementation, tests, minimal diffs, validation command execution |
| **Human** | Approval authority, production deployment decision, release gate sign-off, Linear Done confirmation |

### Rules inferred from delivery pattern

- Only one AI agent edits metadata at a time
- Every handoff document and PRD ends with a "Next Operator" designation (Claude, Codex, or Human)
- Codex should not implement without a Claude-reviewed plan (PRD)
- Claude should not perform uncontrolled metadata edits or production deployments
- Linear updates are deliberate and evidence-based — not automatic
- Production deployment requires an explicit written instruction from Human (programme lead) — never from Claude Code unilaterally
- Human reviews Flow XML diff before any production deployment is permitted

### What to create if AGENTS.md is needed

If `AGENTS.md` is created in future, it should capture:
- Agent roles and responsibilities (as above)
- Which folders each agent operates in
- Handoff convention: "Next Operator: Claude / Codex / Human" at end of every PRD/handoff
- Instruction that Linear must not be updated without explicit human approval
- Instruction that production deployment commands must not be run without written approval in the session

---

## 8. Repository and Workflow Memory

### Repository conventions

| Convention | Detail |
|---|---|
| Metadata root | `force-app/main/default/` |
| PRDs | `PRDS/SAL-N-<name>.md` — one per notification |
| Validation evidence | `validation/SAL-N-*.md` — sandbox deploy, UAT, production deploy, smoke check |
| Handoff documents | `handoff/SAL-N-delivery-handoff.md` |
| LLM context files | `LLM-TXTS/` — Markdown only. Word/PDF files are not active Claude context. |
| Production manifests | `manifest/package-sal-N-production.xml` — scoped per notification, shared infrastructure excluded |
| Scripts | `scripts/apex/` for anonymous Apex smoke test scripts |
| Test classes | `force-app/main/default/classes/` — Apex test classes committed alongside the notification |
| Git branches | Feature branches per notification |
| Commit style | `feat(SAL-N)`, `docs(SAL-N)`, `fix(SAL-N)`, `test(SAL-N)`, `chore(SAL-N)` |

### Files that do not exist (27 Apr 2026)

`AGENTS.md` · `AI_WORKFLOW.md` · `.codex/` directory

### Production org details

| Property | Value |
|---|---|
| Production org URL | `https://astrum.my.salesforce.com` |
| Production org alias | `astrum-prod` |
| Production org ID | `00Dd100000AMk1dEAD` |
| Sandbox org URL | `astrum--astrumpar.sandbox.my.salesforce.com` |
| Sandbox org alias | `amit.kumar@astrumcro.com.astrumpar` |
| API version | 66.0 |
| Org default currency | EUR / Euros |

### End-to-end production delivery sequence (validated by SAL-2 and SAL-9)

```
1.  PRD written to PRDS/
2.  Schema validation via SOQL / Tooling API against sandbox
3.  Flow XML written and committed to feature branch
4.  Sandbox deploy (inactive), UAT test suite executed, all cases pass
5.  Flow activated in sandbox
6.  Production validation (check-only): sf project deploy start --dry-run --manifest manifest/package-sal-N-production.xml
7.  Explicit written approval from programme lead / business owner
8.  Quick deploy to production: sf project deploy quick --job-id <validationJobId>
9.  Confirm active version via FlowDefinition Tooling API query
10. Production smoke test — email delivery via Setup → Email Log Files
11. Documentation commit (validation, handoff, PRD status update)
12. Linear issue update and status → Done
13. Merge to main
```

---

## 9. Open Decisions and Blockers

| Decision / Blocker | Affected Issue | Status | Owner | Impact | Recommended Next Action |
|---|---|---|---|---|---|
| BD-01: Does `Lost/Cancelled/Declined to Bid` stage trigger SAL-10? | SAL-10 | Open | Commercial / Sales Ops | Critical — Flow entry criterion cannot be finalised | Raise with Commercial. Options: include, exclude, or retire the stage |
| BD-02: Which of 6 active `Business_Category__c` values are in SAL-10 scope? | SAL-10 | Open | Commercial | Critical — stub branches for 4 undocumented values | Raise with Commercial alongside BD-03 |
| BD-03: Recipient matrix for S&PS and other undocumented Business Category values | SAL-9, SAL-10 | Open | Commercial | Critical — blocks production activation | Confirm or explicitly exclude each value |
| BD-04: Identical-recipient flag — Phase I Unit Low/High and Phase I-NIS Low/High produce same recipient lists | SAL-10 | Open | Commercial | High — need to confirm intentional or data entry error | Stakeholder to confirm Option A, B, or C (see SAL-10 PRD Section 5a) |
| BD-05: Fallback routing for blank / unrecognised `Business_Category__c` | SAL-10 | Open | Commercial | High — current design exits silently | Confirm silent skip or provide fallback address |
| BYP-G: Bypass_Flow manual test (Scenario G) for SAL-10 | SAL-10 | Pending | Salesforce Admin | High — required before production activation | Manual test: assign Bypass_Flow, update to Closed Lost, confirm 0 emails |
| NF6 `Prior_Probability__c` listed as net-new required | Memory Pack, Memory Update 2026-04-25 | Confirmed not needed | — | Low — creates confusion in future sessions | Remove from net-new field list. `{!$Record__Prior.Opp_Probability__c}` is native. |
| `chore/dual-agent-codex-setup` branch not merged to main | SAL-9, SAL-10 | Open | Human | Medium — main is 7 commits behind working branch | Human to review and approve merge after final documentation commit |
| SAL-10 PRD build status section is stale (still says "BLOCKED FOR ACTIVE BUILD") | SAL-10 | Open | Claude Code | Low — creates confusion in future sessions | Update PRD status section when next instructed to touch SAL-10 |
| BD5 (programme-wide): S&PS recipient matrix for SAL-9 and SAL-10 | SAL-9 (out of scope confirmed), SAL-10 (still blocking) | Partially resolved | Commercial | SAL-9 resolved (S&PS excluded). SAL-10 still requires decision. | Confirm S&PS is also out of scope for SAL-10, or provide recipient matrix |
| BD1: Required field list for Notification 8 and Agentforce Subagent 3 | SAL-8, Agentforce S3 | Open | BD Lead | Critical for both workstreams | BD Lead must sign off field list in writing before build can begin |
| BD8: Agentforce licensing status | Agentforce | Open | IT / Commercial | Critical — cannot start Agent Builder without licence | Confirm provision or procurement timeline |
| `Opportunity_Code__c` blank on Dynamics-migrated records | All 14 notifications | Ongoing | Data / Admin | Email bodies show blank Opportunity Code on migrated records | Data backfill required before full notification value is realised |

---

## 10. Memory Candidates for Permanent Project Instructions

### Must add

| Memory text | Source evidence | Confidence | Target file |
|---|---|---|---|
| SAL-2 is COMPLETE — production active since 25 Apr 2026 (Linear Done, smoke test PASS). Flow `Notify_Critical_Stage_Progression_After_Save` v2 (`301TY00000rVQPaYAO`) active in `astrum-prod`. | `validation/SAL-2-production-smoke-check.md`, Linear SAL-2, Git `9f9c1f8` | High | Astrum_Project_Memory_Pack_v1.md Section 2 |
| SAL-9 is COMPLETE — production active since 27 Apr 2026 (Linear Done, PRE-07 PASS). Flow `Notify_Closed_Won_After_Save` (`301TY00000rYVAxYAO`) active in `astrum-prod`. | `handoff/SAL-9-delivery-handoff.md`, Linear SAL-9, commit `b867bb5` | High | Astrum_Project_Memory_Pack_v1.md Section 2 |
| `{!$Record__Prior.FieldName}` is natively available in after-save record-triggered Flows. No helper field, before-save Flow, or SOQL required for prior-value access. NF6 (`Prior_Probability__c`) is not required. | SAL-2 UAT evidence, SAL-2 memory update proposal Section 3.1 | High | Astrum_Project_Memory_Pack_v1.md Section 11 (retire NF6) |
| `Salesforce_Base_URL` Custom Label (value: `https://astrum.my.salesforce.com`, ID: `101TY00000rVYYOYA4`) is deployed in production. Always reference via `{!$Label.Salesforce_Base_URL}`. Do not re-deploy in future notification manifests. | `validation/SAL-2-production-deploy-output.md`, `validation/SAL-9-delivery-handoff.md` | High | Astrum_Project_Memory_Pack_v1.md Section 10 |
| `emailSimple` Flow action routes via org email relay and does NOT count under `Number of Email Invocations` governor limit. Delivery can only be verified via Setup → Email Log Files. No SOQL-based verification is available. | `validation/SAL-2-production-smoke-check.md` Section Execution Results | High | Astrum_Project_Memory_Pack_v1.md Section 10 |
| `Loss_Reason_Date__c` (Date) is a required field on Closed Lost Opportunities. Enforced by validation rule `STAGE_Closed_Lost` alongside `Loss_Reason__c` and `Description`. Always populated on real Closed Lost records. | Linear SAL-10 sandbox build discoveries | High | Astrum_Project_Memory_Pack_v1.md Section 4 / Schema section |
| Five new Opportunity fields confirmed via Closed Won validation rule (`STAGE_Closed_Won`): `Reason_for_win__c`, `Protocol_Title__c`, `Contract_Type__c`, `Payment_Schedule_Type__c`, `Contract_Entity__c`. All required on Closed Won saves. | `PRDS/SAL-9-closed-won-notification.md` Section 3.5, `handoff/SAL-9-delivery-handoff.md` Section 12 | High | Astrum_Project_Memory_Pack_v1.md Section 4 |
| The org has **19 active `StageName` values** including `Lost/Cancelled/Declined to Bid` (not in Memory Pack canonical list of 13). This stage does not currently trigger SAL-10. BD-01 required. | Linear SAL-10 (OpportunityStage SOQL 26 Apr 2026) | High | Astrum_Project_Memory_Pack_v1.md Section 4 / canonical picklist values |

### Should add

| Memory text | Source evidence | Confidence | Target file |
|---|---|---|---|
| SAL-10 sandbox build complete (26 Apr 2026). Flow `Notify_Closed_Lost_Review_After_Save` active in `astrum--astrumpar`. 6/7 smoke tests pass. Bypass manual test pending. Production blocked on BD-01–BD-05. | Linear SAL-10, commit evidence on `chore/dual-agent-codex-setup` | High | Astrum_Project_Memory_Pack_v1.md Section 2 |
| `STAGE_Closed_Won` validation rule (`03dUD000000TMbRYAW`) enforces 12 fields non-blank on Closed Won saves. All Closed Won Opportunity email payload fields will be populated in production. | `PRDS/SAL-9-closed-won-notification.md` Section 3.5 | High | Astrum_Project_Memory_Pack_v1.md — Note under Section 10 |
| Production deployment sequence for immediate record-triggered notifications is validated end-to-end by SAL-2 and SAL-9. Follow the 13-step sequence in `LLM-TXTS/SAL-2-memory-update-proposal.md` Section 4. | SAL-2 and SAL-9 delivery evidence | High | AGENTS.md (if created) or AI_WORKFLOW.md (if created) |
| A-05 (SAL-9 re-trigger): If StageName moves Closed Won → other → Closed Won again, a second SAL-9 email fires. Confirmed acceptable for MVP. One-lifetime guard deferred to Release 1.1. | Linear SAL-9 (RG-1), `PRDS/SAL-9-closed-won-notification.md` | High | Astrum_Project_Memory_Pack_v1.md — Notification 9 notes |
| For production Flow XML: do not include double hyphens (`--`) inside XML comments — illegal XML. Do not place `<recordTriggerType>` outside the `<start>` block. | `LLM-TXTS/SAL-2-memory-update-proposal.md` Section 6.8 | High | AGENTS.md (if created) / Claude Code build guidance |

### Do not add yet — unconfirmed

| Candidate memory | Why not added | What would confirm it |
|---|---|---|
| Phase I Unit and Phase I-NIS recipient lists for SAL-10 (identical after normalisation) | Not formally confirmed by stakeholder. Awaiting BD-04 resolution. | Written confirmation from Commercial on whether threshold distinction is intentional |
| Whether `Lost/Cancelled/Declined to Bid` triggers SAL-10 | BD-01 open. Current flow does NOT fire for this stage. | Written confirmation from Commercial / Sales Ops |
| Full recipient matrix for SAL-10 S&PS and other undocumented Business Category values | Not provided. BD-03 open. | Stakeholder provides matrices or confirms exclusion |
| Number of active org stages (19) as a permanent canonical list | Value is live org data subject to change. Use SOQL to verify at build time. | Query org at build time: `SELECT MasterLabel FROM OpportunityStage WHERE IsActive=true` |

---

## 11. Source Evidence Used

| Source | Role in this update |
|---|---|
| `LLM-TXTS/Astrum_Project_Memory_Pack_v1.md` | Programme authority — guardrails, canonical values, open decisions |
| `LLM-TXTS/Astrum_Orbit_Project_Memory_Update_2026-04-25.md` | Prior memory update — baseline for what was known at 25 Apr 2026 |
| `LLM-TXTS/SAL-2-memory-update-proposal.md` | SAL-2 design decisions, production delivery pattern, NF6 correction |
| `PRDS/SAL-9-closed-won-notification.md` | SAL-9 full PRD — deployment status, trigger criteria, recipient matrix, new schema discoveries |
| `PRDS/SAL-10-closed-lost-review-notification.md` | SAL-10 full PRD — trigger criteria, recipient matrix, blockers |
| `handoff/SAL-9-delivery-handoff.md` | SAL-9 delivery handoff — production deployment evidence, smoke test, recipients |
| `validation/SAL-2-production-smoke-check.md` | SAL-2 smoke test PASS evidence |
| `validation/SAL-2-production-deploy-output.md` | SAL-2 production deploy IDs, Flow version history |
| Git log (`git log --oneline -30`, `git log --oneline --all --decorate`) | Commit history, branch names, merge state |
| Linear MCP — SAL-2 | Current status: Done (completedAt 2026-04-26T05:43:05Z). Note: Linear description body still shows stale "Awaiting production deployment" text — body not updated. |
| Linear MCP — SAL-9 | Current status: Done (completedAt 2026-04-27T08:25:42Z). Production completion comment present. |
| Linear MCP — SAL-10 | Current status: In Progress, Blocked label. Sandbox build evidence present including Deploy ID `0AfUD00000Go6KL0AZ`, 6/7 smoke test results, new schema discoveries, and updated blocker table. |
| Linear MCP — SAL-11 | Current status: Backlog. No new work. |

---

## 12. Items Deliberately Not Added

| Item | Reason not added |
|---|---|
| Confirmed exact recipient email addresses for SAL-9 and SAL-10 as permanent memory | Email addresses are operational data and change over time. They are correctly captured in the PRDs. Permanent memory would become stale. |
| SAL-10 Flow XML details (element names, decision paths) | These are derivable from the committed Flow XML. Redundant in memory. |
| Org-active stage list as a 19-item canonical reference | Live org data that must be queried at build time. Not stable enough for permanent memory. |
| AGENTS.md and AI_WORKFLOW.md content | These files do not exist in the repository. Cannot capture their content. Flagged as a recommendation if the dual-agent model is to be formalised. |
| .codex/ directory content | Directory does not exist. Cannot capture. |
| Detailed deployment CLI commands | These are correctly captured in PRDs and handoff files. Duplication in memory adds maintenance burden. |
| SAL-2 Linear description body stale content | The SAL-2 Linear description body still says "Not deployed — awaiting approval." This is stale but harmless — the `completedAt` and `status: Done` fields are authoritative. Not a memory update; flagged for awareness only. |

---

## Next Operator

- **Run next in:** Human
- **Reason:** Review and approve this memory update before it is committed or merged into permanent project instructions.
- **Next prompt:** "Review the memory update and prepare a clean commit plan. Do not commit until I approve."

### Specific items requiring human decision before next Claude/Codex session

1. **Approve or reject** the recommended permanent memory updates in Section 10 for merging into `LLM-TXTS/Astrum_Project_Memory_Pack_v1.md`.
2. **Decide** whether to create `AGENTS.md` and/or `AI_WORKFLOW.md` to formalise the dual-agent operating model.
3. **Instruct** when to merge `chore/dual-agent-codex-setup` to `main`.
4. **Escalate** BD-01 through BD-05 to Commercial / Sales Ops to unblock SAL-10 production activation.
5. **Assign** the Bypass_Flow manual test (Scenario G) to the Salesforce Admin to complete SAL-10 sandbox sign-off.

---

## 13. Build Best Practices — Confirmed by SAL-2, SAL-9, SAL-10 Delivery

These practices are project-specific and confirmed by evidence in this repo. They supplement the 13-step production delivery sequence in Section 8 and the guardrails in Section 3. Items already captured in `LLM-TXTS/SAL-2-memory-update-proposal.md` are not repeated here.

---

### A. Solution Design

**A1 — ALWAYS use Get Records to retrieve cross-object fields**

In after-save record-triggered Flows, `$Record.Account.Name` and `$Record.Owner.Email` are not reliably available on the trigger record. Always retrieve them via a Get Records element (filter: `Id = {!$Record.Id}`, retrieve all fields). Applied in SAL-2, SAL-9, and SAL-10 as the `Get_Opportunity_Detail` element.

> Evidence: `PRDS/SAL-9-closed-won-notification.md` §8 Get_Opportunity_Detail spec; `PRDS/SAL-10-closed-lost-review-notification.md` §8 Get_Opportunity_Detail spec.

**A2 — Treat validation rule errors during smoke testing as schema discovery events**

When smoke test scripts fail because a validation rule requires a field that was not previously known, document the field immediately and add it to schema memory. Do not treat these as test failures to work around — they reveal mandatory field requirements that affect all future builds on that object.

Applied during SAL-9: `STAGE_Closed_Won` validation rule revealed `Reason_for_win__c`, `Protocol_Title__c`, `Contract_Sign_Date__c`, `Contract_Type__c`, `Payment_Schedule_Type__c`, `Contract_Entity__c` as mandatory fields not previously in schema memory.

Applied during SAL-10: `STAGE_Closed_Lost` validation rule revealed `Loss_Reason_Date__c` as a mandatory field not previously in schema memory.

> Evidence: `handoff/SAL-9-delivery-handoff.md` §12; Linear SAL-10 "New Smoke Test Discoveries".

**A3 — Implement stub End elements for unresolved routing paths**

When a recipient matrix is not yet confirmed for a Business Category value, implement a stub End element in the Flow decision tree. The stub exits cleanly — no email, no error, Opportunity saves normally. This allows the Flow to be built and tested on confirmed paths without blocking the entire build on unresolved branches.

Applied in SAL-9: S&PS, All Other Projects (Phase I-NIS), Phase I Clinical Conduct Portugal, and Site & Patient Services (CRP & MissionTEC) all exit via stubs.
Applied in SAL-10: same four values plus the blank/unrecognised default path are stubs.

Label format: `Stub_Exit_[BusinessCategoryValue]`. Description on each stub: "No email sent. Recipient matrix pending [decision reference]. Do not connect to a send action until sign-off is received."

> Evidence: `PRDS/SAL-10-closed-lost-review-notification.md` §5; `PRDS/SAL-9-closed-won-notification.md` FR-05.

---

### B. Flow XML Configuration

**B1 — Deploy to production as Draft; activate manually in Setup > Flows**

Flow XML committed to the repo for production deployment must use `<status>Draft</status>`. Deploy → verify in Setup > Flows → click Activate manually. Never deploy a production Flow as Active — there is no review window once it fires on live data.

Commit `95a166c` ("fix(SAL-9): flow status Inactive → Draft for production deploy") exists because the initial SAL-9 XML had the wrong status. This fix was required before the production deploy could proceed.

For sandbox: Active is acceptable — the sandbox is isolated and activation during deploy is lower risk.

> Evidence: git commit `95a166c`; `handoff/SAL-9-delivery-handoff.md` production deployment milestone table ("Deployed as Draft, manually activated by admin").

**B2 — Declare run mode explicitly in every Flow XML**

Every Flow XML must include `<runInMode>DefaultMode</runInMode>` explicitly. Do not omit this element. SystemModeWithoutSharing is the silent default for some Flow types and bypasses object-level sharing rules. DefaultMode = User Context.

> Evidence: Memory Pack §6 NEVER rule; SAL-2, SAL-9, SAL-10 all explicitly declare DefaultMode.

---

### C. Apex Test Coding

**C1 — `@isTest(SeeAllData=true)` is required for all Opportunity Apex tests in this org**

The `Oppty_Code` Flow (an existing org automation, fires on Opportunity insert) requires a Custom Setting or sequence record that does not exist in an isolated test context. Without `SeeAllData=true`, any Apex test that inserts an Opportunity will fail when this Flow attempts to read its configuration. This annotation is required for all Opportunity-related Apex tests in this org. All test DML is still rolled back at the end of the test method.

> Evidence: `SAL9_BypassFlow_Test.cls` line 1 comment — explicit and confirmed in production test run `707UD00000pLfAm`.

**C2 — Mixed-DML workaround: wrap User creation in `System.runAs`**

Creating a User record (setup object DML) and then inserting an Opportunity (non-setup DML) in the same test method triggers Salesforce's mixed-DML restriction. Wrap User creation inside `System.runAs(new User(Id = UserInfo.getUserId()))` to isolate setup-object DML.

```apex
// Correct pattern — isolates setup DML from non-setup DML
System.runAs(new User(Id = UserInfo.getUserId())) {
    testUser = createTestUser('BypassUser', true);
}
// Opportunity DML follows outside the runAs block
```

> Evidence: `SAL9_BypassFlow_Test.cls` lines 76–79 and helper method comment at line 12.

**C3 — BYP-02 assertion is DML success, not email invocation count**

In test context, `Limits.getEmailInvocations()` may return 0 even for a user without Bypass_Flow, because `emailSimple` faults before the counter increments (sandbox email domain restriction). The correct primary assertion for BYP-02 is that the Opportunity DML succeeded — proving the fault connector caught the send error without rethrowing. Combined with BYP-01 (0 invocations with bypass active), the two tests together prove the gate is binary.

```apex
// BYP-02 correct assertion
System.assertEquals('Closed Won', saved.StageName,
    'BYP-02 FAIL: Opportunity did not save — fault connector may have rethrown');
// NOT: System.assertEquals(1, Limits.getEmailInvocations(), ...)
```

> Evidence: `SAL9_BypassFlow_Test.cls` lines 107–111 comment; line 135 assertion.

**C4 — All 12 Closed Won validation-required fields must be populated in test Opportunity data**

`STAGE_Closed_Won` (ID `03dUD000000TMbRYAW`) enforces that these 12 fields are non-blank before any Opportunity can be saved to Closed Won. Any test that updates an Opportunity to Closed Won must populate all 12 or the test will fail the validation rule before the Flow executes.

Required fields: `Description`, `Reason_for_win__c`, `Indication__c`, `Number_of_Enrolled_Participants__c`, `Study_Countries__c`, `Number_of_Sites__c`, `Entities_Providing_Services__c`, `Protocol_Title__c`, `Contract_Sign_Date__c`, `Contract_Type__c`, `Payment_Schedule_Type__c`, `Contract_Entity__c`.

The `buildOpportunity()` helper in `SAL9_BypassFlow_Test.cls` is the canonical reference implementation for this population pattern. Reuse or extend for future SAL-9 and Closed Won tests.

**⚠️ Potential defect to verify:** `SAL9_BypassFlow_Test.cls` line 65 sets `Contract_Type__c = 'Statement of Work, Work Order'` (comma), but the confirmed org picklist value from the PRD is `Statement of Work/Work Order` (slash). If the comma form is not a valid picklist value, it may be silently accepted as a data quality issue or may cause a validation rule pass for the wrong reason. Human or admin should verify via Setup → Object Manager → Opportunity → Contract Type → Picklist Values before the next test run.

> Evidence: `SAL9_BypassFlow_Test.cls` `buildOpportunity()` method; `PRDS/SAL-9-closed-won-notification.md` §3.5 Contract_Type__c picklist values.

---

### D. Smoke Testing

**D1 — Delete or cleanly revert production smoke test records**

After PRE-07 production smoke test, delete or revert the test Opportunity. Leaving a false Closed Won or Closed Lost record in production corrupts pipeline reporting and may trigger unwanted follow-up actions (handover calls, client communications, loss review meetings).

SAL-9 PRE-07: Opportunity `006TY00000vLQOTYA4` was explicitly deleted after smoke test.
SAL-2 PRE smoke: Opportunity `006TY00000qpSxEYAU` (ADP1005) was reverted to null probability.

> Evidence: Linear SAL-9 production completion note ("Smoke test cleanup: Deleted"); `validation/SAL-2-production-smoke-check.md` §8.

**D2 — Select smoke test records with minimal blast radius**

Choose an Opportunity at an early stage (Pre-Identification, Early Engagement) with no active proposal in flight. This minimises the real-world impact of the test email reaching business recipients. Criteria: early stage, low Opp_Probability__c, no active commercial negotiation, opportunity owner aware of or expecting a test email.

SAL-2 selection rationale: "Pre-Identification stage, null current probability, clear early-stage scientific study. No active proposal in flight. Safest available record."

> Evidence: `validation/SAL-2-production-smoke-check.md` §1.

**D3 — `emailSimple` always faults in sandbox for the `astrumcro.com` domain — this is expected**

In `astrum--astrumpar`, `emailSimple` will fault with `INSUFFICIENT_ACCESS_OR_READONLY` for any send to `astrumcro.com` addresses because the domain is not verified in the sandbox. The fault connector catches this. Opportunity DML succeeds. This is expected behaviour — not a Flow defect. Do not attempt to fix it. Email delivery confirmation must happen via production smoke test only.

> Evidence: `handoff/SAL-9-delivery-handoff.md` §11 "Email delivery — 0/4 CONFIRMED"; Linear SAL-10 smoke test Scenarios A–D.

**D4 — Each notification's timing bands must be documented separately**

Debug log `Flow:Opportunity` CODE_UNIT timing is used as the primary smoke test proxy when email delivery cannot be directly confirmed. Timing bands differ by notification because each has a different number of Flow elements.

| Notification | Scenario | Duration | Interpretation |
|---|---|---|---|
| SAL-2 | Entry criteria not met | < 5ms | Blocked at entry |
| SAL-2 | Bypass permission held | ~3ms | Bypassed |
| SAL-2 | Full execution + email send | 179–560ms (UAT); 380ms (production) | Email sent |
| SAL-9 | Full execution + email send | ~500–513ms (sandbox) | Email attempted |
| SAL-10 | Full execution + email send | ~1,500ms (sandbox) | Email attempted |
| SAL-10 | Entry criteria not met | < 10ms | Blocked at entry |

Do not assume SAL-2 timing bands apply to SAL-9 or SAL-10. SAL-10 is approximately 3× slower than SAL-2 due to additional routing decisions.

> Evidence: `LLM-TXTS/SAL-2-memory-update-proposal.md` §6.5; `handoff/SAL-9-delivery-handoff.md` §11; Linear SAL-10 "Evidence method".

---

### E. Prompting and Workflow

**E1 — Specify "documentation mode only" when asking Claude Code to do planning or memory work**

When instructing Claude to do memory updates, design reviews, PRD drafting, or analysis, explicitly include: *"documentation mode only — do not create, edit, deploy, or modify Salesforce metadata."* Without this instruction, Claude may offer to implement or deploy as part of a planning response.

> Evidence: Applied in this memory update session (27 Apr 2026).

**E2 — Every PRD must include all sections before implementation begins**

A PRD is not implementation-ready until it contains all of the following sections: objective, confirmed requirements (functional + non-functional), object and field mapping (schema-validated), trigger criteria, bypass logic, email template content, duplicate-send prevention design, Flow design (element sequence), release gates, test cases (happy path / idempotency / bypass / silent exit / edge cases), deployment plan, rollback plan, open decisions.

A PRD missing any of these sections is incomplete. Do not write Flow XML until all sections are present and reviewed. Applied consistently in SAL-2, SAL-9, and SAL-10.

> Evidence: Structure consistent across `PRDS/SAL-2-*.md`, `PRDS/SAL-9-*.md`, `PRDS/SAL-10-*.md`.

**E3 — Schema validation is a dedicated pre-build step**

Before writing any Flow XML, run SOQL or Tooling API queries against the sandbox to confirm: field API names, data types, picklist values, object relationships, and validation rules. Mark anything that cannot be confirmed as `ORG-VALIDATION REQUIRED` in the PRD. Do not build against assumed field names — silent failures in production are the result.

Schema validation for SAL-9 was performed 25–26 Apr 2026 and revealed the Closed Won validation rule and five previously undocumented fields. Schema validation for SAL-10 was performed 25 Apr 2026 and confirmed `Loss_Reason__c` API name and all six `Business_Category__c` active values.

> Evidence: SAL-2 proposal §4 Step 2; `PRDS/SAL-9-closed-won-notification.md` §3 "All fields validated against live sandbox org"; `PRDS/SAL-10-closed-lost-review-notification.md` §3 "All fields validated against the live sandbox org on 25 April 2026".

---

*Astrum Orbit Programme — Project Memory Update v2.0*
*27 April 2026 — compiled from Memory Pack v1.0, SAL-2 Memory Proposal, SAL-9 PRD and Handoff, SAL-10 PRD, SAL-10 Linear (live), Git history, and Linear MCP queries for SAL-2, SAL-9, SAL-10, SAL-11.*
*Primary source: Linear MCP (27 Apr 2026) is the most up-to-date source for SAL-10 sandbox delivery status.*
*Next update: when BD-01–BD-05 are resolved, when SAL-10 production is activated, or when the next notification enters active build.*
