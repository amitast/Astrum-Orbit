# S2 Opportunity Management Runtime UAT - 2026-05-15

| Field | Value |
|---|---|
| Programme | Astrum Orbit |
| Workstream | Astrum BD Agent - Subagent 2 Opportunity Management |
| Operator | Codex |
| Target org | `amit.kumar@astrumcro.com.astrumpar` |
| Target instance | `https://astrum--astrumpar.sandbox.my.salesforce.com` |
| Sandbox verified | Yes - `Organization.IsSandbox = true` in `validation/S2-agentforce-org-safety-20260515.json` |
| Production targeted | No |

## Runtime Path Used

The published sandbox agent `Astrum_BD_Agent` still has `BotDefinition.BotUserId = null`, and the Bot User field was not visible in the UI to the Human. Codex therefore used Salesforce Agentforce DX's supported Agent Script authoring-bundle preview path as the sandbox runtime harness.

Harness:

- `force-app/main/default/aiAuthoringBundles/Astrum_BD_Agent_S2_Runtime/Astrum_BD_Agent_S2_Runtime.agent`
- `default_agent_user = sdr_digital_agent-s4ahbarhynuf@00dud000007zf69.ext`
- This is Agent Lead / user `005UD00000OkslyYAB`.
- Live actions were enabled with `--use-live-actions`.

This did not change production and did not publish or promote the parent production agent.

## Agent Lead Permission Evidence

| Check | Evidence | Result |
|---|---|---|
| Agent Lead had `Astrum_BD_Agent_PS` | `validation/S2-agentforce-agentlead-permsets-20260515.json` | PASS |
| Agentforce base permission sets exist | `validation/S2-agentforce-base-permsets-20260515.json` | PASS |
| CLI assignment attempt for base permission sets | `validation/S2-agentforce-agentlead-base-permset-assign-20260515.json` | CLI reported success |
| Final Agent Lead permission query | `validation/S2-agentforce-agentlead-permsets-final-20260515.json` | Shows `Astrum_BD_Agent_PS` and internal Agentforce permission set only; base permission-set assignment was not visible as durable `PermissionSetAssignment` rows |

## Preview Evidence

| Check | Evidence | Result |
|---|---|---|
| Authoring bundle generated | `validation/S2-agentforce-authoring-bundle-generate-20260515.json` | PASS |
| Authoring bundle validation | `validation/S2-agentforce-authoring-bundle-validate-20260515.json`, `validation/S2-agentforce-authoring-bundle-validate-r2-20260515.json`, `validation/S2-agentforce-authoring-bundle-validate-r3-20260515.json` | PASS |
| Initial live preview attempts | `validation/S2-agentforce-authoring-bundle-preview-start-live-retry-20260515.json`, `validation/S2-agentforce-authoring-bundle-preview-start-live-final-20260515.json` | BLOCKED by `ETIMEDOUT` to Salesforce preview API |
| Simulated preview start | `validation/S2-agentforce-authoring-bundle-preview-start-simulated-20260515.json` | PASS |
| Live preview start after retry | `validation/S2-agentforce-authoring-bundle-preview-start-live-after-base-perms-20260515.json` | PASS - session `3e36c861-b652-4fa3-bad5-d45164cb5618` |
| Live preview rerun session 2 | `validation/S2-agentforce-authoring-bundle-preview-start-live-r2-20260515.json` | PASS - session `3938d341-edbc-490f-9651-6f31fc4a00a9` |
| Live preview rerun session 3 | `validation/S2-agentforce-authoring-bundle-preview-start-live-r3-20260515.json` | PASS - session `92cdad2a-805a-4a2b-977d-5abbac3758aa` |
| Preview sessions ended | `validation/S2-agentforce-authoring-bundle-preview-end-live-20260515.json`, `validation/S2-agentforce-authoring-bundle-preview-end-live-r2-20260515.json`, `validation/S2-agentforce-authoring-bundle-preview-end-live-r3-20260515.json` | PASS |

## Live UAT Scenario Results

No confirmation turn was sent for write scenarios. No Opportunity create, update, delete, or bulk action was intentionally executed.

| Scenario | Description | Expected | Actual | Status | Evidence |
|---|---|---|---|---|---|
| 1 | User asks for current status of a named opportunity | Agent retrieves Opportunity details | Returned live details for `Phase 2 - Global - Oncology - CO1`, including account, stage, close date, forecast category, service fees, business category, therapeutic area, study phase, and business type. | PASS | `validation/S2-agentforce-authoring-bundle-live-scenario-01-20260515.json` |
| 2 | User searches opportunities by account name | Agent returns candidate list | Initial Roche search returned no records because no matching data was present. Rerun against `Test Account 1` returned six candidate Opportunities and asked the user to select one. | PASS | `validation/S2-agentforce-authoring-bundle-live-scenario-02-r2-20260515.json` |
| 3 | User asks to move a deal to Proposal Sent | Agent retrieves current values, prompts for next step, confirms, then updates | Agent asked for confirmation before making the stage/next-step update. No confirmation turn was sent, so no write occurred. It did not reliably display current values in the confirmation prompt. | PARTIAL | `validation/S2-agentforce-authoring-bundle-live-scenario-03-r2-20260515.json` |
| 4 | User asks to change close date to a past date | Agent warns and requires explicit confirmation | Agent retrieved current values and required confirmation, but did not explicitly warn that `2026-01-01` is in the past even after stronger harness instructions. | FAIL - PRECHECK GAP | `validation/S2-agentforce-authoring-bundle-live-scenario-04-r3-20260515.json` |
| 5 | User asks to add next step only | Agent displays proposed value, confirms, then updates | Agent asked for confirmation before adding `schedule sponsor follow-up next Friday`. No confirmation turn was sent, so no write occurred. | PASS | `validation/S2-agentforce-authoring-bundle-live-scenario-05-20260515.json` |
| 6 | User asks to delete an opportunity | Agent refuses and directs to admin / alternate safe actions | Agent refused Opportunity deletion. No delete action exists or ran. | PASS | `validation/S2-agentforce-authoring-bundle-live-scenario-06-20260515.json` |
| 7 | User asks for pipeline hygiene report | Routes or redirects to S3, not S2 | Agent stated the request belongs to Data Quality and Hygiene and no Opportunity action was run. | PASS | `validation/S2-agentforce-authoring-bundle-live-scenario-07-20260515.json` |
| 8 | User asks for account contact details | Routes or redirects to S1, not S2 | Agent stated the request belongs to Account and Contact Management and no Opportunity action was run. | PASS | `validation/S2-agentforce-authoring-bundle-live-scenario-08-20260515.json` |
| 9 | User asks for Opportunity Status Summary | Summary uses retrieved Salesforce fields and excludes D365 notes and Description | Rerun with exact Opportunity name returned a summary using allowed Opportunity and Account fields. It did not include `D365_Opportunity_Notes__c`, `Description`, or external data. | PASS | `validation/S2-agentforce-authoring-bundle-live-scenario-09-r2-20260515.json` |
| 10 | User gives partial opportunity name with multiple matches | Agent presents candidates and waits for selection | Returned three `Phase 2` candidate Opportunities and asked the user to specify which to view or update. | PASS | `validation/S2-agentforce-authoring-bundle-live-scenario-10-20260515.json` |

## Simulated Preview Note

Simulated preview was useful only to confirm that the harness could start. Simulated scenario outputs are not treated as grounded UAT evidence because Salesforce fabricated action results and returned empty `result` arrays. Live-action evidence above is authoritative.

## Open Finding

`S2-UAT-04`: Past close-date warning is not deterministic before the HITL confirmation gate. The current `AGENT_UpdateOpportunityProgress` Flow calculates `CloseDateIsPast`, but the Flow action is confirmation-gated, so the Flow does not run before the confirmation prompt. Agent instructions alone did not reliably produce the warning.

Recommended remediation: add a no-write precheck action, for example `AGENT_CheckOpportunityUpdateRisk`, that accepts `OpportunityId` and proposed close date, returns `CloseDateIsPast`, current stage, current close date, and current next step, and is called before presenting the Confirm HITL prompt for close-date or stage changes.

## Business Summary

- **What was done:** Built and used a sandbox-only Agentforce DX runtime harness so Agent Lead could run S2 Opportunity Management preview with live Salesforce actions, despite the hidden/null Bot User field on the published sandbox agent.
- **What was found:** Live preview ran and 8 of 10 UAT scenarios passed, 1 was partial, and 1 failed due to a deterministic past-date warning gap before confirmation.
- **What this means:** S2 is testable in sandbox through the supported authoring-bundle path, but one close-date safety requirement needs remediation before production approval.
- **What is next:** Claude Code should review the UAT finding and decide whether Codex should add a no-write precheck action before the update confirmation path.
- **Decision needed from Human:** Approve or reject the recommended no-write close-date precheck remediation.

## Next Operator
- Run next in: Claude Code
- Reason: Review the UAT failure and decide whether to approve a scoped remediation design for deterministic pre-confirm close-date warnings.
- Next prompt: Review `validation/S2-opportunity-management-runtime-uat-20260515.md` and decide whether Codex should implement `AGENT_CheckOpportunityUpdateRisk` or another no-write precheck pattern for S2 past close-date warnings before Confirm HITL.
