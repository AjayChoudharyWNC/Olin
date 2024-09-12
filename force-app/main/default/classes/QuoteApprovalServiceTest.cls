@isTest
private class QuoteApprovalServiceTest {
    @testSetup
    public static void testsSetup(){
         // Create internal account
         // 
        List<Account> accList = new List<Account>();
        Account soldToAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
            Name = 'Sold To Account',
            AccountNumber_R1__c = '267687',
            Ship_To__c = true,
            Sold_To__c = true
        );
        accList.add(soldToAccount);
        
        Account shipToAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
            Name = 'First Ship To Account',
            AccountNumber_R1__c = '267623',
            Ship_To__c = true,
            ParentId = soldToAccount.Id
        );
        accList.add(shipToAccount);

        // insert shipToAccount;
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

        //Create Product
        Product2 testProduct = new Product2(
            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
            Name = 'Test Product',
            TradeProduct_R1__c = '123456',
            Product_Level__c = 'GMID'
        );
        insert testProduct;

        // Standard PriceBook
        Id pricebookId = Test.getStandardPricebookId();
        

        // Create Opportunity
        Opportunity testOpportunity = new Opportunity(
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CAPV Commercial').getRecordTypeId(),
            Name = 'Test Opportunity',
            Type = 'Contract',
            CloseDate = date.newInstance(2019, 12, 31),
            StageName = 'Discovery/Qualification',
            CurrencyIsoCode = 'USD',
            Contract_Start_Date__c = date.newInstance(2019, 03, 01),
            Contract_End_Date__c = date.newInstance(2019, 12, 31)
        );
        insert testOpportunity;

        // Create Quote
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c(
            RecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Draft Price Request').getRecordTypeId(),
            SBQQ__Primary__c = true,
            Price_Start_Date__c = date.newInstance(2019, 03, 01),
            SBQQ__Opportunity2__c = testOpportunity.Id,
            Ship_To_Any__c= true,
            SubmitForApproval__c = true
        );
        insert testQuote;
        
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
            SBQQ__Bundle__c = true
        );
        insert testQuoteLine;
		
        sbaa__ApprovalChain__c testApprovalChain    = new sbaa__ApprovalChain__c(sbaa__TargetObject__c = 'SBQQ__QuoteLine__c',
        Name='Test Chain');
        insert testApprovalChain;
        
        sbaa__Approver__c testApprover = new sbaa__Approver__c(sbaa__User__c = userInfo.getUserId());
        insert testApprover;
        
        sbaa__Approval__c approvalRecord = new sbaa__Approval__c(Quote__c = testQuote.id,
        Quote_Line__c = testQuoteLine.id,
        sbaa__ApprovalStep__c = 1,
        sbaa__RecordField__c = 'Quote_Line__c',
        sbaa__ApprovalChain__c = testApprovalChain.id,
        sbaa__Approver__c = testApprover.id);      
        insert approvalRecord ;
    }
    static testMethod void submitTest() {
      
		SBQQ__Quote__c testQuote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        
        Test.startTest();
        QuoteApprovalService.submit(new Set<Id>{testQuote.Id});
        Test.stopTest();

    }
    static testMethod void approveRejectTest(){
       //List<Id> approvalIds, Boolean doApprove, String comments
         sbaa__Approval__c[] approvalTest = [SELECT Id, Quote__c  FROM sbaa__Approval__c LIMIT 1];
        Map<Id, Set<Id>> mQuoteApproval = new Map<Id, Set<Id>>();
        for (sbaa__Approval__c ap : approvalTest){
            Id approvalIdtmp = ap.Id;
            if (mQuoteApproval.containsKey(ap.Quote__c)){
                mQuoteApproval.get(ap.Quote__c).add(approvalIdtmp);
            } else {
                Set<Id> lApprovalIdtmp = new Set<Id>();
                lApprovalIdtmp.add(approvalIdtmp);
                mQuoteApproval.put(ap.Quote__c,lApprovalIdtmp);
            }
        }
        
        Test.startTest();
        QuoteApprovalService.approveReject(new List<Id>{approvalTest[0].Id}, True, 'test comment');
        Test.setMock(HttpCalloutMock.class, new QuoteApprovalServiceTest.MockHttpResponseGenerator());
        System.enqueueJob(new QueueableQuoteLineApprovals(mQuoteApproval, true, 'test'));
        Test.stopTest();
        
    }
    static testMethod void waitUntilQuoteUnlockedTest(){
        SBQQ__QuoteLine__c qlTest = [SELECT Id FROM SBQQ__QuoteLine__c LIMIT 1];
         Test.startTest();
        QuoteApprovalService.waitUntilQuoteUnlocked(qlTest.Id);
        Test.stopTest();
        
    }
    static testMethod void isQuoteLockedTest(){
        SBQQ__QuoteLine__c qlTest = [SELECT Id FROM SBQQ__QuoteLine__c LIMIT 1];
         Test.startTest();
        QuoteApprovalService.isQuoteLocked(qlTest.Id);
        Test.stopTest();
        
    }

    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"access_token": "mocked_token"}'); // Set the desired response body
            return res;
        }
    }
    
}