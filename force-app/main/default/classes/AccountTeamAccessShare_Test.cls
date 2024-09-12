@isTest
public class AccountTeamAccessShare_Test {
    
    @testsetup
    public static void testData() {
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;
        Profile adminProfile = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', ProfileId = adminProfile.Id, 
                    TimeZoneSidKey='America/Los_Angeles', UserName='olin-test-123@testorg.com', 
                    UserRoleId = r.Id);
        insert u;
        
        // Create Users
        List<User> lstTestUser = new List<User>();
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
            CurrencyIsoCode = 'USD');
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
            CurrencyIsoCode = 'USD');
        lstTestUser.add(testUser);
        insert lstTestUser;
        
        system.runAs(u) {
            // Create internal account
            Account acc = new Account(Name = 'FastChem Cooperation', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Olin Corp').getRecordTypeId());
            insert acc;
            
            AccountName__c acctName = new AccountName__c();
            acctName.Name = 'FastChem Corp';
            acctName.OlinAccountValue__c = acc.id;
            insert acctName;
    
            // Create Account
            List<Account> lstSoldToAccount = new List<Account>();
            Account soldToAccount = new Account(
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
                Name = 'Sold To Account',
                AccountNumber_R1__c = '267687',
                Ship_To__c = true,
                Sold_To__c = true
            );
            lstSoldToAccount.add(soldToAccount);
    
            soldToAccount = new Account(
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
                Name = 'Test Sold To Account 2',
                AccountNumber_R1__c = '267689',
                Ship_To__c = true,
                Sold_To__c = true
            );
            lstSoldToAccount.add(soldToAccount);
            insert lstSoldToAccount;
                
            List<Account> lstShipToAccount = new List<Account>();
            Account shipToAccount = new Account(
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
                Name = 'Ship To Account',
                AccountNumber_R1__c = '267687',
                Ship_To__c = true,
                ParentId = lstSoldToAccount[0].Id
            );
            lstShipToAccount.add(shipToAccount);
    
            shipToAccount = new Account(
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
                Name = 'Test Ship To Account 2',
                AccountNumber_R1__c = '267688',
                Ship_To__c = true,
                ParentId = lstSoldToAccount[1].Id
            );
            lstShipToAccount.add(shipToAccount);
            insert lstShipToAccount;
    
            // Create Account Relationship
            List<Account_Relationships__c> lstTestAccountRelationship = new List<Account_Relationships__c>();
            Account_Relationships__c testAccountRel = new Account_Relationships__c(
                Name = 'Test Account Relationship',
                Sold_To__c = lstSoldToAccount[0].Id,
                Ship_To__c = lstShipToAccount[0].Id,
                Relationship_Type__c = 'Sold To / Ship To'
            );
            lstTestAccountRelationship.add(testAccountRel);
    
            testAccountRel = new Account_Relationships__c(
                Name = 'Test Account Relationship 2',
                Sold_To__c = lstSoldToAccount[1].Id,
                Ship_To__c = lstShipToAccount[1].Id,
                Relationship_Type__c = 'Sold To / Ship To'
            );
            lstTestAccountRelationship.add(testAccountRel);
            insert lstTestAccountRelationship;
    
            // Create Call Report
            List<FCM_VisitReport__c> lstTestCallReport = new List<FCM_VisitReport__c>();
            FCM_VisitReport__c callReport = new FCM_VisitReport__c(
                FCM_Account__c = lstSoldToAccount[0].Id
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
    
            // Create Opportunity
            Opportunity testOpportunity = new Opportunity(
                RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CAPV Commercial').getRecordTypeId(),
                Name = 'Test Opportunity',
                AccountId = lstShipToAccount[0].Id,
                Type = 'Contract',
                CloseDate = date.newInstance(2019, 12, 31),
                StageName = 'Discovery/Qualification',
                CurrencyIsoCode = 'USD',
                Contract_Start_Date__c = date.newInstance(2019, 03, 01),
                Contract_End_Date__c = date.newInstance(2019, 12, 31)
            );
            insert testOpportunity;
    
            // Create Opportunity Product
           /* List<OpportunityLineItem> lstTestOppProduct = new List<OpportunityLineItem>();
            OpportunityLineItem testOpportunityProduct = new OpportunityLineItem(
                OpportunityId = testOpportunity.Id,
                Product2Id = testProduct.Id,
                Ship_To__c = lstShipToAccount[1].Id,
                PricebookEntryId = testPriceBook.id,
                Quantity = 10,
                UnitPrice = 500
            );
            lstTestOppProduct.add(testOpportunityProduct);
            insert lstTestOppProduct;
            
            */
            // Create Quote
            SBQQ__Quote__c testQuote = new SBQQ__Quote__c(
                RecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Draft Price Request').getRecordTypeId(),
                SBQQ__Primary__c = true,
                Price_Start_Date__c = date.newInstance(2019, 03, 01),
                SBQQ__Opportunity2__c = testOpportunity.Id,
                Ship_To_Any__c= true,
                SBQQ__Account__c = lstSoldToAccount[0].Id
            );
            insert testQuote;
    
            // Create Quote Lines
            SBQQ__QuoteLine__c testQuoteLine = new SBQQ__QuoteLine__c(
                SBQQ__Quote__c = testQuote.Id,
                SBQQ__Product__c = testProduct.Id,
                SBQQ__Quantity__c = 1,
                SBQQ__ListPrice__c = 10,
                SBQQ__NetPrice__c = 10,
                SBQQ__Number__c = 1,
                SBQQ__SubscriptionPricing__c = 'Fixed Price',
                Price_Start_Date__c = date.newInstance(2019, 12, 31)
            );
            insert testQuoteLine;
    
            //Create Purchased Product
            PurchasedProduct_R1__c testPurchasedProduct = new PurchasedProduct_R1__c(
                Account_R1__c = lstSoldToAccount[0].Id,
                Ship_To__c = lstShipToAccount[0].Id,
                Product_R1__c = testProduct.Id
            );
            insert testPurchasedProduct;
    
            // Create Total Consumption
            Total_Consumption__c testTotalConsumption = new Total_Consumption__c(
                Purchased_Product__c = testPurchasedProduct.Id,
                Product__c = testProduct.Id,
                Year__c = '2018',
                Consumption__c = 250000
            );
            insert testTotalConsumption;
            
            
            // Create Account Team Members
            List<AccountTeamMember> lstTestAccountTeamMember = new List<AccountTeamMember>();
            AccountTeamMember teamMember = new AccountTeamMember(
                AccountId = lstSoldToAccount[0].Id,
                UserId = lstTestUser[0].Id
            );
            lstTestAccountTeamMember.add(teamMember);
    
            teamMember = new AccountTeamMember(
                AccountId = lstSoldToAccount[1].Id,
                UserId = lstTestUser[1].Id
            );
            lstTestAccountTeamMember.add(teamMember);
            
            insert lstTestAccountTeamMember;
            System.debug('>>> team member insert >>>' + lstTestAccountTeamMember);
            // Create Forecast
            
            
            Test.startTest();
            Forecast__c testForecast = new Forecast__c(
                Purchased_Product__c = testPurchasedProduct.Id, 
                CurrencyIsoCode = 'USD'
            );
            insert testForecast;
            update testForecast;
            Test.stopTest();
        }
    }
    
    
    
    testMethod static void testMethods() {
        Test.startTest();
        AccountTeamAccessShareBatch b = new AccountTeamAccessShareBatch();
        database.executebatch(b,100);
        Test.stopTest();
    }
}