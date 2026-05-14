# S2 Agent Builder Human Setup - Opportunity Management

| Field | Value |
|---|---|
| Programme | Astrum Orbit |
| Agent | Astrum BD Agent |
| Subagent | Opportunity Management |
| Date | 2026-05-14 |
| Operator | Codex |
| Target | Sandbox only |

## Why This Is Human-Only

Codex confirmed that `GenAiPlannerBundle`, `Bot`, `AiEvaluationDefinition`, and `GenAiPromptTemplate` metadata are retrievable in the sandbox. However, full Agent Builder configuration for S2 includes standard Get/Search/Create actions, Confirm HITL settings, field pickers, and Prompt Template action bindings that are safer to complete and verify in Agent Builder than to hand-author from an S1-only retrieved planner bundle.

Codex did not force planner bundle edits because an invalid planner bundle could block the wider Astrum BD Agent configuration. The S2 Flows, permission set changes, and Prompt Template are metadata-buildable and remain in Codex scope.

## Prerequisites

- `AGENT_UpdateOpportunityProgress` deployed to sandbox.
- `AGENT_CaptureNextSteps` deployed to sandbox.
- `AGENT_OpportunityStatusSummary` deployed to sandbox as a Draft Prompt Template.
- `Astrum_BD_Agent_PS` updated with Opportunity Create/Edit, no Delete, S2 FLS, and S2 Flow access.
- `Opportunity_ID_18__c` is not present in sandbox. Do not configure S2 summaries to use record links until that field is deployed to sandbox.

## Topic

Create or update this topic in Agent Builder:

| Field | Value |
|---|---|
| Topic name | Opportunity Management |
| Developer name | Opportunity_Management |
| HITL default | Writes require Confirm |

Description:

```text
Handles requests to look up, search, create, update, and summarise individual Salesforce Opportunity records. Use this topic when the user asks about a specific deal, opportunity stage, close date, forecast category, service fees, probability, next step, next specific action, or opportunity status summary.

Do not use this topic for account or contact management, cross-pipeline hygiene reports, bulk Opportunity updates, deletion requests, pipeline forecasting views, or external-channel actions. This topic acts on one Opportunity record at a time and every write action must require user confirmation before saving.
```

## Topic Instructions

Paste these instructions:

```text
Always retrieve and display the current Opportunity record before proposing an update.

Always confirm the exact Opportunity identity before writing. If the user's request matches more than one Opportunity, present a candidate list and wait for the user to select one.

Never update more than one Opportunity in a single action. If the user asks for a bulk update, explain that the agent can update one Opportunity at a time with confirmation.

Never delete an Opportunity. If the user asks to delete a deal, explain that deletion is outside scope and must be handled by a Salesforce administrator.

Never use standard Probability or Probability__c. Use only Opp_Probability__c when discussing probability.

Never pass D365_Opportunity_Notes__c, Description, migration notes, or raw long text fields into a Prompt Template.

For stage or close-date changes, use Update Opportunity Progress and require Confirm HITL before saving.

If the proposed close date is in the past and the Flow returns CloseDateIsPast = true, warn the user that the proposed close date has already passed and require explicit confirmation before proceeding.

For next-step-only changes, use Capture Next Steps and require Confirm HITL before saving.

When stage is progressed, ask for next step information if the user has not provided it.

When the user asks for a pipeline hygiene report, overdue deal list, missing data report, or cross-record quality check, route or redirect to Data Quality and Hygiene.

When the user asks for account or contact details, route or redirect to Account and Contact Management.

When generating an Opportunity Status Summary, use only retrieved Salesforce Opportunity and related Account data. Omit blank fields instead of saying unknown.
```

## Positive Classification Examples

Add these examples:

```text
Show me the details for the Roche Phase I opportunity.
Which Roche deals are we working on?
Move the MSD deal to Proposal Sent.
Update the close date on the AZ Full Service opportunity to 31 August 2026.
Add a next step to the BioNTech deal: send revised protocol by end of this week.
Create a new opportunity for Pfizer. Phase II full service. Close end of year.
Summarise the current status of the Eli Lilly opportunity.
What stage is the Sanofi bioanalytical deal at?
Mark the Roche Phase I deal: next action is bid defence prep, due 15 May, responsible John Smith.
What is the probability of winning the Roche deal?
```

## Negative Classification Examples

Add these examples:

```text
Show me the key contacts at Novartis. -> Account and Contact Management
Update Sarah Chen's job title. -> Account and Contact Management
Run a data quality check on my pipeline. -> Data Quality and Hygiene
Which of my opportunities have overdue close dates? -> Data Quality and Hygiene
Delete the Roche opportunity. -> Refuse / admin escalation
Update all my opportunities at Proposal Sent to Bid Defense. -> Refuse bulk update
Create a new account for BioArk Pharma. -> Account creation is out of scope
Send an email to all contacts on this opportunity. -> Out of scope
Build a pipeline forecast report. -> Out of scope
Show me raw D365 migration notes for this deal. -> Out of scope
```

## Actions

### 1. Get Opportunity Details

| Field | Value |
|---|---|
| Action type | Standard Get Record or metadata-supported equivalent |
| Object | Opportunity |
| HITL | Autonomous |
| Use when | User asks for details, stage, close date, value, probability, next step, or status of a specific Opportunity |

Fields to include:

```text
Name
Account.Name
StageName
CloseDate
ForecastCategoryName
Amount
Service_Fees__c
Opp_Probability__c
Business_Category__c
Therapeutic_Area__c
Study_Phase_Type__c
NextStep
Next_specific_action__c
Date_of_next_specific_action__c
Person_responsible_for_next_action__c
Last_client_interaction_date__c
Opportunity_Code__c
Award_Date__c
Business_Type__c
```

Do not include:

```text
Probability
Probability__c
D365_Opportunity_Notes__c
Description
Opportunity_ID_18__c until deployed to sandbox
```

### 2. Search Opportunities

| Field | Value |
|---|---|
| Action type | Standard Query Records or metadata-supported equivalent |
| Object | Opportunity |
| HITL | Autonomous |
| Limit | 10 results |

Search by:

```text
Name
Account.Name
StageName
Owner.Name
Opportunity_Code__c
```

Return:

```text
Name
Account.Name
StageName
CloseDate
Opp_Probability__c
Opportunity_Code__c
Owner.Name
```

### 3. Create Opportunity

| Field | Value |
|---|---|
| Action type | Standard Create Record |
| Object | Opportunity |
| HITL | Confirm |

Mandatory-field validation required in UI:

```text
AccountId
Name
CloseDate
StageName
ForecastCategoryName
Business_Category__c
Entities_Providing_Services__c
Project_Category__c
Project_Start_Work__c
Project_End_Work__c
RfP_Received_Date__c
RfP_Due_Sent_Date__c
Study_Phase_Type__c
Therapeutic_Area__c
```

If Agent Builder cannot reliably prompt for all mandatory fields before Confirm HITL, stop and create a follow-up design item for `AGENT_CreateOpportunity`. Do not create incomplete Opportunity records.

### 4. Update Opportunity Progress

| Field | Value |
|---|---|
| Action type | Invocable Action / Flow |
| Flow | `AGENT_UpdateOpportunityProgress` |
| HITL | Confirm |

Inputs:

```text
OpportunityId
NewStageName
NewCloseDate
NewNextStep
NewNextSpecificAction
NewDateOfNextAction
NewPersonResponsible
```

Outputs to display:

```text
CurrentStageName
CurrentCloseDate
CurrentNextStep
CloseDateIsPast
UpdatedOpportunityName
Success
ErrorMessage
```

### 5. Capture Next Steps

| Field | Value |
|---|---|
| Action type | Invocable Action / Flow |
| Flow | `AGENT_CaptureNextSteps` |
| HITL | Confirm |

Inputs:

```text
OpportunityId
NewNextStep
NewNextSpecificAction
NewDateOfNextAction
NewPersonResponsible
```

Outputs to display:

```text
CurrentNextStep
CurrentNextSpecificAction
UpdatedOpportunityName
Success
ErrorMessage
```

### 6. Opportunity Status Summary

| Field | Value |
|---|---|
| Action type | Prompt Template |
| Template | `AGENT_OpportunityStatusSummary` |
| HITL | Autonomous |

Only invoke after the Opportunity record has been retrieved.

## Testing Center Checks

Run the S2 prompt set from `validation/S2-opportunity-management-validation-20260514.md` after metadata deployment and topic setup.

## Business Summary

- **What was done:** Prepared the Human-only Agent Builder setup instructions for S2 Opportunity Management.
- **What was found:** Metadata support exists for Agentforce assets, but full S2 topic/action setup includes UI-specific standard actions and HITL settings that should be completed in Agent Builder.
- **What this means:** Codex can deliver the deployable metadata foundation while Human completes final Agent Builder wiring safely in sandbox.
- **What is next:** Human configures the S2 topic and actions after Codex deploy/validation evidence is ready.
- **Decision needed from Human:** Confirm whether standard Create Opportunity can capture all mandatory fields before UAT sign-off.
