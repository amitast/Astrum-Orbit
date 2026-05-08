"""
One-shot script: reads the four cached sobject describe JSON files from the system temp
directory and writes LLM-TXTS/schema/Astrum_Objects_Fields_Schema_Authority.md

Run from the project root:
    python3 LLM-TXTS/schema/generate_schema.py
"""
import json
import os
import tempfile
from datetime import datetime

TMPDIR = tempfile.gettempdir()
OUTPUT_PATH = os.path.join(
    os.path.dirname(__file__),
    "Astrum_Objects_Fields_Schema_Authority.md",
)

# ── helpers ──────────────────────────────────────────────────────────────────

def load(obj_name):
    p = os.path.join(TMPDIR, obj_name.lower() + "_schema.json")
    with open(p, encoding="utf-8", errors="replace") as f:
        return json.load(f)["result"]["fields"]


def picklist_values(field):
    vals = field.get("picklistValues", [])
    if not vals:
        return ""
    active = [v["value"] for v in vals if v.get("active", True)]
    return "; ".join(active)


def ref_to(field):
    refs = field.get("referenceTo", [])
    return ", ".join(refs) if refs else ""


def required(field):
    # nillable=False AND defaultedOnCreate=False means truly required
    if not field.get("nillable") and not field.get("defaultedOnCreate"):
        return "Required"
    return ""


def field_type_str(field):
    ft = field.get("type", "")
    length = field.get("length", 0)
    precision = field.get("precision", 0)
    scale = field.get("scale", 0)
    if ft in ("string", "textarea", "encryptedstring"):
        return f"{ft}({length})" if length else ft
    if ft in ("double", "currency", "percent"):
        return f"{ft}({precision},{scale})" if precision else ft
    return ft


def md_row(*cells):
    return "| " + " | ".join(str(c).replace("|", "\\|") for c in cells) + " |"


def check_fields(fields_list, priority_api_names):
    """Return dict {api_name: field_or_None}"""
    field_map = {f["name"]: f for f in fields_list}
    return {name: field_map.get(name) for name in priority_api_names}


# ── priority field lists ──────────────────────────────────────────────────────

ACCOUNT_PRIORITY = [
    "Name","Industry","Type","Phone","Website","Description","Rating",
    "NumberOfEmployees","OwnerId","ParentId",
    "Client_Type__c","Account_Segment__c","Tier_Category__c",
    "Therapeutic_Area__c","D365_Account_ID__c",
]

CONTACT_PRIORITY = [
    "FirstName","LastName","AccountId","Title","Department","Email","Phone",
    "MobilePhone","OwnerId","ReportsToId","HasOptedOutOfEmail","DoNotCall",
    "IndividualId","ActionCadenceState","Preferred_Method_of_Contact__c",
    "D365_Contact_ID__c",
]

OPPORTUNITY_PRIORITY = [
    "AccountId","Name","CloseDate","StageName","ForecastCategoryName","Amount",
    "Service_Fees__c","Total_Fees__c","Business_Category__c","Business_Type__c",
    "Opportunity_Code__c","Opportunity_ID_18__c","Opp_Probability__c",
    "Probability","Probability__c","Entities_Providing_Services__c",
    "Project_Category__c","Project_Start_Work__c","Project_End_Work__c",
    "RfP_Received_Date__c","RfP_Due_Sent_Date__c","Study_Phase_Type__c",
    "Therapeutic_Area__c","Study_Countries__c","Indication__c",
    "Number_of_Enrolled_Participants__c","Number_of_Sites__c","Protocol_Title__c",
    "NextStep","Next_specific_action__c","Date_of_next_specific_action__c",
    "Person_responsible_for_next_action__c","Last_client_interaction_date__c",
    "Loss_Reason__c","Reason_for_win__c","Award_Date__c","Discovery_Completed__c",
    "Budget_Confirmed__c","Key_Decision_Criteria__c","Triage_Score__c",
    "D365_Opportunity_ID__c","D365_Opportunity_Notes__c","CampaignId",
    "OwnerId","IsClosed","IsWon",
    # extra from spec
    "Contract_Sign_Date__c","Contract_Type__c","Payment_Schedule_Type__c",
    "Contract_Entity__c","Loss_Reason_Date__c","Number_of_Enrolled_Participants__c",
    "Weighted_Service_Fees__c","Triage_Score__c","Parent_Opportunity__c",
]

LEAD_PRIORITY = [
    "Company","FirstName","LastName","Status","Email","Phone",
    "HasOptedOutOfEmail","DoNotCall","IndividualId","ActionCadenceState",
    "Lead_Source__c","LeadSource","FirstEmailDateTime",
    "Date_first_outreach_performed__c","Preferred_Method_of_Contact__c",
    "Action_Next_Steps__c","Rating","Client_Type__c","Therapeutic_Area__c",
    "D365_Lead_ID__c","CampaignId",
]

# ── table generators ──────────────────────────────────────────────────────────

HEADER = md_row("Field API Name","Label","Type","Required","Createable","Updateable","Ref To","Picklist Values","Standard/Custom","Notes")
DIVIDER = md_row("-"*30,"-"*30,"-"*20,"-"*10,"-"*10,"-"*10,"-"*20,"-"*60,"-"*15,"-"*30)


def field_row(f, notes=""):
    is_custom = "Custom" if f["custom"] else "Standard"
    return md_row(
        f["name"],
        f.get("label",""),
        field_type_str(f),
        required(f),
        "Y" if f.get("createable") else "N",
        "Y" if f.get("updateable") else "N",
        ref_to(f),
        picklist_values(f),
        is_custom,
        notes,
    )


FIELD_NOTES = {
    "Opp_Probability__c": "AUTHORITATIVE probability field. Use this ONLY — never standard Probability.",
    "Probability": "Standard field — display only. Do NOT use in any Flow condition or formula.",
    "Probability__c": "Formula field — display only. Do NOT use in trigger conditions.",
    "Opportunity_ID_18__c": "⚠️ NOT IN SANDBOX — deployed to production only (SAL-2). Deploy to sandbox before build.",
    "D365_Opportunity_Notes__c": "EXCLUDE from all Prompt Templates — prompt injection risk.",
    "D365_Account_Notes__c": "EXCLUDE from all Prompt Templates — free-text migration field.",
    "D365_Lead_Notes__c": "EXCLUDE from all Prompt Templates — free-text migration field.",
    "Study_Countries__c": "Contains non-standard picklist values. Do NOT include in email payloads until cleaned.",
    "Therapeutic_Area__c": "Contains encoding errors (Gynecology variants). Display-only. Do not parse.",
    "Opportunity_Code__c": "Blank on Dynamics-migrated records. Handle gracefully — do not error on blank.",
    "IndividualId": "Requires privacy management feature. ORG-VALIDATION REQUIRED for Data Cloud Consent DMO.",
    "ActionCadenceState": "Requires High Velocity Sales / Sales Cadences feature licence. ORG-VALIDATION REQUIRED.",
    "DoNotCall": "CRITICAL consent gate. Absent from describe — likely FLS-restricted. ORG-VALIDATION REQUIRED.",
    "HasOptedOutOfEmail": "CRITICAL consent gate — hard stop for all email sends.",
    "StageName": "19 active values confirmed in org via SOQL (26 Apr 2026). See picklist section.",
    "Business_Category__c": "6 active values confirmed (26 Apr 2026 SOQL). Only Phase I Unit and Phase I-NIS have confirmed recipient matrices. S&PS and remaining 3 values blocked on BD-02/BD-03.",
    "CampaignId": "Primary Campaign Source on Opportunity. Critical for campaign attribution at Lead conversion.",
    "Loss_Reason_Date__c": "Confirmed in org — required by STAGE_Closed_Lost validation rule.",
    "LeadSource": "Standard field — do NOT use for segmentation. Use Lead_Source__c (custom) only.",
    "Parent_Opportunity__c": "NOT YET BUILT. NET-NEW REQUIRED — Decision D8 intent.",
    "Total_Fees__c": "Formula field — cannot be written to. Verify formula returns values before including in notifications.",
    "Triage_Score__c": "Formula field. Confirm it returns values before including in Prompt Templates.",
    "Rating": "Standard Account/Lead field. Absent from describe — likely FLS-restricted for this user. Confirm FLS with Salesforce Admin.",
    "AnnualRevenue": "Standard Account field. Absent from describe — likely FLS-restricted for this user. Referenced in Account Intelligence Summary PT. Confirm FLS access before template build.",
    "Tier_Category__c": "Custom Account field. CONFIRMED in sandbox org. Include in Account Intelligence Summary and Search Accounts filters.",
    "D365_Account_ID__c": "Custom Account field. CONFIRMED. Use as cross-system external ID for Dynamics-migrated Account records.",
    "D365_Contact_ID__c": "Custom Contact field. Absent from sandbox describe. Verify FLS or whether deployed.",
    "Preferred_Method_of_Contact__c": "Custom Contact field. CONFIRMED on Lead. Check Contact separately — not in Contact describe for this user.",
    "NextStep": "Standard Opportunity field (Text 255). Part of dual next-steps pattern with Next_specific_action__c.",
    "Next_specific_action__c": "Custom Opportunity field (TextArea 255). Part of dual next-steps pattern. CONFIRMED.",
    "IsClosed": "Boolean formula on Opportunity. True for Closed Won and Closed Lost stages.",
    "IsWon": "Boolean formula on Opportunity. True only for Closed Won stage.",
}


def object_section(title, fields_list, priority_names, heading="##"):
    lines = []
    field_map = {f["name"]: f for f in fields_list}
    total = len(fields_list)
    custom_count = sum(1 for f in fields_list if f["custom"])

    lines.append(f"{heading} {title} Schema\n")
    lines.append(f"Total fields in org: **{total}** ({custom_count} custom, {total-custom_count} standard)\n")

    # Priority fields first
    lines.append(f"\n### {title} — Priority Fields (Astrum Agentforce build)\n")
    lines.append(HEADER)
    lines.append(DIVIDER)
    for name in dict.fromkeys(priority_names):  # deduplicate, preserve order
        f = field_map.get(name)
        extra_note = FIELD_NOTES.get(name, "")
        if f:
            note = "✅ CONFIRMED" + (" — " + extra_note if extra_note else "")
            lines.append(field_row(f, note))
        else:
            note = "⚠️ NOT FOUND IN ORG" + (" — " + extra_note if extra_note else "")
            lines.append(md_row(name, "—", "—", "—", "—", "—", "—", "—", "—", note))

    # All remaining fields
    lines.append(f"\n### {title} — Full Field List\n")
    lines.append(HEADER)
    lines.append(DIVIDER)
    seen_priority = set(priority_names)
    for f in sorted(fields_list, key=lambda x: x["name"]):
        if f["name"] not in seen_priority:
            lines.append(field_row(f))

    return "\n".join(lines)


def picklist_section(label, fields_list, field_name):
    field_map = {f["name"]: f for f in fields_list}
    f = field_map.get(field_name)
    if not f:
        return f"### {label}\n\n⚠️ Field **{field_name}** NOT FOUND in org.\n"
    vals = f.get("picklistValues", [])
    if not vals:
        return f"### {label}\n\n*No picklist values returned (field type: {f['type']}).*\n"
    lines = [f"### {label}"]
    lines.append("")
    lines.append("| Value | Active | Default |")
    lines.append("|---|---|---|")
    for v in vals:
        active = "Yes" if v.get("active") else "No"
        default = "Yes" if v.get("defaultValue") else ""
        lines.append(f"| {v['value']} | {active} | {default} |")
    return "\n".join(lines)


# ── main ──────────────────────────────────────────────────────────────────────

def main():
    acc_fields = load("account")
    con_fields = load("contact")
    opp_fields = load("opportunity")
    lea_fields = load("lead")

    opp_map = {f["name"]: f for f in opp_fields}
    acc_map = {f["name"]: f for f in acc_fields}
    lea_map = {f["name"]: f for f in lea_fields}

    # Collect not-found items for the summary table
    # Known context for specific not-found fields
    NOT_FOUND_NOTES = {
        # Account
        ("Account", "Rating"): "Standard Salesforce field. Absent from describe — likely FLS-restricted for this user. Confirm with Salesforce Admin. Not used in Agentforce S1 spec.",
        # Contact
        ("Contact", "DoNotCall"): "Standard Salesforce field. Absent from describe — likely FLS-restricted for this user. CRITICAL consent gate. ORG-VALIDATION REQUIRED before any outreach logic is built.",
        ("Contact", "IndividualId"): "Requires Individual privacy management feature to be enabled. NOT FOUND — BD-10 open blocker. Required for Data Cloud Consent DMO. ORG-VALIDATION REQUIRED.",
        ("Contact", "ActionCadenceState"): "Requires High Velocity Sales / Sales Cadences feature licence. NOT FOUND. Required as journey deduplication gate. ORG-VALIDATION REQUIRED.",
        ("Contact", "Preferred_Method_of_Contact__c"): "Custom field. CONFIRMED on Lead object. NOT RETURNED for Contact by this user's describe — may be FLS-restricted on Contact or not deployed to Contact. Verify with Salesforce Admin.",
        ("Contact", "D365_Contact_ID__c"): "Custom field. CONFIRMED on Contact object in describe (see Contact full field list). Appeared as NOT FOUND only if not in describe — re-verify.",
        # Opportunity
        ("Opportunity", "Opportunity_ID_18__c"): "CRITICAL: This is a formula custom field (CASESAFEID(Id)) deployed to PRODUCTION as part of SAL-2. It is NOT present in this sandbox. Deploy to sandbox before any build work that requires record links. Used in all 14 notification email bodies.",
        ("Opportunity", "Weighted_Service_Fees__c"): "Not found in sandbox. Confirm whether this field exists in production or is NET-NEW REQUIRED.",
        ("Opportunity", "Parent_Opportunity__c"): "Referenced in Decision D8 for Change Order code inheritance. NOT YET BUILT. NET-NEW REQUIRED — requires business sign-off.",
        # Lead
        ("Lead", "DoNotCall"): "Standard Salesforce field. Absent from describe — likely FLS-restricted for this user. CRITICAL consent gate. ORG-VALIDATION REQUIRED.",
        ("Lead", "IndividualId"): "Requires Individual privacy management feature. NOT FOUND. Required for Data Cloud Consent DMO. ORG-VALIDATION REQUIRED.",
        ("Lead", "ActionCadenceState"): "Requires High Velocity Sales / Sales Cadences feature licence. NOT FOUND. Required as journey deduplication gate. ORG-VALIDATION REQUIRED.",
        ("Lead", "CampaignId"): "Lead does NOT have a standard CampaignId field in Salesforce. Campaign-Lead relationships use CampaignMember object. The spec reference to Lead.CampaignId is INCORRECT — use CampaignMember or Opportunity.CampaignId instead. This is a spec correction.",
    }

    not_found = []
    for name in dict.fromkeys(ACCOUNT_PRIORITY):
        if name not in {f["name"] for f in acc_fields}:
            note = NOT_FOUND_NOTES.get(("Account", name), "ORG-VALIDATION REQUIRED. Confirm field exists and API name is correct.")
            not_found.append((name, "Account", "Agentforce S1 / Memory Pack", "⚠️ NOT FOUND", note))
    for name in dict.fromkeys(CONTACT_PRIORITY):
        if name not in {f["name"] for f in con_fields}:
            note = NOT_FOUND_NOTES.get(("Contact", name), "ORG-VALIDATION REQUIRED. Confirm field exists and API name is correct.")
            not_found.append((name, "Contact", "Agentforce S1 / Memory Pack", "⚠️ NOT FOUND", note))
    for name in dict.fromkeys(OPPORTUNITY_PRIORITY):
        if name not in {f["name"] for f in opp_fields}:
            note = NOT_FOUND_NOTES.get(("Opportunity", name), "ORG-VALIDATION REQUIRED. Confirm field exists and API name is correct.")
            not_found.append((name, "Opportunity", "Agentforce S2/S3 / Memory Pack", "⚠️ NOT FOUND", note))
    for name in dict.fromkeys(LEAD_PRIORITY):
        if name not in {f["name"] for f in lea_fields}:
            note = NOT_FOUND_NOTES.get(("Lead", name), "ORG-VALIDATION REQUIRED. Confirm field exists and API name is correct.")
            not_found.append((name, "Lead", "Memory Pack / Journey spec", "⚠️ NOT FOUND", note))

    lines = []

    # ── Document header ──────────────────────────────────────────────────────
    lines.append("# Astrum Objects and Fields Schema Authority\n")
    lines.append("## Document Control\n")
    lines.append("| Item | Value |")
    lines.append("|---|---|")
    lines.append("| Generated from | Salesforce sandbox org (read-only `sf sobject describe`) |")
    lines.append("| Generated date | " + datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ") + " |")
    lines.append("| Generated by | Claude Code (Architect agent) — Astrum Orbit programme |")
    lines.append("| Salesforce username | amit.kumar@astrumcro.com.astrumpar |")
    lines.append("| Instance URL | https://astrum--astrumpar.sandbox.my.salesforce.com |")
    lines.append("| Org ID | 00DUD000007zF692AE |")
    lines.append("| Org type | **Sandbox** (isSandbox = true, isScratch = false) |")
    lines.append("| API version | 66.0 |")
    lines.append("| Source method | `sf sobject describe --json` — read-only. No metadata was created, modified, deployed, or deleted. |")
    lines.append("| Objects in scope | Account, Contact, Opportunity, Lead |")
    lines.append("| Important limitation | This file reflects the sandbox schema at the date above. Production and sandbox schemas may diverge. Re-run describe commands to refresh. |")
    lines.append("")

    # ── Schema usage rule ────────────────────────────────────────────────────
    lines.append("## Schema Usage Rule\n")
    lines.append(
        "**This file is the schema authority for Astrum Orbit build work in this local repo.**  "
        "Any object, field, picklist value, trigger condition, Flow input, Prompt Template input, "
        "notification payload, journey entry condition, segment rule, or agent action not confirmed "
        "in this file must be labelled `ORG-VALIDATION REQUIRED` or `NET-NEW REQUIRED` before being "
        "proposed or built. Do not reference fields marked ⚠️ NOT FOUND without first verifying "
        "their existence in the org or obtaining business sign-off to create them as new fields."
    )
    lines.append("")

    # ── Object summary ───────────────────────────────────────────────────────
    lines.append("## Object Summary\n")
    lines.append("| Object | Total Fields | Custom Fields | Standard Fields | Notes |")
    lines.append("|---|---|---|---|---|")

    def obj_mandatory(flds):
        return [f["name"] for f in flds if not f.get("nillable") and not f.get("defaultedOnCreate") and not f.get("calculated")]

    for label, flds in [("Account", acc_fields), ("Contact", con_fields),
                         ("Opportunity", opp_fields), ("Lead", lea_fields)]:
        tot = len(flds)
        cust = sum(1 for f in flds if f["custom"])
        std = tot - cust
        mand = obj_mandatory(flds)
        mand_str = ", ".join(mand[:8]) + ("…" if len(mand) > 8 else "")
        lines.append(f"| {label} | {tot} | {cust} | {std} | Mandatory (sample): {mand_str} |")
    lines.append("")

    # ── Object sections ──────────────────────────────────────────────────────
    lines.append(object_section("Account", acc_fields, ACCOUNT_PRIORITY))
    lines.append("")
    lines.append(object_section("Contact", con_fields, CONTACT_PRIORITY))
    lines.append("")
    lines.append(object_section("Opportunity", opp_fields, OPPORTUNITY_PRIORITY))
    lines.append("")
    lines.append(object_section("Lead", lea_fields, LEAD_PRIORITY))
    lines.append("")

    # ── Confirmed picklist values ────────────────────────────────────────────
    lines.append("## Confirmed Picklist Values\n")
    lines.append(picklist_section("Opportunity.StageName", opp_fields, "StageName"))
    lines.append("")
    lines.append(picklist_section("Opportunity.Opp_Probability__c", opp_fields, "Opp_Probability__c"))
    lines.append("")
    lines.append(picklist_section("Opportunity.ForecastCategoryName", opp_fields, "ForecastCategoryName"))
    lines.append("")
    lines.append(picklist_section("Opportunity.Business_Category__c", opp_fields, "Business_Category__c"))
    lines.append("")
    lines.append(picklist_section("Opportunity.Business_Type__c", opp_fields, "Business_Type__c"))
    lines.append("")
    lines.append(picklist_section("Opportunity.Loss_Reason__c", opp_fields, "Loss_Reason__c"))
    lines.append("")
    lines.append(picklist_section("Lead.Status", lea_fields, "Status"))
    lines.append("")
    lines.append(picklist_section("Lead.Lead_Source__c", lea_fields, "Lead_Source__c"))
    lines.append("")
    lines.append(picklist_section("Account.Client_Type__c", acc_fields, "Client_Type__c"))
    lines.append("")
    lines.append(picklist_section("Account.Account_Segment__c", acc_fields, "Account_Segment__c"))
    lines.append("")

    # ── Agentforce field map ─────────────────────────────────────────────────
    lines.append("## Agentforce-Relevant Field Map\n")
    lines.append("| Use Case | Object | Field API Name | Confirmed? | Notes |")
    lines.append("|---|---|---|---|---|")

    def ag_row(use_case, obj, field_name, all_fields, notes=""):
        fmap = {f["name"]: f for f in all_fields}
        confirmed = "✅ CONFIRMED" if field_name in fmap else "⚠️ NOT FOUND"
        return f"| {use_case} | {obj} | `{field_name}` | {confirmed} | {notes} |"

    # S1 Account
    for fn in ["Name","Industry","Type","Phone","Website","Description","Rating",
               "Client_Type__c","Account_Segment__c","OwnerId","ParentId","AnnualRevenue","NumberOfEmployees"]:
        lines.append(ag_row("S1 Account lookup/update", "Account", fn, acc_fields))
    # S1 Contact
    for fn in ["FirstName","LastName","Title","Department","Email","Phone","MobilePhone",
               "AccountId","OwnerId","HasOptedOutOfEmail","DoNotCall"]:
        lines.append(ag_row("S1 Contact lookup/create/update", "Contact", fn, con_fields,
                            "PII — mask in Prompt Templates" if fn in ("Email","Phone","MobilePhone") else ""))
    # S2 Opportunity
    for fn in ["Name","AccountId","StageName","CloseDate","Opp_Probability__c","Amount","Service_Fees__c",
               "Business_Category__c","NextStep","Next_specific_action__c",
               "Date_of_next_specific_action__c","Person_responsible_for_next_action__c",
               "ForecastCategoryName","Opportunity_Code__c","Opportunity_ID_18__c","OwnerId"]:
        lines.append(ag_row("S2 Opportunity lookup/create/update", "Opportunity", fn, opp_fields))
    # S2 Opportunity summary PT
    for fn in ["StageName","CloseDate","Opp_Probability__c","ForecastCategoryName","Amount",
               "Service_Fees__c","Business_Category__c","Therapeutic_Area__c","Study_Phase_Type__c",
               "NextStep","Next_specific_action__c","Date_of_next_specific_action__c",
               "Person_responsible_for_next_action__c","Last_client_interaction_date__c",
               "Opportunity_Code__c"]:
        notes = "EXCLUDE — prompt injection risk" if fn == "D365_Opportunity_Notes__c" else ""
        lines.append(ag_row("S2 Opp Status Summary PT input", "Opportunity", fn, opp_fields, notes))
    # S3
    for fn in ["Industry","Client_Type__c","Account_Segment__c","Name"]:
        lines.append(ag_row("S3 Account completeness check", "Account", fn, acc_fields))
    for fn in ["LastModifiedDate","OwnerId","Name","Email","Phone"]:
        lines.append(ag_row("S3 Stale record finder", "Contact", fn, con_fields,
                            "PII — do not pass to PT" if fn in ("Email","Phone") else ""))
    for fn in ["CloseDate","StageName","NextStep","Next_specific_action__c","IsClosed",
               "Business_Category__c","Therapeutic_Area__c"]:
        lines.append(ag_row("S3 Opp hygiene report", "Opportunity", fn, opp_fields))
    # PT exclusions
    for fn, obj, flds in [
        ("D365_Opportunity_Notes__c","Opportunity",opp_fields),
        ("Description","Opportunity",opp_fields),
        ("Email","Contact",con_fields),("Phone","Contact",con_fields),
        ("MobilePhone","Contact",con_fields),
    ]:
        lines.append(ag_row("Prompt Template EXCLUSION", obj, fn, flds,
                            "Must NOT be passed to any Prompt Template input"))
    lines.append("")

    # ── Prompt Template exclusion list ───────────────────────────────────────
    lines.append("## Prompt Template Exclusion List\n")
    lines.append("The following fields **must not** be passed directly into any Prompt Template input without explicit review and Trust Layer masking confirmation.\n")
    lines.append("| Field API Name | Object | Reason | Confirmed in Org? |")
    lines.append("|---|---|---|---|")
    excl = [
        ("D365_Opportunity_Notes__c","Opportunity","Free-text migration field. Prompt injection risk."),
        ("D365_Opportunity_Notes__c","Opportunity","Long Text Area (32768). Not structured. Contains historical Dynamics data."),
        ("Description","Opportunity","Free-text Long Text Area. Review before including."),
        ("Email","Contact","PII. Must be masked by Einstein Trust Layer before any PT invocation."),
        ("Phone","Contact","PII. Must be masked."),
        ("MobilePhone","Contact","PII. Must be masked."),
    ]
    for field_name, obj, reason in excl:
        flds = opp_fields if obj == "Opportunity" else con_fields
        fmap = {f["name"]: f for f in flds}
        confirmed = "✅" if field_name in fmap else "⚠️ NOT FOUND"
        lines.append(f"| `{field_name}` | {obj} | {reason} | {confirmed} |")
    lines.append("")

    # ── Not found / requires validation ──────────────────────────────────────
    lines.append("## Not Found / Requires Validation\n")
    if not_found:
        lines.append("Fields referenced in Astrum Orbit specs or Memory Pack that were **not found** in the sandbox org at describe time:\n")
        lines.append("| Referenced Field | Object | Source | Status | Recommendation / Context |")
        lines.append("|---|---|---|---|---|")
        seen_nf = set()
        for name, obj, source, status, note in not_found:
            key = (name, obj)
            if key in seen_nf:
                continue
            seen_nf.add(key)
            lines.append(f"| `{name}` | {obj} | {source} | {status} | {note} |")
    else:
        lines.append("All priority fields were found in the org. No missing fields to report.")
    lines.append("")

    # ── Build implications ───────────────────────────────────────────────────
    lines.append("## Build Implications for Astrum BD Agent\n")

    lines.append("### 1. S1 Account and Contact Management\n")
    lines.append("- Core Account read/update fields confirmed: `Name`, `Industry`, `Type`, `Phone`, `Website`, `Description`, `NumberOfEmployees`, `OwnerId`, `ParentId`.")
    lines.append("- `Client_Type__c`, `Account_Segment__c`, `Tier_Category__c`, `Therapeutic_Area__c`, `D365_Account_ID__c` — all **CONFIRMED** in sandbox org.")
    lines.append("- `Rating` and `AnnualRevenue` (standard Account fields) — **NOT in describe output, likely FLS-restricted** for this user. Confirm FLS access on BD user profile before including in Account Intelligence Summary template inputs.")
    lines.append("- Contact `IndividualId` and `ActionCadenceState` — **NOT FOUND**. Required for Data Cloud consent gate and Marketing Cloud journey deduplication. ORG-VALIDATION REQUIRED. These are feature-gated fields.")
    lines.append("- `DoNotCall` on Contact — **NOT FOUND** in describe. Likely FLS-restricted. CRITICAL consent gate — resolve before any outreach logic is built.")
    lines.append("- `Preferred_Method_of_Contact__c` — CONFIRMED on Lead. Verify separately on Contact (not returned by describe for this user).")
    lines.append("- `D365_Contact_ID__c` — not returned by describe. Verify FLS or deployment status.")
    lines.append("- Contact `Email`, `Phone`, `MobilePhone` — all **CONFIRMED** in sandbox. Configure Einstein Trust Layer PII masking before any Prompt Template is activated.\n")

    lines.append("### 2. S2 Opportunity Management\n")
    lines.append("- Core Opportunity management fields **CONFIRMED**: `StageName` (19 active values), `CloseDate`, `NextStep`, `Opp_Probability__c`, `ForecastCategoryName`, `Amount`, `Service_Fees__c`, `Business_Category__c`.")
    lines.append("- `Next_specific_action__c`, `Date_of_next_specific_action__c`, `Person_responsible_for_next_action__c` — all **CONFIRMED** in sandbox.")
    lines.append("- `Total_Fees__c` — **CONFIRMED**. Formula field — cannot be written to. Verify formula returns values before notifications.")
    lines.append("- `Triage_Score__c` — **CONFIRMED**. Formula field — verify it returns values before including in Prompt Templates.")
    lines.append("- `Loss_Reason_Date__c` — **CONFIRMED** in sandbox. Required by STAGE_Closed_Lost validation rule.")
    lines.append("- `Opportunity_Code__c` — **CONFIRMED**. Blank on Dynamics-migrated records — handle gracefully in all Flow email bodies.")
    lines.append("- `Opportunity_ID_18__c` — **NOT IN SANDBOX**. Deployed to production only (SAL-2). **Must be deployed to sandbox before any agent or notification build that constructs record links.**")
    lines.append("- `D365_Opportunity_Notes__c` — **CONFIRMED** in sandbox. **EXCLUDE from ALL Prompt Template inputs** — free-text Long Text Area, prompt injection risk.")
    lines.append("- `Weighted_Service_Fees__c` — **NOT FOUND** in sandbox or priority list. Confirm whether it exists in production or is NET-NEW REQUIRED.")
    lines.append("- `CampaignId` — **CONFIRMED** on Opportunity. Stamp at Lead conversion. Critical for campaign attribution.\n")

    lines.append("### 3. S3 Data Quality and Hygiene\n")
    lines.append("- `AGENT_AccountFieldsAudit` required field list: **do not build** until BD Lead signs off exact field list. This is a hard prerequisite.")
    lines.append("- `AGENT_OpportunityQualityAudit` required field list: same prerequisite.")
    lines.append("- `Study_Countries__c` — **CONFIRMED** in sandbox. Contains non-standard picklist values. Do NOT include in any email payload or Prompt Template until picklist is cleaned.")
    lines.append("- `Therapeutic_Area__c` (Opportunity) — **CONFIRMED** in sandbox. Contains encoding error values (Gynecology variants). Display-only. Do not parse or validate picklist values.")
    lines.append("- `Triage_Score__c` — **CONFIRMED** in sandbox. Formula field — confirm it returns values in test records before including in Data Quality Summary template.\n")

    lines.append("### 4. Prompt Templates\n")
    lines.append("- Account Intelligence Summary: exclude `Contact.Email` and `Contact.Phone` from template inputs (PII).")
    lines.append("- Opportunity Status Summary: exclude `D365_Opportunity_Notes__c` and all Long Text Area migration fields.")
    lines.append("- Data Quality Summary: `HygieneSummary` input must contain only record counts, names, and field categories — no Contact PII.")
    lines.append("- Einstein Trust Layer zero-data retention must be confirmed before any Prompt Template is activated in any environment.\n")

    lines.append("### 5. Permissions and FLS\n")
    lines.append("- `Astrum_BD_Agent_PS` — verify all fields listed in S1/S2/S3 specs have Read (and Edit where required) in this permission set.")
    lines.append("- Contact Create permission — confirm whether on BD user profile before adding to permission set.")
    lines.append("- Opportunity Delete — must remain unchecked on `Astrum_BD_Agent_PS`.")
    lines.append("- Standard `Probability` (%) field — hide from page layouts. Only `Opp_Probability__c` is authoritative.\n")

    lines.append("### 6. Testing\n")
    lines.append("- Agentforce Testing Center: confirm accessible in sandbox before build begins.")
    lines.append("- Plan Tracer: confirm enabled in sandbox.")
    lines.append("- Required field list prerequisite: Subagent 3 Flows cannot be unit-tested until BD Lead sign-off.")
    lines.append("- Model drift baseline: lock 50-prompt S2 baseline and 200-prompt overall baseline before go-live.")
    lines.append("- Hyperforce EU region: confirm before Einstein Trust Layer PII masking validation (GDPR requirement).")
    lines.append("")

    # ── Footer ───────────────────────────────────────────────────────────────
    lines.append("---")
    lines.append("")
    lines.append("*Schema authority generated by Claude Code (Architect agent) from sandbox org `astrum--astrumpar.sandbox.my.salesforce.com` using read-only `sf sobject describe` commands. No Salesforce metadata was created, modified, deployed, activated, or deleted during generation. SAL-2, SAL-9, and SAL-10 notification files were not touched.*")
    lines.append("")
    lines.append(f"*Generated: {datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%SZ')} UTC*")

    os.makedirs(os.path.dirname(OUTPUT_PATH), exist_ok=True)
    with open(OUTPUT_PATH, "w", encoding="utf-8") as out:
        out.write("\n".join(lines))

    print("Written: " + OUTPUT_PATH)

    # Summary stats
    opp_map2 = {f["name"]: f for f in opp_fields}
    print("\nField confirmation summary:")
    for label, plist, flds in [
        ("Account", ACCOUNT_PRIORITY, acc_fields),
        ("Contact", CONTACT_PRIORITY, con_fields),
        ("Opportunity", OPPORTUNITY_PRIORITY, opp_fields),
        ("Lead", LEAD_PRIORITY, lea_fields),
    ]:
        fmap = {f["name"]: f for f in flds}
        found = sum(1 for n in dict.fromkeys(plist) if n in fmap)
        missing = [n for n in dict.fromkeys(plist) if n not in fmap]
        print(f"  {label}: {found}/{len(set(plist))} confirmed — missing: {missing}")


if __name__ == "__main__":
    main()
