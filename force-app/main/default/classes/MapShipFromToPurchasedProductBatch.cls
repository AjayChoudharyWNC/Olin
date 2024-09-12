global  class MapShipFromToPurchasedProductBatch implements Database.Batchable<sObject>, Database.Stateful {

    global String errorStr = '';

    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, ' + 
                        'Name, ' +
                        'ShipFrom_R1__c, ' +
                        'ShipTo_R1__c ' + 
                        ' FROM PurchasedProduct_R1__c WHERE isDeleted = False';
                        // AND (ShipFrom_R1__c != null OR ShipTo_R1__c != null)
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<PurchasedProduct_R1__c> scope){

        // Create a list of location ids for ship from and ship to 
        List<Id> shipFromLocIds = new List<Id>();
        List<Id> shipToLocIds = new List<Id>();
        
        for(PurchasedProduct_R1__c purchasedProd : scope) {

            if(purchasedProd.ShipFrom_R1__c != null) {
                shipFromLocIds.add(purchasedProd.ShipFrom_R1__c);
            }
            
            if(purchasedProd.ShipTo_R1__c != null) {
                shipToLocIds.add(purchasedProd.ShipTo_R1__c);
            }
            
        }

        Map<Id, Id> mapOfLocIdandAccIdShipFrom = new Map<Id, Id>();
        Map<Id, Id> mapOfLocIdandAccIdShipTo = new Map<Id, Id>();

        // Query all account that has Location ID of the lookup of ship from
        List<Account> shipFromAccs = [SELECT Id, Location_Record_ID__c FROM Account WHERE Location_Record_ID__c IN :shipFromLocIds];

        for(Account acc : shipFromAccs) {
            mapOfLocIdandAccIdShipFrom.put(acc.Location_Record_ID__c, acc.Id);
        }

        // Query all account that has Location ID of the lookup of ship to
        List<Account> shipToAccs = [SELECT Id, Location_Record_ID__c FROM Account WHERE Location_Record_ID__c IN :shipToLocIds];

        for(Account acc : shipToAccs) {
            mapOfLocIdandAccIdShipTo.put(acc.Location_Record_ID__c, acc.Id);
        }

        List<PurchasedProduct_R1__c> updatePurchasedProds = new List<PurchasedProduct_R1__c>();

        // loop through all purchased product
        for(PurchasedProduct_R1__c purchasedProd : scope) {

            if(purchasedProd.ShipFrom_R1__c != null && mapOfLocIdandAccIdShipFrom.containsKey(purchasedProd.ShipFrom_R1__c)) {
                purchasedProd.Ship_From__c = mapOfLocIdandAccIdShipFrom.get(purchasedProd.ShipFrom_R1__c);
            } else {
                purchasedProd.Ship_From__c = null;
            }

            if(purchasedProd.ShipTo_R1__c != null && mapOfLocIdandAccIdShipTo.containsKey(purchasedProd.ShipTo_R1__c)) {
                purchasedProd.Ship_To__c = mapOfLocIdandAccIdShipTo.get(purchasedProd.ShipTo_R1__c);
            } else {
                purchasedProd.Ship_To__c = null;
            }

            updatePurchasedProds.add(purchasedProd);

        }

        Database.SaveResult[] sr = Database.update(updatePurchasedProds, false);
        
        for(Integer i = 0; i < sr.size(); i++) {

            if(!sr[i].isSuccess()) {
                for(Database.Error error : sr[i].getErrors()) {
                    errorStr += updatePurchasedProds[i].Id + ' | ' 
                            + updatePurchasedProds[i].Name 
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
        mailSend.setSubject('MapShipFromToPurcheasedProduct Batch Job has been done.');

        String body = 'The batch Apex job has processed. \n Errors: \n' + errorStr;

        mailSend.setPlainTextBody(body);

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mailSend });
        
    }

}