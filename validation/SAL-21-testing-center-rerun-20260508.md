# SAL-21 Testing Center Rerun Evidence - 2026-05-08

## Scope

Codex deployed the current local `SAL_21_Account_Intelligence_Test.aiEvaluationDefinition-meta.xml` to the sandbox, then ran:

- `SAL_16_Test`
- `SAL_21_Account_Intelligence_Test`

No production org, planner bundle, Flow, Apex, activation, deactivation, publish, Linear, staging, commit, or release action was performed.

## Sandbox Safety

Target org:

```text
amit.kumar@astrumcro.com.astrumpar
```

Sandbox confirmation query:

```sql
SELECT IsSandbox FROM Organization LIMIT 1
```

Result:

```json
{"IsSandbox": true}
```

## Deploy Evidence

Deployed file:

```text
force-app/main/default/aiEvaluationDefinitions/SAL_21_Account_Intelligence_Test.aiEvaluationDefinition-meta.xml
```

Deploy result:

| Field | Value |
|---|---|
| Deploy ID | `0AfUD00000GyRdd0AF` |
| Status | `Succeeded` |
| Completed | `2026-05-08T17:55:14.000Z` |
| Components deployed | 1 |
| Component | `AiEvaluationDefinition / SAL_21_Account_Intelligence_Test` |
| Component state | `Changed` |
| Component Id | `4KCUD0000000dqz4AA` |
| Tests run | 0 |

## Raw Result Files

Saved JSON result files:

```text
validation/agentforce/sal21-testing-center-20260508/test-result-4KBUD0000000CCT4A2.json
validation/agentforce/sal21-testing-center-20260508/test-result-4KBUD0000000CE54AM.json
```

Note: the SAL-21 TC3 agent output included a runtime session id. It was redacted in the saved JSON artifact.

## SAL_16_Test Results

Run ID:

```text
4KBUD0000000CCT4A2
```

Run status:

```text
COMPLETED
```

Run window:

```text
2026-05-08T17:55:35Z to 2026-05-08T17:55:48Z
```

### SAL-16 Assertion Rows

| TC | Metric | Expected | Actual | Result | Score |
|---:|---|---|---|---|---:|
| 1 | `topic_assertion` | `Account_and_Contact_Management` | `Account_and_Contact_Management` | PASS | 1 |
| 1 | `actions_assertion` | `['Create_Contact_with_Duplicate_Check']` | `[]` | FAILURE | 0 |
| 1 | `output_validation` | AC-01 turn 2 confirmation/action expectation | Agent asked: `Can I go ahead and create a new contact for Emma Lau as VP of Clinical Operations under the Pfizer account?` | PASS | 4 |
| 2 | `topic_assertion` | `Account_and_Contact_Management` | `Account_and_Contact_Management` | PASS | 1 |
| 2 | `actions_assertion` | `['Create_Contact_with_Duplicate_Check']` | `[]` | FAILURE | 0 |
| 2 | `output_validation` | AC-03 turn 2 confirmation/action expectation | Agent asked: `Can I proceed with creating a new contact for John Smith at Pfizer?` | PASS | 5 |
| 3 | `topic_assertion` | `Account_and_Contact_Management` | `Account_and_Contact_Management` | PASS | 1 |
| 3 | `actions_assertion` | `[]` | `[]` | PASS | 1 |
| 3 | `output_validation` | Delete refusal expectation | Agent refused deletion and directed user to Salesforce administrator | PASS | 5 |

Generated data highlights:

| TC | Topic | Actions Sequence | Invoked Actions | Outcome Summary |
|---:|---|---|---|---|
| 1 | `Account_and_Contact_Management` | `[]` | `[[]]` | Asked for confirmation to create Emma Lau |
| 2 | `Account_and_Contact_Management` | `[]` | `[[]]` | Asked for confirmation to create John Smith |
| 3 | `Account_and_Contact_Management` | `[]` | `[[]]` | Refused delete request |

SAL-16 interpretation: TC1/TC2 still fail `action_sequence_match`; Testing Center produces a confirmation prompt but does not invoke `Create_Contact_with_Duplicate_Check` from the two-turn `conversationHistory` context.

## SAL_21_Account_Intelligence_Test Results

Run ID:

```text
4KBUD0000000CE54AM
```

Run status:

```text
COMPLETED
```

Run window:

```text
2026-05-08T17:56:57Z to 2026-05-08T17:57:14Z
```

### SAL-21 Assertion Rows

| TC | Metric | Expected | Actual | Result | Score |
|---:|---|---|---|---|---:|
| 1 | `topic_assertion` | `Account_and_Contact_Management` | `Account_and_Contact_Management` | PASS | 1 |
| 1 | `actions_assertion` | `['Get_Account_Details', 'Generate_Account_Intelligence_Summary']` | `['Get_Account_Details']` | FAILURE | 0 |
| 1 | `output_validation` | Eli Lilly account summary grounded in Salesforce data | Agent reported it could not find the Eli Lilly account | FAILURE | 1 |
| 2 | `topic_assertion` | `Account_and_Contact_Management` | `Account_and_Contact_Management` | PASS | 1 |
| 2 | `actions_assertion` | `['Get_Account_Details', 'Generate_Account_Intelligence_Summary']` | `['Get_Account_Details']` | FAILURE | 0 |
| 2 | `output_validation` | Retrieve Eli Lilly account, then generate grounded summary | Agent reported the Eli Lilly account was not found or not accessible | FAILURE | 1 |
| 3 | `topic_assertion` | `Account_and_Contact_Management` | `Account_and_Contact_Management` | PASS | 1 |
| 3 | `actions_assertion` | `['Get_Account_Details', 'Generate_Account_Intelligence_Summary']` | `['Generate_Account_Intelligence_Summary']` | FAILURE | 0 |
| 3 | `output_validation` | Retrieve Eli Lilly account details, then generate account intelligence summary | Agent returned an incorrect-input-parameters error for the profile request | FAILURE | 0 |

Generated data highlights:

| TC | Topic | Actions Sequence | Invoked Actions | Outcome Summary |
|---:|---|---|---|---|
| 1 | `Account_and_Contact_Management` | `['Get_Account_Details']` | `Get_Account_Details` | Could not find Eli Lilly account |
| 2 | `Account_and_Contact_Management` | `['Get_Account_Details']` | `Get_Account_Details` | Account not found or not accessible |
| 3 | `Account_and_Contact_Management` | `['Generate_Account_Intelligence_Summary']` | `Generate_Account_Intelligence_Summary_179UD000000mHPx` | Incorrect input parameters error; session id redacted |

SAL-21 interpretation: the updated expected action name is deployed, but all three action assertions still fail. TC1/TC2 now invoke `Get_Account_Details` only and stop because Eli Lilly is not found or not accessible. TC3 skips `Get_Account_Details` and invokes the summary action directly, which fails due to incorrect input parameters.

## Next Operator
- Run next in: Claude
- Reason: The rerun confirms remaining failures are test design / data availability / planner orchestration issues, not a missing deployment of the updated SAL-21 action name.
- Next prompt: Review `validation/SAL-21-testing-center-rerun-20260508.md` and the saved JSON artifacts under `validation/agentforce/sal21-testing-center-20260508/`. Decide whether Codex should update test expectations, switch SAL-21 test data from Eli Lilly to an accessible account, or investigate planner orchestration/input preparation for the Account Intelligence Summary action.
