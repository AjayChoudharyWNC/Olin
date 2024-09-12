@isTest
public class CallReportProductTrigger_Test {
    
    static testMethod void test1(){
        Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Account acct = new Account (name='test account',AccountNumber_R1__c='1234567890',AccountSource='Blue Cube', recordtypeid=RecordTypeIdAccount);
        insert acct;
        
        List<Product2> products = new List<Product2>();
        products.add( new Product2(
            Name = 'TestProd_',
            ProductCode = 'TestProd_',
            Product_Level__c = 'GMID',
            IsActive = true));
        insert products;
        
        FCM_VisitReport__c visitReport = new FCM_VisitReport__c(
            FCM_Account__c = acct.Id,
            FCM_Status__c = 'Planned',
            FCM_VisitDate__c = Date.today());
        
        insert visitReport;
        
        FCM_VRProduct__c vrproduct = new FCM_VRProduct__c(
            FCM_VisitReport__c = visitReport.ID, 
            FCM_Product__c = products[0].ID
            
        );
        insert vrproduct;
        delete vrproduct;
    }
    
}