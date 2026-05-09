# SAL-21 Account Intelligence Testing Center Run

Date/time of execution: 2026-05-09T08:52:50+01:00
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

Deploy command:

```powershell
& "$env:APPDATA\npm\sf.cmd" project deploy start --metadata "AiEvaluationDefinition:SAL_21_Account_Intelligence_Test" --target-org amit.kumar@astrumcro.com.astrumpar --json
```

| Field | Value |
|---|---|
| Deploy ID | 0AfUD00000Gyd5J0AR |
| Status | Failed |
| Components deployed | 0 |
| Component errors | 1 |

Failure:

```text
AiEvaluationDefinition:SAL_21_Account_Intelligence_Test failed.
Evaluation Type: data value too large: SAL-21 account intelligence test spec for Astrum_BD_Agent. Validates Account_and_Contact_Management routing for account summary requests and asserts Get_Account_Details followed by Generate_Account_Intelligence_Summary. Test account: Pfizer (confirmed accessible in sandbox). (max length=255)
```

Per instruction, Testing Center execution did not proceed because the evaluation definition deploy failed.

## Testing Center result

| Field | Value |
|---|---|
| Test job ID | Not created |
| Results JSON path | Not created |
| Exact action name format recorded by Testing Center | Not observed |
| Assertion correction required and applied | Not assessed; no test run occurred |

| TC | Utterance | topic_sequence_match | action_sequence_match | bot_response_rating |
|----|-----------|----------------------|-----------------------|---------------------|
| 1 | Give me a summary of the Pfizer account. | NOT RUN | NOT RUN | NOT RUN |
| 2 | Summarise what we know about Pfizer. | NOT RUN | NOT RUN | NOT RUN |
| 3 | Give me an account intelligence profile for Pfizer. | NOT RUN | NOT RUN | NOT RUN |

## Guardrail confirmation

| Guardrail | Result |
|---|---|
| Production not touched | Confirmed |
| Target org was sandbox ASTRUMPAR only | Confirmed |
| Prompt template not activated or deactivated | Confirmed |
| Agent not activated or deactivated | Confirmed |
| Planner bundle not modified | Confirmed |
| No metadata edited beyond approved scope | Confirmed |

## Files changed

| File | Reason |
|---|---|
| validation/SAL-21-account-intelligence-testing-center-20260509.md | Evidence for halted SAL-21 Testing Center run |

## Next Operator
- Run next in: Claude
- Reason: Review deploy failure and decide whether to authorize a scoped evaluation definition description correction before Codex retries the deploy and Testing Center run.
- Next prompt: Review SAL-21 evidence file `validation/SAL-21-account-intelligence-testing-center-20260509.md`. The AiEvaluationDefinition deploy failed because the description value exceeds the 255-character org limit. Decide whether to authorize Codex to shorten the evaluation definition description, redeploy `AiEvaluationDefinition:SAL_21_Account_Intelligence_Test`, run Testing Center, and update Linear with the completed results.
