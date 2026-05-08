# SAL-15 Delivery Handoff - AGENT_CreateContact

| Item | Value |
|---|---|
| Linear issue | SAL-15 ([S1] AGENT_CreateContact Flow Build) |
| Project | Astrum BD Agent - S1 Create Contact |
| Builder | Codex |
| Date | 2026-04-28 |
| Target org | `amit.kumar@astrumcro.com.astrumpar` |
| Target org ID | `00DUD000007zF692AE` |
| Target org type | Sandbox confirmed |
| Deployment | Succeeded |
| Deploy ID | `0AfUD00000Gq3wf0AB` |
| Validation evidence | `validation/SAL-BD-S1-AGENT_CreateContact.md` |

## Built and Deployed

- `force-app/main/default/flows/AGENT_CreateContact.flow-meta.xml`
- `force-app/main/default/classes/AGENT_CreateContact_Test.cls`
- `force-app/main/default/classes/AGENT_CreateContact_Test.cls-meta.xml`

## CLI Issue Resolution

Previous execution was blocked because `sf` was not available on `PATH`. Human provided the explicit executable path, and Codex used:

```powershell
& "$env:APPDATA\npm\sf.cmd"
```

CLI version confirmed:

```text
@salesforce/cli/2.131.7 win32-x64 node-v24.15.0
```

No `.codex/config.toml` changes were made.

## Sandbox Proof

- `sf org list --json` showed `amit.kumar@astrumcro.com.astrumpar` under `sandboxes` with `isSandbox: true`.
- `Organization` SOQL query returned `IsSandbox: true`.
- Target instance URL was `https://astrum--astrumpar.sandbox.my.salesforce.com`.
- Production `astrum-prod` appeared separately with `isSandbox: false` and was not targeted.

## Deployment Summary

Final deployment command used only the approved SAL-15 source paths:

```powershell
& "$env:APPDATA\npm\sf.cmd" project deploy start --source-dir force-app/main/default/flows/AGENT_CreateContact.flow-meta.xml --source-dir force-app/main/default/classes/AGENT_CreateContact_Test.cls --source-dir force-app/main/default/classes/AGENT_CreateContact_Test.cls-meta.xml --target-org amit.kumar@astrumcro.com.astrumpar --test-level RunSpecifiedTests --tests AGENT_CreateContact_Test --wait 30 --json
```

| Result item | Value |
|---|---|
| Deploy ID | `0AfUD00000Gq3wf0AB` |
| Status | Succeeded |
| Components deployed | 2 |
| Component errors | 0 |
| Tests completed | 4 |
| Test failures | 0 |

## Test Result Summary

| Scenario | Runtime test method | Status |
|---|---|---|
| TC-01 No duplicate creates Contact | `tc01_noDuplicateCreatesContact` | PASS |
| TC-02 Duplicate by Account/name prevents create | `tc02_duplicateByNameExitsWithoutCreate` | PASS |
| TC-03 Duplicate by Email prevents create | `tc03_duplicateByEmailExitsWithoutCreate` | PASS |
| TC-04 Account not found returns clean ErrorMessage | `tc04_accountNotFoundFailsGracefully` | PASS |

## Exit Criteria Status

| Criterion | Status |
|---|---|
| FC-01 All four unit test scenarios pass | PASS |
| FC-04 TC-02 and TC-03 confirm no Contact record is created when `DuplicateFound = true` | PASS |
| FC-05 TC-04 confirms Flow returns `ErrorMessage` cleanly without unhandled fault | PASS |

## Scope Confirmation

- Built and deployed only the custom Subagent 1 Action 6 Flow and its Apex test class.
- Did not generate Flow XML for Actions 1-5 or 7.
- Did not touch SAL-2, SAL-9, or SAL-10 notification source files.
- Did not start Agent Builder configuration.
- Did not update permission sets.
- Did not update Linear directly.
- Did not move any Linear issue to Done, Closed, Production Ready, or any terminal state.
- Did not touch production.

## Warnings and Review Notes

- Three failed deployment attempts occurred before the successful deploy; each rolled back with `rollbackOnError: true`.
- The successful deploy required scoped SAL-15 Flow XML source-order fixes: contiguous `recordLookups`, contiguous `assignments`, and removal of unsupported `FlowStart` description.
- Salesforce metadata rejects a description on `FlowStart`; all deployable Flow elements retain non-blank descriptions. Claude should review FC-06 interpretation.
- Flow coverage reports `Set_Fault_Create_Failed` not covered. TC-04 graceful account-not-found handling passed; create-DML fault injection was not one of the four PRD scenarios.

## SAL-16 / SAL-17 Readiness

Based on SAL-15 runtime evidence, FC-01, FC-04, and FC-05 are PASS. This section is superseded by the SAL-16/SAL-17 sandbox configuration updates below. SAL-17 is complete, and SAL-16 was subsequently completed through `GenAiPlannerBundle` metadata deployment for S1 Action 6 only.

## SAL-16 and SAL-17 Sandbox Configuration Update

| Item | Result |
|---|---|
| Timestamp | 2026-04-28T19:10:27+01:00 |
| Target org | `amit.kumar@astrumcro.com.astrumpar` |
| Sandbox proof | `sf org list --json`, `Organization.IsSandbox = true`, sandbox instance URL |
| SAL-16 status | SUPERSEDED - see completion update below |
| SAL-17 status | COMPLETED |
| SAL-16 evidence | `validation/SAL-16-AgentBuilder-CreateContact.md` |
| SAL-17 evidence | `validation/SAL-17-Permissions-FLS-CreateContact.md` |
| SAL-16 Linear comment | `1001a46c-05b1-441b-a4db-cf550a557f00` |
| SAL-17 Linear comment | `b5a3a164-6075-423c-8ce6-1764d70713c7` |

SAL-16 Agent Builder configuration could not be completed through CLI/API because no existing `Astrum BD Agent` / `Astrum_BD_Agent` planner, bot, plugin, function, or Subagent 1 record was found in sandbox. Existing exposed agents are `Astrum Lead Nurturing Agent`, `Sales Representative Agent`, and the default Agentforce employee copilot. Codex did not create a new Agentforce agent or attach the action to a potentially wrong agent.

SAL-17 permission/FLS validation is complete. `Astrum_BD_Agent_PS` did not initially exist, so Codex created the minimum sandbox permission set with deploy ID `0AfUD00000Gq4EP0AZ`. Revalidation confirms Account read only, Contact read/create/edit, no Delete, no View All, no Modify All, no Account Create, Contact FLS for permissionable fields used by `AGENT_CreateContact`, and Flow access to `AGENT_CreateContact`.

Remaining risks:

- This original SAL-16 block was resolved by creating the Astrum BD Agent/Subagent 1 metadata in the later SAL-16 completion update below.
- `Contact.FirstName` and `Contact.LastName` are not permissionable FLS fields in this org; they are createable/updateable via Contact object permissions.
- No Agentforce Testing Center CLI/API run was performed in this earlier pass.

## SAL-16 Agentforce Metadata Completion Update

| Item | Result |
|---|---|
| Timestamp | 2026-04-28T19:34:57+01:00 |
| Target org | `amit.kumar@astrumcro.com.astrumpar` |
| Sandbox proof | `sf org list --json`, standard `Organization.IsSandbox = true`, sandbox instance URL |
| SAL-16 status | COMPLETED |
| Deploy ID | `0AfUD00000Gq4j30AB` |
| Deployment status | Succeeded |
| Components deployed | `GenAiPlannerBundle` only |
| Validation evidence | `validation/SAL-16-AgentBuilder-CreateContact.md` |
| SAL-16 Linear comment | `aba3edfd-ee1d-4ba0-8da6-c2f19db39487` |

Codex retrieved existing Agentforce metadata, confirmed no pre-existing `Astrum_BD_Agent`, `Account_and_Contact_Management`, `Create_Contact_with_Duplicate_Check`, or `AGENT_CreateContact` Agentforce configuration was present, then authored and deployed the minimum S1 Action 6 metadata only.

Files authored and deployed:

- `force-app/main/default/genAiPlannerBundles/Astrum_BD_Agent/Astrum_BD_Agent.genAiPlannerBundle`
- `force-app/main/default/genAiPlannerBundles/Astrum_BD_Agent/localActions/Account_and_Contact_Management/Create_Contact_with_Duplicate_Check/input/schema.json`
- `force-app/main/default/genAiPlannerBundles/Astrum_BD_Agent/localActions/Account_and_Contact_Management/Create_Contact_with_Duplicate_Check/output/schema.json`

Post-deploy Tooling API validation confirmed:

- Planner `Astrum_BD_Agent` exists with label `Astrum BD Agent` and `PlannerType = AiCopilot__ReAct`.
- Topic `Account_and_Contact_Management` exists with label `Account and Contact Management` and links to planner `16jUD00000061hNYAQ`.
- Function `Create_Contact_with_Duplicate_Check` exists with label `Create Contact with Duplicate Check`, links to topic `179UD000000l0PZYAY`, has `InvocationTargetType = flow`, resolves to the `AGENT_CreateContact` FlowDefinition Id `300UD00000QvVmUYAV`, and has `IsConfirmationRequired = true`.
- No external Bot/channel configuration was created.
- No Account Create, Delete, bulk action, SAL-2, SAL-9, SAL-10, Flow XML, or permission set metadata was deployed.

Remaining risks:

- Agentforce Testing Center was not run in this CLI pass.
- Actions 1-5, 7, and 8 remain intentionally out of scope and were not configured.
- Claude should review whether any UI-only activation/publication step is required before sandbox UAT.

## SAL-16 Bot Shell Remediation Update

| Item | Result |
|---|---|
| Timestamp | 2026-04-28T21:10:01+01:00 |
| Target org | `amit.kumar@astrumcro.com.astrumpar` |
| Sandbox proof | `sf org list --json`, standard `Organization.IsSandbox = true`, sandbox instance URL |
| Deploy ID | `0AfUD00000Gq6Hq0AJ` |
| Deployment status | Succeeded |
| Components deployed | `Bot` and `BotVersion` only |
| Validation evidence | `validation/SAL-16-AgentBuilder-CreateContact.md` |
| SAL-16 remediation Linear comment | `6427b6cb-2aad-4364-b308-806a2be62f23` |

Codex created the Agentforce Studio-visible shell for `Astrum_BD_Agent` using the confirmed working `Sales_Representative_Agent` Bot metadata structure. The deployed BotVersion links to the existing planner with `<genAiPlannerName>Astrum_BD_Agent</genAiPlannerName>`.

Files authored and deployed:

- `force-app/main/default/bots/Astrum_BD_Agent/Astrum_BD_Agent.bot-meta.xml`
- `force-app/main/default/bots/Astrum_BD_Agent/v1.botVersion-meta.xml`

Post-deploy validation confirmed:

- `BotDefinition` row exists for `Astrum_BD_Agent`, label `Astrum BD Agent`, Type `InternalCopilot`, Id `0XxUD0000000wlZ0AQ`.
- `BotVersion` row exists for `Astrum_BD_Agent`, version `v1`, Status `Inactive`, Id `0X9UD0000000lAD0AY`.
- `GenAiPlannerDefinition` remains present and unchanged with Id `16jUD00000061hNYAQ`.

Scope confirmation:

- No activation, deactivation, or publication was performed.
- Existing agents `Copilot_for_Salesforce`, `Agentforce_Sales_Development_Rep`, and `Sales_Representative_Agent` were not modified.
- `GenAiPlannerBundle`, `AGENT_CreateContact`, and `Astrum_BD_Agent_PS` were not redeployed.
- Production was not touched.

## Next Operator
- Run next in: Claude
- Reason: Claude must review Codex's Agentforce configuration evidence, permission/FLS validation evidence, and handoff updates before the next sandbox UAT step.
- Next prompt: Review the SAL-16 Agent Builder configuration and SAL-17 permission/FLS validation completed by Codex in the Astrum sandbox. Confirm whether the AGENT_CreateContact action is correctly configured with Confirm HITL, whether Astrum_BD_Agent_PS permissions are compliant, and whether the work can proceed to sandbox UAT.
