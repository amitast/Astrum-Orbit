# SAL-21 Phase 3 Planner Bundle Live Quick Deploy Evidence - 2026-05-09

## 1. Scope

| Item | Value |
|---|---|
| Operator | Codex |
| Phase | Phase 3 live quick deploy |
| Target org username | amit.kumar@astrumcro.com |
| Target alias | astrum-prod |
| Instance URL | https://astrum.my.salesforce.com |
| Authorization chain | Human approval received 2026-05-09; Claude Code review completed 2026-05-09; authorized action was Phase 3 live quick deploy of GenAiPlannerBundle:Astrum_BD_Agent to astrum-prod using validated job 0AfTY000003o1Ll0AI |
| Agent activated | No |
| Agent published | No |

## 2. Production Safety Confirmation

Pre-flight command run first:

```powershell
& "$env:APPDATA\npm\sf.cmd" data query --query "SELECT Id, Name, IsSandbox, InstanceName FROM Organization" --target-org amit.kumar@astrumcro.com --json
```

| Check | Expected | Actual | Status |
|---|---|---|---|
| IsSandbox | false | false | PASS |
| Name | ASTRUM CRO, SL | ASTRUM CRO, SL | PASS |
| InstanceName | Production instance | SWE64 | PASS |

Full org query JSON output:

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

## 3. Git Status Before Deploy

Command:

```powershell
git status --short --untracked-files=all
```

Output:

```text
?? unpackaged/package.xml
?? validation/SAL-21-phase-2-production-validate-20260509.md
?? validation/SAL-21-phase-2-remediation-20260509.md
?? validation/SAL-21-phase-3-planner-bundle-validate-reattempt-20260509.md
?? validation/SAL-21-phase-3-production-validate-20260509.md
?? validation/SAL-21-phase-3b-production-remediation-20260509.md
```

## 4. Exact Deploy Command Run

Actual PowerShell invocation:

```powershell
& "$env:APPDATA\npm\sf.cmd" project deploy quick --job-id 0AfTY000003o1Ll0AI --target-org amit.kumar@astrumcro.com --json
```

Authorized Salesforce CLI command:

```bash
sf project deploy quick --job-id 0AfTY000003o1Ll0AI --target-org amit.kumar@astrumcro.com --json
```

## 5. Validation Result Summary

| Field | Value |
|---|---|
| Deploy ID | 0AfTY000003o1SD0AY |
| checkOnly | false |
| Status | Succeeded |
| Completed Date | 2026-05-09T16:42:52.000Z |
| Components Total | 1 |
| Components Deployed | 1 |
| Component Errors | 0 |
| Tests Run During Quick Deploy | 0 |
| Test Errors | 0 |
| Warnings | None |

## 6. Component Results

| Component Name | Type | Deploy State | Result |
|---|---|---|---|
| Astrum_BD_Agent | GenAiPlannerBundle | Created | Success |

Note: `package.xml` appeared in `componentSuccesses` as the deployment manifest only; `numberComponentsTotal` and `numberComponentsDeployed` both reported `1`.

## 7. Blocking Errors

None.

## 8. Full Deploy JSON Output

```json
{
  "status": 0,
  "result": {
    "checkOnly": false,
    "completedDate": "2026-05-09T16:42:52.000Z",
    "createdBy": "005d1000002tlef",
    "createdByName": "Amit Kumar",
    "createdDate": "2026-05-09T16:42:43.000Z",
    "details": {
      "componentSuccesses": [
        {
          "changed": true,
          "componentType": "GenAiPlannerBundle",
          "created": true,
          "createdDate": "2026-05-09T16:42:50.000Z",
          "deleted": false,
          "fileName": "genAiPlannerBundles/Astrum_BD_Agent.genAiPlannerBundle",
          "fullName": "Astrum_BD_Agent",
          "id": "16jTY000000Oa5ZYAS",
          "success": true
        },
        {
          "changed": true,
          "componentType": "",
          "created": false,
          "createdDate": "2026-05-09T16:42:50.000Z",
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
      },
      "componentFailures": []
    },
    "done": true,
    "id": "0AfTY000003o1SD0AY",
    "ignoreWarnings": false,
    "lastModifiedDate": "2026-05-09T16:42:52.000Z",
    "numberComponentErrors": 0,
    "numberComponentsDeployed": 1,
    "numberComponentsTotal": 1,
    "numberFiles": "52",
    "numberTestErrors": 0,
    "numberTestsCompleted": 0,
    "numberTestsTotal": 0,
    "rollbackOnError": true,
    "runTestsEnabled": false,
    "startDate": "2026-05-09T16:42:43.000Z",
    "status": "Succeeded",
    "success": true,
    "zipSize": "56780",
    "files": [
      {
        "fullName": "Astrum_BD_Agent",
        "type": "GenAiPlannerBundle",
        "state": "Created",
        "filePath": "genAiPlannerBundles/Astrum_BD_Agent.genAiPlannerBundle"
      }
    ],
    "deployUrl": "https://astrum.my.salesforce.com/lightning/setup/DeployStatus/page?address=%2Fchangemgmt%2FmonitorDeploymentsDetails.apexp%3FasyncId%3D0AfTY000003o1SD0AY%26retURL%3D%252Fchangemgmt%252FmonitorDeployment.apexp"
  },
  "warnings": []
}
```

## 9. Post-Deploy Metadata Confirmation

Command:

```powershell
& "$env:APPDATA\npm\sf.cmd" org list metadata --metadata-type GenAiPlannerBundle --target-org amit.kumar@astrumcro.com --json
```

Confirmation:

| Check | Expected | Actual | Status |
|---|---|---|---|
| GenAiPlannerBundle present | Astrum_BD_Agent | Astrum_BD_Agent | PASS |
| Valid metadata id | Non-blank id | 16jTY000000Oa5ZYAS | PASS |
| Last modified date matches today | 2026-05-09 | 2026-05-09T16:42:44.000Z | PASS |

Full metadata list JSON output:

```json
{
  "status": 0,
  "result": [
    {
      "createdById": "005d1000002tlefAAA",
      "createdByName": "Amit Kumar",
      "createdDate": "2026-05-09T16:42:44.000Z",
      "fileName": "genAiPlannerBundles/Astrum_BD_Agent.genAiPlannerBundle",
      "fullName": "Astrum_BD_Agent",
      "id": "16jTY000000Oa5ZYAS",
      "lastModifiedById": "005d1000002tlefAAA",
      "lastModifiedByName": "Amit Kumar",
      "lastModifiedDate": "2026-05-09T16:42:44.000Z",
      "manageableState": "unmanaged",
      "type": "GenAiPlannerBundle"
    },
    {
      "createdById": "005TY00000QwF6AYAV",
      "createdByName": "mayank G",
      "createdDate": "2026-03-19T11:26:01.000Z",
      "fileName": "genAiPlannerBundles/Sales_Representative_Agent.genAiPlannerBundle",
      "fullName": "Sales_Representative_Agent",
      "id": "16jTY000000D9LdYAK",
      "lastModifiedById": "005TY00000QwF6AYAV",
      "lastModifiedByName": "mayank G",
      "lastModifiedDate": "2026-03-19T11:26:01.000Z",
      "manageableState": "unmanaged",
      "type": "GenAiPlannerBundle"
    },
    {
      "createdById": "005TY00000QwF6AYAV",
      "createdByName": "mayank G",
      "createdDate": "2026-03-31T06:47:39.000Z",
      "fileName": "genAiPlannerBundles/Agentforce_Sales_Development_Rep.genAiPlannerBundle",
      "fullName": "Agentforce_Sales_Development_Rep",
      "id": "16jTY000000FxHVYA0",
      "lastModifiedById": "005TY00000QwF6AYAV",
      "lastModifiedByName": "mayank G",
      "lastModifiedDate": "2026-03-31T06:47:39.000Z",
      "manageableState": "unmanaged",
      "type": "GenAiPlannerBundle"
    }
  ],
  "warnings": []
}
```

## 10. Explicit Exclusions

| Exclusion | Confirmation |
|---|---|
| No agent activation performed | Confirmed |
| No agent publication performed | Confirmed |
| No manual flow activation performed | Confirmed |
| No local metadata modification performed | Confirmed |
| No AGENTS.md edits | Confirmed |
| No CLAUDE.md edits | Confirmed |
| No unrelated metadata deployed | Confirmed |
| No Linear status transition performed | Confirmed |
| No git add, commit, or push performed | Confirmed |

## 11. Git Status After Evidence File Creation

Command:

```powershell
git status --short --untracked-files=all
```

Output:

```text
?? unpackaged/package.xml
?? validation/SAL-21-phase-2-production-validate-20260509.md
?? validation/SAL-21-phase-2-remediation-20260509.md
?? validation/SAL-21-phase-3-planner-bundle-live-deploy-20260509.md
?? validation/SAL-21-phase-3-planner-bundle-validate-reattempt-20260509.md
?? validation/SAL-21-phase-3-production-validate-20260509.md
?? validation/SAL-21-phase-3b-production-remediation-20260509.md
```

## 12. Next Operator

- Run next in: Claude Code
- Reason: Claude Code must review Phase 3 live deploy evidence before any agent activation, publication, or Phase 4 action is authorised.
- Next prompt: Review validation/SAL-21-phase-3-planner-bundle-live-deploy-20260509.md and advise the next authorised step for SAL-21.
