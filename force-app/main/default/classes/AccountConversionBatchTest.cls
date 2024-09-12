@isTest
public class AccountConversionBatchTest {

    @isTest
    private static void testBatchClassWhenAccRecTypeIsCustomer() {

        RecordType customerAccRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Customer'];
        
        Account newCustomerAcc = new Account(
            Name = 'Test Customer Account',
            RecordTypeId = customerAccRecordType.Id,
            CurrencyIsoCode = 'USD',
            Region_R1__c = 'UNITED STATES',
            CustomerSubtype_R1__c = 'Standard'
        );

        insert newCustomerAcc;

        Test.startTest();
            Database.executeBatch(new AccountConversionBatch());
        Test.stopTest();

        Account testAcc = [SELECT Sold_To__c FROM Account WHERE Name = 'Test Customer Account' LIMIT 1];

        System.assert(testAcc.Sold_To__c);

    }

    @isTest
    private static void testBatchClassWhenAccRecTypeIsStandard() {
        
        List<RecordType> recordTypes = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Standard'];

        if(!recordTypes.isEmpty() && recordTypes.size() == 1) {
            
            RecordType standardRecordType = recordTypes.get(0);

            Account newCompetitorAcc = new Account(
                Name = 'Test Standard Account',
                RecordTypeId = standardRecordType.Id,
                CurrencyIsoCode = 'USD',
                Region_R1__c = 'UNITED STATES',
                Type = 'Customer',
                CustomerSubtype_R1__c = 'Standard',
                AccountNumber_R1__c = 'Test Account Number',
                AccountSource = 'Blue Cube'
            );
            
            insert newCompetitorAcc;

            System.debug(newCompetitorAcc);

            Test.startTest();
                Database.executeBatch(new AccountConversionBatch());
            Test.stopTest();

            RecordType customerAccRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Customer'];
            Account testAcc = [SELECT Sold_To__c, Pending_SAP_Customer__c, RecordTypeId FROM Account 
                                WHERE Name = 'Test Standard Account' LIMIT 1];

            System.assertEquals(customerAccRecordType.Id, testAcc.RecordTypeId);
            System.assert(testAcc.Sold_To__c);

        }
    }

    @isTest
    private static void testBatchClassWhenAccRecTypeIsCorporate() {
        
        List<RecordType> recordTypes = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Corporate'];

        if(!recordTypes.isEmpty() && recordTypes.size() == 1) {
            
            RecordType corporateRecordType = recordTypes.get(0);

            Account newCompetitorAcc = new Account(
                Name = 'Test Corporate Account',
                RecordTypeId = corporateRecordType.Id,
                CurrencyIsoCode = 'USD',
                Region_R1__c = 'UNITED STATES',
                Type = 'Customer',
                CustomerSubtype_R1__c = 'Standard'
            );
            
            insert newCompetitorAcc;

            System.debug(newCompetitorAcc);

            Test.startTest();
                Database.executeBatch(new AccountConversionBatch());
            Test.stopTest();

            RecordType olinCorpRecordType = [SELECT Id FROM RecordType WHERE Name = 'Olin Corp' AND sObjectType = 'Account' LIMIT 1];
            Account testAcc = [SELECT Sold_To__c, Pending_SAP_Customer__c, RecordTypeId FROM Account 
                                WHERE Name = 'Test Corporate Account' LIMIT 1];

            System.assertEquals(olinCorpRecordType.Id, testAcc.RecordTypeId);

        }
    }

    @isTest
    private static void testBatchClassWhenAccRecTypeIsPendingSAPCustomer() {
        
        List<RecordType> recordTypes = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Pending SAP Customer'];

        if(!recordTypes.isEmpty() && recordTypes.size() == 1) {
            
            RecordType pendingSAPCustomerRecordType = recordTypes.get(0);

            Account newCompetitorAcc = new Account(
                Name = 'Test Pending SAP Customer Account',
                RecordTypeId = pendingSAPCustomerRecordType.Id,
                CurrencyIsoCode = 'USD',
                BillingCountryCode = 'US',
                Area_R1__c = 'ASIA PACIFIC',
                Region_R1__c = 'ASIA SOUTHEAST',
                Type = 'Customer',
                CustomerSubtype_R1__c = 'Standard'
            );
            
            insert newCompetitorAcc;

            System.debug(newCompetitorAcc);

            Test.startTest();
                Database.executeBatch(new AccountConversionBatch());
            Test.stopTest();

            RecordType customerAccRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Customer'];
            Account testAcc = [SELECT Sold_To__c, Pending_SAP_Customer__c, RecordTypeId FROM Account 
                                WHERE Name = 'Test Pending SAP Customer Account' LIMIT 1];

            System.assert(testAcc.Sold_To__c);
            System.assert(testAcc.Pending_SAP_Customer__c);
            System.assertEquals(customerAccRecordType.Id, testAcc.RecordTypeId);

        }
    }
    
}