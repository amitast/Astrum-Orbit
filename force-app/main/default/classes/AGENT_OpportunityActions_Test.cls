@IsTest(SeeAllData=true)
private class AGENT_OpportunityActions_Test {
    private static Opportunity createSeedOpportunity(String nameSuffix) {
        Account accountRecord = [SELECT Id FROM Account WHERE IsDeleted = false LIMIT 1];
        Date todayDate = Date.today();
        Opportunity opp = new Opportunity(
            Name = 'S2 Agent Test ' + nameSuffix + ' ' + System.now().getTime(),
            AccountId = accountRecord.Id,
            StageName = 'Early Engagement',
            CloseDate = todayDate.addDays(45),
            ForecastCategoryName = 'Pipeline',
            Business_Category__c = 'Phase I-NIS',
            Entities_Providing_Services__c = 'Germany;Portugal',
            Project_Category__c = 'Food Supplement',
            Project_Start_Work__c = todayDate.addDays(60),
            Project_End_Work__c = todayDate.addDays(180),
            RfP_Received_Date__c = todayDate,
            RfP_Due_Sent_Date__c = todayDate.addDays(7),
            Study_Phase_Type__c = 'Post-Marketing',
            Therapeutic_Area__c = 'Hematology (Non-Malignant)',
            NextStep = 'Schedule BD follow-up'
        );
        insert opp;
        return [
            SELECT Id, Name, AccountId, Account.Name
            FROM Opportunity
            WHERE Id = :opp.Id
            LIMIT 1
        ];
    }

    @IsTest
    static void getOpportunityDetailsByIdReturnsGroundedFields() {
        Opportunity opp = createSeedOpportunity('Details');

        AGENT_GetOpportunityDetails.DetailsRequest request = new AGENT_GetOpportunityDetails.DetailsRequest();
        request.OpportunityId = opp.Id;

        List<AGENT_GetOpportunityDetails.DetailsResult> results =
            AGENT_GetOpportunityDetails.getOpportunityDetails(new List<AGENT_GetOpportunityDetails.DetailsRequest>{ request });

        System.assertEquals(1, results.size(), 'One invocable result should be returned.');
        System.assertEquals(true, results[0].Success, 'Lookup by Id should succeed.');
        System.assertEquals(opp.Id, results[0].OpportunityId, 'Resolved Opportunity Id mismatch.');
        System.assert(results[0].DetailsSummary.contains('Opportunity'), 'Summary should include Opportunity details.');
        System.assert(!results[0].DetailsSummary.contains('Description'), 'Description must not be included.');
    }

    @IsTest
    static void getOpportunityDetailsHandlesNoInputNoMatchAndMultipleMatches() {
        createSeedOpportunity('Multi');
        createSeedOpportunity('Multi');

        List<AGENT_GetOpportunityDetails.DetailsResult> noInput =
            AGENT_GetOpportunityDetails.getOpportunityDetails(new List<AGENT_GetOpportunityDetails.DetailsRequest>());
        System.assertEquals(false, noInput[0].Success, 'No-input result should fail gracefully.');

        AGENT_GetOpportunityDetails.DetailsRequest noMatchRequest = new AGENT_GetOpportunityDetails.DetailsRequest();
        noMatchRequest.OpportunityName = 'No Such S2 Agent Opportunity Name';
        List<AGENT_GetOpportunityDetails.DetailsResult> noMatch =
            AGENT_GetOpportunityDetails.getOpportunityDetails(
                new List<AGENT_GetOpportunityDetails.DetailsRequest>{ noMatchRequest }
            );
        System.assertEquals(0, noMatch[0].MatchCount, 'No-match lookup should return zero matches.');

        AGENT_GetOpportunityDetails.DetailsRequest multiRequest = new AGENT_GetOpportunityDetails.DetailsRequest();
        multiRequest.OpportunityName = 'S2 Agent Test Multi';
        List<AGENT_GetOpportunityDetails.DetailsResult> multi =
            AGENT_GetOpportunityDetails.getOpportunityDetails(
                new List<AGENT_GetOpportunityDetails.DetailsRequest>{ multiRequest }
            );
        System.assert(multi[0].MatchCount > 1, 'Multiple matching opportunities should be surfaced.');
        System.assert(multi[0].CandidateSummary.contains('S2 Agent Test Multi'), 'Candidate summary should list matches.');
    }

    @IsTest
    static void searchOpportunitiesByNameReturnsCandidate() {
        Opportunity opp = createSeedOpportunity('Search');

        AGENT_SearchOpportunities.SearchRequest request = new AGENT_SearchOpportunities.SearchRequest();
        request.SearchTerm = opp.Name;

        List<AGENT_SearchOpportunities.SearchResult> results =
            AGENT_SearchOpportunities.searchOpportunities(new List<AGENT_SearchOpportunities.SearchRequest>{ request });

        System.assertEquals(1, results.size(), 'One invocable result should be returned.');
        System.assert(results[0].OpportunityCount >= 1, 'Search should return the seed Opportunity.');
        System.assert(results[0].ResultsSummary.contains(opp.Name), 'Search summary should include the seed Opportunity.');
        System.assert(results[0].ResultsSummary.contains('Opp Probability'), 'Search summary should include Opp Probability label.');
    }

    @IsTest
    static void searchOpportunitiesSupportsFiltersAndValidation() {
        Opportunity opp = createSeedOpportunity('Filter');

        AGENT_SearchOpportunities.SearchRequest blankRequest = new AGENT_SearchOpportunities.SearchRequest();
        List<AGENT_SearchOpportunities.SearchResult> blankResults =
            AGENT_SearchOpportunities.searchOpportunities(new List<AGENT_SearchOpportunities.SearchRequest>{ blankRequest });
        System.assertEquals('At least one search filter must be provided.', blankResults[0].ErrorMessage);

        AGENT_SearchOpportunities.SearchRequest accountRequest = new AGENT_SearchOpportunities.SearchRequest();
        accountRequest.AccountName = opp.Account.Name;
        accountRequest.StageName = 'Early Engagement';
        List<AGENT_SearchOpportunities.SearchResult> accountResults =
            AGENT_SearchOpportunities.searchOpportunities(
                new List<AGENT_SearchOpportunities.SearchRequest>{ accountRequest }
            );
        System.assert(accountResults[0].OpportunityCount >= 1, 'Account and stage filters should return results.');

        AGENT_SearchOpportunities.SearchRequest noMatchRequest = new AGENT_SearchOpportunities.SearchRequest();
        noMatchRequest.OpportunityCode = 'NO-SUCH-S2-CODE';
        List<AGENT_SearchOpportunities.SearchResult> noMatchResults =
            AGENT_SearchOpportunities.searchOpportunities(
                new List<AGENT_SearchOpportunities.SearchRequest>{ noMatchRequest }
            );
        System.assertEquals(0, noMatchResults[0].OpportunityCount, 'No-match search should return zero count.');
    }

    @IsTest
    static void searchOpportunitiesSupportsNoRecentActionFilter() {
        Opportunity opp = createSeedOpportunity('No Recent Action');
        opp.Last_client_interaction_date__c = Date.today().addDays(-45);
        update opp;

        AGENT_SearchOpportunities.SearchRequest request = new AGENT_SearchOpportunities.SearchRequest();
        request.NoActionInLastDays = 30;

        List<AGENT_SearchOpportunities.SearchResult> results =
            AGENT_SearchOpportunities.searchOpportunities(new List<AGENT_SearchOpportunities.SearchRequest>{ request });

        System.assertEquals(1, results.size(), 'One invocable result should be returned.');
        System.assert(results[0].OpportunityCount >= 1, 'No-recent-action search should return stale Opportunities.');
        System.assert(results[0].ResultsSummary.contains(opp.Name), 'Search summary should include the stale seed Opportunity.');
        System.assert(results[0].ResultsSummary.contains('Last Client Interaction'), 'Search summary should include last interaction context.');
    }

    @IsTest
    static void searchOpportunitiesSupportsCreatedInLastDaysFilter() {
        Opportunity opp = createSeedOpportunity('Created Recently');

        AGENT_SearchOpportunities.SearchRequest request = new AGENT_SearchOpportunities.SearchRequest();
        request.CreatedInLastDays = 7;

        List<AGENT_SearchOpportunities.SearchResult> results =
            AGENT_SearchOpportunities.searchOpportunities(new List<AGENT_SearchOpportunities.SearchRequest>{ request });

        System.assertEquals(1, results.size(), 'One invocable result should be returned.');
        System.assert(results[0].OpportunityCount >= 1, 'Created-recently search should return recent Opportunities.');
        System.assert(results[0].ResultsSummary.contains(opp.Name), 'Search summary should include the newly created seed Opportunity.');
        System.assert(results[0].ResultsSummary.contains('Created Date'), 'Search summary should include created date context.');
    }

    @IsTest
    static void statusSummaryOmitProhibitedLongTextFields() {
        Opportunity opp = createSeedOpportunity('Summary');

        AGENT_OpportunityStatusSummaryAction.SummaryRequest request =
            new AGENT_OpportunityStatusSummaryAction.SummaryRequest();
        request.OpportunityId = opp.Id;

        List<AGENT_OpportunityStatusSummaryAction.SummaryResult> results =
            AGENT_OpportunityStatusSummaryAction.summarize(
                new List<AGENT_OpportunityStatusSummaryAction.SummaryRequest>{ request }
            );

        System.assertEquals(true, results[0].Success, 'Status summary should succeed.');
        System.assert(results[0].Summary.contains('Current deal status'), 'Summary should include current deal status.');
        System.assert(results[0].Summary.contains('Current deal status'), 'Summary should be grounded in Opportunity status.');
        System.assert(!results[0].Summary.contains('D365'), 'Summary must not include D365 notes.');
        System.assert(!results[0].Summary.contains('Description'), 'Summary must not include Description.');
    }

    @IsTest
    static void statusSummaryHandlesMultipleMatchesAndRiskSignals() {
        Opportunity first = createSeedOpportunity('Risk');
        createSeedOpportunity('Risk');

        first.CloseDate = Date.today().addDays(-3);
        first.NextStep = null;
        first.Next_specific_action__c = null;
        first.Last_client_interaction_date__c = Date.today().addDays(-45);
        update first;

        AGENT_OpportunityStatusSummaryAction.SummaryRequest riskRequest =
            new AGENT_OpportunityStatusSummaryAction.SummaryRequest();
        riskRequest.OpportunityId = first.Id;
        List<AGENT_OpportunityStatusSummaryAction.SummaryResult> riskResults =
            AGENT_OpportunityStatusSummaryAction.summarize(
                new List<AGENT_OpportunityStatusSummaryAction.SummaryRequest>{ riskRequest }
            );
        System.assert(riskResults[0].Summary.contains('Visible risk signals'), 'Risk signals should be surfaced.');

        AGENT_OpportunityStatusSummaryAction.SummaryRequest multiRequest =
            new AGENT_OpportunityStatusSummaryAction.SummaryRequest();
        multiRequest.OpportunityName = 'S2 Agent Test Risk';
        List<AGENT_OpportunityStatusSummaryAction.SummaryResult> multiResults =
            AGENT_OpportunityStatusSummaryAction.summarize(
                new List<AGENT_OpportunityStatusSummaryAction.SummaryRequest>{ multiRequest }
            );
        System.assert(multiResults[0].MatchCount > 1, 'Multiple matches should be surfaced before summary.');
        System.assert(multiResults[0].CandidateSummary.contains('S2 Agent Test Risk'), 'Candidate summary should list matches.');

        AGENT_OpportunityStatusSummaryAction.SummaryRequest noMatchRequest =
            new AGENT_OpportunityStatusSummaryAction.SummaryRequest();
        noMatchRequest.OpportunityCode = 'NO-SUCH-S2-CODE';
        List<AGENT_OpportunityStatusSummaryAction.SummaryResult> noMatchResults =
            AGENT_OpportunityStatusSummaryAction.summarize(
                new List<AGENT_OpportunityStatusSummaryAction.SummaryRequest>{ noMatchRequest }
            );
        System.assertEquals(0, noMatchResults[0].MatchCount, 'No-match summary should return zero matches.');
    }

    @IsTest
    static void createOpportunityValidatesMandatoryFieldsBeforeDml() {
        AGENT_CreateOpportunity.CreateRequest request = new AGENT_CreateOpportunity.CreateRequest();
        request.Name = 'Missing Account';

        List<AGENT_CreateOpportunity.CreateResult> results =
            AGENT_CreateOpportunity.createOpportunity(new List<AGENT_CreateOpportunity.CreateRequest>{ request });

        System.assertEquals(false, results[0].Success, 'Missing mandatory fields should fail.');
        System.assert(results[0].ErrorMessage.contains('Missing required fields'), 'Error should identify missing fields.');
        System.assert(results[0].ErrorMessage.contains('AccountId or AccountName'), 'Account should be required.');
    }

    @IsTest
    static void createOpportunityInsertsSingleRecordWhenAllFieldsProvided() {
        Account accountRecord = [SELECT Id FROM Account WHERE IsDeleted = false LIMIT 1];
        Date todayDate = Date.today();

        AGENT_CreateOpportunity.CreateRequest request = new AGENT_CreateOpportunity.CreateRequest();
        request.AccountId = accountRecord.Id;
        request.Name = 'S2 Agent Created Opportunity ' + System.now().getTime();
        request.StageName = 'Early Engagement';
        request.CloseDate = todayDate.addDays(90);
        request.ForecastCategoryName = 'Pipeline';
        request.BusinessCategory = 'Phase I-NIS';
        request.EntitiesProvidingServices = 'Germany;Portugal';
        request.ProjectCategory = 'Food Supplement';
        request.ProjectStartWork = todayDate.addDays(120);
        request.ProjectEndWork = todayDate.addDays(300);
        request.RfPReceivedDate = todayDate;
        request.RfPDueSentDate = todayDate.addDays(14);
        request.StudyPhaseType = 'Post-Marketing';
        request.TherapeuticArea = 'Hematology (Non-Malignant)';
        request.NextStep = 'Confirm project assumptions';

        List<AGENT_CreateOpportunity.CreateResult> results =
            AGENT_CreateOpportunity.createOpportunity(new List<AGENT_CreateOpportunity.CreateRequest>{ request });

        System.assertEquals(true, results[0].Success, 'Create Opportunity should succeed with all mandatory fields.');
        System.assertNotEquals(null, results[0].OpportunityId, 'Created Opportunity Id should be returned.');
        System.assertNotEquals(null, results[0].OpportunityName, 'Created Opportunity name should be returned.');
    }
}
