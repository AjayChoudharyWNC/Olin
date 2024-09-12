@isTest
public class OpportunityTrigger_Test {
    /*
    public static testmethod void  runTestOpp(){
        Account acc= new Account(Name='Test Account',type='Customer',AccountNumber_R1__c='123',AccountSource='Blue Cube');  
        insert acc;
        
        User usr = [Select Id  from user where profile.Name =: 'CSR' AND IsActive =: true LIMIT 1  ];
       
        Team__c tem = new Team__c();
        tem.Account__c =acc.id;
        tem.Team_Member__c = usr.Id;
        tem.Team_Role__c = 'Account Manager';
        tem.Account_Access__c = 'Read Only';
        tem.Opportunity_Access__c = 'Read Only';
        tem.Case_Access__c = 'Read Only';
        insert tem;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'testOpp';
        opp.Confidential__c = false;
        opp.AccountId = acc.Id;
        opp.CloseDate = date.today();
        opp.CurrencyIsoCode = 'USD';
        opp.StageName = 'Qualification';
        
        test.startTest();
        insert opp;
        test.stopTest();
        
    }
     public static testmethod void  runTestOpp1(){
        Account acc= new Account(Name='Test Account',type='Customer',AccountNumber_R1__c='123',AccountSource='Blue Cube');  
        insert acc;
        
        User usr = [Select Id  from user where profile.Name =: 'CSR' AND IsActive =: true LIMIT 1  ];
       
        Team__c tem = new Team__c();
        tem.Account__c =acc.id;
        tem.Team_Member__c = usr.Id;
        tem.Team_Role__c = 'Account Manager';
        tem.Account_Access__c = 'Read/Write';
        tem.Opportunity_Access__c = 'Read/Write';
        tem.Case_Access__c = 'Read/Write';
        insert tem;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'testOpp';
        opp.Confidential__c = false;
        opp.AccountId = acc.Id;
        opp.CloseDate = date.today();
        opp.CurrencyIsoCode = 'USD';
        opp.StageName = 'Qualification';
        
        test.startTest();
        insert opp;
        test.stopTest();
        
    }*/
    
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
            List<Account> acctList = new List<Account>();
            Account parentAcc = new Account(
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Parent').getRecordTypeId(),
                Name = 'Parent Account',
                AccountNumber_R1__c = '267690',
                Ship_To__c = true,
                Sold_To__c = true
            );

            acctList.add(parentAcc);

            Account soldToAccount = new Account(
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
                Name = 'Sold To Account',
                AccountNumber_R1__c = '267687',
                Ship_To__c = true,
                Sold_To__c = true
            );
            // insert soldToAccount;
            acctList.add(soldToAccount);
            
            Account shipToAccount = new Account(
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
                Name = 'Ship To Account',
                AccountNumber_R1__c = '267688',
                Ship_To__c = true,
                ParentId = parentAcc.Id
            );            
            // insert shipToAccount;
            acctList.add(shipToAccount);
            // List<Account> accList =[SELECT Name, Id FROM Account WHERE Name = 'Ship To Account'];
            // System.assert(!accList.isEmpty(), 'should not be empty');
    
            Account shipToAccount2 = new Account(
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
                Name = 'Second Ship To Account',
                AccountNumber_R1__c = '267689',
                Ship_To__c = true,
                ParentId = parentAcc.Id
            );
            // insert shipToAccount2;
            acctList.add(shipToAccount2);
    
            //Added Jimmy Daresta for ship from plant list additions in handler
            Account plant = new Account(
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Olin Location').getRecordTypeId(),
                Name = 'Plant Account',
                AccountNumber_R1__c = '4343',
                Ship_From__c = true,
                ParentId = acc.Id
            );
            // insert plant ;    
            acctList.add(plant);
            
            insert acctList;
    
    
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
                Product_Level__c = 'GMID'
            );
            insert testProduct;
    
           //Added Jimmy Daresta for ship from plant list additions in handler 
           Ship_From_Plant_List__c testShipFromPlantList = new Ship_From_Plant_List__c(
               Name = 'Test Ship From Plant List',
               GMID_Product__c = testProduct.Id,
               Plant_Account__c = plant.id
             );
             insert testShipFromPlantList;


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
                AccountId = soldToAccount.Id,
                Type = 'Contract',
                CloseDate = date.newInstance(2019, 12, 31),
                StageName = 'Discovery/Qualification',
                CurrencyIsoCode = 'USD',
                Contract_Start_Date__c = date.newInstance(2019, 03, 01),
                Contract_End_Date__c = date.newInstance(2019, 12, 31)
            );
            insert testOpportunity;
    
            // Create Opportunity Product
            List<OpportunityLineItem> lstTestOppProduct = new List<OpportunityLineItem>();
            OpportunityLineItem testOpportunityProduct = new OpportunityLineItem(
                OpportunityId = testOpportunity.Id,
                Price_Request_Account__c = soldToAccount.Id,
                Product2Id = testProduct.Id,
                Ship_To__c = shipToAccount.Id,
                Ship_To_Account__c = lstTestAccountRelationship[0].Id,
                Ship_From_Plant_List__c = testShipFromPlantList.Id,
                PricebookEntryId = testPriceBookEntry.id,
                Quantity = 10,
                UnitPrice = 500
            );
            lstTestOppProduct.add(testOpportunityProduct);
            insert lstTestOppProduct;
    
            // Update the Owner Id of the Opportunity
            List<User> usr = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true AND Id !=: UserInfo.getUserId() LIMIT 1];
            Test.startTest();
            System.runAs(new user(ID = UserInfo.getUserID())) {
                testOpportunity.OwnerId = usr[0].Id;
                update testOpportunity;
            }
            Test.stopTest();
        }
    }
    
    @isTest
    public static void testAmend(){
        List<OpportunityTrigger_Handler.AmendmentOpportunity> ammendOpp = new List<OpportunityTrigger_Handler.AmendmentOpportunity>();
        Account acc = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
            Name = 'test acc',
            AccountNumber_R1__c = '98765',
            AccountSource='Blue Cube'          
        );
        insert acc;
                
        Opportunity op = new Opportunity(
            AccountId = acc.Id,
            Name = 'test opp name',
            StageName = 'In-Progress',
            CloseDate = Date.newInstance(2024, 06, 10),
            Contract_Start_Date__c = Date.newInstance(2023, 06, 02),
            Contract_End_Date__c = Date.newInstance(2023, 06, 10),
            Has_Been_Amended__c = True,
            Amendment_Number__c = 98765432l
        );
        
        insert op;

        SBQQ__Quote__c priceReq = new SBQQ__Quote__c(
            SBQQ__Opportunity2__c = op.Id,
            SBQQ__Account__c = acc.Id,
            SBQQ__StartDate__c = Date.newInstance(2023, 06, 02),
            SBQQ__EndDate__c = op.CloseDate
            
        );
        insert priceReq;

        op.SBQQ__PrimaryQuote__c = priceReq.Id;

        update op;
               
        OpportunityTrigger_Handler.AmendmentOpportunity am = new OpportunityTrigger_Handler.AmendmentOpportunity();
            am.amendedOpp = op;
            am.agreementStartDate = Date.newInstance(2023, 06, 02);
            am.agreementEndDate = op.CloseDate;
            am.newPriceRequest = priceReq;
        
        ammendOpp.add(am);
         
        Test.startTest();
            OpportunityTrigger_Handler.amendOpportunity(ammendOpp);
        Test.stopTest();
        System.assert(ammendOpp.size() > 0, ammendOpp);
   
    }
}