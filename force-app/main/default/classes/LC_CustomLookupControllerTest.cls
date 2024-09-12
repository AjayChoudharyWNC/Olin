@isTest
public class LC_CustomLookupControllerTest {
    
    @TestSetup
    private static void setup() {
        
        RecordType accRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Competitor'];
        
        Account newAccount = new Account(
            Name = 'Test Account',
            RecordTypeId = accRecordType.Id,
            CurrencyIsoCode = 'USD',
            Type = 'Competitor',
            Region_R1__c = 'UNITED STATES'
        );
        
        insert newAccount;
    }
    
    @isTest
    private static void testFetchLookUpValuesMethod() {
        
        Test.startTest();
        	List<sObject> lookupResults = LC_CustomLookupController.fetchLookUpValues('Test Account', 'Account', 'Type = \'Competitor\'');
        Test.stopTest();
        
        System.assert(!lookupResults.isEmpty());
        
    }
    
}