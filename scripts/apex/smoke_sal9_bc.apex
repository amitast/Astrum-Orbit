// SAL-9 Smoke Test — Scenarios B and C (missing routing paths)
// B: Phase I Unit, Service Fees >= EUR 150,000 → expects Send_Closed_Won_Phase_I_Unit_High
// C: Phase I-NIS, Service Fees < EUR 500,000 → expects Send_Closed_Won_Phase_I_NIS_Low
// Target: astrum--astrumpar sandbox only.
// Note: emailSimple will fault (INSUFFICIENT_ACCESS_OR_READONLY) because astrumcro.com
//       domain is not verified in sandbox. Routing is confirmed via debug log timing.
// Validation rule 03dUD000000TMbRYAW (STAGE_Closed_Won) requires all fields below.

Account acc = [SELECT Id, Name FROM Account ORDER BY CreatedDate DESC LIMIT 1];
System.debug('SAL-9 SMOKE BC: Using Account ' + acc.Id + ' — ' + acc.Name);

// Scenario B: Phase I Unit, Service Fees = EUR 200,000 (>= threshold of 150,000)
// Expected: routes to Send_Closed_Won_Phase_I_Unit_High
Opportunity oppB = new Opportunity(
    Name = '[SAL-9 Smoke B] Phase I Unit High',
    AccountId = acc.Id,
    StageName = 'Proposal In Progress',
    CloseDate = Date.today(),
    Business_Category__c = 'Phase I Unit',
    Service_Fees__c = 200000,
    // Closed Won validation rule fields (03dUD000000TMbRYAW)
    Description = 'SAL-9 smoke test B',
    Reason_for_win__c = 'Client Relationship',
    Indication__c = 'SAL-9 smoke test indication B',
    Number_of_Enrolled_Participants__c = 10,
    Study_Countries__c = 'Portugal',
    Number_of_Sites__c = 3,
    Entities_Providing_Services__c = 'Portugal',
    Protocol_Title__c = 'SAL-9 Smoke Test Protocol B',
    Contract_Sign_Date__c = Date.today(),
    Contract_Type__c = 'Statement of Work, Work Order',
    Payment_Schedule_Type__c = 'Milestone Based',
    Contract_Entity__c = 'Astrum CRO SL'
);

// Scenario C: Phase I-NIS, Service Fees = EUR 300,000 (< threshold of 500,000)
// Expected: routes to Send_Closed_Won_Phase_I_NIS_Low
Opportunity oppC = new Opportunity(
    Name = '[SAL-9 Smoke C] Phase I-NIS Low',
    AccountId = acc.Id,
    StageName = 'Proposal In Progress',
    CloseDate = Date.today(),
    Business_Category__c = 'Phase I-NIS',
    Service_Fees__c = 300000,
    // Closed Won validation rule fields (03dUD000000TMbRYAW)
    Description = 'SAL-9 smoke test C',
    Reason_for_win__c = 'Client Relationship',
    Indication__c = 'SAL-9 smoke test indication C',
    Number_of_Enrolled_Participants__c = 10,
    Study_Countries__c = 'Portugal',
    Number_of_Sites__c = 3,
    Entities_Providing_Services__c = 'Portugal',
    Protocol_Title__c = 'SAL-9 Smoke Test Protocol C',
    Contract_Sign_Date__c = Date.today(),
    Contract_Type__c = 'Statement of Work, Work Order',
    Payment_Schedule_Type__c = 'Milestone Based',
    Contract_Entity__c = 'Astrum CRO SL'
);

insert new List<Opportunity>{ oppB, oppC };
System.debug('SAL-9 SMOKE BC: Inserted B=' + oppB.Id + ' C=' + oppC.Id);

// Trigger the flow: update both to Closed Won
oppB.StageName = 'Closed Won';
oppC.StageName = 'Closed Won';

update new List<Opportunity>{ oppB, oppC };
System.debug('SAL-9 SMOKE BC: Updated both to Closed Won. Flow should have fired x2.');
System.debug('SAL-9 SMOKE B ID: ' + oppB.Id);
System.debug('SAL-9 SMOKE C ID: ' + oppC.Id);
