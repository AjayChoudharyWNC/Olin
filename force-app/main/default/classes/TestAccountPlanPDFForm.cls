@isTest
public class TestAccountPlanPDFForm {
    
    public static testMethod void method(){
        Account acc= new Account();
        acc.Name='test';
        acc.AccountNumber_R1__c='value';
        acc.AccountSource='Blue Cube';
        acc.CurrencyIsoCode='USD';
        acc.type='Customer';
        acc.Name='test';
        insert acc;
        
        Account_Plan__c accPlan= new Account_Plan__c();
        accPlan.Account__c=acc.Id;
        accPlan.Name='test1';
        accPlan.Planning_Year__c='2019';
        accPlan.Status__c='In Progress';
        insert accPlan;
        
        accPlan.Status__c='Approved';
        update accPlan;
        
        Test.startTest();
         HelperAccountPlanPDFForm.getBlob(accPlan.Id);
        Test.stopTest();        
    }
}