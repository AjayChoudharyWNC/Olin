@isTest
public class VRAttendeeEntry_Test {
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
        attlist.add(attendee.id);
        
        test.startTest();
        VRAttendeeEntry.getContactTypes();
        CallReport_NewCompetitive.fetchRelatedAccount(fcm.id);
        VRAttendeeEntry.searchContactRecords(fcm.id);
        VRAttendeeEntry.updateavailableList(con.id, fcm.id);
        VRAttendeeEntry.removeContacts(attendee.id);
        VRAttendeeEntry.CreateContact('test', 'test', 'test@mail.com','mr', '123456890', acct.id, fcm.id);
        VRAttendeeEntry.fetchContacts(fcm.id, '');
        VRAttendeeEntry.updatePrimaryField(attendee.id, fcm.id);
        VRAttendeeEntry.FetchAccountName(fcm.id);
        VRAttendeeEntry.fetchSearchContacts('test', 'test', 'test', 'Related to Account', 'test@mail.com', fcm.id);
        test.stopTest();
    }
}