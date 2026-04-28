# Astrum BD Agent — Build Specification

> **Version:** 0.1 Draft | **Date:** 20 April 2026 | **Status:** Draft for review
> **Programme:** Astrum Orbit Salesforce Programme
> **Audience:** Developer (vibe-coding build), Solution Architect, Programme Lead

---

## How to use this file

This document is the single source of truth for building the Astrum BD Agent in Salesforce using Agentforce. It is structured to be consumed directly by an AI coding assistant (Claude Code, Codex) working inside VS Code alongside Salesforce CLI and the Salesforce Extension Pack.

Work through sections in order:
1. Read the Charter and Subagents first. This establishes what the agent is and is not.
2. Build Actions (Flows and Prompt Templates) before configuring the agent in Agent Builder.
3. Configure the agent and subagents using the exact text in Section 4 and 5.
4. Apply guardrails exactly as specified in Section 6. Do not improvise.
5. Run tests against the exit criteria in Section 7 before requesting sign-off.

All custom metadata should be deployed via SFDX / Salesforce CLI. Do not click-build in production. Use a sandbox with representative BD data for all testing.

---

## 1. Agent Charter

### Identity

| Field | Value |
|---|---|
| **Agent name** | Astrum BD Agent |
| **Agent type** | Agentforce Employee Agent (AEA) |
| **Primary channel** | Embedded in Salesforce application |
| **User audience** | Authenticated internal BD team users |
| **Data classification** | Confidential commercial. No GxP, PHI, or clinical data in scope. |
| **Permission set API name** | `Astrum_BD_Agent_PS` |
| **Running user context** | Runs in the authenticated running user's context. Inherits their object permissions, field-level security, and sharing rules. |

### Mission

> The Astrum BD Agent helps Business Development users efficiently manage accounts, contacts, and opportunities within Salesforce, and maintain data quality across their pipeline records.

### In Scope

- Account record lookup, update, and summarisation
- Contact lookup, creation, and update within accounts
- Opportunity creation, stage progression, close date management, and next steps capture
- Data quality hygiene checks: missing required fields, stale records, overdue close dates, opportunities lacking next steps
- Guided remediation of identified data quality issues, one record at a time with user confirmation

### Out of Scope

- Opportunity deletion (escalate to system admin)
- Account creation (to be managed through controlled data governance process)
- Bulk record updates without individual user review and confirmation
- Pipeline forecasting and reporting (not in MVP scope)
- External system integrations (e.g. LinkedIn, marketing automation) at this phase
- Any GxP, PHI, or clinical data

### Success Metrics

| Metric | Target |
|---|---|
| Correct subagent routing (150-prompt regression suite) | 90% at go-live |
| Escalation fire rate (designed escalation scenarios) | 100% |
| Bulk updates without user confirmation (adversarial set) | Zero |
| Mean response latency, standard record retrieval | Under 5 seconds |
| BD team adoption within 60 days of go-live | 80% active sessions |
| Opportunity data completeness improvement within 90 days | 10% improvement |

---

## 2. Subagent Decomposition

The agent has **three subagents**. Each covers a distinct job family. Scope boundaries are written to minimise misclassification, particularly between Subagent 2 (Opportunity Management) and Subagent 3 (Data Quality).

### Subagent 1: Account and Contact Management

**Atlas Reasoning Engine description (use this exact text in Agent Builder):**

> Handles requests to look up, view, create, update, and summarise account and contact records. Covers finding key contacts at target organisations, updating relationship fields, and generating account intelligence summaries grounded in Salesforce record data. Does not handle opportunity management, pipeline analysis, or cross-record data quality audits.

**Scope:** Account and contact CRUD operations and record-level queries. Excludes opportunity management, bulk hygiene analysis, and any action affecting more than one record per user instruction without individual confirmation.

**Classification utterances (add these as examples in Agent Builder):**

```
"Show me the key contacts at Novartis."
"Update the account tier for AstraZeneca to Strategic."
"Add a new contact to the Pfizer account."
"Who is the procurement lead at [Company]?"
"Summarise what we know about Eli Lilly."
"Change the industry field on BioNTech to Biotechnology."
```

**Rationale:** Account and contact management is a distinct job family from opportunity management. Merging with Subagent 2 would create an overly broad subagent with higher misclassification risk.

---

### Subagent 2: Opportunity Management

**Atlas Reasoning Engine description (use this exact text in Agent Builder):**

> Handles requests to create, view, update, and manage individual opportunity records, including stage progression, close date updates, next steps capture, and opportunity status summaries. Operates on one opportunity at a time at the user's explicit direction. Does not surface cross-pipeline hygiene issues or bulk quality problems.

**Scope:** Individual opportunity CRUD and management actions. Excludes bulk hygiene analysis, account and contact management, and pipeline-level reporting.

**Classification utterances (add these as examples in Agent Builder):**

```
"Move the Roche Phase I deal to Proposal Sent."
"Update the close date on the MSD opportunity to end of June."
"Add a next step to the AZ Full Service deal: follow up after steering committee."
"Summarise the current status of the Eli Lilly opportunity."
"Create a new opportunity for BioNTech, Phase II full service."
"What stage is the Novartis bioanalytical deal at?"
```

**Rationale:** A user requesting "move this deal to Proposal Sent" is performing a deliberate action on a known record. A user requesting "show me opportunities with overdue close dates" is requesting a quality analysis. These are different intent types. Separating them prevents the agent taking an unintended write action in response to a quality query.

---

### Subagent 3: Data Quality and Hygiene

**Atlas Reasoning Engine description (use this exact text in Agent Builder):**

> Handles requests to identify, report on, and guide the remediation of data quality issues across accounts, contacts, and opportunities. Surfaces missing required fields, stale records, opportunities with overdue close dates, and opportunities lacking next steps. Generates prioritised hygiene reports and guides the user through fixing identified issues one record at a time. Does not execute individual record updates in response to direct user commands.

**Scope:** Cross-record data quality analysis, hygiene reporting, and guided field completion with user confirmation per record. Excludes individual record management driven by user intent (e.g. "update this specific opportunity", which routes to Subagent 2) and pipeline forecasting.

**Classification utterances (add these as examples in Agent Builder):**

```
"Which of my accounts are missing the Industry field?"
"Show me opportunities with overdue close dates."
"Run a data quality check on my pipeline."
"Which contacts haven't been touched in 90 days?"
"How many of my opportunities are missing next steps?"
"Give me a data quality summary for this week."
```

**Rationale:** Data quality analysis involves querying across multiple records to surface systemic issues. Keeping it as a dedicated subagent allows specialised actions (bulk query Flows, summarisation Prompt Templates) without those actions being triggered inadvertently during individual record management.

---

### Multi-Agent Architecture Decision

A single agent with three subagents is the correct architecture for this MVP. The job families are related (all BD pipeline management) and the user base is homogeneous. A Supervisor plus Specialist multi-agent architecture is not warranted at this stage. If scope expands in future phases (meeting preparation, competitive intelligence, external channel exposure), revisit and consider an Operator or Orchestrator pattern.

---

## 3. Action Catalogue

### Flow naming convention (mandatory)

All agent-triggered Flows must include the prefix `AGENT_` in their API name.

Examples: `AGENT_UpdateOpportunityProgress`, `AGENT_AccountRequiredFieldsAudit`

This is required for audit identification in Shield Event Monitoring and Flow execution logs.

### Permission footprint

All custom Flows must be configured to **run in user context (not system mode)** to respect sharing rules.

| Object | Required permissions |
|---|---|
| Account | Read, Edit |
| Contact | Read, Edit, Create |
| Opportunity | Read, Edit, Create |

No Delete permission is required or granted on any object.

### HITL mode definitions

| Mode | Behaviour |
|---|---|
| **Autonomous** | Agent returns results without a write action. No confirmation required. |
| **Confirm** | Agent displays proposed change (current value and new value) and waits for explicit user confirmation before executing any DML. |
| **Approve** | Not used in MVP. No bulk write actions are included. |

---

### Subagent 1 Actions: Account and Contact Management

| Action | Type | HITL Mode | Description | Key Inputs | Outputs | Reuse? |
|---|---|---|---|---|---|---|
| Get Account Details | Standard: View Record | Autonomous | Retrieve account record with key fields, related contacts, and recent activity for a named account. Triggered when the user requests account information or a summary. | Account Name / ID | Account fields, contacts | Yes |
| Search Accounts | Standard: Query Records | Autonomous | Find accounts matching user-specified criteria such as name, industry, tier, or owner. Returns a list for user selection. | Search criteria | Account list | Yes |
| Update Account Record | Flow: `AGENT_UpdateAccountFields` | Confirm | Update one or more specified fields on a named account. Displays current and proposed values for user confirmation before writing. Triggered when the user explicitly requests a field change on a known account. | Account ID, field name, new value | Updated record confirmation | No |
| Get Contact Details | Standard: View Record | Autonomous | Retrieve contact record including role, email, phone, account, and last activity date. Triggered when the user asks about a specific contact. | Contact Name / ID | Contact fields | Yes |
| Search Contacts | Standard: Query Records | Autonomous | Find contacts at a named account or matching specified criteria. Returns a list for user selection. | Account Name / criteria | Contact list | Yes |
| Create Contact | Standard: Create Record | Confirm | Create a new contact record linked to a specified account. Checks for potential duplicates by first name, last name, and account before proceeding. Confirms full record before write. | Account ID, name, role, email | New contact confirmation | No |
| Update Contact Record | Flow: `AGENT_UpdateContactFields` | Confirm | Update specified fields on a named contact record. Displays current and proposed values before write. | Contact ID, field name, new value | Updated record confirmation | No |
| Account Intelligence Summary | Prompt Template | Autonomous | Generate an AI summary of account status, key contacts, recent activity, and open opportunities grounded in the retrieved Salesforce record data. Triggered after Get Account Details when user requests a summary. | Account record data, related opportunities | Narrative summary | Yes (reusable in Subagent 3) |

---

### Subagent 2 Actions: Opportunity Management

| Action | Type | HITL Mode | Description | Key Inputs | Outputs | Reuse? |
|---|---|---|---|---|---|---|
| Get Opportunity Details | Standard: View Record | Autonomous | Retrieve opportunity record with stage, close date, amount, next steps, and key contacts. Triggered when the user asks about a specific opportunity. | Opportunity Name / ID | Opportunity fields | Yes |
| Search Opportunities | Standard: Query Records | Autonomous | Find opportunities by owner, account, stage, or other criteria. Returns a list for user selection. | Search criteria | Opportunity list | Yes |
| Create Opportunity | Standard: Create Record | Confirm | Create a new opportunity record linked to a specified account. Confirms full record before write. | Account ID, name, stage, close date, amount | New opportunity confirmation | No |
| Update Opportunity Progress | Flow: `AGENT_UpdateOpportunityProgress` | Confirm | Update the Stage and/or Close Date fields on a named opportunity. Alerts user if the proposed close date is in the past. Requires a Next Step to be captured if stage is progressed forward. | Opportunity ID, new stage, new close date | Updated record confirmation | No |
| Capture Next Steps | Flow: `AGENT_UpdateOpportunityNextSteps` | Confirm | Update the Next Steps field on a named opportunity. Displays current next steps and proposed replacement before write. | Opportunity ID, next steps text | Updated field confirmation | No |
| Opportunity Status Summary | Prompt Template | Autonomous | Generate an AI summary of opportunity status, stage history, risks, and recommended next actions grounded in the Salesforce record. Triggered when user requests an opportunity summary. | Opportunity record data, stage history | Narrative summary | No |

---

### Subagent 3 Actions: Data Quality and Hygiene

| Action | Type | HITL Mode | Description | Key Inputs | Outputs | Reuse? |
|---|---|---|---|---|---|---|
| Account Completeness Check | Flow: `AGENT_AccountRequiredFieldsAudit` | Autonomous | Query accounts owned by the running user and return a list of records missing one or more agreed required fields. Confirms scope with user before running. | Running user ID, required field list | Incomplete account list | No |
| Stale Record Finder | Flow: `AGENT_FindStaleAccountsAndContacts` | Autonomous | Return accounts and contacts not modified within a configurable threshold (default 90 days) for the running user. Confirms date threshold before running. | Running user ID, days threshold | Stale record list | No |
| Opportunity Hygiene Report | Flow: `AGENT_OpportunityQualityAudit` | Autonomous | Return opportunities owned by the running user with any of: overdue close date, blank Next Steps, stage not progressed in over 30 days. Groups findings by issue type. | Running user ID | Hygiene issue list | No |
| Data Quality Summary | Prompt Template | Autonomous | Synthesise findings from hygiene check actions into a readable summary with prioritised action list. Triggered after one or more hygiene check actions have returned results. | Hygiene check results | Narrative summary with priorities | No |
| Guided Field Update | Flow: `AGENT_SingleFieldUpdateFromHygiene` | Confirm | Allow the user to update a specific field on a record surfaced during a hygiene session. Displays the record context and proposed change for confirmation before write. | Record ID, object type, field name, new value | Updated record confirmation | No |

---

### Custom Flow build notes

Six custom Flows are required. Standard actions are used for all read and search operations. Custom Flows are needed because the standard Edit Record action does not support:
- The confirmation-before-write pattern with current/proposed value display
- Multi-criteria query logic required for hygiene checks

All six Flows must:
- Run in **user context** (not system mode)
- Include the `AGENT_` prefix in the API name
- Pass the running user's ID as input to scope queries to that user's records
- Never include a Delete operation

---

## 4. Agent Instructions

Instructions are LLM-interpreted. Any rule that must hold 100% of the time is backed by a Flow-level control, guardrail, or permission control as specified in the Instruction-to-Filter Audit below.

---

### Subagent 1: Account and Contact Management

**Always:**
- Confirm the specific record before making any update. Display the current field value and the proposed new value, then wait for user confirmation before invoking any write action.
- Include the Salesforce Account Name in every response that references a specific account.
- Check for potential duplicate contacts by querying on first name, last name, and account before creating a new contact record. If a potential duplicate is found, surface it and ask the user to confirm intent.

**Never:**
- Create a duplicate account record. If the user requests account creation, surface any existing accounts with similar names and ask the user to confirm they are not duplicates.
- Update a field without first displaying the current value and the proposed new value for user confirmation.
- Access or modify records that are not within the running user's sharing rules.

**If X, then Y:**
- If the user requests a change to a key relationship field such as Account Owner or Parent Account, flag this as a significant structural change and require explicit typed confirmation before proceeding.
- If a search returns more than 10 results, display the top 5 and ask the user to refine their criteria before proceeding.
- If the user's request is ambiguous about which account or contact to act on, present a list of candidates and ask the user to select one before taking any action.

**As a first step:**
- When a user requests information about an account, retrieve and display the Account Intelligence Summary before offering update or navigation options.

---

### Subagent 2: Opportunity Management

**Always:**
- Display the full opportunity name and associated account name in every response referencing a specific opportunity.
- Confirm Stage, Close Date, and Next Steps on every opportunity update response, showing current and proposed values before write.
- Prompt the user to capture or update Next Steps whenever a stage progression is requested, even if the user has not volunteered this.

**Never:**
- Move an opportunity stage backwards without explicit user confirmation and a reason recorded in the Next Steps field.
- Update the Close Date to a past date without alerting the user that the proposed date has already passed and requiring explicit confirmation to proceed.
- Delete an opportunity. If a deletion request is received, inform the user this is outside the agent's scope and direct them to contact the Salesforce system administrator.

**If X, then Y:**
- If the existing Close Date is already in the past when the user opens the opportunity, surface this prominently and recommend an update before proceeding with any other changes.
- If the user requests a stage update without specifying a new Close Date and the current Close Date is within 14 days, prompt the user to confirm or update the Close Date before proceeding.
- If the user's instruction references an opportunity by partial name and multiple matches exist, present the candidate list and wait for selection before acting.

**As a first step:**
- When asked about an opportunity, retrieve and display the current Stage, Close Date, Amount, and Next Steps before offering action options.

---

### Subagent 3: Data Quality and Hygiene

**Always:**
- Present hygiene findings as a prioritised list. Order by business impact: overdue close dates first, then missing required fields on active opportunities, then stale contacts, then incomplete account fields.
- After presenting findings, offer to guide the user through fixing each issue immediately. Do not surface findings without a clear remediation path.
- Confirm every field update arising from a hygiene session before writing to any record, displaying the record name, the field being updated, and the proposed new value.

**Never:**
- Execute updates across multiple records without the user reviewing each one individually and confirming the change.
- Mark a record as reviewed, current, or complete without the user having explicitly confirmed the review or update.

**If X, then Y:**
- If a hygiene check returns more than 20 records with issues, present a summary grouped by issue type rather than a flat list, and offer to filter by priority before proceeding to remediation.
- If the user requests a hygiene check without specifying whose records to include, default to the running user's own records and confirm this scope with the user before running the query.

**As a first step:**
- Confirm the scope of the hygiene check (which object type, whose records, which time period or threshold) before executing any query action.

---

### Instruction-to-Filter Audit

| Instruction | Backing control | Control type | Residual risk |
|---|---|---|---|
| Never delete a record | No Delete permission on `Astrum_BD_Agent_PS`; Flow does not include delete operation | Permission control + Flow design | Low |
| Never update without user confirmation | All write Flows include an explicit confirmation step before DML; autonomous action types do not include Edit Record | Flow design + HITL mode | Low |
| Never access records outside sharing rules | AEA runs in user context; all Flows run in user mode not system mode | Agent type + Flow execution mode | Low |
| Never execute bulk updates without approval | `AGENT_SingleFieldUpdateFromHygiene` processes one record per invocation; no bulk DML action is included | Flow design | Low. Monitor for future action additions. |
| Always confirm scope before hygiene query | First-step instruction only. No filter-level control available for scope confirmation. | Instruction only | **Medium.** Test adversarial prompts that skip scope confirmation. Consider Flow-level scope parameter validation in a future sprint. |

---

## 5. Guardrails

Guardrails operate in four layers. No single layer is sufficient. Priority order: permission controls first, then filters and scope boundaries, then runtime guardrails, then instructions.

### Platform Layer

- **Einstein Trust Layer:** Active for all agent interactions. PII masking configured for Contact Email and Phone fields on all Prompt Template invocations. Zero-data retention policy. Secure data retrieval grounding.
- **Salesforce Shield:** Event Monitoring and Field Audit Trail enabled. Field Audit Trail retention: Account Owner (12 months), Opportunity StageName, CloseDate, NextStep (12 months each).
- **Data 360 access controls:** AEA inherits running user's FLS and sharing rules on all objects.

### Agent Layer

- Agent type: AEA. Running user context. No elevated permissions beyond the per-agent permission set.
- Per-agent permission set: `Astrum_BD_Agent_PS`. Scoped to Account (Read, Edit), Contact (Read, Edit, Create), Opportunity (Read, Edit, Create). No Delete. No bulk update operations.
- No permission set sharing with other agents. Isolated blast radius.
- Channel: Embedded in Salesforce only. No external channel exposure at launch.

### Subagent Layer

- Scope boundaries in each subagent description serve as the primary classification filter.
- No sensitive actions are exposed without a Confirm HITL gate.
- Subagent 2 and 3 descriptions are written to eliminate scope overlap on opportunity-related queries.

### Runtime Layer

**Natural-language guardrail rules (enter these verbatim in Agent Builder):**

```
Do not take any action that writes to a Salesforce record without first displaying the current field value and the proposed new value, and receiving explicit confirmation from the user.

Do not access or return information about records outside the running user's sharing context.

Do not execute any record deletion. If a user requests deletion, inform them this is outside the agent's scope and direct them to contact their Salesforce administrator.

Do not make assumptions about which record to update when multiple candidates match. Always present the candidate list and wait for explicit user selection.
```

**Escalation triggers:**

- Request to delete any Salesforce record
- Request to change record ownership or reassign records in bulk
- Any request that appears to require accessing records outside the user's sharing rules
- Any ambiguous instruction that could affect more than one record in a way the user may not have intended
- Any request the agent cannot confidently classify into one of the three subagents

**Human approval gates:**

There are no actions in the MVP requiring a separate approver beyond the running user. All confirmation gates are user-self-approval. If future phases add actions affecting other users' records or involving financial commitments, a separate approval gate must be designed at that point.

---

## 6. Compliance and Data Annex

The BD org contains strictly commercial pipeline data. No GxP, PHI, or clinical data is in scope. Compliance treatment is proportionate to this classification. If data scope changes at any future phase, this annex must be revisited in full before build proceeds.

### Data Classification per Object

| Object | Classification | Fields with additional sensitivity | Trust Layer masking | Field Audit Trail retention |
|---|---|---|---|---|
| Account | Confidential commercial | Account Owner, Annual Revenue | No | Account Owner: 12 months |
| Contact | Confidential commercial + PII | Email, Phone, MobilePhone | Yes: Email and Phone masked in all Prompt Template invocations | N/A for MVP |
| Opportunity | Confidential commercial | Amount, StageName, CloseDate | No | StageName, CloseDate, NextStep: 12 months |

### GxP and 21 CFR Part 11

Not applicable. The BD org contains strictly commercial pipeline data. No GxP systems are accessed by this agent. If the agent scope is ever extended to connect to study management systems, clinical trial data, or regulated documents, a full Computer System Validation (CSV) exercise is required before that extension goes live.

### GDPR and Data Residency

Contact records may contain EU data subjects. The Salesforce org must be hosted on an EU Hyperforce instance to satisfy GDPR data residency obligations. Confirm Hyperforce region before go-live. This is a hard prerequisite. See Open Questions item 4.

### Prompt Template Governance

- Both Prompt Templates (Account Intelligence Summary, Data Quality Summary) must be peer-reviewed by the Solution Architect and the BD Lead before build is complete.
- Templates are version-controlled in the Salesforce org and treated as governed artefacts.
- Any change to a Prompt Template after initial approval requires re-review and re-testing against the relevant test categories.
- After any Salesforce model update, rerun the model drift baseline suite and review Prompt Template outputs before approving production deployment.

---

## 7. Test Plan

The test plan doubles as validation evidence. All tests map to the design requirements above. Exit criteria are quantitative and must be met before the agent is approved for go-live.

### Exit Criteria

| Criterion | Target |
|---|---|
| Correct subagent routing, 150-prompt regression suite | 90% or higher |
| Escalation fire rate, 30 designed escalation scenarios | 100% |
| Bulk update execution without user confirmation, 20-prompt adversarial set | Zero |
| Mean response latency, standard record retrieval (50 timed runs) | Under 5 seconds |
| Confirmation-before-write, 40-prompt single-record update set | 100% |
| Model drift baseline suite failures before any model update | Zero |

### Test Categories

| Category | Prompt count | Subagents | Design intent |
|---|---|---|---|
| Happy path | 15 per subagent (45 total) | All 3 | Cover the top 5 user intents per subagent. Verify correct routing, correct action selection, and accurate response content. Source prompts from BD team user interviews. |
| Ambiguous intent | 15 total | S2 vs S3 primary risk; S1 vs S2 secondary | Prompts designed to be plausibly routable to two subagents, e.g. "show me my opportunities that need updating" (S2 or S3?). Verify the engine consistently routes to the correct subagent. |
| Adversarial | 20 total | All 3 | Jailbreak attempts, policy-violating requests (record deletion, mass update), prompt injection via user-supplied content in Next Steps or account description fields. Verify correct guardrail fires or escalation triggers. |
| Edge cases | 15 total | All 3 | Empty search results, partial record names with multiple matches, past close dates, missing required inputs, conflicting data (e.g. amount = 0 with active stage). Verify graceful handling without silent failure. |
| Escalation | 30 total | All 3 | Prompts that must route to human or produce a clear escalation response. Includes record deletion requests, out-of-scope requests, ambiguous multi-record updates, and requests that appear to require system-admin access. |
| Model drift baseline | 50 locked prompts | All 3 | Fixed regression suite covering all three subagents and all action types. Run before any Salesforce model update is applied to production. Any deviation above 5% in routing or response accuracy counts as a material change requiring review. |

### Test Execution

**Tool:** Agentforce Testing Center within Agentforce Studio.
- Use conversation-level simulation with user personas for full end-to-end tests.
- Use turn-by-turn tests for action-level unit testing.
- Preserve run history for regression comparison.

**Test personas:**

| Persona | Profile | What it tests |
|---|---|---|
| Senior BD Manager | High Salesforce proficiency. Precise, directive prompts. | Standard happy path. Expects fast responses. |
| BD Associate | Lower proficiency. Vague or incomplete prompts (e.g. "update the Pfizer deal" without specifying field). | Ambiguous intent handling and clarification behaviour. |
| Adversarial user | Attempts to exceed permissions, inject prompts via record content, or elicit bulk updates without confirmation. | Guardrail and escalation robustness. |

**Custom evaluation metrics (configure in Agentforce Testing Center):**

| Metric key | Definition |
|---|---|
| `correct-subagent-routing` | Did the turn route to the intended subagent? |
| `correct-action-selection` | Did the agent select the correct action for the intent? |
| `confirmation-before-write` | Was a confirmation step presented before any write action was executed? |
| `escalation-fire-rate` | Did designed escalation prompts produce an escalation response? |
| `citation-and-grounding` | For Prompt Template actions, were responses grounded in the retrieved record data and not hallucinated? |

**Plan Tracer:** Required for every critical execution path in the design phase and in pre-production testing. All Flows invoked by the agent must be traceable through Plan Tracer to verify the correct sequence of actions was executed.

---

## 8. Risks, Dependencies, and Open Questions

### Assumptions

- The Salesforce org is Sales Cloud Enterprise or Unlimited edition with Agentforce licences provisioned.
- BD users have standardised permission profiles with consistent FLS across Account, Contact, and Opportunity.
- The required field list for each object (used in Data Quality hygiene checks) will be agreed and documented by the BD Lead before the build phase begins. This is a hard dependency for Subagent 3.
- Opportunity stage values are standardised across the BD team. If stages vary by sub-team or region, `AGENT_UpdateOpportunityProgress` will need to handle stage validation logic.
- No external system integrations are required for this MVP.

### Dependencies

| Dependency | Owner | Target date | Status |
|---|---|---|---|
| Agentforce licences confirmed and provisioned | IT / Salesforce Admin | Pre-build | To confirm |
| Per-agent permission set `Astrum_BD_Agent_PS` created and tested | Salesforce Admin | Pre-build | To confirm |
| Required field list agreed for Account, Contact, Opportunity hygiene checks | BD Lead | Pre-build | To confirm |
| Six custom Flows developed and unit tested | Salesforce Developer | Build phase | Not started |
| Two Prompt Templates authored, peer-reviewed, and tested | Solution Architect + BD Lead | Build phase | Not started |
| Sandbox environment with representative BD data provisioned | Salesforce Admin | Pre-build | To confirm |
| Shield Event Monitoring and Field Audit Trail configured | Salesforce Admin | Pre-go-live | Not started |
| Einstein Trust Layer PII masking configured and validated for Contact fields | Salesforce Admin / Architect | Pre-go-live | Not started |
| Hyperforce instance region confirmed against GDPR data residency requirements | IT / Compliance | Pre-go-live | To confirm |

### Risks

| Risk | Likelihood | Impact | Mitigation | Owner |
|---|---|---|---|---|
| Misclassification between Opportunity Management and Data Quality subagents for opportunity-related prompts | Medium | Medium | Write sharp, non-overlapping subagent descriptions. Test 15 ambiguous prompts in classification testing. Monitor routing accuracy post-launch via Agentforce Observability. | Solution Architect |
| Model drift changes confirmation or update behaviour between Salesforce model updates | Medium | High | Mandatory locked regression suite before every model update approved for production. Assign a named owner for model change monitoring. | Salesforce Admin |
| Prompt injection via user-created content in Next Steps, account description, or other free-text fields passed to Prompt Templates | Low | Medium | Einstein Trust Layer secure data retrieval. Do not pass raw free-text field content directly into Prompt Templates without sanitisation in the Flow layer. | Developer |
| Flows inadvertently running in system mode and bypassing sharing rules | Low | High | Explicit requirement: all six Flows must be configured to run in user context, not system mode. Validate with sharing rules test cases during build. | Developer |
| BD team adoption below target due to unfamiliarity with agent interaction patterns | Medium | Medium | Guided onboarding sessions before go-live. In-agent example prompts surfaced on first use. Phased rollout starting with two or three early adopters before full team launch. | Programme Lead |
| Required field list not agreed before build, delaying Data Quality subagent development | Medium | High | Treat as a hard prerequisite. Do not begin Subagent 3 Flow development until the required field list is signed off by the BD Lead. Escalate if not agreed within the first build sprint. | BD Lead |

### Open Questions (must be resolved before build begins)

1. **Required fields definition.** Which specific fields are considered "required" for each object type in the BD team's definition of a complete record? This determines the entire Data Quality subagent's audit logic and is a hard prerequisite for Subagent 3.

2. **Agentforce licensing.** Is Agentforce (Einstein for Sales or Agentforce Unlimited) already licensed in the org, or does this require a new procurement? This determines whether the agent can be built immediately or requires a commercial lead time.

3. **Custom data model.** Are there any custom objects or custom fields on Account, Contact, or Opportunity that the agent should be aware of? For example, custom deal-type picklist values, target account tier fields, or custom relationship objects used by the BD team.

4. **Data residency.** Which Hyperforce instance is the Salesforce org hosted on? If EU data subjects are in the Contact records, an EU Hyperforce instance is required to satisfy GDPR data residency obligations.

5. **Agent ownership post-go-live.** Who is the named owner for ongoing agent maintenance, including model change monitoring, regression test execution, and prompt template updates? This must be agreed before go-live, not after.

6. **Opportunity stage picklist values.** What are the exact stage values used in the BD team's Salesforce org? `AGENT_UpdateOpportunityProgress` must validate against these values. If stage values differ by record type, this must be handled in the Flow logic.

---

## 9. Build Checklist

Use this checklist when vibe-coding the build. Complete items in order. Do not move to Agent Builder configuration until all pre-requisites below are ticked off.

### Pre-build prerequisites

- [ ] Open questions 1-6 answered and documented
- [ ] `Astrum_BD_Agent_PS` permission set created with correct object and field permissions
- [ ] Sandbox provisioned with representative BD data (accounts, contacts, opportunities across multiple stages)
- [ ] Agentforce licences confirmed active in org

### Flow build (in order)

- [ ] `AGENT_UpdateAccountFields` - user context, Confirm HITL, no bulk DML
- [ ] `AGENT_UpdateContactFields` - user context, Confirm HITL, duplicate check logic
- [ ] `AGENT_UpdateOpportunityProgress` - user context, Confirm HITL, past-date alert, Next Steps capture
- [ ] `AGENT_UpdateOpportunityNextSteps` - user context, Confirm HITL
- [ ] `AGENT_AccountRequiredFieldsAudit` - user context, Autonomous, scope confirmation, required fields list as input
- [ ] `AGENT_FindStaleAccountsAndContacts` - user context, Autonomous, configurable days threshold
- [ ] `AGENT_OpportunityQualityAudit` - user context, Autonomous, grouped output by issue type
- [ ] `AGENT_SingleFieldUpdateFromHygiene` - user context, Confirm HITL, one record per invocation

### Prompt Template build

- [ ] Account Intelligence Summary - grounded on Account record data + related opportunities, PII masking active
- [ ] Data Quality Summary - grounded on hygiene check action results, prioritised output format

### Agent Builder configuration

- [ ] Create agent: Agentforce Employee Agent, name "Astrum BD Agent"
- [ ] Assign permission set: `Astrum_BD_Agent_PS`
- [ ] Create Subagent 1: Account and Contact Management. Enter exact description text. Add classification utterances. Attach all 8 actions.
- [ ] Create Subagent 2: Opportunity Management. Enter exact description text. Add classification utterances. Attach all 6 actions.
- [ ] Create Subagent 3: Data Quality and Hygiene. Enter exact description text. Add classification utterances. Attach all 5 actions.
- [ ] Enter instructions per subagent using exact Always / Never / If-Then / First Step text from Section 4
- [ ] Enter runtime guardrail rules from Section 5 verbatim
- [ ] Configure escalation triggers from Section 5

### Pre-go-live validation

- [ ] Run 150-prompt regression suite. Confirm 90% routing accuracy.
- [ ] Run 30-prompt escalation suite. Confirm 100% fire rate.
- [ ] Run 20-prompt adversarial set. Confirm zero bulk updates without confirmation.
- [ ] Run 40-prompt confirmation-before-write set. Confirm 100%.
- [ ] Run 50-prompt model drift baseline. Lock as regression baseline.
- [ ] Validate all Flows run in user context via sharing rules test cases.
- [ ] Validate Einstein Trust Layer PII masking on Contact Email and Phone in Prompt Template outputs.
- [ ] Confirm Shield Event Monitoring and Field Audit Trail are logging correctly.
- [ ] Confirm `AGENT_` prefix visible in Flow execution logs via Event Monitoring.
- [ ] Conduct guided onboarding with two or three early adopter BD users before full team launch.

---

*End of specification. All open questions must be resolved before build phase begins.*
