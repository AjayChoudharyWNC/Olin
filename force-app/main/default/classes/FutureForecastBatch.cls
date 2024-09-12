global class FutureForecastBatch implements Database.Batchable <sObject> {
    
    public List<PurchasedProduct_R1__c> start(Database.BatchableContext BC){
        Integer nextYear = Date.today().Year()+1;
        return [SELECT Id,Account_R1__c,Account_Relationship__r.Ship_To__c,CurrencyIsoCode, Product_R1__c, (SELECT Id FROM Forecasts__r WHERE Year__c =: nextYear) FROM PurchasedProduct_R1__c];
    }
    
    public void execute(Database.BatchableContext BC, List<PurchasedProduct_R1__c> scope){
        List<Forecast__c> lstForecast = new List<Forecast__c>();
        for(PurchasedProduct_R1__c prod : scope){
            if(prod.Forecasts__r.size() == 0){
                Forecast__c f = new Forecast__c();
                f.Sold_To_Forecast__c = prod.Account_R1__c;
                f.Name = 'Forecast '+System.today().Year();
                f.Ship_To_Forecast__c = prod.Account_Relationship__r.Ship_To__c;
                f.Purchased_Product__c = prod.Id;
                f.Year__c = System.today().Year()+1;
                f.CurrencyIsoCode = prod.CurrencyIsoCode;
                f.Product_Forecast__c = prod.Product_R1__c;
                lstForecast.add(f);
            }
        }
        if(lstForecast.size() > 0){
            insert lstForecast;
        }
    }
    
    public void finish(Database.BatchableContext BC){
    }
    
}