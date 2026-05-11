public with sharing class AGENT_AccountIntelligenceSummary {
    @TestVisible
    private static Boolean forceExceptionForTest = false;

    @InvocableMethod(
        label='Generate Account Intelligence Summary'
        description='Generates a concise account intelligence summary for a named account using Salesforce record data only. Invoke when the user asks for an account summary, account profile, or account overview.'
    )
    public static List<SummaryResult> generateSummary(List<SummaryRequest> requests) {
        List<SummaryResult> results = new List<SummaryResult>();
        if (requests == null || requests.isEmpty()) {
            SummaryResult r = new SummaryResult();
            r.success = false;
            r.errorMessage = 'No input provided.';
            results.add(r);
            return results;
        }
        for (SummaryRequest req : requests) {
            results.add(processRequest(req));
        }
        return results;
    }

    private static SummaryResult processRequest(SummaryRequest req) {
        SummaryResult result = new SummaryResult();

        if (String.isBlank(req.accountName) && String.isBlank(req.accountId)) {
            result.success = false;
            result.errorMessage = 'AccountName or AccountId is required.';
            return result;
        }

        try {
            if (forceExceptionForTest) {
                throw new AuraHandledException('Forced test exception.');
            }

            List<Account> accounts;
            if (String.isNotBlank(req.accountId)) {
                String safeId = String.escapeSingleQuotes(req.accountId.trim());
                accounts = [
                    SELECT Id, Name, Industry, Type, BillingCity, BillingCountry,
                           AnnualRevenue, NumberOfEmployees, Description, Owner.Name
                    FROM Account
                    WHERE Id = :safeId
                    WITH USER_MODE
                    LIMIT 1
                ];
            } else {
                String safeName = String.escapeSingleQuotes(req.accountName.trim());
                accounts = [
                    SELECT Id, Name, Industry, Type, BillingCity, BillingCountry,
                           AnnualRevenue, NumberOfEmployees, Description, Owner.Name
                    FROM Account
                    WHERE Name = :safeName
                    WITH USER_MODE
                    LIMIT 1
                ];
            }

            if (accounts.isEmpty()) {
                result.success = false;
                result.errorMessage = 'No account found for: ' +
                    (String.isNotBlank(req.accountName) ? req.accountName : req.accountId);
                return result;
            }

            Account acc = accounts[0];

            List<Contact> contacts = [
                SELECT FirstName, LastName, Title
                FROM Contact
                WHERE AccountId = :acc.Id
                AND Title != null
                WITH USER_MODE
                ORDER BY LastModifiedDate DESC
                LIMIT 3
            ];

            List<Opportunity> openOpps = [
                SELECT Amount, CloseDate
                FROM Opportunity
                WHERE AccountId = :acc.Id
                AND IsClosed = false
                WITH USER_MODE
                ORDER BY CloseDate ASC
                LIMIT 5
            ];

            result.summary = buildSummary(acc, contacts, openOpps);
            result.success = true;
            result.accountName = acc.Name;
            result.accountId = acc.Id;
            result.isDataSparse = isAccountDataSparse(acc);

        } catch (Exception e) {
            result.success = false;
            result.errorMessage = e.getMessage();
        }

        return result;
    }

    private static Boolean isAccountDataSparse(Account acc) {
        return String.isBlank(acc.Industry)
            && String.isBlank(acc.Type)
            && String.isBlank(acc.BillingCity)
            && String.isBlank(acc.BillingCountry)
            && String.isBlank(acc.Description);
    }

    @TestVisible
    private static String buildSummary(Account acc, List<Contact> contacts, List<Opportunity> opps) {
        List<String> parts = new List<String>();

        // Sentence 1: organisation overview
        String overview = acc.Name;
        if (String.isNotBlank(acc.Industry)) {
            overview += ' is a ' + acc.Industry + ' organisation';
        } else {
            overview += ' is an organisation';
        }
        if (String.isNotBlank(acc.Type)) {
            overview += ' (' + acc.Type + ')';
        }

        List<String> locationParts = new List<String>();
        if (String.isNotBlank(acc.BillingCity)) {
            locationParts.add(acc.BillingCity);
        }
        if (String.isNotBlank(acc.BillingCountry)) {
            locationParts.add(acc.BillingCountry);
        }
        if (!locationParts.isEmpty()) {
            overview += ' based in ' + String.join(locationParts, ', ');
        }

        List<String> sizeParts = new List<String>();
        if (acc.NumberOfEmployees != null && acc.NumberOfEmployees > 0) {
            sizeParts.add(String.valueOf(acc.NumberOfEmployees) + ' employees');
        }
        if (acc.AnnualRevenue != null && acc.AnnualRevenue > 0) {
            sizeParts.add('annual revenue of ' + formatCurrency(acc.AnnualRevenue));
        }
        if (!sizeParts.isEmpty()) {
            overview += ' with ' + String.join(sizeParts, ' and ');
        }

        if (String.isNotBlank(acc.Description)) {
            String shortDesc = acc.Description.length() > 250
                ? acc.Description.substring(0, 250) + '...'
                : acc.Description;
            overview += '. ' + shortDesc;
        } else {
            overview += '.';
        }
        parts.add(overview);

        // Sentence 2: key contacts
        if (!contacts.isEmpty()) {
            List<String> contactDescs = new List<String>();
            for (Contact c : contacts) {
                String name = (c.FirstName != null ? c.FirstName + ' ' : '') + c.LastName;
                contactDescs.add(name.trim() + (String.isNotBlank(c.Title) ? ' (' + c.Title + ')' : ''));
            }
            parts.add('Key contacts include: ' + String.join(contactDescs, ', ') + '.');
        }

        // Sentence 3: open pipeline
        if (!opps.isEmpty()) {
            Decimal total = 0;
            for (Opportunity o : opps) {
                if (o.Amount != null) {
                    total += o.Amount;
                }
            }
            String pipeline = opps.size() == 1
                ? 'There is 1 open opportunity'
                : 'There are ' + opps.size() + ' open opportunities';
            if (total > 0) {
                pipeline += ' with a combined pipeline value of ' + formatCurrency(total);
            }
            parts.add(pipeline + '.');
        }

        // Account owner
        if (acc.Owner != null && String.isNotBlank(acc.Owner.Name)) {
            parts.add('Account owner: ' + acc.Owner.Name + '.');
        }

        return String.join(parts, ' ');
    }

    private static String formatCurrency(Decimal amount) {
        if (amount >= 1000000000) {
            return '$' + (amount / 1000000000).setScale(1) + 'B';
        } else if (amount >= 1000000) {
            return '$' + (amount / 1000000).setScale(1) + 'M';
        } else if (amount >= 1000) {
            return '$' + (amount / 1000).setScale(0) + 'K';
        }
        return '$' + amount.setScale(0);
    }

    public class SummaryRequest {
        @InvocableVariable(
            label='Account Name'
            description='Name of the account to summarise, as stated by the user. Use this when the account ID is not already in context.'
            required=false
        )
        public String accountName;

        @InvocableVariable(
            label='Account ID'
            description='18-character Salesforce Account record ID. Use if already available. Leave blank when only the account name is known.'
            required=false
        )
        public String accountId;
    }

    public class SummaryResult {
        @InvocableVariable(label='Summary' description='Account intelligence summary grounded in Salesforce record data.')
        public String summary;

        @InvocableVariable(label='Success' description='True if the summary was generated successfully.')
        public Boolean success;

        @InvocableVariable(label='Account Name' description='Resolved name of the account.')
        public String accountName;

        @InvocableVariable(label='Account ID' description='Salesforce Account record ID.')
        public String accountId;

        @InvocableVariable(label='Error Message' description='Error message if success is false.')
        public String errorMessage;

        @InvocableVariable(label='Is Data Sparse' description='True when key account fields (Industry, Type, BillingCity, BillingCountry, Description) are all blank. When true, call Web_Enrich_Account with the account name to supplement the summary with publicly available information.')
        public Boolean isDataSparse;
    }
}
