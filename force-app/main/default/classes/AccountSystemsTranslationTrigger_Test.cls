@isTest
public class AccountSystemsTranslationTrigger_Test {
    TestMethod static void Meth1(){
        Account acc = new Account(Name = 'FastChem Cooperation', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Olin Corp').getRecordTypeId());
        insert acc;
        Account_Systems_Translation__c ast = new Account_Systems_Translation__c(Account__c = acc.id, Legacy_Account_Data_Source__c = 'OLINSAP', Legacy_Account_Id__c = '235363276');
        insert ast;
        Account_Systems_Translation__c ast1 = new Account_Systems_Translation__c(Account__c = acc.id, Legacy_Account_Data_Source__c = 'OLINSAP', Legacy_Account_Id__c = '235363223');
        insert ast1;
        delete ast;
    }
    TestMethod static void Meth2(){
        Account acc = new Account(Name = 'FastChem Cooperation', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Olin Corp').getRecordTypeId());
        insert acc;
        Account_Systems_Translation__c ast = new Account_Systems_Translation__c(Account__c = acc.id, Legacy_Account_Data_Source__c = 'OLINSAP', Legacy_Account_Id__c = '2353632');
        insert ast;
        delete ast;
    }
    TestMethod static void Meth3(){
        Account acc = new Account(Name = 'FastChem Cooperation', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Olin Corp').getRecordTypeId());
        insert acc;
        Account_Systems_Translation__c ast = new Account_Systems_Translation__c(Account__c = acc.id, Legacy_Account_Data_Source__c = 'OLINSAP', Legacy_Account_Id__c = '12345678911234567891123456789112345678911234567891');
        insert ast;
        Account_Systems_Translation__c ast1 = new Account_Systems_Translation__c(Account__c = acc.id, Legacy_Account_Data_Source__c = 'OLINSAP', Legacy_Account_Id__c = '23536322322353632232235363223223536322322353632232');
        insert ast1;
        Account_Systems_Translation__c ast2 = new Account_Systems_Translation__c(Account__c = acc.id, Legacy_Account_Data_Source__c = 'OLINSAP', Legacy_Account_Id__c = '12345678911234567891123456789112345678911234567892');
        insert ast2;
        Account_Systems_Translation__c ast3 = new Account_Systems_Translation__c(Account__c = acc.id, Legacy_Account_Data_Source__c = 'OLINSAP', Legacy_Account_Id__c = '23536322322353632232235363223223536322322353632233');
        insert ast3;
        Account_Systems_Translation__c ast4 = new Account_Systems_Translation__c(Account__c = acc.id, Legacy_Account_Data_Source__c = 'OLINSAP', Legacy_Account_Id__c = '12345678911234567891123456789112345678911234567899');
        insert ast4;
        Account_Systems_Translation__c ast5 = new Account_Systems_Translation__c(Account__c = acc.id, Legacy_Account_Data_Source__c = 'OLINSAP', Legacy_Account_Id__c = '23536322322353632232235363223223536322322353632236');
        insert ast5;
        ast5.Legacy_Account_Id__c = '87932732739273729';
        update ast5;
    }
}