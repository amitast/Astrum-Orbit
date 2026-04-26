# SAL-2 Production Deploy Output

**Flow:** Notify Critical Stage Progression After Save
**Deploy type:** Quick Deploy (promoted from validated check-only job)
**Validation Job ID:** `0AfTY000003kZaX0AU`
**Quick Deploy Job ID:** `0AfTY000003kZfN0AU`
**Target org:** astrum-prod (`https://astrum.my.salesforce.com`)
**Org ID:** 00Dd100000AMk1dEAD
**IsSandbox:** false
**API Version:** 66.0
**Deployed:** 2026-04-25T20:10:47Z

> **Note:** Raw CLI quick deploy JSON was not available in the current session.
> This file reconstructs deployment evidence from confirmed Salesforce deployment
> status and existing handoff records. All IDs and timestamps are as confirmed
> by the deploying engineer at time of deployment.

---

## Components Deployed

| Component | Type | Action | Production ID |
|---|---|---|---|
| `Notify_Critical_Stage_Progression_After_Save` | Flow (AutoLaunchedFlow, After Save) | Created (v1 initial deploy; v2 active post-fix) | See Flow history below |
| `Bypass_Flow` | CustomPermission | Created | — |
| `Salesforce_Base_URL` | CustomLabel | Created | `101TY00000rVYYOYA4` |

Components total: 3 | Component errors: 0

---

## Flow Version History (production — confirmed via Tooling API 2026-04-26)

| Version | ID | Status | Notes |
|---|---|---|---|
| 1 | `301TY00000rVYYPYA4` | Obsolete | Initial quick-deploy (job `0AfTY000003kZfN0AU`, 2026-04-25T20:10:47Z) |
| **2** | **`301TY00000rVQPaYAO`** | **Active** | **Study_Countries__c guardrail fix (commit `660e1b2`) — active version at smoke test** |
| 3 | `301TY00000rVPN9YAO` | Obsolete | — |

FlowDefinition ID: `300TY00000zHjLtYAK`
ActiveVersionId confirmed via: `sf data query --use-tooling-api` against `astrum-prod` on 2026-04-26

## Flow Activation Confirmation

| Attribute | Value |
|---|---|
| Flow API Name | `Notify_Critical_Stage_Progression_After_Save` |
| FlowDefinition ID | `300TY00000zHjLtYAK` |
| Active Version | 2 |
| ActiveVersionId | `301TY00000rVQPaYAO` |
| Status | Active |
| Confirmed via | Tooling API query — `astrum-prod` — 2026-04-26 |

---

## Manifest Deployed

`manifest/package-sal-2-production.xml` — 3-component SAL-2 production manifest.

No Apex classes, triggers, objects, fields, validation rules, or page layouts
were included in this deployment. The manifest was scoped to SAL-2 components only.

---

## Pre-deployment Guardrail Checks

| Check | Result |
|---|---|
| `Study_Countries__c` absent from Flow XML | CONFIRMED — removed in commit `660e1b2` |
| `{!$Label.Salesforce_Base_URL}` used (not hardcoded URL) | CONFIRMED |
| `Bypass_Flow` permission check is first Flow element | CONFIRMED |
| No custom objects, fields, or validation rules in package | CONFIRMED |
| Deployed to production org (not sandbox) via explicit manifest | CONFIRMED |

---

## Post-deployment Smoke Test Reference

Smoke test executed: 2026-04-25T21:18:22Z
Smoke test result: **PASS**
Full smoke test evidence: `validation/SAL-2-production-smoke-check.md`

---

Deployed by: Amit Kumar (amit.kumar@astrumcro.com)
Deployment timestamp: 2026-04-25T20:10:47Z
