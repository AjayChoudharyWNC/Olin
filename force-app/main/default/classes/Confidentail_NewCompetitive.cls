public class Confidentail_NewCompetitive {
  @AuraEnabled
    public static String fetchRelatedAccount(String recordId){
       String accid = [SELECT  Id,FCM_Account__c,Name FROM  Confidential_Call_Report__c WHERE Id  =: recordId].FCM_Account__c;
        return accid;
    }
}