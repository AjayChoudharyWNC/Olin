@isTest
public class OLINAppsController_Test {
    static testMethod void Test1(){
        Home_Page_Link__c obj = new Home_Page_Link__c();
        obj.Name = 'Test';
        obj.Order__c = 1;
        obj.Fixed_Link__c = True;
        obj.URL__c = 'https://google.com';
        insert obj;
        
        Test.startTest();
        OLINAppsController.getIntlAppLinks();
        Test.stopTest();
    }
}