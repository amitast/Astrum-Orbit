# SAL-24 Production Deployment Closure Evidence

Date: 2026-05-16  
Agent: Codex  
Target org: astrum-prod / https://astrum.my.salesforce.com  
Mode: Production quick deploy from previously successful validate-only jobs

## Org Safety

| Check | Result |
|---|---|
| Organization query | `SELECT Id, Name, IsSandbox FROM Organization` |
| Org name | ASTRUM CRO, SL |
| Org Id | 00Dd100000AMk1dEAD |
| IsSandbox | false |
| Safety verdict | PASS - production org confirmed before deployment |

## Deployment Summary

| Phase | Action | Deploy ID | Status | Notes |
|---|---|---|---|---|
| Phase 1-4 | Quick deploy of combined validated Apex, Flows, prompt template, and permission set | 0AfTY000003pb5R0AQ | Succeeded | Quick-deployed validated job 0AfTY000003pasX0AQ |
| Phase 5 precheck | Planner bundle validate while agent active | 0AfTY000003pb8f0AA | Failed | Expected Salesforce gate: `Cannot update record as Agent is Active` |
| Agent state | Deactivated `Astrum_BD_Agent` | n/a | Succeeded | CLI returned `success=true`, version 1 |
| Phase 5 validate | Validate-only for `GenAiPlannerBundle:Astrum_BD_Agent` | 0AfTY000003pbDV0AY | Succeeded | `AGENT_OpportunityActions_Test` 8/8 passing |
| Phase 5 deploy | Quick deploy of planner bundle | 0AfTY000003pbF70AI | Succeeded | Quick-deployed validated job 0AfTY000003pbDV0AY |
| Agent state | Reactivated `Astrum_BD_Agent` version 1 | n/a | Succeeded | CLI returned `success=true`, version 1 |

## Components Deployed

| Component | Type | Production status |
|---|---|---|
| AGENT_GetOpportunityDetails | ApexClass | Active |
| AGENT_SearchOpportunities | ApexClass | Active |
| AGENT_CreateOpportunity | ApexClass | Active |
| AGENT_OpportunityStatusSummaryAction | ApexClass | Active |
| AGENT_OpportunityActions_Test | ApexClass | Active |
| AGENT_UpdateOpportunityProgress | Flow | Present; latest version created |
| AGENT_CaptureNextSteps | Flow | Present; latest version created |
| AGENT_CheckOpportunityUpdateRisk | Flow | Present; latest version created |
| AGENT_OpportunityStatusSummary | GenAiPromptTemplate | Present |
| Astrum_BD_Agent_PS | PermissionSet | Present and updated |
| Astrum_BD_Agent | GenAiPlannerBundle | Present and updated |

Note: Flow `ActiveVersionId` is null for the deployed autolaunched Flows. AGENTS.md states this is expected Salesforce CLI behaviour and must not be treated as a failure.

## Test Evidence

| Test run | Test run ID | Passing | Failing | Total | Status |
|---|---|---:|---:|---:|---|
| Phase 5 validate-only | 0AfTY000003pbDV0AY | 8 | 0 | 8 | PASS |
| Post-deploy Apex test run | 707TY00001Fd454 | 8 | 0 | 8 | PASS |

Post-deploy test class: `AGENT_OpportunityActions_Test`

Passing methods:
- `createOpportunityInsertsSingleRecordWhenAllFieldsProvided`
- `createOpportunityValidatesMandatoryFieldsBeforeDml`
- `getOpportunityDetailsByIdReturnsGroundedFields`
- `getOpportunityDetailsHandlesNoInputNoMatchAndMultipleMatches`
- `searchOpportunitiesByNameReturnsCandidate`
- `searchOpportunitiesSupportsFiltersAndValidation`
- `statusSummaryHandlesMultipleMatchesAndRiskSignals`
- `statusSummaryOmitProhibitedLongTextFields`

## Runtime Preview Check

| Check | Result | Notes |
|---|---|---|
| `sf agent preview start --api-name Astrum_BD_Agent --target-org astrum-prod` | BLOCKED | Salesforce returned `Invalid user ID provided on start session:` |
| Bot user query | `BotDefinition.BotUserId = null` | Production `Astrum_BD_Agent` currently has no Bot User value exposed through `BotDefinition` |
| Production agent user query | READY | `Lead Agent User` exists and is active: `005TY00000Rpn8oYAB` |
| Permission assignment query | READY | `Lead Agent User` has `Astrum_BD_Agent_PS` assigned |

This is the same platform limitation found in sandbox evidence: `BotDefinition.BotUserId` is not updateable through the standard API, and CLI preview cannot start while Salesforce returns a blank Bot User for the published agent. The deployment is complete; UI/runtime smoke testing still depends on Salesforce Agent Builder / Setup exposing or resolving the Bot User assignment.

## Dependency Readiness Checklist — Astrum_BD_Agent — astrum-prod — 2026-05-16

| Dependency | Type | Required By | Present in astrum-prod | Deploy ID or Confirmation | Status |
|---|---|---|---|---|---|
| AGENT_GetOpportunityDetails | ApexClass | Get Opportunity Details | Yes | 0AfTY000003pb5R0AQ | READY |
| AGENT_SearchOpportunities | ApexClass | Search Opportunities | Yes | 0AfTY000003pb5R0AQ | READY |
| AGENT_CreateOpportunity | ApexClass | Create Opportunity | Yes | 0AfTY000003pb5R0AQ | READY |
| AGENT_OpportunityStatusSummaryAction | ApexClass | Opportunity Status Summary | Yes | 0AfTY000003pb5R0AQ | READY |
| AGENT_UpdateOpportunityProgress | Flow | Update Opportunity Progress | Yes | 0AfTY000003pb5R0AQ | READY |
| AGENT_CaptureNextSteps | Flow | Capture Next Steps | Yes | 0AfTY000003pb5R0AQ | READY |
| AGENT_CheckOpportunityUpdateRisk | Flow | Close date precheck | Yes | 0AfTY000003pb5R0AQ | READY |
| AGENT_OpportunityStatusSummary | GenAiPromptTemplate | Opportunity Status Summary | Yes | 0AfTY000003pb5R0AQ | READY |
| Astrum_BD_Agent_PS | PermissionSet | Permission boundary | Yes | 0AfTY000003pb5R0AQ | READY |
| Astrum_BD_Agent | GenAiPlannerBundle | Agent planner | Yes | 0AfTY000003pbF70AI | READY |

## Business Summary

- **What was done:** Completed the production deployment for SAL-24 S2 Opportunity Management and reactivated the Astrum BD Agent after the planner update.
- **What was found:** Both production quick deploys succeeded. The S2 Apex regression test passed 8/8 after deployment. CLI preview remains blocked because Salesforce reports a blank Bot User for the published agent.
- **What this means:** The S2 production metadata is live and verified, but final user-facing runtime smoke testing still needs the Salesforce Agent Builder/Bot User configuration issue resolved or confirmed by UI.
- **What is next:** Human should perform a quick Agent Builder/UI smoke test for the active production agent and confirm whether Salesforce runtime works despite CLI preview being blocked.
- **Decision needed from Human:** Confirm production runtime acceptance and whether SAL-24 can be moved to Done/Closed in Linear.

## Next Operator
- Run next in: Human
- Reason: Production deployment is complete; only human UI runtime acceptance and Linear closure decision remain.
- Next prompt: Confirm Astrum BD Agent S2 Opportunity Management works in production UI, then approve moving SAL-24 to Done/Closed.
