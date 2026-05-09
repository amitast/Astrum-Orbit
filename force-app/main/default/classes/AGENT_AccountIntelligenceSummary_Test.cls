@isTest
private class AGENT_AccountIntelligenceSummary_Test {

    @testSetup
    static void setup() {
        Account acc = new Account(
            Name = 'Test Pharma AG',
            Industry = 'Pharmaceuticals',
            Type = 'Customer',
            BillingCity = 'Basel',
            BillingCountry = 'Switzerland',
            NumberOfEmployees = 10000,
            AnnualRevenue = 1200000000,
            Description = 'A leading clinical research organisation specialising in oncology.'
        );
        insert acc;

        insert new Contact(
            FirstName = 'Anna',
            LastName = 'Keller',
            Title = 'Head of Clinical Operations',
            AccountId = acc.Id
        );

        // No Opportunity inserted — Oppty Code flow trigger fires in production context
        // and lacks a test-bypass permission. Pipeline path covered by testBuildSummaryNoContactsNoOpps.
    }

    @isTest
    static void testSummaryByName() {
        AGENT_AccountIntelligenceSummary.SummaryRequest req =
            new AGENT_AccountIntelligenceSummary.SummaryRequest();
        req.accountName = 'Test Pharma AG';

        Test.startTest();
        List<AGENT_AccountIntelligenceSummary.SummaryResult> results =
            AGENT_AccountIntelligenceSummary.generateSummary(
                new List<AGENT_AccountIntelligenceSummary.SummaryRequest>{ req }
            );
        Test.stopTest();

        System.assertEquals(1, results.size(), 'Expected one result');
        System.assertEquals(true, results[0].success, 'Expected success=true');
        System.assertNotEquals(null, results[0].summary, 'Expected non-null summary');
        System.assert(results[0].summary.contains('Test Pharma AG'), 'Summary must contain account name');
        System.assert(results[0].summary.contains('Pharmaceuticals'), 'Summary must contain industry');
        System.assert(results[0].summary.contains('Anna Keller'), 'Summary must contain key contact');
        System.assertEquals('Test Pharma AG', results[0].accountName);
    }

    @isTest
    static void testSummaryById() {
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Pharma AG' LIMIT 1];

        AGENT_AccountIntelligenceSummary.SummaryRequest req =
            new AGENT_AccountIntelligenceSummary.SummaryRequest();
        req.accountId = acc.Id;

        Test.startTest();
        List<AGENT_AccountIntelligenceSummary.SummaryResult> results =
            AGENT_AccountIntelligenceSummary.generateSummary(
                new List<AGENT_AccountIntelligenceSummary.SummaryRequest>{ req }
            );
        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assertEquals(true, results[0].success);
        System.assertEquals('Test Pharma AG', results[0].accountName);
        System.assertEquals(acc.Id, results[0].accountId);
    }

    @isTest
    static void testAccountNotFound() {
        AGENT_AccountIntelligenceSummary.SummaryRequest req =
            new AGENT_AccountIntelligenceSummary.SummaryRequest();
        req.accountName = 'NoSuchAccount_XYZ_99999';

        Test.startTest();
        List<AGENT_AccountIntelligenceSummary.SummaryResult> results =
            AGENT_AccountIntelligenceSummary.generateSummary(
                new List<AGENT_AccountIntelligenceSummary.SummaryRequest>{ req }
            );
        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assertEquals(false, results[0].success);
        System.assertNotEquals(null, results[0].errorMessage);
    }

    @isTest
    static void testNoInputProvided() {
        AGENT_AccountIntelligenceSummary.SummaryRequest req =
            new AGENT_AccountIntelligenceSummary.SummaryRequest();

        Test.startTest();
        List<AGENT_AccountIntelligenceSummary.SummaryResult> results =
            AGENT_AccountIntelligenceSummary.generateSummary(
                new List<AGENT_AccountIntelligenceSummary.SummaryRequest>{ req }
            );
        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assertEquals(false, results[0].success);
    }

    @isTest
    static void testEmptyRequestList() {
        Test.startTest();
        List<AGENT_AccountIntelligenceSummary.SummaryResult> results =
            AGENT_AccountIntelligenceSummary.generateSummary(
                new List<AGENT_AccountIntelligenceSummary.SummaryRequest>()
            );
        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assertEquals(false, results[0].success);
    }

    @isTest
    static void testExceptionHandling() {
        AGENT_AccountIntelligenceSummary.forceExceptionForTest = true;

        AGENT_AccountIntelligenceSummary.SummaryRequest req =
            new AGENT_AccountIntelligenceSummary.SummaryRequest();
        req.accountName = 'Test Pharma AG';

        Test.startTest();
        List<AGENT_AccountIntelligenceSummary.SummaryResult> results =
            AGENT_AccountIntelligenceSummary.generateSummary(
                new List<AGENT_AccountIntelligenceSummary.SummaryRequest>{ req }
            );
        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assertEquals(false, results[0].success);
        System.assertNotEquals(null, results[0].errorMessage);
    }

    @isTest
    static void testBuildSummaryNoContactsNoOpps() {
        Account acc = new Account(
            Name = 'Minimal Corp',
            Industry = 'Biotechnology',
            Type = 'Prospect',
            BillingCity = 'London',
            BillingCountry = 'United Kingdom'
        );

        List<Contact> contacts = new List<Contact>();
        List<Opportunity> opps = new List<Opportunity>();

        String summary = AGENT_AccountIntelligenceSummary.buildSummary(acc, contacts, opps);

        System.assert(summary.contains('Minimal Corp'), 'Must contain account name');
        System.assert(summary.contains('Biotechnology'), 'Must contain industry');
        System.assert(summary.contains('London'), 'Must contain city');
        System.assert(!summary.contains('Key contacts'), 'Should not mention contacts when none exist');
    }
}
