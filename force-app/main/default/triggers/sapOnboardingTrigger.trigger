trigger sapOnboardingTrigger on SAP_Onboarding__c (after update, after insert, before update) {
    if((Trigger.isUpdate || Trigger.isInsert) && Trigger.isAfter){
        if(SapOnboardingTriggerHandler.isFirstTime){
            SapOnboardingTriggerHandler.isFirstTime = false;
            SapOnboardingTriggerHandler.afterupdateSap(trigger.new);
            SapOnboardingTriggerHandler.processSharing(Trigger.new, Trigger.oldMap, Trigger.isInsert ? true : false);
        }
        //SapOnboardingTriggerHandler.handleContacts(Trigger.New);
    } 
    if(Trigger.isAfter && Trigger.isUpdate){
        List<VAT__c> vatList = new List<VAT__c>();
        for(SAP_Onboarding__c sap : [SELECT Id,Credit_Application_Status__c , (SELECT Id FROM VAT1__r) FROM SAP_Onboarding__c WHERE Id IN :Trigger.newMap.keySet()]){
            if(sap.VAT1__r.size() == 0 && sap.Credit_Application_Status__c  == 'Started By Sales'){
                VAT__c vt = new VAT__c();
                vt.SAP_Onboarding__c = sap.Id;
                vatList.add(vt);
            }
        }
        insert vatList;
    }
    if(Trigger.isBefore && Trigger.isUpdate){
        Map<Id, List<Onboarding_Product__c>> prodMap = new Map<Id, List<Onboarding_Product__c>>();
        for(Onboarding_Product__c prod : [SELECT Id,SAP_Onboarding__c, Purchased_Product__r.Product_R1__r.Business_Group__c FROM Onboarding_Product__c WHERE SAP_Onboarding__c IN :Trigger.newMap.keySet()]){
            if(!prodMap.containsKey(prod.SAP_Onboarding__c)){
                prodMap.put(prod.SAP_Onboarding__c, new List<Onboarding_Product__c>());
            }
            prodMap.get(prod.SAP_Onboarding__c).add(prod);
        }
        
        for(SAP_Onboarding__c sap : Trigger.New){
            if(sap.Customer_Information_Status__c == 'Customer Submitted' || sap.Order_Placement_Status__c == 'Customer Submitted' || sap.Product_Stewardship_Status__c == 'Customer Submitted' || sap.Credit_Application_Status__c == 'Customer Submitted'){
                String prodBusinessGroup = '';
                if(prodMap.containsKey(sap.Id)){
                    for(Onboarding_Product__c prod : prodMap.get(sap.Id)){
                        if(!prodBusinessGroup.contains(prod.Purchased_Product__r.Product_R1__r.Business_Group__c))
                            prodBusinessGroup += prod.Purchased_Product__r.Product_R1__r.Business_Group__c+',';
                    }
                    prodBusinessGroup = prodBusinessGroup.removeEnd(',');
                }
                sap.Product_Business_Group__c = prodBusinessGroup;
            }
        }
    }
}