trigger OpportunityTrigger on Opportunity (after insert, after update) {
    
    /*if(Trigger.isInsert) {
        if (OpportunityTrigger_Handler.runOnceAfter() || Test.isRunningTest()){
            //--------------Sharing Opportunity with the Account Team if Opportunity is not Confidential------------------
            Set<Id> accIDs = new Set<Id>();
            for(Opportunity opp: Trigger.new){
                if(!opp.Confidential__c){
                    accIDs.add(opp.AccountId);
                }
            }
            List<Team__c> teamList = [SELECT Id,Opportunity_Access__c,Team_Member__c,Account__c 
                                    FROM Team__c 
                                    WHERE Account__c IN: accIDs 
                                    AND Opportunity_Access__c != 'Private' 
                                    AND Opportunity_Access__c != 'Removed' 
                                    LIMIT 50000];
            if(teamList != null && teamList.size() > 0){
                OpportunityTrigger_Handler.shareOpportunity(teamList, Trigger.new);
            }
        }
    }*/

    if(Trigger.isUpdate) {
        if (OpportunityTrigger_Handler.runOnceAfter() || Test.isRunningTest()){
            OpportunityTrigger_Handler.afterUpdateSharing(Trigger.new, Trigger.oldMap);
        }
    }

}