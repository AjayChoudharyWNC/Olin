@isTest
class AccountPlanControllerTest {
    static testMethod void test() {
        Account acc= new Account();
        acc.Name='test';
        acc.AccountNumber_R1__c='value';
        acc.AccountSource='Blue Cube';
        acc.CurrencyIsoCode='USD';
        acc.type='Customer';
        insert acc;

        Account soldToAcc= new Account();
        soldToAcc.Name='test';
        soldToAcc.AccountNumber_R1__c='value';
        soldToAcc.AccountSource='Blue Cube';
        soldToAcc.CurrencyIsoCode='USD';
        soldToAcc.type='Customer';
        soldToAcc.CustomerSubtype_R1__c='Standard';
        soldToAcc.ParentId = acc.Id;
        insert soldToAcc;
        List<String> soldToAccList = new List<String>();
        soldToAccList.add(soldToAcc.Id);
        
        Account_Plan__c accPlan= new Account_Plan__c();
        accPlan.Account__c=acc.Id;
        accPlan.Name='test1';
        accPlan.Planning_Year__c='2019';
        accPlan.Status__c='In Progress';
        insert accPlan;
        
        Test.startTest();
        AccountPlanController.showAccSoldToRecord(acc.Id);
        AccountPlanController.saveRecords(soldToAccList,acc.Id);
        Test.stopTest();
    }
    static testMethod void test1() {
        Account acc= new Account();
        acc.Name='test';
        acc.AccountNumber_R1__c='value';
        acc.AccountSource='Blue Cube';
        acc.CurrencyIsoCode='USD';
        acc.type='Customer';
        insert acc;
        
        Account_Plan__c accPlan= new Account_Plan__c();
        accPlan.Account__c=acc.Id;
        accPlan.Name='test1';
        accPlan.Planning_Year__c='2019';
        accPlan.Status__c='In Progress';
        insert accPlan;
        
        Test.startTest();
        AccountPlanController.showAccSoldToRecord(acc.Id);
        Test.stopTest();
    }
}