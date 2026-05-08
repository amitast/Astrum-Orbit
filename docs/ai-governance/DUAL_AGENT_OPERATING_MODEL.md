# Dual-Agent Operating Model

This repo separates design, build, validation, review, deployment, and release
authority across Claude Code, Codex, and the Human operator.

## Roles

Claude Code is the Architect and Reviewer. Claude turns requirements into PRDs,
identifies blockers, prepares scoped implementation handoffs, and reviews Codex
output against the approved scope.

Codex is the Builder and Test Executor. Codex implements only approved work,
keeps changes minimal, runs validation, and reports evidence.

The Human is the Approval, Deployment, and Release Authority. The Human approves
PRDs, resolves business decisions, authorises sandbox deployment, controls
production release, and controls final Linear status transitions.

## Practical Flow

1. Claude analyses the requirement and asks for missing business decisions.
2. Claude writes a PRD or implementation handoff.
3. The Human approves the PRD or explicit implementation prompt.
4. Codex implements one approved unit and avoids unrelated changes.
5. Codex runs the requested tests or validation.
6. Codex reports changed files, validation evidence, deployment status, Linear
   status, and risks.
7. Claude reviews the implementation.
8. The Human decides whether deployment or release may proceed.

## File Editing Control

Only one AI agent edits files at a time. Claude should not revise files while
Codex is implementing. Codex should not continue implementation while Claude is
reviewing or changing the PRD. If scope changes, stop the current operator and
restart with a fresh handoff.

## Linear Coordination

Claude owns PRD, blocker, and review updates. Codex owns implementation evidence
updates. Both agents update Linear only when instructed.

Before updating Linear, the agent must read the current issue if MCP is
available. Updates must be comments added to the issue unless the Human
explicitly instructs otherwise. If MCP is unavailable, the agent must produce a
paste-ready comment.

No AI agent may move an issue to Done, Closed, Production Ready, or equivalent
without Human instruction.

## Salesforce Delivery Guardrails

Codex must not deploy, update production, perform destructive changes, invent
field API names, or touch unrelated files. Claude must not make business
decisions or silently broaden scope. Both agents must follow the approved schema,
PRD, and prompt constraints.

For Salesforce work, any metadata change must be explicitly approved and scoped.
Deployment is a Human-controlled checkpoint.

## Evidence Expectations

Codex evidence should include:
- Branch name.
- Commit hash when available.
- Files changed.
- Tests or validation run.
- Deployment target and deployment ID, if a Human authorised deployment.
- Remaining risks or blockers.
- Next operator.

Claude review evidence should include:
- Scope reviewed.
- Findings or confirmation that no blocking issues were found.
- Tests or evidence inspected.
- Remaining risks or approval recommendations.
- Next operator.
