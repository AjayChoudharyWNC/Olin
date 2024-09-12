@isTest
public class ConsumptionFromPurchasedProdBatchTest {
    
    @TestSetup
    static void makeData() {

        RecordType accRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Olin_Corp'];
        
        // Create account 
        Account newAccount = new Account(
            Name = 'Test Account',
            RecordTypeId = accRecordType.Id,
            CurrencyIsoCode = 'USD',
            Type = 'Competitor',
            Region_R1__c = 'UNITED STATES'
        );

        insert newAccount;

        Product2 newProduct = new Product2(
            Name = 'Test Product',
            Product_Level__c = 'GMID'
        );

        insert newProduct;

        PurchasedProduct_R1__c newPurchasedProduct = new PurchasedProduct_R1__c(
            Account_R1__c = newAccount.Id,
            Product_R1__c = newProduct.Id,
            Ship_To__c = newAccount.Id,
            AnnualConsumption_R1__c = 10
        );

        insert newPurchasedProduct;

    }

    @isTest
    private static void testBatch() {

        Test.startTest();
            Database.executeBatch(new ConsumptionFromPurchasedProdBatch());
        Test.stopTest();

        // Check Total_Consumption__c
        PurchasedProduct_R1__c purchaseProduct = [SELECT Product_R1__c, Ship_To__c, AnnualConsumption_R1__c
            FROM PurchasedProduct_R1__c LIMIT 1];
        Total_Consumption__c totalConsumption = [SELECT Purchased_Product__c, Product__c, 
            Ship_To__c, Consumption__c FROM Total_Consumption__c LIMIT 1];

        System.assertEquals(purchaseProduct.Id, totalConsumption.Purchased_Product__c);
        System.assertEquals(purchaseProduct.Product_R1__c, totalConsumption.Product__c);
        System.assertEquals(purchaseProduct.Ship_To__c, totalConsumption.Ship_To__c);
        System.assertEquals(purchaseProduct.AnnualConsumption_R1__c, totalConsumption.Consumption__c);



    }

}