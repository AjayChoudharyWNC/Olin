global class MapLocationToAccountCompetitiveBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    global String errorStr = '';

    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, ' + 
                        'Name, ' +
                        'OriginOfGoods_R1__c, ' +
                        'Competitor_Account_Location__c, ' +
                        'CustomerLocation_R1__c, ' +
                        'Customer_Account_Location__c' +
                        ' FROM Competitor_R1__c WHERE isDeleted = False AND ' +
                        '(OriginOfGoods_R1__c != null OR CustomerLocation_R1__c != null)';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Competitor_R1__c> scope){
        
        List<Id> competitorLocationIds = new List<Id>();
        List<Id> customerLocationIds = new List<Id>();

        for(Competitor_R1__c competitive : scope) {

            if(competitive.OriginOfGoods_R1__c != null) {
                competitorLocationIds.add(competitive.OriginOfGoods_R1__c);
            }
            
            if(competitive.CustomerLocation_R1__c != null) {
                customerLocationIds.add(competitive.CustomerLocation_R1__c);
            }
            
        }

        List<Account> competitorAccs = [SELECT Id, Location_Record_ID__c FROM Account 
                                        WHERE Location_Record_ID__c IN :competitorLocationIds];

        List<Account> customerAccs = [SELECT Id, Location_Record_ID__c FROM Account 
                                        WHERE Location_Record_ID__c IN :customerLocationIds];

        Map<Id, Id> mapOfCompetitorLocAndAccIds = new Map<Id, Id>();
        Map<Id, Id> mapOfCustomerLocAndAccIds = new Map<Id, Id>();

        for(Account acc : competitorAccs) {
            mapOfCompetitorLocAndAccIds.put(acc.Location_Record_ID__c, acc.Id);
        }

        for(Account acc : customerAccs) {
            mapOfCustomerLocAndAccIds.put(acc.Location_Record_ID__c, acc.Id);
        }

        List<Competitor_R1__c> competitivesToUpdate = new List<Competitor_R1__c>();

        for(Competitor_R1__c competitive : scope) {

            if(competitive.OriginOfGoods_R1__c != null) {
                competitive.Competitor_Account_Location__c = mapOfCompetitorLocAndAccIds.get(competitive.OriginOfGoods_R1__c);
            }

            if(competitive.CustomerLocation_R1__c != null) {
                competitive.Customer_Account_Location__c = mapOfCustomerLocAndAccIds.get(competitive.CustomerLocation_R1__c);
            }

            competitivesToUpdate.add(competitive);

        }

        Database.SaveResult[] sr = Database.update(competitivesToUpdate, false);
        
        for(Integer i = 0; i < sr.size(); i++) {

            if(!sr[i].isSuccess()) {
                for(Database.Error error : sr[i].getErrors()) {
                    errorStr += competitivesToUpdate[i].Id + ' | ' 
                            + competitivesToUpdate[i].Name 
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
        mailSend.setSubject('MapLocationToAccountCompetitive Batch Job has been done.');

        String body = 'The batch Apex job has processed. \n Errors: \n' + errorStr;

        mailSend.setPlainTextBody(body);

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mailSend });

    }

}