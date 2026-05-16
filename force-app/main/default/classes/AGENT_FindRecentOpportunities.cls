public with sharing class AGENT_FindRecentOpportunities {
    @InvocableMethod(label='Find Opportunities Created Recently' description='Read-only. Always use this action when the user asks to show, search, or list Opportunities created in the last N days, such as "created in last 5 days" or "created recently".')
    public static List<RecencyResult> findRecentlyCreated(List<RecencyRequest> requests) {
        List<RecencyResult> results = new List<RecencyResult>();
        if (requests == null || requests.isEmpty()) {
            requests = new List<RecencyRequest>{ new RecencyRequest() };
        }

        for (RecencyRequest request : requests) {
            results.add(handleRequest(request));
        }
        return results;
    }

    private static RecencyResult handleRequest(RecencyRequest request) {
        RecencyResult result = new RecencyResult();
        result.OpportunityCount = 0;
        result.ResultsSummary = '';

        try {
            Integer days = normalizeDays(request == null ? null : request.Days, 7);
            if (days == null) {
                result.ErrorMessage = 'Days must be between 1 and 365.';
                return result;
            }

            Datetime cutoffDateTime = System.now().addDays(-days);
            List<String> filters = new List<String>{ 'CreatedDate >= :cutoffDateTime' };
            String accountPattern;
            String stageValue;
            String ownerPattern;

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

            String query = 'SELECT Id, Name, Account.Name, StageName, CloseDate, Opp_Probability__c, '
                + 'Opportunity_Code__c, Owner.Name, CreatedDate, Last_client_interaction_date__c, NextStep '
                + 'FROM Opportunity WHERE '
                + String.join(filters, ' AND ')
                + ' WITH USER_MODE ORDER BY CreatedDate DESC LIMIT 10';
            List<Opportunity> opportunities = Database.query(query);

            result.OpportunityCount = opportunities.size();
            result.QueryDescription = 'Opportunities created in the last ' + days + ' days';
            result.ResultsSummary = formatResults(opportunities);
        } catch (Exception e) {
            result.OpportunityCount = 0;
            result.ResultsSummary = '';
            result.ErrorMessage = e.getMessage();
        }

        return result;
    }

    private static Integer normalizeDays(Integer requestedDays, Integer defaultDays) {
        Integer days = requestedDays == null ? defaultDays : requestedDays;
        if (days < 1 || days > 365) {
            return null;
        }
        return days;
    }

    private static String formatResults(List<Opportunity> opportunities) {
        if (opportunities.isEmpty()) {
            return 'No matching Opportunities were found.';
        }

        List<String> lines = new List<String>{
            '| Opportunity | Account | Stage | Close Date | Opp Probability | Code | Created | Last Client Interaction | Next Step | Owner | Id |',
            '|---|---|---|---|---|---|---|---|---|---|---|'
        };
        for (Opportunity opp : opportunities) {
            lines.add('| ' + cell(opp.Name)
                + ' | ' + cell(opp.Account == null ? null : opp.Account.Name)
                + ' | ' + cell(opp.StageName)
                + ' | ' + cell(opp.CloseDate)
                + ' | ' + cell(opp.Opp_Probability__c)
                + ' | ' + cell(opp.Opportunity_Code__c)
                + ' | ' + cell(dateOnly(opp.CreatedDate))
                + ' | ' + cell(opp.Last_client_interaction_date__c)
                + ' | ' + cell(opp.NextStep)
                + ' | ' + cell(opp.Owner == null ? null : opp.Owner.Name)
                + ' | ' + cell(opp.Id)
                + ' |');
        }
        return String.join(lines, '\n');
    }

    private static String cell(Object value) {
        if (value == null) {
            return '';
        }
        return String.valueOf(value)
            .replace('|', '\\|')
            .replace('\r', ' ')
            .replace('\n', ' ');
    }

    private static String dateOnly(Datetime value) {
        return value == null ? null : value.format('yyyy-MM-dd');
    }

    public class RecencyRequest {
        @InvocableVariable(required=false label='Days' description='Number of days from the user. For "last 5 days", pass 5. If the user only says "created recently", leave blank and the action uses 7 days.')
        public Integer Days;
        @InvocableVariable(required=false label='Account Name' description='Optional account name filter if the user asks for recent Opportunities for a specific account.')
        public String AccountName;
        @InvocableVariable(required=false label='Stage Name' description='Optional stage filter if the user asks for recent Opportunities in a specific stage.')
        public String StageName;
        @InvocableVariable(required=false label='Owner Name' description='Optional owner name filter if the user asks for recent Opportunities owned by a specific person.')
        public String OwnerName;
    }

    public class RecencyResult {
        @InvocableVariable public String QueryDescription;
        @InvocableVariable public String ResultsSummary;
        @InvocableVariable public Integer OpportunityCount;
        @InvocableVariable public String ErrorMessage;
    }
}
