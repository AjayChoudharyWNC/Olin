@isTest
public class LeadTrigger_Test {
    static testMethod void Test1(){
        Campaign camp = new Campaign();
        camp.Name = 'Test';
        camp.Status = 'In Progress';
        insert camp;
        
        Campaign camp1 = new Campaign();
        camp1.Name = 'Test';
        camp1.Status = 'In Progress';
        insert camp1;
        
        Lead l = new Lead(Campaign__c=camp.Id,LastName='Test',Company='Test');
        Test.startTest();
        insert l;
        l.Campaign__c = camp1.Id;
        update l;
        l.Campaign__c=null;
        update l;
        Test.stopTest();
    }
}