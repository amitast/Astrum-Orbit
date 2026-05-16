# SAL-24 Recency Search Fix Evidence

Date: 2026-05-16  
Agent: Codex  
Target workstream: SAL-24 - Astrum BD Agent S2 Opportunity Management  
Issue: User utterances for recent/stale Opportunity searches produced no useful result.

## User Utterances Fixed

| Utterance | Expected behaviour after fix |
|---|---|
| `show me opportunities with no action in last 30 days` | Route to Search Opportunities with `NoActionInLastDays = 30`; return up to 10 Opportunities where `Last_client_interaction_date__c` is blank or older than 30 days. |
| `Search for opportunities with no action recently` | Route to Search Opportunities with default `NoActionInLastDays = 30`; return stale/no-action Opportunities. |
| `show me opportunities created in last 7 days` | Route to Search Opportunities with `CreatedInLastDays = 7`; return up to 10 recently created Opportunities. |

## Code And Metadata Changes

| File | Change |
|---|---|
| `force-app/main/default/classes/AGENT_SearchOpportunities.cls` | Added read-only `NoActionInLastDays` and `CreatedInLastDays` filters; query output now includes Created Date, Last Client Interaction, and Next Step. |
| `force-app/main/default/classes/AGENT_OpportunityActions_Test.cls` | Added tests for no-recent-action and created-in-last-days searches. |
| `force-app/main/default/genAiPlannerBundles/Astrum_BD_Agent/Astrum_BD_Agent.genAiPlannerBundle` | Added utterances and routing instructions so these requests invoke Search Opportunities instead of falling through or being treated as unsupported hygiene reports. |

No write action was added. No bulk Opportunity update was added. No delete path was added. No standard `Probability` logic was added.

## Sandbox Validation And Deploy

| Step | Deploy ID | Status | Tests |
|---|---|---|---|
| Sandbox validate-only | 0AfUD00000H5KxB0AV | Succeeded | `AGENT_OpportunityActions_Test` 10/10 |
| Sandbox deploy | 0AfUD00000H5Kyn0AF | Succeeded | `AGENT_OpportunityActions_Test` 10/10 |

Sandbox org safety check: `IsSandbox = true` for `amit.kumar@astrumcro.com.astrumpar`.

## Production Deployment

Production org safety check: `IsSandbox = false` for `astrum-prod`.

| Step | Deploy ID | Status | Tests |
|---|---|---|---|
| Production Apex validate-only | 0AfTY000003pbYT0AY | Succeeded | `AGENT_OpportunityActions_Test` 10/10 |
| Production Apex quick deploy | 0AfTY000003pbNC0AY | Succeeded | Quick deploy from validated job |
| Deactivate `Astrum_BD_Agent` v1 | n/a | Succeeded | Required because active agents cannot be updated |
| Production planner validate-only | 0AfTY000003pbbh0AA | Succeeded | `AGENT_OpportunityActions_Test` 10/10 |
| Production planner quick deploy | 0AfTY000003pbdJ0AQ | Succeeded | Quick deploy from validated job |
| Reactivate `Astrum_BD_Agent` v1 | n/a | Succeeded | Agent reactivated after planner deployment |

## Post-Deploy Verification

| Check | Result |
|---|---|
| Post-deploy Apex test run | PASS |
| Test run ID | 707TY00001FeSqr |
| Passing / failing / total | 10 / 0 / 10 |
| Production count: no action in last 30 days | 1,330 matching Opportunities |
| Production count: created in last 7 days | 5 matching Opportunities |

The production count checks were read-only aggregate SOQL checks. No Opportunity records were created, updated, deleted, or bulk modified by these checks.

## Business Summary

- **What was done:** Updated the Astrum BD Agent Opportunity search so users can ask for stale Opportunities and recently created Opportunities using natural utterances.
- **What was found:** Sandbox and production deployments passed. The production regression test suite passed 10/10, and production has matching records for both supported query types.
- **What this means:** The three reported utterances now have a concrete read-only S2 action path and should return Opportunity lists instead of no result.
- **What is next:** Human should retry the three utterances in the production Agent UI.
- **Decision needed from Human:** Confirm whether the production UI responses are acceptable for SAL-24 closure.

## Next Operator
- Run next in: Human
- Reason: The fix is deployed and tested; UI-level acceptance requires the user to retry the reported utterances in the live agent.
- Next prompt: Retest the three SAL-24 Opportunity recency utterances in production Agent UI and confirm whether SAL-24 can be closed.
