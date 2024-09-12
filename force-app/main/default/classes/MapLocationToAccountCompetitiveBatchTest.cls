@isTest
public class MapLocationToAccountCompetitiveBatchTest {
    
    @TestSetup
    static void makeData() {

        RecordType customerRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Customer'];
        RecordType competitorRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Competitor'];
        RecordType locRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'FCM_Address__c' AND DeveloperName = 'Competitor'];
        
        Product2 newProduct = new Product2(
            Name = 'Test Product',
            IsActive = true
        );

        insert newProduct;

        Account customerAccount = new Account(
            Name = 'Test Account',
            RecordTypeId = customerRecordType.Id,
            CurrencyIsoCode = 'USD',
            Region_R1__c = 'UNITED STATES'
        );

        insert customerAccount;

        Account competitorAccount = new Account(
            Name = 'Competitor Account',
            RecordTypeId = competitorRecordType.Id,
            CurrencyIsoCode = 'USD',
            Type = 'Competitor',
            Region_R1__c = 'UNITED STATES'
        );

        insert competitorAccount;

        Account competitorLocaton = new Account(
            Name = 'Competitor Location',
            RecordTypeId = competitorRecordType.Id,
            CurrencyIsoCode = 'USD',
            Type = 'Competitor',
            Region_R1__c = 'UNITED STATES'
        );

        insert competitorLocaton;

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
            FCM_Account__c = competitorAccount.Id,
            AccountGroup_R1__c = '1234',
            FCM_Inco_Term__c = '01C',
            LineofBusiness_R1__c = 'CAPV',
            FCM_Status__c = 'Active',
            ExternalDataSource_R1__c = 'Test External Source',
            FCM_ExternalId__c = 'Test SAP Id',
            SiteType_R1__c = 'Bleacher'
        );

        insert newLocation;

        competitorLocaton.Location_Record_ID__c = newLocation.Id;

        update competitorLocaton;

        Competitor_R1__c newCompetitive = new Competitor_R1__c(
            Customer_R1__c = customerAccount.Id, 
            Competitor_R1__c = competitorAccount.Id,
            Olin_Product__c = newProduct.Id,
            Price_R1__c = 10.000,
            VolumeofDeal_R1__c = 1,
            UnitofMeasure_R1__c = 'KG',
            OriginOfGoods_R1__c = newLocation.Id,
            CustomerLocation_R1__c = newLocation.Id,
            PriceDiscoveryMethod_R1__c = 'Customer Target'
        );

        insert newCompetitive;

    }

    @isTest
    private static void testBatchClass() {

        Test.startTest();
            Database.executeBatch(new MapLocationToAccountCompetitiveBatch());
        Test.stopTest();

        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Competitor Location' LIMIT 1];
        Competitor_R1__c testCompetitive = [SELECT Id, Competitor_Account_Location__c FROM Competitor_R1__c LIMIT 1];

        System.assertEquals(testAccount.Id, testCompetitive.Competitor_Account_Location__c);

    }

}