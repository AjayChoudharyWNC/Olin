public class ForecastTrigger_Handler {
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
    public ForecastTrigger_Handler(){
        System.debug('Trigger Helper Created');
    }
/* Modified Jimmy Daresta to change to forecast to master detail */
/*    public static void processSharing(List<Forecast__c> lstForecast, Map<Id, Forecast__c> oldMap, Boolean isInsert) {
        Map<String, List<Forecast__c>> mapPurchasedProductToForecast = new Map<String, List<Forecast__c>>();
        Map<String, String> mapForecastIdToForecastOwnerIds = new Map<String, String>();
        
        Set<String> purchasedProductIds = new Set<String>();
        Set<String> forecastIds = new Set<String>();
        
        for(Forecast__c forecast : lstForecast) {
            if(isInsert || (!IsInsert && (oldMap.get(forecast.Id).Purchased_Product__c != forecast.Purchased_Product__c || oldMap.get(forecast.Id).Ship_To_Forecast__c != forecast.Ship_To_Forecast__c || oldMap.get(forecast.Id).Sold_To_Forecast__c != forecast.Sold_To_Forecast__c))) {
                purchasedProductIds.add(forecast.Purchased_Product__c);
                
                if(mapPurchasedProductToForecast.get(forecast.Purchased_Product__c) != null && !mapPurchasedProductToForecast.get(forecast.Purchased_Product__c).isEmpty()) {
                    mapPurchasedProductToForecast.get(forecast.Purchased_Product__c).add(forecast);
                } 
                else {
                    mapPurchasedProductToForecast.put(forecast.Purchased_Product__c, new List<Forecast__c>{forecast});
                }
                forecastIds.add(forecast.Id);
                mapForecastIdToForecastOwnerIds.put(forecast.Id, forecast.OwnerId);
            }
        }
        
        List<PurchasedProduct_R1__c> lstPurchasedProduct = [SELECT Id, Account_R1__c, Ship_To__c FROM PurchasedProduct_R1__c WHERE Id IN: purchasedProductIds];
        
        Map<String, Set<String>> mapShipToIdToPurchasedProductIds = new Map<String, Set<String>>();
        Map<String, Set<String>> mapSoldToIdToShipToIds = new Map<String, Set<String>>();
        
        Set<String> soldToIds = new Set<String>();
        Set<String> shipToIds = new Set<String>();
        
        for(PurchasedProduct_R1__c purchasedProduct : lstPurchasedProduct) {
            if(purchasedProduct.Ship_To__c != null) {
                shipToIds.add(purchasedProduct.Ship_To__c);
            }
            if(mapShipToIdToPurchasedProductIds.get(purchasedProduct.Ship_To__c) != null && !mapShipToIdToPurchasedProductIds.get(purchasedProduct.Ship_To__c).isEmpty()) {
                mapShipToIdToPurchasedProductIds.get(purchasedProduct.Ship_To__c).add(purchasedProduct.Id);
            } 
            else {
                mapShipToIdToPurchasedProductIds.put(purchasedProduct.Ship_To__c, new Set<String>{purchasedProduct.Id});
            }
        }
        
        List<Account_Relationships__c> lstAccountRelationship = [SELECT Id, Ship_To__c, Ship_To__r.OwnerId, Sold_To__c, Sold_To__r.RecordType.Name FROM Account_Relationships__c WHERE Ship_To__c IN: shipToIds 
                                                                 AND Relationship_Type__c = 'Sold To / Ship To'];
        for(Account_Relationships__c acctRelationship : lstAccountRelationship) {
            if(mapSoldToIdToShipToIds.get(acctRelationship.Sold_To__c) != null && !mapSoldToIdToShipToIds.get(acctRelationship.Sold_To__c).isEmpty()) {
                mapSoldToIdToShipToIds.get(acctRelationship.Sold_To__c).add(acctRelationship.Ship_To__c);
            } 
            else {
                mapSoldToIdToShipToIds.put(acctRelationship.Sold_To__c, new Set<String>{acctRelationship.Ship_To__c});
            }
            if(acctRelationship.Sold_To__r.RecordType.Name != 'Parent') {
                soldToIds.add(acctRelationship.Sold_To__c);
            }
        }
        system.debug('Sold to ID: ' + soldToIds);
        if(soldToIds != null && !soldToIds.isEmpty()) {
            List<AccountTeamMember> lstAccountTeamMember = [SELECT Id, AccountId, UserId, User.Name, TeamMemberRole, AccountAccessLevel, OpportunityAccessLevel 
                                                            FROM AccountTeamMember WHERE AccountId IN: soldToIds AND User.isActive = true];       
            List<Forecast__Share> existingTeamMember = [SELECT Id, ParentId, UserOrGroupId FROM Forecast__Share WHERE ParentId IN: forecastIds AND RowCause != 'PROG_FORECAST__c'];
            Map<String, Set<String>> mapParentIdToUserId = new Map<String, Set<String>>();
            for(Forecast__Share existingShares : existingTeamMember) {
                if(mapParentIdToUserId.get(existingShares.ParentId) != null && !mapParentIdToUserId.get(existingShares.ParentId).isEmpty()) {
                    mapParentIdToUserId.get(existingShares.ParentId).add(existingShares.UserOrGroupId);
                } 
                else {
                    mapParentIdToUserId.put(existingShares.ParentId, new Set<String>{existingShares.UserOrGroupId});
                }
                system.debug('Existing Members: ' + mapParentIdToUserId.get(existingShares.ParentId));
            }
            
            List<Forecast__Share> lstForecastShare = new List<Forecast__Share>();
            
            for(AccountTeamMember teamMember : lstAccountTeamMember) {
                if(mapSoldToIdToShipToIds.get(teamMember.AccountId) != null && !mapSoldToIdToShipToIds.get(teamMember.AccountId).isEmpty()) {
                    for(String shipToId : mapSoldToIdToShipToIds.get(teamMember.AccountId)) {
                        if(mapShipToIdToPurchasedProductIds.get(shipToId) != null && !mapShipToIdToPurchasedProductIds.get(shipToId).isEmpty()) {
                            for(String purchasedProductId : mapShipToIdToPurchasedProductIds.get(shipToId)) {
                                if(mapPurchasedProductToForecast.get(purchasedProductId) != null && !mapPurchasedProductToForecast.get(purchasedProductId).isEmpty()) {
                                    for(Forecast__c forecast : mapPurchasedProductToForecast.get(purchasedProductId)) {
                                        if(mapForecastIdToForecastOwnerIds.get(forecast.Id) != null) {
                                            if(teamMember.UserId != mapForecastIdToForecastOwnerIds.get(forecast.Id) && (mapParentIdToUserId.get(forecast.Id) != null && !mapParentIdToUserId.get(forecast.Id).isEmpty() && !mapParentIdToUserId.get(forecast.Id).contains(teamMember.UserId))) {
                                                Forecast__Share forecastShare = new Forecast__Share();
                                                forecastShare.ParentId = forecast.Id;
                                                forecastShare.UserOrGroupId = teamMember.UserId;
                                                if(teamMember.OpportunityAccessLevel == 'Edit') {
                                                    forecastShare.AccessLevel = 'Edit';
                                                } else {
                                                    forecastShare.AccessLevel = 'Read';
                                                }
                                                forecastShare.RowCause = Schema.Forecast__Share.RowCause.PROG_FORECAST__c;
                                                lstForecastShare.add(forecastShare);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            List<Forecast__Share> lstForecastShareDel = [SELECT Id, ParentId, RowCause FROM Forecast__Share WHERE ParentId IN: forecastIds AND RowCause = 'PROG_FORECAST__c'];
            
            // Reset the sharing first
            if(lstForecastShareDel != null && !lstForecastShareDel.isEmpty()) {
                Database.delete(lstForecastShareDel);
            }
            
            // And then re-create them
            if(lstForecastShare != null && !lstForecastShare.isEmpty()) {
                Database.insert(lstForecastShare);
            }
        }
    }
 */   
    public static void updateManagementFields(set<Id> forecastIds){
        /*****Code Added on 12th Nov 2021 to remove change tracker*****Start********-----Ajay Choudhary-----**/
        Forecast__c fc = new Forecast__c();
        Set<String> allForecastFields = fields(fc.getSobjectType());
        allForecastFields.add('Product_Forecast__r.Business_Group__c');
        String query = 'SELECT ';
        for(String fieldName : allForecastFields){
            query += fieldName+',';
        }
        query = query.removeEnd(',');
        query += ' FROM Forecast__c WHERE Id IN :forecastIds';
        /*****Code Added on 12th Nov 2021 to remove change tracker*****End********-----Ajay Choudhary-----**/
        List<Forecast__c> forecastListToUpdate = new List<Forecast__c>();
        List<Forecast__c> forecastList = Database.query(query);
        System.debug('forecastList====='+forecastList);
        for(Forecast__c f : forecastList){
            if(f.PriorActuals_M1__c != null && f.PriorActuals_M1__c != 0 && f.PriorActuals_M2__c != null && f.PriorActuals_M2__c != 0 && f.PriorActuals_M3__c != null && f.PriorActuals_M3__c != 0){
                f.SixMonthRunningAverage_1__c = ((f.PriorActuals_M1__c+f.PriorActuals_M2__c+f.PriorActuals_M3__c)/3).setScale(3);
                f.SixMonthRunningAverage_2__c = ((f.PriorActuals_M1__c+f.PriorActuals_M2__c+f.PriorActuals_M3__c)/3).setScale(3);
                f.SixMonthRunningAverage_3__c = ((f.PriorActuals_M1__c+f.PriorActuals_M2__c+f.PriorActuals_M3__c)/3).setScale(3);
            }
            if(f.PriorActuals_M4__c != null && f.PriorActuals_M4__c != 0 && f.PriorActuals_M5__c != null && f.PriorActuals_M5__c != 0 && f.PriorActuals_M6__c != null && f.PriorActuals_M6__c != 0){
                f.SixMonthRunningAverage_4__c = ((f.PriorActuals_M4__c+f.PriorActuals_M5__c+f.PriorActuals_M6__c)/3).setScale(3);
                f.SixMonthRunningAverage_5__c = ((f.PriorActuals_M4__c+f.PriorActuals_M5__c+f.PriorActuals_M6__c)/3).setScale(3);
                f.SixMonthRunningAverage_6__c = ((f.PriorActuals_M4__c+f.PriorActuals_M5__c+f.PriorActuals_M6__c)/3).setScale(3);
            }
            
            if(f.PriorActuals_M7__c != null && f.PriorActuals_M7__c != 0 && f.PriorActuals_M8__c != null && f.PriorActuals_M8__c != 0 && f.PriorActuals_M9__c != null && f.PriorActuals_M9__c != 0){
                f.SixMonthRunningAverage_7__c = ((f.PriorActuals_M7__c+f.PriorActuals_M8__c+f.PriorActuals_M9__c)/3).setScale(3);
                f.SixMonthRunningAverage_8__c = ((f.PriorActuals_M7__c+f.PriorActuals_M8__c+f.PriorActuals_M9__c)/3).setScale(3);
                f.SixMonthRunningAverage_9__c = ((f.PriorActuals_M7__c+f.PriorActuals_M8__c+f.PriorActuals_M9__c)/3).setScale(3);
            }
            
            if(f.PriorActuals_M10__c != null && f.PriorActuals_M10__c != 0 && f.PriorActuals_M11__c != null && f.PriorActuals_M11__c != 0 && f.PriorActuals_M12__c != null && f.PriorActuals_M12__c != 0){
                f.SixMonthRunningAverage_10__c = ((f.PriorActuals_M10__c+f.PriorActuals_M11__c+f.PriorActuals_M12__c)/3).setScale(3);
                f.SixMonthRunningAverage_11__c = ((f.PriorActuals_M10__c+f.PriorActuals_M11__c+f.PriorActuals_M12__c)/3).setScale(3);
                f.SixMonthRunningAverage_12__c = ((f.PriorActuals_M10__c+f.PriorActuals_M11__c+f.PriorActuals_M12__c)/3).setScale(3);
            }
            /*****Code Changed on 12th Nov 2021 to remove change tracker*****Start********-----Ajay Choudhary-----**/
            if(f.Product_Forecast__r.Business_Group__c != null && (f.Product_Forecast__r.Business_Group__c == 'ALLYLICS & AROMATICS' || f.Product_Forecast__r.Business_Group__c == 'RESINS' || f.Product_Forecast__r.Business_Group__c == 'SYSTEMS & GROWTH')){
                if(f.SixMonthRunningAverage_1__c != null && f.SixMonthRunningAverage_1__c != 0 && f.SixMonthRunningAverage_2__c != null && f.SixMonthRunningAverage_2__c != 0 && f.SixMonthRunningAverage_3__c != null && f.SixMonthRunningAverage_3__c != 0 ){
                    if(f.Acct_Rep_Last_Modified_M1__c == null){
                        f.Acct_Rep_M1__c = f.SixMonthRunningAverage_1__c;
                    }
                    if(f.Acct_Rep_Last_Modified_M2__c == null){
                        f.Acct_Rep_M2__c = f.SixMonthRunningAverage_2__c;
                    }
                    if(f.Acct_Rep_Last_Modified_M3__c == null){
                        f.Acct_Rep_M3__c = f.SixMonthRunningAverage_3__c;
                    }
                    if(f.Management_Last_Modified_M1__c == null){
                        f.Management_M1__c = f.SixMonthRunningAverage_1__c;
                    }
                    if(f.Management_Last_Modified_M2__c == null){
                        f.Management_M2__c = f.SixMonthRunningAverage_2__c;
                    }
                    if(f.Management_Last_Modified_M3__c == null){
                        f.Management_M3__c = f.SixMonthRunningAverage_3__c;
                    }
                }
                
                if(f.SixMonthRunningAverage_4__c != null && f.SixMonthRunningAverage_4__c != 0 && f.SixMonthRunningAverage_5__c != null && f.SixMonthRunningAverage_5__c != 0 && f.SixMonthRunningAverage_6__c != null && f.SixMonthRunningAverage_6__c != 0 ){
                    if(f.Acct_Rep_Last_Modified_M4__c == null){
                        f.Acct_Rep_M4__c = f.SixMonthRunningAverage_4__c;
                    }
                    if(f.Acct_Rep_Last_Modified_M5__c == null){
                        f.Acct_Rep_M5__c = f.SixMonthRunningAverage_5__c;
                    }
                    if(f.Acct_Rep_Last_Modified_M6__c == null){
                        f.Acct_Rep_M6__c = f.SixMonthRunningAverage_6__c;
                    }
                    if(f.Management_Last_Modified_M4__c == null){
                        f.Management_M4__c = f.SixMonthRunningAverage_4__c;
                    }
                    if(f.Management_Last_Modified_M5__c == null){
                        f.Management_M5__c = f.SixMonthRunningAverage_5__c;
                    }
                    if(f.Management_Last_Modified_M6__c == null){
                        f.Management_M6__c = f.SixMonthRunningAverage_6__c;
                    }
                }
                
                if(f.SixMonthRunningAverage_7__c != null && f.SixMonthRunningAverage_7__c != 0 && f.SixMonthRunningAverage_8__c != null && f.SixMonthRunningAverage_8__c != 0 && f.SixMonthRunningAverage_9__c != null && f.SixMonthRunningAverage_9__c != 0 ){
                    if(f.Acct_Rep_Last_Modified_M7__c == null){
                        f.Acct_Rep_M7__c = f.SixMonthRunningAverage_7__c;
                    }
                    if(f.Acct_Rep_Last_Modified_M8__c == null){
                        f.Acct_Rep_M8__c = f.SixMonthRunningAverage_8__c;
                    }
                    if(f.Acct_Rep_Last_Modified_M9__c == null){
                        f.Acct_Rep_M9__c = f.SixMonthRunningAverage_9__c;
                    }
                    if(f.Management_Last_Modified_M7__c == null){
                        f.Management_M7__c = f.SixMonthRunningAverage_7__c;
                    }
                    if(f.Management_Last_Modified_M8__c == null){
                        f.Management_M8__c = f.SixMonthRunningAverage_8__c;
                    }
                    if(f.Management_Last_Modified_M9__c == null){
                        f.Management_M9__c = f.SixMonthRunningAverage_9__c;
                    }
                }
                
                if(f.SixMonthRunningAverage_10__c != null && f.SixMonthRunningAverage_10__c != 0 && f.SixMonthRunningAverage_11__c != null && f.SixMonthRunningAverage_11__c != 0 && f.SixMonthRunningAverage_12__c != null && f.SixMonthRunningAverage_12__c != 0 ){
                    if(f.Acct_Rep_Last_Modified_M10__c == null){
                        f.Acct_Rep_M10__c = f.SixMonthRunningAverage_10__c;
                    }
                    if(f.Acct_Rep_Last_Modified_M11__c == null){
                        f.Acct_Rep_M11__c = f.SixMonthRunningAverage_11__c;
                    }
                    if(f.Acct_Rep_Last_Modified_M12__c == null){
                        f.Acct_Rep_M12__c = f.SixMonthRunningAverage_12__c;
                    }
                    if(f.Management_Last_Modified_M10__c == null){
                        f.Management_M10__c = f.SixMonthRunningAverage_11__c;
                    }
                    if(f.Management_Last_Modified_M11__c == null){
                        f.Management_M11__c = f.SixMonthRunningAverage_10__c;
                    }
                    if(f.Management_Last_Modified_M12__c == null){
                        f.Management_M12__c = f.SixMonthRunningAverage_12__c;
                    }
                }
            }
            else if(f.Product_Forecast__r.Business_Group__c != null){
                if(f.Acct_Rep_Last_Modified_M1__c == null && f.PriorActuals_M1__c != null && f.PriorActuals_M1__c != 0){
                    f.Acct_Rep_M1__c = f.PriorActuals_M1__c.setScale(3);
                }
                if(f.Acct_Rep_Last_Modified_M2__c == null && f.PriorActuals_M2__c != null && f.PriorActuals_M2__c != 0){
                    f.Acct_Rep_M2__c = f.PriorActuals_M2__c.setScale(3);
                }
                if(f.Acct_Rep_Last_Modified_M3__c == null && f.PriorActuals_M3__c != null && f.PriorActuals_M3__c != 0){
                    f.Acct_Rep_M3__c = f.PriorActuals_M3__c.setScale(3);
                }
                if(f.Management_Last_Modified_M1__c == null && f.PriorActuals_M1__c != null && f.PriorActuals_M1__c != 0){
                    f.Management_M1__c = f.PriorActuals_M1__c.setScale(3);
                }
                if(f.Management_Last_Modified_M2__c == null && f.PriorActuals_M2__c != null && f.PriorActuals_M2__c != 0){
                    f.Management_M2__c = f.PriorActuals_M2__c.setScale(3);
                }
                if(f.Management_Last_Modified_M3__c == null && f.PriorActuals_M3__c != null && f.PriorActuals_M3__c != 0){
                    f.Management_M3__c = f.PriorActuals_M3__c.setScale(3);
                }
                
                if(f.Acct_Rep_Last_Modified_M4__c == null && f.PriorActuals_M4__c != null && f.PriorActuals_M4__c != 0){
                    f.Acct_Rep_M4__c = f.PriorActuals_M4__c.setScale(3);
                }
                if(f.Acct_Rep_Last_Modified_M5__c == null && f.PriorActuals_M5__c != null && f.PriorActuals_M5__c != 0){
                    f.Acct_Rep_M5__c = f.PriorActuals_M5__c.setScale(3);
                }
                if(f.Acct_Rep_Last_Modified_M6__c == null && f.PriorActuals_M6__c != null && f.PriorActuals_M6__c != 0){
                    f.Acct_Rep_M6__c = f.PriorActuals_M6__c.setScale(3);
                }
                if(f.Management_Last_Modified_By_M4__c == null && f.PriorActuals_M4__c != null && f.PriorActuals_M4__c != 0){
                    f.Management_M4__c = f.PriorActuals_M4__c.setScale(3);
                }
                if(f.Management_Last_Modified_M5__c == null && f.PriorActuals_M5__c != null && f.PriorActuals_M5__c != 0){
                    f.Management_M5__c = f.PriorActuals_M5__c.setScale(3);
                }
                if(f.Management_Last_Modified_M6__c == null && f.PriorActuals_M6__c != null && f.PriorActuals_M6__c != 0){
                    f.Management_M6__c = f.PriorActuals_M6__c.setScale(3);
                }
                
                if(f.Acct_Rep_Last_Modified_M7__c == null && f.PriorActuals_M7__c != null && f.PriorActuals_M7__c != 0){
                    f.Acct_Rep_M7__c = f.PriorActuals_M7__c.setScale(3);
                }
                if(f.Acct_Rep_Last_Modified_M8__c == null && f.PriorActuals_M8__c != null && f.PriorActuals_M8__c != 0){
                    f.Acct_Rep_M8__c = f.PriorActuals_M8__c.setScale(3);
                }
                if(f.Acct_Rep_Last_Modified_M9__c == null && f.PriorActuals_M9__c != null && f.PriorActuals_M9__c != 0){
                    f.Acct_Rep_M9__c = f.PriorActuals_M9__c.setScale(3);
                }
                if(f.Management_Last_Modified_M7__c == null && f.PriorActuals_M7__c != null && f.PriorActuals_M7__c != 0){
                    f.Management_M7__c = f.PriorActuals_M7__c.setScale(3);
                }
                if(f.Management_Last_Modified_M8__c == null && f.PriorActuals_M8__c != null && f.PriorActuals_M8__c != 0){
                    f.Management_M8__c = f.PriorActuals_M8__c.setScale(3);
                }
                if(f.Management_Last_Modified_M9__c == null && f.PriorActuals_M9__c != null && f.PriorActuals_M9__c != 0){
                    f.Management_M9__c = f.PriorActuals_M9__c.setScale(3);
                }
                
                if(f.Acct_Rep_Last_Modified_M10__c == null && f.PriorActuals_M10__c != null && f.PriorActuals_M10__c != 0){
                    f.Acct_Rep_M10__c = f.PriorActuals_M10__c.setScale(3);
                }
                if(f.Acct_Rep_Last_Modified_M11__c == null && f.PriorActuals_M11__c != null && f.PriorActuals_M11__c != 0){
                    f.Acct_Rep_M11__c = f.PriorActuals_M11__c.setScale(3);
                }
                if(f.Acct_Rep_Last_Modified_M12__c == null && f.PriorActuals_M12__c != null && f.PriorActuals_M12__c != 0){
                    f.Acct_Rep_M12__c = f.PriorActuals_M12__c.setScale(3);
                }
                if(f.Management_Last_Modified_M10__c == null && f.PriorActuals_M10__c != null && f.PriorActuals_M10__c != 0){
                    f.Management_M10__c = f.PriorActuals_M10__c.setScale(3);
                }
                if(f.Management_Last_Modified_M11__c == null && f.PriorActuals_M11__c != null && f.PriorActuals_M11__c != 0){
                    f.Management_M11__c = f.PriorActuals_M11__c.setScale(3);
                }
                if(f.Management_Last_Modified_M12__c == null && f.PriorActuals_M12__c != null && f.PriorActuals_M12__c != 0){
                    f.Management_M12__c = f.PriorActuals_M12__c.setScale(3);
                }
                /*****Code Changed on 12th Nov 2021 to remove change tracker*****End********-----Ajay Choudhary-----**/
            }
            forecastListToUpdate.add(f);
        }
        if(forecastListToUpdate.size() > 0){
            update forecastListToUpdate;
        }
    }
    
    private static Set<String> fields(Schema.sObjectType t) {
        Set<String> resultFields = new Set<String>();
        Map<String, Schema.SObjectField> fields = t.getDescribe().fields.getMap();
        for(String fieldName : fields.keySet()){
            Schema.SObjectField field = fields.get(fieldName);
            if(field.getDescribe().isAccessible()){
                resultFields.add(fieldName);
            }
        }
        return resultFields;
    }
}