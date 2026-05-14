# S2 Opportunity Management Implementation Plan

| Field | Value |
|---|---|
| Programme | Astrum Orbit |
| Workstream | Astrum BD Agent - Subagent 2: Opportunity Management |
| Operator | Codex |
| Date | 2026-05-14 |
| Target org | `amit.kumar@astrumcro.com.astrumpar` |
| Sandbox verified | Yes - `IsSandbox = true` |
| Branch | `feature/astrum-bd-agent-s2-opportunity-management` |
| Readiness verdict | READY WITH ORG-VALIDATION ITEMS |

## 1. Objective

Deliver the sandbox metadata foundation for Astrum BD Agent Subagent 2: Opportunity Management. The subagent will let authenticated BD users retrieve, search, create, update, and summarise individual Opportunity records through Agentforce with Confirm HITL on every write action.

## 2. Source Documents Reviewed

| Source | Purpose |
|---|---|
| `AGENTS.md` | Governance, Salesforce guardrails, evidence standards |
| `CLAUDE.md` | Local Salesforce project rules |
| `AI_WORKFLOW.md` | Two-agent workflow and handoff rules |
| `LLM-TXTS/Astrum_Project_Memory_Pack_v1.md` | Programme-level guardrails and schema authority |
| `LLM-TXTS/Astrum_BD_Agent_S2_OpportunityManagement_Config.md` | S2 configuration source |
| `LLM-TXTS/agentforce/Astrum_BD_Agent_S2_OpportunityManagement_Spec.md` | S2 build specification |
| `LLM-TXTS/agentforce/Astrum_BD_Agent_S1_AccountContact_Spec.md` | Existing S1 implementation pattern |
| `validation/agentforce/Astrum_BD_Agent_Build_Readiness_Report.md` | Prior schema and build-readiness evidence |
| `validation/S2-opportunity-management-kickoff-20260514.md` | Current Phase 0 and Phase 1 evidence |

## 3. Confirmed Scope

- Get Opportunity Details.
- Search Opportunities.
- Create Opportunity with Confirm HITL, subject to mandatory field handling validation in Agent Builder.
- Update Opportunity Progress using `AGENT_UpdateOpportunityProgress`.
- Capture Next Steps using `AGENT_CaptureNextSteps`.
- Generate Opportunity Status Summary using `AGENT_OpportunityStatusSummary`, grounded only in validated Opportunity and related Account fields.

## 4. Explicit Exclusions

- No production deployment.
- No production activation, publishing, or promotion of the parent Astrum BD Agent.
- No destructive metadata changes.
- No record deletes.
- No bulk Opportunity updates.
- No external channels.
- No standard `Probability` or `Probability__c` logic.
- No `D365_Opportunity_Notes__c`, `Description`, raw migration notes, or long text migration fields in prompt templates.
- No unvalidated fields.
- No `Opportunity_ID_18__c` usage until the field is present in sandbox.

## 5. Object and Field Mapping

### Opportunity Fields

| Field | Use | Phase 1 status |
|---|---|---|
| `Id` | Flow input and record identity | Confirmed |
| `Name` | Display and output | Confirmed |
| `AccountId` | Related Account | Confirmed |
| `StageName` | Read and update | Confirmed; 19 active values |
| `CloseDate` | Read and update | Confirmed |
| `ForecastCategoryName` | Summary read | Confirmed |
| `Amount` | Summary read | Confirmed |
| `Service_Fees__c` | Summary read | Confirmed |
| `Opp_Probability__c` | Authoritative probability | Confirmed |
| `Business_Category__c` | Summary read and create context | Confirmed |
| `Therapeutic_Area__c` | Summary read | Confirmed |
| `NextStep` | Read and update | Confirmed |
| `Next_specific_action__c` | Read and update | Confirmed |
| `Date_of_next_specific_action__c` | Read and update | Confirmed |
| `Person_responsible_for_next_action__c` | Read and update | Confirmed |
| `Last_client_interaction_date__c` | Summary read | Confirmed |
| `Opportunity_Code__c` | Deal identifier | Confirmed |
| `Opportunity_ID_18__c` | Record-link identifier | ORG-VALIDATION REQUIRED - absent from sandbox |
| `Award_Date__c` | Summary read | Confirmed |
| `Business_Type__c` | Summary read | Confirmed |
| `Study_Phase_Type__c` | Summary read | Confirmed |
| `D365_Opportunity_Notes__c` | Excluded | Confirmed present, excluded |

### Related Account Fields

| Field | Use | Phase 1 status |
|---|---|---|
| `Account.Name` | Summary context | Confirmed |
| `Client_Type__c` | Summary context | Confirmed |
| `Account_Segment__c` | Summary context | Confirmed |

## 6. Metadata Components

Create:

- `force-app/main/default/flows/AGENT_UpdateOpportunityProgress.flow-meta.xml`
- `force-app/main/default/flows/AGENT_CaptureNextSteps.flow-meta.xml`
- `force-app/main/default/genAiPromptTemplates/AGENT_OpportunityStatusSummary.genAiPromptTemplate-meta.xml`
- `handoff/S2-agent-builder-human-setup.md` if full Agent Builder configuration cannot be safely deployed as metadata
- `handoff/S2-opportunity-management-delivery-handoff.md`
- S2 validation evidence under `validation/`

Update:

- `force-app/main/default/permissionsets/Astrum_BD_Agent_PS.permissionset-meta.xml`
- `force-app/main/default/genAiPlannerBundles/Astrum_BD_Agent/Astrum_BD_Agent.genAiPlannerBundle` only if metadata support is safe and validateable
- `LLM-TXTS` only for durable knowledge created by this build

## 7. Flow Design - `AGENT_UpdateOpportunityProgress`

Autolaunched Flow, no trigger, user context (`DefaultMode`).

Inputs:

| Variable | Type | Required |
|---|---|---|
| `OpportunityId` | Text | Yes |
| `NewStageName` | Text | No |
| `NewCloseDate` | Date | No |
| `NewNextStep` | Text | No |
| `NewNextSpecificAction` | Text | No |
| `NewDateOfNextAction` | Date | No |
| `NewPersonResponsible` | Text | No |

Outputs:

| Variable | Type |
|---|---|
| `Success` | Boolean |
| `CloseDateIsPast` | Boolean |
| `UpdatedOpportunityName` | Text |
| `CurrentStageName` | Text |
| `CurrentCloseDate` | Date |
| `CurrentNextStep` | Text |
| `ErrorMessage` | Text |

Logic:

1. Get Opportunity by `OpportunityId`.
2. If not found, return `Success = false` and a clear `ErrorMessage`.
3. Capture current `StageName`, `CloseDate`, and `NextStep`.
4. If `NewCloseDate` is populated and earlier than current date, set `CloseDateIsPast = true`.
5. Copy the retrieved Opportunity into an update record variable.
6. Assign only non-blank input values into the update record variable.
7. Update the single Opportunity record.
8. On fault, return `Success = false` and `$Flow.FaultMessage`.
9. On success, return `Success = true` and the updated Opportunity name.

## 8. Flow Design - `AGENT_CaptureNextSteps`

Autolaunched Flow, no trigger, user context (`DefaultMode`).

Inputs:

| Variable | Type | Required |
|---|---|---|
| `OpportunityId` | Text | Yes |
| `NewNextStep` | Text | Yes |
| `NewNextSpecificAction` | Text | No |
| `NewDateOfNextAction` | Date | No |
| `NewPersonResponsible` | Text | No |

Outputs:

| Variable | Type |
|---|---|
| `Success` | Boolean |
| `CurrentNextStep` | Text |
| `CurrentNextSpecificAction` | Text |
| `UpdatedOpportunityName` | Text |
| `ErrorMessage` | Text |

Logic:

1. Get Opportunity by `OpportunityId`.
2. If not found, return `Success = false` and a clear `ErrorMessage`.
3. Capture current `NextStep` and `Next_specific_action__c`.
4. Update `NextStep` and optional supporting next-action fields.
5. On fault, return `Success = false` and `$Flow.FaultMessage`.
6. On success, return `Success = true` and the updated Opportunity name.

## 9. Prompt Template Design - `AGENT_OpportunityStatusSummary`

Metadata type: `GenAiPromptTemplate`.

Input:

- `Opportunity` SObject input.

Allowed grounding:

- Validated Opportunity fields listed in Section 5, excluding `D365_Opportunity_Notes__c`, `Description`, and `Opportunity_ID_18__c`.
- Related Account fields only where retrievable from the Opportunity input or prior agent context: `Account.Name`, `Client_Type__c`, `Account_Segment__c`.

Template instructions:

- Use only provided Salesforce data.
- Do not guess, speculate, or invent values.
- Summarise current deal status, next action, and visible risk signals.
- Omit blank values rather than saying unknown.
- Use `Opp_Probability__c`, not standard `Probability`.
- Do not use external web data.

## 10. Permission Set Updates

Update `Astrum_BD_Agent_PS` only.

Object permission target:

| Object | Read | Create | Edit | Delete |
|---|---:|---:|---:|---:|
| Opportunity | true | true | true | false |

FLS target:

| Field | Read | Edit |
|---|---:|---:|
| `Opportunity.StageName` | true | true |
| `Opportunity.CloseDate` | true | true |
| `Opportunity.NextStep` | true | true |
| `Opportunity.Next_specific_action__c` | true | true |
| `Opportunity.Date_of_next_specific_action__c` | true | true |
| `Opportunity.Person_responsible_for_next_action__c` | true | true |
| `Opportunity.Name` | true | false |
| `Opportunity.AccountId` | true | false |
| `Opportunity.Opportunity_Code__c` | true | false |
| `Opportunity.Opp_Probability__c` | true | false |
| `Opportunity.ForecastCategoryName` | true | false |
| `Opportunity.Amount` | true | false |
| `Opportunity.Service_Fees__c` | true | false |
| `Opportunity.Business_Category__c` | true | false |
| `Opportunity.Therapeutic_Area__c` | true | false |
| `Opportunity.Last_client_interaction_date__c` | true | false |
| `Opportunity.Award_Date__c` | true | false |
| `Opportunity.Business_Type__c` | true | false |
| `Opportunity.Study_Phase_Type__c` | true | false |

Flow access:

- `AGENT_UpdateOpportunityProgress`
- `AGENT_CaptureNextSteps`

Prompt Template access:

- Add where metadata support exists. If not supported in permission set metadata, document as Human-only Agent Builder / setup step.

## 11. Agent Builder Configuration

Target topic: `Opportunity Management`.

Actions:

| Action | Type | HITL |
|---|---|---|
| Get Opportunity Details | Standard get / metadata-supported action | Autonomous |
| Search Opportunities | Standard query / metadata-supported action | Autonomous |
| Create Opportunity | Standard create | Confirm |
| Update Opportunity Progress | Flow `AGENT_UpdateOpportunityProgress` | Confirm |
| Capture Next Steps | Flow `AGENT_CaptureNextSteps` | Confirm |
| Opportunity Status Summary | Prompt Template `AGENT_OpportunityStatusSummary` | Autonomous |

If the planner bundle metadata is not safely deployable for all configuration fields, generate click-by-click Human setup instructions and do not force unsupported metadata.

## 12. Testing Strategy

- XML parse / metadata syntax checks for changed XML and JSON.
- Sandbox validate-only deployment with `RunLocalTests`.
- Permission set checks confirming no Opportunity Delete.
- Flow metadata check confirming `runInMode = DefaultMode`.
- Static scan if Salesforce Scanner is installed.
- Agentforce Testing Center evidence where available.
- Manual / Human-only UAT runbook for Testing Center items that cannot be executed through CLI.

Minimum UAT scenarios are the 10 S2 scenarios from the Human-approved prompt.

## 13. Deployment Plan

Sandbox only:

1. Validate changed metadata.
2. Deploy Flows.
3. Deploy permission set update.
4. Deploy Prompt Template.
5. Deploy planner bundle metadata only if validateable and safe.
6. Run post-deploy checks and collect evidence.

No production deployment is authorized.

## 14. Rollback Plan

- Remove S2 actions from Agent Builder / planner bundle if configured.
- Revert `Astrum_BD_Agent_PS` to previous Opportunity read-only footprint.
- Deactivate or supersede S2 Flow versions in sandbox if required.
- Remove or leave draft `AGENT_OpportunityStatusSummary` inactive if validation fails.
- Revert branch commits before merge if Human decides not to proceed.

## 15. Linear Issue Mapping

Linear search is currently blocked because the exposed Linear research/search tool returned `tool research not found`. Codex will retry in Phase 5. If search remains unavailable, Codex will provide paste-ready Linear comments and will not create a duplicate issue blindly.

## 16. Risks and Open Decisions

| Item | Status | Impact |
|---|---|---|
| `Opportunity_ID_18__c` absent from sandbox | ORG-VALIDATION REQUIRED | Do not build record links in S2 summary until field exists |
| Agent Builder mandatory field handling for Create Opportunity | ORG-VALIDATION REQUIRED | Human must validate standard Create action captures all mandatory fields before UAT sign-off |
| Prompt Template access metadata | ORG-VALIDATION REQUIRED | May need Human setup if not represented in permission set metadata |
| Full Agent Builder topic/action configuration | ORG-VALIDATION REQUIRED | Metadata support exists for planner bundle, but UI-only gaps may remain |
| Linear search tool | Tooling gap | Use paste-ready comments if search remains unavailable |

## Business Summary

- **What was done:** Created the S2 implementation plan for Opportunity Management after validating the live sandbox metadata.
- **What was found:** The sandbox supports the core S2 build, but `Opportunity_ID_18__c` is missing and must not be used until deployed to sandbox.
- **What this means:** Codex can proceed with the Flow, permission set, and prompt template build in sandbox with a clear record-link limitation.
- **What is next:** Codex will build the S2 metadata and validation evidence.
- **Decision needed from Human:** None at this time.

## 17. What Will Be Done Next

Codex will build the scoped S2 metadata components, validate them locally, run sandbox validate-only checks, and produce handoff evidence for Human review and UAT.
