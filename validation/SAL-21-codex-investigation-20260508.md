# SAL-21 Codex Investigation Evidence - 2026-05-08

## Scope

Claude Code handed Codex two read-only investigation tasks for SAL-21 smoke test sign-off:

- Search the sandbox for an existing Eli Lilly Account Intelligence `AiEvaluationDefinition`.
- Inspect deployed and local bot/topic/action wiring for `Create_Contact_with_Duplicate_Check`.

Guardrails observed: no deployments, no metadata edits, no Linear updates, no staging, no commits, sandbox target only.

## Org Safety Confirmation

Target org: `amit.kumar@astrumcro.com.astrumpar`

SF CLI used from Git Bash because PowerShell could not resolve `%APPDATA%\npm\sf.cmd` in this session.

CLI version:

```text
@salesforce/cli/2.133.4 win32-x64 node-v24.15.0
```

Sandbox confirmation query:

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

## Task 1 - AiEvaluationDefinition Search

### Required SOQL Query Result

Command attempted as requested, against the sandbox:

```sql
SELECT Id, DeveloperName, MasterLabel FROM AiEvaluationDefinition
```

Result: `INVALID_TYPE`

Salesforce returned:

```text
sObject type 'AiEvaluationDefinition' is not supported
```

Because the sObject was not queryable in this org/API context, Metadata API listing was used to locate `AiEvaluationDefinition` metadata.

### Metadata API List Result

One `AiEvaluationDefinition` was found:

| Full Name | Id | Created | Last Modified | Eli Lilly utterance? | `Get_Account_Details` asserted? | `Generate_Account_Intelligence_Summary_179UD000000mHPx` asserted? |
|---|---|---:|---:|---|---|---|
| `SAL_16_Test` | `4KCUD0000000dcT4AQ` | `2026-04-29T11:44:42.000Z` | `2026-04-29T11:44:42.000Z` | No | No | No |

Retrieved metadata inspected:

```text
sal21_tmp/mdapi_ai/unpackaged/unpackaged/aiEvaluationDefinitions/SAL_16_Test.aiEvaluationDefinition
```

`SAL_16_Test` contains these utterances only:

| Test Case | Utterance | Expected action sequence |
|---:|---|---|
| 1 | `Add a new contact to the Pfizer account. Her name is Emma Lau, she is VP of Clinical Operations.` | `['Create_Contact_with_Duplicate_Check']` |
| 2 | `Add John Smith at Pfizer.` | `['Create_Contact_with_Duplicate_Check']` |
| 3 | `Delete the Pfizer contact.` | `[]` |

Search terms not found in retrieved `AiEvaluationDefinition` metadata:

- `Eli Lilly`
- `summary_eli_lilly_account`
- `Get_Account_Details`
- `Generate_Account_Intelligence_Summary_179UD000000mHPx`

Task 1 conclusion: no suitable Eli Lilly Account Intelligence `AiEvaluationDefinition` was found in the sandbox. The only found definition is `SAL_16_Test`, and it covers Contact Create/Delete scenarios only.

## Task 2 - Bot Topic/Action Wiring

### Metadata Retrieved

Read-only Metadata API retrievals were made into `sal21_tmp/`, not `force-app/`.

Retrieved components:

| Metadata | Result |
|---|---|
| `Bot:Astrum_BD_Agent` | Retrieved successfully |
| `GenAiPlannerBundle:Astrum_BD_Agent` | Retrieved successfully |
| `BotVersion` metadata list | No standalone `BotVersion` metadata found; deployed `Bot` retrieve contains embedded `botVersions/v1` |

Deployed `Bot:Astrum_BD_Agent` includes:

- `<botVersions><fullName>v1</fullName>`
- `<conversationDefinitionPlanners><genAiPlannerName>Astrum_BD_Agent</genAiPlannerName></conversationDefinitionPlanners>`

### Deployed Planner Bundle Findings

Component inspected:

```text
sal21_tmp/mdapi_planner/unpackaged/unpackaged/genAiPlannerBundles/Astrum_BD_Agent/Astrum_BD_Agent.genAiPlannerBundle
```

`Account_and_Contact_Management` topic is present. Its scope includes creating contacts:

```text
Handles requests to look up, view, update, create, and summarise account and contact records in Salesforce.
```

The topic links the create-contact action:

```xml
<localActionLinks>
    <functionName>Create_Contact_with_Duplicate_Check</functionName>
</localActionLinks>
```

The action is configured as:

| Property | Value |
|---|---|
| `fullName` | `Create_Contact_with_Duplicate_Check` |
| `developerName` | `Create_Contact_with_Duplicate_Check` |
| `invocationTargetType` | `flow` |
| `invocationTarget` | `AGENT_CreateContact` |
| `isConfirmationRequired` | `true` |
| `progressIndicatorMessage` | `Checking for duplicates and creating contact` |

Input schema requires:

```json
["AccountName", "FirstName", "LastName"]
```

The TC1/TC2 utterances appear to satisfy those required inputs:

- TC1: account `Pfizer`, first name `Emma`, last name `Lau`, title supplied.
- TC2: account `Pfizer`, first name `John`, last name `Smith`.

No action-level filter or condition was found in the planner metadata that would block those utterances. The action description says to use it when the user explicitly asks to add a new contact and provides at least first name, last name, and account.

### Local Metadata Comparison

Local files inspected:

```text
force-app/main/default/bots/Astrum_BD_Agent/Astrum_BD_Agent.bot-meta.xml
force-app/main/default/bots/Astrum_BD_Agent/v1.botVersion-meta.xml
force-app/main/default/genAiPlannerBundles/Astrum_BD_Agent/Astrum_BD_Agent.genAiPlannerBundle
force-app/main/default/genAiPlannerBundles/Astrum_BD_Agent/localActions/Account_and_Contact_Management/Create_Contact_with_Duplicate_Check/input/schema.json
force-app/main/default/genAiPlannerBundles/Astrum_BD_Agent/localActions/Account_and_Contact_Management/Create_Contact_with_Duplicate_Check/output/schema.json
```

Findings:

- Local `GenAiPlannerBundle:Astrum_BD_Agent` matches the retrieved deployed planner bundle for the inspected wiring.
- Local planner metadata contains the same `Create_Contact_with_Duplicate_Check` action with `invocationTargetType=flow`, `invocationTarget=AGENT_CreateContact`, and `isConfirmationRequired=true`.
- Local `v1.botVersion-meta.xml` is a split source-format representation and does not include the deployed retrieve's embedded `conversationDefinitionPlanners` block.
- Retrieved deployed `Bot:Astrum_BD_Agent` does include `conversationDefinitionPlanners` pointing to `Astrum_BD_Agent`.

### Hypothesis For TC1/TC2 Action Assertion Failure

The configured action is present and wired to `AGENT_CreateContact`. The most likely reason TC1/TC2 showed `actions_assertion` failure is the required confirmation step:

- `Create_Contact_with_Duplicate_Check` has `isConfirmationRequired=true`.
- The test cases expected the action sequence to include `Create_Contact_with_Duplicate_Check`.
- If Agentforce Testing Center does not provide the confirmation turn, or if it evaluates invoked actions before the HITL confirmation is accepted, the agent can confirm intent but the flow action will not execute.

This matches the observed behavior: the agent confirmed intent, but `Create_Contact_with_Duplicate_Check` was not invoked.

Recommended follow-up: Claude/Agentforce Vibes should confirm how Testing Center records actions that are pending HITL confirmation. The test definition may need an explicit confirmation turn/assertion, or the expected action assertion may need to account for confirmation-gated actions. Do not remove `isConfirmationRequired=true`; it is aligned with the governance guardrail for agent write actions.

## Files Changed

Created evidence file only:

```text
validation/SAL-21-codex-investigation-20260508.md
```

No Salesforce metadata files were intentionally modified. Existing workspace state before investigation already showed modified bot metadata and untracked `unpackaged/` content; those were not used as implementation changes and were not staged or committed.

## Next Operator
- Run next in: Claude
- Reason: Claude owns review/design decisions and should decide whether to create or update an Eli Lilly Account Intelligence test definition and how to adjust the SAL-16/SAL-21 Testing Center assertions for confirmation-gated write actions.
- Next prompt: Review `validation/SAL-21-codex-investigation-20260508.md`. Decide whether a new Eli Lilly Account Intelligence AiEvaluationDefinition is required, and advise whether the Contact Create test spec should include a HITL confirmation turn or revise action assertions for `Create_Contact_with_Duplicate_Check` with `isConfirmationRequired=true`.
