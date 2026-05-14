public with sharing class AGENT_CreateOpportunity {
    @InvocableMethod(label='Create Opportunity' description='Create one Opportunity after user confirmation. Validates mandatory Astrum Opportunity fields before insert.')
    public static List<CreateResult> createOpportunity(List<CreateRequest> requests) {
        List<CreateResult> results = new List<CreateResult>();
        if (requests == null || requests.isEmpty()) {
            CreateResult result = new CreateResult();
            result.Success = false;
            result.ErrorMessage = 'No create request was provided.';
            results.add(result);
            return results;
        }

        for (CreateRequest request : requests) {
            results.add(handleRequest(request));
        }
        return results;
    }

    private static CreateResult handleRequest(CreateRequest request) {
        CreateResult result = new CreateResult();
        result.Success = false;

        List<String> missing = missingRequiredFields(request);
        if (!missing.isEmpty()) {
            result.ErrorMessage = 'Cannot create Opportunity. Missing required fields: ' + String.join(missing, ', ') + '.';
            return result;
        }

        try {
            Id accountId = resolveAccountId(request.AccountId, request.AccountName);
            if (accountId == null) {
                result.ErrorMessage = 'No Account matched the supplied AccountId or AccountName.';
                return result;
            }

            Opportunity opp = new Opportunity();
            opp.AccountId = accountId;
            opp.Name = request.Name.trim();
            opp.StageName = request.StageName.trim();
            opp.CloseDate = request.CloseDate;
            opp.ForecastCategoryName = request.ForecastCategoryName.trim();
            opp.Business_Category__c = request.BusinessCategory.trim();
            opp.Entities_Providing_Services__c = request.EntitiesProvidingServices.trim();
            opp.Project_Category__c = request.ProjectCategory.trim();
            opp.Project_Start_Work__c = request.ProjectStartWork;
            opp.Project_End_Work__c = request.ProjectEndWork;
            opp.RfP_Received_Date__c = request.RfPReceivedDate;
            opp.RfP_Due_Sent_Date__c = request.RfPDueSentDate;
            opp.Study_Phase_Type__c = request.StudyPhaseType.trim();
            opp.Therapeutic_Area__c = request.TherapeuticArea.trim();

            if (request.Amount != null) {
                opp.Amount = request.Amount;
            }
            if (request.ServiceFees != null) {
                opp.Service_Fees__c = request.ServiceFees;
            }
            if (String.isNotBlank(request.NextStep)) {
                opp.NextStep = request.NextStep.trim();
            }

            Database.SaveResult saveResult = Database.insert(opp, AccessLevel.USER_MODE);
            if (!saveResult.isSuccess()) {
                result.ErrorMessage = saveResult.getErrors()[0].getMessage();
                return result;
            }

            Opportunity saved = [
                SELECT Id, Name, Account.Name, StageName, CloseDate, Opp_Probability__c, Opportunity_Code__c
                FROM Opportunity
                WHERE Id = :saveResult.getId()
                WITH USER_MODE
                LIMIT 1
            ];
            result.Success = true;
            result.OpportunityId = saved.Id;
            result.OpportunityName = saved.Name;
            result.AccountName = saved.Account == null ? null : saved.Account.Name;
            result.StageName = saved.StageName;
            result.CloseDate = saved.CloseDate;
            result.OppProbability = saved.Opp_Probability__c;
            result.OpportunityCode = saved.Opportunity_Code__c;
        } catch (Exception e) {
            result.ErrorMessage = e.getMessage();
        }

        return result;
    }

    private static List<String> missingRequiredFields(CreateRequest request) {
        List<String> missing = new List<String>();
        if (request == null) {
            missing.add('request');
            return missing;
        }
        if (String.isBlank(request.AccountId) && String.isBlank(request.AccountName)) missing.add('AccountId or AccountName');
        if (String.isBlank(request.Name)) missing.add('Name');
        if (request.CloseDate == null) missing.add('CloseDate');
        if (String.isBlank(request.StageName)) missing.add('StageName');
        if (String.isBlank(request.ForecastCategoryName)) missing.add('ForecastCategoryName');
        if (String.isBlank(request.BusinessCategory)) missing.add('Business_Category__c');
        if (String.isBlank(request.EntitiesProvidingServices)) missing.add('Entities_Providing_Services__c');
        if (String.isBlank(request.ProjectCategory)) missing.add('Project_Category__c');
        if (request.ProjectStartWork == null) missing.add('Project_Start_Work__c');
        if (request.ProjectEndWork == null) missing.add('Project_End_Work__c');
        if (request.RfPReceivedDate == null) missing.add('RfP_Received_Date__c');
        if (request.RfPDueSentDate == null) missing.add('RfP_Due_Sent_Date__c');
        if (String.isBlank(request.StudyPhaseType)) missing.add('Study_Phase_Type__c');
        if (String.isBlank(request.TherapeuticArea)) missing.add('Therapeutic_Area__c');
        return missing;
    }

    private static Id resolveAccountId(String accountId, String accountName) {
        if (String.isNotBlank(accountId)) {
            String safeId = String.escapeSingleQuotes(accountId.trim());
            List<Account> accounts = [SELECT Id FROM Account WHERE Id = :safeId WITH USER_MODE LIMIT 1];
            return accounts.isEmpty() ? null : accounts[0].Id;
        }

        String safeName = accountName.trim();
        List<Account> accounts = [
            SELECT Id
            FROM Account
            WHERE Name = :safeName
            WITH USER_MODE
            LIMIT 2
        ];
        if (accounts.size() == 1) {
            return accounts[0].Id;
        }
        return null;
    }

    public class CreateRequest {
        @InvocableVariable(required=false) public String AccountId;
        @InvocableVariable(required=false) public String AccountName;
        @InvocableVariable(required=true) public String Name;
        @InvocableVariable(required=true) public Date CloseDate;
        @InvocableVariable(required=true) public String StageName;
        @InvocableVariable(required=true) public String ForecastCategoryName;
        @InvocableVariable(required=true) public String BusinessCategory;
        @InvocableVariable(required=true) public String EntitiesProvidingServices;
        @InvocableVariable(required=true) public String ProjectCategory;
        @InvocableVariable(required=true) public Date ProjectStartWork;
        @InvocableVariable(required=true) public Date ProjectEndWork;
        @InvocableVariable(required=true) public Date RfPReceivedDate;
        @InvocableVariable(required=true) public Date RfPDueSentDate;
        @InvocableVariable(required=true) public String StudyPhaseType;
        @InvocableVariable(required=true) public String TherapeuticArea;
        @InvocableVariable(required=false) public Decimal Amount;
        @InvocableVariable(required=false) public Decimal ServiceFees;
        @InvocableVariable(required=false) public String NextStep;
    }

    public class CreateResult {
        @InvocableVariable public Boolean Success;
        @InvocableVariable public String OpportunityId;
        @InvocableVariable public String OpportunityName;
        @InvocableVariable public String AccountName;
        @InvocableVariable public String StageName;
        @InvocableVariable public Date CloseDate;
        @InvocableVariable public String OppProbability;
        @InvocableVariable public String OpportunityCode;
        @InvocableVariable public String ErrorMessage;
    }
}
