@isTest
public class MapLocationToAccountCallReportBatchTest {
    
    @TestSetup
    static void makeData(){

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

            Account newAccount = new Account(
                Name = 'Test Account',
                RecordTypeId = accRecordType.Id,
                CurrencyIsoCode = 'USD',
                Type = 'Competitor',
                Region_R1__c = 'UNITED STATES'
            );

            insert newAccount;

            AccountName__c acctName = new AccountName__c();
            acctName.Name = 'FastChem Corp';
            acctName.OlinAccountValue__c = newAccount.id;
            insert acctName;

            FCM_Address__c newLocation = new FCM_Address__c(
                Name = 'Test Location',
                RecordTypeId = locRecordType.Id,
                FCM_Account__c = newAccount.Id
            );

            insert newLocation;

            newAccount.Location_Record_ID__c = newLocation.Id;

            update newAccount;

            FCM_VisitReport__c newCallReport = new FCM_VisitReport__c(
                FCM_Account__c = newAccount.Id,
                Location_R1__c = newLocation.Id
            );

            insert newCallReport;

        }

        
    }

    @isTest
    public static void testBatchClass() {

        Test.startTest();
            Database.executeBatch(new MapLocationToAccountCallReportBatch());
        Test.stopTest();

        Account acc = [SELECT Id FROM Account LIMIT 1];
        FCM_VisitReport__c callReport = [SELECT Id, Location_Account__c FROM FCM_VisitReport__c LIMIT 1];

        System.assertEquals(acc.Id, callReport.Location_Account__c);
        
    }

}