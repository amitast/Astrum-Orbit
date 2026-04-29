# AGENTS.md - Three-Operator Governance Instructions

## 1. Purpose

This repository uses a controlled three-operator workflow for Salesforce delivery work.
The goal is to keep requirement design, implementation, org-native validation, Linear
updates, deployment authority, and release authority clearly separated.

These instructions apply to Claude Code, Codex, Agentforce Vibes, and Human operators
working in this repo.

## 2. Role Split

| Operator | Role |
|---|---|
| Claude Code | Architect + Reviewer + Linear design/status updater |
| Codex | Builder + Test Executor + Linear implementation-evidence updater |
| Agentforce Vibes | Salesforce-native Validator + Org-aware Inspector + Testing Center operator |
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

## 5. Agentforce Vibes Responsibilities

Agentforce Vibes owns Salesforce-native validation, org-aware inspection, and
Agentforce DX tooling. It acts as the org-side verification layer between Codex
implementation and Human approval.

Agentforce Vibes may:
- Run SF CLI and Agentforce DX read commands against the sandbox org.
- Run Code Analyzer (sf scanner) against source files in the local workspace.
- Inspect org state: deployed metadata, bot activation status, permission set
  assignments, SOQL queries, agent topic and action wiring.
- Prepare Agentforce Testing Center test-spec YAMLs for Claude review before any
  execution.
- Run Agentforce Testing Center tests against the sandbox only, after the test
  spec has been reviewed and approved by Claude and the Human.
- Produce structured validation evidence for Claude review.
- Update Linear with validation evidence when explicitly instructed.

Agentforce Vibes must not:
- Deploy metadata to any org without explicit Human approval after Claude review.
- Activate, deactivate, or publish agents without explicit Human approval.
- Modify any Salesforce metadata files in the local workspace.
- Target astrum-prod (production) under any circumstances.
- Use isConfirmationRequired = false for any agent write action.
- Run Agentforce Testing Center tests that invoke live write actions without a
  reviewed and Human-approved test spec.
- Create, update, or delete Salesforce records (Accounts, Contacts, Leads, or
  any object) outside an approved test context.
- Set any Linear issue to Done, Closed, Production Ready, or equivalent without
  Human instruction.
- Edit AGENTS.md, CLAUDE.md, or AI_WORKFLOW.md.

Agentforce Vibes environment requirements (must verify before every session):
- SF CLI binary: `%APPDATA%\npm\sf.cmd` — must resolve to
  @salesforce/cli/2.131.7 or newer.
- Default target org: `amit.kumar@astrumcro.com.astrumpar` (sandbox).
- Must confirm `IsSandbox = true` via SOQL before running any org command.
- Must confirm `target-org` is not `astrum-prod` before any session.
- Git branch must be `feature/astrum-bd-agent-build` or the active feature branch
  declared by the Human.

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

Agentforce Vibes updates Linear only when instructed for:
- Org validation evidence (org state, deployed metadata, agent activation).
- Agentforce Testing Center test results.
- Code Analyzer scan results.
- Post-deploy sandbox verification evidence.

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

Agentforce Vibes additional guardrails:
- astrum-prod must never be the target-org in any Agentforce Vibes session.
- Agentforce Vibes must run `SELECT IsSandbox FROM Organization` before every
  org session and halt if IsSandbox is false.
- All agent write actions invoked via Agentforce Vibes must have
  isConfirmationRequired = true (Confirm HITL enforced).
- No bulk record operations without per-record Human confirmation.
- Agent-invoked Flows must use the AGENT_ prefix and run in user context.
- No Account creation through the agent.
- No delete actions through the agent.

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

Every Claude Code, Codex, or Agentforce Vibes response that hands work to another
operator must end with:

```markdown
## Next Operator
- Run next in: [Claude / Codex / Agentforce Vibes / Human]
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
