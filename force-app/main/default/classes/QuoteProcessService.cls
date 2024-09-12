public class QuoteProcessService {
    
    @InvocableMethod(label='Submit Quote Contract')
    public static void updateQuoteandSubmit(List<Id> quotes) {
        if(quotes == null || quotes.isEmpty()) return;

        if (System.isBatch() || System.isFuture() || System.isQueueable() || System.isScheduled()) return;
        
        // First, get Quote data by filtering Quote Lines
        List<SBQQ__QuoteLine__c> quoteLines = [ SELECT Id,
                                                    SBQQ__Quote__c,
                                                    SBQQ__Quote__r.SBQQ__Account__c
                                                FROM SBQQ__QuoteLine__c
                                                WHERE SBQQ__Quote__c IN :quotes
                                                    AND Product_Level__c = 'GMID'
                                                    AND SBQQ__Quote__r.SentToSAP__c = false
                                                    AND SBQQ__Quote__r.SBQQ__Status__c = 'Draft Contract'];

        // Use the filtered Quote Line data to get our unique set of Quotes and build a Quote:Account map
        Set<Id> filteredQuotes = new Set<Id>();
        Map<Id, Id> quoteAccountMap = new Map<Id, Id>();
        for(SBQQ__QuoteLine__c ql : quoteLines) {  
            quoteAccountMap.put(ql.SBQQ__Quote__c, ql.SBQQ__Quote__r.SBQQ__Account__c);
            filteredQuotes.add(ql.SBQQ__Quote__c);
        }
        
        // Validate and collect the set of Quotes that use Ship To / Sold To
        Set<Id> validSoldToShipToQuotes = getValidSoldToShipToQuotes(quoteAccountMap);

        // Loop through filtered quotes and check if the Quote is in the valid set
        // Valid quotes are submitted individually to SAP
        // Invalid quotes are updated with an error message
        List<SBQQ__Quote__c> invalidQuotes = new List<SBQQ__Quote__c>();
        for (Id quoteId : filteredQuotes) {
            if (validSoldToShipToQuotes.contains(quoteId)) {
                submitQuoteContract(quoteId);
            }
            else {
                invalidQuotes.add(new SBQQ__Quote__c(Id = quoteId, Mulesoft_Debug__c = 'Quote is not using Ship / Sold to Account'));
            }
        }
        update invalidQuotes;
    }

    @future (callout=true)
    public static void submitQuoteContract(Id quoteId) {
        system.debug('submitQuoteContract quoteId >>> ' + quoteId);

        Mulesoft_ContractEndpoint__c mc = Mulesoft_ContractEndpoint__c.getOrgDefaults();
        if (mc == null || mc.Endpoint__c == null || mc.Enabled__c == false) return;

        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(mc.Endpoint__c);
        req.setMethod(mc.Operation__c);
        req.setTimeout((Integer)mc.Timeout__c);
        req.setHeader('Accept', 'text/plain');
        req.setHeader('Content-type', 'text/plain');
        req.setBody(quoteId);

        DateTime requestStart = DateTime.now();
        HttpResponse response = h.send(req);
        DateTime requestEnd = DateTime.now();
        
        insert new MulesoftCallout__c(
            Quote__c = quoteId,
            Endpoint__c = req.getEndpoint(),
            Method__c = req.getMethod(),
            RequestBody__c = JSON.serialize(req.getBody()),
            RequestTimeout__c = mc.Timeout__c,
            RequestDuration__c = requestEnd.getTime() - requestStart.getTime(),
            ResponseStatus__c = response.getStatus(),
            ResponseStatusCode__c = response.getStatusCode(),
            ResponseBody__c = JSON.serialize(response.getBody())
        );

        SBQQ__Quote__c quote = new SBQQ__Quote__c(Id = quoteId);
        if (response.getStatusCode() == 200) {
            quote.Mulesoft_Debug__c = 'SUCCESS';
            quote.SentToSAP__c = true;
            sendEmailNotifications(quoteId, mc);
        } else {
            quote.Mulesoft_Debug__c = response.getStatus();
            quote.SentToSAP__c = false;
        }
        update quote;
    }

    private static void sendEmailNotifications(Id quoteId, Mulesoft_ContractEndpoint__c mc) {
        //Id recordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get(mc.Contracted_Price_Request_Record_Type__c).getRecordTypeId();
        List<SBQQ__Quote__c> quotes = [SELECT Id, RecordTypeId, SBQQ__SalesRep__c, Price_Request_Version__c FROM SBQQ__Quote__c 
                                        WHERE Id = :quoteId];
                                        
        List<EmailTemplate> e = [SELECT Id FROM EmailTemplate 
                                 WHERE DeveloperName =: mc.Sent_to_SAP_Email_Template__c LIMIT 1];
        
        List<Messaging.singleEmailMessage> mailsToSend = new List<Messaging.SingleEmailMessage>();
        //Update the quotes to the new record type and check the Sent to SAP flag.
        for (SBQQ__Quote__c quote : quotes) {
            //if(e.isEmpty() || quote.Price_Request_Version__c < 2) {
            if(e.isEmpty()) {
                //No email template found or Price Request is version 1
                continue;
            }

            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            //Sales rep field on Quote.
            message.setTargetObjectId(quote.SBQQ__SalesRep__c);
            message.optOutPolicy = 'FILTER';
            message.saveAsActivity = false;
            message.setWhatId(quote.Id);
            message.setTemplateId(e[0].Id);
            mailsToSend.add(message);   
            
        }
        if(!mailsToSend.isEmpty()){
            //sendEmails();
            Messaging.SendEmailResult[] results = messaging.sendEmail(mailsToSend);
            for (Messaging.SendEmailResult result : results) {
                // TODO: Avoid using System.debug in handling email results.
                if (result.success){
                    System.debug('The email was sent successfully.');
                }
                else{
                    System.debug('The email failed to send: '
                                + results[0].errors[0].message);
                }
            }
        }
    }

    private static Set<Id> getValidSoldToShipToQuotes(Map<Id,Id> quoteAccounts) {
        List<Account_Relationships__c> relationships = [SELECT Sold_To__c 
                                                     FROM Account_Relationships__c  
                                                     WHERE Sold_To__c IN: quoteAccounts.values() 
                                                     AND Relationship_Type__c = 'Sold To / Ship To'];
        
        Set<Id> validQuotes = new Set<Id>();
        for(Id quoteId : quoteAccounts.keySet()){
            for(Account_Relationships__c relationship : relationships){
                if(quoteAccounts.get(quoteId) == relationship.Sold_To__c){
                    validQuotes.add(quoteId);
                }
            } 
        }

        return validQuotes;
    }

}