@isTest
public class PurchasedProductTrigger_Test {
    testMethod static void testInsert() {
        // Create Account
        Account testAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
            Name = 'Test Account',
            Ship_To__c = true,
            Sold_To__c = true
        );
        insert testAccount;

        Account shipToAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
            Name = 'Ship To Account',
            AccountNumber_R1__c = '267687',
            Ship_To__c = true,
            ParentId = testAccount.Id
        );
        insert shipToAccount;

        //Create Product
        Product2 testProduct = new Product2(
            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
            Name = 'Test Product',
            Product_Level__c = 'GMID'
        );
        insert testProduct;
		Horizon_Year__c hz = new Horizon_Year__c();
        hz.Name = 'Default';
        hz.Year__c = 2025;
        insert hz;
        //Create Purchased Product
        PurchasedProduct_R1__c testPurchasedProduct = new PurchasedProduct_R1__c(
            Account_R1__c = testAccount.Id,
            Product_R1__c = testProduct.Id,
            Ship_To__c = shipToAccount.Id
        );
        insert testPurchasedProduct;
    }

}