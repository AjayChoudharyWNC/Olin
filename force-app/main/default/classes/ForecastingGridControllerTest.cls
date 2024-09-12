@isTest
public class ForecastingGridControllerTest {

    @testSetup
    public static void createData() {
         Horizon_Year__c hz = new Horizon_Year__c();
        hz.Name = 'Default';
        hz.Year__c = 2025;
        insert hz;
        Product2 p = new Product2(
            SBQQ__SubscriptionTerm__c = 12,
            Fusion_Harmonized_Matl__c = '42275',
            TradeProduct_R1__c = '123456',
            LegacyBCCode_R1__c = '42275',
            ProductCode = '42275',
            TradeProdCode_R1__c = '42275',
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
            SBQQ__OptionSelectionMethod__c = 'Click',
            UnitOfMeasure_R1__c = 'MDT',
            Base_UOM__c = 'DST',
            UOM__c = 'CWT',
            IsActive = true,
            SBQQ__ConfigurationEvent__c = 'Edit',
            SBQQ__SubscriptionPricing__c = 'Fixed Price',
            SBQQ__PricingMethod__c = 'List',
            SBQQ__SubscriptionBase__c = 'List',
            SBQQ__SubscriptionType__c = 'Renewable',
            SBQQ__ConfigurationType__c = 'Required',
            SBQQ__OptionLayout__c = 'Sections',
            SBQQ__PriceEditable__c = true,
            SBQQ__QuantityEditable__c = true,
            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
            Product_Level__c = 'GMID'
        );
        insert p;
    
        Account a = new Account(
            Name='TestAcct', 
            NumberOfEmployees=100,
            Sap_Id__c = '9000001',
            Ship_to__c = true,
            Sold_to__c = true,
            AccountNumber_R1__c = '9000001',
            AccountSource = 'S4',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId()
        );
        insert a;
        
        // Create Account Relationship
         Account_Relationships__c testAccountRel = new Account_Relationships__c(
            Name = 'Test Account Relationship',
            Relationship_Type__c = 'Sold To / Ship To',
            Sold_To__c = a.Id,
            Ship_To__c = a.Id
        );

        insert testAccountRel;
        
        PurchasedProduct_R1__c testPurchasedProduct = new PurchasedProduct_R1__c(
            Account_Relationship__c = testAccountRel.Id,
            Ship_To__c = a.Id,
            Account_R1__c = a.Id,
            Product_R1__c = p.Id
        );     
        insert testPurchasedProduct;
        
        
        Forecast__c newForecast = new Forecast__c(Sold_to_Forecast__c = a.Id, Ship_To_Forecast__c = a.Id, Product_Forecast__c = p.Id,Purchased_Product__c = testPurchasedProduct.Id);
        newForecast.Year__c = 2020; //Date.today().year();
        newForecast.UniqueId__c = '9000001'
                                + '9000001'
                                + '42275' 
                                + String.valueOf(newForecast.Year__c);
                                
        //newForecast.ChangeTracker__c = ForecastingGridController.DEFAULT_CHANGE_TRACKER;
        for(Integer i = 0; i < 12; i+=1) {
            Integer mon = i + 1;
            String monStr = (mon < 10 ? '0' : '') + mon;

            //if(priorVal.containsKey(newForecast.UniqueId__c + '/' + monStr)) {
            newForecast.put('Management_M' + mon + '__c', 100);
            newForecast.put('Acct_Rep_M' + mon + '__c', 100);
            newForecast.put('PriorActuals_M' + mon + '__c', 100);
            //} 
        }
        insert newForecast; 
        
    }
    public testmethod static void getPriorActuals() {
    
        List<SF_STAGE_SALES__c> actualsList = new List<SF_STAGE_SALES__c>();
        for(Forecast__c a : [SELECT Id, Sold_to_forecast__r.Sap_Id__c, Ship_to_forecast__r.Sap_Id__c, Product_Forecast__r.Fusion_Harmonized_Matl__c FROM Forecast__c]) {
            for(Integer i = 1; i < 13; i+=1) {
                String ymonth = (i < 10 ? '0' + i : i + '') + '/' +  (Date.today().year() - 1);
                actualsList.add(
                    new SF_STAGE_SALES__c(
                        SOLD_TO_PARTY__c = a.Sold_to_forecast__r.Sap_Id__c,
                        SHIP_TO_PARTY__c = a.Ship_to_forecast__r.Sap_Id__c,
                        GMID__c = a.Product_Forecast__r.Fusion_Harmonized_Matl__c,
                        VOLUME_ACTUAL_UL__c = Integer.valueOf(Math.random() * 1000),
                        FISCAL_MONTH_YEAR__c = ymonth
                    )
                );
            }
        }
        insert actualsList;
        ForecastingGridController.getPriorActualsData('9000001'
                                + '9000001'
                                + '42275', null, null);
    }
    public testmethod static void runInitialGet() {
        ForecastingGridController.FieldSetConfig fsc1 = new ForecastingGridController.FieldSetConfig();
        fsc1.name = 'GridForecasting_Controls';
        fsc1.type = 'filter';
        ForecastingGridController.FieldSetConfig fsc2 = new ForecastingGridController.FieldSetConfig();
        fsc2.name = 'GridForecasting';
        fsc2.type = 'display';
        
        Id BusinessAccRecTypeId = [SELECT id,Name,SObjectType FROM RecordType where SObjectType = 'Account' and Name = 'Corporate'].id;
        Account acc = new Account(Name = 'FastChem Cooperation', RecordTypeId = BusinessAccRecTypeId);
        insert acc;
        
        AccountName__c acctName = new AccountName__c();
        acctName.Name = 'FastChem Corp';
        acctName.OlinAccountValue__c = acc.id;
        insert acctName;
        
        ForecastingGridController.getUserRole();
        ForecastingGridController.fetchUser();
        ForecastingGridController.saveUserDetail(4,'');
        Test.startTest();
        ForecastingGridController.getFieldSet('Forecast__c',new List<ForecastingGridController.FieldSetConfig>{fsc1, fsc2}, null);
        
        Map<Id, Forecast__c> currForecasts = new Map<Id, Forecast__c>([SELECT Id FROM Forecast__c]);
        
        List<String> ids = new List<String>();
        for(Id i : currForecasts.keyset()) ids.add(i);
        
        ForecastingGridController.createForecastRecords(ids, '["Id"]', null, null, 1);
        List<ForecastingGridController.ForecastWrapper> forecastList = ForecastingGridController.toggle(null,1,Date.today().year()).lstObject;
        System.debug('forecastList=='+forecastList);
        ForecastingExtractController extractPage = new ForecastingExtractController();
        Test.stopTest();
    }
    
    public testmethod static void runSort() {
        ForecastingGridController.FieldSetConfig fsc1 = new ForecastingGridController.FieldSetConfig();
        fsc1.name = 'GridForecasting_Controls';
        fsc1.type = 'filter';
        ForecastingGridController.FieldSetConfig fsc2 = new ForecastingGridController.FieldSetConfig();
        fsc2.name = 'GridForecasting';
        fsc2.type = 'display';
        
        Test.startTest();
        ForecastingGridController.getFieldSet('Forecast__c',new List<ForecastingGridController.FieldSetConfig>{fsc1, fsc2}, null);
        
        ForecastingGridController.FieldSetWrapperGroup swg = ForecastingGridController.sortColumns(
            '{"isActive": true, "sortColumn": "Sold_To_Forecast__c", "sortColumnName": "Sold To", "sortOrder": "DESC", "sortUser" : "' + Userinfo.getUserId() + '"}',
            '[]',
            null
        );
        SimplusGrid_Sorting__c sortItem = new SimplusGrid_Sorting__c();
        sortItem.Active__c = true;
        sortItem.Column_Name__c = 'Sold To';
        sortItem.Column__c = 'Sold_To_Forecast__c';
        sortItem.Priority__c = 1;
        sortItem.Order__c = 'DESC';
        insert sortItem;
        ForecastingGridController.toggleSortFilterItemNew('sort', new List<sObject>{sortItem}, null, null);
        ForecastingGridController.toggleSortFilterItem('sort',swg.sortingWrapper[0].id, true, 1, null);
        
        ForecastingGridController.toggle(null, 1, null);
        ForecastingGridController.querySort(null);
        ForecastingGridController.deleteAllSortFilterItem('sort', JSON.serialize(swg.sortingWrapper));
        
        Test.stopTest();
    }
    public testmethod static void runSort2() {
        ForecastingGridController.FieldSetConfig fsc1 = new ForecastingGridController.FieldSetConfig();
        fsc1.name = 'GridForecasting_Controls';
        fsc1.type = 'filter';
        ForecastingGridController.FieldSetConfig fsc2 = new ForecastingGridController.FieldSetConfig();
        fsc2.name = 'GridForecasting';
        fsc2.type = 'display';
        
        Test.startTest();
        ForecastingGridController.getFieldSet('Forecast__c',new List<ForecastingGridController.FieldSetConfig>{fsc1, fsc2}, null);
        
        ForecastingGridController.FieldSetWrapperGroup swg = ForecastingGridController.sortColumns(
            '{"isActive": true, "sortColumn": "Sold_To_Forecast__c", "sortColumnName": "Sold To", "sortOrder": "DESC", "sortUser" : "' + Userinfo.getUserId() + '"}',
            '[]',
            null
        );
        
        ForecastingGridController.dragAndDrop('sort', JSON.serialize(swg.sortingWrapper));
        ForecastingGridController.toggleSortFilterItem('sort',swg.sortingWrapper[0].id, true, 1, null);
        ForecastingGridController.deleteSortFilterItem('sort', swg.sortingWrapper[0].id, 1, null);
        
        ForecastingGridController.toggle(null, 1, null);
        ForecastingGridController.querySort(null);
        
        Test.stopTest();
    }

    public testmethod static void runFilter() {
        ForecastingGridController.FieldSetConfig fsc1 = new ForecastingGridController.FieldSetConfig();
        fsc1.name = 'GridForecasting_Controls';
        fsc1.type = 'filter';
        ForecastingGridController.FieldSetConfig fsc2 = new ForecastingGridController.FieldSetConfig();
        fsc2.name = 'GridForecasting';
        fsc2.type = 'display';
        
        Test.startTest();
        ForecastingGridController.getFieldSet('Forecast__c',new List<ForecastingGridController.FieldSetConfig>{fsc1, fsc2}, null);
        
        ForecastingGridController.FieldSetWrapperGroup fwg = ForecastingGridController.filterColumns(
            '{"isGlobal" : false, "filterColumnType" : "REFERENCE", "filterOperation " : "contains", "isActive": true, "filterValue" : "a", "filterColumn": "Sold_To_Forecast__c", "filterColumnName": "Sold To", "filterPriority": "1", "filterUser" : "' + Userinfo.getUserId() + '"}',
            '[]',
            null
        );
        
        ForecastingGridController.dragAndDrop('filter', JSON.serialize(fwg.filteringWrapper));
        
        ForecastingGridController.toggleSortFilterItem('filter',fwg.filteringWrapper[0].id, true, 1, null);
        ForecastingGridController.deleteSortFilterItem('filter', fwg.filteringWrapper[0].id, 1,null);
        
        ForecastingGridController.toggle(null,1,null);
        ForecastingGridController.queryFilter(null);
        Test.stopTest();
    }
    public testmethod static void runFilter2() {
        ForecastingGridController.FieldSetConfig fsc1 = new ForecastingGridController.FieldSetConfig();
        fsc1.name = 'GridForecasting_Controls';
        fsc1.type = 'filter';
        ForecastingGridController.FieldSetConfig fsc2 = new ForecastingGridController.FieldSetConfig();
        fsc2.name = 'GridForecasting';
        fsc2.type = 'display';
        
        Test.startTest();
        ForecastingGridController.getFieldSet('Forecast__c',new List<ForecastingGridController.FieldSetConfig>{fsc1, fsc2}, null);
        
        ForecastingGridController.FieldSetWrapperGroup fwg = ForecastingGridController.filterColumns(
            '{"isGlobal" : false, "filterColumnType" : "REFERENCE", "filterOperation " : "contains", "isActive": true, "filterValue" : "a", "filterColumn": "Sold_To_Forecast__c", "filterColumnName": "Sold To", "filterPriority": "1", "filterUser" : "' + Userinfo.getUserId() + '"}',
            '[]',
            null
        );
        
        ForecastingGridController.toggleSortFilterItem('filter',fwg.filteringWrapper[0].id, true, 1, null);
        
        ForecastingGridController.toggle(null,1,null);
        ForecastingGridController.queryFilter(null);
        ForecastingGridController.deleteAllSortFilterItem('filter', JSON.serialize(fwg.filteringWrapper));
        Test.stopTest();
    }
    
    public testmethod static void testSave(){
        String saveJson = '{"monthSet":2,"yearStart":2020,"monthStart":1,"saveList":{"9000001900000142275":[{"mgr":2,"rep":2,"priorMonth":0,"aveMonth":0,"fieldNameRep":"Acct_Rep_M2__c","fieldNameMgr":"Management_M2__c","repIsChanged":1,"mgrIsChanged":1,"identifier":"80005224800052241058452020/2","chMatrix":"111111111111111111111111","year":2020},{"mgr":2,"rep":2,"priorMonth":5,"aveMonth":6,"fieldNameRep":"Acct_Rep_M3__c","fieldNameMgr":"Management_M3__c","repIsChanged":1,"mgrIsChanged":1,"identifier":"80005224800052241058452020/3","chMatrix":"111111111111111111111111","year":2020}],"11000270511000270513000000040":[{"mgr":0,"rep":0,"priorMonth":0,"aveMonth":0,"fieldNameRep":"Acct_Rep_M2__c","fieldNameMgr":"Management_M2__c","repIsChanged":1,"mgrIsChanged":0,"identifier":"110002705110002705130000000402020/2","chMatrix":"010000000000000000000000","year":2020},{"mgr":0,"rep":0,"priorMonth":0,"aveMonth":0,"fieldNameRep":"Acct_Rep_M3__c","fieldNameMgr":"Management_M3__c","repIsChanged":0,"mgrIsChanged":0,"identifier":"110002705110002705130000000402020/3","chMatrix":"010000000000000000000000","year":2020}],"1100027051100027051000001515":[{"mgr":0,"rep":1,"priorMonth":0,"aveMonth":0,"fieldNameRep":"Acct_Rep_M2__c","fieldNameMgr":"Management_M2__c","repIsChanged":1,"mgrIsChanged":0,"identifier":"11000270511000270510000015152020/2","chMatrix":"010000000000000000000000","year":2020},{"mgr":0,"rep":0,"priorMonth":0,"aveMonth":0,"fieldNameRep":"Acct_Rep_M3__c","fieldNameMgr":"Management_M3__c","repIsChanged":0,"mgrIsChanged":0,"identifier":"11000270511000270510000015152020/3","chMatrix":"010000000000000000000000","year":2020}],"1100027051100027051000001472":[{"mgr":0,"rep":0,"priorMonth":0,"aveMonth":0,"fieldNameRep":"Acct_Rep_M2__c","fieldNameMgr":"Management_M2__c","repIsChanged":0,"mgrIsChanged":0,"identifier":"11000270511000270510000014722020/2","chMatrix":"000000000000000000000000","year":2020},{"mgr":0,"rep":0,"priorMonth":0,"aveMonth":0,"fieldNameRep":"Acct_Rep_M3__c","fieldNameMgr":"Management_M3__c","repIsChanged":0,"mgrIsChanged":0,"identifier":"11000270511000270510000014722020/3","chMatrix":"000000000000000000000000","year":2020}],"1100021491100021491000001917":[{"mgr":0,"rep":0,"priorMonth":0,"aveMonth":0,"fieldNameRep":"Acct_Rep_M2__c","fieldNameMgr":"Management_M2__c","repIsChanged":0,"mgrIsChanged":0,"identifier":"11000214911000214910000019172020/2","chMatrix":"000000000000000000000000","year":2020},{"mgr":0,"rep":0,"priorMonth":0,"aveMonth":0,"fieldNameRep":"Acct_Rep_M3__c","fieldNameMgr":"Management_M3__c","repIsChanged":0,"mgrIsChanged":0,"identifier":"11000214911000214910000019172020/3","chMatrix":"000000000000000000000000","year":2020}],"1100027051100027051000001937":[{"mgr":0,"rep":0,"priorMonth":0,"aveMonth":0,"fieldNameRep":"Acct_Rep_M2__c","fieldNameMgr":"Management_M2__c","repIsChanged":0,"mgrIsChanged":0,"identifier":"11000270511000270510000019372020/2","chMatrix":"000000000000000000000000","year":2020},{"mgr":0,"rep":0,"priorMonth":0,"aveMonth":0,"fieldNameRep":"Acct_Rep_M3__c","fieldNameMgr":"Management_M3__c","repIsChanged":0,"mgrIsChanged":0,"identifier":"11000270511000270510000019372020/3","chMatrix":"000000000000000000000000","year":2020}],"1100027051100027051000001062":[{"mgr":0,"rep":0,"priorMonth":0,"aveMonth":0,"fieldNameRep":"Acct_Rep_M2__c","fieldNameMgr":"Management_M2__c","repIsChanged":0,"mgrIsChanged":0,"identifier":"11000270511000270510000010622020/2","chMatrix":"000000000000000000000000","year":2020},{"mgr":0,"rep":0,"priorMonth":0,"aveMonth":0,"fieldNameRep":"Acct_Rep_M3__c","fieldNameMgr":"Management_M3__c","repIsChanged":0,"mgrIsChanged":0,"identifier":"11000270511000270510000010622020/3","chMatrix":"000000000000000000000000","year":2020}],"1100027051100027051000001083":[{"mgr":0,"rep":0,"priorMonth":0,"aveMonth":0,"fieldNameRep":"Acct_Rep_M2__c","fieldNameMgr":"Management_M2__c","repIsChanged":0,"mgrIsChanged":0,"identifier":"11000270511000270510000010832020/2","chMatrix":"000000000000000000000000","year":2020},{"mgr":0,"rep":0,"priorMonth":0,"aveMonth":0,"fieldNameRep":"Acct_Rep_M3__c","fieldNameMgr":"Management_M3__c","repIsChanged":0,"mgrIsChanged":0,"identifier":"11000270511000270510000010832020/3","chMatrix":"000000000000000000000000","year":2020}],"1100027051100027051000000132":[{"mgr":0,"rep":0,"priorMonth":0,"aveMonth":0,"fieldNameRep":"Acct_Rep_M2__c","fieldNameMgr":"Management_M2__c","repIsChanged":0,"mgrIsChanged":0,"identifier":"11000270511000270510000001322020/2","chMatrix":"000000000000000000000000","year":2020},{"mgr":0,"rep":0,"priorMonth":0,"aveMonth":0,"fieldNameRep":"Acct_Rep_M3__c","fieldNameMgr":"Management_M3__c","repIsChanged":0,"mgrIsChanged":0,"identifier":"11000270511000270510000001322020/3","chMatrix":"000000000000000000000000","year":2020}],"100324771003247728152":[{"mgr":0,"rep":0,"priorMonth":0,"aveMonth":0,"fieldNameRep":"Acct_Rep_M2__c","fieldNameMgr":"Management_M2__c","repIsChanged":0,"mgrIsChanged":0,"identifier":"1003247710032477281522020/2","chMatrix":"000000000000000000000000","year":2020},{"mgr":0,"rep":0,"priorMonth":0,"aveMonth":0,"fieldNameRep":"Acct_Rep_M3__c","fieldNameMgr":"Management_M3__c","repIsChanged":0,"mgrIsChanged":0,"identifier":"1003247710032477281522020/3","chMatrix":"000000000000000000000000","year":2020}]},"forecastsPerYear":{"8000522480005224105845":{"2020":{"year":2020,"repMonthly":[2,2,2,2,2,2,2,2,2,2,2,2],"priorMonthly":[6,0,5,5,6,6,0,5,5,0,5,0],"mgrMonthly":[3,2,2,2,2,2,2,2,2,2,2,3],"changeMatrix":"111111111111111111111111","aveMonthly":[6,0,6,6,6,6,0,5,5,0,5,0]}},"11000270511000270513000000040":{"2020":{"year":2020,"repMonthly":[0,0,0,0,0,0,0,0,0,0,0,0],"priorMonthly":[0,0,0,0,0,0,0,0,0,0,0,0],"mgrMonthly":[0,0,0,0,0,0,0,0,0,0,0,0],"changeMatrix":"010000000000000000000000","aveMonthly":[0,0,0,0,0,0,0,0,0,0,0,0]}},"1100027051100027051000001515":{"2020":{"year":2020,"repMonthly":[0,1,0,0,0,0,0,0,0,0,0,0],"priorMonthly":[0,0,0,0,0,0,0,0,0,0,0,0],"mgrMonthly":[0,0,0,0,0,0,0,0,0,0,0,0],"changeMatrix":"010000000000000000000000","aveMonthly":[0,0,0,0,0,0,0,0,0,0,0,0]}},"1100027051100027051000001472":{"2020":{"year":2020,"repMonthly":[0,0,0,0,0,0,0,0,0,0,0,0],"priorMonthly":[0,0,0,0,0,0,0,0,0,0,0,0],"mgrMonthly":[0,0,0,0,0,0,0,0,0,0,0,0],"changeMatrix":"000000000000000000000000","aveMonthly":[0,0,0,0,0,0,0,0,0,0,0,0]}},"1100021491100021491000001917":{"2020":{"year":2020,"repMonthly":[0,0,0,0,0,0,0,0,0,0,0,0],"priorMonthly":[0,0,0,0,0,0,0,0,0,0,0,0],"mgrMonthly":[0,0,0,0,0,0,0,0,0,0,0,0],"changeMatrix":"000000000000000000000000","aveMonthly":[0,0,0,0,0,0,0,0,0,0,0,0]}},"1100027051100027051000001937":{"2020":{"year":2020,"repMonthly":[0,0,0,0,0,0,0,0,0,0,0,0],"priorMonthly":[0,0,0,0,0,0,0,0,0,0,0,0],"mgrMonthly":[0,0,0,0,0,0,0,0,0,0,0,0],"changeMatrix":"000000000000000000000000","aveMonthly":[0,0,0,0,0,0,0,0,0,0,0,0]}},"1100027051100027051000001062":{"2020":{"year":2020,"repMonthly":[0,0,0,0,0,0,0,0,0,0,0,0],"priorMonthly":[0,0,0,0,0,0,0,0,0,0,0,0],"mgrMonthly":[0,0,0,0,0,0,0,0,0,0,0,0],"changeMatrix":"000000000000000000000000","aveMonthly":[0,0,0,0,0,0,0,0,0,0,0,0]}},"1100027051100027051000001083":{"2020":{"year":2020,"repMonthly":[0,0,0,0,0,0,0,0,0,0,0,0],"priorMonthly":[0,0,0,0,0,0,0,0,0,0,0,0],"mgrMonthly":[0,0,0,0,0,0,0,0,0,0,0,0],"changeMatrix":"000000000000000000000000","aveMonthly":[0,0,0,0,0,0,0,0,0,0,0,0]}},"1100027051100027051000000132":{"2020":{"year":2020,"repMonthly":[0,0,0,0,0,0,0,0,0,0,0,0],"priorMonthly":[0,0,0,0,0,0,0,0,0,0,0,0],"mgrMonthly":[0,0,0,0,0,0,0,0,0,0,0,0],"changeMatrix":"000000000000000000000000","aveMonthly":[0,0,0,0,0,0,0,0,0,0,0,0]}},"100324771003247728152":{"2020":{"year":2020,"repMonthly":[0,0,0,0,0,0,0,0,0,0,0,0],"priorMonthly":[0,0,0,0,0,0,0,0,0,0,0,0],"mgrMonthly":[0,0,0,0,0,0,0,0,0,0,0,0],"changeMatrix":"000000000000000000000000","aveMonthly":[0,0,0,0,0,0,0,0,0,0,0,0]}}}}';
        ForecastingGridController.saveLine('90000019000001422752020/2/rep', 2);
        ForecastingGridController.saveRecords(saveJSON);
    }
}