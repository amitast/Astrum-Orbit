# SAL-16 Create Contact AccountName Fix Evidence

## Objective

Fix the SAL-16 Agentforce Testing Center failure where `Create_Contact_with_Duplicate_Check` was not invoked for natural-language contact creation requests such as "Add Emma Lau at Pfizer."

## Root Cause Summary

Initial root cause confirmed locally. The action input contract required `AccountId`, but the user utterance supplies an Account name. The planner bundle topic has no lookup action to resolve an Account ID before invoking `AGENT_CreateContact`, so the required `AccountId` input was unsatisfied and the planner did not invoke the action.

After deploying the `AccountName` input-contract fix, Agentforce Testing Center still reported `actionsSequence = []` for AC-01 and AC-03. This means the `AccountId` contract issue has been removed from deployed metadata, but planner invocation remains unresolved and requires Architect review.

## Files Changed

- `force-app/main/default/genAiPlannerBundles/Astrum_BD_Agent/localActions/Account_and_Contact_Management/Create_Contact_with_Duplicate_Check/input/schema.json`
- `force-app/main/default/flows/AGENT_CreateContact.flow-meta.xml`
- `force-app/main/default/classes/AGENT_CreateContact_Test.cls`

## Exact Metadata Changes Made

- Replaced action input contract `AccountId` with required `AccountName`.
- Updated `AGENT_CreateContact` input variable from `AccountId` to `AccountName`.
- Updated `Get_Account` to filter `Account.Name = AccountName`.
- Added `Name` to the queried Account fields.
- Updated duplicate-by-name Contact lookup to filter Contact `AccountId` using `var_Account.Id`.
- Updated Contact create assignment to set Contact `AccountId` using `var_Account.Id`.
- Updated account-not-found message to: `Account not found. Verify the account name and your record access.`
- Updated `AGENT_CreateContact_Test` helper and test invocations to pass Account names.
- Updated TC-04 to use a non-existent Account name instead of a fake Account ID.

## Sandbox Safety Confirmation

Command:

```bash
sf data query --target-org amit.kumar@astrumcro.com.astrumpar --query 'SELECT Id, Name, IsSandbox, InstanceName FROM Organization LIMIT 1' --json
```

Result:

| Org ID | Name | IsSandbox | Instance |
|---|---|---|---|
| `00DUD000007zF692AE` | `ASTRUM CRO, SL` | `true` | `SWE92S` |

## Local Validation

| Check | Result |
|---|---|
| `git diff --check` | PASS |
| `input/schema.json` parsed as JSON | PASS |
| `AGENT_CreateContact.flow-meta.xml` parsed as XML | PASS |
| Targeted AccountId scan | PASS: no `AccountId` action input variable or `AccountId` element reference remains. Remaining matches are Salesforce field/API references only. |

## Deployment Command And Result

Command:

```bash
sf project deploy start \
  --target-org amit.kumar@astrumcro.com.astrumpar \
  --source-dir force-app/main/default/genAiPlannerBundles/Astrum_BD_Agent/localActions/Account_and_Contact_Management/Create_Contact_with_Duplicate_Check/input/schema.json \
  --source-dir force-app/main/default/flows/AGENT_CreateContact.flow-meta.xml \
  --source-dir force-app/main/default/classes/AGENT_CreateContact_Test.cls \
  --test-level RunSpecifiedTests \
  --tests AGENT_CreateContact_Test \
  --json
```

Result:

| Field | Value |
|---|---|
| First deploy ID | `0AfUD00000Gr44H0AR` |
| First deploy status | `Failed` |
| First deploy error | `Cannot update record as Agent is Active` |
| Successful deploy ID | `0AfUD00000GqwjU0AR` |
| Successful deploy status | `Succeeded` |
| Success | `true` |
| Components deployed | `AGENT_CreateContact_Test`, `AGENT_CreateContact`, `Astrum_BD_Agent` GenAiPlannerBundle |
| rollbackOnError | `true` |
| Deploy tests run | `4` |
| Deploy test result | `4/4 passed` |

The first deployment failed because Salesforce does not allow updating the active Agent planner bundle. After Human deactivated `Astrum_BD_Agent`, Codex reran the same narrow deployment and it succeeded. Codex did not activate, publish, republish, or reconfigure the agent.

## Apex Test Command And Result

Command:

```bash
sf apex test run --target-org amit.kumar@astrumcro.com.astrumpar --tests AGENT_CreateContact_Test --result-format human --wait 10
```

Result:

| Field | Value |
|---|---|
| Test Run ID | `707UD00000peTzo` |
| Outcome | `Passed` |
| Tests ran | `4` |
| Pass rate | `100%` |
| Org ID | `00DUD000007zF692AE` |

Detailed JSON was retrieved with:

```bash
sf apex get test --target-org amit.kumar@astrumcro.com.astrumpar --test-run-id 707UD00000peTzo --result-format json --json
```

## Agentforce Testing Center Re-Run Command And Result

Command:

```bash
sf agent test run --api-name SAL_16_Test --target-org amit.kumar@astrumcro.com.astrumpar --wait 10 --json
```

Result:

| Field | Value |
|---|---|
| Run ID | `4KBUD0000000BzZ4AU` |
| Status | `COMPLETED` |
| Subject | `SAL_16_Test` |

Structured result:

| Test Case | topic_sequence_match | action_sequence_match | bot_response_rating | Overall |
|---|---|---|---|---|
| AC-01 Emma Lau / duplicate-check | PASS | FAIL | PASS | FAIL |
| AC-03 John Smith / duplicate-surface | PASS | FAIL | PASS | FAIL |
| AC-04 delete-refusal | PASS | PASS | PASS | PASS |

AC-01 and AC-03 still returned `actionsSequence = []` and `invokedActions = [[]]`.

## AC-01, AC-03, AC-04 Outcome Summary

| AC | Result | Notes |
|---|---|---|
| AC-01 | FAIL | Topic and response passed, but action invocation failed: `actionsSequence = []`. |
| AC-03 | FAIL | Topic and response passed, but action invocation failed: `actionsSequence = []`. |
| AC-04 | PASS | Delete request refused and no action was invoked. |

## Remaining Blockers

- `AccountName` fix deployed and Apex tests pass, but Agentforce planner still does not invoke `Create_Contact_with_Duplicate_Check` for AC-01 or AC-03.
- Claude review is required to determine whether another planner/action contract setting, topic instruction, HITL/action availability setting, or agent lifecycle step is required.

## Safety Confirmations

- No production org was touched.
- No agent activation, publish, republish, or reconfiguration was performed.
- No bot metadata or bot version metadata was changed locally.
- No `localActionLinks` or output schema files were changed locally.
- No AiEvaluationDefinition or YAML test spec files were changed locally.
- No secrets were written to this evidence file.
