@isTest
public class AccountRelationshipTrigger_Test {
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
            ParentId = soldToAccount.Id
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

        teamMember = new AccountTeamMember(
            AccountId = lstShipToAccount[0].Id,
            UserId = lstTestUser[1].Id
        );
        lstTestAccountTeamMember.add(teamMember);
        insert lstTestAccountTeamMember;

        Test.startTest();
        try{
			delete lstTestAccountRelationship[0];
		} catch(Exception e){}
        Test.stopTest();
    }
}