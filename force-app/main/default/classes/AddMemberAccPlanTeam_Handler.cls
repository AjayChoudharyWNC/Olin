public class AddMemberAccPlanTeam_Handler {
    public static Map<Id,Set<Id>> duplicateTeam(Set<Id> accIdSet){
        Map<Id,Set<Id>> accIdSetTeamIdMap = new Map<Id,Set<Id>>();
        List<Team__c> existTeamList = [SELECT Team_Member__c, Account__c FROM Team__c WHERE Account__c IN: accIdSet LIMIT 50000];
        if(existTeamList != null && existTeamList.size() > 0)
        {
            for(Team__c t2 : existTeamList)
            {
                if(!accIdSetTeamIdMap.containsKey(t2.Account__c))
                {
                    accIdSetTeamIdMap.put(t2.Account__c, new Set<Id>());
                }
                accIdSetTeamIdMap.get(t2.Account__c).add(t2.Team_Member__c);
            }
        }
        return accIdSetTeamIdMap;
    }
    public static Account_Plan_Team__c newAccountPlanTeam(String uId, String apId){
        Account_Plan_Team__c accPlanTeam = new Account_Plan_Team__c();
        accPlanTeam.Account_Plan_Member__c = uId;
        accPlanTeam.Account_Plan__c = apId;
        accPlanTeam.Account_Plan_Access__c = 'Read Only';
        return accPlanTeam;
    }
     public static Map<Id, Set<Id>> AccountPlanGet(Set<Id> accPlanIdSet){
        Map<Id, Set<Id>> accPlanIdUserIdMap = new Map<Id, Set<Id>>();
         List<Account_Plan__c> accPlanList = [SELECT Id, Account__c, (Select Id, Account_Plan__c, Account_Plan_Member__c from Account_Plan_Teams__r) FROM Account_Plan__c WHERE Id IN: accPlanIdSet LIMIT 50000];
            if(accPlanList != null && accPlanList.size() > 0) 
            {
                for(Account_Plan__c ap : accPlanList)
                {
                    for(Account_Plan_Team__c apt : ap.Account_Plan_Teams__r)
                    {
                        if(!accPlanIdUserIdMap.containsKey(ap.Id))
                        {
                            accPlanIdUserIdMap.put(ap.Id, new Set<Id>());
                        }
                        accPlanIdUserIdMap.get(ap.Id).add(apt.Account_Plan_Member__c);
                    }
                }
            }
        return accPlanIdUserIdMap;
     }

}