@isTest
public class OpportunityProductTest {
    testMethod static void testInsert() {
        // Create Account
        Account acc = new Account(
            Name = 'FastChem Cooperation', 
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Olin Corp').getRecordTypeId()
            );
        insert acc;
        
        AccountName__c acctName = new AccountName__c();
            acctName.Name = 'FastChem Corp';
            acctName.OlinAccountValue__c = acc.id;
        insert acctName;

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
            AccountNumber_R1__c='123123',
            Ship_To__c = true,
            Sold_To__c = true
        );
        accList.add(soldToAccount) ;

        //Added Jimmy Daresta 8-24-2021
        Account shipToAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer Location').getRecordTypeId(),
            Name = 'Ship To Account',
            AccountNumber_R1__c = '267687',
            Ship_To__c = true,
            ParentId = parentAccount.Id
        );
        accList.add(shipToAccount);

                
        //Added 8-24-2021 Jimmy Daresta
        Account plant = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Olin Location').getRecordTypeId(),
            Name = 'Plant Account',
            AccountNumber_R1__c = '4343',
            Ship_From__c = true,
            ParentId = acc.Id
        );
        accList.add(plant);
        insert accList;        

        Account_Relationships__c testAccountRel = new Account_Relationships__c(
            Name = 'Test Account Relationship',
            Relationship_Type__c = 'Sold To / Ship To',
            Sold_To__c = soldToAccount.Id,
            Ship_To__c = shipToAccount.Id
        );
        insert testAccountRel; 

        // Create Product
        Product2 testProduct = new Product2(
            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
            Name = 'Test Product',
            ProductCode = '105001',
            Product_Level__c = 'GMID',
            IsActive = true
        );
        insert testProduct;

       //Added Jimmy Daresta for ship from plant list additions in handler 
       Ship_From_Plant_List__c testShipFromPlantList = new Ship_From_Plant_List__c(
           Name = 'Test Ship From Plant List',
           GMID_Product__c = testProduct.Id,
           Plant_Account__c = plant.id
       );
       insert testShipFromPlantList;
       
       
       
        // Standard PriceBook
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry testPriceBook;
       
        //Flow Product Create/Update adds for an inserted product the price book entries. So do a check and pull price book for standard US if it exists because of the flow
        //or insert a test one.
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
        PurchasedProduct_R1__c testPurchasedProduct = new PurchasedProduct_R1__c(
            Ship_To__c = shipToAccount.Id,
            Account_Relationship__c = testAccountRel.Id,
            Account_R1__c = soldToAccount.Id,
            Product_R1__c = testProduct.Id
        );
        insert testPurchasedProduct;

        // Create Opportunity 
        Opportunity testOpportunity = new Opportunity(
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CAPV Commercial').getRecordTypeId(),
            Name = 'Test Opportunity',
            Type = 'Contract',
            CloseDate = date.newInstance(2019, 03, 01),
            StageName = 'Proposal',
            CurrencyIsoCode = 'USD',
            AccountId = soldToAccount.Id,
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
            Ship_To_Any__c = true
        );
        insert testQuote;

        testOpportunity.SBQQ__PrimaryQuote__c = testQuote.Id;
        update testOpportunity;

        // Create Opportunity Product
        OpportunityLineItem testOpportunityProduct = new OpportunityLineItem(
            OpportunityId = testOpportunity.Id,
            Price_Request_Account__c = soldToAccount.Id,
            Product2Id = testProduct.Id,
            Ship_To__c = shipToAccount.Id,
            Ship_To_Account__c = testAccountRel.Id,
            Ship_From_Plant_List__c = testShipFromPlantList.Id,

            PricebookEntryId = testPriceBook.id,
            Quantity = 10,
            UnitPrice = 500
        );
        insert testOpportunityProduct;
        
    }

    testMethod static void testUpdate() {
        Account acc = new Account(
            Name = 'FastChem Cooperation', 
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Olin Corp').getRecordTypeId()
            );
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
            AccountNumber_R1__c='123123',
            Ship_To__c = true,
            Sold_To__c = true
        );
        accList.add(soldToAccount) ;

        //Added Jimmy Daresta 8-24-2021
        Account shipToAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
            Name = 'Ship To Account',
            AccountNumber_R1__c = '267687',
            Ship_To__c = true,
            ParentId = parentAccount.Id
        );
        accList.add(shipToAccount);

        
        //Added 8-24-2021 Jimmy Daresta
        Account plant = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Olin Location').getRecordTypeId(),
            Name = 'Plant Account',
            AccountNumber_R1__c = '4343',
            Ship_From__c = true,
            ParentId = acc.Id
        );
        accList.add(plant);   
        insert accList;

        Account_Relationships__c testAccountRel = new Account_Relationships__c(
            Name = 'Test Account Relationship',
            Relationship_Type__c = 'Sold To / Ship To',
            Sold_To__c = soldToAccount.Id,
            Ship_To__c = shipToAccount.Id
        );
        insert testAccountRel; 

        // Create Product
        Product2 testProduct = new Product2(
            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
            Name = 'Test Product',
            ProductCode = '105001',
            Product_Level__c = 'GMID',
            IsActive = true
        );
        insert testProduct;

       //Added Jimmy Daresta for ship from plant list additions in handler 
       Ship_From_Plant_List__c testShipFromPlantList = new Ship_From_Plant_List__c(
           Name = 'Test Ship From Plant List',
           GMID_Product__c = testProduct.Id,
           Plant_Account__c = plant.id
       );
       insert testShipFromPlantList;


        // Standard PriceBook
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry testPriceBook;

        //Flow Product Create/Update adds for an inserted product the price book entries. So do a check and pull price book for standard US if it exists because of the flow
        //or insert a test one.
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

		PurchasedProduct_R1__c testPurchasedProduct = new PurchasedProduct_R1__c(
            Ship_To__c = shipToAccount.Id,
            Account_Relationship__c = testAccountRel.Id,
            Account_R1__c = soldToAccount.Id,
            Product_R1__c = testProduct.Id
        );
        insert testPurchasedProduct;

        // Create Opportunity 
        Opportunity testOpportunity = new Opportunity(
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CAPV Commercial').getRecordTypeId(),
            Name = 'Test Opportunity',
            Type = 'Contract',
            CloseDate = date.newInstance(2019, 03, 01),
            StageName = 'Proposal',
            CurrencyIsoCode = 'USD',
            AccountId = soldToAccount.Id,
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
            Ship_To_Any__c = true
        );
        insert testQuote;

        testOpportunity.SBQQ__PrimaryQuote__c = testQuote.Id;
        update testOpportunity;
        /*
        PurchasedProduct_R1__c testPurchasedProduct = new PurchasedProduct_R1__c(
            Ship_To__c = testAccount.Id,
            Account_R1__c = testAccount.Id,
            Product_R1__c = testProduct.Id
        );
        insert testPurchasedProduct;

        Total_Consumption__c testTotalConsumption = new Total_Consumption__c(
            Purchased_Product__c = testPurchasedProduct.Id,
            Ship_To__c = testAccount.Id,
            Product__c = testProduct.Id,
            Year__c = string.valueOf(system.today().year()),
            Consumption__c = 250000
        );
        insert testTotalConsumption;*/

        // Create Opportunity Product
        OpportunityLineItem testOpportunityProduct = new OpportunityLineItem(
            OpportunityId = testOpportunity.Id,
            Price_Request_Account__c = soldToAccount.Id,
            Product2Id = testProduct.Id,
            Ship_To__c = shipToAccount.Id,
            Ship_To_Account__c = testAccountRel.Id,
            Ship_From_Plant_List__c = testShipFromPlantList.Id,

            PricebookEntryId = testPriceBook.id,
            Quantity = 10,
            UnitPrice = 500
        );
        insert testOpportunityProduct;
        
        List<OpportunityLineItem> oppLineList = [ SELECT Id, Opportunity.AccountId, OpportunityId, Opportunity.SBQQ__PrimaryQuote__c, 
                Opportunity.SBQQ__PrimaryQuote__r.SBQQ__Primary__c, Product2.Product_Level__c, Ship_To__c, Product2Id, Purchased_Product__c,
                Product2.PH1_Performance_Center__c, Ship_From_Plant_List__r.Plant_Account__c 
            FROM OpportunityLineItem ];
        test.startTest();
        OpportunityProductTriggerHandler.afterInsertUpdate(oppLineList, new Map<Id,OpportunityLineItem>(oppLineList), false);
        test.stopTest();
        
    }

    testMethod static void testApexSharing() {
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;
        
        // Create Users
        List<User> lstTestUser = new List<User>();
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
            UserRoleId = r.Id);
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
            UserRoleId = r.Id);
        lstTestUser.add(testUser);
        insert lstTestUser;
        
        system.runAs(lstTestUser[0]) {
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
                Name = 'Ship To Account',
                AccountNumber_R1__c = '2676871',
                Ship_To__c = true,
                ParentId = parentAccount.Id
            );
            accList.add(shipToAccount);
            
            Account shipToAccount2 = new Account(
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
                Name = 'Second Ship To Account',
                AccountNumber_R1__c = '2676872',
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
            /***
            testAccountRel = new Account_Relationships__c(
                Name = 'Test Account Relationship 2',
                Relationship_Type__c = 'Sold To / Ship To',
                Sold_To__c = soldToAccount.Id,
                Ship_To__c = shipToAccount.Id
            );
            lstTestAccountRelationship.add(testAccountRel);
            ***/
            insert lstTestAccountRelationship;
            
            // Create Account Team Members
            AccountTeamMember teamMember = new AccountTeamMember(
                AccountId = soldToAccount.Id,
                UserId = lstTestUser[0].Id
            );
            insert teamMember;
            
            // Create Call Report
            List<FCM_VisitReport__c> lstTestCallReport = new List<FCM_VisitReport__c>();
            FCM_VisitReport__c callReport = new FCM_VisitReport__c(
                FCM_Account__c = soldToAccount.Id
            );
            lstTestCallReport.add(callReport);
            insert lstTestCallReport;
            
            //Create Product
            Product2 testProduct = new Product2(
                RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
                Name = 'Test Product',
                TradeProduct_R1__c = '123456',
                Product_Level__c = 'GMID',
                IsActive = true
            );
            insert testProduct;
            
            // Standard PriceBook
            Id pricebookId = Test.getStandardPricebookId();
            PricebookEntry testPriceBook;
           
             //Flow Product Create/Update adds for an inserted product the price book entries. So do a check and pull price book for standard US if it exists because of the flow
            //or insert a test one.
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
           /* PurchasedProduct_R1__c testPurchasedProduct = new PurchasedProduct_R1__c(
                Ship_To__c = shipToAccount.Id,
                Account_R1__c = shipToAccount2.Id,
                Product_R1__c = testProduct.Id
            );
            insert testPurchasedProduct;*/
            
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
            
            // Create Opportunity Product
            OpportunityLineItem testOpportunityProduct = new OpportunityLineItem(
                OpportunityId = testOpportunity.Id,
                Product2Id = testProduct.Id,
                Ship_To__c = shipToAccount.Id,
                PricebookEntryId = testPriceBook.id,
                Quantity = 10,
                UnitPrice = 500
            );
            insert testOpportunityProduct;
            
            OpportunityLineItem testOpportunityProduct2 = new OpportunityLineItem(
                OpportunityId = testOpportunity.Id,
                Product2Id = testProduct.Id,
                Ship_To__c = shipToAccount.Id,
                PricebookEntryId = testPriceBook.id,
                Quantity = 10,
                UnitPrice = 500
            );
            insert testOpportunityProduct2;
        
            // Update the Ship To of the Opportunity Product
            Test.startTest();
            System.runAs(new user(ID = UserInfo.getUserID())) {
                testOpportunityProduct.Ship_To__c = shipToAccount2.Id;
                update testOpportunityProduct;
                
                //delete testOpportunityProduct2;
            }
            Test.stopTest();
        }
    }

    testMethod static void testDeleteApexSharing() {
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;
        
        // Create Users
        List<User> lstTestUser = new List<User>();
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
            UserRoleId = r.Id);
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
            UserRoleId = r.Id);
        lstTestUser.add(testUser);
        insert lstTestUser;
        
        system.runAs(lstTestUser[0]) {
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
                Name = 'Ship To Account',
                AccountNumber_R1__c = '2676871',
                Ship_To__c = true,
                ParentId = parentAccount.Id
            );
            accList.add(shipToAccount);
    
            Account shipToAccount2 = new Account(
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
                Name = 'Second Ship To Account',
                AccountNumber_R1__c = '2676872',
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
            /***    
            testAccountRel = new Account_Relationships__c(
                Name = 'Test Account Relationship 2',
                Relationship_Type__c = 'Sold To / Ship To',
                Sold_To__c = soldToAccount.Id,
                Ship_To__c = shipToAccount.Id
            );
            lstTestAccountRelationship.add(testAccountRel);
            ***/
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
                Product_Level__c = 'GMID',
                IsActive = true
            );
            insert testProduct;
    
            // Standard PriceBook
            Id pricebookId = Test.getStandardPricebookId();
            PricebookEntry testPriceBook;
           
             //Flow Product Create/Update adds for an inserted product the price book entries. So do a check and pull price book for standard US if it exists because of the flow
            //or insert a test one.
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
    
            // Create Opportunity Product
            OpportunityLineItem testOpportunityProduct = new OpportunityLineItem(
                OpportunityId = testOpportunity.Id,
                Product2Id = testProduct.Id,
                Ship_To__c = shipToAccount.Id,
                PricebookEntryId = testPriceBook.id,
                Quantity = 10,
                UnitPrice = 500
            );
            insert testOpportunityProduct;
    
            // Update the Ship To of the Opportunity Product
            Test.startTest();
            System.runAs(new user(ID = UserInfo.getUserID())) {
                delete testOpportunityProduct;
            }
            Test.stopTest();
        }
    }
}