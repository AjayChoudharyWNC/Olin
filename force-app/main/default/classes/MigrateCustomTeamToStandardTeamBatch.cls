global without sharing class MigrateCustomTeamToStandardTeamBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    global String errorStr = '';

    global Database.QueryLocator start(Database.BatchableContext BC) {

        String query = 'SELECT Id, ' + 
                        'Name, ' +
                        'Account__c, ' +
                        'Account_Owner__c, ' +
                        'Account_Access__c, ' +
                        'Case_Access__c, ' +
                        'Opportunity_Access__c, ' +
                        'Team_Member__c, ' +
                        'Team_Role__c' +
                        ' FROM Team__c WHERE isDeleted = False AND Account_Access__c != \'Removed\' AND Account__c != null';
        return Database.getQueryLocator(query);
        
    }

    global void execute(Database.BatchableContext BC, List<Team__c> teams) {

        List<AccountTeamMember> listOfNewAccTeamMember = new List<AccountTeamMember>();

        for(Team__c team : teams) {

            String accAccess = null;
            String caseAccess = null;
            String oppAccess = null;

            if(team.Account_Owner__c == true) {
                accAccess = 'Edit';
                caseAccess = 'Edit';
                oppAccess = 'Edit';
            }
            
            if(accAccess == null) {
                if(team.Account_Access__c == 'Read/Write') {
                    accAccess = 'Edit';
                } else if(team.Account_Access__c == 'Read Only') {
                    accAccess = 'Read';
                } else if(team.Account_Access__c == 'Private') {
                    //accAccess = 'None';
                    accAccess = 'Read';
                }
            }
            
            if(caseAccess == null) {
                if(team.Case_Access__c == 'Read/Write') {
                    caseAccess = 'Edit';
                } else if(team.Case_Access__c == 'Read Only') {
                    caseAccess = 'Read';
                } else if(team.Case_Access__c == 'Private') {
                    caseAccess = 'None';
                    //caseAccess = 'Read';
                }
            }

            if(oppAccess == null) {
                if(team.Opportunity_Access__c == 'Read/Write') {
                    oppAccess = 'Edit';
                } else if(team.Opportunity_Access__c == 'Read Only') {
                    oppAccess = 'Read';
                } else if(team.Opportunity_Access__c == 'Private') {
                    //oppAccess = 'None';
                    oppAccess = 'Edit';
                }
            }

            listOfNewAccTeamMember.add(new AccountTeamMember(
                AccountId = team.Account__c,
                UserId = team.Team_Member__c,
                AccountAccessLevel = accAccess,
                CaseAccessLevel = caseAccess,
                OpportunityAccessLevel = oppAccess,
                TeamMemberRole = team.Team_Role__c
            ));

        }

        Database.SaveResult[] sr = Database.insert(listOfNewAccTeamMember, false);
        
        for(Integer i = 0; i < sr.size(); i++) {

            if(!sr[i].isSuccess()) {
                for(Database.Error error : sr[i].getErrors()) {
                    System.debug(error.message);
                    errorStr += teams[i].Id + ' | ' 
                            + teams[i].Name 
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
        mailSend.setSubject('Apex Batch Job has been done.');
        
        String body = 'The batch Apex job has processed. \n Errors: \n' + errorStr;

        mailSend.setPlainTextBody(body);

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mailSend });
        
   }

}