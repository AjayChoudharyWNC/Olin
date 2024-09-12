global class ConsumptionFromPurchasedProdBatch implements Database.Batchable<sObject>, Database.Stateful {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, ' + 
                        'Product_R1__c, ' +
                        'Ship_To__c, ' +
                        'AnnualConsumption_R1__c' +
                        ' FROM PurchasedProduct_R1__c WHERE isDeleted = False';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<PurchasedProduct_R1__c> scope) {
        
        List<Total_Consumption__c> listOfNewTotalConsumption = new List<Total_Consumption__c>();

        String currentYear = string.valueOf(System.today().year());
        
        for(PurchasedProduct_R1__c purchasedProd : scope) {
            listOfNewTotalConsumption.add(new Total_Consumption__c(
                Purchased_Product__c = purchasedProd.Id,
                Product__c = purchasedProd.Product_R1__c,
                Ship_To__c = purchasedProd.Ship_To__c,
                Year__c = currentYear,
                UniqueId__c = purchasedProd.Id + currentYear,
                Consumption__c = purchasedProd.AnnualConsumption_R1__c
            ));
        }

        upsert listOfNewTotalConsumption UniqueId__c;

        List<Consumption_Share__c> listOfNewConsumptionShare = new List<Consumption_Share__c>();
        List<Consumption_Share_Account__mdt> listOfConsumptionShareCustomMDT = [SELECT Id, DeveloperName, MasterLabel, Value__c, IsReadOnly__c FROM Consumption_Share_Account__mdt];
        Set<String> checkExisting = new Set<String>();
        for(Consumption_Share__c cs : [SELECT Id, Consumption_ShareOfWallet__c, Seller_Account_SOW__c FROM Consumption_Share__c WHERE Consumption_ShareOfWallet__c IN :listOfNewTotalConsumption]) {
            checkExisting.add(cs.Consumption_ShareOfWallet__c + '' + cs.Seller_Account_SOW__c);
        }
        
        
        for(Total_Consumption__c totalConsumption : listOfNewTotalConsumption) {

            for(Consumption_Share_Account__mdt consumptionShareCustomMDT : listOfConsumptionShareCustomMDT) {
                if(!checkExisting.contains(totalConsumption.Id + '' + consumptionShareCustomMDT.Value__c)) {
                    if(consumptionShareCustomMDT.MasterLabel == 'Olin Account' || consumptionShareCustomMDT.MasterLabel == 'Unknown Account') {
                        listOfNewConsumptionShare.add(new Consumption_Share__c(
                            Consumption_ShareOfWallet__c = totalConsumption.Id,
                            Seller_Account_SOW__c = consumptionShareCustomMDT.Value__c,
                            ReadOnly__c = consumptionShareCustomMDT.IsReadOnly__c
                        ));
                    }
                }
            }

        }

        if(!listOfNewConsumptionShare.isEmpty()) { 
            insert listOfNewConsumptionShare;
        }

    }

    global void finish(Database.BatchableContext BC) {

        //Send an email to the User after your batch completes
        Messaging.SingleEmailMessage mailSend = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'raniel.agno@simplus.com'};
        mailSend.setToAddresses(toAddresses);
        mailSend.setSubject('AccountConversion Batch Job has been done.');

        String body = 'The batch Apex job has processed. ';

        mailSend.setPlainTextBody(body);

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mailSend });

    }

}