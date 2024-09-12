@isTest
public class AccountTrigger_Test {
    static testmethod void runtest(){
        Account acc= new Account(Name='Test Account',type='Customer',AccountNumber_R1__c='123',AccountSource='Blue Cube');  
        Test.startTest();
        insert acc;
        Test.stopTest();
    }
    static testmethod void runtestupd(){
        list<User> usr = [SELECT Id FROM User WHERE profile.Name = 'System Administrator' AND IsActive = true AND Id !=: UserInfo.getUserId() LIMIT 1];
        Account acc= new Account(Name='Test Account',type='Customer',AccountNumber_R1__c='123',AccountSource='Blue Cube');  
        insert acc;
        Team__c tem = new Team__c();
        tem.Account__c = acc.Id;
        tem.Team_Member__c = usr[0].Id;
        tem.Team_Role__c = 'Account Manager';
        tem.Account_Access__c = 'Read/Write';
        tem.Opportunity_Access__c = 'Read/Write';
        tem.Case_Access__c = 'Read/Write';
        insert tem;        
       
        //acc.OwnerId = usr[0].Id;
        acc.Description = 'testing';
        Test.startTest();
        update acc;
        Test.stopTest();
    }

    testMethod static void testApexSharing() {
        
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
        Account soldToAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
            Name = 'Sold To Account',
            AccountNumber_R1__c = '267687',
            Ship_To__c = true,
            Sold_To__c = true
        );
        insert soldToAccount;
        
        Account shipToAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
            Name = 'Ship To Account',
            AccountNumber_R1__c = '2676878',
            Ship_To__c = true,
            ParentId = soldToAccount.Id
        );
        insert shipToAccount;

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
            Ship_To__c = shipToAccount.Id
        );
        lstTestAccountRelationship.add(testAccountRel);
        insert lstTestAccountRelationship;

        // Create Account Team Members
        AccountTeamMember teamMember = new AccountTeamMember(
            AccountId = soldToAccount.Id,
            UserId = lstTestUser[0].Id
        );
        insert teamMember;

        // Update the Owner Id of the Ship To
        List<User> usr = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator' AND IsActive = true AND Id !=: UserInfo.getUserId() LIMIT 1];
        Test.startTest();
        System.runAs(new user(ID = UserInfo.getUserID())) {
            shipToAccount.OwnerId = usr[0].Id;
            update shipToAccount;
        }
        Test.stopTest();
    }
    testMethod static void priceZone() {
      /*  Price_Zones__c pz = new Price_Zones__c(CountryCode__c = 'US',State_Province_Code__c = 'AL', PriceZoneCode__c = 'z0012');
        insert pz;*/
        Account acc = new Account(Name='Test Account',type='Customer',AccountNumber_R1__c='123',AccountSource='Blue Cube');
        insert acc;
        Account acc1 = new Account(Name='Test Account34',type='Customer',AccountNumber_R1__c='1234',BillingCountryCode = 'US', BillingState = 'Alabama', BillingStateCode = 'AL', AccountSource='Blue Cube');
        insert acc1;
        acc.Name = 'test';
        Test.startTest();
        update acc;
        Test.stopTest();
    }
    testMethod static void priceZone1() {
       /* Price_Zones__c pz = new Price_Zones__c(CountryCode__c = 'US',State_Province_Code__c = 'AL', PriceZoneCode__c = 'z0012');
        insert pz;
        Price_Zones__c pz1 = new Price_Zones__c(CountryCode__c = 'TD',State_Province_Code__c = 'AL', PriceZoneCode__c = 'z0012');
        insert pz1;*/
        Account acc = new Account(Name='Test Account',type='Customer',AccountNumber_R1__c='123', BillingCountryCode = null, AccountSource='Blue Cube');
        insert acc;
        Account acc1 = new Account(Name='Test Account34',type='Customer',AccountNumber_R1__c='1234',BillingCountryCode = 'US', BillingState = 'Alabama', BillingStateCode = 'AL', AccountSource='Blue Cube');
        insert acc1;
        Account acc2 = new Account(Name='Test Account345',type='Customer',AccountNumber_R1__c='1235',BillingCountryCode = 'JP',BillingStateCode = '23', AccountSource='Blue Cube');
        insert acc2;
        Account acc3 = new Account(Name='Test Account3452',type='Customer',AccountNumber_R1__c='1236',BillingCountryCode = 'TD', AccountSource='Blue Cube');
        insert acc3;
        acc.Name = 'test';
        Test.startTest();
        update acc;
        Test.stopTest();
    }
}