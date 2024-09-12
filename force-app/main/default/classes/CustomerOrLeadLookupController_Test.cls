@isTest
private class CustomerOrLeadLookupController_Test {
    
    static testMethod void testFetchRecords() {
        String searchText='Test';
        String sortDirectionLead='ASC';
        String sortDirectionAcc='ASC';
        String sortDirectionOpp='ASC';
        String sortDirectionCon='ASC';
        String sortByLead='Name';
        String sortByAcc='Name';
        String sortByOpp='Name';
        String sortByCon='Account.Name';
        Account acc = new Account(Name='Test',AccountNumber_R1__c='123123',AccountSource='test', Sold_To__c=true);
        insert acc;
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = acc.Id;
        Test.setFixedSearchResults(fixedSearchResults);
        CustomerOrLeadLookupController.fetchRecords(searchText, sortDirectionLead, sortDirectionAcc, sortDirectionOpp, sortDirectionCon, sortByLead, sortByAcc, sortByOpp, sortByCon);
    }
    static testMethod void testFetchContact(){
        String searchText='Test';
        String sortDirectionLead='ASC';
        String sortDirectionAcc='ASC';
        String sortDirectionOpp='ASC';
        String sortDirectionCon='ASC';
        String sortByLead='Name';
        String sortByAcc='Name';
        String sortByOpp='Name';
        String sortByCon='Account.Name';
        Account acc = new Account(Name='Test',AccountNumber_R1__c='123123',AccountSource='test');
        insert acc;
        Contact con = new Contact(LastName='Test',AccountId=acc.Id,Email='test@test.com');
        insert con;
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = con.Id;
        Test.setFixedSearchResults(fixedSearchResults);
        CustomerOrLeadLookupController.fetchRecords(searchText, sortDirectionLead, sortDirectionAcc, sortDirectionOpp, sortDirectionCon, sortByLead, sortByAcc, sortByOpp, sortByCon);
    }
    static testMethod void testFetchLead(){
        String searchText='Test';
        String sortDirectionLead='ASC';
        String sortDirectionAcc='ASC';
        String sortDirectionOpp='ASC';
        String sortDirectionCon='ASC';
        String sortByLead='Name';
        String sortByAcc='Name';
        String sortByOpp='Name';
        String sortByCon='Account.Name';
        
        Lead l = new Lead(Status='Open',LastName='Test',Company='Test');
        insert l;
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = l.Id;
        Test.setFixedSearchResults(fixedSearchResults);
        CustomerOrLeadLookupController.fetchRecords(searchText, sortDirectionLead, sortDirectionAcc, sortDirectionOpp, sortDirectionCon, sortByLead, sortByAcc, sortByOpp, sortByCon);
    }
    static testMethod void testFetchLocations(){
        String searchText='Test';
        String sortDirectionLead='ASC';
        String sortDirectionAcc='ASC';
        String sortDirectionOpp='ASC';
        String sortDirectionCon='ASC';
        String sortByLead='Name';
        String sortByAcc='Name';
        String sortByOpp='Name';
        String sortByCon='Account.Name';
        Account acc = new Account(Name='Test',AccountNumber_R1__c='123123',AccountSource='test',Ship_To__c=true);
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Competitor').getRecordTypeId();
        insert acc;
        FCM_Address__c loc = new FCM_Address__c();
        loc.FCM_Account__c = acc.Id;
        loc.RecordTypeId = Schema.SObjectType.FCM_Address__c.getRecordTypeInfosByName().get('Competitor').getRecordTypeId();
        loc.Name = 'Test';
        insert loc;
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = acc.Id;
        Test.setFixedSearchResults(fixedSearchResults);
        CustomerOrLeadLookupController.fetchRecords(searchText, sortDirectionLead, sortDirectionAcc, sortDirectionOpp, sortDirectionCon, sortByLead, sortByAcc, sortByOpp, sortByCon);
    }
}