global class AccountConversionBatch implements Database.Batchable<sObject>, Database.Stateful {

    global String errorStr = '';

    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, ' + 
                        'Name, ' +
                        'RecordType.Name, ' +
                        'CustomerSubtype_R1__c, ' +
                        'Pending_SAP_Customer__c, ' +
                        'Ship_To__c, ' +
                        'Sold_To__c, ' +
                        'ShippingStreet, ' +
                        'ShippingCity, ' +
                        'ShippingPostalCode, ' +
                        'ShippingStateCode, ' +
                        'ShippingCountryCode, ' +
                        'BillingStreet, ' +
                        'BillingCity, ' +
                        'BillingPostalCode, ' +
                        'BillingStateCode, ' +
                        'BillingCountryCode' +
                        ' FROM Account WHERE isDeleted = False AND ' +
                        '(RecordType.Name = \'Standard\' OR RecordType.Name = \'Customer\' OR RecordType.Name = \'Prospect\'' + 
                        ' OR RecordType.Name = \'Corporate\' OR RecordType.Name = \'Pending SAP Customer\')';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> scope) {
        
        RecordType customerRecordType = [SELECT Id FROM RecordType WHERE Name = 'Customer' AND sObjectType = 'Account' LIMIT 1];
        RecordType olinCorpRecordType = [SELECT Id FROM RecordType WHERE Name = 'Olin Corp' AND sObjectType = 'Account' LIMIT 1];

        List<Account> accountsToUpdate = new List<Account>();

        for(Account acc : scope) {

            String recordTypeName = acc.RecordType.Name;

            if(recordTypeName == 'Customer' && acc.CustomerSubtype_R1__c == 'Standard') {
                acc.Sold_To__c = true;
            } else if(recordTypeName == 'Standard') { 

                acc.RecordTypeId = customerRecordType.Id;
                
                if(acc.CustomerSubtype_R1__c == 'Standard') {
                    acc.Sold_To__c = true;
                }

            } else if(recordTypeName == 'Corporate') { 
                acc.RecordTypeId = olinCorpRecordType.Id;
            } else if(recordTypeName == 'Pending SAP Customer') {

                acc.Pending_SAP_Customer__c = true;
                acc.RecordTypeId = customerRecordType.Id;
                recordTypeName = 'Customer';

                if(acc.CustomerSubtype_R1__c == 'Standard') {
                    acc.Sold_To__c = true;
                }
            }

            Boolean hasShippingAddressValue = (acc.ShippingStreet != null || acc.ShippingCity != null || acc.ShippingPostalCode != null ||
                                                acc.ShippingStateCode != null || acc.ShippingCountryCode != null);

            if((recordTypeName == 'Customer' || recordTypeName == 'Prospect') && acc.Ship_To__c && !hasShippingAddressValue) {
                acc.ShippingStreet = acc.BillingStreet;
                acc.ShippingCity = acc.BillingCity;
                acc.ShippingPostalCode = acc.BillingPostalCode;
                acc.ShippingStateCode = acc.BillingStateCode;
                acc.ShippingCountryCode = acc.BillingCountryCode;
            }

            accountsToUpdate.add(acc);

        }

        Database.SaveResult[] sr = Database.update(accountsToUpdate, false);
        
        for(Integer i = 0; i < sr.size(); i++) {

            if(!sr[i].isSuccess()) {
                for(Database.Error error : sr[i].getErrors()) {
                    errorStr += accountsToUpdate[i].Id + ' | ' 
                            + accountsToUpdate[i].Name 
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
        mailSend.setSubject('AccountConversion Batch Job has been done.');

        String body = 'The batch Apex job has processed. \n Errors: \n' + errorStr;

        mailSend.setPlainTextBody(body);

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mailSend });

    }

}