global class MapLocationToAccountCallReportBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    global String errorStr = '';

    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, ' + 
                        'Name, ' +
                        'Location_R1__c, ' +
                        'Location_Account__c' +
                        ' FROM FCM_VisitReport__c WHERE isDeleted = False AND Location_R1__c != null';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<FCM_VisitReport__c> scope){

        // Create a list to store Location IDS
        List<Id> locationIds = new LIst<Id>();

        for(FCM_VisitReport__c callReport : scope) {
            locationIds.add(callReport.Location_R1__c);
        }

        List<Account> listOfAccs = [SELECT Id, Location_Record_ID__c FROM Account  WHERE Location_Record_ID__c IN :locationIds];

        Map<Id, Id> mapOfLocationAndAccIds = new Map<Id, Id>();

        for(Account acc : listOfAccs) {
            mapOfLocationAndAccIds.put(acc.Location_Record_ID__c, acc.Id);
        }

        List<FCM_VisitReport__c> callReportsToUpdate = new List<FCM_VisitReport__c>();

        for(FCM_VisitReport__c callReport : scope) {

            if(mapOfLocationAndAccIds.containsKey(callReport.Location_R1__c)) {
                callReport.Location_Account__c = mapOfLocationAndAccIds.get(callReport.Location_R1__c);
                callReportsToUpdate.add(callReport);
            }
            
        }

        Database.SaveResult[] sr = Database.update(callReportsToUpdate, false);
        
        for(Integer i = 0; i < sr.size(); i++) {

            if(!sr[i].isSuccess()) {
                for(Database.Error error : sr[i].getErrors()) {
                    errorStr += callReportsToUpdate[i].Id + ' | ' 
                            + callReportsToUpdate[i].Name 
                            + ' | ' + error.getMessage() + '\n';
                }
            }
        }

    }

    global void finish(Database.BatchableContext BC) {

        //Send an email to the User after your batch completes
        Messaging.SingleEmailMessage mailSend = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'raniel.agno@simplus.com'};
        mailSend.setToAddresses(toAddresses);
        mailSend.setSubject('MapLocationToAccountCallReport Batch Job has been done.');

        String body = 'The batch Apex job has processed. \n Errors: \n' + errorStr;

        mailSend.setPlainTextBody(body);

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mailSend });
        
    }

}