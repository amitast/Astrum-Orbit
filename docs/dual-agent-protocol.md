# Dual-Agent Protocol
# Astrum Orbit Salesforce Delivery Programme

**Version:** 1.0 | **Date:** 2026-04-27 | **Status:** Active

This document is the authoritative operating model for all Claude Code + Codex + Human coordination on this programme. Both agents and the Human operator must follow it.

---

## 1. Operating Model Summary

| Dimension | Claude Code (Architect) | Codex (Builder) | Human (Approver) |
|---|---|---|---|
| Primary role | Design, PRD authorship, schema validation, review | Implementation, test execution, evidence collection | Authorization, deployment, business decisions |
| Triggers work | Human instruction or blocker escalation | Claude Code handoff prompt or Human instruction | External business event or agent escalation |
| Reads | PRDs, schema, Linear issues, Memory Pack | AGENTS.md, CLAUDE.md, PRDs, validation files | PRDs, evidence files, agent reports |
| Writes | PRDs, CLAUDE.md, AGENTS.md, handoff docs | Flow XML, Apex, smoke test scripts, evidence files | Linear status transitions, deployment commands |
| Linear status allowed | Todo → In Progress, add comments | Todo → In Progress, add comments | All status transitions including Done/Closed |
| Deploy authority | None (design only) | Sandbox only, when explicitly instructed | Sandbox + Production |
| Can resolve business decisions | No — escalates to Human | No — stops and reports blocker | Yes |

---

## 2. Session Types and Handoff Triggers

### Session Type A: Claude Code — Architect Session
**Trigger:** New SAL issue, blocker analysis, review request, or Human "design X" prompt.
**Output required before closing:**
- PRD saved in `PRDS/SAL-{n}-{title}.md`
- Schema assertions verified (or explicit NET-NEW REQUIRED labels)
- Linear comment posted: requirement summary, PRD status, open decisions
- Codex handoff prompt ready (or stated reason why Codex is not yet unblocked)

### Session Type B: Codex — Builder Session
**Trigger:** Claude Code handoff prompt delivered by Human.
**Pre-conditions (Codex must verify before starting):**
- `AGENTS.md` read completely
- PRD read completely
- Current Linear issue state read
- Branch name confirmed

**Output required before closing:**
- All specified files committed to the feature branch
- Evidence file written in `validation/`
- Smoke test table complete (all scenarios: PASS / FAIL / PENDING with reason)
- Linear comment posted (or paste-ready block produced)
- Known risks list written

### Session Type C: Human — Review and Approval Session
**Trigger:** Codex session complete + Human reads evidence.
**Human actions in this session:**
- Review smoke test results — 7/7 required for sandbox sign-off
- Post Linear comment confirming sign-off (or raising additional blockers)
- If satisfied: authorise production deployment (written instruction required)
- If not satisfied: instruct Claude Code to review and Codex to re-run

---

## 3. Claude → Codex Handoff Checklist

Claude Code must provide all of the following before a Codex session starts. If any item is missing, Codex must ask before proceeding.

- [ ] SAL issue number and Linear issue ID
- [ ] PRD file path and version
- [ ] Exact files to create or modify (full paths)
- [ ] Branch name to work on
- [ ] Schema assertions: every field API name verified, or NET-NEW REQUIRED flagged
- [ ] Open decisions that block the build (Codex must stop if it hits these)
- [ ] Exact deploy command if deployment is authorised this session
- [ ] Smoke test scenarios to run (or reference to PRD section)
- [ ] Evidence file path to write results to

---

## 4. Codex → Claude Handoff Checklist

After each Codex session, the Human passes the following to Claude Code for review. Claude Code must not approve production deployment without reviewing these.

- [ ] List of files changed (with git diff or commit hash)
- [ ] Smoke test result table (all scenarios)
- [ ] Deploy ID (or "not deployed")
- [ ] Known risks list
- [ ] Linear comment (posted or paste-ready)
- [ ] Any open questions or blockers encountered during build

---

## 5. Linear Governance (Authoritative)

### Per-agent update matrix

| Event | Agent | Allowed Linear actions |
|---|---|---|
| PRD authored | Claude Code | Post comment: requirement summary, PRD path, schema assertions, open decisions. May set Todo → In Progress. |
| Blockers identified | Claude Code | Post comment: blocker list, BD item IDs, recommended escalation. No status change. |
| Codex build started | Codex | Set In Progress (if not already). Post comment: build started, branch, files in scope. |
| Codex build complete | Codex | Post comment: files changed, deploy ID, smoke test table, known risks. No status change beyond In Progress. |
| Claude review complete | Claude Code | Post comment: review findings, pass/fail, recommended next step. No status change. |
| Sandbox sign-off | Human | Post comment: sign-off confirmation. May set In Progress → Staging / Ready for Production. |
| Production deployed | Human | Post comment: deploy ID, activation confirmation. May set → Production Ready. |
| Issue closed | Human | Post comment: final confirmation. May set → Done or Closed. |

### Prohibited by both agents at all times
- Setting status to Done, Closed, Production Ready, or any terminal state
- Rewriting the issue description unless explicitly instructed to do so
- Deleting or editing prior comments

### Comment format (both agents, every update)

```
**[AGENT: Claude Code | Codex] — [YYYY-MM-DD]**
**Action:** [one-line summary]
**Evidence:**
- Files: [list or "N/A"]
- Tests: [table or "not applicable this session"]
- Deploy ID: [ID or "Not deployed this session"]
**Risks/Blockers:** [list or "None"]
**Next step:** [recommended action for next agent or Human]
```

### Linear MCP unavailable

Produce a fenced code block:

```
[PASTE TO LINEAR SAL-XX]

**[AGENT: ...] — [date]**
[full comment content]
```

Label it clearly. Do not skip the update.

---

## 6. Branch and Commit Protocol

| Rule | Detail |
|---|---|
| Branch naming | `feature/SAL-{n}-{kebab-title}` |
| Commit message format | `type(SAL-N): description` — types: feat, fix, test, docs, chore |
| No force push | Never `git push --force` to any branch |
| No amend published | Never `git commit --amend` after a commit is pushed |
| PR target | Always target `main` |
| PR approval | Human approval required before merge |
| Merge to main | Human action only |

---

## 7. Governance Checkpoints

These are hard gates. Neither agent may proceed past a checkpoint without the stated authority.

| Checkpoint | Gate | Authority |
|---|---|---|
| PRD approved | Human reviews PRD and confirms it is correct before Codex build starts | Human |
| Sandbox smoke test sign-off | 7/7 scenarios pass. 6/7 is not sign-off. | Human |
| Production deployment authorised | Written instruction in session prompt | Human |
| Linear status → Production Ready | Written instruction | Human |
| Linear status → Done | Written instruction | Human |
| Business decision resolved (BD-01 through BD-10) | Written sign-off | Human (BD Lead / Commercial) |

---

## 8. Current SAL Issue Status (as at 2026-04-27)

| Issue | Notification | Build Status | Linear |
|---|---|---|---|
| SAL-2 | Critical Stage Progression | Complete — production active 25 Apr 2026 | Done |
| SAL-9 | Closed Won | Complete — production active 27 Apr 2026 | Done |
| SAL-10 | Closed Lost Review | Sandbox active. 6/7 smoke tests pass. Prod blocked BD-01–BD-05 | In Progress |
| SAL-3 through SAL-8, SAL-11–SAL-14 | Various | Not started or blocked on custom object / business decisions | Backlog |

### SAL-10 remaining action before sandbox sign-off
- Scenario G (Bypass_Flow manual test) — PENDING
- Completing Scenario G = all 7/7 pass = sandbox sign-off eligible (subject to Human approval)

### Next unblocked build candidates
- SAL-1 (Manual notification) — cleanest trigger; no complex recipient matrix
- SAL-11, SAL-12, SAL-13 — second wave; recipient matrix complexity to be confirmed

---

## 9. Shared Infrastructure Registry

These items are deployed to production. Do not include in any future deployment manifest.

| Item | Metadata type | Production status |
|---|---|---|
| Bypass_Flow | CustomPermission | Active — do not re-deploy |
| Opportunity_ID_18__c | CustomField (Formula) | Active — do not re-deploy |
| Salesforce_Base_URL | CustomLabel | Active (value: `https://astrum.my.salesforce.com`) — do not re-deploy |
| Notify_Critical_Stage_Progression_After_Save | Flow | Active v2 (301TY00000rVQPaYAO) — do not modify |
| Notify_Closed_Won_After_Save | Flow | Active (301TY00000rYVAxYAO) — do not modify |
