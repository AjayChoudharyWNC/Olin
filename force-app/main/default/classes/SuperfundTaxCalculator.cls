public class SuperfundTaxCalculator {
    
    @AuraEnabled
    public static List<UOM_Conversion__c> fetchUOMList(String productId){
        String prodUOM = [SELECT UOM__c FROM Product2 WHERE Id =:productId].UOM__c;
        List<UOM_Conversion__c> uomList = new List<UOM_Conversion__c>();
        for(UOM_Conversion__c uc : [SELECT Id, Quoted_UOM__c, Conversion_Factor__c,Base_UOM__c FROM UOM_Conversion__c WHERE Product__c =: productId AND Base_UOM__c =:prodUOM]){
            uomList.add(uc);
        }
        return uomList;
    }
    
    @AuraEnabled
    public static Product_Charge__c getProductCharges(String productId){
        List<Product_Charge__c> chargeList = new List<Product_Charge__c>();
        chargeList = [SELECT Id, UOM__c, Charge_Amount__c, Charge_Type__c, Product__c FROM Product_Charge__c WHERE Product__c =:productId AND Charge_Type__c = 'Superfund Excise Tax' LIMIT 1];
        if(chargeList.size() > 0){
            return chargeList[0];
        }
        else{
            return null;
        }
    }
    
    @AuraEnabled
    public static String getProductId(String recordId, String sObjectName, String productApiName){
        try{
            sObject obj = Database.query('SELECT '+productApiName+' FROM '+sObjectName+' WHERE Id=:recordId');
            return (String)obj.get(productApiName);
        }
        catch(exception e){
            system.debug('exception=='+e);
            return null;
        }
    }

}