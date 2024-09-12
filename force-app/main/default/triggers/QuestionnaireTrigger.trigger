trigger QuestionnaireTrigger on Questionnaire__c (before insert, after update) {
    
    if(Trigger.isBefore && Trigger.isInsert){
        for(Questionnaire__c ques : Trigger.New)
        {
            ques.Security_Code__c = QuestionnaireTrigger_Handler.genrateRandomNo(); 
        }
    }
}