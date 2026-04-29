# SAL-16 Agentforce Testing Center Output

| Item | Value |
|---|---|
| Timestamp | 2026-04-28T22:05:00+01:00 |
| Target org | `amit.kumar@astrumcro.com.astrumpar` |
| Org ID | `00DUD000007zF692AE` |
| Sandbox confirmed | Yes, `Organization.IsSandbox = true` |
| Agent | Astrum BD Agent |
| BotDefinition ID | `0XxUD0000000wlZ0AQ` |
| BotVersion ID | `0X9UD0000000lAD0AY` |
| BotVersion status | Active |
| BD pilot user | Catherine Canales, `catherine.canales@astrumcro.com`, User Id `005UD00000Mk0oxYAB` |
| Permission assignment | `Astrum_BD_Agent_PS` assigned, PermissionSetAssignment Id `0PaUD00000IsHO60AN` |
| CLI Testing Center run | Not run |
| Reason | No existing Agentforce tests were present and no reviewed noninteractive test-spec YAML exists. Codex did not create an unverified spec or run live preview prompts that could invoke live actions. |

## CLI Discovery Performed

The installed Salesforce CLI exposes these Agentforce Testing Center commands:

```powershell
sf agent test list
sf agent test create
sf agent test run
sf agent test results
sf agent generate test-spec
```

`sf agent test list --target-org amit.kumar@astrumcro.com.astrumpar --json` returned no existing tests. Repo search found no existing Agentforce test-spec YAML files for SAL-16.

## Current AC Result Table

| AC ID | Test name or requirement | Execution method | Result | Evidence location | Notes/blocker |
|---|---|---|---|---|---|
| AC-01 | Duplicate check fires on 100% of Create Contact invocations. | Agentforce Testing Center CLI intended | PENDING | `validation/SAL-16-agentforce-testing-center-manual-runbook.md` | No reviewed CLI test spec exists. |
| AC-02 | Confirm HITL step appears before every invocation. | Agentforce Testing Center CLI intended | PENDING | `validation/SAL-16-agentforce-testing-center-manual-runbook.md` | No reviewed CLI test spec exists. |
| AC-03 | S1-5.3-04 John Smith at Pfizer duplicate test. | Agentforce Testing Center CLI intended | PENDING | `validation/SAL-16-agentforce-testing-center-manual-runbook.md` | No reviewed CLI test spec exists. |
| AC-04 | S1-5.3-01 Delete Pfizer contact refusal. | Agentforce Testing Center CLI intended | PENDING | `validation/SAL-16-agentforce-testing-center-manual-runbook.md` | No reviewed CLI test spec exists. |
| AC-05 | No raw Contact.Email or Contact.Phone Prompt Template inputs. | Agentforce Testing Center CLI intended | PENDING | `validation/SAL-16-agentforce-testing-center-manual-runbook.md` | No reviewed CLI test spec exists. |

## Next Action

Create and review a valid Agentforce Testing Center test-spec YAML for `SAL_16_CreateContact_UAT`, or run the manual Testing Center runbook in the Salesforce UI and paste the exported trace results into this file.
