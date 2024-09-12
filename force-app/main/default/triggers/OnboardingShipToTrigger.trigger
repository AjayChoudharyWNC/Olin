trigger OnboardingShipToTrigger on Onboarding_Ship_To__c (after insert, after update) {
    
    if(Trigger.isInsert || Trigger.isUpdate){
        Set<Id> sapId = new Set<Id>();
        List<Sap_Onboarding__c> toUpdateSapOnboarding = new List<Sap_Onboarding__c>();
        for(Onboarding_Ship_To__c os : Trigger.New){
            if(os.Sap_Onboarding__c != null)
                sapId.add(os.Sap_Onboarding__c);
        }
        System.debug('sapId=='+sapId);
        for(Sap_Onboarding__c sap : [SELECT Id, (SELECT Id, Ship_To_City__c, Ship_To_State_Province__c, Ship_To_Country__c FROM Onboarding_Ship_To__r) FROM Sap_Onboarding__c WHERE Id IN :sapId]){
            if(sap.Onboarding_Ship_To__r != null && sap.Onboarding_Ship_To__r.size() > 0){
                sap.Onboarding_Ship_To_Details__c = sap.Onboarding_Ship_To__r[0].Ship_To_City__c+', '+sap.Onboarding_Ship_To__r[0].Ship_To_State_Province__c+', '+sap.Onboarding_Ship_To__r[0].Ship_To_Country__c;
                toUpdateSapOnboarding.add(sap);
            }
        }
        if(toUpdateSapOnboarding.size() > 0){
            update toUpdateSapOnboarding;
        }
    }

}