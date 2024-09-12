public class OlinContractTriggerHandler {
     public static Boolean isFirstTime = true;
        public static void processSharing(List<Olin_Contract_Database__c> lstOlinContracts, Map<Id, Olin_Contract_Database__c> oldMap, Boolean isInsert) {
        Map<String, List<String>> mapSoldToIdToOlinContractsIds = new Map<String, List<String>>();
        Map<String, String> mapOlinContractsIdToOlinContractsOwnerIds = new Map<String, String>();
        Set<String> olinContractsIds = new Set<String>();
        Set<String> accountIds = new Set<String>();
        List<Olin_Contract_Database__Share> lstOlinContractsShare = new List<Olin_Contract_Database__Share>();
        List<Olin_Contract_Database__Share> lstOlinContractsDel = new List<Olin_Contract_Database__Share>();
        for(Olin_Contract_Database__c so: lstOlinContracts){
            if(isInsert || (!IsInsert && (oldMap.get(so.Id).Global_Customer__c != so.Global_Customer__c))) {
                if(!mapSoldToIdToOlinContractsIds.containsKey(so.Global_Customer__c)){
                    mapSoldToIdToOlinContractsIds.put(so.Global_Customer__c, new List<String>());
                }
                mapSoldToIdToOlinContractsIds.get(so.Global_Customer__c).add(so.Id);
                olinContractsIds.add(so.Id);
                mapOlinContractsIdToOlinContractsOwnerIds.put(so.Id, so.OwnerId);
                accountIds.add(so.Global_Customer__c);
            }
        }
        
        List<AccountTeamMember> newLstAccountTeamMember = [SELECT Id, AccountId, UserId, User.Name, User.IsActive, TeamMemberRole, AccountAccessLevel, OpportunityAccessLevel 
                                                           FROM AccountTeamMember
                                                           WHERE AccountId IN: accountIds AND User.IsActive = true];
        for(AccountTeamMember teamMember : newLstAccountTeamMember) {
            if(mapSoldToIdToOlinContractsIds.get(teamMember.AccountId) != null && !mapSoldToIdToOlinContractsIds.get(teamMember.AccountId).isEmpty()) {
                for(String soId : mapSoldToIdToOlinContractsIds.get(teamMember.AccountId)) {
                    if(mapOlinContractsIdToOlinContractsOwnerIds.get(soId) != null) {
                        if(teamMember.UserId != mapOlinContractsIdToOlinContractsOwnerIds.get(soId)) {
                            Olin_Contract_Database__Share soShare = new Olin_Contract_Database__Share();
                            soShare.ParentId = soId;
                            soShare.UserOrGroupId = teamMember.UserId;
                            /*if(teamMember.OpportunityAccessLevel == 'Edit') {
                                soShare.AccessLevel = 'Edit';
                            } 
                            else {*/
                                soShare.AccessLevel = 'Read';
                            //}
                            soShare.RowCause = 'Manual';
                            lstOlinContractsShare.add(soShare);
                        }
                    }
                }
            }
        }
        
        lstOlinContractsDel = [SELECT Id, ParentId, RowCause FROM Olin_Contract_Database__Share WHERE ParentId IN: olinContractsIds AND RowCause = 'Manual'];
        if(lstOlinContractsDel.size() > 0){
            delete lstOlinContractsDel;
        }
        
        if(lstOlinContractsShare.size() > 0){
            insert lstOlinContractsShare;
        }
    }

}