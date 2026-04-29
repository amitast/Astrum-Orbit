# AI Workflow

This repo uses a controlled Claude Code + Codex + Agentforce Vibes + Human workflow
for Salesforce delivery coordination.

## Standard Workflow

1. Claude analyses requirement.
2. Claude creates PRD.
3. Claude updates Linear with PRD/blocker status if instructed.
4. Human approves PRD.
5. Codex implements one approved unit.
6. Codex runs tests/validation.
7. Codex updates Linear with implementation evidence if instructed.
8. Agentforce Vibes runs org-aware validation if instructed (Code Analyzer,
   metadata inspection, Agentforce DX checks, Testing Center preparation).
9. Claude reviews Codex implementation output and Agentforce Vibes evidence.
10. Claude updates Linear with review result if instructed.
11. Human approves sandbox deployment.
12. Agentforce Vibes runs post-deploy sandbox checks if instructed.
13. Human controls production release and final Linear status transition.

## Operating Rules

- Only one AI agent edits files at a time.
- Every agent output must declare the next operator.
- No issue status transition to Done, Closed, Production Ready, or equivalent may
  happen without Human instruction.
- Linear comments must be concise, factual, and evidence-based.
- Claude owns PRD, architecture, review, and Linear design/status updates.
- Codex owns implementation, validation, and Linear implementation-evidence
  updates.
- Agentforce Vibes owns org-aware validation, Salesforce DX inspection, Testing
  Center operations, and Linear validation-evidence updates.
- Human owns approvals, deployment decisions, production release, and terminal
  Linear status transitions.

## Handoff Rules

Claude handoffs to Codex must include:
- PRD or explicit approved implementation reference.
- Exact allowed file targets.
- Disallowed files or commands.
- Validation commands or expected evidence.
- Linear update instruction, if any.

Claude handoffs to Agentforce Vibes must include:
- Specific validation scope (org checks, Code Analyzer, Testing Center, or metadata
  inspection).
- Target org confirmation: amit.kumar@astrumcro.com.astrumpar (sandbox only).
- Disallowed commands (no deploy, no activate, no metadata modifications).
- Expected evidence format and output file path if any.
- Linear update instruction, if any.

Codex handoffs to Claude must include:
- Files changed.
- Tests or validation run.
- Whether deployment was run.
- Whether Linear was updated.
- Remaining risks or blockers.

Agentforce Vibes handoffs to Claude must include:
- Org validation results (metadata state, bot activation, permission assignments).
- Code Analyzer scan results or Testing Center results if run.
- Sandbox confirmation (IsSandbox = true verified).
- Whether any org commands were run that modified state.
- Remaining risks or open items.

Human checkpoints must explicitly state:
- Whether the PRD is approved.
- Whether sandbox deployment is approved.
- Whether production deployment is approved.
- Whether Linear may be moved to a terminal status.
