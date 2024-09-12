@isTest
public class CreateListPriceControllerTest {
    @TestSetup
    static void makeData(){

        // Create internal account
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

         // Create Account
        List<Account> accList = new List<Account>();
        Account soldToAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
            Name = 'Sold To Account',
            AccountNumber_R1__c = '267687',
            Ship_To__c = true,
            Sold_To__c = true
        );
        // insert soldToAccount;
        accList.add(soldToAccount);
        
        Account shipToAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
            Name = 'First Ship To Account',
            AccountNumber_R1__c = '267623',
            Ship_To__c = true,
            ParentId = soldToAccount.Id
        );
        // insert shipToAccount;
        accList.add(shipToAccount);

        Account shipToAccount2 = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
            Name = 'Second Ship To Account',
            AccountNumber_R1__c = '267432',
            Ship_To__c = true,
            ParentId = soldToAccount.Id
        );
        // insert shipToAccount2;
        accList.add(shipToAccount2);
        insert accList;

        // Create Account Relationship
        List<Account_Relationships__c> lstTestAccountRelationship = new List<Account_Relationships__c>();
        Account_Relationships__c testAccountRel = new Account_Relationships__c(
            Name = 'Test Account Relationship',
            Relationship_Type__c = 'Sold To / Ship To',
            Sold_To__c = soldToAccount.Id,
            Ship_To__c = shipToAccount.Id
        );
        lstTestAccountRelationship.add(testAccountRel);

        testAccountRel = new Account_Relationships__c(
            Name = 'Test Account Relationship 2',
            Relationship_Type__c = 'Sold To / Ship To',
            Sold_To__c = soldToAccount.Id,
            Ship_To__c = shipToAccount2.Id
        );
        lstTestAccountRelationship.add(testAccountRel);
        insert lstTestAccountRelationship;

        // Create Account Team Members
        AccountTeamMember teamMember = new AccountTeamMember(
            AccountId = soldToAccount.Id,
            UserId = lstTestUser[0].Id
        );
        insert teamMember;

        //Create Product
        Product2 testProduct = new Product2(
            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
            Name = 'Test Product',
            TradeProduct_R1__c = '123456',
            Product_Level__c = 'GMID',
            ProductCode = '1000000497'
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
            SBQQ__MinOptionCount__c = 0
        );
        insert testProductFeature;

        //Create Product Options
        SBQQ__ProductOption__c[] lProductOptions = new SBQQ__ProductOption__c[] {};
        SBQQ__ProductOption__c testProductOption = new SBQQ__ProductOption__c(
            SBQQ__ConfiguredSKU__c = testProduct.Id,
            SBQQ__OptionalSKU__c = testProductScale.Id,
            SBQQ__Number__c = 	300,
            SBQQ__Feature__c = testProductFeature.Id
        );
        lProductOptions.add(testProductOption);

        SBQQ__ProductOption__c testProductOption2 = new SBQQ__ProductOption__c(
            SBQQ__ConfiguredSKU__c = testProduct.Id,
            SBQQ__OptionalSKU__c = testProductScale2.Id,
            SBQQ__Number__c = 	310,
            SBQQ__Feature__c = testProductFeature.Id
        );
        lProductOptions.add(testProductOption2);

        SBQQ__ProductOption__c testProductOption3 = new SBQQ__ProductOption__c(
            SBQQ__ConfiguredSKU__c = testProduct.Id,
            SBQQ__OptionalSKU__c = testProductScale3.Id,
            SBQQ__Number__c = 	320,
            SBQQ__Feature__c = testProductFeature.Id
        );
        lProductOptions.add(testProductOption3);

        insert lProductOptions;


        //Create Product List Price
        Product_List_Price__c[] lProductListPrice = new Product_List_Price__c[] {};
        Product_List_Price__c testProductListPrice = new Product_List_Price__c(
            Product__c = testProduct.Id,
            Index_Order_Number__c = 1,
            List_Price__c = 10,
            Per_Quantity__c = '1',
            ScaleQty__c = 80,
            Type__c = 'Add',
            UOM__c = 'LB',
            Valid_From__c = date.newInstance(2019, 03, 01),
            Valid_To__c = date.newInstance(2025, 12, 31)
        );
        lProductListPrice.add(testProductListPrice);

        Product_List_Price__c testProductListPrice2 = new Product_List_Price__c(
            Product__c = testProduct.Id,
            Index_Order_Number__c = 2,
            List_Price__c = 11,
            Per_Quantity__c = '1',
            ScaleQty__c = 40,
            Type__c = 'Add',
            UOM__c = 'LB',
            Valid_From__c = date.newInstance(2019, 03, 01),
            Valid_To__c = date.newInstance(2025, 12, 31)
        );
        lProductListPrice.add(testProductListPrice2);

        Product_List_Price__c testProductListPrice3 = new Product_List_Price__c(
            Product__c = testProduct.Id,
            Index_Order_Number__c = 3,
            List_Price__c = 12,
            Per_Quantity__c = '1',
            ScaleQty__c = 20,
            Type__c = 'Add',
            UOM__c = 'LB',
            Valid_From__c = date.newInstance(2019, 03, 01),
            Valid_To__c = date.newInstance(2025, 12, 31)
        );
        lProductListPrice.add(testProductListPrice3);

        insert lProductListPrice;

        // Create Opportunity
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity testOpportunity = new Opportunity(
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Epoxy Commercial').getRecordTypeId(),
            Name = 'Test Opportunity',
            AccountId = soldToAccount.Id,
            CloseDate = date.newInstance(2019, 12, 31),
            StageName = 'Discovery/Qualification',
            CurrencyIsoCode = 'USD',
            Contract_Start_Date__c = date.newInstance(2019, 03, 01),
            Contract_End_Date__c = date.newInstance(2019, 12, 31)
        );
        //oppList.add(testOpportunity);
        insert testOpportunity;
        
        // Create Quote
        List<SBQQ__Quote__c> qList = new List<SBQQ__Quote__c>();
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c(
            RecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Draft Price Request').getRecordTypeId(),
            SBQQ__Primary__c = true,
            Price_Start_Date__c = date.newInstance(2019, 03, 01),
            SBQQ__Opportunity2__c = testOpportunity.Id,
            Ship_To_Any__c= true,
            SBQQ__Account__c = soldToAccount.Id
        );
        //insert testQuote;
        qList.add(testQuote);
        insert qList;
        
        // Create Quote Line

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
            Price_Firm_Date__c = date.newInstance(2020,1,31),
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
            Price_Firm_Date__c = date.newInstance(2020,1,31),
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
            Price_Firm_Date__c = date.newInstance(2020,1,31),
            Ship_To__c = shipToAccount.Id,
            Price_Request_Account__c = shipToAccount.Id,
            // Ship_To_Account__c = testAccountRel.Id,
            SBQQ__Bundle__c = true,
            Product_Level__c = 'Scale',
            SBQQ__RequiredBy__c = testQuoteLine.Id
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
            Price_Firm_Date__c = date.newInstance(2020,1,31),
            Ship_To__c = shipToAccount.Id,
            Price_Request_Account__c = shipToAccount.Id,
            // Ship_To_Account__c = testAccountRel.Id,
            SBQQ__Bundle__c = true,
            Product_Level__c = 'Scale',
            SBQQ__RequiredBy__c = testQuoteLine.Id
        );
        lQouteLine.add(testQuoteLineScale3);

        SBQQ.TriggerControl.disable();
        insert lQouteLine;
    }
    static testMethod void CreateListPriceControllerTest(){
        SBQQ__Quote__c qt = [SELECT ID FROM SBQQ__Quote__c LIMIT 1];
        Test.StartTest(); 
        PageReference testPage = Page.CreateListPricesVF; 
        Test.setCurrentPage(testPage);
        testPage.getParameters().put('quoteId', String.valueOf(qt.Id));
        
        ApexPages.StandardController sc = new  ApexPages.StandardController(qt);     
        CreateListPriceController ext = new CreateListPriceController(); 
        ext.createListPricesForQuote();
        Test.StopTest();
    }
}