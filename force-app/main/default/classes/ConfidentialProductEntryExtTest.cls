@isTest
public class ConfidentialProductEntryExtTest {
    @testSetup
    static void setup(){
        // Create internal account
        Id BusinessAccRecTypeId = [SELECT id,Name,SObjectType FROM RecordType where SObjectType = 'Account' and Name = 'Customer'].id;
        Account acct1 = new Account(Name = 'FastChem Cooperation', RecordTypeId = BusinessAccRecTypeId);
        insert acct1;
        
        AccountName__c acctName = new AccountName__c();
        acctName.Name = 'FastChem Corp';
        acctName.OlinAccountValue__c = acct1.id;
        insert acctName;    
        Profile profileAdmin = [Select Id from Profile where name = 'System Administrator'];
        system.debug('::ID Profile::'+profileAdmin.id);
        
        //now test data set
        Account acct = new Account (name='test account',AccountNumber_R1__c='1234567890',AccountSource='Blue Cube', RecordTypeId = BusinessAccRecTypeId);
        insert acct;
        
        List<Product2> products = new List<Product2>();
        for (Integer i = 0; i < 102; i++) {
            products.add( new Product2(
                Name = 'TestProd_' + i,
                ProductCode = 'TestProd_' + i,
                Product_Level__c = 'GMID',
                IsActive = true));
        }
        insert products;
        Confidential_Call_Report__c visitReport = new Confidential_Call_Report__c(
            FCM_Account__c = acct.Id,
            FCM_Status__c = 'Planned',
            FCM_VisitDate__c = Date.today());
          insert visitReport;
        Confidential_Call_Report_Product__c vrproduct = new Confidential_Call_Report_Product__c(
            Confidential_Call_Report__c = visitReport.ID, 
            FCM_Product__c = products[0].ID
        );
       insert vrproduct;
        PurchasedProduct_R1__c objPurchasedProduct = new PurchasedProduct_R1__c(
            Account_R1__c = acct.Id,
            Product_R1__c = products[0].ID
        );
        insert objPurchasedProduct;
    }
    static testMethod void testProductSearch(){
      Test.startTest();
          ID accountID = [Select Id,name From Account where name='test account' Limit 1].id;
            ID callReportID = [Select Id,name From Confidential_Call_Report__c where FCM_Account__c= :accountID Limit 1].id;
            Confidential_Call_Report__c visitReport = [Select Id,name From Confidential_Call_Report__c where FCM_Account__c= :accountID Limit 1];
            
            PageReference pageRef = Page.FCM_VRProductEntry;
            pageRef.getParameters().put('Id', callReportID);
            ApexPages.StandardController standardCtrl = new ApexPages.StandardController(visitReport);
            ConfidentialProductEntryExt visitProdEntryExtension = new ConfidentialProductEntryExt(standardCtrl);
            Test.setCurrentPageReference(pageRef);
            
            // We expect 2 procucts to be available in the list after calling the updateAvailableList method but no product already 
            // linked to the visit report
            visitProdEntryExtension.searchString = 'TestProd_';
            visitProdEntryExtension.updateAvailableList();
            
        Test.stopTest();
        
    }
    
    static testMethod void testAddingAndDeletingProducts(){
        
        Test.startTest();
        
            ID accountID = [Select Id,name From Account where name='test account' Limit 1].id;
            ID callReportID = [Select Id,name From Confidential_Call_Report__c where FCM_Account__c= :accountID Limit 1].id;
            Confidential_Call_Report__c visitReport = [Select Id,name From Confidential_Call_Report__c where FCM_Account__c= :accountID Limit 1];
            
            PageReference pageRef = Page.FCM_VRProductEntry;
            pageRef.getParameters().put('Id', callReportID);
            ApexPages.StandardController standardCtrl = new ApexPages.StandardController(visitReport);
            ConfidentialProductEntryExt visitProdEntryExtension = new ConfidentialProductEntryExt(standardCtrl);
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
            
            // Test adding and cancel
            visitProdEntryExtension.updateAvailableList();
            visitProdEntryExtension.toSelect = productId;
            
            // After canceling the operation we expect the number of products related to the visit to stay the same. 
            visitProdEntryExtension.onCancel();
            
            //Test deleting products from the shopping card
            visitProdEntryExtension.updateAvailableList();
            for (Confidential_Call_Report_Product__c visitReportProduct : visitProdEntryExtension.productLst){
                visitReportProduct.FCM_IsToBeDeleted__c = true;
                break;
            }
            visitProdEntryExtension.removeFromShoppingCart();
            visitProdEntryExtension.onSave();
            
        Test.stopTest();
        
    }
    
}