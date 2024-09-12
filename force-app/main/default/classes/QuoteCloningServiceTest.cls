@isTest
public class QuoteCloningServiceTest {
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

        //Create Product
        

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
            SBQQ__Bundle__c = true,
            Product_Level__c = 'GMID'
        );
        insert testQuoteLine;

        // Id defaultQlRtId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByDeveloperName().get('Quote_Lines').getRecordTypeId();
       
        
        
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
    
    static testMethod void cloneAsyncTest() {
        SBQQ__QuoteLine__c qlTest = [SELECT Id FROM SBQQ__QuoteLine__c LIMIT 1];
        SBQQ__Quote__c quoteTest = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        Product2 testProduct2 = [SELECT Id FROM Product2 WHERE Product_Level__c = 'Scale' LIMIT 1];
        // Product2 testProduct3 = [SELECT Id FROM Product2 WHERE Product_Level__c = 'GMID' AND Name = 'Test Product 3' LIMIT 1];
        //Name = 'Test Product 3',
        // // Account shipToAccount = [SELECT Id FROM Account WHERE Ship_To__c = true AND Name = 'First Ship To Account' LIMIT 1];
        // System.debug('opp id ::::' + quoteTest.O);

         SBQQ__QuoteLine__c testQuoteLineChild= new SBQQ__QuoteLine__c(
            // RecordTypeId = defaultQlRtId,
            SBQQ__Quote__c = quoteTest.Id,
            SBQQ__Product__c = testProduct2.Id,
            SBQQ__Quantity__c = 1,
            SBQQ__ListPrice__c = 8,
            SBQQ__NetPrice__c = 8,
            SBQQ__Number__c = 2,
            Price_Start_Date__c = date.newInstance(2019, 12, 31),
            // Ship_To__c = shipToAccount.Id,
            SBQQ__Bundle__c = false,
            SBQQ__RequiredBy__c = qlTest.Id,
            Product_Level__c = 'Scale',
            SBQQ__OptionLevel__c = 1,
            SBQQ__OptionType__c = 'Related Product',
            SBQQ__PriceEditable__c = false,
            SBQQ__PricebookEntryId__c = null

        );
        SBQQ.TriggerControl.disable();
        insert testQuoteLineChild;
        
        test.startTest();
        QuoteCloningService.cloneAsync(new Set<Id>{quoteTest.Id}, new Set<Id>{qlTest.Id});
        test.stopTest();
    }
     static testMethod void cloneTest() {
        SBQQ__QuoteLine__c qlTest = [SELECT Id FROM SBQQ__QuoteLine__c LIMIT 1];
        SBQQ__Quote__c quoteTest = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        
        test.startTest();
        QuoteCloningService.clone(new Set<Id>{quoteTest.Id}, new Set<Id>{qlTest.Id}, True);
        test.stopTest();
    }

}