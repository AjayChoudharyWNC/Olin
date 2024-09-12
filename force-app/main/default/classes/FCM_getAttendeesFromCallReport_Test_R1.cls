/**
*   Property of Olin. Do not distribute without permission.
*   Copyright (c) [2017] Olin, its affiliates and their licensors.
*   @author Team Mexico
*   @date   01/01/2018
*   @description     Testing class for FCM_getAttendeesFromCallReport.apxc
Modification Log:
--------------------------------------------------------------------------------------------
Developer       Mod Number  Date    Description
--------------------------------------------------------------------------------------------
Team Mexico     M-001   02/07/2018  Creation of this Test Class
*/

@isTest

public class FCM_getAttendeesFromCallReport_Test_R1 {
    
    @testSetup
    static void setup() {
        
        // Create internal account
        Id BusinessAccRecTypeId = [SELECT id,Name,SObjectType FROM RecordType where SObjectType = 'Account' and Name = 'Corporate'].id;
        Account acct = new Account(Name = 'FastChem Cooperation', RecordTypeId = BusinessAccRecTypeId);
        insert acct;
        
        AccountName__c acctName = new AccountName__c();
        acctName.Name = 'FastChem Corp';
        acctName.OlinAccountValue__c = acct.id;
        insert acctName;    
        
        Profile profileAdmin = [Select Id from Profile where name = 'System Administrator'];
        system.debug('::ID Profile::'+profileAdmin.id);
        
        User user_test= new User( ProfileId = profileAdmin.Id, Username = 'contactAdminOlin@test.com', Alias = 'Admin', Email = 'contactAdminOlin@test.com',
                                 EmailEncodingKey = 'UTF-8',Firstname = 'test',Lastname = 'user', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US',TimeZoneSidKey = 'America/Los_Angeles');
        insert user_test; 
        User userAdmin = [SELECT id FROM User Where email = 'contactAdminOlin@test.com' Limit 1]; 
        
        system.debug('::User::'+userAdmin.Id);
        System.runAs(userAdmin) {
            /*Creating new RecordType*/
            RecordType objRecordType_Client=[SELECT id,Name from RecordType where sobjecttype = 'Account' and DeveloperName = 'Customer' limit 1];
            RecordType objRecordType_Ctc=[SELECT id,Name from RecordType where sobjecttype = 'Contact' and DeveloperName = 'Contacts' limit 1];

            Account acc = DataCreation_R1.createTestAccount(userAdmin, 'Olin Corporation Account', objRecordType_Client);
            acc.AccountNumber_R1__c = '12345';
            acc.AccountSource = 'Blue Cube';
            insert acc;
            Contact ctc = DataCreation_R1.createTestContact(acc, 'Smith',objRecordType_Ctc);
            insert ctc;
            FCM_VisitReport__c vrp = DataCreation_R1.createTestCallReport(acc);
            insert vrp;
        }
    }
    
    static testMethod void FCM_getAttendeesFromCallReport(){
        Test.startTest();
            FCM_VisitReport__c vrp = [Select id,FCM_VisitReport__c.FCM_Account__r.Name from FCM_VisitReport__c LIMIT 1];
            PageReference pageRefInternal = Page.InternalPDF_VF;
    
            Test.setCurrentPage(pageRefInternal);
            pageRefInternal.getParameters().put('id',vrp.Id);
    
            ApexPages.StandardController sc = new ApexPages.StandardController(vrp);
            FCM_getAttendeesFromCallReport myclass = new FCM_getAttendeesFromCallReport(sc);
    
            PageReference pageRefExternal = Page.ExternalPDF_VF;
    
            Test.setCurrentPage(pageRefExternal);
            pageRefExternal.getParameters().put('id',vrp.Id);
    
            ApexPages.StandardController sc2 = new ApexPages.StandardController(vrp);
            FCM_getAttendeesFromCallReport myclass2 = new FCM_getAttendeesFromCallReport(sc2);
        Test.stopTest(); 

    }      
}