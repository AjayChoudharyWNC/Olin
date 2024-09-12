@isTest
public class approvalRequestQuotelineItemsclassTest {

    public static testmethod void myUnitTest() {

        // Create Account
        Account testAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Competitor').getRecordTypeId(),
            Name = 'Test Account'
        );
        insert testAccount;

        // Create Product
        Product2 testProduct = new Product2(
            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
            Name = 'Distributor Discount',
            ProductCode = 'ZDCE'
        );
        insert testProduct;
        
        Product2 testProduct2 = new Product2(
            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
            Name = 'Product Discount Amount',
            ProductCode = 'ZKM4-ZKM5'
        );
        insert testProduct2;
        
        
        // Standard PriceBook
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry testPriceBookEntry;
        system.debug('Test Pricebook: ' + pricebookId);
      
        list<PricebookEntry> priceBookTestUS = [select id from PricebookEntry where Product2Id = :testProduct.Id and Pricebook2Id = :pricebookId and CurrencyIsoCode = 'USD'];
        if(priceBookTestUS.size() == 1){
            testPriceBookEntry = priceBookTestUS[0];
        }
        else
        {
            // Create PricebookEntry
            testPriceBookEntry = new PricebookEntry( 
                Pricebook2Id = pricebookId,
                Product2Id = testProduct.id,
                CurrencyIsoCode = 'USD',
                IsActive = TRUE,
                UnitPrice = 100.0,
                UseStandardPrice = FALSE
            );
            insert testPriceBookEntry;
        }
        system.debug('Test Pricebook Entry: ' + testPriceBookEntry);

        PricebookEntry testPriceBookEntry2;
        list<PricebookEntry> priceBook2TestUS = [select id from PricebookEntry where Product2Id = :testProduct2.Id and Pricebook2Id = :pricebookId and CurrencyIsoCode = 'USD'];
        if(priceBook2TestUS.size() == 1){
            testPriceBookEntry2 = priceBook2TestUS[0];
        }
        else
        {
            testPriceBookEntry2 = new PricebookEntry( 
                Pricebook2Id = pricebookId,
                Product2Id = testProduct2.id,
                CurrencyIsoCode = 'USD',
                IsActive = TRUE,
                UnitPrice = 100.0,
                UseStandardPrice = FALSE
            );
            insert testPriceBookEntry2;
        }
        system.debug('Test Pricebook Entry: ' + testPriceBookEntry);
        
        /***
        // Standard PriceBook
        Id pricebookId = Test.getStandardPricebookId();
        
        // Create PricebookEntry
        PricebookEntry testPriceBook = new PricebookEntry( 
            Pricebook2Id = pricebookId,
            Product2Id = testProduct.id,
            CurrencyIsoCode = 'USD',
            IsActive = TRUE,
            UnitPrice = 100.0,
            UseStandardPrice = FALSE
        );
        //insert testPriceBook;
        ***/
        
        // Create Opportunity 
        Opportunity testOpportunity = new Opportunity(
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CAPV Commercial').getRecordTypeId(),
            Name = 'Test Opportunity',
            CloseDate = date.newInstance(2019, 03, 01),
            StageName = 'Proposal',
            CurrencyIsoCode = 'USD',
            AccountId = testAccount.Id
        );
        insert testOpportunity;

        // Create Quote
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c(
            RecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Draft Price Request').getRecordTypeId(),
            SBQQ__Primary__c = true,
            Price_Start_Date__c = date.newInstance(2019, 03, 01),
            SBQQ__Opportunity2__c = testOpportunity.Id,
            Ship_To_Any__c = true
        );
        insert testQuote;
        
        // Create Quote Lines
        SBQQ__QuoteLine__c testQuoteLine = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = testQuote.Id,
            SBQQ__Product__c = testProduct.Id,
            SBQQ__Quantity__c = 1,
            SBQQ__ListPrice__c = 10,
            SBQQ__NetPrice__c = 10,
            SBQQ__Number__c = 1,
            Product_Level__c = 'Adder',
            SBQQ__SubscriptionPricing__c = 'Fixed Price'
        );
        insert testQuoteLine;
        
        Test.startTest();
        approvalRequestQuotelineItemsclass approvalReq = new approvalRequestQuotelineItemsclass();
        //approvalReq.quoteid = testQuote.Id; - Changed by Jimmy Daresta to allow for test coverage moving to the quote line now
        approvalReq.quotelineid = testQuoteLine.Id;   
        approvalReq.getquotelines();
        approvalReq.percentDiscount = 'Display Discount';
        approvalReq.flatDiscount = 'Flat Discount';
        Test.stopTest();
    }
    
    public static testmethod void myUnitTest2() {

        // Create Account
        Account testAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Competitor').getRecordTypeId(),
            Name = 'Test Account'
        );
        insert testAccount;

        // Create Product
        Product2 testProduct = new Product2(
            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
            Name = 'Distributor Discount',
            ProductCode = 'ZDCE'
        );
        insert testProduct;
        
        Product2 testProduct2 = new Product2(
            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
            Name = 'Product Discount Amount',
            ProductCode = 'ZKM4-ZKM5'
        );
        insert testProduct2;
        
        
        // Standard PriceBook
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry testPriceBookEntry;
        system.debug('Test Pricebook: ' + pricebookId);
      
        list<PricebookEntry> priceBookTestUS = [select id from PricebookEntry where Product2Id = :testProduct.Id and Pricebook2Id = :pricebookId and CurrencyIsoCode = 'USD'];
        if(priceBookTestUS.size() == 1){
            testPriceBookEntry = priceBookTestUS[0];
        }
        else
        {
            // Create PricebookEntry
            testPriceBookEntry = new PricebookEntry( 
                Pricebook2Id = pricebookId,
                Product2Id = testProduct.id,
                CurrencyIsoCode = 'USD',
                IsActive = TRUE,
                UnitPrice = 100.0,
                UseStandardPrice = FALSE
            );
            insert testPriceBookEntry;
        }
        system.debug('Test Pricebook Entry: ' + testPriceBookEntry);

        PricebookEntry testPriceBookEntry2;
        list<PricebookEntry> priceBook2TestUS = [select id from PricebookEntry where Product2Id = :testProduct2.Id and Pricebook2Id = :pricebookId and CurrencyIsoCode = 'USD'];
        if(priceBook2TestUS.size() == 1){
            testPriceBookEntry2 = priceBook2TestUS[0];
        }
        else
        {
            testPriceBookEntry2 = new PricebookEntry( 
                Pricebook2Id = pricebookId,
                Product2Id = testProduct2.id,
                CurrencyIsoCode = 'USD',
                IsActive = TRUE,
                UnitPrice = 100.0,
                UseStandardPrice = FALSE
            );
            insert testPriceBookEntry2;
        }
        system.debug('Test Pricebook Entry: ' + testPriceBookEntry);
        
        /***
        // Standard PriceBook
        Id pricebookId = Test.getStandardPricebookId();
        
        // Create PricebookEntry
        PricebookEntry testPriceBook = new PricebookEntry( 
            Pricebook2Id = pricebookId,
            Product2Id = testProduct.id,
            CurrencyIsoCode = 'USD',
            IsActive = TRUE,
            UnitPrice = 100.0,
            UseStandardPrice = FALSE
        );
        //insert testPriceBook;
        ***/
        
        // Create Opportunity 
        Opportunity testOpportunity = new Opportunity(
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CAPV Commercial').getRecordTypeId(),
            Name = 'Test Opportunity',
            CloseDate = date.newInstance(2019, 03, 01),
            StageName = 'Proposal',
            CurrencyIsoCode = 'USD',
            AccountId = testAccount.Id
        );
        insert testOpportunity;

        // Create Quote
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c(
            RecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Draft Price Request').getRecordTypeId(),
            SBQQ__Primary__c = true,
            Price_Start_Date__c = date.newInstance(2019, 03, 01),
            SBQQ__Opportunity2__c = testOpportunity.Id,
            Ship_To_Any__c = true
        );
        insert testQuote;
        
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        
        // Create Quote Lines
        SBQQ__QuoteLine__c testQuoteLine = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = testQuote.Id,
            SBQQ__Product__c = testProduct.Id,
            SBQQ__Quantity__c = 1,
            SBQQ__ListPrice__c = 10,
            SBQQ__NetPrice__c = 10,
            SBQQ__Number__c = 1,
            Product_Level__c = 'Adder',
            SBQQ__SubscriptionPricing__c = 'Fixed Price'
        );
        quoteLineList.add(testQuoteLine);
        //insert testQuoteLine;
        
        
        // Create Quote Lines
        SBQQ__QuoteLine__c testQuoteLine2 = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = testQuote.Id,
            SBQQ__Product__c = testProduct2.Id,
            SBQQ__Quantity__c = 1,
            SBQQ__ListPrice__c = 10,
            SBQQ__NetPrice__c = 10,
            SBQQ__Number__c = 1,
            Product_Level__c = 'Adder',
            SBQQ__SubscriptionPricing__c = 'Fixed Price'
        );
        quoteLineList.add(testQuoteLine2);
        //insert testQuoteLine2;
        
        Test.startTest();
        approvalRequestQuotelineItemsclass approvalReq = new approvalRequestQuotelineItemsclass();
        //approvalReq.quoteid = testQuote.Id; - Changed by Jimmy Daresta to allow for test coverage moving to the quote line now
        approvalReq.quotelineid = quoteLineList[0].Id;   
        approvalReq.getquotelines();
        approvalReq.percentDiscount = 'Display Discount';
        approvalReq.flatDiscount = 'Flat Discount';
        Test.stopTest();
    }
}