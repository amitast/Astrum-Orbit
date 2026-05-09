# SAL-21 Phase 2 Production Apex Dependency Remediation Evidence - 2026-05-09

## Scope

- Operator: Codex
- Phase: Phase 2 production Apex dependency remediation only
- Target org username: `amit.kumar@astrumcro.com`
- Target org: `astrum-prod` / `https://astrum.my.salesforce.com`
- Failure remediated: Planner bundle validate-only deploy `0AfTY000003o17F0AQ` failed because production did not resolve Apex invocation target `AGENT_UpdateAccountField`.
- Planner bundle validation or deployment performed: No
- Agent activation or publication performed: No
- Metadata modified locally: No

## Production Safety Confirmation

| Check | Result |
|---|---|
| Git branch | `feature/astrum-bd-agent-build` |
| Target username | `amit.kumar@astrumcro.com` |
| Target alias | `astrum-prod` |
| Target instance URL | `https://astrum.my.salesforce.com` |
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

## Pre-Remediation Production Tooling API Query

```powershell
& "$env:APPDATA\npm\sf.cmd" data query --use-tooling-api --query "SELECT Id, Name, Status FROM ApexClass WHERE Name IN ('AGENT_UpdateAccountField','AGENT_UpdateAccountField_Test','AGENT_SearchAccounts','AGENT_SearchAccounts_Test','AGENT_SearchContacts','AGENT_SearchContacts_Test') ORDER BY Name" --target-org amit.kumar@astrumcro.com --json
```

```json
{
  "status": 0,
  "result": {
    "records": [],
    "totalSize": 0,
    "done": true
  },
  "warnings": []
}
```

## Present / Absent Class Table

| Apex class | Pre-remediation production state | Status |
|---|---|---|
| `AGENT_SearchAccounts` | Absent | N/A |
| `AGENT_SearchAccounts_Test` | Absent | N/A |
| `AGENT_SearchContacts` | Absent | N/A |
| `AGENT_SearchContacts_Test` | Absent | N/A |
| `AGENT_UpdateAccountField` | Absent | N/A |
| `AGENT_UpdateAccountField_Test` | Absent | N/A |

## Remediation Deploy Selection

All four search classes were absent, so they were included with the two always-required Update Account classes.

| Class selected | Reason |
|---|---|
| `AGENT_UpdateAccountField` | Always include; missing production dependency for planner action `Update_Account_Field` |
| `AGENT_UpdateAccountField_Test` | Always include paired test |
| `AGENT_SearchAccounts` | Confirmed absent in production |
| `AGENT_SearchAccounts_Test` | Confirmed absent in production |
| `AGENT_SearchContacts` | Confirmed absent in production |
| `AGENT_SearchContacts_Test` | Confirmed absent in production |

## Command Sequence

### Validate-Only

```powershell
& "$env:APPDATA\npm\sf.cmd" project deploy validate --source-dir force-app/main/default/classes/AGENT_UpdateAccountField.cls --source-dir force-app/main/default/classes/AGENT_UpdateAccountField_Test.cls --source-dir force-app/main/default/classes/AGENT_SearchAccounts.cls --source-dir force-app/main/default/classes/AGENT_SearchAccounts_Test.cls --source-dir force-app/main/default/classes/AGENT_SearchContacts.cls --source-dir force-app/main/default/classes/AGENT_SearchContacts_Test.cls --target-org amit.kumar@astrumcro.com --test-level RunLocalTests --json
```

### Live Quick Deploy

```powershell
& "$env:APPDATA\npm\sf.cmd" project deploy quick --job-id 0AfTY000003o18r0AA --target-org amit.kumar@astrumcro.com --json
```

## Validate-Only Result

| Item | Value |
|---|---|
| Validate deploy ID | `0AfTY000003o18r0AA` |
| `checkOnly` | `true` |
| Status | Succeeded |
| Completed Date | `2026-05-09T16:10:41.000Z` |
| Components Total | 6 |
| Components Validated | 6 |
| Component Errors | 0 |
| Tests Enabled | true |
| Tests Completed | 51 |
| Tests Total | 51 |
| Tests Passing | 51 |
| Tests Failing | 0 |
| Test Errors | 0 |
| Total Test Time | 15874 ms |
| Warnings | None |

## Validate Component Results

| Component | Type | Validate state | Result |
|---|---|---|---|
| `AGENT_SearchAccounts` | ApexClass | Created | Success |
| `AGENT_SearchAccounts_Test` | ApexClass | Created | Success |
| `AGENT_SearchContacts` | ApexClass | Created | Success |
| `AGENT_SearchContacts_Test` | ApexClass | Created | Success |
| `AGENT_UpdateAccountField` | ApexClass | Created | Success |
| `AGENT_UpdateAccountField_Test` | ApexClass | Created | Success |

## Apex Test Method Results

| Test class | Test method | Result | Time ms |
|---|---|---|---:|
| `AGENT_SearchAccounts_Test` | `allFiltersBlankReturnsErrorWithoutQuery` | PASS | 22 |
| `AGENT_SearchAccounts_Test` | `combinedFiltersMatchAllProvidedFilters` | PASS | 103 |
| `AGENT_SearchAccounts_Test` | `exceptionPathReturnsError` | PASS | 63 |
| `AGENT_SearchAccounts_Test` | `industryFilterMatch` | PASS | 70 |
| `AGENT_SearchAccounts_Test` | `noResultsReturnsEmptySummary` | PASS | 75 |
| `AGENT_SearchAccounts_Test` | `searchTermMatchByName` | PASS | 74 |
| `AGENT_SearchAccounts_Test` | `typeFilterMatch` | PASS | 70 |
| `AGENT_SearchContacts_Test` | `accountNameMatch` | PASS | 65 |
| `AGENT_SearchContacts_Test` | `allFiltersBlankReturnsErrorWithoutQuery` | PASS | 53 |
| `AGENT_SearchContacts_Test` | `exceptionPathReturnsError` | PASS | 52 |
| `AGENT_SearchContacts_Test` | `noResultsReturnsEmptySummary` | PASS | 99 |
| `AGENT_SearchContacts_Test` | `searchTermMatchesLastName` | PASS | 81 |
| `AGENT_SearchContacts_Test` | `titleFilterMatch` | PASS | 80 |
| `AGENT_UpdateAccountField_Test` | `nonexistentAccountReturnsGracefulError` | PASS | 59 |
| `AGENT_UpdateAccountField_Test` | `numberOfEmployeesRejectsNonInteger` | PASS | 79 |
| `AGENT_UpdateAccountField_Test` | `rejectsArbitraryField` | PASS | 70 |
| `AGENT_UpdateAccountField_Test` | `rejectsOwnerIdWithoutDml` | PASS | 78 |
| `AGENT_UpdateAccountField_Test` | `rejectsParentIdWithoutDml` | PASS | 66 |
| `AGENT_UpdateAccountField_Test` | `validUpdateDescription` | PASS | 109 |
| `AGENT_UpdateAccountField_Test` | `validUpdateIndustry` | PASS | 103 |
| `AGENT_UpdateAccountField_Test` | `validUpdateNumberOfEmployees` | PASS | 102 |
| `AGENT_UpdateAccountField_Test` | `validUpdatePhone` | PASS | 99 |
| `AGENT_UpdateAccountField_Test` | `validUpdateWebsite` | PASS | 97 |
| `AGENT_CreateContact_Test` | `tc01_noDuplicateCreatesContact` | PASS | 2368 |
| `AGENT_CreateContact_Test` | `tc02_duplicateByNameExitsWithoutCreate` | PASS | 1295 |
| `AGENT_CreateContact_Test` | `tc03_duplicateByEmailExitsWithoutCreate` | PASS | 1318 |
| `AGENT_CreateContact_Test` | `tc04_accountNotFoundFailsGracefully` | PASS | 1109 |
| `AGENT_CreateContactTest` | `tc01_noDuplicateCreatesContact` | PASS | 1418 |
| `AGENT_CreateContactTest` | `tc02_duplicateByNameExitsWithoutCreate` | PASS | 1340 |
| `AGENT_CreateContactTest` | `tc03_duplicateByEmailExitsWithoutCreate` | PASS | 1460 |
| `AGENT_CreateContactTest` | `tc04_accountIdNotFoundFailsGracefully` | PASS | 1054 |
| `AGENT_UpdateContactField_Test` | `nonexistentContactReturnsGracefulError` | PASS | 61 |
| `AGENT_UpdateContactField_Test` | `rejectsAccountIdWithoutDml` | PASS | 82 |
| `AGENT_UpdateContactField_Test` | `rejectsHasOptedOutOfEmail` | PASS | 70 |
| `AGENT_UpdateContactField_Test` | `rejectsOwnerId` | PASS | 67 |
| `AGENT_UpdateContactField_Test` | `rejectsReportsToId` | PASS | 74 |
| `AGENT_UpdateContactField_Test` | `validUpdateDepartment` | PASS | 143 |
| `AGENT_UpdateContactField_Test` | `validUpdateEmail` | PASS | 119 |
| `AGENT_UpdateContactField_Test` | `validUpdateMobilePhone` | PASS | 120 |
| `AGENT_UpdateContactField_Test` | `validUpdatePhone` | PASS | 124 |
| `AGENT_UpdateContactField_Test` | `validUpdateTitle` | PASS | 120 |
| `ChangePasswordControllerTest` | `testChangePasswordController` | PASS | 47 |
| `CommunitiesLandingControllerTest` | `testCommunitiesLandingController` | PASS | 47 |
| `CommunitiesLoginControllerTest` | `testCommunitiesLoginController` | PASS | 46 |
| `CommunitiesSelfRegConfirmControllerTest` | `testCommunitiesSelfRegConfirmController` | PASS | 47 |
| `CommunitiesSelfRegControllerTest` | `testCommunitiesSelfRegController` | PASS | 49 |
| `ForgotPasswordControllerTest` | `testForgotPasswordController` | PASS | 49 |
| `MicrobatchSelfRegControllerTest` | `testMicrobatchSelfRegController` | PASS | 46 |
| `MyProfilePageControllerTest` | `testSave` | PASS | 236 |
| `SiteLoginControllerTest` | `testSiteLoginController` | PASS | 47 |
| `SiteRegisterControllerTest` | `testRegistration` | PASS | 49 |

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
| Live deploy ID | `0AfTY000003o1C50AI` |
| Source validate job ID | `0AfTY000003o18r0AA` |
| `checkOnly` | `false` |
| Status | Succeeded |
| Completed Date | `2026-05-09T16:11:10.000Z` |
| Components Total | 6 |
| Components Deployed | 6 |
| Component Errors | 0 |
| Tests Run During Quick Deploy | 0 |
| Test Errors During Quick Deploy | 0 |
| Warnings | None |

Quick deploy used successful validation job `0AfTY000003o18r0AA`; tests were run in the validate-only job.

## Live Component Results

| Component | Type | Deploy state | Result |
|---|---|---|---|
| `AGENT_SearchAccounts` | ApexClass | Created | Success |
| `AGENT_SearchAccounts_Test` | ApexClass | Created | Success |
| `AGENT_SearchContacts` | ApexClass | Created | Success |
| `AGENT_SearchContacts_Test` | ApexClass | Created | Success |
| `AGENT_UpdateAccountField` | ApexClass | Created | Success |
| `AGENT_UpdateAccountField_Test` | ApexClass | Created | Success |

## Post-Deploy Production Tooling API Confirmation

```powershell
& "$env:APPDATA\npm\sf.cmd" data query --use-tooling-api --query "SELECT Id, Name, Status FROM ApexClass WHERE Name IN ('AGENT_UpdateAccountField','AGENT_UpdateAccountField_Test','AGENT_SearchAccounts','AGENT_SearchAccounts_Test','AGENT_SearchContacts','AGENT_SearchContacts_Test') ORDER BY Name" --target-org amit.kumar@astrumcro.com --json
```

| Apex class | Production Id | Status |
|---|---|---|
| `AGENT_SearchAccounts` | `01pTY000000tCADYA2` | Active |
| `AGENT_SearchAccounts_Test` | `01pTY000000tCAEYA2` | Active |
| `AGENT_SearchContacts` | `01pTY000000tCAFYA2` | Active |
| `AGENT_SearchContacts_Test` | `01pTY000000tCAGYA2` | Active |
| `AGENT_UpdateAccountField` | `01pTY000000tCAHYA2` | Active |
| `AGENT_UpdateAccountField_Test` | `01pTY000000tCAIYA2` | Active |

### Post-Deploy Query Output

```json
{
  "status": 0,
  "result": {
    "records": [
      {
        "attributes": {
          "type": "ApexClass",
          "url": "/services/data/v66.0/tooling/sobjects/ApexClass/01pTY000000tCADYA2"
        },
        "Id": "01pTY000000tCADYA2",
        "Name": "AGENT_SearchAccounts",
        "Status": "Active"
      },
      {
        "attributes": {
          "type": "ApexClass",
          "url": "/services/data/v66.0/tooling/sobjects/ApexClass/01pTY000000tCAEYA2"
        },
        "Id": "01pTY000000tCAEYA2",
        "Name": "AGENT_SearchAccounts_Test",
        "Status": "Active"
      },
      {
        "attributes": {
          "type": "ApexClass",
          "url": "/services/data/v66.0/tooling/sobjects/ApexClass/01pTY000000tCAFYA2"
        },
        "Id": "01pTY000000tCAFYA2",
        "Name": "AGENT_SearchContacts",
        "Status": "Active"
      },
      {
        "attributes": {
          "type": "ApexClass",
          "url": "/services/data/v66.0/tooling/sobjects/ApexClass/01pTY000000tCAGYA2"
        },
        "Id": "01pTY000000tCAGYA2",
        "Name": "AGENT_SearchContacts_Test",
        "Status": "Active"
      },
      {
        "attributes": {
          "type": "ApexClass",
          "url": "/services/data/v66.0/tooling/sobjects/ApexClass/01pTY000000tCAHYA2"
        },
        "Id": "01pTY000000tCAHYA2",
        "Name": "AGENT_UpdateAccountField",
        "Status": "Active"
      },
      {
        "attributes": {
          "type": "ApexClass",
          "url": "/services/data/v66.0/tooling/sobjects/ApexClass/01pTY000000tCAIYA2"
        },
        "Id": "01pTY000000tCAIYA2",
        "Name": "AGENT_UpdateAccountField_Test",
        "Status": "Active"
      }
    ],
    "totalSize": 6,
    "done": true
  },
  "warnings": []
}
```

## Explicit Exclusions

- No planner bundle validation or deployment performed.
- No agent activation or publication performed.
- No AGENTS.md edits.
- No Linear status transition.
- No unrelated metadata deployed.
- No sandbox commands run.
- No Phase 3 action started.

## Git Status After Evidence File Creation

```text
?? unpackaged/
?? validation/SAL-21-phase-2-production-validate-20260509.md
?? validation/SAL-21-phase-2-remediation-20260509.md
```

## Next Operator
- Run next in: Claude Code
- Reason: Claude must review Phase 2 production Apex remediation evidence before any Phase 3 planner bundle validation is authorised.
- Next prompt: Review `validation/SAL-21-phase-2-remediation-20260509.md` and advise whether SAL-21 Phase 3 planner bundle validation is safe to proceed.
