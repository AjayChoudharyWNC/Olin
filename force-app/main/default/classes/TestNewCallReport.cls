@isTest
public class TestNewCallReport {
    static testMethod void Test1(){
        Account acc = new Account(Name='Test',AccountNumber_R1__c='test',AccountSource='Blue Cube');
        insert acc;
        FCM_VisitReport__c vr = new FCM_VisitReport__c(FCM_Account__c=acc.Id,Call_Type__c='In Person',FCM_VisitDate__c=Date.today());
        insert vr;
        ApexPages.StandardController controller = new ApexPages.StandardController(vr);
        Test.startTest();
        	NewCallReport obj = new NewCallReport(controller);
        	obj.save();
        	obj.cancel();
        Test.stopTest();
    }
}