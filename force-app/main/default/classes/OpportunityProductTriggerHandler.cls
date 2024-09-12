public class OpportunityProductTriggerHandler {
    
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
    // public OpportunityProductTriggerHandler(){
    //     System.debug('Trigger Helper Created');
    // }

    public static void afterInsertUpdate(List<OpportunityLineItem> lstOpportunityProduct, Map<Id, OpportunityLineItem> oldMap, Boolean isInsert) {
        Set<String> oppProdShipTo = new Set<String>();
        Set<Id> oppAccountIds = new Set<Id>();
        Set<Id> oppProdProductIds = new Set<Id>();

        Set<Id> oppIds = new Set<Id>();

        for (OpportunityLineItem oppProduct : lstOpportunityProduct) {
            oppIds.add(oppProduct.Id);
        }

        //Added a query to get the related fields we need
        Map<Id, OpportunityLineItem> oppLineItemMap = new Map<Id, OpportunityLineItem>([
            SELECT Id, Ship_To__c, Product2Id, Product2.Product_Level__c, Opportunity.AccountId 
            FROM OpportunityLineItem 
            WHERE Id IN :oppIds
        ]);

        for (OpportunityLineItem oppProduct : lstOpportunityProduct) {
            //This will always return false because we don't automatically have access to all related records' fields. We need to query for the related fields we need.
            // if (oppProduct.Ship_To__c != null && oppProduct.Product2Id != null && oppProduct.Product2.Product_Level__c == 'GMID') {
            if (oppProduct.Ship_To__c != null && oppProduct.Product2Id != null && oppLineItemMap.get(oppProduct.Id).Product2.Product_Level__c == 'GMID') {
                oppProdShipTo.add(oppProduct.Ship_To__c);
                oppAccountIds.add(oppProduct.Opportunity.AccountId);
                oppProdProductIds.add(oppProduct.Product2Id);
            }
        }

        // Combine queries and use relationships to fetch related data
        Map<Id, OpportunityLineItem> mapOpportunityProduct = new Map<Id, OpportunityLineItem>([
            SELECT Id, Opportunity.AccountId, OpportunityId, Opportunity.SBQQ__PrimaryQuote__c, 
                Opportunity.SBQQ__PrimaryQuote__r.SBQQ__Primary__c, Product2.Product_Level__c, 
                Product2.PH1_Performance_Center__c, Ship_From_Plant_List__r.Plant_Account__c 
            FROM OpportunityLineItem 
            WHERE Id IN :lstOpportunityProduct
        ]);

        List<PurchasedProduct_R1__c> lstPurchasedProduct = [
            SELECT Id, Ship_To__c, Account_Relationship__c, Account_R1__c, Product_R1__c, Ship_Mode__c, 
                Global_UOM__c, Standard_UOM__c, Ship_From_Plant_List__c, Ship_From__c
            FROM PurchasedProduct_R1__c
            WHERE Account_Relationship__c != NULL 
                AND Product_R1__c != NULL 
                AND Account_R1__c != NULL 
                AND Account_Relationship__r.Ship_To__c IN :oppProdShipTo 
                AND Account_R1__c IN :oppAccountIds 
                AND Product_R1__c IN :oppProdProductIds
        ];

        Map<String, List<PurchasedProduct_R1__c>> mapProductToPurchasedProduct = new Map<String, List<PurchasedProduct_R1__c>>();
        Map<Id, String> mapOppProductToExistingPurchProd = new Map<Id, String>();
        List<OpportunityLineItem> oppProductList = new List<OpportunityLineItem>();

        for (PurchasedProduct_R1__c purchasedProductRec : lstPurchasedProduct) {
            String productKey = purchasedProductRec.Product_R1__c;
            
            if (!mapProductToPurchasedProduct.containsKey(productKey)) {
                mapProductToPurchasedProduct.put(productKey, new List<PurchasedProduct_R1__c>());
            }
            
            mapProductToPurchasedProduct.get(productKey).add(purchasedProductRec);
        }

        for (OpportunityLineItem oppProduct : lstOpportunityProduct) {
            if (oppProduct.Product2.Product_Level__c == 'GMID') {
                Boolean hasPurchasedProduct = false;
                String existingPurchasedProduct = '';

                if (mapProductToPurchasedProduct.containsKey(oppProduct.Product2Id)) {
                    for (PurchasedProduct_R1__c purchasedProduct : mapProductToPurchasedProduct.get(oppProduct.Product2Id)) {
                        if (oppProduct.Ship_To__c == purchasedProduct.Ship_To__c && oppProduct.Opportunity.AccountId == purchasedProduct.Account_R1__c) {
                            hasPurchasedProduct = true;
                            existingPurchasedProduct = purchasedProduct.Id;
                            break;
                        }
                    }
                }

                if (!hasPurchasedProduct) {
                    oppProductList.add(oppProduct);
                    mapOppProductToExistingPurchProd.put(oppProduct.Id, '');
                } else {
                    mapOppProductToExistingPurchProd.put(oppProduct.Id, existingPurchasedProduct);
                }
            }
        }

        List<PurchasedProduct_R1__c> purchasedProductList = new List<PurchasedProduct_R1__c>();
        Set<String> purchasedProductKeyIdentifier = new Set<String>();
        Map<Id, PurchasedProduct_R1__c> mapOppProductToNewPurchasedProduct = new Map<Id, PurchasedProduct_R1__c>();

        for (OpportunityLineItem oppProduct : lstOpportunityProduct) {
            if (oppProduct.Ship_To__c != null && oppProduct.Product2Id != null) {
                if (mapOppProductToExistingPurchProd.containsKey(oppProduct.Id)) {
                    if ((isInsert && oppProduct.Opportunity != null && oppProduct.Opportunity.SBQQ__PrimaryQuote__r.SBQQ__Primary__c) ||
                        (!isInsert && oppProduct.Opportunity != null && oppProduct.Opportunity.SBQQ__PrimaryQuote__r.SBQQ__Primary__c &&
                            (oldMap.get(oppProduct.Id).Ship_To__c != oppProduct.Ship_To__c || oldMap.get(oppProduct.Id).Product2Id != oppProduct.Product2Id))) {
                        Id existingPurchasedProductId = mapOppProductToExistingPurchProd.get(oppProduct.Id);
                        String prodId = oppProduct.Product2Id;
                        String shipFromId = mapOpportunityProduct.get(oppProduct.Id).Ship_From_Plant_List__r.Plant_Account__c;
                        String shipToAccount = oppProduct.Ship_To_Account__c;

                        if (existingPurchasedProductId == null && !purchasedProductKeyIdentifier.contains(prodId + shipToAccount + shipFromId)) {
                            PurchasedProduct_R1__c newPurchasedProduct = new PurchasedProduct_R1__c(
                                Account_Relationship__c = oppProduct.Ship_To_Account__c,
                                Ship_To__c = oppProduct.Ship_To__c,
                                Account_R1__c = mapOpportunityProduct.get(oppProduct.Id).Opportunity.AccountId,
                                Product_R1__c = oppProduct.Product2Id,
                                Performance_Center__c = mapOpportunityProduct.get(oppProduct.Id).Product2.PH1_Performance_Center__c,
                                Ship_From_Plant_List__c = oppProduct.Ship_From_Plant_List__c,
                                Ship_From__c = mapOpportunityProduct.get(oppProduct.Id).Ship_From_Plant_List__r.Plant_Account__c,
                                Ship_Mode__c = oppProduct.Ship_Mode__c
                            );

                            purchasedProductKeyIdentifier.add(prodId + shipToAccount + shipFromId);
                            mapOppProductToNewPurchasedProduct.put(oppProduct.Id, newPurchasedProduct);
                        }
                    }
                }
            }
        }

        if (!mapOppProductToNewPurchasedProduct.isEmpty()) {
            insert mapOppProductToNewPurchasedProduct.values();
        }

        List<OpportunityLineItem> newOpportunityProductList = new List<OpportunityLineItem>();

        for (OpportunityLineItem oppProduct : lstOpportunityProduct) {
            if (mapOppProductToExistingPurchProd.containsKey(oppProduct.Id)) {
                OpportunityLineItem oppProd = mapOpportunityProduct.get(oppProduct.Id);

                if (mapOppProductToExistingPurchProd.get(oppProduct.Id) != '' && oppProduct.Purchased_Product__c != mapOppProductToExistingPurchProd.get(oppProduct.Id)) {
                    oppProd.Purchased_Product__c = mapOppProductToExistingPurchProd.get(oppProduct.Id);
                    newOpportunityProductList.add(oppProd);
                } else if (mapOppProductToNewPurchasedProduct.containsKey(oppProduct.Id) && oppProduct.Purchased_Product__c != mapOppProductToNewPurchasedProduct.get(oppProduct.Id).Id) {
                    oppProd.Purchased_Product__c = mapOppProductToNewPurchasedProduct.get(oppProduct.Id).Id;
                    newOpportunityProductList.add(oppProd);
                }
            }
        }

        if (!newOpportunityProductList.isEmpty()) {
            update newOpportunityProductList;
        }
    }


    public static void processSharing(List<OpportunityLineItem> lstOpportunityProduct, Map<Id, OpportunityLineItem> oldMap, Boolean isInsert, Boolean isDelete) {

        Map<String, Set<String>> mapSoldToIdToOpportunityIds = new Map<String, Set<String>>();
        Map<String, String> mapOppIdToOppOwnerIds = new Map<String, String>();

        Set<String> soldToIds = new Set<String>();
        Set<String> oppIds = new Set<String>();

        Map<Id, OpportunityLineItem> mapOppProductToOpp = new Map<Id, OpportunityLineItem>();

        if(!isDelete) {
            mapOppProductToOpp = new Map<Id, OpportunityLineItem>([SELECT Id, OpportunityId, Opportunity.AccountId, Ship_To__c FROM OpportunityLineItem WHERE Id IN: lstOpportunityProduct]);
            for(OpportunityLineItem oppProduct : lstOpportunityProduct) {
                if(isInsert || (!IsInsert && (oldMap.get(oppProduct.Id).Ship_To__c != oppProduct.Ship_To__c || oldMap.get(oppProduct.Id).OpportunityId != oppProduct.OpportunityId))) {
                    oppIds.add(oppProduct.OpportunityId);
                    soldToIds.add(mapOppProductToOpp.get(oppProduct.Id).Opportunity.AccountId);
                    mapOppIdToOppOwnerIds.put(oppProduct.OpportunityId, oppProduct.Opportunity.OwnerId);

                    if(mapSoldToIdToOpportunityIds.get(mapOppProductToOpp.get(oppProduct.Id).Opportunity.AccountId) != null && !mapSoldToIdToOpportunityIds.get(mapOppProductToOpp.get(oppProduct.Id).Opportunity.AccountId).isEmpty()) {
                        mapSoldToIdToOpportunityIds.get(mapOppProductToOpp.get(oppProduct.Id).Opportunity.AccountId).add(oppProduct.OpportunityId);
                    } else {
                        mapSoldToIdToOpportunityIds.put(mapOppProductToOpp.get(oppProduct.Id).Opportunity.AccountId, new Set<String>{oppProduct.OpportunityId});
                    }
                }
            }
        } else {
            mapOppProductToOpp = new Map<Id, OpportunityLineItem>([SELECT Id, OpportunityId, Opportunity.AccountId, Ship_To__c FROM OpportunityLineItem WHERE Id IN: oldMap.keySet()]);
            for(OpportunityLineItem oppProduct : oldMap.values()) {
                oppIds.add(oppProduct.OpportunityId);
                soldToIds.add(mapOppProductToOpp.get(oppProduct.Id).Opportunity.AccountId);
                mapOppIdToOppOwnerIds.put(oppProduct.OpportunityId, oppProduct.Opportunity.OwnerId);

                if(mapSoldToIdToOpportunityIds.get(mapOppProductToOpp.get(oppProduct.Id).Opportunity.AccountId) != null && !mapSoldToIdToOpportunityIds.get(mapOppProductToOpp.get(oppProduct.Id).Opportunity.AccountId).isEmpty()) {
                    mapSoldToIdToOpportunityIds.get(mapOppProductToOpp.get(oppProduct.Id).Opportunity.AccountId).add(oppProduct.OpportunityId);
                } else {
                    mapSoldToIdToOpportunityIds.put(mapOppProductToOpp.get(oppProduct.Id).Opportunity.AccountId, new Set<String>{oppProduct.OpportunityId});
                }
            }
        }
        
        List<OpportunityLineItem> lstOppProduct = new List<OpportunityLineItem>();
        if(isDelete) {
            lstOppProduct = [SELECT Id, Ship_To__c, OpportunityId, Opportunity.OwnerId FROM OpportunityLineItem WHERE OpportunityId IN: oppIds AND Id NOT IN: oldMap.keySet()];
        } else {
            lstOppProduct = [SELECT Id, Ship_To__c, OpportunityId, Opportunity.OwnerId FROM OpportunityLineItem WHERE OpportunityId IN: oppIds AND Ship_To__c != null];
        }
        
        Map<String, List<String>> mapSoldToIdToShipToIds = new Map<String, List<String>>();
        Map<String, Set<String>> mapShipToIdToOpportunityIds = new Map<String, Set<String>>();

        Set<String> shipToIds = new Set<String>();

        for(OpportunityLineItem oppProduct : lstOppProduct) {
            if(oppProduct.Ship_To__c != null) {
                shipToIds.add(oppProduct.Ship_To__c);
            }

            if(mapShipToIdToOpportunityIds.get(oppProduct.Ship_To__c) != null && !mapShipToIdToOpportunityIds.get(oppProduct.Ship_To__c).isEmpty()) {
                mapShipToIdToOpportunityIds.get(oppProduct.Ship_To__c).add(oppProduct.OpportunityId);
            } else {
                mapShipToIdToOpportunityIds.put(oppProduct.Ship_To__c, new Set<String>{oppProduct.OpportunityId});
            }
            mapOppIdToOppOwnerIds.put(oppProduct.OpportunityId, oppProduct.Opportunity.OwnerId);
        }

        if(shipToIds != null && !shipToIds.isEmpty()) {
            List<Account_Relationships__c> lstAccountRelationships = [SELECT Id, Sold_To__c, Ship_To__c, Ship_To__r.OwnerId, Relationship_Type__c, Ship_To__r.Ship_To__c
                                                                        FROM Account_Relationships__c 
                                                                        WHERE Ship_To__c IN: shipToIds AND Sold_To__c != null AND Relationship_Type__c = 'Sold To / Ship To' AND Ship_To__r.Ship_To__c = TRUE];
            
            for(Account_Relationships__c acctRelationship : lstAccountRelationships) {
                if(mapSoldToIdToShipToIds.get(acctRelationship.Sold_To__c) != null && !mapSoldToIdToShipToIds.get(acctRelationship.Sold_To__c).isEmpty()) {
                    mapSoldToIdToShipToIds.get(acctRelationship.Sold_To__c).add(acctRelationship.Ship_To__c);
                } else {
                    mapSoldToIdToShipToIds.put(acctRelationship.Sold_To__c, new List<String>{acctRelationship.Ship_To__c});
                }
                soldToIds.add(acctRelationship.Sold_To__c);
            }
        }

        List<AccountTeamMember> lstAccountTeamMember = [SELECT Id, AccountId, UserId, User.Name, User.IsActive, TeamMemberRole, AccountAccessLevel, OpportunityAccessLevel 
                                                        FROM AccountTeamMember
                                                        WHERE AccountId IN: soldToIds AND User.IsActive = true];

        List<OpportunityShare> existingTeamMember = [SELECT Id, OpportunityId, UserOrGroupId FROM OpportunityShare WHERE OpportunityId IN: oppIds AND RowCause != 'Manual'];
        Map<String, Set<String>> mapParentIdToUserId = new Map<String, Set<String>>();
        for(OpportunityShare existingShares : existingTeamMember) {
            if(mapParentIdToUserId.get(existingShares.OpportunityId) != null && !mapParentIdToUserId.get(existingShares.OpportunityId).isEmpty()) {
                mapParentIdToUserId.get(existingShares.OpportunityId).add(existingShares.UserOrGroupId);
            } else {
                mapParentIdToUserId.put(existingShares.OpportunityId, new Set<String>{existingShares.UserOrGroupId});
            }
            system.debug('Existing Members: ' + mapParentIdToUserId.get(existingShares.OpportunityId));
        }
        
        List<OpportunityShare> lstOpportunityShare = new List<OpportunityShare>();

        for(AccountTeamMember teamMember : lstAccountTeamMember) {
            if(mapSoldToIdToShipToIds.get(teamMember.AccountId) != null && !mapSoldToIdToShipToIds.get(teamMember.AccountId).isEmpty()) {
                for(String shipToAcountId : mapSoldToIdToShipToIds.get(teamMember.AccountId)) {
                    if(mapShipToIdToOpportunityIds.get(shipToAcountId) != null && !mapShipToIdToOpportunityIds.get(shipToAcountId).isEmpty()) {
                        for(String opportunityId : mapShipToIdToOpportunityIds.get(shipToAcountId)) {
                            if(teamMember.UserId != mapOppIdToOppOwnerIds.get(opportunityId) && (mapParentIdToUserId.get(opportunityId) != null && !mapParentIdToUserId.get(opportunityId).isEmpty() && !mapParentIdToUserId.get(opportunityId).contains(teamMember.UserId))) {
                                OpportunityShare opportunityShare = new OpportunityShare();
                                opportunityShare.OpportunityId = opportunityId;
                                opportunityShare.UserOrGroupId = teamMember.UserId;
                                if(teamMember.OpportunityAccessLevel == 'Edit') {
                                    opportunityShare.OpportunityAccessLevel = 'Edit';
                                } else {
                                    opportunityShare.OpportunityAccessLevel = 'Read';
                                }
                                lstOpportunityShare.add(opportunityShare);
                            }
                        }
                    }
                }
            } else if(mapSoldToIdToOpportunityIds.get(teamMember.AccountId) != null && !mapSoldToIdToOpportunityIds.get(teamMember.AccountId).isEmpty()) {
                for(String opportunityId : mapSoldToIdToOpportunityIds.get(teamMember.AccountId)) {
                    if(teamMember.UserId != mapOppIdToOppOwnerIds.get(opportunityId) && (mapParentIdToUserId.get(opportunityId) != null && !mapParentIdToUserId.get(opportunityId).isEmpty() && !mapParentIdToUserId.get(opportunityId).contains(teamMember.UserId))) {
                        OpportunityShare opportunityShare = new OpportunityShare();
                        opportunityShare.OpportunityId = opportunityId;
                        opportunityShare.UserOrGroupId = teamMember.UserId;
                        if(teamMember.OpportunityAccessLevel == 'Edit') {
                            opportunityShare.OpportunityAccessLevel = 'Edit';
                        } else {
                            opportunityShare.OpportunityAccessLevel = 'Read';
                        }
                        lstOpportunityShare.add(opportunityShare);
                    }
                }
            }
        }

        List<OpportunityShare> lstOpportunityShareDel = [SELECT Id, OpportunityId, RowCause FROM OpportunityShare WHERE OpportunityId IN: oppIds AND RowCause = 'Manual'];
        
        // Reset the sharing first
        if(lstOpportunityShareDel != null && !lstOpportunityShareDel.isEmpty()) {
            Database.delete(lstOpportunityShareDel);
        }

        // And then re-create them
        if(lstOpportunityShare != null && !lstOpportunityShare.isEmpty()) {
            Database.insert(lstOpportunityShare);
        }
    }

}