# SAL-16 — Sandbox Test Data Plan

## Overview

This document describes the test data creation plan for SAL-16 (Agentforce Testing Center tests AC-01, AC-03, AC-04). This is documentation only — no records are created by this plan. Human approval is required before any record creation.

## Environment check (performed)
- Organization Id: 00DUD000007zF692AE
- DefaultAccountAccess: Edit
- DefaultContactAccess: ControlledByParent
- Confirmed sandbox: Yes (Organization.IsSandbox = true)

## Catherine Canales (pilot user)
- Username: catherine.canales@astrumcro.com
- User Id: 005UD00000Mk0oxYAB
- Name: catherine canales
- Profile: Astrum
- UserRole: (none assigned)

## Existing data check (results)
- Accounts matching '%Pfizer%': none found
- Contacts FirstName='John' LastName='Smith': none found

## Test records to create (Human must run these; do NOT create them now)

### Record 1: Pfizer Account
- Object: Account
- Required fields:
  - Name: Pfizer
  - OwnerId: 005UD00000Mk0oxYAB  # Catherine Canales user id (recommended to ensure visibility)
- Optional fields (recommended for realism and routing):
  - Industry: Pharmaceuticals
  - Type: Customer

Notes:
- Sharing model: DefaultAccountAccess = Edit (Organization-wide default). Catherine should be able to access Accounts for read/write by default; OwnerId assignment is recommended for deterministic access but may not be necessary if OWD already permits it.
- AC-01/AC-02 dependency: AGENT_CreateContact requires a resolvable AccountId. Ensure the Pfizer Account is discoverable by the agent planner (Account.Name = 'Pfizer' or other matching name).

### Record 2: John Smith Contact at Pfizer
- Object: Contact
- Required fields:
  - FirstName: John
  - LastName: Smith
  - AccountId: [Pfizer Account Id from above]
  - OwnerId: 005UD00000Mk0oxYAB (optional — recommended)
- Optional fields (for deterministic duplicate detection):
  - Title: Clinical Director
  - Email: john.smith@pfizer-test.sandbox.invalid

Notes:
- Sharing model: DefaultContactAccess = ControlledByParent — Contact access is controlled by the parent Account. If Catherine can see the Pfizer Account, she will see its Contacts.
- AC-03 dependency: AGENT_CreateContact's duplicate detection queries WHERE AccountId = [Pfizer] AND LastName = 'Smith'. The Contact above must exist for duplicate detection to return a result.

## Creation sequence
1. Create the Pfizer Account.
2. Create the John Smith Contact (assign AccountId to the Pfizer Account).
3. Verify visibility as Catherine Canales before executing tests.

## Post-creation verification queries (to run after Human-created records)
Run these as catherine.canales@astrumcro.com to confirm visibility:
- SELECT Id, Name FROM Account WHERE Name = 'Pfizer'
- SELECT Id, FirstName, LastName, Account.Name FROM Contact WHERE FirstName = 'John' AND LastName = 'Smith' AND Account.Name = 'Pfizer'

## Sharing-model risks
- OWD for Account = Edit means Catherine likely has access to Accounts without being owner.
- DefaultContactAccess = ControlledByParent means Contact visibility depends on Account sharing. If Catherine cannot see the Pfizer Account for any reason (role, sharing rules), she will not see Contacts under it.
- If Catherine's Profile lacks read access to Account or Contact objects, tests may fail. Profile 'Astrum' should be reviewed to confirm object-level permissions.

## Human approval required
- Human must confirm and issue an explicit instruction to create the records and specify exact field values and OwnerId enforcement (HITL Confirm).
- After human approval and record creation, run the Post-creation verification queries as the Catherine user to confirm visibility.

## Audit and safety
- Use .invalid domain for test Contact emails to avoid sending real email.
- Do not activate or deploy agents during test data setup.
- Do not target astrum-prod for any steps.

## Contacts
- Pilot user: catherine.canales@astrumcro.com (UserId: 005UD00000Mk0oxYAB)

# End of plan