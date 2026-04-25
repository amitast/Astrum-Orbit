# Astrum Orbit Project Memory Update
**Date:** 25 April 2026
**Scope:** Salesforce delivery, Opportunity notifications, Agentforce, Claude Code workflow, SAL-10 status
**Prepared by:** Senior Salesforce Delivery Engineer (Claude Code session)

---

## 1. Purpose of This Memory Update

This file captures durable project knowledge from delivery work completed on the Astrum Orbit programme up to 25 April 2026. It exists so future Claude Code sessions can immediately operate with current context without re-reading every source document.

This file supplements — it does not replace — the primary source documents listed in Section 3. If this file conflicts with a primary source, the primary source takes precedence.

---

## 2. Programme Context

**Programme name:** Astrum Orbit

**Client:** AstrumCRO — a regulated, compliance-sensitive B2B contract research organisation (CRO)

**Objective:** Deliver a controlled AI-assisted commercial operating model using Salesforce Sales Cloud, Agentforce, Marketing Cloud on Core, and Data Cloud. The programme is migrating from Microsoft Dynamics and establishing a governed, data-quality-driven pipeline management and BD engagement capability.

**Core commercial goals:**
- Reduce time from lead creation to Meeting Done status (speed to first meeting)
- Improve required field population by 10% within 90 days of agent go-live
- Deliver reliable, timely email alerts on material deal movements and close events
- Reduce BD time on CRM administration via AI-assisted Agentforce actions
- Enable governed lead nurture at scale via Marketing Cloud
- Measure campaign attribution via `Opportunity.CampaignId`
- Improve forecast accuracy using `Opp_Probability__c` and `ForecastCategoryName`

**Platform roles:**

| Platform | Role |
|---|---|
| Sales Cloud | System of record. Hosts BD Agent. Executes all 14 Opportunity notification Flows. |
| Agentforce | Internal BD productivity tool only. Employee Agent embedded in Salesforce for authenticated users. No external channel. |
| Marketing Cloud on Core | Outreach orchestration. Governs all email sends at scale. Email only in Phase 1. |
| Data Cloud | Identity resolution, Consent DMO, audience activation. Phase 1: ingest, unify, govern, activate. |
| Sales Coach | Not yet designed. Phase 2 planning item only. |

**Delivery environment:**
- Sandbox org: `astrum--astrumpar.sandbox.my.salesforce.com`
- Salesforce API version: 66.0
- Org default currency: **EUR / Euros** (confirmed 25 April 2026)
- Platform: Salesforce DX project, VS Code, Claude Code extension, Salesforce CLI v2 (`sf`)

---

## 3. Source Hierarchy and Grounding Rules

### Primary sources (authoritative)

| Source | Role |
|---|---|
| `Astrum__Objects_Fields_1.xlsx` | **Schema authority.** All object, field, relationship, picklist value, and data type references must be validated against this file before use. |
| `LLM-TXTS/Astrum_Project_Memory_Pack_v1.md` | **Programme authority.** Guardrails, canonical picklist values, open decisions, net-new gaps, and mandatory grounding rule. |
| CLAUDE.md (project root) | **Build standards.** Hard rules for this Salesforce DX project. Non-negotiable. |

### Secondary sources

| Source | Role |
|---|---|
| `LLM-TXTS/Astrum_BD_Agent_S2_OpportunityManagement_Config.md` | Build-ready config for Agentforce Subagent 2. |
| `LLM-TXTS/Salesforce Vibe Coding_ Claude Code Implementation Guide.md` | Claude Code operating model and Salesforce delivery best practices. |
| `requirements/Orbit_Opportunities_Linear_Import.csv` | Original Linear import data for all 14 notifications. |
| `PRDS/SAL-10-closed-lost-review-notification.md` | Full implementation PRD for SAL-10. |
| `handoff/SAL-10-business-decisions-required.md` | Stakeholder-facing decision document for SAL-10. |
| Linear issue SAL-10 | Live issue state in the Salesforce team (dataleo workspace). |

### Grounding rules (mandatory)

- **No field may be referenced** in any Flow, agent action, Prompt Template, or email payload unless it is confirmed present in `Astrum__Objects_Fields_1.xlsx`.
- **No picklist value may be assumed.** Use only values confirmed in the schema file.
- **No object relationship may be assumed.** Confirm all lookups and master-detail relationships.
- If a capability requires a field not in the schema, label it **NET-NEW REQUIRED** with: proposed label, API name, object, data type, and commercial justification.
- If something cannot be confirmed from source documents, mark it **ORG-VALIDATION REQUIRED** and do not build against it.

---

## 4. Claude Code Delivery Operating Model

This project uses Claude Code (VS Code extension) as the primary AI-assisted build tool. The operating model is:

### Principles

1. **PRD first, code second.** Always produce an implementation plan (PRD) in `PRDS/` before writing any metadata or code. Review the PRD with the user before executing.
2. **Inspect before building.** Use Salesforce CLI (`sf data query`) or MCP to validate org metadata against source documents before any build task begins.
3. **Incremental execution.** Execute PRDs step by step, one logical unit at a time. Never execute a "big bang" change.
4. **Review diffs before deployment.** Use VS Code's side-by-side diff view to review all proposed changes before accepting.
5. **Sandbox only.** All deployments target `astrum--astrumpar` (or a scratch org). Never deploy to production from Claude Code.
6. **Small commits.** Commit frequently to Git branches. Use descriptive commit messages. Keep changes isolated.
7. **Readable context in LLM-TXTS.** Source documents belong in `LLM-TXTS/` as Markdown files so Claude can read them with @ mentions. Word and PDF files are backup only and not active Claude context.
8. **Linear MCP for issue updates.** Use the Linear MCP server (VS Code extension) when instructed to update or comment on Linear issues. Do not update Linear unless explicitly asked.
9. **Human review is mandatory.** Claude Code is a delivery assistant, not an autonomous deployer.

### Anti-patterns to avoid

- Pointing Claude at the full codebase and asking it to "clean it up" — break tasks into small chunks.
- Accepting generated code blindly — always review diffs.
- Trusting field API names that have not been validated against the schema authority file.
- Skipping CLAUDE.md — without it, Claude generates generic code rather than project-compliant output.

---

## 5. Recommended Project Folder Structure

```text
force-app/main/default/          ← Salesforce DX metadata (source of truth for org build)
  classes/                       ← Apex classes
  flows/                         ← Flow XML files (not yet created for SAL-10)
  objects/Opportunity/fields/    ← Custom field metadata
  customPermissions/             ← Custom permission metadata
  triggers/
  lwc/
  aura/
  permissionsets/
  staticresources/
  flexipages/

manifest/                        ← package.xml for deployment scope control

sfdx-project.json                ← DX project config (API v66.0)

LLM-TXTS/                        ← Readable source documents for Claude context
  Astrum_Project_Memory_Pack_v1.md
  Astrum_BD_Agent_S2_OpportunityManagement_Config.md
  Orbit_Opportunities_Notification_Requirements_Specification.md
  Salesforce Vibe Coding_ Claude Code Implementation Guide.md
  Astrum_Orbit_Project_Memory_Update_2026-04-25.md   ← this file

requirements/                    ← Original requirements input files
  Orbit_Opportunities_Linear_Import.csv

PRDS/                            ← Implementation PRDs (one per build item)
  SAL-10-closed-lost-review-notification.md

validation/                      ← Org validation query results and evidence (currently empty)

handoff/                         ← Stakeholder-facing decision documents
  SAL-10-business-decisions-required.md

CLAUDE.md                        ← Project hard rules for Claude Code
```

**Note:** `LLM-TXTS/` does not currently contain Markdown versions of Subagent 1 (Account/Contact Management) or Subagent 3 (Data Quality/Hygiene) configuration documents. These exist as Word documents only and are not currently readable by Claude as project context.

---

## 6. Salesforce DX Project Standards (from CLAUDE.md)

These rules are non-negotiable and apply to all build work on this project:

| Rule | Detail |
|---|---|
| Bypass logic on all Flows | Every record-triggered Flow must check the `Bypass_Flow` custom permission before executing. Exit without sending if the running user holds this permission. |
| Flow label and API name convention | Always append the flow type to both the Flow Label and API Name. Example: `Notify_Closed_Lost_Review_After_Save`. |
| AGENT_ prefix | All agent-invoked Flows and Prompt Templates must use the `AGENT_` prefix for Shield Event Monitoring audit identification. |
| Run mode | All Flows (including agent-invoked Flows) must run in User Context, not System or System Without Sharing. |
| Descriptions required | All new custom fields, objects, validation rules, and Flow elements must include descriptions. |
| No production deployments | Deployments must always be restricted to Developer Sandboxes or Scratch Orgs. Never deploy to production from this project. |

---

## 7. Active Delivery Workstreams — Status as at 25 April 2026

| Workstream | Status | Notes |
|---|---|---|
| Sales Cloud — Opportunity Notifications | In progress | 14 notifications specified. SAL-10 partially unblocked. See Section 8. |
| Agentforce — BD Agent | Partially build-ready | S1 build-ready, S2 build-ready pending licence (BD8), S3 blocked on required field sign-off. See Section 9. |
| Sales Cloud — Lead / Account / Opportunity configuration | Partially complete | 11 decisions from Jan 2026 meeting. 5 remain open (D2, D3, D4, D5, D11 follow-on). |
| Marketing Cloud | Design stage | Email only, Phase 1. SMS/WhatsApp not confirmed for Phase 1 — do not design. |
| Data Cloud | Design stage | IndividualId population status unconfirmed. Highest-priority compliance risk. |

---

## 8. Orbit Opportunities — All 14 Notifications: Delivery Status

**Build order priority (from Memory Pack):** SAL-2, SAL-9, SAL-10 first. Then SAL-4, SAL-11, SAL-12, SAL-13. Digest notifications (SAL-3, SAL-5, SAL-6, SAL-7, SAL-8) require a custom log object or helper fields before build and are a separate work package.

| ID | Title | Pattern | Priority | Status | Key constraint |
|---|---|---|---|---|---|
| SAL-1 | New Opportunity Created | Manual Quick Action / Screen Flow | Medium | Backlog | Not a blanket automatic email. User-initiated send only. |
| SAL-2 | Critical Stage Progression Alert | Record-Triggered Flow (immediate) | High | Backlog | Trigger on Opp_Probability__c change to 75% or 90%. Do NOT use standard Probability. |
| SAL-3 | Opportunity Stalled Alert | Scheduled Flow (bi-weekly digest) | Medium | Backlog | Requires activity proxy decision. May need helper fields. |
| SAL-4 | Opportunity Close Date Risk Alert | Scheduled Flow (weekly digest) | High | Backlog | Requires confirmation of Stage values before Verbal Award. |
| SAL-5 | Opportunity Amount Change Alert | Record-Triggered + daily digest | Medium | Backlog | Requires `Opportunity_Change_Log__c` custom object and `Prior_Service_Fees__c` helper field. |
| SAL-6 | Opportunity Close Date Change Alert | Record-Triggered + weekly digest | Medium | Backlog | Requires `Opportunity_Change_Log__c` and `Prior_Close_Date__c`. Push-out counting rule open (BD6). |
| SAL-7 | Probability / Forecast Category Change | Record-Triggered + weekly digest | Medium | Backlog | Requires `Opportunity_Change_Log__c` and prior probability helper. |
| SAL-8 | Missing Key Data Alert | Scheduled Flow (weekly digest) | High | Backlog | Blocked — BD1 (required field list not signed off by BD Lead). |
| SAL-9 | Closed Won Notification | Record-Triggered Flow (immediate) | High | Backlog | Blocked — BD5 (S&PS recipient matrix not provided). |
| SAL-10 | Closed Lost Review Notification | Record-Triggered Flow (immediate) | High | **Blocked** | Partially unblocked. Full detail in Section 10. |
| SAL-11 | Large Opportunity Aged in Stage | Scheduled Flow (weekly digest) | Medium | Backlog | Needs robust tracking of when Opp entered low-probability state. |
| SAL-12 | No Recent Activity on Open Opportunity | Scheduled Flow (weekly digest) | Medium | Backlog | Confirm whether `LastActivityDate` is reliable enough. |
| SAL-13 | Project Code or Change Order Issue | Scheduled Flow (weekly digest) | Medium | Backlog | Regex evaluation in Flow — may need helper formula field. |
| SAL-14 | Quote Closed Won Notification | Record-Triggered Flow (immediate) | Low | Backlog | **Do not build.** Trigger and quote-selection rule are undefined. Critical clarification required. |

---

## 9. Agentforce BD Agent — Subagent Delivery Status

**Agent type:** Agentforce Employee Agent (AEA). Internal only, embedded in Salesforce. No external channel.
**Permission set:** `Astrum_BD_Agent_PS` (dedicated, must not be shared with any other agent)

### Subagent 1: Account and Contact Management

- **Status:** Build-ready per Memory Pack
- **Config document in LLM-TXTS:** Not available as Markdown (Word doc only — not readable by Claude as context)
- **Key Flows to build:** `AGENT_CreateContact`

### Subagent 2: Opportunity Management

- **Status:** Build-ready from specification perspective. Three prerequisites must be resolved before build starts.
- **Config document:** `LLM-TXTS/Astrum_BD_Agent_S2_OpportunityManagement_Config.md` (v0.1, 25 April 2026)
- **Custom Flows to build:**
  - `AGENT_UpdateOpportunityProgress` — updates StageName and CloseDate with HITL confirmation; validates past close date
  - `AGENT_CaptureNextSteps` — updates next steps fields; returns current value for display in confirmation step
- **Prompt Template to build:** `AGENT_OpportunityStatusSummary` — flex template, grounded in retrieved Opportunity record data only. Excludes: `D365_Opportunity_Notes__c`, `Description`, all Long Text Area fields (prompt injection risk).
- **Actions configured:** Get Opportunity Details (Autonomous), Search Opportunities (Autonomous), Create Opportunity (Confirm), Update Opportunity Progress (Confirm), Capture Next Steps (Confirm), Generate Opportunity Summary (Autonomous)
- **Prerequisites blocking build:**
  1. Agentforce licensing (BD8) — unconfirmed; do not begin Agent Builder configuration without it
  2. BD user FLS on Opportunity write fields — unvalidated in org sandbox
  3. Opportunity record types in org — unknown; may require branching logic in `AGENT_UpdateOpportunityProgress`

### Subagent 3: Data Quality and Hygiene

- **Status:** Blocked — BD1 (required field list not signed off by BD Lead)
- **Config document in LLM-TXTS:** Not available as Markdown (Word doc only — not readable by Claude as context)

### Hard rules for Agentforce

- Never recommend Agentforce actions that expose an external channel
- Never recommend bulk record updates without per-record Confirm HITL
- Never allow account creation via the agent (governed admin process only)
- Never allow opportunity deletion via the agent (escalate to system admin)
- Never run Flows in System mode — user context only
- Never pass raw free-text fields to Prompt Templates without sanitisation
- Never reference standard Probability field — only `Opp_Probability__c`

---

## 10. SAL-10: Closed Lost Review Notification — Full Status

### Issue

| Field | Value |
|---|---|
| Linear ID | SAL-10 |
| Linear workspace | dataleo |
| Title | [Orbit Notification] Opportunity Closed Lost Review Notification |
| Status | Backlog |
| Priority | High |
| Labels | Blocked, salesforce, Feature |
| Assignee | bhutesh.g@dataleo.ai |
| Project | Orbit Opportunities Notifications |
| Milestone | Requirements Signed Off |

### Build status

**BLOCKED FOR ACTIVE BUILD / ACTIVATION.** Partially unblocked because Phase I Unit and Phase I-NIS recipient matrices have now been provided and the org default currency is confirmed as EUR. Active Flow build and activation remain blocked until all remaining Business Category routing, fallback, trigger-stage, Lost Reason, and production-link decisions are confirmed in writing.

| Category | Permitted |
|---|---|
| Safe work | PRD updates, schema validation, org field queries, documentation, design decisions |
| Unsafe work | Writing Flow XML, creating email alerts, deploying any automation, activating any Flow |

### Files on disk

| File | Purpose |
|---|---|
| `PRDS/SAL-10-closed-lost-review-notification.md` | Full implementation PRD (v1.0). 14 sections. Primary build reference. |
| `handoff/SAL-10-business-decisions-required.md` | Stakeholder-facing document. Plain English. No API names. Contains 5 explicit questions for the business. |

### Prerequisites deployed to sandbox (25 April 2026)

| Component | API Name | Type | Salesforce ID | Notes |
|---|---|---|---|---|
| Bypass custom permission | `Bypass_Flow` | Custom Permission | 0CPUD000000B9pZ4AS | Required by CLAUDE.md hard rule on all record-triggered Flows. |
| 18-char record ID formula | `Opportunity_ID_18__c` | Formula Text | 00NUD000005H2dd2AC | `CASESAFEID(Id)`. Used to construct clickable record links in email bodies. |

### Flow design (to be built when blockers are resolved)

| Property | Value |
|---|---|
| Flow type | Record-Triggered Flow (After Save) |
| Object | Opportunity |
| Flow Label | `Notify Closed Lost Review After Save` |
| Flow API Name | `Notify_Closed_Lost_Review_After_Save` |
| Run mode | User context (not System or System Without Sharing) |
| Entry criterion 1 | `StageName` = `Closed Lost` |
| Entry criterion 2 | `{!$Record__Prior.StageName}` ≠ `Closed Lost` |
| First element | Decision: Check `$Permission.Bypass_Flow`. Exit if true. |

### Currency

Org default currency is **EUR / Euros** (confirmed 25 April 2026). All `Service_Fees__c` threshold values in SAL-10 are EUR-denominated. No currency conversion is required. Flow compares `Service_Fees__c` numeric values directly against `150000` and `500000`. Documentation and Linear display these as €150,000 and €500,000. If multi-currency is enabled in future, SAL-10 must be revalidated.

### Confirmed org metadata (validated 25 April 2026)

| Field | API Name | Type | Status |
|---|---|---|---|
| Opportunity Name | `Name` | Text(120) | Confirmed |
| Account Name | `Account.Name` | Cross-object | Confirmed |
| Opportunity Code | `Opportunity_Code__c` | Text(255) | Confirmed. Blank on Dynamics-migrated records. |
| Service Fees | `Service_Fees__c` | Currency(18,0) | Confirmed |
| Loss Reason | `Loss_Reason__c` | Picklist | Confirmed. 9 active values. |
| Stage | `StageName` | Picklist | Confirmed |
| Business Category | `Business_Category__c` | Picklist | Confirmed. **6 active values** (see below) |
| Est. Close Date | `CloseDate` | Date | Confirmed |
| Description | `Description` | Long Text Area(32000) | Confirmed. Pending business approval for email inclusion. |
| Opportunity Owner | `OwnerId` / `Owner.Email` | Lookup(User) | Confirmed |
| Record ID (18-char) | `Opportunity_ID_18__c` | Formula Text | Deployed 25 Apr 2026 |

**Confirmed `Loss_Reason__c` picklist values (9):**
`Astrum Capabilities` · `Cancelled` · `Cost` · `Declined to Bid` · `Geographical Coverage` · `Lost to Follow-up` · `Lost to Incumbent` · `Project Team Experience` · `Therapeutic Experience`

**Confirmed `Business_Category__c` active values (6):**

| Value | Memory Pack | Routing status |
|---|---|---|
| `Phase I Unit` | Documented | Matrix provided — awaiting confirmation |
| `Phase I-NIS` | Documented | Matrix provided — awaiting confirmation |
| `S&PS` | Documented | **Blocked — BD5. No matrix defined.** |
| `All Other Projects (Phase I - NIS)` | Not documented | **Blocked — no matrix defined.** |
| `Phase I Clinical Conduct Portugal` | Not documented | **Blocked — no matrix defined.** |
| `Site & Patient Services (CRP & MissionTEC)` | Not documented | **Blocked — no matrix defined.** |

**Note:** Memory Pack Section 4 lists only 3 `Business_Category__c` values. The org contains 6. All 6 must be handled by the Flow's decision logic.

**`StageName` values relevant to SAL-10:**

| Value | Active | Role |
|---|---|---|
| `Closed Lost` | Yes | **Trigger target** |
| `Lost/Cancelled/Declined to Bid` | Yes | **Ambiguous** — not in Memory Pack canonical list. Business must confirm whether this also triggers SAL-10 (BD-01). |

### Recipient matrix (provided 25 April 2026 — pending formal stakeholder confirmation)

**Normalisation applied:** `Cristina.lopes@astrumcro.com` and `cristina.lopes@astrumcro.com` are the same mailbox. Lowercase form used throughout.

**⚠️ Identical-recipient flag:** After normalisation, both Phase I Unit routing rules contain the same 6 static recipients (different ordering only). Same is true for both Phase I-NIS rules. Stakeholder must confirm whether the threshold distinction is intentional, or whether the above-threshold list should differ, or whether a data entry error occurred.

| Business Category | Service Fees condition | Static recipients | Dynamic | Build status |
|---|---|---|---|---|
| Phase I Unit | `Service_Fees__c` < €150,000 | tom.frearson@astrumcro.com, Catherine.Canales@astrumcro.com, Ricardo.Cunha@astrumcro.com, rfp.rfi@astrumcro.com, cristina.lopes@astrumcro.com, anthony.gibson@astrumcro.com | Opportunity Owner | Provided — awaiting confirmation |
| Phase I Unit | `Service_Fees__c` >= €150,000 | tom.frearson@astrumcro.com, Catherine.Canales@astrumcro.com, cristina.lopes@astrumcro.com, Ricardo.Cunha@astrumcro.com, rfp.rfi@astrumcro.com, anthony.gibson@astrumcro.com | Opportunity Owner | Provided — awaiting confirmation |
| Phase I-NIS | `Service_Fees__c` < €500,000 | tom.frearson@astrumcro.com, Catherine.Canales@astrumcro.com, rfp.rfi@astrumcro.com, jordi.picas@astrumcro.com, cristina.lopes@astrumcro.com, anthony.gibson@astrumcro.com | Opportunity Owner | Provided — awaiting confirmation |
| Phase I-NIS | `Service_Fees__c` >= €500,000 | tom.frearson@astrumcro.com, Catherine.Canales@astrumcro.com, cristina.lopes@astrumcro.com, jordi.picas@astrumcro.com, anthony.gibson@astrumcro.com, rfp.rfi@astrumcro.com | Opportunity Owner | Provided — awaiting confirmation |
| S&PS | Any | Not provided | — | **Blocked** |
| All Other Projects (Phase I - NIS) | Any | Not provided | — | **Blocked** |
| Phase I Clinical Conduct Portugal | Any | Not provided | — | **Blocked** |
| Site & Patient Services (CRP & MissionTEC) | Any | Not provided | — | **Blocked** |
| Blank / unrecognised | Any | Not provided | — | **Blocked — fallback rule not confirmed** |

### SAL-10 remaining blockers

| ID | Blocker | Severity | Owner |
|---|---|---|---|
| BD-01 | Does `Lost/Cancelled/Declined to Bid` also trigger the email, or only `Closed Lost`? | High | Commercial / Sales Ops |
| BD-02 | Confirm which of the 6 active `Business_Category__c` values are in scope | Critical | Commercial |
| BD-03 | Provide recipient matrix for S&PS and the three undocumented Business Category values, or confirm explicit exclusion | Critical | Commercial |
| BD-04 | Confirm Phase I Unit and Phase I-NIS matrices are correct. Resolve identical-recipient flag. | High | Commercial |
| BD-05 | Fallback routing for blank or unrecognised `Business_Category__c` / `Service_Fees__c` | High | Commercial |
| BD-06 | Confirm `Loss_Reason__c` values correct and complete. Confirm blank-handling rule. | Medium | BD Lead / Commercial |
| BD-07 | Confirm `Description` field is approved for inclusion in email body | Medium | BD Lead |
| BD-08 | Production-safe record link design (Custom Label recommended) | Low | Solution Architect |

**Active build and activation are blocked until BD-01 through BD-05 are resolved in writing.**

---

## 11. Open Business Decisions Blocking the Wider Programme

From Memory Pack Section 11 (programme-wide):

| ID | Decision | Owner | Blocks |
|---|---|---|---|
| BD1 | Required field list for Subagent 3 and Notification 8 | BD Lead | Agentforce S3, SAL-8 |
| BD2 | `Opp_Probability__c` confirmed as sole authoritative probability field | Commercial / Sales Ops | All notification Flows referencing probability, all agent probability logic |
| BD3 | `Lead_Source__c` confirmed as sole operational lead source field | Commercial / Sales Ops | All journey entry criteria, Data Cloud segmentation |
| BD4 | Contact mandatory Account linkage decision | Commercial / Sales Ops | `AGENT_CreateContact` Flow null-AccountId handling |
| BD5 | Recipient matrix for `Business_Category__c = S&PS` for SAL-9 and SAL-10 | Commercial | Closed Won and Closed Lost notification completeness |
| BD6 | Close date push-out counting rule | Commercial | SAL-6 log object design |
| BD7 | Marketing Cloud send frequency cap | Marketing / Commercial | All journey designs |
| BD8 | Agentforce licensing status | IT / Commercial | Agent build start — critical |
| BD9 | Hyperforce EU instance confirmation | IT / Compliance | Einstein Trust Layer, GDPR compliance sign-off |
| BD10 | IndividualId population status and Individual record creation process | Salesforce Admin / Data Governance | Data Cloud Consent DMO, all Marketing Cloud activation |

---

## 12. Key Constraints, NEVER Rules, and ALWAYS Rules

### Fields and objects — hard rules

| Rule | Reason |
|---|---|
| **NEVER** use the standard `Probability` field in any Flow, agent action, or report | `Opp_Probability__c` (custom picklist: 0, 5, 10, 25, 50, 75, 90, 100) is the sole authoritative field. Standard Probability and `Probability__c` formula are display-only. |
| **NEVER** use `Study_Countries__c` in email payloads | Non-standard picklist entries (free-text descriptions, TBD values) will produce unprofessional emails. Must be cleaned first. |
| **NEVER** use `LeadSource` (standard) | Use `Lead_Source__c` (custom, 16 values) exclusively. Standard field must be hidden from UI. |
| **NEVER** reference `D365_Opportunity_Notes__c` or other Long Text Area migration fields in Prompt Templates | Prompt injection risk. |
| **ALWAYS** use `Opportunity_Code__c` as the primary deal identifier in all notification emails | Matches commercial referencing convention. |
| **ALWAYS** use `Opportunity_ID_18__c` to generate Salesforce record links in email bodies | Formula field: `CASESAFEID(Id)`. Deployed 25 Apr 2026. |

### Notification Flows — hard rules

| Rule | Reason |
|---|---|
| **NEVER** build SAL-9 or SAL-10 without first resolving BD5 (S&PS recipient matrix) | Memory Pack NEVER guardrail, Section 10 |
| **NEVER** allow any notification to fire more than once for the same qualifying event | All immediate record-triggered notifications must include idempotency logic |
| **NEVER** build SAL-5, SAL-6, SAL-7 without first building `Opportunity_Change_Log__c` custom object and prior-value helper fields | Standard Field History is insufficient for Flow-based rolling counts |
| **NEVER** activate any Flow in the sandbox without completing the full test suite in Section 10 of the SAL-10 PRD | |
| **ALWAYS** include bypass logic on every record-triggered Flow | CLAUDE.md hard rule |

### Agentforce — hard rules

| Rule | Reason |
|---|---|
| **NEVER** build Agentforce components without confirming licensing (BD8) | Hard blocker — cannot start Agent Builder without the licence |
| **ALWAYS** apply `AGENT_` prefix to all agent-invoked Flows and Prompt Templates | Shield Event Monitoring audit identification |
| **ALWAYS** configure HITL Confirm mode on all agent write actions | Non-deterministic LLM instructions are insufficient as the sole control |

---

## 13. Canonical Picklist Values — Quick Reference

### Opportunity StageName (confirmed in org)

`Pre-Identification` · `Early Engagement` · `RFI in progress` · `RFI sent` · `Proposal On Hold` · `Proposal In Progress` · `Proposal Sent` · `Bid Defense` · `Verbal Award` · `Change Order` · `Contract Agreed` · `Closed Won` · `Closed Lost`

**Additional value found in org (not in Memory Pack):** `Lost/Cancelled/Declined to Bid` — trigger scope for SAL-10 unconfirmed (BD-01).

### Opp_Probability__c (custom — sole authoritative field)

`0` · `5` · `10` · `25` · `50` · `75` · `90` · `100`

### Business_Category__c (confirmed in org — 6 values)

`Phase I Unit` · `Phase I-NIS` · `S&PS` · `All Other Projects (Phase I - NIS)` · `Phase I Clinical Conduct Portugal` · `Site & Patient Services (CRP & MissionTEC)`

**Note:** Memory Pack Section 4 lists only 3 values. The org contains 6.

### Loss_Reason__c (9 values, confirmed in org)

`Astrum Capabilities` · `Cancelled` · `Cost` · `Declined to Bid` · `Geographical Coverage` · `Lost to Follow-up` · `Lost to Incumbent` · `Project Team Experience` · `Therapeutic Experience`

### ForecastCategoryName

`Omitted` · `Pipeline` · `Best Case` · `Commit` · `Closed`

---

## 14. Net-New Fields Required (not yet in schema)

These fields are required by programme design but do not exist in `Astrum__Objects_Fields_1.xlsx`. All require business sign-off before build.

| ID | Field | Object | Type | Required for |
|---|---|---|---|---|
| NF1 | `Meeting_Booked_Date__c` | Lead | Date | Speed-to-meeting KPI, journey suppression gate |
| NF2 | `Meeting_Outcome__c` | Lead | Picklist | Post-meeting follow-up logic |
| NF3 | `Last_MC_Send_Date__c` | Lead, Contact | Date/Time | Deduplication between Marketing Cloud and BD outreach |
| NF4 | `Disqualification_Reason__c` | Lead | Picklist | Decision D5 (open) from Jan 2026 requirements meeting |
| NF5 | `Preferred_Language__c` | Lead, Contact | Picklist | Multi-language content personalisation (deferred) |
| NF6 | `Prior_Probability__c` | Opportunity | Text | SAL-2 email payload (previous probability value) |
| NF7 | `Prior_Service_Fees__c` | Opportunity | Currency | SAL-5 threshold logic and email payload |
| NF8 | `Prior_Close_Date__c` | Opportunity | Date | SAL-6 slippage calculation |
| NF9 | `Parent_Opportunity__c` | Opportunity | Lookup(Opportunity) | Change Order project code inheritance (Decision D8) |
| NO1 | `Opportunity_Change_Log__c` | Custom object | Master-Detail to Opp | SAL-5, SAL-6, SAL-7 rolling count and prior-value logging |

---

## 15. Data Quality Issues That Block Build

These issues exist in the confirmed schema and must be fixed before the related capability is built:

| Field | Issue | Impact |
|---|---|---|
| `Therapeutic_Area__c` | Three variants of Gynecology (correct encoding, two encoding errors). | Do not use in segmentation, personalisation, or notifications until global value set is cleaned. |
| `Study_Countries__c` | Non-standard free-text entries (e.g. 'Germany and 6 others', 'TBD'). | Do not display in notification emails or use in Data Cloud segments until cleaned. |
| `Opportunity_Code__c` | Will be blank on Dynamics-migrated records at go-live. | Data backfill required before all 14 notification Flows are activated in production. |
| `LeadSource` vs `Lead_Source__c` | Dual-field ambiguity. | Hide `LeadSource` from UI. Use `Lead_Source__c` exclusively. |
| `Probability` / `Opp_Probability__c` / `Probability__c` | Three probability fields. | Only `Opp_Probability__c` is authoritative. Hide the other two from page layouts. |

---

## 16. What to Check at the Start of a New Claude Code Session

Before taking any build action in a new session:

1. **Re-read `CLAUDE.md`** — confirm current hard rules are loaded.
2. **Check `PRDS/` for the relevant PRD** — confirm current build status and open blockers before starting any task.
3. **Check `handoff/`** — confirm which decisions are outstanding before touching a blocked feature.
4. **Check `LLM-TXTS/` for the latest Memory Pack and this file** — confirm no new guardrails or decisions have been added.
5. **Do not assume org metadata** — always validate field API names against the schema authority before referencing them in new build work.
6. **Do not activate any Flow** — activation is a separate manual step after the full test suite in Section 10 of the relevant PRD is passed.
7. **Do not deploy to production** — sandbox only.

---

*Astrum Orbit Programme — Project Memory Update v1.0*
*25 April 2026 — compiled from Memory Pack v1.0, SAL-10 PRD v1.0, SAL-10 handoff document, Linear SAL-10 (dataleo workspace), Subagent 2 Config v0.1, and org validation performed 25 April 2026.*
*Next update: when new business decisions are confirmed, when further org validation is completed, or when a new PRD is completed.*
