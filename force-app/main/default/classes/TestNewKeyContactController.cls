@isTest
public class TestNewKeyContactController {
    static testMethod void Test1(){
        Account acc = new Account(Name='Test',AccountNumber_R1__c='test',AccountSource='Blue Cube');
        insert acc;
        Contact con = new Contact(LastName='Test',AccountId=acc.Id,Email='test@test.com');
        insert con;
        Account_Plan__c ap = new Account_Plan__c(Account__c=acc.Id);
        insert ap;
        Test.startTest();
        NewKeyContactController.saveRecords('test',ap.Id,con.Id,'test');
        Test.stopTest();
    }
}