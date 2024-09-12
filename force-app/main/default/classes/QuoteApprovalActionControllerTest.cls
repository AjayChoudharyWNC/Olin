@isTest
private class QuoteApprovalActionControllerTest {
    
    @testSetup
    private static void setupTestData() {
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
            AccountNumber_R1__c = '267688',
            Ship_To__c = true,
            ParentId = soldToAccount.Id
        );
        accList.add(shipToAccount);

        Account shipToAccount2 = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
            Name = 'Second Ship To Account',
            AccountNumber_R1__c = '267689',
            Ship_To__c = true,
            ParentId = soldToAccount.Id
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
        /***
        // Standard PriceBook
        Id pricebookId = Test.getStandardPricebookId();
        
        // Create PricebookEntry
        PricebookEntry testPriceBook = new PricebookEntry( 
            Pricebook2Id = pricebookId,
            Product2Id = testProduct.id,
            CurrencyIsoCode = 'USD',
            IsActive = TRUE,
            UnitPrice = 100.0,
            UseStandardPrice = FALSE
        );
        insert testPriceBook;
        ***/
        
        // Standard PriceBook
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry testPriceBookEntry;
        system.debug('Test Pricebook: ' + pricebookId);
      
        list<PricebookEntry> priceBookTestUS = [select id from PricebookEntry where Product2Id = :testProduct.Id and Pricebook2Id = :pricebookId and CurrencyIsoCode = 'USD'];
        if(priceBookTestUS.size() == 1){
            testPriceBookEntry = priceBookTestUS[0];
        } else {
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
        system.debug('Test Pricebook Entry: ' + testPriceBookEntry);
        
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

        // Create Quote
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c(
            RecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Draft Price Request').getRecordTypeId(),
            SBQQ__Primary__c = true,
            Price_Start_Date__c = date.newInstance(2019, 03, 01),
            SBQQ__Opportunity2__c = testOpportunity.Id,
            Ship_To_Any__c= true,
            SBQQ__Account__c = soldToAccount.Id
        );
        insert testQuote;

        // Create Quote Line
        SBQQ__QuoteLine__c testQuoteLine = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = testQuote.Id,
            SBQQ__Product__c = testProduct.Id,
            SBQQ__Quantity__c = 1,
            SBQQ__ListPrice__c = 10,
            SBQQ__NetPrice__c = 10,
            SBQQ__Number__c = 1,
            SBQQ__SubscriptionPricing__c = 'Fixed Price',
            Price_Start_Date__c = date.newInstance(2019, 12, 31),
            Ship_To__c = shipToAccount.Id
        );
        insert testQuoteLine;
    }

    @isTest
    private static void testMassApprovalAction() {
        SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        Boolean result = false;
        Test.startTest();
            result = QuoteApprovalActionController.approveQuoteLine(quote.Id);
        Test.stopTest();

        System.assertEquals(true, result, 'Expected all lines to be approved');
    }

    
    @isTest
    static void getQuoteLineIdsTest(){
        SBQQ__Quoteline__c qLine = [SELECt Id, ApprovalStatus__c FROM SBQQ__Quoteline__c 
                                WHERE ApprovalStatus__c != 'Approved' LIMIT 1];
        Test.startTest();
        QuoteApprovalActionController.getQuoteLineIds(qLine.Id);
        Test.stopTest();
    }

    @isTest
    static void fieldsAndRecords(){
        Test.startTest();
        // QuoteApprovalActionController.getFieldsAndRecords('Account','CPQ_Lookup','AccountNumber_R1__c','267687');
        QuoteApprovalActionController.getFieldsAndRecords('SBQQ__Quoteline__c','CUPS_Information','Status__c','Won');
        Test.stopTest();
    }
}