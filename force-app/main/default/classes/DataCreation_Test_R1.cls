/**
*   Property of Olin. Do not distribute without permission.
*   Copyright (c) [2017] Olin, its affiliates and their licensors.
*   @author Mexico Team
*   @date   02/14/2018
*   @description     ME-00: Tests the DataCreation_R1
Modification Log:.
--------------------------------------------------------------------------------------------
Developer       Mod Number  Date    Description
--------------------------------------------------------------------------------------------
*/
@isTest
public class DataCreation_Test_R1 {
    
    @testSetup
    static void setup() {
        
        // Create internal account
        Id BusinessAccRecTypeId = [SELECT id,Name,SObjectType FROM RecordType where SObjectType = 'Account' and DeveloperName = 'Corporate'].id;
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
        System.runAs(userAdmin) {
            /*Creating new RecordType*/
            RecordType objRecordType_Client=[SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType='Account' And DeveloperName= 'Standard' limit 1];
            RecordType objRecordType_Customer=[SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType='Account' And DeveloperName= 'Customer' limit 1];
            RecordType objRecordType_Ctc=[SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType='Contact' And DeveloperName= 'Contacts' limit 1];
            Account acc = DataCreation_R1.createTestAccount(userAdmin, 'Olin Corporation Account', objRecordType_Customer);
            insert acc;
            Contact ctc = DataCreation_R1.createTestContact(acc, 'Smith',objRecordType_Ctc);
            insert ctc;
            FCM_VisitReport__c vrp = DataCreation_R1.createTestCallReport(acc);
            insert vrp;
        }
        
    }
    
    static testMethod void createTestAccount(){
        Test.startTest();
            RecordType objRecordType=[SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType='Account' And DeveloperName= 'Standard' limit 1];
            User ownerUser = [SELECT id FROM User Where email = 'contactAdminOlin@test.com' Limit 1];
            DataCreation_R1.createTestAccount(ownerUser, 'name',objRecordType);        
        Test.stopTest();
    }
    
    static testMethod void createTestContact(){
        Test.startTest();
            RecordType objRecordType =[SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType='Account' And DeveloperName= 'Standard' limit 1];
            Account objAccount = [SELECT id FROM Account Limit 1];
            DataCreation_R1.createTestContact(objAccount, 'LastName', objRecordType);
        Test.stopTest();
    }
    
    static testMethod void createTestCallReport(){
        Test.startTest();
            Account objAccount = [SELECT id FROM Account Limit 1];
            DataCreation_R1.createTestCallReport(objAccount);
        Test.stopTest();
    } 
    
    static testMethod void GenerateAccounts(){
        Test.startTest();
            DataCreation_R1 dataCreation = new DataCreation_R1();
            dataCreation.GenerateAccounts(10);
        Test.stopTest();
    } 
    
    static testMethod void GenerateCompetitors(){
        Test.startTest();
            Account objAccount = [SELECT id FROM Account Limit 1];
            DataCreation_R1 dataCreation = new DataCreation_R1();
            dataCreation.GenerateCompetitors(10, objAccount);
        Test.stopTest();
    } 
    
    static testMethod void GenerateContacts(){
        Test.startTest();
            RecordType objRecordType =[SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType='Account' And DeveloperName= 'Standard' limit 1];
            Account objAccount = [SELECT id FROM Account Limit 1];
            DataCreation_R1 dataCreation = new DataCreation_R1();
            dataCreation.GenerateContacts(15,'Prueba', objAccount, objRecordType);
        Test.stopTest();
    }
    
    static testMethod void GenerateProducts(){
        Test.startTest();
            RecordType objRecordType =[SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType='Account' And DeveloperName= 'Standard' limit 1];
            DataCreation_R1 dataCreation = new DataCreation_R1();
            dataCreation.GenerateProducts(10, objRecordType);
        Test.stopTest();
    } 
    
    static testMethod void GenerateCallReports(){
        Test.startTest();
            Account objAccount = [SELECT id FROM Account Limit 1];
            DataCreation_R1 dataCreation = new DataCreation_R1();
            dataCreation.GenerateCallReports(10, objAccount);
        Test.stopTest();
    } 
}