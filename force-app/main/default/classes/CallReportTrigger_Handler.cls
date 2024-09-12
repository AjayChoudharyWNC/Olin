public class CallReportTrigger_Handler {
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
	public CallReportTrigger_Handler(){
		System.debug('Trigger Helper Created');
	}
    /*
    public static void apexSharing(List<FCM_VisitReport__c> crList){
        List<FCM_VisitReport__share> crShare = new List<FCM_VisitReport__share>();
        Set<String> roleNames = new Set<String>();
        set<String> AcntId = new set<String>();
        Map<String,list<Team__c>> mapOfAccountTeamMember = new Map<String,list<Team__c>>();
        for(FCM_VisitReport__c cr: crList){
            roleNames.add(cr.OwnerRoleName_R1__c);
            AcntId.add(cr.FCM_Account__c);
        }
        system.debug('roleNames------'+roleNames);
        
        list<Team__c> acntTeamMember = [SELECT Account__c,Team_Member__c,Account_Access__c FROM Team__c WHERE Account__c IN: AcntId LIMIT 50000];
        system.debug('acntTeamMember'+acntTeamMember);
        for(Team__c acntteam: acntTeamMember)
        {
            if(!mapOfAccountTeamMember.containsKey(acntteam.Account__c)){
                mapOfAccountTeamMember.put(acntteam.Account__c,new list<Team__c>());
            }
            mapOfAccountTeamMember.get(acntteam.Account__c).add(acntteam);     
        }
        
        for(FCM_VisitReport__c fcmVisit: crList)
        {
            list<Team__c> acntTeamlist = mapOfAccountTeamMember.get(fcmVisit.FCM_Account__c);
            if(acntTeamlist != null && acntTeamlist.size() > 0){
                for(Team__c atm: acntTeamlist){
                    if(atm.Account_Access__c == 'Read Only'){
                        FCM_VisitReport__share crs = CallReportTrigger_Utility.getSharingRow(atm.Team_Member__c, fcmVisit.Id, 'Read');
                        crShare.add(crs);
                    }
                    else if(atm.Account_Access__c == 'Read/Write'){
                        FCM_VisitReport__share crs = CallReportTrigger_Utility.getSharingRow(atm.Team_Member__c, fcmVisit.Id, 'Edit');
                        crShare.add(crs);
                    }
                }
            }
        }
        
        if(roleNames.size() > 0){
            List<Sharing__c> sharingList = [SELECT Id,Role_Name__c,Public_Group_s__c FROM Sharing__c WHERE Role_Name__c IN: roleNames LIMIT 50000];
            List<Group> publicGroups = [SELECT Id,DeveloperName FROM Group LIMIT 50000];
            Map<String,Id> groupMap = new Map<String,Id>();
            if(publicGroups != null && publicGroups.size() > 0){
                for(Group g: publicGroups){
                    groupMap.put(g.DeveloperName,g.Id);
                }
            }
            if(sharingList != null && sharingList.size() > 0){
                Map<String,List<String>> roleGroupMap = new Map<String,List<String>>();
                for(Sharing__c s: sharingList){
                    if(String.isNotBlank(s.Role_Name__c)){
                        if(s.Public_Group_s__c.contains(',')){
                            roleGroupMap.put(s.Role_Name__c, s.Public_Group_s__c.split(','));
                        }
                        else{
                            roleGroupMap.put(s.Role_Name__c, new List<String>{s.Public_Group_s__c});
                        }
                    }
                }
                for(FCM_VisitReport__c cr: crList){
                    if(roleGroupMap.containsKey(cr.OwnerRoleName_R1__c)){
                        if(roleGroupMap.get(cr.OwnerRoleName_R1__c).size() == 1 && groupMap.containsKey(roleGroupMap.get(cr.OwnerRoleName_R1__c)[0])){
                            FCM_VisitReport__share crs = CallReportTrigger_Utility.getSharingRow(groupMap.get(roleGroupMap.get(cr.OwnerRoleName_R1__c)[0]), cr.Id, 'Read');
                            crShare.add(crs);
                        }
                        else if(roleGroupMap.get(cr.OwnerRoleName_R1__c).size() > 1){
                            for(String s: roleGroupMap.get(cr.OwnerRoleName_R1__c)){
                                if(groupMap.containsKey(s)){
                                    FCM_VisitReport__share crs = CallReportTrigger_Utility.getSharingRow(groupMap.get(s), cr.Id, 'Read');
                                    crShare.add(crs);
                                }
                            }
                        }
                    }
                }
            }
        }
        if(crShare.size() > 0){
            Database.insert(crShare,false);
        }
    }
    
    public static void revokeSharing(list<FCM_VisitReport__c> revokedCrList)
    {
        set<Id> fcmId = new set<Id>();
        Map<string,list<FCM_VisitReport__share>> mapOfFcm = new Map<string,list<FCM_VisitReport__share>>();
        for(FCM_VisitReport__c fcm: revokedCrList)
        {
            fcmId.add(fcm.Id);
        }
        list<FCM_VisitReport__share> fcmShareList =  [select id,ParentId from FCM_VisitReport__share where ParentId IN: fcmId AND RowCause = 'Manual' LIMIT 50000];        
        if(fcmShareList != null && fcmShareList.size() > 0){
        	Database.delete(fcmShareList);
        }
    }*/

    public static void processSharing(List<FCM_VisitReport__c> lstCallReport, Map<Id, FCM_VisitReport__c> oldMap, Boolean isInsert) {
        Map<String, List<String>> mapSoldToIdToShipToIds = new Map<String, List<String>>();
        Map<String, List<String>> mapSoldToIdToCallReportIds = new Map<String, List<String>>();
        Map<String, List<String>> mapShipToIdToCallReportIds = new Map<String, List<String>>();
        Map<String, String> mapCallReportIdToCallReportOwnerIds = new Map<String, String>();

        Set<String> soldToIds = new Set<String>();
        Set<String> callReportIds = new Set<String>();

        for(FCM_VisitReport__c callReport : lstCallReport) {
            if(isInsert || (!isInsert && (oldMap.get(callReport.Id).FCM_Account__c != callReport.FCM_Account__c || oldMap.get(callReport.Id).Location_Account__c != callReport.Location_Account__c))) {
                if(mapSoldToIdToCallReportIds.get(callReport.FCM_Account__c) != null && !mapSoldToIdToCallReportIds.get(callReport.FCM_Account__c).isEmpty()) {
                    mapSoldToIdToCallReportIds.get(callReport.FCM_Account__c).add(callReport.Id);
                } else {
                    mapSoldToIdToCallReportIds.put(callReport.FCM_Account__c, new List<String>{callReport.Id});
                }
                soldToIds.add(callReport.FCM_Account__c);
                callReportIds.add(callReport.Id);
                mapCallReportIdToCallReportOwnerIds.put(callReport.Id, callReport.OwnerId);
            }
        }
        system.debug('@ Account IDs: ' + soldToIds);

        List<Account_Relationships__c> lstAccountRelationships = [SELECT Id, Sold_To__c, Ship_To__c, Ship_To__r.OwnerId, Relationship_Type__c, Ship_To__r.Ship_To__c
                                                                  FROM Account_Relationships__c 
                                                                  WHERE Ship_To__c != null AND Sold_To__c IN: soldToIds AND Relationship_Type__c = 'Sold To / Ship To'];
        
        Set<String> shipToIds = new Set<String>();
        for(Account_Relationships__c acctRelationship : lstAccountRelationships) {
            List<String> callReports = mapSoldToIdToCallReportIds.get(acctRelationship.Sold_To__c);
            mapShipToIdToCallReportIds.put(acctRelationship.Ship_To__c, callReports);
            shipToIds.add(acctRelationship.Ship_To__c);
        }

        List<Account_Relationships__c> newLstAccountRelationships = [SELECT Id, Sold_To__c, Ship_To__c, Ship_To__r.OwnerId, Relationship_Type__c, Ship_To__r.Ship_To__c
                                                                    FROM Account_Relationships__c 
                                                                    WHERE Ship_To__c IN: shipToIds AND Sold_To__c != null AND Relationship_Type__c = 'Sold To / Ship To'];
        for(Account_Relationships__c acctRelationship : newLstAccountRelationships) {
            if(mapSoldToIdToShipToIds.get(acctRelationship.Sold_To__c) != null && !mapSoldToIdToShipToIds.get(acctRelationship.Sold_To__c).isEmpty()) {
                mapSoldToIdToShipToIds.get(acctRelationship.Sold_To__c).add(acctRelationship.Ship_To__c);
            } else {
                mapSoldToIdToShipToIds.put(acctRelationship.Sold_To__c, new List<String>{acctRelationship.Ship_To__c});
            }
            soldToIds.add(acctRelationship.Sold_To__c);
        }
		system.debug('@@ Account IDs: ' + soldToIds);
        if(soldToIds != null && !soldToIds.isEmpty()) {
            List<AccountTeamMember> lstAccountTeamMember = [SELECT Id, AccountId, UserId, User.Name, User.IsActive, TeamMemberRole, AccountAccessLevel, OpportunityAccessLevel 
                                                            FROM AccountTeamMember
                                                            WHERE AccountId IN: soldToIds AND User.IsActive = true];
			system.debug('@@@ Account Team Members: ' + lstAccountTeamMember);
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

            List<FCM_VisitReport__Share> lstCallReportShare = new List<FCM_VisitReport__Share>();
            
            for(AccountTeamMember teamMember : lstAccountTeamMember) {
                // Share Call Reports to all Account Team Members with Account Relationship record
                if(mapSoldToIdToShipToIds.get(teamMember.AccountId) != null && !mapSoldToIdToShipToIds.get(teamMember.AccountId).isEmpty()) {
                    for(String shipToAcountId : mapSoldToIdToShipToIds.get(teamMember.AccountId)) {
                        if(mapShipToIdToCallReportIds.get(shipToAcountId) != null && !mapShipToIdToCallReportIds.get(shipToAcountId).isEmpty()) {
                            for(String callReportId : mapShipToIdToCallReportIds.get(shipToAcountId)) {
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
            }

            List<FCM_VisitReport__Share> lstCallReportShareDel = [SELECT Id, ParentId, RowCause FROM FCM_VisitReport__Share WHERE ParentId IN: callReportIds AND RowCause = 'PROG_CALL_RPT__c'];

            // Reset the sharing first
            if(lstCallReportShareDel != null && !lstCallReportShareDel.isEmpty()) {
                Database.delete(lstCallReportShareDel);
            }

            // And then re-create them
            if(lstCallReportShare != null && !lstCallReportShare.isEmpty()) {
                Database.insert(lstCallReportShare);
            }
        }
    }
}