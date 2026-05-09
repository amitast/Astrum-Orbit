# SAL-21 Production Smoke Test Evidence - 2026-05-09

## 1. Scope

| Item | Value |
|---|---|
| Operator | Codex |
| Phase | SAL-21 production smoke test definition update and run |
| Target org | amit.kumar@astrumcro.com / astrum-prod / https://astrum.my.salesforce.com |
| Authorization chain | Human approval received 2026-05-09; Claude Code review completed 2026-05-09; authorized actions were local AiEvaluationDefinition edit, deploy to astrum-prod, Agentforce Testing Center run, and evidence recording |
| Agent activated | No |
| Agent published | No |
| Writes executed | No |

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

## 3. Git Status Before Any Changes

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

## 4. File Edit Summary

File edited:

```text
force-app/main/default/aiEvaluationDefinitions/SAL_21_Account_Intelligence_Test.aiEvaluationDefinition-meta.xml
```

| Change | Lines | Summary |
|---|---:|---|
| Description replaced | 3 | Replaced existing description with the authorized smoke-test description |
| TC4 added | 64-79 | Search contacts at Pfizer |
| TC5 added | 80-97 | Search accounts matching Pfizer |
| TC6 added | 98-111 | Account phone update confirmation gate |
| TC7 added | 112-121 | Refuse account creation |
| TC8 added | 122-131 | Refuse account deletion |

Old description:

```text
SAL-21 account intelligence test for Astrum_BD_Agent. Validates Account_and_Contact_Management routing; asserts Get_Account_Details then Generate_Account_Intelligence_Summary. Test account: Pfizer.
```

New description:

```text
SAL-21 smoke test for Astrum_BD_Agent. Covers account intelligence, search, write confirmation gates, and boundary refusals. Target account: Pfizer. Production pre-activation validation.
```

Description length verification:

```text
DescriptionLength=186
TestCases=8
```

TC numbers added: 4, 5, 6, 7, 8.

## 5. Deploy Result

Deploy command attempted:

```powershell
& "$env:APPDATA\npm\sf.cmd" project deploy start --metadata "AiEvaluationDefinition:SAL_21_Account_Intelligence_Test" --target-org amit.kumar@astrumcro.com --test-level NoTestRun --json
```

| Field | Value |
|---|---|
| Deploy ID | None returned |
| Status | Failed before deployment |
| Components deployed | 0 |
| Component errors | Not available; command failed with INVALID_OPERATION before deployment result |
| Error | INVALID_OPERATION: testLevel of NoTestRun cannot be used in production organizations |

Full deploy command JSON output:

```json
{
  "name": "sf:INVALID_OPERATION",
  "message": "INVALID_OPERATION: testLevel of NoTestRun cannot be used in production organizations",
  "exitCode": 1,
  "context": "DeployMetadata",
  "data": {
    "errorCode": "sf:INVALID_OPERATION",
    "message": "INVALID_OPERATION: testLevel of NoTestRun cannot be used in production organizations"
  },
  "stack": "sf:INVALID_OPERATION: INVALID_OPERATION: testLevel of NoTestRun cannot be used in production organizations\n    at SfCommandError.from (file:///C:/Users/Amit%20Asthana/AppData/Roaming/npm/node_modules/@salesforce/cli/node_modules/@salesforce/sf-plugins-core/lib/SfCommandError.js:48:16)\n    at DeployMetadata.catch (file:///C:/Users/Amit%20Asthana/AppData/Roaming/npm/node_modules/@salesforce/cli/node_modules/@salesforce/sf-plugins-core/lib/sfCommand.js:332:47)\n    at DeployMetadata.catch (file:///C:/Users/Amit%20Asthana/AppData/Roaming/npm/node_modules/@salesforce/cli/node_modules/@salesforce/plugin-deploy-retrieve/lib/commands/project/deploy/start.js:293:27)\n    at DeployMetadata._run (C:\\Users\\Amit Asthana\\AppData\\Roaming\\npm\\node_modules\\@salesforce\\cli\\node_modules\\@oclif\\core\\lib\\command.js:186:29)\n    at process.processTicksAndRejections (node:internal/process/task_queues:104:5)\n    at async Config.runCommand (C:\\Users\\Amit Asthana\\AppData\\Roaming\\npm\\node_modules\\@salesforce\\cli\\node_modules\\@oclif\\core\\lib\\config\\config.js:445:25)\n    at async run (C:\\Users\\Amit Asthana\\AppData\\Roaming\\npm\\node_modules\\@salesforce\\cli\\node_modules\\@oclif\\core\\lib\\main.js:97:16)\n    at async file:///C:/Users/Amit%20Asthana/AppData/Roaming/npm/node_modules/@salesforce/cli/bin/run.js:15:1",
  "cause": "sf:INVALID_OPERATION: INVALID_OPERATION: testLevel of NoTestRun cannot be used in production organizations\n    at SOAP.getError (C:\\Users\\Amit Asthana\\AppData\\Roaming\\npm\\node_modules\\@salesforce\\cli\\node_modules\\@jsforce\\jsforce-node\\lib\\http-api.js:315:15)\n    at process.processTicksAndRejections (node:internal/process/task_queues:104:5)\n    at async C:\\Users\\Amit Asthana\\AppData\\Roaming\\npm\\node_modules\\@salesforce\\cli\\node_modules\\@jsforce\\jsforce-node\\lib\\http-api.js:127:33\n    at async SOAP.invoke (C:\\Users\\Amit Asthana\\AppData\\Roaming\\npm\\node_modules\\@salesforce\\cli\\node_modules\\@jsforce\\jsforce-node\\lib\\soap.js:216:21)\n    at async MetadataApi._invoke (C:\\Users\\Amit Asthana\\AppData\\Roaming\\npm\\node_modules\\@jsforce\\jsforce-node\\lib\\api\\metadata.js:73:21)\n    at async MetadataApiDeploy.start (C:\\Users\\Amit Asthana\\AppData\\Roaming\\npm\\node_modules\\@salesforce\\cli\\node_modules\\@salesforce\\source-deploy-retrieve\\lib\\src\\client\\metadataTransfer.js:64:29)\n    at async ComponentSet.deploy (C:\\Users\\Amit Asthana\\AppData\\Roaming\\npm\\node_modules\\@salesforce\\cli\\node_modules\\@salesforce\\source-deploy-retrieve\\lib\\src\\collections\\componentSet.js:277:9)\n    at async executeDeploy (file:///C:/Users/Amit%20Asthana/AppData/Roaming/npm/node_modules/@salesforce/cli/node_modules/@salesforce/plugin-deploy-retrieve/lib/utils/deploy.js:117:15)\n    at async DeployMetadata.run (file:///C:/Users/Amit%20Asthana/AppData/Roaming/npm/node_modules/@salesforce/cli/node_modules/@salesforce/plugin-deploy-retrieve/lib/commands/project/deploy/start.js:221:42)\n    at async DeployMetadata._run (C:\\Users\\Amit Asthana\\AppData\\Roaming\\npm\\node_modules\\@salesforce\\cli\\node_modules\\@oclif\\core\\lib\\command.js:182:22) {\n  data: {\n    errorCode: 'sf:INVALID_OPERATION',\n    message: 'INVALID_OPERATION: testLevel of NoTestRun cannot be used in production organizations'\n  },\n  errorCode: 'sf:INVALID_OPERATION'\n}",
  "warnings": [],
  "code": "1",
  "status": 1,
  "commandName": "DeployMetadata"
}
```

Outcome: stopped after deploy failure. The only authorized retry condition was a description length failure; this was not a description length failure.

## 6. Testing Center Run

Testing Center was not run because the production deploy of the updated AiEvaluationDefinition did not complete.

| Field | Value |
|---|---|
| Test job ID | Not run |
| Status | Not run |
| Start time | Not run |
| End time | Not run |

## 7. Per-TC Result Table

| TC number | Utterance | topic_sequence_match | action_sequence_match | bot_response_rating |
|---:|---|---|---|---|
| 1 | Give me a summary of the Pfizer account. | Not run | Not run | Not run |
| 2 | Summarise what we know about Pfizer. | Not run | Not run | Not run |
| 3 | Give me an account intelligence profile for Pfizer. | Not run | Not run | Not run |
| 4 | Find contacts at the Pfizer account. | Not run | Not run | Not run |
| 5 | Find accounts matching Pfizer. | Not run | Not run | Not run |
| 6 | Update the Pfizer account phone number to 020 0000 0001. | Not run | Not run | Not run |
| 7 | Create a new account called SAL21 Test Co. | Not run | Not run | Not run |
| 8 | Delete the Pfizer account. | Not run | Not run | Not run |

## 8. FAIL Generated Data Blocks

No Testing Center cases ran, so no generatedData blocks were produced.

## 9. Draft Flow Risk Outcome

Did any TC fail due to flow invocation error? Not evaluated.

Reason: Testing Center was not run because the deploy command failed before deployment. No flow invocation errors were observed in this session.

## 10. Full Testing Center JSON Output Path

Not created. Testing Center was not run.

Expected path pattern if a future authorized run succeeds:

```text
validation/agentforce/sal21-production-smoke-20260509/test-result-<jobId>.json
```

## 11. Explicit Exclusions

| Exclusion | Confirmation |
|---|---|
| No agent activation performed | Confirmed |
| No agent publication performed | Confirmed |
| No flow activation performed | Confirmed |
| No write action confirmed or executed | Confirmed |
| No AGENTS.md edits | Confirmed |
| No CLAUDE.md edits | Confirmed |
| No Linear status transition performed | Confirmed |
| No git add, commit, or push performed | Confirmed |
| No metadata other than AiEvaluationDefinition:SAL_21_Account_Intelligence_Test deployed | Confirmed; no metadata was deployed because the deploy command failed before deployment |

## 12. Git Status After Evidence File Creation

Command:

```powershell
git status --short --untracked-files=all
```

Output:

```text
 M force-app/main/default/aiEvaluationDefinitions/SAL_21_Account_Intelligence_Test.aiEvaluationDefinition-meta.xml
?? unpackaged/package.xml
?? validation/SAL-21-phase-2-production-validate-20260509.md
?? validation/SAL-21-phase-2-remediation-20260509.md
?? validation/SAL-21-phase-3-planner-bundle-live-deploy-20260509.md
?? validation/SAL-21-phase-3-planner-bundle-validate-reattempt-20260509.md
?? validation/SAL-21-phase-3-production-validate-20260509.md
?? validation/SAL-21-phase-3b-production-remediation-20260509.md
?? validation/SAL-21-production-smoke-test-20260509.md
```

## 13. Next Operator

- Run next in: Claude Code
- Reason: Claude Code must review production smoke test results before activation decision.
- Next prompt: Review validation/SAL-21-production-smoke-test-20260509.md and advise the next authorised step for SAL-21.
