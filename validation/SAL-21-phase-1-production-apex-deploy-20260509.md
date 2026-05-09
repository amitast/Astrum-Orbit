# SAL-21 Phase 1 Production Apex Deploy Evidence - 2026-05-09

## Scope

- Agent: Codex (Builder)
- Phase: Phase 1 only
- Target org username: `amit.kumar@astrumcro.com`
- Target org: `astrum-prod` / `https://astrum.my.salesforce.com`
- Components deployed:
  - `ApexClass:AGENT_UpdateContactField`
  - `ApexClass:AGENT_UpdateContactField_Test`
- Purpose: Introduce the missing Apex invocation target dependency required by planner action `Update_Contact_Field`.
- Phases 2-4 executed: No
- Linear update performed: No

## Source Changes Included

| File | Change |
|---|---|
| `force-app/main/default/classes/AGENT_UpdateContactField_Test.cls` | Added `validUpdateMobilePhone` to cover the permitted `Contact.MobilePhone` update path. |

## Phase 1 Deploy Evidence

Deploy ID: `0AfTY000003nxLN0AY`
Target org: `https://astrum.my.salesforce.com`
Timestamp: `2026-05-09T09:23:46Z`
Components deployed: `AGENT_UpdateContactField`, `AGENT_UpdateContactField_Test`
Result: Validate-only succeeded

Deploy ID: `0AfTY000003nxMz0AI`
Target org: `https://astrum.my.salesforce.com`
Timestamp: `2026-05-09T09:24:19Z`
Components deployed: `AGENT_UpdateContactField`, `AGENT_UpdateContactField_Test`
Result: Live deploy succeeded

## Command Sequence

### Validate-Only

```powershell
& "$env:APPDATA\npm\sf.cmd" project deploy validate --source-dir force-app/main/default/classes/AGENT_UpdateContactField.cls --source-dir force-app/main/default/classes/AGENT_UpdateContactField_Test.cls --target-org amit.kumar@astrumcro.com --test-level RunLocalTests
```

### Live Deploy

```powershell
& "$env:APPDATA\npm\sf.cmd" project deploy quick --job-id 0AfTY000003nxLN0AY --target-org amit.kumar@astrumcro.com
```

## Validate-Only Result

| Item | Value |
|---|---|
| Deploy ID | `0AfTY000003nxLN0AY` |
| `checkOnly` | `true` |
| Status | Succeeded |
| Completed Date | `2026-05-09T09:23:46.000Z` |
| Components Total | 2 |
| Components Deployed / Validated | 2 |
| Component Errors | 0 |
| Tests Enabled | true |
| Tests Completed | 28 |
| Tests Total | 28 |
| Test Errors | 0 |
| Test Result | PASS |
| Warnings | None |

## Live Deploy Result

| Item | Value |
|---|---|
| Deploy ID | `0AfTY000003nxMz0AI` |
| `checkOnly` | `false` |
| Status | Succeeded |
| Completed Date | `2026-05-09T09:24:19.000Z` |
| Components Total | 2 |
| Components Deployed | 2 |
| Component Errors | 0 |
| Tests Run During Quick Deploy | 0 |
| Test Errors During Quick Deploy | 0 |
| Warnings | None |

Quick deploy used successful validation job `0AfTY000003nxLN0AY`; tests were run in the validate-only job.

## Apex Test Summary

| Metric | Value |
|---|---:|
| Tests run in validate-only job | 28 |
| Passing | 28 |
| Failing | 0 |
| Total time | 14843 ms |

## `AGENT_UpdateContactField_Test` Method Results

| Test class | Test method | Result |
|---|---|---|
| `AGENT_UpdateContactField_Test` | `nonexistentContactReturnsGracefulError` | PASS |
| `AGENT_UpdateContactField_Test` | `rejectsAccountIdWithoutDml` | PASS |
| `AGENT_UpdateContactField_Test` | `rejectsHasOptedOutOfEmail` | PASS |
| `AGENT_UpdateContactField_Test` | `rejectsOwnerId` | PASS |
| `AGENT_UpdateContactField_Test` | `rejectsReportsToId` | PASS |
| `AGENT_UpdateContactField_Test` | `validUpdateDepartment` | PASS |
| `AGENT_UpdateContactField_Test` | `validUpdateEmail` | PASS |
| `AGENT_UpdateContactField_Test` | `validUpdateMobilePhone` | PASS |
| `AGENT_UpdateContactField_Test` | `validUpdatePhone` | PASS |
| `AGENT_UpdateContactField_Test` | `validUpdateTitle` | PASS |

## Coverage Evidence

| Coverage source | Covered lines | Total lines | Coverage |
|---|---:|---:|---:|
| Validate-only deploy run, all reported Apex classes | 174 | 221 | 78.73% |
| Validate-only deploy run, `AGENT_UpdateContactField` | 38 | 43 | 88.37% |
| Post-live Tooling API `ApexOrgWideCoverage.PercentCovered` | N/A | N/A | 0% |
| Post-live Tooling API `ApexCodeCoverageAggregate` for `AGENT_UpdateContactField` | 0 | 43 | 0% |

Notes:

- Salesforce accepted the validate-only job with `RunLocalTests`, 28/28 tests passing, and no coverage warnings.
- The deploy-run coverage from `project deploy report --json` is the gating coverage evidence for the Phase 1 deployment: 78.73% org-wide across reported Apex classes.
- The post-live Tooling API aggregate coverage queries returned stale/unpopulated values immediately after deploy. They are recorded above for transparency and should not be used as the Phase 1 validation gate without a separate coverage recalculation/test run.

## Production Class Confirmation

Read-only Tooling API query after live deploy:

```sql
SELECT Id, Name, Status, ApiVersion
FROM ApexClass
WHERE Name IN ('AGENT_UpdateContactField','AGENT_UpdateContactField_Test')
ORDER BY Name
```

| Name | Id | Status | API Version |
|---|---|---|---:|
| `AGENT_UpdateContactField` | `01pTY000000tBKbYAM` | Active | 66 |
| `AGENT_UpdateContactField_Test` | `01pTY000000tBKcYAM` | Active | 66 |

## Blocking Errors

None for Phase 1.

## Remaining Risks / Notes For Claude

- Phase 1 only deployed the missing Apex dependency. It did not deploy the planner bundle, permission set changes, or any Phase 2-4 scope.
- The earlier planner-bundle validate-only job `0AfTY000003nxBh0AI` failed because production did not resolve `AGENT_UpdateContactField`. Phase 1 has now created that Apex class in production.
- Claude should review this evidence before authorising Phase 2.

## Next Operator
- Run next in: Claude
- Reason: Claude owns final architecture review of Phase 1 evidence before any Phase 2 authorisation.
- Next prompt: Review `validation/SAL-21-phase-1-production-apex-deploy-20260509.md`, `validation/SAL-21-production-validate-0AfTY000003nxBh0AI.md`, and `AGENT_UpdateContactField_Test.validUpdateMobilePhone`. Confirm Phase 1 is acceptable and decide whether to authorise Codex for Phase 2 validate-only/live sequence.
