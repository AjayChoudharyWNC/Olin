@isTest
public class VRProductEntry_Test {
    public static testmethod void testMethod1(){
        Id rcID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Account acct = new Account (name='test account',recordtypeid = rcID,AccountNumber_R1__c='1234567890',AccountSource='Blue Cube');
        insert acct;
        
        FCM_VisitReport__c fcm = new FCM_VisitReport__c();
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
        VRProductEntry.fetchProducts(fcm.id, products.Id);
        VRProductEntry.fetchSearchProducts('test', 'BOTH', 'Purchased Products', fcm.id);
        VRProductEntry.getFilterTypes();
        VRProductEntry.getListLineofBussiness();
        VRProductEntry.removeProductRecords(products.id);
        VRProductEntry.selectedProductRecords(fcm.id);
        VRProductEntry.updateavailableList(products.id, fcm.id);
        test.stopTest();
    }
}