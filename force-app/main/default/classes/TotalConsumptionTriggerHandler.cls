public class TotalConsumptionTriggerHandler {
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
    public TotalConsumptionTriggerHandler(){
        System.debug('Trigger Helper Created');
    }

    //Full block of code commented out. This functionality is done by de DuplicateConsumptionsRecordsBatch
    //No need to keep next year's total consumption in synch here
    /*
    public static void afterUpdate(List<Total_Consumption__c> lstTotalConsumption, Map<Id, Total_Consumption__c> oldMap) {
        Integer currentYear;
        Set<String> purchasedProductIds = new Set<String>();
        for(Total_Consumption__c totalConsumption : lstTotalConsumption) {
            purchasedProductIds.add(oldMap.get(totalConsumption.Id).Purchased_Product__c);
            if(currentYear == null) {
                currentYear = integer.valueOf(totalConsumption.Year__c);
            } else if(currentYear < integer.valueOf(totalConsumption.Year__c)) {
                currentYear = integer.valueOf(totalConsumption.Year__c);
            }
        }

        List<Total_Consumption__c> totalConsumptionList = [SELECT Id, Purchased_Product__c, Year__c, Consumption__c, Product__c, Ship_To__c 
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
        
        List<Total_Consumption__c> updatedTotalConsumptionList = new List<Total_Consumption__c>();
        for(Total_Consumption__c totalConsumption : lstTotalConsumption) {
            Integer nextYear = integer.valueOf(totalConsumption.Year__c) + 1;
            system.debug('NEXT YEAR >> ' + nextYear);
            system.debug('MAP >> ' + mapPurchasedProductToTotalConsumption);
            //system.debug('FIRST >> ' + mapPurchasedProductToTotalConsumption.get(oldMap.get(totalConsumption.Id).Purchased_Product__c).keySet().contains(string.valueOf(nextYear)));
            //system.debug('SECOND >> ' + mapPurchasedProductToTotalConsumption.get(oldMap.get(totalConsumption.Id).Purchased_Product__c).keySet().contains(string.valueOf(totalConsumption.Year__c)));
            
            if(
            mapPurchasedProductToTotalConsumption.containsKey(oldMap.get(totalConsumption.Id).Purchased_Product__c)
            && mapPurchasedProductToTotalConsumption.get(oldMap.get(totalConsumption.Id).Purchased_Product__c).containsKey(string.valueOf(nextYear)) 
            && mapPurchasedProductToTotalConsumption.get(oldMap.get(totalConsumption.Id).Purchased_Product__c).get(string.valueOf(nextYear)).Id != totalConsumption.Id) {
                Total_Consumption__c nextYearTotalConsumption = new Total_Consumption__c();
                nextYearTotalConsumption = mapPurchasedProductToTotalConsumption.get(oldMap.get(totalConsumption.Id).Purchased_Product__c).get(string.valueOf(nextYear));
                nextYearTotalConsumption.Consumption__c = totalConsumption.Consumption__c;
                nextYearTotalConsumption.Purchased_Product__c = totalConsumption.Purchased_Product__c;
                nextYearTotalConsumption.Ship_To__c = totalConsumption.Ship_To__c;
                nextYearTotalConsumption.Product__c = totalConsumption.Product__c;
                nextYearTotalConsumption.UniqueId__c = totalConsumption.Purchased_Product__c + '' + nextYear;
                updatedTotalConsumptionList.add(nextYearTotalConsumption);
                system.debug('UPDATED TOTAL CONSUMPTION 1 >> ' + updatedTotalConsumptionList);
            }
        }

        if(updatedTotalConsumptionList != null && !updatedTotalConsumptionList.isEmpty()) {
            //01/06/2021 Jose Aguilar (Cipaq)
            //Changed upsert statement to prevent error: INVALID_FIELD_FOR_INSERT_UPDATE
            //upsert updatedTotalConsumptionList Total_Consumption__c.UniqueId__c;
            upsert updatedTotalConsumptionList;
            system.debug('UPDATED TOTAL CONSUMPTION >> ' + updatedTotalConsumptionList);
        }
    }*/
    
/*    public static void processSharing(List<Total_Consumption__c> lstTotalConsumption, Map<Id, Total_Consumption__c> oldMap, Boolean isInsert) {
        Map<String, List<Total_Consumption__c>> mapPurchasedProductToTotalConsump = new Map<String, List<Total_Consumption__c>>();
        Map<String, String> mapTotalConsumpIdToTotalConsumpOwnerIds = new Map<String, String>();
        
        Set<String> purchasedProductIds = new Set<String>();
        Set<String> totalConsumptionIds = new Set<String>();
        
        for(Total_Consumption__c totalConsumption : lstTotalConsumption) {
            if(isInsert || (!IsInsert && oldMap.get(totalConsumption.Id).Purchased_Product__c != totalConsumption.Purchased_Product__c)) {
                purchasedProductIds.add(totalConsumption.Purchased_Product__c);
                
                if(mapPurchasedProductToTotalConsump.get(totalConsumption.Purchased_Product__c) != null && !mapPurchasedProductToTotalConsump.get(totalConsumption.Purchased_Product__c).isEmpty()) {
                    mapPurchasedProductToTotalConsump.get(totalConsumption.Purchased_Product__c).add(totalConsumption);
                } else {
                    mapPurchasedProductToTotalConsump.put(totalConsumption.Purchased_Product__c, new List<Total_Consumption__c>{totalConsumption});
                }
                totalConsumptionIds.add(totalConsumption.Id);
                mapTotalConsumpIdToTotalConsumpOwnerIds.put(totalConsumption.Id, totalConsumption.OwnerId);
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
            } else {
                mapShipToIdToPurchasedProductIds.put(purchasedProduct.Ship_To__c, new Set<String>{purchasedProduct.Id});
            }
        }

        List<Account_Relationships__c> lstAccountRelationship = [SELECT Id, Ship_To__c, Ship_To__r.OwnerId, Sold_To__c, Sold_To__r.RecordType.Name FROM Account_Relationships__c WHERE Ship_To__c IN: shipToIds AND Relationship_Type__c = 'Sold To / Ship To'];
        for(Account_Relationships__c acctRelationship : lstAccountRelationship) {
            if(mapSoldToIdToShipToIds.get(acctRelationship.Sold_To__c) != null && !mapSoldToIdToShipToIds.get(acctRelationship.Sold_To__c).isEmpty()) {
                mapSoldToIdToShipToIds.get(acctRelationship.Sold_To__c).add(acctRelationship.Ship_To__c);
            } else {
                mapSoldToIdToShipToIds.put(acctRelationship.Sold_To__c, new Set<String>{acctRelationship.Ship_To__c});
            }

            if(acctRelationship.Sold_To__r.RecordType.Name != 'Parent') {
                soldToIds.add(acctRelationship.Sold_To__c);
            }
        }

        system.debug('Sold to ID: ' + soldToIds);
        if(soldToIds != null && !soldToIds.isEmpty()) {
            List<AccountTeamMember> lstAccountTeamMember = [SELECT Id, AccountId, UserId, User.Name, User.IsActive, TeamMemberRole, AccountAccessLevel, OpportunityAccessLevel 
                                                            FROM AccountTeamMember
                                                            WHERE AccountId IN: soldToIds AND User.IsActive = true];
            
            List<Total_Consumption__Share> existingTeamMember = [SELECT Id, ParentId, UserOrGroupId FROM Total_Consumption__Share WHERE ParentId IN: totalConsumptionIds AND (RowCause != 'PROG_TOTAL_CONSUMP__c' OR RowCause != 'Manual')];
            Map<String, Set<String>> mapParentIdToUserId = new Map<String, Set<String>>();
            for(Total_Consumption__Share existingShares : existingTeamMember) {
                if(mapParentIdToUserId.get(existingShares.ParentId) != null && !mapParentIdToUserId.get(existingShares.ParentId).isEmpty()) {
                    mapParentIdToUserId.get(existingShares.ParentId).add(existingShares.UserOrGroupId);
                } else {
                    mapParentIdToUserId.put(existingShares.ParentId, new Set<String>{existingShares.UserOrGroupId});
                }
                system.debug('Existing Members: ' + mapParentIdToUserId.get(existingShares.ParentId));
            }

            List<Total_Consumption__Share> lstTotalConsumptionShare = new List<Total_Consumption__Share>();
            
            for(AccountTeamMember teamMember : lstAccountTeamMember) {
                if(mapSoldToIdToShipToIds.get(teamMember.AccountId) != null && !mapSoldToIdToShipToIds.get(teamMember.AccountId).isEmpty()) {
                    for(String shipToId : mapSoldToIdToShipToIds.get(teamMember.AccountId)) {
                        if(mapShipToIdToPurchasedProductIds.get(shipToId) != null && !mapShipToIdToPurchasedProductIds.get(shipToId).isEmpty()) {
                            for(String purchasedProductId : mapShipToIdToPurchasedProductIds.get(shipToId)) {
                                if(mapPurchasedProductToTotalConsump.get(purchasedProductId) != null && !mapPurchasedProductToTotalConsump.get(purchasedProductId).isEmpty()) {
                                    for(Total_Consumption__c totalConsumption : mapPurchasedProductToTotalConsump.get(purchasedProductId)) {
                                        if(mapTotalConsumpIdToTotalConsumpOwnerIds.get(totalConsumption.Id) != null) {
                                            if(teamMember.UserId != mapTotalConsumpIdToTotalConsumpOwnerIds.get(totalConsumption.Id) && (mapParentIdToUserId.get(totalConsumption.Id) != null && !mapParentIdToUserId.get(totalConsumption.Id).isEmpty() && !mapParentIdToUserId.get(totalConsumption.Id).contains(teamMember.UserId))) {
                                                Total_Consumption__Share totalConsumptionShare = new Total_Consumption__Share();
                                                totalConsumptionShare.ParentId = totalConsumption.Id;
                                                totalConsumptionShare.UserOrGroupId = teamMember.UserId;
                                                if(teamMember.OpportunityAccessLevel == 'Edit') {
                                                    totalConsumptionShare.AccessLevel = 'Edit';
                                                } else {
                                                    totalConsumptionShare.AccessLevel = 'Read';
                                                }
                                                totalConsumptionShare.RowCause = Schema.Total_Consumption__Share.RowCause.PROG_TOTAL_CONSUMP__c;
                                                lstTotalConsumptionShare.add(totalConsumptionShare);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            List<Total_Consumption__Share> lstTotalConsumptionShareDel = [SELECT Id, ParentId, RowCause FROM Total_Consumption__Share WHERE ParentId IN: totalConsumptionIds AND RowCause = 'PROG_TOTAL_CONSUMP__c'];
            
            // Reset the sharing first
            if(lstTotalConsumptionShareDel != null && !lstTotalConsumptionShareDel.isEmpty()) {
                Database.delete(lstTotalConsumptionShareDel);
            }
            
            // And then re-create them
            if(lstTotalConsumptionShare != null && !lstTotalConsumptionShare.isEmpty()) {
                Database.insert(lstTotalConsumptionShare);
            }
            
        }
    } */
}