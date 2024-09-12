@isTest
public class CallReportOverrideNew_Test {
    static testMethod void test1(){
        Account acc = new Account(Name='Test',RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get('End User').getRecordTypeId());
        insert acc;
        
        Test.startTest();
        	String rec = CallReportOverrideNew.getRecordType(acc.Id);
        	System.assertEquals(rec,'End User');
        Test.stopTest();
    }
}