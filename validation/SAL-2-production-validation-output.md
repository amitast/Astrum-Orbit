# SAL-2 Production Validation Output

**Flow:** Notify Critical Stage Progression After Save
**Validation Job ID:** `0AfTY000003kZaX0AU`
**Status:** Succeeded (checkOnly — nothing deployed)
**Target org:** astrum-prod (`https://astrum.my.salesforce.com`)
**Org ID:** 00Dd100000AMk1dEAD
**IsSandbox:** false
**Test level:** RunLocalTests
**API Version:** 66.0
**Started:** 2026-04-25T19:52:41Z
**Completed:** 2026-04-25T19:52:49Z

---

## Component Validation Results

| Component | Type | Action | Result |
|---|---|---|---|
| `Salesforce_Base_URL` | CustomLabel | Created | PASS |
| `Bypass_Flow` | CustomPermission | Created | PASS |
| `Notify_Critical_Stage_Progression_After_Save` | Flow | Created | PASS |

Components total: 3 | Component errors: 0

---

## Apex Test Results

Tests run: 10 | Failures: 0 | Total time: 1,986ms

| Test class | Method | Time | Result |
|---|---|---|---|
| ChangePasswordControllerTest | testChangePasswordController | 81ms | PASS |
| CommunitiesLandingControllerTest | testCommunitiesLandingController | 89ms | PASS |
| CommunitiesLoginControllerTest | testCommunitiesLoginController | 87ms | PASS |
| CommunitiesSelfRegConfirmControllerTest | testCommunitiesSelfRegConfirmController | 82ms | PASS |
| CommunitiesSelfRegControllerTest | testCommunitiesSelfRegController | 86ms | PASS |
| ForgotPasswordControllerTest | testForgotPasswordController | 83ms | PASS |
| MicrobatchSelfRegControllerTest | testMicrobatchSelfRegController | 86ms | PASS |
| MyProfilePageControllerTest | testSave | 1,026ms | PASS |
| SiteLoginControllerTest | testSiteLoginController | 81ms | PASS |
| SiteRegisterControllerTest | testRegistration | 87ms | PASS |

All 10 tests are standard Salesforce Communities/Sites/Portal platform tests.
None are related to SAL-2. All passed. No SAL-2 Apex was deployed.

---

## Code Coverage Summary

Coverage data returned for 11 Apex classes (standard platform classes only).
No coverage warnings. No SAL-2 Apex classes in scope.

Classes with partial coverage (pre-existing, not SAL-2):
- FetchAccountInfo: 0/15 lines covered
- CommunitiesSelfRegController: 32/42 lines covered
- MicrobatchSelfRegController: 32/40 lines covered
- SiteRegisterController: 22/27 lines covered
- MyProfilePageController: 21/24 lines covered
- CommunitiesSelfRegConfirmController: 9/9 lines covered
- ForgotPasswordController: 8/9 lines covered

These are pre-existing org classes unrelated to SAL-2. No coverage requirement
applies to this deployment (no SAL-2 Apex deployed).

---

## Flow Coverage

6 pre-existing org flows have 0 test coverage (unrelated to SAL-2):
- AUTO_Send_Follow_UP_Email
- AUTO_Send_Mail_Flow
- Consumption_Threshold_Alerts1
- Opportunity_Pipeline_Category_Auto_Update
- Oppty_Code
- flow_dTRoE8GsNcnbdzHE

No flow coverage warnings raised. SAL-2 flow was not run by tests (expected —
flow fires on live Opportunity DML, not unit tests).

---

## Git State at Validation

Branch: feature/SAL-2-critical-stage-progression-alert

Changes included in this validation (relative to last commit 885b88a):
- force-app/main/default/flows/Notify_Critical_Stage_Progression_After_Save.flow-meta.xml
  - Flow description updated (removed "sandbox only - never production")
  - Email_Body description updated (OD-02 marked resolved)
  - Hardcoded sandbox URL replaced with {!$Label.Salesforce_Base_URL}
- force-app/main/default/labels/CustomLabels.labels-meta.xml (new)
  - Salesforce_Base_URL = https://astrum.my.salesforce.com
- manifest/package-sal-2-production.xml (new)
  - 3-component SAL-2 production manifest

Unrelated dirty file (not in deployment package):
- .vscode/settings.json (VS Code editor setting only)

---

## Quick Deploy Command (do not run without explicit approval)

```bash
sf project deploy quick \
  --job-id 0AfTY000003kZaX0AU \
  --target-org astrum-prod \
  --wait 60 \
  --json
```

Validated by: Amit Kumar (amit.kumar@astrumcro.com)
Validation timestamp: 2026-04-25T19:52:49Z
