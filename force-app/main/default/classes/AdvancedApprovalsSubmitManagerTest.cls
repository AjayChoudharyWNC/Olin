@isTest
public with sharing class AdvancedApprovalsSubmitManagerTest {

    testMethod static void testMethods() {
        

        // Create Account
        Account testAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Competitor').getRecordTypeId(),
            Name = 'Test Account'
        );
        insert testAccount;

        // Create Product
        Product2 testProduct = new Product2(
            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
            Name = 'Test Product',
            ProductCode = '105001'
        );
        insert testProduct;
        
        // Standard PriceBook
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry testPriceBookEntry;
      
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
        
        /**
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
        insert testPriceBook;
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
            SBQQ__Opportunity2__c = testOpportunity.Id
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
            SBQQ__SubscriptionPricing__c = 'Fixed Price'
        );
        insert testQuoteLine;

        AdvancedApprovalsSubmitManager.QuoteGroup qgroup = new AdvancedApprovalsSubmitManager.QuoteGroup();
        qgroup.quotes = new List<AdvancedApprovalsSubmitManager.QuoteEntry>();
        AdvancedApprovalsSubmitManager.QuoteEntry entry = new AdvancedApprovalsSubmitManager.QuoteEntry();
        entry.id = testQuote.id;
        entry.name = testQuote.Name;
        entry.status = 'Quotation';
        entry.isUpdate = false;
        entry.success = null;
        entry.response = null;
        entry.error = null;
        qgroup.quotes.add(entry);
        
        AdvancedApprovalsSubmitManager.QuoteEntry upEntry = new AdvancedApprovalsSubmitManager.QuoteEntry();
        upEntry.id = testQuote.id;
        upEntry.name = testQuote.Name;
        upEntry.status = 'Quotation';
        upEntry.isUpdate = true;
        upEntry.success = null;
        upEntry.response = null;
        upEntry.error = null;
        qgroup.quotes.add(upEntry);


        //Test Errors
        AdvancedApprovalsSubmitManager.QuoteEntry badEntry = new AdvancedApprovalsSubmitManager.QuoteEntry();
        badEntry.id = null;
        badEntry.name = testQuote.Name;
        badEntry.status = 'Quotation';
        badEntry.isUpdate = false;
        badEntry.success = null;
        badEntry.response = null;
        badEntry.error = null;
        qgroup.quotes.add(badEntry);
        
        AdvancedApprovalsSubmitManager.QuoteEntry badEntry2 = new AdvancedApprovalsSubmitManager.QuoteEntry();
        badEntry2.id = null;
        badEntry.name = testQuote.Name;
        badEntry2.status = 'Quotation';
        badEntry2.isUpdate = true;
        badEntry2.success = null;
        badEntry2.response = null;
        badEntry2.error = null;
        qgroup.quotes.add(badEntry2);

        System.debug('Request: ' + JSON.serialize(qgroup));

        String response = AdvancedApprovalsSubmitManager.doPost(JSON.serialize(qgroup));

        System.debug('Response: ' + response);

        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote = [SELECT ApprovalStatus__c FROM SBQQ__Quote__c WHERE Id = :testQuote.Id LIMIT 1];
        System.assertEquals('Approved', quote.ApprovalStatus__c);
    }
}