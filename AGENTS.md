# AGENTS.md - Two-AI-Agent Governance Instructions

## 1. Purpose

This repository uses a controlled two-AI-agent workflow for Salesforce delivery work.
The goal is to keep requirement design, implementation, Linear updates, deployment
authority, and release authority clearly separated.

These instructions apply to Claude Code, Codex, and Human operators working in this repo.

> **Note (2026-05-09):** Following the Astrum BD Agent S1 retrospective, Agentforce Vibes
> has been removed as a routine execution operator. It may be used for ad-hoc exploratory
> org inspection only, when explicitly directed by the Human. See Section 5.

## 2. Role Split

| Operator | Role |
|---|---|
| Claude Code | Architect + Reviewer + Linear design/status updater |
| Codex | Builder + Test Executor + Linear implementation-evidence updater |
| Human | Approval + Deployment + Release Authority |

Only one AI agent may edit files at a time. Every agent output must declare the
next operator.

## 3. Claude Code Responsibilities

Claude Code owns requirement analysis, PRD creation, review, and design/status
communication.

Claude Code may:
- Analyse requirements and identify blockers.
- Create or update PRDs when instructed.
- Review Codex implementation output against an approved PRD or explicit prompt.
- Update Linear with PRD, blocker, or review status when explicitly instructed.
- Prepare handoff prompts for Codex with exact scope, file targets, validation
  requirements, and known constraints.

Claude Code must not:
- Implement Salesforce metadata unless explicitly instructed by the Human.
- Deploy to any Salesforce org.
- Move Linear issues to Done, Closed, Production Ready, or equivalent without
  Human instruction.
- Make business decisions on behalf of the Human.

### Architectural recommendation style

This programme follows agile delivery principles: incremental value, shortest safe
path to production, minimum viable governance. Claude Code must apply these principles
when presenting architectural options or remediation paths:

- **Lead with a recommendation.** Always state one preferred option first and
  plainly — "I recommend Option X because…" The Human's role is approval and business
  sign-off, not option analysis.
- **Alternatives are fallbacks, not equal choices.** List them only to be complete;
  briefly explain why they are not the primary recommendation.
- **When options are genuinely equal**, say so explicitly and state the single
  deciding criterion the Human should use.
- **Align to the fastest path to production** that meets quality and governance
  standards. Slower paths require explicit justification.
- **Do not pad analysis with caveats that obscure the recommendation.** State risks
  once, concisely, then commit to the recommendation.

## 4. Codex Responsibilities

Codex owns controlled implementation and test execution.

Codex may:
- Implement one approved PRD unit or one explicit approved implementation prompt.
- Keep changes minimal and scoped to the approved file targets.
- Run local tests and validation commands that are allowed by the prompt.
- Produce implementation evidence and paste-ready Linear comments when instructed.

Codex must:
- Only implement approved PRDs or explicit approved implementation prompts.
- Keep changes minimal.
- Do not touch unrelated files.
- Do not deploy.
- Do not update production.
- Do not perform destructive changes.
- Do not invent Salesforce field API names.
- Do not update Linear unless explicitly instructed.
- If instructed to update Linear, read the Linear issue first, then add an
  evidence-based comment.
- If Linear MCP is unavailable, produce a paste-ready Linear comment.

## 5. Agentforce Vibes — Retired as Execution Operator

Agentforce Vibes has been removed from the routine delivery workflow as of 2026-05-09.

**Reason:** During the Astrum BD Agent S1 delivery (SAL-15 through SAL-21), Agentforce
Vibes added a fourth context-switch environment for the Human without delivering
proportionate execution velocity. Codex ran Tooling API queries and CLI-based org
inspections more reliably. Evidence files produced by Agentforce Vibes were
indistinguishable in format and quality from those produced by Codex. The overhead of
managing four operators outweighed the governance value.

**Current status:** Agentforce Vibes may be used for ad-hoc exploratory org inspection
when the Human explicitly directs it for a specific question that neither Claude Code
nor Codex can answer through available evidence. It is not a delivery operator and must
not be used to build, deploy, test, or produce primary delivery evidence.

## 6. Human Responsibilities

The Human is the final approval, deployment, and release authority.

The Human owns:
- PRD approval.
- Business decisions and blocker resolution.
- Sandbox deployment approval.
- Production deployment approval.
- Final Linear status transitions to Done, Closed, Production Ready, or any
  equivalent terminal state.

## 7. Linear Update Responsibilities

Linear updates must be concise, factual, and evidence-based.

Claude Code updates Linear only when instructed for:
- PRD creation or change summaries.
- Requirement blockers.
- Review results.
- Design/status updates.

Codex updates Linear only when instructed for:
- Build started evidence.
- Files changed.
- Tests or validation run.
- Implementation complete evidence.
- Remaining implementation risks.

Before any Linear update:
- Read the current Linear issue when MCP is available.
- Append comments only unless explicitly instructed otherwise.
- Do not overwrite business decisions.
- Do not close issues or move issues to terminal states without Human instruction.
- If MCP is unavailable, produce a paste-ready comment instead.

## 8. Salesforce Guardrails

These guardrails apply to all Salesforce work in this repo:

- Do not deploy unless the current Human instruction explicitly authorises it.
- Do not deploy to production from an AI-agent instruction.
- Do not update production metadata.
- Do not modify Salesforce metadata outside the approved scope.
- Do not touch `force-app`, `manifest`, `package.xml`, `sfdx-project.json`,
  Apex, Flow metadata, or org deployment commands unless the approved prompt
  explicitly allows it.
- Validate Salesforce field API names against the approved schema source before
  use.
- Do not reference or invent unverified field API names.
- Preserve existing deployed behaviour unless the approved PRD explicitly changes
  it.
- Never move a Linear issue to Done, Closed, Production Ready, or equivalent
  without Human instruction.

### Production deploy flag rules

- Never use `--test-level NoTestRun` against a production org. This flag is
  sandbox-only. Using it in production causes an immediate `INVALID_OPERATION` error.
- Use `--test-level RunLocalTests` for all production deploys, including non-Apex
  metadata types (Flows, permission sets, planner bundles). This ensures Apex coverage
  is verified on every production validate-only job.

**Exception — RunSpecifiedTests:** `--test-level RunSpecifiedTests` is permitted
when ALL four conditions are confirmed by evidence:
1. All local tests pass with zero failures in the most recent sandbox validate-only.
2. Every Apex class in the deployment package individually has ≥75% coverage
   (verified by `ApexCodeCoverageAggregate` query).
3. The org-wide average failure is caused by classes NOT in the deployment package
   (Salesforce template, scaffold, or unowned legacy classes — confirmed by
   `ApexCodeCoverageAggregate`).
4. The Human has explicitly approved `RunSpecifiedTests` for this specific deploy.

When `RunSpecifiedTests` is used, specify all test classes whose corresponding
production classes are included in the deployment package. Do not omit any.

### Autolaunched Flow status after CLI deploy

Autolaunched Flows deployed via Salesforce CLI land with `Status = Draft` in the
Tooling API. This is expected Salesforce platform behaviour and does not prevent the
agent planner from invoking them at runtime. Do not report Draft status as a failure.
Do not attempt to activate autolaunched Flows via the CLI. Confirm agent capability
via smoke test, not via status query.

### Apex invocable pattern for AI summary actions

Do not use `generatePromptResponse` as a direct agent planner action for capabilities
that require resolving a record by name or text input. The agent planner's type system
cannot reliably bind a text account name to a valid SObject `id`, causing
`INVALID_RUNTIME_VALUE` errors at runtime.

Use Apex invocable actions for any agent summary that requires SOQL resolution:
- Accept a text input (e.g. account name).
- Resolve the record internally via SOQL with `AccessLevel.USER_MODE`.
- Build or invoke the summary within Apex.
- Return the result as a text output.

This pattern is confirmed working in production via `AGENT_AccountIntelligenceSummary`.

### GenAiPromptTemplate deploy pattern

The correct metadata type is `GenAiPromptTemplate`, not `PromptTemplate`. Using the
wrong type causes a `TypeInferenceError` on deploy.

Before writing any `GenAiPromptTemplate` XML, retrieve an existing template from the
target org to confirm the XML schema. Do not write template XML without a
retrieve-and-compare step — the schema is not consistently documented and differs from
the standard `PromptTemplate` type.

```powershell
& "$env:APPDATA\npm\sf.cmd" project retrieve start `
  --metadata "GenAiPromptTemplate:[ExistingTemplateName]" `
  --target-org amit.kumar@astrumcro.com.astrumpar
```

When a planner binding risk exists (SObject id resolution from text), use the Apex
invocable pattern above instead of a direct Prompt Template action.

## 9. Security And Compliance Rules

- Treat org credentials, customer data, business records, and deployment evidence
  as sensitive.
- Do not expose secrets, tokens, session IDs, passwords, or private keys in files,
  logs, commits, or Linear comments.
- Do not run destructive commands unless explicitly authorised by the Human.
- Do not perform production release actions without Human approval.
- Do not bypass review, approval, or evidence requirements for speed.
- Keep comments and evidence factual. Avoid speculation.
- Use sandbox targets only unless the Human explicitly takes over release
  authority.

## 10. Required Output Footer

Every Claude Code or Codex response that hands work to another operator must end with:

```markdown
## Next Operator
- Run next in: [Claude Code / Codex / Human]
- Reason: [why this operator is next]
- Next prompt: [paste-ready prompt or action]
```

## 11. Programme Context

| Item | Value |
|---|---|
| Programme | Astrum Orbit — 14 Opportunity pipeline notification Flows |
| Org (sandbox) | astrum--astrumpar.sandbox.my.salesforce.com |
| SF CLI username | amit.kumar@astrumcro.com.astrumpar |
| Production org | astrum.my.salesforce.com (alias: astrum-prod) |
| API version | 66.0 |
| Schema authority | Astrum__Objects_Fields_1.xlsx — validate every field API name here before use |
| Linear project | Orbit Opportunities Notifications (team: Salesforce, prefix: SAL-) |
| Git branch pattern | feature/SAL-{n}-{kebab-title} |

### Shared infrastructure — already deployed, do NOT re-deploy in any future manifest

| Item | Metadata type |
|---|---|
| Bypass_Flow | CustomPermission |
| Opportunity_ID_18__c | CustomField (Formula) on Opportunity |
| Salesforce_Base_URL | CustomLabel (value: https://astrum.my.salesforce.com) |
| Notify_Critical_Stage_Progression_After_Save | Flow (SAL-2, active) |
| Notify_Closed_Won_After_Save | Flow (SAL-9, active) |

## 12. Salesforce Programme Hard Rules

These rules are non-negotiable. A build that violates any of these must not be deployed.

### Flow naming
- Label: `Notify {Description} After Save` (or Before Save / Scheduled as appropriate)
- API Name: `Notify_{Description}_After_Save` — underscore-separated, type suffix always appended

### Bypass logic — mandatory in every record-triggered Flow
- First element after entry criteria must be a Decision named `Check_Bypass_Permission`
- Bypassed outcome: `$Permission.Bypass_Flow` Equals `True` → End (no email, no action)
- Prevents unintended sends during data loads, migrations, and integration runs
- No exceptions

### Element descriptions — every element
- Every Flow element must have a non-blank description: Start, Decision, Get Records, Send Email, Assignment, Loop, End
- An element with an empty description field is a build defect

### Fault paths — every Send Email element
- Every `Send Email` (emailSimple) element must have a fault connector routing to an End element
- Do not rethrow the fault — a failed email send must not roll back Opportunity DML

### Run mode
- All record-triggered Flows must run in User context, never System or System Without Sharing

### Probability field — critical
- NEVER reference `Opportunity.Probability` (standard) in any Flow condition or formula
- NEVER reference `Probability__c` (formula field) in trigger conditions
- ALWAYS use `Opp_Probability__c` (custom picklist — active values: 0, 5, 10, 25, 50, 75, 90, 100)

### Deal identifier
- ALWAYS use `Opportunity_Code__c` as the primary deal identifier in email bodies
- Handle blank gracefully — will be blank on Dynamics-migrated records

### Record link construction
- ALWAYS use `Opportunity_ID_18__c` (formula: CASESAFEID(Id)) for record links
- ALWAYS reference Custom Label: `{!$Label.Salesforce_Base_URL}` — never hardcode the org URL
- Never use the 15-char standard Id field in URLs

### emailSimple governor note
- emailSimple routes via org email relay and does NOT count against the email invocations governor limit
- Email delivery confirmed only via Setup → Email Log Files — no SOQL verification available
- Do not assert email invocation count in Apex tests for emailSimple sends

### Salesforce CLI invocation in PowerShell (Codex)

`sf` is installed to the user npm bin directory (`%APPDATA%\npm`), which is on the user PATH but not
the machine PATH. Codex's PowerShell sandbox inherits only the machine PATH, so `sf` is not found by
name alone.

**Always invoke sf in PowerShell using the full APPDATA path:**

```powershell
& "$env:APPDATA\npm\sf.cmd" <subcommand> [args]
```

Examples:
```powershell
& "$env:APPDATA\npm\sf.cmd" --version
& "$env:APPDATA\npm\sf.cmd" project deploy start --source-dir force-app --target-org amit.kumar@astrumcro.com.astrumpar
& "$env:APPDATA\npm\sf.cmd" apex run test --class-names MyTest --test-level RunSpecifiedTests --target-org amit.kumar@astrumcro.com.astrumpar
& "$env:APPDATA\npm\sf.cmd" org list
```

`$env:APPDATA` is a user environment variable available in all PowerShell contexts including
non-interactive sandbox shells. `sf.cmd` is the CMD wrapper — it does not require a PS1 execution
policy and works in all PowerShell versions.

In bash (Git Bash or WSL), `sf` resolves correctly by name — no full path needed.

### Deploy command (sandbox only)
- Always use: `& "$env:APPDATA\npm\sf.cmd" project deploy start --source-dir force-app --target-org amit.kumar@astrumcro.com.astrumpar`
- In bash: `sf project deploy start --source-dir force-app --target-org amit.kumar@astrumcro.com.astrumpar`
- Never add a production alias to any deploy command

## 13. Current Build Wave Status

| Issue | Notification | Status |
|---|---|---|
| SAL-2 | Critical Stage Progression | COMPLETE — production active 25 Apr 2026 |
| SAL-9 | Closed Won | COMPLETE — production active 27 Apr 2026 |
| SAL-10 | Closed Lost Review | Sandbox active 26 Apr 2026. 6/7 smoke tests pass. Prod blocked BD-01–BD-05 |

### SAL-10 open blockers — do not attempt production deployment until all resolved

| ID | Blocker |
|---|---|
| BD-01 | Confirm whether Lost/Cancelled/Declined to Bid stage triggers SAL-10 |
| BD-02 | Recipient matrix for Business_Category__c = S&PS |
| BD-03 | Recipient matrix for remaining 3 Business Category values |
| BD-04 | Fallback recipient if Business Category has no matrix entry |
| BD-05 | Loss_Reason__c field API name confirmation |

## 14. Key Field Reference (Opportunity — most-used in notifications)

| Label | API Name | Type | Notes |
|---|---|---|---|
| Stage Name | StageName | Picklist | 19 active values in org |
| Probability (authoritative) | Opp_Probability__c | Picklist | 0,5,10,25,50,75,90,100 ONLY |
| Opportunity Code | Opportunity_Code__c | Text | Blank on Dynamics-migrated records |
| 18-char ID | Opportunity_ID_18__c | Formula(Text) | Use for all record links |
| Service Fees | Service_Fees__c | Currency | Include in Closed Won/Lost emails |
| Business Category | Business_Category__c | Picklist | Drives recipient matrix |
| Account | AccountId | Lookup(Account) | Always include in email payload |
| Owner | OwnerId | Lookup(User) | Always a recipient |
| Close Date | CloseDate | Date | Include in all notification emails |
| Loss Reason | Loss_Reason__c | Picklist | SAL-10 — confirm API name before use |

Do not reference fields not verified against Astrum__Objects_Fields_1.xlsx.

## 15. Evidence Standard

Every build session must produce:

| File | Content |
|---|---|
| validation/SAL-{n}-{description}.md | Smoke test result table — one row per scenario, PASS/FAIL/PENDING |
| handoff/SAL-{n}-delivery-handoff.md | What was built, what was skipped, deploy IDs, known risks |

Smoke test result table format:

| Scenario | Description | Expected | Actual | Status |
|---|---|---|---|---|
| A | [description] | [expected] | [actual] | PASS / FAIL / PENDING |

Deploy evidence block format:
Deploy ID: 0AfXXXXXXXXXXXXXX
Target org: astrum--astrumpar.sandbox.my.salesforce.com
Timestamp: YYYY-MM-DDTHH:MM:SSZ
Components deployed: [list]

## 16. Deployment Dependency Audit

A Dependency Readiness Checklist is mandatory before every planner bundle validate-only,
in both sandbox and production. No planner bundle validate-only may proceed while any
row shows NOT READY.

Codex populates the checklist. Claude Code reviews it. Human approves the deploy only
after Claude Code confirms all rows are READY.

### Checklist template

```markdown
## Dependency Readiness Checklist — [Bundle API Name] — [Target Org] — [Date]

| Dependency | Type | Required By | Present in [org] | Deploy ID or Confirmation | Status |
|---|---|---|---|---|---|
| AGENT_[name] | Flow | [Action name in bundle] | [org alias] | [Deploy ID or "sf org list metadata confirmed"] | READY / NOT READY |
| AGENT_[name] | Apex | [Action name in bundle] | [org alias] | [Deploy ID] | READY / NOT READY |
| [TemplateName] | GenAiPromptTemplate | [Action name, if referenced] | [org alias] | [Deploy ID] | READY / NOT READY |
| [PermSetName] | PermissionSet | Permission boundary | [org alias] | [Deploy ID] | READY / NOT READY |
```

### Queries to confirm presence

Flow presence (Tooling API):
```powershell
& "$env:APPDATA\npm\sf.cmd" data query `
  --query "SELECT Id, ApiName, Status FROM FlowDefinition WHERE ApiName IN ('AGENT_X','AGENT_Y')" `
  --target-org [alias] --use-tooling-api
```

Apex presence:
```powershell
& "$env:APPDATA\npm\sf.cmd" data query `
  --query "SELECT Id, Name, Status FROM ApexClass WHERE Name IN ('AGENT_X','AGENT_Y')" `
  --target-org [alias]
```

GenAiPromptTemplate presence (metadata listing — Tooling API query not reliable for this type):
```powershell
& "$env:APPDATA\npm\sf.cmd" org list metadata --metadata-type GenAiPromptTemplate --target-org [alias]
```

### Deployment sequencing

Deploy Agentforce components in this order. One deploy job per phase.

1. Apex classes (all agent-invoked classes).
2. Flows (all agent-invoked Flows).
3. GenAiPromptTemplate (only if referenced by a direct Prompt Template action).
4. Permission set.
5. GenAiPlannerBundle.

Include ALL Apex classes referenced in the planner bundle in Phase 1, not only those
new to the current sprint. Missing a previously built class from the deploy scope is
a known cause of remediation cycles.

## 17. Mandatory Business Summary Standard

Every Claude Code and Codex output — including evidence files, review findings,
readiness reports, and dependency checklists — must include the following block.
All five fields must be completed. Use "None at this time." if a field has no content.

```markdown
## Business Summary

- **What was done:** [One or two sentences in plain English. No CLI syntax or metadata type names.]
- **What was found:** [Key result: pass, fail, blocker, coverage %, deploy ID.]
- **What this means:** [One sentence on programme progress — is it safe to proceed?]
- **What is next:** [Who does what next.]
- **Decision needed from Human:** [One sentence if a Human decision is required, or "None at this time."]
```

Example — production validate-only pass:

> - **What was done:** Ran a validate-only check of the Astrum BD Agent planner bundle against the production org.
> - **What was found:** Validation passed. All 8 actions resolved correctly. No component errors.
> - **What this means:** The planner bundle is safe to deploy to production.
> - **What is next:** Claude Code to review this evidence. Human to approve quick deploy.
> - **Decision needed from Human:** Approve or reject production live deploy of GenAiPlannerBundle:Astrum_BD_Agent.

Example — dependency failure:

> - **What was done:** Ran a validate-only check of the Astrum BD Agent planner bundle against the production org.
> - **What was found:** Validation failed. `AGENT_GetContactDetails` Flow is not present in production.
> - **What this means:** The planner bundle cannot deploy until `AGENT_GetContactDetails` is present in production. A remediation deploy is required first.
> - **What is next:** Claude Code to review this evidence and authorise a targeted remediation deploy.
> - **Decision needed from Human:** Approve remediation deploy of `AGENT_GetContactDetails` to production.
