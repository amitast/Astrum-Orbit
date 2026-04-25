# SAL-10 — Closed Lost Review Notification
## Business Decisions Required Before Build

| | |
|---|---|
| Prepared by | Salesforce Delivery Team |
| For | BD Lead, Commercial |
| Date | 25 April 2026 |
| Programme | Astrum Orbit |
| Priority | High — blocks the Closed Lost notification build |

---

## Recipient Matrix Now Partially Resolved

The following routing has been provided by the project team. It is recorded here for stakeholder confirmation. **Build has not started. No automation is active.**

> **Currency confirmation:** The Salesforce org default currency is EUR / Euros. All deal size thresholds shown below (€150,000 and €500,000) are Euro amounts. This has been confirmed against the live org configuration.

### What has been provided

| Business Category | Service Fees condition | Recipients |
|---|---|---|
| Phase I Unit | Below €150,000 | tom.frearson, Catherine.Canales, Opportunity Owner, Ricardo.Cunha, rfp.rfi, cristina.lopes, anthony.gibson |
| Phase I Unit | €150,000 and above | tom.frearson, Catherine.Canales, Opportunity Owner, cristina.lopes, Ricardo.Cunha, rfp.rfi, anthony.gibson |
| Phase I-NIS | Below €500,000 | tom.frearson, Catherine.Canales, Opportunity Owner, rfp.rfi, jordi.picas, cristina.lopes, anthony.gibson |
| Phase I-NIS | €500,000 and above | tom.frearson, Catherine.Canales, Opportunity Owner, cristina.lopes, jordi.picas, anthony.gibson, rfp.rfi |

Opportunity Owner is included in all four rules as a dynamic recipient (the BD user assigned to the deal).

### One question on the provided matrix

When we reviewed the two Phase I Unit lists and the two Phase I-NIS lists, we noticed that after accounting for email address casing, the recipients below the threshold and at or above the threshold are the **same people** in both cases.

**Please confirm one of the following:**

- The same people are notified regardless of deal size — the threshold distinction is kept for future use but does not change who receives the email today.
- The threshold distinction should be removed — a single flat list per Business Category is enough.
- There was a data entry issue — please resupply the correct list for the larger-deal scenario.

### What remains unresolved

| Item | Status |
|---|---|
| S&PS routing | Not provided — no email will be sent for S&PS deals |
| All Other Projects (Phase I - NIS) routing | Not provided — no email will be sent |
| Phase I Clinical Conduct Portugal routing | Not provided — no email will be sent |
| Site & Patient Services (CRP & MissionTEC) routing | Not provided — no email will be sent |
| What to do when Business Category or Service Fees is blank | Not confirmed |

---

## Why we need these decisions

We are building an automated email that fires every time an Opportunity is marked as Closed Lost. The email sends an immediate review notification to the right people, showing the deal name, account, service fees, loss reason, and close date.

Before we can write any automation, the business needs to answer seven questions. Until these are answered, we will not send any emails and no automation will be active.

We need written confirmation of each decision so the build can proceed without ambiguity.

---

## Decision 1 — Does "Lost/Cancelled/Declined to Bid" also trigger the email?

**Background:** The Salesforce system currently has two stages that represent a lost outcome:

- `Closed Lost` — the stage we planned to trigger the notification
- `Lost/Cancelled/Declined to Bid` — a second active stage found in the system

**Question:** Should the Closed Lost review email also fire when an Opportunity moves to `Lost/Cancelled/Declined to Bid`?

**Your options:**

- **Yes, include it** — both stages trigger the email
- **No, exclude it** — only `Closed Lost` triggers the email; the other stage is ignored
- **Retire the second stage** — we consolidate all lost records into `Closed Lost` (separate migration task required)

**Why it matters:** If we exclude it, any deal closed under `Lost/Cancelled/Declined to Bid` will not trigger a review email and will be silently missed.

**Decision needed from:** Commercial / Sales Ops

---

## Decision 2 — Which deal types should receive the email?

**Background:** Every Opportunity in Salesforce has a Business Category field. We found six active Business Category values in the system. The programme documentation only covers three of them.

**The six active values:**

1. Phase I Unit
2. Phase I-NIS
3. S&PS
4. All Other Projects (Phase I - NIS)
5. Phase I Clinical Conduct Portugal
6. Site & Patient Services (CRP & MissionTEC)

**Question:** For each value above, should the Closed Lost review email be sent?

Please mark each as **In scope** (send the email) or **Out of scope** (no email).

Any value marked out of scope will be silently skipped — no email, no error.

**Why it matters:** Without this confirmation, we cannot route the email correctly. Deals in the three undocumented categories will not receive any notification until you confirm they are in scope.

**Decision needed from:** Commercial

---

## Decision 3 — Who receives the email for each deal type?

**Background:** The email recipient list depends on the Business Category and the size of the deal (Service Fees). We need the business to define the routing matrix.

**For each Business Category confirmed as in scope in Decision 2, please provide:**

| Business Category | Service Fees threshold (£) | Recipients below threshold | Recipients at or above threshold |
|---|---|---|---|
| Phase I Unit | | | |
| Phase I-NIS | | | |
| S&PS | | | |
| *(other in-scope values)* | | | |

**Notes:**
- The Opportunity Owner will always be included as a recipient unless you tell us otherwise.
- If the recipient lists for Closed Lost are the same as for Closed Won (notification 9), please confirm this explicitly and we will use the same values for both.
- Please provide full email addresses for each recipient group.

**Why it matters:** Without these lists, we cannot configure who receives the email. The automation cannot be built.

**Decision needed from:** Commercial

---

## Decision 4 — What should happen when a deal has no Business Category or no Service Fees?

**Background:** Some Opportunity records may have a blank Business Category or a blank Service Fees value. The system needs a rule for what to do in these cases.

**Question for each scenario below:**

| Scenario | Option A — Send to a fallback person | Option B — Do not send (silent skip) |
|---|---|---|
| Business Category is blank | Who should receive it? | No email sent |
| Business Category is an unexpected value | Who should receive it? | No email sent |
| Service Fees is blank or zero | Use the standard (lower) recipient list | No email sent |

Our current default is Option B (silent skip) for all three. If you prefer Option A for any scenario, please provide the fallback email address.

**Why it matters:** If we default to silent skip and the business expects a fallback send, deals will be missed with no notification or error.

**Decision needed from:** Commercial

---

## Decision 5 — Loss Reason values: are these correct and complete?

**Background:** The Loss Reason field in Salesforce currently has these nine values:

1. Astrum Capabilities
2. Cancelled
3. Cost
4. Declined to Bid
5. Geographical Coverage
6. Lost to Follow-up
7. Lost to Incumbent
8. Project Team Experience
9. Therapeutic Experience

**Two questions:**

**5a — Are these values correct?** If any value is wrong, missing, or should be retired, please let us know before build. Changing picklist values after the notification is live is possible but requires a separate change request.

**5b — If Loss Reason is blank on a deal, should we still send the email?** Our current design sends the email and simply omits the Loss Reason line. If you prefer to block the send until Loss Reason is populated, we can add that rule — but it means some Closed Lost records will not trigger the email until the field is filled in.

**Decision needed from:** BD Lead / Commercial

---

## Decision 6 — Should the Opportunity Owner always receive the email?

**Background:** Our current design always sends the notification to the Opportunity Owner (the BD user assigned to the deal), in addition to the named recipient list.

**Question:** Are there any situations where the Owner should NOT receive the email?

For example:
- If the Owner is a former employee whose account is inactive
- If the Owner is a system or integration account rather than a person
- If the deal was reassigned and the new Owner should not receive historical loss notifications

Our current default is: Owner always included with no exceptions.

If you want exceptions, please describe them and we will add the logic.

**Decision needed from:** Commercial

---

## Decision 7 — How should the link to the Salesforce record work?

**Background:** The review email will contain a button or link that opens the Opportunity record directly in Salesforce. We need to know how to construct that link so it works when the system goes live in production.

**Three options:**

**Option A — Custom Label (recommended)**
We create a configuration value in Salesforce that stores the production URL (e.g. `https://astrumcro.my.salesforce.com`). The link in the email is built from this value. When the system moves from sandbox to production, only the configuration value needs to change — not the automation itself.

**Option B — Relative link**
The link in the email is a short path (e.g. `/006...`). It only works if the recipient is already logged into Salesforce in their browser. Simpler to build but less user-friendly.

**Option C — Accept sandbox URL for now**
We hardcode the sandbox URL for the moment and document that it must be manually updated before go-live. Accepted known limitation.

**Recommendation:** Option A. It takes approximately 30 minutes to set up and avoids a manual step before every environment promotion.

**Decision needed from:** Solution Architect (or IT if they own the production URL)

---

## Summary: what we still need from you

| # | Decision | Status | Owner | Required before build |
|---|---|---|---|---|
| 1 | Does `Lost/Cancelled/Declined to Bid` trigger the email? | **Open** | Commercial / Sales Ops | Yes |
| 2 | Which Business Categories are in scope? | **Open — 4 values unresolved** | Commercial | Yes |
| 3a | Phase I Unit recipient matrix (< €150k and >= €150k) | Provided — **awaiting confirmation** | Commercial | Yes |
| 3b | Phase I-NIS recipient matrix (< €500k and >= €500k) | Provided — **awaiting confirmation** | Commercial | Yes |
| 3c | S&PS recipient matrix | **Open — not provided** | Commercial | Yes |
| 3d | Recipient matrix for remaining 3 Business Category values | **Open — not provided** | Commercial | Yes |
| 4 | Threshold-duplication question on provided matrices | **Open — see above** | Commercial | Yes |
| 5 | Fallback rule for blank/unrecognised values | **Open** | Commercial | Yes |
| 6 | Loss Reason values correct, and blank handling rule | **Open** | BD Lead / Commercial | Yes |
| 7 | Owner always included — any exceptions? | **Open** | Commercial | Yes |
| 8 | Record link design for production | **Open** | Solution Architect | Before production go-live |

**Decisions 1 through 7 are needed before we can write a single line of automation.**

Decision 8 can be deferred until just before production go-live.

---

## To fully unblock SAL-10 — questions for the business

Please reply to the following five questions. Answers to all five are needed before build can start.

**Question 1 — S&PS and other deal types**
What should happen for the following deal types when a deal is Closed Lost?

- S&PS
- All Other Projects (Phase I - NIS)
- Phase I Clinical Conduct Portugal
- Site & Patient Services (CRP & MissionTEC)

For each, please tell us: who receives the email, or confirm that no email should be sent.

**Question 2 — Blank or missing information**
If an Opportunity is marked Closed Lost but has no Business Category, or the Service Fees field is blank — what should happen?

Options: send to Opportunity Owner only, send to Tom Frearson and Catherine Canales plus Owner, send to a named fallback address, or do not send at all.

**Question 3 — The Lost/Cancelled/Declined to Bid stage**
Should the review email also fire when a deal moves to `Lost/Cancelled/Declined to Bid`? Or should it only fire for `Closed Lost`?

**Question 4 — Loss Reason field**
Please confirm that these nine Loss Reason values are correct and complete in Salesforce:
Astrum Capabilities, Cancelled, Cost, Declined to Bid, Geographical Coverage, Lost to Follow-up, Lost to Incumbent, Project Team Experience, Therapeutic Experience.

Also confirm: if a deal is closed lost with no Loss Reason selected, should the email still send (omitting that line), or should we block the send until a Loss Reason is entered?

**Question 5 — Provided matrix confirmation**
Please confirm the Phase I Unit and Phase I-NIS recipient lists above are correct, and clarify whether the same recipients apply regardless of deal size, or whether the lists for large deals should be different.

---

## What happens if decisions are delayed

Every week without these decisions is a week the Closed Lost notification is not active. Lost deals are not triggering a review. Loss reason data is not being systematically captured at the point of closure.

This notification is in the first build wave alongside the Closed Won and Critical Stage Progression notifications. Delaying it pushes the entire wave.

Please reply with your decisions or arrange a 30-minute call to work through them together.

---

**Do not build or activate the SAL-10 Flow until the remaining routing, fallback, trigger-stage, Loss Reason, and production-link decisions are confirmed in writing.**

---

*Astrum Orbit Programme — SAL-10 Closed Lost Review Notification*
*Technical implementation plan: PRDS/SAL-10-closed-lost-review-notification.md*
*Prepared: 25 April 2026*
