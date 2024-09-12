@isTest
public class MuleSoftCalloutManager_Test {

    @TestSetup
    static void testData(){
        // Create Account
        Account testAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
            Name = 'Sold To Account',
            AccountNumber_R1__c = '267687',
            Ship_To__c = true,
            Sold_To__c = true
        );
        insert testAccount;

        //Create Product
        Product2 testProduct = new Product2(
            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
            Name = 'Test Product',
            TradeProduct_R1__c = '123456',
            Product_Level__c = 'GMID'
        );
        insert testProduct;

        // Standard PriceBook
        //Id pricebookId = Test.getStandardPricebookId();
        /***
        // Create PricebookEntry
        PricebookEntry testPriceBook = new PricebookEntry( 
            Pricebook2Id = pricebookId,
            Product2Id = testProduct.id,
            CurrencyIsoCode = 'USD',
            IsActive = TRUE,
            UnitPrice = 100.0,
            UseStandardPrice = FALSE
        );
        insert testPriceBook;
        ***/
        
        // Standard PriceBook
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry testPriceBookEntry;
        system.debug('Test Pricebook: ' + pricebookId);
      
        list<PricebookEntry> priceBookTestUS = [select id from PricebookEntry where Product2Id = :testProduct.Id and Pricebook2Id = :pricebookId and CurrencyIsoCode = 'USD'];
        if(priceBookTestUS.size() == 1){
            testPriceBookEntry = priceBookTestUS[0];
        } else {
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
        
        // Create Opportunity
        Opportunity testOpportunity = new Opportunity(
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CAPV Commercial').getRecordTypeId(),
            Name = 'Test Opportunity',
            AccountId = testAccount.Id,
            Type = 'Contract',
            CloseDate = date.newInstance(2019, 12, 31),
            StageName = 'Discovery/Qualification',
            CurrencyIsoCode = 'USD',
            Contract_Start_Date__c = date.newInstance(2019, 03, 01),
            Contract_End_Date__c = date.newInstance(2019, 12, 31)
        );
        insert testOpportunity;

        // Create Quote
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c(
            RecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Draft Price Request').getRecordTypeId(),
            SBQQ__Primary__c = true,
            Price_Start_Date__c = date.newInstance(2019, 03, 01),
            SBQQ__Opportunity2__c = testOpportunity.Id,
            Ship_To_Any__c= true,
            SBQQ__Account__c = testAccount.Id
        );
        insert testQuote;

        Mulesoft_CloneEndpoint__c mc = new Mulesoft_CloneEndpoint__c();
        mc.Endpoint__c = 'https://clone-quote.us-e2.cloudhub.io/clone';
        mc.Submit_Endpoint__c = 'https://clone-quote.us-e2.cloudhub.io/cloneandsubmit';
        mc.Operation__c = 'POST';
        insert mc;
    }

    testMethod static void testDoClone() {
        List<SBQQ__Quote__c> lstQuote = [SELECT Id FROM SBQQ__Quote__c];
        Set<String> quoteIds = new Set<String>();
        for(SBQQ__Quote__c testQuote : lstQuote) {
            quoteIds.add(testQuote.Id);
        }
        
        Test.setMock(HttpCalloutMock.class, new MuleSoftCalloutManager_MockTest());
        HttpResponse res = MuleSoftCalloutManager.doClone(quoteIds);
    }

    testMethod static void testDoCloneandSubmit() {
        List<SBQQ__Quote__c> lstQuote = [SELECT Id FROM SBQQ__Quote__c];
        Set<String> quoteIds = new Set<String>();
        for(SBQQ__Quote__c testQuote : lstQuote) {
            quoteIds.add(testQuote.Id);
        }
        
        Test.setMock(HttpCalloutMock.class, new MuleSoftCalloutManager_MockTest());
        HttpResponse res = MuleSoftCalloutManager.doCloneandSubmit(quoteIds);
    }

    testMethod static void testDoUpdate() {
        List<SBQQ__Quote__c> lstQuote = [SELECT Id FROM SBQQ__Quote__c];
        Set<String> quoteIds = new Set<String>();
        for(SBQQ__Quote__c testQuote : lstQuote) {
            quoteIds.add(testQuote.Id);
        }
        
        Test.setMock(HttpCalloutMock.class, new MuleSoftCalloutManager_MockTest());
        HttpResponse res = MuleSoftCalloutManager.doUpdate(quoteIds);
    }
}