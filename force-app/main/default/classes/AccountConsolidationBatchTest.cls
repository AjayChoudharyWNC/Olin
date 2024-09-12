@isTest
public class AccountConsolidationBatchTest {
    
    @TestSetup
    static void makeData() 
    {
        RecordType customerLocationRT = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Customer Location'];
        RecordType customerRT = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Customer'];
        RecordType competitorRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Competitor'];

        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 

        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;

        User usr = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', ProfileId = p.Id, 
                    TimeZoneSidKey='America/Los_Angeles', UserName='olin-test-123@testorg.com', 
                    UserRoleId = r.Id);
		insert usr ;

        System.runAs(usr) {

            Account newAccount = new Account(
                Name = 'Test Account',
                RecordTypeId = competitorRecordType.Id,
                CurrencyIsoCode = 'USD',
                Type = 'Competitor',
                Region_R1__c = 'UNITED STATES'
            );

            insert newAccount;

            AccountName__c acctName = new AccountName__c();
            acctName.Name = 'FastChem Corp';
            acctName.OlinAccountValue__c = newAccount.id;
            insert acctName;

            Account newCustomerLocAcc = new Account(
                Name = 'Test Customer Location Account',
                RecordTypeId = customerLocationRT.Id,
                CurrencyIsoCode = 'USD',
                Region_R1__c = 'UNITED STATES',
                Type = 'Customer',
                CustomerSubtype_R1__c = 'Standard',
                AccountNumber_R1__c = '0001'
            );

            insert newCustomerLocAcc;

            Account newCustomerAcc = new Account(
                Name = 'Test Customer Account',
                RecordTypeId = customerRT.Id,
                CurrencyIsoCode = 'USD',
                Region_R1__c = 'UNITED STATES',
                Type = 'Customer',
                CustomerSubtype_R1__c = 'Standard',
                AccountNumber_R1__c = '0001',
                Ship_To__c = false
            );

            insert newCustomerAcc;
			/*
            FCM_VisitReport__c newCallReport = new FCM_VisitReport__c(
                FCM_Account__c = newCustomerLocAcc.Id
            );

            insert newCallReport;
            */
            Product2 newProduct = new Product2(
                Name = 'Test Product',
                IsActive = true
            );

            insert newProduct;

            Competitor_R1__c newCompetitive = new Competitor_R1__c(
                Customer_R1__c = newAccount.Id, 
                Competitor_R1__c = newAccount.Id,
                Olin_Product__c = newProduct.Id,
                Price_R1__c = 10.000,
                VolumeofDeal_R1__c = 1,
                UnitofMeasure_R1__c = 'KG',
                PriceDiscoveryMethod_R1__c = 'Customer Target',
                Customer_Account_Location__c = newCustomerLocAcc.Id
            );

            insert newCompetitive;

        }

    }

    @isTest
    private static void testBatch() {
        
        Test.startTest();
            Database.executeBatch(new AccountConsolidationBatch());
        Test.stopTest();

        // Customer, Customer Location, Call report, competitive
        List<Account> customerLocation = [SELECT Id FROM Account WHERE Name = 'Test Customer Location Account'];
        Account customerAcc = [SELECT Id, Ship_To__c FROM Account WHERE Name = 'Test Customer Account'];
        //FCM_VisitReport__c callReport = [SELECT Id, FCM_Account__c FROM FCM_VisitReport__c LIMIT 1];
        Competitor_R1__c competitive = [SELECT Id, Customer_Account_Location__c FROM Competitor_R1__c LIMIT 1];


        // Check if customer location account is deleted
        System.assert(customerLocation.isEmpty());

        // Check if FCM_Account__c field in the Call Report object points to customer account
        //System.assertEquals(customerAcc.Id, callReport.FCM_Account__c);

        // Check if Customer_Account_Location__c field in the Competitve object points to customer account
        System.assertEquals(customerAcc.Id, competitive.Customer_Account_Location__c);

        // Check if Ship To is true
        System.assert(customerAcc.Ship_To__c);

    }

}