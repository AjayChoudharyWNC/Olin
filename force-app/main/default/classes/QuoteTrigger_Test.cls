@isTest
public class QuoteTrigger_Test {
    
    @testSetup static void testContractMapping() {
        List<User> lstTestUser = new List<User>();
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
       // Insert account as current user
        System.runAs (thisUser) {
            UserRole ur = new UserRole(Name = 'CEO');
            insert ur;
            // Create Users
            
            Profile adminProfile = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator'];
            
            User testUser = new User(
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
                UserRoleId= ur.Id);
            lstTestUser.add(testUser);
            
            testUser = new User(
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
                UserRoleId= ur.Id);
            lstTestUser.add(testUser);
            insert lstTestUser;
        }
        // Create internal account
        Account acc = new Account(Name = 'FastChem Cooperation', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Olin Corp').getRecordTypeId());
        insert acc;
        
        AccountName__c acctName = new AccountName__c();
        acctName.Name = 'FastChem Corp';
        acctName.OlinAccountValue__c = acc.id;
        insert acctName;
        // Create Account
        List<Account> accList = new List<Account>();

        Account parentAccount = new Account(
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Parent').getRecordTypeId(),
                Name = 'Parent Account',
                AccountNumber_R1__c = '267690',
                Ship_To__c = true,
                Sold_To__c = true
            );
        accList.add(parentAccount);

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
            AccountNumber_R1__c = '267656',
            Ship_To__c = true,
            ParentId = parentAccount.Id
        );
        accList.add(shipToAccount);
        
        Account shipToAccount2 = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
            Name = 'Second Ship To Account',
            AccountNumber_R1__c = '267632',
            Ship_To__c = true,
            ParentId = parentAccount.Id
        );
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
        
        // Standard PriceBook
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry testPriceBookEntry;
         system.debug('Test Pricebook: ' + pricebookId);
      
        list<PricebookEntry> priceBookTestUS = [select id from PricebookEntry where Product2Id = :testProduct.Id and Pricebook2Id = :pricebookId and CurrencyIsoCode = 'USD'];
        if(priceBookTestUS.size() == 1){
            testPriceBookEntry = priceBookTestUS[0];
        }
        else
        {
        // Create PricebookEntry
       testPriceBookEntry = new PricebookEntry( 
            Pricebook2Id = pricebookId,
            Product2Id = testProduct.id,
            CurrencyIsoCode = 'USD',
            IsActive = TRUE,
            UnitPrice = 100.0,
            UseStandardPrice = FALSE
        );
        insert testPriceBookEntry;
        }
        // Create Opportunity
        Opportunity testOpportunity = new Opportunity(
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CAPV Commercial').getRecordTypeId(),
            Name = 'Test Opportunity',
            AccountId = shipToAccount2.Id,
            Type = 'Contract',
            CloseDate = date.newInstance(2019, 12, 31),
            StageName = 'Discovery/Qualification',
            CurrencyIsoCode = 'USD',
            Contract_Start_Date__c = date.newInstance(2019, 03, 01),
            Contract_End_Date__c = date.newInstance(2019, 12, 31)
        );
        insert testOpportunity;
        List<Opportunity> oppList = new List<Opportunity>();
        for(Integer i=1; i<=21; i++){
            oppList.add(new Opportunity(
                RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CAPV Commercial').getRecordTypeId(),
                Name = 'Test Opportunity' + i,
                AccountId = shipToAccount2.Id,
                Type = 'Contract',
                CloseDate = date.newInstance(2019, 12, 31),
                StageName = 'Discovery/Qualification',
                CurrencyIsoCode = 'USD',
                Contract_Start_Date__c = date.newInstance(2019, 03, 01),
                Contract_End_Date__c = date.newInstance(2019, 12, 31)
            ));
        }
        
        insert oppList;
        // Create Quote
        
        SBQQ__Quote__c testOriginalQuote = new SBQQ__Quote__c(
            RecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Draft Price Request').getRecordTypeId(),
            SBQQ__Primary__c = true,
            Price_Start_Date__c = date.newInstance(2019, 03, 01),
            SBQQ__Opportunity2__c = testOpportunity.Id,
            Ship_To_Any__c= true,
            SBQQ__Account__c = soldToAccount.Id,
            SentToSAP__c = false,
            SBQQ__Status__c = 'Proposal'
        );
        insert testOriginalQuote;
        
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c(
            RecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Draft Price Request').getRecordTypeId(),
            SBQQ__Primary__c = true,
            Price_Start_Date__c = date.newInstance(2019, 03, 01),
            SBQQ__Opportunity2__c = testOpportunity.Id,
            Ship_To_Any__c= true,
            SBQQ__Account__c = soldToAccount.Id,
            Original_Price_Request__c = testOriginalQuote.Id,
            SentToSAP__c = false,
            Price_Request_Version__c = 10,
            SBQQ__Status__c = 'Proposal'
        );
        insert testQuote;
        
        SBQQ__Quote__c testQuote1 = new SBQQ__Quote__c(
            RecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Draft Price Request').getRecordTypeId(),
            SBQQ__Primary__c = true,
            Price_Start_Date__c = date.newInstance(2019, 03, 01),
            SBQQ__Opportunity2__c = testOpportunity.Id,
            Ship_To_Any__c= true,
            SBQQ__Account__c = soldToAccount.Id,
            Original_Price_Request__c = testOriginalQuote.Id,
            SentToSAP__c = false,
            Price_Request_Version__c = 1,
            SBQQ__Status__c = 'Proposal'
        );
        insert testQuote1;

        SBQQ__Quote__c testQuote2 = new SBQQ__Quote__c(
            RecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Draft Price Request').getRecordTypeId(),
            SBQQ__Primary__c = true,
            Price_Start_Date__c = date.newInstance(2019, 03, 01),
            SBQQ__Opportunity2__c = testOpportunity.Id,
            Ship_To_Any__c= true,
            SBQQ__Account__c = soldToAccount.Id,
            Original_Price_Request__c = testOriginalQuote.Id,
            SentToSAP__c = false,
            Price_Request_Version__c = 1,
            SBQQ__Status__c = 'Quotation'
        );
        insert testQuote2;

        Mulesoft_ContractEndpoint__c mc = new Mulesoft_ContractEndpoint__c();
        mc.Endpoint__c = 'https://contract-to-sap-uat.us-e2.cloudhub.io/contract';  //'https://contract-to-sap.us-e2.cloudhub.io/contract';
        mc.Operation__c = 'POST';
        mc.Timeout__c = 60000;
        mc.Contracted_Price_Request_Status__c = 'Draft Contract';
        mc.Contracted_Price_Request_Record_Type__c = 'Contract - Fields Locked';
        mc.Sent_to_SAP_Email_Template__c = 'Price_Update_Email_Template';
        mc.Enabled__c = true;
        
        
        Test.startTest();
        insert mc;
        Test.stopTest();
    }
    
    testMethod static void testWithoutShipTo() {
        Test.startTest();
        List<SBQQ__Quote__c> quotes = [SELECT Id, SentToSAP__c, SBQQ__Status__c, SBQQ__Opportunity2__c FROM SBQQ__Quote__c];
        
        quotes[1].ApprovalStatus__c = 'Approved';
        update quotes;
        Test.stopTest();
    }
    
    testMethod static void testWithShipTo() {
        Test.startTest();
        List<SBQQ__Quote__c> quotes = [SELECT Id, SentToSAP__c, SBQQ__Status__c FROM SBQQ__Quote__c];
        List<SBQQ__QuoteLine__c> quotelines = [SELECT Id, Ship_To__c FROM SBQQ__QuoteLine__c];
        List<Account> soldToAccount = [SELECT Id FROM Account WHERE Name = 'Sold To Account'];
        List<Account> parentAcc = [SELECT Id FROM Account WHERE Name = 'Parent Account'];

        Set<Id> quoteId = new Set<Id>();
        Account shipToAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
            Name = 'Ship To Account 2',
            AccountNumber_R1__c = '267623',
            Ship_To__c = true,
            ParentId = parentAcc[0].Id
        );
        insert shipToAccount;
          
        quotes[1].ApprovalStatus__c = 'Approved';
        update quotes;
        
        
        Test.stopTest();
    }
    
    /* testMethod static void testDoContractSubmit() {
        List<SBQQ__Quote__c> lstQuote = [SELECT Id FROM SBQQ__Quote__c];
        Set<String> quoteIds = new Set<String>();
        
        for(SBQQ__Quote__c testQuote : lstQuote) {
            quoteIds.add(testQuote.Id);
        }
        
        Test.setMock(HttpCalloutMock.class, new MuleSoftCalloutManager_MockTest());
        QuoteTrigger_Handler.doContractSubmit(quoteIds,quoteIds);
    }
    
    testMethod static void testWithShipToBulk() {
        Test.startTest();        
        Set<id> setQuoteId = new Set<id>();
        for(SBQQ__Quote__c rec :  [SELECT Id FROM SBQQ__Quote__c]){
            setQuoteId.add(rec.Id);
        }
        QuoteTrigger_Handler.updateQuoteandSubmit(setQuoteId);
        Test.stopTest();
        
    } */
    
    testMethod static void testUpdatePRV1() {
        Test.startTest();
        List<SBQQ__Quote__c> quotes = [SELECT Id, SentToSAP__c, SBQQ__Status__c FROM SBQQ__Quote__c WHERE Price_Request_Version__c = 1];
        
        quotes[1].SBQQ__Status__c = 'Draft Contract';
        update quotes;
        Test.stopTest();
    }

    testMethod static void testDoContractSubmitCallout() {
        
        
        Test.startTest();

        SBQQ__Quote__c quote = [SELECT Id, SentToSAP__c, SBQQ__Status__c FROM SBQQ__Quote__c WHERE Price_Request_Version__c = 1 LIMIT 1];
        Product2 product  = [SELECT Id FROM Product2 LIMIT 1];
        Account soldToAccount = [SELECT Id FROM Account WHERE Name = 'Sold To Account' LIMIT 1];
        Mulesoft_ContractEndpoint__c mc = [SELECT Id FROM Mulesoft_ContractEndpoint__c LIMIT 1];
        
        SBQQ__QuoteLine__c testQuoteLine = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = quote.Id,
            SBQQ__Product__c = product.Id,
            SBQQ__Quantity__c = 1,
            SBQQ__ListPrice__c = 10,
            SBQQ__NetPrice__c = 10,
            SBQQ__Number__c = 1,
            SBQQ__SubscriptionPricing__c = 'Fixed Price',
            Price_Request_Account__c = soldToAccount.Id,
            Product_Level__c = 'GMID'
            
        );
        insert testQuoteLine;

        
        quote.SBQQ__Status__c = 'Draft Contract';
        update quote;

        Test.setMock(HttpCalloutMock.class, new MuleSoftCalloutManager_MockTest());
        
        Test.stopTest();

        
    }

    @isTest static void testQuotePending(){
        SBQQ__Quote__c quote = [SELECT Id, SentToSAP__c, SBQQ__Status__c, ApprovalStatus__c, SBQQ__LastCalculatedOn__c, SBQQ__LastSavedOn__c, SBQQ__Uncalculated__c FROM SBQQ__Quote__c WHERE Price_Request_Version__c = 1 LIMIT 1];
        DateTime dt = Datetime.now();
        quote.ApprovalStatus__c = 'Pending';
        quote.SBQQ__LastCalculatedOn__c = dt;
        quote.SBQQ__LastSavedOn__c = dt;

        Test.startTest();
        SBQQ.TriggerControl.disable();
        update quote;
        SBQQ.TriggerControl.enable();
        Test.stopTest();
    }

    @isTest static void testSubmitQuoteContract() {
        SBQQ__Quote__c quote = [SELECT Id, SentToSAP__c, SBQQ__Status__c, ApprovalStatus__c FROM SBQQ__Quote__c WHERE Price_Request_Version__c = 1 LIMIT 1];

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new MuleSoftCalloutManager_MockTest());

        // QuoteTrigger_Handler.submitQuoteContract(quote.Id,true);
        Test.stopTest();
    }


    @isTest static void testQuoteApproval(){
        SBQQ__Quote__c quote = [SELECT Id, SentToSAP__c, SBQQ__Status__c, ApprovalStatus__c, SBQQ__LastCalculatedOn__c, SBQQ__LastSavedOn__c, SBQQ__Uncalculated__c FROM SBQQ__Quote__c WHERE Price_Request_Version__c = 1 LIMIT 1];
        DateTime dt = Datetime.now();
        quote.ApprovalStatus__c = 'Approved';
        quote.SBQQ__LastCalculatedOn__c = dt;
        quote.SBQQ__LastSavedOn__c = dt;

        Test.startTest();
        SBQQ.TriggerControl.disable();
        update quote;
        SBQQ.TriggerControl.enable();
        Test.stopTest();
    }

    @isTest static void testQuoteRejectRecall(){
        SBQQ__Quote__c quote = [SELECT Id, SentToSAP__c, SBQQ__Status__c, ApprovalStatus__c, SBQQ__LastCalculatedOn__c, SBQQ__LastSavedOn__c, SBQQ__Uncalculated__c FROM SBQQ__Quote__c WHERE Price_Request_Version__c = 1 LIMIT 1];
        DateTime dt = Datetime.now();
        quote.ApprovalStatus__c = 'Recalled';
        quote.SBQQ__LastCalculatedOn__c = dt;
        quote.SBQQ__LastSavedOn__c = dt;

        Test.startTest();
        SBQQ.TriggerControl.disable();
        update quote;
        SBQQ.TriggerControl.enable();
        
        Test.stopTest();
    }

    // @isTest static void testSendEmailNotification(){
    
    //     SBQQ__Quote__c quote = [SELECT Id, SentToSAP__c, SBQQ__Status__c, ApprovalStatus__c, SBQQ__LastCalculatedOn__c, SBQQ__LastSavedOn__c, SBQQ__Uncalculated__c FROM SBQQ__Quote__c WHERE Price_Request_Version__c = 1 LIMIT 1];
    //     Mulesoft_ContractEndpoint__c mc = [SELECT Id, Sent_to_SAP_Email_Template__c FROM Mulesoft_ContractEndpoint__c LIMIT 1];

    //     Test.startTest();
    //     // QuoteTrigger_Handler.sendEmailNotification(quote.Id,mc);
    //     QuoteProcessService.sendEmailNotifications(quote.Id,mc);
    //     Test.stopTest();

    // }

    // testMethod static void testQuoteProcessService() {
    //     SBQQ__Quote__c quote = [SELECT Id, SentToSAP__c, SBQQ__Status__c FROM SBQQ__Quote__c WHERE Price_Request_Version__c = 1 LIMIT 1];
    //     SBQQ__Quote__c quote2 = [SELECT Id, SentToSAP__c, SBQQ__Status__c FROM SBQQ__Quote__c WHERE Price_Request_Version__c = 1 AND SentToSAP__c = false LIMIT 1];
    //     Product2 product  = [SELECT Id FROM Product2 LIMIT 1];
    //     Account soldToAccount = [SELECT Id FROM Account WHERE Name = 'Sold To Account' LIMIT 1];
    //     Account parentAcc = [SELECT Id FROM Account WHERE Name = 'Sold To Account' LIMIT 1];

    //     Mulesoft_ContractEndpoint__c mc = [SELECT Id FROM Mulesoft_ContractEndpoint__c LIMIT 1];
        
    //     Test.startTest();
    //     SBQQ__QuoteLine__c testQuoteLine = new SBQQ__QuoteLine__c(
    //         SBQQ__Quote__c = quote2.Id,
    //         SBQQ__Product__c = product.Id,
    //         SBQQ__Quantity__c = 1,
    //         SBQQ__ListPrice__c = 10,
    //         SBQQ__NetPrice__c = 10,
    //         SBQQ__Number__c = 1,
    //         SBQQ__SubscriptionPricing__c = 'Fixed Price',
    //         Price_Request_Account__c = soldToAccount.Id,
    //         Product_Level__c = 'GMID'
            
    //     );
    //     insert testQuoteLine;

        
    //     quote.SBQQ__Status__c = 'Draft Contract';
    //     quote.SentToSAP__c = false;
    //     update quote;
        
    //     List<Id> listQuoteId = new List<Id>{quote.id};

    //     QuoteProcessService.updateQuoteandSubmit(listQuoteId);

    //     Test.setMock(HttpCalloutMock.class, new MuleSoftCalloutManager_MockTest());
        
    //     Test.stopTest();
    // }

    // @isTest static void testSubmitQuoteProcess() {
    //     SBQQ__Quote__c quote = [SELECT Id, SentToSAP__c, SBQQ__Status__c, ApprovalStatus__c FROM SBQQ__Quote__c WHERE Price_Request_Version__c = 1 LIMIT 1];
    //     Mulesoft_ContractEndpoint__c mc = [SELECT Id FROM Mulesoft_ContractEndpoint__c LIMIT 1];

    //     Test.startTest();

    //     Test.setMock(HttpCalloutMock.class, new MuleSoftCalloutManager_MockTest());

    //     QuoteProcessService.submitQuoteContract(quote.Id);
    //     Test.stopTest();
    // }

    testMethod static void testApprovalSubmit() {
        
        
        Test.startTest();
        SBQQ__Quote__c quote = [SELECT Id, SentToSAP__c, SBQQ__Status__c, ApprovalStatus__c, Cloned_From_Mulesoft__c,SubmitForApproval__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c = 'Quotation' AND ApprovalStatus__c = '' LIMIT 1];
        Product2 product  = [SELECT Id FROM Product2 LIMIT 1];

        Account soldToAccount = [SELECT Id FROM Account WHERE Name = 'Sold To Account' LIMIT 1];
        Mulesoft_ContractEndpoint__c mc = [SELECT Id FROM Mulesoft_ContractEndpoint__c LIMIT 1];

        SBQQ__QuoteLine__c testQuoteLine = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = quote.Id,
            SBQQ__Product__c = product.Id,
            SBQQ__Quantity__c = 1,
            SBQQ__ListPrice__c = 10,
            SBQQ__NetPrice__c = 10,
            SBQQ__Number__c = 1,
            SBQQ__SubscriptionPricing__c = 'Fixed Price',
            Price_Request_Account__c = soldToAccount.Id,
            Product_Level__c = 'GMID'
            
        );
        insert testQuoteLine;

        quote.Cloned_From_Mulesoft__c = true;
        quote.SubmitForApproval__c = true;

        update quote;

        Test.stopTest();
    }
    /*
    @isTest
    public static void validateAndSendApprovedQuotesToSAPTest(){
        //account
        Account parentAcc = new Account(
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Parent').getRecordTypeId(),
                Name = 'Parent Account',
                AccountNumber_R1__c = '267701',
                Ship_To__c = true,
                Sold_To__c = true
            );
        insert parentAcc;

        Account customerAcc = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
            Name = 'Second Ship To Account',
            AccountNumber_R1__c = '267702',
            Ship_To__c = true,
            ParentId = parentAcc.Id
        );
        insert customerAcc;

        //Opportunity
        Opportunity testOpportunity = new Opportunity(
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CAPV Commercial').getRecordTypeId(),
            Name = 'Test Opportunity',
            AccountId = customerAcc.Id,
            Type = 'Contract',
            CloseDate = date.newInstance(2019, 12, 31),
            StageName = 'Discovery/Qualification',
            CurrencyIsoCode = 'USD',
            Contract_Start_Date__c = date.newInstance(2019, 03, 01),
            Contract_End_Date__c = date.newInstance(2019, 12, 31)
        );
        insert testOpportunity;
        

        // creeate quote
        SBQQ__Quote__c testOriginalQuote = new SBQQ__Quote__c(
            RecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Draft Price Request').getRecordTypeId(),
            SBQQ__Primary__c = true,
            Price_Start_Date__c = date.newInstance(2019, 03, 01),
            SBQQ__Opportunity2__c = testOpportunity.Id,
            Ship_To_Any__c= true,
            SBQQ__Account__c = customerAcc.Id,
            SentToSAP__c = false,
            SBQQ__Status__c = 'Proposal'
        );
        insert testOriginalQuote;
        
        List<SBQQ__Quote__c> quoteList = [SELECT Id, Name, SentToSAP__c FROM SBQQ__Quote__c WHERE Id = : testOriginalQuote.Id];
        Test.startTest();
            QuoteTrigger_Handler.validateAndSendApprovedQuotesToSAP(quoteList);
        Test.stopTest();
    }
    */

}