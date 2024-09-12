@isTest
public class CallReportAttendeeTrigger_Test {
    
     public static testmethod void testMethod1(){
        
        Id rcID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Account acct = new Account (name='test account',recordtypeid = rcID,AccountNumber_R1__c='1234567890',AccountSource='Blue Cube');
        insert acct;
        
        contact con = new contact();
        con.AccountId = acct.id;
        con.LastName = 'Test ' ;
        con.FirstName = 'Olin ';
        insert con ;
        
        FCM_VisitReport__c fcm = new FCM_VisitReport__c();
        fcm.FCM_Account__c = acct.id;
        fcm.FCM_Status__c = 'Planned';
        fcm.FCM_VisitDate__c = Date.today();
        insert fcm;
        
        List<String> attlist = new list <String>();
        FCM_VRAttendee__c attendee = new FCM_VRAttendee__c();
        attendee.FCM_VisitReport__c = fcm.Id; 
        attendee.FCM_Contact__c = con.id;
        insert attendee;
        delete attendee;
     }

}