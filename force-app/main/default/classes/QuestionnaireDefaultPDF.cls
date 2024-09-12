public class QuestionnaireDefaultPDF {
    @AuraEnabled
    public static Questionnaire__c getQuestionnaire(String recordId){
       return [SELECT Id, RecordType.Name, Questionnaire_Setup_Type__c FROM Questionnaire__c WHERE Id =:recordId];
    }
}