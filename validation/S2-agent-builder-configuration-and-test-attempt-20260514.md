# S2 Agent Builder Configuration and Test Attempt - 2026-05-14

| Field | Value |
|---|---|
| Programme | Astrum Orbit |
| Workstream | Astrum BD Agent - Subagent 2 Opportunity Management |
| Operator | Codex |
| Date | 2026-05-14 |
| Target org | `amit.kumar@astrumcro.com.astrumpar` |
| Target instance | `https://astrum--astrumpar.sandbox.my.salesforce.com` |
| Sandbox verified | Yes - `Organization.IsSandbox = true` |
| Production targeted | No |

## Request

Configure S2 Opportunity Management in sandbox Agent Builder using `handoff/S2-agent-builder-human-setup.md`, then run the scenarios in `validation/S2-opportunity-management-validation-20260514.md` and record results.

## Result

BLOCKED - Human Agent Builder UI required.

Codex could not complete the Agent Builder configuration or runtime scenario execution from the available CLI/tooling because:

- No in-session Salesforce Agent Builder browser automation tool is available.
- `sf org open agent --url-only` can generate a UI URL, but it returns a session-bearing frontdoor OTP URL and does not perform configuration.
- The local retrieved `GenAiPlannerBundle` contains only the S1 `Account_and_Contact_Management` topic. It does not contain a safely reusable S2 topic/action baseline.
- The S2 setup requires Agent Builder UI configuration for standard Get/Search/Create Opportunity actions, Confirm HITL settings, field pickers, and prompt-action binding.
- The existing sandbox BotVersion for `Astrum_BD_Agent` is `Inactive`.
- Programmatic preview failed with `No valid version available`.
- No existing S2 Agentforce Testing Center test definition exists.

No production org was touched. No Opportunity records were created, updated, or deleted.

## Evidence Files

| Evidence | Path |
|---|---|
| Sandbox safety query | `validation/S2-agent-builder-test-org-safety-20260514.json` |
| BotVersion query | `validation/S2-agent-botversion-before-test-20260514.json` |
| Agent Builder URL generation, redacted | `validation/S2-agent-builder-url-20260514.json` |
| Agent preview start attempt | `validation/S2-agent-preview-start-20260514.json` |
| Existing Agentforce test list | `validation/S2-agent-test-list-20260514.json` |

## Sandbox Safety

| Check | Result |
|---|---|
| Organization name | `ASTRUM CRO, SL` |
| Org Id | `00DUD000007zF692AE` |
| Instance | `SWE92S` |
| IsSandbox | `true` |
| Production alias used | No |

## Agent State

| Check | Result |
|---|---|
| BotDefinition | `Astrum_BD_Agent` |
| BotVersion count returned | 1 |
| Latest BotVersion | Version 1 |
| Latest BotVersion status | `Inactive` |

## Agent Builder URL Handling

`sf org open agent --api-name Astrum_BD_Agent --url-only --json` succeeded, but the returned URL contained a Salesforce frontdoor OTP token. Codex immediately redacted the saved evidence file and did not store or report the session-bearing URL.

## Preview Attempt

Command intent:

```text
Start programmatic preview for Astrum_BD_Agent in the confirmed sandbox.
```

Result:

```text
PreviewStartFailed
404 [{"errorCode":"NOT_FOUND","message":"No valid version available"}]
```

Impact:

- No preview session was created.
- No scenario utterances were sent.
- No write confirmation was presented.
- No data was mutated.

## Testing Center Check

Existing Agentforce tests listed:

| Test | Status |
|---|---|
| `SAL_16_Test` | Existing S1/SAL-16 test |
| `SAL_21_Account_Intelligence_Test` | Existing S1/SAL-21 test |

No S2 Opportunity Management test definition exists.

Creating a new S2 test definition through `sf agent test create` would create or update `AiEvaluationDefinition` metadata, but it still cannot run the requested scenarios until the Opportunity Management topic/actions are configured and a valid agent version is available.

## Scenario Results

| Scenario | Description | Expected | Actual | Status |
|---|---|---|---|---|
| 1 | User asks for current status of a named opportunity | Agent retrieves Opportunity details | Not run - S2 topic/actions not configured and agent preview has no valid version | BLOCKED |
| 2 | User searches opportunities by account name | Agent returns candidate list | Not run - S2 topic/actions not configured and agent preview has no valid version | BLOCKED |
| 3 | User asks to move a deal to Proposal Sent | Agent retrieves current values, prompts for next step, confirms, then updates | Not run - S2 topic/actions not configured and agent preview has no valid version | BLOCKED |
| 4 | User asks to change close date to a past date | Agent warns and requires explicit confirmation | Not run - S2 topic/actions not configured and agent preview has no valid version | BLOCKED |
| 5 | User asks to add next step only | Agent displays current and proposed values, confirms, then updates | Not run - S2 topic/actions not configured and agent preview has no valid version | BLOCKED |
| 6 | User asks to delete an opportunity | Agent refuses and directs to Salesforce admin | Static metadata confirms no Opportunity Delete permission and no delete action in S2 metadata; runtime not run | PASS STATIC / BLOCKED RUNTIME |
| 7 | User asks for pipeline hygiene report | Routes or redirects to S3, not S2 | Not run - S2 topic/actions not configured and agent preview has no valid version | BLOCKED |
| 8 | User asks for account contact details | Routes or redirects to S1, not S2 | Not run - S2 topic/actions not configured and agent preview has no valid version | BLOCKED |
| 9 | User asks for Opportunity Status Summary | Prompt uses only retrieved Salesforce fields and excludes D365 notes and Description | Static template confirms exclusions; runtime not run | PASS STATIC / BLOCKED RUNTIME |
| 10 | User gives partial opportunity name with multiple matches | Agent presents candidates and waits for selection | Not run - S2 topic/actions not configured and agent preview has no valid version | BLOCKED |

## Required Human Action

1. Open sandbox Agent Builder for `Astrum_BD_Agent`.
2. Follow `handoff/S2-agent-builder-human-setup.md`.
3. Configure the `Opportunity Management` topic and six actions.
4. Confirm all write actions use Confirm HITL.
5. Confirm standard Create Opportunity captures all mandatory fields.
6. Activate or otherwise make a valid sandbox agent version available for preview/testing, if appropriate for UAT.
7. Run the ten S2 scenarios and update `validation/S2-opportunity-management-validation-20260514.md`.

## Business Summary

- **What was done:** Attempted to configure and test S2 Opportunity Management using available CLI evidence and Agentforce commands.
- **What was found:** The sandbox agent has no valid active version for preview, no S2 Testing Center definition exists, and the remaining setup requires Agent Builder UI configuration.
- **What this means:** Codex cannot truthfully mark S2 Agent Builder setup or runtime UAT complete from this session. The deployable S2 metadata remains sandbox-ready, but agent runtime validation is blocked.
- **What is next:** Human must configure the S2 topic/actions in Agent Builder, make a valid sandbox version available, and run the UAT scenarios.
- **Decision needed from Human:** Decide whether to activate/publish a sandbox agent version for S2 UAT after completing Agent Builder setup.

## Next Operator
- Run next in: Human
- Reason: Human Agent Builder UI access is required to complete S2 topic/action setup and runtime UAT.
- Next prompt: Configure `Opportunity Management` in sandbox Agent Builder using `handoff/S2-agent-builder-human-setup.md`, make a valid sandbox test version available, then run and record the ten scenarios in `validation/S2-opportunity-management-validation-20260514.md`.
