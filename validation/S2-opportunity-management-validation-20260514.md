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
| 1 | User asks for current status of a named opportunity | Agent retrieves Opportunity details | Not run - S2 topic/actions not configured and agent preview returned `No valid version available` | BLOCKED |
| 2 | User searches opportunities by account name | Agent returns candidate list | Not run - S2 topic/actions not configured and agent preview returned `No valid version available` | BLOCKED |
| 3 | User asks to move a deal to Proposal Sent | Agent retrieves current values, prompts for next step, confirms, updates | Not run - S2 topic/actions not configured and agent preview returned `No valid version available` | BLOCKED |
| 4 | User asks to change close date to a past date | Agent warns and requires explicit confirmation | `CloseDateIsPast` output built; runtime not run because agent preview returned `No valid version available` | BLOCKED |
| 5 | User asks to add next step only | Agent displays current/proposed values, confirms, updates | Not run - S2 topic/actions not configured and agent preview returned `No valid version available` | BLOCKED |
| 6 | User asks to delete an opportunity | Agent refuses and directs to Salesforce admin | Static metadata confirms no Opportunity Delete permission and no delete action in S2 metadata; runtime not run | PASS STATIC / BLOCKED RUNTIME |
| 7 | User asks for pipeline hygiene report | Routes or redirects to S3 | Not run - S2 topic/actions not configured and agent preview returned `No valid version available` | BLOCKED |
| 8 | User asks for account contact details | Routes or redirects to S1 | Not run - S2 topic/actions not configured and agent preview returned `No valid version available` | BLOCKED |
| 9 | User asks for Opportunity Status Summary | Prompt uses only retrieved Salesforce fields and excludes D365 notes and Description | Static Prompt Template confirms exclusions; runtime not run | PASS STATIC / BLOCKED RUNTIME |
| 10 | User gives partial opportunity name with multiple matches | Agent presents candidates and waits for selection | Not run - S2 topic/actions not configured and agent preview returned `No valid version available` | BLOCKED |

Runtime attempt evidence is recorded in `validation/S2-agent-builder-configuration-and-test-attempt-20260514.md`.

## Open Validation Items

| Item | Status | Owner |
|---|---|---|
| Agent Builder topic/action setup | Pending | Human |
| Agentforce Testing Center run | Blocked - no S2 test definition and no valid agent preview version | Human after Agent Builder setup |
| Create Opportunity mandatory-field handling | ORG-VALIDATION REQUIRED | Human / Salesforce Admin |
| `Opportunity_ID_18__c` in sandbox | ORG-VALIDATION REQUIRED | Salesforce Admin / Human |
| Low-privilege BD user runtime test | Blocked until Agent Builder setup and valid sandbox agent version are available | Human / Salesforce Admin |

## Business Summary

- **What was done:** Validated and deployed the S2 Opportunity Management metadata foundation to the confirmed sandbox, then attempted Agent Builder/runtime validation through available Agentforce CLI commands.
- **What was found:** The S2 metadata deploy passed with 4 components and no component errors. Runtime UAT is blocked because the sandbox agent has no valid active preview version and S2 topic/action setup remains Human-only in Agent Builder.
- **What this means:** The deployable S2 metadata foundation is sandbox-ready, but S2 agent runtime behaviour is not yet validated.
- **What is next:** Human configures the Opportunity Management topic/actions using `handoff/S2-agent-builder-human-setup.md`, makes a valid sandbox test version available, then runs UAT/Testing Center prompts.
- **Decision needed from Human:** Confirm standard Create Opportunity mandatory-field handling in Agent Builder, decide whether to deploy `Opportunity_ID_18__c` to sandbox for record-link support, and decide whether to activate/publish a sandbox agent version for UAT.
