public with sharing class AGENT_UpdateContactField {
    private static final Set<String> ALLOWED_FIELDS = new Set<String>{
        'Title', 'Department', 'Email', 'Phone', 'MobilePhone'
    };

    private static final Map<String, String> FIELD_LABELS = new Map<String, String>{
        'Title' => 'Title',
        'Department' => 'Department',
        'Email' => 'Email',
        'Phone' => 'Business Phone',
        'MobilePhone' => 'Mobile Phone'
    };

    @InvocableMethod(label='Update Contact Field' description='Update a single permitted field on a named Contact record. Requires user confirmation before execution.')
    public static List<UpdateResult> updateContactField(List<UpdateRequest> requests) {
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
        String contactId = request == null ? null : request.ContactId;
        String newValue = request == null ? null : request.NewValue;
        result.NewValue = newValue;
        result.UpdatedFieldLabel = getFieldLabel(fieldApiName);

        if (!ALLOWED_FIELDS.contains(fieldApiName)) {
            result.ErrorMessage = 'Field ' + fieldApiName + ' is not permitted for agent update.';
            return result;
        }

        try {
            Contact c = new Contact(Id = contactId);
            c.put(fieldApiName, newValue);
            Database.update(c, AccessLevel.USER_MODE);
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
        public String ContactId;

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
