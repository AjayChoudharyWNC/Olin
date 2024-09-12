public without sharing class ManageAccountTeamMembersController {
    public static Boolean runAccountTeamMemberTrigger = true;//----Added by Gaurish Goel on 6th Dec'21 to bypass "AccountTeamMemberTrigger" apex trigger
    
    // Used to get all Account Team Member of an Account
    @AuraEnabled
    public static List<AccountTeamMember> getAccountTeamMembers(String accountId){
        List<AccountTeamMember> lstAccountTeamMember = [SELECT Id, AccountId, UserId, User.Name, User.IsActive, TeamMemberRole, AccountAccessLevel, OpportunityAccessLevel 
                                                        FROM AccountTeamMember
                                                        WHERE AccountId =: accountId AND User.IsActive = true ORDER BY CreatedDate];
        return lstAccountTeamMember;
    }
    
    @AuraEnabled
    public static Boolean getUser(Id acctId) {
        User u = [SELECT Id, Profile.Name FROM User WHERE Id =:Userinfo.getUserId() LIMIT 1];
        Account a = [SELECT Id, OwnerId FROM Account WHERE Id = :acctId LIMIT 1];
        return a.OwnerId == u.Id || u.Profile.Name == 'System Administrator' || FeatureManagement.checkPermission('Account_Team_Managing') || FeatureManagement.checkPermission('Change_Owner_Permission');
    }
    
    // Used to get the picklist values for the Team Role picklist field
    @AuraEnabled
    public static List<String> getPicklistValues(){
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = AccountTeamMember.TeamMemberRole.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }     
        return pickListValuesList;
    }
    
    // Used to insert new Account Team Members
    @AuraEnabled
    public static List<AccountTeamMember> createAccountTeamMember(String teamMember, String accountId){
        AccountTeamMember newAccountTeamMember = new AccountTeamMember();
        newAccountTeamMember = (AccountTeamMember)JSON.deserialize(teamMember, AccountTeamMember.class);
        runAccountTeamMemberTrigger = false;//----Added by Gaurish Goel on 6th Dec'21 to bypass "AccountTeamMemberTrigger" apex trigger
        insert newAccountTeamMember;
        
        List<AccountTeamMember> updatedAccountTeamMembers = [SELECT Id, AccountId, UserId, User.Name, User.IsActive, TeamMemberRole, AccountAccessLevel, OpportunityAccessLevel 
                                                             FROM AccountTeamMember 
                                                             WHERE AccountId =: accountId AND User.IsActive = true];
        return updatedAccountTeamMembers;
    }
    
    @AuraEnabled
    public static List<AccountTeamMember> saveAllItems(String teamMember, String accountId){
        //AccountTeamMember newAccountTeamMember = new AccountTeamMember();
        List<AccountTeamMember> newAccountTeamMember = (List<AccountTeamMember>)JSON.deserialize(teamMember, List<AccountTeamMember>.class);
        runAccountTeamMemberTrigger = false;//----Added by Gaurish Goel on 6th Dec'21 to bypass "AccountTeamMemberTrigger" apex trigger
        upsert newAccountTeamMember;
        
        List<AccountTeamMember> updatedAccountTeamMembers = [SELECT Id, AccountId, UserId, User.Name, User.IsActive, TeamMemberRole, AccountAccessLevel, OpportunityAccessLevel 
                                                             FROM AccountTeamMember 
                                                             WHERE AccountId =: accountId AND User.IsActive = true ORDER BY CreatedDate];
        return updatedAccountTeamMembers;
    }
    
    @AuraEnabled
    public static List<AccountTeamMember> deleteAccountTeamMember(List<String> teamMembers, String accountId){
        List<AccountTeamMember> toDeleteAccountTeamMembers = [SELECT Id, AccountId, UserId, User.Name, User.IsActive, TeamMemberRole, AccountAccessLevel, OpportunityAccessLevel 
                                                              FROM AccountTeamMember 
                                                              WHERE Id IN: teamMembers];
        runAccountTeamMemberTrigger = false;//----Added by Gaurish Goel on 6th Dec'21 to bypass "AccountTeamMemberTrigger" apex trigger
        delete toDeleteAccountTeamMembers;
        
        List<AccountTeamMember> updatedAccountTeamMembers = [SELECT Id, AccountId, UserId, User.Name, User.IsActive, TeamMemberRole, AccountAccessLevel, OpportunityAccessLevel 
                                                             FROM AccountTeamMember 
                                                             WHERE AccountId =: accountId AND User.IsActive = true];
        return updatedAccountTeamMembers;
    }
    
    @AuraEnabled
    public static void ShareAccess(List<String> lstAccount) {
        //runAccountTeamMemberTrigger = false;
        // Get all Account Team Members of the Sold To account
        List<AccountTeamMember> lstAccountTeamMember = [SELECT Id, AccountId, UserId, User.Name, User.IsActive, TeamMemberRole, AccountAccessLevel, OpportunityAccessLevel 
                                                        FROM AccountTeamMember
                                                        WHERE AccountId IN: lstAccount AND User.IsActive = true];
        
        // Get all records needed related to the Sold To account
        List<Account_Relationships__c> lstAccountRelationships = [SELECT Id, Sold_To__c, Ship_To__c, Ship_To__r.OwnerId, Relationship_Type__c FROM Account_Relationships__c WHERE Sold_To__c IN: lstAccount AND Ship_To__c != null AND Relationship_Type__c = 'Sold To / Ship To'];
        List<FCM_VisitReport__c> lstCallReport = [SELECT Id, FCM_Account__c, OwnerId FROM FCM_VisitReport__c WHERE FCM_Account__c IN: lstAccount];
        List<SBQQ__Quote__c> lstPriceRequest = [SELECT Id, SBQQ__Account__c, OwnerId FROM SBQQ__Quote__c WHERE SBQQ__Account__c IN: lstAccount];
        List<SAP_Onboarding__c> lstCustomerSetup = [SELECT Id, Account__c, OwnerId FROM SAP_Onboarding__c WHERE Account__c IN :lstAccount];
        List<Olin_Contract_Database__c> lstOlinContracts = [SELECT Id, Global_Customer__c, OwnerId FROM Olin_Contract_Database__c WHERE Global_Customer__c IN:lstAccount];
        system.debug('lstPriceRequest'+lstPriceRequest);
        system.debug('lstOlinContracts'+lstOlinContracts);
        /* Modified Jimmy Daresta to change for to master detail */
        /*        List<PurchasedProduct_R1__c> lstPurchasedProduct = [SELECT Id, Account_R1__c, (SELECT Id, OwnerId FROM Total_Consumptions__r), (SELECT Id, OwnerId FROM Forecasts__r) FROM PurchasedProduct_R1__c WHERE Account_R1__c IN: lstAccount]; */
        
        Map<String, List<String>> mapSoldToIdToShipToIds = new Map<String, List<String>>();
        Map<String, String> mapShipToIdToShipToOwnerIds = new Map<String, String>();
        
        Map<String, List<String>> mapSoldToIdToCallReportIds = new Map<String, List<String>>();
        Map<String, String> mapCallReportIdToCallReportOwnerIds = new Map<String, String>();
        Map<String, List<String>> mapShipToIdToCallReportIds = new Map<String, List<String>>();
        
        Map<String, Set<String>> mapShipToIdToOpportunityIds = new Map<String, Set<String>>();
        Map<String, String> mapOppIdToOppOwnerIds = new Map<String, String>();
        
        Map<String, List<String>> mapSoldToIdToPriceReqIds = new Map<String, List<String>>();
        Map<String, String> mapPriceReqIdToPriceReqOwnerIds = new Map<String, String>();
        
        Map<String, List<String>> mapSoldToIdToSapIds = new Map<String, List<String>>();
        Map<String, String> mapSapIdToSapOwnerIds = new Map<String, String>();
        
        Map<String, List<String>> mapSoldToIdToContract = new Map<String, List<String>>();
        Map<String, String> mapSapIdToContractOwnerIds = new Map<String, String>();
 
         /* Modified Jimmy Daresta to change to master detail 4/15/2022 */
        
        /* Map<String, List<String>> mapSoldToIdToTotalConsumpIds = new Map<String, List<String>>();
        Map<String, String> mapTotalConsumpIdToTotalConsumpOwnerIds = new Map<String, String>(); */
        
        /* Modified Jimmy Daresta to change to master detail */
        
        /*      Map<String, List<String>> mapSoldToIdToForecastIds = new Map<String, List<String>>();
Map<String, String> mapForecastIdToForecastOwnerIds = new Map<String, String>(); */
        
        Set<String> soldToIds = new Set<String>();
        Set<String> shipToIds = new Set<String>();
        Set<String> callReportIds = new Set<String>();
        Set<String> opportunityIds = new Set<String>();
        Set<String> priceReqIds = new Set<String>();
        Set<String> sapIds = new Set<String>();
        Set<String> contIds = new Set<String>();
        
        
        /* Set<String> ctotalConsumptionIds = new Set<String>(); */ /* Modified Jimmy Daresta to change to master detail */
        /* Set<String> forecastIds = new Set<String>(); */            /* Modified Jimmy Daresta to change to master detail */
        
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
            System.debug('mapSoldToIdToCallReportIds'+mapSoldToIdToCallReportIds);
            callReportIds.add(callReport.Id);
            soldToIds.add(callReport.FCM_Account__c);
            mapCallReportIdToCallReportOwnerIds.put(callReport.Id, callReport.OwnerId);
        }
        for(Olin_Contract_Database__c cont : lstOlinContracts) {
            if(mapSoldToIdToContract.get(cont.Global_Customer__c) != null && !mapSoldToIdToContract.get(cont.Global_Customer__c).isEmpty()) {
                mapSoldToIdToContract.get(cont.Global_Customer__c).add(cont.Id);
            } else {
                mapSoldToIdToContract.put(cont.Global_Customer__c, new List<String>{cont.Id});
            }
            contIds.add(cont.Id);
            soldToIds.add(cont.Global_Customer__c);
            mapSapIdToContractOwnerIds.put(cont.Id, cont.OwnerId);
        }
        system.debug('mapSoldToIdToContract'+mapSoldToIdToContract);
        
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
            System.debug('callReports'+callReports);
            mapShipToIdToCallReportIds.put(acctRelationship.Ship_To__c, callReports);
            System.debug('mapShipToIdToCallReportIds'+mapShipToIdToCallReportIds);
        }
        system.debug('Sold To IDs: ' + soldToIds);
        
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
        
        for(SAP_Onboarding__c sap : lstCustomerSetup) {
            if(mapSoldToIdToSapIds.get(sap.Account__c) != null && !mapSoldToIdToSapIds.get(sap.Account__c).isEmpty()) {
                mapSoldToIdToSapIds.get(sap.Account__c).add(sap.Id);
            } else {
                mapSoldToIdToSapIds.put(sap.Account__c, new List<String>{sap.Id});
            }
            sapIds.add(sap.Id);
            mapSapIdToSapOwnerIds.put(sap.Id, sap.OwnerId);
        }
        
        
        
                        /* Modified Jimmy Daresta to change to forecast to master detail 4/15/2022 */
        
 /*       
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
                }/*
                /* Modified Jimmy Daresta to change to forecast to master detail */
                /*     if(purchasedProduct.Forecasts__r != null && !purchasedProduct.Forecasts__r.isEmpty()) {
for(Forecast__c forecast : purchasedProduct.Forecasts__r) {
if(mapSoldToIdToForecastIds.get(purchasedProduct.Account_R1__c) != null && !mapSoldToIdToForecastIds.get(purchasedProduct.Account_R1__c).isEmpty()) {
mapSoldToIdToForecastIds.get(purchasedProduct.Account_R1__c).add(forecast.Id);
} else {
mapSoldToIdToForecastIds.put(purchasedProduct.Account_R1__c, new List<String>{forecast.Id});
}
forecastIds.add(forecast.Id);
mapForecastIdToForecastOwnerIds.put(forecast.Id, forecast.OwnerId);
}
}*/
 /*           }
        } */
        
        // List of SObjects to Share
        List<AccountShare> lstAccountShare = new List<AccountShare>();
        List<FCM_VisitReport__Share> lstCallReportShare = new List<FCM_VisitReport__Share>();
        List<OpportunityShare> lstOpportunityShare = new List<OpportunityShare>();
        List<SBQQ__Quote__Share> lstPriceReqShare = new List<SBQQ__Quote__Share>();
        List<SAP_Onboarding__Share> lstCustomerSetupShare = new List<SAP_Onboarding__Share>();
        List<Olin_Contract_Database__Share> lstOlinContractShare = new List<Olin_Contract_Database__Share>();
        /* Modified Jimmy Daresta to change to forecast to master detail 4/15/2022 */
        /* List<Total_Consumption__Share> lstTotalConsumptionShare = new List<Total_Consumption__Share>(); */
        /* Modified Jimmy Daresta to change to forecast to master detail */
        /* List<Forecast__Share> lstForecastShare = new List<Forecast__Share>(); */
        
        List<FCM_VisitReport__Share> existingTeamMember = [SELECT Id, ParentId, UserOrGroupId FROM FCM_VisitReport__Share WHERE ParentId IN: callReportIds AND RowCause != 'PROG_CALL_RPT__c' AND RowCause != 'Manual'];
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
                            if(mapShipToIdToCallReportIds.get(shipToAcountId) != null) {
                                if(mapShipToIdToCallReportIds.get(shipToAcountId) != null && !mapShipToIdToCallReportIds.get(shipToAcountId).isEmpty()) {
                                    for(String callReportId : mapShipToIdToCallReportIds.get(shipToAcountId)) {
                                        if(mapCallReportIdToCallReportOwnerIds.get(callReportId) != null) {
                                            if(teamMember.UserId != mapCallReportIdToCallReportOwnerIds.get(callReportId) != null) {// && (mapParentIdToUserId.get(callReportId) != null && !mapParentIdToUserId.get(callReportId).isEmpty() && !mapParentIdToUserId.get(callReportId).contains(teamMember.UserId))
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
            
            //Share customer setp to all Account Team Member
            if(mapSoldToIdToSapIds.get(teamMember.AccountId) != null && !mapSoldToIdToSapIds.get(teamMember.AccountId).isEmpty()) {
                for(String sapId : mapSoldToIdToSapIds.get(teamMember.AccountId)) {
                    if(mapSapIdToSapOwnerIds.get(sapId) != null) {
                        if(teamMember.UserId != mapSapIdToSapOwnerIds.get(sapId)) {
                            SAP_Onboarding__Share sapOnboardingShare = new SAP_Onboarding__Share();
                            sapOnboardingShare.ParentId = sapId;
                            sapOnboardingShare.UserOrGroupId = teamMember.UserId;
                            if(teamMember.OpportunityAccessLevel == 'Edit') {
                                sapOnboardingShare.AccessLevel = 'Edit';
                            } else {
                                sapOnboardingShare.AccessLevel = 'Read';
                            }
                            sapOnboardingShare.RowCause = Schema.SAP_Onboarding__Share.RowCause.Manual;
                            lstCustomerSetupShare.add(sapOnboardingShare);
                        }
                    }
                }
            }
            System.debug('lstCustomerSetupShare=='+lstCustomerSetupShare);
            System.debug('teamMember.AccountId'+teamMember.AccountId);
            if(mapSoldToIdToContract.get(teamMember.AccountId) != null && !mapSoldToIdToContract.get(teamMember.AccountId).isEmpty()) {
                for(String conId : mapSoldToIdToContract.get(teamMember.AccountId)) {
                    System.debug('conId 1'+conId);
                    if(mapSapIdToContractOwnerIds.get(conId) != null) {
                        System.debug('mapSapIdToContractOwnerIds.get(conId)'+mapSapIdToContractOwnerIds.get(conId));
                         System.debug('teamMember.UserId'+teamMember.UserId);
                        if(teamMember.UserId != mapSapIdToContractOwnerIds.get(conId)) {
                            Olin_Contract_Database__Share olinContractShare = new Olin_Contract_Database__Share();
                            olinContractShare.ParentId = conId;
                            olinContractShare.UserOrGroupId = teamMember.UserId;
                            /*if(teamMember.OpportunityAccessLevel == 'Edit') {
                                olinContractShare.AccessLevel = 'Edit';
                            } else {*/
                                olinContractShare.AccessLevel = 'Read';
                            //}
                            olinContractShare.RowCause = Schema.Olin_Contract_Database__Share.RowCause.Manual;
                            lstOlinContractShare.add(olinContractShare);
                        }
                    }
                }
            }
            System.debug('lstOlinContractShare=='+lstOlinContractShare.size()+'=='+lstOlinContractShare);
           /* Modified Jimmy Daresta to change to forecast to master detail 4/15/2022 */                
            // Share Total Consumptions to all Account Team Members
          /*  if(mapSoldToIdToTotalConsumpIds.get(teamMember.AccountId) != null && !mapSoldToIdToTotalConsumpIds.get(teamMember.AccountId).isEmpty()) {
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
            } */
            /* Modified Jimmy Daresta to change to forecast to master detail */    
            // Share Forecasts to all Account Team Members
            /*           if(mapSoldToIdToForecastIds.get(teamMember.AccountId) != null && !mapSoldToIdToForecastIds.get(teamMember.AccountId).isEmpty()) {
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
}*/
            
        }
        
        List<AccountShare> lstAccountShareDel = [SELECT Id, AccountId, RowCause FROM AccountShare WHERE AccountId IN: shipToIds AND RowCause = 'Manual'];
        List<FCM_VisitReport__Share> lstCallReportShareDel = [SELECT Id, ParentId, RowCause FROM FCM_VisitReport__Share WHERE ParentId IN: callReportIds AND RowCause = 'PROG_CALL_RPT__c'];
        List<OpportunityShare> lstOpportunityShareDel = [SELECT Id, OpportunityId, RowCause FROM OpportunityShare WHERE OpportunityId IN: opportunityIds AND RowCause = 'Manual'];
        List<SBQQ__Quote__Share> lstPriceReqShareDel = [SELECT Id, ParentId, RowCause FROM SBQQ__Quote__Share WHERE ParentId IN: priceReqIds AND RowCause = 'PROG_PRICE_REQ__c'];
        List<SAP_Onboarding__Share> lstCustomerSetupShareDel = [SELECT Id, ParentId, RowCause FROM SAP_Onboarding__Share WHERE ParentId IN: sapIds AND RowCause = 'Manual'];
        List<Olin_Contract_Database__Share> lstOlinContractShareDel = [SELECT Id, ParentId, RowCause FROM Olin_Contract_Database__Share WHERE ParentId IN: contIds AND RowCause = 'Manual'];
        
        /* Modified Jimmy Daresta to change to forecast to master detail 4-15-2022 */
        /* List<Total_Consumption__Share> lstTotalConsumptionShareDel = [SELECT Id, ParentId, RowCause FROM Total_Consumption__Share WHERE ParentId IN: totalConsumptionIds AND RowCause = 'PROG_TOTAL_CONSUMP__c']; */
        /* Modified Jimmy Daresta to change to forecast to master detail */
        /*        List<Forecast__Share> lstForecastShareDel = [SELECT Id, ParentId, RowCause FROM Forecast__Share WHERE ParentId IN: forecastIds AND RowCause = 'PROG_FORECAST__c']; */
        
        // Reset the sharing first
        if(lstAccountShareDel != null && !lstAccountShareDel.isEmpty()) {
            Database.delete(lstAccountShareDel);
        }
        
        system.debug('Call Report Delete: ' + lstCallReportShareDel);
        if(lstCallReportShareDel != null && !lstCallReportShareDel.isEmpty()) {
            Database.delete(lstCallReportShareDel);
        }
        
        /*if(lstOpportunityShareDel != null && !lstOpportunityShareDel.isEmpty()) {
Database.delete(lstOpportunityShareDel);
}*/
        
        if(!lstOpportunityShareDel.isEmpty()) {
            try{
                Database.delete(lstOpportunityShareDel);
            }
            catch(exception e){
                system.debug('error message'+ e.getmessage());
            }
        }
        
        if(lstPriceReqShareDel != null && !lstPriceReqShareDel.isEmpty()) {
            ManageAccountTeamMembersBatchDelete batchDelete = new ManageAccountTeamMembersBatchDelete(lstPriceReqShareDel);
            Database.executeBatch(batchDelete, 200);
            //Database.delete(lstPriceReqShareDel);
        }
        
        if(lstCustomerSetupShareDel != null && !lstCustomerSetupShareDel.isEmpty()){
             try{
                Database.delete(lstCustomerSetupShareDel);
            }
            catch(exception e){
                system.debug('error message in lstCustomerSetupShareDel'+ e.getmessage());
            }
        }
        
        if(lstOlinContractShareDel != null && !lstOlinContractShareDel.isEmpty()){
             try{
                Database.delete(lstOlinContractShareDel);
            }
            catch(exception e){
                system.debug('error message in lstOlinContractShareDel'+ e.getmessage());
            }
        }
        
        /* Modified Jimmy Daresta to change to forecast to master detail 4/15/2022 */
        /*
        if(lstTotalConsumptionShareDel != null && !lstTotalConsumptionShareDel.isEmpty()) {
            ManageAccountTeamMembersBatchDelete batchDelete = new ManageAccountTeamMembersBatchDelete(lstTotalConsumptionShareDel);
            Database.executeBatch(batchDelete, 200);
            //Database.delete(lstTotalConsumptionShareDel);
        }
        */        
        /* Modified Jimmy Daresta to change to forecast to master detail */
        /*
if(lstForecastShareDel != null && !lstForecastShareDel.isEmpty()) {
ManageAccountTeamMembersBatchDelete batchDelete = new ManageAccountTeamMembersBatchDelete(lstForecastShareDel);
Database.executeBatch(batchDelete, 200);
//Database.delete(lstForecastShareDel);
}*/
        
        // And then re-create them
        if(lstAccountShare != null && !lstAccountShare.isEmpty()) {
            ManageAccountTeamMembersBatchInsert batchInsert = new ManageAccountTeamMembersBatchInsert(lstAccountShare);
            Database.executeBatch(batchInsert, 200);
            //Database.insert(lstAccountShare);
        }
        
        system.debug('Call Report Share: ' + lstCallReportShare);
        if(lstCallReportShare != null && !lstCallReportShare.isEmpty()) {
            ManageAccountTeamMembersBatchInsert batchInsert = new ManageAccountTeamMembersBatchInsert(lstCallReportShare);
            Database.executeBatch(batchInsert, 200);
            //Database.insert(lstCallReportShare);
        }
        
        if(lstOpportunityShare != null && !lstOpportunityShare.isEmpty()) {
            ManageAccountTeamMembersBatchInsert batchInsert = new ManageAccountTeamMembersBatchInsert(lstOpportunityShare);
            Database.executeBatch(batchInsert, 200);
            //Database.insert(lstOpportunityShare);
        }
        
        if(lstPriceReqShare != null && !lstPriceReqShare.isEmpty()) {
            ManageAccountTeamMembersBatchInsert batchInsert = new ManageAccountTeamMembersBatchInsert(lstPriceReqShare);
            Database.executeBatch(batchInsert, 200);
            //Database.insert(lstPriceReqShare);
        }
        
        if(lstCustomerSetupShare != null && !lstCustomerSetupShare.isEmpty()) {
            ManageAccountTeamMembersBatchInsert batchInsert = new ManageAccountTeamMembersBatchInsert(lstCustomerSetupShare);
            Database.executeBatch(batchInsert, 200);
            //Database.insert(lstCustomerSetupShare);
        }
        if(lstOlinContractShare != null && !lstOlinContractShare.isEmpty()) {
            ManageAccountTeamMembersBatchInsert batchInsert = new ManageAccountTeamMembersBatchInsert(lstOlinContractShare);
            Database.executeBatch(batchInsert, 200);
            //Database.insert(lstCustomerSetupShare);
        }
        
        
        /* Modified Jimmy Daresta to change to forecast to master detail 4/15/2022 */
        /* if(lstTotalConsumptionShare != null && !lstTotalConsumptionShare.isEmpty()) {
            ManageAccountTeamMembersBatchInsert batchInsert = new ManageAccountTeamMembersBatchInsert(lstTotalConsumptionShare);
            Database.executeBatch(batchInsert, 200);
            //Database.insert(lstTotalConsumptionShare);
        } */
        
        /*       if(lstForecastShare != null && !lstForecastShare.isEmpty()) {
ManageAccountTeamMembersBatchInsert batchInsert = new ManageAccountTeamMembersBatchInsert(lstForecastShare);
Database.executeBatch(batchInsert, 200);
//Database.insert(lstForecastShare);
} */
    }
}