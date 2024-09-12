public class NewAccountSalesOrg {
    @AuraEnabled
    public static String getOrgName(String orgId){
        return [SELECT Name FROM Sales_Organization__c WHERE Id=: orgId].Name;
    }
}