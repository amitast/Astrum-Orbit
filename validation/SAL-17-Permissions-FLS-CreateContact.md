# SAL-17 Permissions and FLS Validation - AGENT_CreateContact

| Item | Value |
|---|---|
| Validation timestamp | 2026-04-28T19:10:27+01:00 |
| Shell used | Windows PowerShell Desktop 5.1.26100.8115 |
| Salesforce CLI command path | `& "$env:APPDATA\npm\sf.cmd"` |
| Salesforce CLI version | `@salesforce/cli/2.131.7 win32-x64 node-v24.15.0` |
| Target org | `amit.kumar@astrumcro.com.astrumpar` |
| Org ID | `00DUD000007zF692AE` |
| Sandbox proof | `sf org list --json` showed target under `sandboxes` with `isSandbox: true`; `Organization.IsSandbox` query returned `true`; instance URL is `https://astrum--astrumpar.sandbox.my.salesforce.com` |
| Permission set | `Astrum_BD_Agent_PS` |
| Permission set deployment | Succeeded |
| Deploy ID | `0AfUD00000Gq4EP0AZ` |
| Production touched | No |
| Agent Builder configuration | Not started |
| Linear comment | `b5a3a164-6075-423c-8ce6-1764d70713c7` |

## Initial State

Initial SOQL validation returned no PermissionSet row for `Astrum_BD_Agent_PS`. Codex created the minimum required sandbox permission set metadata at:

```text
force-app/main/default/permissionsets/Astrum_BD_Agent_PS.permissionset-meta.xml
```

First deploy attempt `0AfUD00000Gq4BB0AZ` failed and rolled back because Salesforce does not allow FLS entries for non-permissionable `Contact.FirstName`. Contact describe confirmed:

| Field | Permissionable | Createable | Updateable |
|---|---:|---:|---:|
| Contact.FirstName | false | true | true |
| Contact.LastName | false | true | true |
| Contact.AccountId | true | true | true |
| Contact.Title | true | true | true |
| Contact.Email | true | true | true |
| Contact.Phone | true | true | true |
| Contact.MobilePhone | true | true | true |

The permission set was redeployed without non-permissionable FirstName/LastName FLS entries.

## Deployment Command

```powershell
& "$env:APPDATA\npm\sf.cmd" project deploy start --source-dir force-app/main/default/permissionsets/Astrum_BD_Agent_PS.permissionset-meta.xml --target-org amit.kumar@astrumcro.com.astrumpar --wait 30 --json
```

## Object Permission Results

| Object | Read | Create | Edit | Delete | View All | Modify All | Status |
|---|---:|---:|---:|---:|---:|---:|---|
| Account | true | false | false | false | false | false | PASS |
| Contact | true | true | true | false | false | false | PASS |

## Field Permission Results

| Field | Read | Edit | Status |
|---|---:|---:|---|
| Contact.AccountId | true | true | PASS |
| Contact.Email | true | true | PASS |
| Contact.MobilePhone | true | true | PASS |
| Contact.Phone | true | true | PASS |
| Contact.Title | true | true | PASS |
| Contact.FirstName | N/A | N/A | PASS - field is not permissionable in this org; createable/updateable via object permission |
| Contact.LastName | N/A | N/A | PASS - field is not permissionable in this org; createable/updateable via object permission |

## Flow Access

| Access | Result |
|---|---|
| `SetupEntityAccess` for `Astrum_BD_Agent_PS` | Present |
| Setup entity type | `FlowDefinition` |
| Setup entity ID | `300UD00000QvVmUYAV` (`AGENT_CreateContact`) |
| Status | PASS |

## Commands Used

```powershell
& "$env:APPDATA\npm\sf.cmd" data query --target-org amit.kumar@astrumcro.com.astrumpar --query "SELECT Id, Name, Label FROM PermissionSet WHERE Name = 'Astrum_BD_Agent_PS'" --json
& "$env:APPDATA\npm\sf.cmd" data query --target-org amit.kumar@astrumcro.com.astrumpar --query "SELECT SobjectType, PermissionsRead, PermissionsCreate, PermissionsEdit, PermissionsDelete, PermissionsViewAllRecords, PermissionsModifyAllRecords FROM ObjectPermissions WHERE Parent.Name = 'Astrum_BD_Agent_PS' AND SobjectType IN ('Account','Contact') ORDER BY SobjectType" --json
& "$env:APPDATA\npm\sf.cmd" data query --target-org amit.kumar@astrumcro.com.astrumpar --query "SELECT SobjectType, Field, PermissionsRead, PermissionsEdit FROM FieldPermissions WHERE Parent.Name = 'Astrum_BD_Agent_PS' AND Field IN ('Contact.AccountId','Contact.FirstName','Contact.LastName','Contact.Title','Contact.Email','Contact.Phone','Contact.MobilePhone') ORDER BY Field" --json
& "$env:APPDATA\npm\sf.cmd" data query --target-org amit.kumar@astrumcro.com.astrumpar --query "SELECT SetupEntityId, SetupEntityType FROM SetupEntityAccess WHERE Parent.Name = 'Astrum_BD_Agent_PS'" --json
```

## Permission Changes Made

Created `Astrum_BD_Agent_PS` in sandbox with:

- Account: Read only
- Contact: Read, Create, Edit
- Contact FLS: Read/Edit for AccountId, Title, Email, Phone, MobilePhone
- Flow access: `AGENT_CreateContact`

Confirmed no:

- Account Create
- Delete permissions
- View All permissions
- Modify All permissions
- Production changes

## SAL-17 Result

SAL-17 permission/FLS validation is complete and PASS for the `AGENT_CreateContact` runtime requirements.

Linear issue SAL-17 was updated with this permission/FLS evidence. Issue status was not changed.
