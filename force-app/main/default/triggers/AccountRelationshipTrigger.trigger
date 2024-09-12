trigger AccountRelationshipTrigger on Account_Relationships__c (after insert, before delete) {
    
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            if (AccountRelationship_Handler.runOnceAfter() || Test.isRunningTest()){
                AccountRelationship_Handler.processSharing(Trigger.new, Trigger.oldMap, false);
            }
        }
    }
    
    if(Trigger.isBefore) {
        if(Trigger.isDelete) {
            if (AccountRelationship_Handler.runOnceBefore() || Test.isRunningTest()){
                AccountRelationship_Handler.processSharing(new List<Account_Relationships__c>(), Trigger.oldMap, true);
            }
        }
    }
}