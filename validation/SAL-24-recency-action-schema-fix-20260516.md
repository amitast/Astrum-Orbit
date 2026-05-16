# SAL-24 Recency Action Schema Fix Evidence

Date: 2026-05-16  
Agent: Codex  
Target workstream: SAL-24 - Astrum BD Agent S2 Opportunity Management  
Issue: Production Agent Builder selected the Opportunity Management topic but returned a fallback instead of invoking the dedicated recency search actions.

## Finding

The Opportunity Management topic had local action links and local action definitions for:

| Action | Apex target |
|---|---|
| Find Opportunities Created Recently | `AGENT_FindRecentOpportunities` |
| Find Opportunities With No Recent Action | `AGENT_FindStaleOpportunities` |

However, the `GenAiPlannerBundle` did not include `localActions/Opportunity_Management/.../input/schema.json` or `output/schema.json` files for those actions. Account and Contact Management actions already had these schema files. Without the schema files, Agentforce could display/select the topic but did not have a concrete action contract to execute, which matched the observed fallback in production.

## Files Added

| File | Purpose |
|---|---|
| `force-app/main/default/genAiPlannerBundles/Astrum_BD_Agent/localActions/Opportunity_Management/Find_Opportunities_Created_Recently/input/schema.json` | Defines planner inputs for recently created Opportunity searches. |
| `force-app/main/default/genAiPlannerBundles/Astrum_BD_Agent/localActions/Opportunity_Management/Find_Opportunities_Created_Recently/output/schema.json` | Marks recently created Opportunity results as displayable and planner-usable. |
| `force-app/main/default/genAiPlannerBundles/Astrum_BD_Agent/localActions/Opportunity_Management/Find_Opportunities_With_No_Recent_Action/input/schema.json` | Defines planner inputs for no-recent-action Opportunity searches. |
| `force-app/main/default/genAiPlannerBundles/Astrum_BD_Agent/localActions/Opportunity_Management/Find_Opportunities_With_No_Recent_Action/output/schema.json` | Marks no-recent-action Opportunity results as displayable and planner-usable. |

## Local Validation

| Check | Result |
|---|---|
| JSON parse for all four new schema files | PASS |
| `git diff --check` for new schema files | PASS |

## Sandbox Evidence

| Step | Deploy ID | Status | Tests |
|---|---|---|---|
| Sandbox validate-only | `0AfUD00000H5Mz00AF` | Succeeded | `AGENT_OpportunityActions_Test` 12/12 |
| Sandbox deploy | `0AfUD00000H5NIL0A3` | Succeeded | `AGENT_OpportunityActions_Test` 12/12 |

## Production Evidence

| Step | Deploy ID / Result | Status | Tests |
|---|---|---|---|
| Production safety gate | `Organization.IsSandbox = false` | PASS | n/a |
| Initial production validate while active | `0AfTY000003pe3J0AQ` | Expected failure: `Cannot update record as Agent is Active` | n/a |
| Deactivate `Astrum_BD_Agent` v1 | `success = true`, `version = 1` | Succeeded | n/a |
| Production validate-only after deactivation | `0AfTY000003pe4v0AA` | Succeeded | `AGENT_OpportunityActions_Test` 12/12 |
| Production quick deploy | `0AfTY000003pe6X0AQ` | Succeeded | Quick deploy from validated job |
| Reactivate `Astrum_BD_Agent` v1 | `success = true`, `version = 1` | Succeeded | n/a |
| Planner bundle existence check | `GenAiPlannerDefinition.Id = 16jTY000000Oa5ZYAS` | Present | n/a |

## Preview Limitation

Codex attempted to start a production CLI preview session after reactivation. The CLI preview failed with:

`Failed to start preview session: Bad Request: Invalid user ID provided on start session`

This is the existing production bot-user preview limitation seen earlier. The Human's Agent Builder browser preview remains the acceptance path.

## No Data Mutation

This fix changed only Agentforce planner schema metadata. No Opportunity records were created, updated, deleted, or bulk modified.

## Business Summary

- **What was done:** Added the missing action schema files so Agentforce can execute and display the two Opportunity recency search actions.
- **What was found:** The production fallback was consistent with missing action schemas: the topic existed, but the planner lacked executable input/output contracts for the new actions.
- **What this means:** The active production agent now has explicit schemas for the recency actions and should invoke them instead of giving a dashboard fallback.
- **What is next:** Human should refresh Agent Builder and start a new preview session before retesting the recency utterances.
- **Decision needed from Human:** Confirm whether the refreshed production preview now returns Opportunity rows.

## Next Operator
- Run next in: Human
- Reason: Backend metadata and action schemas are deployed; browser preview acceptance must be retested in a fresh Agent Builder session.
- Next prompt: Refresh Agent Builder for Astrum BD Agent v1, start a new Conversation Preview, and retest: "Search for opportunities created in last 5 days", "show me opportunities with no action in last 30 days", and "Search for opportunities with no action recently".
