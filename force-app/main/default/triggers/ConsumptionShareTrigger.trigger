trigger ConsumptionShareTrigger on Consumption_Share__c (after update) {
    if(trigger.isAfter) {
        if(trigger.isUpdate) {
            if (ConsumptionShareTriggerHandler.runOnceAfter() || Test.isRunningTest()){
                ConsumptionShareTriggerHandler.afterUpdate(trigger.new, trigger.oldMap);
            }
        } 
    }
}