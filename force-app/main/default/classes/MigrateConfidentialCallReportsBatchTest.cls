@isTest
public class MigrateConfidentialCallReportsBatchTest {
    
    @TestSetup
    static void makeData() {
        
        RecordType accRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Prospect'];
        RecordType locRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'FCM_Address__c' AND DeveloperName = 'Prospect'];
        
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
            
            Product2 newProduct = new Product2(
                Name = 'Test Product',
                IsActive = true
            );
            
            Account newAccount = new Account(
                Name = 'Test Account',
                RecordTypeId = accRecordType.Id,
                CurrencyIsoCode = 'USD',
                Type = 'Competitor',
                Region_R1__c = 'UNITED STATES',
                AccountNumber_R1__c = 'Test Acc number'
            );
            
            insert newAccount;

			Contact newContact = new Contact(
                AccountId = newAccount.Id,
                LastName = 'Last Name'
            );
            
            insert newContact;
            
            AccountName__c acctName = new AccountName__c();
            acctName.Name = 'FastChem Corp';
            acctName.OlinAccountValue__c = newAccount.id;
            insert acctName;
            
            FCM_Address__c newLocation = new FCM_Address__c(
                Name = 'Test Location',
                RecordTypeId = locRecordType.Id,
                FCM_Account__c = newAccount.Id,
                FCM_ExternalId__c = 'Test SAP Id'
            );
            
            insert newLocation;
            
            newAccount.Location_Record_ID__c = newLocation.Id;
            
            update newAccount;
            
            FCM_VisitReport__c newCallReport = new FCM_VisitReport__c(
                FCM_Account__c = newAccount.Id,
                Location_R1__c = newLocation.Id,
                Confidential__c = true
            );
            
            insert newCallReport;
            
            FCM_VRAttendee__c newCallReportAttendee = new FCM_VRAttendee__c(
                FCM_VisitReport__c = newCallReport.Id,
                FCM_Contact__c = newContact.Id
            );
            
            insert newCallReportAttendee;
            
            FCM_VRProduct__c newCallReportProduct = new FCM_VRProduct__c(
                FCM_VisitReport__c = newCallReport.Id
            );
            
            insert newCallReportProduct;
            
            Competitor_R1__c newCompetitive = new Competitor_R1__c(
                CallReport_R1__c = newCallReport.Id,
                Customer_R1__c = newAccount.Id, 
                //Competitor_R1__c = newAccount.Id,
                Olin_Product__c = newProduct.Id,
                Price_R1__c = 10.000,
                VolumeofDeal_R1__c = 1,
                UnitofMeasure_R1__c = 'KG',
                //OriginOfGoods_R1__c = newLocation.Id,
                CustomerLocation_R1__c = newLocation.Id,
                PriceDiscoveryMethod_R1__c = 'Customer Target'
            );
            
            insert newCompetitive;
            
        }
    }
    
    @isTest
    private static void testBatch() {
        
        Test.startTest();
        Database.executeBatch(new MigrateConfidentialCallReportsBatch());
        Test.stopTest();
        
        List<Confidential_Call_Report__c> newConfidentialCallReports = [SELECT Id FROM Confidential_Call_Report__c];
        
        System.assert(newConfidentialCallReports.size() == 1);
        
        Confidential_Call_Report__c newConfidentialCallReport = newConfidentialCallReports.get(0);
        
        Confidential_Call_Report_Attendee__c newConfidentialCallReportAttendee = [SELECT Confidential_Call_Report__c 
                                                                                  FROM Confidential_Call_Report_Attendee__c LIMIT 1];
        Confidential_Call_Report_Product__c newConfidentialCallReportProduct = [SELECT Confidential_Call_Report__c 
                                                                                FROM Confidential_Call_Report_Product__c LIMIT 1];
        Confidential_Competitive__c newConfidentialCompetitive = [SELECT Confidential_Call_Report__c 
                                                                  FROM Confidential_Competitive__c LIMIT 1];
        
        System.assertEquals(newConfidentialCallReport.Id, newConfidentialCallReportAttendee.Confidential_Call_Report__c);
        System.assertEquals(newConfidentialCallReport.Id, newConfidentialCallReportProduct.Confidential_Call_Report__c);
        System.assertEquals(newConfidentialCallReport.Id, newConfidentialCompetitive.Confidential_Call_Report__c);
        
    }
    
}