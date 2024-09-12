@isTest
public class ConsumptionShareTest {
    testMethod static void testMethods() {
        // Create Account
        List<Account> lstTestAccount = new List<Account>();
        Account testAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Competitor').getRecordTypeId(),
            Name = 'Test Account',
            AccountNumber_R1__c = '123123'
        );
        lstTestAccount.add(testAccount);

        testAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Competitor').getRecordTypeId(),
            Name = 'Test Account Unknown'
        );
        lstTestAccount.add(testAccount);
        insert lstTestAccount;

        //Create Product
        Product2 testProduct = new Product2(
            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
            Name = 'Test Product',
            Product_Level__c = 'GMID'
        );
        insert testProduct;

        //Create Purchased Product
        PurchasedProduct_R1__c testPurchasedProduct = new PurchasedProduct_R1__c(
            Account_R1__c = lstTestAccount[0].Id,
            Product_R1__c = testProduct.Id
        );
        insert testPurchasedProduct;

        //Create Total Consumption
        List<Total_Consumption__c> lstTestTotalConsumption = new List<Total_Consumption__c>();
        Total_Consumption__c testTotalConsumption = new Total_Consumption__c(
            Purchased_Product__c = testPurchasedProduct.Id,
            Ship_To__c = lstTestAccount[0].Id,
            Product__c = testProduct.Id,
            Year__c = '2019',
            Consumption__c = 250000
        );
        lstTestTotalConsumption.add(testTotalConsumption);

        testTotalConsumption = new Total_Consumption__c(
            Purchased_Product__c = testPurchasedProduct.Id,
            Ship_To__c = lstTestAccount[0].Id,
            Product__c = testProduct.Id,
            Year__c = '2020',
            Consumption__c = 150000
        );
        lstTestTotalConsumption.add(testTotalConsumption);
        insert lstTestTotalConsumption;

        //Create Consumption Share
        List<Consumption_Share__c> lstTestConsumptionShare = new List<Consumption_Share__c>();
        Consumption_Share__c testConsumptionShare = new Consumption_Share__c();
        testConsumptionShare.Consumption_ShareOfWallet__c = lstTestTotalConsumption[0].Id;
        testConsumptionShare.Seller_Account_SOW__c = lstTestAccount[0].Id;
        testConsumptionShare.Share_Amount__c = 25000;
        testConsumptionShare.Share_Percent__c = 15;
        lstTestConsumptionShare.add(testConsumptionShare);

        testConsumptionShare = new Consumption_Share__c();
        testConsumptionShare.Consumption_ShareOfWallet__c = lstTestTotalConsumption[0].Id;
        testConsumptionShare.Seller_Account_SOW__c = lstTestAccount[1].Id;
        testConsumptionShare.Share_Amount__c = 35000;
        testConsumptionShare.Share_Percent__c = 5;
        lstTestConsumptionShare.add(testConsumptionShare);

        testConsumptionShare = new Consumption_Share__c();
        testConsumptionShare.Consumption_ShareOfWallet__c = lstTestTotalConsumption[1].Id;
        testConsumptionShare.Seller_Account_SOW__c = lstTestAccount[0].Id;
        testConsumptionShare.Share_Amount__c = 25000;
        testConsumptionShare.Share_Percent__c = 5;
        lstTestConsumptionShare.add(testConsumptionShare);

        testConsumptionShare = new Consumption_Share__c();
        testConsumptionShare.Consumption_ShareOfWallet__c = lstTestTotalConsumption[1].Id;
        testConsumptionShare.Seller_Account_SOW__c = lstTestAccount[1].Id;
        testConsumptionShare.Share_Amount__c = 35000;
        testConsumptionShare.Share_Percent__c = 5;
        lstTestConsumptionShare.add(testConsumptionShare);
        insert lstTestConsumptionShare;

        lstTestConsumptionShare[0].Share_Amount__c = 30000;
        lstTestConsumptionShare[0].Share_Percent__c = 2;
        update lstTestConsumptionShare;
    }
}