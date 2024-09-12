public class OnboardingTriggerHandler {
    public static Boolean isFirstTime = true;
    public static void afterInsert(List<Onboarding_Product__c> newList, Map<Id, Onboarding_Product__c> newMap)
    {
        system.debug('after insert');
        Set<Id> sapIds = new Set<Id>();
        Map<Id, Onboarding_Product__c> onboardingProductMap = new Map<id, Onboarding_Product__c>([SELECT Id, SAP_Onboarding__r.Account__c FROM Onboarding_Product__c WHERE Id IN: newMap.keyset()]); 
        List<Questionnaire__c> questList = new List<Questionnaire__c>();
        List<Site_Observation__c> siteList = new  List< Site_Observation__c>();
        List<Onboarding_Product__c> toUpdateList = new List<Onboarding_Product__c>();
        List<SAP_Onboarding__c> toUpdateSapList = new List<SAP_Onboarding__c>();
        Map<Id, List<Assessment_Selector__c>> prodAssesSelectorMap = new Map<Id, List<Assessment_Selector__c>>();
        Map<Id, List<Onboarding_Product__c>> prodMap = new Map<Id, List<Onboarding_Product__c>>();
        for(Onboarding_Product__c pr : newList){
            if(pr.SAP_Onboarding__c != null){
                sapIds.add(pr.SAP_Onboarding__c);
            }
        }
        for(Onboarding_Product__c prod : [SELECT Id,SAP_Onboarding__c, Purchased_Product__r.Product_R1__r.Business_Group__c FROM Onboarding_Product__c WHERE SAP_Onboarding__c IN :sapIds]){
            if(!prodMap.containsKey(prod.SAP_Onboarding__c)){
                prodMap.put(prod.SAP_Onboarding__c, new List<Onboarding_Product__c>());
            }
            prodMap.get(prod.SAP_Onboarding__c).add(prod);
        }
        for(SAP_Onboarding__c sap : [SELECT Id, Name, Product_Business_Group__c FROM SAP_Onboarding__c WHERE Id IN :sapIds]){
            String prodBusinessGroup = '';
            if(prodMap.containsKey(sap.Id)){
                for(Onboarding_Product__c prod : prodMap.get(sap.Id)){
                    if(!prodBusinessGroup.contains(prod.Purchased_Product__r.Product_R1__r.Business_Group__c)){
                        prodBusinessGroup += prod.Purchased_Product__r.Product_R1__r.Business_Group__c+',';
                    }
                    
                }
                prodBusinessGroup = prodBusinessGroup.removeEnd(',');
            }
            sap.Product_Business_Group__c = prodBusinessGroup;
            toUpdateSapList.add(sap);
        }
        for(Assessment_Selector__c ast : [SELECT Id, Product__c, Assessment_Document__c, Hazard_Category__c, Epoxy_Document_Type__c, Ship_Mode__c, Site_Assessment_Needed__c FROM Assessment_Selector__c]){
            if(!prodAssesSelectorMap.containsKey(ast.Product__c)){
                prodAssesSelectorMap.put(ast.Product__c, new List<Assessment_Selector__c>());
            }
            prodAssesSelectorMap.get(ast.Product__c).add(ast);
        }
        for(Onboarding_Product__c op : [SELECT Id, SAP_Onboarding__c, Onboarding_Ship_To__c, Purchased_Product__c,Ship_Mode__c, Customer_Pickup__c, New_Customer_Ship_Mode__c, Purchased_Product__r.Product_R1__c, Purchased_Product__r.Ship_Mode__c, Purchased_Product__r.New_Customer_Ship_Mode__c, Purchased_Product__r.Product_R1__r.Family FROM Onboarding_Product__c WHERE Id IN:newMap.keyset()]){
            if(op.Purchased_Product__c != null && prodAssesSelectorMap.containsKey(op.Purchased_Product__r.Product_R1__c) && prodAssesSelectorMap.get(op.Purchased_Product__r.Product_R1__c).size() > 0) 
            {
                for(Assessment_Selector__c ast : prodAssesSelectorMap.get(op.Purchased_Product__r.Product_R1__c)){
                    if(String.isNotBlank(ast.Assessment_Document__c) && String.isNotBlank(ast.Ship_Mode__c) && (ast.Ship_Mode__c == op.New_Customer_Ship_Mode__c || ast.Ship_Mode__c == 'All')){
                        String recordTypeName = ast.Ship_Mode__c == 'All' ?  ast.Assessment_Document__c : ast.Assessment_Document__c+' - '+ast.Ship_Mode__c;
                        String setupType;
                        if(ast.Assessment_Document__c == 'Epoxy High-Medium Hazard' && op.New_Customer_Ship_Mode__c == 'Truck'){
                            recordTypeName = 'Epoxy High-Medium Hazard - Truck';
                        }
                        op.Hazard_Category__c = ast.Hazard_Category__c;
                        if(SObjectType.Questionnaire__c.getRecordTypeInfosByName().get(recordTypeName) != null){
                            op.Shipment_Questionnaire__c = recordTypeName;
                            if(ast.Assessment_Document__c == 'Epoxy High-Medium Hazard'){
                                op.Shipment_Questionnaire__c = ast.Epoxy_Document_Type__c != null ? ast.Epoxy_Document_Type__c : 'Standard High Medium Checklist';
                            }
                            op.Is_a_Shipment_Questionnaire_Needed__c = 'Yes';
                            Questionnaire__c ques = new Questionnaire__c(
                                Account_Name__c = onboardingProductMap.get(op.id).SAP_Onboarding__r.Account__c,
                                RecordTypeId = String.isNotBlank(recordTypeName) ? Schema.SObjectType.Questionnaire__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId() : null,
                                Onboarding_Product__c = op.id,
                                SAP_Onboarding__c = op.SAP_Onboarding__c,
                                Onboarding_Ship_To__c = op.Onboarding_Ship_To__c
                            );
                            if(ast.Assessment_Document__c == 'Epoxy High-Medium Hazard'){
                                ques.Questionnaire_Setup_Type__c = 'Offline';
                            }
                            if(ast.Assessment_Document__c == 'Epoxy High-Medium Hazard' && op.New_Customer_Ship_Mode__c == 'Truck'){
                                ques.Questionnaire_Setup_Type__c = 'Online';
                            }
                            if(op.Customer_Pickup__c =='Yes' && op.New_Customer_Ship_Mode__c =='Truck' && (op.Purchased_Product__r.Product_R1__r.Family == 'CAPV' || op.Purchased_Product__r.Product_R1__r.Family == 'Epoxy' || op.Purchased_Product__r.Product_R1__r.Family == 'EPOXY'))
                            {
                                system.debug('we do not need any assessment');
                            }
                            else{
                                questList.add(ques);
                            }
                        }
                    }
                    if(ast.Site_Assessment_Needed__c == 'Yes' && op.Customer_Pickup__c == 'No'){
                        op.Is_a_Ship_To_Site_Assessment_Needed__c = 'Yes';
                        siteList.add(new Site_Observation__c (
                            Onboarding_Product__c = op.id,
                            SAP_Onboarding__c = op.SAP_Onboarding__c
                        ));
                    }
                    
                }
                toUpdateList.add(op);
            }
            else if((!prodAssesSelectorMap.containsKey(op.Purchased_Product__r.Product_R1__c) || prodAssesSelectorMap.get(op.Purchased_Product__r.Product_R1__c).size() == 0) && op.New_Customer_Ship_Mode__c == 'Truck' && (op.Purchased_Product__r.Product_R1__r.Family == 'Epoxy' || op.Purchased_Product__r.Product_R1__r.Family == 'EPOXY' )){
                op.Is_a_Shipment_Questionnaire_Needed__c = 'Yes';
                op.Shipment_Questionnaire__c = 'Standard Truck';
                op.Hazard_Category__c = 'Low';
                toUpdateList.add(op);
                Questionnaire__c ques = new Questionnaire__c(
                    Account_Name__c = onboardingProductMap.get(op.id).SAP_Onboarding__r.Account__c,
                    RecordTypeId =  Schema.SObjectType.Questionnaire__c.getRecordTypeInfosByName().get('Standard Truck').getRecordTypeId(),
                    Onboarding_Product__c = op.id,
                    Questionnaire_Setup_Type__c = 'Online',
                    SAP_Onboarding__c = op.SAP_Onboarding__c,
                    Onboarding_Ship_To__c = op.Onboarding_Ship_To__c
                );
                if(op.Customer_Pickup__c =='Yes' && op.New_Customer_Ship_Mode__c =='Truck' && (op.Purchased_Product__r.Product_R1__r.Family == 'CAPV' || op.Purchased_Product__r.Product_R1__r.Family == 'Epoxy' || op.Purchased_Product__r.Product_R1__r.Family == 'EPOXY'))
                {
                    system.debug('we do not need any assessment');
                }
                else{
                    questList.add(ques);
                }
            }
        }
        if(questList.size()>0)
            insert questList; 
        if(siteList.size()>0)
            insert siteList;
        if(toUpdateList.size()>0)
            update toUpdateList;
        if(toUpdateSapList.size() > 0){
            update toUpdateSapList;
        }
        updateCustomerSetup(sapIds);
    }
    
    @future
    public static void updateCustomerSetup(Set<Id> customerSetupIds){
        List<SAP_Onboarding__c> toUpdateCustomerSetup = new List<SAP_Onboarding__c>();
        for(SAP_Onboarding__c sap : [SELECT Id, (SELECT Id FROM Onboarding_Products__r WHERE Hazard_Category__c = 'High' OR Hazard_Category__c = 'Medium') FROM SAP_Onboarding__c WHERE Id IN:customerSetupIds]){
            if(sap.Onboarding_Products__r.size() > 0){
                sap.Product_Stewardship_Reviewed__c = 'Pending';
                sap.Product_Stewardship_Setup_Complete__c = 'Not Started';
            }
            else{
                sap.Product_Stewardship_Reviewed__c = 'N/A';
                sap.Product_Stewardship_Setup_Complete__c = 'N/A';
            }
            toUpdateCustomerSetup.add(sap);
        }
        if(toUpdateCustomerSetup.size() > 0){
            update toUpdateCustomerSetup;
        }
    }
    public static void afterUpdate(List<Onboarding_Product__c> newList, Map<id,Onboarding_Product__c> oldop, Map<id,Onboarding_Product__c> newMap)
    {
        Map<Id, Onboarding_Product__c> onboardingProductMap = new Map<id, Onboarding_Product__c>([SELECT Id, SAP_Onboarding__r.Account__c, SAP_Onboarding__r.Product_Stewardship_Status__c FROM Onboarding_Product__c WHERE Id In: newMap.keyset()]); 
        List<Questionnaire__c> questList = new List<Questionnaire__c>();
        List<Onboarding_Product__c> toUpdateList = new List<Onboarding_Product__c>();
        List<Site_Observation__c> siteList = new  List< Site_Observation__c>();
        Set<Id> onboardingProductIds = new Set<Id>();
        Map<Id, List<Assessment_Selector__c>> prodAssesSelectorMap = new Map<Id, List<Assessment_Selector__c>>();
        for(Assessment_Selector__c ast : [SELECT Id, Product__c, Assessment_Document__c, Ship_Mode__c, Site_Assessment_Needed__c FROM Assessment_Selector__c]){
            if(!prodAssesSelectorMap.containsKey(ast.Product__c)){
                prodAssesSelectorMap.put(ast.Product__c, new List<Assessment_Selector__c>());
            }
            prodAssesSelectorMap.get(ast.Product__c).add(ast);
        }
        for(Onboarding_Product__c op : [SELECT Id,Purchased_Product__c,SAP_Onboarding__c, SAP_Onboarding__r.Product_Stewardship_Status__c, Onboarding_Ship_To__c,Ship_Mode__c, New_Customer_Ship_Mode__c, Customer_Pickup__c,Purchased_Product__r.Product_R1__c,Purchased_Product__r.New_Customer_Ship_Mode__c, Purchased_Product__r.Ship_Mode__c FROM Onboarding_Product__c WHERE Id IN:newMap.keyset()]){
            if(oldop.get(op.Id).Purchased_Product__c != op.Purchased_Product__c && op.Purchased_Product__c != null && prodAssesSelectorMap.containsKey(op.Purchased_Product__r.Product_R1__c) && prodAssesSelectorMap.get(op.Purchased_Product__r.Product_R1__c).size() > 0) 
            {
                for(Assessment_Selector__c ast : prodAssesSelectorMap.get(op.Purchased_Product__r.Product_R1__c)){
                    if(ast.Site_Assessment_Needed__c == 'Yes' && oldop.get(op.Id).Is_a_Ship_To_Site_Assessment_Needed__c != 'Yes' && op.Customer_Pickup__c == 'No'){
                        op.Is_a_Ship_To_Site_Assessment_Needed__c = 'Yes';
                        siteList.add(new Site_Observation__c (
                            Onboarding_Product__c = op.id,
                            SAP_Onboarding__c = op.SAP_Onboarding__c
                        ));
                    }
                    
                }
            }
        }
        if(siteList.size()>0)
            insert siteList;
    }
    
}