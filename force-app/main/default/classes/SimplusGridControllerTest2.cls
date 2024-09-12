@isTest
public with sharing class SimplusGridControllerTest2 {
    @testSetup
    public static void testSetup(){
       
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
        

        // Account distributorAccount = new Account(
        //     RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
        //     Name = 'Sold To Account',
        //     AccountNumber_R1__c = '267685',
        //     Distributor__c = true
        // );
        // insert distributorAccount;

        List<Account> accList = new List<Account>();
        Account soldToAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
            Name = 'Sold To Account',
            AccountNumber_R1__c = '267687',
            Ship_To__c = true,
            Sold_To__c = true,
            Distributor__c = true
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


        // Create Product List Price
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
            Per_Quantity__c = '10',
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
            Per_Quantity__c = '100',
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
            SBQQ__Account__c = soldToAccount.Id,
            SBQQ__Distributor__c = soldToAccount.Id
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
            Product_Level__c = 'Scale',
            SBQQ__RequiredBy__c = testQuoteLine.Id
        );
        lQouteLine.add(testQuoteLineScale);

        SBQQ__QuoteLine__c testQuoteLineScale2 = new SBQQ__QuoteLine__c(
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
            Product_Level__c = 'Scale',
            SBQQ__RequiredBy__c = testQuoteLine.Id
        );
        lQouteLine.add(testQuoteLineScale2);

        SBQQ__QuoteLine__c testQuoteLineScale3 = new SBQQ__QuoteLine__c(
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
            Product_Level__c = 'Scale',
            SBQQ__RequiredBy__c = testQuoteLine.Id
        );
        lQouteLine.add(testQuoteLineScale3);

        SBQQ.TriggerControl.disable();
        insert lQouteLine;


        sbaa__ApprovalChain__c testApprovalChain    = new sbaa__ApprovalChain__c(sbaa__TargetObject__c = 'SBQQ__QuoteLine__c',
        Name='Test Chain');
        insert testApprovalChain;
        
        sbaa__Approver__c testApprover = new sbaa__Approver__c(sbaa__User__c = userInfo.getUserId());
        insert testApprover;
        
        sbaa__Approval__c approvalRecord = new sbaa__Approval__c(Quote__c = testQuote.id,
        Quote_Line__c = testQuoteLine.id,
        sbaa__ApprovalStep__c = 1,
        sbaa__RecordField__c = 'Quote_Line__c',
        sbaa__ApprovalChain__c = testApprovalChain.id,
        sbaa__Approver__c = testApprover.id);      
        insert approvalRecord ;
        Contract_Number_Mapping__c cnmTest = new Contract_Number_Mapping__c(
            CurrencyIsoCode = 'USD',                                                        
            Incoterm__c = 'PPA', 
            Original_Quote__c = testQuote.Id,
            Quote_Line__c =testQuoteLine.Id ,
            Related_Sold_To__c = soldToAccount.Id, 
            Ship_To__c = shipToAccount.Id, 
            Shipping_Condition__c = 'FT'); 
        insert cnmTest;
    }

    // static testMethod void cloneTest() {
    //     SBQQ__QuoteLine__c qlTest = [SELECT Id FROM SBQQ__QuoteLine__c LIMIT 1];
    //     SBQQ__Quote__c quoteTest = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        
    //     test.startTest();
    //     SimplusGridController.doClone(quoteTest.Id, true);
    //     test.stopTest();
    // }

    static testMethod void areQuotesCalculatedTest() {
        List<SBQQ__QuoteLine__c> qlTest = [SELECT Id FROM SBQQ__QuoteLine__c WHERE Product_Level__c = 'GMID' LIMIT 1];
        List<Id> qlIdList = new List<Id>();
        for(SBQQ__QuoteLine__c ql : qlTest){
            qlIdList.add(ql.Id);
        }
        
        test.startTest();
        SimplusGridController.areQuotesCalculated(qlIdList);
        test.stopTest();
    }

    static testMethod void getAllApprovalsTest() {
        test.startTest();
        SimplusGridController.getAllApprovals();
        test.stopTest();
    }

    static testMethod void approveRejectTest(){
       //List<Id> approvalIds, Boolean doApprove, String comments
         sbaa__Approval__c[] approvalTest = [SELECT Id, Quote__c  FROM sbaa__Approval__c LIMIT 1];
        Map<Id, Set<Id>> mQuoteApproval = new Map<Id, Set<Id>>();
        String approvalIds = '';
        for (sbaa__Approval__c ap : approvalTest){
            Id approvalIdtmp = ap.Id;
            if (mQuoteApproval.containsKey(ap.Quote__c)){
                mQuoteApproval.get(ap.Quote__c).add(approvalIdtmp);
            } else {
                Set<Id> lApprovalIdtmp = new Set<Id>();
                lApprovalIdtmp.add(approvalIdtmp);
                mQuoteApproval.put(ap.Quote__c,lApprovalIdtmp);
            }
        }
        //convert approvalTest to approvalIds in JSON format
        for (Id quoteId : mQuoteApproval.keySet()){
            approvalIds = JSON.serialize(mQuoteApproval.get(quoteId));
        }
        Test.startTest();
        SimplusGridController.approveReject(approvalIds, true, 'test comment');
        Test.setMock(HttpCalloutMock.class, new SimplusGridControllerTest2.MockHttpResponseGenerator());
        SimplusGridController.massApproveReject(new List<Id>{approvalTest[0].Id}, true, 'test comment');
        Test.stopTest();
        
    }

    //getLineFromApproval

    static testMethod void getLinesToApproveTest() {
        List<SBQQ__QuoteLine__c> qlTest = [SELECT Id FROM SBQQ__QuoteLine__c WHERE Product_Level__c = 'GMID' LIMIT 1];
        
        test.startTest();
        SimplusGridController.getLinesToApprove(qlTest[0].Id);
        test.stopTest();
    }

     static testMethod void getLineFromApprovalTest() {
        SBQQ__Quote__c quoteTest = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        sbaa__Approval__c[] approvalTest = [SELECT Id, Quote__c  FROM sbaa__Approval__c LIMIT 1];
        
        test.startTest();
        // SimplusGridController.getLineFromApproval(quoteTest[0].Id);
        SimplusGridController.getLineFromApproval(approvalTest[0].Id);
        test.stopTest();
    }

    static testMethod void getLinesFromApprovalTest() {
        SBQQ__Quote__c quoteTest = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        
        test.startTest();
        SimplusGridController.getLinesFromApproval(quoteTest.Id);
        test.stopTest();
    }

    //getApproverName
    static testMethod void getApproverNameTest() {
        sbaa__Approval__c[] approvalTest = [SELECT Id, Quote__c  FROM sbaa__Approval__c LIMIT 1];
        
        test.startTest();
        // SimplusGridController.getLineFromApproval(quoteTest[0].Id);
        SimplusGridController.getApproverName(approvalTest[0].Id);
        test.stopTest();
    }

    static testMethod void saveInlineEditRecordsScaleTest(){
        Map<Id, SBQQ__QuoteLine__c> quoteLineMap = new Map<Id, SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> qlTest = [SELECT Id, New_Delivered_Price__c, New_Price_Start_Date__c,New_Price_Firm_Date__c FROM SBQQ__QuoteLine__c WHERE Product_Level__c = 'Scale' LIMIT 1];
        List<Id> qlIdList = new List<Id>();
        for(SBQQ__QuoteLine__c ql : qlTest){
            qlIdList.add(ql.Id);
            quoteLineMap.put(ql.Id, ql);
        }
        Date priceStartDate = Date.today();
        Date priceEndDate = priceStartDate.addMonths(1); 
        
        test.startTest();
        SimplusGridController.saveInlineEditRecords(quoteLineMap, priceStartDate, priceEndDate);
        test.stopTest();
    }

    static testMethod void saveInlineEditRecordsGMIDTest(){
        Map<Id, SBQQ__QuoteLine__c> quoteLineMap = new Map<Id, SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> qlTest = [SELECT Id, New_Delivered_Price__c, New_Price_Start_Date__c,New_Price_Firm_Date__c FROM SBQQ__QuoteLine__c WHERE Product_Level__c = 'GMID' LIMIT 1];
        List<Id> qlIdList = new List<Id>();
        for(SBQQ__QuoteLine__c ql : qlTest){
            qlIdList.add(ql.Id);
            quoteLineMap.put(ql.Id, ql);
        }
        Date priceStartDate = Date.today();
        Date priceEndDate = priceStartDate.addMonths(1); 
        
        test.startTest();
        SimplusGridController.saveInlineEditRecords(quoteLineMap, priceStartDate, priceEndDate);
        test.stopTest();
    }
    
    static testMethod void retrievedProductListPriceGMIDTest(){
        Map<Id, SBQQ__QuoteLine__c> quoteLineMap = new Map<Id, SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> qlTest = [SELECT Id, New_Delivered_Price__c, New_Price_Start_Date__c,New_Price_Firm_Date__c FROM SBQQ__QuoteLine__c WHERE Product_Level__c = 'GMID' LIMIT 1];
        List<Id> qlIdList = new List<Id>();
        for(SBQQ__QuoteLine__c ql : qlTest){
            qlIdList.add(ql.Id);
            quoteLineMap.put(ql.Id, ql);
            ql.Distributor__c = true;
        }

        update qlTest; 

        Date priceStartDate = Date.today();
        Date priceEndDate = priceStartDate.addMonths(1); 
        
        test.startTest();
        SimplusGridController.retrievedProductListPrice(qlIdList, priceStartDate, priceEndDate);
        test.stopTest();
    }

    static testMethod void retrievedProductListPriceScaleTest(){
        Map<Id, SBQQ__QuoteLine__c> quoteLineMap = new Map<Id, SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> qlTest = [SELECT Id, New_Delivered_Price__c, New_Price_Start_Date__c,New_Price_Firm_Date__c FROM SBQQ__QuoteLine__c WHERE Product_Level__c = 'Scale' LIMIT 1];
        List<Id> qlIdList = new List<Id>();
        for(SBQQ__QuoteLine__c ql : qlTest){
            qlIdList.add(ql.Id);
            quoteLineMap.put(ql.Id, ql);
            ql.Distributor__c = true;
        }

        update qlTest; 

        Date priceStartDate = Date.today();
        Date priceEndDate = priceStartDate.addMonths(1); 
        
        test.startTest();
        SimplusGridController.retrievedProductListPrice(qlIdList, priceStartDate, priceEndDate);
        test.stopTest();
    }

     static testMethod void handleScalePricingUpdateFromProductListPriceTest(){
        
        List<SBQQ__QuoteLine__c> qlTest = [SELECT Id, New_Delivered_Price__c, New_Price_Start_Date__c,New_Price_Firm_Date__c, SBQQ__RequiredBy__c, SBQQ__RequiredBy__r.SBQQ__Product__c, SAP_Sales_Org__c, SBQQ__Number__c, SBQQ__ListPrice__c, Per_Quantity__c FROM SBQQ__QuoteLine__c WHERE Product_Level__c = 'Scale' LIMIT 1];
        
        for(SBQQ__QuoteLine__c ql : qlTest){
            ql.Distributor__c = true;
            ql.SBQQ__ListPrice__c = 0;
        }

        update qlTest; 

        Date priceStartDate = Date.today();
        Date priceEndDate = priceStartDate.addMonths(1); 
        
        test.startTest();
        SimplusGridController.handleScalePricingUpdateFromProductListPrice(qlTest, priceStartDate, priceEndDate);
        test.stopTest();
    }

    static testMethod void saveRecordsTest(){
        
        List<SBQQ__QuoteLine__c> qlTest = [SELECT Id, New_Delivered_Price__c, New_Price_Start_Date__c,New_Price_Firm_Date__c, SBQQ__RequiredBy__c, SBQQ__RequiredBy__r.SBQQ__Product__c, SAP_Sales_Org__c, SBQQ__Number__c, SBQQ__ListPrice__c, Per_Quantity__c FROM SBQQ__QuoteLine__c WHERE Product_Level__c = 'Scale' LIMIT 1];
        
        for(SBQQ__QuoteLine__c ql : qlTest){
            ql.Distributor__c = true;
            ql.SBQQ__ListPrice__c = 0;
        }

        String quoteLineJson = JSON.serialize(qlTest);
        
        test.startTest();
        SimplusGridController.saveRecords(quoteLineJson);
        test.stopTest();
    }

    static testMethod void saveRecordsNegativeTest(){
        
        List<SBQQ__QuoteLine__c> qlTest = [SELECT New_Delivered_Price__c, New_Price_Start_Date__c,New_Price_Firm_Date__c, SBQQ__RequiredBy__c, SBQQ__RequiredBy__r.SBQQ__Product__c, SAP_Sales_Org__c, SBQQ__Number__c, SBQQ__ListPrice__c, Per_Quantity__c FROM SBQQ__QuoteLine__c WHERE Product_Level__c = 'Scale' LIMIT 1];
        
        for(SBQQ__QuoteLine__c ql : qlTest){
            ql.Distributor__c = true;
            ql.SBQQ__ListPrice__c = 0;
        }

        String quoteLineJson = JSON.serialize(qlTest);
        
        test.startTest();
        SimplusGridController.saveRecords(quoteLineJson);
        test.stopTest();
    }
    static testMethod void validateQuotesForCloningTest(){
        
        List<Id> qlIds = new List<Id>();
        for (SBQQ__QuoteLine__c ql : [SELECT Id FROM SBQQ__QuoteLine__c WHERE Product_Level__c = 'GMID']) {
            qlIds.add(ql.Id);
        }
        
        test.startTest();
        SimplusGridController.validateQuotesForCloning(qlIds);
        test.stopTest();
    }
    

    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"access_token": "mocked_token"}'); // Set the desired response body
            return res;
        }
    }
    
}