@isTest
public class MapShipFromToPurchasedProductBatchTest {

    @TestSetup
    static void makeData(){

        RecordType accRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Corporate'];
        RecordType locRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'FCM_Address__c' AND DeveloperName = 'Plant'];
        
        // Create account 
        Account newAccount = new Account(
            Name = 'Test Account',
            RecordTypeId = accRecordType.Id,
            CurrencyIsoCode = 'USD',
            Type = 'Competitor',
            Region_R1__c = 'UNITED STATES'
        );

        insert newAccount;

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
            FCM_Account__c = newAccount.Id,
            AccountGroup_R1__c = '1234',
            FCM_Inco_Term__c = '01C',
            LineofBusiness_R1__c = 'CAPV',
            FCM_Status__c = 'Active',
            ExternalDataSource_R1__c = 'Test External Source',
            FCM_ExternalId__c = 'Test SAP Id',
            SiteType_R1__c = 'Bleacher'
        );

        insert newLocation;

        newAccount.Location_Record_ID__c = newLocation.Id;

        update newAccount;

        Product2 newProduct = new Product2(
            Name = 'Test Product',
            Product_Level__c = 'GMID'
        );

        insert newProduct;

        PurchasedProduct_R1__c newPurchasedProduct = new PurchasedProduct_R1__c(
            Product_R1__c = newProduct.Id,
            Account_R1__c = newAccount.Id,
            ShipFrom_R1__c = newLocation.Id,
            ShipTo_R1__c = newLocation.Id
        );

        insert newPurchasedProduct;

    }

    @isTest
    public static void testBatchClass() {

        Test.startTest();
            Database.executeBatch(new MapShipFromToPurchasedProductBatch());
        Test.stopTest();

        PurchasedProduct_R1__c newPurchasedProduct = [SELECT Ship_From__c, Ship_To__c FROM PurchasedProduct_R1__c LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE Name = 'Test Account' LIMIT 1];

        System.assertEquals(acc.Id, newPurchasedProduct.Ship_From__c);
        System.assertEquals(acc.Id, newPurchasedProduct.Ship_To__c);

    }
}