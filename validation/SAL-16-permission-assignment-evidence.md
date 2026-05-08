# SAL-16 Permission Assignment Evidence

| Item | Value |
|---|---|
| Timestamp | 2026-04-28T22:05:00+01:00 |
| Target org | `amit.kumar@astrumcro.com.astrumpar` |
| Org ID | `00DUD000007zF692AE` |
| Sandbox proof | Standard `Organization` SOQL returned `IsSandbox = true`, instance `SWE92S`; target instance URL previously confirmed as `https://astrum--astrumpar.sandbox.my.salesforce.com` |
| Production touched | No |
| Permission set | `Astrum_BD_Agent_PS` |
| Permission set ID | `0PSUD00000107wz4AA` |
| Selected BD pilot user | Catherine Canales |
| Selected user ID | `005UD00000Mk0oxYAB` |
| Selected username | `catherine.canales@astrumcro.com` |
| Selected user profile | Astrum |
| Selection basis | Human explicitly instructed Codex to use Catherine Canales as the BD pilot user for SAL-16. User record is active. |
| Assignment performed | Yes |
| PermissionSetAssignment ID | `0PaUD00000IsHO60AN` |

## Sandbox Proof

```sql
SELECT Id, Name, IsSandbox, InstanceName
FROM Organization
LIMIT 1
```

Result:

| Id | IsSandbox | InstanceName |
|---|---|---|
| `00DUD000007zF692AE` | `true` | `SWE92S` |

## Permission Set Existence

```sql
SELECT Id, Name, Label
FROM PermissionSet
WHERE Name = 'Astrum_BD_Agent_PS'
```

Result:

| Id | Name | Label |
|---|---|---|
| `0PSUD00000107wz4AA` | `Astrum_BD_Agent_PS` | Astrum BD Agent |

## Selected User

```sql
SELECT Id, Username, Name, Email, IsActive, Profile.Name
FROM User
WHERE Username = 'catherine.canales@astrumcro.com'
LIMIT 1
```

Result:

| Id | Name | Username | Email | IsActive | Profile |
|---|---|---|---|---|---|
| `005UD00000Mk0oxYAB` | catherine canales | `catherine.canales@astrumcro.com` | `catherine.canales@astrumcro.com` | `true` | Astrum |

## Existing Assignment Check Before Assignment

```sql
SELECT Id, AssigneeId, Assignee.Name, Assignee.Username, PermissionSet.Name
FROM PermissionSetAssignment
WHERE AssigneeId = '005UD00000Mk0oxYAB'
AND PermissionSet.Name = 'Astrum_BD_Agent_PS'
```

Result before assignment: zero rows.

## Assignment Command

```powershell
& "C:\Users\Amit Asthana\AppData\Roaming\npm\sf.cmd" org assign permset --target-org amit.kumar@astrumcro.com.astrumpar --name Astrum_BD_Agent_PS --on-behalf-of catherine.canales@astrumcro.com --json
```

Result: command succeeded for `catherine.canales@astrumcro.com`, permission set `Astrum_BD_Agent_PS`.

## Post-Assignment Proof

```sql
SELECT Id, AssigneeId, Assignee.Name, Assignee.Username, PermissionSet.Name
FROM PermissionSetAssignment
WHERE AssigneeId = '005UD00000Mk0oxYAB'
AND PermissionSet.Name = 'Astrum_BD_Agent_PS'
```

Result:

| Id | AssigneeId | Assignee.Name | Assignee.Username | PermissionSet.Name |
|---|---|---|---|---|
| `0PaUD00000IsHO60AN` | `005UD00000Mk0oxYAB` | catherine canales | `catherine.canales@astrumcro.com` | `Astrum_BD_Agent_PS` |

## Scope Confirmation

- Only `Astrum_BD_Agent_PS` was assigned.
- No users were created, deleted, or modified.
- No broad admin permission set was assigned.
- No production org was targeted.
- No unrelated agents were modified.
