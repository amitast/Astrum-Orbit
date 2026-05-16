public with sharing class AGENT_SearchOpportunities {
    @InvocableMethod(label='Search Opportunities' description='Search Opportunity records by opportunity name, account name, stage, owner name, Opportunity Code, created date recency, or stale last-client-action recency.')
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
            Date noActionCutoffDate;
            Datetime createdCutoffDate;

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
            if (request != null && request.NoActionInLastDays != null) {
                if (request.NoActionInLastDays < 1 || request.NoActionInLastDays > 365) {
                    result.ErrorMessage = 'NoActionInLastDays must be between 1 and 365.';
                    return result;
                }
                noActionCutoffDate = Date.today().addDays(-request.NoActionInLastDays);
                filters.add('(Last_client_interaction_date__c = NULL OR Last_client_interaction_date__c < :noActionCutoffDate)');
            }
            if (request != null && request.CreatedInLastDays != null) {
                if (request.CreatedInLastDays < 1 || request.CreatedInLastDays > 365) {
                    result.ErrorMessage = 'CreatedInLastDays must be between 1 and 365.';
                    return result;
                }
                createdCutoffDate = System.now().addDays(-request.CreatedInLastDays);
                filters.add('CreatedDate >= :createdCutoffDate');
            }

            if (filters.isEmpty()) {
                result.ErrorMessage = 'At least one search filter must be provided.';
                return result;
            }

            String query = 'SELECT Id, Name, Account.Name, StageName, CloseDate, Opp_Probability__c, '
                + 'Opportunity_Code__c, Owner.Name, CreatedDate, Last_client_interaction_date__c, NextStep '
                + 'FROM Opportunity WHERE '
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
                + '; Created Date: ' + blank(opp.CreatedDate)
                + '; Last Client Interaction: ' + blank(opp.Last_client_interaction_date__c)
                + '; Next Step: ' + blank(opp.NextStep)
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
        @InvocableVariable(
            required=false
            label='No Action In Last Days'
            description='Set to 30 when the user asks for opportunities with no action in the last 30 days or no action recently. Filters records where Last_client_interaction_date__c is blank or older than this many days.'
        )
        public Integer NoActionInLastDays;
        @InvocableVariable(
            required=false
            label='Created In Last Days'
            description='Set to 7 when the user asks for opportunities created in the last 7 days or created recently. Filters records where CreatedDate is within this many days.'
        )
        public Integer CreatedInLastDays;
    }

    public class SearchResult {
        @InvocableVariable public String ResultsSummary;
        @InvocableVariable public Integer OpportunityCount;
        @InvocableVariable public String ErrorMessage;
    }
}
