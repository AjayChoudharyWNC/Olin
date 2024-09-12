@isTest
public class CallReport_ShareOfWallet_Test {
    
    static testMethod void testController(){
        Horizon_Year__c hz = new Horizon_Year__c();
        hz.Name = 'Default';
        hz.Year__c = System.today().year() + 1;
        insert hz;
        
        // Create Account
        Account testAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId(),
            Name = 'Test Account',
            AccountNumber_R1__c = '123'
        );
        insert testAccount;
        
        Account testUnknownAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Competitor').getRecordTypeId(),
            Name = 'UNKNOWN',
            AccountNumber_R1__c = '1234'
        );
        insert testUnknownAccount;
        
        Product2 testProduct = new Product2(
            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
            Name = 'Test Product',
            Product_Level__c = 'GMID',
            isActive = true
        );
        insert testProduct;
        
        //Create Purchased Product
        List<PurchasedProduct_R1__c> lstTestPurchasedProduct = new List<PurchasedProduct_R1__c>();
        PurchasedProduct_R1__c testPurchasedProduct = new PurchasedProduct_R1__c(
            Account_R1__c = testAccount.Id,
            Product_R1__c = testProduct.Id
        );
        lstTestPurchasedProduct.add(testPurchasedProduct);
        
        testPurchasedProduct = new PurchasedProduct_R1__c(
            Account_R1__c = testUnknownAccount.Id,
            Product_R1__c = testProduct.Id
        );
        lstTestPurchasedProduct.add(testPurchasedProduct);
        insert lstTestPurchasedProduct;
        
        Integer currentYear = Date.today().year();
        //Create Total Consumption
        List<Total_Consumption__c> lstTestTotalConsumption = new List<Total_Consumption__c>();
        Total_Consumption__c testTotalConsumption = new Total_Consumption__c(
            Purchased_Product__c = lstTestPurchasedProduct[0].Id,
            Year__c = '2018',
            Consumption__c = 250000,
            UnknownAmount__c = 15000,
            UnknownPercent__c = 10
        );
        lstTestTotalConsumption.add(testTotalConsumption);
        
        testTotalConsumption = new Total_Consumption__c(
            Purchased_Product__c = lstTestPurchasedProduct[1].Id,
            Year__c = '2018',
            Consumption__c = 250000,
            UnknownAmount__c = 15000,
            UnknownPercent__c = 10
        );
        lstTestTotalConsumption.add(testTotalConsumption);
        insert lstTestTotalConsumption;
        FCM_VisitReport__c newCallReport = new FCM_VisitReport__c(
            FCM_Account__c = testAccount.Id
        );
        
        insert newCallReport;
        
        CallReport_ShareOfWallet.getAllPurchasedProducts(newCallReport.Id, null);
        CallReport_ShareOfWallet.getRelatedSoldToAccounts(testAccount.Id);
        CallReport_MarketSegmentation.getAllPurchasedProducts(newCallReport.Id, null);
		CallReport_MarketSegmentation.getRelatedSoldToAccounts(testAccount.Id);        
        
    }
    
}