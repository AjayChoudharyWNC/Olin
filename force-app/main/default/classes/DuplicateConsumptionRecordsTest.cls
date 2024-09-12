@isTest
public class DuplicateConsumptionRecordsTest {
    
    testMethod static void testSchedClass() {
        //Create Horizon Year
        Horizon_Year__c hz = new Horizon_Year__c();
        hz.Name = 'Default';
        hz.Year__c = System.today().year() + 1;
        insert hz;
        
        // Create Account
        Account testAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Competitor').getRecordTypeId(),
            Name = 'Test Account',
            AccountNumber_R1__c = '123123'
        );
        insert testAccount;

        //Create Product
        Product2 testProduct = new Product2(
            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
            Name = 'Test Product',
            Product_Level__c = 'GMID'
        );
        insert testProduct;

        //Create Purchased Product
        PurchasedProduct_R1__c testPurchasedProduct = new PurchasedProduct_R1__c(
            Account_R1__c = testAccount.Id,
            Product_R1__c = testProduct.Id
        );
        insert testPurchasedProduct;

        // Create Total Consumption
        Total_Consumption__c testTotalConsumption = new Total_Consumption__c(
            Purchased_Product__c = testPurchasedProduct.Id,
            Ship_To__c = testAccount.Id,
            Product__c = testProduct.Id,
            Year__c = string.valueOf(system.today().year() - 1),
            Consumption__c = 250000
        );
        insert testTotalConsumption;

        // Create Consumption Share
        Consumption_Share__c testConsumptionShare = new Consumption_Share__c();
        testConsumptionShare.Consumption_ShareOfWallet__c = testTotalConsumption.Id;
        testConsumptionShare.Seller_Account_SOW__c = testAccount.Id;
        testConsumptionShare.Share_Amount__c = 25000;
        testConsumptionShare.Share_Percent__c = 15;
        insert testConsumptionShare;

        Test.startTest();
        DuplicateConsumptionRecordsSched sh1 = new DuplicateConsumptionRecordsSched();
        String sch = '0 0 0 1/1 * ? *'; 
        system.schedule('Test Share of Wallet Duplicate', sch, sh1);
        Test.stopTest();
    }
    
    
    testMethod static void testConstructorNoParams() {
        //Create Horizon Year
        Horizon_Year__c hz = new Horizon_Year__c();
        hz.Name = 'Default';
        hz.Year__c = System.today().year();
        insert hz;
        
        // Create Account
        Account testAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Competitor').getRecordTypeId(),
            Name = 'Test Account',
            AccountNumber_R1__c = '123123'
        );
        insert testAccount;

        //Create Product
        Product2 testProduct = new Product2(
            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
            Name = 'Test Product',
            Product_Level__c = 'GMID'
        );
        insert testProduct;

        //Create Purchased Product
        PurchasedProduct_R1__c testPurchasedProduct = new PurchasedProduct_R1__c(
            Account_R1__c = testAccount.Id,
            Product_R1__c = testProduct.Id
        );
        insert testPurchasedProduct;

        // Create Total Consumption
        Total_Consumption__c testTotalConsumption = new Total_Consumption__c(
            Purchased_Product__c = testPurchasedProduct.Id,
            Ship_To__c = testAccount.Id,
            Product__c = testProduct.Id,
            Year__c = string.valueOf(system.today().year() - 1),
            Consumption__c = 250000
        );
        insert testTotalConsumption;

        // Create Consumption Share
        Consumption_Share__c testConsumptionShare = new Consumption_Share__c();
        testConsumptionShare.Consumption_ShareOfWallet__c = testTotalConsumption.Id;
        testConsumptionShare.Seller_Account_SOW__c = testAccount.Id;
        testConsumptionShare.Share_Amount__c = 25000;
        testConsumptionShare.Share_Percent__c = 15;
        insert testConsumptionShare;

        Test.startTest();
        DuplicateConsumptionRecordsBatch b = new DuplicateConsumptionRecordsBatch();
        Database.executeBatch(b, 200);
        Test.stopTest();
    }
    
    
    testMethod static void testConstructorWithParams() {
        //Create Horizon Year
        Horizon_Year__c hz = new Horizon_Year__c();
        hz.Name = 'Default';
        hz.Year__c = System.today().year();
        insert hz;
        
        // Create Account
        Account testAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Competitor').getRecordTypeId(),
            Name = 'Test Account',
            AccountNumber_R1__c = '123123'
        );
        insert testAccount;

        //Create Product
        Product2 testProduct = new Product2(
            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
            Name = 'Test Product',
            Product_Level__c = 'GMID'
        );
        insert testProduct;

        //Create Purchased Product
        PurchasedProduct_R1__c testPurchasedProduct = new PurchasedProduct_R1__c(
            Account_R1__c = testAccount.Id,
            Product_R1__c = testProduct.Id
        );
        insert testPurchasedProduct;

        // Create Total Consumption
        Total_Consumption__c testTotalConsumption = new Total_Consumption__c(
            Purchased_Product__c = testPurchasedProduct.Id,
            Ship_To__c = testAccount.Id,
            Product__c = testProduct.Id,
            Year__c = string.valueOf(system.today().year()),
            Consumption__c = 250000
        );
        insert testTotalConsumption;

        // Create Consumption Share
        Consumption_Share__c testConsumptionShare = new Consumption_Share__c();
        testConsumptionShare.Consumption_ShareOfWallet__c = testTotalConsumption.Id;
        testConsumptionShare.Seller_Account_SOW__c = testAccount.Id;
        testConsumptionShare.Share_Amount__c = 25000;
        testConsumptionShare.Share_Percent__c = 15;
        insert testConsumptionShare;
        
        Test.startTest();
		DuplicateConsumptionRecordsBatch b = new DuplicateConsumptionRecordsBatch(System.today().year(), System.today().year() + 1);
        Database.executeBatch(b, 200);
        Test.stopTest();
    }
    
    testMethod static void testConstructorWithParamsForAlreadyExistingConsumption() {
        //Create Horizon Year
        Horizon_Year__c hz = new Horizon_Year__c();
        hz.Name = 'Default';
        hz.Year__c = System.today().year() + 1;
        insert hz;
        
        // Create Account
        Account testAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Competitor').getRecordTypeId(),
            Name = 'Test Account',
            AccountNumber_R1__c = '123123'
        );
        insert testAccount;
        
        // Create Account for another share
        Account testAccount2 = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Competitor').getRecordTypeId(),
            Name = 'Test Account 2',
            AccountNumber_R1__c = '123456'
        );
        insert testAccount2;

        //Create Product
        Product2 testProduct = new Product2(
            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
            Name = 'Test Product',
            Product_Level__c = 'GMID'
        );
        insert testProduct;

        //Create Purchased Product
        PurchasedProduct_R1__c testPurchasedProduct = new PurchasedProduct_R1__c(
            Account_R1__c = testAccount.Id,
            Product_R1__c = testProduct.Id
        );
        insert testPurchasedProduct;

        // Create Total Consumption for current Year
        Total_Consumption__c testTotalConsumption = new Total_Consumption__c(
            Purchased_Product__c = testPurchasedProduct.Id,
            Ship_To__c = testAccount.Id,
            Product__c = testProduct.Id,
            Year__c = string.valueOf(system.today().year()),
            Consumption__c = 250000
        );
        insert testTotalConsumption;

        // Create Consumption Share for current year's consumption
        Consumption_Share__c testConsumptionShare = new Consumption_Share__c();
        testConsumptionShare.Consumption_ShareOfWallet__c = testTotalConsumption.Id;
        testConsumptionShare.Seller_Account_SOW__c = testAccount.Id;
        testConsumptionShare.Share_Amount__c = 25000;
        testConsumptionShare.Share_Percent__c = 15;
        insert testConsumptionShare;
        
        // Create Consumption Share for current year's consumption, other account
        Consumption_Share__c testConsumptionShare2 = new Consumption_Share__c();
        testConsumptionShare2.Consumption_ShareOfWallet__c = testTotalConsumption.Id;
        testConsumptionShare2.Seller_Account_SOW__c = testAccount2.Id;
        testConsumptionShare2.Share_Amount__c = 25000;
        testConsumptionShare2.Share_Percent__c = 15;
        insert testConsumptionShare2;
        
        // Create Total Consumption for next year
        Total_Consumption__c testTotalConsumptionNextYear = new Total_Consumption__c(
            Purchased_Product__c = testPurchasedProduct.Id,
            Ship_To__c = testAccount.Id,
            Product__c = testProduct.Id,
            Year__c = string.valueOf(system.today().year() + 1),
            Consumption__c = 250000
        );
        insert testTotalConsumptionNextYear;

        // Create Consumption Share for next year's consumption
        Consumption_Share__c testConsumptionShareNextYear = new Consumption_Share__c();
        testConsumptionShareNextYear.Consumption_ShareOfWallet__c = testTotalConsumptionNextYear.Id;
        testConsumptionShareNextYear.Seller_Account_SOW__c = testAccount.Id;
        testConsumptionShareNextYear.Share_Amount__c = 25000;
        testConsumptionShareNextYear.Share_Percent__c = 15;
        insert testConsumptionShareNextYear;
        

        Test.startTest();
		DuplicateConsumptionRecordsBatch b = new DuplicateConsumptionRecordsBatch(System.today().year(), System.today().year() + 1);
        Database.executeBatch(b, 200);
        Test.stopTest();
    }
    
}