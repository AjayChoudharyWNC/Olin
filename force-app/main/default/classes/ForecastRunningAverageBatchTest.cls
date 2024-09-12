@isTest
public class ForecastRunningAverageBatchTest {
    
    @testSetup
    public static void setupData() {
        Product2 p = new Product2(
            SBQQ__SubscriptionTerm__c = 12,
            Fusion_Harmonized_Matl__c = '42275',
            TradeProduct_R1__c = '123456',
            LegacyBCCode_R1__c = '42275',
            ProductCode = '42275',
            TradeProdCode_R1__c = '42275',
            EXTERNALDATASOURCEID_R1__c = 'BCSAP',
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
            UnitOfMeasure_R1__c = 'DST',
            Base_UOM__c = 'DST',
            UOM__c = 'SDT',
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
            Name='TestAcct', 
            NumberOfEmployees=100,
            Sap_Id__c = '9000001',
            Ship_to__c = true,
            AccountNumber_R1__c = '9000001',
            AccountSource = 'Olin Heritage'
        );
        insert a;
        
        Forecast__c newForecast = new Forecast__c(Sold_to_Forecast__c = a.Id, Ship_To_Forecast__c = a.Id, Product_Forecast__c = p.Id);
        newForecast.Year__c = Date.today().year();
        newForecast.UniqueId__c = '9000001'
                                + '9000001'
                                + '42275' 
                                + String.valueOf(newForecast.Year__c);
                                
        newForecast.ChangeTracker__c = ForecastingGridController.DEFAULT_CHANGE_TRACKER;

        for(Integer i = 0; i < 12; i+=1) {
            Integer mon = i + 1;
            String monStr = (mon < 10 ? '0' : '') + mon;
            newForecast.put('Management_M' + mon + '__c', 100);
            newForecast.put('Acct_Rep_M' + mon + '__c', 100);
            newForecast.put('PriorActuals_M' + mon + '__c', 100);
        }
        
        Integer month = Date.today().month() - 1;
        Integer year = Date.today().year();
        if(month == 0) {
            month = 12;
            year -=1;
        }
        
        SF_STAGE_SALES__c stg = new SF_STAGE_SALES__c(
            SHIP_TO_PARTY__c = '9000001',
            SOLD_TO_PARTY__c = '9000001',
            GMID__c = '42275',
            VOLUME_ACTUAL_UL__c = 100,
            YEAR_MONTH__c = (month < 10 ? '0' + month : '' + month) + '/' + year 
        );
        
        insert newForecast;
        insert stg;
    }
    
    public testmethod static void testBatch() {
        Database.executeBatch(new ForecastRunningAverageBatch());
        
        Test.startTest();
        ForecastRunningAverageSched sh1 = new ForecastRunningAverageSched();
        String sch = '0 0 0 1/1 * ? *'; 
        system.schedule('Test ForecastingBatch', sch, sh1);
        Test.stopTest();
    }


}