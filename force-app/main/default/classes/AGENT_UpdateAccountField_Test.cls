@IsTest
private class AGENT_UpdateAccountField_Test {
    @TestSetup
    static void setupData() {
        insert new Account(
            Name = 'SAL21 Update Account',
            Industry = 'Healthcare',
            Type = 'Prospect',
            Phone = '+44 20 3000 0001',
            Website = 'https://before.example.invalid',
            Description = 'Before description',
            NumberOfEmployees = 10
        );
    }

    @IsTest
    static void validUpdateIndustry() {
        Account accountRecord = getTestAccount();
        AGENT_UpdateAccountField.UpdateResult result = updateField(accountRecord.Id, 'Industry', 'Biotechnology');

        System.assertEquals(true, result.Success, 'Industry update should succeed.');
        System.assertEquals('Industry', result.UpdatedFieldLabel, 'Field label mismatch.');
        System.assertEquals('Biotechnology', result.NewValue, 'NewValue echo mismatch.');
        System.assertEquals('Biotechnology', [SELECT Industry FROM Account WHERE Id = :accountRecord.Id WITH USER_MODE].Industry, 'Industry should be updated.');
    }

    @IsTest
    static void validUpdatePhone() {
        Account accountRecord = getTestAccount();
        AGENT_UpdateAccountField.UpdateResult result = updateField(accountRecord.Id, 'Phone', '+44 20 3999 9999');

        System.assertEquals(true, result.Success, 'Phone update should succeed.');
        System.assertEquals('+44 20 3999 9999', [SELECT Phone FROM Account WHERE Id = :accountRecord.Id WITH USER_MODE].Phone, 'Phone should be updated.');
    }

    @IsTest
    static void validUpdateWebsite() {
        Account accountRecord = getTestAccount();
        AGENT_UpdateAccountField.UpdateResult result = updateField(accountRecord.Id, 'Website', 'https://after.example.invalid');

        System.assertEquals(true, result.Success, 'Website update should succeed.');
        System.assertEquals('https://after.example.invalid', [SELECT Website FROM Account WHERE Id = :accountRecord.Id WITH USER_MODE].Website, 'Website should be updated.');
    }

    @IsTest
    static void validUpdateDescription() {
        Account accountRecord = getTestAccount();
        AGENT_UpdateAccountField.UpdateResult result = updateField(accountRecord.Id, 'Description', 'After description');

        System.assertEquals(true, result.Success, 'Description update should succeed.');
        System.assertEquals('After description', [SELECT Description FROM Account WHERE Id = :accountRecord.Id WITH USER_MODE].Description, 'Description should be updated.');
    }

    @IsTest
    static void validUpdateNumberOfEmployees() {
        Account accountRecord = getTestAccount();
        AGENT_UpdateAccountField.UpdateResult result = updateField(accountRecord.Id, 'NumberOfEmployees', '42');

        System.assertEquals(true, result.Success, 'NumberOfEmployees update should succeed.');
        System.assertEquals(42, [SELECT NumberOfEmployees FROM Account WHERE Id = :accountRecord.Id WITH USER_MODE].NumberOfEmployees, 'NumberOfEmployees should be updated.');
    }

    @IsTest
    static void rejectsOwnerIdWithoutDml() {
        Account accountRecord = getTestAccount();
        String originalName = accountRecord.Name;

        AGENT_UpdateAccountField.UpdateResult result = updateField(accountRecord.Id, 'OwnerId', UserInfo.getUserId());

        System.assertEquals(false, result.Success, 'OwnerId should be rejected.');
        System.assertEquals('Field OwnerId is not permitted for agent update.', result.ErrorMessage, 'OwnerId error mismatch.');
        System.assertEquals(originalName, [SELECT Name FROM Account WHERE Id = :accountRecord.Id WITH USER_MODE].Name, 'Rejected update should not change account.');
    }

    @IsTest
    static void rejectsParentIdWithoutDml() {
        Account accountRecord = getTestAccount();

        AGENT_UpdateAccountField.UpdateResult result = updateField(accountRecord.Id, 'ParentId', accountRecord.Id);

        System.assertEquals(false, result.Success, 'ParentId should be rejected.');
        System.assertEquals('Field ParentId is not permitted for agent update.', result.ErrorMessage, 'ParentId error mismatch.');
    }

    @IsTest
    static void rejectsArbitraryField() {
        Account accountRecord = getTestAccount();

        AGENT_UpdateAccountField.UpdateResult result = updateField(accountRecord.Id, 'Rating', 'Hot');

        System.assertEquals(false, result.Success, 'Arbitrary field should be rejected.');
        System.assertEquals('Field Rating is not permitted for agent update.', result.ErrorMessage, 'Arbitrary field error mismatch.');
    }

    @IsTest
    static void numberOfEmployeesRejectsNonInteger() {
        Account accountRecord = getTestAccount();

        AGENT_UpdateAccountField.UpdateResult result = updateField(accountRecord.Id, 'NumberOfEmployees', 'forty two');

        System.assertEquals(false, result.Success, 'Invalid integer should fail.');
        System.assertEquals('NumberOfEmployees requires a whole number value.', result.ErrorMessage, 'Invalid integer error mismatch.');
        System.assertEquals(10, [SELECT NumberOfEmployees FROM Account WHERE Id = :accountRecord.Id WITH USER_MODE].NumberOfEmployees, 'Invalid integer should not update field.');
    }

    @IsTest
    static void nonexistentAccountReturnsGracefulError() {
        Id missingAccountId = '001000000000000AAA';

        AGENT_UpdateAccountField.UpdateResult result = updateField(missingAccountId, 'Phone', '+44 20 3000 0009');

        System.assertEquals(false, result.Success, 'Missing account update should fail.');
        System.assertNotEquals(null, result.ErrorMessage, 'Missing account should return an error message.');
    }

    private static Account getTestAccount() {
        return [
            SELECT Id, Name, Industry, Phone, Website, Description, NumberOfEmployees
            FROM Account
            WHERE Name = 'SAL21 Update Account'
            WITH USER_MODE
            LIMIT 1
        ];
    }

    private static AGENT_UpdateAccountField.UpdateResult updateField(Id accountId, String fieldApiName, String newValue) {
        AGENT_UpdateAccountField.UpdateRequest request = new AGENT_UpdateAccountField.UpdateRequest();
        request.AccountId = String.valueOf(accountId);
        request.FieldApiName = fieldApiName;
        request.NewValue = newValue;

        Test.startTest();
        List<AGENT_UpdateAccountField.UpdateResult> results = AGENT_UpdateAccountField.updateAccountField(
            new List<AGENT_UpdateAccountField.UpdateRequest>{ request }
        );
        Test.stopTest();

        System.assertEquals(1, results.size(), 'One invocable result should be returned.');
        return results[0];
    }
}
