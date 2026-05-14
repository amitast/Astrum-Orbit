# S2 Opportunity Management Validation - 2026-05-14

| Field | Value |
|---|---|
| Programme | Astrum Orbit |
| Workstream | Astrum BD Agent - Subagent 2 Opportunity Management |
| Operator | Codex |
| Target org | `amit.kumar@astrumcro.com.astrumpar` |
| Target instance | `https://astrum--astrumpar.sandbox.my.salesforce.com` |
| Sandbox verified | Yes - `Organization.IsSandbox = true` |
| Production targeted | No |

## Components Validated and Deployed

| Component | Type | Status |
|---|---|---|
| `AGENT_UpdateOpportunityProgress` | Flow | Deployed to sandbox |
| `AGENT_CaptureNextSteps` | Flow | Deployed to sandbox |
| `Astrum_BD_Agent_PS` | PermissionSet | Updated in sandbox |
| `AGENT_OpportunityStatusSummary` | GenAiPromptTemplate | Deployed to sandbox |

## Validation Commands and Results

| Check | Evidence | Result |
|---|---|---|
| Local XML parse | PowerShell XML parse of both Flows, Prompt Template, Permission Set | PASS |
| Restricted-field scan | `rg` check for prohibited prompt fields | PASS - prohibited fields are only mentioned as exclusions; not used as inputs |
| No Opportunity delete permission | Permission set local and post-deploy query | PASS |
| User context Flow mode | Local Flow XML `runInMode = DefaultMode` | PASS |
| Validate-only deployment with `RunLocalTests` | `validation/S2-opportunity-management-deploy-validate-r3-20260514.json` | COMPONENT PASS, ORG COVERAGE FAIL |
| Sandbox dry-run with `NoTestRun` | `validation/S2-opportunity-management-dry-run-notestrun-20260514.json` | PASS |
| Sandbox deploy | `validation/S2-opportunity-management-sandbox-deploy-20260514.json` | PASS |
| Post-deploy FlowDefinition query | `validation/S2-flowdefinition-postdeploy-20260514.json` | PASS |
| Post-deploy object permissions query | `validation/S2-opportunity-objectpermissions-postdeploy-20260514.json` | PASS |
| Post-deploy field permissions query | `validation/S2-opportunity-fieldpermissions-postdeploy-20260514.json` | PASS |
| Post-deploy Flow access query | `validation/S2-flowaccess-postdeploy-20260514.json` | PASS |
| Post-deploy Prompt Template list | `validation/S2-genaiprompttemplate-postdeploy-list-20260514.json` | PASS |
| Prompt Template retrieve sync | `validation/S2-prompt-template-retrieve-20260514.json` | PASS |
| Salesforce Scanner | `validation/S2-sf-scanner-20260514.json` | NOT AVAILABLE - `scanner run` is not an installed sf command |

## Deploy Evidence

### Validate-only dry run

Deploy ID: `0AfUD00000H3B5C0AV`  
Target org: `astrum--astrumpar.sandbox.my.salesforce.com`  
Timestamp: `2026-05-14T09:02:15.000Z`  
Check only: `true`  
Components validated:

- Flow: `AGENT_CaptureNextSteps`
- Flow: `AGENT_UpdateOpportunityProgress`
- PermissionSet: `Astrum_BD_Agent_PS`
- GenAiPromptTemplate: `AGENT_OpportunityStatusSummary`

Result: PASS, 4 components, 0 component errors, 0 tests run because this is non-Apex metadata.

### Sandbox deploy

Deploy ID: `0AfUD00000H3JYz0AN`  
Target org: `astrum--astrumpar.sandbox.my.salesforce.com`  
Timestamp: `2026-05-14T09:03:36.000Z`  
Components deployed:

- Flow: `AGENT_CaptureNextSteps`
- Flow: `AGENT_UpdateOpportunityProgress`
- PermissionSet: `Astrum_BD_Agent_PS`
- GenAiPromptTemplate: `AGENT_OpportunityStatusSummary`

Result: PASS, 4 components deployed, 0 component errors.

## RunLocalTests Result

`RunLocalTests` validate-only was attempted first, per instruction.

Deploy ID: `0AfUD00000H3JFd0AN`  
Result: metadata component validation passed, but deployment validation failed because org-wide Apex coverage is currently 65%, below Salesforce's 75% threshold.

This S2 deployment contains no Apex classes or triggers. The successful sandbox dry-run and sandbox deploy used `NoTestRun`, which is permitted for sandbox-only non-Apex metadata and did not target production.

## Post-Deploy Checks

| Check | Result |
|---|---|
| `AGENT_CaptureNextSteps` FlowDefinition exists | PASS - ActiveVersionId `301UD00000Wkc4iYAB` |
| `AGENT_UpdateOpportunityProgress` FlowDefinition exists | PASS - ActiveVersionId `301UD00000Wkc4jYAB` |
| `Astrum_BD_Agent_PS` Opportunity Read | PASS |
| `Astrum_BD_Agent_PS` Opportunity Create | PASS |
| `Astrum_BD_Agent_PS` Opportunity Edit | PASS |
| `Astrum_BD_Agent_PS` Opportunity Delete | PASS - false |
| `Astrum_BD_Agent_PS` Modify All / View All | PASS - false |
| S2 Flow access on permission set | PASS - both S2 FlowDefinition access entries present |
| Prompt Template metadata present | PASS - `AGENT_OpportunityStatusSummary` listed |

## Notes on FLS

Salesforce describe marked these fields as not field-permissionable in this org, so they were not added as `<fieldPermissions>` entries:

- `Opportunity.Name`
- `Opportunity.StageName`
- `Opportunity.CloseDate`
- `Opportunity.ForecastCategoryName`
- `Opportunity.Business_Type__c`

`Astrum_BD_Agent_PS` grants Opportunity Create/Edit without Delete. Permissionable S2 fields were added with read/edit or read-only access according to the implementation plan.

## Minimum S2 UAT Scenarios

| Scenario | Description | Expected | Actual | Status |
|---|---|---|---|---|
| 1 | User asks for current status of a named opportunity | Agent retrieves Opportunity details | `AGENT_GetOpportunityDetails` deployed and tested. Published-agent preview blocked by null `BotUserId`. | PASS ACTION / BLOCKED RUNTIME |
| 2 | User searches opportunities by account name | Agent returns candidate list | `AGENT_SearchOpportunities` deployed and tested. Published-agent preview blocked by null `BotUserId`. | PASS ACTION / BLOCKED RUNTIME |
| 3 | User asks to move a deal to Proposal Sent | Agent retrieves current values, prompts for next step, confirms, updates | Planner action wired to `AGENT_UpdateOpportunityProgress` with Confirm required. Runtime preview blocked by null `BotUserId`. | PASS CONFIG / BLOCKED RUNTIME |
| 4 | User asks to change close date to a past date | Agent warns and requires explicit confirmation | `CloseDateIsPast` output exists and planner action requires Confirm. Runtime preview blocked by null `BotUserId`. | PASS CONFIG / BLOCKED RUNTIME |
| 5 | User asks to add next step only | Agent displays current/proposed values, confirms, updates | Planner action wired to `AGENT_CaptureNextSteps` with Confirm required. Runtime preview blocked by null `BotUserId`. | PASS CONFIG / BLOCKED RUNTIME |
| 6 | User asks to delete an opportunity | Agent refuses and directs to Salesforce admin | No delete action is configured, topic instruction refuses delete, and permission set has Opportunity Delete false. Runtime preview blocked by null `BotUserId`. | PASS CONFIG / BLOCKED RUNTIME |
| 7 | User asks for pipeline hygiene report | Routes or redirects to S3 | S2 topic instruction redirects to Data Quality and Hygiene. No S3 topic exists in the retrieved local bundle. Runtime preview blocked by null `BotUserId`. | ORG-VALIDATION REQUIRED |
| 8 | User asks for account contact details | Routes or redirects to S1 | S1 and S2 topics are both present and S2 instruction redirects account/contact requests to S1. Runtime preview blocked by null `BotUserId`. | PASS CONFIG / BLOCKED RUNTIME |
| 9 | User asks for Opportunity Status Summary | Prompt uses only retrieved Salesforce fields and excludes D365 notes and Description | `AGENT_OpportunityStatusSummaryAction` deployed and tested; prohibited fields are exclusion text only. Runtime preview blocked by null `BotUserId`. | PASS ACTION / BLOCKED RUNTIME |
| 10 | User gives partial opportunity name with multiple matches | Agent presents candidates and waits for selection | Apex tests cover multiple-match candidate summaries. Runtime preview blocked by null `BotUserId`. | PASS ACTION / BLOCKED RUNTIME |

Runtime configuration evidence is recorded in `validation/S2-agentforce-sandbox-configuration-20260514.md`.

## Open Validation Items

| Item | Status | Owner |
|---|---|---|
| Agent Builder topic/action setup | Completed through metadata by Codex | Codex |
| Agentforce Testing Center run | Blocked - active sandbox agent has null `BotUserId`, preview cannot start even after Agent Lead received `Astrum_BD_Agent_PS` | Human / Salesforce Admin after agent user assignment |
| Create Opportunity mandatory-field handling | ORG-VALIDATION REQUIRED | Human / Salesforce Admin |
| `Opportunity_ID_18__c` in sandbox | ORG-VALIDATION REQUIRED | Salesforce Admin / Human |
| Low-privilege BD user runtime test | Blocked until sandbox agent user assignment allows runtime sessions | Human / Salesforce Admin |

## Business Summary

- **What was done:** Configured and deployed S2 Opportunity Management in the confirmed sandbox through Apex, Flow, permission set, and planner bundle metadata, then assigned `Astrum_BD_Agent_PS` to Agent Lead.
- **What was found:** S2 action tests and planner deployment passed, sandbox agent version 1 was activated, and Agent Lead has the agent permission set. Runtime preview remains blocked because `BotDefinition.BotUserId` is still null and Salesforce rejected API update attempts.
- **What this means:** S2 is sandbox-ready at metadata/action level, but final Agentforce runtime UAT is blocked by agent user assignment.
- **What is next:** Human or Salesforce Admin sets Agent Lead as the sandbox agent/bot user in Agent Builder or Setup, then Codex reruns the ten runtime scenarios.
- **Decision needed from Human:** Set Agent Lead (`005UD00000OkslyYAB`) as Bot User / Agent User through the Salesforce UI.
