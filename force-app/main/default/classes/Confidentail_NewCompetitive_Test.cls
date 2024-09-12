@isTest
public class Confidentail_NewCompetitive_Test {
    public static testmethod void testMethod1(){
        
        Id rcID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Account acct = new Account (name='test account',recordtypeid = rcID,AccountNumber_R1__c='1234567890',AccountSource='Blue Cube');
        insert acct;
        
        contact con = new contact();
        con.AccountId = acct.id;
        con.LastName = 'Test ' ;
        con.FirstName = 'Olin ';
        insert con ;
        
        Confidential_Call_Report__c fcm = new Confidential_Call_Report__c();
        fcm.FCM_Account__c = acct.id;
        fcm.FCM_Status__c = 'Planned';
        fcm.FCM_VisitDate__c = Date.today();
        insert fcm;
        
        FCM_VisitReport__c fcmv = new FCM_VisitReport__c();
        fcmv.FCM_Account__c = acct.id;
        fcmv.FCM_Status__c = 'Planned';
        fcmv.FCM_VisitDate__c = Date.today();
        insert fcmv;
        
        List<String> attlist = new list <String>();
        Confidential_Call_Report_Attendee__c attendee = new Confidential_Call_Report_Attendee__c();
        CallReport_NewCompetitive.fetchRelatedAccount(fcmv.id);
        attendee.Confidential_Call_Report__c = fcm.Id; 
        attendee.FCM_Contact__c = con.id;
        insert attendee;
        attlist.add(attendee.id);
        
        test.startTest();
        Confidentail_NewCompetitive.fetchRelatedAccount(fcm.id);
    }
}