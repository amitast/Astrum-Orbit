# S2 Opportunity Update Risk Precheck Wiring Validation - 2026-05-15

| Field | Value |
|---|---|
| Programme | Astrum Orbit |
| Workstream | Astrum BD Agent - Subagent 2 Opportunity Management |
| Linear issue | SAL-24 |
| Operator | Codex |
| Target org | `amit.kumar@astrumcro.com.astrumpar` |
| Target instance | `https://astrum--astrumpar.sandbox.my.salesforce.com` |
| Sandbox verified | Yes - `Organization.IsSandbox = true` in `validation/S2-precheck-org-safety-20260515.json` |
| Production targeted | No |

## Scope

Codex wired the new no-write precheck Flow into the S2 Opportunity Management action path before `AGENT_UpdateOpportunityProgress`.

Changed metadata:

- `force-app/main/default/flows/AGENT_CheckOpportunityUpdateRisk.flow-meta.xml`
- `force-app/main/default/permissionsets/Astrum_BD_Agent_PS.permissionset-meta.xml`
- `force-app/main/default/genAiPlannerBundles/Astrum_BD_Agent/Astrum_BD_Agent.genAiPlannerBundle`
- `force-app/main/default/aiAuthoringBundles/Astrum_BD_Agent_S2_Runtime/Astrum_BD_Agent_S2_Runtime.agent`

## Metadata Changes

| Component | Change |
|---|---|
| `AGENT_CheckOpportunityUpdateRisk` | New autolaunched, user-context, read-only Flow. Retrieves current Opportunity Name, StageName, CloseDate, and NextStep. Returns `CloseDateIsPast` when proposed close date is earlier than current date. |
| `Astrum_BD_Agent_PS` | Added Flow access for `AGENT_CheckOpportunityUpdateRisk`. |
| `Astrum_BD_Agent` planner bundle | Added autonomous `Check_Opportunity_Update_Risk` local action. Updated Opportunity Management instructions so stage/close-date changes call the precheck before Confirm HITL update. |
| `Astrum_BD_Agent_S2_Runtime` authoring bundle | Added matching runtime harness action for live preview validation. |

## Validation Evidence

| Check | Evidence | Result |
|---|---|---|
| Local XML parse | Shell XML parse for Flow, permission set, and planner bundle | PASS |
| Read-only Flow scan | No `<recordCreates>`, `<recordUpdates>`, `<recordDeletes>`, `<screens>`, or `<actionCalls>` in the Flow | PASS |
| Authoring bundle compile | `validation/S2-precheck-authoring-bundle-validate-20260515.json` | PASS |
| Sandbox validate-only deploy | `validation/S2-precheck-wiring-deploy-dry-run-20260515.json` | PASS - deploy ID `0AfUD00000H4EXF0A3`, 3 components, 0 tests |
| Sandbox deploy | `validation/S2-precheck-wiring-deploy-sandbox-20260515.json` | PASS - deploy ID `0AfUD00000H4DT80AN`, 3 components, 0 tests |
| FlowDefinition post-deploy | `validation/S2-precheck-flowdefinition-postdeploy-20260515.json` | PASS - `AGENT_CheckOpportunityUpdateRisk`, ActiveVersionId `301UD00000WoDCaYAN` |
| Permission set Flow access | `validation/S2-precheck-flowaccess-postdeploy-r2-20260515.json` | PASS - `Astrum_BD_Agent_PS` has FlowDefinition access row for `300UD00000Rdv3lYAB` |
| Live Agentforce preview | `validation/S2-precheck-preview-past-close-date-20260515.json` | PASS - agent warned proposed close date is in the past before asking for confirmation |
| No write after preview | `validation/S2-precheck-opportunity-close-date-after-preview-20260515.json` | PASS - `Phase 2 - Global - Oncology - CO1` CloseDate remained `2046-08-16` |

## Deploy Evidence

Validate-only deploy:

- Deploy ID: `0AfUD00000H4EXF0A3`
- Target org: `astrum--astrumpar.sandbox.my.salesforce.com`
- Timestamp: `2026-05-15T06:00:24.000Z`
- Check only: `true`
- Components validated: Flow `AGENT_CheckOpportunityUpdateRisk`, PermissionSet `Astrum_BD_Agent_PS`, GenAiPlannerBundle `Astrum_BD_Agent`
- Tests: 0 run, no Apex in scope
- Result: Succeeded

Sandbox deploy:

- Deploy ID: `0AfUD00000H4DT80AN`
- Target org: `astrum--astrumpar.sandbox.my.salesforce.com`
- Timestamp: `2026-05-15T06:10:58.000Z`
- Components deployed: Flow `AGENT_CheckOpportunityUpdateRisk`, PermissionSet `Astrum_BD_Agent_PS`, GenAiPlannerBundle `Astrum_BD_Agent`
- Tests: 0 run, no Apex in scope
- Result: Succeeded

## Runtime Scenario

Utterance:

```text
Change the close date on Phase 2 - Global - Oncology - CO1 to 1 January 2026.
```

Observed response:

```text
The current close date for "Phase 2 - Global - Oncology - CO1" is 16 August 2046. You requested to change it to 1 January 2026.

Warning: The proposed close date is in the past compared to today (15 May 2026). This may impact reporting and pipeline accuracy.

Do you want to proceed and update the close date to 1 January 2026? Please confirm before I save the change.
```

No confirmation turn was sent. No Opportunity update was performed.

## Business Summary

- **What was done:** Added and wired a read-only precheck before S2 Opportunity progress updates so the agent can warn users when a proposed close date is in the past before asking for confirmation.
- **What was found:** Sandbox validate-only and deploy both passed. Live preview confirmed the agent now warns on the past close date before Confirm HITL.
- **What this means:** The prior S2 UAT close-date warning gap is remediated in sandbox.
- **What is next:** Review the deployed sandbox behavior and decide whether to include this remediation in the next production approval package.
- **Decision needed from Human:** Approve whether this sandbox remediation should proceed toward production readiness review.

## Next Operator
- Run next in: Human
- Reason: The S2 close-date precheck remediation is deployed and validated in sandbox; Human owns production readiness decisions.
- Next prompt: Review `validation/S2-precheck-wiring-validation-20260515.md` and decide whether to approve S2 Opportunity Management for production readiness review.
