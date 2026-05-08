# SAL-21 Sandbox Deploy And Test Evidence

## Scope

- Target org: `amit.kumar@astrumcro.com.astrumpar`
- Org URL: `https://astrum--astrumpar.sandbox.my.salesforce.com`
- Branch: `feature/astrum-bd-agent-build`
- Production touched: No
- C-09 permission set update deployed: No
- Source files modified during this pass: No Apex or Flow source files modified

## Sandbox Confirmation

| Check | Command result | Status |
|---|---|---|
| `SELECT IsSandbox FROM Organization LIMIT 1` | `IsSandbox = true` | PASS |

## Deployment Evidence

| Step | Components | Deploy ID | Status | Timestamp |
|---|---|---|---|---|
| D-11 | `AGENT_GetAccountDetails`, `AGENT_GetContactDetails` | `0AfUD00000GvASr0AN` | Succeeded | `2026-05-06T09:23:24.000Z` |
| D-12 | `AGENT_SearchAccounts`, `AGENT_SearchContacts`, `AGENT_UpdateAccountField`, `AGENT_UpdateContactField` | `0AfUD00000GvBiH0AV` | Succeeded | `2026-05-06T09:32:05.000Z` |
| D-13 | `GenAiPlannerBundle / Astrum_BD_Agent` | `0AfUD00000GxlT70AJ` | Succeeded | `2026-05-08T08:57:09.000Z` |

## Apex Test Summary

- Coverage-enabled test run ID: `707UD00000qH9M1`
- Test start time: `2026-05-06T09:33:03.000Z`
- Outcome: Passed
- Tests ran: 36
- Passing: 36
- Failing: 0
- Skipped: 0
- Pass rate: 100%
- Test run coverage: 89%
- Org-wide coverage reported by CLI: 36%

## Coverage By Class

| Class | Lines covered | Total lines | Coverage |
|---|---:|---:|---:|
| `AGENT_SearchAccounts` | 61 | 69 | 88% |
| `AGENT_SearchContacts` | 69 | 77 | 90% |
| `AGENT_UpdateAccountField` | 46 | 51 | 90% |
| `AGENT_UpdateContactField` | 38 | 43 | 88% |

## Method Results

| Test class | Test method | Result |
|---|---|---|
| `AGENT_CreateContact_Test` | `tc01_noDuplicateCreatesContact` | PASS |
| `AGENT_CreateContact_Test` | `tc02_duplicateByNameExitsWithoutCreate` | PASS |
| `AGENT_CreateContact_Test` | `tc03_duplicateByEmailExitsWithoutCreate` | PASS |
| `AGENT_CreateContact_Test` | `tc04_accountNotFoundFailsGracefully` | PASS |
| `AGENT_SearchAccounts_Test` | `allFiltersBlankReturnsErrorWithoutQuery` | PASS |
| `AGENT_SearchAccounts_Test` | `combinedFiltersMatchAllProvidedFilters` | PASS |
| `AGENT_SearchAccounts_Test` | `exceptionPathReturnsError` | PASS |
| `AGENT_SearchAccounts_Test` | `industryFilterMatch` | PASS |
| `AGENT_SearchAccounts_Test` | `noResultsReturnsEmptySummary` | PASS |
| `AGENT_SearchAccounts_Test` | `searchTermMatchByName` | PASS |
| `AGENT_SearchAccounts_Test` | `typeFilterMatch` | PASS |
| `AGENT_SearchContacts_Test` | `accountNameMatch` | PASS |
| `AGENT_SearchContacts_Test` | `allFiltersBlankReturnsErrorWithoutQuery` | PASS |
| `AGENT_SearchContacts_Test` | `exceptionPathReturnsError` | PASS |
| `AGENT_SearchContacts_Test` | `noResultsReturnsEmptySummary` | PASS |
| `AGENT_SearchContacts_Test` | `searchTermMatchesLastName` | PASS |
| `AGENT_SearchContacts_Test` | `titleFilterMatch` | PASS |
| `AGENT_UpdateAccountField_Test` | `nonexistentAccountReturnsGracefulError` | PASS |
| `AGENT_UpdateAccountField_Test` | `numberOfEmployeesRejectsNonInteger` | PASS |
| `AGENT_UpdateAccountField_Test` | `rejectsArbitraryField` | PASS |
| `AGENT_UpdateAccountField_Test` | `rejectsOwnerIdWithoutDml` | PASS |
| `AGENT_UpdateAccountField_Test` | `rejectsParentIdWithoutDml` | PASS |
| `AGENT_UpdateAccountField_Test` | `validUpdateDescription` | PASS |
| `AGENT_UpdateAccountField_Test` | `validUpdateIndustry` | PASS |
| `AGENT_UpdateAccountField_Test` | `validUpdateNumberOfEmployees` | PASS |
| `AGENT_UpdateAccountField_Test` | `validUpdatePhone` | PASS |
| `AGENT_UpdateAccountField_Test` | `validUpdateWebsite` | PASS |
| `AGENT_UpdateContactField_Test` | `nonexistentContactReturnsGracefulError` | PASS |
| `AGENT_UpdateContactField_Test` | `rejectsAccountIdWithoutDml` | PASS |
| `AGENT_UpdateContactField_Test` | `rejectsHasOptedOutOfEmail` | PASS |
| `AGENT_UpdateContactField_Test` | `rejectsOwnerId` | PASS |
| `AGENT_UpdateContactField_Test` | `rejectsReportsToId` | PASS |
| `AGENT_UpdateContactField_Test` | `validUpdateDepartment` | PASS |
| `AGENT_UpdateContactField_Test` | `validUpdateEmail` | PASS |
| `AGENT_UpdateContactField_Test` | `validUpdatePhone` | PASS |
| `AGENT_UpdateContactField_Test` | `validUpdateTitle` | PASS |

## SOQL LIKE Bind Variable Gate

| Test class | Method | Confirmation |
|---|---|---|
| `AGENT_SearchAccounts_Test` | `searchTermMatchByName` | PASS - SOQL LIKE bind variable path passed |
| `AGENT_SearchContacts_Test` | `searchTermMatchesLastName` | PASS - SOQL LIKE bind variable path passed |

## Human UI Verification

| Check | Result |
|---|---|
| Agentforce Studio — Astrum BD Agent visible | PASS — confirmed by Human 2026-05-08 |
| Account and Contact Management topic present | PASS — confirmed by Human 2026-05-08 |
| All 7 local actions listed | PASS — confirmed by Human 2026-05-08 |
| Confirmation required on write actions | PASS — confirmed by Human 2026-05-08 |
