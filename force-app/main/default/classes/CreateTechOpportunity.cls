public class CreateTechOpportunity {
    
    @AuraEnabled
    public static List<PurchasedProduct_R1__c> GetProducts(String accId){
        return [SELECT Id, Name,Product_R1__r.Name,Ship_From__r.Name From PurchasedProduct_R1__c WHERE Account_R1__c =:accid];
    }

    @AuraEnabled
    public static string getRecordTypeId(String recordTypeName){
        try {
            return Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        } catch (Exception e) {
            AuraHandledException ex = new AuraHandledException(e.getMessage());
            ex.setMessage(e.getMessage());
            throw ex;
        }
    }

}