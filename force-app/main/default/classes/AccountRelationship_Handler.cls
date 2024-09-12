public class AccountRelationship_Handler {
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
	public AccountRelationship_Handler(){
		System.debug('Trigger Helper Created');
	}

    public static void processSharing(List<Account_Relationships__c> lstAccountRelationship, Map<Id, Account_Relationships__c> oldMap, Boolean isDelete) {
        Map<String, List<String>> mapSoldToIdToShipToIds = new Map<String, List<String>>();
        Map<String, String> mapShipToIdToShipToOwnerIds = new Map<String, String>();
        Map<String, String> mapCallReportIdToCallReportOwnerIds = new Map<String, String>();

        Set<String> soldToIds = new Set<String>();
        Set<String> shipToIds = new Set<String>();
        Set<String> callReportIds = new Set<String>();

        Map<Id, Account_Relationships__c> accountRelationship = new Map<Id, Account_Relationships__c>();

        if(!isDelete) {
            for(Account_Relationships__c acctRelationship : lstAccountRelationship) {
                shipToIds.add(acctRelationship.Ship_To__c);
            }

            accountRelationship = new Map<Id, Account_Relationships__c>([SELECT Id, Ship_To__c, Ship_To__r.OwnerId, Sold_To__c, Sold_To__r.RecordType.Name FROM Account_Relationships__c WHERE Ship_To__c IN: shipToIds AND Relationship_Type__c = 'Sold To / Ship To']);

            for(Account_Relationships__c acctRelationship : accountRelationship.values()) {
                if(mapSoldToIdToShipToIds.get(acctRelationship.Sold_To__c) != null && !mapSoldToIdToShipToIds.get(acctRelationship.Sold_To__c).isEmpty()) {
                    mapSoldToIdToShipToIds.get(acctRelationship.Sold_To__c).add(acctRelationship.Ship_To__c);
                } else {
                    mapSoldToIdToShipToIds.put(acctRelationship.Sold_To__c, new List<String>{acctRelationship.Ship_To__c});
                }
                soldToIds.add(acctRelationship.Sold_To__c);
                mapShipToIdToShipToOwnerIds.put(acctRelationship.Ship_To__c, accountRelationship.get(acctRelationship.Id).Ship_To__r.OwnerId);
            }
        } else {
            for(Account_Relationships__c acctRelationship : oldMap.values()) {
                shipToIds.add(acctRelationship.Ship_To__c);
            }

            accountRelationship = new Map<Id, Account_Relationships__c>([SELECT Id, Ship_To__c, Ship_To__r.OwnerId, Sold_To__c, Sold_To__r.RecordType.Name FROM Account_Relationships__c WHERE Ship_To__c IN: shipToIds AND Relationship_Type__c = 'Sold To / Ship To']);

            for(Account_Relationships__c acctRelationship : accountRelationship.values()) {
                soldToIds.add(acctRelationship.Sold_To__c);
                shipToIds.add(acctRelationship.Ship_To__c);
            }
        }
        
        system.debug('SOLD TO IDS: '+ soldToIds);
        if(soldToIds != null && !soldToIds.isEmpty()) {
            List<FCM_VisitReport__c> lstCallReport = [SELECT Id, FCM_Account__c, OwnerId FROM FCM_VisitReport__c WHERE FCM_Account__c IN: soldToIds];
            for(FCM_VisitReport__c callReport : lstCallReport) {
                callReportIds.add(callReport.Id);
                mapCallReportIdToCallReportOwnerIds.put(callReport.Id, callReport.OwnerId);
            }
        }
        List<AccountTeamMember> lstAccountTeamMember = [SELECT Id, AccountId, UserId, User.Name, User.IsActive, TeamMemberRole, AccountAccessLevel, OpportunityAccessLevel 
                                                        FROM AccountTeamMember
                                                        WHERE AccountId IN: soldToIds AND User.IsActive = true];
        
        List<Account_Relationships__c> lstShipToAccounts = new List<Account_Relationships__c>();
        if(isDelete) {
            lstShipToAccounts = [SELECT Id, Sold_To__c, Ship_To__c, Ship_To__r.OwnerId, Relationship_Type__c FROM Account_Relationships__c WHERE Sold_To__c IN: soldToIds AND Id NOT IN: oldMap.keySet() AND Relationship_Type__c = 'Sold To / Ship To'];
            for(Account_Relationships__c acctRelationship : lstShipToAccounts) {
                    if(mapSoldToIdToShipToIds.get(acctRelationship.Sold_To__c) != null && !mapSoldToIdToShipToIds.get(acctRelationship.Sold_To__c).isEmpty()) {
                    mapSoldToIdToShipToIds.get(acctRelationship.Sold_To__c).add(acctRelationship.Ship_To__c);
                } else {
                    mapSoldToIdToShipToIds.put(acctRelationship.Sold_To__c, new List<String>{acctRelationship.Ship_To__c});
                }
                mapShipToIdToShipToOwnerIds.put(acctRelationship.Ship_To__c, acctRelationship.Ship_To__r.OwnerId);
            }
        }

        List<AccountShare> existingTeamMember = [SELECT Id, AccountId, UserOrGroupId FROM AccountShare WHERE AccountId IN: shipToIds AND RowCause != 'Manual'];
        Map<String, Set<String>> mapParentIdToUserId = new Map<String, Set<String>>();
        for(AccountShare existingShares : existingTeamMember) {
            if(mapParentIdToUserId.get(existingShares.AccountId) != null && !mapParentIdToUserId.get(existingShares.AccountId).isEmpty()) {
                mapParentIdToUserId.get(existingShares.AccountId).add(existingShares.UserOrGroupId);
            } else {
                mapParentIdToUserId.put(existingShares.AccountId, new Set<String>{existingShares.UserOrGroupId});
            }
            system.debug('Existing Members: ' + mapParentIdToUserId.get(existingShares.AccountId));
        }

        List<AccountShare> lstAccountShare = new List<AccountShare>();
        List<FCM_VisitReport__Share> lstCallReportShare = new List<FCM_VisitReport__Share>();
        Map<Id, Account> mapShipToToCallReport = new Map<Id, Account>([SELECT Id, (SELECT Id, OwnerId FROM Call_Reports1__r) FROM Account WHERE Id IN: shipToIds]);

        for(AccountTeamMember teamMember : lstAccountTeamMember) {
            if(mapSoldToIdToShipToIds.get(teamMember.AccountId) != null && !mapSoldToIdToShipToIds.get(teamMember.AccountId).isEmpty()) {
                for(String shipToAcountId : mapSoldToIdToShipToIds.get(teamMember.AccountId)) {
                    if(mapShipToIdToShipToOwnerIds.get(shipToAcountId) != null) {
                        // Share Ship To accounts to all Account Team Members
                        if(teamMember.UserId != mapShipToIdToShipToOwnerIds.get(shipToAcountId)) { // && (mapParentIdToUserId.get(shipToAcountId) != null && !mapParentIdToUserId.get(shipToAcountId).isEmpty() && !mapParentIdToUserId.get(shipToAcountId).contains(teamMember.UserId))
                            AccountShare shipToShare = new AccountShare();
                            shipToShare.AccountId = shipToAcountId;
                            shipToShare.UserOrGroupId = teamMember.UserId;
                            shipToShare.AccountAccessLevel = teamMember.AccountAccessLevel;
                            shipToShare.OpportunityAccessLevel = teamMember.OpportunityAccessLevel;
                            lstAccountShare.add(shipToShare);

                            if(mapShipToToCallReport.get(shipToAcountId) != null) {
                                if(mapShipToToCallReport.get(shipToAcountId).Call_Reports1__r != null && !mapShipToToCallReport.get(shipToAcountId).Call_Reports1__r.isEmpty()) {
                                    for(FCM_VisitReport__c callReport : mapShipToToCallReport.get(shipToAcountId).Call_Reports1__r) {
                                        if(callReport.OwnerId != null) {
                                            if(teamMember.UserId != callReport.OwnerId) {
                                                FCM_VisitReport__Share callReportShare = new FCM_VisitReport__Share();
                                                callReportShare.ParentId = callReport.Id;
                                                callReportShare.UserOrGroupId = teamMember.UserId;
                                                callReportShare.AccessLevel = 'Read';
                                                lstCallReportShare.add(callReportShare);
                                                callReportIds.add(callReport.Id);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        List<AccountShare> lstAccountShareDel = [SELECT Id, AccountId, RowCause, UserOrGroupId FROM AccountShare WHERE AccountId IN: shipToIds AND RowCause = 'Manual'];
        List<FCM_VisitReport__Share> lstCallReportShareDel = [SELECT Id, ParentId, RowCause FROM FCM_VisitReport__Share WHERE ParentId IN: callReportIds AND RowCause = 'Manual'];

        // Reset the sharing first
        if(lstAccountShareDel != null && !lstAccountShareDel.isEmpty()) {
            Database.delete(lstAccountShareDel);
        }

        if(lstCallReportShareDel != null && !lstCallReportShareDel.isEmpty()) {
            Database.delete(lstCallReportShareDel);
        }
        
        // And then re-create them
        if(lstAccountShare != null && !lstAccountShare.isEmpty()) {
            Database.insert(lstAccountShare);
        }

        if(lstCallReportShare != null && !lstCallReportShare.isEmpty()) {
            Database.insert(lstCallReportShare);
        }
        
    }
}