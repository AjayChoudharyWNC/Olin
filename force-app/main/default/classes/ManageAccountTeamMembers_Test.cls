@isTest
public class ManageAccountTeamMembers_Test {
    testMethod static void testMethods() {         
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
        
        System.runAs(lstTestUser[0]){
            
            // Create internal account
            Account acc = new Account(Name = 'FastChem Cooperation', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Olin Corp').getRecordTypeId());
            insert acc;
            
            AccountName__c acctName = new AccountName__c();
            acctName.Name = 'FastChem Corp';
            acctName.OlinAccountValue__c = acc.id;
            insert acctName;

            // Create Account
               List<String> aclist = new  List<String>();

            Account parentAccount = new Account(
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Parent').getRecordTypeId(),
                Name = 'Parent Account',
                AccountNumber_R1__c = '176687434',
                Ship_To__c = false,
                Sold_To__c = false
            );
            insert parentAccount;
            aclist.add(parentAccount.id);
            

            Account soldToAccount = new Account(
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
                Name = 'Sold To Account',
                AccountNumber_R1__c = '267687',
                Ship_To__c = true,
                Sold_To__c = true,
                ParentId = parentAccount.Id
            );
            insert soldToAccount;
            aclist.add(soldToAccount.id);
            
            Account soldToAccount1 = new Account(
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
                Name = 'Sold To Account',
                AccountNumber_R1__c = '267465856687',
                Ship_To__c = true,
                Sold_To__c = true,
                ParentId = parentAccount.Id
            );
            insert soldToAccount1;
            
            
            List<Account> lstShipToAccount = new List<Account>();
            Account shipToAccount = new Account(
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
                Name = 'Ship To Account',
                AccountNumber_R1__c = '26785687',
                Ship_To__c = true
            );
            lstShipToAccount.add(shipToAccount);
            
            shipToAccount = new Account(
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
                Name = 'Test Ship To Account 2',
                AccountNumber_R1__c = '267688',
                Ship_To__c = true
            );
            lstShipToAccount.add(shipToAccount);
            insert lstShipToAccount;
            
            // Create Account Relationship
            List<Account_Relationships__c> lstTestAccountRelationship = new List<Account_Relationships__c>();
            Account_Relationships__c testAccountRel = new Account_Relationships__c(
                Name = 'Test Account Relationship',
                Sold_To__c = soldToAccount.Id,
                Ship_To__c = lstShipToAccount[0].Id,
                Relationship_Type__c = 'Sold To / Ship To'
            );
            lstTestAccountRelationship.add(testAccountRel);
            
            testAccountRel = new Account_Relationships__c(
                Name = 'Test Account Relationship 2',
                Sold_To__c = soldToAccount.Id,
                Ship_To__c = lstShipToAccount[1].Id,
                Relationship_Type__c = 'Sold To / Ship To'
            );
            lstTestAccountRelationship.add(testAccountRel);
            insert lstTestAccountRelationship;
            
            // Create Account Team Members
            List<AccountTeamMember> lstTestAccountTeamMember = new List<AccountTeamMember>();
            AccountTeamMember teamMember = new AccountTeamMember(
                AccountId = soldToAccount.Id,
                UserId = lstTestUser[0].Id
            );
            lstTestAccountTeamMember.add(teamMember);
            
            teamMember = new AccountTeamMember(
                AccountId = soldToAccount.Id,
                UserId = lstTestUser[1].Id
            );
            lstTestAccountTeamMember.add(teamMember);
            //insert lstTestAccountTeamMember;
            
            List<String> lstTeamMembers = new List<String>();
            for(AccountTeamMember member : lstTestAccountTeamMember) {
                lstTeamMembers.add(member.Id);
            }

            // Create Parent Account Team Members
            List<AccountTeamMember> lstTestParentAccountTeamMember = new List<AccountTeamMember>();
            AccountTeamMember parentTeamMember = new AccountTeamMember(
                AccountId = parentAccount.Id,
                UserId = lstTestUser[0].Id
            );
            lstTestParentAccountTeamMember.add(parentTeamMember );
            
            parentTeamMember = new AccountTeamMember(
                AccountId = parentAccount.Id,
                UserId = lstTestUser[1].Id
            );
            lstTestParentAccountTeamMember.add(parentTeamMember );
            //insert lstTestAccountTeamMember;
            
            List<String> lstParentTeamMembers = new List<String>();
            for(AccountTeamMember member : lstTestParentAccountTeamMember) {
                lstParentTeamMembers.add(member.Id);
            }

            
            ManageAccountTeamMembersController.getAccountTeamMembers(soldToAccount.Id);
            ManageAccountTeamMembersController.getUser(soldToAccount.Id);
            ManageAccountTeamMembersController.getPicklistValues();
            ManageAccountTeamMembersController.createAccountTeamMember(JSON.serialize(teamMember), soldToAccount.Id);
            ManageAccountTeamMembersController.saveAllItems(JSON.serialize(lstTestAccountTeamMember), soldToAccount.Id);
            ManageAccountTeamMembersController.deleteAccountTeamMember(lstTeamMembers, soldToAccount.Id);
            
            ManageAccountTeamMembersController.getAccountTeamMembers(parentAccount.Id);
            ManageAccountTeamMembersController.getUser(parentAccount.Id);
            ManageAccountTeamMembersController.createAccountTeamMember(JSON.serialize(parentTeamMember ), parentAccount.Id);
            ManageAccountTeamMembersController.saveAllItems(JSON.serialize(lstTestParentAccountTeamMember), parentAccount.Id);
            ManageAccountTeamMembersController.deleteAccountTeamMember(lstParentTeamMembers , parentAccount.Id);
            
            
            // Create Product
            Product2 testProduct = new Product2(
                RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
                Name = 'Test Product 1',
                ProductCode = '1050011',
                Product_Level__c = 'GMID',
                IsActive = True
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
                CloseDate = date.newInstance(2019, 03, 01),
                StageName = 'Proposal',
                CurrencyIsoCode = 'USD',
                AccountId = lstShipToAccount[1].Id
            );
            insert testOpportunity;
            
            
            OpportunityLineItem testOpportunityProduct = new OpportunityLineItem(
                OpportunityId = testOpportunity.Id,
                Product2Id = testProduct.Id,
                Ship_To__c = lstShipToAccount[1].Id,
                PricebookEntryId = testPriceBook.id,
                Quantity = 10,
                UnitPrice = 500
            );
            insert testOpportunityProduct;
            
            Olin_Contract_Database__c contract =  new Olin_Contract_Database__c();
            contract.Global_Customer__c = parentAccount.Id;
            contract.RecordTypeId = Schema.SObjectType.Olin_Contract_Database__c.getRecordTypeInfosByName().get('Sales Agreement').getRecordTypeId();
            contract.Line_of_Business__c = 'CAPV';
            insert contract;
            
            Test.startTest();
             insert new FCM_VisitReport__c(
                FCM_Account__c = soldToAccount.Id
            );
            ManageAccountTeamMembersController.ShareAccess(aclist);
            Test.stopTest();
        }
    }
    
    testMethod static void testDelete() {
        
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
        
        System.runAs(lstTestUser[0]){
            // Create internal account
            Account acc = new Account(Name = 'FastChem Cooperation', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Olin Corp').getRecordTypeId());
            insert acc;
            
            AccountName__c acctName = new AccountName__c();
            acctName.Name = 'FastChem Corp';
            acctName.OlinAccountValue__c = acc.id;
            insert acctName;
            
            // Create Account
            Account soldToAccount = new Account(
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
                Name = 'Sold To Account',
                AccountNumber_R1__c = '267687',
                Ship_To__c = true,
                Sold_To__c = true
            );
            insert soldToAccount;
            Account soldToAccount1 = new Account(
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
                Name = 'Sold To Account',
                AccountNumber_R1__c = '267465856687',
                Ship_To__c = true,
                Sold_To__c = true
            );
            insert soldToAccount1;
            List<Account> lstShipToAccount = new List<Account>();
            Account shipToAccount = new Account(
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
                Name = 'Ship To Account',
                AccountNumber_R1__c = '2676878',
                Ship_To__c = true,
                ParentId = soldToAccount.Id
            );
            lstShipToAccount.add(shipToAccount);
            
            shipToAccount = new Account(
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
                Name = 'Test Ship To Account 2',
                AccountNumber_R1__c = '267688',
                Ship_To__c = true,
                ParentId = soldToAccount1.Id
            );
            lstShipToAccount.add(shipToAccount);
            insert lstShipToAccount;
            
            // Create Account Relationship
            List<Account_Relationships__c> lstTestAccountRelationship = new List<Account_Relationships__c>();
            Account_Relationships__c testAccountRel = new Account_Relationships__c(
                Name = 'Test Account Relationship',
                Sold_To__c = soldToAccount.Id,
                Ship_To__c = lstShipToAccount[0].Id,
                Relationship_Type__c = 'Sold To / Ship To'
            );
            lstTestAccountRelationship.add(testAccountRel);
            
            testAccountRel = new Account_Relationships__c(
                Name = 'Test Account Relationship 2',
                Sold_To__c = soldToAccount.Id,
                Ship_To__c = lstShipToAccount[1].Id,
                Relationship_Type__c = 'Sold To / Ship To'
            );
            lstTestAccountRelationship.add(testAccountRel);
            insert lstTestAccountRelationship;
            
            
            // Create Account Team Members
            List<AccountTeamMember> lstTestAccountTeamMember = new List<AccountTeamMember>();
            AccountTeamMember teamMember = new AccountTeamMember(
                AccountId = soldToAccount.Id,
                UserId = lstTestUser[0].Id
            );
            lstTestAccountTeamMember.add(teamMember);
            
            teamMember = new AccountTeamMember(
                AccountId = soldToAccount.Id,
                UserId = lstTestUser[1].Id
            );
            lstTestAccountTeamMember.add(teamMember);
            insert lstTestAccountTeamMember;
            
            List<String> lstTeamMembers = new List<String>();
            for(AccountTeamMember member : lstTestAccountTeamMember) {
                lstTeamMembers.add(member.Id);
            }
            
            ManageAccountTeamMembersController.saveAllItems(JSON.serialize(lstTestAccountTeamMember), soldToAccount.Id);
            ManageAccountTeamMembersController.deleteAccountTeamMember(lstTeamMembers, soldToAccount.Id);
        }
    }
    
    testMethod static void testShare() {
        
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
        System.runAs(lstTestUser[0]){
            // Create internal account
            Account acc = new Account(Name = 'FastChem Cooperation', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Olin Corp').getRecordTypeId());
            insert acc;
            
            AccountName__c acctName = new AccountName__c();
            acctName.Name = 'FastChem Corp';
            acctName.OlinAccountValue__c = acc.id;
            insert acctName;
            
            // Create Account
            List<String> aclist = new  List<String>();
            Account soldToAccount = new Account(
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
                Name = 'Sold To Account',
                AccountNumber_R1__c = '26768784',
                Ship_To__c = true,
                Sold_To__c = true
            );
            insert soldToAccount;
            aclist.add(soldToAccount.id);
            Account soldToAccount1 = new Account(
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
                Name = 'Sold To Account',
                AccountNumber_R1__c = '267465856687',
                Ship_To__c = true,
                Sold_To__c = true
            );
            insert soldToAccount1;
           // insert aclist;
            
            List<Account> lstShipToAccount = new List<Account>();
            Account shipToAccount = new Account(
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
                Name = 'Ship To Account',
                AccountNumber_R1__c = '267687',
                Ship_To__c = true,
                ParentId = soldToAccount.Id
            );
            lstShipToAccount.add(shipToAccount);
            
            shipToAccount = new Account(
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
                Name = 'Test Ship To Account 2',
                AccountNumber_R1__c = '267688',
                Ship_To__c = true,
                ParentId = soldToAccount1.Id
            );
            lstShipToAccount.add(shipToAccount);
            insert lstShipToAccount;
            
            // Create Account Relationship
            List<Account_Relationships__c> lstTestAccountRelationship = new List<Account_Relationships__c>();
            Account_Relationships__c testAccountRel = new Account_Relationships__c(
                Name = 'Test Account Relationship',
                Sold_To__c = soldToAccount.Id,
                Ship_To__c = lstShipToAccount[0].Id,
                Relationship_Type__c = 'Sold To / Ship To'
            );
            lstTestAccountRelationship.add(testAccountRel);
            
            testAccountRel = new Account_Relationships__c(
                Name = 'Test Account Relationship 2',
                Sold_To__c = soldToAccount.Id,
                Ship_To__c = lstShipToAccount[1].Id,
                Relationship_Type__c = 'Sold To / Ship To'
            );
            lstTestAccountRelationship.add(testAccountRel);
            insert lstTestAccountRelationship;
            
            // Create Account Team Members
            List<AccountTeamMember> lstTestAccountTeamMember = new List<AccountTeamMember>();
            AccountTeamMember teamMember = new AccountTeamMember(
                AccountId = soldToAccount.Id,
                UserId = lstTestUser[0].Id
            );
            lstTestAccountTeamMember.add(teamMember);
            
            teamMember = new AccountTeamMember(
                AccountId = soldToAccount.Id,
                UserId = lstTestUser[1].Id
            );
            lstTestAccountTeamMember.add(teamMember);
            //insert lstTestAccountTeamMember;
            
            List<String> lstTeamMembers = new List<String>();
            for(AccountTeamMember member : lstTestAccountTeamMember) {
                lstTeamMembers.add(member.Id);
            }
            
            ManageAccountTeamMembersController.getAccountTeamMembers(soldToAccount.Id);
            ManageAccountTeamMembersController.getUser(soldToAccount.Id);
            ManageAccountTeamMembersController.getPicklistValues();
            //    ManageAccountTeamMembersController.createAccountTeamMember(JSON.serialize(teamMember), soldToAccount.Id);
            //    ManageAccountTeamMembersController.saveAllItems(JSON.serialize(lstTestAccountTeamMember), soldToAccount.Id);
            ManageAccountTeamMembersController.deleteAccountTeamMember(lstTeamMembers, soldToAccount.Id);
            // Create Product
            Product2 testProduct = new Product2(
                RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
                Name = 'Test Product 3',
                ProductCode = '1050001',
                Product_Level__c = 'GMID',
                IsActive = True
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
                CloseDate = date.newInstance(2019, 03, 01),
                StageName = 'Proposal',
                CurrencyIsoCode = 'USD',
                AccountId = lstShipToAccount[1].Id
            );
            insert testOpportunity;
            
            OpportunityLineItem testOpportunityProduct = new OpportunityLineItem(
                OpportunityId = testOpportunity.Id,
                Product2Id = testProduct.Id,
                Ship_To__c = lstShipToAccount[1].Id,
                PricebookEntryId = testPriceBook.id,
                Quantity = 10,
                UnitPrice = 500
            );
            insert testOpportunityProduct;
            
            // Create Quote
            SBQQ__Quote__c testQuote = new SBQQ__Quote__c(
                RecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Draft Price Request').getRecordTypeId(),
                SBQQ__Primary__c = true,
                Price_Start_Date__c = date.newInstance(2019, 03, 01),
                SBQQ__Opportunity2__c = testOpportunity.Id,
                Ship_To_Any__c = false,
                ApprovalStatus__c = 'Pending',
                SBQQ__LastCalculatedOn__c = system.today().AddDays(1), 
                SBQQ__Account__c = soldToAccount.Id
            );
            insert testQuote;
            
            testOpportunity.SBQQ__PrimaryQuote__c = testQuote.Id;
            update testOpportunity;
            Horizon_Year__c hz = new Horizon_Year__c();
            hz.Name = 'Default';
            hz.Year__c = System.today().year() + 1;
            insert hz;
            PurchasedProduct_R1__c testPurchasedProduct = new PurchasedProduct_R1__c(
                Ship_To__c = lstShipToAccount[1].Id,                
                Account_R1__c = soldToAccount.Id,
                Product_R1__c = testProduct.Id
            );
            insert testPurchasedProduct; 
            Forecast__c fc = new Forecast__c();
            fc.Purchased_Product__c = testPurchasedProduct.id;
            
            insert fc;
            Total_Consumption__c tc= new Total_Consumption__c();
            tc.Purchased_Product__c = testPurchasedProduct.id;
            insert tc;        
            Test.startTest();   
            insert new FCM_VisitReport__c(
                FCM_Account__c = soldToAccount.Id
            );
            ManageAccountTeamMembersController.ShareAccess(aclist);
            Test.stopTest();
        }   
    }
}