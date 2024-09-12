@isTest
public class CustomProductSearchPluginTest {
    
    @TestSetup
    static void testData(){
        
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

      // Create Product
      Product2 testProduct = new Product2(
          RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
          Name = 'Test Product',
          ProductCode = '105001',
          IsActive  = true,
          Product_Level__c = 'GMID'
      );
      insert testProduct;

      //Added 8-20-2022 by Jimmy Daresta to allow test class passing
      // Create Trade Product
      Product2 testProduct2 = new Product2(
          RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
          Name = 'Test Trade Product',
          ProductCode = '00009999',
          IsActive  = true,
          Product_Level__c = 'Trade Product'
      );
      insert testProduct2;      
      

      PurchasedProduct_R1__c testPurchasedProduct = new PurchasedProduct_R1__c(
          Account_R1__c = testAccount.Id,
          Product_R1__c = testProduct.Id
      );
      insert testPurchasedProduct;

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

      //Added 8-20-2022 by Jimmy Daresta to allow test class passing
      // Create PricebookEntry Trade Product
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
          Ship_To_Any__c = false,
          Ship_To__c = testAccount.Id,
          SBQQ__PriceBook__c = pricebookId
      );
      insert testQuote;
      system.debug('Test Quote: ' + testQuote);

      // Create Quote Line
      SBQQ__QuoteLine__c testQuoteLine = new SBQQ__QuoteLine__c(
          SBQQ__Quote__c = testQuote.Id,
          SBQQ__Product__c = testProduct.Id,
          SBQQ__Quantity__c = 1,
          SBQQ__ListPrice__c = 10,
          SBQQ__NetPrice__c = 10,
          SBQQ__Number__c = 1,
          SBQQ__SubscriptionPricing__c = 'Fixed Price',
          Price_Start_Date__c = date.newInstance(2019, 12, 31)
      );
      insert testQuoteLine;
    }

    testMethod static void testMethods(){
      List<SBQQ__Quote__c> lstTestQuote = [SELECT Id FROM SBQQ__Quote__c];

      test.startTest();
      CustomProductSearchPlugin customProductSearch = new CustomProductSearchPlugin();
      Map<String, Object> mapStrObj = new Map<String, Object>();
      mapStrObj.put('', lstTestQuote[0]);
      customProductSearch.isFilterHidden(lstTestQuote[0], '');
      customProductSearch.getFilterDefaultValue(lstTestQuote[0], '');
      customProductSearch.isSearchCustom(lstTestQuote[0], mapStrObj);
      customProductSearch.getAdditionalSearchFilters(lstTestQuote[0], mapStrObj);
      customProductSearch.getAdditionalSuggestFilters(lstTestQuote[0], mapStrObj);
      customProductSearch.isSuggestCustom(lstTestQuote[0], mapStrObj);
      customProductSearch.suggest(lstTestQuote[0], mapStrObj);
      customProductSearch.isInputHidden(lstTestQuote[0], '');
      customProductSearch.getInputDefaultValue(lstTestQuote[0], '');
      test.stopTest();
    }

    testMethod static void searchTrueTest(){
      List<SBQQ__Quote__c> lstTestQuote = [SELECT Id, SBQQ__PriceBook__c FROM SBQQ__Quote__c];
      
      test.startTest();
      CustomProductSearchPlugin customProductSearch = new CustomProductSearchPlugin();
      Map<String, Object> mapStrObj = new Map<String, Object>();
      mapStrObj.put('Show_All_Products__c', true);
      try {
        customProductSearch.search(lstTestQuote[0], mapStrObj);
      } catch(Exception ex) {
        system.debug('Error: ' + ex);
      }
      test.stopTest();
    }

    testMethod static void searchFalseTest(){
      List<SBQQ__Quote__c> lstTestQuote = [SELECT Id, SBQQ__PriceBook__c FROM SBQQ__Quote__c];
      system.debug('Quote: ' + lstTestQuote);
      test.startTest();
      CustomProductSearchPlugin customProductSearch = new CustomProductSearchPlugin();
      Map<String, Object> mapStrObj = new Map<String, Object>();
      mapStrObj.put('Show_All_Products__c', false);
      try {
        customProductSearch.search(lstTestQuote[0], mapStrObj);
      } catch(Exception ex) {
        system.debug('Error: ' + ex);
      }
      test.stopTest();
    }

    testMethod static void searchParentOppProductTest(){

      Account testAccount = [SELECT Id, Name FROM Account WHERE Name = 'Test Account'];
      //Product2 testProduct = [SELECT Id, Name FROM Product2 WHERE Name = 'Test Trade Product'];
      //Added to accommodate the trade product needed for parent id - Jimmy Daresta 8/20/2022
      Product2 testProduct = [SELECT Id, Name FROM Product2 WHERE Name = 'Test Trade Product'];

      // Standard PriceBook
      //Id pricebookId = Test.getStandardPricebookId();
    // PricebookEntry priceBookEntry = [SELECT Id FROM PricebookEntry WHERE PriceBook2Id =:pricebookId AND Product2Id =:testProduct.Id];
     PricebookEntry priceBookEntry = [SELECT Id, PriceBook2Id FROM PricebookEntry WHERE Product2Id =:testProduct.Id AND CurrencyIsoCode = 'USD' LIMIT 1];

      // Create Parent Opportunity 
      Opportunity testParentOpportunity = new Opportunity(
          RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Long Term Opportunity').getRecordTypeId(),
          Name = 'Test Parent Opportunity',
          CloseDate = date.newInstance(2019, 03, 01),
          StageName = 'Proposal',
          CurrencyIsoCode = 'USD',
          AccountId = testAccount.Id
      );
      insert testParentOpportunity;

      OpportunityLineItem testParentOppLineItem = new OpportunityLineItem(
        Product2Id = testProduct.Id,
        PricebookEntryId = priceBookEntry.Id,
        OpportunityId = testParentOpportunity.Id,
        Quantity = 1,
        TotalPrice = 3.8,
        Avg_Annualize_Volume__c = 100
      );
      insert testParentOppLineItem;

      // Create Child Opportunity 
      Opportunity testChildOpportunity = new Opportunity(
          RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Epoxy Commercial').getRecordTypeId(),
          Name = 'Test Child Opportunity',
          CloseDate = date.newInstance(2019, 03, 01),
          Parent_Opportunity__c = testParentOpportunity.Id,
          StageName = 'Proposal',
          CurrencyIsoCode = 'USD',
          AccountId = testAccount.Id
      );
      insert testChildOpportunity;

      OpportunityLineItem testChildOppLineItem = new OpportunityLineItem(
        Product2Id = testProduct.Id,
        PricebookEntryId = priceBookEntry.Id,
        OpportunityId = testChildOpportunity.Id,
        Quantity = 1,
        TotalPrice = 3.8
      );
      insert testChildOppLineItem;

      SBQQ.TriggerControl.disable();
      // Create Quote
      SBQQ__Quote__c testQuote = new SBQQ__Quote__c(
        RecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Contracted Price Requests').getRecordTypeId(),
        SBQQ__Primary__c = true,
        Price_Start_Date__c = date.newInstance(2019, 03, 01),
        SBQQ__Opportunity2__c = testChildOpportunity.Id,
        Ship_To_Any__c = false,
        Ship_To__c = testAccount.Id,
        SBQQ__PriceBook__c = priceBookEntry.Pricebook2Id
      );
      insert testQuote;
      SBQQ.TriggerControl.enable();
      
      test.startTest();
      CustomProductSearchPlugin customProductSearch = new CustomProductSearchPlugin();
      Map<String, Object> mapStrObj = new Map<String, Object>();
      mapStrObj.put('Show_All_Products__c', false);
      try {
        customProductSearch.search(testQuote, mapStrObj);
      } catch(Exception ex) {
        system.debug('Error: ' + ex);
      }
      test.stopTest();
    }

}