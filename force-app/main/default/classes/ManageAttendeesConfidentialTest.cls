@isTest
public class ManageAttendeesConfidentialTest {
    
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
        
        List<String> attlist = new list <String>();
        Confidential_Call_Report_Attendee__c attendee = new Confidential_Call_Report_Attendee__c();
        attendee.Confidential_Call_Report__c = fcm.Id; 
        attendee.FCM_Contact__c = con.id;
        insert attendee;
        attlist.add(attendee.id);
        
        test.startTest();
        ManageAttendeesConfidential.getContactTypes();
        ManageAttendeesConfidential.searchContactRecords(fcm.id);
        ManageAttendeesConfidential.FetchAccountName(fcm.id);
        ManageAttendeesConfidential.updateavailableList(con.id, fcm.id);
        ManageAttendeesConfidential.removeContacts(attendee.id);
        ManageAttendeesConfidential.CreateContact('test', 'test', 'test@mail.com','mr', '123456890', acct.id, fcm.id);
        ManageAttendeesConfidential.fetchContacts(fcm.id, '');
        ManageAttendeesConfidential.updatePrimaryField(attendee.id, fcm.id);
        ManageAttendeesConfidential.fetchSearchContacts('test', 'test', 'test', 'Related to Account', 'test@mail.com', fcm.id);
        test.stopTest();
    }

}