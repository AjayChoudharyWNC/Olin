@isTest
public class TeamTrigger_Test {
    static testMethod void userAccessValidation(){
        Account acc= new Account(Name='Test Account',type='Customer',AccountNumber_R1__c='123',AccountSource='Blue Cube');
        insert acc;
		User u = [SELECT Id FROM User WHERE Profile.Name != 'System Administrator' AND IsActive = True LIMIT 1];
        System.runAs(u){
            Team__c tem = new Team__c();
            tem.Account__c = acc.Id;
            tem.Team_Member__c = u.Id;
            tem.Team_Role__c = 'Account Manager';
            tem.Account_Access__c = 'Read/Write';
            tem.Opportunity_Access__c = 'Read/Write';
            tem.Case_Access__c = 'Read/Write';
            Test.startTest();
        	try{
            	insert tem;
            }
            catch(Exception e){}
            Test.stopTest();
        }
    }
    
    public static testmethod void positiveScenarion(){
        test.startTest();
        Account acc= new Account(Name='Test Account',type='Customer',AccountNumber_R1__c='123',AccountSource='Blue Cube');	
        insert acc;
        
        List<User> usr = [Select Id  from user where profile.Name =: 'CSR' AND IsActive =: true LIMIT 2  ];
        Team__c tem = new Team__c();
        tem.Account__c = acc.Id;
        tem.Team_Member__c = usr[1].Id;
        tem.Team_Role__c = 'Account Manager';
        tem.Account_Access__c = 'Read/Write';
        tem.Opportunity_Access__c = 'Read/Write';
        tem.Case_Access__c = 'Read/Write';
        insert tem;
        List<Team__c> temList  = new List<Team__c>();
        temList.add(tem);
        TeamTrigger_Handler.updateShareAccCallReport(temList);
        test.stopTest();
    }
    static testmethod void shareCallReportsRecords(){
        Account acc= new Account(Name='Test Account',type='Customer',AccountNumber_R1__c='123',AccountSource='Blue Cube');	
        insert acc;
        FCM_VisitReport__c visitReport1 = new FCM_VisitReport__c(
            FCM_Account__c = acc.Id,
            FCM_Status__c = 'Planned',
            FCM_VisitDate__c = Date.today(),
            Confidential__c = true
        );
        insert visitReport1;
        
        User usr = [Select Id  from user where profile.Name =: 'CSR' AND IsActive =: true LIMIT 1  ];
        
        Opportunity opp = new Opportunity();
        opp.Name = 'testOpp';
        opp.Confidential__c = false;
        opp.AccountId = acc.Id;
        opp.CloseDate = date.today();
        opp.CurrencyIsoCode = 'USD';
        opp.StageName = 'Qualification';
        insert opp;
        Case cs = new Case();
        cs.AccountId = acc.Id;
        cs.CurrencyIsoCode = 'USD';
        cs.Status = 'New';
        cs.Origin ='Email';
        insert cs;
        
        Team__c tem = new Team__c();
        tem.Account__c = acc.Id;
        tem.Team_Member__c = usr.Id;
        tem.Team_Role__c = 'Account Manager';
        tem.Account_Access__c = 'Read Only';
        tem.Opportunity_Access__c = 'Read Only';
        tem.Case_Access__c = 'Read Only';
        
        Test.startTest();
        insert tem;
        Test.stopTest();
    }
    static testmethod void shareCallReportsRecordsReadWrite(){
        Account acc= new Account(Name='Test Account',type='Customer',AccountNumber_R1__c='123',AccountSource='Blue Cube');	
        insert acc;
        FCM_VisitReport__c visitReport1 = new FCM_VisitReport__c(
            FCM_Account__c = acc.Id,
            FCM_Status__c = 'Planned',
            FCM_VisitDate__c = Date.today(),
            Confidential__c = true
        );
        insert visitReport1;
        
        User usr = [Select Id  from user where profile.Name =: 'CSR' AND IsActive =: true LIMIT 1  ];
        
        Opportunity opp = new Opportunity();
        opp.Name = 'testOpp';
        opp.Confidential__c = false;
        opp.AccountId = acc.Id;
        opp.CloseDate = date.today();
        opp.CurrencyIsoCode = 'USD';
        opp.StageName = 'Qualification';
        insert opp;
        Case cs = new Case();
        cs.AccountId = acc.Id;
        cs.CurrencyIsoCode = 'USD';
        cs.Status = 'New';
        cs.Origin ='Email';
        insert cs;
        
        Team__c tem = new Team__c();
        tem.Account__c = acc.Id;
        tem.Team_Member__c = usr.Id;
        tem.Team_Role__c = 'Account Manager';
        tem.Account_Access__c = 'Read/Write';
        tem.Opportunity_Access__c = 'Read/Write';
        tem.Case_Access__c = 'Read/Write';
        
        Test.startTest();
        insert tem;
        Test.stopTest();
    }
    static testmethod void shareCallReportsRecordsOnUpdFCM(){
        
        Account acc= new Account(Name='Test Account',type='Customer',AccountNumber_R1__c='123',AccountSource='Blue Cube');	
        insert acc;
        FCM_VisitReport__c visitReport1 = new FCM_VisitReport__c(
            FCM_Account__c = acc.Id,
            FCM_Status__c = 'Planned',
            FCM_VisitDate__c = Date.today(),
            Confidential__c = true
        );
        insert visitReport1;
        
        User usr = [Select Id  from user where profile.Name =: 'CSR' AND IsActive =: true LIMIT 1  ];
        
        Team__c tem = new Team__c();
        tem.Account__c = acc.Id;
        tem.Team_Member__c = usr.Id;
        tem.Team_Role__c = 'Account Manager';
        tem.Account_Access__c = 'Read Only';
        tem.Opportunity_Access__c = 'Read Only';
        tem.Case_Access__c = 'Read Only';
        insert tem;      
        
        tem.Account_Access__c = 'Read/Write';
        tem.Opportunity_Access__c = 'Read/Write';
        tem.Case_Access__c = 'Read/Write';
        Test.startTest();
        update tem;
        Test.stopTest();
    }
    static testmethod void shareCallReportsRecordsOnUpdFCM1(){
        
        Account acc= new Account(Name='Test Account',type='Customer',AccountNumber_R1__c='123',AccountSource='Blue Cube');	
        insert acc;
        FCM_VisitReport__c visitReport1 = new FCM_VisitReport__c(
            FCM_Account__c = acc.Id,
            FCM_Status__c = 'Planned',
            FCM_VisitDate__c = Date.today(),
            Confidential__c = true
        );
        insert visitReport1;
        
        User usr = [Select Id  from user where profile.Name =: 'CSR' AND IsActive =: true LIMIT 1  ];
        
        Team__c tem = new Team__c();
        tem.Account__c = acc.Id;
        tem.Team_Member__c = usr.Id;
        tem.Team_Role__c = 'Account Manager';
        tem.Account_Access__c = 'Read/Write';
        tem.Opportunity_Access__c = 'Read Only';
        tem.Case_Access__c = 'Read Only';
        insert tem;      
        
        tem.Account_Access__c = 'Read Only';
        tem.Opportunity_Access__c = 'Read/Write';
        tem.Case_Access__c = 'Read/Write';
        Test.startTest();
        update tem;
        Test.stopTest();
    }
    
    static testmethod void shareCallReportsRecordsOnUpd(){
        
        Account acc= new Account(Name='Test Account',type='Customer',AccountNumber_R1__c='123',AccountSource='Blue Cube');	
        insert acc;
        
        User usr = [Select Id  from user where profile.Name =: 'CSR' AND IsActive =: true LIMIT 1  ];
        
        Team__c tem = new Team__c();
        tem.Account__c = acc.Id;
        tem.Team_Member__c = usr.Id;
        tem.Team_Role__c = 'Account Manager';
        tem.Account_Access__c = 'Read Only';
        tem.Opportunity_Access__c = 'Read Only';
        tem.Case_Access__c = 'Read Only';
        insert tem;      
        
        
        Opportunity opp = new Opportunity();
        opp.Name = 'testOpp';
        opp.Confidential__c = false;
        opp.AccountId = acc.Id;
        opp.CloseDate = date.today();
        opp.CurrencyIsoCode = 'USD';
        opp.StageName = 'Qualification';
        insert opp;
        Case cs = new Case();
        cs.AccountId = acc.Id;
        cs.CurrencyIsoCode = 'USD';
        cs.Status = 'New';
        cs.Origin ='Email';
        insert cs;
        tem.Account_Access__c = 'Read/Write';
        tem.Opportunity_Access__c = 'Read/Write';
        tem.Case_Access__c = 'Read/Write';
        Test.startTest();
        update tem;
        Test.stopTest();
    }
    static testmethod void shareCallReportsRecordsOnUpdted(){
        
        Account acc= new Account(Name='Test Account',type='Customer',AccountNumber_R1__c='123',AccountSource='Blue Cube');	
        insert acc;
        
        User usr = [Select Id  from user where profile.Name =: 'CSR' AND IsActive =: true LIMIT 1  ];
        
        Team__c tem = new Team__c();
        tem.Account__c = acc.Id;
        tem.Team_Member__c = usr.Id;
        tem.Team_Role__c = 'Account Manager';
        tem.Account_Access__c = 'Read/Write';
        tem.Opportunity_Access__c = 'Read/Write';
        tem.Case_Access__c = 'Read/Write';
        insert tem;      
        
        Opportunity opp = new Opportunity();
        opp.Name = 'testOpp';
        opp.Confidential__c = false;
        opp.AccountId = acc.Id;
        opp.CloseDate = date.today();
        opp.CurrencyIsoCode = 'USD';
        opp.StageName = 'Qualification';
        insert opp;
        Case cs = new Case();
        cs.AccountId = acc.Id;
        cs.CurrencyIsoCode = 'USD';
        cs.Status = 'New';
        cs.Origin ='Email';
        insert cs;
        
        tem.Account_Access__c = 'Read Only';
        tem.Opportunity_Access__c = 'Read Only';
        tem.Case_Access__c = 'Read Only';
        Test.startTest();
        update tem;
        Test.stopTest();
    }
    static testmethod void shareCallReportsRecordsOnUpd1(){
        
        Account acc= new Account(Name='Test Account',type='Customer',AccountNumber_R1__c='123',AccountSource='Blue Cube');	
        insert acc;
        FCM_VisitReport__c visitReport1 = new FCM_VisitReport__c(
            FCM_Account__c = acc.Id,
            FCM_Status__c = 'Planned',
            FCM_VisitDate__c = Date.today(),
            Confidential__c = true
        );
        insert visitReport1;
        User usr = [Select Id  from user where profile.Name =: 'CSR' AND IsActive =: true LIMIT 1  ];
        
        Team__c tem = new Team__c();
        tem.Account__c = acc.Id;
        tem.Team_Member__c = usr.Id;
        tem.Team_Role__c = 'Account Manager';
        tem.Account_Access__c = 'Read Only';
        tem.Opportunity_Access__c = 'Read Only';
        tem.Case_Access__c = 'Read Only';
        
        insert tem;  
        
        Opportunity opp = new Opportunity();
        opp.Name = 'testOpp';
        opp.Confidential__c = false;
        opp.AccountId = acc.Id;
        opp.CloseDate = date.today();
        opp.CurrencyIsoCode = 'USD';
        opp.StageName = 'Qualification';
        insert opp;
        Case cs = new Case();
        cs.AccountId = acc.Id;
        cs.CurrencyIsoCode = 'USD';
        cs.Status = 'New';
        cs.Origin ='Email';
        insert cs; 
        
        tem.Account_Access__c = 'Removed';
        tem.Opportunity_Access__c = 'Removed';
        tem.Case_Access__c = 'Removed';
        Test.startTest();
        update tem;
        Test.stopTest();
    }
}