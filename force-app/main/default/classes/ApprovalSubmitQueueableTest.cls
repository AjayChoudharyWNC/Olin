@isTest
public class ApprovalSubmitQueueableTest {

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
        Account soldToAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
            Name = 'Sold To Account',
            AccountNumber_R1__c = '267686',
            Ship_To__c = true,
            Sold_To__c = true
        );
        // insert soldToAccount;
        accList.add(soldToAccount);
        
        Account shipToAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
            Name = 'First Ship To Account',
            AccountNumber_R1__c = '267687',
            Ship_To__c = true,
            ParentId = soldToAccount.Id
        );
        // insert shipToAccount;
        accList.add(shipToAccount);
        
        Account shipToAccount2 = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
            Name = 'Second Ship To Account',
            AccountNumber_R1__c = '267688',
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
        
        // SBQQ__Quote__c testQuote = new SBQQ__Quote__c(
        //     RecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Draft Price Request').getRecordTypeId(),
        //     SBQQ__Primary__c = true,
        //     Price_Start_Date__c = date.newInstance(2019, 03, 01),
        //     SBQQ__Opportunity2__c = testOpportunity.Id,
        //     Ship_To_Any__c= true,
        //     SBQQ__Account__c = soldToAccount.Id,
        //     Original_Price_Request__c = testOriginalQuote.Id,
        //     SentToSAP__c = false,
        //     Price_Request_Version__c = 10,
        //     SBQQ__Status__c = 'Proposal'
        // );
        // insert testQuote;        
        
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
        
        SBQQ__QuoteLine__c testQuoteLine= new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = testQuote1.Id,
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

    @isTest static void testSubmit(){
        SBQQ__Quote__c quote = [SELECT Id, SentToSAP__c, SBQQ__Status__c, ApprovalStatus__c FROM SBQQ__Quote__c WHERE Price_Request_Version__c = 1 LIMIT 1];
        //SBQQ__QuoteLine__c quoteline = [SELECT Id, SentToSAP__c, ApprovalStatus__c, SBQQ__Quote__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c =: quote.Id LIMIT 1];
        Profile integProfile = [SELECT Id, Name FROM Profile WHERE Name = 'Integration User'];
        UserRole ur = [SELECT Name FROM UserRole LIMIT 1];
        User u = new User(
            LastName = integProfile.Name,
            FirstName = 'Test3',
            Email = integProfile.Name.remove(' ') + '.' + 'Test3@fastchem.com.dev.test',
            Username = integProfile.Name.remove(' ') + '.' + 'Test3@fastchem.com.dev.test',
            Alias = 'testusr3',
            CommunityNickname = 'test3' + integProfile.Name.right(7),
            ProfileId = integProfile.Id,
            TimeZoneSidKey = 'America/Chicago',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            CurrencyIsoCode = 'USD',
            UserRoleId= ur.Id);
        insert u;

        List<Id> listQuoteIds = new List<Id>{quote.id};
        //Set<Id> listQuoteLineIds = new Set<Id>{quoteline.id};
        Set<Id> setQuoteLineIds = new Set<Id>{quote.id};


        Test.startTest();
        System.runAs(u){
            ApprovalSubmitQueueable asq = new ApprovalSubmitQueueable(listQuoteIds);
            ApprovalSubmitQueueable asq2 = new ApprovalSubmitQueueable(setQuoteLineIds);

            System.enqueueJob(asq);
            System.enqueueJob(asq2);

        }
        Test.stopTest();
    }
}