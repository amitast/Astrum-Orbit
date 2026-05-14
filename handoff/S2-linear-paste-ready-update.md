# S2 Linear Paste-Ready Update

Linear search/update status: Linear plugin discovery succeeded, but the available search/research call failed with `tool research not found`, and no issue-list tool was exposed in this session. Codex did not create or update a Linear issue blindly.

## Suggested New Issue

Title:

```text
[Astrum BD Agent] Subagent 2 Opportunity Management Build
```

Team:

```text
Salesforce
```

Project:

```text
Orbit Opportunities Notifications
```

Labels:

```text
salesforce, agentforce, Feature
```

Priority:

```text
High
```

Description:

```markdown
## Objective

Deliver Astrum BD Agent Subagent 2: Opportunity Management in sandbox.

## Scope

- Get Opportunity Details.
- Search Opportunities.
- Create Opportunity with Confirm HITL, subject to mandatory-field validation.
- Update Opportunity Progress via `AGENT_UpdateOpportunityProgress`.
- Capture Next Steps via `AGENT_CaptureNextSteps`.
- Opportunity Status Summary via `AGENT_OpportunityStatusSummary`.

## Metadata Components

- `AGENT_UpdateOpportunityProgress` Flow
- `AGENT_CaptureNextSteps` Flow
- `Astrum_BD_Agent_PS` permission set update
- `AGENT_OpportunityStatusSummary` GenAiPromptTemplate
- Human Agent Builder setup guide

## Build Status

Sandbox metadata build complete.

## Validation Status

Sandbox deploy passed.

- Dry-run validate ID: `0AfUD00000H3B5C0AV`
- Sandbox deploy ID: `0AfUD00000H3JYz0AN`
- Target org: `astrum--astrumpar.sandbox.my.salesforce.com`
- Components: 4
- Component errors: 0

`RunLocalTests` was attempted and failed only because org-wide Apex coverage is currently 65%. This S2 package contains no Apex.

## Remaining Blockers / Human-Only Steps

- Human to configure S2 topic/actions in Agent Builder using `handoff/S2-agent-builder-human-setup.md`.
- Human/Salesforce Admin to validate Create Opportunity mandatory-field handling.
- Human to run Agentforce Testing Center / UAT scenarios.
- `Opportunity_ID_18__c` is absent from sandbox; record-link support remains out of scope until deployed to sandbox.

## Evidence

- `validation/S2-opportunity-management-kickoff-20260514.md`
- `validation/S2-opportunity-management-validation-20260514.md`
- `handoff/S2-opportunity-management-delivery-handoff.md`
- `handoff/S2-agent-builder-human-setup.md`
```

## Phase Comments

### Phase 0 Inspection Complete

```markdown
Codex update - 2026-05-14 - Phase 0 inspection complete

Phase 0 safety inspection is complete.

Evidence:
- `validation/S2-opportunity-management-kickoff-20260514.md`

Findings:
- Feature branch created: `feature/astrum-bd-agent-s2-opportunity-management`.
- Pre-existing dirty worktree contains unrelated SAL-10/SAL-22 notification work; Codex avoided those files.
- Alias `astrumpar` is not authorized locally, but documented username `amit.kumar@astrumcro.com.astrumpar` connects to the sandbox.
- `Organization.IsSandbox = true` confirmed.

No production org was targeted.
```

### Phase 1 Org Validation Complete

```markdown
Codex update - 2026-05-14 - Phase 1 org validation complete

Live sandbox validation is complete.

Evidence:
- `validation/S2-opportunity-management-kickoff-20260514.md`
- `validation/S2-opportunity-required-fields-20260514.json`
- `validation/S2-genaiprompttemplate-list-20260514.json`
- `validation/S2-genaiplannerbundle-list-20260514.json`

Findings:
- Opportunity object and core S2 fields confirmed.
- Full 19 active StageName values confirmed.
- `Opp_Probability__c` values confirmed: `0`, `5`, `10`, `25`, `50`, `75`, `90`, `100`.
- `Astrum_BD_Agent_PS` exists.
- Agentforce and Prompt Template metadata support confirmed.
- `Opportunity_ID_18__c` is absent from sandbox and remains ORG-VALIDATION REQUIRED.

Verdict: READY WITH ORG-VALIDATION ITEMS.
```

### Phase 3 Build Complete

```markdown
Codex update - 2026-05-14 - Phase 3 build complete

S2 metadata build is complete.

Files changed:
- `force-app/main/default/flows/AGENT_UpdateOpportunityProgress.flow-meta.xml`
- `force-app/main/default/flows/AGENT_CaptureNextSteps.flow-meta.xml`
- `force-app/main/default/permissionsets/Astrum_BD_Agent_PS.permissionset-meta.xml`
- `force-app/main/default/genAiPromptTemplates/AGENT_OpportunityStatusSummary.genAiPromptTemplate-meta.xml`
- `handoff/S2-agent-builder-human-setup.md`

Notes:
- Both Flows run in user context via `DefaultMode`.
- Opportunity Delete permission remains false.
- Prompt Template excludes `D365_Opportunity_Notes__c`, `Description`, long text migration fields, and external web data.
```

### Phase 4 Validation Complete

```markdown
Codex update - 2026-05-14 - Phase 4 validation complete

S2 metadata validation and sandbox deployment are complete.

Evidence:
- `validation/S2-opportunity-management-validation-20260514.md`
- `validation/S2-opportunity-management-dry-run-notestrun-20260514.json`
- `validation/S2-opportunity-management-sandbox-deploy-20260514.json`

Results:
- Dry-run validate ID: `0AfUD00000H3B5C0AV` - PASS.
- Sandbox deploy ID: `0AfUD00000H3JYz0AN` - PASS.
- Components deployed: 4.
- Component errors: 0.
- Production targeted: No.

Remaining:
- Human Agent Builder setup.
- Testing Center / UAT execution.
- Create Opportunity mandatory-field handling validation.
```

### Final Handoff Ready

```markdown
Codex update - 2026-05-14 - Final handoff ready

S2 Opportunity Management sandbox metadata foundation is ready for Human Agent Builder setup and UAT.

Handoff:
- `handoff/S2-opportunity-management-delivery-handoff.md`
- `handoff/S2-agent-builder-human-setup.md`

Open items:
- Configure Opportunity Management topic/actions in Agent Builder.
- Validate standard Create Opportunity action prompts for all mandatory fields.
- Run Testing Center/UAT scenarios.
- Decide whether to deploy `Opportunity_ID_18__c` to sandbox for record-link support.

Do not move this issue to Done/Closed/Production Ready until Human Agent Builder setup and UAT are complete.
```

## Business Summary

- **What was done:** Prepared paste-ready Linear issue and phase comments for the S2 Opportunity Management build.
- **What was found:** Linear search/update tooling was not fully available in this session, so Codex did not create or update a Linear issue directly.
- **What this means:** The Linear update can be applied manually without risking an update to the wrong issue.
- **What is next:** Human or a session with working Linear search should create/update the correct Linear issue using this content.
- **Decision needed from Human:** Decide whether to paste this into an existing S2 issue or create the suggested new issue.
