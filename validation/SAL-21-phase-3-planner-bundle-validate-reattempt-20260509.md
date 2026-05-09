# SAL-21 Phase 3 Planner Bundle Validate-Only Re-Attempt Evidence - 2026-05-09

## Scope

- Operator: Codex
- Phase: Phase 3 planner bundle validate-only re-attempt
- Target org username: `amit.kumar@astrumcro.com`
- Target org: `astrum-prod` / `https://astrum.my.salesforce.com`
- Authorization: Human, 2026-05-09
- Reviewed/authorized by: Claude Code, 2026-05-09
- Metadata validated:
  - `GenAiPlannerBundle:Astrum_BD_Agent`
- Live deploy run: No
- Quick deploy run: No
- Result: Validate-only succeeded

## Production Safety Confirmation

| Check | Result |
|---|---|
| Git branch before validation | `feature/astrum-bd-agent-build` |
| Target username | `amit.kumar@astrumcro.com` |
| Target alias | `astrum-prod` |
| Target instance URL | `https://astrum.my.salesforce.com` |
| Organization name | `ASTRUM CRO, SL` |
| Organization `IsSandbox` | `false` |
| Safety result | PASS - production target confirmed |

### Git Status Before Validation

```text
?? unpackaged/
?? validation/SAL-21-phase-2-production-validate-20260509.md
?? validation/SAL-21-phase-2-remediation-20260509.md
?? validation/SAL-21-phase-3-production-validate-20260509.md
?? validation/SAL-21-phase-3b-production-remediation-20260509.md
```

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

## Context

This was a Phase 3 planner bundle validate-only re-attempt after Phase 3b dependency remediation.

Previous Phase 3 validate-only deploy `0AfTY000003o1Dh0AI` failed because `AGENT_GetContactDetails` (type: flow) was absent in production.

## Phase 3b Dependency Summary

| Dependency | Phase 3b outcome |
|---|---|
| `AGENT_GetContactDetails` | Deployed to production |
| `AGENT_GetAccountDetails` | Deployed to production |
| `AGENT_AccountIntelligenceSummary` | Deployed to production |

## Carry-Forward Flag

| Dependency | Production visibility | Status flag |
|---|---|---|
| `AGENT_GetContactDetails` | FlowDefinition present, LatestVersionId `301TY00000smcf9YAA` | Draft / no ActiveVersionId |
| `AGENT_GetAccountDetails` | FlowDefinition present, LatestVersionId `301TY00000smcf8YAA` | Draft / no ActiveVersionId |

No manual flow activation was performed. The Draft status did not block this planner bundle validate-only re-attempt.

## Pre-Validation Dependency Spot Check

### FlowDefinition Query

```powershell
& "$env:APPDATA\npm\sf.cmd" data query --use-tooling-api --query "SELECT Id, DeveloperName, ActiveVersionId, LatestVersionId FROM FlowDefinition WHERE DeveloperName IN ('AGENT_GetContactDetails','AGENT_GetAccountDetails') ORDER BY DeveloperName" --target-org amit.kumar@astrumcro.com --json
```

```json
{
  "status": 0,
  "result": {
    "records": [
      {
        "Id": "300TY000010hnUvYAI",
        "DeveloperName": "AGENT_GetAccountDetails",
        "ActiveVersionId": null,
        "LatestVersionId": "301TY00000smcf8YAA"
      },
      {
        "Id": "300TY000010hnUwYAI",
        "DeveloperName": "AGENT_GetContactDetails",
        "ActiveVersionId": null,
        "LatestVersionId": "301TY00000smcf9YAA"
      }
    ],
    "totalSize": 2,
    "done": true
  },
  "warnings": []
}
```

### Prompt Template Metadata Listing

```powershell
& "$env:APPDATA\npm\sf.cmd" org list metadata --metadata-type GenAiPromptTemplate --target-org amit.kumar@astrumcro.com --json
```

Relevant entry:

```json
{
  "createdByName": "Amit Kumar",
  "createdDate": "2026-05-09T16:27:32.000Z",
  "fileName": "genAiPromptTemplates/AGENT_AccountIntelligenceSummary.genAiPromptTemplate",
  "fullName": "AGENT_AccountIntelligenceSummary",
  "id": "0hfTY000002uwcrYAA",
  "lastModifiedByName": "Amit Kumar",
  "lastModifiedDate": "2026-05-09T16:27:33.000Z",
  "manageableState": "unmanaged",
  "type": "GenAiPromptTemplate"
}
```

## Validate-Only Command

```powershell
& "$env:APPDATA\npm\sf.cmd" project deploy validate --metadata GenAiPlannerBundle:Astrum_BD_Agent --target-org amit.kumar@astrumcro.com --test-level RunLocalTests --json
```

## Validation Result Summary

| Item | Value |
|---|---|
| Validate deploy ID | `0AfTY000003o1Ll0AI` |
| `checkOnly` | `true` |
| Status | Succeeded |
| Completed Date | `2026-05-09T16:35:25.000Z` |
| Components Total | 1 |
| Components Validated | 1 |
| Component Errors | 0 |
| Tests Enabled | true |
| Tests Completed | 51 |
| Tests Total | 51 |
| Tests Passing | 51 |
| Tests Failing | 0 |
| Test Errors | 0 |
| Total Test Time | 16314 ms |
| Warnings | None |

## Component Results

| Component | Type | Validate state | Result |
|---|---|---|---|
| `Astrum_BD_Agent` | `GenAiPlannerBundle` | Created | Success |

## Component Errors

None.

## Test Method Summary

| Test class | Test method | Result | Time ms |
|---|---|---|---:|
| `AGENT_CreateContact_Test` | `tc01_noDuplicateCreatesContact` | PASS | 2376 |
| `AGENT_CreateContact_Test` | `tc02_duplicateByNameExitsWithoutCreate` | PASS | 1399 |
| `AGENT_CreateContact_Test` | `tc03_duplicateByEmailExitsWithoutCreate` | PASS | 1324 |
| `AGENT_CreateContact_Test` | `tc04_accountNotFoundFailsGracefully` | PASS | 1098 |
| `AGENT_CreateContactTest` | `tc01_noDuplicateCreatesContact` | PASS | 1324 |
| `AGENT_CreateContactTest` | `tc02_duplicateByNameExitsWithoutCreate` | PASS | 1333 |
| `AGENT_CreateContactTest` | `tc03_duplicateByEmailExitsWithoutCreate` | PASS | 1306 |
| `AGENT_CreateContactTest` | `tc04_accountIdNotFoundFailsGracefully` | PASS | 1220 |
| `AGENT_SearchAccounts_Test` | `allFiltersBlankReturnsErrorWithoutQuery` | PASS | 17 |
| `AGENT_SearchAccounts_Test` | `combinedFiltersMatchAllProvidedFilters` | PASS | 87 |
| `AGENT_SearchAccounts_Test` | `exceptionPathReturnsError` | PASS | 56 |
| `AGENT_SearchAccounts_Test` | `industryFilterMatch` | PASS | 69 |
| `AGENT_SearchAccounts_Test` | `noResultsReturnsEmptySummary` | PASS | 69 |
| `AGENT_SearchAccounts_Test` | `searchTermMatchByName` | PASS | 77 |
| `AGENT_SearchAccounts_Test` | `typeFilterMatch` | PASS | 67 |
| `AGENT_SearchContacts_Test` | `accountNameMatch` | PASS | 55 |
| `AGENT_SearchContacts_Test` | `allFiltersBlankReturnsErrorWithoutQuery` | PASS | 50 |
| `AGENT_SearchContacts_Test` | `exceptionPathReturnsError` | PASS | 56 |
| `AGENT_SearchContacts_Test` | `noResultsReturnsEmptySummary` | PASS | 78 |
| `AGENT_SearchContacts_Test` | `searchTermMatchesLastName` | PASS | 83 |
| `AGENT_SearchContacts_Test` | `titleFilterMatch` | PASS | 86 |
| `AGENT_UpdateAccountField_Test` | `nonexistentAccountReturnsGracefulError` | PASS | 65 |
| `AGENT_UpdateAccountField_Test` | `numberOfEmployeesRejectsNonInteger` | PASS | 76 |
| `AGENT_UpdateAccountField_Test` | `rejectsArbitraryField` | PASS | 63 |
| `AGENT_UpdateAccountField_Test` | `rejectsOwnerIdWithoutDml` | PASS | 73 |
| `AGENT_UpdateAccountField_Test` | `rejectsParentIdWithoutDml` | PASS | 630 |
| `AGENT_UpdateAccountField_Test` | `validUpdateDescription` | PASS | 115 |
| `AGENT_UpdateAccountField_Test` | `validUpdateIndustry` | PASS | 102 |
| `AGENT_UpdateAccountField_Test` | `validUpdateNumberOfEmployees` | PASS | 101 |
| `AGENT_UpdateAccountField_Test` | `validUpdatePhone` | PASS | 102 |
| `AGENT_UpdateAccountField_Test` | `validUpdateWebsite` | PASS | 94 |
| `AGENT_UpdateContactField_Test` | `nonexistentContactReturnsGracefulError` | PASS | 61 |
| `AGENT_UpdateContactField_Test` | `rejectsAccountIdWithoutDml` | PASS | 78 |
| `AGENT_UpdateContactField_Test` | `rejectsHasOptedOutOfEmail` | PASS | 68 |
| `AGENT_UpdateContactField_Test` | `rejectsOwnerId` | PASS | 68 |
| `AGENT_UpdateContactField_Test` | `rejectsReportsToId` | PASS | 68 |
| `AGENT_UpdateContactField_Test` | `validUpdateDepartment` | PASS | 126 |
| `AGENT_UpdateContactField_Test` | `validUpdateEmail` | PASS | 117 |
| `AGENT_UpdateContactField_Test` | `validUpdateMobilePhone` | PASS | 119 |
| `AGENT_UpdateContactField_Test` | `validUpdatePhone` | PASS | 124 |
| `AGENT_UpdateContactField_Test` | `validUpdateTitle` | PASS | 118 |
| `ChangePasswordControllerTest` | `testChangePasswordController` | PASS | 47 |
| `CommunitiesLandingControllerTest` | `testCommunitiesLandingController` | PASS | 48 |
| `CommunitiesLoginControllerTest` | `testCommunitiesLoginController` | PASS | 49 |
| `CommunitiesSelfRegConfirmControllerTest` | `testCommunitiesSelfRegConfirmController` | PASS | 48 |
| `CommunitiesSelfRegControllerTest` | `testCommunitiesSelfRegController` | PASS | 49 |
| `ForgotPasswordControllerTest` | `testForgotPasswordController` | PASS | 47 |
| `MicrobatchSelfRegControllerTest` | `testMicrobatchSelfRegController` | PASS | 49 |
| `MyProfilePageControllerTest` | `testSave` | PASS | 252 |
| `SiteLoginControllerTest` | `testSiteLoginController` | PASS | 48 |
| `SiteRegisterControllerTest` | `testRegistration` | PASS | 55 |

## Coverage Summary

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

## Failure Classification

Not applicable. Validation succeeded.

No new missing dependency issue appeared. No flow activation/status issue appeared. No prompt template visibility issue appeared. No Apex or test failure appeared. No planner bundle XML/configuration issue appeared.

## Explicit Exclusions

- No quick deploy run.
- No live deploy run.
- No `project deploy start` run.
- No agent activation performed.
- No agent publication performed.
- No manual flow activation performed.
- No GenAiPlannerBundle source edits.
- No local metadata modification performed.
- No AGENTS.md edits.
- No unrelated source changes.
- No git add, commit, or push performed.
- No Linear status transition performed.

## Git Status After Evidence File Creation

```text
?? unpackaged/
?? validation/SAL-21-phase-2-production-validate-20260509.md
?? validation/SAL-21-phase-2-remediation-20260509.md
?? validation/SAL-21-phase-3-planner-bundle-validate-reattempt-20260509.md
?? validation/SAL-21-phase-3-production-validate-20260509.md
?? validation/SAL-21-phase-3b-production-remediation-20260509.md
```

## Next Operator
- Run next in: Claude Code
- Reason: Claude must review Phase 3 planner bundle validate-only evidence before any further production deployment, activation, publication, or Phase 4 action is authorised.
- Next prompt: Review `validation/SAL-21-phase-3-planner-bundle-validate-reattempt-20260509.md` and advise the next authorised step for SAL-21.
