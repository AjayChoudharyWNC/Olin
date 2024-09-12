@isTest
    public class ManageProductsConfidentialsTest {
    
     public static testmethod void testMethod1(){
        Id rcID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Account acct = new Account (name='test account',recordtypeid = rcID,AccountNumber_R1__c='1234567890',AccountSource='Blue Cube');
        insert acct;
        
        Confidential_Call_Report__c fcm = new Confidential_Call_Report__c();
        fcm.FCM_Account__c = acct.id;
        fcm.FCM_Status__c = 'Planned';
        fcm.FCM_VisitDate__c = Date.today();
        insert fcm;
        
        List<String> plist = new list <String>();
        Product2 products = new Product2();
        products.Name = 'TestProd_';
        products.ProductCode = 'TestProd_' ;
        products.Product_Level__c = 'GMID';
        products.IsActive = true;
        insert products;
        plist.add(products.id);
         test.startTest();
        ManageProductsConfidentials.fetchProducts(fcm.id, products.Id);
        ManageProductsConfidentials.fetchSearchProducts('test', 'BOTH', 'Purchased Products', fcm.id);
        ManageProductsConfidentials.getFilterTypes();
        ManageProductsConfidentials.getListLineofBussiness();
        ManageProductsConfidentials.removeProductRecords(products.id);
        ManageProductsConfidentials.selectedProductRecords(fcm.id);
        ManageProductsConfidentials.updateavailableList(products.id, fcm.id);
        test.stopTest();
    }

}