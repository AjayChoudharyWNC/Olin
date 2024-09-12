@isTest
public class CustomerSetupNotificationTest {
    
    static testMethod void test1(){
        Account ac1 = new Account(Name='test account1',AccountNumber_R1__c='123', AccountSource='Olin Heritage');
        insert ac1;
        SAP_Onboarding__c sap = new SAP_Onboarding__c();
        sap.On_boarding_Request_Type__c = 'New Sold-To w/ Ship-to & Product';
        sap.Account__c = ac1.Id;
        sap.Ship_To_Account__c = ac1.Id;
        sap.Form_Due_Date__c = Date.today().addDays(5);
        sap.Send_Invitation_Email_to_Main_Contact__c = 'No';
        insert sap;
        SAP_Onboarding__c sapRecord = new SAP_Onboarding__c();
        List<Onboarding_Ship_To__c> shipToList = new List<Onboarding_Ship_To__c> ();
        CustomerSetupNotification cs = new CustomerSetupNotification();
        cs.sapRecordId = sap.Id;
        sapRecord = cs.sapRecord;
        shipToList = cs.shipToList; 
        
        CustomerSetupNotificationGCO csGCO = new CustomerSetupNotificationGCO();
        csGCO.sapRecordId = sap.Id;
        sapRecord = csGCO.sapRecord;
        shipToList = csGCO.shipToList;
        
        CustomerSetupNotificationOCAV csOCAV = new CustomerSetupNotificationOCAV();
        csOCAV.sapRecordId = sap.Id;
        sapRecord = csOCAV.sapRecord;
        shipToList = csOCAV.shipToList;
        
         CustomerSetupNotificationEPOXY csEpoxy = new CustomerSetupNotificationEPOXY();
        csEpoxy.sapRecordId = sap.Id;
        sapRecord = csEpoxy.sapRecord;
        shipToList = csEpoxy.shipToList;
       
    }
}