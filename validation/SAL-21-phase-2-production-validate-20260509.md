# SAL-21 Phase 2 Production Validate-Only Evidence - 2026-05-09

## Scope

- Agent: Codex (Builder)
- Phase: Phase 2 validate-only
- Target org username: `amit.kumar@astrumcro.com`
- Target org: `astrum-prod` / `https://astrum.my.salesforce.com`
- Metadata validated:
  - `GenAiPlannerBundle:Astrum_BD_Agent`
- Purpose: Validate the production deployability of the `Astrum_BD_Agent` planner bundle after Phase 1.
- Live deploy executed: No
- Metadata modified: No

## Phase 2 Validate-Only Evidence

Deploy ID: `0AfTY000003o17F0AQ`
Target org: `amit.kumar@astrumcro.com` / `astrum-prod`
Timestamp: `2026-05-09T16:02:42.000Z`
Components validated: `GenAiPlannerBundle:Astrum_BD_Agent`
Result: Validate-only failed

## Command Sequence

### Validate-Only

```powershell
& "$env:APPDATA\npm\sf.cmd" project deploy validate --metadata GenAiPlannerBundle:Astrum_BD_Agent --target-org amit.kumar@astrumcro.com --test-level RunLocalTests
```

### Deploy Report

```powershell
& "$env:APPDATA\npm\sf.cmd" project deploy report --job-id 0AfTY000003o17F0AQ --json
```

## Validate-Only Result

| Item | Value |
|---|---|
| Deploy ID | `0AfTY000003o17F0AQ` |
| `checkOnly` | `true` confirmed |
| Status | Failed |
| Completed Date | `2026-05-09T16:02:42.000Z` |
| Components Total | 1 |
| Components Deployed / Validated | 0 |
| Component Errors | 1 |
| Tests Enabled | true |
| Tests Completed | 0 |
| Tests Total | 0 |
| Tests Passing | 0 |
| Tests Failing | 0 |
| Test Errors | 0 |
| Warnings | None |

## Coverage Evidence

| Coverage source | Covered lines | Total lines | Coverage |
|---|---:|---:|---:|
| Validate-only deploy report, org-wide coverage | N/A | N/A | Not reported |
| Validate-only deploy report, per-class coverage | N/A | N/A | Not reported |

Notes:

- The deployment failed during component validation before Apex tests executed.
- The JSON deploy report returned empty `codeCoverage` and `codeCoverageWarnings` arrays.
- No org-wide or per-class coverage figures were produced by this validate-only job.

## Blocking Errors

| Component | Type | Location | Error |
|---|---|---|---|
| `Astrum_BD_Agent` | `GenAiPlannerBundle` | `10:18` | The invocation target value `AGENT_UpdateAccountField` (type: apex) for action `Update_Account_Field` is invalid. Check that the referenced target exists in your org, or update the invocation target field with a valid value. |

## Full CLI Output

```text
Validating Deployment of v66.0 metadata to amit.kumar@astrumcro.com using the v66.0 SOAP API.
----- Validating Deployment -----
Stages:
1. Preparing
2. Waiting for the org to respond
3. Deploying Metadata
4. Running Tests
5. Updating Source Tracking
6. Done

> Preparing...
   Deploy ID: 0AfTY000003o17F0AQ
   Target Org: amit.kumar@astrumcro.com
(+) Preparing (245ms)
( ) Waiting for the org to respond - Skipped
> Deploying Metadata...
   Components: 0/1 (0%)
(x) Deploying Metadata (3.61s)

Status: Failed
Deploy ID: 0AfTY000003o17F0AQ
Target Org: amit.kumar@astrumcro.com

Elapsed time: 3.86s

Component Failures [1]
Type: GenAiPlannerBundle
Name: Astrum_BD_Agent
Problem: The invocation target value 'AGENT_UpdateAccountField' (type: apex) for action 'Update_Account_Field' is invalid. Check that the referenced target exists in your org, or update the invocation target field with a valid value. (10:18)
Line:Column: 10:18


Test Results Summary
Passing: 0
Failing: 0
Total: 0
Error (FailedValidationError): Failed to validate the deployment (0AfTY000003o17F0AQ). Due To:
Error in Astrum_BD_Agent - The invocation target value 'AGENT_UpdateAccountField' (type: apex) for action 'Update_Account_Field' is invalid. Check that the referenced target exists in your org, or update the invocation target field with a valid value. (10:18)

1 component error(s)
```

## Full JSON Deploy Report Output

```json
{
  "status": 0,
  "result": {
    "checkOnly": true,
    "completedDate": "2026-05-09T16:02:42.000Z",
    "createdBy": "005d1000002tlef",
    "createdByName": "Amit Kumar",
    "createdDate": "2026-05-09T16:02:39.000Z",
    "details": {
      "componentFailures": [
        {
          "changed": false,
          "columnNumber": 18,
          "componentType": "GenAiPlannerBundle",
          "created": false,
          "createdDate": "2026-05-09T16:02:42.000Z",
          "deleted": false,
          "fileName": "genAiPlannerBundles/Astrum_BD_Agent.genAiPlannerBundle",
          "fullName": "Astrum_BD_Agent",
          "lineNumber": 10,
          "problem": "The invocation target value 'AGENT_UpdateAccountField' (type: apex) for action 'Update_Account_Field' is invalid. Check that the referenced target exists in your org, or update the invocation target field with a valid value.",
          "problemType": "Error",
          "success": false
        }
      ],
      "componentSuccesses": [
        {
          "changed": true,
          "componentType": "",
          "created": false,
          "createdDate": "2026-05-09T16:02:42.000Z",
          "deleted": false,
          "fileName": "package.xml",
          "fullName": "package.xml",
          "success": true
        }
      ],
      "runTestResult": {
        "numFailures": 0,
        "numTestsRun": 0,
        "totalTime": 0,
        "codeCoverage": [],
        "codeCoverageWarnings": [],
        "failures": [],
        "flowCoverage": [],
        "flowCoverageWarnings": [],
        "successes": []
      }
    },
    "done": true,
    "id": "0AfTY000003o17F0AQ",
    "ignoreWarnings": false,
    "lastModifiedDate": "2026-05-09T16:02:42.000Z",
    "numberComponentErrors": 1,
    "numberComponentsDeployed": 0,
    "numberComponentsTotal": 1,
    "numberFiles": "52",
    "numberTestErrors": 0,
    "numberTestsCompleted": 0,
    "numberTestsTotal": 0,
    "rollbackOnError": true,
    "runTestsEnabled": true,
    "startDate": "2026-05-09T16:02:39.000Z",
    "status": "Failed",
    "success": false,
    "zipSize": "56780",
    "files": [
      {
        "fullName": "Astrum_BD_Agent",
        "type": "GenAiPlannerBundle",
        "state": "Failed",
        "problemType": "Error",
        "filePath": "C:\\Users\\Amit Asthana\\my-ai-project\\force-app\\main\\default\\genAiPlannerBundles\\Astrum_BD_Agent\\Astrum_BD_Agent.genAiPlannerBundle",
        "lineNumber": 10,
        "columnNumber": 18,
        "error": "The invocation target value 'AGENT_UpdateAccountField' (type: apex) for action 'Update_Account_Field' is invalid. Check that the referenced target exists in your org, or update the invocation target field with a valid value. (10:18)"
      }
    ]
  },
  "warnings": []
}
```

## Remaining Risks / Notes For Claude

- Phase 2 validate-only failed because production does not resolve Apex invocation target `AGENT_UpdateAccountField` for planner action `Update_Account_Field`.
- The job was check-only; no live deployment was run.
- No remediation was attempted.

## Next Operator
- Run next in: Claude
- Reason: Claude owns review of Phase 2 validate-only evidence and any decision on whether to authorise remediation or a later phase.
- Next prompt: Review `validation/SAL-21-phase-2-production-validate-20260509.md` and failed validate-only deploy `0AfTY000003o17F0AQ`. Decide whether to authorise a scoped remediation for missing production Apex invocation target `AGENT_UpdateAccountField` before any further SAL-21 deployment action.
