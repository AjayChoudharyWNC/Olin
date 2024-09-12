@isTest
public class TotalConsumptionTest {
    testMethod static void testMethods() {
        //Create Horizon Year
        Horizon_Year__c hz = new Horizon_Year__c();
        hz.Name = 'Default';
        hz.Year__c = System.today().year() + 1;
        insert hz;
        
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

        // Create Account
        Account testAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
            Name = 'Test Account',
            Ship_To__c = true,
            Sold_To__c = true
        );
        insert testAccount;

        Account shipToAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
            Name = 'Ship To Account',
            AccountNumber_R1__c = '267687',
            Ship_To__c = true,
            ParentId = testAccount.Id
        );
        insert shipToAccount;

        // Create Account Relationship
        List<Account_Relationships__c> lstTestAccountRelationship = new List<Account_Relationships__c>();
        Account_Relationships__c testAccountRel = new Account_Relationships__c(
            Name = 'Test Account Relationship',
            Sold_To__c = testAccount.Id,
            Ship_To__c = shipToAccount.Id,
            Relationship_Type__c = 'Sold To / Ship To'
        );
        lstTestAccountRelationship.add(testAccountRel);

        testAccountRel = new Account_Relationships__c(
            Name = 'Test Account Relationship 2',
            Sold_To__c = testAccount.Id,
            Ship_To__c = shipToAccount.Id,
            Relationship_Type__c = 'Sold To / Ship To'
        );
        lstTestAccountRelationship.add(testAccountRel);
        insert lstTestAccountRelationship;

        // Create Account Team Members
        List<AccountTeamMember> lstTestAccountTeamMember = new List<AccountTeamMember>();
        AccountTeamMember teamMember = new AccountTeamMember(
            AccountId = testAccount.Id,
            UserId = lstTestUser[0].Id
        );
        lstTestAccountTeamMember.add(teamMember);

        teamMember = new AccountTeamMember(
            AccountId = testAccount.Id,
            UserId = lstTestUser[1].Id
        );
        lstTestAccountTeamMember.add(teamMember);
        insert lstTestAccountTeamMember;

        //Create Product
        Product2 testProduct = new Product2(
            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
            Name = 'Test Product',
            Product_Level__c = 'GMID',
            IsActive = True
        );
        insert testProduct;

        //Create Purchased Product
        PurchasedProduct_R1__c testPurchasedProduct = new PurchasedProduct_R1__c(
            Account_R1__c = testAccount.Id,
            Product_R1__c = testProduct.Id,
            Ship_To__c = shipToAccount.Id
        );
        insert testPurchasedProduct;

        Integer currentYear = Date.today().year();
        //Create Total Consumption
        List<Total_Consumption__c> testTotalConsumptionList = new List<Total_Consumption__c>();
        Total_Consumption__c testTotalConsumption = new Total_Consumption__c(
            Purchased_Product__c = testPurchasedProduct.Id,
            Ship_To__c = testAccount.Id,
            Product__c = testProduct.Id,
            Year__c = String.valueOf(currentYear),
            Consumption__c = 250000,
            UnknownAmount__c = 15000,
            UnknownPercent__c = 10,
            UniqueId__c = testPurchasedProduct.Id + '' + currentYear + '' + System.now()
        );
        testTotalConsumptionList.add(testTotalConsumption);

        testTotalConsumption = new Total_Consumption__c(
            Purchased_Product__c = testPurchasedProduct.Id,
            Ship_To__c = testAccount.Id,
            Product__c = testProduct.Id,
            Year__c = String.valueOf(currentYear+1),
            Consumption__c = 150000,
            UnknownAmount__c = 15000,
            UnknownPercent__c = 10
        );
        testTotalConsumptionList.add(testTotalConsumption);
        insert testTotalConsumptionList;

        testTotalConsumptionList[0].Consumption__c = 250500;
        update testTotalConsumptionList;
    }

    testMethod static void testMethodForTestingSpecificMethods()
    {
        //Constructor
        TotalConsumptionTriggerHandler c = new TotalConsumptionTriggerHandler();
        TotalConsumptionTriggerHandler.runOnceBefore();
        TotalConsumptionTriggerHandler.runOnceAfter();
        TotalConsumptionTriggerHandler.runOnceBefore();
        TotalConsumptionTriggerHandler.runOnceAfter();
    }
}