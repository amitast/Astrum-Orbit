# S2 Opportunity Management Kickoff Evidence - 2026-05-14

| Item | Finding |
|---|---|
| Workstream | Astrum BD Agent Subagent 2: Opportunity Management |
| Operator | Codex |
| Phase | Phase 0 - Safety and repository inspection |
| Date | 2026-05-14 |
| Branch requested | `feature/astrum-bd-agent-s2-opportunity-management` |
| Branch created | Yes |
| Current branch | `feature/astrum-bd-agent-s2-opportunity-management` |
| Salesforce DX project root | `c:\Users\Amit Asthana\my-ai-project` |
| Package directory | `force-app` |
| Source API version | `66.0` |

## Git Safety Check

Initial branch before S2 work: `main`.

The working tree was dirty before S2 work began. Existing changes appear related to prior SAL-10/SAL-22 notification work and are outside the S2 Opportunity Management scope:

| Path | Status | S2 related? | Action |
|---|---:|---|---|
| `force-app/main/default/flows/Notify_Critical_Stage_Progression_After_Save.flow-meta.xml` | Modified | No | Do not touch |
| `PRDS/SAL-notifications-business-feedback-20260511.md` | Untracked | No | Do not touch |
| `force-app/main/default/classes/SAL22_WeeklyOpportunityIntakeDigest.cls` | Untracked | No | Do not touch |
| `force-app/main/default/classes/SAL22_WeeklyOpportunityIntakeDigest.cls-meta.xml` | Untracked | No | Do not touch |
| `force-app/main/default/classes/SAL22_WeeklyOpportunityIntakeDigest_Test.cls` | Untracked | No | Do not touch |
| `force-app/main/default/classes/SAL22_WeeklyOpportunityIntakeDigest_Test.cls-meta.xml` | Untracked | No | Do not touch |
| `force-app/main/default/flows/Notify_Closed_Lost_Review_After_Save.flow-meta.xml` | Untracked | No | Do not touch |
| `force-app/main/default/objects/Opportunity/fields/SAL10_Lost_Notification_Reset__c.field-meta.xml` | Untracked | No | Do not touch |
| `force-app/main/default/objects/Opportunity/fields/SAL10_Lost_Notification_Sent_Date__c.field-meta.xml` | Untracked | No | Do not touch |
| `force-app/main/default/objects/Opportunity/fields/SAL10_Lost_Notification_Sent__c.field-meta.xml` | Untracked | No | Do not touch |
| `force-app/main/default/permissionsets/SAL10_Notification_Field_Access.permissionset-meta.xml` | Untracked | No | Do not touch |
| `handoff/SAL-10-SAL-23-production-deployment-handoff-20260513.md` | Untracked | No | Do not touch |
| `handoff/SAL-notifications-business-feedback-20260511.md` | Untracked | No | Do not touch |
| `scripts/apex/schedule_sal22_weekly_digest.apex` | Untracked | No | Do not touch |
| `scripts/apex/smoke_sal10_business_feedback.apex` | Untracked | No | Do not touch |
| `scripts/api/` | Untracked | No | Do not touch |
| `validation/SAL-10-SAL-23-production-deploy-20260513.md` | Untracked | No | Do not touch |
| `validation/SAL-10-SAL-23-production-validate-20260513.md` | Untracked | No | Do not touch |
| `validation/SAL-10-SAL-23-production-validation-plan-20260512.md` | Untracked | No | Do not touch |
| `validation/SAL-notifications-business-feedback-20260511.md` | Untracked | No | Do not touch |
| `validation/SAL-notifications-business-feedback-baseline-20260511.md` | Untracked | No | Do not touch |

Branch creation initially hit a local `.git` permission lock under the sandbox and was retried with elevated filesystem permission. No files were changed by the branch operation.

## Repository Documents Read

| Document | Purpose |
|---|---|
| `CLAUDE.md` | Local project and Salesforce rules |
| `AGENTS.md` | Two-agent governance and Salesforce guardrails |
| `AI_WORKFLOW.md` | Handoff and validation process |
| `LLM-TXTS/Astrum_Project_Memory_Pack_v1.md` | Programme guardrails and schema authority |
| `LLM-TXTS/Astrum_BD_Agent_S2_OpportunityManagement_Config.md` | S2 configuration source |
| `LLM-TXTS/agentforce/Astrum_BD_Agent_S2_OpportunityManagement_Spec.md` | S2 build specification |
| `LLM-TXTS/agentforce/Astrum_BD_Agent_S1_AccountContact_Spec.md` | Existing S1 implementation pattern |
| `validation/agentforce/Astrum_BD_Agent_Build_Readiness_Report.md` | Prior schema and build readiness findings |
| Existing `PRDS/`, `validation/`, `handoff/`, and `LLM-TXTS/` indexes | Relevant evidence and delivery patterns |

## Existing S1 Metadata Pattern Found

| Component | Local path |
|---|---|
| Permission set | `force-app/main/default/permissionsets/Astrum_BD_Agent_PS.permissionset-meta.xml` |
| S1 Flow | `force-app/main/default/flows/AGENT_CreateContact.flow-meta.xml` |
| Account/contact detail Flows | `force-app/main/default/flows/AGENT_GetAccountDetails.flow-meta.xml`, `force-app/main/default/flows/AGENT_GetContactDetails.flow-meta.xml` |
| S1 AGENT Apex actions | `force-app/main/default/classes/AGENT_*.cls` |
| Existing prompt template | `force-app/main/default/genAiPromptTemplates/AGENT_AccountIntelligenceSummary.genAiPromptTemplate-meta.xml` |
| Existing planner bundle | `force-app/main/default/genAiPlannerBundles/Astrum_BD_Agent/` |
| Existing bot metadata | `force-app/main/default/bots/Astrum_BD_Agent/` |

## Salesforce Target Safety Check

Requested alias check:

| Command intent | Result |
|---|---|
| Display org for alias `astrumpar` | Failed: no local authorization found for alias `astrumpar` |
| Display org for documented username `amit.kumar@astrumcro.com.astrumpar` | Connected successfully |

Sensitive note: `sf org display --json` returned a session access token. The token is intentionally not recorded in this evidence file.

Sandbox verification query:

```text
SELECT Id, Name, IsSandbox FROM Organization
```

| Field | Value |
|---|---|
| Organization Id | `00DUD000007zF692AE` |
| Organization Name | `ASTRUM CRO, SL` |
| Instance URL | `https://astrum--astrumpar.sandbox.my.salesforce.com` |
| Username | `amit.kumar@astrumcro.com.astrumpar` |
| Local alias shown by CLI | `par-sandbox` |
| IsSandbox | `true` |

## Phase 0 Verdict

READY FOR PHASE 1 ORG VALIDATION.

Constraints carried forward:

- Use target org `amit.kumar@astrumcro.com.astrumpar` or local alias `par-sandbox`; alias `astrumpar` is not authorized in this CLI config.
- Do not touch unrelated SAL-10/SAL-22 dirty worktree files.
- Do not store or publish Salesforce session tokens.
- Do not target production.

## Business Summary

- **What was done:** Started the S2 Opportunity Management workstream, created the feature branch, inspected the repository, and verified the Salesforce target is a sandbox.
- **What was found:** The local alias `astrumpar` is not authorized, but the documented sandbox username connects to `ASTRUM CRO, SL` with `IsSandbox = true`.
- **What this means:** It is safe to proceed with live org validation against the sandbox, while avoiding unrelated pre-existing SAL-10/SAL-22 worktree changes.
- **What is next:** Codex will validate Opportunity fields, picklist values, record types, permissions, Prompt Template support, and Agentforce metadata support.
- **Decision needed from Human:** None at this time.

## Phase 1 Org Validation

Validation target: `amit.kumar@astrumcro.com.astrumpar` / `https://astrum--astrumpar.sandbox.my.salesforce.com`.

JSON evidence files saved:

| Evidence | Path |
|---|---|
| Full Opportunity describe | `validation/S2-opportunity-describe-20260514.json` |
| Required Opportunity field summary | `validation/S2-opportunity-required-fields-20260514.json` |
| Opportunity record type summary | `validation/S2-opportunity-record-types-20260514.json` |
| Account describe for related summary fields | `validation/S2-account-describe-20260514.json` |
| Required Account field summary | `validation/S2-account-required-fields-20260514.json` |
| Permission set existence query | `validation/S2-permissionset-query-20260514.json` |
| Existing AGENT FlowDefinition query | `validation/S2-flowdefinition-query-20260514.json` |
| Opportunity object permissions | `validation/S2-opportunity-objectpermissions-20260514.json` |
| Opportunity field permissions | `validation/S2-opportunity-fieldpermissions-20260514.json` |
| Permission set setup entity access | `validation/S2-setupentityaccess-20260514.json` |
| Agentforce / Einstein license query | `validation/S2-agentforce-license-query-20260514.json` |
| GenAiPromptTemplate metadata list | `validation/S2-genaiprompttemplate-list-20260514.json` |
| GenAiPlannerBundle metadata list | `validation/S2-genaiplannerbundle-list-20260514.json` |
| Bot metadata list | `validation/S2-bot-list-20260514.json` |
| AiEvaluationDefinition metadata list | `validation/S2-aievaluationdefinition-list-20260514.json` |
| Legacy PromptTemplate metadata check | `validation/S2-prompttemplate-list-20260514.json` |

### Field Validation

| Check | Result |
|---|---|
| Opportunity object exists | PASS |
| Required S2 Opportunity fields exist | PASS except `Opportunity_ID_18__c` |
| `Opportunity_ID_18__c` | ORG-VALIDATION REQUIRED - absent from sandbox describe |
| Required related Account fields exist | PASS for `Account.Name`, `Client_Type__c`, `Account_Segment__c` |
| `StageName` values | PASS - all requested values present, plus the full 19 active value list |
| `Opp_Probability__c` values | PASS - `0`, `5`, `10`, `25`, `50`, `75`, `90`, `100` |
| `D365_Opportunity_Notes__c` | CONFIRMED present and explicitly excluded from prompt templates |
| `Description` | Standard Opportunity field present in describe but explicitly excluded from S2 prompt templates |

Full active `StageName` values confirmed in sandbox:

```text
Pre-Identification
Early Engagement
RFI in progress
RFI sent
Proposal On Hold
Proposal In Progress
Proposal Sent
Bid Defense
Verbal Award
Change Order
Contract Agreed
Closed Won
Closed Lost
Proposal/CO sent
Won (signed contract/CO)
Lost/Cancelled/Declined to Bid
Proposal/CO on hold/No updates for long time
Contract/CO agreed but not yet signed
Early Discussions without budget sent
```

### Record Types

| Record type | Developer name | Active | Available | Default | Impact |
|---|---|---:|---:|---:|---|
| Master | Master | true | true | true | No record-type-specific stage branching required for S2 Flow build |

### Permission Set Validation

| Check | Result |
|---|---|
| `Astrum_BD_Agent_PS` exists | PASS |
| Current Opportunity object permission | Read only |
| Current Opportunity Create/Edit permission | Missing - build must add |
| Opportunity Delete permission | PASS - false |
| Current Opportunity FLS | Only `Opportunity.Amount` read found |
| Required S2 Opportunity FLS | Missing - build must add |
| Existing Flow access | S1 flows present for `AGENT_CreateContact`, `AGENT_GetAccountDetails`, `AGENT_GetContactDetails` |
| S2 Flow access | Missing because S2 flows do not yet exist - build must add |

### Agentforce and Metadata Support

| Check | Result |
|---|---|
| Agentforce / Einstein license query | PASS - active Agentforce and Einstein permission set licenses found, including Agent platform builder and prompt template licenses |
| `GenAiPromptTemplate` metadata support | PASS - list metadata succeeded and existing templates are present |
| Legacy `PromptTemplate` metadata support | Not supported - invalid metadata type. Use `GenAiPromptTemplate` only |
| `GenAiPlannerBundle` metadata support | PASS - `Astrum_BD_Agent` exists |
| `Bot` metadata support | PASS - `Astrum_BD_Agent` exists |
| `AiEvaluationDefinition` metadata support | PASS - existing SAL-16 and SAL-21 definitions present |
| Existing S2 flows in org | Not present - expected before build |

### Linear Tooling Note

Linear plugin discovery succeeded, but the available Linear search/research call failed with `tool research not found`. No Linear issue was created or updated during Phase 0 or Phase 1. If Linear search remains unavailable, Codex will produce paste-ready evidence comments rather than create or update a potentially wrong issue.

## Build-Readiness Verdict

READY WITH ORG-VALIDATION ITEMS.

Proceed with S2 metadata build under these constraints:

- Build both S2 Flows and permission set updates.
- Build `AGENT_OpportunityStatusSummary` as `GenAiPromptTemplate` only.
- Do not reference `Opportunity_ID_18__c` in S2 Flow or Prompt Template until the field is deployed to sandbox.
- Do not use legacy `PromptTemplate` metadata.
- Do not attempt production deployment or parent agent production activation.
- Agent Builder / Testing Center UI execution may require Human setup if metadata deployment cannot fully express the S2 topic and action configuration.

## Business Summary - Phase 1

- **What was done:** Validated the S2 Opportunity Management design against the live sandbox org metadata.
- **What was found:** Core Opportunity fields, the 19 active Stage values, the authoritative probability field, Account grounding fields, Agentforce metadata, and Prompt Template metadata are available. `Opportunity_ID_18__c` is not present in sandbox, and the S2 Opportunity permissions are not yet on `Astrum_BD_Agent_PS`.
- **What this means:** S2 build can proceed for Flows, permission set updates, and a grounded summary template, but record-link construction must remain out of scope until `Opportunity_ID_18__c` is deployed to sandbox.
- **What is next:** Codex will create the S2 implementation plan and then build the in-scope metadata.
- **Decision needed from Human:** None at this time for sandbox build; later Human action may be needed to deploy `Opportunity_ID_18__c` to sandbox if record links are required in S2 summaries.
