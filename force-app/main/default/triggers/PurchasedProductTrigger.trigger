trigger PurchasedProductTrigger on PurchasedProduct_R1__c (after insert, after update) {
    //---Purchase Product Update Process Builder logic-----START
    List<PurchasedProduct_R1__c> prList = [SELECT Id,Account_R1__c,CurrencyIsoCode,Product_R1__c,Ship_To__c,Account_Relationship__c,Account_Relationship__r.Ship_To__c FROM PurchasedProduct_R1__c 
                                           WHERE Id IN: Trigger.newMap.keySet()];
    if(prList != null && prList.size() > 0){
        for(PurchasedProduct_R1__c pr: prList){
            if(pr.Account_Relationship__c != null && pr.Account_Relationship__r.Ship_To__c != null &&
               (Trigger.isInsert || (Trigger.oldMap.get(pr.Id).Account_Relationship__c != pr.Account_Relationship__c && Trigger.isUpdate))){
                   pr.Ship_To__c = pr.Account_Relationship__r.Ship_To__c;
               }
        }
        if(Trigger.isUpdate && PurchasedProductTrigger_Handler.runOnceAfter()){
            update prList;
        }
    }
    //---Purchase Product Update Process Builder logic-----END----Gaurish 20Aug2021
    
    if(Trigger.isInsert) {
        if (PurchasedProductTrigger_Handler.runOnceAfter() || Test.isRunningTest()){
            if(prList.size() > 0){
                update prList;
                PurchasedProductTrigger_Handler.afterInsert(prList);
                PurchasedProductTrigger_Handler.createForecastRecords(prList);
            }
        }
    }
}