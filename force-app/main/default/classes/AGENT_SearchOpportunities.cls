public with sharing class AGENT_SearchOpportunities {
    @InvocableMethod(label='Search Opportunities' description='Search Opportunity records by opportunity name, account name, stage, owner name, or Opportunity Code.')
    public static List<SearchResult> searchOpportunities(List<SearchRequest> requests) {
        List<SearchResult> results = new List<SearchResult>();
        if (requests == null || requests.isEmpty()) {
            SearchResult result = new SearchResult();
            result.OpportunityCount = 0;
            result.ResultsSummary = '';
            result.ErrorMessage = 'At least one search filter must be provided.';
            results.add(result);
            return results;
        }

        for (SearchRequest request : requests) {
            results.add(handleRequest(request));
        }
        return results;
    }

    private static SearchResult handleRequest(SearchRequest request) {
        SearchResult result = new SearchResult();
        result.OpportunityCount = 0;
        result.ResultsSummary = '';

        try {
            List<String> filters = new List<String>();
            String termPattern;
            String accountPattern;
            String stageValue;
            String ownerPattern;
            String codeValue;

            if (request != null && String.isNotBlank(request.SearchTerm)) {
                termPattern = '%' + String.escapeSingleQuotes(request.SearchTerm.trim()) + '%';
                filters.add('Name LIKE :termPattern');
            }
            if (request != null && String.isNotBlank(request.AccountName)) {
                accountPattern = '%' + String.escapeSingleQuotes(request.AccountName.trim()) + '%';
                filters.add('Account.Name LIKE :accountPattern');
            }
            if (request != null && String.isNotBlank(request.StageName)) {
                stageValue = request.StageName.trim();
                filters.add('StageName = :stageValue');
            }
            if (request != null && String.isNotBlank(request.OwnerName)) {
                ownerPattern = '%' + String.escapeSingleQuotes(request.OwnerName.trim()) + '%';
                filters.add('Owner.Name LIKE :ownerPattern');
            }
            if (request != null && String.isNotBlank(request.OpportunityCode)) {
                codeValue = request.OpportunityCode.trim();
                filters.add('Opportunity_Code__c = :codeValue');
            }

            if (filters.isEmpty()) {
                result.ErrorMessage = 'At least one search filter must be provided.';
                return result;
            }

            String query = 'SELECT Id, Name, Account.Name, StageName, CloseDate, Opp_Probability__c, '
                + 'Opportunity_Code__c, Owner.Name FROM Opportunity WHERE '
                + String.join(filters, ' AND ')
                + ' WITH USER_MODE ORDER BY LastModifiedDate DESC LIMIT 10';
            List<Opportunity> opportunities = Database.query(query);
            result.OpportunityCount = opportunities.size();
            result.ResultsSummary = formatResults(opportunities);
        } catch (Exception e) {
            result.OpportunityCount = 0;
            result.ResultsSummary = '';
            result.ErrorMessage = e.getMessage();
        }

        return result;
    }

    private static String formatResults(List<Opportunity> opportunities) {
        List<String> lines = new List<String>();
        for (Opportunity opp : opportunities) {
            lines.add('- ' + opp.Name
                + '; Account: ' + blank(opp.Account == null ? null : opp.Account.Name)
                + '; Stage: ' + blank(opp.StageName)
                + '; Close Date: ' + blank(opp.CloseDate)
                + '; Opp Probability: ' + blank(opp.Opp_Probability__c)
                + '; Opportunity Code: ' + blank(opp.Opportunity_Code__c)
                + '; Owner: ' + blank(opp.Owner == null ? null : opp.Owner.Name)
                + '; Id: ' + opp.Id);
        }
        return String.join(lines, '\n');
    }

    private static String blank(Object value) {
        return value == null ? '' : String.valueOf(value);
    }

    public class SearchRequest {
        @InvocableVariable(required=false) public String SearchTerm;
        @InvocableVariable(required=false) public String AccountName;
        @InvocableVariable(required=false) public String StageName;
        @InvocableVariable(required=false) public String OwnerName;
        @InvocableVariable(required=false) public String OpportunityCode;
    }

    public class SearchResult {
        @InvocableVariable public String ResultsSummary;
        @InvocableVariable public Integer OpportunityCount;
        @InvocableVariable public String ErrorMessage;
    }
}
