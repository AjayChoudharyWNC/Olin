public class SimplusWalletShareController {

    @AuraEnabled
    public static Boolean getLimitDate()
    {
        Share_of_Wallet_Settings__mdt mdt = [
            SELECT Id, Limit_Date__c 
            FROM Share_of_Wallet_Settings__mdt
            WHERE DeveloperName = 'Main_Record'
            LIMIT 1
        ];

        Boolean result;

        if(mdt != null)
        {
            Date limitDate = date.newinstance(System.today().year(), mdt.Limit_Date__c.month(), mdt.Limit_Date__c.day());
            result = System.today() <= limitDate;

            System.debug('Today: ' + System.today());
            System.debug('Limit date: ' + limitDate);
            System.debug('Editable: ' + result);

            return result;
        }
        else
        {
            System.debug('No metadata settings were found... making last year read only.');
            return false;
        }
    }
    
    @AuraEnabled
    public static String getFieldSet(String sObjectName, String fieldSetName) {
        String result = '';
        try{
            SObjectType objToken = Schema.getGlobalDescribe().get(sObjectName);
            Schema.DescribeSObjectResult d = objToken.getDescribe();
            Map<String, Schema.FieldSet> FsMap = d.fieldSets.getMap();
            system.debug('>>>>>>> FsMap >>> ' + FsMap);
            if(FsMap.containsKey(fieldSetName))
                for(Schema.FieldSetMember f : FsMap.get(fieldSetName).getFields()) {
                    if(result != ''){
                        result += ',';
                    }
                    String jsonPart = '{';
                    jsonPart += '"label":"' + f.getLabel() + '",';
                    jsonPart += '"required":"' + (f.getDBRequired() || f.getRequired()) + '",';
                    jsonPart += '"type":"' + (f.getType()) + '",';
                    jsonPart += '"name":"' + f.getFieldPath() + '"';
                    jsonPart += '}';
                    result += jsonPart;
                }
        }
        catch(Exception e){
            result += e.getLineNumber() + ' : ' + e.getMessage();
        }
        return '['+result+']';
    }

    @AuraEnabled
    public static String getRecords(String sObjectName, String parentRecordId, String fieldNameJson){
        
        List<sObject> lstResult = new List<sObject>();
        String result = '[]';
        try{
            List<String> fieldNames = (List<String>) JSON.deserialize(fieldNameJson, List<String>.class);

            for(String s : new List<String> {'Olin_Produced__c', 'Purchased_Product__c', 'Purchased_Product__r.Name','Purchased_Product__r.UOM__c'}) {
                if(!fieldNames.contains(s)) fieldNames.add(s);
            }

            Set<String> setFieldNames = new Set<String>();
            String query = 'SELECT ' + String.join(fieldNames, ',') + ' FROM ' + sObjectName;
            if(parentRecordId != NULL){
                query += ' WHERE Id' + '= \'' +  parentRecordId + '\'' ;
            }
            query += 'ORDER BY OrderPriority__c ASC, CreatedDate DESC';
            
            for(sObject s : Database.query(query)){
                lstResult.add(s);
            }
            if(lstResult.size() > 0) {
                result = JSON.serialize(lstResult);
            }
        }
        catch(Exception e){
            result += e.getLineNumber() + ' : ' + e.getMessage();
        }
        system.debug('RESULT >> ' + result);
        return result;
    }

    @AuraEnabled 
    public static Object updateRecords(Total_Consumption__c tc, String csListStr, List<String> dlList) {
        //----Try-Catch block added by Gaurish on 8th Nov 2019
        try{
            update tc;
            
            List<Consumption_Share__c> csList = (List<Consumption_Share__c>) JSON.deserialize(csListStr, List<sObject>.class);
            List<Consumption_Share__c> insertList = new List<Consumption_Share__c>(); 
            List<Consumption_Share__c> updateList = new List<Consumption_Share__c>();
            for(Consumption_Share__c cs : csList) {
                if(cs.Id == null) insertList.add(cs);
                else updateList.add(cs);
            }
            insert insertList;
            update updateList;
            List<Consumption_Share__c> deleteList = new List<Consumption_Share__c>();
            for(String s : dlList) deleteList.add(new Consumption_Share__c(Id=s));
            Database.delete(deleteList);
            
            return csList;
        }
        catch(Exception e){
            system.debug('ERROR WHILE SAVING Consumption Share records----'+e.getMessage());
            return 'ERROR:'+e.getMessage();
        }
    }

    private static final String ACCOUNT_NAME_UNKNOWN = 'UNKNOWN';
    private static final String ACCOUNT_NAME_OLIN = 'Olin Corporation';
    @AuraEnabled
    public static PurchasedProductWrapper getConsumptionShares(String recordId){
        PurchasedProductWrapper purchasedProductWrap = new PurchasedProductWrapper();
        List<TotalConsumptionWrapper> lstTotalConsumptionWrapper = new List<TotalConsumptionWrapper>();
        List<PurchasedProduct_R1__c> lstPurchasedProduct = [SELECT Id, Ship_To__c, Product_R1__c FROM PurchasedProduct_R1__c WHERE Id =: recordId];
        //01/06/2021 Jose Aguilar (Cipaq)
        //commented this line to prevent automatic Total Consumption records whenever the component loads
        initiateConsumptionForYear(new PurchasedProduct_R1__c(Id=recordId));

        List<Total_Consumption__c> lstTotalConsumption = [
            SELECT Id, Name, Year__c, Consumption__c, Ship_To__c, Product__c, LastModifiedDate,LastModifiedBy.Name,
                    Purchased_Product__c, Purchased_Product__r.Name,Purchased_Product__r.UOM__c,Purchased_Product__r.Product_R1__r.Name,
                    (SELECT Id, Name, Olin_Produced__c, Annual_Actuals_Updated__c, Seller_Account_SOW__c, Seller_Account_SOW__r.Name, Seller_Account_SOW__r.Id, Share_Amount__c, 
                     Share_Percent__c, ReadOnly__c, Contact_Expiration_Date__c 
                     FROM Share_Of_Wallets__r 
                     ORDER BY OrderPriority__c ASC, CreatedDate ASC) 
            FROM Total_Consumption__c WHERE 
            //Reverting change to now get records based on purchased products
            //Ship_To__c IN: shipToId AND 
            //Product__c IN: productId 
            Purchased_Product__c = :recordId
            ORDER BY Year__c ASC, CreatedDate ASC];

        Map<String, ConsumptionYearWrapper> mapTotalWrapper = new Map<String, ConsumptionYearWrapper>();
        Set<String> lstYear = new Set<String>();

        


        if(lstTotalConsumption != null && !lstTotalConsumption.isEmpty()) {
            for(Total_Consumption__c totalConsump: lstTotalConsumption) {
                TotalConsumptionWrapper totalConsumptionWrap = new TotalConsumptionWrapper();
                totalConsumptionWrap.totalConsumption = totalConsump;

                lstYear.add(totalConsump.Year__c);
                Integer looper = 0;
                List<ConsumptionShareWrapper> lstConsumptionShareWrapper = new List<ConsumptionShareWrapper>();

                for(Consumption_Share__c consumption : totalConsump.Share_Of_Wallets__r) {
                    ConsumptionShareWrapper consump = new ConsumptionShareWrapper(consumption);
                    lstConsumptionShareWrapper.add(consump);
                    if(consumption.Seller_Account_SOW__r.Name == ACCOUNT_NAME_UNKNOWN) {
                        totalConsumptionWrap.unknownIndex = looper;
                    } else {

                        System.debug('totalConsump >>>>> ' + totalConsump);
                        System.debug('consumption >>>>> ' + consumption);

                        if(mapTotalWrapper.get(totalConsump.Year__c) != null) {
                            mapTotalWrapper.get(totalConsump.Year__c).totalAmount += (consumption.Share_Amount__c != null ? consumption.Share_Amount__c : 0);
                            mapTotalWrapper.get(totalConsump.Year__c).totalPercent += (consumption.Share_Percent__c != null ? consumption.Share_Percent__c : 0);
                            system.debug('IF >> ' + mapTotalWrapper);
                        } else {
                            ConsumptionYearWrapper consumpTotal = new ConsumptionYearWrapper();
                            consumpTotal.consumptionYear = totalConsump.Year__c;
                            consumpTotal.totalAmount = (consumption.Share_Amount__c != null ? consumption.Share_Amount__c : 0);
                            consumpTotal.totalPercent = (consumption.Share_Percent__c != null ? consumption.Share_Percent__c : 0);
                            mapTotalWrapper.put(totalConsump.Year__c, consumpTotal);
                            system.debug('ELSE >> ' + mapTotalWrapper);
                        }
                    }
                    looper += 1;
                    
                }

                if(!mapTotalWrapper.containsKey(totalConsump.Year__c)) {
                    system.debug('mapTotalWrapper >> ' + mapTotalWrapper);
                    ConsumptionYearWrapper consumpTotal = new ConsumptionYearWrapper();
                    consumpTotal.consumptionYear = totalConsump.Year__c;
                    consumpTotal.totalAmount = 0;
                    consumpTotal.totalPercent = 0;
                    mapTotalWrapper.put(totalConsump.Year__c, consumpTotal);
                }
                /*
                mapTotalWrapper.get(totalConsump.Year__c).totalAmount += totalConsump.UnknownAmount__c != null ? totalConsump.UnknownAmount__c : 0;
                mapTotalWrapper.get(totalConsump.Year__c).totalPercent += totalConsump.UnknownPercent__c != null ? totalConsump.UnknownPercent__c : 0;
                */
                try {
                lstConsumptionShareWrapper[totalConsumptionWrap.unknownIndex].consumptionShare.Share_Amount__c = totalConsump.Consumption__c - mapTotalWrapper.get(totalConsump.Year__c).totalAmount;
                lstConsumptionShareWrapper[totalConsumptionWrap.unknownIndex].consumptionShare.Share_Percent__c = 100 - mapTotalWrapper.get(totalConsump.Year__c).totalPercent;


                } catch(Exception e) {

                }
                totalConsumptionWrap.lstConsumptionShare = lstConsumptionShareWrapper;
                lstTotalConsumptionWrapper.add(totalConsumptionWrap);
            }

            system.debug('mapTotalWrapper final >> ' + mapTotalWrapper);

            purchasedProductWrap.lstTotalConsumption = lstTotalConsumptionWrapper;
            purchasedProductWrap.lstYear = new List<String>();
            purchasedProductWrap.lstYear.addAll(lstYear);
            purchasedProductWrap.mapTotal = mapTotalWrapper;
            purchasedProductWrap.objPurchasedProduct = lstPurchasedProduct[0];
        }



        return purchasedProductWrap;
    }

    @AuraEnabled
    public static string updateGridRecord(Consumption_Share__c s){
        String retMsg = '';
        try {
            update s;
            system.debug('UPDATED >> ' + s);
        } catch(Exception e) {
            retMsg = e.getMessage();
        }
        return retMsg;
    }

    @AuraEnabled
    public static string updateGridRecords(String updatedConsumption){
        String retMsg = '';
        try {
            List<Consumption_Share__c> consumptionShare = (List<Consumption_Share__c>) JSON.deserialize(updatedConsumption, List<Consumption_Share__c>.class);
            update consumptionShare;
            system.debug('UPDATED >> ' + consumptionShare);
        } catch(Exception e) {
            retMsg = e.getMessage();
        }
        return retMsg;
    }

    @AuraEnabled
    public static void initiateConsumptionForYear(PurchasedProduct_R1__c purchasedProductObj){
        Integer currYear = Date.today().year();
        List<Account> unknownAcct = [SELECT Id FROM Account WHERE Name = :ACCOUNT_NAME_UNKNOWN LIMIT 1];
        List<Account> olinAcct = [SELECT Id FROM Account WHERE Name = :ACCOUNT_NAME_OLIN LIMIT 1];

        List<Total_Consumption__c> tcThisYear = [SELECT Id FROM Total_Consumption__c WHERE Purchased_Product__c = :purchasedProductObj.Id AND Year__c = :String.valueOf(currYear) LIMIT 1];

        List<Consumption_Share__c> csInsert = new List<Consumption_Share__c>();
        if(tcThisYear.isEmpty()) {
            Total_Consumption__c tc = new Total_Consumption__c(
                //Ship_To__c = purchasedProductObj.Ship_To__c,
                //Product__c = purchasedProductObj.Product_R1__c,
                Purchased_Product__c = purchasedProductObj.Id,
                Consumption__c = 0,
                UnknownAmount__c = 0,
                UnknownPercent__c = 0,
                Year__c = String.valueOf(currYear)
            );
            insert tc;
            
            //will this acct ever change name?

            //create cs
            Consumption_Share__c cs = new Consumption_Share__c(
                Consumption_ShareOfWallet__c = tc.Id,
                ReadOnly__c = true,
                Seller_Account_SOW__c = unknownAcct[0].Id,
                Share_Amount__c = 0,
                Share_Percent__c = 100
            );
            csInsert.add(cs);

            cs = new Consumption_Share__c(
                Consumption_ShareOfWallet__c = tc.Id,
                ReadOnly__c = false,
                Seller_Account_SOW__c = olinAcct[0].Id,
                Share_Amount__c = 0,
                Share_Percent__c = 0
            );
            csInsert.add(cs);
        }

        List<Total_Consumption__c> tcNotThisYear = [SELECT Id, (SELECT Id FROM Share_Of_Wallets__r WHERE Seller_Account_SOW__c = :unknownAcct[0].Id) 
            FROM Total_Consumption__c WHERE Purchased_Product__c = :purchasedProductObj.Id AND Year__c != :String.valueOf(currYear) AND (NOT Id IN :tcThisYear)];
        
        for(Total_Consumption__c tc : tcNotThisYear) {
            if(tc.Share_Of_Wallets__r.isEmpty()) {
                Consumption_Share__c cs = new Consumption_Share__c(
                    Consumption_ShareOfWallet__c = tc.Id,
                    ReadOnly__c = true,
                    Seller_Account_SOW__c = unknownAcct[0].Id
                );
                csInsert.add(cs);

                cs = new Consumption_Share__c(
                    Consumption_ShareOfWallet__c = tc.Id,
                    ReadOnly__c = false,
                    Seller_Account_SOW__c = olinAcct[0].Id
                );
                csInsert.add(cs);
            }
        }
        if(!csInsert.isEmpty()){
            try{
                insert csInsert;
            }
            catch (Exception e){
                System.debug('exception on insert is '+e);
            }
        }
            

    }

    public class TotalConsumptionWrapper {
        @AuraEnabled public Total_Consumption__c totalConsumption {get;set;}
        @AuraEnabled public List<ConsumptionShareWrapper> lstConsumptionShare {get;set;}
        @AuraEnabled public ConsumptionShareWrapper unknownWrapper {get;set;}
        @AuraEnabled public Integer unknownIndex;

        //@AuraEnabled public List<String> lstYear {get;set;}
        //@AuraEnabled public Map<String, ConsumptionYearWrapper> mapTotal {get;set;}
    }

    public class ConsumptionShareWrapper {
        @AuraEnabled public Consumption_Share__c consumptionShare {get;set;}

        public ConsumptionShareWrapper(Consumption_Share__c consumption) {
            this.consumptionShare = consumption;
        }
    }

    public class ConsumptionYearWrapper {
        @AuraEnabled public String consumptionYear {get;set;}
        @AuraEnabled public Decimal totalAmount {get;set;}
        @AuraEnabled public Decimal totalPercent {get;set;}
    }

    public class PurchasedProductWrapper {
        @AuraEnabled public List<TotalConsumptionWrapper> lstTotalConsumption {get;set;}
        @AuraEnabled public List<String> lstYear {get;set;}
        @AuraEnabled public Map<String, ConsumptionYearWrapper> mapTotal {get;set;}
        @AuraEnabled public PurchasedProduct_R1__c objPurchasedProduct {get;set;}
    }
}