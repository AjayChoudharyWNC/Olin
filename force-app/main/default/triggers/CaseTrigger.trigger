trigger CaseTrigger on Case (after insert) {
	//--------------Sharing Case with the Account Team if Case Access on Team is read/edit------------------
    Set<Id> accIDs = new Set<Id>();
    for(Case opp: Trigger.new){
        if(opp.AccountId != null){
        	accIDs.add(opp.AccountId);
        }
    }
    List<Team__c> teamList = [SELECT Id,Case_Access__c,Team_Member__c,Account__c 
                              FROM Team__c 
                              WHERE Account__c IN: accIDs 
                              AND Case_Access__c != 'Private' 
                              AND Case_Access__c != 'Removed' 
                              LIMIT 50000];
    if(teamList != null && teamList.size() > 0){
        CaseTrigger_Handler.shareCase(teamList, Trigger.new);
    }
}