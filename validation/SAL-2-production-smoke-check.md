# SAL-2 Production Smoke Test Plan

**Flow:** Notify Critical Stage Progression After Save
**Programme:** Astrum Orbit — notification 2 of 14
**Org:** astrum-prod (`https://astrum.my.salesforce.com`)
**Prepared:** 2026-04-25
**Status:** PLAN — awaiting approval before execution

---

## Pre-test confirmation status

| Check | Result |
|---|---|
| Git working tree clean | PASS — commit 1c5f252 |
| Evidence files present | PASS — all 5 files confirmed |
| Study_Countries__c in payload | NOTE — IS included (by design per SAL-2 PRD). Check expectation was inverted. Not a defect. |
| Record link uses Salesforce_Base_URL | PASS — `{!$Label.Salesforce_Base_URL}/{!Get_Opportunity_Detail.Opportunity_ID_18__c}` |
| Flow active in production | PASS — ActiveVersionId 301TY00000rVYYPYA4 |

---

## 1. Record selected

**Opportunity:** Ketamine BE study
**Opportunity Code:** ADP1005
**Salesforce ID:** 006TY00000qpSxEYAU (15-char) / `006TY00000qpSxEYAU` (18-char formula)

Rationale for selection: Pre-Identification stage, null current probability, clear
early-stage scientific study. No active proposal in flight. Safest available record
for a change that will send live emails to five business recipients.

---

## 2. Current field values

| Field | API Name | Current Value |
|---|---|---|
| Opportunity Name | Name | Ketamine BE study |
| Account | Account.Name | Adragos Pharma |
| Stage | StageName | Pre-Identification |
| Probability (custom) | Opp_Probability__c | null (blank) |
| Opportunity Code | Opportunity_Code__c | ADP1005 |
| Owner | Owner.Name | Pedro Francisco |
| ID 18 (formula) | Opportunity_ID_18__c | 006TY00000qpSxEYAU |
| Close Date | CloseDate | 2027-01-01 |

---

## 3. Proposed change

Set `Opp_Probability__c` from `null` → `75`

This satisfies Flow entry conditions:
- Condition A: `Opp_Probability__c = 75` — TRUE
- Condition B: `Opp_Probability__c = 90` — FALSE
- Condition C: `Opp_Probability__c IsChanged` — TRUE (null → 75)
- Custom logic `(A OR B) AND C` — TRUE

The Flow will proceed past `Check_Bypass_Permission` (running user does not hold
`Bypass_Flow` permission during this test), execute `Get_Opportunity_Detail`, and
call `Send_Critical_Stage_Alert` via `emailSimple`.

---

## 4. Expected email result

**Subject:**
```
Critical Stage Progression. Ketamine BE study moved to 75%
```

**Body (expected rendering):**
```
CRITICAL STAGE PROGRESSION ALERT

Account:                     Adragos Pharma
Opportunity:                 Ketamine BE study
Opportunity Code:            ADP1005

Previous Probability:        %       ← null renders as blank, literal % remains
New Probability:             75%
Stage:                       Pre-Identification
Service Fees:                [value or blank]
Close Date:                  2027-01-01

Study Countries:             [value or blank — field IS in payload per PRD]
Therapeutic Area:            [value or blank]
Indication:                  [value or blank]
Entities Providing Services: [value or blank]

Next Specific Action:        [value or blank]
Date of Next Action:         [value or blank]
Person Responsible:          [value or blank]

View record in Salesforce:
https://astrum.my.salesforce.com/006TY00000qpSxEYAU

---
This is an automated notification from Salesforce.
Please do not reply to this email.
```

Note: "Previous Probability: %" is expected. Prior value is null (field was blank).
The `%` is a literal suffix appended unconditionally. This is documented behaviour (L-01).

---

## 5. Recipient list

Five fixed recipients will receive a live email:

| Recipient | Address |
|---|---|
| RFP / RFI inbox | rfp.rfi@astrumcro.com |
| Jordi Picas | jordi.picas@astrumcro.com |
| Cristina Lopes | cristina.lopes@astrumcro.com |
| Anthony Gibson | anthony.gibson@astrumcro.com |
| Vania Araujo | vania.araujo@astrumcro.com |

**This is a live production email send. Recipients will receive a real email.**
Advise recipients in advance if needed to avoid alarm.

---

## 6. Evidence to capture

After the Opportunity update:

| Evidence item | How to capture |
|---|---|
| Flow executed | ApexLog query: `SELECT Id, Application, DurationMilliseconds FROM ApexLog WHERE LogUserId = '<UserId>' ORDER BY StartTime DESC LIMIT 5` — expect duration > 150ms |
| Flow named in log | Second log entry named `Notify_Critical_Stage_Progression_After_Save` in limit-check position |
| Email received | Confirm at least one recipient receives the email and record link opens `https://astrum.my.salesforce.com/006TY00000qpSxEYAU` |
| Opportunity state after | Re-query `Opp_Probability__c` to confirm it is `75` |
| Revert confirmation | Re-query after revert to confirm `Opp_Probability__c` is null and no second email fires |

---

## 7. Risk assessment

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Recipients alarmed by test email | Medium — recipients are real business users | Medium — causes confusion | Advise recipients in advance or accept low cosmetic risk at Pre-Identification stage |
| Other automations fire | Low — check below | Low–Medium | See automation check |
| Record saved incorrectly | Very low | Low | Standard Salesforce DML; can be reverted immediately |
| Email not delivered | Low — org deliverability is live | Blocks smoke test | Check Setup > Deliverability is All Email before running |
| Flow does not fire | Low — verified Active | Blocks smoke test | Check ApexLog immediately after save |
| "Previous Probability: %" appears in email | Certain — null prior value | Cosmetic only | Documented expected behaviour (L-01); not a defect |

### Other automations likely to fire

The production org contains the following Flows observed during RunLocalTests validation:
- `AUTO_Send_Follow_UP_Email` — likely email-related; trigger object unknown
- `Opportunity_Pipeline_Category_Auto_Update` — likely fires on Opportunity DML; may update a pipeline category field
- `Oppty_Code` — likely fires on Opportunity DML; counter/code logic; ADP1005 already has a code so unlikely to alter it

**Assessment:** `Opportunity_Pipeline_Category_Auto_Update` and `Oppty_Code` may fire
on this Opportunity save. Neither is expected to interfere with the SAL-2 email send
or the Opportunity record in a harmful way. Monitor the record after save for unexpected
field changes.

---

## 8. Backout / restore approach

**After smoke test:**

Set `Opp_Probability__c` back to `null` (blank / empty value).

**Will revert trigger a second SAL-2 email?**

No. The Flow entry conditions require `Opp_Probability__c = 75 OR = 90`. Setting the
field from `75` back to `null` fails both value conditions — the Flow does not enter.
The revert is safe. No second email will be sent.

**Revert command (anonymous Apex):**
```apex
Opportunity opp = [SELECT Id, Opp_Probability__c FROM Opportunity
                   WHERE Id = '006TY00000qpSxEYAU' LIMIT 1];
opp.Opp_Probability__c = null;
update opp;
```

---

## 9. Approval statement

**Approval required before execution.**

This smoke test will:
- Set `Opp_Probability__c` to `75` on Opportunity `ADP1005` (Ketamine BE study, Adragos Pharma)
  in the production org `astrum-prod`
- Send a live email to five named business recipients
- Not affect any other record
- Be fully reversible by clearing `Opp_Probability__c` back to null

No deployment will be made. No metadata will be changed. This is a data-only operation
on a single Opportunity record.

---

## Execution results

*To be completed after approval and execution.*

| Item | Result |
|---|---|
| Opportunity updated | — |
| Flow log confirmed | — |
| Email received | — |
| Record link correct | — |
| Revert executed | — |
| Second email triggered on revert | — |
| Overall smoke test result | — |
