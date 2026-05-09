# SAL-21 Phase 3b Production Dependency Remediation Evidence - 2026-05-09

## Scope

- Operator: Codex
- Phase: Phase 3b production dependency audit and remediation
- Target org username: `amit.kumar@astrumcro.com`
- Target org: `astrum-prod` / `https://astrum.my.salesforce.com`
- Authorization: Human approved Phase 2 remediation 2026-05-09; Phase 3b authorized by same audit-then-remediate pattern.
- Failure remediated: Phase 3 planner bundle validate-only deploy `0AfTY000003o1Dh0AI` failed because production did not resolve flow invocation target `AGENT_GetContactDetails`.
- Planner bundle validation or deployment performed: No
- Agent activation or publication performed: No
- Metadata modified locally: No
- Linear update performed: No

## Production Safety Confirmation

| Check | Result |
|---|---|
| Target username | `amit.kumar@astrumcro.com` |
| Target alias | `astrum-prod` |
| Target instance URL | `https://astrum.my.salesforce.com` |
| Organization name | `ASTRUM CRO, SL` |
| Organization `IsSandbox` | `false` |
| Safety result | PASS - production target confirmed |

### Organization Query Output

```json
{
  "status": 0,
  "result": {
    "records": [
      {
        "attributes": {
          "type": "Organization",
          "url": "/services/data/v66.0/sobjects/Organization/00Dd100000AMk1dEAD"
        },
        "Id": "00Dd100000AMk1dEAD",
        "Name": "ASTRUM CRO, SL",
        "IsSandbox": false,
        "InstanceName": "SWE64"
      }
    ],
    "totalSize": 1,
    "done": true
  },
  "warnings": []
}
```

## Pre-Remediation Queries

### Instructed Flow Query

```powershell
& "$env:APPDATA\npm\sf.cmd" data query --use-tooling-api --query "SELECT Id, Name, Status FROM Flow WHERE Definition.DeveloperName IN ('AGENT_GetContactDetails','AGENT_GetAccountDetails','AGENT_CreateContact') ORDER BY Definition.DeveloperName" --target-org amit.kumar@astrumcro.com --json
```

Result: Failed because Tooling API `Flow` does not expose a `Name` column in this org/API.

```json
{
  "name": "INVALID_FIELD",
  "message": "No such column 'Name' on entity 'Flow'.",
  "status": 1,
  "commandName": "DataSoqlQueryCommand"
}
```

### Corrected Flow Tooling API Query

```powershell
& "$env:APPDATA\npm\sf.cmd" data query --use-tooling-api --query "SELECT Id, Status, Definition.DeveloperName FROM Flow WHERE Definition.DeveloperName IN ('AGENT_GetContactDetails','AGENT_GetAccountDetails','AGENT_CreateContact') ORDER BY Definition.DeveloperName" --target-org amit.kumar@astrumcro.com --json
```

```json
{
  "status": 0,
  "result": {
    "records": [
      {
        "Id": "301TY00000slVHNYA2",
        "Status": "Active",
        "Definition": {
          "DeveloperName": "AGENT_CreateContact"
        }
      }
    ],
    "totalSize": 1,
    "done": true
  },
  "warnings": []
}
```

### Instructed Prompt Template Tooling API Query

```powershell
& "$env:APPDATA\npm\sf.cmd" data query --use-tooling-api --query "SELECT Id, DeveloperName, Status FROM AiPromptTemplate WHERE DeveloperName = 'AGENT_AccountIntelligenceSummary'" --target-org amit.kumar@astrumcro.com --json
```

Result: Failed because `AiPromptTemplate` is not exposed as a supported Tooling API sObject in this org/API.

```json
{
  "name": "INVALID_TYPE",
  "message": "sObject type 'AiPromptTemplate' is not supported.",
  "status": 1,
  "commandName": "DataSoqlQueryCommand"
}
```

### Prompt Template Metadata Listing

```powershell
& "$env:APPDATA\npm\sf.cmd" org list metadata --metadata-type GenAiPromptTemplate --target-org amit.kumar@astrumcro.com --json
```

```json
{
  "status": 0,
  "result": [
    {
      "fileName": "genAiPromptTemplates/Opportunity_Follow_Up_Email.genAiPromptTemplate",
      "fullName": "Opportunity_Follow_Up_Email",
      "id": "0hfTY000002SNOlYAO",
      "manageableState": "unmanaged",
      "type": "GenAiPromptTemplate"
    },
    {
      "fileName": "genAiPromptTemplates/Subject_template.genAiPromptTemplate",
      "fullName": "Subject_template",
      "id": "0hfTY000002SPC1YAO",
      "manageableState": "unmanaged",
      "type": "GenAiPromptTemplate"
    }
  ],
  "warnings": []
}
```

## Present / Absent Dependency Table

| Dependency | Type | Pre-remediation production state | Status |
|---|---|---|---|
| `AGENT_CreateContact` | Flow | Present | Active |
| `AGENT_GetAccountDetails` | Flow | Absent | N/A |
| `AGENT_GetContactDetails` | Flow | Absent | N/A |
| `AGENT_AccountIntelligenceSummary` | GenAiPromptTemplate | Absent | N/A |

## Remediation Deploy Selection

Only confirmed-absent dependencies were selected.

| Component selected | Type | Source path | Reason |
|---|---|---|---|
| `AGENT_GetAccountDetails` | Flow | `force-app/main/default/flows/AGENT_GetAccountDetails.flow-meta.xml` | Confirmed absent in production |
| `AGENT_GetContactDetails` | Flow | `force-app/main/default/flows/AGENT_GetContactDetails.flow-meta.xml` | Confirmed absent in production and blocking Phase 3 validate-only |
| `AGENT_AccountIntelligenceSummary` | GenAiPromptTemplate | `force-app/main/default/genAiPromptTemplates/AGENT_AccountIntelligenceSummary.genAiPromptTemplate-meta.xml` | Confirmed absent in production |

Not selected:

| Component | Reason |
|---|---|
| `AGENT_CreateContact` | Already present in production as Active |
| `AGENT_UpdateContactField` | Already inferred present; outside Phase 3b dependency list |
| `GenAiPlannerBundle:Astrum_BD_Agent` | Explicitly excluded from Phase 3b |

## Command Sequence

### Validate-Only

```powershell
& "$env:APPDATA\npm\sf.cmd" project deploy validate --source-dir force-app/main/default/flows/AGENT_GetContactDetails.flow-meta.xml --source-dir force-app/main/default/flows/AGENT_GetAccountDetails.flow-meta.xml --source-dir force-app/main/default/genAiPromptTemplates/AGENT_AccountIntelligenceSummary.genAiPromptTemplate-meta.xml --target-org amit.kumar@astrumcro.com --test-level RunLocalTests --json
```

### Live Quick Deploy

```powershell
& "$env:APPDATA\npm\sf.cmd" project deploy quick --job-id 0AfTY000003o1Gv0AI --target-org amit.kumar@astrumcro.com --json
```

## Validate-Only Result

| Item | Value |
|---|---|
| Validate deploy ID | `0AfTY000003o1Gv0AI` |
| `checkOnly` | `true` |
| Status | Succeeded |
| Completed Date | `2026-05-09T16:27:17.000Z` |
| Components Total | 3 |
| Components Validated | 3 |
| Component Errors | 0 |
| Tests Enabled | true |
| Tests Completed | 51 |
| Tests Total | 51 |
| Tests Passing | 51 |
| Tests Failing | 0 |
| Test Errors | 0 |
| Total Test Time | 26008 ms |
| Warnings | None |

## Validate Component Results

| Component | Type | Validate state | Result |
|---|---|---|---|
| `AGENT_GetAccountDetails` | Flow | Created | Success |
| `AGENT_GetContactDetails` | Flow | Created | Success |
| `AGENT_AccountIntelligenceSummary` | GenAiPromptTemplate | Created | Success |

## Apex Test Summary

| Metric | Value |
|---|---:|
| Tests run in validate-only job | 51 |
| Passing | 51 |
| Failing | 0 |
| Total time | 26008 ms |

## Apex Test Method Results

| Test class | Test method | Result | Time ms |
|---|---|---|---:|
| `AGENT_CreateContact_Test` | `tc01_noDuplicateCreatesContact` | PASS | 3343 |
| `AGENT_CreateContact_Test` | `tc02_duplicateByNameExitsWithoutCreate` | PASS | 2353 |
| `AGENT_CreateContact_Test` | `tc03_duplicateByEmailExitsWithoutCreate` | PASS | 2257 |
| `AGENT_CreateContact_Test` | `tc04_accountNotFoundFailsGracefully` | PASS | 1856 |
| `AGENT_CreateContactTest` | `tc01_noDuplicateCreatesContact` | PASS | 2235 |
| `AGENT_CreateContactTest` | `tc02_duplicateByNameExitsWithoutCreate` | PASS | 2150 |
| `AGENT_CreateContactTest` | `tc03_duplicateByEmailExitsWithoutCreate` | PASS | 2166 |
| `AGENT_CreateContactTest` | `tc04_accountIdNotFoundFailsGracefully` | PASS | 1767 |
| `AGENT_SearchAccounts_Test` | `allFiltersBlankReturnsErrorWithoutQuery` | PASS | 32 |
| `AGENT_SearchAccounts_Test` | `combinedFiltersMatchAllProvidedFilters` | PASS | 142 |
| `AGENT_SearchAccounts_Test` | `exceptionPathReturnsError` | PASS | 120 |
| `AGENT_SearchAccounts_Test` | `industryFilterMatch` | PASS | 117 |
| `AGENT_SearchAccounts_Test` | `noResultsReturnsEmptySummary` | PASS | 125 |
| `AGENT_SearchAccounts_Test` | `searchTermMatchByName` | PASS | 124 |
| `AGENT_SearchAccounts_Test` | `typeFilterMatch` | PASS | 116 |
| `AGENT_SearchContacts_Test` | `accountNameMatch` | PASS | 107 |
| `AGENT_SearchContacts_Test` | `allFiltersBlankReturnsErrorWithoutQuery` | PASS | 158 |
| `AGENT_SearchContacts_Test` | `exceptionPathReturnsError` | PASS | 92 |
| `AGENT_SearchContacts_Test` | `noResultsReturnsEmptySummary` | PASS | 148 |
| `AGENT_SearchContacts_Test` | `searchTermMatchesLastName` | PASS | 152 |
| `AGENT_SearchContacts_Test` | `titleFilterMatch` | PASS | 145 |
| `AGENT_UpdateAccountField_Test` | `nonexistentAccountReturnsGracefulError` | PASS | 112 |
| `AGENT_UpdateAccountField_Test` | `numberOfEmployeesRejectsNonInteger` | PASS | 121 |
| `AGENT_UpdateAccountField_Test` | `rejectsArbitraryField` | PASS | 112 |
| `AGENT_UpdateAccountField_Test` | `rejectsOwnerIdWithoutDml` | PASS | 115 |
| `AGENT_UpdateAccountField_Test` | `rejectsParentIdWithoutDml` | PASS | 112 |
| `AGENT_UpdateAccountField_Test` | `validUpdateDescription` | PASS | 201 |
| `AGENT_UpdateAccountField_Test` | `validUpdateIndustry` | PASS | 173 |
| `AGENT_UpdateAccountField_Test` | `validUpdateNumberOfEmployees` | PASS | 175 |
| `AGENT_UpdateAccountField_Test` | `validUpdatePhone` | PASS | 181 |
| `AGENT_UpdateAccountField_Test` | `validUpdateWebsite` | PASS | 175 |
| `AGENT_UpdateContactField_Test` | `nonexistentContactReturnsGracefulError` | PASS | 107 |
| `AGENT_UpdateContactField_Test` | `rejectsAccountIdWithoutDml` | PASS | 150 |
| `AGENT_UpdateContactField_Test` | `rejectsHasOptedOutOfEmail` | PASS | 138 |
| `AGENT_UpdateContactField_Test` | `rejectsOwnerId` | PASS | 135 |
| `AGENT_UpdateContactField_Test` | `rejectsReportsToId` | PASS | 132 |
| `AGENT_UpdateContactField_Test` | `validUpdateDepartment` | PASS | 280 |
| `AGENT_UpdateContactField_Test` | `validUpdateEmail` | PASS | 233 |
| `AGENT_UpdateContactField_Test` | `validUpdateMobilePhone` | PASS | 230 |
| `AGENT_UpdateContactField_Test` | `validUpdatePhone` | PASS | 225 |
| `AGENT_UpdateContactField_Test` | `validUpdateTitle` | PASS | 226 |
| `ChangePasswordControllerTest` | `testChangePasswordController` | PASS | 84 |
| `CommunitiesLandingControllerTest` | `testCommunitiesLandingController` | PASS | 83 |
| `CommunitiesLoginControllerTest` | `testCommunitiesLoginController` | PASS | 85 |
| `CommunitiesSelfRegConfirmControllerTest` | `testCommunitiesSelfRegConfirmController` | PASS | 83 |
| `CommunitiesSelfRegControllerTest` | `testCommunitiesSelfRegController` | PASS | 85 |
| `ForgotPasswordControllerTest` | `testForgotPasswordController` | PASS | 85 |
| `MicrobatchSelfRegControllerTest` | `testMicrobatchSelfRegController` | PASS | 85 |
| `MyProfilePageControllerTest` | `testSave` | PASS | 428 |
| `SiteLoginControllerTest` | `testSiteLoginController` | PASS | 83 |
| `SiteRegisterControllerTest` | `testRegistration` | PASS | 85 |

## Coverage Evidence

| Coverage source | Covered lines | Total lines | Coverage |
|---|---:|---:|---:|
| Validate-only deploy run, all reported Apex classes | 350 | 418 | 83.73% |
| Validate-only deploy run, `AGENT_SearchAccounts` | 61 | 69 | 88.41% |
| Validate-only deploy run, `AGENT_SearchContacts` | 69 | 77 | 89.61% |
| Validate-only deploy run, `AGENT_UpdateAccountField` | 46 | 51 | 90.20% |
| Validate-only deploy run, `AGENT_UpdateContactField` | 38 | 43 | 88.37% |

Coverage warnings: None.

## Blocking Errors

None.

## Live Quick Deploy Result

| Item | Value |
|---|---|
| Live deploy ID | `0AfTY000003o1IX0AY` |
| Source validate job ID | `0AfTY000003o1Gv0AI` |
| `checkOnly` | `false` |
| Status | Succeeded |
| Completed Date | `2026-05-09T16:27:35.000Z` |
| Components Total | 3 |
| Components Deployed | 3 |
| Component Errors | 0 |
| Tests Run During Quick Deploy | 0 |
| Test Errors During Quick Deploy | 0 |
| Warnings | None |

Quick deploy used successful validation job `0AfTY000003o1Gv0AI`; tests were run in the validate-only job.

## Live Component Results

| Component | Type | Deploy state | Result |
|---|---|---|---|
| `AGENT_GetAccountDetails` | Flow | Created | Success |
| `AGENT_GetContactDetails` | Flow | Created | Success |
| `AGENT_AccountIntelligenceSummary` | GenAiPromptTemplate | Created | Success |

## Post-Deploy Confirmation

### Flow Tooling API Confirmation

```powershell
& "$env:APPDATA\npm\sf.cmd" data query --use-tooling-api --query "SELECT Id, Status, Definition.DeveloperName FROM Flow WHERE Definition.DeveloperName IN ('AGENT_GetContactDetails','AGENT_GetAccountDetails','AGENT_CreateContact') ORDER BY Definition.DeveloperName" --target-org amit.kumar@astrumcro.com --json
```

| Component | Type | Production Id | Status |
|---|---|---|---|
| `AGENT_CreateContact` | Flow | `301TY00000slVHNYA2` | Active |
| `AGENT_GetAccountDetails` | Flow | `301TY00000smcf8YAA` | Draft |
| `AGENT_GetContactDetails` | Flow | `301TY00000smcf9YAA` | Draft |

### Prompt Template Confirmation

Tooling API confirmation was attempted for `GenAiPromptTemplate`, but this org/API does not expose it as a Tooling sObject:

```json
{
  "name": "INVALID_TYPE",
  "message": "sObject type 'GenAiPromptTemplate' is not supported.",
  "status": 1,
  "commandName": "DataSoqlQueryCommand"
}
```

Metadata listing confirms the deployed prompt template is present:

```json
{
  "fileName": "genAiPromptTemplates/AGENT_AccountIntelligenceSummary.genAiPromptTemplate",
  "fullName": "AGENT_AccountIntelligenceSummary",
  "id": "0hfTY000002uwcrYAA",
  "lastModifiedByName": "Amit Kumar",
  "lastModifiedDate": "2026-05-09T16:27:33.000Z",
  "manageableState": "unmanaged",
  "type": "GenAiPromptTemplate"
}
```

## Explicit Exclusions

- No planner bundle validate-only performed.
- No planner bundle deployment performed.
- No agent activation or publication performed.
- No local metadata modification performed.
- No AGENTS.md edits.
- No CLAUDE.md or AI_WORKFLOW.md edits.
- No Linear update performed.
- No Linear status transition performed.
- No unrelated metadata deployed.
- No Phase 3 re-attempt or subsequent action started.

## Git Status After Evidence File Creation

```text
?? unpackaged/
?? validation/SAL-21-phase-2-production-validate-20260509.md
?? validation/SAL-21-phase-2-remediation-20260509.md
?? validation/SAL-21-phase-3-production-validate-20260509.md
?? validation/SAL-21-phase-3b-production-remediation-20260509.md
```

## Next Operator
- Run next in: Claude Code
- Reason: Claude Code must review Phase 3b production dependency remediation evidence before authorizing a Phase 3 planner bundle validate-only re-attempt.
- Next prompt: Review `validation/SAL-21-phase-3b-production-remediation-20260509.md` and advise whether SAL-21 Phase 3 planner bundle validate-only re-attempt is safe to proceed.
