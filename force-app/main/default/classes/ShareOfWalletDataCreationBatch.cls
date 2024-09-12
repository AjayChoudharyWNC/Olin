public class ShareOfWalletDataCreationBatch implements Database.batchable<sObject>, Database.Stateful{
    private static final String ACCOUNT_NAME_UNKNOWN = 'UNKNOWN';
    private static final String ACCOUNT_NAME_OLIN = 'Olin Corporation';
    public List<String> yearsToProcess;
    public Set<String> prodIdsToTest;
    public List<Account> unknownAcct = [SELECT Id FROM Account WHERE Name = :ACCOUNT_NAME_UNKNOWN LIMIT 1];
    public List<Account> olinAcct = [SELECT Id FROM Account WHERE Name = :ACCOUNT_NAME_OLIN LIMIT 1];
    public ShareOfWalletDataCreationBatch(List<String> years, Set<String> prodIds){
        yearsToProcess = years;
        prodIdsToTest = prodIds;
    }
    public Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT Id, CreatedDate FROM PurchasedProduct_R1__c';
        if(prodIdsToTest != null){
            query +=' WHERE Id IN:prodIdsToTest';
        }
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<PurchasedProduct_R1__c> scope){
        Set<Id> purchasedProdIds = new Set<Id>();
        for(PurchasedProduct_R1__c prod : scope){
            purchasedProdIds.add(prod.Id);
        }
        Map<String, List<Total_Consumption__c>> consumptionMap = new Map<String, List<Total_Consumption__c>>();
        for(Total_Consumption__c cm : [SELECT Id, Name, Year__c, Consumption__c, Ship_To__c, Product__c, LastModifiedDate,LastModifiedBy.Name,
                                       Purchased_Product__c, Purchased_Product__r.Name,Purchased_Product__r.UOM__c,Purchased_Product__r.Product_R1__r.Name,
                                       (SELECT Id, Name, Olin_Produced__c, Annual_Actuals_Updated__c, Seller_Account_SOW__c, Seller_Account_SOW__r.Name, Seller_Account_SOW__r.Id, Share_Amount__c, 
                                        Share_Percent__c, ReadOnly__c, Contact_Expiration_Date__c FROM Share_Of_Wallets__r) FROM Total_Consumption__c WHERE 
                                       Purchased_Product__c IN :purchasedProdIds AND Year__c IN :yearsToProcess])
        {
            if(!consumptionMap.containsKey(cm.Purchased_Product__c+'--'+cm.Year__c)){
                consumptionMap.put(cm.Purchased_Product__c+'--'+cm.Year__c, new List<Total_Consumption__c>());
            }
            consumptionMap.get(cm.Purchased_Product__c+'--'+cm.Year__c).add(cm);
        }
        System.debug('consumptionMap=='+consumptionMap);
        List<Total_Consumption__c> toInsertTotalConsumption = new List<Total_Consumption__c>();
        List<Consumption_Share__c> toInsertConsumptionShare = new List<Consumption_Share__c>();
        for(String year : yearsToProcess){
            for(PurchasedProduct_R1__c product : scope){
                if(product.CreatedDate.year() <= Integer.valueOf(year)){
                    String prodId = product.Id;
                    String key = prodId+'--'+year;
                    String pastYearKey = prodId+'--'+String.valueOf((Integer.valueOf(year)-1));
                    ConsumptionWrapper wrapper;
                    if(!consumptionMap.containsKey(key)){
                        if(consumptionMap.containsKey(pastYearKey) && consumptionMap.get(pastYearKey).size() > 0){
                            wrapper = getConsumption(prodId, consumptionMap.get(pastYearKey)[0], year);
                        }
                        else{
                            wrapper = getConsumption(prodId, null, year);
                        }
                    }
                    else if(consumptionMap.get(key).size() == 0){
                        wrapper = getConsumption(prodId, null, year);
                    }
                    if(wrapper != null){
                        if(wrapper.consumption != null){
                            toInsertTotalConsumption.add(wrapper.consumption);
                        }
                        if(wrapper.consumptionShareList != null && wrapper.consumptionShareList.size() > 0){
                            toInsertConsumptionShare.addAll(wrapper.consumptionShareList);
                        }
                    }
                }
            }
        }
        List<sObject> allRecordsToInsert = new List<sObject>();
        allRecordsToInsert.addAll(toInsertTotalConsumption);
        allRecordsToInsert.addAll(toInsertConsumptionShare);
        if(allRecordsToInsert.size() > 0){
            Database.insert(allRecordsToInsert);
        }
    }
    
    public ConsumptionWrapper getConsumption(Id prodId, Total_Consumption__c tc, String year){
        System.debug('year=='+year);
        ConsumptionWrapper wrapper = new ConsumptionWrapper();
        if(tc == NULL){
            wrapper = initiateConsumptionForYear(prodId, year);
            system.debug('wrapper from new=='+wrapper);                                     
        }
        else{
            List<Consumption_Share__c> clonedConsumptionShares = new List<Consumption_Share__c>();
            Total_Consumption__c clonedTc = tc.clone();
            clonedTc.UniqueId__c = prodId+year;
            clonedTc.Year__c = year;
            for(Consumption_Share__c cs : tc.Share_Of_Wallets__r){
                Consumption_Share__c clonedCS = new Consumption_Share__c(
                    Consumption_ShareOfWallet__r = new Total_Consumption__c(UniqueId__c = prodId+year),
                    ReadOnly__c = cs.ReadOnly__c,
                    Seller_Account_SOW__c = cs.Seller_Account_SOW__c,
                    Share_Amount__c = cs.Share_Amount__c,
                    Share_Percent__c = cs.Share_Percent__c
                );
                clonedConsumptionShares.add(clonedCS);
            }
            wrapper.consumption = clonedTc;
            wrapper.consumptionShareList = clonedConsumptionShares;
            system.debug('wrapper from clone=='+wrapper); 
        }
        return wrapper;
    }
    
    public ConsumptionWrapper initiateConsumptionForYear(Id prodId, String year){
        ConsumptionWrapper wrapper = new ConsumptionWrapper();
        List<Consumption_Share__c> csInsert = new List<Consumption_Share__c>();
        Total_Consumption__c tc = new Total_Consumption__c(
            Purchased_Product__c = prodId,
            Consumption__c = 0,
            UnknownAmount__c = 0,
            UnknownPercent__c = 0,
            Year__c = year,
            UniqueId__c = prodId+year
        );
        system.debug('unknownAcct=='+unknownAcct);
        Consumption_Share__c cs = new Consumption_Share__c(
            Consumption_ShareOfWallet__r = new Total_Consumption__c(UniqueId__c = prodId+year),
            ReadOnly__c = true,
            Seller_Account_SOW__c = unknownAcct[0].Id,
            Share_Amount__c = 0,
            Share_Percent__c = 100
        );
        csInsert.add(cs);
        
        cs = new Consumption_Share__c(
            Consumption_ShareOfWallet__r = new Total_Consumption__c(UniqueId__c = prodId+year),
            ReadOnly__c = false,
            Seller_Account_SOW__c = olinAcct[0].Id,
            Share_Amount__c = 0,
            Share_Percent__c = 0
        );
        csInsert.add(cs);
        wrapper.consumption = tc;
        wrapper.consumptionShareList = csInsert;
        return wrapper;
    }
    
    
    
    
    public void finish(Database.BatchableContext bc){
        
    }
    
    public class ConsumptionWrapper{
        public Total_Consumption__c consumption;
        public List<Consumption_Share__c> consumptionShareList;
    }
    
}