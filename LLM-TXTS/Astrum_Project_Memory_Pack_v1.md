
ASTRUM ORBIT PROGRAMME
Project Memory Pack
Standing context for all future delivery recommendations
Version 1.0  |  April 2026  |  Confidential Commercial

SCHEMA AUTHORITY: All future recommendations must be validated against Astrum__Objects_Fields_1.xlsx before being proposed. Any field, object, trigger condition, personalisation attribute, segmentation criterion, notification payload, or agent action that cannot be confirmed in that file must be explicitly labelled NET-NEW REQUIRED.

 
1.  Programme Objective

The Astrum Orbit programme is delivering a controlled AI-assisted commercial operating model for AstrumCRO using Salesforce Sales Cloud, Agentforce, Marketing Cloud on Core, and Data Cloud. The programme is migrating from Microsoft Dynamics and establishing a governed, data-quality-driven pipeline management and engagement capability for the Business Development team.

Core commercial goals this programme must deliver:
•	Speed to first meeting: reduce time from lead creation to Meeting Done status.
•	Pipeline data completeness: 10% improvement in required field population within 90 days of agent go-live.
•	Pipeline visibility: reliable, timely email alerts on material deal movements and close events.
•	Seller productivity: reduce BD time on CRM administration via AI-assisted agent actions.
•	Governed lead nurture at scale: Marketing Cloud outreach without duplicating BD effort or sending to suppressed individuals.
•	Campaign attribution: measure which campaigns generated which Opportunities via Opportunity.CampaignId.
•	Forecast accuracy: improve reliability of Opp_Probability__c and ForecastCategoryName as planning inputs.

The programme operates in a regulated, compliance-sensitive B2B CRO environment. Trust, timing, and relevance matter more than volume. Data quality is a commercial dependency. GDPR consent and suppression controls are non-negotiable.
 
2.  Current Delivery Focus

Five parallel workstreams are in active delivery as of April 2026:

NOTE	AGENTFORCE: Astrum BD Agent (Employee Agent). Three subagents: Subagent 1 Account/Contact Management (build-ready), Subagent 2 Opportunity Management (build-ready), Subagent 3 Data Quality and Hygiene (blocked on required field sign-off). Design Brief v0.1 and S1 Config v0.1 are primary build artefacts.
NOTE	SALES CLOUD: Configuration of Lead model, Account model, Opportunity model based on Dynamics migration. 11 decisions from Jan 2026 requirements meeting; 5 remain Open (D2-D5, D11 follow-on). 14 Opportunity email notifications specified and awaiting build.
NOTE	MARKETING CLOUD: Top-of-funnel Lead nurture journeys and re-engagement journeys. Email is the confirmed Phase 1 channel. SMS and WhatsApp are referenced in capability diagram but NOT confirmed for Phase 1 — do not design until channel, consent, and content are confirmed.
NOTE	DATA CLOUD: Identity resolution, Consent DMO, and audience activation to Marketing Cloud. IndividualId population status in the live org is unconfirmed and is the single highest-priority compliance risk.
NOTE	EMAIL NOTIFICATIONS: 14 Opportunity pipeline notifications specified. Build order priority: notifications 2, 9, 10 first (cleanest trigger logic), then 4, 11, 12, 13; digest and historical-change notifications (3, 5, 6, 7, 8) require custom log object or helper fields before build.
DELIVERED	SAL-2 (Notification 2 — Critical Stage Progression): COMPLETE — production active since 25 Apr 2026 (Linear Done, smoke test PASS). Flow `Notify_Critical_Stage_Progression_After_Save` v2 (ID `301TY00000rVQPaYAO`) active in astrum-prod.
DELIVERED	SAL-9 (Notification 9 — Closed Won): COMPLETE — production active since 27 Apr 2026 (PRE-07 PASS, Linear Done). Flow `Notify_Closed_Won_After_Save` (ID `301TY00000rYVAxYAO`) active in astrum-prod. Deploy ID `0AfTY000003kpyf0AA`.

Out of scope until explicitly confirmed:
•	External-facing Agentforce channels (web chat, email bot, LinkedIn)
•	SMS and WhatsApp Marketing Cloud journeys
•	Sales Coach (no specification exists; no call transcript data source in CRM)
•	Automated meeting booking with calendar integration
•	Automated proposals or AI-led negotiation
•	ERP integration (Phase 2)
•	Multi-language content delivery (no Preferred_Language__c field exists)
•	GlobalData or LinkedIn enrichment (Phase 1 integrations referenced but not specified)
 
3.  Platform Responsibilities

Agentforce	Internal BD productivity tool only. Employee Agent embedded in Salesforce. Manages Account, Contact, and Opportunity records for authenticated BD users. Generates AI-grounded summaries. Data quality audits. No external channel. No outreach. No proposals. No meeting booking via external calendar.

Marketing Cloud on Core	Outreach orchestration layer. Governs all email sends to Leads and Contacts at scale. Enforces suppression and consent gates. Delivers journey-based nurture sequences. Prevents overlap with BD Sales Engagement cadences. Email only in Phase 1.

Data Cloud	Identity resolution backbone. Unifies Lead and Contact records on Email. Enforces consent via Consent DMO (requires IndividualId population). Activates Marketing Cloud audiences. Phase 1 scope: ingest, unify, govern, activate. No propensity scoring, external data enrichment, or Agentforce grounding from unified profiles in Phase 1.

Sales Cloud	System of record for the commercial pipeline. Hosts the BD Agent. Executes all 14 Opportunity notification Flows. Enforces Lead conversion governance, Project Code generation, Duplicate Management, Field Audit Trail. Clean Sales Cloud data is the prerequisite for every other platform to function correctly.

Sales Coach	Not yet designed. Referenced in capability diagram only. Requires call transcript data source, conversation intelligence integration, and manager operating model before any specification can begin. Treat as Phase 2 planning item only.
 
4.  Canonical Object Model Summary

Four objects are in scope. Source of truth: Astrum__Objects_Fields_1.xlsx. All field references must use API names from this file.

Object	Total Fields	Custom Fields	Mandatory Fields (API Names)
Account	42	16	Name
Contact	50	7	LastName
Opportunity	146	108	AccountId, Name, CloseDate, StageName, ForecastCategoryName, Business_Category__c, Entities_Providing_Services__c, Project_Category__c, Project_Start_Work__c, Project_End_Work__c, RfP_Received_Date__c, RfP_Due_Sent_Date__c, Study_Phase_Type__c, Therapeutic_Area__c
Lead	51	15	Company, LastName, Status

Key confirmed picklist values to use exactly:
•	Opportunity StageName (13 canonical values): Pre-Identification, Early Engagement, RFI in progress, RFI sent, Proposal On Hold, Proposal In Progress, Proposal Sent, Bid Defense, Verbal Award, Change Order, Contract Agreed, Closed Won, Closed Lost. NOTE: Org has 19 active stage values confirmed via SOQL 26 Apr 2026. Additional active stage includes `Lost/Cancelled/Declined to Bid`. BD-01 required to determine whether this stage triggers SAL-10.
•	Opp_Probability__c: 0, 5, 10, 25, 50, 75, 90, 100  [Custom picklist — this is the authoritative probability field, not standard Probability]
•	ForecastCategoryName: Omitted, Pipeline, Best Case, Commit, Closed
•	Business_Category__c (6 active values confirmed via SOQL 26 Apr 2026): Phase I Unit, Phase I-NIS, S&PS, All Other Projects (Phase I - NIS), Phase I Clinical Conduct Portugal, Site & Patient Services (CRP & MissionTEC). Only Phase I Unit and Phase I-NIS have confirmed recipient matrices. S&PS and the remaining 3 values are blocked on BD-02/BD-03/BD-05. Do not assume the prior 3-value list is complete.
•	Business_Type__c: Change Order, New Business
•	Loss_Reason__c: Astrum Capabilities, Cancelled, Cost, Declined to Bid, Geographical Coverage, Lost to Follow-up, Lost to Incumbent, Project Team Experience, Therapeutic Experience
•	Lead Status: New, Prospect, Outreach Done, Meeting Done, RfP Expected, Qualified, Disqualified
•	Lead_Source__c (custom, authoritative): Astrum Event, BD Outreach, Conference Event, Employee Referral, Existing Client, External Event, External Referral, Google AdWords, Inbound Lead, Marketing Campaign, Other, Personal Connection, Prospecting, Referral, Referral (from existing client), Webinar
•	Account Client_Type__c: Biotech, Consultant, Generics/Biosimilars, MedTech/Medical Devices, Nutraceuticals/Cosmetics, Other CRO, Other Vendor, Pharma, Academic
•	Account_Segment__c: Strategic Account, Standard Account, Key Account

Opportunity validation rule required fields (confirmed via org 25–26 Apr 2026 — not in original schema capture):
•	STAGE_Closed_Won (ID 03dUD000000TMbRYAW) — enforces these 12 fields non-blank on Closed Won saves: Description, Reason_for_win__c, Indication__c, Number_of_Enrolled_Participants__c, Study_Countries__c, Number_of_Sites__c, Entities_Providing_Services__c, Protocol_Title__c, Contract_Sign_Date__c, Contract_Type__c, Payment_Schedule_Type__c, Contract_Entity__c
•	STAGE_Closed_Lost — enforces non-blank on Closed Lost saves: Loss_Reason__c, Loss_Reason_Date__c (Date field — not in original schema capture), Description
•	Contract_Type__c confirmed active picklist values: Change Order, Clinical Services Agreement, Invoice Only, Letter of Agreement, Out of Scope, Proposal Acceptance Form, Start Work Authorisation, Statement of Work/Work Order
 
5.  Canonical Field Dependency Summary

Consent and Suppression Gates (hard gates across ALL platforms)
NEVER	Lead.HasOptedOutOfEmail — if true, no email send permitted under any circumstance.
NEVER	Contact.HasOptedOutOfEmail — same rule, same weight.
NEVER	Lead.DoNotCall or Contact.DoNotCall — if true, no call or SMS outreach.
NEVER	Lead.Status = Disqualified — exclude from all outreach and journeys immediately.
ALWAYS	Lead.IndividualId and Contact.IndividualId — must be populated for Data Cloud Consent DMO to function. Verify population status before any Data Cloud activation.
ALWAYS	Lead.ActionCadenceState and Contact.ActionCadenceState — if active cadence running, Marketing Cloud must not send concurrently.

Lead Engagement Eligibility Fields
•	HasOptedOutOfEmail, DoNotCall (hard gates)
•	Status (lifecycle gate — exclude Disqualified)
•	ActionCadenceState (deduplication gate)
•	FirstEmailDateTime, Date_first_outreach_performed__c (recency suppression)
•	IndividualId (consent linkage)
•	Preferred_Method_of_Contact__c: Any, Email, Phone (channel routing)

Personalisation Fields by Object
•	Lead: FirstName, Company, Title, Client_Type__c, Therapeutic_Area__c, Lead_Source__c, Rating
•	Contact: FirstName, LastName, Title, Department, BuyerAttributes, Preferred_Method_of_Contact__c
•	Account (via lookup): Client_Type__c, Account_Segment__c, Tier_Category__c, Therapeutic_Area__c
•	Opportunity (post-conversion): Business_Category__c, Therapeutic_Area__c, Study_Phase_Type__c, StageName

Meeting Booking and Handoff Fields
•	Lead.Status = 'Meeting Done' — primary handoff signal
•	Opportunity.Next_specific_action__c — post-conversion next action
•	Opportunity.Date_of_next_specific_action__c — scheduled date
•	Opportunity.Person_responsible_for_next_action__c — named owner
•	Lead.Date_first_outreach_performed__c — speed-to-first-contact KPI
•	Opportunity.Last_client_interaction_date__c — recency gate
GAPS: Meeting_Booked_Date__c and Meeting_Outcome__c do not exist in schema — both are proposed net-new fields.

Campaign Attribution
•	Opportunity.CampaignId (Primary Campaign Source) — must be stamped at Lead conversion for ROI measurement. This requires a dedicated Flow at conversion point. Without it, campaign attribution cannot be measured.

Coaching Inputs (for future Sales Coach design)
•	StageName, CloseDate, Next_specific_action__c, Date_of_next_specific_action__c, Person_responsible_for_next_action__c, Opp_Probability__c, ForecastCategoryName, Loss_Reason__c, Reason_for_win__c, Service_Fees__c, Weighted_Service_Fees__c, Last_client_interaction_date__c, Discovery_Completed__c, Budget_Confirmed__c, Key_Decision_Criteria__c, Triage_Score__c
•	Lead: Status, Date_first_outreach_performed__c, Rating, Action_Next_Steps__c
GAP: No call transcript or conversation data field exists in the CRM schema. Sales Coach requires a call intelligence integration before any design can proceed.
 
6.  Guardrails for Agentforce Recommendations

NEVER	Recommend Agentforce actions that expose an external channel (web chat, email bot, external API) at Phase 1. The BD Agent is internal-only, embedded in Salesforce, for authenticated BD users.
NEVER	Recommend bulk record updates without per-record Confirm HITL. Zero bulk DML without explicit user review and confirmation of each record.
NEVER	Recommend account creation via the agent. Account creation is a governed admin process only.
NEVER	Recommend opportunity deletion via the agent. Escalate to system admin.
NEVER	Allow Flows to run in system mode. All six agent-invoked Flows must run in user context to respect sharing rules.
NEVER	Pass raw free-text field content (Action_Next_Steps__c, Description, D365 Notes fields) directly to Prompt Templates without sanitisation. Prompt injection risk.
NEVER	Reference standard Probability field in agent logic. Only Opp_Probability__c (custom picklist) is authoritative.
ALWAYS	Apply AGENT_ prefix to all agent-invoked Flows and Prompt Templates for Shield Event Monitoring audit identification.
ALWAYS	Configure PII masking on Contact.Email and Contact.Phone in all Prompt Template invocations via Einstein Trust Layer.
ALWAYS	Require a locked 50-prompt regression baseline suite before any Salesforce model update is approved for production.
ALWAYS	Use Astrum_BD_Agent_PS (dedicated permission set, not shared with any other agent).
ALWAYS	Ground all Prompt Templates in retrieved Salesforce record data only. No hallucination. No external web grounding in Phase 1.
BEFORE BUILD	Agentforce licensing must be confirmed as provisioned. If not, procurement lead time may delay the entire agent timeline.
BEFORE BUILD	Hyperforce EU instance must be confirmed if EU Contact records are in scope (GDPR data residency requirement).
BEFORE BUILD	Subagent 3 (Data Quality) cannot start build until BD Lead formally signs off the required fields list in writing.
BEFORE BUILD	Product Q&A use case (UC-04) requires an approved knowledge base before build. No Salesforce Knowledge object or approved content library is confirmed in the schema. This is a content governance gap, not a schema gap.
 
7.  Guardrails for Marketing Cloud Recommendations

NEVER	Recommend SMS or WhatsApp journeys in Phase 1. These channels are referenced in the capability diagram but channel coverage, consent basis, template approval, and send volume are not confirmed. Do not design until all of these are confirmed.
NEVER	Design a journey entry condition without checking HasOptedOutOfEmail = false, ActionCadenceState not active, and Status not equal to Disqualified.
NEVER	Reference LeadSource (standard field) for journey segmentation. Use Lead_Source__c (custom, 16 values) only. The dual-field ambiguity must be resolved and the standard field hidden before any journey entry criteria are built.
NEVER	Send marketing content that has not been formally approved. Anything not approved is unusable.
NEVER	Allow parallel enrolment of the same Lead in two Marketing Cloud journeys simultaneously without a documented frequency cap and deduplication rule.
ALWAYS	Sender domain authentication must be completed before any send configuration is built. Unauthenticated sends cause permanent deliverability damage.
ALWAYS	CampaignId must be stamped on Opportunity at Lead conversion for any Marketing Cloud journey to generate attributable pipeline. Design the CampaignId write-back Flow as part of journey build, not as an afterthought.
ALWAYS	Journey exits must fire on: HasOptedOutOfEmail = true, Status = Disqualified, and — for post-conversion contacts — StageName advancing to Proposal In Progress or beyond.
ALWAYS	Check Last_client_interaction_date__c on related Opportunity as a recency suppression gate before nurture sends to Contacts on active deals.
BEFORE BUILD	Marketing Cloud send frequency cap (maximum sends per individual per 30 days) must be agreed by business before any journey is built. Absence of a frequency cap risks over-contact and opt-outs.
BEFORE BUILD	Last_MC_Send_Date__c (proposed net-new Date/Time field on Lead and Contact) must be designed and built before deduplication between Marketing Cloud and BD Sales Engagement can be enforced from CRM data.
NOTE	Therapeutic_Area__c has encoding errors (three variants of Gynecology). Do not use this field for personalisation or journey branching until the global value set is cleaned.
 
8.  Guardrails for Data Cloud Recommendations

NEVER	Recommend activating Marketing Cloud audiences from Data Cloud until IndividualId population on Lead and Contact is verified as active in the live Salesforce org. If Individual records are not being created and linked, consent enforcement will fail silently.
NEVER	Recommend Data Cloud segments that use Therapeutic_Area__c or Study_Countries__c until encoding errors and non-standard picklist entries are cleaned. Segments built on dirty data will produce incorrect audience counts.
NEVER	Use LeadSource (standard) as a segmentation attribute. Use Lead_Source__c (custom) only.
NEVER	Recommend propensity scoring, AI-generated segments, or external data enrichment (GlobalData, LinkedIn) in Phase 1. These are deferred. No specification exists for them.
NEVER	Allow Data Cloud identity resolution to default-resolve the Lead-to-Contact pre/post-conversion case. An explicit ruleset matching on Email is mandatory. Without it, the same individual will appear as two unified profiles and receive duplicate sends.
ALWAYS	Design the Consent DMO from day one. IndividualId on Lead and Contact is the linkage field. Confirm it is populated before relying on consent enforcement.
ALWAYS	Use D365_Lead_ID__c, D365_Contact_ID__c, and D365_Account_ID__c as cross-system External ID keys for any records originating from the Dynamics migration.
ALWAYS	Confirm Data Cloud is provisioned on an EU Hyperforce region if EU personal data is processed. Data residency compliance is non-negotiable.
ALWAYS	Ingest ActionCadenceState on Lead and Contact to enforce Sales Engagement deduplication gate in Marketing Cloud journey entry.
BEFORE BUILD	Verify IndividualId population rate in the live org. If zero or near-zero, build a Flow to create Individual records and link IndividualId on Lead/Contact upsert as the first Data Cloud prerequisite task.
NOTE	Data Cloud Agentforce grounding (unified profile data surfaced in Prompt Templates) is a Phase 2 consideration only. Do not include it in Phase 1 Prompt Template design.
 
9.  Guardrails for Sales Cloud Improvement Recommendations

NEVER	Reference standard Probability field in any Flow, validation rule, or report. Only Opp_Probability__c (custom picklist) is authoritative. Standard Probability and Probability__c formula are display-only fields and should be hidden from page layouts.
NEVER	Reference LeadSource (standard) in any configuration output. Use Lead_Source__c (custom) as the sole operational field. Recommend hiding LeadSource from all page layouts.
NEVER	Implement post-close field changes on Opportunity via notification alone. Use validation rules or record locking. A notification after a Closed Won or Closed Lost record has already been changed is insufficient. Preventative controls are required.
NEVER	Allow the BD Agent to create Account records. Account creation is a governed admin process.
ALWAYS	Confirm HasOptedOutOfEmail is mapped from Lead to Contact in the Lead conversion field mapping configuration. Test this as a mandatory UAT scenario.
ALWAYS	Apply Duplicate Management for Accounts (confirmed as active). Duplicate detection for Contacts should be handled programmatically by the AGENT_CreateContact Flow (query by LastName under AccountId and by Email).
ALWAYS	Apply Field Audit Trail on Opportunity.StageName, Opportunity.CloseDate, Opportunity.NextStep, Account.OwnerId with 12-month minimum retention before go-live.
ALWAYS	Use AGENT_ prefix naming convention on all agent-invoked Flows for Shield Event Monitoring audit trail.
BEFORE BUILD	Open decisions D2 (Lead Status Working hidden), D3 (field relocation), D4 (Disqualified rename), D5 (Disqualification Reason values) from January 2026 requirements meeting must all be closed before Lead model configuration is finalised and before any platform that depends on Lead Status logic is built.
BEFORE BUILD	Parent_Opportunity__c lookup field (for Change Order code inheritance) must be confirmed as built or added to the build backlog. It is referenced in confirmed Decision D8 but does not appear in the current schema file.
BEFORE BUILD	Study_Countries__c picklist non-standard entries (free-text descriptions, TBD values, compound country descriptions) must be cleaned before this field is used in notification email payloads or Data Cloud segments.
NOTE	Opportunity_Code__c will be blank for Dynamics-migrated records at go-live. All 14 notifications reference this field. Data backfill for open historical Opportunities is required before notification Flows are activated in production.
 
10.  Guardrails for Email Notification Design

NEVER	Build notification 5 (Service Fees Change), 6 (Close Date Change), or 7 (Probability Change) without first building the Opportunity_Change_Log__c custom object and the prior-value helper fields. Standard Field History is insufficient for Flow-based rolling count and prior-value retrieval.
NEVER	Build Closed Won (notification 9) or Closed Lost (notification 10) without first resolving the recipient matrix gap for Business_Category__c = S&PS. Currently only Phase I Unit and Phase I-NIS have defined recipient rules.
NEVER	Allow any notification to fire more than once for the same qualifying event. All immediate record-triggered notifications must include idempotency logic (entry criterion checks prior field state or uses a sent-flag helper field).
NEVER	Include Study_Countries__c in an email payload until the non-standard picklist entries are cleaned. Emails containing 'Germany and 6 others' or 'TBD' as country values are unprofessional and will undermine trust in the notification system from day one.
ALWAYS	Use Opportunity_Code__c (not Opportunity.Id or Opportunity.Name alone) as the primary deal identifier in all notification emails. This matches the commercial referencing convention.
ALWAYS	Use Opportunity_ID_18__c (formula field, confirmed in schema) to generate Salesforce record links in email bodies.
ALWAYS	Build digest notifications (3, 5, 6, 7, 8) as a separate work package after immediate notifications (2, 9, 10) are live and validated. Digest notifications require more complex data design and should not be rushed into brittle Flows.
ALWAYS	Confirm Total_Fees__c formula field is reliably populated before including it in the Closed Won notification payload. Formula fields that depend on incomplete source data will render as zero or blank.
BEFORE BUILD	Notification 8 (Missing Key Data weekly digest) cannot be built until the BD Lead formally signs off the required fields list. The digest audits exactly those fields. Building against the wrong criteria produces a useless digest from day one.
BEFORE BUILD	Notification 15 (Quote Closed Won) is not implementation-ready. The trigger mixes Opportunity and Quote logic and the quote selection rule is undefined. Do not start build until the quote trigger and quote-selection rule are formally confirmed.
NOTE	Build priority order as recommended in the Notification Specification: notifications 2, 9, 10, then 1 (manual). These have the cleanest trigger logic and will deliver value fastest. Digest and historical-change notifications are a second work package.
ALWAYS	Reference `Salesforce_Base_URL` Custom Label (value: `https://astrum.my.salesforce.com`, Label ID `101TY00000rVYYOYA4`) in all notification Flow email bodies for Salesforce record links. Use `{!$Label.Salesforce_Base_URL}`. Label is deployed in production since 25 Apr 2026. Do not re-deploy in future notification manifests.
ALWAYS	`emailSimple` Flow action routes via org email relay and does NOT count under the `Number of Email Invocations` governor limit. Email delivery can only be confirmed via Setup → Email Log Files. No SOQL-based verification is available. Do not assert email invocation count in Apex tests for `emailSimple` sends.
 
11.  Known Gaps and Unresolved Decisions

Net-New Fields Required (not in current schema — all require business sign-off before build)

ID	Field / Object	Type	Why Required
NF1	Meeting_Booked_Date__c (Lead)	Date	Speed-to-meeting KPI measurement. Journey suppression gate.
NF2	Meeting_Outcome__c (Lead)	Picklist	Structured post-meeting follow-up logic and coaching analysis. Values: Strong Interest, Neutral/Follow-up, No Appetite, RfP Expected, Deferred.
NF3	Last_MC_Send_Date__c (Lead, Contact)	Date/Time	Deduplication gate between Marketing Cloud sends and BD outreach. Critical for preventing duplicate messaging.
NF4	Disqualification_Reason__c (Lead)	Picklist	Confirmed as Decision D5 (Open) in Jan 2026 requirements meeting. Values from Dynamics taxonomy pending Commercial.
NF5	Preferred_Language__c (Lead, Contact)	Picklist	Multi-language content personalisation. Deferred unless Phase 1 content is confirmed as English-only.
NF6	[RETIRED — NOT REQUIRED] Prior_Probability__c (Opportunity)	Text	Confirmed not required as at Apr 2026. `{!$Record__Prior.Opp_Probability__c}` is natively available in after-save record-triggered Flows. No helper field or before-save Flow needed. Confirmed in SAL-2 delivery evidence. Do not build this field.
NF7	Prior_Service_Fees__c (Opportunity)	Currency	Previous Service Fees value for notification 5 threshold logic and email payload.
NF8	Prior_Close_Date__c (Opportunity)	Date	Previous close date for notification 6 slippage calculation.
NO1	Opportunity_Change_Log__c (custom object)	Master-Detail to Opp	Rolling count and prior-value logging for notifications 5, 6, 7. Fields: Change_Type__c, Previous_Value__c, New_Value__c, Change_Date__c, Changed_By__c.
NF9	Parent_Opportunity__c (Opportunity)	Lookup(Opportunity)	Change Order Project Code inheritance. Confirmed as intent in Decision D8 (Closed) but absent from schema file.

Open Business Decisions That Block Build

ESCALATE	BD1: Required field list for Subagent 3 and Notification 8. Owner: BD Lead. Blocks: Agentforce Subagent 3 build, Notification 8 Flow build.
ESCALATE	BD2: Opp_Probability__c formally confirmed as sole authoritative probability field. Owner: Commercial/Sales Ops. Blocks: All notification Flows referencing probability, all agent probability logic.
ESCALATE	BD3: Lead_Source__c confirmed as sole operational lead source field; standard LeadSource hidden. Owner: Commercial/Sales Ops. Blocks: All journey entry criteria, Data Cloud segmentation.
ESCALATE	BD4: Contact mandatory Account linkage decision. Owner: Commercial/Sales Ops. Blocks: AGENT_CreateContact Flow null-AccountId handling.
ESCALATE	BD5: Recipient matrix for Business_Category__c = S&PS for notifications 9 and 10. Owner: Commercial. Blocks: Closed Won and Closed Lost notification completeness.
ESCALATE	BD6: Close date push-out counting rule (push-outs only vs all changes). Owner: Commercial. Blocks: Notification 6 log object design.
ESCALATE	BD7: Marketing Cloud send frequency cap. Owner: Marketing/Commercial. Blocks: All journey designs.
ESCALATE	BD8: Agentforce licensing status. Owner: IT/Commercial. Blocks: Agent build start.
ESCALATE	BD9: Hyperforce EU instance confirmation. Owner: IT/Compliance. Blocks: Einstein Trust Layer validation, GDPR compliance sign-off.
ESCALATE	BD10: IndividualId population status and Individual record creation process. Owner: Salesforce Admin/Data Governance. Blocks: Data Cloud Consent DMO, all Marketing Cloud activation from Data Cloud.

Data Quality Issues That Must Be Fixed Before Build
•	Therapeutic_Area__c: three variants of Gynecology value (correct, encoding error with í, encoding error with ?). Fix global value set before any segmentation or personalisation build.
•	Study_Countries__c: contains non-standard free-text entries (e.g. 'Germany and 6 others', 'TBD', 'Portugal as a baseline'). Fix picklist before any notification or segmentation using this field.
•	Opportunity_Code__c: will be blank on Dynamics-migrated records at go-live. Data backfill required before all 14 notification Flows are activated in production.
•	LeadSource (standard) vs Lead_Source__c (custom): dual-field ambiguity must be resolved. Hide LeadSource from UI. Use Lead_Source__c exclusively.
•	Probability (standard) vs Opp_Probability__c (custom) vs Probability__c (formula): three fields. Opp_Probability__c is authoritative. Hide the other two from page layouts and document this decision formally.
 
12.  Non-Negotiable Schema-Grounding Rule for Future Recommendations

MANDATORY RULE: Every future recommendation produced for this programme must be validated against Astrum__Objects_Fields_1.xlsx before it is proposed. This rule has no exceptions.

The schema file Astrum__Objects_Fields_1.xlsx is the authoritative source for all object, field, relationship, picklist value, and data type information for the Astrum Orbit programme. It contains four sheets: Account (42 fields), Contact (50 fields), Opportunity (146 fields), and Lead (51 fields).

What this rule means in practice:
•	No field may be referenced in any Agentforce action, Prompt Template, Flow, notification payload, Marketing Cloud journey condition, Data Cloud segment, segmentation attribute, personalisation merge field, or activation criterion unless it is confirmed present in the schema file.
•	No object relationship may be assumed. Confirm all lookups and master-detail relationships in the schema before designing against them.
•	No picklist value may be assumed. Use only the confirmed values from the schema. Inventing or guessing picklist values produces Flows and agents that fail silently in production.
•	No data type may be assumed. Text(255) and Long Text Area(32000) behave differently in SOQL and Flow. Formula fields cannot be written to. Roll-Up Summary fields cannot be used in record-triggered Flows as trigger conditions.

What to do when a capability appears to require a field not in the schema:
•	Do not proceed with the design as if the field exists.
•	Label the gap clearly as NET-NEW REQUIRED with: proposed label, proposed API name, object, data type, and commercial justification.
•	Flag it as a business decision required before build can proceed.
•	Do not design trigger conditions, SOQL queries, Flow logic, or agent actions against a field that does not yet exist.

Data quality issues in the confirmed schema that must not be silently accepted:
•	Therapeutic_Area__c encoding errors: three variants of Gynecology. Never use this field in segmentation, personalisation, or notifications until global value set is cleaned.
•	Study_Countries__c non-standard picklist values: multiple free-text entries that are not valid ISO country codes. Never display this field in notification emails or use in Data Cloud segments until cleaned.
•	Probability field ambiguity: only Opp_Probability__c is authoritative. All other probability fields must be treated as derived/display fields.
•	Lead Source field ambiguity: only Lead_Source__c (custom) is operational. LeadSource (standard) must be hidden and superseded.

This memory pack was built from: Astrum BD Agent Design Brief v0.1, Astrum BD Agent S1 Account/Contact Config v0.1, Astrum Commercial Salesforce Requirements Meeting Summary 29 Jan 2026, Orbit Opportunities Notification Requirements Specification, Astrum Use Cases capability diagram, Licensing and Scope, FY25 Customer Success Metrics, Astrum__Objects_Fields_1.xlsx (schema authority), ROI dynamic calculator, and Astrum List Prices. If any of these documents are updated, this memory pack must be reviewed and updated to reflect the changes.

Programme
Astrum Orbit	Schema Version
April 2026 — Astrum__Objects_Fields_1.xlsx	Memory Pack Version
1.0 — April 2026

