trigger TotalConsumptionTrigger on Total_Consumption__c (after insert, after update) {
    if(trigger.isAfter) {
        if(trigger.isInsert) {
            if (TotalConsumptionTriggerHandler.runOnceAfter() || Test.isRunningTest()){
             //   TotalConsumptionTriggerHandler.processSharing(Trigger.new, Trigger.oldMap, true);
            }
        } 
        
        if(trigger.isUpdate) {
            if (TotalConsumptionTriggerHandler.runOnceAfter() || Test.isRunningTest()){
                //TotalConsumptionTriggerHandler.afterUpdate(trigger.new, trigger.oldMap);
              //  TotalConsumptionTriggerHandler.processSharing(Trigger.new, Trigger.oldMap, false);
            }
        } 
    }
}