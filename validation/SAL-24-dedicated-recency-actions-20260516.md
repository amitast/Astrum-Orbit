# SAL-24 Dedicated Recency Actions Evidence

Date: 2026-05-16  
Agent: Codex  
Target workstream: SAL-24 - Astrum BD Agent S2 Opportunity Management  
Reason: Agent Builder selected Opportunity Management for recency utterances but did not invoke the generic Search Opportunities action.

## Issue Observed

The Human supplied a production Agent Builder screenshot showing this utterance:

`Search for opportunities created in last 5 days`

The agent selected the Opportunity Management subagent but returned a conversational fallback saying it could not directly search. No action was invoked.

## Fix Applied

To make action selection deterministic, Codex added two purpose-built read-only Apex actions with literal user-facing labels:

| Action label | Apex class | Purpose |
|---|---|---|
| Find Opportunities Created Recently | `AGENT_FindRecentOpportunities` | Handles "opportunities created in last N days" and "created recently". |
| Find Opportunities With No Recent Action | `AGENT_FindStaleOpportunities` | Handles "no action in last N days", "no action recently", "stale activity", and "no recent client interaction". |

The planner bundle now links both actions directly under Opportunity Management and includes explicit instructions not to answer these utterances from memory or send the user to a dashboard.

## Files Changed

| File | Change |
|---|---|
| `force-app/main/default/classes/AGENT_FindRecentOpportunities.cls` | New read-only invocable Apex action for created-recently searches. |
| `force-app/main/default/classes/AGENT_FindRecentOpportunities.cls-meta.xml` | Apex metadata. |
| `force-app/main/default/classes/AGENT_FindStaleOpportunities.cls` | New read-only invocable Apex action for no-recent-action searches. |
| `force-app/main/default/classes/AGENT_FindStaleOpportunities.cls-meta.xml` | Apex metadata. |
| `force-app/main/default/classes/AGENT_OpportunityActions_Test.cls` | Added tests for the two dedicated actions. |
| `force-app/main/default/permissionsets/Astrum_BD_Agent_PS.permissionset-meta.xml` | Added Apex class access for the two new actions. |
| `force-app/main/default/genAiPlannerBundles/Astrum_BD_Agent/Astrum_BD_Agent.genAiPlannerBundle` | Added local action links, local actions, utterances, and deterministic routing instructions. |

## Sandbox Evidence

| Step | Deploy ID | Status | Tests |
|---|---|---|---|
| Sandbox validate-only | 0AfUD00000H5JY60AN | Succeeded | `AGENT_OpportunityActions_Test` 12/12 |
| Sandbox deploy | 0AfUD00000H5N5R0AV | Succeeded | `AGENT_OpportunityActions_Test` 12/12 |

## Production Evidence

Production safety check confirmed `astrum-prod` has `IsSandbox = false`.

| Step | Deploy ID | Status | Tests |
|---|---|---|---|
| Production Apex + PermissionSet validate-only | 0AfTY000003pdbt0AA | Succeeded | `AGENT_OpportunityActions_Test` 12/12 |
| Production Apex + PermissionSet quick deploy | 0AfTY000003pddV0AQ | Succeeded | Quick deploy from validated job |
| Deactivate `Astrum_BD_Agent` v1 | n/a | Succeeded | Required to update active agent planner |
| Production planner validate-only | 0AfTY000003pdqP0AQ | Succeeded | `AGENT_OpportunityActions_Test` 12/12 |
| Production planner quick deploy | 0AfTY000003pds10AA | Succeeded | Quick deploy from validated job |
| Reactivate `Astrum_BD_Agent` v1 | n/a | Succeeded | Agent active again |

## Post-Deploy Verification

| Check | Result |
|---|---|
| `AGENT_FindRecentOpportunities` production class | Active |
| `AGENT_FindStaleOpportunities` production class | Active |
| Post-deploy production test run | `707TY00001FebZT`, 12/12 passing |
| Production count for no action in last 30 days | 1,330 matching Opportunities |
| Production count for created in last 5 days | 4 matching Opportunities |

The production count checks were read-only aggregate SOQL checks. No Opportunity records were created, updated, deleted, or bulk modified.

## Business Summary

- **What was done:** Added and deployed two dedicated Opportunity recency actions so the agent has exact action choices for recently created Opportunities and Opportunities with no recent action.
- **What was found:** Sandbox and production deployments succeeded. Production tests passed 12/12. Production contains matching records for the exact "created in last 5 days" query.
- **What this means:** The backend action path and planner wiring are now explicit and live; the reported utterances should no longer depend on the generic Search Opportunities action.
- **What is next:** Human should refresh Agent Builder/Conversation Preview and retry the reported utterances against active version 1.
- **Decision needed from Human:** Confirm whether the production UI now invokes the dedicated action and returns Opportunity rows.

## Next Operator
- Run next in: Human
- Reason: The deterministic action fix is deployed; UI preview acceptance must be confirmed in the browser.
- Next prompt: Refresh Agent Builder for Astrum BD Agent v1 and retest: "Search for opportunities created in last 5 days", "show me opportunities with no action in last 30 days", and "Search for opportunities with no action recently".
