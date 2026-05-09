@IsTest
private class AGENT_UpdateContactField_Test {
    @TestSetup
    static void setupData() {
        Account accountRecord = new Account(Name = 'SAL21 Contact Update Account');
        insert accountRecord;

        insert new Contact(
            AccountId = accountRecord.Id,
            FirstName = 'Casey',
            LastName = 'ContactUpdate',
            Title = 'Manager',
            Department = 'Clinical',
            Email = 'casey.before@example.invalid',
            Phone = '+44 20 4000 0001',
            MobilePhone = '+44 7700 400001'
        );
    }

    @IsTest
    static void validUpdateTitle() {
        Contact contactRecord = getTestContact();
        AGENT_UpdateContactField.UpdateResult result = updateField(contactRecord.Id, 'Title', 'Senior Director');

        System.assertEquals(true, result.Success, 'Title update should succeed.');
        System.assertEquals('Title', result.UpdatedFieldLabel, 'Field label mismatch.');
        System.assertEquals('Senior Director', [SELECT Title FROM Contact WHERE Id = :contactRecord.Id WITH USER_MODE].Title, 'Title should be updated.');
    }

    @IsTest
    static void validUpdateDepartment() {
        Contact contactRecord = getTestContact();
        AGENT_UpdateContactField.UpdateResult result = updateField(contactRecord.Id, 'Department', 'Operations');

        System.assertEquals(true, result.Success, 'Department update should succeed.');
        System.assertEquals('Operations', [SELECT Department FROM Contact WHERE Id = :contactRecord.Id WITH USER_MODE].Department, 'Department should be updated.');
    }

    @IsTest
    static void validUpdateEmail() {
        Contact contactRecord = getTestContact();
        AGENT_UpdateContactField.UpdateResult result = updateField(contactRecord.Id, 'Email', 'casey.after@example.invalid');

        System.assertEquals(true, result.Success, 'Email update should succeed.');
        System.assertEquals('casey.after@example.invalid', result.NewValue, 'NewValue echo mismatch.');
        System.assertEquals('casey.after@example.invalid', [SELECT Email FROM Contact WHERE Id = :contactRecord.Id WITH USER_MODE].Email, 'Email should be updated.');
    }

    @IsTest
    static void validUpdatePhone() {
        Contact contactRecord = getTestContact();
        AGENT_UpdateContactField.UpdateResult result = updateField(contactRecord.Id, 'Phone', '+44 20 4999 9999');

        System.assertEquals(true, result.Success, 'Phone update should succeed.');
        System.assertEquals('+44 20 4999 9999', [SELECT Phone FROM Contact WHERE Id = :contactRecord.Id WITH USER_MODE].Phone, 'Phone should be updated.');
    }

    @IsTest
    static void validUpdateMobilePhone() {
        Contact contactRecord = getTestContact();
        AGENT_UpdateContactField.UpdateResult result = updateField(contactRecord.Id, 'MobilePhone', '+44 7700 499999');

        System.assertEquals(true, result.Success, 'MobilePhone update should succeed.');
        System.assertEquals('Mobile Phone', result.UpdatedFieldLabel, 'Field label mismatch.');
        System.assertEquals('+44 7700 499999', [SELECT MobilePhone FROM Contact WHERE Id = :contactRecord.Id WITH USER_MODE].MobilePhone, 'MobilePhone should be updated.');
    }

    @IsTest
    static void rejectsAccountIdWithoutDml() {
        Contact contactRecord = getTestContact();

        AGENT_UpdateContactField.UpdateResult result = updateField(contactRecord.Id, 'AccountId', contactRecord.AccountId);

        System.assertEquals(false, result.Success, 'AccountId should be rejected.');
        System.assertEquals('Field AccountId is not permitted for agent update.', result.ErrorMessage, 'AccountId error mismatch.');
        System.assertEquals(contactRecord.AccountId, [SELECT AccountId FROM Contact WHERE Id = :contactRecord.Id WITH USER_MODE].AccountId, 'Rejected AccountId update should not change parent.');
    }

    @IsTest
    static void rejectsOwnerId() {
        Contact contactRecord = getTestContact();

        AGENT_UpdateContactField.UpdateResult result = updateField(contactRecord.Id, 'OwnerId', UserInfo.getUserId());

        System.assertEquals(false, result.Success, 'OwnerId should be rejected.');
        System.assertEquals('Field OwnerId is not permitted for agent update.', result.ErrorMessage, 'OwnerId error mismatch.');
    }

    @IsTest
    static void rejectsReportsToId() {
        Contact contactRecord = getTestContact();

        AGENT_UpdateContactField.UpdateResult result = updateField(contactRecord.Id, 'ReportsToId', contactRecord.Id);

        System.assertEquals(false, result.Success, 'ReportsToId should be rejected.');
        System.assertEquals('Field ReportsToId is not permitted for agent update.', result.ErrorMessage, 'ReportsToId error mismatch.');
    }

    @IsTest
    static void rejectsHasOptedOutOfEmail() {
        Contact contactRecord = getTestContact();

        AGENT_UpdateContactField.UpdateResult result = updateField(contactRecord.Id, 'HasOptedOutOfEmail', 'true');

        System.assertEquals(false, result.Success, 'HasOptedOutOfEmail should be rejected.');
        System.assertEquals('Field HasOptedOutOfEmail is not permitted for agent update.', result.ErrorMessage, 'HasOptedOutOfEmail error mismatch.');
    }

    @IsTest
    static void nonexistentContactReturnsGracefulError() {
        Id missingContactId = '003000000000000AAA';

        AGENT_UpdateContactField.UpdateResult result = updateField(missingContactId, 'Title', 'Director');

        System.assertEquals(false, result.Success, 'Missing contact update should fail.');
        System.assertNotEquals(null, result.ErrorMessage, 'Missing contact should return an error message.');
    }

    private static Contact getTestContact() {
        return [
            SELECT Id, AccountId, Title, Department, Email, Phone, MobilePhone
            FROM Contact
            WHERE LastName = 'ContactUpdate'
            WITH USER_MODE
            LIMIT 1
        ];
    }

    private static AGENT_UpdateContactField.UpdateResult updateField(Id contactId, String fieldApiName, String newValue) {
        AGENT_UpdateContactField.UpdateRequest request = new AGENT_UpdateContactField.UpdateRequest();
        request.ContactId = String.valueOf(contactId);
        request.FieldApiName = fieldApiName;
        request.NewValue = newValue;

        Test.startTest();
        List<AGENT_UpdateContactField.UpdateResult> results = AGENT_UpdateContactField.updateContactField(
            new List<AGENT_UpdateContactField.UpdateRequest>{ request }
        );
        Test.stopTest();

        System.assertEquals(1, results.size(), 'One invocable result should be returned.');
        return results[0];
    }
}
