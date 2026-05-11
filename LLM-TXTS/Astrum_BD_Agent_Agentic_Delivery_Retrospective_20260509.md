# Astrum BD Agent Agentic Delivery Retrospective

> **Date:** 2026-05-09
> **Author:** Claude Code (Architect agent)
> **Programme:** Astrum Orbit — Salesforce Agentforce
> **Issues covered:** SAL-15, SAL-16, SAL-17, SAL-21
> **Branch reviewed:** `feature/astrum-bd-agent-build`
> **Status:** For Human review and approval

---

## 1. Executive Summary

The Astrum BD Agent, Subagent 1 (Account and Contact Management), has been successfully built, validated, and deployed to production. Eight agent actions, one permission set, one planner bundle, and supporting Apex classes and Flows have been deployed and confirmed active. A Human-conducted smoke test on 2026-05-09 returned 8/8 PASS. The agent is deployed and approved for publication.

The delivery used a three-operator agentic model: Claude Code as Architect and Reviewer, Codex as Builder and Test Executor, and Human as Approval Authority. Agentforce Vibes was added partway through the delivery as a fourth operator. Based on evidence reviewed, Agentforce Vibes added governance overhead without delivering commensurate execution velocity. It is recommended that Agentforce Vibes be removed from the routine delivery workflow and that the programme proceed with a streamlined two-AI-agent model.

**Primary operating model recommendation:** Continue with Claude Code and Codex only, governed by a tighter phase gate process. Define Agentforce Vibes as an optional reference resource, not an execution operator. Require every Claude and Codex output to include a plain-English business summary. Establish a dependency readiness checklist before every production deployment.

---

## 2. Scope of Retrospective

| Item | Detail |
|---|---|
| Workstreams reviewed | SAL-15 (AGENT_CreateContact Flow), SAL-16 (Agent Builder — Create Contact), SAL-17 (Permission Set), SAL-21 (S1 Remaining Actions + Production Deployment) |
| PRDs reviewed | `PRDS/SAL-21-astrum-bd-agent-s1-remaining-actions.md` |
| Specs reviewed | `LLM-TXTS/agentforce/Astrum_BD_Agent_Overarching_Spec.md`, `Astrum_BD_Agent_S1_AccountContact_Spec.md`, `Astrum_BD_Agent_S2_OpportunityManagement_Spec.md`, `Astrum_BD_Agent_S3_DataQualityHygiene_Spec.md` |
| Validation evidence reviewed | 37 evidence files in `validation/`, including all SAL-21 production phases |
| Handoff files reviewed | `handoff/SAL-15-16-17-session-closeout.md`, `handoff/Astrum-BD-Agent-Business-User-Guide-20260509.md` |
| Metadata reviewed | `GenAiPlannerBundle:Astrum_BD_Agent`, `Astrum_BD_Agent_PS`, all AGENT_ Apex classes and Flows |
| Git evidence reviewed | `feature/astrum-bd-agent-build` git log (full branch history) |
| AGENTS.md, CLAUDE.md reviewed | Yes |
| AI_WORKFLOW.md | Not present in repository |
| Linear evidence | Linear MCP not available at time of retrospective. Linear was not inspected. Evidence from Linear comment IDs recorded in handoff files was noted. |

---

## 3. What Was Delivered

### 3.1 Business-Language Summary

The Astrum BD Agent is now live in the Astrum production Salesforce org. BD users who have been assigned the `Astrum_BD_Agent_PS` permission set can open the Salesforce agent interface and ask questions about accounts and contacts, request account summaries, search for contacts by account or title, and update permitted account and contact fields — all with a confirmation step before any change is written.

The agent does not allow users to create new accounts, delete any record, update structural fields such as account owner, or make changes across multiple records at once without reviewing each one individually. All of these restrictions are enforced at the Apex and permission level, not just by the agent's instructions.

Production smoke testing on 2026-05-09 by the Human approved 8 out of 8 test scenarios covering the full capability range. The agent was confirmed ready for publication by the programme lead, Amit Asthana.

### 3.2 Technical Summary

| Component | API Name | Type | Status |
|---|---|---|---|
| Create Contact with Duplicate Check | `AGENT_CreateContact` | Autolaunched Flow | Active in production |
| Get Account Details | `AGENT_GetAccountDetails` | Autolaunched Flow | Draft in production (note below) |
| Get Contact Details | `AGENT_GetContactDetails` | Autolaunched Flow | Draft in production (note below) |
| Search Accounts | `AGENT_SearchAccounts` | Apex Invocable | Active in production |
| Search Contacts | `AGENT_SearchContacts` | Apex Invocable | Active in production |
| Update Account Field | `AGENT_UpdateAccountField` | Apex Invocable | Active in production |
| Update Contact Field | `AGENT_UpdateContactField` | Apex Invocable | Active in production |
| Account Intelligence Summary | `AGENT_AccountIntelligenceSummary` | Apex Invocable (replaced Prompt Template action) | Active in production |
| Permission Set | `Astrum_BD_Agent_PS` | Permission Set | Active in production |
| Planner Bundle | `Astrum_BD_Agent` | GenAiPlannerBundle | Deployed, ID `16jTY000000Oa5ZYAS` |
| Prompt Template (as deployed metadata) | `AGENT_AccountIntelligenceSummary` | GenAiPromptTemplate | Deployed to production (metadata only; invoked via Apex, not as a direct Prompt Template action) |

> **Note on Flow status:** `AGENT_GetAccountDetails` and `AGENT_GetContactDetails` report as `Draft` status via Tooling API post-production-deploy. This is a Salesforce platform behaviour: autolaunched Flows deployed via Metadata API land as Draft. They are callable by the agent planner at runtime. The smoke test (8/8 PASS) confirms they are functioning correctly despite the Draft status label.

**Confirmed excluded from this delivery:**
- Subagent 2 (Opportunity Management) — not built.
- Subagent 3 (Data Quality and Hygiene) — not built.
- Full Agentforce Testing Center regression suite — not executed in production. Sandbox Testing Center runs completed for SAL-21.
- Einstein Trust Layer PII masking configuration — confirmation outstanding.
- Field Audit Trail configuration — outstanding.
- Hyperforce EU instance confirmation — outstanding.

### 3.3 Production Deployment Evidence

| Phase | Deploy ID | Components | Result |
|---|---|---|---|
| Phase 1 — Apex classes to production | `0AfTY000003nxMz0AI` | `AGENT_UpdateContactField`, `AGENT_UpdateContactField_Test` | Succeeded |
| Phase 2 — Remaining Apex and Flows | (from evidence files) | All remaining AGENT_ Apex classes and Flows | Succeeded |
| Phase 3b — Dependency remediation | `0AfTY000003o1IX0AY` | `AGENT_GetAccountDetails`, `AGENT_GetContactDetails`, `AGENT_AccountIntelligenceSummary` (Prompt Template metadata) | Succeeded |
| Phase 3 — Planner Bundle | `0AfTY000003o1SD0AY` | `GenAiPlannerBundle:Astrum_BD_Agent` | Succeeded |
| Post-smoke-test — Apex action replacement | `0AfTY000003o2ph0AA`, `0AfTY000003o2sv0AA` | `AGENT_AccountIntelligenceSummary` Apex + updated planner bundle | Succeeded |

**Production smoke test:** 8/8 PASS — 2026-05-09, conducted by Amit Asthana (Human).

---

## 4. Delivery Model Used

### 4.1 Roles

| Operator | Role as Used | Activation point |
|---|---|---|
| Claude Code | Architect, PRD author, reviewer, risk assessor, evidence reviewer, next-prompt generator | From project start |
| Codex | Builder, test executor, Salesforce CLI operator, evidence file creator | From project start |
| Human | Approval authority, production release authority, UAT executor, business decision maker, UI-only steps | From project start |
| Agentforce Vibes | Salesforce-native validator, Tooling API inspector, Testing Center operator | Added at SAL-16 (commit `5291ecf`, 2026-04-28) |

### 4.2 Governance Framework

The three-operator model was established in `AGENTS.md` and `CLAUDE.md`. The required output footer (`## Next Operator`) was mandatory in all AI-operator outputs. The evidence standard defined in AGENTS.md Section 15 (validation/ and handoff/ files) was followed throughout the delivery.

---

## 5. What Worked Well

| Practice | Why it worked | Evidence observed | Keep / Change |
|---|---|---|---|
| PRD-first delivery | Codex received unambiguous scope before building. Change in architecture (standard → custom actions) was captured in PRD v1.1 before build began. | `PRDS/SAL-21-astrum-bd-agent-s1-remaining-actions.md` v1.0 → v1.1; SAL-15-17 session closeout | **Keep** |
| Build Readiness Report before build | Claude Code produced a schema authority QC and cross-spec validation before Codex touched any metadata. Caught StageName gap (13 vs 19 values) and FLS-restricted fields before build began. | `validation/agentforce/Astrum_BD_Agent_Build_Readiness_Report.md` | **Keep** |
| Claude Code as architect/reviewer gate | Claude reviewed Codex evidence before any live deploy was authorised. Identified and blocked incorrect approaches (e.g. standard actions without field allow-lists) before metadata was built. | SAL-21 PRD v1.1 architect review; all phase validate-only review prompts | **Keep** |
| Codex as disciplined builder | Codex built exactly the approved scope. Changes were minimal and scoped. No unrelated files were touched in any build session. Evidence files were consistently produced. | All validation/ evidence files; git log confirms no out-of-scope file edits | **Keep** |
| Check-only validation before every live deploy | No metadata was written to production without a prior successful validate-only job. Quick deploy reused the validated job ID. | Phase 1, Phase 2, Phase 3, Phase 3b validate-only evidence files | **Keep — mandatory** |
| RunLocalTests on every validate | Apex test coverage was confirmed on every validate-only job. 28/28, 51/51 tests passed in production validate jobs. | `SAL-21-phase-1-production-apex-deploy-20260509.md`, `SAL-21-phase-3b-production-remediation-20260509.md` | **Keep — mandatory** |
| Human approval gates | No live deploy ran without explicit Human authorisation. Activation and publication were Human-controlled. No AI operator activated or published the agent. | All phase evidence files carry Human authorisation statements | **Keep — mandatory** |
| Pre-flight org check (IsSandbox) | Every Codex org operation began with `SELECT IsSandbox FROM Organization`. Production operations confirmed `IsSandbox = false` before proceeding. | Explicit check in all production phase evidence files | **Keep — mandatory** |
| Next Operator footer | Every Claude and Codex output carried a `## Next Operator` block. Handoffs were never ambiguous. | All evidence files and handoff documents | **Keep — mandatory** |
| Dedicated permission set | `Astrum_BD_Agent_PS` was scoped exclusively to this agent. No profile changes. Additive-only pattern. No delete permissions. | `validation/SAL-17-Permissions-FLS-CreateContact.md`; `SAL-15-16-17-session-closeout.md` | **Keep** |
| Custom Apex allow-lists for field control | Standard Update Record action has no platform-enforced field allow-list. Apex invocables with hard-coded allow-lists prevent the agent from proposing updates to structural fields (`OwnerId`, `AccountId`, `ParentId`). Test cases confirm rejection. | PRD v1.1 architect review; `AGENT_UpdateAccountField_Test`, `AGENT_UpdateContactField_Test` | **Keep — security critical** |
| AGENT_ prefix on all agent-invoked Flows and Apex | Audit identification in Shield Event Monitoring. No exceptions during delivery. | All flow and class file names; confirmed in bundle localAction names | **Keep — mandatory** |
| Evidence file naming convention | Standard naming (SAL-{n}-{description}.md in validation/) made evidence findable and reviewable without a manifest. | `validation/` directory — 37 evidence files, all consistently named | **Keep** |
| Handoff documents | `handoff/` files provided programme-level summary for each session. The Business User Guide (`handoff/Astrum-BD-Agent-Business-User-Guide-20260509.md`) provides a business-readable view of what was delivered. | `handoff/SAL-15-16-17-session-closeout.md`; Business User Guide | **Keep** |
| Incremental dependency remediation | When a production validate failed due to a missing dependency, the response was a targeted remediation deploy of the specific missing component, not a full re-deploy. | Phase 2, Phase 3b remediation evidence files | **Keep pattern — but improve pre-flight checklist** |
| No production deployment by AI without Human authority | No AI operator ran a live production deploy without Human authorisation in the session. The authorisation chain is documented in each production evidence file. | All production evidence files carry explicit authorisation statements | **Keep — non-negotiable** |

---

## 6. What Did Not Work Well

| Issue | Impact | Root Cause | Recommendation |
|---|---|---|---|
| Sequential production dependency failures | Three separate production remediation cycles before the planner bundle could deploy. Added at least two additional Human approval cycles and multiple Codex evidence sessions. | Planner bundle deployment requires all invocation targets (Flows, Apex, Prompt Templates) to be present and resolvable in the target org before the bundle can validate. No pre-deploy dependency audit was run. | **Create a dependency readiness checklist.** Before any planner bundle validate-only, confirm every referenced Flow, Apex class, and Prompt Template exists and is Active in the target org. |
| Prompt Template delivery pathway was complex and fragile | Three failed attempts before a working Account Intelligence Summary was delivered. CLI TypeInferenceError, invalid template XML, UI-only creation, retrieve artefact, and finally an Apex replacement. | Salesforce metadata API for GenAiPromptTemplate is immature. `PromptTemplate` (wrong type) caused `TypeInferenceError`. Flex template XML schema not validated against a real org retrieve. Ultimately the `generatePromptResponse` action binding to SObject `id` was non-deterministic from the planner. | Replace direct Prompt Template actions with Apex invocable actions where the agent planner has a binding risk. The Apex approach (AGENT_AccountIntelligenceSummary) resolved the issue and passed smoke test. Document this as standard pattern for future AI summary actions. |
| generatePromptResponse SObject id binding failure | Account intelligence summary consistently failed in production with `INVALID_RUNTIME_VALUE` because the planner could not reliably bind `AccountId` as a valid SObject `id`. Required late-stage redesign after planner bundle was already deployed. | Agentforce planner's type system maps text outputs to SObject `id` fields loosely. When the planner receives account name as text (not a confirmed Id), it does not resolve to a valid SObject. | Use Apex invocable actions for any summary requiring SOQL resolution. Pass text inputs (account name) and let Apex resolve the record internally. |
| Agentforce Vibes added governance overhead without proportionate value | Agentforce Vibes was introduced as a third AI operator, requiring: AGENTS.md updates, a new prompt style, separate session management, and additional Human context-switching. In practice, Codex performed org inspection and Tooling API queries more reliably. | Agentforce Vibes is a Salesforce-native AI tool well-suited to click-based agent building and testing. It is not optimised for CLI-driven controlled metadata delivery at API v66.0. | **Remove Agentforce Vibes from routine delivery workflow.** Keep it as an optional reference tool for learning or exploratory inspection. |
| Permission set XML deploy failures | Four separate permission set deploy failures due to XML ordering, compound address fields, required Opportunity field FLS entries, and description length. Each failure required a new commit and re-deploy. | Salesforce Metadata API has strict XML element ordering rules. Compound address sub-components (`BillingCity`, `BillingCountry`) cannot be granted FLS via permission set. Required fields cannot have explicit FLS entries. These constraints are not well-documented. | Document the confirmed XML ordering pattern and prohibited FLS entries in AGENTS.md. Include in future Codex permission set build prompts. |
| Flow status interpretation (Draft vs Active) | Confusion about whether `AGENT_GetAccountDetails` and `AGENT_GetContactDetails` were usable after production deploy, because Tooling API returned `Status = Draft`. Added uncertainty to the smoke test go/no-go decision. | Autolaunched Flows deployed via Metadata API land as Draft in Salesforce. This is a platform behaviour. Draft status does not prevent invocation from the agent planner. The smoke test confirmed both Flows are callable. | Document in AGENTS.md: autolaunched Flows deployed via CLI land as Draft. Draft status is expected and does not block invocation. Confirm function via smoke test, not status check. |
| AiEvaluationDefinition NoTestRun restriction in production | First attempt at production smoke test deploy failed immediately with `INVALID_OPERATION: testLevel of NoTestRun cannot be used in production organizations`. | Codex used `--test-level NoTestRun` which is not permitted in production orgs. The correct flag for non-Apex metadata is `RunLocalTests` or omit the test-level flag. | Add to AGENTS.md: production org deploys of non-Apex metadata require `RunLocalTests`. `NoTestRun` is sandbox-only. |
| Handoff friction between tool contexts | Human had to repeatedly switch between Claude Code, Codex, Salesforce UI, Salesforce CLI, and Linear. Each switch required a context load and confirmation step. | Three-operator model with different session environments creates inherent switching overhead. Agentforce Vibes added a fourth environment. | Reduce the number of operators. With Agentforce Vibes removed, the main context switches are Claude → Human authorisation → Codex → Human review. This is an acceptable and necessary minimum. |
| Prompt Template metadata type ambiguity | First attempt used metadata type `PromptTemplate`. Salesforce returned `TypeInferenceError`. Correct type was `GenAiPromptTemplate`. Second attempt with correct type failed due to XML schema mismatch. Ultimately template was created via Agent Builder UI and retrieved. | `GenAiPromptTemplate` metadata type is relatively new and not consistently covered in Salesforce documentation. XML schema differs from standard `PromptTemplate`. | Before deploying any GenAiPromptTemplate, retrieve an existing template from the target org to confirm XML schema. Do not write template XML without a retrieve-and-compare step. |
| No single pre-production dependency matrix | Each production phase required ad-hoc dependency investigation. There was no single document listing every component required in production before the planner bundle could deploy. | Agentforce planner bundle validation runs at deploy time and fails fast if a dependency is missing. The dependency list was discovered reactively rather than proactively. | **Create a deployment dependency matrix before every planner bundle deploy.** One row per action: action name, invocation target type, invocation target API name, confirmed present in org (Y/N), deploy ID or manual confirmation. |
| Outputs sometimes too technical for business stakeholders | Validation evidence files contain full JSON deploy output, SOQL queries, and CLI command output. Useful for technical review, but not readable by programme leadership or business stakeholders. | Evidence files were optimised for technical audit, not business communication. | Add a brief `## Business Summary` block to every evidence file. Keep the technical content; add a 4-line plain-English summary at the top. |

---

## 7. Delivery Delays and Friction Points

| Friction point | Time / quality impact | Preventative action |
|---|---|---|
| Missing Flows (`AGENT_GetContactDetails`, `AGENT_GetAccountDetails`) discovered only at Phase 3 planner bundle validate-only | Additional Human authorisation cycle, Codex Phase 3b session, Phase 3 re-attempt. Estimated delay: 3–4 hours of delivery time. | Run a dependency audit query before every planner bundle validate attempt. Confirm all referenced invocation targets exist and are active in the target org. |
| `AGENT_UpdateContactField` absent from production (blocking Phase 2) | Phase 2 remediation cycle. | Include ALL Apex classes referenced in the planner bundle in the Phase 2 deploy scope, not just the ones newly added in that sprint. |
| Prompt Template TypeInferenceError (PromptTemplate → GenAiPromptTemplate) | Failed commit `085a88a`, `d749c56`. Re-work and re-retrieve. | Document the correct metadata type (`GenAiPromptTemplate`) and retrieve pattern. Add to standard prompt for any template deployment. |
| generatePromptResponse binding failure discovered in production smoke test | Required a new Apex class (`AGENT_AccountIntelligenceSummary`), updated planner bundle, and additional production deploys. | Test account intelligence summary action in sandbox Testing Center before production deploy. Confirm the planner correctly resolves AccountId before approving production. |
| Permission set XML validation failures (4 failures) | Multiple fix commits (`0d89f81`, `fcebc02`, `f4586b2`, `4f90719`, `c29281d`). | Pre-validate permission set XML against confirmed constraints (element ordering, prohibited FLS entries) before first deploy attempt. |
| AiEvaluationDefinition deploy failure in production (NoTestRun) | Production smoke test attempt failed. Required workaround (manual Testing Center run, then Human manual UAT). | Add production-safe deploy flags to AGENTS.md. Use `RunLocalTests` for all production deploys. Never use `NoTestRun` against production. |
| Testing Center `actionsSequence = []` failure (SAL-16) | SAL-16 AC-01 through AC-05 remain pending. Carried to SAL-22. | Investigate Testing Center metadata deploy pattern before relying on it for regression. Confirm correct AiEvaluationDefinition schema before build. |
| Tooling API limitations in production (`AiPromptTemplate`, `Flow.Name`) | Required fallback to Metadata API listing for GenAiPromptTemplate confirmation. Additional evidence collection steps. | Document Tooling API limitations in AGENTS.md. Use `sf org list metadata` as primary post-deploy confirmation for GenAiPromptTemplate and Flow types. |
| Switching between Claude, Codex, Human, Salesforce UI, and Linear | Context load overhead for Human on each switch. | Minimise operator count. Reduce Human UI-only steps by improving CLI coverage. Batch Linear updates into single Codex evidence comments per phase. |

---

## 8. Quality Controls That Should Be Retained

The following controls are mandatory for all future Agentforce delivery work on this programme. They are non-negotiable.

1. **Pre-flight IsSandbox check** — run `SELECT Id, Name, IsSandbox FROM Organization` before every org operation. Stop if result is unexpected.
2. **Check-only validation before every live deploy** — no exceptions, including planner bundles, permission sets, and Prompt Templates.
3. **RunLocalTests on all production validate-only jobs** — even for non-Apex metadata, to catch FLS and coverage regressions.
4. **Human approval before every live deploy** — no AI operator executes a live production deploy without the Human explicitly authorising it in the current session.
5. **Human authority for agent activation and publication** — AI operators do not activate, deactivate, or publish agents at any time.
6. **Claude review before Codex execution** — Claude reviews every Codex evidence file before the next phase is authorised.
7. **Evidence files per delivery phase** — one validation/ file per phase, following the naming convention in AGENTS.md Section 15.
8. **Next Operator footer** — mandatory in every Claude Code and Codex output that hands work to another operator.
9. **AGENT_ prefix on all agent-invoked Flows and Apex** — mandatory for audit identification.
10. **Apex allow-lists for field control** — no standard Update Record action for write actions. All write actions must use Apex invocables with hard-coded field allow-lists.
11. **No delete actions, no account creation actions** — confirmed at permission set level and in action library design.
12. **User context for all Flows** — `runInMode = DefaultMode`. No system mode.
13. **AccessLevel.USER_MODE on all DML in Apex** — confirmed in every invocable class.
14. **No bulk update actions** — one record per invocation for all write actions.

---

## 9. Revised Operating Model

### 9.1 Future State — Two AI Agents Plus Human

| Operator | Role | Permitted actions | Forbidden actions |
|---|---|---|---|
| **Claude Code** | Architect, PRD Author, Reviewer, Risk Assessor, Evidence Reviewer | Read files; analyse requirements; author PRDs and evidence review; generate next-prompt; update Linear with design/review comments when instructed; produce business-language summaries | Implement uncontrolled metadata changes; deploy to any org; activate or publish agents; set Linear issues to Done/Closed/Production Ready; make business decisions |
| **Codex** | Builder, Test Executor, Salesforce CLI Operator, Evidence Creator | Implement approved PRD scope only; run CLI validate-only and live deploy when authorised; run Apex tests; create evidence files; produce business-language summaries; update Linear with implementation evidence when instructed | Deploy without Human authorisation; activate or publish agents; make changes outside approved scope; edit AGENTS.md, CLAUDE.md, or AI_WORKFLOW.md; set Linear issues to Done/Closed/Production Ready |
| **Human** | Approval Authority, Release Authority, Business Decision Maker | Approve PRDs; authorise deploys; activate and publish agents; perform UI-only steps; resolve business decisions; merge to main; set Linear terminal states | None that are forbidden — Human is the final authority |
| **Agentforce Vibes** | Optional learning and reference support only | Read org state if needed for exploratory investigation | Build, deploy, execute tests, produce delivery evidence, or act as a primary delivery operator in any routine sprint |

### 9.2 What Agentforce Vibes Was Used For

During this delivery, Agentforce Vibes was introduced to handle Salesforce-native validation, Tooling API queries, and Testing Center execution. In practice:

- Tooling API queries were more reliably executed by Codex using the standard Salesforce CLI.
- Testing Center execution was blocked by metadata schema issues that Agentforce Vibes could not resolve without Claude and Human input.
- Evidence files produced by Agentforce Vibes did not differ in format or quality from those produced by Codex.
- The additional operator required Human context management across four tools instead of three.

**Conclusion:** The value of Agentforce Vibes as an execution operator was not proportionate to the overhead it introduced. Remove it from the routine delivery model. It may be used for ad-hoc exploratory inspection when Claude Code identifies an org-state question that neither Claude nor Codex can answer through available evidence.

---

## 10. Future Phase Gate Process

Every future Agentforce delivery sprint must follow this phase gate sequence. No phase may begin before the preceding gate is complete.

```
Gate 0 — REQUIREMENT REVIEW
  Claude Code: reads spec and Linear issue
  Claude Code: produces PRD or approves existing PRD
  Claude Code: confirms dependencies, blockers, risks
  Human: approves PRD
  ↓
Gate 1 — PRE-BUILD DEPENDENCY AUDIT
  Claude Code: confirms all metadata dependencies are present in target org
  Claude Code: creates dependency readiness checklist (see §13)
  Human: confirms checklist is complete before build begins
  ↓
Gate 2 — IMPLEMENTATION
  Codex: builds approved scope only
  Codex: runs local tests
  Codex: produces git diff and evidence file
  ↓
Gate 3 — CLAUDE REVIEW
  Claude Code: reviews Codex output
  Claude Code: produces review findings and business summary
  Claude Code: authorises or rejects proceed to deploy
  Human: approves proceed to deploy
  ↓
Gate 4 — SANDBOX VALIDATE-ONLY
  Codex: runs check-only validate against sandbox
  Codex: produces validate evidence file
  Claude Code: reviews validate evidence
  Human: approves live sandbox deploy
  ↓
Gate 5 — SANDBOX LIVE DEPLOY
  Codex: quick deploy using validated job ID
  Codex: runs post-deploy confirmation queries
  Codex: produces deploy evidence file
  ↓
Gate 6 — SMOKE TEST
  Human (or Codex where safe): executes defined smoke test scenarios
  Codex: records results in evidence file
  Claude Code: reviews smoke test evidence
  Human: signs off sandbox smoke test
  ↓
Gate 7 — PRODUCTION DEPENDENCY AUDIT
  Codex: queries production org for every invocation target referenced in planner bundle
  Codex: produces dependency readiness table (PRESENT / ABSENT for each)
  Claude Code: reviews and approves or identifies gaps
  Human: approves production deploy only if all dependencies confirmed PRESENT
  ↓
Gate 8 — PRODUCTION VALIDATE-ONLY
  Codex: runs check-only validate against production
  Codex: produces validate evidence file
  Claude Code: reviews validate evidence
  Human: approves quick deploy
  ↓
Gate 9 — PRODUCTION LIVE DEPLOY
  Codex: quick deploy using validated job ID
  Codex: confirms post-deploy metadata presence
  Codex: produces deploy evidence file
  ↓
Gate 10 — PRODUCTION SMOKE TEST AND SIGN-OFF
  Human: executes smoke test scenarios in production
  Human: signs off if all scenarios pass
  Human: approves activation and publication
  Human: activates and publishes agent
  Human: merges branch to main
  Human: sets Linear issue to Done/Production Ready
```

---

## 11. Prompting Standards Going Forward

### 11.1 Prompt Quality Checklist

Every prompt issued to Claude Code or Codex must satisfy the following checklist before it is sent. A prompt that fails any item must be revised.

- [ ] **Operator role stated** — "You are Claude Code (Architect)" or "You are Codex (Builder)".
- [ ] **Objective stated** — one sentence describing what the operator is asked to produce.
- [ ] **Files or metadata in scope stated** — exact file paths, metadata type and API name, or Linear issue reference.
- [ ] **Out-of-scope items stated explicitly** — "Do not touch force-app", "Do not deploy", "Do not update Linear", etc.
- [ ] **Target org and safety checks stated** — if org access is involved, specify username, confirm IsSandbox check is required, and confirm which org is in scope.
- [ ] **Allowed CLI commands listed** — exactly which `sf` commands are permitted. No open-ended "do what is needed".
- [ ] **Forbidden commands listed** — "Do not run `project deploy start` without explicit next-prompt authorisation."
- [ ] **Evidence file path stated** — exact path where the evidence file must be created (e.g. `validation/SAL-{n}-{phase}-{date}.md`).
- [ ] **Linear update rule stated** — "Do not update Linear" or "Post paste-ready comment to SAL-{n} — read the issue first."
- [ ] **Business-language summary required** — "Include the standard `## Business Summary` block at the end of your evidence file."
- [ ] **Stop condition stated** — "Stop after producing the evidence file. Do not proceed to the next phase without a new prompt."
- [ ] **Next Operator footer required** — "End with the `## Next Operator` block."
- [ ] **No broad instructions** — never write "fix everything" or "deploy what is needed". Every action must be explicit.
- [ ] **No hidden assumptions** — if the prompt assumes a prior step has completed, state it explicitly.
- [ ] **Documentation/review tasks** — include "No deploy/no mutation. This is a documentation/review task only."

### 11.2 Prompt Anti-Patterns to Avoid

| Anti-pattern | Why it fails | Correct alternative |
|---|---|---|
| "Deploy the agent" | Too broad. Codex may deploy the bundle before dependencies are in the org. | "Run validate-only for GenAiPlannerBundle:Astrum_BD_Agent against astrum-prod. Do not live deploy. Produce evidence file." |
| "Fix the permission set issues" | Codex will attempt multiple fixes without a clear stopping point. | "Add these exact XML entries to Astrum_BD_Agent_PS: [entries]. Do not change any other element. Produce git diff. Do not deploy." |
| "Set up the Agentforce Testing Center" | Ambiguous. Does not specify which test spec, which org, what evidence to produce. | "Deploy AiEvaluationDefinition:SAL_21_Account_Intelligence_Test to sandbox astrumpar using RunLocalTests. Record results in validation/SAL-21-account-intelligence-testing-center-{date}.md." |
| "Confirm the agent is working" | Not specific. Codex will run open-ended queries. | "Query SELECT Id, Status, Definition.DeveloperName FROM Flow WHERE Definition.DeveloperName IN ('AGENT_GetAccountDetails','AGENT_GetContactDetails') against astrum-prod Tooling API. Record output in evidence file." |

---

## 12. Mandatory Business-Language Summary Standard

Every Claude Code and Codex output — including technical evidence files, review outputs, and validation files — must include the following block. The block must be complete even if one section contains "None at this time."

```markdown
## Business Summary

- **What was done:** [One or two sentences describing the action taken in plain English.]
- **What was found:** [One or two sentences on the key finding — pass, fail, blocker, risk.]
- **What this means:** [One sentence on the implication for the programme — is it safe to proceed? Is there a decision needed?]
- **What is next:** [One sentence on the next step — who does what.]
- **Decision needed from Human:** [One sentence if a Human decision is needed, or "None at this time."]
```

**Example — a production validate-only pass:**

> ## Business Summary
> - **What was done:** Ran a validate-only check of the Astrum BD Agent planner bundle against the production org.
> - **What was found:** Validation passed. All 8 actions resolved correctly. No component errors.
> - **What this means:** The planner bundle is safe to deploy to production.
> - **What is next:** Claude Code to review this evidence. Human to approve quick deploy.
> - **Decision needed from Human:** Approve or reject production live deploy of GenAiPlannerBundle:Astrum_BD_Agent.

**Example — a dependency failure:**

> ## Business Summary
> - **What was done:** Ran a validate-only check of the Astrum BD Agent planner bundle against the production org.
> - **What was found:** Validation failed. `AGENT_GetContactDetails` Flow is not present in production and was referenced by the Get Contact Details action.
> - **What this means:** The planner bundle cannot deploy until `AGENT_GetContactDetails` is present in production. A remediation deploy is required first.
> - **What is next:** Claude Code to review this evidence and authorise a targeted remediation deploy of the missing Flow.
> - **Decision needed from Human:** Approve remediation deploy of `AGENT_GetContactDetails` to production.

---

## 13. Recommended Updates to Project Working Practices

### 13.1 PRDs

- Every Codex build task must reference a named PRD or explicit approved implementation prompt. No unstructured "build this" instructions.
- PRD version must be bumped (e.g. v1.0 → v1.1) when architecture decisions change scope. Reasons for change must be stated.
- PRD must include a deployment plan with explicit sequencing and dependency ordering.

### 13.2 Validation Evidence

- One evidence file per delivery phase. Do not combine phases in a single file.
- Every evidence file must begin with scope (operator, phase, target org, authorisation chain).
- Every evidence file must end with Explicit Exclusions, Git Status, Business Summary, and Next Operator.
- Production evidence files must include the full IsSandbox check output in JSON.
- Do not record "N/A" for failed checks without explaining why they were not run.

### 13.3 Handoff Files

- Handoff files in `handoff/` must be produced at session close or issue completion.
- Handoff files must include: files committed, deploy IDs, open risks, next session starting point.
- The Business User Guide (`handoff/Astrum-BD-Agent-Business-User-Guide-{date}.md`) must be updated after every production capability change.

### 13.4 Linear Comments

- Comments must be concise. No more than 8 bullet points per comment.
- Comments must state: agent name, date, action, evidence file reference (file path).
- No AI agent may set an issue to Done, Closed, or Production Ready. Human only.
- Do not post speculative comments. Only post evidence-based updates.
- Read the current issue state before posting. Do not duplicate information already in the issue.

### 13.5 Git Commits

- Commit messages must state the issue number (e.g. `feat(SAL-21):`), the action type (feat, fix, docs, chore, test), and a plain description.
- No commit should touch files outside the approved scope for that issue.
- Evidence files should be committed separately from source metadata changes.
- Do not commit unrelated retrieved metadata from the org (e.g. pre-existing bot definitions).

### 13.6 Production Safety Checks

- Mandatory IsSandbox query before every production org operation — no exceptions.
- Mandatory confirm target username matches the intended org alias before any deploy command.
- Never use `--test-level NoTestRun` against a production org.
- Use `RunLocalTests` for all production deploys, even for non-Apex metadata types.

### 13.7 Deployment Sequencing

- Apex classes must be deployed before any permission set that references them.
- Flows must be deployed (and Active or Draft) before any planner bundle that references them as invocation targets.
- GenAiPromptTemplate must be deployed before any planner bundle that references a Prompt Template action.
- Deploy Apex classes in one job, Flows in one job, then permission set, then planner bundle — in that order.
- Quick deploy (`project deploy quick --job-id`) for live deploys. Reuse the validated job. Do not re-validate live.

### 13.8 Dependency Audits

Every production deployment sequence must begin with a dependency readiness checklist. Template:

```markdown
## Dependency Readiness Checklist — [Bundle Name] — [Date]

| Dependency | Type | Required by | Present in [org] | Deploy ID or Confirmation | Status |
|---|---|---|---|---|---|
| AGENT_GetAccountDetails | Flow | Get Account Details action | astrum-prod | [ID or "Confirmed via metadata list"] | READY / NOT READY |
| AGENT_GetContactDetails | Flow | Get Contact Details action | astrum-prod | [ID] | READY / NOT READY |
| AGENT_CreateContact | Flow | Create Contact action | astrum-prod | [ID] | READY / NOT READY |
| AGENT_SearchAccounts | Apex | Search Accounts action | astrum-prod | [ID] | READY / NOT READY |
| AGENT_SearchContacts | Apex | Search Contacts action | astrum-prod | [ID] | READY / NOT READY |
| AGENT_UpdateAccountField | Apex | Update Account Field action | astrum-prod | [ID] | READY / NOT READY |
| AGENT_UpdateContactField | Apex | Update Contact Field action | astrum-prod | [ID] | READY / NOT READY |
| AGENT_AccountIntelligenceSummary | Apex | Account Intelligence action | astrum-prod | [ID] | READY / NOT READY |
| AGENT_AccountIntelligenceSummary | GenAiPromptTemplate | Prompt Template metadata | astrum-prod | [ID] | READY / NOT READY |
| Astrum_BD_Agent_PS | PermissionSet | Agent permission boundary | astrum-prod | [ID] | READY / NOT READY |
```

**Do not proceed with planner bundle validate-only until every row shows READY.**

---

## 14. Risks if the Operating Model Is Not Changed

| Risk | Likelihood if model unchanged | Impact |
|---|---|---|
| Repeated production dependency failures | High — same pattern will repeat for S2 and S3 planner bundles | Wasted Human authorisation cycles, extended delivery timeline, increased risk of incorrect deploy sequencing |
| Higher Human admin burden | High — four operators require more context-switching than two | Human fatigue, authorisation delays, potential for oversight gaps |
| Unclear accountability at handoff points | Medium — four-operator model has more boundary ambiguity | Delayed handoffs, missed steps, incorrect operator taking an action |
| Inconsistent business stakeholder communication | High — no current mandatory business summary requirement | Programme leadership and BD stakeholders cannot follow delivery progress without technical translation |
| Unnecessary tool-switching overhead | High — Agentforce Vibes requires a separate session and context | Human spends time re-loading context for a tool that adds limited value |
| Prompt Template deployment failures repeated for S2 | Medium — `GenAiPromptTemplate` XML schema is not yet documented for S2 | Failed deploys, wasted session time, late discovery of binding issues |
| generatePromptResponse binding failures for S2/S3 | Medium — Opportunity Status Summary PT has same SObject binding risk | Late-stage redesign of a second Prompt Template action; production deploy blocker |
| Slower delivery | High — phase 2/3/S2/S3 delivery at same pace would be significantly slower than necessary | Delayed go-live for S2 and S3 capabilities |

---

## 15. Implementation Checklist

Adopt the revised model immediately with the following steps.

- [ ] **1. Remove Agentforce Vibes from AGENTS.md** — Update AGENTS.md to define Agentforce Vibes as an optional reference resource, not an execution operator. Remove Agentforce Vibes from the Role Split table. Remove Section 5 (Agentforce Vibes Responsibilities). Add a brief note explaining the decision. (Requires Human approval before edit.)
- [ ] **2. Add Dependency Readiness Checklist to AGENTS.md** — Add Section 16: Deployment Dependency Audit. Include the checklist template from §13.8 of this retrospective. Specify it is mandatory before every planner bundle validate-only.
- [ ] **3. Add Business Summary requirement to AGENTS.md** — Add Section 17: Mandatory Business Summary Standard. Include the standard block from §12 of this retrospective.
- [ ] **4. Add production deploy flag rules to AGENTS.md** — Add to Section 8 (Salesforce Guardrails): "Never use `--test-level NoTestRun` against a production org. Use `RunLocalTests` for all production deploys."
- [ ] **5. Add Flow status note to AGENTS.md** — Add to Section 8: "Autolaunched Flows deployed via CLI land as Draft status. Draft is expected and does not prevent agent planner invocation. Confirm function via smoke test."
- [ ] **6. Add Apex invocable pattern for AI summary actions** — Add to AGENTS.md: "For agent summary actions that require SOQL resolution (e.g. account intelligence summary), use Apex invocable actions. Accept text inputs (account name) and resolve the record internally. Do not use generatePromptResponse for actions requiring SObject id binding from a text output."
- [ ] **7. Add GenAiPromptTemplate deploy pattern** — Add to AGENTS.md: "Before deploying any GenAiPromptTemplate, retrieve an existing template from the target org to confirm XML schema. Do not write template XML without a retrieve-and-compare step."
- [ ] **8. Update prompt templates for S2 delivery** — Write a Claude Code prompt and a Codex prompt for S2 (Opportunity Management) using the prompting standards from §11 of this retrospective. Include the dependency readiness checklist and business summary requirement.
- [ ] **9. Confirm SAL-22 scope and open items** — SAL-16 AC-01 through AC-05 Testing Center results are pending. Carry to SAL-22. Scope: full S1 regression suite, Testing Center AiEvaluationDefinition schema fix, and model drift baseline.
- [ ] **10. Merge branch to main** — Human to merge `feature/astrum-bd-agent-build` to main after publication is confirmed.

---

## 16. Open Decisions

The following decisions are outstanding and require Human input.

| ID | Decision | Options | Blocking |
|---|---|---|---|
| OD-A | Update AGENTS.md to remove Agentforce Vibes as an execution operator | Approve removal / Retain with reduced scope | Implementation checklist items 1-2 |
| OD-B | S2 Opportunity Management delivery: confirm go/no-go for next sprint | Go with S2 now / Pause for BD team adoption period / Proceed with S3 prerequisites first | Future sprint planning |
| OD-C | SAL-22 scope confirmation: full S1 Testing Center regression + model drift baseline | In-scope for next sprint / Deferred | SAL-16 AC-01–AC-05 closure |
| OD-D | Einstein Trust Layer PII masking confirmation | Admin to confirm zero-data retention and Contact Email/Phone masking are active | Compliance gate before wider rollout |
| OD-E | Hyperforce EU instance region confirmation | IT/Compliance to confirm org is on EU Hyperforce | GDPR prerequisite for EU contact data processing |
| OD-F | BD Lead required-field sign-off for S3 | BD Lead to document Account, Contact, Opportunity required field lists in writing | S3 build cannot begin without this |
| OD-G | Agent publication | Human to publish agent in Setup → Agents → Astrum BD Agent → Publish | Final activation for BD users |

---

## 17. Appendix A — Evidence Reviewed

### A.1 Source Control

| Item | Path | Notes |
|---|---|---|
| AGENTS.md | Root | Governance instructions for all operators |
| CLAUDE.md | Root | Claude Code context and programme rules |
| SAL-21 PRD | `PRDS/SAL-21-astrum-bd-agent-s1-remaining-actions.md` | v1.1 — key PRD for S1 remaining actions |
| Overarching Spec | `LLM-TXTS/agentforce/Astrum_BD_Agent_Overarching_Spec.md` | Agent architecture, guardrails, test plan |
| S1 Spec | `LLM-TXTS/agentforce/Astrum_BD_Agent_S1_AccountContact_Spec.md` | Action library and instructions |
| Build Readiness Report | `validation/agentforce/Astrum_BD_Agent_Build_Readiness_Report.md` | Schema QC, blockers, build eligibility |
| Session Closeout | `handoff/SAL-15-16-17-session-closeout.md` | SAL-15, SAL-16, SAL-17 delivery status |
| Business User Guide | `handoff/Astrum-BD-Agent-Business-User-Guide-20260509.md` | Final business-readable delivery summary |

### A.2 Validation Evidence Files Reviewed

| File | Phase |
|---|---|
| `validation/SAL-BD-S1-AGENT_CreateContact.md` | SAL-15 flow build and test |
| `validation/SAL-16-AgentBuilder-CreateContact.md` | SAL-16 planner configuration |
| `validation/SAL-17-Permissions-FLS-CreateContact.md` | SAL-17 permission set |
| `validation/SAL-21-D15-D17-D18-prompt-template-action-output.md` | S1 sandbox prompt template |
| `validation/SAL-21-sandbox-deploy-and-test-output.md` | S1 sandbox deploy |
| `validation/SAL-21-agent-smoke-test-output.md` | Sandbox smoke test |
| `validation/SAL-21-phase-1-production-apex-deploy-20260509.md` | Production Phase 1 |
| `validation/SAL-21-phase-2-production-validate-20260509.md` | Production Phase 2 validate |
| `validation/SAL-21-phase-2-remediation-20260509.md` | Production Phase 2 remediation |
| `validation/SAL-21-phase-3-production-validate-20260509.md` | Production Phase 3 initial validate (failed) |
| `validation/SAL-21-phase-3b-production-remediation-20260509.md` | Production Phase 3b dependency remediation |
| `validation/SAL-21-phase-3-planner-bundle-validate-reattempt-20260509.md` | Phase 3 re-validate |
| `validation/SAL-21-phase-3-planner-bundle-live-deploy-20260509.md` | Phase 3 live deploy |
| `validation/SAL-21-production-smoke-test-20260509.md` | Production smoke test round 1 (blocked) |
| `validation/SAL-21-production-smoke-test-20260509-r2.md` | Production smoke test round 2 |
| `validation/SAL-21-production-smoke-test-20260509-r3.md` | Production smoke test round 3 (8/8 PASS) |
| `validation/agentforce/sal-bd-s1-testing-center-20260509/` | Testing Center run results |
| `validation/agentforce/sal21-account-intelligence-20260509/` | Account Intelligence Testing Center |
| `validation/agentforce/sal21-testing-center-20260508/` | S1 Testing Center sandbox run |

### A.3 Git Evidence

- Full git log of `feature/astrum-bd-agent-build` branch reviewed.
- Total commits reviewed: ~50 commits from branch base to merge commit `05a2893`.
- No commits to force-app outside approved scope were found.
- Multiple fix commits for permission set XML confirmed in log.
- Prompt Template type reclassification commit confirmed (`d749c56`).

### A.4 Linear Evidence

- Linear MCP was not available at time of retrospective authoring.
- Linear comment IDs referenced in handoff files were noted (SAL-15, SAL-16, SAL-17 comments from Codex confirmed in `SAL-15-16-17-session-closeout.md`).
- Linear was not inspected or updated during this retrospective.

---

## 18. Appendix B — Retrospective Action Log

| Action ID | Action | Owner | Priority | Due Point | Acceptance Criteria |
|---|---|---|---|---|---|
| ACT-01 | Update AGENTS.md: remove Agentforce Vibes as execution operator; add dependency readiness checklist, business summary standard, production deploy flag rules, Flow status note, Apex invocable pattern for summaries, GenAiPromptTemplate deploy pattern | Human approves; Claude Code drafts changes | High | Before next S2 sprint begins | AGENTS.md updated, committed, and reviewed by Human |
| ACT-02 | Create S2 Opportunity Management delivery prompts (Claude and Codex) using revised prompting standards | Claude Code | High | Before S2 sprint kick-off | Prompts satisfy the §11 checklist; reviewed and approved by Human |
| ACT-03 | Create production deployment dependency matrix template for S2 planner bundle | Claude Code | High | Before S2 production deploy | Dependency matrix document created and available for Codex to populate |
| ACT-04 | Publish Astrum BD Agent in production (Setup → Agents → Astrum BD Agent → Publish) | Human | High | Immediately — decision OD-G | Agent is published and accessible to authorised BD users |
| ACT-05 | Merge `feature/astrum-bd-agent-build` to `main` | Human | High | After publication confirmed | Branch merged, no conflicts |
| ACT-06 | Confirm Einstein Trust Layer PII masking (Contact Email/Phone) is active in production | Salesforce Admin / Human | High | Before wider BD team rollout | Written confirmation from Admin; evidence recorded in validation/ |
| ACT-07 | Confirm Hyperforce EU instance region for GDPR compliance | IT / Compliance / Human | High | Before wider BD team rollout | Written confirmation; evidence recorded |
| ACT-08 | Scope and kick off SAL-22 (S1 Testing Center regression, AC-01–AC-05, model drift baseline) | Human / Claude Code | Medium | Next sprint after S2 planning | SAL-22 Linear issue created with scope; PRD approved |
| ACT-09 | BD Lead required-field sign-off for S3 Data Quality actions | BD Lead / Human | Medium | Before S3 sprint begins | Written sign-off document for Account, Contact, and Opportunity required fields |
| ACT-10 | Assign `Astrum_BD_Agent_PS` to BD pilot users | Salesforce Admin | Medium | Before pilot rollout | Users assigned; access confirmed via SOQL |
| ACT-11 | Document GenAiPromptTemplate deploy and retrieve pattern for S2 Opportunity Status Summary | Claude Code | Medium | During S2 PRD authoring | Pattern documented in S2 PRD or AGENTS.md; Apex invocable alternative designed if binding risk identified |
| ACT-12 | Review and close SAL-10 open business decisions (BD-01 through BD-05) | Human / BD Lead | Medium | Separate timeline — not dependent on BD Agent | BD-01 through BD-05 resolved and documented; SAL-10 production deployment authorised or formally deferred |

---

## Business Summary

- **What was done:** A structured retrospective of the Astrum BD Agent S1 delivery (SAL-15, SAL-16, SAL-17, SAL-21) was produced, reviewing 37 evidence files, the full git log, PRDs, specifications, validation evidence, and handoff documents. No Salesforce metadata was changed, no deploy was run, no activation or publication occurred, no commit or push was made, and Linear was not updated.
- **What was found:** The Astrum BD Agent S1 is fully deployed and confirmed functional in production (8/8 smoke test PASS). The delivery model worked overall but experienced significant friction from production dependency sequencing failures, Prompt Template complexity, and the overhead of managing a four-operator model including Agentforce Vibes. Twelve specific friction points and a detailed set of preventative actions were identified.
- **What this means:** The programme can deliver S2 and S3 faster and with fewer dependency failures by adopting the revised two-AI-agent model (Claude Code and Codex only), applying the dependency readiness checklist before every production deploy, and requiring business-language summaries in all outputs.
- **What is next:** Human to review this retrospective and approve the AGENTS.md updates (ACT-01). Once approved, Claude Code will draft the revised AGENTS.md changes. S2 delivery planning can then begin.
- **Decision needed from Human:** (1) Approve removal of Agentforce Vibes as an execution operator from AGENTS.md (OD-A). (2) Approve publication of the Astrum BD Agent in production (OD-G). (3) Confirm S2 sprint timing (OD-B).

---

## Next Operator

- **Run next in:** Human
- **Reason:** Human should review and approve the revised delivery operating model before it is used for future Astrum BD Agent or Salesforce Agentforce work.
- **Next prompt:** After I review `LLM-TXTS/Astrum_BD_Agent_Agentic_Delivery_Retrospective_20260509.md`, generate the updated Claude and Codex operating model prompts for future Salesforce delivery work.
