@IsTest
private class AGENT_CreateContactTest {
    private static User createBdTestUser() {
        Profile p = [
            SELECT Id
            FROM Profile
            WHERE UserType = 'Standard'
            AND PermissionsViewAllData = false
            LIMIT 1
        ];
        User runningUser = [
            SELECT TimeZoneSidKey, LocaleSidKey, LanguageLocaleKey
            FROM User
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ];
        Long ts = System.now().getTime();
        User u = new User(
            FirstName = 'SALBD',
            LastName = 'BDUser',
            Email = 'salbd.bduser.' + ts + '@test.salbd.invalid',
            Username = 'salbd.bduser.' + ts + '@test.salbd.invalid',
            Alias = 'salbd',
            ProfileId = p.Id,
            TimeZoneSidKey = runningUser.TimeZoneSidKey,
            LocaleSidKey = runningUser.LocaleSidKey,
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = runningUser.LanguageLocaleKey
        );
        insert u;

        PermissionSet ps = new PermissionSet(
            Name = 'SALBD_AGENT_CC_PS_' + ts,
            Label = 'SALBD Agent Create Contact Test ' + ts
        );
        insert ps;

        insert new ObjectPermissions(
            ParentId = ps.Id,
            SObjectType = 'Account',
            PermissionsRead = true,
            PermissionsCreate = true,
            PermissionsEdit = true,
            PermissionsDelete = false,
            PermissionsViewAllRecords = false,
            PermissionsModifyAllRecords = false
        );
        insert new ObjectPermissions(
            ParentId = ps.Id,
            SObjectType = 'Contact',
            PermissionsRead = true,
            PermissionsCreate = true,
            PermissionsEdit = true,
            PermissionsDelete = false,
            PermissionsViewAllRecords = false,
            PermissionsModifyAllRecords = false
        );

        insert new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id);
        return u;
    }

    private static Account createAccount(String name) {
        Account acc = new Account(Name = name);
        insert acc;
        return acc;
    }

    private static Map<String, Object> runCreateContactFlow(
        Id accountId,
        String firstName,
        String lastName,
        String title,
        String email,
        String phone,
        String mobilePhone
    ) {
        Map<String, Object> inputs = new Map<String, Object>{
            'AccountId' => String.valueOf(accountId),
            'FirstName' => firstName,
            'LastName' => lastName,
            'Title' => title,
            'Email' => email,
            'Phone' => phone,
            'MobilePhone' => mobilePhone
        };
        Flow.Interview.AGENT_CreateContact interview = new Flow.Interview.AGENT_CreateContact(inputs);
        interview.start();
        return new Map<String, Object>{
            'Success' => interview.getVariableValue('Success'),
            'CreatedContactId' => interview.getVariableValue('CreatedContactId'),
            'CreatedContactName' => interview.getVariableValue('CreatedContactName'),
            'DuplicateFound' => interview.getVariableValue('DuplicateFound'),
            'DuplicateContactName' => interview.getVariableValue('DuplicateContactName'),
            'DuplicateContactId' => interview.getVariableValue('DuplicateContactId'),
            'ErrorMessage' => interview.getVariableValue('ErrorMessage')
        };
    }

    @IsTest
    static void tc01_noDuplicateCreatesContact() {
        User bdUser;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            bdUser = createBdTestUser();
        }

        System.runAs(bdUser) {
            Account acc = createAccount('SAL-BD-S1 TC01 Account');
            String lastName = 'Unique' + System.now().getTime();

            Integer beforeCount = [
                SELECT COUNT()
                FROM Contact
                WHERE AccountId = :acc.Id
                AND LastName = :lastName
            ];

            Test.startTest();
            Map<String, Object> outputs = runCreateContactFlow(
                acc.Id,
                'Ava',
                lastName,
                'Director',
                'ava.' + lastName.toLowerCase() + '@example.invalid',
                '+44 20 0000 0001',
                '+44 7700 000001'
            );
            Test.stopTest();

            System.assertEquals(true, outputs.get('Success'), 'TC-01 Success should be true.');
            System.assertEquals(false, outputs.get('DuplicateFound'), 'TC-01 DuplicateFound should be false.');
            System.assertNotEquals(null, outputs.get('CreatedContactId'), 'TC-01 CreatedContactId should be populated.');
            System.assertEquals('Ava ' + lastName, outputs.get('CreatedContactName'), 'TC-01 CreatedContactName mismatch.');
            System.assertEquals(null, outputs.get('ErrorMessage'), 'TC-01 ErrorMessage should be blank.');

            String createdContactId = (String) outputs.get('CreatedContactId');
            Contact created = [
                SELECT Id, AccountId, FirstName, LastName, Title, Email, Phone, MobilePhone
                FROM Contact
                WHERE Id = :createdContactId
            ];
            System.assertEquals(acc.Id, created.AccountId, 'TC-01 AccountId mismatch.');
            System.assertEquals('Ava', created.FirstName, 'TC-01 FirstName mismatch.');
            System.assertEquals(lastName, created.LastName, 'TC-01 LastName mismatch.');
            System.assertEquals('Director', created.Title, 'TC-01 Title mismatch.');

            Integer afterCount = [
                SELECT COUNT()
                FROM Contact
                WHERE AccountId = :acc.Id
                AND LastName = :lastName
            ];
            System.assertEquals(beforeCount + 1, afterCount, 'TC-01 should create exactly one Contact.');
        }
    }

    @IsTest
    static void tc02_duplicateByNameExitsWithoutCreate() {
        User bdUser;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            bdUser = createBdTestUser();
        }

        System.runAs(bdUser) {
            Account acc = createAccount('SAL-BD-S1 TC02 Account');
            String lastName = 'NameDup' + System.now().getTime();
            Contact existing = new Contact(
                AccountId = acc.Id,
                FirstName = 'Existing',
                LastName = lastName,
                Email = 'existing.' + lastName.toLowerCase() + '@example.invalid'
            );
            insert existing;

            Integer beforeCount = [
                SELECT COUNT()
                FROM Contact
                WHERE AccountId = :acc.Id
                AND LastName = :lastName
            ];

            Test.startTest();
            Map<String, Object> outputs = runCreateContactFlow(
                acc.Id,
                'New',
                lastName,
                'VP',
                'new.' + lastName.toLowerCase() + '@example.invalid',
                null,
                null
            );
            Test.stopTest();

            System.assertEquals(false, outputs.get('Success'), 'TC-02 Success should be false.');
            System.assertEquals(true, outputs.get('DuplicateFound'), 'TC-02 DuplicateFound should be true.');
            System.assertEquals(String.valueOf(existing.Id), outputs.get('DuplicateContactId'), 'TC-02 should return the existing Contact ID.');
            System.assertEquals('Existing ' + lastName, outputs.get('DuplicateContactName'), 'TC-02 duplicate name mismatch.');
            System.assertEquals(null, outputs.get('CreatedContactId'), 'TC-02 CreatedContactId should be blank.');
            System.assertEquals(null, outputs.get('ErrorMessage'), 'TC-02 ErrorMessage should be blank.');

            Integer afterCount = [
                SELECT COUNT()
                FROM Contact
                WHERE AccountId = :acc.Id
                AND LastName = :lastName
            ];
            System.assertEquals(beforeCount, afterCount, 'TC-02 should not create a new Contact.');
        }
    }

    @IsTest
    static void tc03_duplicateByEmailExitsWithoutCreate() {
        User bdUser;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            bdUser = createBdTestUser();
        }

        System.runAs(bdUser) {
            Account targetAccount = createAccount('SAL-BD-S1 TC03 Target Account');
            Account otherAccount = createAccount('SAL-BD-S1 TC03 Other Account');
            String suffix = String.valueOf(System.now().getTime());
            String email = 'emaildup.' + suffix + '@example.invalid';
            Contact existing = new Contact(
                AccountId = otherAccount.Id,
                FirstName = 'Email',
                LastName = 'Duplicate' + suffix,
                Email = email
            );
            insert existing;

            Integer beforeCount = [
                SELECT COUNT()
                FROM Contact
                WHERE Email = :email
            ];

            Test.startTest();
            Map<String, Object> outputs = runCreateContactFlow(
                targetAccount.Id,
                'Different',
                'Last' + suffix,
                'Head of Clinical Operations',
                email,
                null,
                null
            );
            Test.stopTest();

            System.assertEquals(false, outputs.get('Success'), 'TC-03 Success should be false.');
            System.assertEquals(true, outputs.get('DuplicateFound'), 'TC-03 DuplicateFound should be true.');
            System.assertEquals(String.valueOf(existing.Id), outputs.get('DuplicateContactId'), 'TC-03 should return the email-match Contact ID.');
            System.assertEquals('Email Duplicate' + suffix, outputs.get('DuplicateContactName'), 'TC-03 duplicate name mismatch.');
            System.assertEquals(null, outputs.get('CreatedContactId'), 'TC-03 CreatedContactId should be blank.');

            Integer afterCount = [
                SELECT COUNT()
                FROM Contact
                WHERE Email = :email
            ];
            System.assertEquals(beforeCount, afterCount, 'TC-03 should not create a new Contact.');
        }
    }

    @IsTest
    static void tc04_accountIdNotFoundFailsGracefully() {
        User bdUser;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            bdUser = createBdTestUser();
        }

        System.runAs(bdUser) {
            Id missingAccountId = '001000000000000AAA';
            String lastName = 'MissingAccount' + System.now().getTime();

            Test.startTest();
            Map<String, Object> outputs = runCreateContactFlow(
                missingAccountId,
                'Mia',
                lastName,
                null,
                null,
                null,
                null
            );
            Test.stopTest();

            System.assertEquals(false, outputs.get('Success'), 'TC-04 Success should be false.');
            System.assertEquals(false, outputs.get('DuplicateFound'), 'TC-04 DuplicateFound should be false.');
            System.assertEquals(null, outputs.get('CreatedContactId'), 'TC-04 CreatedContactId should be blank.');
            System.assert(
                String.valueOf(outputs.get('ErrorMessage')).contains('Account not found'),
                'TC-04 ErrorMessage should contain Account not found.'
            );

            Integer createdCount = [
                SELECT COUNT()
                FROM Contact
                WHERE LastName = :lastName
            ];
            System.assertEquals(0, createdCount, 'TC-04 should not create a Contact.');
        }
    }
}
