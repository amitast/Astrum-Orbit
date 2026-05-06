public with sharing class AGENT_UpdateAccountField {
    private static final Set<String> ALLOWED_FIELDS = new Set<String>{
        'Industry', 'Type', 'Phone', 'Website', 'Description', 'NumberOfEmployees'
    };

    private static final Map<String, String> FIELD_LABELS = new Map<String, String>{
        'Industry' => 'Industry',
        'Type' => 'Account Type',
        'Phone' => 'Account Phone',
        'Website' => 'Website',
        'Description' => 'Account Description',
        'NumberOfEmployees' => 'Employees'
    };

    @InvocableMethod(label='Update Account Field' description='Update a single permitted field on a named Account record. Requires user confirmation before execution.')
    public static List<UpdateResult> updateAccountField(List<UpdateRequest> requests) {
        List<UpdateResult> results = new List<UpdateResult>();
        if (requests == null || requests.isEmpty()) {
            UpdateResult result = new UpdateResult();
            result.Success = false;
            result.ErrorMessage = 'No update request was provided.';
            results.add(result);
            return results;
        }

        for (UpdateRequest request : requests) {
            results.add(updateSingleRequest(request));
        }
        return results;
    }

    private static UpdateResult updateSingleRequest(UpdateRequest request) {
        UpdateResult result = new UpdateResult();
        result.Success = false;

        String fieldApiName = request == null ? null : request.FieldApiName;
        String accountId = request == null ? null : request.AccountId;
        String newValue = request == null ? null : request.NewValue;
        result.NewValue = newValue;
        result.UpdatedFieldLabel = getFieldLabel(fieldApiName);

        if (!ALLOWED_FIELDS.contains(fieldApiName)) {
            result.ErrorMessage = 'Field ' + fieldApiName + ' is not permitted for agent update.';
            return result;
        }

        Object castValue = newValue;
        if (fieldApiName == 'NumberOfEmployees') {
            try {
                castValue = Integer.valueOf(newValue);
            } catch (Exception e) {
                result.ErrorMessage = 'NumberOfEmployees requires a whole number value.';
                return result;
            }
        }

        try {
            Account acct = new Account(Id = accountId);
            acct.put(fieldApiName, castValue);
            Database.update(acct, AccessLevel.USER_MODE);
            result.Success = true;
        } catch (Exception e) {
            result.Success = false;
            result.ErrorMessage = e.getMessage();
        }

        return result;
    }

    private static String getFieldLabel(String fieldApiName) {
        if (FIELD_LABELS.containsKey(fieldApiName)) {
            return FIELD_LABELS.get(fieldApiName);
        }
        return fieldApiName;
    }

    public class UpdateRequest {
        @InvocableVariable(required=true)
        public String AccountId;

        @InvocableVariable(required=true)
        public String FieldApiName;

        @InvocableVariable(required=true)
        public String NewValue;
    }

    public class UpdateResult {
        @InvocableVariable
        public Boolean Success;

        @InvocableVariable
        public String UpdatedFieldLabel;

        @InvocableVariable
        public String NewValue;

        @InvocableVariable
        public String ErrorMessage;
    }
}
