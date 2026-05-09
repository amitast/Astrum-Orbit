# SAL-21 Account Intelligence Testing Center Run

Date/time of execution: 2026-05-09T09:02:02+01:00
Agent: Codex

## Sandbox safety confirmation

| Field | Value |
|---|---|
| Target org | amit.kumar@astrumcro.com.astrumpar |
| Org name | ASTRUM CRO, SL |
| Org ID | 00DUD000007zF692AE |
| IsSandbox | true |
| Instance | SWE92S |

Safety query:

```powershell
& "$env:APPDATA\npm\sf.cmd" data query --query "SELECT Id, Name, IsSandbox, InstanceName FROM Organization LIMIT 1" --target-org amit.kumar@astrumcro.com.astrumpar --json
```

## Evaluation definition deploy

Initial deploy attempt before Claude-authorized description trim:

| Field | Value |
|---|---|
| Deploy ID | 0AfUD00000Gyd5J0AR |
| Status | Failed |
| Components deployed | 0 |
| Component errors | 1 |
| Failure | Evaluation definition description exceeded 255 characters |

Claude-authorized redeploy after description-only trim:

| Field | Value |
|---|---|
| Deploy ID | 0AfUD00000GydBl0AJ |
| Status | Succeeded |
| Components deployed | 1 |
| Component errors | 0 |
| Component | AiEvaluationDefinition:SAL_21_Account_Intelligence_Test |

Deploy command:

```powershell
& "$env:APPDATA\npm\sf.cmd" project deploy start --metadata "AiEvaluationDefinition:SAL_21_Account_Intelligence_Test" --target-org amit.kumar@astrumcro.com.astrumpar --json
```

## Testing Center run

Requested command used `--name`, but installed Salesforce CLI 2.133.4 reports `--name` as a nonexistent flag for `sf agent test run`. CLI help confirms the current equivalent flag is `--api-name`, which maps to the AiEvaluationDefinition metadata API name.

Run command executed:

```powershell
& "$env:APPDATA\npm\sf.cmd" agent test run --api-name "SAL_21_Account_Intelligence_Test" --target-org amit.kumar@astrumcro.com.astrumpar --wait 10 --result-format json --verbose --json
```

| Field | Value |
|---|---|
| Test job ID | 4KBUD0000000CHJ4A2 |
| Status | COMPLETED |
| Start time | 2026-05-09T07:59:54Z |
| End time | 2026-05-09T08:00:28Z |
| Results JSON path | validation/agentforce/sal21-account-intelligence-20260509/test-result-4KBUD0000000CHJ4A2.json |

## Per-test-case results

| TC | Utterance | topic_sequence_match | action_sequence_match | bot_response_rating |
|----|-----------|----------------------|-----------------------|---------------------|
| 1 | Give me a summary of the Pfizer account. | PASS | FAIL | FAIL |
| 2 | Summarise what we know about Pfizer. | PASS | FAIL | FAIL |
| 3 | Give me an account intelligence profile for Pfizer. | PASS | FAIL | FAIL |

## Action name format observed

Testing Center recorded two action-name formats:

| Source | Recorded value |
|---|---|
| `generatedData.actionsSequence` TC1 and TC2 | `['Generate_Account_Intelligence_Summary']` |
| `generatedData.invokedActions` TC1 and TC2 | `Generate_Account_Intelligence_Summary_179UD000000mHPx` |
| `generatedData.actionsSequence` TC3 | `[]` |
| `generatedData.invokedActions` TC3 | `[]` |

The `action_sequence_match` assertion compared against the short local action name format. Actual values were:

| TC | Expected | Actual | Result |
|---|---|---|---|
| 1 | `['Get_Account_Details', 'Generate_Account_Intelligence_Summary']` | `['Generate_Account_Intelligence_Summary']` | FAIL |
| 2 | `['Get_Account_Details', 'Generate_Account_Intelligence_Summary']` | `['Generate_Account_Intelligence_Summary']` | FAIL |
| 3 | `['Get_Account_Details', 'Generate_Account_Intelligence_Summary']` | `[]` | FAIL |

Assertion correction was not required and was not applied. The failure was not caused by Testing Center comparing against the suffixed full action name. The failure was caused by the agent not invoking `Get_Account_Details` before the prompt action in TC1 and TC2, and invoking no actions in TC3.

## Bot response summary

| TC | Result detail |
|---|---|
| 1 | Bot returned an error/clarification response instead of a grounded Pfizer summary. |
| 2 | Bot returned a generic error response instead of retrieving Pfizer account data. |
| 3 | Output validation failed with status ERROR and message `Skip metric result due to missing expected input`; no action was invoked. |

## Guardrail confirmation

| Guardrail | Result |
|---|---|
| Production not touched | Confirmed |
| Target org was sandbox ASTRUMPAR only | Confirmed |
| Prompt template not activated or deactivated | Confirmed |
| Agent not activated or deactivated | Confirmed |
| Planner bundle not modified | Confirmed |
| No action assertion metadata correction applied | Confirmed |
| SAL-21 Linear status not moved to Done, Closed, or Production Ready | Confirmed |

## Files changed

| File | Reason |
|---|---|
| force-app/main/default/aiEvaluationDefinitions/SAL_21_Account_Intelligence_Test.aiEvaluationDefinition-meta.xml | Claude-authorized description-only trim from 275 to 204 characters; no test logic touched |
| validation/SAL-21-account-intelligence-testing-center-20260509.md | Evidence for SAL-21 deploy and Testing Center run |
| validation/agentforce/sal21-account-intelligence-20260509/test-result-4KBUD0000000CHJ4A2.json | Full Testing Center JSON result |

## Next Operator
- Run next in: Claude
- Reason: Review SAL-21 Testing Center TC1-TC3 pass/fail results and determine whether planner/action routing changes are required.
- Next prompt: Review SAL-21 Testing Center evidence in `validation/SAL-21-account-intelligence-testing-center-20260509.md` and full JSON result `validation/agentforce/sal21-account-intelligence-20260509/test-result-4KBUD0000000CHJ4A2.json`. Evaluation definition deploy succeeded (`0AfUD00000GydBl0AJ`) and test run completed (`4KBUD0000000CHJ4A2`). Topic routing passed all three cases; action sequence and bot response checks failed all three. Testing Center action assertion used the short action name `Generate_Account_Intelligence_Summary`, so no suffixed-name assertion correction was required.
