# SAL-21 Phase 3 Production Planner Bundle Validate-Only Evidence - 2026-05-09

## Scope

- Operator: Codex
- Phase: Phase 3 planner bundle validate-only
- Target org username: `amit.kumar@astrumcro.com`
- Target alias: `astrum-prod`
- Instance URL: `https://astrum.my.salesforce.com`
- Organization name: `ASTRUM CRO, SL`
- Organization `IsSandbox`: `false`
- Authorized by: Human, 2026-05-09
- Reviewed by: Claude Code, 2026-05-09
- Metadata validated:
  - `GenAiPlannerBundle:Astrum_BD_Agent`
- Live deploy run: No
- Result: Validate-only failed

## Pre-Flight Org Query Output

```powershell
& "$env:APPDATA\npm\sf.cmd" data query --query "SELECT Id, Name, IsSandbox, InstanceName FROM Organization" --target-org amit.kumar@astrumcro.com --json
```

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

## Command Sequence

### Validate-Only

```powershell
& "$env:APPDATA\npm\sf.cmd" project deploy validate --metadata GenAiPlannerBundle:Astrum_BD_Agent --target-org amit.kumar@astrumcro.com --test-level RunLocalTests --json
```

### Deploy Report

```powershell
& "$env:APPDATA\npm\sf.cmd" project deploy report --job-id 0AfTY000003o1Dh0AI --json
```

## Validate-Only Result

| Item | Value |
|---|---|
| Deploy ID | `0AfTY000003o1Dh0AI` |
| `checkOnly` | `true` confirmed |
| Status | Failed |
| Completed Date | `2026-05-09T16:19:01.000Z` |
| Components Total | 1 |
| Components Validated | 0 |
| Component Errors | 1 |
| Tests Enabled | true |
| Tests Total | 0 |
| Tests Completed | 0 |
| Tests Passing | 0 |
| Tests Failing | 0 |
| Test Errors | 0 |
| Total Test Time | 0 ms |
| Warnings | None |

## Component Results

| Component | Type | Validate state | Result |
|---|---|---|---|
| `Astrum_BD_Agent` | `GenAiPlannerBundle` | Failed | Error: invalid flow invocation target `AGENT_GetContactDetails` for action `Get_Contact_Details` |

## Apex Test Method Results

No Apex tests ran. The validate-only job failed during planner bundle component validation before test execution.

| Test class | Test method | Result | Time ms |
|---|---|---|---:|
| N/A | N/A | Not run | 0 |

## Coverage Evidence

No Apex coverage was reported. The validate-only job failed during planner bundle component validation before test execution.

| Coverage source | Covered lines | Total lines | Coverage |
|---|---:|---:|---:|
| Validate-only deploy report, org-wide coverage | N/A | N/A | Not reported |
| Validate-only deploy report, `AGENT_` classes | N/A | N/A | Not reported |

Coverage warnings: None.

## Blocking Errors

| Component | Type | Location | Error |
|---|---|---|---|
| `Astrum_BD_Agent` | `GenAiPlannerBundle` | `10:18` | The invocation target value `AGENT_GetContactDetails` (type: flow) for action `Get_Contact_Details` is invalid. Check that the referenced target exists in your org, or update the invocation target field with a valid value. |

## Validate Command JSON Output

```json
{
  "name": "FailedValidationError",
  "message": "Failed to validate the deployment (0AfTY000003o1Dh0AI). Due To:\nError in Astrum_BD_Agent - The invocation target value 'AGENT_GetContactDetails' (type: flow) for action 'Get_Contact_Details' is invalid. Check that the referenced target exists in your org, or update the invocation target field with a valid value. (10:18)\r\n\r\n1 component error(s)",
  "exitCode": 1,
  "context": "DeployMetadataValidate",
  "data": {
    "deployId": "0AfTY000003o1Dh0AI"
  },
  "cause": "undefined",
  "warnings": [],
  "code": "FailedValidationError",
  "status": 1,
  "commandName": "DeployMetadataValidate"
}
```

Note: The CLI JSON output also included a local stack trace. It was omitted from this evidence file because it contains local runtime paths and does not add deploy evidence beyond the `FailedValidationError`, deploy ID, and deploy report.

## Deploy Report JSON Output

```json
{
  "status": 0,
  "result": {
    "checkOnly": true,
    "completedDate": "2026-05-09T16:19:01.000Z",
    "createdBy": "005d1000002tlef",
    "createdByName": "Amit Kumar",
    "createdDate": "2026-05-09T16:18:56.000Z",
    "details": {
      "componentFailures": [
        {
          "changed": false,
          "columnNumber": 18,
          "componentType": "GenAiPlannerBundle",
          "created": false,
          "createdDate": "2026-05-09T16:19:00.000Z",
          "deleted": false,
          "fileName": "genAiPlannerBundles/Astrum_BD_Agent.genAiPlannerBundle",
          "fullName": "Astrum_BD_Agent",
          "lineNumber": 10,
          "problem": "The invocation target value 'AGENT_GetContactDetails' (type: flow) for action 'Get_Contact_Details' is invalid. Check that the referenced target exists in your org, or update the invocation target field with a valid value.",
          "problemType": "Error",
          "success": false
        }
      ],
      "componentSuccesses": [
        {
          "changed": true,
          "componentType": "",
          "created": false,
          "createdDate": "2026-05-09T16:19:00.000Z",
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
    "id": "0AfTY000003o1Dh0AI",
    "ignoreWarnings": false,
    "lastModifiedDate": "2026-05-09T16:19:01.000Z",
    "numberComponentErrors": 1,
    "numberComponentsDeployed": 0,
    "numberComponentsTotal": 1,
    "numberFiles": "52",
    "numberTestErrors": 0,
    "numberTestsCompleted": 0,
    "numberTestsTotal": 0,
    "rollbackOnError": true,
    "runTestsEnabled": true,
    "startDate": "2026-05-09T16:18:56.000Z",
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
        "error": "The invocation target value 'AGENT_GetContactDetails' (type: flow) for action 'Get_Contact_Details' is invalid. Check that the referenced target exists in your org, or update the invocation target field with a valid value. (10:18)"
      }
    ]
  },
  "warnings": []
}
```

## Explicit Exclusions

- No live deploy run.
- No `project deploy quick` run.
- No `project deploy start` run.
- No agent activation or publication performed.
- No local metadata modification performed.
- No files in `force-app/` edited.
- No Linear status transition performed.
- No Linear update performed.
- No AGENTS.md edits.
- No CLAUDE.md or AI_WORKFLOW.md edits.
- No Phase 4 or subsequent action started.

## Git Status After Evidence File Creation

```text
?? unpackaged/
?? validation/SAL-21-phase-2-production-validate-20260509.md
?? validation/SAL-21-phase-2-remediation-20260509.md
?? validation/SAL-21-phase-3-production-validate-20260509.md
```

## Next Operator
- Run next in: Claude Code
- Reason: Claude must review Phase 3 validate-only evidence before any live deploy decision.
- Next prompt: Review `validation/SAL-21-phase-3-production-validate-20260509.md` and advise whether SAL-21 Phase 3 live quick deploy of `GenAiPlannerBundle:Astrum_BD_Agent` to `astrum-prod` is safe to proceed.
