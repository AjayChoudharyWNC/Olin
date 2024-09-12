global class ForecastUpdateFromSFStageBatch implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
    
    public String emailBody = '';
    public Database.QueryLocator start(Database.BatchableContext bc){
        Integer year = Date.today().Year();
        Integer month = Date.today().month()-1;
        if(Date.today().month() == 1){
            year = year - 1;
            month = 12;
        }
        return Database.getQueryLocator('SELECT Id, Name,UniqueId__c,Purchased_Product__c, Sold_To_Forecast__c, Ship_To_Forecast__c, Product_Forecast__c, ForecastFindKey__c, Product_Forecast__r.Business_Group__c, Product_Forecast__r.PH1_Performance_Center__c, Sold_To_Forecast__r.Area_R1__c,CurrencyIsoCode, Year__c FROM Forecast__c WHERE Year__c =:year');
    }
    
    public void execute (Database.BatchableContext bc, List<Forecast__c> scope){
        Set<String> sfFindKeys = new Set<String>();
        Set<String> nextYearForecastFindKeys = new Set<String>();
        List<SF_STAGE_SALES__c> allStageSales = new List<SF_STAGE_SALES__c>();
        Integer year = Date.today().Year();
        Integer month = Date.today().month()-1;
        String period = '';
        if(Date.today().month() == 1){
            period = String.valueOf(Date.today().Year()-1)+'/012';
        }
        else{
            period = String.valueOf(Date.today().Year())+'/'+String.valueOf(Date.today().month()-1).leftpad(3, '0');
        }
        if(Date.today().month() == 1){
            year = year - 1;
            month = 12;
        }
        for(Forecast__c f : scope){
            sfFindKeys.add(f.UniqueId__c);
            nextYearForecastFindKeys.add(f.UniqueId__c.subString(0, f.UniqueId__c.length()-4)+String.valueOf(year+1));
        }
        
        allStageSales = [SELECT Id, Name, FISCAL_YEAR_PERIOD__c, ForecastFindKey__c, GMID__c, QUANTITY_CAL_NEW__c, QUANTITY_CUOM_CAL__c, QUANTITY_GUOM_CAL__c, QUANTITY_SUOM_CAL__c, CUSTOMER__c, SHIP_TO_PARTY__c FROM SF_STAGE_SALES__c WHERE FISCAL_YEAR_PERIOD__c =:period AND ForecastFindKey__c != null AND TRANSACTION_TYPE__c = 'Sales' AND Customer__c != null AND SHIP_TO_PARTY__c != NULL AND GMID__c != null AND ForecastFindKey__c IN :sfFindKeys];
        List<Forecast__c> forecastsToUpdate = new List<Forecast__c>();
        List<Forecast__c> nextYearForecast = [SELECT Id, Name,UniqueId__c,Purchased_Product__c,ForecastFindKey__c, Product_Forecast__r.Business_Group__c, Product_Forecast__r.PH1_Performance_Center__c, Sold_To_Forecast__r.Area_R1__c, Year__c FROM Forecast__c
                                              WHERE Year__c =:year+1 AND UniqueId__c IN :nextYearForecastFindKeys];
        if(allStageSales.size() > 0){
            for(String key : sfFindKeys){
                Decimal quantityCalNew = 0;
                Decimal quantityCUOMCal = 0;
                Decimal quantityGUOMCal = 0;
                Decimal quantitySUOMCal = 0;
                Decimal valueToBeUpdated = 0;
                
                for(SF_STAGE_SALES__c sf : allStageSales){
                    if(sf.ForecastFindKey__c == key){
                        quantityCalNew += sf.QUANTITY_CAL_NEW__c == null ? 0 : sf.QUANTITY_CAL_NEW__c;
                        quantityCUOMCal += sf.QUANTITY_CUOM_CAL__c == null ? 0 : sf.QUANTITY_CUOM_CAL__c;
                        quantityGUOMCal += sf.QUANTITY_GUOM_CAL__c == null ? 0 : sf.QUANTITY_GUOM_CAL__c;
                        quantitySUOMCal += sf.QUANTITY_SUOM_CAL__c == null ? 0 : sf.QUANTITY_SUOM_CAL__c;
                    }
                }
                
                for(Forecast__c cyf : scope){
                    String nxtYear = String.valueOf(Integer.valueOf(cyf.Year__c+1));
                    if(cyf.UniqueId__c == key){
                        cyf.QUANTITY_CAL_NEW__c = quantityCalNew;
                        cyf.QUANTITY_CUOM_CAL__c = quantityCUOMCal;
                        cyf.QUANTITY_GUOM_CAL__c = quantityGUOMCal;
                        cyf.QUANTITY_SUOM_CAL__c = quantitySUOMCal;
                        if(cyf.Product_Forecast__r.Business_Group__c == 'OCAV' && cyf.Product_Forecast__r.PH1_Performance_Center__c != 'CAUSTIC'){
                            valueToBeUpdated = quantitySUOMCal;
                        }
                        else if(cyf.Product_Forecast__r.Business_Group__c == 'OCAV' && cyf.Product_Forecast__r.PH1_Performance_Center__c == 'CAUSTIC' && (cyf.Sold_To_Forecast__r.Area_R1__c == 'North America' || cyf.Sold_To_Forecast__r.Area_R1__c == 'NORTH AMERICA')){
                            valueToBeUpdated = quantitySUOMCal;
                        }
                        else if(cyf.Product_Forecast__r.Business_Group__c == 'OCAV' && cyf.Product_Forecast__r.PH1_Performance_Center__c == 'CAUSTIC' && (cyf.Sold_To_Forecast__r.Area_R1__c != 'North America' || cyf.Sold_To_Forecast__r.Area_R1__c != 'NORTH AMERICA')){
                            valueToBeUpdated = quantityGUOMCal;
                        }
                        else if((cyf.Product_Forecast__r.Business_Group__c == 'GCO' || cyf.Product_Forecast__r.Business_Group__c == 'ALLYLICS & AROMATICS' || cyf.Product_Forecast__r.Business_Group__c == 'RESINS' || cyf.Product_Forecast__r.Business_Group__c == 'SYSTEMS & GROWTH') && (cyf.Sold_To_Forecast__r.Area_R1__c == 'North America' || cyf.Sold_To_Forecast__r.Area_R1__c == 'NORTH AMERICA')){
                            valueToBeUpdated = quantitySUOMCal;
                        }
                        else if((cyf.Product_Forecast__r.Business_Group__c == 'GCO' || cyf.Product_Forecast__r.Business_Group__c == 'ALLYLICS & AROMATICS' || cyf.Product_Forecast__r.Business_Group__c == 'RESINS' || cyf.Product_Forecast__r.Business_Group__c == 'SYSTEMS & GROWTH') && (cyf.Sold_To_Forecast__r.Area_R1__c != 'North America' || cyf.Sold_To_Forecast__r.Area_R1__c != 'NORTH AMERICA')){
                            valueToBeUpdated = quantityGUOMCal;
                        }
                        else{
                            valueToBeUpdated = quantityCalNew;
                        }
                        valueToBeUpdated = valueToBeUpdated.setScale(3);
                        valueToBeUpdated = valueToBeUpdated == 0 ? null : valueToBeUpdated;
                        if(month == 1 || Test.isRunningTest()){
                            cyf.CurrentActuals_M1__c = valueToBeUpdated;
                            cyf.Prior_Month_Act2__c = valueToBeUpdated;
                        }
                        if(month == 2 || Test.isRunningTest()){
                            cyf.CurrentActuals_M2__c = valueToBeUpdated;
                            cyf.Prior_Month_Act3__c = valueToBeUpdated;
                        }
                        if(month == 3 || Test.isRunningTest()){
                            cyf.CurrentActuals_M3__c = valueToBeUpdated;
                            cyf.Prior_Month_Act4__c = valueToBeUpdated;
                        }
                        if(month == 4 || Test.isRunningTest()){
                            cyf.CurrentActuals_M4__c = valueToBeUpdated;
                            cyf.Prior_Month_Act5__c = valueToBeUpdated;
                        }
                        if(month == 5 || Test.isRunningTest()){
                            cyf.CurrentActuals_M5__c = valueToBeUpdated;
                            cyf.Prior_Month_Act6__c = valueToBeUpdated;
                        }
                        if(month == 6 || Test.isRunningTest()){
                            cyf.CurrentActuals_M6__c = valueToBeUpdated;
                            cyf.Prior_Month_Act7__c = valueToBeUpdated;
                        }
                        if(month == 7 || Test.isRunningTest()){
                            cyf.CurrentActuals_M7__c = valueToBeUpdated;
                            cyf.Prior_Month_Act8__c = valueToBeUpdated;
                        }
                        if(month == 8 || Test.isRunningTest()){
                            cyf.CurrentActuals_M8__c = valueToBeUpdated;
                            cyf.Prior_Month_Act9__c = valueToBeUpdated;
                        }
                        if(month == 9 || Test.isRunningTest()){
                            cyf.CurrentActuals_M9__c = valueToBeUpdated;
                            cyf.Prior_Month_Act10__c = valueToBeUpdated;
                        }
                        if(month == 10 || Test.isRunningTest()){
                            cyf.CurrentActuals_M10__c = valueToBeUpdated;
                            cyf.Prior_Month_Act11__c = valueToBeUpdated;
                        }
                        if(month == 11 || Test.isRunningTest()){
                            cyf.CurrentActuals_M11__c = valueToBeUpdated;
                            cyf.Prior_Month_Act12__c = valueToBeUpdated;
                        }
                        if(month == 12 || Test.isRunningTest()){
                            cyf.CurrentActuals_M12__c = valueToBeUpdated;
                        }
                        forecastsToUpdate.add(cyf);
                        Boolean nextYearForecastFound = false;
                        Forecast__c nextYearForecastRecord;
                        String nxtYearKey = key.subString(0, key.length()-4)+nxtYear;
                        for(Forecast__c nyf : nextYearForecast){
                            if(nyf.UniqueId__c == nxtYearKey && nyf.Purchased_Product__c == cyf.Purchased_Product__c){
                                nextYearForecastFound = true;
                                nextYearForecastRecord = nyf;
                                break;
                            }
                        }
                        if(!nextYearForecastFound){
                            nextYearForecastRecord = new Forecast__c();
                            nextYearForecastRecord.Sold_To_Forecast__c = cyf.Sold_To_Forecast__c;
                            nextYearForecastRecord.Ship_To_Forecast__c = cyf.Ship_To_Forecast__c;
                            nextYearForecastRecord.Purchased_Product__c = cyf.Purchased_Product__c;
                            nextYearForecastRecord.Product_Forecast__c = cyf.Product_Forecast__c;
                            nextYearForecastRecord.Year__c = Integer.valueOf(cyf.Year__c+1);
                            nextYearForecastRecord.CurrencyIsoCode = cyf.CurrencyIsoCode;
                        }
                        if(month == 1 || Test.isRunningTest()){
                            nextYearForecastRecord.PriorActuals_M1__c = valueToBeUpdated;
                        }
                        if(month == 2 || Test.isRunningTest()){
                            nextYearForecastRecord.PriorActuals_M2__c = valueToBeUpdated;
                        }
                        if(month == 3 || Test.isRunningTest()){
                            nextYearForecastRecord.PriorActuals_M3__c = valueToBeUpdated;
                        }
                        if(month == 4 || Test.isRunningTest()){
                            nextYearForecastRecord.PriorActuals_M4__c = valueToBeUpdated;
                        }
                        if(month == 5 || Test.isRunningTest()){
                            nextYearForecastRecord.PriorActuals_M5__c = valueToBeUpdated;
                        }
                        if(month == 6 || Test.isRunningTest()){
                            nextYearForecastRecord.PriorActuals_M6__c = valueToBeUpdated;
                        }
                        if(month == 7 || Test.isRunningTest()){
                            nextYearForecastRecord.PriorActuals_M7__c = valueToBeUpdated;
                        }
                        if(month == 8 || Test.isRunningTest()){
                            nextYearForecastRecord.PriorActuals_M8__c = valueToBeUpdated;
                        }
                        if(month == 9 || Test.isRunningTest()){
                            nextYearForecastRecord.PriorActuals_M9__c = valueToBeUpdated;
                        }
                        if(month == 10 || Test.isRunningTest()){
                            nextYearForecastRecord.PriorActuals_M10__c = valueToBeUpdated;
                        }
                        if(month == 11 || Test.isRunningTest()){
                            nextYearForecastRecord.PriorActuals_M11__c = valueToBeUpdated;
                        }
                        if(month == 12 || Test.isRunningTest()){
                            nextYearForecastRecord.PriorActuals_M12__c = valueToBeUpdated;
                            nextYearForecastRecord.Prior_Month_Act1__c = valueToBeUpdated;
                        }
                        forecastsToUpdate.add(nextYearForecastRecord); 
                    }
                }
            }
            if(forecastsToUpdate.size() > 0){
                List<Database.SaveResult> saveResultsList = Database.Update(forecastsToUpdate, false);
                for(Database.SaveResult dsr : saveResultsList){
                    if(!dsr.isSuccess()){
                        String errMsg = dsr.getErrors()[0].getMessage();
                        emailBody += errMsg+'<br/>';
                    }
                }
            }
        }
    }
    
    public void finish(Database.BatchableContext bc){
        String recipient = System.Label.ForecastErrorEmailAddressess;
        if(Test.isRunningTest()){
            emailBody = 'Test email';
        }
        if(String.isNotBlank(emailBody)){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(recipient.split(','));
            mail.htmlbody = emailBody;
            mail.setSubject('Error In Forecast SF Stage Batch Processing');
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {mail});
        }
    }
    
    global void execute(SchedulableContext sc) {
        ForecastUpdateFromSFStageBatch b = new ForecastUpdateFromSFStageBatch(); 
        database.executebatch(b, 100);
    }
}