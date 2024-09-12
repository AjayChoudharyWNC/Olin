@isTest
public class CalculateConsumptionRecordsTest {
    testMethod static void testSchedClass() {
        //Create Horizon Year
        Horizon_Year__c hz = new Horizon_Year__c();
        hz.Name = 'Default';
        hz.Year__c = System.today().year() + 1;
        insert hz;
        
        // Create Account
        Account testAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
            Name = 'Test Account',
            AccountNumber_R1__c = '2676875',
            Sold_To__c = true,
            Ship_To__c = true,
            Status_R1__c = 'Active'
            
        );
        insert testAccount;
        
        Account testUnknownAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Olin Corp').getRecordTypeId(),
            Name = 'UNKNOWN',
            AccountNumber_R1__c = '267687'
        );
        insert testUnknownAccount;
        
        // Create Account Relationship
        Account_Relationships__c testAccountRel = new Account_Relationships__c(
            Name = 'Test Account Relationship',
            Relationship_Type__c = 'Sold To / Ship To',
            Sold_To__c = testAccount.Id,
            Ship_To__c = testAccount.Id
        );
        
        insert testAccountRel;      
        
        
        //Create Product
        Product2 testProduct = new Product2(
            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
            Name = 'Test Product',
            TradeProduct_R1__c = '123456',
            Product_Level__c = 'GMID',
            IsActive = true
        );
        insert testProduct;
        
        //Create Purchased Product
        PurchasedProduct_R1__c testPurchasedProduct = new PurchasedProduct_R1__c(
            Account_R1__c = testAccount.Id,
            Ship_To__c = testAccount.Id,
            Product_R1__c = testProduct.Id,
            Account_Relationship__c = testAccountRel.Id
        );
        insert testPurchasedProduct;
        
        // Create Total Consumption
        Total_Consumption__c testTotalConsumption = new Total_Consumption__c(
            Purchased_Product__c = testPurchasedProduct.Id,
            Ship_To__c = testAccount.Id,
            Product__c = testProduct.Id,
            Year__c = String.valueOf(Date.today().year() - 1),
            Consumption__c = 250000
        );
        insert testTotalConsumption;
        
        // Create Consumption Share
        List<Consumption_Share__c> lstTestConsumptionShare = new List<Consumption_Share__c>();
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
        
        // Create SF STAGE SALES 
        SF_STAGE_SALES__c testSfStageSales = new SF_STAGE_SALES__c(
            SHIP_TO_PARTY__c = '2676875',
            SOLD_TO_PARTY__c = '267687', 
            TRADE_PRODUCT_MAT__c= '123456', 
            VOLUME_IN_BASEUOM__c= 50000, 
            CALENDAR_YEAR_IMP__c = '2018', 
            CALENDAR_MONTH_IMP__c = '01',
            CUSTOMER__c = '2676875'
        );
        insert testSfStageSales;
        
        Test.startTest();
        CalculateConsumptionRecordsSched sh1 = new CalculateConsumptionRecordsSched();
        String sch = '0 0 0 1/1 * ? *'; 
        system.schedule('Test Share of Wallet Actuals', sch, sh1);
        Test.stopTest();
    }
    
    testMethod static void forceEmptyVolumeOnStageSales() {
        //Create Horizon Year
        Horizon_Year__c hz = new Horizon_Year__c();
        hz.Name = 'Default';
        hz.Year__c = System.today().year() + 1;
        insert hz;
        
        // Create Olin Account
        Account olincAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Olin Corp').getRecordTypeId(),
            Name = 'Olin Corp',
            AccountNumber_R1__c = '111111'
        );
        insert olincAccount;
        
        // Create Account
        Account testAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
            Name = 'Test Account',
            AccountNumber_R1__c = '222222',
            Area_R1__c = 'TEST',
            Sold_To__c = true,
            Ship_To__c = true,
            Status_R1__c = 'Active'
        );
        insert testAccount;
        
        // Create Account Relationship
        Account_Relationships__c testAccountRel = new Account_Relationships__c(
            Name = 'Test Account Relationship',
            Relationship_Type__c = 'Sold To / Ship To',
            Sold_To__c = testAccount.Id,
            Ship_To__c = testAccount.Id
        ); 
        
        insert testAccountRel;  
        
        
        Account testUnknownAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Competitor').getRecordTypeId(),
            Name = 'UNKNOWN',
            AccountNumber_R1__c = '333333'
        );
        insert testUnknownAccount;
        
        //Create Product
        Product2 testProduct = new Product2(
            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
            Name = 'Test Product',
            Gmid_Number__c = '55555',
            Product_Level__c = 'GMID',
            Business_Group__c = 'OCAV',
            PH1_Performance_Center__c = 'BLEACH',
            IsActive = true
        );
        insert testProduct;
        
        //Create Purchased Product
        PurchasedProduct_R1__c testPurchasedProduct = new PurchasedProduct_R1__c(
            Account_R1__c = testAccount.Id,
            Ship_To__c = olincAccount.Id,
            Product_R1__c = testProduct.Id,
            Account_Relationship__c = testAccountRel.Id
        );
        insert testPurchasedProduct;
        
        // Create Total Consumption
        Total_Consumption__c testTotalConsumption = new Total_Consumption__c(
            Purchased_Product__c = testPurchasedProduct.Id,
            Ship_To__c = testAccount.Id,
            Product__c = testProduct.Id,
            Year__c = String.valueOf(Date.today().year()),
            Consumption__c = 100000
        );
        insert testTotalConsumption;
        
        // Create Consumption Shares
        List<Consumption_Share__c> lstTestConsumptionShare = new List<Consumption_Share__c>();
        
        //Olin
        Consumption_Share__c testConsumptionShareOlin = new Consumption_Share__c();
        testConsumptionShareOlin.Consumption_ShareOfWallet__c = testTotalConsumption.Id;
        testConsumptionShareOlin.Seller_Account_SOW__c = olincAccount.Id;
        testConsumptionShareOlin.Share_Amount__c = 50000;
        testConsumptionShareOlin.Share_Percent__c = 50;
        lstTestConsumptionShare.add(testConsumptionShareOlin);
        
        //Other account
        Consumption_Share__c testConsumptionShare = new Consumption_Share__c();
        testConsumptionShare.Consumption_ShareOfWallet__c = testTotalConsumption.Id;
        testConsumptionShare.Seller_Account_SOW__c = testUnknownAccount.Id;
        testConsumptionShare.Share_Amount__c = 25000;
        testConsumptionShare.Share_Percent__c = 15;
        lstTestConsumptionShare.add(testConsumptionShare);
        
        //Unknown
        testConsumptionShare = new Consumption_Share__c();
        testConsumptionShare.Consumption_ShareOfWallet__c = testTotalConsumption.Id;
        testConsumptionShare.Seller_Account_SOW__c = testAccount.Id;
        testConsumptionShare.Share_Amount__c = 35000;
        testConsumptionShare.Share_Percent__c = 5;
        lstTestConsumptionShare.add(testConsumptionShare);
        insert lstTestConsumptionShare;
        
        // Create SF STAGE SALES 
        SF_STAGE_SALES__c testSfStageSales = new SF_STAGE_SALES__c(
            CUSTOMER__c = '222222',
            SHIP_TO_PARTY__c = '111111',
            GMID__c = '55555',            
            FISCAL_YEAR__c = '2021'
        );
        insert testSfStageSales;
        
        Test.startTest();
        CalculateConsumptionRecordsBatch b = new CalculateConsumptionRecordsBatch();
        Database.executeBatch(b, 200);
        Test.stopTest();
    }
    
    
    testMethod static void testZeroShareAmount() {
        //Create Horizon Year
        Horizon_Year__c hz = new Horizon_Year__c();
        hz.Name = 'Default';
        hz.Year__c = System.today().year() + 1;
        insert hz;
        
        // Create Olin Account
        Account olincAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Olin Corp').getRecordTypeId(),
            Name = 'Olin Corp',
            AccountNumber_R1__c = '111111'
        );
        insert olincAccount;
        
        // Create Account
        Account testAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
            Name = 'Test Account',
            AccountNumber_R1__c = '222222',
            Area_R1__c = 'TEST',
            Sold_To__c = true,
            Ship_To__c = true,
            Status_R1__c = 'Active'
        );
        insert testAccount;
        
        // Create Account Relationship
        Account_Relationships__c testAccountRel = new Account_Relationships__c(
            Name = 'Test Account Relationship',
            Relationship_Type__c = 'Sold To / Ship To',
            Sold_To__c = testAccount.Id,
            Ship_To__c = testAccount.Id
        );  
        
        insert testAccountRel;
        
        
        Account testUnknownAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Competitor').getRecordTypeId(),
            Name = 'UNKNOWN',
            AccountNumber_R1__c = '333333'
        );
        insert testUnknownAccount;
        
        //Create Product
        Product2 testProduct = new Product2(
            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
            Name = 'Test Product',
            Gmid_Number__c = '55555',
            Product_Level__c = 'GMID',
            Business_Group__c = 'OCAV',
            PH1_Performance_Center__c = 'BLEACH',
            IsActive = true
        );
        insert testProduct;
        
        //Create Purchased Product
        PurchasedProduct_R1__c testPurchasedProduct = new PurchasedProduct_R1__c(
            Account_R1__c = testAccount.Id,
            Ship_To__c = olincAccount.Id,
            Product_R1__c = testProduct.Id,
            Account_Relationship__c = testAccountRel.Id
        );
        insert testPurchasedProduct;
        
        // Create Total Consumption
        Total_Consumption__c testTotalConsumption = new Total_Consumption__c(
            Purchased_Product__c = testPurchasedProduct.Id,
            Ship_To__c = testAccount.Id,
            Product__c = testProduct.Id,
            Year__c = String.valueOf(Date.today().year()),
            Consumption__c = 100000
        );
        insert testTotalConsumption;
        
        // Create Consumption Shares
        List<Consumption_Share__c> lstTestConsumptionShare = new List<Consumption_Share__c>();
        
        //Olin
        Consumption_Share__c testConsumptionShareOlin = new Consumption_Share__c();
        testConsumptionShareOlin.Consumption_ShareOfWallet__c = testTotalConsumption.Id;
        testConsumptionShareOlin.Seller_Account_SOW__c = olincAccount.Id;
        testConsumptionShareOlin.Share_Amount__c = 0;
        testConsumptionShareOlin.Share_Percent__c = 0;
        lstTestConsumptionShare.add(testConsumptionShareOlin);
        
        //Other account
        Consumption_Share__c testConsumptionShare = new Consumption_Share__c();
        testConsumptionShare.Consumption_ShareOfWallet__c = testTotalConsumption.Id;
        testConsumptionShare.Seller_Account_SOW__c = testUnknownAccount.Id;
        testConsumptionShare.Share_Amount__c = 25000;
        testConsumptionShare.Share_Percent__c = 15;
        lstTestConsumptionShare.add(testConsumptionShare);
        
        //Unknown
        testConsumptionShare = new Consumption_Share__c();
        testConsumptionShare.Consumption_ShareOfWallet__c = testTotalConsumption.Id;
        testConsumptionShare.Seller_Account_SOW__c = testAccount.Id;
        testConsumptionShare.Share_Amount__c = 35000;
        testConsumptionShare.Share_Percent__c = 5;
        lstTestConsumptionShare.add(testConsumptionShare);
        insert lstTestConsumptionShare;
        
        // Create SF STAGE SALES 
        SF_STAGE_SALES__c testSfStageSales = new SF_STAGE_SALES__c(
            CUSTOMER__c = '222222',
            SHIP_TO_PARTY__c = '111111',
            GMID__c = '55555',            
            FISCAL_YEAR__c = '2021',
            QUANTITY_SUOM_CAL__c = 50000,
            QUANTITY_GUOM_CAL__c = 50000,
            QUANTITY_CAL_NEW__c = 50000
        );
        insert testSfStageSales;
        
        Test.startTest();
        CalculateConsumptionRecordsBatch b = new CalculateConsumptionRecordsBatch();
        Database.executeBatch(b, 200);
        Test.stopTest();
    }
    
    
    
    //Business_Group__c == 'OCAV' && PH1_Performance_Center__c != 'CAUSTIC'
    testMethod static void testConstructorNoParams01() {
        //Create Horizon Year
        Horizon_Year__c hz = new Horizon_Year__c();
        hz.Name = 'Default';
        hz.Year__c = System.today().year() + 1;
        insert hz;
        
        // Create Olin Account
        Account olincAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Olin Corp').getRecordTypeId(),
            Name = 'Olin Corp',
            AccountNumber_R1__c = '111111'
        );
        insert olincAccount;
        
        // Create Account
        Account testAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
            Name = 'Test Account',
            AccountNumber_R1__c = '222222',
            Area_R1__c = 'TEST',
            Sold_To__c = true,
            Ship_To__c = true,
            Status_R1__c = 'Active'
        );
        insert testAccount;
        
        // Create Account Relationship
        Account_Relationships__c testAccountRel = new Account_Relationships__c(
            Name = 'Test Account Relationship',
            Relationship_Type__c = 'Sold To / Ship To',
            Sold_To__c = testAccount.Id,
            Ship_To__c = testAccount.Id
        );  
        
        insert testAccountRel;
        
        Account testUnknownAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Competitor').getRecordTypeId(),
            Name = 'UNKNOWN',
            AccountNumber_R1__c = '333333'
        );
        insert testUnknownAccount;
        
        //Create Product
        Product2 testProduct = new Product2(
            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
            Name = 'Test Product',
            Gmid_Number__c = '55555',
            Product_Level__c = 'GMID',
            Business_Group__c = 'OCAV',
            PH1_Performance_Center__c = 'BLEACH',
            IsActive = true
        );
        insert testProduct;
        
        //Create Purchased Product
        PurchasedProduct_R1__c testPurchasedProduct = new PurchasedProduct_R1__c(
            Account_R1__c = testAccount.Id,
            Ship_To__c = olincAccount.Id,
            Product_R1__c = testProduct.Id,
            Account_Relationship__c = testAccountRel.Id
        );
        insert testPurchasedProduct;
        
        // Create Total Consumption
        Total_Consumption__c testTotalConsumption = new Total_Consumption__c(
            Purchased_Product__c = testPurchasedProduct.Id,
            Ship_To__c = testAccount.Id,
            Product__c = testProduct.Id,
            Year__c = String.valueOf(Date.today().year()),
            Consumption__c = 100000
        );
        insert testTotalConsumption;
        
        // Create Consumption Shares
        List<Consumption_Share__c> lstTestConsumptionShare = new List<Consumption_Share__c>();
        
        //Olin
        Consumption_Share__c testConsumptionShareOlin = new Consumption_Share__c();
        testConsumptionShareOlin.Consumption_ShareOfWallet__c = testTotalConsumption.Id;
        testConsumptionShareOlin.Seller_Account_SOW__c = olincAccount.Id;
        testConsumptionShareOlin.Share_Amount__c = 50000;
        testConsumptionShareOlin.Share_Percent__c = 50;
        lstTestConsumptionShare.add(testConsumptionShareOlin);
        
        //Other account
        Consumption_Share__c testConsumptionShare = new Consumption_Share__c();
        testConsumptionShare.Consumption_ShareOfWallet__c = testTotalConsumption.Id;
        testConsumptionShare.Seller_Account_SOW__c = testUnknownAccount.Id;
        testConsumptionShare.Share_Amount__c = 25000;
        testConsumptionShare.Share_Percent__c = 15;
        lstTestConsumptionShare.add(testConsumptionShare);
        
        //Unknown
        testConsumptionShare = new Consumption_Share__c();
        testConsumptionShare.Consumption_ShareOfWallet__c = testTotalConsumption.Id;
        testConsumptionShare.Seller_Account_SOW__c = testAccount.Id;
        testConsumptionShare.Share_Amount__c = 35000;
        testConsumptionShare.Share_Percent__c = 5;
        lstTestConsumptionShare.add(testConsumptionShare);
        insert lstTestConsumptionShare;
        
        // Create SF STAGE SALES 
        SF_STAGE_SALES__c testSfStageSales = new SF_STAGE_SALES__c(
            CUSTOMER__c = '222222',
            SHIP_TO_PARTY__c = '111111',
            GMID__c = '55555',            
            FISCAL_YEAR__c = '2021',
            QUANTITY_SUOM_CAL__c = 50000,
            QUANTITY_GUOM_CAL__c = 50000,
            QUANTITY_CAL_NEW__c = 50000
        );
        insert testSfStageSales;
        
        Test.startTest();
        CalculateConsumptionRecordsBatch b = new CalculateConsumptionRecordsBatch();
        Database.executeBatch(b, 200);
        Test.stopTest();
    }
    
    //Business_Group__c == 'OCAV' && PH1_Performance_Center__c == 'CAUSTIC' && Area_R1__c == 'North America'
    testMethod static void testConstructorNoParams02() {
        //Create Horizon Year
        Horizon_Year__c hz = new Horizon_Year__c();
        hz.Name = 'Default';
        hz.Year__c = System.today().year() + 1;
        insert hz;
        
        // Create Olin Account
        Account olincAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Olin Corp').getRecordTypeId(),
            Name = 'Olin Corp',
            AccountNumber_R1__c = '111111'
        );
        insert olincAccount;
        
        // Create Account
        Account testAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
            Name = 'Test Account',
            AccountNumber_R1__c = '222222',
            Area_R1__c = 'NORTH AMERICA',
            Sold_To__c = true,
            Ship_To__c = true,
            Status_R1__c = 'Active'
        );
        insert testAccount;
        
        // Create Account Relationship
        Account_Relationships__c testAccountRel = new Account_Relationships__c(
            Name = 'Test Account Relationship',
            Relationship_Type__c = 'Sold To / Ship To',
            Sold_To__c = testAccount.Id,
            Ship_To__c = testAccount.Id
        );  
        
        insert testAccountRel;
        
        Account testUnknownAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Competitor').getRecordTypeId(),
            Name = 'UNKNOWN',
            AccountNumber_R1__c = '333333'
        );
        insert testUnknownAccount;
        
        //Create Product
        Product2 testProduct = new Product2(
            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
            Name = 'Test Product',
            Gmid_Number__c = '55555',
            Product_Level__c = 'GMID',
            Business_Group__c = 'OCAV',
            PH1_Performance_Center__c = 'CAUSTIC',
            IsActive = true
        );
        insert testProduct;
        
        //Create Purchased Product
        PurchasedProduct_R1__c testPurchasedProduct = new PurchasedProduct_R1__c(
            Account_R1__c = testAccount.Id,
            Ship_To__c = olincAccount.Id,
            Product_R1__c = testProduct.Id,
            Account_Relationship__c = testAccountRel.Id
        );
        insert testPurchasedProduct;
        
        testAccount.Area_R1__c = 'NORTH AMERICA';
        update testAccount;
        
        PurchasedProduct_R1__c pp = [SELECT Id, Account_R1__r.Name, Account_R1__r.Area_R1__c FROM PurchasedProduct_R1__c WHERE Id =: testPurchasedProduct.Id];
        System.debug('IMPORTANT: ACCOUNT R1: ' + pp.Account_R1__c);
        System.debug('IMPORTANT: ACCOUNT R1 NAME: ' + pp.Account_R1__r.Name);
        System.debug('IMPORTANT: AREA R1 QUERY: ' + pp.Account_R1__r.Area_R1__c);
        
        // Create Total Consumption
        Total_Consumption__c testTotalConsumption = new Total_Consumption__c(
            Purchased_Product__c = testPurchasedProduct.Id,
            Ship_To__c = testAccount.Id,
            Product__c = testProduct.Id,
            Year__c = String.valueOf(Date.today().year()),
            Consumption__c = 100000
        );
        insert testTotalConsumption;
        
        // Create Consumption Shares
        List<Consumption_Share__c> lstTestConsumptionShare = new List<Consumption_Share__c>();
        
        //Olin
        Consumption_Share__c testConsumptionShareOlin = new Consumption_Share__c();
        testConsumptionShareOlin.Consumption_ShareOfWallet__c = testTotalConsumption.Id;
        testConsumptionShareOlin.Seller_Account_SOW__c = olincAccount.Id;
        testConsumptionShareOlin.Share_Amount__c = 50000;
        testConsumptionShareOlin.Share_Percent__c = 50;
        lstTestConsumptionShare.add(testConsumptionShareOlin);
        
        //Other account
        Consumption_Share__c testConsumptionShare = new Consumption_Share__c();
        testConsumptionShare.Consumption_ShareOfWallet__c = testTotalConsumption.Id;
        testConsumptionShare.Seller_Account_SOW__c = testUnknownAccount.Id;
        testConsumptionShare.Share_Amount__c = 25000;
        testConsumptionShare.Share_Percent__c = 15;
        lstTestConsumptionShare.add(testConsumptionShare);
        
        //Unknown
        testConsumptionShare = new Consumption_Share__c();
        testConsumptionShare.Consumption_ShareOfWallet__c = testTotalConsumption.Id;
        testConsumptionShare.Seller_Account_SOW__c = testAccount.Id;
        testConsumptionShare.Share_Amount__c = 35000;
        testConsumptionShare.Share_Percent__c = 5;
        lstTestConsumptionShare.add(testConsumptionShare);
        insert lstTestConsumptionShare;
        
        // Create SF STAGE SALES 
        SF_STAGE_SALES__c testSfStageSales = new SF_STAGE_SALES__c(
            CUSTOMER__c = '222222',
            SHIP_TO_PARTY__c = '111111',
            GMID__c = '55555',            
            FISCAL_YEAR__c = '2021',
            QUANTITY_SUOM_CAL__c = 50000,
            QUANTITY_GUOM_CAL__c = 50000,
            QUANTITY_CAL_NEW__c = 50000
        );
        insert testSfStageSales;
        
        Test.startTest();
        CalculateConsumptionRecordsBatch b = new CalculateConsumptionRecordsBatch();
        Database.executeBatch(b, 200);
        Test.stopTest();
    }
    
    //Business_Group__c == 'OCAV' && PH1_Performance_Center__c == 'CAUSTIC' && Area_R1__c != 'North America'
    testMethod static void testConstructorNoParams03() {
        //Create Horizon Year
        Horizon_Year__c hz = new Horizon_Year__c();
        hz.Name = 'Default';
        hz.Year__c = System.today().year() + 1;
        insert hz;
        
        // Create Olin Account
        Account olincAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Olin Corp').getRecordTypeId(),
            Name = 'Olin Corp',
            AccountNumber_R1__c = '111111'
        );
        insert olincAccount;
        
        // Create Account
        Account testAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
            Name = 'Test Account',
            AccountNumber_R1__c = '222222',
            Area_R1__c = 'TEST',
            Sold_To__c = true,
            Ship_To__c = true,
            Status_R1__c = 'Active'
        );
        insert testAccount;
        
        // Create Account Relationship
        Account_Relationships__c testAccountRel = new Account_Relationships__c(
            Name = 'Test Account Relationship',
            Relationship_Type__c = 'Sold To / Ship To',
            Sold_To__c = testAccount.Id,
            Ship_To__c = testAccount.Id
        ); 
        
        insert testAccountRel; 
        
        Account testUnknownAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Competitor').getRecordTypeId(),
            Name = 'UNKNOWN',
            AccountNumber_R1__c = '333333'
        );
        insert testUnknownAccount;
        
        //Create Product
        Product2 testProduct = new Product2(
            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
            Name = 'Test Product',
            Gmid_Number__c = '55555',
            Product_Level__c = 'GMID',
            Business_Group__c = 'OCAV',
            PH1_Performance_Center__c = 'CAUSTIC',
            IsActive = true
        );
        insert testProduct;
        
        //Create Purchased Product
        PurchasedProduct_R1__c testPurchasedProduct = new PurchasedProduct_R1__c(
            Account_R1__c = testAccount.Id,
            Ship_To__c = olincAccount.Id,
            Product_R1__c = testProduct.Id,
            Account_Relationship__c = testAccountRel.Id
        );
        insert testPurchasedProduct;
        
        // Create Total Consumption
        Total_Consumption__c testTotalConsumption = new Total_Consumption__c(
            Purchased_Product__c = testPurchasedProduct.Id,
            Ship_To__c = testAccount.Id,
            Product__c = testProduct.Id,
            Year__c = String.valueOf(Date.today().year()),
            Consumption__c = 100000
        );
        insert testTotalConsumption;
        
        // Create Consumption Shares
        List<Consumption_Share__c> lstTestConsumptionShare = new List<Consumption_Share__c>();
        
        //Olin
        Consumption_Share__c testConsumptionShareOlin = new Consumption_Share__c();
        testConsumptionShareOlin.Consumption_ShareOfWallet__c = testTotalConsumption.Id;
        testConsumptionShareOlin.Seller_Account_SOW__c = olincAccount.Id;
        testConsumptionShareOlin.Share_Amount__c = 50000;
        testConsumptionShareOlin.Share_Percent__c = 50;
        lstTestConsumptionShare.add(testConsumptionShareOlin);
        
        //Other account
        Consumption_Share__c testConsumptionShare = new Consumption_Share__c();
        testConsumptionShare.Consumption_ShareOfWallet__c = testTotalConsumption.Id;
        testConsumptionShare.Seller_Account_SOW__c = testUnknownAccount.Id;
        testConsumptionShare.Share_Amount__c = 25000;
        testConsumptionShare.Share_Percent__c = 15;
        lstTestConsumptionShare.add(testConsumptionShare);
        
        //Unknown
        testConsumptionShare = new Consumption_Share__c();
        testConsumptionShare.Consumption_ShareOfWallet__c = testTotalConsumption.Id;
        testConsumptionShare.Seller_Account_SOW__c = testAccount.Id;
        testConsumptionShare.Share_Amount__c = 35000;
        testConsumptionShare.Share_Percent__c = 5;
        lstTestConsumptionShare.add(testConsumptionShare);
        insert lstTestConsumptionShare;
        
        // Create SF STAGE SALES 
        SF_STAGE_SALES__c testSfStageSales = new SF_STAGE_SALES__c(
            CUSTOMER__c = '222222',
            SHIP_TO_PARTY__c = '111111',
            GMID__c = '55555',            
            FISCAL_YEAR__c = '2021',
            QUANTITY_SUOM_CAL__c = 50000,
            QUANTITY_GUOM_CAL__c = 50000,
            QUANTITY_CAL_NEW__c = 50000
        );
        insert testSfStageSales;
        
        Test.startTest();
        CalculateConsumptionRecordsBatch b = new CalculateConsumptionRecordsBatch();
        Database.executeBatch(b, 200);
        Test.stopTest();
    }
    
    //Business_Group__c == 'GCO' && Area_R1__c != 'North America'
    testMethod static void testConstructorNoParams04() {
        //Create Horizon Year
        Horizon_Year__c hz = new Horizon_Year__c();
        hz.Name = 'Default';
        hz.Year__c = System.today().year() + 1;
        insert hz;
        
        // Create Olin Account
        Account olincAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Olin Corp').getRecordTypeId(),
            Name = 'Olin Corp',
            AccountNumber_R1__c = '111111'
        );
        insert olincAccount;
        
        // Create Account
        Account testAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
            Name = 'Test Account',
            AccountNumber_R1__c = '222222',
            Area_R1__c = 'North America',
            Sold_To__c = true,
            Ship_To__c = true,
            Status_R1__c = 'Active'
        );
        insert testAccount;
        
        // Create Account Relationship
        Account_Relationships__c testAccountRel = new Account_Relationships__c(
            Name = 'Test Account Relationship',
            Relationship_Type__c = 'Sold To / Ship To',
            Sold_To__c = testAccount.Id,
            Ship_To__c = testAccount.Id
        ); 
        
        insert testAccountRel; 
        
        Account testUnknownAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Competitor').getRecordTypeId(),
            Name = 'UNKNOWN',
            AccountNumber_R1__c = '333333'
        );
        insert testUnknownAccount;
        
        //Create Product
        Product2 testProduct = new Product2(
            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
            Name = 'Test Product',
            Gmid_Number__c = '55555',
            Product_Level__c = 'GMID',
            Business_Group__c = 'GCO',
            PH1_Performance_Center__c = 'CAUSTIC',
            IsActive = true
        );
        insert testProduct;
        
        //Create Purchased Product
        PurchasedProduct_R1__c testPurchasedProduct = new PurchasedProduct_R1__c(
            Account_R1__c = testAccount.Id,
            Ship_To__c = olincAccount.Id,
            Product_R1__c = testProduct.Id,
            Account_Relationship__c = testAccountRel.Id
        );
        insert testPurchasedProduct;
        
        // Create Total Consumption
        Total_Consumption__c testTotalConsumption = new Total_Consumption__c(
            Purchased_Product__c = testPurchasedProduct.Id,
            Ship_To__c = testAccount.Id,
            Product__c = testProduct.Id,
            Year__c = String.valueOf(Date.today().year()),
            Consumption__c = 100000
        );
        insert testTotalConsumption;
        
        // Create Consumption Shares
        List<Consumption_Share__c> lstTestConsumptionShare = new List<Consumption_Share__c>();
        
        //Olin
        Consumption_Share__c testConsumptionShareOlin = new Consumption_Share__c();
        testConsumptionShareOlin.Consumption_ShareOfWallet__c = testTotalConsumption.Id;
        testConsumptionShareOlin.Seller_Account_SOW__c = olincAccount.Id;
        testConsumptionShareOlin.Share_Amount__c = 50000;
        testConsumptionShareOlin.Share_Percent__c = 50;
        lstTestConsumptionShare.add(testConsumptionShareOlin);
        
        //Other account
        Consumption_Share__c testConsumptionShare = new Consumption_Share__c();
        testConsumptionShare.Consumption_ShareOfWallet__c = testTotalConsumption.Id;
        testConsumptionShare.Seller_Account_SOW__c = testUnknownAccount.Id;
        testConsumptionShare.Share_Amount__c = 25000;
        testConsumptionShare.Share_Percent__c = 15;
        lstTestConsumptionShare.add(testConsumptionShare);
        
        //Unknown
        testConsumptionShare = new Consumption_Share__c();
        testConsumptionShare.Consumption_ShareOfWallet__c = testTotalConsumption.Id;
        testConsumptionShare.Seller_Account_SOW__c = testAccount.Id;
        testConsumptionShare.Share_Amount__c = 35000;
        testConsumptionShare.Share_Percent__c = 5;
        lstTestConsumptionShare.add(testConsumptionShare);
        insert lstTestConsumptionShare;
        
        // Create SF STAGE SALES 
        SF_STAGE_SALES__c testSfStageSales = new SF_STAGE_SALES__c(
            CUSTOMER__c = '222222',
            SHIP_TO_PARTY__c = '111111',
            GMID__c = '55555',            
            FISCAL_YEAR__c = '2021',
            QUANTITY_SUOM_CAL__c = 50000,
            QUANTITY_GUOM_CAL__c = 50000,
            QUANTITY_CAL_NEW__c = 50000
        );
        insert testSfStageSales;
        
        Test.startTest();
        CalculateConsumptionRecordsBatch b = new CalculateConsumptionRecordsBatch();
        Database.executeBatch(b, 200);
        Test.stopTest();
    }
    
    testMethod static void testConstructorNoParams05() {
        //Create Horizon Year
        Horizon_Year__c hz = new Horizon_Year__c();
        hz.Name = 'Default';
        hz.Year__c = System.today().year() + 1;
        insert hz;
        
        // Create Olin Account
        Account olincAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Olin Corp').getRecordTypeId(),
            Name = 'Olin Corp',
            AccountNumber_R1__c = '111111'
        );
        insert olincAccount;
        
        // Create Account
        Account testAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
            Name = 'Test Account',
            AccountNumber_R1__c = '222222',
            Area_R1__c = 'NORTH AMERICA',
            Sold_To__c = true,
            Ship_To__c = true,
            Status_R1__c = 'Active'
        );
        insert testAccount;
        
        
        // Create Account Relationship
        Account_Relationships__c testAccountRel = new Account_Relationships__c(
            Name = 'Test Account Relationship',
            Relationship_Type__c = 'Sold To / Ship To',
            Sold_To__c = testAccount.Id,
            Ship_To__c = testAccount.Id
        ); 
        
        insert testAccountRel; 
        
        Account testUnknownAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Competitor').getRecordTypeId(),
            Name = 'UNKNOWN',
            AccountNumber_R1__c = '333333'
        );
        insert testUnknownAccount;
        
        //Create Product
        Product2 testProduct = new Product2(
            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
            Name = 'Test Product',
            Gmid_Number__c = '55555',
            Product_Level__c = 'GMID',
            Business_Group__c = 'GCO',
            PH1_Performance_Center__c = 'CAUSTIC',
            IsActive = true
        );
        insert testProduct;
        
        //Create Purchased Product
        PurchasedProduct_R1__c testPurchasedProduct = new PurchasedProduct_R1__c(
            Account_R1__c = testAccount.Id,
            Ship_To__c = olincAccount.Id,
            Product_R1__c = testProduct.Id,
            Account_Relationship__c = testAccountRel.Id
        );
        insert testPurchasedProduct;
        testAccount.Area_R1__c = 'NORTH AMERICA';
        update testAccount;
        // Create Total Consumption
        Total_Consumption__c testTotalConsumption = new Total_Consumption__c(
            Purchased_Product__c = testPurchasedProduct.Id,
            Ship_To__c = testAccount.Id,
            Product__c = testProduct.Id,
            Year__c = String.valueOf(Date.today().year()),
            Consumption__c = 100000
        );
        insert testTotalConsumption;
        
        // Create Consumption Shares
        List<Consumption_Share__c> lstTestConsumptionShare = new List<Consumption_Share__c>();
        
        //Olin
        Consumption_Share__c testConsumptionShareOlin = new Consumption_Share__c();
        testConsumptionShareOlin.Consumption_ShareOfWallet__c = testTotalConsumption.Id;
        testConsumptionShareOlin.Seller_Account_SOW__c = olincAccount.Id;
        testConsumptionShareOlin.Share_Amount__c = 50000;
        testConsumptionShareOlin.Share_Percent__c = 50;
        lstTestConsumptionShare.add(testConsumptionShareOlin);
        
        //Other account
        Consumption_Share__c testConsumptionShare = new Consumption_Share__c();
        testConsumptionShare.Consumption_ShareOfWallet__c = testTotalConsumption.Id;
        testConsumptionShare.Seller_Account_SOW__c = testUnknownAccount.Id;
        testConsumptionShare.Share_Amount__c = 25000;
        testConsumptionShare.Share_Percent__c = 15;
        lstTestConsumptionShare.add(testConsumptionShare);
        
        //Unknown
        testConsumptionShare = new Consumption_Share__c();
        testConsumptionShare.Consumption_ShareOfWallet__c = testTotalConsumption.Id;
        testConsumptionShare.Seller_Account_SOW__c = testAccount.Id;
        testConsumptionShare.Share_Amount__c = 35000;
        testConsumptionShare.Share_Percent__c = 5;
        lstTestConsumptionShare.add(testConsumptionShare);
        insert lstTestConsumptionShare;
        
        // Create SF STAGE SALES 
        SF_STAGE_SALES__c testSfStageSales = new SF_STAGE_SALES__c(
            CUSTOMER__c = '222222',
            SHIP_TO_PARTY__c = '111111',
            GMID__c = '55555',            
            FISCAL_YEAR__c = '2021',
            QUANTITY_SUOM_CAL__c = 50000,
            QUANTITY_GUOM_CAL__c = 50000,
            QUANTITY_CAL_NEW__c = 50000
        );
        insert testSfStageSales;
        
        Test.startTest();
        CalculateConsumptionRecordsBatch b = new CalculateConsumptionRecordsBatch();
        Database.executeBatch(b, 200);
        Test.stopTest();
    }
    testMethod static void testConstructorNoParams06() {
        //Create Horizon Year
        Horizon_Year__c hz = new Horizon_Year__c();
        hz.Name = 'Default';
        hz.Year__c = System.today().year() + 1;
        insert hz;
        
        // Create Olin Account
        Account olincAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Olin Corp').getRecordTypeId(),
            Name = 'Olin Corp',
            AccountNumber_R1__c = '111111'
        );
        insert olincAccount;
        
        // Create Account
        Account testAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
            Name = 'Test Account',
            AccountNumber_R1__c = '222222',
            Sold_To__c = true,
            Ship_To__c = true,
            Status_R1__c = 'Active'
        );
        insert testAccount;
        
        
        // Create Account Relationship
        Account_Relationships__c testAccountRel = new Account_Relationships__c(
            Name = 'Test Account Relationship',
            Relationship_Type__c = 'Sold To / Ship To',
            Sold_To__c = testAccount.Id,
            Ship_To__c = testAccount.Id
        ); 
        
        insert testAccountRel; 
        
        Account testUnknownAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Competitor').getRecordTypeId(),
            Name = 'UNKNOWN',
            AccountNumber_R1__c = '333333'
        );
        insert testUnknownAccount;
        
        //Create Product
        Product2 testProduct = new Product2(
            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
            Name = 'Test Product',
            Gmid_Number__c = '55555',
            Product_Level__c = 'GMID',
            IsActive = true
        );
        insert testProduct;
        
        //Create Purchased Product
        PurchasedProduct_R1__c testPurchasedProduct = new PurchasedProduct_R1__c(
            Account_R1__c = testAccount.Id,
            Ship_To__c = olincAccount.Id,
            Product_R1__c = testProduct.Id,
            Account_Relationship__c = testAccountRel.Id
        );
        insert testPurchasedProduct;
        testAccount.Area_R1__c = 'NORTH AMERICA';
        update testAccount;
        // Create Total Consumption
        Total_Consumption__c testTotalConsumption = new Total_Consumption__c(
            Purchased_Product__c = testPurchasedProduct.Id,
            Ship_To__c = testAccount.Id,
            Product__c = testProduct.Id,
            Year__c = String.valueOf(Date.today().year()),
            Consumption__c = 100000
        );
        insert testTotalConsumption;
        
        // Create Consumption Shares
        List<Consumption_Share__c> lstTestConsumptionShare = new List<Consumption_Share__c>();
        
        //Olin
        Consumption_Share__c testConsumptionShareOlin = new Consumption_Share__c();
        testConsumptionShareOlin.Consumption_ShareOfWallet__c = testTotalConsumption.Id;
        testConsumptionShareOlin.Seller_Account_SOW__c = olincAccount.Id;
        testConsumptionShareOlin.Share_Amount__c = 50000;
        testConsumptionShareOlin.Share_Percent__c = 50;
        lstTestConsumptionShare.add(testConsumptionShareOlin);
        
        //Other account
        Consumption_Share__c testConsumptionShare = new Consumption_Share__c();
        testConsumptionShare.Consumption_ShareOfWallet__c = testTotalConsumption.Id;
        testConsumptionShare.Seller_Account_SOW__c = testUnknownAccount.Id;
        testConsumptionShare.Share_Amount__c = 25000;
        testConsumptionShare.Share_Percent__c = 15;
        lstTestConsumptionShare.add(testConsumptionShare);
        
        //Unknown
        testConsumptionShare = new Consumption_Share__c();
        testConsumptionShare.Consumption_ShareOfWallet__c = testTotalConsumption.Id;
        testConsumptionShare.Seller_Account_SOW__c = testAccount.Id;
        testConsumptionShare.Share_Amount__c = 35000;
        testConsumptionShare.Share_Percent__c = 5;
        lstTestConsumptionShare.add(testConsumptionShare);
        insert lstTestConsumptionShare;
        
        // Create SF STAGE SALES 
        SF_STAGE_SALES__c testSfStageSales = new SF_STAGE_SALES__c(
            CUSTOMER__c = '222222',
            SHIP_TO_PARTY__c = '111111',
            GMID__c = '55555',            
            FISCAL_YEAR__c = String.valueOf(Date.today().year() - 1),
            QUANTITY_SUOM_CAL__c = 50000,
            QUANTITY_GUOM_CAL__c = 50000,
            QUANTITY_CAL_NEW__c = 50000
        );
        insert testSfStageSales;
        
        Test.startTest();
        CalculateConsumptionRecordsBatch b = new CalculateConsumptionRecordsBatch(Date.today().year() - 1, Date.today().year());
        Database.executeBatch(b, 200);
        Test.stopTest();
    }
    
    
    testMethod static void testConstructorWithParams() {
        //Create Horizon Year
        Horizon_Year__c hz = new Horizon_Year__c();
        hz.Name = 'Default';
        hz.Year__c = System.today().year() + 1;
        insert hz;
        
        // Create Account
        Account testOlinAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Olin Corp').getRecordTypeId(),
            Name = 'Olin Corp',
            AccountNumber_R1__c = '267687',
            Status_R1__c = 'Active'
        );
        insert testOlinAccount;
        
        // Create Account
        Account testAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
            Name = 'Test Account',
            AccountNumber_R1__c = '222222',
            Area_R1__c = 'TEST',
            Sold_To__c = true,
            Ship_To__c = true,
            Status_R1__c = 'Active'
        );
        insert testAccount;
        
        // Create Account Relationship
        Account_Relationships__c testAccountRel = new Account_Relationships__c(
            Name = 'Test Account Relationship',
            Relationship_Type__c = 'Sold To / Ship To',
            Sold_To__c = testAccount.Id,
            Ship_To__c = testAccount.Id
        );  
        
        insert testAccountRel;
        
        Account testUnknownAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Olin Corp').getRecordTypeId(),
            Name = 'UNKNOWN',
            AccountNumber_R1__c = '2676871'
        );
        insert testUnknownAccount;
        
        //Create Product
        Product2 testProduct = new Product2(
            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
            Name = 'Test Product',
            TradeProduct_R1__c = '123456',
            Product_Level__c = 'GMID',
            Gmid_Number__c = '12345',
            Business_Group__c = 'OCAV',
            PH1_Performance_Center__c = 'BLEACH',
            IsActive = true
        );
        insert testProduct;
        
        //Create Purchased Product
        PurchasedProduct_R1__c testPurchasedProduct = new PurchasedProduct_R1__c(
            Account_R1__c = testAccount.Id,
            Ship_To__c = testAccount.Id,
            Product_R1__c = testProduct.Id,
            Account_Relationship__c = testAccountRel.Id
            
            
        );
        insert testPurchasedProduct;
        
        // Create Total Consumption
        Total_Consumption__c testTotalConsumption = new Total_Consumption__c(
            Purchased_Product__c = testPurchasedProduct.Id,
            Ship_To__c = testAccount.Id,
            Product__c = testProduct.Id,
            Year__c = String.valueOf(Date.today().year() - 1),
            Consumption__c = 250000
        );
        insert testTotalConsumption;
        
        // Create Consumption Share
        List<Consumption_Share__c> lstTestConsumptionShare = new List<Consumption_Share__c>();
        Consumption_Share__c testConsumptionShare = new Consumption_Share__c();
        testConsumptionShare.Consumption_ShareOfWallet__c = testTotalConsumption.Id;
        testConsumptionShare.Seller_Account_SOW__c = testUnknownAccount.Id;
        testConsumptionShare.Share_Amount__c = 25000;
        testConsumptionShare.Share_Percent__c = 15;
        lstTestConsumptionShare.add(testConsumptionShare);
        
        testConsumptionShare = new Consumption_Share__c();
        testConsumptionShare.Consumption_ShareOfWallet__c = testTotalConsumption.Id;
        testConsumptionShare.Seller_Account_SOW__c = testOlinAccount.Id;
        testConsumptionShare.Share_Amount__c = 35000;
        testConsumptionShare.Share_Percent__c = 5;
        lstTestConsumptionShare.add(testConsumptionShare);
        insert lstTestConsumptionShare;
        
        // Create SF STAGE SALES 
        SF_STAGE_SALES__c testSfStageSales = new SF_STAGE_SALES__c(
            SHIP_TO_PARTY__c = '222222',
            SOLD_TO_PARTY__c = '267687', 
            TRADE_PRODUCT_MAT__c= '123456', 
            VOLUME_IN_BASEUOM__c= 50000, 
            CALENDAR_YEAR_IMP__c = '2018', 
            CALENDAR_MONTH_IMP__c = '01',
            Customer__c = '222222',
            GMID__c = '12345',
            FISCAL_YEAR__c = String.valueOf(Date.today().year() - 1),
            //QUANTITY_SUOM_CAL__c = 50000,
            QUANTITY_GUOM_CAL__c = 50000,
            QUANTITY_CAL_NEW__c = 50000
        );
        insert testSfStageSales;
        
        Test.startTest();
        CalculateConsumptionRecordsBatch b = new CalculateConsumptionRecordsBatch(Date.today().year() - 1, Date.today().year());
        Database.executeBatch(b, 200);
        Test.stopTest();
    }
    testMethod static void testConstructorWithParams02() {
        //Create Horizon Year
        Horizon_Year__c hz = new Horizon_Year__c();
        hz.Name = 'Default';
        hz.Year__c = System.today().year() + 1;
        insert hz;
        
        // Create Account
        Account testOlinAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Olin Corp').getRecordTypeId(),
            Name = 'Olin Corp',
            AccountNumber_R1__c = '267687',
            Status_R1__c = 'Active'
        );
        insert testOlinAccount;
        
        // Create Account
        Account testAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
            Name = 'Test Account',
            AccountNumber_R1__c = '222222',
            Area_R1__c = 'TEST',
            Sold_To__c = true,
            Ship_To__c = true,
            Status_R1__c = 'Active'
        );
        insert testAccount;
        
        // Create Account Relationship
        Account_Relationships__c testAccountRel = new Account_Relationships__c(
            Name = 'Test Account Relationship',
            Relationship_Type__c = 'Sold To / Ship To',
            Sold_To__c = testAccount.Id,
            Ship_To__c = testAccount.Id
        );  
        
        insert testAccountRel;
        
        Account testUnknownAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Olin Corp').getRecordTypeId(),
            Name = 'UNKNOWN',
            AccountNumber_R1__c = '2676871'
        );
        insert testUnknownAccount;
        
        //Create Product
        Product2 testProduct = new Product2(
            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
            Name = 'Test Product',
            TradeProduct_R1__c = '123456',
            Product_Level__c = 'GMID',
            Gmid_Number__c = '12345',
            Business_Group__c = 'OCAV',
            PH1_Performance_Center__c = 'BLEACH',
            IsActive = true
        );
        insert testProduct;
        
        //Create Purchased Product
        PurchasedProduct_R1__c testPurchasedProduct = new PurchasedProduct_R1__c(
            Account_R1__c = testAccount.Id,
            Ship_To__c = testAccount.Id,
            Product_R1__c = testProduct.Id,
            Account_Relationship__c = testAccountRel.Id
            
            
        );
        insert testPurchasedProduct;
        
        // Create Total Consumption
        Total_Consumption__c testTotalConsumption = new Total_Consumption__c(
            Purchased_Product__c = testPurchasedProduct.Id,
            Ship_To__c = testAccount.Id,
            Product__c = testProduct.Id,
            Year__c = String.valueOf(Date.today().year() - 1),
            Consumption__c = 250000
        );
        insert testTotalConsumption;
        
        // Create Consumption Share
        List<Consumption_Share__c> lstTestConsumptionShare = new List<Consumption_Share__c>();
        Consumption_Share__c testConsumptionShare = new Consumption_Share__c();
        testConsumptionShare.Consumption_ShareOfWallet__c = testTotalConsumption.Id;
        testConsumptionShare.Seller_Account_SOW__c = testOlinAccount.Id;
        testConsumptionShare.Share_Amount__c = 25000;
        testConsumptionShare.Share_Percent__c = 15;
        lstTestConsumptionShare.add(testConsumptionShare);
        
        testConsumptionShare = new Consumption_Share__c();
        testConsumptionShare.Consumption_ShareOfWallet__c = testTotalConsumption.Id;
        testConsumptionShare.Seller_Account_SOW__c = testOlinAccount.Id;
        testConsumptionShare.Share_Amount__c = 35000;
        testConsumptionShare.Share_Percent__c = 5;
        lstTestConsumptionShare.add(testConsumptionShare);
        insert lstTestConsumptionShare;
        
        // Create SF STAGE SALES 
        SF_STAGE_SALES__c testSfStageSales = new SF_STAGE_SALES__c(
            SHIP_TO_PARTY__c = '222222',
            SOLD_TO_PARTY__c = '267687', 
            TRADE_PRODUCT_MAT__c= '123456', 
            VOLUME_IN_BASEUOM__c= 50000, 
            CALENDAR_YEAR_IMP__c = '2018', 
            CALENDAR_MONTH_IMP__c = '01',
            Customer__c = '222222',
            GMID__c = '12345',
            FISCAL_YEAR__c = String.valueOf(Date.today().year() - 1),
            QUANTITY_SUOM_CAL__c = 50000,
            QUANTITY_GUOM_CAL__c = 50000,
            QUANTITY_CAL_NEW__c = 50000
        );
        insert testSfStageSales;
        
        Test.startTest();
        CalculateConsumptionRecordsBatch b = new CalculateConsumptionRecordsBatch(Date.today().year() - 1, Date.today().year());
        Database.executeBatch(b, 200);
        Test.stopTest();
    }
    
    
}