@isTest
public class OlinContractTriggerTest {
    
    static testMethod void test1(){
        Profile adminProfile = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
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
        
        insert testUser;
        
        Account ac1 = new Account(Name='test account1',AccountNumber_R1__c='123', AccountSource='Olin Heritage',RecordTypeId='012f4000000Wz2iAAC');
        insert ac1;
        AccountName__c acctName = new AccountName__c();
        acctName.Name = 'FastChem Corp';
        acctName.OlinAccountValue__c = ac1.id;
        insert acctName;
        AccountTeamMember teamMember = new AccountTeamMember(
            AccountId = ac1.Id,
            UserId = testUser.Id
        );
        insert teamMember;
        Olin_Contract_Database__c contract =  new Olin_Contract_Database__c();
        contract.Global_Customer__c = ac1.Id;
        contract.Line_of_Business__c = 'CAPV';
        contract.RecordTypeId = Schema.SObjectType.Olin_Contract_Database__c.getRecordTypeInfosByName().get('Sales Agreement').getRecordTypeId();
        insert contract;
    }
    
}