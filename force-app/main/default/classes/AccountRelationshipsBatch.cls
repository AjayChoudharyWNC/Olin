global class AccountRelationshipsBatch  implements Database.Batchable<sObject>, Database.Stateful {

    global String errorStr = '';

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, ' + 
                        'Name, ' +
                        'Location_Record_ID__c' + 
                        ' FROM Account WHERE isDeleted = False AND Location_Record_ID__c != null AND ' +
                        '(RecordType.Name = \'Customer Location\' OR RecordType.Name = \'Prospect Location\'' + 
                        ' OR RecordType.Name = \'Competitor Location\' OR RecordType.Name = \'Olin Location\')';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> scope) {

        List<Id> accLocationIds = new List<Id>();

        for(Account acc : scope) {
            accLocationIds.add(acc.Location_Record_ID__c);
        }

        Map<Id, FCM_Address__c> mapOfLocations = new Map<Id, FCM_Address__c>(
            [Select Id, FCM_Account__c, FCM_Account__r.Name FROM FCM_Address__c WHERE Id IN :accLocationIds]);

        List<Account_Relationships__c> newAccRelationships = new List<Account_Relationships__c>();

        for(Account acc : scope) {

            FCM_Address__c loc = mapOfLocations.get(acc.Location_Record_ID__c);
            String soldToName = loc.FCM_Account__r.Name;
            String shipToName = acc.Name;
            Integer maxSize = 38;

            if(soldToName.length() > maxSize) {
                soldToName = soldToName.abbreviate(maxSize);
            }
            
            if(shipToName.length() > maxSize) {
                shipToName = shipToName.abbreviate(maxSize);
            }

            newAccRelationships.add(
                new Account_Relationships__c(
                    Name = soldToName + ' - ' + shipToName,
                    Sold_To__c = loc.FCM_Account__c,
                    Ship_To__c = acc.Id,
                    Relationship_Type__c = 'Sold To / Ship To'
                )
            );

        }

        Database.SaveResult[] sr = Database.insert(newAccRelationships, false);

        List<Account> dupeAccs = new List<Account>();

        for(Integer i = 0; i < sr.size(); i++) {

            if(!sr[i].isSuccess()) {
                for(Database.Error error : sr[i].getErrors()) {
                    errorStr += newAccRelationships[i].Sold_To__c + ' | ' 
                            + newAccRelationships[i].Ship_To__c 
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
        mailSend.setSubject('AccountRelationships Batch Job has been done.');

        String body = 'The batch Apex job has processed. \n Errors: \n' + errorStr;

        mailSend.setPlainTextBody(body);

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mailSend });

        
    }

}