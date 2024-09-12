public class AccountTeamAccessShare {
    
    // Used for Batch runs
    public static void BatchShareAccess(List<String> lstAccount, String jobId) {
        // Get all Account Team Members of the Sold To account
        List<AccountTeamMember> lstAccountTeamMember = [SELECT Id, AccountId, UserId, User.Name, User.IsActive, TeamMemberRole, AccountAccessLevel, OpportunityAccessLevel 
                                                        FROM AccountTeamMember
                                                        WHERE AccountId IN: lstAccount AND User.IsActive = true];

        // Get all records needed related to the Sold To account
        List<Account_Relationships__c> lstAccountRelationships = [SELECT Id, Sold_To__c, Ship_To__c, Ship_To__r.OwnerId, Relationship_Type__c FROM Account_Relationships__c WHERE Sold_To__c IN: lstAccount AND Ship_To__c != null AND Relationship_Type__c = 'Sold To / Ship To'];
        List<FCM_VisitReport__c> lstCallReport = [SELECT Id, FCM_Account__c, OwnerId FROM FCM_VisitReport__c WHERE FCM_Account__c IN: lstAccount];
        List<SBQQ__Quote__c> lstPriceRequest = [SELECT Id, SBQQ__Account__c, OwnerId FROM SBQQ__Quote__c WHERE SBQQ__Account__c IN: lstAccount];
        List<PurchasedProduct_R1__c> lstPurchasedProduct = [SELECT Id, Account_R1__c, (SELECT Id, OwnerId FROM Total_Consumptions__r), (SELECT Id, OwnerId FROM Forecasts__r) FROM PurchasedProduct_R1__c WHERE Account_R1__c IN: lstAccount];
        
        Map<String, List<String>> mapSoldToIdToShipToIds = new Map<String, List<String>>();
        Map<String, String> mapShipToIdToShipToOwnerIds = new Map<String, String>();
        
        Map<String, List<String>> mapSoldToIdToCallReportIds = new Map<String, List<String>>();
        Map<String, String> mapCallReportIdToCallReportOwnerIds = new Map<String, String>();
        Map<String, List<String>> mapShipToIdToCallReportIds = new Map<String, List<String>>();
        
        Map<String, Set<String>> mapShipToIdToOpportunityIds = new Map<String, Set<String>>();
        Map<String, String> mapOppIdToOppOwnerIds = new Map<String, String>();

        Map<String, List<String>> mapSoldToIdToPriceReqIds = new Map<String, List<String>>();
        Map<String, String> mapPriceReqIdToPriceReqOwnerIds = new Map<String, String>();

        Map<String, List<String>> mapSoldToIdToTotalConsumpIds = new Map<String, List<String>>();
        Map<String, String> mapTotalConsumpIdToTotalConsumpOwnerIds = new Map<String, String>();

        Map<String, List<String>> mapSoldToIdToForecastIds = new Map<String, List<String>>();
        Map<String, String> mapForecastIdToForecastOwnerIds = new Map<String, String>();

        Set<String> soldToIds = new Set<String>();
        Set<String> shipToInsertShare = new Set<String>();
        Set<String> shipToIds = new Set<String>();
        Set<String> callReportIds = new Set<String>();
        Set<String> opportunityIds = new Set<String>();
        Set<String> priceReqIds = new Set<String>();
        Set<String> totalConsumptionIds = new Set<String>();
        Set<String> forecastIds = new Set<String>();

        Set<String> acctRelShipTos = new Set<String>();
        for(Account_Relationships__c acctRelationship : lstAccountRelationships) {
            acctRelShipTos.add(acctRelationship.Ship_To__c);
        }

        for(FCM_VisitReport__c callReport : lstCallReport) {
            if(mapSoldToIdToCallReportIds.get(callReport.FCM_Account__c) != null && !mapSoldToIdToCallReportIds.get(callReport.FCM_Account__c).isEmpty()) {
                mapSoldToIdToCallReportIds.get(callReport.FCM_Account__c).add(callReport.Id);
            } else {
                mapSoldToIdToCallReportIds.put(callReport.FCM_Account__c, new List<String>{callReport.Id});
            }
            callReportIds.add(callReport.Id);
            soldToIds.add(callReport.FCM_Account__c);
            mapCallReportIdToCallReportOwnerIds.put(callReport.Id, callReport.OwnerId);
        }

        List<Account_Relationships__c> newLstAccountRelationships = [SELECT Id, Sold_To__c, Sold_To__r.RecordType.Name, Ship_To__c, Ship_To__r.OwnerId, Relationship_Type__c 
                                                                    FROM Account_Relationships__c 
                                                                    WHERE Sold_To__c != null AND Ship_To__c IN: acctRelShipTos AND Relationship_Type__c = 'Sold To / Ship To'];
		
        for(Account_Relationships__c acctRelationship : newLstAccountRelationships) {
            if(mapSoldToIdToShipToIds.get(acctRelationship.Sold_To__c) != null && !mapSoldToIdToShipToIds.get(acctRelationship.Sold_To__c).isEmpty()) {
                mapSoldToIdToShipToIds.get(acctRelationship.Sold_To__c).add(acctRelationship.Ship_To__c);
            } else {
                mapSoldToIdToShipToIds.put(acctRelationship.Sold_To__c, new List<String>{acctRelationship.Ship_To__c});
            }
            
            //if(acctRelationship.Sold_To__r.RecordType.Name != 'Parent') {
                soldToIds.add(acctRelationship.Sold_To__c);
                shipToIds.add(acctRelationship.Ship_To__c);
                mapShipToIdToShipToOwnerIds.put(acctRelationship.Ship_To__c, acctRelationship.Ship_To__r.OwnerId);
            //}

            List<String> callReports = mapSoldToIdToCallReportIds.get(acctRelationship.Sold_To__c);
            mapShipToIdToCallReportIds.put(acctRelationship.Ship_To__c, callReports);
        }
        
        List<AccountTeamMember> newLstAccountTeamMember = [SELECT Id, AccountId, UserId, User.Name, User.IsActive, TeamMemberRole, AccountAccessLevel, OpportunityAccessLevel 
                                                           FROM AccountTeamMember
                                                           WHERE AccountId IN: soldToIds AND User.IsActive = true];
        
        List<OpportunityLineItem> lstOppProduct = [SELECT Id, Ship_To__c, OpportunityId, Opportunity.OwnerId FROM OpportunityLineItem WHERE Ship_To__c IN: shipToIds];
        for(OpportunityLineItem oppProduct : lstOppProduct) {
            if(mapShipToIdToOpportunityIds.get(oppProduct.Ship_To__c) != null && !mapShipToIdToOpportunityIds.get(oppProduct.Ship_To__c).isEmpty()) {
                mapShipToIdToOpportunityIds.get(oppProduct.Ship_To__c).add(oppProduct.OpportunityId);
            } else {
                mapShipToIdToOpportunityIds.put(oppProduct.Ship_To__c, new Set<String>{oppProduct.OpportunityId});
            }
            opportunityIds.add(oppProduct.OpportunityId);
            mapOppIdToOppOwnerIds.put(oppProduct.OpportunityId, oppProduct.Opportunity.OwnerId);
        }
        
        for(SBQQ__Quote__c priceRequest : lstPriceRequest) {
            if(mapSoldToIdToPriceReqIds.get(priceRequest.SBQQ__Account__c) != null && !mapSoldToIdToPriceReqIds.get(priceRequest.SBQQ__Account__c).isEmpty()) {
                mapSoldToIdToPriceReqIds.get(priceRequest.SBQQ__Account__c).add(priceRequest.Id);
            } else {
                mapSoldToIdToPriceReqIds.put(priceRequest.SBQQ__Account__c, new List<String>{priceRequest.Id});
            }
            priceReqIds.add(priceRequest.Id);
            mapPriceReqIdToPriceReqOwnerIds.put(priceRequest.Id, priceRequest.OwnerId);
        }
        
        if(lstPurchasedProduct != null && !lstPurchasedProduct.isEmpty()) {
            for(PurchasedProduct_R1__c purchasedProduct : lstPurchasedProduct) {
                if(purchasedProduct.Total_Consumptions__r != null && !purchasedProduct.Total_Consumptions__r.isEmpty()) {
                    for(Total_Consumption__c totalConsumption : purchasedProduct.Total_Consumptions__r) {
                        if(mapSoldToIdToTotalConsumpIds.get(purchasedProduct.Account_R1__c) != null && !mapSoldToIdToTotalConsumpIds.get(purchasedProduct.Account_R1__c).isEmpty()) {
                            mapSoldToIdToTotalConsumpIds.get(purchasedProduct.Account_R1__c).add(totalConsumption.Id);
                        } else {
                            mapSoldToIdToTotalConsumpIds.put(purchasedProduct.Account_R1__c, new List<String>{totalConsumption.Id});
                        }
                        totalConsumptionIds.add(totalConsumption.Id);
                        mapTotalConsumpIdToTotalConsumpOwnerIds.put(totalConsumption.Id, totalConsumption.OwnerId);
                    }
                }

                if(purchasedProduct.Forecasts__r != null && !purchasedProduct.Forecasts__r.isEmpty()) {
                    for(Forecast__c forecast : purchasedProduct.Forecasts__r) {
                        if(mapSoldToIdToForecastIds.get(purchasedProduct.Account_R1__c) != null && !mapSoldToIdToForecastIds.get(purchasedProduct.Account_R1__c).isEmpty()) {
                            mapSoldToIdToForecastIds.get(purchasedProduct.Account_R1__c).add(forecast.Id);
                        } else {
                            mapSoldToIdToForecastIds.put(purchasedProduct.Account_R1__c, new List<String>{forecast.Id});
                        }
                        forecastIds.add(forecast.Id);
                        mapForecastIdToForecastOwnerIds.put(forecast.Id, forecast.OwnerId);
                    }
                }
            }
        }
        
        // List of SObjects to Share
        List<AccountShare> lstAccountShare = new List<AccountShare>();
        List<FCM_VisitReport__Share> lstCallReportShare = new List<FCM_VisitReport__Share>();
        List<OpportunityShare> lstOpportunityShare = new List<OpportunityShare>();
        List<SBQQ__Quote__Share> lstPriceReqShare = new List<SBQQ__Quote__Share>();
        List<Total_Consumption__Share> lstTotalConsumptionShare = new List<Total_Consumption__Share>();
        List<Forecast__Share> lstForecastShare = new List<Forecast__Share>();

        List<FCM_VisitReport__Share> existingTeamMember = [SELECT Id, ParentId, UserOrGroupId FROM FCM_VisitReport__Share WHERE ParentId IN: callReportIds AND (RowCause != 'PROG_CALL_RPT__c' OR RowCause != 'Manual')];
        Map<String, Set<String>> mapParentIdToUserId = new Map<String, Set<String>>();
        for(FCM_VisitReport__Share existingShares : existingTeamMember) {
            if(mapParentIdToUserId.get(existingShares.ParentId) != null && !mapParentIdToUserId.get(existingShares.ParentId).isEmpty()) {
                mapParentIdToUserId.get(existingShares.ParentId).add(existingShares.UserOrGroupId);
            } else {
                mapParentIdToUserId.put(existingShares.ParentId, new Set<String>{existingShares.UserOrGroupId});
            }
            system.debug('Existing Members: ' + mapParentIdToUserId.get(existingShares.ParentId));
        }
        
        for(AccountTeamMember teamMember : newLstAccountTeamMember) {
            
            if(mapSoldToIdToShipToIds.get(teamMember.AccountId) != null && !mapSoldToIdToShipToIds.get(teamMember.AccountId).isEmpty()) {
                for(String shipToAcountId : mapSoldToIdToShipToIds.get(teamMember.AccountId)) {
                    if(mapShipToIdToShipToOwnerIds.get(shipToAcountId) != null) {
                        // Share Ship To accounts to all Account Team Members
                        if(teamMember.UserId != mapShipToIdToShipToOwnerIds.get(shipToAcountId)) {
                            AccountShare shipToShare = new AccountShare();
                            shipToShare.AccountId = shipToAcountId;
                            shipToShare.UserOrGroupId = teamMember.UserId;
                            shipToShare.AccountAccessLevel = teamMember.AccountAccessLevel;
                            shipToShare.OpportunityAccessLevel = teamMember.OpportunityAccessLevel;
                            lstAccountShare.add(shipToShare);
                            shipToInsertShare.add(shipToAcountId);

                            if(mapShipToIdToCallReportIds.get(shipToAcountId) != null) {
                                if(mapShipToIdToCallReportIds.get(shipToAcountId) != null && !mapShipToIdToCallReportIds.get(shipToAcountId).isEmpty()) {
                                    for(String callReportId : mapShipToIdToCallReportIds.get(shipToAcountId)) {
                                        if(mapCallReportIdToCallReportOwnerIds.get(callReportId) != null) {
                                            if(teamMember.UserId != mapCallReportIdToCallReportOwnerIds.get(callReportId) != null) { // && (mapParentIdToUserId.get(callReportId) != null && !mapParentIdToUserId.get(callReportId).isEmpty() && !mapParentIdToUserId.get(callReportId).contains(teamMember.UserId))
                                                FCM_VisitReport__Share callReportShare = new FCM_VisitReport__Share();
                                                callReportShare.ParentId = callReportId;
                                                callReportShare.UserOrGroupId = teamMember.UserId;
                                                callReportShare.AccessLevel = 'Read';
                                                callReportShare.RowCause = Schema.FCM_VisitReport__Share.RowCause.PROG_CALL_RPT__c;
                                                lstCallReportShare.add(callReportShare);
                                                callReportIds.add(callReportId);
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Share Opportunities to all Account Team Members
                        if(mapShipToIdToOpportunityIds.get(shipToAcountId) != null && !mapShipToIdToOpportunityIds.get(shipToAcountId).isEmpty()) {
                            for(String opportunityId : mapShipToIdToOpportunityIds.get(shipToAcountId)) {
                                if(teamMember.UserId != mapOppIdToOppOwnerIds.get(opportunityId)) {
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
                }
            }

            // Share Call Reports to all Account Team Members
            if(mapSoldToIdToCallReportIds.get(teamMember.AccountId) != null && !mapSoldToIdToCallReportIds.get(teamMember.AccountId).isEmpty()) {
                for(String callReportId : mapSoldToIdToCallReportIds.get(teamMember.AccountId)) {
                    if(mapCallReportIdToCallReportOwnerIds.get(callReportId) != null) {
                        if(teamMember.UserId != mapCallReportIdToCallReportOwnerIds.get(callReportId) && (mapParentIdToUserId.get(callReportId) != null && !mapParentIdToUserId.get(callReportId).isEmpty() && !mapParentIdToUserId.get(callReportId).contains(teamMember.UserId))) {
                            FCM_VisitReport__Share callReportShare = new FCM_VisitReport__Share();
                            callReportShare.ParentId = callReportId;
                            callReportShare.UserOrGroupId = teamMember.UserId;
                            callReportShare.AccessLevel = 'Read';
                            callReportShare.RowCause = Schema.FCM_VisitReport__Share.RowCause.PROG_CALL_RPT__c;
                            lstCallReportShare.add(callReportShare);
                        }
                    }
                }
            }

            // Share Price Requests to all Account Team Members
            if(mapSoldToIdToPriceReqIds.get(teamMember.AccountId) != null && !mapSoldToIdToPriceReqIds.get(teamMember.AccountId).isEmpty()) {
                for(String priceRequestId : mapSoldToIdToPriceReqIds.get(teamMember.AccountId)) {
                    if(mapPriceReqIdToPriceReqOwnerIds.get(priceRequestId) != null) {
                        if(teamMember.UserId != mapPriceReqIdToPriceReqOwnerIds.get(priceRequestId)) {
                            SBQQ__Quote__Share priceRequestShare = new SBQQ__Quote__Share();
                            priceRequestShare.ParentId = priceRequestId;
                            priceRequestShare.UserOrGroupId = teamMember.UserId;
                            if(teamMember.OpportunityAccessLevel == 'Edit') {
                                priceRequestShare.AccessLevel = 'Edit';
                            } else {
                                priceRequestShare.AccessLevel = 'Read';
                            }
                            priceRequestShare.RowCause = Schema.SBQQ__Quote__Share.RowCause.PROG_PRICE_REQ__c;
                            lstPriceReqShare.add(priceRequestShare);
                        }
                    }
                }
            }
            
            // Share Total Consumptions to all Account Team Members
            if(mapSoldToIdToTotalConsumpIds.get(teamMember.AccountId) != null && !mapSoldToIdToTotalConsumpIds.get(teamMember.AccountId).isEmpty()) {
                for(String totalConsumptionId : mapSoldToIdToTotalConsumpIds.get(teamMember.AccountId)) {
                    if(mapTotalConsumpIdToTotalConsumpOwnerIds.get(totalConsumptionId) != null) {
                        if(teamMember.UserId != mapTotalConsumpIdToTotalConsumpOwnerIds.get(totalConsumptionId)) {
                            Total_Consumption__Share totalConsumptionShare = new Total_Consumption__Share();
                            totalConsumptionShare.ParentId = totalConsumptionId;
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

            // Share Forecasts to all Account Team Members
            if(mapSoldToIdToForecastIds.get(teamMember.AccountId) != null && !mapSoldToIdToForecastIds.get(teamMember.AccountId).isEmpty()) {
                for(String forecastId : mapSoldToIdToForecastIds.get(teamMember.AccountId)) {
                    if(mapForecastIdToForecastOwnerIds.get(forecastId) != null) {
                        if(teamMember.UserId != mapForecastIdToForecastOwnerIds.get(forecastId)) {
                            Forecast__Share forecastShare = new Forecast__Share();
                            forecastShare.ParentId = forecastId;
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

        List<AccountShare> lstAccountShareDel = [SELECT Id, AccountId, RowCause FROM AccountShare WHERE AccountId IN: shipToIds AND RowCause = 'Manual' AND Account.Batch_Job_ID__c !=: jobId];
        List<FCM_VisitReport__Share> lstCallReportShareDel = [SELECT Id, ParentId, RowCause FROM FCM_VisitReport__Share WHERE ParentId IN: callReportIds AND RowCause = 'PROG_CALL_RPT__c'];
        List<OpportunityShare> lstOpportunityShareDel = [SELECT Id, OpportunityId, RowCause FROM OpportunityShare WHERE OpportunityId IN: opportunityIds AND RowCause = 'Manual'];
        List<SBQQ__Quote__Share> lstPriceReqShareDel = [SELECT Id, ParentId, RowCause FROM SBQQ__Quote__Share WHERE ParentId IN: priceReqIds AND RowCause = 'PROG_PRICE_REQ__c'];
        List<Total_Consumption__Share> lstTotalConsumptionShareDel = [SELECT Id, ParentId, RowCause FROM Total_Consumption__Share WHERE ParentId IN: totalConsumptionIds AND RowCause = 'PROG_TOTAL_CONSUMP__c'];
        List<Forecast__Share> lstForecastShareDel = [SELECT Id, ParentId, RowCause FROM Forecast__Share WHERE ParentId IN: forecastIds AND RowCause = 'PROG_FORECAST__c'];
        
        // Reset the sharing first
        if(lstAccountShareDel != null && !lstAccountShareDel.isEmpty()) {
            Database.delete(lstAccountShareDel);
        }
        
        if(lstCallReportShareDel != null && !lstCallReportShareDel.isEmpty()) {
            Database.delete(lstCallReportShareDel);
        }
        
        if(lstOpportunityShareDel != null && !lstOpportunityShareDel.isEmpty()) {
            Database.delete(lstOpportunityShareDel);
        }
        
        if(lstPriceReqShareDel != null && !lstPriceReqShareDel.isEmpty()) {
            Database.delete(lstPriceReqShareDel);
        }
        
        if(lstTotalConsumptionShareDel != null && !lstTotalConsumptionShareDel.isEmpty()) {
            Database.delete(lstTotalConsumptionShareDel);
        }

        if(lstForecastShareDel != null && !lstForecastShareDel.isEmpty()) {
            Database.delete(lstForecastShareDel);
        }
        
        // And then re-create them
        if(lstAccountShare != null && !lstAccountShare.isEmpty()) {
            Database.insert(lstAccountShare);
        }

        if(lstCallReportShare != null && !lstCallReportShare.isEmpty()) {
            Database.insert(lstCallReportShare);
        }
        
        if(lstOpportunityShare != null && !lstOpportunityShare.isEmpty()) {
            Database.insert(lstOpportunityShare);
        }
        
        if(lstPriceReqShare != null && !lstPriceReqShare.isEmpty()) {
            Database.insert(lstPriceReqShare);
        }
        
        if(lstTotalConsumptionShare != null && !lstTotalConsumptionShare.isEmpty()) {
            Database.insert(lstTotalConsumptionShare);
        }

        if(lstForecastShare != null && !lstForecastShare.isEmpty()) {
            Database.insert(lstForecastShare);
        }

        // Save the batch ID to be used as a filter in the batch class
        List<Account> updateBatchId = new List<Account>();
        for(String shipto : shipToInsertShare) {
            updateBatchId.add(new Account(Id = shipTo, Batch_Job_ID__c = jobId));
        }
        if(updateBatchId != null && !updateBatchId.isEmpty()) {
            update updateBatchId;
        }
    }

}