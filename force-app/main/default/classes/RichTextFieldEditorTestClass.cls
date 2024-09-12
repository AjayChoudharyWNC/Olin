@isTest
public class RichTextFieldEditorTestClass {
    public testmethod static void testmethod1()
    {
        Account acc= new Account();
        acc.Name = 'test';
        acc.AccountNumber_R1__c ='123456789';
        acc.AccountSource = 'S4';
        Insert acc;
        test.startTest();
        RichTextFieldEditorClass.FetchType(acc.Id, 'CSR_Notes__c');
        test.stopTest();
    }
    
}