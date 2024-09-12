public class CaseTrigger_Handler {
	public static void shareCase(List<Team__c> teamList, List<Case> cList){
        Map<Id,List<Team__c>> teamAccMap = new Map<Id,List<Team__c>>();
        List<CaseShare> cShareList = new List<CaseShare>();
        for(Team__c t: teamList){
            if(!teamAccMap.containsKey(t.Account__c)){
                teamAccMap.put(t.Account__c, new List<Team__c>());
            }
            teamAccMap.get(t.Account__c).add(t);
        }
        for(Case opp: cList){
            if(teamAccMap.containsKey(opp.AccountId)){
                List<Team__c> tList = teamAccMap.get(opp.AccountId);
                for(Team__c t: tList){
                    if(t.Case_Access__c == 'Read Only')
                    	cShareList.add(TeamTrigger_Utility.createCaseShareRecords(t.Team_Member__c, opp.Id, 'Read'));
                    else if(t.Case_Access__c == 'Read/Write')
                        cShareList.add(TeamTrigger_Utility.createCaseShareRecords(t.Team_Member__c, opp.Id, 'Edit'));
                }
            }
        }
        if(cShareList.size() > 0){
            Database.insert(cShareList,false);
        }
    }
}