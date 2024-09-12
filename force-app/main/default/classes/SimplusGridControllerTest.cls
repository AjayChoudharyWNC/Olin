@isTest(SeeAllData=true)
public class SimplusGridControllerTest {

    testMethod static void controlFieldTest() {
        List<String> fieldset = new List<String>();
        fieldset.add('SimplusGrid');
        SimplusGridController.getControlFields(fieldset);
    }

    testMethod static void getFieldSetTest() {
        String fieldSets = '[{"name": "SimplusGrid", "type": "display"}, {"name": "SimplusGrid_Filter", "type": "filter"}]';
        List<SimplusGridController.FieldSetConfig> configs = (List<SimplusGridController.FieldSetConfig>)JSON.deserialize(fieldSets, List<SimplusGridController.FieldSetConfig>.class);
        SimplusGridController.FieldSetWrapperGroup fieldSet = SimplusGridController.getFieldSet('SBQQ__QuoteLine__c', configs, 'SimplusGrid');
        System.assertNotEquals(fieldSet, null);
    }

    testMethod static void getUserTest() {
        Test.startTest();
        user testingUser = SimplusGridController.fetchUser();
        System.assertNotEquals(testingUser, null);
        
        List<Id> quoteIds = new List<Id>();
        for(SBQQ__Quote__c q : [SELECT Id FROM SBQQ__Quote__c LIMIT 10]) {
            quoteIds.add(q.Id);
        }
        SimplusGridController.getQuotesForCloning(quoteIds);
        Test.stopTest();
    }

    testMethod static void toggle() {
        SimplusGridController.FieldSetWrapperGroup wrapperGroup = SimplusGridController.toggle('SBQQ__QuoteLine__c','SimplusGrid', 1);
        System.assertNotEquals(wrapperGroup, null);
    }
    
    testMethod static void testCustomUtilites() {
        Test.startTest();
        CustomUtilitiesController.doSearch('Account', new List<String>{'Id','Name'}, 'Name <> \'a\'', '', 'tes', new List<String>{'Id','Name'});
        Test.stopTest();
    }

    testMethod static void sortFilterTests() {
        
        List<SimplusGrid_Sorting__c> sortGroup = new List<SimplusGrid_Sorting__c>();
        SimplusGrid_Sorting__c sort1 = new SimplusGrid_Sorting__c (
            Column__c = 'SBQQ__ProductCode__c',
            Column_Name__c = 'Product Code',
            Order__c = 'ASC',
            Priority__c = 1,
            Active__c = true,
            OwnerId = userInfo.getUserId(),
            List_Source__c = 'SimplusGrid'
        );
        sortGroup.add(sort1);
        SimplusGrid_Sorting__c sort2 = new SimplusGrid_Sorting__c(
            Column__c = 'SBQQ__ProductName__c',
            Column_Name__c = 'Product Name',
            Order__c = 'ASC',
            Priority__c = 2,
            Active__c = true,
            OwnerId = userInfo.getUserId(),
            List_Source__c = 'SimplusGrid'
        );
        sortGroup.add(sort2);
        SimplusGrid_Sorting__c sort3 = new SimplusGrid_Sorting__c(
            Column__c = 'SBQQ__ListPrice__c',
            Column_Name__c = 'Base Price',
            Order__c = 'DESC',
            Priority__c = 3,
            Active__c = true,
            OwnerId = userInfo.getUserId(),
            List_Source__c = 'SimplusGrid'
        );
        sortGroup.add(sort3);
        insert sortGroup;

        List<SimplusGrid_Filtering__c> filterGroup = new List<SimplusGrid_Filtering__c>();
        filterGroup.add(new SimplusGrid_Filtering__c(
            Column__c = 'SBQQ__ProductName__c',
            Column_Name__c = 'Product Name',
            Column_Type__c = 'STRING',
            Operation__c = 'starts with',
            Value__c = 'AIRSTONE 550E',
            Priority__c = 1,
            Active__c = true,
            OwnerId = userInfo.getUserId(),
            List_Source__c = 'SimplusGrid'
        ));
        filterGroup.add(new SimplusGrid_Filtering__c(
            Column__c = 'SBQQ__ProductName__c',
            Column_Name__c = 'Product Name',
            Column_Type__c = 'STRING',
            Operation__c = 'ends with',
            Value__c = 'AIRSTONE 550E',
            Priority__c = 2,
            Active__c = true,
            OwnerId = userInfo.getUserId(),
            List_Source__c = 'SimplusGrid'
        ));
        filterGroup.add(new SimplusGrid_Filtering__c(
            Column__c = 'SBQQ__ProductName__c',
            Column_Name__c = 'Product Name',
            Column_Type__c = 'STRING',
            Operation__c = 'contains',
            Value__c = 'AIRSTONE 550E',
            Priority__c = 3,
            Active__c = true,
            OwnerId = userInfo.getUserId(),
            List_Source__c = 'SimplusGrid_Filter'
        ));
        filterGroup.add(new SimplusGrid_Filtering__c(
            Column__c = 'SBQQ__ListPrice__c',
            Column_Name__c = 'Base Price',
            Column_Type__c = 'DOUBLE',
            Operation__c = 'eq',
            Value__c = '0',
            Priority__c = 4,
            Active__c = true,
            OwnerId = userInfo.getUserId(),
            List_Source__c = 'SimplusGrid_Filter'
        ));
        filterGroup.add(new SimplusGrid_Filtering__c(
            Column__c = 'SBQQ__ListPrice__c',
            Column_Name__c = 'Base Price',
            Column_Type__c = 'DOUBLE',
            Operation__c = 'lt',
            Value__c = '1',
            Priority__c = 5,
            Active__c = true,
            OwnerId = userInfo.getUserId(),
            List_Source__c = 'SimplusGrid_Filter'
        ));
        filterGroup.add(new SimplusGrid_Filtering__c(
            Column__c = 'SBQQ__ListPrice__c',
            Column_Name__c = 'Base Price',
            Column_Type__c = 'DOUBLE',
            Operation__c = 'gt',
            Value__c = '-1',
            Priority__c = 6,
            Active__c = true,
            OwnerId = userInfo.getUserId(),
            List_Source__c = 'SimplusGrid_Filter'
        ));
        filterGroup.add(new SimplusGrid_Filtering__c(
            Column__c = 'Price_Firm_Date__c',
            Column_Name__c = 'Price Firm Date',
            Column_Type__c = 'DATE',
            Operation__c = 'before',
            Value__c = '2019-01-31',
            Priority__c = 7,
            Active__c = true,
            OwnerId = userInfo.getUserId(),
            List_Source__c = 'SimplusGrid_Filter'
        ));
        filterGroup.add(new SimplusGrid_Filtering__c(
            Column__c = 'Price_Firm_Date__c',
            Column_Name__c = 'Price Firm Date',
            Column_Type__c = 'DATE',
            Operation__c = 'after',
            Value__c = '2019-01-29',
            Priority__c = 8,
            Active__c = true,
            OwnerId = userInfo.getUserId(),
            List_Source__c = 'SimplusGrid_Filter'
        ));
        filterGroup.add(new SimplusGrid_Filtering__c(
            Column__c = 'Price_Firm_Date__c',
            Column_Name__c = 'Price Firm Date',
            Column_Type__c = 'DATE',
            Operation__c = 'equal',
            Value__c = '2019-01-30',
            Priority__c = 9,
            Active__c = true,
            OwnerId = userInfo.getUserId(),
            List_Source__c = 'SimplusGrid_Filter'
        ));
        filterGroup.add(new SimplusGrid_Filtering__c(
            Column__c = 'Price_Firm_Date__c',
            Column_Name__c = 'Price Firm Date',
            Column_Type__c = 'DATETIME',
            Operation__c = 'before',
            Value__c = '2019-01-31 00:00:01',
            Priority__c = 10,
            Active__c = true,
            OwnerId = userInfo.getUserId(),
            List_Source__c = 'SimplusGrid_Filter'
        ));
        filterGroup.add(new SimplusGrid_Filtering__c(
            Column__c = 'Price_Firm_Date__c',
            Column_Name__c = 'Price Firm Date',
            Column_Type__c = 'DATETIME',
            Operation__c = 'after',
            Value__c = '2019-01-29 00:00:01',
            Priority__c = 11,
            Active__c = true,
            OwnerId = userInfo.getUserId(),
            List_Source__c = 'SimplusGrid_Filter'
        ));
        filterGroup.add(new SimplusGrid_Filtering__c(
            Column__c = 'Price_Firm_Date__c',
            Column_Name__c = 'Price Firm Date',
            Column_Type__c = 'DATETIME',
            Operation__c = 'equal',
            Value__c = '2019-01-30 00:00:01',
            Priority__c = 12,
            Active__c = true,
            OwnerId = userInfo.getUserId(),
            List_Source__c = 'SimplusGrid_Filter'
        ));
        filterGroup.add(new SimplusGrid_Filtering__c(
            Column__c = 'SBQQ__ProductName__c',
            Column_Name__c = 'Product Name',
            Column_Type__c = 'STRING',
            Operation__c = 'equals',
            Value__c = 'AIRSTONE 550E',
            Priority__c = 13,
            Active__c = true,
            OwnerId = userInfo.getUserId(),
            List_Source__c = 'SimplusGrid_Filter'
        ));
        insert filterGroup;

        // Create Account
        Account testAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Competitor').getRecordTypeId(),
            Name = 'Test Account',
            AccountNumber_R1__c = '123',
            AccountSource = 'Olin Heritage'
        );
        insert testAccount;

        // Account soldToAccount = new Account(
        //     RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
        //     Name = 'Sold To Account',
        //     AccountNumber_R1__c = '267687',
        //     Ship_To__c = true,
        //     Sold_To__c = true
        // );
        // insert soldToAccount;

        // Account shipToAccount = new Account(
        //     RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
        //     Name = 'First Ship To Account',
        //     AccountNumber_R1__c = '267623',
        //     Ship_To__c = true,
        //     ParentId = soldToAccount.Id
        // );
        // insert shipToAccount;

        // Create Product
        Product2 testProduct = new Product2(
            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
            Name = 'Test Product',
            ProductCode = '105001',
            Product_Level__c = 'GMID'
        );
        insert testProduct;

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
            Price_Start_Date__c = Date.today().addYears(-2),
            SBQQ__Opportunity2__c = testOpportunity.Id,
            Ship_To_Any__c= true
        );
        insert testQuote;

        // Create Quote Lines
        // List<SBQQ__QuoteLine__c> lstTestQuoteLine = new List<SBQQ__QuoteLine__c>();
        // SBQQ__QuoteLine__c testQuoteLine = new SBQQ__QuoteLine__c(
        //     SBQQ__Quote__c = testQuote.Id,
        //     SBQQ__Product__c = testProduct.Id,
        //     SBQQ__Quantity__c = 1,
        //     SBQQ__ListPrice__c = 10,
        //     SBQQ__NetPrice__c = 10,
        //     SBQQ__Number__c = 1,
        //     SBQQ__SubscriptionPricing__c = 'Fixed Price',
        //     Price_Start_Date__c = date.newInstance(2019, 12, 31),
        //     Ship_To__c = shipToAccount.Id,
        //     SBQQ__Bundle__c = true,
        //     Product_Level__c = 'GMID'
        //     // New_Price_Start_Date__c = Date.today().addDays(1)
        // );
        // // lstTestQuoteLine.add(testQuoteLine);
        // insert lstTestQuoteLine;
        
        //Generate the filter query
        SimplusGridController.dynamicQueryFilter('SimplusGrid_Filter');

        //Setup the sort and filter wrapper collections
        List<SimplusGridController.SortColumWrapper> sortWrapper = SimplusGridController.querySort('SBQQ__QuoteLine__c','SimplusGrid');
        List<SimplusGridController.FilterColumWrapper> filterWrapper = SimplusGridController.queryFilter('SBQQ__QuoteLine__c','SimplusGrid');
        //Test drag and drop
        SimplusGridController.dragAndDrop('sort', JSON.serialize(sortWrapper));
        SimplusGridController.dragAndDrop('filter', JSON.serialize(filterWrapper));
            
            //Ordering updates
            try {
            SimplusGridController.sortColumns(JSON.serialize(sortWrapper[0]), JSON.serialize(sortWrapper), 'SimplusGrid');
            } catch(Exception e) {}
            try {
            SimplusGridController.filterColumns(JSON.serialize(filterWrapper[0]), JSON.serialize(filterWrapper), 'SimplusGrid');
            } catch(Exception e) {}
            
            SimplusGridController.toggleSortFilterItem('SBQQ__QuoteLine__c','sort', sortGroup[0].Id, true, 1);
            SimplusGridController.toggleSortFilterItem('SBQQ__QuoteLine__c','filter', filterGroup[0].Id, true, 1);
            SimplusGridController.deleteSortFilterItem('SBQQ__QuoteLine__c','sort', sortGroup[0].Id, 1);
            SimplusGridController.deleteSortFilterItem('SBQQ__QuoteLine__c','filter', filterGroup[0].Id, 1);
    
            //Update the sort and filter wrapper collections        
            sortWrapper = SimplusGridController.querySort('SBQQ__QuoteLine__c','SimplusGrid');
            filterWrapper = SimplusGridController.queryFilter('SBQQ__QuoteLine__c','SimplusGrid');
            SimplusGridController.deleteAllSortFilterItem('sort', JSON.serialize(sortWrapper));
            SimplusGridController.deleteAllSortFilterItem('filter', JSON.serialize(filterWrapper));

            // SimplusGridController.saveRecords(JSON.serialize(lstTestQuoteLine));
    
            List<String> lstStr = new List<String>{testQuote.Id};
        Test.startTest();
            List<Id> quoteLineIds = new List<Id>{testQuote.Id};
        
            String jsonReturn = SimplusGridController.cloneRecords(quoteLineIds, true);
            Map<String, Object> objMap = (Map<String, Object>) JSON.deserializeUntyped(jsonReturn);
            // System.assertEquals('Clone successful!',  objMap.get('message'));
        Test.stopTest();
    }
    
    public testmethod static void testSortFilter() {
    
        List<SimplusGridController.SortColumWrapper> sortWrapper = SimplusGridController.querySort('SBQQ__QuoteLine__c','SimplusGrid');
        List<SimplusGridController.FilterColumWrapper> filterWrapper = SimplusGridController.queryFilter('SBQQ__QuoteLine__c','SimplusGrid');
        Test.startTest();
        //Test drag and drop
        SimplusGridController.dragAndDrop('sort', JSON.serialize(sortWrapper));
        SimplusGridController.dragAndDrop('filter', JSON.serialize(filterWrapper));
        
        //Ordering updates
        try {
        SimplusGridController.sortColumns(JSON.serialize(sortWrapper[0]), JSON.serialize(sortWrapper), 'SimplusGrid');
        } catch(Exception e) {}
        try {
        SimplusGridController.filterColumns(JSON.serialize(filterWrapper[0]), JSON.serialize(filterWrapper), 'SimplusGrid');
        } catch(Exception e) {}
    }

    // static testMethod void cloneTest() {
    //     SBQQ__QuoteLine__c qlTest = [SELECT Id FROM SBQQ__QuoteLine__c LIMIT 1];
    //     SBQQ__Quote__c quoteTest = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        
    //     test.startTest();
    //     SimplusGridController.doClone(quoteTest.Id, true);
    //     test.stopTest();
    // }

    static testMethod void getmydomainTest() {
        Test.startTest();
        SimplusGridController.getmydomain();
        Test.stopTest();
    }
    

}