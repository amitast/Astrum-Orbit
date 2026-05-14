# S2 Agentforce Sandbox Configuration Evidence - 2026-05-14

| Field | Value |
|---|---|
| Programme | Astrum Orbit |
| Workstream | Astrum BD Agent - Subagent 2 Opportunity Management |
| Operator | Codex |
| Target org | `amit.kumar@astrumcro.com.astrumpar` |
| Target instance | `https://astrum--astrumpar.sandbox.my.salesforce.com` |
| Sandbox verified | Yes - `Organization.IsSandbox = true` |
| Production targeted | No |

## What Codex Configured

Codex implemented the S2 Agent Builder setup through supported metadata instead of UI clicks:

- Added `Opportunity_Management` topic to `GenAiPlannerBundle:Astrum_BD_Agent`.
- Added S2 topic instructions, classification utterances, and boundaries.
- Added six S2 actions:
  - `Get_Opportunity_Details` - Apex, Autonomous.
  - `Search_Opportunities` - Apex, Autonomous.
  - `Create_Opportunity` - Apex, Confirm required.
  - `Update_Opportunity_Progress` - Flow, Confirm required.
  - `Capture_Next_Steps` - Flow, Confirm required.
  - `Opportunity_Status_Summary` - Apex, Autonomous.
- Added AGENT-prefixed Apex action layer for get, search, create, and status summary.
- Updated `Astrum_BD_Agent_PS` with S2 Apex access and mandatory create-field FLS. Opportunity Delete remains false.
- Deployed the S2 planner bundle to the confirmed sandbox.
- Activated `Astrum_BD_Agent` version 1 in the confirmed sandbox.
- Assigned `Astrum_BD_Agent_PS` to Agent Lead (`005UD00000OkslyYAB`) after Human direction.

## Why This Differs From The Handoff UI Path

`handoff/S2-agent-builder-human-setup.md` described standard Agent Builder Get/Search/Create actions. Codex could not operate the Salesforce Agent Builder UI directly in this session, and no `AiAuthoringBundle` exists in the sandbox. To complete the setup without inventing standard action metadata, Codex mirrored the existing S1 implementation pattern: AGENT-prefixed invocable Apex and Flow actions wired into `GenAiPlannerBundle`.

The summary capability is implemented as `AGENT_OpportunityStatusSummaryAction` instead of a direct Prompt Template planner action. This follows the repo's confirmed S1 pattern for summary actions that need text-to-record resolution and avoids planner binding risk.

## Dependency Readiness Checklist - Astrum_BD_Agent - Sandbox - 2026-05-14

| Dependency | Type | Required By | Present in sandbox | Deploy ID or Confirmation | Status |
|---|---|---|---|---|---|
| `AGENT_GetOpportunityDetails` | Apex | Get Opportunity Details | Yes | `0AfUD00000H3v3B0AR` | READY |
| `AGENT_SearchOpportunities` | Apex | Search Opportunities | Yes | `0AfUD00000H3v3B0AR` | READY |
| `AGENT_CreateOpportunity` | Apex | Create Opportunity | Yes | `0AfUD00000H3v3B0AR` | READY |
| `AGENT_OpportunityStatusSummaryAction` | Apex | Opportunity Status Summary | Yes | `0AfUD00000H3v3B0AR` | READY |
| `AGENT_AccountIntelligenceSummary` | Apex | Existing S1 summary action | Yes | `0AfUD00000H3vET0AZ` | READY |
| `AGENT_UpdateOpportunityProgress` | Flow | Update Opportunity Progress | Yes | `validation/S2-agentforce-flow-postdeploy-query-20260514.json` | READY |
| `AGENT_CaptureNextSteps` | Flow | Capture Next Steps | Yes | `validation/S2-agentforce-flow-postdeploy-query-20260514.json` | READY |
| `Astrum_BD_Agent_PS` | PermissionSet | Permission boundary | Yes | `0AfUD00000H3vJJ0AZ` | READY |
| `Astrum_BD_Agent` | GenAiPlannerBundle | S2 topic/action routing | Yes | `0AfUD00000H3vWD0AZ` | READY |

## Deploy And Test Evidence

| Check | Evidence | Result |
|---|---|---|
| S2 Apex validate-only | `validation/S2-agentforce-apex-validate-20260514.json` | PASS - deploy ID `0AfUD00000H3uyL0AR`, 8/8 tests, 0 failures |
| S2 Apex deploy | `validation/S2-agentforce-apex-deploy-20260514.json` | PASS - deploy ID `0AfUD00000H3v3B0AR`, 8/8 tests, 0 failures |
| Existing S1 dependency deploy | `validation/S2-agentforce-s1-dependency-deploy-20260514.json` | PASS - deploy ID `0AfUD00000H3vET0AZ`, 9/9 tests, 0 failures |
| Permission set deploy | `validation/S2-agentforce-permissionset-deploy-r2-20260514.json` | PASS - deploy ID `0AfUD00000H3vJJ0AZ` |
| Planner validate-only | `validation/S2-agentforce-planner-validate-20260514.json` | PASS - deploy ID `0AfUD00000H3vKv0AJ`, 8/8 tests, 0 failures |
| Planner deploy | `validation/S2-agentforce-planner-deploy-20260514.json` | PASS - deploy ID `0AfUD00000H3vWD0AZ`, 8/8 tests, 0 failures |
| Post-deploy S2 Apex tests | `validation/S2-agentforce-apex-test-run-20260514.json` | PASS - test run `707UD00000rYLUg`, 8/8 tests, 0 failures |
| Sandbox activation | `validation/S2-agentforce-activate-sandbox-20260514.json` | PASS - `Astrum_BD_Agent` version 1 activated |
| BotVersion after activation | `validation/S2-agentforce-botversion-after-activate-20260514.json` | PASS - version 1 `Active` |
| Agent Lead permission-set assignment | `validation/S2-agentforce-agentlead-permset-assign-20260514.json` and `validation/S2-agentforce-agentlead-permset-confirm-20260514.json` | PASS - `Astrum_BD_Agent_PS` assigned to Agent Lead |
| BotUserId standard API update attempt | `validation/S2-agentforce-botuser-update-attempt-20260514.json` | BLOCKED - Salesforce returned `entity type cannot be updated: Bot` |
| BotUserId Tooling API update attempt | `validation/S2-agentforce-botuser-tooling-update-attempt-20260514.txt` | BLOCKED - Salesforce returned `NOT_FOUND` |
| BotUserId after update attempts | `validation/S2-agentforce-botuser-after-update-attempts-20260514.json` | BLOCKED - `BotUserId` remains null |
| CLI preview start | `validation/S2-agentforce-preview-start-after-activate-20260514.json` | BLOCKED - `Invalid user ID provided on start session` |
| CLI preview start after Agent Lead permission set | `validation/S2-agentforce-preview-start-after-agentlead-20260514.json` | BLOCKED - `Invalid user ID provided on start session` |
| Bot user check | `validation/S2-agentforce-botuser-before-update-20260514.json` | BLOCKED - `BotUserId` is null |
| Agent API start session | `validation/S2-agentforce-agent-api-start-session-20260514.json` | BLOCKED - HTTP 404 through direct Agent API attempt |

## Scenario Results

| Scenario | Description | Expected | Actual | Status |
|---|---|---|---|---|
| 1 | User asks for current status of a named opportunity | Agent retrieves Opportunity details | `AGENT_GetOpportunityDetails` deployed and tested. Published-agent preview blocked by null `BotUserId`. | PASS ACTION / BLOCKED RUNTIME |
| 2 | User searches opportunities by account name | Agent returns candidate list | `AGENT_SearchOpportunities` deployed and tested. Published-agent preview blocked by null `BotUserId`. | PASS ACTION / BLOCKED RUNTIME |
| 3 | User asks to move a deal to Proposal Sent | Agent retrieves current values, prompts for next step, confirms, then updates | Planner action wired to `AGENT_UpdateOpportunityProgress` with Confirm required. Runtime preview blocked by null `BotUserId`. | PASS CONFIG / BLOCKED RUNTIME |
| 4 | User asks to change close date to a past date | Agent warns and requires explicit confirmation | `CloseDateIsPast` Flow output exists and planner action requires Confirm. Runtime preview blocked by null `BotUserId`. | PASS CONFIG / BLOCKED RUNTIME |
| 5 | User asks to add next step only | Agent displays current/proposed values, confirms, then updates | Planner action wired to `AGENT_CaptureNextSteps` with Confirm required. Runtime preview blocked by null `BotUserId`. | PASS CONFIG / BLOCKED RUNTIME |
| 6 | User asks to delete an opportunity | Agent refuses and directs to Salesforce admin | No delete action is configured, topic instruction refuses delete, and permission set has Opportunity Delete false. Runtime preview blocked by null `BotUserId`. | PASS CONFIG / BLOCKED RUNTIME |
| 7 | User asks for pipeline hygiene report | Routes or redirects to S3, not S2 | S2 topic instruction redirects to Data Quality and Hygiene. No S3 topic exists in the retrieved local bundle. Runtime preview blocked by null `BotUserId`. | ORG-VALIDATION REQUIRED |
| 8 | User asks for account contact details | Routes or redirects to S1, not S2 | S1 and S2 topics are both present and S2 instruction redirects account/contact requests to S1. Runtime preview blocked by null `BotUserId`. | PASS CONFIG / BLOCKED RUNTIME |
| 9 | User asks for Opportunity Status Summary | Uses only retrieved Salesforce fields and excludes D365 notes and Description | `AGENT_OpportunityStatusSummaryAction` deployed and tested. Static scans confirm prohibited fields are exclusion text only. Runtime preview blocked by null `BotUserId`. | PASS ACTION / BLOCKED RUNTIME |
| 10 | User gives partial opportunity name with multiple matches | Agent presents candidates and waits for selection | Apex tests cover multiple-match candidate summaries. Runtime preview blocked by null `BotUserId`. | PASS ACTION / BLOCKED RUNTIME |

## Remaining Runtime Blocker

`sf agent preview start --api-name Astrum_BD_Agent` now reaches the active sandbox agent but fails with:

```text
Bad Request: Invalid user ID provided on start session
```

Evidence shows `BotDefinition.BotUserId = null`. Agent Lead now has `Astrum_BD_Agent_PS`, but Salesforce rejected both supported API attempts to set `BotUserId`: the standard data API returned `entity type cannot be updated: Bot`, and the Tooling REST endpoint returned `NOT_FOUND`. The `BotDefinition` describe marks `BotUserId` and the object itself as not updateable through the standard data API. No `AiAuthoringBundle` exists in the sandbox. Direct Agent API session start with `bypassUser=false` returned HTTP 404, so Codex could not complete published-agent scenario execution from this session.

## Business Summary

- **What was done:** Codex configured S2 Opportunity Management in the sandbox through metadata, deployed the action layer, permission set, and planner bundle, activated the sandbox agent version, and assigned `Astrum_BD_Agent_PS` to Agent Lead.
- **What was found:** Metadata/action validation passed. Runtime preview remains blocked because the active sandbox agent has no Bot User assigned and Salesforce does not allow Codex to set `BotUserId` through standard or Tooling API.
- **What this means:** The S2 configuration is deployed and sandbox-ready at metadata/action level, but final Agentforce runtime UAT cannot complete until the sandbox agent user is assigned.
- **What is next:** Human or Salesforce Admin sets Agent Lead as the sandbox agent/bot user in Agent Builder or Setup, then Codex reruns the ten runtime scenarios.
- **Decision needed from Human:** Assign Agent Lead as Bot User / Agent User through the Salesforce UI.

## Next Operator
- Run next in: Human
- Reason: The remaining blocker is org-admin Agent Builder/Setup assignment of the sandbox agent user; `BotDefinition.BotUserId` is null and Salesforce rejected standard and Tooling API update attempts.
- Next prompt: Set Agent Lead (`005UD00000OkslyYAB`) as the Bot User / Agent User for `Astrum_BD_Agent` in Salesforce Setup or Agent Builder, then ask Codex to rerun `sf agent preview start --api-name Astrum_BD_Agent --target-org amit.kumar@astrumcro.com.astrumpar` and execute the ten S2 UAT scenarios.
