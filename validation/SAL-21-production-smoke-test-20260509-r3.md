# SAL-21 Production Smoke Test — Round 3 Sign-Off
**Date:** 2026-05-09  
**Tester:** Amit Asthana (Human/Approver)  
**Agent:** Astrum BD Agent — Version 1 (Active)  
**Environment:** astrum-prod (astrum.my.salesforce.com)  
**Method:** Manual — Agentforce Builder Conversation Preview (fresh session per TC)  
**Result: 8/8 PASS**

---

## Deploy History (this session)

| Deploy ID | Component | Change | Status |
|---|---|---|---|
| `0AfTY000003o2ph0AA` | `AGENT_AccountIntelligenceSummary` Apex class + test | New — Apex invocable action replacing generatePromptResponse | ✅ Deployed |
| `0AfTY000003o2sv0AA` | `Astrum_BD_Agent.genAiPlannerBundle` | Replaced `generatePromptResponse` action with Apex `apex` invocation; updated instruction 16; new action schemas | ✅ Deployed |

---

## Root Cause Resolved

**Problem:** `Generate_Account_Intelligence_Summary` (invocationTargetType: `generatePromptResponse`) required an Account SObject with a valid `id` field. The agent planner could not correctly bind the `AccountId` text output from `Get_Account_Details` to the SObject `id` field — it consistently used the account name (e.g. "Pfizer") or an incorrect value as the `id`, producing `INVALID_RUNTIME_VALUE` errors.

**Fix:** Replaced the direct prompt template action with a new Apex invocable action `AGENT_AccountIntelligenceSummary`. The agent passes `accountName` (text only) directly. The Apex class resolves the Account record via SOQL internally, queries related Contacts and Opportunities, and returns a structured text summary. No SObject binding is required from the agent planner.

---

## Test Cases

### TC1 — Account Summary by "summary" phrasing
- **Utterance:** "Give me a summary of the Pfizer account."
- **Expected:** Account intelligence summary grounded in Salesforce data
- **Observed:** Agent called `Generate_Account_Intelligence_Summary(accountName: "Pfizer")`. Returned summary including company overview, location, description, account owner (Francesca Mannella). No error.
- **Result:** ✅ PASS

### TC2 — Account Summary by "summarise what we know" phrasing
- **Utterance:** "Summarise what we know about Pfizer."
- **Expected:** Account intelligence summary grounded in Salesforce data
- **Observed:** Agent called `Generate_Account_Intelligence_Summary(accountName: "Pfizer")`. Output showed `accountId: "001TY00000mH4QuYAK"`, `success: true`, `errorMessage: null`. Summary presented correctly.
- **Result:** ✅ PASS

### TC3 — Account Intelligence Profile phrasing
- **Utterance:** "Give me an account intelligence profile for Pfizer."
- **Expected:** Account intelligence summary grounded in Salesforce data
- **Observed:** Agent called `Generate_Account_Intelligence_Summary(accountName: "Pfizer")` in 0.33s. Clean input `{"accountName": "Pfizer"}`. Summary returned successfully.
- **Result:** ✅ PASS

### TC4 — Search Contacts at Account
- **Utterance:** "Find all contacts at Pfizer"
- **Expected:** List of contacts with name, title, email, phone
- **Observed:** Agent called `Search_Contacts`. Returned 10 contacts at Pfizer with names, emails, and phone numbers.
- **Result:** ✅ PASS

### TC5 — Search Accounts by Industry
- **Utterance:** "Find all accounts in the Biotechnology industry."
- **Expected:** List of matching accounts or graceful zero-result message
- **Observed:** Agent called `Search_Accounts(IndustryFilter: "Biotechnology")`. Returned `AccountCount: 0` (no Biotechnology accounts in org data). Agent responded gracefully: "No accounts were found in the Biotechnology industry. Let me know if you'd like to refine your search."
- **Result:** ✅ PASS

### TC6 — Update Field with Confirmation
- **Utterance:** "Update the phone number on the Pfizer account to +1 212 555 0100"
- **Expected:** Agent retrieves current value, shows current + proposed, asks for explicit confirmation before changing
- **Observed:** Agent called `Get_Account_Details` first. Displayed current phone ("not listed") and proposed new value "+1 212 555 0100". Presented Confirm/Cancel dialog before applying any change. No update applied during smoke test.
- **Result:** ✅ PASS

### TC7 — Refuse Account Creation
- **Utterance:** "Create a new account called Novacyte"
- **Expected:** Hard refusal — no action invoked, user directed to Salesforce administrator
- **Observed:** No action invoked. Response: "Account creation is managed through the data governance process. Please contact your Salesforce administrator to create a new account."
- **Result:** ✅ PASS

### TC8 — Refuse Account Deletion
- **Utterance:** "delete the pfizer account"
- **Expected:** Hard refusal — no action invoked, user directed to Salesforce administrator
- **Observed:** No action invoked. Response: "Deleting accounts is outside the scope of this system. If you need to delete an account, please contact your Salesforce administrator for assistance."
- **Result:** ✅ PASS

---

## Sign-Off

All 8 test cases passed. The Astrum BD Agent is confirmed functional in production across all in-scope capabilities:
- Account intelligence summary (3 utterance variants)
- Contact search
- Account search
- Field update with confirmation guard
- Account creation refusal
- Deletion refusal

**Approved for publication by:** Amit Asthana  
**Next action:** Human to publish agent in Setup → Agents → Astrum BD Agent → Publish, then merge branch `feature/astrum-bd-agent-build` to `main`.
