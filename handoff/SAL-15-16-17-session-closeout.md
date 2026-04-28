# SAL-15 / SAL-16 / SAL-17 Session Closeout

| Item | Value |
|---|---|
| Date | 2026-04-28 |
| Branch | `feature/astrum-bd-agent-build` |
| Reviewer | Claude Code (Architect agent) |
| Session summary | SAL-15 AGENT_CreateContact deployed and tested. SAL-16 Agentforce planner configured. SAL-17 permission set deployed and validated. Repository committed and closed for today. |

---

## Issue Status

| Issue | Title | Status |
|---|---|---|
| SAL-15 | AGENT_CreateContact Flow Build | COMPLETE — deployed and all FC criteria PASS |
| SAL-16 | Agent Builder Create Contact | CONFIGURED IN SANDBOX — UAT PENDING |
| SAL-17 | Permissions and FLS | PASS |

---

## Deploy IDs

| Deploy | ID | Status |
|---|---|---|
| SAL-15 Flow + Apex test | `0AfUD00000Gq3wf0AB` | Succeeded |
| SAL-15 failed attempt 1 (interleaved recordLookups) | `0AfUD00000Gq3mz0AB` | Rolled back |
| SAL-15 failed attempt 2 (interleaved assignments) | `0AfUD00000Gq3tR0AR` | Rolled back |
| SAL-15 failed attempt 3 (unsupported FlowStart description) | `0AfUD00000Gq3v30AB` | Rolled back |
| SAL-16 GenAiPlannerBundle | `0AfUD00000Gq4j30AB` | Succeeded |
| SAL-17 Astrum_BD_Agent_PS (failed — FirstName/LastName FLS) | `0AfUD00000Gq4BB0AZ` | Rolled back |
| SAL-17 Astrum_BD_Agent_PS (final) | `0AfUD00000Gq4EP0AZ` | Succeeded |

---

## SAL-15 Formal Status — COMPLETE

All FC criteria PASS:

| Criterion | Status |
|---|---|
| FC-01: All 4 unit tests pass | PASS — 4/4, 0 failures, deploy `0AfUD00000Gq3wf0AB` |
| FC-02: Flow API name `AGENT_CreateContact` | PASS |
| FC-03: Run mode is User context | PASS — `<runInMode>DefaultMode</runInMode>` |
| FC-04: TC-02/TC-03 confirm no Contact created on duplicate | PASS |
| FC-05: TC-04 confirms clean ErrorMessage, no unhandled fault | PASS |
| FC-06: All Flow elements have descriptions | PASS — Salesforce metadata API does not expose `<description>` on `FlowStart`; platform constraint, not a build defect; all non-Start elements carry non-blank descriptions |

---

## SAL-16 Formal Ruling — PASS FOR SANDBOX CONFIGURATION, UAT PENDING

Agentforce metadata deployed to sandbox (`0AfUD00000Gq4j30AB`). Tooling API post-deploy validation confirmed:

| Check | Result |
|---|---|
| Astrum BD Agent planner exists | PASS — DeveloperName `Astrum_BD_Agent`, label `Astrum BD Agent` |
| PlannerType | PASS — `AiCopilot__ReAct` (Employee Agent / AEA) |
| Subagent 1 topic exists | PASS — `Account_and_Contact_Management` |
| Action exists under topic | PASS — `Create_Contact_with_Duplicate_Check` |
| Action invokes AGENT_CreateContact | PASS — FlowDefinition `300UD00000QvVmUYAV` |
| InvocationTargetType | PASS — `flow` |
| HITL Confirm | PASS — `IsConfirmationRequired = true` |
| External channel added | PASS — none added; BotDefinition query returned zero rows |
| Account Create action added | PASS — none added |
| Delete action added | PASS — none added |
| SAL-2/SAL-9/SAL-10 touched | PASS — not touched |
| Scope limited to S1 + Action 6 | PASS |
| Production touched | No |

Schema files verified:
- Input schema: 7 fields (AccountId required, FirstName required, LastName required, Title optional, Email optional, Phone optional, MobilePhone optional). PII tagging correct — FirstName, LastName, Email, Phone, MobilePhone marked `lightning:isPII = true`.
- Output schema: 7 variables (Success, CreatedContactId, CreatedContactName, DuplicateFound, DuplicateContactName, DuplicateContactId, ErrorMessage). All marked `copilotAction:isDisplayable = true` and `copilotAction:isUsedByPlanner = true`.

Subagent instructions verified in planner XML: duplicate check instruction, no account create instruction, no delete instruction, opportunity boundary instruction, data quality boundary instruction — all present.

**Conditions before UAT may start:**
1. Agentforce Testing Center was not run. AC-01 through AC-05 remain pending.
2. UI-only activation/publication status is unconfirmed. Salesforce Agentforce agents may require a UI publish/activation step in Agent Builder or Agentforce Studio before they become available to users. Human must confirm whether the agent is active/published in the sandbox before any UAT attempt.
3. `Astrum_BD_Agent_PS` must be assigned to the BD test user before UAT.

---

## SAL-17 Formal Ruling — PASS

Permission set `Astrum_BD_Agent_PS` deployed (`0AfUD00000Gq4EP0AZ`). All checks pass:

| Check | Result |
|---|---|
| Permission set exists | PASS |
| Account: Read only | PASS — Read=true, Create=false, Edit=false |
| Account: Delete = false | PASS |
| Account: View All = false | PASS |
| Account: Modify All = false | PASS |
| Contact: Read + Create + Edit | PASS |
| Contact: Delete = false | PASS |
| Contact: View All = false | PASS |
| Contact: Modify All = false | PASS |
| Contact.AccountId FLS Read+Edit | PASS |
| Contact.Email FLS Read+Edit | PASS |
| Contact.MobilePhone FLS Read+Edit | PASS |
| Contact.Phone FLS Read+Edit | PASS |
| Contact.Title FLS Read+Edit | PASS |
| Contact.FirstName FLS | N/A — not permissionable in this org; createable/updateable via Contact object permission |
| Contact.LastName FLS | N/A — not permissionable in this org; createable/updateable via Contact object permission |
| Flow access to AGENT_CreateContact | PASS — SetupEntityAccess confirmed, entity ID `300UD00000QvVmUYAV` |
| Production touched | No |

Deferred permission items (not needed for AGENT_CreateContact runtime, needed for later S1 actions):
- Account Edit — required when Action 3 (Update Account Field) is configured
- Opportunity Read — required when Action 8 (Account Intelligence Summary) is configured
- Contact.Department FLS — required when Action 7 (Update Contact Field) is configured

---

## Files Committed This Session

### Commit 1 — feat(SAL-15): add AGENT_CreateContact flow and apex test class
- `force-app/main/default/flows/AGENT_CreateContact.flow-meta.xml`
- `force-app/main/default/classes/AGENT_CreateContact_Test.cls`
- `force-app/main/default/classes/AGENT_CreateContact_Test.cls-meta.xml`

### Commit 2 — feat(SAL-16): configure Agentforce create contact action
- `force-app/main/default/genAiPlannerBundles/Astrum_BD_Agent/Astrum_BD_Agent.genAiPlannerBundle`
- `force-app/main/default/genAiPlannerBundles/Astrum_BD_Agent/localActions/Account_and_Contact_Management/Create_Contact_with_Duplicate_Check/input/schema.json`
- `force-app/main/default/genAiPlannerBundles/Astrum_BD_Agent/localActions/Account_and_Contact_Management/Create_Contact_with_Duplicate_Check/output/schema.json`

### Commit 3 — feat(SAL-17): add Astrum BD Agent permission set
- `force-app/main/default/permissionsets/Astrum_BD_Agent_PS.permissionset-meta.xml`

### Commit 4 — docs(SAL-15-17): add PRDs, specs, validation evidence, and session closeout
- `AGENTS.md` (PowerShell sf CLI invocation fix — directly unblocked SAL-15)
- `docs/PRDs/SAL-BD-S1-AGENT_CreateContact-PRD.md`
- `LLM-TXTS/agentforce/Astrum_BD_Agent_Overarching_Spec.md`
- `LLM-TXTS/agentforce/Astrum_BD_Agent_S1_AccountContact_Spec.md`
- `LLM-TXTS/agentforce/Astrum_BD_Agent_S2_OpportunityManagement_Spec.md`
- `LLM-TXTS/agentforce/Astrum_BD_Agent_S3_DataQualityHygiene_Spec.md`
- `LLM-TXTS/schema/Astrum_Objects_Fields_Schema_Authority.md`
- `LLM-TXTS/schema/generate_schema.py`
- `validation/SAL-BD-S1-AGENT_CreateContact.md`
- `validation/SAL-16-AgentBuilder-CreateContact.md`
- `validation/SAL-17-Permissions-FLS-CreateContact.md`
- `validation/agentforce/Astrum_BD_Agent_Build_Readiness_Report.md`
- `handoff/SAL-15-delivery-handoff.md`
- `handoff/SAL-15-16-17-session-closeout.md` (this file)

---

## Files Intentionally Left Uncommitted

The following files were retrieved from the sandbox by Codex during the SAL-16 discovery pass (Codex retrieves all org metadata to establish XML structure before authoring). These are pre-existing sandbox metadata that Astrum BD Agent does not depend on. Committing them would add noise to the SAL-16 delivery audit trail and risk mixing unrelated org state into this branch.

| Path | Reason not committed |
|---|---|
| `force-app/main/default/bots/Agentforce_Sales_Development_Rep/` | Pre-existing sandbox bot, not SAL scope |
| `force-app/main/default/bots/Copilot_for_Salesforce/` | Pre-existing sandbox bot, not SAL scope |
| `force-app/main/default/bots/Sales_Representative_Agent/` | Pre-existing sandbox bot, not SAL scope |
| `force-app/main/default/genAiFunctions/AUTO_Send_Follow_UP_Emails/` | Pre-existing sandbox function, not SAL scope |
| `force-app/main/default/genAiFunctions/AUTO_Send_Mail_Flow/` | Pre-existing sandbox function, not SAL scope |
| `force-app/main/default/genAiFunctions/Fetch_Account_Information1/` | Pre-existing sandbox function, not SAL scope |
| `force-app/main/default/genAiFunctions/Fetch_Lead_By_Name/` | Pre-existing sandbox function, not SAL scope |
| `force-app/main/default/genAiPlannerBundles/Agentforce_Sales_Development_Rep/` | Pre-existing sandbox agent, not SAL scope |
| `force-app/main/default/genAiPlannerBundles/EmployeeCopilotPlanner/` | Pre-existing sandbox agent, not SAL scope |
| `force-app/main/default/genAiPlannerBundles/Sales_Representative_Agent/` | Pre-existing sandbox agent, not SAL scope |
| `force-app/main/default/genAiPlugins/Fetch_Lead_Details.genAiPlugin-meta.xml` | Pre-existing sandbox plugin, not SAL scope |
| `force-app/main/default/genAiPlugins/Lead_Nurturing.genAiPlugin-meta.xml` | Pre-existing sandbox plugin, not SAL scope |

These files remain untracked in the working tree. The next session should add them to `.gitignore` or stage them separately if sandbox parity tracking becomes required.

---

## AGENTS.md Decision

COMMITTED. The diff adds the PowerShell `sf` CLI invocation instructions (`& "$env:APPDATA\npm\sf.cmd"`) that directly unblocked SAL-15. This is permanent, programme-wide governance content that applies to all future Codex sessions. The change is scoped, approved, and directly relevant.

---

## Remaining Risks Before UAT

| Risk | Description | Owner |
|---|---|---|
| Agentforce activation/publication | Salesforce may require a UI-only publish or activation step in Agent Builder / Agentforce Studio before the Astrum BD Agent is available to sandbox users. CLI/Metadata deploy creates configuration but may not activate it. Human must verify in sandbox UI before UAT. | Human |
| Testing Center not run | AC-01 through AC-05 (agent-level exit criteria) are pending. Agentforce Testing Center must be run to confirm Flow is invoked on 100% of Create Contact requests, Confirm HITL appears, and test case S1-5.3-04 (John Smith / Pfizer duplicate) passes. | Codex/Human in next session |
| Permission set not assigned | `Astrum_BD_Agent_PS` must be assigned to the BD UAT user profile or specific test user before any UAT can run. | Human (UI step) |
| Standard actions 1-5 and 7 not configured | Only Action 6 (AGENT_CreateContact) is configured. Standard actions (Get Account Details, Search Accounts, Update Account Field, Get Contact Details, Search Contacts, Update Contact Field) are not yet added to the agent. UAT scope limited to Action 6 only. | Next session |
| Action 8 (Prompt Template) not started | Account Intelligence Summary is a separate deliverable, not started. | Future session |

---

## Recommended Next Session Starting Point

Ask Claude: "Prepare the sandbox UAT plan for SAL-15, SAL-16, and SAL-17. The plan should cover: (1) UI activation/publication verification for Astrum BD Agent in the sandbox, (2) Astrum_BD_Agent_PS assignment to the BD test user, (3) Agentforce Testing Center test cases for AC-01 through AC-05, (4) low-privilege BD user walkthrough of the Create Contact with Duplicate Check action, and (5) Linear issue closure criteria for SAL-15, SAL-16, and SAL-17."

---

## Linear Comments Posted

| Issue | Comment ID | Status |
|---|---|---|
| SAL-15 | (posted during SAL-15 session — see validation file) | Evidence comment posted |
| SAL-16 | `aba3edfd-ee1d-4ba0-8da6-c2f19db39487` | Evidence comment posted by Codex |
| SAL-17 | `b5a3a164-6075-423c-8ce6-1764d70713c7` | Evidence comment posted by Codex |

Claude did not post additional Linear comments in this closeout session. Issue statuses were not changed. No terminal status transitions (Done/Closed/Production Ready) were made.

---

## Next Operator

- Run next in: Human
- Reason: Today's work is paused after repository closeout. Human should review the committed closeout summary before starting the next session.
- Next prompt: Start the next session by asking Claude to prepare the sandbox UAT plan for SAL-15, SAL-16, and SAL-17, including Agentforce Testing Center checks, UI activation/publication verification, low-privilege BD user testing, and Linear issue closure criteria.
