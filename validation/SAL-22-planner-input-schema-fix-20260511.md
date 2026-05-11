# SAL-22 Planner Input Schema Fix - 2026-05-11

## Sandbox Safety Confirmation

Command:

```powershell
& "$env:APPDATA\npm\sf.cmd" data query --query "SELECT Id, Name, IsSandbox FROM Organization" --target-org amit.kumar@astrumcro.com.astrumpar
```

Output:

```text
┌────────────────────┬────────────────┬───────────┐
│ ID                 │ NAME           │ ISSANDBOX │
├────────────────────┼────────────────┼───────────┤
│ 00DUD000007zF692AE │ ASTRUM CRO, SL │ true      │
└────────────────────┴────────────────┴───────────┘

Total number of records retrieved: 1.
Querying Data... done
```

Result: PASS. Target org is sandbox (`IsSandbox = true`).

## Git Branch Confirmation

Command:

```powershell
git branch --show-current
```

Output:

```text
main
```

Result: PASS. Current branch is `main`.

## Schema Diff

File changed:

```text
force-app/main/default/genAiPlannerBundles/Astrum_BD_Agent/localActions/Account_and_Contact_Management/Generate_Account_Intelligence_Summary/input/schema.json
```

Exact diff:

```diff
diff --git a/force-app/main/default/genAiPlannerBundles/Astrum_BD_Agent/localActions/Account_and_Contact_Management/Generate_Account_Intelligence_Summary/input/schema.json b/force-app/main/default/genAiPlannerBundles/Astrum_BD_Agent/localActions/Account_and_Contact_Management/Generate_Account_Intelligence_Summary/input/schema.json
index 8319072..38f34a9 100644
--- a/force-app/main/default/genAiPlannerBundles/Astrum_BD_Agent/localActions/Account_and_Contact_Management/Generate_Account_Intelligence_Summary/input/schema.json
+++ b/force-app/main/default/genAiPlannerBundles/Astrum_BD_Agent/localActions/Account_and_Contact_Management/Generate_Account_Intelligence_Summary/input/schema.json
@@ -4,14 +4,14 @@
   "properties" : {
     "accountName" : {
       "title" : "Account Name",
-      "description" : "Name of the account to summarise, as stated by the user. Use when the account ID is not in context. Pass the account name exactly as the user stated it.",
+      "description" : "Name of the account to summarise. Always use this when the user has stated an account name. Pass the name exactly as the user stated it — do not first resolve it via Get Account Details.",
       "lightning:type" : "lightning__textType",
       "lightning:isPII" : false,
       "copilotAction:isUserInput" : true
     },
     "accountId" : {
       "title" : "Account ID",
-      "description" : "18-character Salesforce Account record ID. Use only if already available from a prior action. Leave blank when only the account name is known — the action resolves the account internally.",
+      "description" : "18-character Salesforce Account record ID. Use only if a prior Search Accounts or Search Contacts action explicitly returned this ID. Do not populate from Get Account Details output — that action does not return an Account ID.",
       "lightning:type" : "lightning__textType",
       "lightning:isPII" : false,
       "copilotAction:isUserInput" : false
warning: in the working copy of 'force-app/main/default/genAiPlannerBundles/Astrum_BD_Agent/localActions/Account_and_Contact_Management/Generate_Account_Intelligence_Summary/input/schema.json', LF will be replaced by CRLF the next time Git touches it
```

## Sandbox Validate-Only

Command:

```powershell
& "$env:APPDATA\npm\sf.cmd" project deploy validate --source-dir force-app/main/default/classes --source-dir force-app/main/default/genAiPlannerBundles --target-org amit.kumar@astrumcro.com.astrumpar --test-level RunSpecifiedTests --tests AGENT_AccountIntelligenceSummary_Test AGENT_SearchAccounts_Test AGENT_SearchContacts_Test AGENT_UpdateAccountField_Test AGENT_UpdateContactField_Test AGENT_CreateContact_Test AGENT_CreateContactTest SAL9_BypassFlow_Test
```

Output:

```text
Validating Deployment of v66.0 metadata to amit.kumar@astrumcro.com.astrumpar using the v66.0 SOAP API.
───── Validating Deployment ─────
Stages:
1. Preparing
2. Waiting for the org to respond
3. Deploying Metadata
4. Running Tests
5. Updating Source Tracking
6. Done

► Preparing…
   Deploy ID: 0AfUD00000GzVIc0AN
   Target Org: amit.kumar@astrumcro.com.astrumpar
√ Preparing (179ms)
( ) Waiting for the org to respond - Skipped
► Deploying Metadata…
   Components: 0/14 (0%)
   Components: 13/14 (93%)
   Components: 14/14 (100%)
√ Deploying Metadata (32.61s)
► Running Tests…
   Successful: 9/52 (17%)
   Successful: 11/52 (21%)
   Successful: 15/52 (29%)
   Successful: 39/52 (75%)
   Successful: 51/52 (98%)
√ Running Tests (24.64s)
   Successful: 52/52 (100%)
( ) Updating Source Tracking - Skipped
► Done…
√ Done (1ms)

Status: Succeeded
Deploy ID: 0AfUD00000GzVIc0AN
Target Org: amit.kumar@astrumcro.com.astrumpar

Elapsed time: 57.44s

Validated Source
┌─────────┬───────────────────────────────────────┬────────────────────┬─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│ State   │ Name                                  │ Type               │ Path                                                                                                                                                                            │
├─────────┼───────────────────────────────────────┼────────────────────┼─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Created │ AGENT_AccountIntelligenceSummary      │ ApexClass          │ force-app\main\default\classes\AGENT_AccountIntelligenceSummary.cls                                                                                                             │
│ Created │ AGENT_AccountIntelligenceSummary      │ ApexClass          │ force-app\main\default\classes\AGENT_AccountIntelligenceSummary.cls-meta.xml                                                                                                    │
│ Created │ AGENT_AccountIntelligenceSummary_Test │ ApexClass          │ force-app\main\default\classes\AGENT_AccountIntelligenceSummary_Test.cls                                                                                                        │
│ Created │ AGENT_AccountIntelligenceSummary_Test │ ApexClass          │ force-app\main\default\classes\AGENT_AccountIntelligenceSummary_Test.cls-meta.xml                                                                                               │
│ Changed │ AGENT_CreateContactTest               │ ApexClass          │ force-app\main\default\classes\AGENT_CreateContactTest.cls                                                                                                                      │
│ Changed │ AGENT_CreateContactTest               │ ApexClass          │ force-app\main\default\classes\AGENT_CreateContactTest.cls-meta.xml                                                                                                             │
│ Changed │ AGENT_CreateContact_Test              │ ApexClass          │ force-app\main\default\classes\AGENT_CreateContact_Test.cls                                                                                                                     │
│ Changed │ AGENT_CreateContact_Test              │ ApexClass          │ force-app\main\default\classes\AGENT_CreateContact_Test.cls-meta.xml                                                                                                            │
│ Changed │ AGENT_SearchAccounts                  │ ApexClass          │ force-app\main\default\classes\AGENT_SearchAccounts.cls                                                                                                                         │
│ Changed │ AGENT_SearchAccounts                  │ ApexClass          │ force-app\main\default\classes\AGENT_SearchAccounts.cls-meta.xml                                                                                                                │
│ Changed │ AGENT_SearchAccounts_Test             │ ApexClass          │ force-app\main\default\classes\AGENT_SearchAccounts_Test.cls                                                                                                                    │
│ Changed │ AGENT_SearchAccounts_Test             │ ApexClass          │ force-app\main\default\classes\AGENT_SearchAccounts_Test.cls-meta.xml                                                                                                           │
│ Changed │ AGENT_SearchContacts                  │ ApexClass          │ force-app\main\default\classes\AGENT_SearchContacts.cls                                                                                                                         │
│ Changed │ AGENT_SearchContacts                  │ ApexClass          │ force-app\main\default\classes\AGENT_SearchContacts.cls-meta.xml                                                                                                                │
│ Changed │ AGENT_SearchContacts_Test             │ ApexClass          │ force-app\main\default\classes\AGENT_SearchContacts_Test.cls                                                                                                                    │
│ Changed │ AGENT_SearchContacts_Test             │ ApexClass          │ force-app\main\default\classes\AGENT_SearchContacts_Test.cls-meta.xml                                                                                                           │
│ Changed │ AGENT_UpdateAccountField              │ ApexClass          │ force-app\main\default\classes\AGENT_UpdateAccountField.cls                                                                                                                     │
│ Changed │ AGENT_UpdateAccountField              │ ApexClass          │ force-app\main\default\classes\AGENT_UpdateAccountField.cls-meta.xml                                                                                                            │
│ Changed │ AGENT_UpdateAccountField_Test         │ ApexClass          │ force-app\main\default\classes\AGENT_UpdateAccountField_Test.cls                                                                                                                │
│ Changed │ AGENT_UpdateAccountField_Test         │ ApexClass          │ force-app\main\default\classes\AGENT_UpdateAccountField_Test.cls-meta.xml                                                                                                       │
│ Changed │ AGENT_UpdateContactField              │ ApexClass          │ force-app\main\default\classes\AGENT_UpdateContactField.cls                                                                                                                     │
│ Changed │ AGENT_UpdateContactField              │ ApexClass          │ force-app\main\default\classes\AGENT_UpdateContactField.cls-meta.xml                                                                                                            │
│ Changed │ AGENT_UpdateContactField_Test         │ ApexClass          │ force-app\main\default\classes\AGENT_UpdateContactField_Test.cls                                                                                                                │
│ Changed │ AGENT_UpdateContactField_Test         │ ApexClass          │ force-app\main\default\classes\AGENT_UpdateContactField_Test.cls-meta.xml                                                                                                       │
│ Changed │ SAL9_BypassFlow_Test                  │ ApexClass          │ force-app\main\default\classes\SAL9_BypassFlow_Test.cls                                                                                                                         │
│ Changed │ SAL9_BypassFlow_Test                  │ ApexClass          │ force-app\main\default\classes\SAL9_BypassFlow_Test.cls-meta.xml                                                                                                                │
│ Changed │ Astrum_BD_Agent                       │ GenAiPlannerBundle │ force-app\main\default\genAiPlannerBundles\Astrum_BD_Agent\Astrum_BD_Agent.genAiPlannerBundle                                                                                   │
│ Changed │ Astrum_BD_Agent                       │ GenAiPlannerBundle │ force-app\main\default\genAiPlannerBundles\Astrum_BD_Agent\localActions\Account_and_Contact_Management\Create_Contact_with_Duplicate_Check\input\schema.json                    │
│ Changed │ Astrum_BD_Agent                       │ GenAiPlannerBundle │ force-app\main\default\genAiPlannerBundles\Astrum_BD_Agent\localActions\Account_and_Contact_Management\Create_Contact_with_Duplicate_Check\output\schema.json                   │
│ Changed │ Astrum_BD_Agent                       │ GenAiPlannerBundle │ force-app\main\default\genAiPlannerBundles\Astrum_BD_Agent\localActions\Account_and_Contact_Management\Generate_Account_Intelligence_Summary\input\schema.json                  │
│ Changed │ Astrum_BD_Agent                       │ GenAiPlannerBundle │ force-app\main\default\genAiPlannerBundles\Astrum_BD_Agent\localActions\Account_and_Contact_Management\Generate_Account_Intelligence_Summary\output\schema.json                 │
│ Changed │ Astrum_BD_Agent                       │ GenAiPlannerBundle │ force-app\main\default\genAiPlannerBundles\Astrum_BD_Agent\localActions\Account_and_Contact_Management\Generate_Account_Intelligence_Summary_179UD000000mHPx\input\schema.json  │
│ Changed │ Astrum_BD_Agent                       │ GenAiPlannerBundle │ force-app\main\default\genAiPlannerBundles\Astrum_BD_Agent\localActions\Account_and_Contact_Management\Generate_Account_Intelligence_Summary_179UD000000mHPx\output\schema.json │
│ Changed │ Astrum_BD_Agent                       │ GenAiPlannerBundle │ force-app\main\default\genAiPlannerBundles\Astrum_BD_Agent\localActions\Account_and_Contact_Management\Get_Account_Details\input\schema.json                                    │
│ Changed │ Astrum_BD_Agent                       │ GenAiPlannerBundle │ force-app\main\default\genAiPlannerBundles\Astrum_BD_Agent\localActions\Account_and_Contact_Management\Get_Account_Details\output\schema.json                                   │
│ Changed │ Astrum_BD_Agent                       │ GenAiPlannerBundle │ force-app\main\default\genAiPlannerBundles\Astrum_BD_Agent\localActions\Account_and_Contact_Management\Get_Contact_Details\input\schema.json                                    │
│ Changed │ Astrum_BD_Agent                       │ GenAiPlannerBundle │ force-app\main\default\genAiPlannerBundles\Astrum_BD_Agent\localActions\Account_and_Contact_Management\Get_Contact_Details\output\schema.json                                   │
│ Changed │ Astrum_BD_Agent                       │ GenAiPlannerBundle │ force-app\main\default\genAiPlannerBundles\Astrum_BD_Agent\localActions\Account_and_Contact_Management\Search_Accounts\input\schema.json                                        │
│ Changed │ Astrum_BD_Agent                       │ GenAiPlannerBundle │ force-app\main\default\genAiPlannerBundles\Astrum_BD_Agent\localActions\Account_and_Contact_Management\Search_Accounts\output\schema.json                                       │
│ Changed │ Astrum_BD_Agent                       │ GenAiPlannerBundle │ force-app\main\default\genAiPlannerBundles\Astrum_BD_Agent\localActions\Account_and_Contact_Management\Search_Contacts\input\schema.json                                        │
│ Changed │ Astrum_BD_Agent                       │ GenAiPlannerBundle │ force-app\main\default\genAiPlannerBundles\Astrum_BD_Agent\localActions\Account_and_Contact_Management\Search_Contacts\output\schema.json                                       │
│ Changed │ Astrum_BD_Agent                       │ GenAiPlannerBundle │ force-app\main\default\genAiPlannerBundles\Astrum_BD_Agent\localActions\Account_and_Contact_Management\Update_Account_Field\input\schema.json                                   │
│ Changed │ Astrum_BD_Agent                       │ GenAiPlannerBundle │ force-app\main\default\genAiPlannerBundles\Astrum_BD_Agent\localActions\Account_and_Contact_Management\Update_Account_Field\output\schema.json                                  │
│ Changed │ Astrum_BD_Agent                       │ GenAiPlannerBundle │ force-app\main\default\genAiPlannerBundles\Astrum_BD_Agent\localActions\Account_and_Contact_Management\Update_Contact_Field\input\schema.json                                   │
│ Changed │ Astrum_BD_Agent                       │ GenAiPlannerBundle │ force-app\main\default\genAiPlannerBundles\Astrum_BD_Agent\localActions\Account_and_Contact_Management\Update_Contact_Field\output\schema.json                                  │
│ Changed │ Astrum_BD_Agent                       │ GenAiPlannerBundle │ force-app\main\default\genAiPlannerBundles\Astrum_BD_Agent\plannerActions\AnswerQuestionsWithKnowledge_16jUD00000061hN\input\schema.json                                        │
│ Changed │ Astrum_BD_Agent                       │ GenAiPlannerBundle │ force-app\main\default\genAiPlannerBundles\Astrum_BD_Agent\plannerActions\AnswerQuestionsWithKnowledge_16jUD00000061hN\output\schema.json                                       │
└─────────┴───────────────────────────────────────┴────────────────────┴─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘


Test Results Summary
Passing: 52
Failing: 0
Total: 52
Time: 25077

Successfully validated the deployment (0AfUD00000GzVIc0AN).
Run "sf project deploy quick --job-id 0AfUD00000GzVIc0AN" to execute this deploy
```

Deploy ID: `0AfUD00000GzVIc0AN`

Test results summary: Passing 52, Failing 0, Total 52.

Final status: PASS. Sandbox validate-only succeeded.

## Business Summary

- **What was done:** Updated the Generate Account Intelligence Summary input guidance so the planner uses the user-stated account name and does not derive `accountId` from Get Account Details.
- **What was found:** Sandbox validate-only passed with Deploy ID `0AfUD00000GzVIc0AN`; all 52 specified tests passed with zero failures.
- **What this means:** SAL-22 is validated in sandbox and ready for Claude Code review before any production validation or live deploy decision.
- **What is next:** Claude Code should review the evidence and advise the Human on production validate-only authorisation.
- **Decision needed from Human:** Approve or reject a future production validate-only for SAL-22; no production action was run.

## Next Operator
- Run next in: Claude Code / Human
- Reason: SAL-22 sandbox validate-only passed and Codex was instructed to stop before production action.
- Next prompt: Claude Code, review `validation/SAL-22-planner-input-schema-fix-20260511.md` and the schema-only diff for SAL-22, then advise the Human whether to authorise production validate-only. Human to approve or reject the next production step.

## Production Validate-Only - 2026-05-11 [Codex]

### Production Org Safety Confirmation

Command:

```powershell
& "$env:APPDATA\npm\sf.cmd" data query --query "SELECT Id, Name, IsSandbox FROM Organization" --target-org astrum-prod
```

Output:

```text
┌────────────────────┬────────────────┬───────────┐
│ ID                 │ NAME           │ ISSANDBOX │
├────────────────────┼────────────────┼───────────┤
│ 00Dd100000AMk1dEAD │ ASTRUM CRO, SL │ false     │
└────────────────────┴────────────────┴───────────┘

Total number of records retrieved: 1.
Querying Data... done
```

Result: PASS. Target org `astrum-prod` is production (`IsSandbox = false`).

### Git Branch Confirmation

Command:

```powershell
git branch --show-current
```

Output:

```text
main
```

Result: PASS. Current branch is `main`.

### Production Validate-Only

Command:

```powershell
& "$env:APPDATA\npm\sf.cmd" project deploy validate --source-dir force-app/main/default/classes --source-dir force-app/main/default/genAiPlannerBundles --target-org astrum-prod --test-level RunSpecifiedTests --tests AGENT_AccountIntelligenceSummary_Test AGENT_SearchAccounts_Test AGENT_SearchContacts_Test AGENT_UpdateAccountField_Test AGENT_UpdateContactField_Test AGENT_CreateContact_Test AGENT_CreateContactTest SAL9_BypassFlow_Test
```

Output:

```text
Validating Deployment of v66.0 metadata to amit.kumar@astrumcro.com using the v66.0 SOAP API.
───── Validating Deployment ─────
Stages:
1. Preparing
2. Waiting for the org to respond
3. Deploying Metadata
4. Running Tests
5. Updating Source Tracking
6. Done

► Preparing…
   Deploy ID: 0AfTY000003oMmn0AE
   Target Org: amit.kumar@astrumcro.com
√ Preparing (172ms)
► Waiting for the org to respond…
√ Waiting for the org to respond (1.15s)
► Deploying Metadata…
   Components: 0/14 (0%)
   Components: 13/14 (93%)
× Deploying Metadata (6.84s)

Status: Failed
Deploy ID: 0AfTY000003oMmn0AE
Target Org: amit.kumar@astrumcro.com

Elapsed time: 8.17s

Component Failures [1]
┌────────────────────┬─────────────────┬─────────────────────────────────────────┬─────────────┐
│ Type               │ Name            │ Problem                                 │ Line:Column │
├────────────────────┼─────────────────┼─────────────────────────────────────────┼─────────────┤
│ GenAiPlannerBundle │ Astrum_BD_Agent │ Cannot update record as Agent is Active │             │
└────────────────────┴─────────────────┴─────────────────────────────────────────┴─────────────┘


Test Results Summary
Passing: 0
Failing: 0
Total: 0
Error (FailedValidationError): Failed to validate the deployment (0AfTY000003oMmn0AE). Due To:
Error in Astrum_BD_Agent - Cannot update record as Agent is Active

1 component error(s)
```

Deploy ID: `0AfTY000003oMmn0AE`

Test results summary: Passing 0, Failing 0, Total 0.

### Per-Class Coverage Verification

Command:

```powershell
& "$env:APPDATA\npm\sf.cmd" data query --query "SELECT ApexClassOrTrigger.Name, NumLinesCovered, NumLinesUncovered FROM ApexCodeCoverageAggregate WHERE ApexClassOrTrigger.Name IN ('AGENT_AccountIntelligenceSummary','AGENT_SearchAccounts','AGENT_SearchContacts','AGENT_UpdateAccountField','AGENT_UpdateContactField') ORDER BY ApexClassOrTrigger.Name" --use-tooling-api --target-org astrum-prod
```

Output:

```text
┌──────────────────────────────────┬─────────────────┬───────────────────┐
│ APEXCLASSORTRIGGER.NAME          │ NUMLINESCOVERED │ NUMLINESUNCOVERED │
├──────────────────────────────────┼─────────────────┼───────────────────┤
│ AGENT_AccountIntelligenceSummary │ 0               │ 111               │
│ AGENT_SearchAccounts             │ 0               │ 69                │
│ AGENT_SearchContacts             │ 0               │ 77                │
│ AGENT_UpdateAccountField         │ 0               │ 51                │
│ AGENT_UpdateContactField         │ 0               │ 43                │
└──────────────────────────────────┴─────────────────┴───────────────────┘

Total number of records retrieved: 5.
Querying Data... done
```

Per-class coverage table:

| Production class | Lines covered | Lines uncovered | Coverage % | Source | Status |
|---|---:|---:|---:|---|---|
| AGENT_AccountIntelligenceSummary | 0 | 111 | 0.00% | ApexCodeCoverageAggregate | Not meaningful for this failed job |
| AGENT_SearchAccounts | 0 | 69 | 0.00% | ApexCodeCoverageAggregate | Not meaningful for this failed job |
| AGENT_SearchContacts | 0 | 77 | 0.00% | ApexCodeCoverageAggregate | Not meaningful for this failed job |
| AGENT_UpdateAccountField | 0 | 51 | 0.00% | ApexCodeCoverageAggregate | Not meaningful for this failed job |
| AGENT_UpdateContactField | 0 | 43 | 0.00% | ApexCodeCoverageAggregate | Not meaningful for this failed job |

Coverage note: The validate-only failed during metadata deployment before tests ran, so no job-level RunSpecifiedTests coverage was produced for Deploy ID `0AfTY000003oMmn0AE`.

Final status: FAIL. Production validate-only failed because `Astrum_BD_Agent` is active in production and the planner bundle cannot be updated while active.

## Business Summary

- **What was done:** Confirmed the target org is production, confirmed branch `main`, and attempted the authorised SAL-22 production validate-only.
- **What was found:** Validate-only failed with Deploy ID `0AfTY000003oMmn0AE` before tests because `Astrum_BD_Agent` is active in production.
- **What this means:** SAL-22 cannot be production-validated until the Human authorises the required agent deactivation window or another approved deployment path.
- **What is next:** Claude Code should review this evidence and advise the Human on the governed next step.
- **Decision needed from Human:** Decide whether to authorise deactivating the Astrum BD Agent for another production validate-only attempt; no live deploy, quick deploy, or agent state change was run by Codex.

## Next Operator
- Run next in: Claude Code / Human
- Reason: Production validate-only failed because the Astrum BD Agent is active, and Codex was instructed not to reactivate or deactivate the agent.
- Next prompt: Claude Code, review `validation/SAL-22-planner-input-schema-fix-20260511.md`, especially `Production Validate-Only - 2026-05-11 [Codex]`, and advise the Human whether to authorise an agent deactivation window and a retry of production validate-only.

## Production Validate-Only Retry - 2026-05-11 [Codex]

### Production Org Safety Confirmation

Command:

```powershell
& "$env:APPDATA\npm\sf.cmd" data query --query "SELECT Id, Name, IsSandbox FROM Organization" --target-org astrum-prod
```

Output:

```text
┌────────────────────┬────────────────┬───────────┐
│ ID                 │ NAME           │ ISSANDBOX │
├────────────────────┼────────────────┼───────────┤
│ 00Dd100000AMk1dEAD │ ASTRUM CRO, SL │ false     │
└────────────────────┴────────────────┴───────────┘

Total number of records retrieved: 1.
Querying Data... done
```

Result: PASS. Target org `astrum-prod` is production (`IsSandbox = false`).

### Git Branch Confirmation

Command:

```powershell
git branch --show-current
```

Output:

```text
main
```

Result: PASS. Current branch is `main`.

### Production Validate-Only Retry

Context: Human stated the Astrum BD Agent had been deactivated and instructed Codex to proceed with the production validate-only retry.

Command:

```powershell
& "$env:APPDATA\npm\sf.cmd" project deploy validate --source-dir force-app/main/default/classes --source-dir force-app/main/default/genAiPlannerBundles --target-org astrum-prod --test-level RunSpecifiedTests --tests AGENT_AccountIntelligenceSummary_Test AGENT_SearchAccounts_Test AGENT_SearchContacts_Test AGENT_UpdateAccountField_Test AGENT_UpdateContactField_Test AGENT_CreateContact_Test AGENT_CreateContactTest SAL9_BypassFlow_Test
```

Output:

```text
Validating Deployment of v66.0 metadata to amit.kumar@astrumcro.com using the v66.0 SOAP API.
───── Validating Deployment ─────
Stages:
1. Preparing
2. Waiting for the org to respond
3. Deploying Metadata
4. Running Tests
5. Updating Source Tracking
6. Done

► Preparing…
   Deploy ID: 0AfTY000003oMtF0AU
   Target Org: amit.kumar@astrumcro.com
√ Preparing (87ms)
► Waiting for the org to respond…
√ Waiting for the org to respond (1.13s)
► Deploying Metadata…
   Components: 0/14 (0%)
   Components: 13/14 (93%)
√ Deploying Metadata (10.02s)
   Components: 14/14 (100%)
► Running Tests…
   Successful: 6/52 (12%)
   Successful: 11/52 (21%)
   Successful: 15/52 (29%)
   Successful: 45/52 (87%)
   Successful: 52/52 (100%)
√ Running Tests (23.47s)
( ) Updating Source Tracking - Skipped
► Done…
√ Done (2ms)

Status: Succeeded
Deploy ID: 0AfTY000003oMtF0AU
Target Org: amit.kumar@astrumcro.com

Elapsed time: 34.72s

Validated Source
State      Name                                  Type               Path
Unchanged  AGENT_AccountIntelligenceSummary      ApexClass          force-app\main\default\classes\AGENT_AccountIntelligenceSummary.cls
Unchanged  AGENT_AccountIntelligenceSummary      ApexClass          force-app\main\default\classes\AGENT_AccountIntelligenceSummary.cls-meta.xml
Unchanged  AGENT_AccountIntelligenceSummary_Test ApexClass          force-app\main\default\classes\AGENT_AccountIntelligenceSummary_Test.cls
Unchanged  AGENT_AccountIntelligenceSummary_Test ApexClass          force-app\main\default\classes\AGENT_AccountIntelligenceSummary_Test.cls-meta.xml
Unchanged  AGENT_CreateContactTest               ApexClass          force-app\main\default\classes\AGENT_CreateContactTest.cls
Unchanged  AGENT_CreateContactTest               ApexClass          force-app\main\default\classes\AGENT_CreateContactTest.cls-meta.xml
Unchanged  AGENT_CreateContact_Test              ApexClass          force-app\main\default\classes\AGENT_CreateContact_Test.cls
Unchanged  AGENT_CreateContact_Test              ApexClass          force-app\main\default\classes\AGENT_CreateContact_Test.cls-meta.xml
Unchanged  AGENT_SearchAccounts                  ApexClass          force-app\main\default\classes\AGENT_SearchAccounts.cls
Unchanged  AGENT_SearchAccounts                  ApexClass          force-app\main\default\classes\AGENT_SearchAccounts.cls-meta.xml
Unchanged  AGENT_SearchAccounts_Test             ApexClass          force-app\main\default\classes\AGENT_SearchAccounts_Test.cls
Unchanged  AGENT_SearchAccounts_Test             ApexClass          force-app\main\default\classes\AGENT_SearchAccounts_Test.cls-meta.xml
Unchanged  AGENT_SearchContacts                  ApexClass          force-app\main\default\classes\AGENT_SearchContacts.cls
Unchanged  AGENT_SearchContacts                  ApexClass          force-app\main\default\classes\AGENT_SearchContacts.cls-meta.xml
Unchanged  AGENT_SearchContacts_Test             ApexClass          force-app\main\default\classes\AGENT_SearchContacts_Test.cls
Unchanged  AGENT_SearchContacts_Test             ApexClass          force-app\main\default\classes\AGENT_SearchContacts_Test.cls-meta.xml
Unchanged  AGENT_UpdateAccountField              ApexClass          force-app\main\default\classes\AGENT_UpdateAccountField.cls
Unchanged  AGENT_UpdateAccountField              ApexClass          force-app\main\default\classes\AGENT_UpdateAccountField.cls-meta.xml
Unchanged  AGENT_UpdateAccountField_Test         ApexClass          force-app\main\default\classes\AGENT_UpdateAccountField_Test.cls
Unchanged  AGENT_UpdateAccountField_Test         ApexClass          force-app\main\default\classes\AGENT_UpdateAccountField_Test.cls-meta.xml
Unchanged  AGENT_UpdateContactField              ApexClass          force-app\main\default\classes\AGENT_UpdateContactField.cls
Unchanged  AGENT_UpdateContactField              ApexClass          force-app\main\default\classes\AGENT_UpdateContactField.cls-meta.xml
Unchanged  AGENT_UpdateContactField_Test         ApexClass          force-app\main\default\classes\AGENT_UpdateContactField_Test.cls
Unchanged  AGENT_UpdateContactField_Test         ApexClass          force-app\main\default\classes\AGENT_UpdateContactField_Test.cls-meta.xml
Unchanged  SAL9_BypassFlow_Test                  ApexClass          force-app\main\default\classes\SAL9_BypassFlow_Test.cls
Unchanged  SAL9_BypassFlow_Test                  ApexClass          force-app\main\default\classes\SAL9_BypassFlow_Test.cls-meta.xml
Changed    Astrum_BD_Agent                       GenAiPlannerBundle force-app\main\default\genAiPlannerBundles\Astrum_BD_Agent\Astrum_BD_Agent.genAiPlannerBundle
Changed    Astrum_BD_Agent                       GenAiPlannerBundle force-app\main\default\genAiPlannerBundles\Astrum_BD_Agent\localActions\Account_and_Contact_Management\Generate_Account_Intelligence_Summary\input\schema.json
Changed    Astrum_BD_Agent                       GenAiPlannerBundle force-app\main\default\genAiPlannerBundles\Astrum_BD_Agent\plannerActions\AnswerQuestionsWithKnowledge_16jUD00000061hN\output\schema.json

Test Results Summary
Passing: 52
Failing: 0
Total: 52
Time: 24224

Successfully validated the deployment (0AfTY000003oMtF0AU).
Run "sf project deploy quick --job-id 0AfTY000003oMtF0AU" to execute this deploy
```

Deploy ID: `0AfTY000003oMtF0AU`

Test results summary: Passing 52, Failing 0, Total 52.

Warnings: None shown by validate-only output. Deploy report JSON returned `"warnings": []`.

### Per-Class Coverage Verification

Command:

```powershell
& "$env:APPDATA\npm\sf.cmd" data query --query "SELECT ApexClassOrTrigger.Name, NumLinesCovered, NumLinesUncovered FROM ApexCodeCoverageAggregate WHERE ApexClassOrTrigger.Name IN ('AGENT_AccountIntelligenceSummary','AGENT_SearchAccounts','AGENT_SearchContacts','AGENT_UpdateAccountField','AGENT_UpdateContactField') ORDER BY ApexClassOrTrigger.Name" --use-tooling-api --target-org astrum-prod
```

Output:

```text
┌──────────────────────────────────┬─────────────────┬───────────────────┐
│ APEXCLASSORTRIGGER.NAME          │ NUMLINESCOVERED │ NUMLINESUNCOVERED │
├──────────────────────────────────┼─────────────────┼───────────────────┤
│ AGENT_AccountIntelligenceSummary │ 0               │ 111               │
│ AGENT_SearchAccounts             │ 0               │ 69                │
│ AGENT_SearchContacts             │ 0               │ 77                │
│ AGENT_UpdateAccountField         │ 0               │ 51                │
│ AGENT_UpdateContactField         │ 0               │ 43                │
└──────────────────────────────────┴─────────────────┴───────────────────┘

Total number of records retrieved: 5.
Querying Data... done
```

Coverage note: `ApexCodeCoverageAggregate` returned zero covered lines, matching the known RunSpecifiedTests aggregate behaviour observed in SAL-21 and earlier SAL-22 evidence. Codex retrieved the read-only deploy report JSON for Deploy ID `0AfTY000003oMtF0AU` and used job-level `runTestResult.codeCoverage` for the table below.

Job-level RunSpecifiedTests coverage from deploy report:

| Production class | Locations covered | Locations not covered | Coverage % | Status |
|---|---:|---:|---:|---|
| AGENT_AccountIntelligenceSummary | 95 | 16 | 85.59% | PASS |
| AGENT_SearchAccounts | 61 | 8 | 88.41% | PASS |
| AGENT_SearchContacts | 69 | 8 | 89.61% | PASS |
| AGENT_UpdateAccountField | 46 | 5 | 90.20% | PASS |
| AGENT_UpdateContactField | 38 | 5 | 88.37% | PASS |

All production package classes individually passed >=75% in the validation job: Yes.

Final status: PASS. Production validate-only succeeded after the Human confirmed the Astrum BD Agent had been deactivated. No live deploy or quick deploy was run.

## Business Summary

- **What was done:** Confirmed production org safety and branch `main`, then reran the authorised SAL-22 production validate-only after Human-confirmed agent deactivation.
- **What was found:** Validate-only passed with Deploy ID `0AfTY000003oMtF0AU`; all 52 specified tests passed; job-level coverage for all five production package classes is above 75%.
- **What this means:** SAL-22 is production-validated and ready for Claude Code review before any live deploy or quick deploy decision.
- **What is next:** Claude Code should review this evidence and advise the Human whether to authorise quick deploy/live deploy.
- **Decision needed from Human:** Approve or reject quick deploy/live deploy for validated job `0AfTY000003oMtF0AU`; Codex did not run it.

## Next Operator
- Run next in: Claude Code / Human
- Reason: SAL-22 production validate-only passed, and deployment authority rests with Human after Claude Code review.
- Next prompt: Claude Code, review `validation/SAL-22-planner-input-schema-fix-20260511.md`, especially `Production Validate-Only Retry - 2026-05-11 [Codex]`, and advise the Human whether to approve quick deploy/live deploy for Deploy ID `0AfTY000003oMtF0AU`.
