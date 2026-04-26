// Get active picklist values for Closed Won validation rule required fields
Schema.DescribeSObjectResult opp = Opportunity.sObjectType.getDescribe();
Map<String, Schema.SObjectField> fields = opp.fields.getMap();

String[] fieldNames = new String[]{
    'Reason_for_win__c', 'Contract_Type__c',
    'Payment_Schedule_Type__c', 'Contract_Entity__c',
    'Study_Countries__c', 'Entities_Providing_Services__c'
};

for (String fn : fieldNames) {
    if (fields.containsKey(fn.toLowerCase())) {
        Schema.DescribeFieldResult f = fields.get(fn.toLowerCase()).getDescribe();
        List<String> vals = new List<String>();
        for (Schema.PicklistEntry e : f.getPicklistValues()) {
            if (e.isActive()) vals.add(e.getValue());
        }
        System.debug(fn + ' values: ' + String.join(vals, ' | '));
    } else {
        System.debug(fn + ': NOT FOUND in describe');
    }
}
