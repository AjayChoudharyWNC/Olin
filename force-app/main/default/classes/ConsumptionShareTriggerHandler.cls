public class ConsumptionShareTriggerHandler {
    //Static run variables
	private static boolean runBefore = true;
	private static boolean runAfter = true;

    //Run Singleton
	public static boolean runOnceBefore(){
		if(runBefore){
			runBefore=false;
			return true;
		}else{
			return runBefore;
		}
	}

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
	public ConsumptionShareTriggerHandler(){
		System.debug('Trigger Helper Created');
	}

    public static void afterUpdate(List<Consumption_Share__c> lstConsumptionShare, Map<Id, Consumption_Share__c> oldMap) {
        Map<Id, Consumption_Share__c> mapTotalConsumptionToConsumptionShare = new Map<Id, Consumption_Share__c>([SELECT Id, Consumption_ShareOfWallet__c, Consumption_ShareOfWallet__r.Purchased_Product__c, Consumption_ShareOfWallet__r.Year__c
                                                                                                                 FROM Consumption_Share__c
                                                                                                                 WHERE Id IN: lstConsumptionShare]);
        Integer currentYear;
        Set<String> purchasedProductIds = new Set<String>();
        for(Consumption_Share__c consumptionShare : lstConsumptionShare) {
            if(oldMap.get(consumptionShare.Id).Share_Amount__c != consumptionShare.Share_Amount__c || oldMap.get(consumptionShare.Id).Share_Percent__c != consumptionShare.Share_Percent__c) {
                purchasedProductIds.add(mapTotalConsumptionToConsumptionShare.get(consumptionShare.Id).Consumption_ShareOfWallet__r.Purchased_Product__c);
                if(currentYear == null) {
                    currentYear = integer.valueOf(mapTotalConsumptionToConsumptionShare.get(consumptionShare.Id).Consumption_ShareOfWallet__r.Year__c);
                } else if(currentYear < integer.valueOf(mapTotalConsumptionToConsumptionShare.get(consumptionShare.Id).Consumption_ShareOfWallet__r.Year__c)) {
                    currentYear = integer.valueOf(mapTotalConsumptionToConsumptionShare.get(consumptionShare.Id).Consumption_ShareOfWallet__r.Year__c);
                }
            }
        }

        List<Total_Consumption__c> totalConsumptionList = [SELECT Id, Purchased_Product__c, Year__c, Consumption__c, Product__c, Ship_To__c, (SELECT Id, Seller_Account_SOW__c, Share_Amount__c, Share_Percent__c FROM Share_Of_Wallets__r)
                                                           FROM Total_Consumption__c
                                                           WHERE Purchased_Product__c IN: purchasedProductIds AND Year__c >=: string.valueOf(currentYear)];
        system.debug('TOTAL CONSUMPTION >> ' + totalConsumptionList);
        Map<String, Map<String, Total_Consumption__c>> mapPurchasedProductToTotalConsumption = new Map<String, Map<String, Total_Consumption__c>>();
        for(Total_Consumption__c totalConsumption : totalConsumptionList) {
            if(mapPurchasedProductToTotalConsumption.get(totalConsumption.Purchased_Product__c) != null && !mapPurchasedProductToTotalConsumption.get(totalConsumption.Purchased_Product__c).keySet().isEmpty()) {
                mapPurchasedProductToTotalConsumption.get(totalConsumption.Purchased_Product__c).put(totalConsumption.Year__c, totalConsumption);
            } else {
                Map<String, Total_Consumption__c> mapYearToTotalConsumption = new Map<String, Total_Consumption__c>();
                mapYearToTotalConsumption.put(totalConsumption.Year__c, totalConsumption);
                mapPurchasedProductToTotalConsumption.put(totalConsumption.Purchased_Product__c, mapYearToTotalConsumption);
            }
        }
        
        List<Consumption_Share__c> updatedConsumptionShareList = new List<Consumption_Share__c>();
        for(Consumption_Share__c consumptionShare : lstConsumptionShare) {
            if(oldMap.get(consumptionShare.Id).Share_Amount__c != consumptionShare.Share_Amount__c || oldMap.get(consumptionShare.Id).Share_Percent__c != consumptionShare.Share_Percent__c) {
                Integer nextYear = integer.valueOf(mapTotalConsumptionToConsumptionShare.get(consumptionShare.Id).Consumption_ShareOfWallet__r.Year__c) + 1;
                system.debug('NEXT YEAR >> ' + nextYear);
                system.debug('MAP >> ' + mapPurchasedProductToTotalConsumption);
                if(mapPurchasedProductToTotalConsumption.get(mapTotalConsumptionToConsumptionShare.get(consumptionShare.Id).Consumption_ShareOfWallet__r.Purchased_Product__c).keySet().contains(string.valueOf(nextYear))) {
                    for(Consumption_Share__c conShare : mapPurchasedProductToTotalConsumption.get(mapTotalConsumptionToConsumptionShare.get(consumptionShare.Id).Consumption_ShareOfWallet__r.Purchased_Product__c).get(string.valueOf(nextYear)).Share_Of_Wallets__r) {
                        if(consumptionShare.Seller_Account_SOW__c == conShare.Seller_Account_SOW__c) {
                            conShare.Share_Amount__c = consumptionShare.Share_Amount__c;
                            conShare.Share_Percent__c = consumptionShare.Share_Percent__c;
                            updatedConsumptionShareList.add(conShare);
                        }
                    }
                }
            }
        }

        if(updatedConsumptionShareList != null && !updatedConsumptionShareList.isEmpty()) {
            update updatedConsumptionShareList;
            system.debug('UPDATED CONSUMPTION SHARE >> ' + updatedConsumptionShareList);
        }

    }
}