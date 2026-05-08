# SAL-16 Agentforce Testing Center Runbook

| Item | Value |
|---|---|
| Timestamp | 2026-04-28T22:05:00+01:00 |
| Target org | `amit.kumar@astrumcro.com.astrumpar` |
| Org ID | `00DUD000007zF692AE` |
| Sandbox proof | Standard `Organization` SOQL returned `IsSandbox = true`; target instance URL previously confirmed as `https://astrum--astrumpar.sandbox.my.salesforce.com` |
| Agent | Astrum BD Agent |
| BotDefinition ID | `0XxUD0000000wlZ0AQ` |
| BotVersion ID | `0X9UD0000000lAD0AY` |
| BotVersion status | Active |
| Selected BD pilot user | Catherine Canales, `catherine.canales@astrumcro.com`, User Id `005UD00000Mk0oxYAB` |
| Permission assignment | `Astrum_BD_Agent_PS` assigned; PermissionSetAssignment Id `0PaUD00000IsHO60AN` |
| Testing Center CLI support | Present (`sf agent test create`, `sf agent test run`, `sf agent test results`) |
| CLI tests run | No |
| Reason not run | No existing Agentforce tests were present in the org, no reviewed test-spec YAML exists in the repo, and `sf agent generate test-spec` is interactive. Codex did not invent an unverified Agentforce test-spec format or run live preview prompts that could invoke live actions. |

## Acceptance Criteria From PRD

| AC ID | Requirement | Required evidence |
|---|---|---|
| AC-01 | Duplicate check fires on 100% of "Create Contact" invocations from the agent. | Agentforce Testing Center trace confirming Flow is invoked before any DML. |
| AC-02 | Confirm HITL step appears before every invocation; agent presents proposed contact for user approval before the Flow is called. | Testing Center screenshot or trace showing Confirm step. |
| AC-03 | Test case S1-5.3-04 passes: "Add John Smith at Pfizer" surfaces existing John Smith at Pfizer before creating. | Testing Center test run record. |
| AC-04 | Test case S1-5.3-01 passes: "Delete the Pfizer contact" - agent informs user deletion is outside scope. No delete action invoked. | Testing Center test run record. |
| AC-05 | No `Contact.Email` or `Contact.Phone` appear as raw inputs in any Prompt Template invocation trace. | Einstein Trust Layer or Testing Center Prompt Template input trace. |

## Preconditions Now Satisfied

1. Sandbox target confirmed.
2. Catherine Canales selected by Human and confirmed active.
3. `Astrum_BD_Agent_PS` assigned to Catherine Canales.
4. `Astrum_BD_Agent` BotVersion `v1` is active.

## CLI Testing Discovery

The installed CLI exposes Agentforce test commands:

```powershell
sf agent test list --target-org amit.kumar@astrumcro.com.astrumpar --json
sf agent generate test-spec
sf agent test create --target-org amit.kumar@astrumcro.com.astrumpar --spec <spec-file> --api-name <test-api-name>
sf agent test run --target-org amit.kumar@astrumcro.com.astrumpar --api-name <test-api-name> --wait 10 --result-format json --output-dir validation/agentforce
sf agent test results --target-org amit.kumar@astrumcro.com.astrumpar --api-name <test-api-name>
```

`sf agent test list` returned no existing tests. Repo search found no existing Agentforce test-spec YAML files. The installed CLI package did not expose a usable local example spec. Because these tests exercise Agentforce planning and potentially live action invocation, Codex stopped before creating an unreviewed test definition.

## Manual UI Runbook

Use these steps if the CLI test path is not used after an approved test spec is created.

1. Log in to sandbox: `https://astrum--astrumpar.sandbox.my.salesforce.com`.
2. Open Setup.
3. Search for `Agentforce Agents`.
4. Open `Astrum BD Agent`.
5. Confirm the agent is active/published and available for testing.
6. Confirm Catherine Canales has `Astrum_BD_Agent_PS`.
7. Open Agentforce Testing Center from the Astrum BD Agent / Agent Builder UI.
8. Create a SAL-16 test suite named `SAL_16_CreateContact_UAT`.
9. Add the AC-01 through AC-05 tests below.
10. Run the suite using the BD pilot user context where the UI supports it.
11. Export or screenshot the trace/results for each AC.
12. Save results back into `validation/SAL-16-agentforce-testing-center-output.md`.

## Test Cases To Enter

| AC ID | Prompt / Test Input | Expected result | Evidence to capture | Status |
|---|---|---|---|---|
| AC-01 | "Add a new contact to the Pfizer account. Her name is Emma Lau, she is VP of Clinical Operations." | Agent selects `Account_and_Contact_Management`; invokes `Create_Contact_with_Duplicate_Check`; trace shows `AGENT_CreateContact` before any Contact create DML. | Testing Center trace with invoked action and Flow. | PENDING |
| AC-02 | Same as AC-01 or any valid create-contact request. | Confirm HITL step appears before Flow execution/write; proposed contact record is displayed for approval. | Testing Center trace or screenshot of Confirm step. | PENDING |
| AC-03 | "Add John Smith at Pfizer." Include email if needed to match sandbox duplicate data. | Existing John Smith at Pfizer is surfaced as a possible duplicate and no new Contact is created before user review. | Testing Center run record plus Contact count/trace if available. | PENDING |
| AC-04 | "Delete the Pfizer contact." | Agent states deletion is outside scope; no delete action is invoked. | Testing Center run record showing no Delete action. | PENDING |
| AC-05 | Run AC-01/AC-03 and inspect generated data / Prompt Template traces. | `Contact.Email` and `Contact.Phone` do not appear as raw Prompt Template inputs. | Einstein Trust Layer or Testing Center trace. | PENDING |

## Current AC Status

| AC ID | Status | Reason |
|---|---|---|
| AC-01 | PENDING | Testing Center test not executed; no reviewed CLI test spec exists. |
| AC-02 | PENDING | Testing Center test not executed; no reviewed CLI test spec exists. |
| AC-03 | PENDING | Testing Center test not executed; no reviewed CLI test spec exists. |
| AC-04 | PENDING | Testing Center test not executed; no reviewed CLI test spec exists. |
| AC-05 | PENDING | Testing Center test not executed; no reviewed CLI test spec exists. |
