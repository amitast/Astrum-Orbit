# SAL-21 Account Intelligence Test Deployment Evidence - 2026-05-08

## Scope

Codex authored and deployed Agentforce Testing Center `AiEvaluationDefinition` metadata only:

- Updated `SAL_16_Test` TC1 and TC2 to use multi-turn `conversationHistory`.
- Added `SAL_21_Account_Intelligence_Test` with three account intelligence summary cases.

No planner bundle, Flow, Apex, permission, package, production, Linear, staging, commit, or release action was performed.

## Multi-Turn Schema Verification

Source checked before editing `SAL_16_Test`:

- Salesforce Agentforce Developer Guide, "Build Tests in Metadata API"
- Salesforce Agentforce Developer Guide, "Metadata API Reference for Testing API"

Confirmed format:

- `AiEvaluationDefinition` test case input supports `utterance` plus `conversationHistory`.
- `conversationHistory` is an XML array under `inputs`.
- Each `conversationHistory` entry includes `role`, `message`, zero-based `index`, and `topic` when `role` is `agent`.
- The final `inputs/utterance` is the turn being evaluated. Prior turns are represented in `conversationHistory`.

Implementation decision:

- SAL-16 TC1 and TC2 now make the final utterance `Yes, create the contact.`
- The original create request is stored as history index `0`.
- A confirmation-seeking agent message is stored as history index `1` with topic `Account_and_Contact_Management`.
- `action_sequence_match` remains `['Create_Contact_with_Duplicate_Check']`, so the create action is asserted for the confirmation turn only.

## Sandbox Safety Confirmation

Target org:

```text
amit.kumar@astrumcro.com.astrumpar
```

Safety query:

```sql
SELECT IsSandbox FROM Organization LIMIT 1
```

Result:

```json
{
  "IsSandbox": true
}
```

No command targeted `astrum-prod`.

## Files Changed

```text
force-app/main/default/aiEvaluationDefinitions/SAL_16_Test.aiEvaluationDefinition-meta.xml
force-app/main/default/aiEvaluationDefinitions/SAL_21_Account_Intelligence_Test.aiEvaluationDefinition-meta.xml
validation/SAL-21-account-intelligence-test-deploy-20260508.md
```

## SAL-21 Test Cases Added

Definition:

```text
SAL_21_Account_Intelligence_Test
```

All three cases assert:

```text
Topic: Account_and_Contact_Management
Actions: ['Get_Account_Details', 'Generate_Account_Intelligence_Summary_179UD000000mHPx']
```

Utterances:

| # | Utterance |
|---:|---|
| 1 | Give me a summary of the Eli Lilly account. |
| 2 | Summarise what we know about Eli Lilly. |
| 3 | Give me an account intelligence profile for Eli Lilly. |

## Deploy Evidence

Deploy command scope:

```text
force-app/main/default/aiEvaluationDefinitions/SAL_16_Test.aiEvaluationDefinition-meta.xml
force-app/main/default/aiEvaluationDefinitions/SAL_21_Account_Intelligence_Test.aiEvaluationDefinition-meta.xml
```

Deploy ID:

```text
0AfUD00000GyDNm0AN
```

Target org:

```text
astrum--astrumpar.sandbox.my.salesforce.com
```

Timestamp:

```text
2026-05-08T16:38:56Z
```

Status:

```text
Succeeded
```

Components deployed:

| Component Type | Full Name | Result | Id |
|---|---|---|---|
| AiEvaluationDefinition | `SAL_16_Test` | Changed | `4KCUD0000000dcT4AQ` |
| AiEvaluationDefinition | `SAL_21_Account_Intelligence_Test` | Created | `4KCUD0000000dqz4AA` |

Tests run:

```text
0
```

## Post-Deploy Metadata Confirmation

Read-only Metadata API list confirmed both definitions exist in the sandbox:

| Full Name | Id | Last Modified |
|---|---|---|
| `SAL_16_Test` | `4KCUD0000000dcT4AQ` | `2026-05-08T16:38:55.000Z` |
| `SAL_21_Account_Intelligence_Test` | `4KCUD0000000dqz4AA` | `2026-05-08T16:38:56.000Z` |

## Next Operator
- Run next in: Agentforce Vibes
- Reason: The Testing Center definitions are deployed to the sandbox; org-native execution and result capture are the next validation step.
- Next prompt: Run Agentforce Testing Center tests for `SAL_16_Test` and `SAL_21_Account_Intelligence_Test` against sandbox `amit.kumar@astrumcro.com.astrumpar`. Confirm sandbox safety first. Capture topic/action assertion results, especially SAL-16 TC1/TC2 turn-2 action invocation and all SAL-21 account intelligence action sequences. Do not deploy, activate, deactivate, publish, or modify metadata.
