public with sharing class AGENT_GetOpportunityDetails {
    @InvocableMethod(label='Get Opportunity Details' description='Retrieve details for a specific Opportunity by ID, Opportunity Code, name, or account name.')
    public static List<DetailsResult> getOpportunityDetails(List<DetailsRequest> requests) {
        List<DetailsResult> results = new List<DetailsResult>();
        if (requests == null || requests.isEmpty()) {
            DetailsResult result = new DetailsResult();
            result.Success = false;
            result.ErrorMessage = 'No Opportunity lookup request was provided.';
            results.add(result);
            return results;
        }

        for (DetailsRequest request : requests) {
            results.add(handleRequest(request));
        }
        return results;
    }

    private static DetailsResult handleRequest(DetailsRequest request) {
        DetailsResult result = new DetailsResult();
        result.Success = false;

        try {
            List<Opportunity> opportunities = findOpportunities(
                request == null ? null : request.OpportunityId,
                request == null ? null : request.OpportunityName,
                request == null ? null : request.AccountName,
                request == null ? null : request.OpportunityCode,
                10
            );

            result.MatchCount = opportunities.size();
            if (opportunities.isEmpty()) {
                result.ErrorMessage = 'No Opportunity matched the supplied criteria.';
                return result;
            }

            if (opportunities.size() > 1) {
                result.CandidateSummary = formatCandidates(opportunities);
                result.ErrorMessage = 'Multiple Opportunities matched. Ask the user to select one candidate before continuing.';
                return result;
            }

            Opportunity opp = opportunities[0];
            result.Success = true;
            result.OpportunityId = opp.Id;
            result.OpportunityName = opp.Name;
            result.AccountName = opp.Account == null ? null : opp.Account.Name;
            result.StageName = opp.StageName;
            result.CloseDate = opp.CloseDate;
            result.DetailsSummary = formatDetails(opp);
        } catch (Exception e) {
            result.ErrorMessage = e.getMessage();
        }

        return result;
    }

    private static List<Opportunity> findOpportunities(
        String opportunityId,
        String opportunityName,
        String accountName,
        String opportunityCode,
        Integer maxRows
    ) {
        List<String> filters = new List<String>();
        String safeId;
        String namePattern;
        String accountPattern;
        String safeCode;

        if (String.isNotBlank(opportunityId)) {
            safeId = String.escapeSingleQuotes(opportunityId.trim());
            filters.add('Id = :safeId');
        } else {
            if (String.isNotBlank(opportunityCode)) {
                safeCode = opportunityCode.trim();
                filters.add('Opportunity_Code__c = :safeCode');
            }
            if (String.isNotBlank(opportunityName)) {
                namePattern = '%' + String.escapeSingleQuotes(opportunityName.trim()) + '%';
                filters.add('Name LIKE :namePattern');
            }
            if (String.isNotBlank(accountName)) {
                accountPattern = '%' + String.escapeSingleQuotes(accountName.trim()) + '%';
                filters.add('Account.Name LIKE :accountPattern');
            }
        }

        if (filters.isEmpty()) {
            throw new AuraHandledException('OpportunityId, OpportunityName, OpportunityCode, or AccountName is required.');
        }

        String query = baseQuery() + ' WHERE ' + String.join(filters, ' AND ')
            + ' WITH USER_MODE ORDER BY LastModifiedDate DESC LIMIT ' + maxRows;
        return Database.query(query);
    }

    private static String baseQuery() {
        return 'SELECT Id, Name, Account.Name, Account.Client_Type__c, Account.Account_Segment__c, '
            + 'StageName, CloseDate, ForecastCategoryName, Amount, Service_Fees__c, Opp_Probability__c, '
            + 'Business_Category__c, Therapeutic_Area__c, Study_Phase_Type__c, NextStep, '
            + 'Next_specific_action__c, Date_of_next_specific_action__c, Person_responsible_for_next_action__c, '
            + 'Last_client_interaction_date__c, Opportunity_Code__c, Award_Date__c, Business_Type__c '
            + 'FROM Opportunity';
    }

    private static String formatDetails(Opportunity opp) {
        List<String> parts = new List<String>();
        add(parts, 'Opportunity', opp.Name);
        add(parts, 'Account', opp.Account == null ? null : opp.Account.Name);
        add(parts, 'Stage', opp.StageName);
        add(parts, 'Close Date', opp.CloseDate);
        add(parts, 'Forecast Category', opp.ForecastCategoryName);
        add(parts, 'Amount', opp.Amount);
        add(parts, 'Service Fees', opp.Service_Fees__c);
        add(parts, 'Opp Probability', opp.Opp_Probability__c);
        add(parts, 'Business Category', opp.Business_Category__c);
        add(parts, 'Therapeutic Area', opp.Therapeutic_Area__c);
        add(parts, 'Study Phase Type', opp.Study_Phase_Type__c);
        add(parts, 'Next Step', opp.NextStep);
        add(parts, 'Next Specific Action', opp.Next_specific_action__c);
        add(parts, 'Date of Next Action', opp.Date_of_next_specific_action__c);
        add(parts, 'Person Responsible', opp.Person_responsible_for_next_action__c);
        add(parts, 'Last Client Interaction', opp.Last_client_interaction_date__c);
        add(parts, 'Opportunity Code', opp.Opportunity_Code__c);
        add(parts, 'Award Date', opp.Award_Date__c);
        add(parts, 'Business Type', opp.Business_Type__c);
        add(parts, 'Account Client Type', opp.Account == null ? null : opp.Account.Client_Type__c);
        add(parts, 'Account Segment', opp.Account == null ? null : opp.Account.Account_Segment__c);
        return String.join(parts, '; ');
    }

    private static String formatCandidates(List<Opportunity> opportunities) {
        List<String> lines = new List<String>();
        for (Opportunity opp : opportunities) {
            lines.add('- ' + opp.Name
                + '; Account: ' + blank(opp.Account == null ? null : opp.Account.Name)
                + '; Stage: ' + blank(opp.StageName)
                + '; Close Date: ' + blank(opp.CloseDate)
                + '; Opportunity Code: ' + blank(opp.Opportunity_Code__c)
                + '; Id: ' + opp.Id);
        }
        return String.join(lines, '\n');
    }

    private static void add(List<String> parts, String label, Object value) {
        if (value != null && String.isNotBlank(String.valueOf(value))) {
            parts.add(label + ': ' + String.valueOf(value));
        }
    }

    private static String blank(Object value) {
        return value == null ? '' : String.valueOf(value);
    }

    public class DetailsRequest {
        @InvocableVariable(required=false)
        public String OpportunityId;

        @InvocableVariable(required=false)
        public String OpportunityName;

        @InvocableVariable(required=false)
        public String AccountName;

        @InvocableVariable(required=false)
        public String OpportunityCode;
    }

    public class DetailsResult {
        @InvocableVariable public Boolean Success;
        @InvocableVariable public Integer MatchCount;
        @InvocableVariable public String OpportunityId;
        @InvocableVariable public String OpportunityName;
        @InvocableVariable public String AccountName;
        @InvocableVariable public String StageName;
        @InvocableVariable public Date CloseDate;
        @InvocableVariable public String DetailsSummary;
        @InvocableVariable public String CandidateSummary;
        @InvocableVariable public String ErrorMessage;
    }
}
