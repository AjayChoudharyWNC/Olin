global class AccountConsolidationBatch implements Database.Batchable<sObject>, Database.Stateful {

    global List<AggregateResult> duplicateAccs = new List<AggregateResult>();
 
    global AccountConsolidationBatch() {

        duplicateAccs = [SELECT COUNT(Id), AccountNumber_R1__c 
            FROM Account
            GROUP By AccountNumber_R1__c 
            HAVING COUNT(Id) > 1 AND AccountNumber_R1__c  != null
        ];
        
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {

        List<String> duplicateAccIds = new List<String>();

        for(AggregateResult ag : duplicateAccs) {
            duplicateAccIds.add((String)ag.get('AccountNumber_R1__c'));
        }

        return Database.getQueryLocator([SELECT Id, AccountNumber_R1__c FROM Account 
            WHERE AccountNumber_R1__c IN :duplicateAccIds AND RecordType.Name = 'Customer Location']);

    }

    global void execute(Database.BatchableContext BC, List<Account> locAccs) {

        Map<String, Id> mapOfExternalIdAndLocAccId = new Map<String, Id>();

        for(Account locAcc : locAccs) {
            mapOfExternalIdAndLocAccId.put(locAcc.AccountNumber_R1__c, locAcc.Id);
        } 

        List<Account> customerAccs = [SELECT Id, AccountNumber_R1__c FROM Account
            WHERE AccountNumber_R1__c IN :mapOfExternalIdAndLocAccId.keySet() AND RecordType.Name = 'Customer'
        ];

        Map<Id, Id> mapOfLocIdAndCustomerAccId = new Map<Id, Id>();

        for(Account customerAcc : customerAccs) {
            if (mapOfExternalIdAndLocAccId.containsKey(customerAcc.AccountNumber_R1__c)) {
               mapOfLocIdAndCustomerAccId.put(
                   mapOfExternalIdAndLocAccId.get(customerAcc.AccountNumber_R1__c), 
                   customerAcc.Id
                );

                // Set customer accounts as Ship To
                customerAcc.Ship_To__c = true;
            }
        }

        // Point call reports acc reference from location account to customer acc
        List<FCM_VisitReport__c> callReports = [SELECT Id, FCM_Account__c FROM FCM_VisitReport__c 
            WHERE FCM_Account__c IN :mapOfLocIdAndCustomerAccId.keySet()];

        for(FCM_VisitReport__c callReport : callReports) {
            callReport.FCM_Account__c = mapOfLocIdAndCustomerAccId.get(callReport.FCM_Account__c);
        }

        update callReports;

        // Point competitives acc reference from location account to customer acc
        List<Competitor_R1__c> competitives = [SELECT Id, Customer_Account_Location__c FROM Competitor_R1__c 
            WHERE Customer_Account_Location__c IN :mapOfLocIdAndCustomerAccId.keySet()];

        for(Competitor_R1__c competitve : competitives) {
            competitve.Customer_Account_Location__c = mapOfLocIdAndCustomerAccId.get(competitve.Customer_Account_Location__c);
        }

        update competitives;

        // Delete location accounts
        delete locAccs;

        // Update ship to field for customer accounts 
        update customerAccs;

    }

    global void finish(Database.BatchableContext BC) {

        //Send an email to the User after your batch completes
        Messaging.SingleEmailMessage mailSend = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'raniel.agno@simplus.com'};
        mailSend.setToAddresses(toAddresses);
        mailSend.setSubject('Apex Batch Job has been done.');
        
        String body = 'Done.';

        mailSend.setPlainTextBody(body);
        System.debug(body);

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mailSend });
        
   }

}