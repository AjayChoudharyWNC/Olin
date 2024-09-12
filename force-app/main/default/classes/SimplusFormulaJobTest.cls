@isTest
public class SimplusFormulaJobTest {
    testMethod static void testMethods() {

        // Create Formula
        Formula__c testFormula = new Formula__c(
            Name = 'Test Formula',
            Active__c = true
        );
        insert testFormula;

        // Create Account
        Account testAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Competitor').getRecordTypeId(),
            Name = 'Test Account',
            AccountNumber_R1__c = '123',
            AccountSource = 'Olin Heritage'
        );
        insert testAccount;

        // Create Product
        Product2 testProduct = new Product2(
            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
            Name = 'Test Product',
            ProductCode = '105001'
        );
        insert testProduct;
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
        insert testPriceBook;
        ***/

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
            Ship_To_Any__c= true
        );
        insert testQuote;

        // Create Quote Lines
        SBQQ__QuoteLine__c testQuoteLine = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = testQuote.Id,
            Formula_Name__c = testFormula.Id,
            SBQQ__Product__c = testProduct.Id,
            SBQQ__Quantity__c = 1,
            SBQQ__ListPrice__c = 10,
            SBQQ__NetPrice__c = 10,
            SBQQ__Number__c = 1,
            SBQQ__SubscriptionPricing__c = 'Fixed Price'
        );
        insert testQuoteLine;

        Test.startTest();
        SimplusFormulaJobHelper helper = new SimplusFormulaJobHelper(true);
        SimplusFormulaJobHelper.runOnce();
        SimplusFormulaJobHelper.RunFormula(testQuote.Id);
        SimplusFormulaJobHelper.getJobName(testQuote.Id);
        SimplusFormulaJobHelper.getJobCronString(1);
        SimplusFormulaJobHelper.abortPreviousJobs(testQuote.Id);
        helper.RunFormulas();
        Test.stopTest();
    }
}