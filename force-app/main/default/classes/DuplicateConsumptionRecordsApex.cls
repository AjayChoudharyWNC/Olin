public class DuplicateConsumptionRecordsApex
{
    public static void duplicateConsumption(List<Total_Consumption__c> lstTotalConsumption, String sourceYear, String destinationYear)
    {
        Integer nextYear = integer.valueOf(destinationYear);
        Map<String, Total_Consumption__c> originalAndCloneTotalConsumptions = new Map<String, Total_Consumption__c>();
        List<Consumption_Share__c> consumptionShareList = new List<Consumption_Share__c>();

        //Map for storing the source total consumptions using a Year-PurchasedProduct key to retrieve them
        Map<String, Total_Consumption__c> sourceTotalConsumptionMap = new Map<String, Total_Consumption__c>();
        //Map for getting all the Total Consumption records that already exist for the destination year
        Map<String, Total_Consumption__c> existingTotalConsumptions = new Map<String, Total_Consumption__c>();
        //Map for getting all the Consumption Share records that already exist for the already existing Total Consumption records
        Map<String, Consumption_Share__c> existingConsumptionShareByTotalConsumption = new Map<String, Consumption_Share__c>();

        System.debug('duplicateConsumption::Creating map for the source Total Consumption records...');
        for(Total_Consumption__c totalConsumptionRec : lstTotalConsumption)
        {
            String key = totalConsumptionRec.Year__c + '-' + totalConsumptionRec.Purchased_Product__c;

            if(!sourceTotalConsumptionMap.containsKey(key))
                sourceTotalConsumptionMap.put(key, totalConsumptionRec);
        }
        System.debug('duplicateConsumption::Map for the source Total Consumption records created: ' + sourceTotalConsumptionMap);

        System.debug('duplicateConsumption::Creating map for the already existing Total Consumption records...');
        for(Total_Consumption__c tc :  [SELECT Id, Product__c, Ship_To__c, Year__c, Consumption__c, Purchased_Product__c, (SELECT Id, Consumption_ShareOfWallet__c, Seller_Account_SOW__c, Share_Amount__c, Share_Percent__c, Contact_Expiration_Date__c FROM Share_Of_Wallets__r) FROM Total_Consumption__c WHERE Year__c = :destinationYear])
        {
            String key = tc.Year__c + '-' + tc.Purchased_Product__c;

            if(!existingTotalConsumptions.containsKey(key))
                existingTotalConsumptions.put(key, tc);
            
            for(Consumption_Share__c cs : tc.Share_Of_Wallets__r)
            {
                String csKey = key + '-' + cs.Seller_Account_SOW__c;

                if(!existingConsumptionShareByTotalConsumption.containsKey(csKey))
                    existingConsumptionShareByTotalConsumption.put(csKey, cs);
            }            
        }
        System.debug('duplicateConsumption::Map for the already existing Total Consumption records created: ' + existingTotalConsumptions);
        System.debug('duplicateConsumption::Map for the already existing Consumption Share records created: ' + existingConsumptionShareByTotalConsumption);

        System.debug('duplicateConsumption::Starting logic for checking if new records need to be created...');
        for(Total_Consumption__c totalConsumptionRec : lstTotalConsumption)
        {
            String key = destinationYear + '-' + totalConsumptionRec.Purchased_Product__c;
            System.debug('duplicateConsumption::source key: ' + key);

            if(!existingTotalConsumptions.containsKey(key))
            {
                System.debug('duplicateConsumption::source key: <' + key + '> does not exist, creating a new Total Consumption record...');
                Total_Consumption__c dupTotalConsumption = new Total_Consumption__c();
                dupTotalConsumption = totalConsumptionRec.clone();
                dupTotalConsumption.Year__c = string.valueOf(nextYear);
                originalAndCloneTotalConsumptions.put(totalConsumptionRec.Id, dupTotalConsumption);
                System.debug('duplicateConsumption::Duplicated Total Consumption for key: <' + key + '> is: ' + dupTotalConsumption);
            }
            else
            {
                System.debug('duplicateConsumption::source key: <' + key + '> already exists, skipping creation...');
            }
        }
        System.debug('duplicateConsumption::Total consumptions to be used: ' + originalAndCloneTotalConsumptions);
        insert originalAndCloneTotalConsumptions.values();

        System.debug('duplicateConsumption::Checking if the Consumption shares exist or not...');
        for(String key : sourceTotalConsumptionMap.keySet())
        {
            Total_Consumption__c totalConsumptionRec = sourceTotalConsumptionMap.get(key);

            String tcKey = destinationYear + '-' + totalConsumptionRec.Purchased_Product__c;
            
            for(Consumption_Share__c consumptionShares : totalConsumptionRec.Share_Of_Wallets__r)
            {
                String csKey = tcKey + '-' + consumptionShares.Seller_Account_SOW__c;

                if(existingTotalConsumptions.containsKey(tcKey))
                {
                    System.debug('duplicateConsumption::source Total consumption with key: <' + key + '> already exists, checking if consumption shares exist...');
                    if(!existingConsumptionShareByTotalConsumption.containsKey(csKey))
                    {
                        System.debug('duplicateConsumption::Consumption Share with key: <' + csKey + '> does not exist, creating it...');
                        Consumption_Share__c dupConsumptionShare = new Consumption_Share__c();
                        dupConsumptionShare = consumptionShares.clone();
                        dupConsumptionShare.Consumption_ShareOfWallet__c = existingTotalConsumptions.get(tcKey).Id;
                        consumptionShareList.add(dupConsumptionShare);
                    }
                    else
                    {
                        System.debug('duplicateConsumption::Consumption Share with key: <' + csKey + '> already exists, skipping it...');
                    }
                }
                else
                {
                    System.debug('duplicateConsumption::Creating a new Consumption Share with key <' + csKey + '> for a new Total consumption with key: <' + key + '>');
                    Consumption_Share__c dupConsumptionShare = new Consumption_Share__c();
                    dupConsumptionShare = consumptionShares.clone();
                    dupConsumptionShare.Consumption_ShareOfWallet__c = originalAndCloneTotalConsumptions.get(totalConsumptionRec.Id).Id;
                    consumptionShareList.add(dupConsumptionShare);
                }
            }
        }
        System.debug('duplicateConsumption::Consumption shares to be inserted: ' + consumptionShareList);
        insert consumptionShareList;
    }
}