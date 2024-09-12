@isTest
public class CompetitiveTrigger_Test {
    
    static testMethod void test1(){
        RecordType competitorRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Competitor'];
        RecordType customerLocationRT = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND Name = 'Customer Location'];
        
        Account newAccount = new Account(
            Name = 'Test Account',
            RecordTypeId = competitorRecordType.Id,
            CurrencyIsoCode = 'USD',
            Type = 'Competitor',
            Region_R1__c = 'UNITED STATES'
        );
        
        insert newAccount;
        Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        
        
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
        Account acctt = new Account();
        acctt.Name='test';
        acctt.AccountNumber_R1__c='value102110';
        acctt.AccountSource='Blue Cube';
        acctt.CurrencyIsoCode='USD';
        acctt.type='Customer';
        acctt.RecordTypeId = RecordTypeIdAccount;
        insert acctt;
        
        
        Product2 newProduct = new Product2(
            Name = 'Test Product',
            IsActive = true
        );
        
        insert newProduct;
        
        
        Competitor_R1__c newCompetitive = new Competitor_R1__c(
            Customer_R1__c = acctt.Id, 
            Competitor_R1__c = newAccount.Id,
            Olin_Product__c = newProduct.Id,
            Price_R1__c = 10.000,
            VolumeofDeal_R1__c = 1,
            UnitofMeasure_R1__c = 'KG',
            PriceDiscoveryMethod_R1__c = 'Customer Target',
            Customer_Account_Location__c = newCustomerLocAcc.Id
        );
        insert newCompetitive; 
        delete newCompetitive;
    }
    
}