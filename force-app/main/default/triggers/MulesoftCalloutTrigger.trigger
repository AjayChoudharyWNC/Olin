trigger MulesoftCalloutTrigger on MulesoftCallout__c (after insert) {
    if(Trigger.isAfter && Trigger.isInsert){
        MulesoftCalloutTriggerHandler.handleAfterInsert(Trigger.new);
    }
}