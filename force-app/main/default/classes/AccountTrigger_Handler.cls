public class AccountTrigger_Handler {
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
	public AccountTrigger_Handler(){
		System.debug('Trigger Helper Created');
	}
    /*
    public static Team__c createTeamRecord(Account acc, Boolean isOwner, List<Team__c> teamList){
        if(teamList == null || teamList.size() == 0){
            Team__c t = new Team__c();
            t.Account__c = acc.Id;
            if(isOwner){
                t.Account_Owner__c = true;
                t.Account_Access__c = 'Read/Write';
            }
            t.Case_Access__c = 'Private';
            t.Opportunity_Access__c = 'Private';
            t.Team_Member__c = acc.OwnerId;
            t.Team_Role__c = 'Account Manager';
            return t;
        }
        else{
            String existingTeamMemberId = '';
            for(Team__c t: teamList){
                if(t.Team_Member__c == acc.OwnerId){
                    existingTeamMemberId = t.Id;
                }
            }
            if(String.isNotBlank(existingTeamMemberId)){
                Team__c t = new Team__c(Id=existingTeamMemberId);
                t.Account__c = acc.Id;
                if(isOwner){
                    t.Account_Owner__c = true;
                    t.Account_Access__c = 'Read/Write';
                }
                t.Case_Access__c = 'Private';
                t.Opportunity_Access__c = 'Private';
                t.Team_Member__c = acc.OwnerId;
                t.Team_Role__c = 'Account Manager';
                return t;
            }
            else
            {
                return createTeamRecord(acc,true,null);
            }
        }
    }
    
    public static void updateAccountTeamOwner(Set<Id> accIDs, List<Account> accList, Map<Id,Account> oldAccountMap){
        List<Team__c> teamListUpsert = new List<Team__c>();
        Map<Id,Team__c> accTeamMap = new Map<Id,Team__c>();
        List<Team__c> updateTeamRemoved = new List<Team__c>();
        List<Team__c> teamList = [SELECT Id,Team_Member__c,Account_Owner__c,Account_Access__c,Case_Access__c,Opportunity_Access__c,Account__c 
                                  FROM Team__c 
                                  WHERE Account__c IN: accIDs
                                  LIMIT 50000];
        if(teamList.size() > 0){
            for(Team__c t: teamList){
                if(t.Team_Member__c == oldAccountMap.get(t.Account__c).OwnerId)
                {
                    t.Account_Access__c = 'Removed';
                    t.Case_Access__c = 'Removed';
                    t.Opportunity_Access__c = 'Removed';
                    t.Account_Owner__c = false;
                    updateTeamRemoved.add(t);
                }
            }
        }
        for(Account acc: accList){
            teamListUpsert.add(createTeamRecord(acc,true,teamList));
        }
        if(teamListUpsert.size() > 0){
            upsert teamListUpsert;
        }
        if(updateTeamRemoved.size() > 0){
            update updateTeamRemoved;
        }
    }*/

    public static void handleAccountTeamOnInsert(List<Account> accList){
        List<AccountTeamMember> newAccountTeamMembers = new List<AccountTeamMember>();
        for(Account act : accList){
            AccountTeamMember newTeamMember = new AccountTeamMember();
            newTeamMember.AccountId = act.Id;
            newTeamMember.UserId = act.OwnerId;
            newTeamMember.TeamMemberRole = 'Account Manager';
            newTeamMember.AccountAccessLevel = 'Edit';
            newTeamMember.OpportunityAccessLevel = 'Edit';
            newAccountTeamMembers.add(newTeamMember);
        }
        if(newAccountTeamMembers.size() > 0){
            insert newAccountTeamMembers;
        }
    }
    public static void processSharing(List<Account> lstAccount, Map<Id, Account> oldMap) {
        List<Account_Relationships__c> lstAccountRelationships = [SELECT Id, Sold_To__c, Ship_To__c, Ship_To__r.OwnerId, Relationship_Type__c, Ship_To__r.Ship_To__c, Ship_To__r.Sold_To__c
                                                                  FROM Account_Relationships__c 
                                                                  WHERE Ship_To__c IN: lstAccount AND Sold_To__c != null AND Relationship_Type__c = 'Sold To / Ship To' AND (Ship_To__r.Ship_To__c = TRUE OR Ship_To__r.Sold_To__c = TRUE)];

        Map<String, List<String>> mapSoldToIdToShipToIds = new Map<String, List<String>>();
        Map<String, String> mapShipToIdToShipToOwnerIds = new Map<String, String>();
		
        List<String> lstSoldToIds = new List<String>();
        Set<String> soldToIds = new Set<String>();
        Set<String> shipToIds = new Set<String>();
        
        Map<Id, Account> accounts = new Map<Id, Account>([SELECT Id, OwnerId, RecordType.Name FROM Account WHERE Id IN: lstAccount]);

        Map<String, String> mapAccountToOldOwnerId = new Map<String, String>();
        Map<String, String> mapAccountToNewOwnerId = new Map<String, String>();
        Map<String, String> mapAccountToOwnerId = new Map<String, String>();

        Set<String> ownerId = new Set<String>();

        for(Account account : accounts.values()) {
            if(oldMap.get(account.Id).OwnerId != account.OwnerId && (account.RecordType.Name == 'Customer' || account.RecordType.Name == 'Prospect' || account.RecordType.Name == 'Parent')) {
                lstSoldToIds.add(account.Id);
                ownerId.add(oldMap.get(account.Id).OwnerId);
                ownerId.add(account.OwnerId);
                mapAccountToOldOwnerId.put(account.Id, oldMap.get(account.Id).OwnerId);
                mapAccountToNewOwnerId.put(account.Id, account.OwnerId);
            }
        }

        List<AccountTeamMember> deleteTeamMember = new List<AccountTeamMember>();
        List<AccountTeamMember> insertTeamMember = new List<AccountTeamMember>();
        List<AccountTeamMember> accountTeamMembers = [SELECT Id, AccountId, UserId, User.IsActive FROM AccountTeamMember WHERE AccountId IN: mapAccountToNewOwnerId.keySet() AND UserId IN: ownerId AND User.IsActive = true];
        
        for(AccountTeamMember acctTeamMember : accountTeamMembers) {
            if(mapAccountToOldOwnerId.get(acctTeamMember.AccountId) == acctTeamMember.UserId) {
                deleteTeamMember.add(acctTeamMember);
            } else if(mapAccountToNewOwnerId.get(acctTeamMember.AccountId) == acctTeamMember.UserId) {
                mapAccountToOwnerId.put(acctTeamMember.AccountId, acctTeamMember.UserId);
            }
        }
        
        if(deleteTeamMember != null && !deleteTeamMember.isEmpty()) {
            delete deleteTeamMember;
        }

        for(String accountId : mapAccountToNewOwnerId.keySet()) {
            if(mapAccountToOwnerId.get(accountId) == null) {
                AccountTeamMember newTeamMember = new AccountTeamMember();
                newTeamMember.AccountId = accountId;
                newTeamMember.UserId = mapAccountToNewOwnerId.get(accountId);
                newTeamMember.TeamMemberRole = 'Account Manager';
                newTeamMember.AccountAccessLevel = 'Edit';
                newTeamMember.OpportunityAccessLevel = 'Edit';
                insertTeamMember.add(newTeamMember);
            }
        }
        
        if(insertTeamMember != null && !insertTeamMember.isEmpty()) {
            insert insertTeamMember;
            ManageAccountTeamMembersController.ShareAccess(lstSoldToIds);
        }

        for(Account_Relationships__c acctRelationship : lstAccountRelationships) {
            if(oldMap.get(acctRelationship.Ship_To__c).OwnerId != acctRelationship.Ship_To__r.OwnerId) {
                if(mapSoldToIdToShipToIds.get(acctRelationship.Sold_To__c) != null && !mapSoldToIdToShipToIds.get(acctRelationship.Sold_To__c).isEmpty()) {
                    mapSoldToIdToShipToIds.get(acctRelationship.Sold_To__c).add(acctRelationship.Ship_To__c);
                } else {
                    mapSoldToIdToShipToIds.put(acctRelationship.Sold_To__c, new List<String>{acctRelationship.Ship_To__c});
                }
                soldToIds.add(acctRelationship.Sold_To__c);
                shipToIds.add(acctRelationship.Ship_To__c);
                mapShipToIdToShipToOwnerIds.put(acctRelationship.Ship_To__c, acctRelationship.Ship_To__r.OwnerId);
            }
        }
        
        if(soldToIds != null && !soldToIds.isEmpty()) {
            List<AccountTeamMember> lstAccountTeamMember = [SELECT Id, AccountId, UserId, User.Name, User.IsActive, TeamMemberRole, AccountAccessLevel, OpportunityAccessLevel 
                                                            FROM AccountTeamMember
                                                            WHERE AccountId IN: soldToIds AND User.IsActive = true];

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

            for(AccountTeamMember teamMember : lstAccountTeamMember) {
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
                            }
                        }
                    }
                }
            }

            List<AccountShare> lstAccountShareDel = [SELECT Id, AccountId, RowCause FROM AccountShare WHERE AccountId IN: shipToIds AND RowCause = 'Manual'];

            // Reset the sharing first
            if(lstAccountShareDel != null && !lstAccountShareDel.isEmpty()) {
                Database.delete(lstAccountShareDel);
            }
            
            // And then re-create them
            if(lstAccountShare != null && !lstAccountShare.isEmpty()) {
                Database.insert(lstAccountShare);
            }
        }
    }

  /*  public static void processAccountsForPriceZone(Account acc, List<Price_Zones__c> allPriceZoneList){
        String recordTypeName = Schema.SObjectType.Account.getRecordTypeInfosById().get(acc.RecordTypeId).Name;
        if(recordTypeName == 'Customer' || recordTypeName == 'Customer Location' 
        || recordTypeName == 'Prospect' || recordTypeName == 'Prospect Location')
        {
            try { acc.Price_Zone__c = AccountTrigger_Handler.getPriceZone(acc.BillingCountryCode, acc.BillingStateCode ,allPriceZoneList); } catch(Exception e){}
        }
    }

    public static String getPriceZone(String bcc, String bsc, List<Price_Zones__c> allPriceZoneList){
        if(String.isBlank(bcc)){
            return '';
        }
        else{
            Map<String,Price_Zones__c> pzMap = new Map<String,Price_Zones__c>();
            for(Price_Zones__c pz: allPriceZoneList){
                if(pz.CountryCode__c == 'US'){
                    pzMap.put(pz.CountryCode__c+'-'+pz.State_Province_Code__c, pz);
                }
                else{
                    pzMap.put(pz.CountryCode__c, pz);
                }
            }
            if(bcc == 'US'){
                if(String.isBlank(bsc)){
                    return '';
                }
                else{
                    if(pzMap.containsKey(bcc+'-'+bsc)){
                        return String.valueOf(pzMap.get(bcc+'-'+bsc).Id);
                    }
                    else{
                        return '';
                    }
                }
            }
            else{
                if(pzMap.containsKey(bcc)){
                    return String.valueOf(pzMap.get(bcc).Id);
                }
                else{
                    return '';
                }
            }
        }
    }*/
}