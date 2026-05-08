@IsTest
private class AGENT_SearchAccounts_Test {
    @TestSetup
    static void setupData() {
        insert new List<Account>{
            new Account(
                Name = 'SAL21 Search Alpha Biotech',
                Industry = 'Biotechnology',
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
                Industry = 'Biotechnology',
                Type = 'Customer',
                Phone = '+44 20 1000 0003',
                BillingCity = 'Oxford',
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
    static void industryFilterMatch() {
        AGENT_SearchAccounts.SearchRequest request = new AGENT_SearchAccounts.SearchRequest();
        request.IndustryFilter = 'Biotechnology';

        List<AGENT_SearchAccounts.SearchResult> results = AGENT_SearchAccounts.searchAccounts(
            new List<AGENT_SearchAccounts.SearchRequest>{ request }
        );

        System.assert(results[0].AccountCount >= 2, 'Industry search should return Biotechnology accounts.');
        System.assert(results[0].ResultsSummary.contains('Industry: Biotechnology'), 'Summary should include industry.');
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
