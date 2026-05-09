# SAL-21 D-15 / D-17 / D-18 Prompt Template Action Output

## 1. Date/time

2026-05-08T16:19:47.5014332+01:00

## 2. Branch and commit before execution

- Branch: `feature/astrum-bd-agent-build`
- Working tree before execution: clean
- Recent commits before execution:
  - `85d5556 test(SAL-21): add Agentforce runtime smoke test evidence`
  - `433d304 test(SAL-21): record Astrum BD Agent smoke test evidence`
  - `e9296bb chore(SAL-21): retrieve valid Account Intelligence prompt template metadata`

## 3. Sandbox safety evidence

Command:

```powershell
sf data query --query "SELECT Id, Name, IsSandbox, InstanceName FROM Organization LIMIT 1" --target-org amit.kumar@astrumcro.com.astrumpar --json
```

Result:

- Org Id: `00DUD000007zF692AE`
- Org Name: `ASTRUM CRO, SL`
- IsSandbox: `true`
- InstanceName: `SWE92S`

Command:

```powershell
sf org display --target-org amit.kumar@astrumcro.com.astrumpar --json
```

Result:

- Username: `amit.kumar@astrumcro.com.astrumpar`
- Instance URL: `https://astrum--astrumpar.sandbox.my.salesforce.com`
- Connected status: `Connected`
- Target is not `astrum-prod`
- Sensitive access token was not recorded in this evidence file.

## 4. D-15 deploy evidence

Pre-deploy inspection:

- Root type: `GenAiPromptTemplate`
- Status: `Draft`
- Definition: `SOBJECT://Account`
- Visibility: `Global`
- `primaryModel`: present, `sfdc_ai__DefaultGPT5Mini`
- `versionIdentifier`: present
- Deprecated schema elements absent:
  - `activeVersionNumber`
  - `promptTemplateVersions`
  - `templateBody`
  - `templateInputs`
  - `versionNumber`
- Prompt Template inputs: Account SObject only.
- Contact `Email`, `Phone`, and `MobilePhone` are not included as Prompt Template inputs.
- Raw D365 notes, Account `Description`, and long text migration fields are not included as Prompt Template inputs.

Deploy command:

```powershell
sf project deploy start --source-dir force-app/main/default/genAiPromptTemplates/AGENT_AccountIntelligenceSummary.genAiPromptTemplate-meta.xml --target-org amit.kumar@astrumcro.com.astrumpar --json
```

Deploy result:

- Deploy ID: `0AfUD00000GyM9J0AV`
- Status: `Succeeded`
- Success: `true`
- Completed date: `2026-05-08T15:18:25.000Z`
- Components deployed: 1
- Component: `GenAiPromptTemplate / AGENT_AccountIntelligenceSummary`
- Component file: `genAiPromptTemplates/AGENT_AccountIntelligenceSummary.genAiPromptTemplate`
- Component errors: 0
- Test errors: 0
- Tests run: 0
- Warnings: none

Deploy report command:

```powershell
sf project deploy report --job-id 0AfUD00000GyM9J0AV --target-org amit.kumar@astrumcro.com.astrumpar --json
```

Deploy report result:

- Status: `Succeeded`
- Success: `true`
- Component errors: 0
- Test errors: 0
- Component success: `GenAiPromptTemplate / AGENT_AccountIntelligenceSummary`

Read-only post-deploy inspection observation:

- Tooling API query against `GenAiPromptTemplate` returned `INVALID_TYPE`, so the prompt template could not be verified through SOQL/Tooling API in this org.
- The deployed source remains `Draft`; no activation command was run.

## 5. D-17 configuration evidence

Status: `BLOCKED`

Method discovery performed:

```powershell
sf --version
sf agent --help
sf agent preview --help
sf agent preview start --help
sf project retrieve start --help
sf project deploy start --help
```

CLI version:

- `@salesforce/cli/2.133.4 win32-x64 node-v24.15.0`

Discovery result:

- `sf agent` supports generate, preview, publish, activate, deactivate, validate, create, and test workflows.
- No supported CLI command was found to add/configure a Prompt Template Action into an existing Agent Builder topic.
- Local bundle inspection found `Account_and_Contact_Management` with 7 existing S1 local actions.
- Existing retrieved local actions are represented with `invocationTargetType` values of `flow` or `apex`.
- No existing repo-retrieved Prompt Template Action representation was found that proves a safe metadata format for Action 8.

Action 8 configuration:

- Action 8 configured: No
- Reason: Codex has no supported CLI/metadata path proven for safely configuring the Agent Builder Prompt Template Action, and the prompt prohibited speculative planner bundle edits.
- Required next step: Human must configure Action 8 in Agent Builder UI, or provide an approved supported command/metadata representation from org-retrieved output.

All 8 S1 actions visibility:

- Not verified.
- Human UI confirmation required after Action 8 is configured.

Runtime smoke check:

- Not run.
- Reason: D-17 Action 8 configuration was not completed.

## 6. D-18 retrieve evidence

Status: `Not run`

Reason:

- The approved prompt permits D-18 GenAiPlannerBundle retrieval only if D-17 was completed.
- D-17 is blocked as UI-required / unsupported by available CLI or proven metadata path.

Files changed:

- `validation/SAL-21-D15-D17-D18-prompt-template-action-output.md`

Diff summary:

- Evidence file added.
- No GenAiPlannerBundle retrieval occurred.
- No planner bundle metadata changed.

## 7. Guardrail confirmation

- Production touched: No
- Prompt Template activated: No
- Prompt Template content changed: No
- Primary model changed: No
- Apex modified: No
- Flow modified: No
- Permission set modified: No
- Planner bundle deployed: No
- Git staged: No
- Git committed: No
- Git pushed: No
- Linear updated: No
- D-15 deploy scope: GenAiPromptTemplate file only
- D-17 speculative metadata edit: Not performed

## 8. Blockers / observations

- D-17 is blocked because no supported CLI command or proven retrieved metadata format was available to configure the Agent Builder Prompt Template Action.
- Human UI configuration in Agent Builder is required unless Claude/Human provides a supported metadata representation or command path.
- D-18 was not run because D-17 was not completed.
- Pre-activation observations still apply:
  - Prompt text references some unbound fields.
  - Final model choice requires Human / Architect approval before activation.

## 9. Recommended next operator

Claude Code should review this D-15 result and D-17 blocker, then prepare Human UI instructions or approve a supported metadata/CLI path if one is available.
