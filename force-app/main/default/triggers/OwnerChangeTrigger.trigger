trigger OwnerChangeTrigger on Account_Plan__c (after update) {
    if(trigger.isUpdate){
        for(Account_Plan__c accPlan: trigger.new){            
            if(accPlan.OwnerId != trigger.oldMap.get(accPlan.Id).OwnerId){
                HelperOwnerChangeTrigger.ownerMethod(accPlan.Id);
            }
        }
    }
}