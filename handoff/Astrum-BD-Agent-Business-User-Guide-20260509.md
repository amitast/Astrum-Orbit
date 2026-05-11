# Astrum BD Agent Business User Guide

## 1. Purpose of this guide

This guide helps Astrum BD users understand how to use the Astrum BD Agent safely and effectively inside Salesforce.

It explains what the agent can do today, what it cannot do, how to write useful requests, when confirmation is required, and when to contact Salesforce Admin or programme support.

This is a business user guide. It avoids implementation detail where possible and focuses on practical use.

## 2. What the Astrum BD Agent is

The Astrum BD Agent is an internal Salesforce assistant for Astrum business development users.

It helps users work with Salesforce account and contact records, and can generate account summaries using Salesforce data. Where available in the user's Salesforce access, the account summary may include a brief open pipeline view linked to that account.

The agent uses Salesforce data that the user is already allowed to access. It does not give users extra access, and it should not bypass normal Salesforce permissions.

The agent does not replace Salesforce record ownership, data governance, business approval, or user judgement. Users remain responsible for checking records and confirming any change before it is made.

In Phase 1, the agent works inside Salesforce. It is not an external web chat, email bot, LinkedIn assistant, client-facing assistant, or marketing outreach tool.

## 3. Who should use it

The Astrum BD Agent is intended for:

| User group | Use |
|---|---|
| BD users | Day-to-day account and contact lookup, permitted contact creation, permitted field updates, and account summaries. |
| Sales and commercial users with authorised Salesforce access | Reviewing and updating account or contact information within their normal Salesforce permissions. |
| Managers with authorised Salesforce access | Reviewing account, contact, and visible pipeline context where their Salesforce permissions allow it. |
| First-line support teams | Helping users understand expected behaviour, confirmation prompts, and when to escalate. |

The agent is not intended for:

| User group | Reason |
|---|---|
| External users, clients, vendors, or partners | The agent is internal-only in Phase 1. |
| Users without authorised Salesforce access | The agent relies on Salesforce permissions and should not bypass them. |
| Users seeking clinical, patient, GxP, PHI, or regulated study-data support | Those data types are outside the agent's commercial BD scope. |

## 4. Where to find it

1. Open Salesforce.
2. Navigate to the Astrum BD Agent from the Salesforce agent interface.
3. Start a new agent conversation and type your request.

Exact navigation may vary by Salesforce release and by how the Salesforce Admin has exposed the agent in the user interface.

If you cannot see the agent, contact the Salesforce Admin or programme support team. They may need to confirm that the agent is published for your users, that you have the correct permission set, and that your Salesforce profile or permission assignments allow access.

## 5. What the agent can do

The table below lists capabilities confirmed from the current deployed agent bundle, source files, and production smoke-test evidence reviewed for this guide.

| Area | What you can ask | Example user prompt | What the agent will do | Confirmation required? |
|---|---|---|---|---|
| Account and Contact Management | Find account details | Show me the account details for AstraZeneca. | Retrieve and display key account information such as name, industry, type, phone, website, location, owner, and related account information where available. | No |
| Account and Contact Management | Search for accounts | Find accounts in the biotechnology industry. | Search matching Salesforce account records and return up to 10 results, or explain if no matching accounts are found. | No |
| Account and Contact Management | Update permitted account fields | Update the phone number on the BioNTech account to [value]. | Retrieve the current account first, show the current and proposed value, then ask for confirmation before changing the record. | Yes |
| Account and Contact Management | Find contact details | Find Sarah Chen in Salesforce. | Retrieve and display contact details such as name, title, department, account, email, phone, mobile, owner, and last modified date where available. | No |
| Account and Contact Management | Search for contacts | Show me contacts at Pfizer. | Search matching Salesforce contact records by contact name, account, or title, and return up to 10 results. | No |
| Account and Contact Management | Create a new contact | Add a new contact to the Pfizer account. | Check for possible duplicates by account and contact details, present duplicate information if found, and ask for confirmation before creating the contact. | Yes |
| Account and Contact Management | Update permitted contact fields | Update Sarah Chen's job title to Senior Director. | Retrieve the current contact first, show the current and proposed value, then ask for confirmation before changing the record. | Yes |
| Account and Contact Management | Generate an account intelligence summary | Give me a summary of the Eli Lilly account. | Generate a concise summary using Salesforce record data only. It may include account overview, key contacts by name and title, visible open pipeline count/value, and account owner where available. | No |

Permitted account fields for update are: Industry, Type, Phone, Website, Description, and Number of Employees.

Permitted contact fields for update are: Title, Department, Email, Phone, and Mobile Phone.

Opportunity Management is not currently available as a direct agent capability for users. The agent should not create opportunities, update opportunity stages, change close dates, or capture deal next steps unless Salesforce Admin later confirms that the Opportunity Management capability has been deployed and enabled.

Data Quality and Hygiene is not currently available as a direct agent capability for users. The agent should not run pipeline hygiene audits, stale-record reports, missing-field reports, or bulk data-quality checks unless Salesforce Admin later confirms that the Data Quality capability has been deployed and enabled.

## 6. How to use the agent effectively

Be specific. Use account names, contact names, and clear field names where possible.

Give one instruction at a time, especially for record updates.

Review the Salesforce record the agent shows before confirming any update or creation request.

If the agent finds multiple possible records, choose the correct one before asking it to update anything.

Ask a follow-up question if the answer is unclear or if the agent shows a record that does not look right.

Do not paste sensitive notes, client emails, long migration notes, confidential free text, clinical information, patient information, or unreviewed Dynamics 365 notes unless there is a clear business need and Salesforce policy allows it.

### Account prompt examples

| Use | Example prompt |
|---|---|
| View an account | Show me the account details for AstraZeneca. |
| Search for accounts | Find accounts in the biotechnology industry. |
| Update an account field | Update the phone number on the BioNTech account to [value]. |
| Summarise an account | Give me a summary of the Eli Lilly account. |

### Contact prompt examples

| Use | Example prompt |
|---|---|
| Search contacts at an account | Show me contacts at Pfizer. |
| Find a named contact | Find Sarah Chen in Salesforce. |
| Create a new contact | Add a new contact to the Pfizer account. |
| Update a contact field | Update Sarah Chen's job title to Senior Director. |

Opportunity prompts are not included because direct Opportunity Management capability is not currently confirmed as available to users.

## 7. Step-by-step how-to scenarios

### Scenario 1. Find an account

1. Ask the agent to find or show an account, for example: "Show me the account details for Pfizer."
2. Review the returned account details.
3. Ask a follow-up question or request an allowed update if needed.

### Scenario 2. Update an account field

1. Ask for the account first, for example: "Show me the BioNTech account."
2. Ask for the specific field update, for example: "Update the phone number to [value]."
3. Review the proposed change.
4. Confirm only if the account, field, current value, and proposed new value are correct.
5. Check the updated Salesforce record if needed.

### Scenario 3. Find contacts at an account

1. Ask for contacts at a named account, for example: "Show me contacts at Pfizer."
2. Review the returned list.
3. Ask for more detail on a specific contact, for example: "Show me details for Sarah Chen."

### Scenario 4. Create a new contact

1. Provide the account name and contact details, for example: "Add Emma Lau as VP Clinical Operations at Pfizer, email [value]."
2. The agent checks for possible duplicates.
3. If a duplicate is found, review it before proceeding.
4. If no duplicate is found, review the proposed new contact.
5. Confirm creation only if the account and contact details are correct.

### Scenario 5. Update a contact field

1. Ask the agent to find the contact.
2. Ask for the specific field update, for example: "Update Sarah Chen's job title to Senior Director."
3. Review the current and proposed values.
4. Confirm only if the record and proposed change are correct.

### Scenario 6. Generate an account summary

1. Ask for the account summary, for example: "Give me a summary of the Pfizer account."
2. Review the summary.
3. Use it as a starting point, not as the sole source of truth.
4. Check Salesforce records directly for critical decisions, client-facing use, or leadership reporting.

## 8. What the agent cannot do

| Request | Why it cannot do this | What to do instead |
|---|---|---|
| Create Account records | Account creation is controlled by data governance and is not an agent action. | Follow the governed account creation process or contact Salesforce Admin. |
| Delete records | Delete actions are outside the agent scope and no delete permission is granted for the agent permission set. | Contact Salesforce Admin if a record genuinely needs review or deletion. |
| Perform bulk updates | Bulk updates risk changing many records without proper individual review. | Use approved Salesforce Admin, data governance, or migration processes. |
| Update records without user confirmation | Record creation and updates require user confirmation before Salesforce is changed. | Review the proposed change and confirm only if correct. |
| Access records outside the user's Salesforce permissions | The agent must respect normal Salesforce access. | Ask your manager or Salesforce Admin if you believe your access is incorrect. |
| Use external web, LinkedIn, email bot, or client-facing channels in Phase 1 | Phase 1 is internal to Salesforce only. | Use approved business tools and processes outside the agent. |
| Replace business approval or data ownership | Users and record owners remain accountable for Salesforce data and decisions. | Follow normal approval and ownership processes. |
| Guarantee that incomplete Salesforce data is correct | The agent can only use the data available in Salesforce. | Verify important data against the Salesforce record owner or trusted business source. |
| Process GxP, PHI, clinical, or patient data | The agent is scoped to commercial BD pipeline data only. | Use approved regulated-data systems and processes. |
| Send marketing outreach | The agent is not a marketing automation or outreach tool. | Use approved Marketing Cloud or BD outreach processes. |
| Automatically book meetings | Meeting booking is not an agent capability in the confirmed deployment. | Use Outlook, Salesforce activity tools, or the approved scheduling process. |
| Generate proposals or negotiate with clients | Proposal generation and client negotiation require human commercial judgement and approval. | Use the approved proposal and commercial review process. |
| Use raw D365 notes or long unreviewed text as reliable AI input | Long migrated notes may contain stale, incomplete, or misleading information. | Review and curate key information before adding it to Salesforce or using it in a prompt. |
| Create, update, or manage opportunities | Direct Opportunity Management actions are not confirmed as available in the deployed agent. | Update opportunities directly in Salesforce or contact Salesforce Admin for capability status. |
| Run data quality or hygiene audits | Data Quality and Hygiene actions are not confirmed as available in the deployed agent. | Use existing reports or contact Salesforce Admin for the appropriate process. |

## 9. Confirmation and safety rules

The agent will ask for confirmation before creating or updating Salesforce records.

Users must check the current value and proposed new value before confirming. If the user confirms a wrong update, the record may be changed in Salesforce.

The agent respects the user's Salesforce access. If a user cannot see or update a record in Salesforce, the agent should not bypass that access.

If the agent shows multiple possible records, do not confirm a change until you are certain which record is correct.

If a confirmation prompt does not look right, cancel the action and start again with a clearer request.

## 10. Data quality and privacy expectations

Use clean, specific prompts. The agent works best when account names, contact names, and requested fields are clear.

Do not paste unnecessary personal data. Contact email and phone data must be handled carefully and only for legitimate business use.

Do not paste confidential client emails, long unstructured notes, raw Dynamics 365 migration notes, clinical content, patient data, or sensitive commercial text unless there is a clear business need and Salesforce policy allows it.

The agent is for commercial BD pipeline data, not clinical, patient, PHI, or GxP data.

Users remain accountable for the quality of the data they create or update. The agent can help, but it does not know whether incomplete Salesforce data is commercially correct.

## 11. Good prompts and poor prompts

| Good prompt | Why it works | Poor prompt | Why it is poor |
|---|---|---|---|
| Show me the Pfizer account record. | Names the account and asks for a clear read-only action. | Tell me everything about Pfizer. | Too broad and may imply information outside Salesforce. |
| Update Sarah Chen's title to Senior Director after showing me her current record. | Names the contact, field, new value, and asks for review before update. | Fix Sarah. | Unclear person, record, field, and desired outcome. |
| Add Emma Lau as VP Clinical Operations at Pfizer, email [value]. | Provides the account and key contact details for duplicate checking and confirmation. | Add this person somewhere. | Missing account, role, and useful identifying details. |
| Find contacts at Pfizer with procurement in their title. | Gives account context and search criteria. | Who handles procurement? | Too vague unless the account is already clear. |
| Update the BioNTech website to [value]. | Names an allowed account field and target account. | Update BioNTech. | Does not say which field or value should change. |
| Give me a summary of the Eli Lilly account. | Matches the confirmed account summary capability. | Write a full client briefing from everything online. | The agent does not use external web sources in Phase 1. |

## 12. Troubleshooting

| Issue | Likely reason | What the user should do | When to contact Salesforce Admin or programme support |
|---|---|---|---|
| I cannot see the agent. | The agent may not be published to your user interface, or you may not have the required permission assignment. | Refresh Salesforce and check whether the agent is available from the agent interface. | Contact support if it still does not appear. |
| The agent cannot find the record. | The record name may be misspelled, there may be multiple similar records, or you may not have access. | Try the exact Salesforce record name or add more detail such as account, country, or contact last name. | Contact support if you can see the record manually but the agent cannot. |
| The agent found multiple records. | The prompt matched more than one account or contact. | Select the correct record before asking for a change. | Contact support if the returned records look incorrect or incomplete. |
| The agent asks me to confirm. | The request would create or update a Salesforce record. | Check the current and proposed values, then confirm only if correct. | Contact support if confirmation appears for an unexpected action. |
| The agent says it cannot perform the request. | The request may be outside current capability, outside your permissions, or blocked by a safety rule. | Rephrase as a supported account or contact request, or use the normal Salesforce process. | Contact support if you believe the request should be supported. |
| The agent gives an unexpected answer. | The prompt may be ambiguous, Salesforce data may be incomplete, or the agent may have selected the wrong record. | Ask a clearer follow-up and verify the underlying Salesforce record. | Contact support if the answer could lead to incorrect business action. |
| A record update failed. | The field may not be permitted, the record may be locked, your permissions may not allow the update, or Salesforce validation may have blocked it. | Check the record directly in Salesforce and try a permitted field update. | Contact support if the issue persists or if the error is unclear. |
| I think the agent made a mistake. | The agent may have misunderstood the prompt or worked from incomplete Salesforce data. | Stop, do not confirm further changes, and check the Salesforce record. | Report the issue with details and screenshots if appropriate. |

## 13. Escalation and support

Salesforce Admin support contact: [To be confirmed]

Programme support contact: [To be confirmed]

When reporting an issue, include:

| Detail | What to include |
|---|---|
| User name | Your Salesforce user name. |
| Date and time | When the issue happened, including time zone if relevant. |
| Record name | Account, contact, or other Salesforce record involved. |
| What was asked | The exact prompt or a close copy. |
| What the agent replied | The response or error message. |
| Screenshot | Include one if appropriate and allowed by policy. |

Do not include passwords, security tokens, session IDs, private keys, or unnecessary client-sensitive information in support reports.

## 14. Quick reference

### Best uses

| Use the agent for |
|---|
| Finding account details. |
| Searching for accounts by name, industry, or type. |
| Finding contact details. |
| Searching for contacts by account, name, or title. |
| Creating a new contact after duplicate checking and confirmation. |
| Updating permitted account or contact fields with confirmation. |
| Generating a concise account summary from Salesforce data. |

### Do not use for

| Do not use the agent for |
|---|
| Account creation. |
| Record deletion. |
| Bulk updates. |
| Direct opportunity creation, stage updates, close-date changes, or next-step capture. |
| Pipeline hygiene audits or missing-field reports. |
| Clinical, patient, PHI, or GxP data. |
| Marketing outreach, proposal generation, negotiation, or meeting booking. |
| External web, LinkedIn, email bot, or client-facing interactions. |

### Golden rules

| Rule |
|---|
| Be specific. |
| Ask for one thing at a time. |
| Review the Salesforce record before confirming. |
| Confirm only if the proposed change is correct. |
| Do not paste unnecessary confidential or personal data. |
| Use Salesforce records as the source of truth for critical decisions. |
| Contact Salesforce Admin if access, visibility, or record ownership looks wrong. |

### Example prompts

| Example |
|---|
| Show me the account details for AstraZeneca. |
| Find accounts in the biotechnology industry. |
| Give me a summary of the Eli Lilly account. |
| Show me contacts at Pfizer. |
| Find Sarah Chen in Salesforce. |
| Add Emma Lau as VP Clinical Operations at Pfizer, email [value]. |
| Update Sarah Chen's job title to Senior Director. |
| Update the phone number on the BioNTech account to [value]. |

## 15. Appendix. Confirmed deployed capability basis

This appendix summarises the evidence used to prepare this guide. It is included so reviewers can trace business-facing statements back to the deployed capability without exposing secrets or unnecessary internal command output.

### Confirmed deployed agent topic and actions

The current agent bundle contains one confirmed user-facing topic:

| Confirmed topic | Business meaning |
|---|---|
| Account and Contact Management | The agent can help with account and contact lookup, search, permitted updates, contact creation with duplicate checking, and account summaries. |

The deployed topic includes these confirmed actions:

| Confirmed action | Business capability | Confirmation required? |
|---|---|---|
| Get Account Details | Find and display account details. | No |
| Search Accounts | Search account records by supported criteria. | No |
| Update Account Field | Update one permitted account field at a time. | Yes |
| Get Contact Details | Find and display contact details. | No |
| Search Contacts | Search contact records by supported criteria. | No |
| Create Contact with Duplicate Check | Create a contact after duplicate checking. | Yes |
| Update Contact Field | Update one permitted contact field at a time. | Yes |
| Generate Account Intelligence Summary | Generate a concise account summary from Salesforce data only. | No |

The deployed agent bundle also contains a standard "Answer Questions with Knowledge" planner action. This guide does not present it as a business capability because the reviewed business evidence and smoke tests focused on the confirmed Account and Contact Management capability.

### Evidence files reviewed

| Evidence reviewed | Relevance |
|---|---|
| `force-app/main/default/genAiPlannerBundles/Astrum_BD_Agent/Astrum_BD_Agent.genAiPlannerBundle` | Confirms the deployed topic, actions, confirmation settings, guardrail instructions, and scope boundaries. |
| `force-app/main/default/bots/Astrum_BD_Agent/v1.botVersion-meta.xml` | Confirms the Astrum BD Agent bot version is linked to the Astrum BD Agent planner and describes the Salesforce BD role. |
| `force-app/main/default/permissionsets/Astrum_BD_Agent_PS.permissionset-meta.xml` | Confirms permission-set footprint for account, contact, opportunity read for summaries, approved flows, and approved agent classes. |
| `force-app/main/default/classes/AGENT_SearchAccounts.cls` | Confirms account search uses user-mode Salesforce access. |
| `force-app/main/default/classes/AGENT_SearchContacts.cls` | Confirms contact search uses user-mode Salesforce access. |
| `force-app/main/default/classes/AGENT_UpdateAccountField.cls` | Confirms account update allow-list and user-mode update behaviour. |
| `force-app/main/default/classes/AGENT_UpdateContactField.cls` | Confirms contact update allow-list and user-mode update behaviour. |
| `force-app/main/default/classes/AGENT_AccountIntelligenceSummary.cls` | Confirms the account summary action resolves account data and uses Salesforce account, contact, and open opportunity data visible to the user. |
| `force-app/main/default/flows/AGENT_CreateContact.flow-meta.xml` | Confirms the contact creation flow with duplicate-check behaviour. |
| `force-app/main/default/flows/AGENT_GetAccountDetails.flow-meta.xml` | Confirms account detail lookup. |
| `force-app/main/default/flows/AGENT_GetContactDetails.flow-meta.xml` | Confirms contact detail lookup. |
| `validation/SAL-21-production-smoke-test-20260509-r3.md` | Confirms 8/8 production smoke-test pass across account summaries, contact search, account search, update confirmation, account creation refusal, and account deletion refusal. |
| `validation/SAL-21-phase-3-planner-bundle-live-deploy-20260509.md` | Confirms the planner bundle deployment evidence for production. |
| `validation/SAL-21-phase-2-remediation-20260509.md` | Confirms production deployment of search and update action classes and passing tests. |
| `validation/SAL-21-phase-1-production-apex-deploy-20260509.md` | Confirms production deployment of the update contact action class and passing tests. |
| `validation/SAL-21-phase-3b-production-remediation-20260509.md` | Confirms deployment evidence for supporting account/contact detail flows and account intelligence prompt/template dependency. |
| `validation/SAL-BD-S1-AGENT_CreateContact.md` | Confirms contact creation flow validation, duplicate-check behaviour, confirmation guardrail, and delete refusal evidence. |
| `PRDS/SAL-21-astrum-bd-agent-s1-remaining-actions.md` | Confirms the approved S1 scope and field allow-list requirements used for SAL-21. |
| `docs/PRDs/SAL-BD-S1-AGENT_CreateContact-PRD.md` | Confirms Create Contact design and guardrails. |
| `LLM-TXTS/agentforce/Astrum_BD_Agent_Overarching_Spec.md` | Confirms overall design intent, Phase 1 internal Salesforce channel, data classification, and guardrails. |
| `LLM-TXTS/agentforce/Astrum_BD_Agent_S1_AccountContact_Spec.md` | Confirms Account and Contact Management design basis. |
| `LLM-TXTS/agentforce/Astrum_BD_Agent_S2_OpportunityManagement_Spec.md` and `LLM-TXTS/Astrum_BD_Agent_S2_OpportunityManagement_Config.md` | Reviewed for opportunity design context; no deployed S2 topic/actions were confirmed in current metadata. |
| `LLM-TXTS/agentforce/Astrum_BD_Agent_S3_DataQualityHygiene_Spec.md` | Reviewed for data quality design context; no deployed S3 topic/actions were confirmed in current metadata. |
| `validation/SAL-17-Permissions-FLS-CreateContact.md`, `validation/SAL-16-permission-assignment-evidence.md`, and `handoff/SAL-16-uat-readiness-update.md` | Confirm earlier permission set evidence and pilot user assignment evidence in sandbox. |

### Confirmed available capabilities

| Capability | Status |
|---|---|
| Account details lookup | Confirmed available |
| Account search | Confirmed available |
| Account field update with confirmation | Confirmed available for permitted fields only |
| Contact details lookup | Confirmed available |
| Contact search | Confirmed available |
| Contact creation with duplicate checking and confirmation | Confirmed available |
| Contact field update with confirmation | Confirmed available for permitted fields only |
| Account intelligence summary using Salesforce data only | Confirmed available |
| Account creation refusal | Confirmed in smoke testing |
| Record deletion refusal | Confirmed in smoke testing |

### Not currently available

| Capability | Status | Reason |
|---|---|---|
| Direct Opportunity Management | Not currently available | S2 design files exist, but no deployed Opportunity Management topic/actions were confirmed in the current agent bundle. |
| Data Quality and Hygiene | Not currently available | S3 design files exist, but no deployed Data Quality and Hygiene topic/actions were confirmed in the current agent bundle. |
| Bulk updates | Not currently available | Explicitly outside guardrails and no bulk update action is deployed. |
| External web, LinkedIn, email bot, or client-facing channel use | Not currently available | Phase 1 is internal Salesforce only. |
| Marketing outreach, meeting booking, proposal generation, or negotiation | Not currently available | Not in confirmed deployed agent scope. |

### To be confirmed by Salesforce Admin

| Item | Reason |
|---|---|
| End-user navigation path | Exact Salesforce navigation may vary by release and by how the agent is exposed in the UI. |
| Production user visibility and assignment | The guide assumes users must have the correct Salesforce access and permission assignment. Admin should confirm which user groups have access. |
| Final support contacts | Support names or distribution lists were not present in the reviewed evidence. |
| Whether any future S2 or S3 capability has been deployed after this guide date | This guide is based on evidence available in the repo on 9 May 2026. |

