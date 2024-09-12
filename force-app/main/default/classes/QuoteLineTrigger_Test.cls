@isTest
public class QuoteLineTrigger_Test {
    @testSetup 
    static void dataSetup() {
        
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

        Account soldToAccount2 = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
            Name = 'Sold To Account 2',
            AccountNumber_R1__c = '2676870',
            Ship_To__c = true,
            Sold_To__c = true,
            Distributor__c = true
        );
        // insert soldToAccount;
        accList.add(soldToAccount2);

        Account soldToAccount3 = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
            Name = 'Sold To Account 3',
            AccountNumber_R1__c = '2676871',
            Ship_To__c = false,
            Sold_To__c = false,
            Distributor__c = false
        );
        accList.add(soldToAccount3);

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
        
        Account_Relationships__c testAccountRel3 = new Account_Relationships__c(
            Name = 'Test Account Relationship 3',
            Relationship_Type__c = 'Sold To / Ship To',
            Sold_To__c = soldToAccount3.Id,
            Ship_To__c = soldToAccount3.Id
        );        
        lstTestAccountRelationship.add(testAccountRel3);

        Account_Relationships__c testAccountRel4 = new Account_Relationships__c(
            Name = 'Test Account Relationship 4',
            Relationship_Type__c = 'Sold To / Ship To',
            Sold_To__c = soldToAccount2.Id,
            Ship_To__c = soldToAccount2.Id
        );
        lstTestAccountRelationship.add(testAccountRel4);
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

        // Standard PriceBook
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry testPriceBook;
      
        list<PricebookEntry> priceBookTestUS = [select id from PricebookEntry where Product2Id = :testProduct.Id and Pricebook2Id = :pricebookId and CurrencyIsoCode = 'USD'];
        if(priceBookTestUS.size() == 1){
            testPriceBook = priceBookTestUS[0];
        }
        else
        {
            // Create PricebookEntry
            testPriceBook = new PricebookEntry( 
                Pricebook2Id = pricebookId,
                Product2Id = testProduct.id,
                CurrencyIsoCode = 'USD',
                IsActive = TRUE,
                UnitPrice = 100.0,
                UseStandardPrice = FALSE
            );
            insert testPriceBook;
        }

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
        
        // Create Opportunity
        Opportunity testOpportunity2 = new Opportunity(
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Epoxy Commercial').getRecordTypeId(),
            Name = 'Test Opportunity 12',
            AccountId = soldToAccount.Id,
            Type = 'Contract',
            CloseDate = date.newInstance(2019, 12, 31),
            StageName = 'Discovery/Qualification',
            CurrencyIsoCode = 'USD',
            Contract_Start_Date__c = date.newInstance(2020, 03, 01),
            Contract_End_Date__c = date.newInstance(2020, 12, 31)
        );
        oppList.add(testOpportunity2);
        insert oppList;

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
         SBQQ__Quote__c testQuote2 = new SBQQ__Quote__c(
            RecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Draft Price Request').getRecordTypeId(),
            SBQQ__Primary__c = true,
            Price_Start_Date__c = date.newInstance(2019, 03, 01),
            SBQQ__Opportunity2__c = testOpportunity2.Id,
            Ship_To_Any__c= true,
            SBQQ__Account__c = soldToAccount.Id
        );
        qList.add(testQuote2);
        insert qList;
        
        //Add quote as primary quote for Opportunity
       // testOpportunity2.SBQQ__PrimaryQuote__c = testQuote2.Id;
        //update testOpportunity2;
        

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
        
        /*SBQQ__QuoteLine__c testQuoteLine = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = testQuote.Id,
            SBQQ__Product__c = testProduct2.Id,
            SBQQ__Quantity__c = 1,
            SBQQ__ListPrice__c = 10,
            SBQQ__NetPrice__c = 10,
            SBQQ__Number__c = 1,
            SBQQ__SubscriptionPricing__c = 'Fixed Price',
            Price_Start_Date__c = date.newInstance(2019, 12, 31),
            Ship_To__c = shipToAccount.Id,
            SBQQ__Bundled__c = true,
            SBQQ__RequiredBy__c = testQuoteLinePrnt.Id
        );
        insert testQuoteLine;*/
        
        
        SBQQ__QuoteLine__c testQuoteLine2 = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = testQuote2.Id,
            SBQQ__Product__c = testProduct.Id,
            SBQQ__Quantity__c = 1,
            SBQQ__ListPrice__c = 10,
            SBQQ__NetPrice__c = 10,
            SBQQ__Number__c = 1,
            SBQQ__SubscriptionPricing__c = 'Fixed Price',
            Status__c = 'Negotiation',
            Price_Start_Date__c = date.newInstance(2019, 12, 31),
            Source_Quote_Line__c = testQuoteLine.Id,
            Ship_To__c = shipToAccount.Id,
            Price_Request_Account__c = shipToAccount.Id,
            SBQQ__Source__c = testQuoteLine.Id,
            ApprovalStatus__c = 'Approved'
        );

        insert testQuoteLine2;

        // SBQQ__QuoteLine__c testQuoteLine3 = new SBQQ__QuoteLine__c(
        //     SBQQ__Quote__c = testQuote2.Id,
        //     SBQQ__Product__c = testProduct.Id,
        //     SBQQ__Quantity__c = 1,
        //     SBQQ__ListPrice__c = 10,
        //     SBQQ__NetPrice__c = 10,
        //     SBQQ__Number__c = 1,
        //     product_level__c = 'Scale',
        //     SBQQ__RequiredBy__c = testQuoteLine.Id
        // );
        // insert testQuoteLine3;

      
        Mulesoft_ContractEndpoint__c mc = new Mulesoft_ContractEndpoint__c();
        // mc.Contracted_Price_Request_Status__c = 'test';
        // mc.Id = mc.Id;
        mc.Enabled__c = true;
        mc.Endpoint__c = 'https://contract-number-mapping-uat.us-e2.cloudhub.io/contractmapping';
        mc.Timeout__c = 60000;
        mc.Contracted_Price_Request_Status__c = 'Draft Contract';
        mc.Operation__c = 'POST';
        insert mc;
    }

    testMethod static void testPopulateStatus() {
        Map<Id, SBQQ__QuoteLine__c> qlMap = new Map<Id, SBQQ__QuoteLine__c>();

        SBQQ__QuoteLine__c quoteLine = [SELECT Id, Status__c, ApprovalStatus__c, Source_Quote_Line__c 
                                        FROM SBQQ__QuoteLine__c 
                                        WHERE Source_Quote_Line__c != NULL LIMIT 1];
        qlMap.put(quoteLine.Id, quoteLine);

        List<SBQQ__QuoteLine__c> newQlList = new List<SBQQ__QuoteLine__c>();
        
        quoteLine.ApprovalStatus__c = 'Approved';
        newQlList.add(quoteLine);
        test.startTest();
            QuoteLineTrigger_Handler.populateStatus(newQlList, qlMap);
        test.stopTest();
    }
    testMethod static void testOnCloneQuoteLineInsert(){
       
        SBQQ__QuoteLine__c qlId = [SELECT Id FROM SBQQ__QuoteLine__c WHERE Source_Quote_Line__c = NULL LIMIT 1];

        List<SBQQ__QuoteLine__c> qlList = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c qlDetails = [SELECT Id, Status__c, ApprovalStatus__c, Source_Quote_Line__c, 
                                        SBQQ__RequiredBy__c, SBQQ__Quote__c, SBQQ__Product__c, 
                                        Ship_To__c, Ship_To_Account__c 
                                FROM SBQQ__QuoteLine__c 
                                WHERE Source_Quote_Line__c != NULL 
                                LIMIT 1];
        // qlDetails.SBQQ__RequiredBy__c = qlId.Id;
        qlList.add(qlDetails);
        System.debug('QUOTE LIST JL >>> '  + qlList);
        test.startTest();        
            QuoteLineTrigger_Handler.onCloneQuoteLineInsert(qlList);
        test.stopTest();
    }

    testMethod static void testDeleteSharing() {        
        // SBQQ__QuoteLine__c ql = [SELECT Id, ApprovalStatus__c
        //                         FROM SBQQ__QuoteLine__c 
        //                         WHERE Source_Quote_Line__c != NULL LIMIT 1];
        
        // ql.ApprovalStatus__c = null;
        // // Delete Quote Lines 
        // Test.startTest();
        // delete ql;
        // Test.stopTest();
    }

    testMethod static void customerProdCode(){
        List<SBQQ__QuoteLine__c> quotelineList = [SELECT Id, SAP_Sales_Org__c, SBQQ__Product__c, Price_Request_Account__c, Ship_To_Account__c, Customer_Product_Code__c
                                                    FROM SBQQ__QuoteLine__c]; 
        // system.debug('QUOTELINE SIZE >>> ' + quotelineList.size());

        test.startTest();
        QuoteLineTrigger_Handler.populateCustomerProductCode(quotelineList);
        test.stopTest();
    }

    
    testMethod static void customerProdCodeWithShipToAcc(){
        System.debug('JL TEST');
        List<SBQQ__QuoteLine__c> quotelineList = new List<SBQQ__QuoteLine__c>();
        Account_Relationships__c acctRel = [SELECT Id FROM Account_Relationships__c LIMIT 1];
       
        SBQQ__QuoteLine__c quoteLine = [SELECT Id, SAP_Sales_Org__c, SBQQ__Product__c, 
                                            Price_Request_Account__c, Ship_To_Account__c, 
                                            Customer_Product_Code__c
                                            FROM SBQQ__QuoteLine__c 
                                            LIMIT 1 ]; 
        
        quoteLine.Ship_To_Account__c = acctRel.Id;
        quoteLine.Price_Request_Account__c = null;
        quotelineList.add(quoteLine);
       
        test.startTest();
        QuoteLineTrigger_Handler.populateCustomerProductCode(quotelineList);
        test.stopTest();
    }

    testMethod static void quoteLineSaveTest(){
        Map<Id, SBQQ__QuoteLine__c> oldMap = new Map<Id, SBQQ__QuoteLine__c>();
        Map<Id, SBQQ__QuoteLine__c> newMap = new Map<Id, SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c newQuoteLine = new SBQQ__QuoteLine__c();
        SBQQ__QuoteLine__c oldQuoteLine = new SBQQ__QuoteLine__c();
        test.startTest();

        Account_Relationships__c accRel = [SELECT Id, Name, Relationship_type__c, Sold_to__c, Ship_to__c, Ship_to__r.Account_Data_Source__c,
                                            Ship_to__r.status_R1__c, Sold_to__r.status_R1__c, Is_Distribution_Relationship__c
                                            FROM Account_Relationships__c 
                                            WHERE name = 'Test Account Relationship 3' 
                                            LIMIT 1];
        
        Account accTest = [SELECT Id, Account_Data_Source__c, Status_R1__c FROM Account WHERE Id =: accRel.Ship_to__c];
        
        SBQQ__QuoteLine__c quoteLine = [SELECT Id, Status__c, ApprovalStatus__c, Source_Quote_Line__c, 
                            SBQQ__RequiredBy__c, SBQQ__Quote__c, SBQQ__Product__c, 
                            Ship_To__c, Ship_To__r.Status_R1__c, Ship_To_Account__c, Price_Request_Account__c, 
                            Price_Request_Account__r.Status_R1__c 
                    FROM SBQQ__QuoteLine__c 
                    WHERE Source_Quote_Line__c != NULL 
                    LIMIT 1];
        oldQuoteLine = quoteLine.clone();
        newQuoteLine = quoteLine.clone();

        
        oldMap.put(oldQuoteLine.Id, oldQuoteLine);
        
        newQuoteLine.Ship_To_Account__c = accRel.Id;
        // update newQuoteLine;
        newMap.put(newQuoteLine.Id, newQuoteLine);

        QuoteLineTrigger_Handler.onQuoteLineSave(newMap, oldMap);
        
        test.stopTest();
        
    }

    
    testMethod  static void deleteScaleItemTest(){
        Set<Id> toDelItems = new Set<Id>();

        for(SBQQ__QuoteLine__c ids: [SELECT Id FROM SBQQ__QuoteLine__c]){
            toDelItems.add(ids.Id);            
        }
        
        Test.startTest();
            QuoteLineTrigger_Handler.deleteScaleItems(toDelItems);
        Test.stopTest();
        
    }

    testMethod static void quoteLineWonTest(){
        List<SBQQ__QuoteLine__c> quoteLineLs = new List<SBQQ__QuoteLine__c>();
        Map<Id, SBQQ__QuoteLine__c> oldMap = new Map<Id, SBQQ__QuoteLine__c>();
       
        SBQQ__QuoteLine__c quoteLine = [SELECT Id, Status__c, ApprovalStatus__c, Source_Quote_Line__c, 
                            SBQQ__RequiredBy__c, SBQQ__Quote__c, SBQQ__Product__c, 
                            Ship_To__c, Ship_To__r.Status_R1__c, Ship_To_Account__c, Price_Request_Account__c, 
                            Price_Request_Account__r.Status_R1__c 
                    FROM SBQQ__QuoteLine__c 
                    WHERE Status__c = 'Negotiation' 
                    LIMIT 1];
        SBQQ__QuoteLine__c oldQuoteline = new SBQQ__QuoteLine__c();
        test.startTest(); 
        Test.setMock(HttpCalloutMock.class, new QuoteLineTrigger_Test.MockHttpResponseGenerator());
        oldQuoteline = quoteLine.clone(true,false,false,false);
        
        oldMap.put(oldQuoteline.Id, oldQuoteline);
        
        quoteLine.Status__c = 'Won';
        quoteLine.SBQQ__RequiredBy__c = null;
        quoteLineLs.add(quoteLine);        
            QuoteLineTrigger_Handler.onQuoteLineWon(quoteLineLs, oldMap);
        test.stopTest();
    }

    
    testMethod static void validateSoldToShipQuoteTest(){
        
        Map<Id, Id> qlMap = new Map<Id,Id>();
        SBQQ__QuoteLine__c ql = [SELECT Id,  SBQQ__Quote__c, SBQQ__Quote__r.SBQQ__Account__c
                    FROM SBQQ__QuoteLine__c 
                    LIMIT 1];
        qlMap.put(ql.SBQQ__Quote__c, ql.SBQQ__Quote__r.SBQQ__Account__c);
        Test.startTest();
        
            QuoteLineTrigger_Handler.getValidSoldToShipToQuotes(qlMap);
        
        Test.stopTest();
        
    }

    testMethod static void onRejectRecallTest(){
        List<SBQQ__QuoteLine__c> quoteLineLs = new List<SBQQ__QuoteLine__c>();
        Map<Id, SBQQ__QuoteLine__c> oldMap = new Map<Id, SBQQ__QuoteLine__c>();
       
        SBQQ__QuoteLine__c quoteLine = [SELECT Id, Status__c, ApprovalStatus__c, Source_Quote_Line__c, 
                            SBQQ__RequiredBy__c, SBQQ__Quote__c, SBQQ__Product__c, 
                            Ship_To__c, Ship_To__r.Status_R1__c, Ship_To_Account__c, Price_Request_Account__c, 
                            Price_Request_Account__r.Status_R1__c, SBQQ__Source__c 
                    FROM SBQQ__QuoteLine__c 
                    WHERE Status__c = 'Negotiation' 
                    LIMIT 1];
        SBQQ__QuoteLine__c oldQuoteline = new SBQQ__QuoteLine__c();
        test.startTest(); 
        Test.setMock(HttpCalloutMock.class, new QuoteLineTrigger_Test.MockHttpResponseGenerator());
        oldQuoteline = quoteLine.clone(true,false,false,false);
        
        oldMap.put(oldQuoteline.Id, oldQuoteline);
        
        quoteLine.ApprovalStatus__c = 'Rejected';
        // quoteLine.SBQQ__RequiredBy__c = null;
        quoteLineLs.add(quoteLine);        
            QuoteLineTrigger_Handler.onRejectRecall(quoteLineLs, oldMap);
        test.stopTest();
    }


    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"access_token": "mocked_token"}'); // Set the desired response body
            return res;
        }
    }

    @IsTest
    static void singletonTest(){
        
        Test.startTest();
        QuoteLineTrigger_Handler.runOnceBefore();
        QuoteLineTrigger_Handler.runOnceAfter();
        QuoteLineTrigger_Handler.runOnceBeforeInsert();
        Test.stopTest();
        
    }
    @IsTest
    static void testPending() {
        SBQQ__QuoteLine__c[] testQuoteLine = [SELECT Id, ApprovalStatus__c,Status__c, SBQQ__Quote__c, Name FROM SBQQ__QuoteLine__c LIMIT 1];

        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new QuoteLineTrigger_Test.MockHttpResponseGenerator());
        testQuoteLine[0].ApprovalStatus__c = 'Pending';
            update testQuoteLine;
             // Create a mock implementation of HttpCalloutMock
            
        // String accessToken = QuoteLineWonQueueable.getAccessToken();
            // Enqueue the Queueable class
            //System.enqueueJob(new QuoteLineWonQueueable(quoteLineIdsByQuoteId, new MockHttpResponseGenerator(), false));
        Test.stopTest();

        
    }

    @IsTest
    static void testRejected() {
        SBQQ__QuoteLine__c[] testQuoteLine = [SELECT Id, ApprovalStatus__c,Status__c, SBQQ__Quote__c, Name FROM SBQQ__QuoteLine__c LIMIT 1];

        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new QuoteLineTrigger_Test.MockHttpResponseGenerator());
        testQuoteLine[0].ApprovalStatus__c = 'Rejected';
        update testQuoteLine;
        Test.stopTest();
        
    }

    @isTest
    static void beforeQuotelineDel(){
        Map<Id, SBQQ__QuoteLine__c> quotelineMap = new Map<Id, SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c quoteLine = [SELECT Id, ApprovalStatus__c FROM SBQQ__QuoteLine__c WHERE ApprovalStatus__c = 'Approved' LIMIT 1];
        quotelineMap.put(quoteLine.Id, quoteLine);

        Test.startTest();
        QuoteLineTrigger_Handler.beforeQuoteLinesDelete(quotelineMap);
        Test.stopTest();
    }

    testMethod static void negativeQuoteLineSaveTest(){
        Map<Id, SBQQ__QuoteLine__c> oldMap = new Map<Id, SBQQ__QuoteLine__c>();
        Map<Id, SBQQ__QuoteLine__c> newMap = new Map<Id, SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c newQuoteLine = new SBQQ__QuoteLine__c();
        SBQQ__QuoteLine__c oldQuoteLine = new SBQQ__QuoteLine__c();
        test.startTest();

        Account_Relationships__c accRel = [SELECT Id, Name, Relationship_type__c, Sold_to__c, Ship_to__c, Ship_to__r.Account_Data_Source__c,
                                            Ship_to__r.status_R1__c, Sold_to__r.status_R1__c, Is_Distribution_Relationship__c
                                            FROM Account_Relationships__c 
                                            WHERE name = 'Test Account Relationship 4' 
                                            LIMIT 1];
        
        Account accTest = [SELECT Id, Account_Data_Source__c, Status_R1__c FROM Account WHERE Id =: accRel.Ship_to__c];
        
        SBQQ__QuoteLine__c quoteLine = [SELECT Id, Status__c, ApprovalStatus__c, Source_Quote_Line__c, 
                            SBQQ__RequiredBy__c, SBQQ__Quote__c, SBQQ__Product__c, 
                            Ship_To__c, Ship_To__r.Status_R1__c, Ship_To_Account__c, Price_Request_Account__c, 
                            Price_Request_Account__r.Status_R1__c, SAP_Sales_Org__c
                    FROM SBQQ__QuoteLine__c 
                    WHERE Source_Quote_Line__c != NULL 
                    LIMIT 1];
        oldQuoteLine = quoteLine.clone();
        newQuoteLine = quoteLine.clone();
        System.debug('SHIP TO ACCOUNT >>> ' + quoteLine.Ship_To_Account__c);
        
        oldMap.put(oldQuoteLine.Id, oldQuoteLine);
        
        newQuoteLine.Ship_To_Account__c = accRel.Id;
        // update newQuoteLine;
        newMap.put(newQuoteLine.Id, newQuoteLine);

        QuoteLineTrigger_Handler.onQuoteLineSave(newMap, oldMap);
        
        test.stopTest();
        
    }


/** = = = = = = = = = = = = = = = = = = = = = = = = = */
  
   /* testMethod static void testDeleteSharing() {
        List<SBQQ__Quote__c> lstQuote = [SELECT Id FROM SBQQ__Quote__c];
        List<Product2> lstProduct = [SELECT Id FROM Product2];
        List<Account> lstShipToAccount1 = [SELECT Id FROM Account WHERE Name = 'First Ship To Account'];

        // Create Quote Line
        SBQQ__QuoteLine__c testQuoteLine = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = lstQuote[0].Id,
            SBQQ__Product__c = lstProduct[0].Id,
            SBQQ__Quantity__c = 1,
            SBQQ__ListPrice__c = 10,
            SBQQ__NetPrice__c = 10,
            SBQQ__Number__c = 1,
            SBQQ__SubscriptionPricing__c = 'Fixed Price',
            Price_Start_Date__c = date.newInstance(2019, 12, 31),
            Ship_To__c = lstShipToAccount1[0].Id
        );
        insert testQuoteLine;

        // Delete Quote Lines 
        Test.startTest();
        delete testQuoteLine;
        Test.stopTest();
    }

    @isTest static void testcalculateGMIDPriorPrice(){
        List<SBQQ__Quote__c> lstQuote = [SELECT Id FROM SBQQ__Quote__c];
        List<Product2> lstProduct = [SELECT Id FROM Product2];
        List<Account> lstShipToAccount1 = [SELECT Id FROM Account WHERE Name = 'First Ship To Account'];

        List<SBQQ__QuoteLine__c> lstQL = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c testQuoteLine = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = lstQuote[0].Id,
            SBQQ__Product__c = lstProduct[0].Id,
            SBQQ__Quantity__c = 1,
            SBQQ__ListPrice__c = 10,
            SBQQ__NetPrice__c = 10,
            SBQQ__Number__c = 1,
            SBQQ__SubscriptionPricing__c = 'Fixed Price',
            Price_Start_Date__c = date.newInstance(2019, 12, 31),
            Ship_To__c = lstShipToAccount1[0].Id
        );
        lstQL.add(testQuoteLine);
        insert lstQL;
        
        Test.startTest();
        QuoteLineTrigger_Handler.calculateGMIDPriorPrice(lstQL);
        Test.stopTest();
    }*/
}