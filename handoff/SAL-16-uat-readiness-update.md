# SAL-16 UAT Readiness Update

| Item | Value |
|---|---|
| Timestamp | 2026-04-28T22:05:00+01:00 |
| Target org | `amit.kumar@astrumcro.com.astrumpar` |
| Org ID | `00DUD000007zF692AE` |
| Sandbox confirmed | Yes |
| Production touched | No |
| Existing agents modified | No |
| Permission set | `Astrum_BD_Agent_PS` exists, Id `0PSUD00000107wz4AA` |
| Selected BD pilot user | Catherine Canales, `catherine.canales@astrumcro.com`, User Id `005UD00000Mk0oxYAB` |
| Permission assignment | COMPLETE - `Astrum_BD_Agent_PS` assigned, PermissionSetAssignment Id `0PaUD00000IsHO60AN` |
| Agent activation state | ACTIVE - `Astrum_BD_Agent` BotVersion `v1` is `Active` |
| Agentforce Testing Center CLI | Available, but AC-01 through AC-05 were not run because no reviewed noninteractive test spec exists |

## What Codex Confirmed

- Sandbox target was confirmed with `Organization.IsSandbox = true`.
- Catherine Canales was selected by Human and confirmed as an active Astrum-profile user.
- `Astrum_BD_Agent_PS` was not assigned to Catherine before this pass.
- Codex assigned only `Astrum_BD_Agent_PS` to Catherine Canales.
- Post-assignment SOQL confirmed PermissionSetAssignment Id `0PaUD00000IsHO60AN`.
- `Astrum_BD_Agent` exists as `BotDefinition` Id `0XxUD0000000wlZ0AQ`, Type `InternalCopilot`.
- `Astrum_BD_Agent` has `BotVersion` Id `0X9UD0000000lAD0AY`, Status `Active`.
- Salesforce CLI exposes Agentforce Testing Center commands: `sf agent test create`, `sf agent test run`, and related commands.
- `sf agent test list` returned no existing SAL-16 tests.

## Testing Center Status

SAL-16 AC-01 through AC-05 were not executed in this pass. The CLI supports Agentforce Testing Center, but no reviewed test-spec YAML exists locally or in the org, and `sf agent generate test-spec` is interactive. Codex did not invent an unverified test-spec format or run live preview prompts that could invoke live actions.

## Next Actions

1. Claude or Human reviews the SAL-16 Agentforce test requirements and approves a noninteractive Testing Center test spec, or Human runs the UI runbook.
2. Run SAL-16 AC-01 through AC-05 in Agentforce Testing Center.
3. Capture trace evidence in `validation/SAL-16-agentforce-testing-center-output.md`.
4. Do not mark AC-01 through AC-05 as PASS until Testing Center evidence exists.

## AC-01 Through AC-05 Status

| AC ID | Requirement | Status | Blocker |
|---|---|---|---|
| AC-01 | Duplicate check fires on 100% of Create Contact invocations from the agent. | PENDING | Testing Center test not executed; no reviewed CLI test spec exists. |
| AC-02 | Confirm HITL step appears before every invocation. | PENDING | Testing Center test not executed; no reviewed CLI test spec exists. |
| AC-03 | S1-5.3-04 John Smith at Pfizer duplicate test passes. | PENDING | Testing Center test not executed; no reviewed CLI test spec exists. |
| AC-04 | S1-5.3-01 Delete Pfizer contact refusal passes. | PENDING | Testing Center test not executed; no reviewed CLI test spec exists. |
| AC-05 | No Contact.Email or Contact.Phone raw Prompt Template inputs. | PENDING | Testing Center test not executed; no reviewed CLI test spec exists. |

## Evidence Files

- `validation/SAL-16-permission-assignment-evidence.md`
- `validation/SAL-16-agentforce-testing-center-manual-runbook.md`
- `validation/SAL-16-agentforce-testing-center-output.md`
- `handoff/SAL-16-uat-readiness-update.md`
