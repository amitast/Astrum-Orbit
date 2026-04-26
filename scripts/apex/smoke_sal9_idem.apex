// SAL-9 Smoke Test — Idempotency: IDEM-01 and IDEM-02
// IDEM-01: Re-save an already-Closed-Won Opportunity (Description change only)
//          → Flow should NOT fire (StageName IsChanged = false on second save)
// IDEM-02: Move the same Opportunity from Closed Won to Proposal In Progress
//          → Flow should NOT fire (StageName ≠ 'Closed Won')
// Target: astrum--astrumpar sandbox only.
//
// Evidence method: debug log CODE_UNIT duration for Flow:Opportunity
//   >= 500ms  = Flow executed  (correct for Step 1 only — expected first fire)
//   < 5ms     = entry criteria blocked (correct for IDEM-01 and IDEM-02)
//
// Step 1 (initial Closed Won transition) WILL fire the flow — this is expected and is
// not the test. IDEM-01 and IDEM-02 fire in separate DML calls and should not re-fire.
//
// Validation rule 03dUD000000TMbRYAW (STAGE_Closed_Won) requires all fields below.

Account acc = [SELECT Id, Name FROM Account ORDER BY CreatedDate DESC LIMIT 1];
System.debug('SAL-9 IDEM: Using Account ' + acc.Id + ' — ' + acc.Name);

// Create a fresh Opportunity in Proposal In Progress
Opportunity opp = new Opportunity(
    Name = '[SAL-9 IDEM] Idempotency Test',
    AccountId = acc.Id,
    StageName = 'Proposal In Progress',
    CloseDate = Date.today(),
    Business_Category__c = 'Phase I Unit',
    Service_Fees__c = 100000,
    // Closed Won validation rule fields (03dUD000000TMbRYAW)
    Description = 'SAL-9 IDEM test',
    Reason_for_win__c = 'Client Relationship',
    Indication__c = 'SAL-9 IDEM test indication',
    Number_of_Enrolled_Participants__c = 10,
    Study_Countries__c = 'Portugal',
    Number_of_Sites__c = 3,
    Entities_Providing_Services__c = 'Portugal',
    Protocol_Title__c = 'SAL-9 IDEM Test Protocol',
    Contract_Sign_Date__c = Date.today(),
    Contract_Type__c = 'Statement of Work, Work Order',
    Payment_Schedule_Type__c = 'Milestone Based',
    Contract_Entity__c = 'Astrum CRO SL'
);
insert opp;
System.debug('SAL-9 IDEM: Inserted ' + opp.Id);

// Step 1: Initial Closed Won transition — Flow WILL fire here. This is expected.
opp.StageName = 'Closed Won';
update opp;
System.debug('SAL-9 IDEM STEP 1: Transitioned to Closed Won. Flow expected to fire ONCE here.');
System.debug('SAL-9 IDEM STEP 1 RECORD: ' + opp.Id);

// IDEM-01: Re-save with Description change only — StageName unchanged (still Closed Won)
// IsChanged = false on StageName → entry condition 2 blocks → Flow should NOT fire
opp.Description = 'SAL-9 IDEM-01 — re-save without stage change — ' + String.valueOf(System.now());
update opp;
System.debug('SAL-9 IDEM-01: Updated Description only. StageName unchanged (Closed Won). Flow should NOT fire.');
System.debug('SAL-9 IDEM-01 RECORD: ' + opp.Id);

// IDEM-02: Move away from Closed Won — EqualTo Closed Won condition fails → Flow should NOT fire
opp.StageName = 'Proposal In Progress';
update opp;
System.debug('SAL-9 IDEM-02: Moved StageName to Proposal In Progress. Flow should NOT fire (StageName != Closed Won).');
System.debug('SAL-9 IDEM-02 RECORD: ' + opp.Id);
