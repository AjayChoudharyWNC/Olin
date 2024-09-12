@isTest
public class CaseTrigger_Test {
    public static testmethod void runTest(){
        Account acc= new Account(Name='Test Account',type='Customer',AccountNumber_R1__c='123',AccountSource='Blue Cube');	
        insert acc;
        
        User usr = [Select Id  from user where profile.Name =: 'CSR' AND IsActive =: true LIMIT 1  ];
       
        Team__c tem = new Team__c();
        tem.Account__c =acc.id;
        tem.Team_Member__c = usr.Id;
        tem.Team_Role__c = 'Account Manager';
        tem.Account_Access__c = 'Read Only';
        tem.Opportunity_Access__c = 'Read Only';
        tem.Case_Access__c = 'Read Only';
        insert tem;
        
        Case cs = new Case();
        cs.AccountId = acc.Id;
        cs.CurrencyIsoCode = 'USD';
        cs.Status = 'New';
        cs.Origin ='Email';
        
        test.startTest();
        insert cs;
        test.stopTest();
        
    }
    public static testmethod void runTest1(){
        Account acc= new Account(Name='Test Account',type='Customer',AccountNumber_R1__c='123',AccountSource='Blue Cube');	
        insert acc;
        
        User usr = [Select Id  from user where profile.Name =: 'CSR' AND IsActive =: true LIMIT 1  ];
       
        Team__c tem = new Team__c();
        tem.Account__c =acc.id;
        tem.Team_Member__c = usr.Id;
        tem.Team_Role__c = 'Account Manager';
        tem.Account_Access__c = 'Read/Write';
        tem.Opportunity_Access__c = 'Read/Write';
        tem.Case_Access__c = 'Read/Write';
        insert tem;
        
        Case cs = new Case();
        cs.AccountId = acc.Id;
        cs.CurrencyIsoCode = 'USD';
        cs.Status = 'New';
        cs.Origin ='Email';
        
        test.startTest();
        insert cs;
        test.stopTest();
        
    }
}