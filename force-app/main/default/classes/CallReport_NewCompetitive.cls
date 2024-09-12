public class CallReport_NewCompetitive {
    @AuraEnabled
    public static String fetchRelatedAccount(String recordId){
        String accid = [SELECT  Id,FCM_Account__c,Name FROM  FCM_VisitReport__c WHERE Id  =: recordId].FCM_Account__c;
        return accid;
    }
}