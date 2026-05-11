# SAL-21 Search Accounts Client Type Fix - 2026-05-11

## Business Summary

- **What was done:** Fixed the Search Accounts action so business-user searches for biotechnology accounts use Astrum's account classification field.
- **What was found:** Sandbox validation, production validate-only, production deployment, and production smoke verification all passed. Production deploy ID: `0AfTY000003oPnt0AE`.
- **What this means:** The production Search Accounts action now returns Account records classified as Biotech even when standard Industry is blank.
- **What is next:** Human should run one Agent Builder Conversation Preview check for the exact business utterance.
- **Decision needed from Human:** Decide whether to commit the two Apex file changes after reviewing this evidence.

## Production-Observed Symptom

Production Agent Builder / Conversation Preview did not return matching accounts for:

`Find accounts in the biotechnology industry.`

Matching Account records exist in production, but their authoritative Astrum classification is `Account.Client_Type__c = "Biotech"` and standard `Account.Industry` may be blank.

## Confirmed Root Cause

Classified as:

- A. Apex search logic only checked Account `Name`, standard `Industry`, and `Type`.
- B. Apex did not normalise `biotechnology`, `biotech`, or `biotechnologies` to `Client_Type__c = "Biotech"`.
- C. Existing action descriptions framed the search as industry/type/name rather than Astrum client type. The deployed behavioral fix handles the planner inputs without requiring a planner bundle deployment.

Not confirmed:

- D. GenAiPlannerBundle action input mapping incomplete.
- E. Permission/FLS issue on `Account.Client_Type__c`.

## Sandbox Safety Proof

Commands run:

```powershell
git branch --show-current
git status --short
& "$env:APPDATA\npm\sf.cmd" org list
& "$env:APPDATA\npm\sf.cmd" org display --target-org amit.kumar@astrumcro.com.astrumpar --json
& "$env:APPDATA\npm\sf.cmd" data query --query "SELECT Id, Name, IsSandbox FROM Organization" --target-org amit.kumar@astrumcro.com.astrumpar --json
```

Results:

- Branch: `main`
- Working tree was already dirty before SAL-21 work. Human confirmed Codex may proceed without reverting existing changes.
- Sandbox org: `amit.kumar@astrumcro.com.astrumpar`
- Sandbox org ID: `00DUD000007zF692AE`
- Sandbox instance: `https://astrum--astrumpar.sandbox.my.salesforce.com`
- `Organization.IsSandbox = true`
- Salesforce CLI required elevated execution because the sandbox could not read `%APPDATA%\npm`.
- Sensitive `org display` session-token output was not copied into this evidence file.

## Field And Data Assumption Checks - Sandbox

Commands run:

```powershell
& "$env:APPDATA\npm\sf.cmd" data query --query "SELECT QualifiedApiName, DataType, Label FROM FieldDefinition WHERE EntityDefinition.QualifiedApiName = 'Account' AND QualifiedApiName = 'Client_Type__c'" --target-org amit.kumar@astrumcro.com.astrumpar --use-tooling-api --json
& "$env:APPDATA\npm\sf.cmd" sobject describe --sobject Account --target-org amit.kumar@astrumcro.com.astrumpar --json
& "$env:APPDATA\npm\sf.cmd" data query --query "SELECT Id, Name, Client_Type__c, Industry FROM Account WHERE Client_Type__c = 'Biotech' WITH USER_MODE LIMIT 5" --target-org amit.kumar@astrumcro.com.astrumpar --json
```

Results:

- `Account.Client_Type__c` exists.
- Field label: `Client Type`.
- Field type: `Picklist`.
- Picklist value `Biotech` exists and is active.
- User-mode query succeeded, confirming the running user can read `Client_Type__c`.
- At least one sandbox Account exists with `Client_Type__c = "Biotech"`.
- Example sandbox result: `Test Account 1`, `Client_Type__c = Biotech`, `Industry = null`.
- Standard `Account.Industry` is not reliable for this scenario.

Note: `PicklistValueInfo` query was not supported through the attempted API path, so object describe was used to confirm active picklist metadata.

## Files Changed

- `force-app/main/default/classes/AGENT_SearchAccounts.cls`
- `force-app/main/default/classes/AGENT_SearchAccounts_Test.cls`

## Exact Implementation Summary

- Added `Client_Type__c` to the Search Accounts SOQL query and formatted output.
- Added narrow normalization for `biotech`, `biotechnology`, and `biotechnologies` to `Client_Type__c = "Biotech"`.
- Treated biotechnology-style `IndustryFilter` values as Astrum client-type searches.
- Treated exact/generic biotechnology search terms, including `Find accounts in the biotechnology industry`, as Astrum client-type searches.
- Preserved normal account name search for non-classification search terms.
- Preserved standard `Industry` searches for non-Biotech values.
- Preserved `Type` filtering and combined-filter behavior.
- Preserved `public with sharing` and the existing `WITH USER_MODE` query pattern.

## Tests Updated

`AGENT_SearchAccounts_Test` now covers:

- Isolated test Account with `Client_Type__c = "Biotech"`.
- Isolated non-Biotech Account.
- `IndustryFilter = "Biotechnology"` returns Biotech client-type accounts.
- `SearchTerm = "biotech"` returns Biotech client-type accounts.
- `SearchTerm = "biotechnologies"` returns Biotech client-type accounts.
- Exact utterance-style input `Find accounts in the biotechnology industry` returns Biotech client-type accounts.
- Non-Biotech / standard Industry-only Biotechnology Account is excluded for Astrum Biotech classification searches.
- Existing name search still works.
- Existing standard non-Biotech Industry search still works.
- Existing type search still works.

## Local Checks

Command run:

```powershell
git diff --check -- "force-app/main/default/classes/AGENT_SearchAccounts.cls" "force-app/main/default/classes/AGENT_SearchAccounts_Test.cls"
```

Result:

- Passed with only existing line-ending warnings.
- No XML metadata was changed for this fix, so XML parsing was not applicable.

## Sandbox Deployment And Test Result

Command run:

```powershell
& "$env:APPDATA\npm\sf.cmd" project deploy start --source-dir force-app/main/default/classes/AGENT_SearchAccounts.cls --source-dir force-app/main/default/classes/AGENT_SearchAccounts_Test.cls --target-org amit.kumar@astrumcro.com.astrumpar --test-level RunSpecifiedTests --tests AGENT_SearchAccounts_Test --wait 30 --json
```

Result:

- Deploy ID: `0AfUD00000GznDt0AJ`
- Target org: `astrum--astrumpar.sandbox.my.salesforce.com`
- Completed: `2026-05-11T13:05:59.000Z`
- Components deployed: `AGENT_SearchAccounts`, `AGENT_SearchAccounts_Test`
- Status: `Succeeded`
- Tests: `11/11` passed
- Failures: `0`

## Sandbox Smoke Verification

Command run:

```apex
AGENT_SearchAccounts.SearchRequest req = new AGENT_SearchAccounts.SearchRequest();
req.SearchTerm = 'Find accounts in the biotechnology industry';
List<AGENT_SearchAccounts.SearchResult> results =
    AGENT_SearchAccounts.searchAccounts(new List<AGENT_SearchAccounts.SearchRequest>{ req });
System.debug(results[0].AccountCount);
System.debug(results[0].ErrorMessage);
System.debug(results[0].ResultsSummary);
```

Result:

- Compiled successfully.
- Executed successfully.
- `AccountCount = 1`
- `ErrorMessage = null`
- Returned `Test Account 1` with `Client Type: Biotech` and blank standard `Industry`.
- DML statements: `0`

Agent Builder Conversation Preview was not run by Codex because no authenticated browser automation path was available in this session.

## Production Target Proof

Commands run:

```powershell
& "$env:APPDATA\npm\sf.cmd" org display --target-org astrum-prod --json
& "$env:APPDATA\npm\sf.cmd" data query --query "SELECT Id, Name, IsSandbox FROM Organization" --target-org astrum-prod --json
```

Sanitised results:

- Production alias: `astrum-prod`
- Username: `amit.kumar@astrumcro.com`
- Org ID: `00Dd100000AMk1dEAD`
- Instance URL: `https://astrum.my.salesforce.com`
- Connected status: `Connected`
- `Organization.IsSandbox = false`
- Sensitive `org display` session-token output was not copied into this evidence file.

## Production Validate-Only Result

Command run:

```powershell
& "$env:APPDATA\npm\sf.cmd" project deploy validate --source-dir force-app/main/default/classes/AGENT_SearchAccounts.cls --source-dir force-app/main/default/classes/AGENT_SearchAccounts_Test.cls --target-org astrum-prod --test-level RunLocalTests --wait 60 --json
```

Result:

- Validate-only ID: `0AfTY000003oPmH0AU`
- Target org: `astrum.my.salesforce.com`
- Completed: `2026-05-11T13:07:46.000Z`
- Components validated: `AGENT_SearchAccounts`, `AGENT_SearchAccounts_Test`
- Status: `Succeeded`
- Tests: `66/66` passed
- Failures: `0`
- Component errors: `0`
- Test level: `RunLocalTests`

## Production Deployment Result

Command run:

```powershell
& "$env:APPDATA\npm\sf.cmd" project deploy start --source-dir force-app/main/default/classes/AGENT_SearchAccounts.cls --source-dir force-app/main/default/classes/AGENT_SearchAccounts_Test.cls --target-org astrum-prod --test-level RunLocalTests --wait 60 --json
```

Result:

- Deploy ID: `0AfTY000003oPnt0AE`
- Target org: `astrum.my.salesforce.com`
- Started: `2026-05-11T13:08:05.000Z`
- Completed: `2026-05-11T13:08:37.000Z`
- Components deployed: `AGENT_SearchAccounts`, `AGENT_SearchAccounts_Test`
- Status: `Succeeded`
- Tests: `66/66` passed
- Failures: `0`
- Component errors: `0`
- Test level: `RunLocalTests`

## Production Smoke Verification

Commands run:

```powershell
& "$env:APPDATA\npm\sf.cmd" sobject describe --sobject Account --target-org astrum-prod --json
& "$env:APPDATA\npm\sf.cmd" data query --query "SELECT Id, Name, Client_Type__c, Industry FROM Account WHERE Client_Type__c = 'Biotech' WITH USER_MODE LIMIT 5" --target-org astrum-prod --json
```

Results:

- `Account.Client_Type__c` exists in production.
- `Biotech` exists and is active.
- Production has readable Biotech Accounts.
- Sample results all had `Client_Type__c = "Biotech"` and `Industry = null`.
- Sample Accounts: `bitop AG`, `ASAC Pharmaceutical`, `Immunic Therapeutics`, `THERIVA BIOLOGICS, SL.`, `Alfa Sigma`.

Production Apex smoke:

```apex
AGENT_SearchAccounts.SearchRequest req = new AGENT_SearchAccounts.SearchRequest();
req.SearchTerm = 'Find accounts in the biotechnology industry';
List<AGENT_SearchAccounts.SearchResult> results =
    AGENT_SearchAccounts.searchAccounts(new List<AGENT_SearchAccounts.SearchRequest>{ req });
System.debug(results[0].AccountCount);
System.debug(results[0].ErrorMessage);
System.debug(results[0].ResultsSummary);
```

Result:

- Compiled successfully.
- Executed successfully.
- `AccountCount = 10`
- `ErrorMessage = null`
- Returned Biotech accounts including `bitop AG`, `ASAC Pharmaceutical`, `Immunic Therapeutics`, `THERIVA BIOLOGICS, SL.`, `Alfa Sigma`, `Probelte Pharma`, `LDS, lyotropic delivery systems`, `Taiho Oncology`, `Roca Therapeutics`, and `Green Phoenix Labs`.
- Returned rows showed `Client Type: Biotech`.
- Returned rows showed blank standard `Industry`, confirming the fix no longer depends on standard `Industry`.
- DML statements: `0`

Agent Builder Conversation Preview was not run by Codex because no authenticated production browser automation path was available in this session. The deployed invocable action was smoke-tested directly with the exact utterance text and returned the expected Biotech accounts.

## What Was Not Changed

- No Account records were created, updated, deleted, or bulk modified.
- No S2 Opportunity Management or S3 Data Quality metadata was changed.
- No Flow metadata was changed.
- No permission set was changed.
- No GenAiPlannerBundle was deployed.
- No production agent activation, deactivation, or publishing action was performed.
- No Linear issue was updated.
- No git commit or push was performed.
- SAL-21 AiEvaluationDefinition metadata was not changed or deployed; the production fix was kept to the minimum Apex scope and verified through Apex tests plus action-level smoke.

## Residual Risks

- The action-level production smoke passed, but Human should still run Agent Builder Conversation Preview to confirm the live planner launches Search Accounts for the exact utterance after any Agent Builder caching or runtime routing behavior.
- The planner bundle file was already dirty before this work. This fix deliberately avoided deploying it to prevent unrelated metadata changes from being included.

## Rollback Approach

If rollback is required, restore the prior versions of:

- `AGENT_SearchAccounts`
- `AGENT_SearchAccounts_Test`

Then deploy only those two Apex classes to the affected org with `RunLocalTests` in production. No data rollback is required because this change did not mutate Account data.

## Recommended Next Human Check

Run production Agent Builder / Conversation Preview with:

`Find accounts in the biotechnology industry.`

Expected result:

- Route: `Account and Contact Management`
- Action: `Search Accounts`
- Returned accounts have `Client_Type__c = "Biotech"`
- Standard `Industry` may be blank and should not prevent results.
