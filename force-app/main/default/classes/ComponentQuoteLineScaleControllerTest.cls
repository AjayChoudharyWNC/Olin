@isTest
public class ComponentQuoteLineScaleControllerTest {
    
    @testSetup
    public static void testSetup(){
        
        List<Account> accList = new List<Account>();
        Account soldToAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
            Name = 'Sold To Account',
            AccountNumber_R1__c = '267687',
            Ship_To__c = true,
            Sold_To__c = true
        );
        accList.add(soldToAccount);
        
        Account shipToAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
            Name = 'First Ship To Account',
            AccountNumber_R1__c = '267623',
            Ship_To__c = true,
            ParentId = soldToAccount.Id
        );
        accList.add(shipToAccount);

        // insert shipToAccount;
        Account acc = new Account(Name = 'FastChem Cooperation', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Olin Corp').getRecordTypeId());
        insert acc;
        
        AccountName__c acctName = new AccountName__c();
        acctName.Name = 'FastChem Corp';
        acctName.OlinAccountValue__c = acc.id;
        insert acctName;

        // Create Users
        List<User> lstTestUser = new List<User>();
        Profile adminProfile = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator'];
        lstTestUser.add(new User(
            LastName = adminProfile.Name,
            FirstName = 'Test1',
            Email = adminProfile.Name.remove(' ') + '.' + 'Test1@fastchem.com.dev.test',
            Username = adminProfile.Name.remove(' ') + '.' + 'Test1@fastchem.com.dev.test',
            Alias = 'testusr1',
            CommunityNickname = 'test1' + adminProfile.Name.right(7),
            ProfileId = adminProfile.Id,
            TimeZoneSidKey = 'America/Chicago',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            CurrencyIsoCode = 'USD',
            UserRoleId = [SELECT Id FROM UserRole WHERE DeveloperName = 'Administration'].Id));

        lstTestUser.add(new User(
            LastName = adminProfile.Name,
            FirstName = 'Test2',
            Email = adminProfile.Name.remove(' ') + '.' + 'Test2@fastchem.com.dev.test',
            Username = adminProfile.Name.remove(' ') + '.' + 'Test2@fastchem.com.dev.test',
            Alias = 'testusr2',
            CommunityNickname = 'test2' + adminProfile.Name.right(7),
            ProfileId = adminProfile.Id,
            TimeZoneSidKey = 'America/Chicago',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            CurrencyIsoCode = 'USD',
            UserRoleId = [SELECT Id FROM UserRole WHERE DeveloperName = 'Administration'].Id));
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert lstTestUser;
        }

        //Create Product
        Product2 testProduct = new Product2(
            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
            Name = 'Test Product',
            TradeProduct_R1__c = '123456',
            Product_Level__c = 'GMID'
        );
        insert testProduct;

        //Create Product Scales
        Product2[] lProductScales = new Product2[] {};
        Product2 testProductScale = new Product2(
            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
            Name = 'Scale Pricing (1)',
            TradeProduct_R1__c = '123433',
            Product_Level__c = 'Scale'
        );
        lProductScales.add(testProductScale);

        Product2 testProductScale2 = new Product2(
            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
            Name = 'Scale Pricing (2)',
            TradeProduct_R1__c = '123434',
            Product_Level__c = 'Scale'
        );
        lProductScales.add(testProductScale2);

        Product2 testProductScale3 = new Product2(
            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
            Name = 'Scale Pricing (3)',
            TradeProduct_R1__c = '123435',
            Product_Level__c = 'Scale'
        );
        lProductScales.add(testProductScale3);
        insert lProductScales;
        
        //Create Product Feature
        
        SBQQ__ProductFeature__c testProductFeature = new SBQQ__ProductFeature__c(
            Name = 'Scale Pricing',
            SBQQ__ConfiguredSKU__c = testProduct.Id,
            SBQQ__Number__c = 10,
            SBQQ__MinOptionCount__c = 0,
            SBQQ__Category__c = 'Discounts'
        );
        insert testProductFeature;

        //Create Product Options
        SBQQ__ProductOption__c[] lProductOptions = new SBQQ__ProductOption__c[] {};
        SBQQ__ProductOption__c testProductOption = new SBQQ__ProductOption__c(
            SBQQ__ConfiguredSKU__c = testProduct.Id,
            SBQQ__OptionalSKU__c = testProductScale.Id,
            SBQQ__Number__c =   300,
            SBQQ__Feature__c = testProductFeature.Id
        );
        lProductOptions.add(testProductOption);

        SBQQ__ProductOption__c testProductOption2 = new SBQQ__ProductOption__c(
            SBQQ__ConfiguredSKU__c = testProduct.Id,
            SBQQ__OptionalSKU__c = testProductScale2.Id,
            SBQQ__Number__c =   310,
            SBQQ__Feature__c = testProductFeature.Id
        );
        lProductOptions.add(testProductOption2);

        SBQQ__ProductOption__c testProductOption3 = new SBQQ__ProductOption__c(
            SBQQ__ConfiguredSKU__c = testProduct.Id,
            SBQQ__OptionalSKU__c = testProductScale3.Id,
            SBQQ__Number__c =   320,
            SBQQ__Feature__c = testProductFeature.Id
        );
        lProductOptions.add(testProductOption3);

        insert lProductOptions;
        

        // Standard PriceBook
        Id pricebookId = Test.getStandardPricebookId();
        
        Product2 testProduct2 = new Product2(
            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
            Name = 'Scale Pricing (1)',
            Product_Level__c = 'Scale',
            ProductCode = 'SP-00001'
        );
        insert testProduct2;

        Product2 testProduct3 = new Product2(
            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
            Name = 'Test Product 3',
            TradeProduct_R1__c = '123452',
            Product_Level__c = 'GMID'
        );
        insert testProduct3;

        // Create Opportunity
        Opportunity testOpportunity = new Opportunity(
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CAPV Commercial').getRecordTypeId(),
            Name = 'Test Opportunity',
            Type = 'Contract',
            CloseDate = date.newInstance(2019, 12, 31),
            StageName = 'Discovery/Qualification',
            CurrencyIsoCode = 'USD',
            Contract_Start_Date__c = date.newInstance(2019, 03, 01),
            Contract_End_Date__c = date.newInstance(2019, 12, 31)
        );
        insert testOpportunity;
        System.debug('opp Id ::::' + testOpportunity.Id);
        // Create Quote
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c(
            RecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Draft Price Request').getRecordTypeId(),
            SBQQ__Primary__c = true,
            Price_Start_Date__c = date.newInstance(2019, 03, 01),
            SBQQ__Opportunity2__c = testOpportunity.Id,
            Ship_To_Any__c= true,
            SubmitForApproval__c = true
        );
        insert testQuote;
            
        SBQQ__QuoteLine__c[] lMainQouteLine = new SBQQ__QuoteLine__c[] {};
        SBQQ__QuoteLine__c testQuoteLine= new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = testQuote.Id,
            SBQQ__Product__c = testProduct.Id,
            SBQQ__Quantity__c = 1,
            SBQQ__ListPrice__c = 10,
            SBQQ__NetPrice__c = 10,
            SBQQ__Number__c = 1,
            SBQQ__SubscriptionPricing__c = 'Fixed Price',
            Price_Start_Date__c = date.newInstance(2019, 12, 31),
            Ship_To__c = shipToAccount.Id,
            Price_Request_Account__c = shipToAccount.Id,
            // Ship_To_Account__c = testAccountRel.Id,
            SBQQ__Bundle__c = true,
            Product_Level__c = 'GMID'
        );
        lMainQouteLine.add(testQuoteLine);

        SBQQ.TriggerControl.disable();
        insert lMainQouteLine;
        
        //Create Quote Line Scale
        SBQQ__QuoteLine__c[] lQouteLine = new SBQQ__QuoteLine__c[] {};
        SBQQ__QuoteLine__c testQuoteLineScale = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = testQuote.Id,
            SBQQ__Product__c = testProductScale.Id,
            SBQQ__Quantity__c = 1,
            SBQQ__ListPrice__c = 10,
            SBQQ__NetPrice__c = 10,
            SBQQ__Number__c = 1,
            SBQQ__SubscriptionPricing__c = 'Fixed Price',
            Price_Start_Date__c = date.newInstance(2019, 12, 31),
            Ship_To__c = shipToAccount.Id,
            Price_Request_Account__c = shipToAccount.Id,
            // Ship_To_Account__c = testAccountRel.Id,
            SBQQ__Bundle__c = true,
            Product_Level__c = 'Scale',
            SBQQ__RequiredBy__c = testQuoteLine.Id
        );
        lQouteLine.add(testQuoteLineScale);

        SBQQ__QuoteLine__c testQuoteLineScale2 = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = testQuote.Id,
            SBQQ__Product__c = testProductScale2.Id,
            SBQQ__Quantity__c = 1,
            SBQQ__ListPrice__c = 10,
            SBQQ__NetPrice__c = 10,
            SBQQ__Number__c = 1,
            SBQQ__SubscriptionPricing__c = 'Fixed Price',
            Price_Start_Date__c = date.newInstance(2019, 12, 31),
            Ship_To__c = shipToAccount.Id,
            Price_Request_Account__c = shipToAccount.Id,
            // Ship_To_Account__c = testAccountRel.Id,
            SBQQ__Bundle__c = true,
            Product_Level__c = 'Scale',
            SBQQ__RequiredBy__c = testQuoteLine.Id,
            SBQQ__ProductOption__c = testProductOption.Id,
            Validity_Start_Date__c = system.today(),
            Validity_End_Date__c = system.today()+10,
            Discount_Percent__c = 10
        );
        lQouteLine.add(testQuoteLineScale2);

        SBQQ__QuoteLine__c testQuoteLineScale3 = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = testQuote.Id,
            SBQQ__Product__c = testProductScale3.Id,
            SBQQ__Quantity__c = 1,
            SBQQ__ListPrice__c = 10,
            SBQQ__NetPrice__c = 10,
            SBQQ__Number__c = 1,
            SBQQ__SubscriptionPricing__c = 'Fixed Price',
            Price_Start_Date__c = date.newInstance(2019, 12, 31),
            Ship_To__c = shipToAccount.Id,
            Price_Request_Account__c = shipToAccount.Id,
            // Ship_To_Account__c = testAccountRel.Id,
            SBQQ__Bundle__c = true,
            Product_Level__c = 'Scale',
            SBQQ__RequiredBy__c = testQuoteLine.Id,
            SBQQ__ProductOption__c = testProductOption.Id,
            Validity_Start_Date__c = system.today(),
            Validity_End_Date__c = system.today()+10,
            Discount_Percent__c = 0
        );
        lQouteLine.add(testQuoteLineScale3);

        SBQQ.TriggerControl.disable();
        insert lQouteLine;

    }
    
    public static testmethod void Test1() {
        ComponentQuoteLineScaleController cont = new ComponentQuoteLineScaleController();
        boolean scale = cont.getHasScale();
        boolean surcharge = cont.getHasSurcharge();
        boolean discount = cont.getHasDiscount();
        boolean comp = cont.getHasCompetitor();
        
        //main quoteline
        SBQQ__Quoteline__c ql = new SBQQ__Quoteline__c ();
        ql = [select id from SBQQ__Quoteline__c where SBQQ__RequiredBy__c = null limit 1];
        cont.quotelineId = ql.id;
        
        List<SBQQ__Quoteline__c> quotelines = new List<SBQQ__Quoteline__c> ();
        List<ComponentQuoteLineScaleController.QuoteLineDiscountWrapper> discountWrapper = new List<ComponentQuoteLineScaleController.QuoteLineDiscountWrapper>();
        quotelines = cont.getquotelines();
        quotelines = cont.getquotelinesSurcharge();
        discountWrapper = cont.getquotelinesDiscount();
        quotelines = cont.getquotelinesCompetitor();
        
        
    }
}