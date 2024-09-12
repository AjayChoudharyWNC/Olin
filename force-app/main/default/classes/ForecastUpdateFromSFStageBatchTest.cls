@isTest
public class ForecastUpdateFromSFStageBatchTest {
    
    static testMethod void test1(){
        Product2 p = new Product2(
            //SBQQ__SubscriptionTerm__c = 12,
            Fusion_Harmonized_Matl__c = '42275',
            TradeProduct_R1__c = '123456',
            LegacyBCCode_R1__c = '42275',
            ProductCode = '42275',
            TradeProdCode_R1__c = '42275',
            EXTERNALDATASOURCEID_R1__c = 'S4',
            Family = 'CAPV',
            Business_Group__c = 'OCAV',
            LineOfBusiness_R1__c = 'CAPV',
            MaterialGroup_R1__c = 'CAUSTIC',
            PerfCenterCode_R1__c = 'CAUSTIC SALES',
            PH1_Performance_Center__c = 'Bleach',
            PerformanceCenter_R1__c = 'CAUSTIC SALES',
            ProdCenter_R1__c = 'CAUSTIC SALES',
            ProdCenterCode_R1__c = 'CAUSTIC SALES',
            ValueCenter_R1__c = 'CAUSTIC SALES',
            ValueCenterCode_R1__c = 'CAUSTIC SALES',
            Description = 'CAUSTIC SODA 25% IND GR',
            Name = 'CAUSTIC SODA 25% IND GR',
            PlanProdCode_R1__c = 'CAUSTIC SODA 50PCT SOLN',
            PlanProduct_R1__c = 'CAUSTIC SODA 50PCT SOLN',
            //SBQQ__OptionSelectionMethod__c = 'Click',
            UnitOfMeasure_R1__c = 'MDT',
            Base_UOM__c = 'DST',
            UOM__c = 'CWT',
            /*SBQQ__ConfigurationEvent__c = 'Edit',
            SBQQ__SubscriptionPricing__c = 'Fixed Price',
            SBQQ__PricingMethod__c = 'List',
            SBQQ__SubscriptionBase__c = 'List',
            SBQQ__SubscriptionType__c = 'Renewable',
            SBQQ__ConfigurationType__c = 'Required',
            SBQQ__OptionLayout__c = 'Sections',*/
            Product_Level__c = 'GMID',
            /*SBQQ__PriceEditable__c = true,
            SBQQ__QuantityEditable__c = true*/
             IsActive = true
        );
        insert p;
        
        Product2 p1 = new Product2(
            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
            Product_Level__c = 'GMID',
            //SBQQ__SubscriptionTerm__c = 12,
            Fusion_Harmonized_Matl__c = '42276',
            TradeProduct_R1__c = '123456',
            LegacyBCCode_R1__c = '42276',
            ProductCode = '42276',
            TradeProdCode_R1__c = '42276',
            EXTERNALDATASOURCEID_R1__c = 'S4',
            Family = 'CAPV',
            Business_Group__c = 'OCAV',
            PH1_Performance_Center__c = 'CAUSTIC',
            PerformanceCenter_R1__c = 'CAUSTIC SALES',
            Name = 'CAUSTIC SODA 25% IND GR',
             IsActive = true
        );
        insert p1;
        
        Product2 p3 = new Product2(
            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
            Product_Level__c = 'GMID',
            //SBQQ__SubscriptionTerm__c = 12,
            Fusion_Harmonized_Matl__c = '42271',
            TradeProduct_R1__c = '123456',
            LegacyBCCode_R1__c = '42271',
            ProductCode = '42271',
            TradeProdCode_R1__c = '42271',
            EXTERNALDATASOURCEID_R1__c = 'S4',
            Family = 'CAPV',
            Business_Group__c = 'OCAV',
            PH1_Performance_Center__c = 'CAUSTIC',
            PerformanceCenter_R1__c = 'CAUSTIC SALES',
            Name = 'CAUSTIC SODA 25% IND GR',
             IsActive = true

        );
        insert p3;
        
        Product2 p2 = new Product2(
            //SBQQ__SubscriptionTerm__c = 12,
            Fusion_Harmonized_Matl__c = '42277',
            TradeProduct_R1__c = '123456',
            LegacyBCCode_R1__c = '42277',
            ProductCode = '42277',
            Business_Group__c = 'GCO',
            TradeProdCode_R1__c = '42277',
            EXTERNALDATASOURCEID_R1__c = 'S4',
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
            //SBQQ__OptionSelectionMethod__c = 'Click',
            UnitOfMeasure_R1__c = 'MDT',
            Base_UOM__c = 'DST',
            UOM__c = 'CWT',
            /*SBQQ__ConfigurationEvent__c = 'Edit',
            SBQQ__SubscriptionPricing__c = 'Fixed Price',
            SBQQ__PricingMethod__c = 'List',
            SBQQ__SubscriptionBase__c = 'List',
            SBQQ__SubscriptionType__c = 'Renewable',
            SBQQ__ConfigurationType__c = 'Required',
            SBQQ__OptionLayout__c = 'Sections',*/
            Product_Level__c = 'GMID',
             IsActive = true
            /*SBQQ__PriceEditable__c = true,
            SBQQ__QuantityEditable__c = true*/
        );
        insert p2;
        Horizon_Year__c hz = new Horizon_Year__c();
        hz.Name = 'Default';
        hz.Year__c = 2025;
        insert hz;
        Account acc = new Account(
            Name='TestAcct', 
            NumberOfEmployees=100,
            Sap_Id__c = '9000001',
            Ship_to__c = true,
            Sold_To__C = true,
            AccountNumber_R1__c = '9000001',
            AccountSource = 'Olin Heritage',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId()
        );
        insert acc;
        
        Account acc1 = new Account(
            Name='TestAcct', 
            NumberOfEmployees=100,
            Sap_Id__c = '9000002',
            Ship_to__c = true,
            Sold_To__C = true,
           AccountNumber_R1__c = '9000002',
            AccountSource = 'Olin Heritage',
            Area_R1__c = 'North America',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId()
        );
        insert acc1;
 
          // Create Account Relationship
         Account_Relationships__c testAccountRel = new Account_Relationships__c(
            Name = 'Test Account Relationship',
            Relationship_Type__c = 'Sold To / Ship To',
            Sold_To__c = acc1.Id,
            Ship_To__c = acc1.Id
        );

        insert testAccountRel;

         // Create Account Relationship
         Account_Relationships__c testAccountRel2 = new Account_Relationships__c(
            Name = 'Test Account Relationship',
            Relationship_Type__c = 'Sold To / Ship To',
            Sold_To__c = acc1.Id,
            Ship_To__c = acc.Id
        );

        insert testAccountRel2;
 

 
        
        PurchasedProduct_R1__c testPurchasedProduct = new PurchasedProduct_R1__c(
            Account_Relationship__c = testAccountRel.Id,
            Account_R1__c = acc1.Id,
            Product_R1__c = p1.Id,
            Ship_To__c = acc1.Id
        );
        insert testPurchasedProduct;
 
         PurchasedProduct_R1__c testPurchasedProduct2 = new PurchasedProduct_R1__c(
            Account_R1__c = acc1.Id,
            Product_R1__c = p2.Id,
            Ship_To__c = acc1.Id
        );
        //insert testPurchasedProduct2;
        
         PurchasedProduct_R1__c testPurchasedProduct3 = new PurchasedProduct_R1__c(
             Account_Relationship__c = testAccountRel2.Id,
            Account_R1__c = acc1.Id,
            Product_R1__c = p.Id,
            Ship_To__c = acc.Id
        );
        //insert testPurchasedProduct3;


 
        String period = '';
        if(Date.today().month() == 1){
            period = String.valueOf(Date.today().Year()-1)+'/012';
        }
        else{
            period = String.valueOf(Date.today().Year())+'/'+String.valueOf(Date.today().month()-1).leftpad(3, '0');
        }
        Integer year = Date.today().Year();
        Integer month = Date.today().month()-1;
        if(Date.today().month() == 1){
            year = year - 1;
            month = 12;
        }
        List<Forecast__c> fList = new List<Forecast__c>();
        Forecast__c f1 = new Forecast__c(Sold_to_Forecast__c = acc.Id, Ship_To_Forecast__c = acc1.Id, Product_Forecast__c = p1.Id, Purchased_Product__c = testPurchasedProduct.Id);
        f1.Year__c = year;
        f1.UniqueId__c = '9000001900000242276'+String.valueOf(year);
        fList.add(f1);
        insert fList;
        System.debug('fList======'+fList);        
        List<SF_STAGE_SALES__c> actualsList = new List<SF_STAGE_SALES__c>();
        for(Forecast__c a : [SELECT Id, Sold_to_forecast__r.Sap_Id__c, Ship_to_forecast__r.Sap_Id__c, Product_Forecast__r.Fusion_Harmonized_Matl__c FROM Forecast__c]) {
            for(Integer i = 1; i < 13; i+=1) {
                String ymonth = (i < 10 ? '0' + i : i + '') + '/' +  (Date.today().year() - 1);
                actualsList.add(
                    new SF_STAGE_SALES__c(
                        CUSTOMER__c = a.Sold_to_forecast__r.Sap_Id__c,
                        SHIP_TO_PARTY__c = a.Ship_to_forecast__r.Sap_Id__c,
                        SOLD_TO_PARTY__c = a.Sold_to_forecast__r.Sap_Id__c,
                        GMID__c = a.Product_Forecast__r.Fusion_Harmonized_Matl__c,
                        VOLUME_ACTUAL_UL__c = Integer.valueOf(Math.random() * 1000),
                        FISCAL_MONTH_YEAR__c = ymonth,
                        FISCAL_YEAR_PERIOD__c = period,
                        TRANSACTION_TYPE__c = 'Sales'
                    )
                );
            }
        }
        insert actualsList;
        
        Test.startTest();
        Database.executeBatch(new ForecastUpdateFromSFStageBatch());
        Test.stopTest();
        
    }
    
}