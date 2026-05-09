# SAL-21 Production Validate-Only Evidence - 2026-05-09

## Scope

- Agent: Codex (Builder)
- Command type: validate-only deployment
- Target org username: `amit.kumar@astrumcro.com`
- Target org alias/context: `astrum-prod`
- Metadata requested: `GenAiPlannerBundle:Astrum_BD_Agent`
- Test level requested: `RunLocalTests`
- Live deploy performed: No
- Linear update performed: No

## Command

```powershell
& "$env:APPDATA\npm\sf.cmd" project deploy validate --metadata GenAiPlannerBundle:Astrum_BD_Agent --target-org amit.kumar@astrumcro.com --test-level RunLocalTests
```

## Validate-Only Result

| Item | Result |
|---|---|
| Validate ID | `0AfTY000003nxBh0AI` |
| Status | Failed |
| `checkOnly` | `true` |
| `dry-run` | `true` |
| Completed Date | `2026-05-09T09:11:46.000Z` |
| Components Total | 1 |
| Components Deployed | 0 |
| Component Errors | 1 |
| Tests Enabled | true |
| Tests Completed | 0 |
| Tests Total | 0 |
| Test Errors | 0 |

## Component Result

| Type | Name | Result | Problem | Line:Column |
|---|---|---|---|---|
| `GenAiPlannerBundle` | `Astrum_BD_Agent` | FAIL | The invocation target value `AGENT_UpdateContactField` (type: apex) for action `Update_Contact_Field` is invalid. Check that the referenced target exists in your org, or update the invocation target field with a valid value. | `10:18` |

## Test Run Result

| Metric | Value |
|---|---:|
| Passing | 0 |
| Failing | 0 |
| Total | 0 |

Tests did not run because the validate-only deployment failed during the component validation phase.

## Org-Wide Apex Coverage

The validate-only job did not report coverage because no Apex tests ran. Codex ran this read-only Tooling API query against the same production org to capture the current org-wide coverage position:

```powershell
& "$env:APPDATA\npm\sf.cmd" data query --use-tooling-api --query "SELECT PercentCovered FROM ApexOrgWideCoverage" --target-org amit.kumar@astrumcro.com
```

| Query | Result |
|---|---:|
| `SELECT PercentCovered FROM ApexOrgWideCoverage` | 0 |

Coverage %: **0%**

## Full CLI Output

### Validate Command Output

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
   Deploy ID: 0AfTY000003nxBh0AI
   Target Org: amit.kumar@astrumcro.com
√ Preparing (143ms)
( ) Waiting for the org to respond - Skipped
► Deploying Metadata…
   Components: 0/1 (0%)
× Deploying Metadata (3.89s)

Status: Failed
Deploy ID: 0AfTY000003nxBh0AI
Target Org: amit.kumar@astrumcro.com

Elapsed time: 4.03s

Component Failures [1]
┌────────────────────┬─────────────────┬──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┬─────────────┐
│ Type               │ Name            │ Problem                                                                                                                                                                                                                                  │ Line:Column │
├────────────────────┼─────────────────┼──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┼─────────────┤
│ GenAiPlannerBundle │ Astrum_BD_Agent │ The invocation target value 'AGENT_UpdateContactField' (type: apex) for action 'Update_Contact_Field' is invalid. Check that the referenced target exists in your org, or update the invocation target field with a valid value. (10:18) │ 10:18       │
└────────────────────┴─────────────────┴──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┴─────────────┘


Test Results Summary
Passing: 0
Failing: 0
Total: 0
Error (FailedValidationError): Failed to validate the deployment (0AfTY000003nxBh0AI). Due To:
Error in Astrum_BD_Agent - The invocation target value 'AGENT_UpdateContactField' (type: apex) for action 'Update_Contact_Field' is invalid. Check that the referenced target exists in your org, or update the invocation target field with a valid value. (10:18)

1 component error(s)
```

### Deploy Report Output

```text
0AfTY000003nxBh0AI... Failed

Deploy Info
┌──────────────────────────┬──────────────────────────┐
│ Key                      │ Value                    │
├──────────────────────────┼──────────────────────────┤
│ checkOnly                │ true                     │
│ completedDate            │ 2026-05-09T09:11:46.000Z │
│ createdBy                │ 005d1000002tlef          │
│ createdByName            │ Amit Kumar               │
│ createdDate              │ 2026-05-09T09:11:43.000Z │
│ done                     │ true                     │
│ id                       │ 0AfTY000003nxBh0AI       │
│ ignoreWarnings           │ false                    │
│ lastModifiedDate         │ 2026-05-09T09:11:46.000Z │
│ numberComponentErrors    │ 1                        │
│ numberComponentsDeployed │ 0                        │
│ numberComponentsTotal    │ 1                        │
│ numberFiles              │ 52                       │
│ numberTestErrors         │ 0                        │
│ numberTestsCompleted     │ 0                        │
│ numberTestsTotal         │ 0                        │
│ rollbackOnError          │ true                     │
│ runTestsEnabled          │ true                     │
│ startDate                │ 2026-05-09T09:11:43.000Z │
│ status                   │ Failed                   │
│ success                  │ false                    │
│ zipSize                  │ 56780                    │
└──────────────────────────┴──────────────────────────┘


Deploy Options
┌──────────────────┬────────────────────────────────────────────────────────────────┐
│ Key              │ Value                                                          │
├──────────────────┼────────────────────────────────────────────────────────────────┤
│ metadata         │ GenAiPlannerBundle:Astrum_BD_Agent                             │
│ target-org       │ amit.kumar@astrumcro.com                                       │
│ test-level       │ RunLocalTests                                                  │
│ ignore-warnings  │ false                                                          │
│ ignore-conflicts │ true                                                           │
│ dry-run          │ true                                                           │
│ api              │ SOAP                                                           │
│ manifest         │ C:\Users\Amit Asthana\.sf\manifestCache\0AfTY000003nxBh0AI.xml │
│ wait             │ 33 minutes                                                     │
│ isMdapi          │ false                                                          │
│ job-id           │ 0AfTY000003nxBh0AI                                             │
└──────────────────┴────────────────────────────────────────────────────────────────┘


Component Failures [1]
┌────────────────────┬─────────────────┬──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┬─────────────┐
│ Type               │ Name            │ Problem                                                                                                                                                                                                                                  │ Line:Column │
├────────────────────┼─────────────────┼──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┼─────────────┤
│ GenAiPlannerBundle │ Astrum_BD_Agent │ The invocation target value 'AGENT_UpdateContactField' (type: apex) for action 'Update_Contact_Field' is invalid. Check that the referenced target exists in your org, or update the invocation target field with a valid value. (10:18) │ 10:18       │
└────────────────────┴─────────────────┴──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┴─────────────┘


Test Results Summary
Passing: 0
Failing: 0
Total: 0
```

### Coverage Query Output

```text
┌────────────────┐
│ PERCENTCOVERED │
├────────────────┤
│ 0              │
└────────────────┘

Total number of records retrieved: 1.
Querying Data... done
```

## Blocking Errors

- Production does not currently resolve the Apex invocation target `AGENT_UpdateContactField` for planner action `Update_Contact_Field`.
- Because component validation failed first, `RunLocalTests` did not execute in the validate-only job.
- Current org-wide Apex coverage returned by Tooling API is `0%`, below the 75% production deployment threshold.

## Recommended Next Step

Claude Code should review the missing production dependency for `AGENT_UpdateContactField` and decide whether the production deployment sequence must first introduce the Apex class/test dependency, then re-run validate-only deployment with `RunLocalTests` before Human sign-off.

## Files Changed In Follow-Up Builder Pass

| File | Change |
|---|---|
| `force-app/main/default/classes/AGENT_UpdateContactField_Test.cls` | Added `validUpdateMobilePhone` to cover the permitted `Contact.MobilePhone` update path. |
| `validation/SAL-21-production-validate-0AfTY000003nxBh0AI.md` | Filed validate-only production evidence for job `0AfTY000003nxBh0AI`. |

## Next Operator
- Run next in: Claude
- Reason: Claude owns architecture review and must decide the production dependency/remediation sequence before Human sign-off.
- Next prompt: Review `validation/SAL-21-production-validate-0AfTY000003nxBh0AI.md` and the added `AGENT_UpdateContactField_Test.validUpdateMobilePhone` method. Confirm whether the production deployment plan should first validate/deploy the missing `AGENT_UpdateContactField` Apex class and test dependency before re-running planner bundle validation.
