# SAL-2 Sandbox Deploy Output

**Flow:** Notify Critical Stage Progression After Save  
**API Name:** `Notify_Critical_Stage_Progression_After_Save`  
**Flow ID:** `301UD00000VgdXnYAJ`  
**Deploy ID:** `0AfUD00000GnvlV0AB`  
**Target org:** `astrum--astrumpar.sandbox.my.salesforce.com`  
**Username:** `amit.kumar@astrumcro.com.astrumpar`  
**API version:** 66.0  
**Deployed:** 2026-04-25  
**Final status:** Active  

## Deploy sequence

| Step | Command | Outcome |
|---|---|---|
| 1 | `sf project deploy start --source-dir force-app/main/default/flows/Notify_Critical_Stage_Progression_After_Save.flow-meta.xml --target-org amit.kumar@astrumcro.com.astrumpar` (Draft — `<status>Draft</status>`) | Failed — `<recordTriggerType>` invalid at top-level `<Flow>` |
| 2 | Removed top-level `<recordTriggerType>Update</recordTriggerType>`; `<recordTriggerType>` retained inside `<start>` only | XML valid |
| 3 | Re-deployed as Draft | Success — Deploy ID `0AfUD00000GnvlV0AB` |
| 4 | Re-deployed with `<status>Active</status>` | Success — Flow Active |

## Tooling API verification

```
SELECT Id, MasterLabel, Status, ProcessType FROM Flow 
WHERE MasterLabel = 'Notify Critical Stage Progression After Save'
```

Result:
- Id: `301UD00000VgdXnYAJ`
- MasterLabel: `Notify Critical Stage Progression After Save`
- Status: `Active`
- ProcessType: `AutoLaunchedFlow`

## XML errors resolved during build

1. **Double-hyphen in XML comment** — `astrum--astrumpar` inside `<!-- -->` comment is illegal XML (`--` not permitted inside comment content). Fixed by rewriting all block comments.
2. **`<recordTriggerType>` at wrong level** — element is only valid inside `<start>`, not at top-level `<Flow>`. Removed from top level; retained inside `<start>`.
