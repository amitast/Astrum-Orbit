# SAL-24 Recency Output Bullet Format Evidence

Date: 2026-05-16  
Agent: Codex  
Target workstream: SAL-24 - Astrum BD Agent S2 Opportunity Management  
Issue: Human requested recency Opportunity listings in bullet points instead of table format.

## Change Made

Codex updated the two dedicated read-only Opportunity recency actions to return bullet-point output:

| Action | Apex class | Output change |
|---|---|---|
| Find Opportunities Created Recently | `AGENT_FindRecentOpportunities` | `ResultsSummary` now returns bullet-point listings. |
| Find Opportunities With No Recent Action | `AGENT_FindStaleOpportunities` | `ResultsSummary` now returns bullet-point listings. |

Each Opportunity is formatted as:

```text
- Opportunity: [Name]
  - Account: [Account]
  - Stage: [Stage]
  - Close Date: [Close Date]
  - Opp Probability: [Opp_Probability__c]
  - Code: [Opportunity_Code__c]
  - Created: [Created Date]
  - Last Client Interaction: [Last_client_interaction_date__c]
  - Next Step: [NextStep]
  - Owner: [Owner]
  - Id: [Id]
```

`OpportunityCount` remains planner-usable but not directly displayable.

## Files Changed

| File | Change |
|---|---|
| `force-app/main/default/classes/AGENT_FindRecentOpportunities.cls` | Changed recently created Opportunity output from table to bullet list. |
| `force-app/main/default/classes/AGENT_FindStaleOpportunities.cls` | Changed no-recent-action Opportunity output from table to bullet list. |
| `force-app/main/default/classes/AGENT_OpportunityActions_Test.cls` | Updated assertions to require bullet-point output. |
| `force-app/main/default/genAiPlannerBundles/Astrum_BD_Agent/localActions/Opportunity_Management/Find_Opportunities_Created_Recently/output/schema.json` | Updated output schema description to bullet-point list. |
| `force-app/main/default/genAiPlannerBundles/Astrum_BD_Agent/localActions/Opportunity_Management/Find_Opportunities_With_No_Recent_Action/output/schema.json` | Updated output schema description to bullet-point list. |

## Validation And Deploy Evidence

| Step | Deploy ID / Result | Status | Tests |
|---|---|---|---|
| Local diff check | `git diff --check` | PASS | n/a |
| Local schema JSON parse | `ConvertFrom-Json` | PASS | n/a |
| Sandbox validate-only | `0AfUD00000H5PTp0AN` | Succeeded | `AGENT_OpportunityActions_Test` 12/12 |
| Sandbox deploy | `0AfUD00000H5PVR0A3` | Succeeded | `AGENT_OpportunityActions_Test` 12/12 |
| Production safety gate | `Organization.IsSandbox = false` | PASS | n/a |
| Production agent deactivated | `success = true`, `version = 1` | Succeeded | n/a |
| Production validate-only | `0AfTY000003pf4D0AQ` | Succeeded | `AGENT_OpportunityActions_Test` 12/12 |
| Production quick deploy | `0AfTY000003pf5p0AA` | Succeeded | Quick deploy from validated job |
| Production agent reactivated | `success = true`, `version = 1` | Succeeded | n/a |

## No Data Mutation

This change updated Apex formatting logic and Agentforce output schema descriptions only. No Opportunity records were created, updated, deleted, or bulk modified.

## Business Summary

- **What was done:** Changed Opportunity recency results from table format to bullet-point listings.
- **What was found:** The previous table formatting was technically valid, but the requested user preference is bullet-point output.
- **What this means:** Production users should now see Opportunity recency search results as structured bullet points.
- **What is next:** Human should refresh Agent Builder and retest the recency search utterance in a new preview session.
- **Decision needed from Human:** Confirm whether the bullet-point presentation is acceptable.

## Next Operator
- Run next in: Human
- Reason: Bullet formatting is deployed; browser preview should verify the rendered output.
- Next prompt: Refresh Agent Builder for Astrum BD Agent v1 and retest "Search for opportunities created in last 5 days"; confirm the result displays as bullet-point listings.
