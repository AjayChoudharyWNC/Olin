/**
* Created by beclassen on 4/24/2017.
*/

@isTest
private class FCM_VRProductEntryCtrlExtensionTest {
    
    private static Account acct;
    private static List<Account> accounts;
    private static List<Product2> products;
    private static FCM_VisitReport__c visitReport;
    //private static List<PricebookEntry> pricebookEntries;
    
    static void setUp(){
        
        // Create internal account
        Id BusinessAccRecTypeId = [SELECT id,Name,SObjectType FROM RecordType where SObjectType = 'Account' and Name = 'Olin Corp'].id;
        Account acct1 = new Account(Name = 'FastChem Cooperation', RecordTypeId = BusinessAccRecTypeId);
        insert acct1;
        
        AccountName__c acctName = new AccountName__c();
        acctName.Name = 'FastChem Corp';
        acctName.OlinAccountValue__c = acct1.id;
        insert acctName;    
        
        Profile profileAdmin = [Select Id from Profile where name = 'System Administrator'];
        system.debug('::ID Profile::'+profileAdmin.id);
        
        //   User user_test= new User( ProfileId = profileAdmin.Id, Username = 'contactAdminOlin@test.com', Alias = 'Admin', Email = 'contactAdminOlin@test.com',
        //        EmailEncodingKey = 'UTF-8',Firstname = 'test',Lastname = 'user', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US',TimeZoneSidKey = 'America/Los_Angeles');
        // insert user_test; 
        //User userAdmin = [SELECT id FROM User Where email = 'contactAdminOlin@test.com' Limit 1]; 
        
        // system.debug('::::: ID user ::'+ userAdmin);
        //  System.runAs(userAdmin) {
        //now test data set
        
        Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Account acct = new Account (name='test account',AccountNumber_R1__c='1234567890',AccountSource='Blue Cube', recordtypeid=RecordTypeIdAccount);
        insert acct;
        system.debug('::::: acct ::'+ acct);
        //id prodrectypeid = [SELECT Id FROM RecordType WHERE Name = 'Product' LIMIT 1].Id;
        
        List<Product2> products = new List<Product2>();
        for (Integer i = 0; i < 102; i++) {
            products.add( new Product2(
                Name = 'TestProd_' + i,
                ProductCode = 'TestProd_' + i,
                Product_Level__c = 'GMID',
                IsActive = true));
        }
        insert products;
        system.debug('::::: products ::'+ products);
        /*Pricebook2 pricebook = FCM_TestDataFactory.createPricebook();
Id stdPricebookId = Test.getStandardPricebookId();
pricebook.Id = stdPricebookId;


pricebookEntries = FCM_TestDataFactory.createPricebookEntries(pricebook, products);
insert pricebookEntries ;
*/
        //visitReport = FCM_TestDataFactory.createVisitReport(acct);
        FCM_VisitReport__c visitReport = new FCM_VisitReport__c(
            FCM_Account__c = acct.Id,
            FCM_Status__c = 'Planned',
            FCM_VisitDate__c = Date.today());
        
        insert visitReport;
        system.debug('::::: visitReport ::'+ visitReport.ID);
        
        FCM_VRProduct__c vrproduct = new FCM_VRProduct__c(
            FCM_VisitReport__c = visitReport.ID, 
            FCM_Product__c = products[0].ID
            
        );
        insert vrproduct;
        system.debug('::::: vrproduct ::'+ vrproduct.ID);
        
        PurchasedProduct_R1__c objPurchasedProduct = new PurchasedProduct_R1__c(
            Account_R1__c = acct.Id,
            Product_R1__c = products[0].ID
        );
        insert objPurchasedProduct;
        system.debug('::::: objPurchasedProduct ::'+ objPurchasedProduct.ID);
        // }     
    }
    
    static testMethod void testProductSearch(){
        
        setUp();
        
        test.startTest();
        
        // User userAdmin = [SELECT id FROM User Where email = 'contactAdminOlin@test.com' Limit 1]; 
        //  System.runAs(userAdmin) {
        ID accountID = [Select Id,name From Account where name='test account' Limit 1].id;
        ID callReportID = [Select Id,name From FCM_VisitReport__c where FCM_Account__c= :accountID Limit 1].id;
        FCM_VisitReport__c visitReport = [Select Id,name From FCM_VisitReport__c where FCM_Account__c= :accountID Limit 1];
        
        PageReference pageRef = Page.FCM_VRProductEntry;
        pageRef.getParameters().put('Id', callReportID);
        ApexPages.StandardController standardCtrl = new ApexPages.StandardController(visitReport);
        FCM_VRProductEntryCtrlExtension visitProdEntryExtension = new FCM_VRProductEntryCtrlExtension(standardCtrl);
        Test.setCurrentPageReference(pageRef);
        
        // We expect 2 procucts to be available in the list after calling the updateAvailableList method but no product already 
        // linked to the visit report
        visitProdEntryExtension.searchString = 'TestProd_';
        visitProdEntryExtension.updateAvailableList();
        //System.assertEquals(0, visitProdEntryExtension.productLst.size());
        //System.assertEquals(2, visitProdEntryExtension.availableProducts.size());
        
        //visitProdEntryExtension.TestProd_
        // }
        test.stopTest();
    }
    
    static testMethod void testAddingAndDeletingProducts(){
        
        // Within this method we will link products to the visit report. After that we will delete them again. 
        setUp();
        
        test.startTest();
        // User userAdmin = [SELECT id FROM User Where email = 'contactAdminOlin@test.com' Limit 1]; 
        //     System.runAs(userAdmin) {
        ID accountID = [Select Id,name From Account where name='test account' Limit 1].id;
        ID callReportID = [Select Id,name From FCM_VisitReport__c where FCM_Account__c= :accountID Limit 1].id;
        FCM_VisitReport__c visitReport = [Select Id,name From FCM_VisitReport__c where FCM_Account__c= :accountID Limit 1];
        
        PageReference pageRef = Page.FCM_VRProductEntry;
        pageRef.getParameters().put('Id', callReportID);
        ApexPages.StandardController standardCtrl = new ApexPages.StandardController(visitReport);
        FCM_VRProductEntryCtrlExtension visitProdEntryExtension = new FCM_VRProductEntryCtrlExtension(standardCtrl);
        Test.setCurrentPageReference(pageRef);
        
        ID productId = [Select Id, Name From Product2 where  IsActive = true And ProductCode = 'TestProd_101' And Name = 'TestProd_101' ].ID;
        List<Product2> products = [Select Id, Name From Product2 where  IsActive = true];
        // Test adding and saving
        visitProdEntryExtension.updateAvailableList();
        visitProdEntryExtension.AvailableProducts = products;
        visitProdEntryExtension.toSelect = productId;
        visitProdEntryExtension.addToShoppingCart();
        visitProdEntryExtension.getListLineofBussiness();
        visitProdEntryExtension.getListProductFilterType();
        // After saving we expect the number of products related to the visit report to increase by one. The number of available
        // products stays as it was before since it is possible to select the same product multiple times.
        visitProdEntryExtension.onSave();
        //System.assertEquals(1, visitProdEntryExtension.productLst.size());
        //System.assertEquals(2, visitProdEntryExtension.availableProducts.size());
        
        // Test adding and cancel
        visitProdEntryExtension.updateAvailableList();
        visitProdEntryExtension.toSelect = productId;
        
        // After canceling the operation we expect the number of products related to the visit to stay the same. 
        visitProdEntryExtension.onCancel();
        //System.assertEquals(1, visitProdEntryExtension.productLst.size());
        //System.assertEquals(2, visitProdEntryExtension.availableProducts.size());
        
        
        //Test deleting products from the shopping card
        visitProdEntryExtension.updateAvailableList();
        for (FCM_VRProduct__c visitReportProduct : visitProdEntryExtension.productLst){
            visitReportProduct.FCM_IsToBeDeleted__c = true;
            break;
        }
        visitProdEntryExtension.removeFromShoppingCart();
        visitProdEntryExtension.onSave();
        
        // After saving we expect the list of available products to be empty.
        //System.assertEquals(0, visitProdEntryExtension.productLst.size());
        //System.assertEquals(2, visitProdEntryExtension.availableProducts.size());
        //}
        test.stopTest();
    }
}