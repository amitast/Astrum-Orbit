# SAL-16 Agent Builder Create Contact Validation

| Item | Value |
|---|---|
| Validation timestamp | 2026-04-28T19:34:57+01:00 |
| Shell used | Windows PowerShell Desktop |
| Salesforce CLI command path | `& "$env:APPDATA\npm\sf.cmd"`; escalated execution used direct path `C:\Users\Amit Asthana\AppData\Roaming\npm\sf.cmd` because the workspace sandbox cannot access `%APPDATA%\npm` |
| Salesforce CLI version | `@salesforce/cli/2.131.7 win32-x64 node-v24.15.0` |
| Target org | `amit.kumar@astrumcro.com.astrumpar` |
| Org ID | `00DUD000007zF692AE` |
| Sandbox proof | `sf org list --json` showed target under `sandboxes` with `isSandbox: true`; standard `Organization` query returned `IsSandbox: true`; instance URL is `https://astrum--astrumpar.sandbox.my.salesforce.com`; production `astrum-prod` was a separate entry with `isSandbox: false` and was not targeted |
| Tooling Organization query note | The mandated `--use-tooling-api` Organization query failed with `INVALID_TYPE: sObject type 'Organization' is not supported`; the standard API Organization query succeeded |
| Production touched | No |
| External channels configured | No |
| Agent Builder action configured | Yes, through `GenAiPlannerBundle` metadata |
| SAL-16 status | COMPLETED |
| Linear comment | `aba3edfd-ee1d-4ba0-8da6-c2f19db39487` |

## Discovery And Retrieval

Retrieved current Agentforce metadata from the sandbox before authoring:

| Metadata type | Result |
|---|---|
| `GenAiPlannerBundle` | Succeeded; retrieved existing `Agentforce_Sales_Development_Rep`, `EmployeeCopilotPlanner`, and `Sales_Representative_Agent` bundles |
| `GenAiPlugin` | Succeeded; retrieved existing `Fetch_Lead_Details` and `Lead_Nurturing` standalone plugin metadata |
| `GenAiFunction` | Succeeded; retrieved existing `Fetch_Lead_By_Name`, `AUTO_Send_Follow_UP_Emails`, `AUTO_Send_Mail_Flow`, and `Fetch_Account_Information1` standalone function metadata plus schemas |
| `Bot` | Succeeded; retrieved existing `Agentforce_Sales_Development_Rep`, `Copilot_for_Salesforce`, and `Sales_Representative_Agent` bot metadata |

Retrieved force-app paths written:

| Path | File count after retrieval/authoring |
|---|---:|
| `force-app/main/default/genAiPlannerBundles/` | 120 |
| `force-app/main/default/genAiPlugins/` | 2 |
| `force-app/main/default/genAiFunctions/` | 12 |
| `force-app/main/default/bots/` | 6 |

Searches across retrieved `genAiPlannerBundles`, `genAiPlugins`, `genAiFunctions`, and `bots` found no pre-existing `Astrum_BD_Agent`, `Account_and_Contact_Management`, `Create_Contact_with_Duplicate_Check`, or `AGENT_CreateContact` Agentforce configuration before authoring.

## Metadata Structure Confirmed

| Structure item | Confirmed representation |
|---|---|
| Planner bundle directory | `force-app/main/default/genAiPlannerBundles/<DeveloperName>/<DeveloperName>.genAiPlannerBundle` |
| Planner bundle action schemas | `force-app/main/default/genAiPlannerBundles/<DeveloperName>/localActions/<TopicDeveloperName>/<FunctionDeveloperName>/input/schema.json` and `output/schema.json` |
| Standalone plugin directory | `force-app/main/default/genAiPlugins/<DeveloperName>.genAiPlugin-meta.xml` |
| Standalone function directory | `force-app/main/default/genAiFunctions/<DeveloperName>/<DeveloperName>.genAiFunction-meta.xml` plus `input/schema.json` and `output/schema.json` |
| Planner XML root | `<GenAiPlannerBundle xmlns="http://soap.sforce.com/2006/04/metadata">` |
| Planner key elements | `<description>`, `<localTopicLinks>`, `<localTopics>`, `<masterLabel>`, `<plannerType>` |
| Plugin/topic link from planner | `<localTopicLinks><genAiPluginName>...</genAiPluginName></localTopicLinks>` |
| Plugin/topic inline definition | `<localTopics>` with `<fullName>`, `<description>`, `<developerName>`, `<genAiPluginInstructions>`, `<aiPluginUtterances>`, `<localActionLinks>`, `<localActions>`, `<localDeveloperName>`, `<masterLabel>`, `<pluginType>Topic</pluginType>`, and `<scope>` |
| Function link from plugin/topic | `<localActionLinks><functionName>...</functionName></localActionLinks>` |
| Function inline definition | `<localActions>` with `<fullName>`, `<description>`, `<developerName>`, `<invocationTarget>`, `<invocationTargetType>`, `<isConfirmationRequired>`, `<isIncludeInProgressIndicator>`, `<localDeveloperName>`, `<masterLabel>`, and optional `<progressIndicatorMessage>` |
| Flow action target | `<invocationTarget>AGENT_CreateContact</invocationTarget>` deployed as Tooling `InvocationTarget = 300UD00000QvVmUYAV` |
| Flow action type | `<invocationTargetType>flow</invocationTargetType>` |
| HITL Confirm | `<isConfirmationRequired>true</isConfirmationRequired>` |
| Classification examples | `<aiPluginUtterances>` |
| Subagent instructions | `<genAiPluginInstructions>` |
| Employee Agent / AEA representation | Existing employee-style Agentforce planners use `<plannerType>AiCopilot__ReAct</plannerType>`; the new planner uses the same value |

## Files Authored

- `force-app/main/default/genAiPlannerBundles/Astrum_BD_Agent/Astrum_BD_Agent.genAiPlannerBundle`
- `force-app/main/default/genAiPlannerBundles/Astrum_BD_Agent/localActions/Account_and_Contact_Management/Create_Contact_with_Duplicate_Check/input/schema.json`
- `force-app/main/default/genAiPlannerBundles/Astrum_BD_Agent/localActions/Account_and_Contact_Management/Create_Contact_with_Duplicate_Check/output/schema.json`

No `AGENT_CreateContact.flow-meta.xml`, `Astrum_BD_Agent_PS.permissionset-meta.xml`, SAL-2, SAL-9, or SAL-10 metadata was redeployed.

## Deployment

```powershell
& "C:\Users\Amit Asthana\AppData\Roaming\npm\sf.cmd" project deploy start --source-dir force-app/main/default/genAiPlannerBundles/Astrum_BD_Agent --target-org amit.kumar@astrumcro.com.astrumpar --wait 30 --json
```

| Result item | Value |
|---|---|
| Deploy ID | `0AfUD00000Gq4j30AB` |
| Status | Succeeded |
| Completed | 2026-04-28T18:33:53.000Z |
| Components deployed | 1 |
| Component errors | 0 |
| Files deployed | 3 authored files under `force-app/main/default/genAiPlannerBundles/Astrum_BD_Agent` |
| Tests run | 0; metadata-only deploy |

## Tooling API Validation

### Planner

```json
{
  "Id": "16jUD00000061hNYAQ",
  "DeveloperName": "Astrum_BD_Agent",
  "MasterLabel": "Astrum BD Agent",
  "PlannerType": "AiCopilot__ReAct"
}
```

### Topic / Subagent 1

```json
{
  "Id": "179UD000000l0PZYAY",
  "DeveloperName": "Account_and_Contact_Management",
  "MasterLabel": "Account and Contact Management",
  "PlannerId": "16jUD00000061hNYAQ"
}
```

### Action / Function

```json
{
  "Id": "172UD0000017YHJYA2",
  "DeveloperName": "Create_Contact_with_Duplicate_Check",
  "MasterLabel": "Create Contact with Duplicate Check",
  "Description": "Create a new contact record linked to a specified account in Salesforce. Before creating, searches for existing contacts with the same last name at the same account, or the same email address. If a potential duplicate is found, presents it to the user for review before proceeding. Use when the user explicitly asks to add a new contact to an account and has provided at minimum a first name, last name, and account.",
  "InvocationTarget": "300UD00000QvVmUYAV",
  "InvocationTargetType": "flow",
  "IsConfirmationRequired": true,
  "IsIncludeInProgressIndicator": true,
  "LocalDeveloperName": "Create_Contact_with_Duplicate_Check",
  "PlannerId": null,
  "PluginId": "179UD000000l0PZYAY"
}
```

`InvocationTarget` resolves to the deployed `AGENT_CreateContact` FlowDefinition. The metadata source uses `AGENT_CreateContact`; Salesforce stores the target as FlowDefinition Id `300UD00000QvVmUYAV`.

### External Channel Check

`BotDefinition` query for `DeveloperName = 'Astrum_BD_Agent'` returned zero rows. The deployed planner bundle contains no channel, messaging, web chat, email bot, LinkedIn, or external channel elements.

## SAL-16 Check Table

| Required SAL-16 check | Result |
|---|---|
| Astrum BD Agent exists in sandbox | PASS |
| Subagent 1 exists | PASS |
| Create Contact with Duplicate Check action exists under Subagent 1 | PASS |
| Action invokes `AGENT_CreateContact` | PASS |
| HITL mode Confirm | PASS |
| External channel added | PASS - none added |
| Account create action added | PASS - none added |
| Delete action added | PASS - none added |
| Bulk action added | PASS - none added |
| SAL-2/SAL-9/SAL-10 touched | PASS - not touched |
| `AGENT_CreateContact` Flow XML redeployed | PASS - not redeployed |
| `Astrum_BD_Agent_PS` redeployed | PASS - not redeployed |

## Pending / Limitations

- Agentforce Testing Center was not run in this CLI pass; no CLI/API Testing Center surface was invoked.
- Actions 1-5, 7, and 8 remain intentionally out of scope for this session and were not configured.
- Permission set assignment to the agent is not represented in the retrieved/deployed `GenAiPlannerBundle` XML structure. SAL-17 permission set evidence remains complete and was not rerun.
- Claude should review whether the new planner requires any additional activation or UI-only publication step before sandbox UAT.

## Result

SAL-16 Agentforce metadata configuration is completed in the Astrum sandbox for S1 Action 6 only.
