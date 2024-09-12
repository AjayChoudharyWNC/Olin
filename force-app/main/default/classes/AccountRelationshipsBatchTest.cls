@isTest
public class AccountRelationshipsBatchTest {

    @TestSetup
    static void makeData() {

        RecordType accRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Prospect'];
        RecordType customerLocationRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Customer Location'];
        RecordType locRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'FCM_Address__c' AND DeveloperName = 'Prospect'];
        
        Account parentAccount = new Account(
            Name = 'Parent Account',
            RecordTypeId = accRecordType.Id,
            CurrencyIsoCode = 'USD',
            Type = 'Competitor',
            Region_R1__c = 'UNITED STATES',
            Sold_To__c = True
        );

        insert parentAccount;

        FCM_Address__c newLocation = new FCM_Address__c(
                Name = 'Test Location',
                CurrencyIsoCode = 'USD',
                RecordTypeId = locRecordType.Id,
                FCM_Street__c = 'Test Street',
                FCM_City__c = 'Test Street',
                FCM_StateProvince__c = 'IL',
                FCM_ZipPostalCode__c = '60439',
                FCM_Country__c = 'US',
                Name_2__c = 'Test Name 2',
                FCM_Account__c = parentAccount.Id,
                AccountGroup_R1__c = '1234',
                FCM_Inco_Term__c = '01C',
                LineofBusiness_R1__c = 'CAPV',
                FCM_Status__c = 'Active',
                ExternalDataSource_R1__c = 'Test External Source',
                FCM_ExternalId__c = 'Test SAP Id',
                SiteType_R1__c = 'Bleacher'
            );

        insert newLocation;

        Account locationAccount = new Account(
            Name = 'Test Location',
            RecordTypeId = customerLocationRecordType.Id,
            CurrencyIsoCode = 'USD',
            Type = 'Customer',
            Region_R1__c = 'UNITED STATES',
            Location_Record_ID__c = newLocation.Id
        );

        insert locationAccount;

    }

    @isTest
    public static void testBatch() {

        Test.startTest();
            Database.executeBatch(new AccountRelationshipsBatch());
        Test.stopTest();

        Account_Relationships__c newAccRelationships = [SELECT Id, Name FROM Account_Relationships__c LIMIT 1];

        System.assertEquals('Parent Account - Test Location', newAccRelationships.Name);

    } 

}