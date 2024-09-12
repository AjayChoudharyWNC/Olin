@isTest
public class LocationToAccountBatchTest {
    
    @TestSetup
    static void makeData(){

        List<RecordType> accRecordTypes = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Account' 
            AND (Name = 'Competitor' OR Name = 'Standard' OR Name = 'Customer' OR Name = 'Corporate' )];
        
        List<Account> testAccs = new List<Account>();
		for(RecordType accRecordType : accRecordTypes) {

            Account newAccount = new Account(
                Name = 'Test ' + accRecordType.Name + ' Account',
                RecordTypeId = accRecordType.Id,
                CurrencyIsoCode = 'USD',
                Type = 'Customer',
                Region_R1__c = 'UNITED STATES',
                AccountNumber_R1__c = 'Test Account Number',
                AccountSource = 'Blue Cube'
            );

            testAccs.add(newAccount);

        }

        insert testAccs;
        
        Location_Migration_Filter__c dateFilter = new Location_Migration_Filter__c(
            Name = 'Created Date Range Filter',
            Start_Date__c = Date.parse('4/11/2018'),
            End_Date__c = Date.today() +1
        );

        insert dateFilter;
        
    }

    @isTest
    private static void testBatchClass() {

        RecordType locRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'FCM_Address__c' AND DeveloperName = 'Prospect'];
        Account newAccount = [SELECT Id FROM Account WHERE RecordType.Name = 'Customer' LIMIT 1];

        Map<String, List<String>> mapOfCountryAndStateCodes = new Map<String, List<String>>{'US' => new List<String>{'IL'}}; 

        String name = 'Test Location';
        
        FCM_Address__c newLocation = new FCM_Address__c(
            Name = name,
            CurrencyIsoCode = 'USD',
            RecordTypeId = locRecordType.Id,
            FCM_Street__c = 'Test Street',
            FCM_City__c = 'Test City',
            FCM_StateProvince__c = 'IL',
            FCM_ZipPostalCode__c = '72761',
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
        
        Test.startTest();
            Database.executeBatch(new LocationToAccountBatch(new Map<String, List<String>>(), mapOfCountryAndStateCodes));
        Test.stopTest();
        
        List<Account> newlyCreatedAcc = [SELECT Id, Location_Record_ID__c, Region_R1__c, RecordType.Name FROM Account WHERE Name = :name];

        System.assertEquals(1, newlyCreatedAcc.size());
        System.assertEquals(newLocation.Id, newlyCreatedAcc[0].Location_Record_ID__c);
        /*
        System.assertEquals('Competitor Location', newlyCreatedAcc[0].RecordType.Name);
        System.assertEquals('UNITED STATES', newlyCreatedAcc[0].Region_R1__c);
		*/
    }
    

    @isTest
    private static void testBulkBatchClass() {

        List<RecordType> locRecordTypes = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'FCM_Address__c' AND 
            (Name = 'Competitor'  OR Name = 'Plant'
             OR Name = 'Pending SAP Customer' OR Name = 'Prospect' OR Name = 'Standard')];
        
        List<Account> testAccounts = [SELECT Id, RecordType.Name FROM Account];

        Map<String, Account> mapOfRecTypeNameAndAcc = new Map<String, Account>();

        for(Account acc : testAccounts) {
            mapOfRecTypeNameAndAcc.put(acc.RecordType.Name, acc);
        }

        Map<String, List<String>> mapOfCountryAndStateCodes = new Map<String, List<String>>{'US' => new List<String>{'IL'}};
        Map<String, List<String>> mapOfCountryAndState = new Map<String, List<String>>{'United States' => new List<String>{'Illinois'}}; 

        List<FCM_Address__c> newLocations = new List<FCM_Address__c>();
        List<String> testCountryData = new List<String>{'US', 'United States', '', '', 'US', 'Error Country'};
        List<String> testStateData = new List<String>{'IL', 'Illinois', '', 'IL', '', 'Error State'};

        for(Integer i = 0; i < 100; i++) {
            
            RecordType randomRecordType = locRecordTypes.get(Math.mod(i, locRecordTypes.size()));
            Account parentAcc = null;

            if(randomRecordType.Name == 'Competitor' || randomRecordType.Name == 'Prospect') {
                parentAcc = mapOfRecTypeNameAndAcc.get('Competitor');
            } else if(randomRecordType.Name == 'Standard' || randomRecordType.Name == 'Pending SAP Customer') {
                parentAcc = mapOfRecTypeNameAndAcc.get('Standard');
            } else if(randomRecordType.Name == 'Plant') {
                parentAcc = mapOfRecTypeNameAndAcc.get('Corporate');
            } else {
                parentAcc = mapOfRecTypeNameAndAcc.get('Competitor');
            }

            FCM_Address__c newLocation = new FCM_Address__c(
                Name = 'Test Location',
                CurrencyIsoCode = 'USD',
                RecordTypeId = randomRecordType.Id,
                FCM_Street__c = 'Test Street',
                FCM_City__c = 'Test Street',
                FCM_StateProvince__c = testStateData.get(Math.mod(i, testStateData.size())),
                FCM_ZipPostalCode__c = '60439',
                FCM_Country__c = testCountryData.get(Math.mod(i, testCountryData.size())),
                Name_2__c = 'Test Name 2',
                FCM_Account__c = parentAcc.Id,
                AccountGroup_R1__c = '1234',
                FCM_Inco_Term__c = '01C',
                LineofBusiness_R1__c = 'CAPV',
                FCM_Status__c = 'Active',
                ExternalDataSource_R1__c = 'Test External Source',
                FCM_ExternalId__c = 'Test SAP Id',
                SiteType_R1__c = 'Bleacher'
            );

            newLocations.add(newLocation);

        }

        insert newLocations;

        Test.startTest();
            Database.executeBatch(new LocationToAccountBatch(mapOfCountryAndState, mapOfCountryAndStateCodes));
        Test.stopTest();

    }

	
}