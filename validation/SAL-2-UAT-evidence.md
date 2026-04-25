# SAL-2 UAT Evidence

**Flow:** Notify Critical Stage Progression After Save  
**Org:** `astrum--astrumpar.sandbox.my.salesforce.com`  
**Executed by:** `amit.kumar@astrumcro.com.astrumpar`  
**Date:** 2026-04-25  
**Evidence method:** Anonymous Apex via `sf apex run`. Flow execution confirmed by named code unit `Notify_Critical_Stage_Progression_After_Save` in ApexLog limit-check records. No-fire confirmed by after-save Flow unit duration <5ms vs 179–560ms for full execution.

## Test Opportunities

| ID | Name | Notes |
|---|---|---|
| `006UD00000HKKFLYA5` | Test code 1 | Primary test opp; `Opportunity_Code__c = TES-0031` |
| `006UD00000FzZ3RYAV` | Test Ippty | Used for HP-03 (75→90 transition) |
| `006UD00000G8fMZYAZ` | Phase 4 - Spain - Dermatology | Used for IDEM-01 (already at 75, Description-only update) |

---

## HP — Happy Path (Flow MUST fire)

| ID | Scenario | Opp | Δ Opp_Probability__c | Flow unit duration | Result |
|---|---|---|---|---|---|
| HP-01 | Standard trigger | HKKFLYA5 | 50→75 | **383ms** | PASS |
| HP-02 | High target | HKKFLYA5 | 50→90 | **209ms** | PASS |
| HP-03 | Both values in trigger set | FzZ3RYAV | 75→90 | **424ms** | PASS |
| HP-04 | Blank `Opportunity_Code__c` | HKKFLYA5 | 50→90 | **415ms** | PASS |
| HP-05 | 7 blank payload fields | HKKFLYA5 | 50→75 | **320ms** | PASS |
| HP-06 | Non-zero, non-target source | HKKFLYA5 | 25→75 | **179ms** | PASS |

HP-01 additionally confirmed by explicit named code unit in ApexLog:

```
CODE_UNIT_STARTED|[EXTERNAL]|limit check|Notify_Critical_Stage_Progression_After_Save
CODE_UNIT_FINISHED|Notify_Critical_Stage_Progression_After_Save
```

---

## IDEM — Idempotency (Flow must NOT fire)

| ID | Scenario | Opp | Change | Flow unit duration | Result |
|---|---|---|---|---|---|
| IDEM-01 | Edit non-probability field on opp at 75 | G8fMZYAZ | Description only | **<1ms** | PASS |
| IDEM-02 | Resave opp at 90 without changing probability | FzZ3RYAV | Description only | **<1ms** | PASS |
| IDEM-03 | Downward move | HKKFLYA5 | 75→50 | **<1ms** | PASS |
| IDEM-04 | Neither value is 75 or 90 | HKKFLYA5 | 25→50 | **<1ms** | PASS |

`IsChanged` operator confirmed working: Flow entry criteria check completes in <1ms when `Opp_Probability__c` is unchanged between saves.

---

## BYP — Bypass Logic

| ID | Scenario | `Bypass_Flow` permission | Flow unit duration | Result |
|---|---|---|---|---|
| BYP-01 | Trigger with permission active | `true` — verified `FeatureManagement.checkPermission('Bypass_Flow') = true` | **3.28ms** (entered, evaluated `Check_Bypass_Permission`, took `Bypassed` outcome) | PASS |
| BYP-02 | Trigger after permission removed | `false` — PSA deleted, verified in fresh Apex session | **366ms** | PASS |

PermissionSet `Test_Bypass_Flow_SAL2` created and deleted during test. Org is clean post-test.

---

## CRE — Creation Exclusion

| ID | Scenario | Result |
|---|---|---|
| CRE-01 | Insert new Opportunity with `Opp_Probability__c=75` | PASS — no named limit-check log generated; `recordTriggerType=Update` excluded the insert |

---

## Exit Criteria (PRD §10.5)

All 13 test cases PASS.

| Criterion | Status |
|---|---|
| HP-01–HP-06: Flow fires for all valid trigger transitions | PASS |
| IDEM-01–IDEM-04: No duplicate sends on unchanged saves or non-target transitions | PASS |
| BYP-01–BYP-02: Bypass permission honoured and reversed correctly | PASS |
| CRE-01: Creation excluded by `recordTriggerType=Update` | PASS |
| No DML rollbacks on any execution | PASS |
| Blank fields rendered gracefully (no fault path taken) | PASS |

---

## Post-test data state

| Item | State |
|---|---|
| `006UD00000HKKFLYA5` `Opportunity_Code__c` | Restored to `TES-0031` |
| `006UD00000HKKFLYA5` `Opp_Probability__c` | 75 (last BYP-02 trigger value) |
| Test PermissionSet `Test_Bypass_Flow_SAL2` | Deleted |
| Trace flag and FlowTrace debug level | Deleted |
