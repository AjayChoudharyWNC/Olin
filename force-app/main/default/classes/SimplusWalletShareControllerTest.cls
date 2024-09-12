@isTest
public class SimplusWalletShareControllerTest {
    testMethod static void testMethods() {
        //Create Horizon Year
        Horizon_Year__c hz = new Horizon_Year__c();
        hz.Name = 'Default';
        hz.Year__c = System.today().year() + 1;
        insert hz;
        
        // Create Account
        Account testAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Competitor').getRecordTypeId(),
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

        Account testOlinAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Competitor').getRecordTypeId(),
            Name = 'Olin Corporation',
            AccountNumber_R1__c = '12345'
        );
        insert testOlinAccount;

        // Create Sold To and Ship To Account
        Account soldToAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
            Name = 'Sold To Account',
            AccountNumber_R1__c = '267687',
            Ship_To__c = true,
            Sold_To__c = true
        );
        insert soldToAccount;
        
        Account shipToAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
            Name = 'First Ship To Account',
            AccountNumber_R1__c = '267687',
            Ship_To__c = true,
            ParentId = soldToAccount.Id
        );
        insert shipToAccount;

        // Crete Account Relationship
        Account_Relationships__c testAccountRel = new Account_Relationships__c(
            Name = 'Test Account Relationship',
            Relationship_Type__c = 'Sold To / Ship To',
            Sold_To__c = soldToAccount.Id,
            Ship_To__c = shipToAccount.Id
        );
        insert testAccountRel;

        //Create Product
        Product2 testProduct = new Product2(
            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
            Name = 'Test Product',
            Product_Level__c = 'GMID'
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

        //Create Consumption Share
        List<Consumption_Share__c> lstTestConsumptionShare = new List<Consumption_Share__c>();
        List<String> lstTestConsumptionShareId = new List<String>();
        Consumption_Share__c testConsumptionShare = new Consumption_Share__c();
        testConsumptionShare.Consumption_ShareOfWallet__c = lstTestTotalConsumption[0].Id;
        testConsumptionShare.Seller_Account_SOW__c = testUnknownAccount.Id;
        testConsumptionShare.Share_Amount__c = 25000;
        testConsumptionShare.Share_Percent__c = 15;
        lstTestConsumptionShare.add(testConsumptionShare);

        testConsumptionShare = new Consumption_Share__c();
        testConsumptionShare.Consumption_ShareOfWallet__c = lstTestTotalConsumption[0].Id;
        testConsumptionShare.Seller_Account_SOW__c = testOlinAccount.Id;
        testConsumptionShare.Share_Amount__c = 25000;
        testConsumptionShare.Share_Percent__c = 15;
        lstTestConsumptionShare.add(testConsumptionShare);

        testConsumptionShare = new Consumption_Share__c();
        testConsumptionShare.Consumption_ShareOfWallet__c = lstTestTotalConsumption[1].Id;
        testConsumptionShare.Seller_Account_SOW__c = testAccount.Id;
        testConsumptionShare.Share_Amount__c = 35000;
        testConsumptionShare.Share_Percent__c = 5;
        lstTestConsumptionShare.add(testConsumptionShare);
        insert lstTestConsumptionShare;
        lstTestConsumptionShareId.add(testConsumptionShare.Id);

        List<String> fieldSetValues = new List<String>();
        SObjectType objToken = Schema.getGlobalDescribe().get('Consumption_Share__c');
        Schema.DescribeSObjectResult d = objToken.getDescribe();
        Map<String, Schema.FieldSet> FsMap = d.fieldSets.getMap();
        if(FsMap.containsKey('SimplusWalletShare')){
            for(Schema.FieldSetMember f : FsMap.get('SimplusWalletShare').getFields()) {
                fieldSetValues.add(f.getFieldPath());
            }
        }

        SimplusWalletShareController.getLimitDate();
        SimplusWalletShareController.getFieldSet('Consumption_Share__c', 'SimplusWalletShare');
        SimplusWalletShareController.getRecords('Consumption_Share__c', lstTestConsumptionShare[0].Id, JSON.serialize(fieldSetValues));
        SimplusWalletShareController.getRecords('Consumption_Share__c', lstTestConsumptionShare[1].Id, JSON.serialize(fieldSetValues));
        SimplusWalletShareController.getRecords('Consumption_Share__c', lstTestConsumptionShare[2].Id, JSON.serialize(fieldSetValues));
        SimplusWalletShareController.getRecords('Consumption_Share__c', lstTestTotalConsumption[0].Id, JSON.serialize(fieldSetValues));
        SimplusWalletShareController.getConsumptionShares(lstTestPurchasedProduct[0].Id);
        SimplusWalletShareController.updateGridRecord(lstTestConsumptionShare[0]);
        SimplusWalletShareController.updateGridRecords(JSON.serialize(lstTestConsumptionShare));
        SimplusWalletShareController.updateRecords(lstTestTotalConsumption[0], JSON.serialize(lstTestConsumptionShare), new List<String>{lstTestConsumptionShare[0].Id});
        //delete lstTestConsumptionShare;
        SimplusWalletShareController.getConsumptionShares(lstTestPurchasedProduct[0].Id);
        //SimplusWalletShareController.initiateConsumptionForYear(lstTestPurchasedProduct[1]);
    }

    testMethod static void testUnknowns() {
        //Create Horizon Year
        Horizon_Year__c hz = new Horizon_Year__c();
        hz.Name = 'Default';
        hz.Year__c = System.today().year() + 1;
        insert hz;
        
        // Create Account
        Account testAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Competitor').getRecordTypeId(),
            Name = 'Test Account'
        );
        insert testAccount;

        Account testUnknownAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Competitor').getRecordTypeId(),
            Name = 'UNKNOWN'
        );
        insert testUnknownAccount;

        //Create Product
        Product2 testProduct = new Product2(
            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
            Name = 'Test Product',
            Product_Level__c = 'GMID'
        );
        insert testProduct;

        //Create Purchased Product
        PurchasedProduct_R1__c testPurchasedProduct = new PurchasedProduct_R1__c(
            Account_R1__c = testUnknownAccount.Id,
            Product_R1__c = testProduct.Id
        );
        insert testPurchasedProduct;

        Integer currentYear = Date.today().year();
        //Create Total Consumption
        Total_Consumption__c testTotalConsumption = new Total_Consumption__c(
            Purchased_Product__c = testPurchasedProduct.Id,
            Year__c = '2018',
            Consumption__c = 250000,
            UnknownAmount__c = 15000,
            UnknownPercent__c = 10
        );
        insert testTotalConsumption;

        //Create Consumption Share
        List<Consumption_Share__c> lstTestConsumptionShare = new List<Consumption_Share__c>();
        List<String> lstTestConsumptionShareId = new List<String>();
        Consumption_Share__c testConsumptionShare = new Consumption_Share__c();
        testConsumptionShare.Consumption_ShareOfWallet__c = testTotalConsumption.Id;
        testConsumptionShare.Seller_Account_SOW__c = testUnknownAccount.Id;
        testConsumptionShare.Share_Amount__c = 25000;
        testConsumptionShare.Share_Percent__c = 15;
        lstTestConsumptionShare.add(testConsumptionShare);

        testConsumptionShare = new Consumption_Share__c();
        testConsumptionShare.Consumption_ShareOfWallet__c = testTotalConsumption.Id;
        testConsumptionShare.Seller_Account_SOW__c = testAccount.Id;
        testConsumptionShare.Share_Amount__c = 35000;
        testConsumptionShare.Share_Percent__c = 5;
        lstTestConsumptionShare.add(testConsumptionShare);
        insert lstTestConsumptionShare;
        lstTestConsumptionShareId.add(testConsumptionShare.Id);

        SimplusWalletShareController.getConsumptionShares(testPurchasedProduct.Id);
    }

}