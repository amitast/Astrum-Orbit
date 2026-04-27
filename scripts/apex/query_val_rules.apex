// Query active validation rules on Opportunity
List<ValidationRule> rules = [
    SELECT Id, Active, Description, ErrorConditionFormula, ErrorMessage, ErrorDisplayField
    FROM ValidationRule
    WHERE EntityDefinition.DeveloperName = 'Opportunity'
    AND Active = true
    LIMIT 20
];
System.debug('VALIDATION RULES: Found ' + rules.size() + ' active rules');
for (ValidationRule r : rules) {
    System.debug('=== Rule ID: ' + r.Id + ' ===');
    System.debug('ErrorMessage: ' + r.ErrorMessage);
    System.debug('Formula: ' + r.ErrorConditionFormula);
}
