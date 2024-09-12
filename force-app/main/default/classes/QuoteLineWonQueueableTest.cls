@isTest
private class QuoteLineWonQueueableTest {
    @TestSetup
    static void makeData(){

        // Create internal account
        Account acc = new Account(Name = 'FastChem Cooperation', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Olin Corp').getRecordTypeId());
        insert acc;
        
        AccountName__c acctName = new AccountName__c();
        acctName.Name = 'FastChem Corp';
        acctName.OlinAccountValue__c = acc.id;
        insert acctName;

        // Create Users
        List<User> lstTestUser = new List<User>();
        Profile adminProfile = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator'];
        lstTestUser.add(new User(
            LastName = adminProfile.Name,
            FirstName = 'Test1',
            Email = adminProfile.Name.remove(' ') + '.' + 'Test1@fastchem.com.dev.test',
            Username = adminProfile.Name.remove(' ') + '.' + 'Test1@fastchem.com.dev.test',
            Alias = 'testusr1',
            CommunityNickname = 'test1' + adminProfile.Name.right(7),
            ProfileId = adminProfile.Id,
            TimeZoneSidKey = 'America/Chicago',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            CurrencyIsoCode = 'USD',
            UserRoleId = [SELECT Id FROM UserRole WHERE DeveloperName = 'Administration'].Id));

        lstTestUser.add(new User(
            LastName = adminProfile.Name,
            FirstName = 'Test2',
            Email = adminProfile.Name.remove(' ') + '.' + 'Test2@fastchem.com.dev.test',
            Username = adminProfile.Name.remove(' ') + '.' + 'Test2@fastchem.com.dev.test',
            Alias = 'testusr2',
            CommunityNickname = 'test2' + adminProfile.Name.right(7),
            ProfileId = adminProfile.Id,
            TimeZoneSidKey = 'America/Chicago',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            CurrencyIsoCode = 'USD',
            UserRoleId = [SELECT Id FROM UserRole WHERE DeveloperName = 'Administration'].Id));
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert lstTestUser;
        }

         // Create Account
        List<Account> accList = new List<Account>();
        Account soldToAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
            Name = 'Sold To Account',
            AccountNumber_R1__c = '267687',
            Ship_To__c = true,
            Sold_To__c = true
        );
        // insert soldToAccount;
        accList.add(soldToAccount);
        
        Account shipToAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
            Name = 'First Ship To Account',
            AccountNumber_R1__c = '267623',
            Ship_To__c = true,
            ParentId = soldToAccount.Id
        );
        // insert shipToAccount;
        accList.add(shipToAccount);

        Account shipToAccount2 = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
            Name = 'Second Ship To Account',
            AccountNumber_R1__c = '267432',
            Ship_To__c = true,
            ParentId = soldToAccount.Id
        );
        // insert shipToAccount2;
        accList.add(shipToAccount2);
        insert accList;

        // Create Account Relationship
        List<Account_Relationships__c> lstTestAccountRelationship = new List<Account_Relationships__c>();
        Account_Relationships__c testAccountRel = new Account_Relationships__c(
            Name = 'Test Account Relationship',
            Relationship_Type__c = 'Sold To / Ship To',
            Sold_To__c = soldToAccount.Id,
            Ship_To__c = shipToAccount.Id
        );
        lstTestAccountRelationship.add(testAccountRel);

        testAccountRel = new Account_Relationships__c(
            Name = 'Test Account Relationship 2',
            Relationship_Type__c = 'Sold To / Ship To',
            Sold_To__c = soldToAccount.Id,
            Ship_To__c = shipToAccount2.Id
        );
        lstTestAccountRelationship.add(testAccountRel);
        insert lstTestAccountRelationship;

        // Create Account Team Members
        AccountTeamMember teamMember = new AccountTeamMember(
            AccountId = soldToAccount.Id,
            UserId = lstTestUser[0].Id
        );
        insert teamMember;

        //Create Product
        Product2 testProduct = new Product2(
            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
            Name = 'Test Product',
            TradeProduct_R1__c = '123456',
            Product_Level__c = 'GMID'
        );
        insert testProduct;
        Product2 testProduct2 = new Product2(
            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
            Name = 'Test Product',
            TradeProduct_R1__c = '123433',
            Product_Level__c = 'Scale'
        );
        insert testProduct2;

        // Create Opportunity
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity testOpportunity = new Opportunity(
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Epoxy Commercial').getRecordTypeId(),
            Name = 'Test Opportunity',
            AccountId = soldToAccount.Id,
            CloseDate = date.newInstance(2019, 12, 31),
            StageName = 'Discovery/Qualification',
            CurrencyIsoCode = 'USD',
            Contract_Start_Date__c = date.newInstance(2019, 03, 01),
            Contract_End_Date__c = date.newInstance(2019, 12, 31)
        );
        //oppList.add(testOpportunity);
        insert testOpportunity;
        
        // Create Quote
        List<SBQQ__Quote__c> qList = new List<SBQQ__Quote__c>();
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c(
            RecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Draft Price Request').getRecordTypeId(),
            SBQQ__Primary__c = true,
            Price_Start_Date__c = date.newInstance(2019, 03, 01),
            SBQQ__Opportunity2__c = testOpportunity.Id,
            Ship_To_Any__c= true,
            SBQQ__Account__c = soldToAccount.Id
        );
        //insert testQuote;
        qList.add(testQuote);
        insert qList;
        
        
        SBQQ__QuoteLine__c testQuoteLine= new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = testQuote.Id,
            SBQQ__Product__c = testProduct.Id,
            SBQQ__Quantity__c = 1,
            SBQQ__ListPrice__c = 10,
            SBQQ__NetPrice__c = 10,
            SBQQ__Number__c = 1,
            SBQQ__SubscriptionPricing__c = 'Fixed Price',
            Price_Start_Date__c = date.newInstance(2019, 12, 31),
            Ship_To__c = shipToAccount.Id,
            Price_Request_Account__c = shipToAccount.Id,
            // Ship_To_Account__c = testAccountRel.Id,
            SBQQ__Bundle__c = true
        );
        insert testQuoteLine;

        testQuoteLine.ApprovalStatus__c = 'Approved';
        testQuoteLine.Status__c = 'Negotiation';
        update testQuoteLine;
        
    }

    testMethod
    static void test() {
        SBQQ__QuoteLine__c[] testQuoteLine = [SELECT Id, ApprovalStatus__c,Status__c, SBQQ__Quote__c, Name FROM SBQQ__QuoteLine__c LIMIT 1];

        Set<Id> quoteIds = new Set<Id>();
        Map<Id, Set<Id>> quoteLineIdsByQuoteId = new Map<Id, Set<Id>>();
        for (SBQQ__QuoteLine__c quoteLine : testQuoteLine) {
            quoteIds.add(quoteLine.SBQQ__Quote__c);
            if(!quoteLineIdsByQuoteId.containsKey(quoteLine.SBQQ__Quote__c)) {
                quoteLineIdsByQuoteId.put(quoteLine.SBQQ__Quote__c, new Set<Id>());
            }
            quoteLineIdsByQuoteId.get(quoteLine.SBQQ__Quote__c).add(quoteLine.Id);
        }
        

        Test.startTest();
        testQuoteLine[0].Status__c = 'Won';
        Test.setMock(HttpCalloutMock.class, new QuoteLineWonQueueableTest.MockHttpResponseGenerator());
            update testQuoteLine;
             // Create a mock implementation of HttpCalloutMock
            
        // String accessToken = QuoteLineWonQueueable.getAccessToken();
            // Enqueue the Queueable class
            //System.enqueueJob(new QuoteLineWonQueueable(quoteLineIdsByQuoteId, new MockHttpResponseGenerator(), false));

        Test.stopTest();

        
    }

    testMethod
    static void testGetAccessTokenMock() {
        Test.startTest();
        // Create a mock HTTP callout
        Test.setMock(HttpCalloutMock.class, new QuoteLineWonQueueableTest.MockHttpResponseGenerator());

        // Call the method you want to test
        String accessToken = QuoteLineWonQueueable.getAccessToken();
        Test.stopTest();

        // Perform assertions
        System.assertNotEquals(null, accessToken, 'Access token should not be null');
        // Add more assertions as needed based on the expected behavior of the method
    }

        // Mock implementation of HttpCalloutMock
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"access_token": "mocked_token"}'); // Set the desired response body
            return res;
        }
    }
}