/*------------------------------------------------------------
Author:        Taurun Kaushik
Company:       Deloitte
Description:   Tests the controller helping in creating a contact for each new user
User Story:    -              
History
<Date>      <Authors Name>     <Brief Description of Change>
15.12.2017  Christian Conrad   Adjusted according to security review
06.11.2017  Taruan Kaushik     Initial version
------------------------------------------------------------*/

@isTest(SeeAllData = false)
public with sharing class FCM_UserHandler_Test {

    //This Method Validate the Active User and Contact Creation Process happens in parallel
    public static testMethod void ValidateActiveUserContactCreation() {

        // Create internal account
        Id BusinessAccRecTypeId = [SELECT id,Name,SObjectType FROM RecordType where SObjectType = 'Account' and Name = 'Corporate'].id;
        Account acc = new Account(Name = 'FastChem Cooperation', RecordTypeId = BusinessAccRecTypeId);
        insert acc;
        
        AccountName__c acctName = new AccountName__c();
        acctName.Name = 'FastChem Corp';
        acctName.OlinAccountValue__c = acc.id;
        insert acctName;

        // Create admin user
        Profile adminProfile = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator'];
        User u = new User(
            LastName = adminProfile.Name,
            FirstName = 'Testi',
            Email = adminProfile.Name.remove(' ') + '.' + 'Testi@fastchem.com.dev.test',
            Username = adminProfile.Name.remove(' ') + '.' + 'Testi@fastchem.com.dev.test',
            Alias = 't' + adminProfile.Name.right(7),
            CommunityNickname = 'test' + adminProfile.Name.right(7),
            ProfileId = adminProfile.Id,
            TimeZoneSidKey = 'America/Chicago',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            CurrencyIsoCode = 'USD');
        
        test.starttest();    
        insert u;
        test.stoptest();
        //System.runAs(u)
        //{
            
            // Check if a contact was created for the admin user
            List<contact> contactList = [select Id from Contact where UserId_R1__c = :u.Id];
            System.assertEquals(1, contactList.size());

            
        //}
    }
}