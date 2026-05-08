# SAL-BD-S1 AGENT_CreateContact Validation Evidence

| Item | Value |
|---|---|
| Linear issue | SAL-BD-S1 |
| PRD | `docs/PRDs/SAL-BD-S1-AGENT_CreateContact-PRD.md` |
| Target org | `astrum--astrumpar.sandbox.my.salesforce.com` |
| Target username | `amit.kumar@astrumcro.com.astrumpar` |
| Validation timestamp | 2026-05-08T18:24:57Z |
| Validation ID | `0AfUD00000GyNzr0AF` |
| Validation type | Check-only deployment validation with `RunSpecifiedTests`; no metadata was deployed |
| SF CLI | `@salesforce/cli/2.133.4` |

## Scope Built

| Component | Type | Status |
|---|---|---|
| `force-app/main/default/flows/AGENT_CreateContact.flow-meta.xml` | Flow | Updated to PRD AccountId contract |
| `force-app/main/default/classes/AGENT_CreateContactTest.cls` | Apex test | Created for PRD TC-01 through TC-04 |
| `force-app/main/default/classes/AGENT_CreateContactTest.cls-meta.xml` | Apex metadata | Created |
| `force-app/main/default/classes/AGENT_CreateContact_Test.cls` | Existing Apex test | Updated from legacy AccountName input to AccountId so future all-tests runs do not fail after Flow deployment |

No SAL-2, SAL-9, SAL-10, SAL-21 agent planner, bot, prompt-template, or evaluation files were edited by this build.

## Validation Commands

Sandbox confirmation:

```powershell
& 'C:\Program Files\Git\bin\bash.exe' -lc "sf data query --query 'SELECT IsSandbox FROM Organization' --target-org amit.kumar@astrumcro.com.astrumpar --json"
```

Result: `IsSandbox = true`.

Check-only validation and tests:

```powershell
& 'C:\Program Files\Git\bin\bash.exe' -lc "sf project deploy validate --source-dir force-app/main/default/flows/AGENT_CreateContact.flow-meta.xml --source-dir force-app/main/default/classes/AGENT_CreateContactTest.cls --source-dir force-app/main/default/classes/AGENT_CreateContactTest.cls-meta.xml --source-dir force-app/main/default/classes/AGENT_CreateContact_Test.cls --source-dir force-app/main/default/classes/AGENT_CreateContact_Test.cls-meta.xml --target-org amit.kumar@astrumcro.com.astrumpar --test-level RunSpecifiedTests --tests AGENT_CreateContactTest --tests AGENT_CreateContact_Test --wait 30 --json"
```

Result: validation succeeded, `checkOnly = true`, `numFailures = 0`, `numberTestsCompleted = 8`, `numberTestsTotal = 8`.

## Smoke Test Results

| Scenario | Description | Expected | Actual | Status |
|---|---|---|---|---|
| TC-01 | Valid AccountId, unique Contact name/email | Contact created; `Success = true`; `DuplicateFound = false`; created ID/name populated | `AGENT_CreateContactTest.tc01_noDuplicateCreatesContact` PASS; compatibility test also PASS | PASS |
| TC-02 | Existing Contact with same LastName at same Account | No new Contact; `DuplicateFound = true`; existing Contact ID/name returned | `AGENT_CreateContactTest.tc02_duplicateByNameExitsWithoutCreate` PASS; compatibility test also PASS | PASS |
| TC-03 | Existing Contact with same Email at another Account | No new Contact; `DuplicateFound = true`; email-match Contact ID/name returned | `AGENT_CreateContactTest.tc03_duplicateByEmailExitsWithoutCreate` PASS; compatibility test also PASS | PASS |
| TC-04 | Syntactically valid AccountId does not resolve | No Contact; `Success = false`; `DuplicateFound = false`; `ErrorMessage` contains `Account not found` | `AGENT_CreateContactTest.tc04_accountIdNotFoundFailsGracefully` PASS; compatibility test also PASS | PASS |

## Flow Exit Criteria

| Criterion | Evidence | Status |
|---|---|---|
| FC-01: TC-01 through TC-04 pass | `AGENT_CreateContactTest` ran 4/4 PASS. Existing `AGENT_CreateContact_Test` also ran 4/4 PASS after AccountId compatibility update. | PASS |
| FC-02: Flow API name is `AGENT_CreateContact` | Metadata path `force-app/main/default/flows/AGENT_CreateContact.flow-meta.xml`; validation component fullName `AGENT_CreateContact`. | PASS |
| FC-03: User-launched run mode, not system mode | Flow XML uses `<runInMode>DefaultMode</runInMode>`, Salesforce metadata value for "User or Queue That Launched the Flow"; validation succeeded. No `SystemMode*` value present. | PASS |
| FC-04: Duplicate scenarios create no Contact | TC-02 and TC-03 assert Contact counts do not increase. | PASS |
| FC-05: AccountId-not-found path exits cleanly | TC-04 asserts no Contact created and `ErrorMessage` contains `Account not found`. | PASS |
| FC-06: Element descriptions populated | Static XML check confirmed all configurable Flow elements have non-blank `<description>` tags. Note: Salesforce metadata rejects descriptions on `<start>`, so Start cannot carry a description in source XML. | PASS |

## Flow Guardrail Checks

| Check | Result |
|---|---|
| Flow API name has `AGENT_` prefix | PASS |
| Autolaunched Flow, no screen elements | PASS |
| No Delete Records element | PASS |
| No `Check_Bypass_Permission` / `Bypass_Flow` decision | PASS |
| Create Records fault connector routes to `Set_Fault_Create_Failed` | PASS |
| Account validation uses `Account.Id = {!AccountId}` before duplicate lookup/create | PASS |
| Duplicate-by-name query uses `Contact.AccountId = {!AccountId}` and `Contact.LastName = {!LastName}` | PASS |
| Duplicate-by-email query is gated by `Email` not blank | PASS |
| Create Contact sets only `AccountId`, `FirstName`, `LastName`, `Title`, `Email`, `Phone`, `MobilePhone` | PASS |

## Notes

- No deploy was run. The successful validation was check-only.
- The PRD prompt requested `runInMode = UserMode`, but Salesforce Flow metadata validates user-launched context as `DefaultMode`; `DefaultMode` is used consistently by existing repo Flow metadata and passed API 66.0 validation.
- `Set_Fault_Create_Failed` is present and wired from the Create Records fault connector. It is not covered by the four PRD tests because the required scenarios do not force a Contact create DML fault.
- The existing `AGENT_CreateContact_Test.cls` was updated because it was still passing `AccountName`; leaving it unchanged would create a future all-tests failure after the Flow moves to the PRD AccountId contract.

## Paste-ready Linear Comment

SAL-BD-S1 implementation evidence for `AGENT_CreateContact`:

- Built/updated Flow: `force-app/main/default/flows/AGENT_CreateContact.flow-meta.xml`
- Created PRD test class: `force-app/main/default/classes/AGENT_CreateContactTest.cls`
- Updated existing compatibility test: `force-app/main/default/classes/AGENT_CreateContact_Test.cls`
- Validation evidence: `validation/SAL-BD-S1-AGENT_CreateContact.md`
- Target org confirmed sandbox: `amit.kumar@astrumcro.com.astrumpar`, `IsSandbox = true`
- Check-only validation succeeded; no deployment performed
- Validation ID: `0AfUD00000GyNzr0AF`
- Tests: `AGENT_CreateContactTest` 4/4 PASS for TC-01 through TC-04; existing `AGENT_CreateContact_Test` also 4/4 PASS
- Guardrails confirmed: autolaunched Flow, `AGENT_` prefix, user-launched run mode (`DefaultMode` metadata value), no screens, no delete element, no Bypass_Flow decision, Create fault path routes to `Set_Fault_Create_Failed`
- Note for review: Salesforce API 66.0 accepts `DefaultMode` for "User or Queue That Launched the Flow"; `UserMode` did not appear in the repo's validated Flow metadata patterns.

Ready for Claude review against `docs/PRDs/SAL-BD-S1-AGENT_CreateContact-PRD.md`.
