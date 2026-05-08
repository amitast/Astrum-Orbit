public with sharing class AGENT_SearchAccounts {
    @TestVisible
    private static Boolean forceExceptionForTest = false;

    private class SearchAccountsException extends Exception {
    }

    @InvocableMethod(label='Search Accounts' description='Search for Account records matching name, industry, or type criteria. Returns up to 10 results.')
    public static List<SearchResult> searchAccounts(List<SearchRequest> requests) {
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
        result.AccountCount = 0;

        String searchTerm = request == null ? null : request.SearchTerm;
        String industryFilter = request == null ? null : request.IndustryFilter;
        String typeFilter = request == null ? null : request.TypeFilter;

        Boolean hasSearchTerm = !String.isBlank(searchTerm);
        Boolean hasIndustryFilter = !String.isBlank(industryFilter);
        Boolean hasTypeFilter = !String.isBlank(typeFilter);

        if (!hasSearchTerm && !hasIndustryFilter && !hasTypeFilter) {
            result.ErrorMessage = 'At least one search filter must be provided.';
            return result;
        }

        try {
            if (forceExceptionForTest) {
                throw new SearchAccountsException('Forced exception for test coverage.');
            }

            List<String> filters = new List<String>();
            String searchPattern;
            String industryValue;
            String typeValue;
            if (hasSearchTerm) {
                searchPattern = '%' + String.escapeSingleQuotes(searchTerm.trim()) + '%';
                filters.add('Name LIKE :searchPattern');
            }
            if (hasIndustryFilter) {
                industryValue = industryFilter.trim();
                filters.add('Industry = :industryValue');
            }
            if (hasTypeFilter) {
                typeValue = typeFilter.trim();
                filters.add('Type = :typeValue');
            }

            String query =
                'SELECT Id, Name, Industry, Type, Phone, BillingCity, BillingCountry, Owner.Name ' +
                'FROM Account WHERE ' + String.join(filters, ' AND ') + ' WITH USER_MODE LIMIT 10';
            List<Account> accounts = Database.query(query);
            result.AccountCount = accounts.size();
            result.ResultsSummary = formatAccounts(accounts);
        } catch (Exception e) {
            result.AccountCount = 0;
            result.ResultsSummary = '';
            result.ErrorMessage = e.getMessage();
        }

        return result;
    }

    private static SearchResult noInputResult() {
        SearchResult result = new SearchResult();
        result.ResultsSummary = '';
        result.AccountCount = 0;
        result.ErrorMessage = 'At least one search filter must be provided.';
        return result;
    }

    private static String formatAccounts(List<Account> accounts) {
        if (accounts.isEmpty()) {
            return '';
        }

        List<String> lines = new List<String>();
        for (Account accountRecord : accounts) {
            List<String> parts = new List<String>();
            parts.add('Name: ' + accountRecord.Name);
            parts.add('Industry: ' + blankIfNull(accountRecord.Industry));
            parts.add('Type: ' + blankIfNull(accountRecord.Type));
            parts.add('City/Country: ' + blankIfNull(accountRecord.BillingCity) + '/' + blankIfNull(accountRecord.BillingCountry));
            lines.add('- ' + String.join(parts, '; '));
        }
        return String.join(lines, '\n');
    }

    private static String blankIfNull(Object value) {
        return value == null ? '' : String.valueOf(value);
    }

    public class SearchRequest {
        @InvocableVariable(required=false)
        public String SearchTerm;

        @InvocableVariable(required=false)
        public String IndustryFilter;

        @InvocableVariable(required=false)
        public String TypeFilter;
    }

    public class SearchResult {
        @InvocableVariable
        public String ResultsSummary;

        @InvocableVariable
        public Integer AccountCount;

        @InvocableVariable
        public String ErrorMessage;
    }
}
