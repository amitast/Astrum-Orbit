// SAL-9 Smoke Test — Silent Exit: SE-01
// SE-01: Opportunity with Business_Category__c = 'S&PS' transitions to Closed Won
//        → Flow should ENTER (entry criteria pass, ~500ms) but exit silently at
//          Check_Business_Category (no defaultConnector — S&PS falls through to silent exit)
//        → No email sent, no error, Opportunity saves normally
// Target: astrum--astrumpar sandbox only.
//
// Evidence method: debug log CODE_UNIT duration for Flow:Opportunity
//   >= 500ms  = Flow entered and executed to Check_Business_Category (correct)
//   < 5ms     = entry criteria blocked (unexpected — would indicate a test setup error)
//
// Confirm PASS by: Opportunity DML succeeds + no emailSimple fault in the debug log.
// An emailSimple fault (INSUFFICIENT_ACCESS_OR_READONLY) would indicate the Flow
// incorrectly reached an email send path, which would be a routing failure.
//
// Validation rule 03dUD000000TMbRYAW (STAGE_Closed_Won) requires all fields below.
// 'S&PS' is a confirmed active picklist value for Business_Category__c (25 Apr 2026).

Account acc = [SELECT Id, Name FROM Account ORDER BY CreatedDate DESC LIMIT 1];
System.debug('SAL-9 SE-01: Using Account ' + acc.Id + ' — ' + acc.Name);

// SE-01: S&PS category — Flow enters, exits silently at Check_Business_Category
Opportunity oppSE = new Opportunity(
    Name = '[SAL-9 SE-01] S&PS Silent Exit',
    AccountId = acc.Id,
    StageName = 'Proposal In Progress',
    CloseDate = Date.today(),
    Business_Category__c = 'S&PS',
    Service_Fees__c = 100000,
    // Closed Won validation rule fields (03dUD000000TMbRYAW)
    Description = 'SAL-9 SE-01 silent exit test',
    Reason_for_win__c = 'Client Relationship',
    Indication__c = 'SAL-9 SE-01 test indication',
    Number_of_Enrolled_Participants__c = 10,
    Study_Countries__c = 'Portugal',
    Number_of_Sites__c = 3,
    Entities_Providing_Services__c = 'Portugal',
    Protocol_Title__c = 'SAL-9 SE-01 Test Protocol',
    Contract_Sign_Date__c = Date.today(),
    Contract_Type__c = 'Statement of Work, Work Order',
    Payment_Schedule_Type__c = 'Milestone Based',
    Contract_Entity__c = 'Astrum CRO SL'
);
insert oppSE;
System.debug('SAL-9 SE-01: Inserted ' + oppSE.Id);

// Trigger: update to Closed Won — Flow should enter and exit silently
oppSE.StageName = 'Closed Won';
update oppSE;
System.debug('SAL-9 SE-01: Updated to Closed Won. Flow should have ENTERED (~500ms) then exited at Check_Business_Category.');
System.debug('SAL-9 SE-01: No emailSimple fault should appear in the debug log.');
System.debug('SAL-9 SE-01 RECORD: ' + oppSE.Id);
