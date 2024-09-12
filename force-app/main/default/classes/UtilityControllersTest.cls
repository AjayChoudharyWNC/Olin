@isTest
public class UtilityControllersTest {
    
    @testSetup
    public static void createData() {
        Product2 p = new Product2(
            SBQQ__SubscriptionTerm__c = 12,
            Fusion_Harmonized_Matl__c = '1233332123',
            TradeProduct_R1__c = '123456',
            LegacyBCCode_R1__c = '42275',
            ProductCode = '42275',
            TradeProdCode_R1__c = '42275',
 //         EXTERNALDATASOURCEID_R1__c = 'BCSAP', - Fix to prevent validation against invalid data source.
            EXTERNALDATASOURCEID_R1__c = 'Blue Cube',
           Family = 'CAPV',
            LineOfBusiness_R1__c = 'CAPV',
            MaterialGroup_R1__c = 'CAUSTIC',
            PerfCenterCode_R1__c = 'CAUSTIC SALES',
            PerformanceCenter_R1__c = 'CAUSTIC SALES',
            ProdCenter_R1__c = 'CAUSTIC SALES',
            ProdCenterCode_R1__c = 'CAUSTIC SALES',
            ValueCenter_R1__c = 'CAUSTIC SALES',
            ValueCenterCode_R1__c = 'CAUSTIC SALES',
            Description = 'CAUSTIC SODA 25% IND GR',
            Name = 'CAUSTIC SODA 25% IND GR',
            PlanProdCode_R1__c = 'CAUSTIC SODA 50PCT SOLN',
            PlanProduct_R1__c = 'CAUSTIC SODA 50PCT SOLN',
            SBQQ__OptionSelectionMethod__c = 'Click',
            UnitOfMeasure_R1__c = 'DT',
            Base_UOM__c = 'DT',
            UOM__c = 'DT',
            SBQQ__ConfigurationEvent__c = 'Edit',
            SBQQ__SubscriptionPricing__c = 'Fixed Price',
            SBQQ__PricingMethod__c = 'List',
            SBQQ__SubscriptionBase__c = 'List',
            SBQQ__SubscriptionType__c = 'Renewable',
            SBQQ__ConfigurationType__c = 'Required',
            SBQQ__OptionLayout__c = 'Sections',
            Product_Level__c = 'Trade Product',
            SBQQ__PriceEditable__c = true,
            SBQQ__QuantityEditable__c = true
        );
        insert p;
    
        Account a = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
            Name='TestAcct', 
            NumberOfEmployees=100,
            Sap_Id__c = '9000001',
            Ship_to__c = true,
            AccountNumber_R1__c = '123',
            AccountSource = 'Olin Heritage'
        );
        insert a;
        
        
        Opportunity testOpportunity = new Opportunity(
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CAPV Commercial').getRecordTypeId(),
            Name = 'Test Opportunity',
            CloseDate = date.newInstance(2019, 03, 01),
            StageName = 'Proposal',
            CurrencyIsoCode = 'USD',
            AccountId = a.Id
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
        List<SBQQ__QuoteLine__c> lstTestQuoteLine = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c testQuoteLine = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = testQuote.Id,
            SBQQ__Product__c = p.Id,
            SBQQ__Quantity__c = 1,
            SBQQ__ListPrice__c = 10,
            SBQQ__NetPrice__c = 10,
            SBQQ__Number__c = 1,
            SBQQ__SubscriptionPricing__c = 'Fixed Price'
        );
        lstTestQuoteLine.add(testQuoteLine);
        insert lstTestQuoteLine;
        
        insert new Mulesoft_CloneEndpoint__c (
            Endpoint__c = 'http://www.google.com',
            Operation__c = 'get',
            Authentication__c = 'basicauth'
        );
        
    }

    public static testmethod void CustomUtilities_doSearch() {
        Test.startTest();
        CustomUtilitiesController.doSearch('Account', new List<String>{'Id','Name'},null, 'Name ASC','test',new List<String>{'Name'});
        CustomUtilitiesController.doSearch('Account', new List<String>{'Id','Name'},null, 'Name ASC','asd',new List<String>{'Name'});
        Test.stopTest();
    }
    
    public static testmethod void MuleSoftCalloutManager_doClone() {
        Set<String> setIds = new Set<String>();
        for(SBQQ__Quote__c q : [SELECT Id, Name FROM SBQQ__Quote__c LIMIT 10]) {
            setIds.add(q.Id);
        }
        
        Test.startTest();
        MuleSoftCalloutManager.doClone(setIds);
        MuleSoftCalloutManager.doUpdate(setIds);
        Test.stopTest();
    }
}