@isTest
public class ShareOfWalletDataCreationBatch_Test {
    
    static testMethod void testBatch(){
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
        //insert soldToAccount;
        List<String> soldToAccList = new List<String>();
        soldToAccList.add(soldToAccount.Id);
        
        Account shipToAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
            Name = 'First Ship To Account',
            AccountNumber_R1__c = '267687',
            Ship_To__c = true,
            ParentId = soldToAccList[0]
        );
        insert shipToAccount;
        
        // Crete Account Relationship
        Account_Relationships__c testAccountRel = new Account_Relationships__c(
            Name = 'Test Account Relationship',
            Relationship_Type__c = 'Sold To / Ship To',
            Sold_To__c = soldToAccList[0],
            Ship_To__c = shipToAccount.Id
        );
        insert testAccountRel;
        
        //Create Product
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
        ShareOfWalletDataCreationBatch batch = new ShareOfWalletDataCreationBatch(new List<String>{'2021', '2022', '2023', '2024', '2025'}, null);
        batch.initiateConsumptionForYear(lstTestPurchasedProduct[0].Id, '2021');
        Database.executeBatch(batch);
    }
}