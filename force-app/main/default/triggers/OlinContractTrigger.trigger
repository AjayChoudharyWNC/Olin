trigger OlinContractTrigger on Olin_Contract_Database__c (after update, after insert, before update) {
    
    if((Trigger.isUpdate || Trigger.isInsert) && Trigger.isAfter){
        if(OlinContractTriggerHandler.isFirstTime){
            OlinContractTriggerHandler.isFirstTime = false;
            OlinContractTriggerHandler.processSharing(Trigger.new, Trigger.oldMap, Trigger.isInsert ? true : false);
        }
    } 

}