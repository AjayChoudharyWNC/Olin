public class CreditApplicationPDFController {
    
    public String sapId {get;set;}
    Public List<VAT__c> vatList {get;set;}
    Public List<Attachment> bankRefFiles{get;set;}
    Public List<Attachment> tradeRefFiles{get;set;}
    Public SAP_Onboarding__c sapRecord {get;set;}
    Public List<Onboarding_Product__c> prodList {get;set;}
    
    public CreditApplicationPDFController(ApexPages.StandardController sc){
        sapId = sc.getId();
        vatList = new List<VAT__c>();
        prodList = new List<Onboarding_Product__c>();
        bankRefFiles = new List<Attachment>();
        tradeRefFiles = new List<Attachment>();
        sapRecord = new SAP_Onboarding__c();
        Set<String> allFields = fields(sapRecord.getSobjectType());
        String query = 'SELECT ';
        for(String fieldName : allFields){
            query += fieldName+','; 
        }
        query = query.removeEnd(',');
        query += ' FROM SAP_Onboarding__c WHERE Id =:sapId';
        sapRecord = Database.query(query);
        vatList = [SELECT Id, Name, Country__c, Tax_Type__c, Tax_Type_Code__c, Tax_VAT1_Exempt__c, VAT_Tax_Number__c FROM VAT__c WHERE SAP_Onboarding__c =:sapId];
        prodList = [SELECT Id, Name, Purchased_Product__r.Product_R1__r.Name, Purchased_Product__r.Product_R1__r.Business_Group__c, Ship_Mode__c, Volume_Period__c, Estimated_Volume__c,New_Customer_Ship_Mode__c FROM Onboarding_Product__c WHERE SAP_Onboarding__c =:sapId];
        bankRefFiles = [SELECT Id, Name FROM Attachment WHERE ParentId =:sapId AND Description LIKE :'%bankReferenceFile%'];
        tradeRefFiles = [SELECT Id, Name FROM Attachment WHERE ParentId =:sapId AND Description LIKE :'%tradeReferenceFile%'];
    }
    
    private static Set<String> fields(Schema.sObjectType t) {
        Set<String> resultFields = new Set<String>();
        Map<String, Schema.SObjectField> fields = t.getDescribe().fields.getMap();
        for(String fieldName : fields.keySet()){
            Schema.SObjectField field = fields.get(fieldName);
            if(field.getDescribe().isAccessible()){
                resultFields.add(fieldName);
            }
        }
        return resultFields;
    }
}