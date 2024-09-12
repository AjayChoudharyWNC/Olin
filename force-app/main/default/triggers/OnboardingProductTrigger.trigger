trigger OnboardingProductTrigger on Onboarding_Product__c (after insert,after update){
    if(Trigger.isInsert) {
        if(onboardingTriggerHandler.isFirstTime){
            onboardingTriggerHandler.isFirstTime = false;
            onboardingTriggerHandler.afterInsert(trigger.new, trigger.newMap);
        }
        //onboardingTriggerHandler.afterInsertOnboarding(trigger.new);
    }
    if(Trigger.isUpdate){
        if(onboardingTriggerHandler.isFirstTime){
            onboardingTriggerHandler.isFirstTime = false;
            onboardingTriggerHandler.afterUpdate(trigger.new, trigger.oldMap, trigger.newMap);
        }
    }   
}