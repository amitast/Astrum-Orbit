# Linear Update Protocol

Linear is the delivery record. Updates must be concise, factual, evidence-based,
and appended unless the Human explicitly instructs otherwise.

## 1. Who Can Update Linear

Claude Code may update Linear when instructed for PRD, blocker, design/status,
and review updates.

Codex may update Linear when instructed for build, validation, and implementation
evidence updates.

The Human may update Linear at any time and is the only authority for terminal
status transitions.

## 2. When Claude Should Update Linear

Claude should update Linear when instructed after:
- Requirement analysis identifies blockers.
- A PRD is created or materially changed.
- A review is completed.
- A design/status summary is needed for the delivery record.

## 3. When Codex Should Update Linear

Codex should update Linear when instructed after:
- A build starts.
- Implementation completes.
- Validation passes.
- Validation fails.
- Deployment evidence must be recorded after Human-authorised deployment.

Codex comments must be evidence-based and include implementation facts, not PRD
definitions or business decisions.

## 4. When Human Must Approve Before Linear Status Changes

Human approval is required before:
- Moving an issue to Done.
- Moving an issue to Closed.
- Moving an issue to Production Ready.
- Moving an issue to any equivalent terminal or release-ready state.
- Recording production release completion.

AI agents may leave an issue In Progress after build or review unless instructed
otherwise.

## 5. Standard Linear Comment Templates

### PRD Created

```markdown
**[AGENT: Claude Code] - [YYYY-MM-DD]**
**Action:** PRD created for [SAL-XX].
**Branch:** [branch or N/A]
**Commit:** [hash or N/A]
**Files changed:**
- [file]
**Tests run:** Not applicable - PRD only.
**Deployment target:** Not deployed.
**Remaining risks:** [risks/blockers or None identified]
**Next step:** Human review and PRD approval.
```

### Blocked

```markdown
**[AGENT: Claude Code] - [YYYY-MM-DD]**
**Action:** [SAL-XX] blocked.
**Branch:** [branch or N/A]
**Commit:** [hash or N/A]
**Files changed:** None.
**Tests run:** Not applicable.
**Deployment target:** Not deployed.
**Remaining risks:** [specific blocker list]
**Next step:** Human/owner to resolve blockers before implementation or release.
```

### Build Started

```markdown
**[AGENT: Codex] - [YYYY-MM-DD]**
**Action:** Build started for [SAL-XX].
**Branch:** [branch]
**Commit:** [hash or N/A]
**Files changed:** Pending.
**Tests run:** Pending.
**Deployment target:** Not deployed.
**Remaining risks:** [known risks or None identified]
**Next step:** Codex implementation and validation.
```

### Implementation Complete

```markdown
**[AGENT: Codex] - [YYYY-MM-DD]**
**Action:** Implementation complete for [SAL-XX].
**Branch:** [branch]
**Commit:** [hash or N/A]
**Files changed:**
- [file]
**Tests run:**
| Scenario | Result |
|---|---|
| [scenario] | [PASS/FAIL/PENDING] |
**Deployment target:** Not deployed.
**Remaining risks:** [risks or None identified]
**Next step:** Claude review.
```

### Validation Passed

```markdown
**[AGENT: Codex] - [YYYY-MM-DD]**
**Action:** Validation passed for [SAL-XX].
**Branch:** [branch]
**Commit:** [hash or N/A]
**Files changed:**
- [file or None]
**Tests run:**
| Scenario | Result |
|---|---|
| [scenario] | PASS |
**Deployment target:** [target or Not deployed]
**Remaining risks:** [risks or None identified]
**Next step:** Claude review or Human deployment checkpoint.
```

### Validation Failed

```markdown
**[AGENT: Codex] - [YYYY-MM-DD]**
**Action:** Validation failed for [SAL-XX].
**Branch:** [branch]
**Commit:** [hash or N/A]
**Files changed:**
- [file or None]
**Tests run:**
| Scenario | Result |
|---|---|
| [scenario] | FAIL |
**Deployment target:** Not deployed.
**Remaining risks:** [failure details and risks]
**Next step:** Codex fix or Claude scope review.
```

### Claude Review Complete

```markdown
**[AGENT: Claude Code] - [YYYY-MM-DD]**
**Action:** Review complete for [SAL-XX].
**Branch:** [branch]
**Commit:** [hash or N/A]
**Files changed:** Reviewed only.
**Tests run:** [tests/evidence inspected]
**Deployment target:** Not deployed.
**Remaining risks:** [findings/risks or None identified]
**Next step:** [Codex fixes / Human sandbox deployment checkpoint]
```

### Sandbox Deployment Complete

```markdown
**[AGENT: Human/Authorised Operator] - [YYYY-MM-DD]**
**Action:** Sandbox deployment complete for [SAL-XX].
**Branch:** [branch]
**Commit:** [hash]
**Files changed:**
- [file]
**Tests run:**
| Scenario | Result |
|---|---|
| [scenario] | [PASS/FAIL/PENDING] |
**Deployment target:** Sandbox - [org/alias]
**Deploy ID:** [deploy id]
**Remaining risks:** [risks or None identified]
**Next step:** Claude review, additional validation, or Human production checkpoint.
```

### Production Deployment Complete

```markdown
**[AGENT: Human/Authorised Operator] - [YYYY-MM-DD]**
**Action:** Production deployment complete for [SAL-XX].
**Branch:** [branch]
**Commit:** [hash]
**Files changed:**
- [file]
**Tests run:**
| Scenario | Result |
|---|---|
| [scenario] | [PASS/FAIL/PENDING] |
**Deployment target:** Production - [org/alias]
**Deploy ID:** [deploy id]
**Remaining risks:** [risks or None identified]
**Next step:** Human may approve final Linear status transition.
```

## 6. Rules

- Always read the current Linear issue before updating.
- Do not overwrite business decisions unless instructed.
- Do not close issues without Human instruction.
- Include branch name, commit hash if available, files changed, tests run,
  deployment target, and remaining risks.
- If MCP is unavailable, produce a paste-ready comment.
- Do not move issues to Done, Closed, Production Ready, or equivalent without
  Human instruction.
- Keep comments short, factual, and tied to evidence.
