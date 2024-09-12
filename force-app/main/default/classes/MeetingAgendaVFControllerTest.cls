@isTest
public class MeetingAgendaVFControllerTest {
    public static testMethod void testCall(){
        Test.startTest();
        Account acc= new Account();
        acc.Name='test';
        acc.AccountNumber_R1__c='value';
        acc.AccountSource='Blue Cube';
        acc.CurrencyIsoCode='USD';
        acc.type='Customer';
        acc.Name='test';
        insert acc;
        
        Account soldToAcc= new Account();
        soldToAcc.Name='test';
        soldToAcc.AccountNumber_R1__c='value';
        soldToAcc.AccountSource='Blue Cube';
        soldToAcc.CurrencyIsoCode='USD';
        soldToAcc.type='Customer';
        soldToAcc.Name='test';
        soldToAcc.CustomerSubtype_R1__c='Standard';
        soldToAcc.ParentId = acc.Id;
        insert soldToAcc;
        
        Account soldToAcc1 = new Account();
        soldToAcc1.Name='test';
        soldToAcc1.AccountNumber_R1__c='value';
        soldToAcc1.AccountSource='Blue Cube';
        soldToAcc1.CurrencyIsoCode='USD';
        soldToAcc1.type='Customer';
        soldToAcc1.Name='test';
        soldToAcc1.CustomerSubtype_R1__c='Standard';
        soldToAcc1.ParentId = acc.Id;
        insert soldToAcc1;
        
        Account_Plan__c accPlan = new Account_Plan__c();
        accPlan.Account__c = acc.Id;
        accPlan.Name='test1';
        accPlan.Planning_Year__c = '2019';
        accPlan.Status__c = 'In Progress';
        insert accPlan;
        
        Meeting_Agenda__c meetingAgenda = new Meeting_Agenda__c(Account_Plan__c = accPlan.Id, Meeting_Date__c = system.today(), Topics_to_Avoid__c = 'Test', Topics_to_Discuss__c = 'Test', Type__c = 'EPCA' );
        insert  meetingAgenda;
        
        PageReference pref = Page.MeetingAgendaVF;
        pref.getParameters().put('id', meetingAgenda.id);
        Test.setCurrentPage(pref);
        ApexPages.StandardController sc = new ApexPages.StandardController(meetingAgenda);
        MeetingAgendaVFController ma = new MeetingAgendaVFController(sc);
        ma.init();
        Test.stopTest();
    }    
}