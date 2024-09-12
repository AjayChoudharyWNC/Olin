trigger OpportunityProductTrigger on OpportunityLineItem (after insert, after update, before delete) {
    
    if(trigger.isAfter) {
        if(trigger.isInsert) {
            if (OpportunityProductTriggerHandler.runOnceAfter() || Test.isRunningTest()){
                OpportunityProductTriggerHandler.afterInsertUpdate(trigger.new, trigger.oldMap, true);
                OpportunityProductTriggerHandler.processSharing(trigger.new, trigger.oldMap, true, false);
            }
        }
        
        if(trigger.isUpdate) {
            if (OpportunityProductTriggerHandler.runOnceAfter() || Test.isRunningTest()){
                OpportunityProductTriggerHandler.afterInsertUpdate(trigger.new, trigger.oldMap, false);
                OpportunityProductTriggerHandler.processSharing(trigger.new, trigger.oldMap, false, false);
            }
        }
    }

    if(trigger.isBefore) {
        if(trigger.isDelete) {
            if (OpportunityProductTriggerHandler.runOnceBefore() || Test.isRunningTest()){
                OpportunityProductTriggerHandler.processSharing(new List<OpportunityLineItem>(), trigger.oldMap, true, true);
            }
        }
    }
}