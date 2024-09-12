public class PurchasedProductTrigger_Handler {
    //Static run variables
    private static boolean runAfter = true;
    
    //Run Singleton
    public static boolean runOnceAfter(){
        if(runAfter){
            runAfter=false;
            return true;
        }else{
            return runAfter;
        }
    }

    //Constructor
    public PurchasedProductTrigger_Handler(){
        System.debug('Trigger Helper Created');
    }
    
    public static void afterInsert(List<PurchasedProduct_R1__c> lstPurchasedProduct) {
        String currentYear = string.valueOf(system.today().year());
        List<Total_Consumption__c> totalConsumptionList = new List<Total_Consumption__c>();
        for(PurchasedProduct_R1__c purchasedProduct : lstPurchasedProduct) {
            Total_Consumption__c newTotalConsumption = new Total_Consumption__c();
            newTotalConsumption.Purchased_Product__c = purchasedProduct.Id;
            newTotalConsumption.Product__c = purchasedProduct.Product_R1__c != null ? purchasedProduct.Product_R1__c : null;
            newTotalConsumption.Ship_To__c = purchasedProduct.Ship_To__c != null ? purchasedProduct.Ship_To__c : null;
            newTotalConsumption.Year__c = currentYear;
            newTotalConsumption.UniqueId__c = purchasedProduct.Id + currentYear;
            totalConsumptionList.add(newTotalConsumption);
        }
        upsert totalConsumptionList Total_Consumption__c.UniqueId__c;
        system.debug('NEW TOTAL CONSUMPTION: ' + totalConsumptionList);

        Set<String> consumpAcctSet = new Set<String>();
        for(Consumption_Share__c tc : [SELECT Id, Consumption_ShareOfWallet__c, Seller_Account_SOW__c FROM Consumption_Share__c WHERE Consumption_ShareOfWallet__c IN :totalConsumptionList]) {
            consumpAcctSet.add(tc.Consumption_ShareOfWallet__c + '/' + tc.Seller_Account_SOW__c);
        }

        List<Consumption_Share__c> consumptionShareList = new List<Consumption_Share__c>();
        List<Consumption_Share_Account__mdt> lstCustomMetadataType = [SELECT Id, DeveloperName, MasterLabel, Value__c, IsReadOnly__c FROM Consumption_Share_Account__mdt];
        for(Total_Consumption__c totalConsumption : totalConsumptionList) {
            for(Consumption_Share_Account__mdt metadataType : lstCustomMetadataType) {
                if(!consumpAcctSet.contains(totalConsumption.Id + '/' + metadataType.Value__c)) {
                    Consumption_Share__c newConsumptionShare = new Consumption_Share__c();
                    newConsumptionShare.Consumption_ShareOfWallet__c = totalConsumption.Id;
                    newConsumptionShare.Seller_Account_SOW__c = metadataType.Value__c;
                    newConsumptionShare.ReadOnly__c = metadataType.IsReadOnly__c;
                    newConsumptionShare.Share_Amount__c = 0;
                    newConsumptionShare.Share_Percent__c = metadataType.DeveloperName == 'Unknown_Account' ? 100 : 0;
                    consumptionShareList.add(newConsumptionShare);
                }
            }
        }
        if(!consumptionShareList.isEmpty()) insert consumptionShareList;
        system.debug('NEW CONSUMPTION SHARES: ' + consumptionShareList);
    }
    
    public static void createForecastRecords(List<PurchasedProduct_R1__c> lstPurchasedProduct){
        Decimal year = Date.today().Year() + 4;
        Horizon_Year__c hz = Horizon_Year__c.getValues('Default');
        
        if (hz != null) year = hz.Year__c;
        
        List<Forecast__c> lstForecast = new List<Forecast__c>();
        for(PurchasedProduct_R1__c prod : lstPurchasedProduct){
//            for(Integer i = Date.today().Year(); i<=hz.Year__c; i++){
            for(Integer i = Date.today().Year(); i<=year; i++){
                Forecast__c f = new Forecast__c();
                f.Sold_To_Forecast__c = prod.Account_R1__c;
                f.Ship_To_Forecast__c = prod.Account_Relationship__r.Ship_To__c;
                f.Purchased_Product__c = prod.Id;
                f.Year__c = i;
                f.CurrencyIsoCode = prod.CurrencyIsoCode;
                f.Product_Forecast__c = prod.Product_R1__c;
                lstForecast.add(f);
            }            
        }
        insert lstForecast;
        update lstPurchasedProduct;
    }
}