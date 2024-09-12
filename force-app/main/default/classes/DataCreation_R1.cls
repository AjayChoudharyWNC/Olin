//test

public class DataCreation_R1 {
    
    //Create single account
    public static Account createTestAccount(User ownerUser, String name,RecordType rType) {
        Account account = new Account(Name = name,ownerId = ownerUser.id,Type = 'Customer',RecordTypeId =rType.id);//CurrencyIsoCode = 'U.S. Dollar',
        return account;
    }
    
    //Create single contact
    public static Contact createTestContact(Account parentAccount, String lastName,RecordType rType ) {
        Contact contact = new Contact(FirstName = 'test',LastName = lastName,Phone = '4155551212',AccountId = parentAccount.id,RecordTypeId =rType.id);
        return contact;
    }
    
    //Create single CallReport
    public static FCM_VisitReport__c createTestCallReport( Account childAccount) {
        FCM_VisitReport__c callreportt = new FCM_VisitReport__c(FCM_Account__c = childAccount.id);
        return callreportt;
    }
    
    /*
     * //Create single CallReport linked to an account
    public static FCM_VRAttendee__c createTestContact( FCM_VisitReport__c visitreport, Contact contact2) {
        //FCM_VisitReport__r.ConfidentialityAgreement_R1__r.Name,ID,Name,FCM_ShortComment__c,FCM_Contact__r.name,FCM_Contact__r.Account.Name FROM FCM_VRAttendee__c WHERE FCM_VisitReport__c = :acc.ID
        FCM_VRAttendee__c callreport = new FCM_VRAttendee__c(FCM_VisitReport__c = visitreport.id, FCM_Contact__c = contact2.Id);
        return callreport;
    }*/
    
    //Generate Accounts
    public List<Account> GenerateAccounts(Integer intAccount){
        List<Account> lstAccount = new List<Account>();
        
        for(Integer i = 1; i <= intAccount; i++){
            lstAccount.add(new Account(Name = 'Account ' + i));
        }
        
        return lstAccount;
    }
    
    //Generate Competitors
    public List<Competitor_R1__c> GenerateCompetitors(Integer intCompetitors, Account objAccount){
        List<Competitor_R1__c> lstCompetitor = new List<Competitor_R1__c>();
        
        for(Integer i = 1; i <= intCompetitors; i++){
            lstCompetitor.add(new Competitor_R1__c(Customer_R1__c = objAccount.Id));
        }
        
        return lstCompetitor;
    }
    
    //Generate Contacts
    public List<Contact> GenerateContacts(Integer intContacts, String LastName, Account objAccount, RecordType RType){
        List<Contact> lstContact = new List<Contact>();
        
        for(Integer i = 1; i <= intContacts; i++){
            lstContact.add(new Contact(LastName = LastName + i, AccountId = objAccount.Id));
            //lstContact.add(new Contact(LastName = LastName, AccountId = '001W000000dbaLwIAI'));
        }
        
        return lstContact;
    }
    
    //Generate Products
    public List<Product2> GenerateProducts(Integer intProduct, RecordType RType){
        List<Product2> lstProduct = new List<Product2>();
        
        for(Integer i = 1; i <= intProduct; i++){
            lstProduct.add(new Product2(Name = 'Test Product ' + i));
        }
        
        return lstProduct;
    }
    
    //Generate Call Reports
    public List<FCM_VisitReport__c> GenerateCallReports(Integer intCallReport, Account objAccount){
        List<FCM_VisitReport__c> lstCallReport = new List<FCM_VisitReport__c>();
        
        for(Integer i = 1; i <= intCallReport; i++){
            lstCallReport.add(new FCM_VisitReport__c(FCM_Account__c = objAccount.id));
        }
        
        return lstCallReport;
    }
    
    
}