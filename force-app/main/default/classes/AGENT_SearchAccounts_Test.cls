@IsTest
private class AGENT_SearchAccounts_Test {
    @TestSetup
    static void setupData() {
        insert new List<Account>{
            new Account(
                Name = 'SAL21 Search Alpha Biotech',
                Client_Type__c = 'Biotech',
                Type = 'Prospect',
                Phone = '+44 20 1000 0001',
                BillingCity = 'London',
                BillingCountry = 'United Kingdom'
            ),
            new Account(
                Name = 'SAL21 Search Beta Pharma',
                Industry = 'Healthcare',
                Type = 'Customer',
                Phone = '+44 20 1000 0002',
                BillingCity = 'Cambridge',
                BillingCountry = 'United Kingdom'
            ),
            new Account(
                Name = 'SAL21 Combined Match',
                Client_Type__c = 'Biotech',
                Type = 'Customer',
                Phone = '+44 20 1000 0003',
                BillingCity = 'Oxford',
                BillingCountry = 'United Kingdom'
            ),
            new Account(
                Name = 'SAL21 Standard Industry Biotechnology Only',
                Industry = 'Biotechnology',
                Type = 'Customer',
                Phone = '+44 20 1000 0004',
                BillingCity = 'Reading',
                BillingCountry = 'United Kingdom'
            )
        };
    }

    @IsTest
    static void searchTermMatchByName() {
        AGENT_SearchAccounts.SearchRequest request = new AGENT_SearchAccounts.SearchRequest();
        request.SearchTerm = 'Alpha';

        Test.startTest();
        List<AGENT_SearchAccounts.SearchResult> results = AGENT_SearchAccounts.searchAccounts(
            new List<AGENT_SearchAccounts.SearchRequest>{ request }
        );
        Test.stopTest();

        System.assertEquals(1, results.size(), 'One invocable result should be returned.');
        System.assert(results[0].AccountCount >= 1, 'Name search should return at least one account.');
        System.assert(results[0].ResultsSummary.contains('SAL21 Search Alpha Biotech'), 'Summary should include matching account.');
        System.assertEquals(null, results[0].ErrorMessage, 'Name search should not return an error.');
    }

    @IsTest
    static void biotechIndustryFilterUsesClientType() {
        AGENT_SearchAccounts.SearchRequest request = new AGENT_SearchAccounts.SearchRequest();
        request.IndustryFilter = 'Biotechnology';

        List<AGENT_SearchAccounts.SearchResult> results = AGENT_SearchAccounts.searchAccounts(
            new List<AGENT_SearchAccounts.SearchRequest>{ request }
        );

        System.assertEquals(2, results[0].AccountCount, 'Biotechnology searches should return Client_Type__c = Biotech accounts.');
        System.assert(results[0].ResultsSummary.contains('SAL21 Search Alpha Biotech'), 'Biotech client type account should be included.');
        System.assert(results[0].ResultsSummary.contains('SAL21 Combined Match'), 'Second Biotech client type account should be included.');
        System.assert(results[0].ResultsSummary.contains('Client Type: Biotech'), 'Summary should include client type.');
        System.assert(
            !results[0].ResultsSummary.contains('SAL21 Standard Industry Biotechnology Only'),
            'Standard Industry-only Biotechnology account should not be returned for Astrum Biotech classification search.'
        );
    }

    @IsTest
    static void biotechSearchTermUsesClientType() {
        AGENT_SearchAccounts.SearchRequest request = new AGENT_SearchAccounts.SearchRequest();
        request.SearchTerm = 'biotech';

        List<AGENT_SearchAccounts.SearchResult> results = AGENT_SearchAccounts.searchAccounts(
            new List<AGENT_SearchAccounts.SearchRequest>{ request }
        );

        System.assertEquals(2, results[0].AccountCount, 'Biotech search term should map to Client_Type__c = Biotech.');
        System.assert(results[0].ResultsSummary.contains('SAL21 Search Alpha Biotech'), 'Biotech account should be included.');
        System.assert(
            !results[0].ResultsSummary.contains('SAL21 Standard Industry Biotechnology Only'),
            'Non-Biotech client type account should be excluded.'
        );
    }

    @IsTest
    static void biotechnologyUtteranceUsesClientType() {
        AGENT_SearchAccounts.SearchRequest request = new AGENT_SearchAccounts.SearchRequest();
        request.SearchTerm = 'Find accounts in the biotechnology industry';

        List<AGENT_SearchAccounts.SearchResult> results = AGENT_SearchAccounts.searchAccounts(
            new List<AGENT_SearchAccounts.SearchRequest>{ request }
        );

        System.assertEquals(2, results[0].AccountCount, 'Biotechnology utterance should map to Client_Type__c = Biotech.');
        System.assert(results[0].ResultsSummary.contains('Client Type: Biotech'), 'Summary should include Biotech client type.');
    }

    @IsTest
    static void biotechnologiesSearchTermUsesClientType() {
        AGENT_SearchAccounts.SearchRequest request = new AGENT_SearchAccounts.SearchRequest();
        request.SearchTerm = 'biotechnologies';

        List<AGENT_SearchAccounts.SearchResult> results = AGENT_SearchAccounts.searchAccounts(
            new List<AGENT_SearchAccounts.SearchRequest>{ request }
        );

        System.assertEquals(2, results[0].AccountCount, 'Biotechnologies search term should map to Client_Type__c = Biotech.');
    }

    @IsTest
    static void standardIndustryFilterStillWorks() {
        AGENT_SearchAccounts.SearchRequest request = new AGENT_SearchAccounts.SearchRequest();
        request.IndustryFilter = 'Healthcare';

        List<AGENT_SearchAccounts.SearchResult> results = AGENT_SearchAccounts.searchAccounts(
            new List<AGENT_SearchAccounts.SearchRequest>{ request }
        );

        System.assertEquals(1, results[0].AccountCount, 'Standard Industry search should continue to work for non-Astrum client type terms.');
        System.assert(results[0].ResultsSummary.contains('SAL21 Search Beta Pharma'), 'Healthcare industry account should be included.');
        System.assert(results[0].ResultsSummary.contains('Industry: Healthcare'), 'Summary should include industry.');
    }

    @IsTest
    static void typeFilterMatch() {
        AGENT_SearchAccounts.SearchRequest request = new AGENT_SearchAccounts.SearchRequest();
        request.TypeFilter = 'Customer';

        List<AGENT_SearchAccounts.SearchResult> results = AGENT_SearchAccounts.searchAccounts(
            new List<AGENT_SearchAccounts.SearchRequest>{ request }
        );

        System.assert(results[0].AccountCount >= 2, 'Type search should return Customer accounts.');
        System.assert(results[0].ResultsSummary.contains('Type: Customer'), 'Summary should include type.');
    }

    @IsTest
    static void combinedFiltersMatchAllProvidedFilters() {
        AGENT_SearchAccounts.SearchRequest request = new AGENT_SearchAccounts.SearchRequest();
        request.SearchTerm = 'Combined';
        request.IndustryFilter = 'Biotechnology';
        request.TypeFilter = 'Customer';

        List<AGENT_SearchAccounts.SearchResult> results = AGENT_SearchAccounts.searchAccounts(
            new List<AGENT_SearchAccounts.SearchRequest>{ request }
        );

        System.assertEquals(1, results[0].AccountCount, 'Combined filters should return exactly the matching test account.');
        System.assert(results[0].ResultsSummary.contains('SAL21 Combined Match'), 'Combined match should be included.');
        System.assert(!results[0].ResultsSummary.contains('SAL21 Search Alpha Biotech'), 'Nonmatching type should be excluded.');
        System.assert(!results[0].ResultsSummary.contains('SAL21 Standard Industry Biotechnology Only'), 'Non-Biotech client type should be excluded.');
    }

    @IsTest
    static void noResultsReturnsEmptySummary() {
        AGENT_SearchAccounts.SearchRequest request = new AGENT_SearchAccounts.SearchRequest();
        request.SearchTerm = 'NoSuchSAL21Account';

        List<AGENT_SearchAccounts.SearchResult> results = AGENT_SearchAccounts.searchAccounts(
            new List<AGENT_SearchAccounts.SearchRequest>{ request }
        );

        System.assertEquals(0, results[0].AccountCount, 'No result path should return zero count.');
        System.assertEquals('', results[0].ResultsSummary, 'No result path should return an empty summary.');
        System.assertEquals(null, results[0].ErrorMessage, 'No result path is not an error.');
    }

    @IsTest
    static void allFiltersBlankReturnsErrorWithoutQuery() {
        AGENT_SearchAccounts.SearchRequest request = new AGENT_SearchAccounts.SearchRequest();
        request.SearchTerm = ' ';
        request.IndustryFilter = null;
        request.TypeFilter = '';

        Integer queriesBefore = Limits.getQueries();
        List<AGENT_SearchAccounts.SearchResult> results = AGENT_SearchAccounts.searchAccounts(
            new List<AGENT_SearchAccounts.SearchRequest>{ request }
        );
        Integer queriesAfter = Limits.getQueries();

        System.assertEquals(queriesBefore, queriesAfter, 'No-input path should not execute SOQL.');
        System.assertEquals(0, results[0].AccountCount, 'No-input path should return zero count.');
        System.assertEquals('', results[0].ResultsSummary, 'No-input path should return empty summary.');
        System.assertEquals('At least one search filter must be provided.', results[0].ErrorMessage, 'No-input error mismatch.');
    }

    @IsTest
    static void exceptionPathReturnsError() {
        AGENT_SearchAccounts.SearchRequest request = new AGENT_SearchAccounts.SearchRequest();
        request.SearchTerm = 'Alpha';
        AGENT_SearchAccounts.forceExceptionForTest = true;

        List<AGENT_SearchAccounts.SearchResult> results = AGENT_SearchAccounts.searchAccounts(
            new List<AGENT_SearchAccounts.SearchRequest>{ request }
        );

        AGENT_SearchAccounts.forceExceptionForTest = false;
        System.assertEquals(0, results[0].AccountCount, 'Exception path should return zero count.');
        System.assertEquals('', results[0].ResultsSummary, 'Exception path should return empty summary.');
        System.assert(results[0].ErrorMessage.contains('Forced exception'), 'Exception path should return the exception message.');
    }
}
