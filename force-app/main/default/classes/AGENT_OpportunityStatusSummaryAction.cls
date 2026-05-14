public with sharing class AGENT_OpportunityStatusSummaryAction {
    @InvocableMethod(label='Opportunity Status Summary' description='Summarise current deal status, next action, and visible risk signals using Salesforce Opportunity and Account fields only.')
    public static List<SummaryResult> summarize(List<SummaryRequest> requests) {
        List<SummaryResult> results = new List<SummaryResult>();
        if (requests == null || requests.isEmpty()) {
            SummaryResult result = new SummaryResult();
            result.Success = false;
            result.ErrorMessage = 'OpportunityId, OpportunityName, OpportunityCode, or AccountName is required.';
            results.add(result);
            return results;
        }

        for (SummaryRequest request : requests) {
            results.add(handleRequest(request));
        }
        return results;
    }

    private static SummaryResult handleRequest(SummaryRequest request) {
        SummaryResult result = new SummaryResult();
        result.Success = false;

        try {
            List<Opportunity> opportunities = findOpportunities(request, 10);
            result.MatchCount = opportunities.size();
            if (opportunities.isEmpty()) {
                result.ErrorMessage = 'No Opportunity matched the supplied criteria.';
                return result;
            }
            if (opportunities.size() > 1) {
                result.CandidateSummary = formatCandidates(opportunities);
                result.ErrorMessage = 'Multiple Opportunities matched. Ask the user to select one candidate before summarising.';
                return result;
            }

            Opportunity opp = opportunities[0];
            result.Success = true;
            result.OpportunityId = opp.Id;
            result.OpportunityName = opp.Name;
            result.AccountName = opp.Account == null ? null : opp.Account.Name;
            result.Summary = buildSummary(opp);
        } catch (Exception e) {
            result.ErrorMessage = e.getMessage();
        }

        return result;
    }

    private static List<Opportunity> findOpportunities(SummaryRequest request, Integer maxRows) {
        List<String> filters = new List<String>();
        String safeId;
        String namePattern;
        String accountPattern;
        String safeCode;

        if (request != null && String.isNotBlank(request.OpportunityId)) {
            safeId = String.escapeSingleQuotes(request.OpportunityId.trim());
            filters.add('Id = :safeId');
        } else {
            if (request != null && String.isNotBlank(request.OpportunityCode)) {
                safeCode = request.OpportunityCode.trim();
                filters.add('Opportunity_Code__c = :safeCode');
            }
            if (request != null && String.isNotBlank(request.OpportunityName)) {
                namePattern = '%' + String.escapeSingleQuotes(request.OpportunityName.trim()) + '%';
                filters.add('Name LIKE :namePattern');
            }
            if (request != null && String.isNotBlank(request.AccountName)) {
                accountPattern = '%' + String.escapeSingleQuotes(request.AccountName.trim()) + '%';
                filters.add('Account.Name LIKE :accountPattern');
            }
        }

        if (filters.isEmpty()) {
            throw new AuraHandledException('OpportunityId, OpportunityName, OpportunityCode, or AccountName is required.');
        }

        String query = 'SELECT Id, Name, Account.Name, Account.Client_Type__c, Account.Account_Segment__c, '
            + 'StageName, CloseDate, ForecastCategoryName, Amount, Service_Fees__c, Opp_Probability__c, '
            + 'Business_Category__c, Therapeutic_Area__c, Study_Phase_Type__c, NextStep, '
            + 'Next_specific_action__c, Date_of_next_specific_action__c, Person_responsible_for_next_action__c, '
            + 'Last_client_interaction_date__c, Opportunity_Code__c, Award_Date__c, Business_Type__c '
            + 'FROM Opportunity WHERE ' + String.join(filters, ' AND ')
            + ' WITH USER_MODE ORDER BY LastModifiedDate DESC LIMIT ' + maxRows;
        return Database.query(query);
    }

    @TestVisible
    private static String buildSummary(Opportunity opp) {
        List<String> sections = new List<String>();
        List<String> status = new List<String>();
        status.add(opp.Name);
        if (opp.Account != null && String.isNotBlank(opp.Account.Name)) {
            status.add('for ' + opp.Account.Name);
        }
        if (String.isNotBlank(opp.StageName)) {
            status.add('is at ' + opp.StageName);
        }
        if (opp.CloseDate != null) {
            status.add('with close date ' + String.valueOf(opp.CloseDate));
        }
        if (String.isNotBlank(opp.ForecastCategoryName)) {
            status.add('forecast ' + opp.ForecastCategoryName);
        }
        if (String.isNotBlank(opp.Opp_Probability__c)) {
            status.add('and Opp Probability ' + opp.Opp_Probability__c);
        }
        sections.add('Current deal status: ' + String.join(status, ' ') + '.');

        List<String> commercial = new List<String>();
        add(commercial, 'Amount', opp.Amount);
        add(commercial, 'Service Fees', opp.Service_Fees__c);
        add(commercial, 'Business Category', opp.Business_Category__c);
        add(commercial, 'Therapeutic Area', opp.Therapeutic_Area__c);
        add(commercial, 'Study Phase Type', opp.Study_Phase_Type__c);
        add(commercial, 'Business Type', opp.Business_Type__c);
        if (!commercial.isEmpty()) {
            sections.add('Visible commercial context: ' + String.join(commercial, '; ') + '.');
        }

        List<String> nextAction = new List<String>();
        add(nextAction, 'Next Step', opp.NextStep);
        add(nextAction, 'Next Specific Action', opp.Next_specific_action__c);
        add(nextAction, 'Due Date', opp.Date_of_next_specific_action__c);
        add(nextAction, 'Responsible', opp.Person_responsible_for_next_action__c);
        if (!nextAction.isEmpty()) {
            sections.add('Next action: ' + String.join(nextAction, '; ') + '.');
        }

        List<String> risks = new List<String>();
        if (opp.CloseDate != null && opp.CloseDate < Date.today()) {
            risks.add('close date is in the past');
        }
        if (String.isBlank(opp.NextStep) && String.isBlank(opp.Next_specific_action__c)) {
            risks.add('no visible next step is recorded');
        }
        if (opp.Last_client_interaction_date__c != null && opp.Last_client_interaction_date__c < Date.today().addDays(-30)) {
            risks.add('last client interaction is more than 30 days old');
        }
        if (!risks.isEmpty()) {
            sections.add('Visible risk signals: ' + String.join(risks, '; ') + '.');
        }

        return String.join(sections, ' ');
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

    public class SummaryRequest {
        @InvocableVariable(required=false) public String OpportunityId;
        @InvocableVariable(required=false) public String OpportunityName;
        @InvocableVariable(required=false) public String AccountName;
        @InvocableVariable(required=false) public String OpportunityCode;
    }

    public class SummaryResult {
        @InvocableVariable public Boolean Success;
        @InvocableVariable public Integer MatchCount;
        @InvocableVariable public String OpportunityId;
        @InvocableVariable public String OpportunityName;
        @InvocableVariable public String AccountName;
        @InvocableVariable public String Summary;
        @InvocableVariable public String CandidateSummary;
        @InvocableVariable public String ErrorMessage;
    }
}
