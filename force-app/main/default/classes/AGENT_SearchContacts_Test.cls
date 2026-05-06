@IsTest
private class AGENT_SearchContacts_Test {
    @TestSetup
    static void setupData() {
        Account accountOne = new Account(Name = 'SAL21 Contact Account One');
        Account accountTwo = new Account(Name = 'SAL21 Contact Account Two');
        insert new List<Account>{ accountOne, accountTwo };

        insert new List<Contact>{
            new Contact(
                AccountId = accountOne.Id,
                FirstName = 'Ada',
                LastName = 'Searchson',
                Title = 'Procurement Lead',
                Email = 'ada.searchson@example.invalid',
                Phone = '+44 20 2000 0001'
            ),
            new Contact(
                AccountId = accountOne.Id,
                FirstName = 'Ben',
                LastName = 'Finder',
                Title = 'Clinical Director',
                Email = 'ben.finder@example.invalid',
                Phone = '+44 20 2000 0002'
            ),
            new Contact(
                AccountId = accountTwo.Id,
                FirstName = 'Cara',
                LastName = 'Lookup',
                Title = 'Finance Partner',
                Email = 'cara.lookup@example.invalid',
                Phone = '+44 20 2000 0003'
            )
        };
    }

    @IsTest
    static void searchTermMatchesLastName() {
        AGENT_SearchContacts.SearchRequest request = new AGENT_SearchContacts.SearchRequest();
        request.SearchTerm = 'Searchson';

        List<AGENT_SearchContacts.SearchResult> results = AGENT_SearchContacts.searchContacts(
            new List<AGENT_SearchContacts.SearchRequest>{ request }
        );

        System.assertEquals(1, results[0].ContactCount, 'LastName search should return one test contact.');
        System.assert(results[0].ResultsSummary.contains('Ada Searchson'), 'Summary should include matching contact name.');
        System.assertEquals(null, results[0].ErrorMessage, 'Search should not return an error.');
    }

    @IsTest
    static void accountNameMatch() {
        AGENT_SearchContacts.SearchRequest request = new AGENT_SearchContacts.SearchRequest();
        request.AccountName = 'SAL21 Contact Account One';

        List<AGENT_SearchContacts.SearchResult> results = AGENT_SearchContacts.searchContacts(
            new List<AGENT_SearchContacts.SearchRequest>{ request }
        );

        System.assertEquals(2, results[0].ContactCount, 'AccountName search should return two account contacts.');
        System.assert(results[0].ResultsSummary.contains('SAL21 Contact Account One'), 'Summary should include account name.');
    }

    @IsTest
    static void titleFilterMatch() {
        AGENT_SearchContacts.SearchRequest request = new AGENT_SearchContacts.SearchRequest();
        request.TitleFilter = 'Procurement';

        List<AGENT_SearchContacts.SearchResult> results = AGENT_SearchContacts.searchContacts(
            new List<AGENT_SearchContacts.SearchRequest>{ request }
        );

        System.assertEquals(1, results[0].ContactCount, 'Title filter should return one matching contact.');
        System.assert(results[0].ResultsSummary.contains('Procurement Lead'), 'Summary should include title.');
    }

    @IsTest
    static void noResultsReturnsEmptySummary() {
        AGENT_SearchContacts.SearchRequest request = new AGENT_SearchContacts.SearchRequest();
        request.SearchTerm = 'NoSuchSAL21Contact';

        List<AGENT_SearchContacts.SearchResult> results = AGENT_SearchContacts.searchContacts(
            new List<AGENT_SearchContacts.SearchRequest>{ request }
        );

        System.assertEquals(0, results[0].ContactCount, 'No result path should return zero count.');
        System.assertEquals('', results[0].ResultsSummary, 'No result path should return empty summary.');
        System.assertEquals(null, results[0].ErrorMessage, 'No result path is not an error.');
    }

    @IsTest
    static void allFiltersBlankReturnsErrorWithoutQuery() {
        AGENT_SearchContacts.SearchRequest request = new AGENT_SearchContacts.SearchRequest();
        request.SearchTerm = '';
        request.AccountName = ' ';
        request.TitleFilter = null;

        Integer queriesBefore = Limits.getQueries();
        List<AGENT_SearchContacts.SearchResult> results = AGENT_SearchContacts.searchContacts(
            new List<AGENT_SearchContacts.SearchRequest>{ request }
        );
        Integer queriesAfter = Limits.getQueries();

        System.assertEquals(queriesBefore, queriesAfter, 'No-input path should not execute SOQL.');
        System.assertEquals(0, results[0].ContactCount, 'No-input path should return zero count.');
        System.assertEquals('', results[0].ResultsSummary, 'No-input path should return empty summary.');
        System.assertEquals('At least one search filter must be provided.', results[0].ErrorMessage, 'No-input error mismatch.');
    }

    @IsTest
    static void exceptionPathReturnsError() {
        AGENT_SearchContacts.SearchRequest request = new AGENT_SearchContacts.SearchRequest();
        request.SearchTerm = 'Searchson';
        AGENT_SearchContacts.forceExceptionForTest = true;

        List<AGENT_SearchContacts.SearchResult> results = AGENT_SearchContacts.searchContacts(
            new List<AGENT_SearchContacts.SearchRequest>{ request }
        );

        AGENT_SearchContacts.forceExceptionForTest = false;
        System.assertEquals(0, results[0].ContactCount, 'Exception path should return zero count.');
        System.assertEquals('', results[0].ResultsSummary, 'Exception path should return empty summary.');
        System.assert(results[0].ErrorMessage.contains('Forced exception'), 'Exception path should return the exception message.');
    }
}
