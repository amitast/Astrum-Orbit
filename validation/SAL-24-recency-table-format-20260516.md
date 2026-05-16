# SAL-24 Recency Output Table Format Evidence

Date: 2026-05-16  
Agent: Codex  
Target workstream: SAL-24 - Astrum BD Agent S2 Opportunity Management  
Issue: Production recency search action now returns data, but output was semicolon-delimited text with a raw count displayed as a separate number.

## Change Made

Codex updated the two dedicated read-only Opportunity recency actions to return Markdown table output:

| Action | Apex class | Output change |
|---|---|---|
| Find Opportunities Created Recently | `AGENT_FindRecentOpportunities` | `ResultsSummary` now returns a Markdown table. |
| Find Opportunities With No Recent Action | `AGENT_FindStaleOpportunities` | `ResultsSummary` now returns a Markdown table. |

The table columns are:

| Column |
|---|
| Opportunity |
| Account |
| Stage |
| Close Date |
| Opp Probability |
| Code |
| Created |
| Last Client Interaction |
| Next Step |
| Owner |
| Id |

Codex also changed both output schemas so `OpportunityCount` remains usable by the planner but is no longer directly displayable. This removes the loose standalone count that appeared after the result list.

## Files Changed

| File | Change |
|---|---|
| `force-app/main/default/classes/AGENT_FindRecentOpportunities.cls` | Changed recency result formatting from bullet text to Markdown table. |
| `force-app/main/default/classes/AGENT_FindStaleOpportunities.cls` | Changed no-recent-action result formatting from bullet text to Markdown table. |
| `force-app/main/default/classes/AGENT_OpportunityActions_Test.cls` | Added assertions that dedicated recency results contain a Markdown table header. |
| `force-app/main/default/genAiPlannerBundles/Astrum_BD_Agent/localActions/Opportunity_Management/Find_Opportunities_Created_Recently/output/schema.json` | Hid raw `OpportunityCount` from direct display and clarified table output description. |
| `force-app/main/default/genAiPlannerBundles/Astrum_BD_Agent/localActions/Opportunity_Management/Find_Opportunities_With_No_Recent_Action/output/schema.json` | Hid raw `OpportunityCount` from direct display and clarified table output description. |

## Validation And Deploy Evidence

| Step | Deploy ID / Result | Status | Tests |
|---|---|---|---|
| Local diff check | `git diff --check` | PASS | n/a |
| Local schema JSON parse | `ConvertFrom-Json` | PASS | n/a |
| Sandbox validate-only | `0AfUD00000H5NNB0A3` | Succeeded | `AGENT_OpportunityActions_Test` 12/12 |
| Sandbox deploy | `0AfUD00000H5NOn0AN` | Succeeded | `AGENT_OpportunityActions_Test` 12/12 |
| Production safety gate | `Organization.IsSandbox = false` | PASS | n/a |
| Production agent deactivated | `success = true`, `version = 1` | Succeeded | n/a |
| Production validate-only | `0AfTY000003pe9l0AA` | Succeeded | `AGENT_OpportunityActions_Test` 12/12 |
| Production quick deploy | `0AfTY000003peBN0AY` | Succeeded | Quick deploy from validated job |
| Production agent reactivated | `success = true`, `version = 1` | Succeeded | n/a |

## No Data Mutation

This change updated Apex formatting logic and Agentforce output schema metadata only. No Opportunity records were created, updated, deleted, or bulk modified.

## Business Summary

- **What was done:** Changed the Opportunity recency search results to return a table instead of long semicolon-separated text.
- **What was found:** The action was working, but the previous output was hard to scan and displayed the raw count as a loose number.
- **What this means:** Production users should now see cleaner, tabular Opportunity results for recently created and no-recent-action searches.
- **What is next:** Human should refresh Agent Builder and retest the recency search utterance in a new preview session.
- **Decision needed from Human:** Confirm whether the rendered table meets the desired presentation standard.

## Next Operator
- Run next in: Human
- Reason: Formatting metadata and Apex are deployed; browser preview should verify the rendered table.
- Next prompt: Refresh Agent Builder for Astrum BD Agent v1 and retest "Search for opportunities created in last 5 days"; confirm the result displays as a table without a standalone raw count.
