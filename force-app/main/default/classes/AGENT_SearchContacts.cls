public with sharing class AGENT_SearchContacts {
    @TestVisible
    private static Boolean forceExceptionForTest = false;

    private class SearchContactsException extends Exception {
    }

    @InvocableMethod(label='Search Contacts' description='Search for Contact records matching name, account, or title criteria. Returns up to 10 results.')
    public static List<SearchResult> searchContacts(List<SearchRequest> requests) {
        List<SearchResult> results = new List<SearchResult>();
        if (requests == null || requests.isEmpty()) {
            results.add(noInputResult());
            return results;
        }

        for (SearchRequest request : requests) {
            results.add(searchSingleRequest(request));
        }
        return results;
    }

    private static SearchResult searchSingleRequest(SearchRequest request) {
        SearchResult result = new SearchResult();
        result.ResultsSummary = '';
        result.ContactCount = 0;

        String searchTerm = request == null ? null : request.SearchTerm;
        String accountName = request == null ? null : request.AccountName;
        String titleFilter = request == null ? null : request.TitleFilter;

        Boolean hasSearchTerm = !String.isBlank(searchTerm);
        Boolean hasAccountName = !String.isBlank(accountName);
        Boolean hasTitleFilter = !String.isBlank(titleFilter);

        if (!hasSearchTerm && !hasAccountName && !hasTitleFilter) {
            result.ErrorMessage = 'At least one search filter must be provided.';
            return result;
        }

        try {
            if (forceExceptionForTest) {
                throw new SearchContactsException('Forced exception for test coverage.');
            }

            List<String> filters = new List<String>();
            String searchPattern;
            String accountNameValue;
            String titlePattern;
            if (hasSearchTerm) {
                searchPattern = '%' + String.escapeSingleQuotes(searchTerm.trim()) + '%';
                filters.add('LastName LIKE :searchPattern');
            }
            if (hasAccountName) {
                accountNameValue = accountName.trim();
                filters.add('Account.Name = :accountNameValue');
            }
            if (hasTitleFilter) {
                titlePattern = '%' + String.escapeSingleQuotes(titleFilter.trim()) + '%';
                filters.add('Title LIKE :titlePattern');
            }

            String query =
                'SELECT Id, FirstName, LastName, Title, Email, Phone, Account.Name ' +
                'FROM Contact WHERE ' + String.join(filters, ' AND ') + ' WITH USER_MODE LIMIT 10';
            List<Contact> contacts = Database.query(query);
            result.ContactCount = contacts.size();
            result.ResultsSummary = formatContacts(contacts);
        } catch (Exception e) {
            result.ContactCount = 0;
            result.ResultsSummary = '';
            result.ErrorMessage = e.getMessage();
        }

        return result;
    }

    private static SearchResult noInputResult() {
        SearchResult result = new SearchResult();
        result.ResultsSummary = '';
        result.ContactCount = 0;
        result.ErrorMessage = 'At least one search filter must be provided.';
        return result;
    }

    private static String formatContacts(List<Contact> contacts) {
        if (contacts.isEmpty()) {
            return '';
        }

        List<String> lines = new List<String>();
        for (Contact contactRecord : contacts) {
            List<String> parts = new List<String>();
            parts.add('Name: ' + buildFullName(contactRecord));
            parts.add('Title: ' + blankIfNull(contactRecord.Title));
            parts.add('Account: ' + (contactRecord.Account == null ? '' : blankIfNull(contactRecord.Account.Name)));
            parts.add('Email: ' + blankIfNull(contactRecord.Email));
            parts.add('Phone: ' + blankIfNull(contactRecord.Phone));
            lines.add('- ' + String.join(parts, '; '));
        }
        return String.join(lines, '\n');
    }

    private static String buildFullName(Contact contactRecord) {
        List<String> nameParts = new List<String>();
        if (!String.isBlank(contactRecord.FirstName)) {
            nameParts.add(contactRecord.FirstName);
        }
        if (!String.isBlank(contactRecord.LastName)) {
            nameParts.add(contactRecord.LastName);
        }
        return String.join(nameParts, ' ');
    }

    private static String blankIfNull(Object value) {
        return value == null ? '' : String.valueOf(value);
    }

    public class SearchRequest {
        @InvocableVariable(required=false)
        public String SearchTerm;

        @InvocableVariable(required=false)
        public String AccountName;

        @InvocableVariable(required=false)
        public String TitleFilter;
    }

    public class SearchResult {
        @InvocableVariable
        public String ResultsSummary;

        @InvocableVariable
        public Integer ContactCount;

        @InvocableVariable
        public String ErrorMessage;
    }
}
