public class SapOnboardingAttachments {
    
     @AuraEnabled
    public static Boolean getCreditPermission(){
        return FeatureManagement.checkPermission('Customer_Setup_Credit');
    }
	
    static String createQueryString(){
        return 'SELECT Id,ParentId,Parent.Name,Name,Description,CreatedDate FROM Attachment';
    }
    
    public static List<Attachment> getSapOnboardingFiles(String recId){
        return Database.query(createQueryString()+' WHERE ParentId =: recId');
    }
    
    public static List<Attachment> getTaxVatFiles(String recId){
        List<VAT__c> vatList = [SELECT Id FROM VAT__c WHERE SAP_Onboarding__c=: recId];
        if(!vatList.isEmpty()){
            Set<Id> attIDs = new Set<Id>();
            for(VAT__c v: vatList){
                attIDs.add(v.Id);
            }
            return Database.query(createQueryString()+' WHERE ParentId IN: attIDs');
        }
        else{
            return null;
        }
    }    
    
    public static List<Attachment> getProductFiles(String recId){
        List<Onboarding_Product__c> vatList = [SELECT Id FROM Onboarding_Product__c WHERE SAP_Onboarding__c=: recId];
        if(!vatList.isEmpty()){
            Set<Id> attIDs = new Set<Id>();
            for(Onboarding_Product__c v: vatList){
                attIDs.add(v.Id);
            }
            return Database.query(createQueryString()+' WHERE ParentId IN: attIDs');
        }
        else{
            return null;
        }
    }
    
    public static List<Attachment> getAssessmentFiles(String recId){
        List<Questionnaire__c> vatList = [SELECT Id FROM Questionnaire__c WHERE SAP_Onboarding__c=: recId];
        if(!vatList.isEmpty()){
            Set<Id> attIDs = new Set<Id>();
            for(Questionnaire__c v: vatList){
                attIDs.add(v.Id);
            }
            return Database.query(createQueryString()+' WHERE ParentId IN: attIDs');
        }
        else{
            return null;
        }
    }
}