public with sharing class QuoteLineWonQueueable implements Queueable, Database.AllowsCallouts {
    Map<Id,Set<Id>> quoteLinesByQuoteIdMap = new Map<Id,Set<Id>>();
    Set<Id> quotesComplete = new Set<Id>();
    Set<Id> quoteLinesCompleted = new Set<Id>();

    public QuoteLineWonQueueable(Map<Id,Set<Id>> quoteLinesByQuoteId) {
        quoteLinesByQuoteIdMap = quoteLinesByQuoteId;
    }

    public QuoteLineWonQueueable(Map<Id,Set<Id>> quoteLinesByQuoteId, Set<Id> qlCompleted,
    Set<Id> qCompleted) {
        quoteLinesByQuoteIdMap = quoteLinesByQuoteId;
        quoteLinesCompleted = qlCompleted;
        quotesComplete = qCompleted;
    }


    public void execute(QueueableContext context) {
        Id quoteId = getNextQuoteIdToProcessFromKeyset();
    
        if (quoteId != null) {
            List<String> quoteLineNames = new List<String>();
            Set<Id> quoteLineIds = quoteLinesByQuoteIdMap.get(quoteId);
            system.debug('QuoteLineWonQueueable   line 23 quoteLineIds  ::   '  +quoteLineIds);
            // We've retrieved all of this Map row, remove it so we can continue to pass this map along for further processing
            quoteLinesByQuoteIdMap.remove(quoteId);
            // Marc T (Simplus) - Refactored this to include the Child Quote Lines
            List<SBQQ__QuoteLine__c> allQuoteLines = [SELECT Id, Name, SentToSAP__c, Status__c, SBQQ__RequiredBy__c
                FROM SBQQ__QuoteLine__c 
                WHERE (Id IN :quoteLineIds) OR
                (SBQQ__RequiredBy__c IN :quoteLineIds
                AND SBQQ__Quote__c = :quoteId)];
                
            Set<Id> quoteLineIdSet = new Set<Id>();
            List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
            List<SBQQ__QuoteLine__c> childQuoteLines = new List<SBQQ__QuoteLine__c>();
            List<SBQQ__QuoteLine__c> quoteLinesToUpdate = new List<SBQQ__QuoteLine__c>();
            for(SBQQ__QuoteLine__c quoteLine : allQuoteLines) {
                if (quoteLine.SBQQ__RequiredBy__c != null) {
                    childQuoteLines.add(quoteLine);
                    
                }
                else {

                    quoteLineIdSet.add(quoteLine.Id);
                    quoteLines.add(quoteLine);
                }
                quoteLineNames.add(quoteLine.Name);
            }

            List<Id> quoteLineIdList = new List<Id> (quoteLineIdSet);
            String quotelineIdsString = String.join(quoteLineIdList,',');
            Integration_Endpoint__mdt mc = Integration_Endpoint__mdt.getInstance('Mulesoft_Pricing');
            Boolean isSuccess = false;
            SBQQ__Quote__c quote = new SBQQ__Quote__c(Id = quoteId);
            String accessToken = '';
            if (mc.Enabled__c == false) {
                isSuccess = true;
            } 
            else {
                
                // Mulesoft OAuth - active PC
                if (!Test.isRunningTest()){
                    accessToken = getAccessToken();
                } else {
                    accessToken = 'mocked_access_token';
                }

                if (accessToken != null) {
                    
                    Http h = new Http();
                    HttpRequest req = new HttpRequest();
                    req.setHeader('Authorization', 'Bearer ' + accessToken);
                    // req.setHeader('client_id', mc.Client_Id__c);
                    // req.setHeader('client_secret', mc.Client_Secret__c);

                    //Mulesoft Additional Auth
                    // String username = mc.username__c;
                    // String password = mc.password__c;

                    // Blob headerValue = Blob.valueOf(username+':'+password);
                    // String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
                    // req.setHeader('Authorization', authorizationHeader);
                    
                    req.setEndpoint(mc.Endpoint__c);
                    req.setMethod(mc.Operation__c);
                    req.setTimeout((Integer)mc.Timeout__c);
                    req.setHeader('Accept', 'text/plain');
                    req.setHeader('Content-type', 'text/plain');
                    req.setBody(quotelineIdsString);

                    DateTime requestStart = DateTime.now();
                    HttpResponse response = h.send(req);
                    DateTime requestEnd = DateTime.now();
                    
                    insert new MulesoftCallout__c(
                        Quote__c = quoteId,
                        QuoteLines__c = String.join(quoteLineNames, ';'),
                        Endpoint__c = req.getEndpoint(),
                        Method__c = req.getMethod(),
                        RequestBody__c = JSON.serialize(req.getBody()),
                        RequestTimeout__c = mc.Timeout__c,
                        RequestDuration__c = requestEnd.getTime() - requestStart.getTime(),
                        ResponseStatus__c = response.getStatus(),
                        ResponseStatusCode__c = response.getStatusCode(),
                        ResponseBody__c = JSON.serialize(response.getBody())
                    );
                    System.debug('response-'+response);
                    
                    isSuccess = response.getStatusCode() == 200;
                    System.debug('QuoteLineWonQueueable check isSuccess--'+ isSuccess);
                } else {
                    System.debug('No Acces Token');
                }
                
            }
            
            if (isSuccess){
                for(SBQQ__QuoteLine__c quoteLine : quoteLines) {
                   // if (quoteLine.Status__c == 'Won')
                   // {
                        quoteLinesCompleted.add(quoteLine.id);
                   // }
                }
                // Marc T (Simplus) - Should only be populated if it has a parent Quote Line via RequiredBy
                for(SBQQ__QuoteLine__c childQuoteLine : childQuoteLines) {
                   // if (childQuoteLine.Status__c == 'Won')
                   // {
                        quoteLinesCompleted.add(childQuoteLine.id);
                   // }
                }
                // Marc T (Simplus) - Commented out for Epoxy, will Revisit for the future
                //sendEmailNotification(quoteId);

                /*quote.SentToSAP__c = true;
                //quote.Mulesoft_Debug__c = 'SUCCESS';
                quotesComplete.add(quote.Id);*/
            }

            //quoteLinesCompleted.addAll(quoteLinesToUpdate);
            if (Test.isRunningTest()) {
                QuoteLineWonQueueable.doUpdate(quoteLinesCompleted, quotesComplete);
            } else {
                System.enqueueJob(new QuoteLineWonQueueable(quoteLinesByQuoteIdMap, quoteLinesCompleted, quotesComplete));
            }
			
        }
        else {
            // We're done processing quotes, do the updates.
            QuoteLineWonQueueable.doUpdate(quoteLinesCompleted, quotesComplete);
        }
    }

    private Id getNextQuoteIdToProcessFromKeyset() {
        Id idToReturn;

        if (!quoteLinesByQuoteIdMap.isEmpty()) {
            List<Id> idList = new List<Id>();
            idList.addAll(quoteLinesByQuoteIdMap.keySet());
            idToReturn = idList.get(0);
        }

        return idToReturn;
    }

    @future (callout=true)
    private static void doUpdate(Set<Id> qlCompl, Set<Id> qCompl) {
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        for (SBQQ__QuoteLine__c ql : [SELECT Id, Status__c,  ApprovalStatus__c, SentToSAP__c, Name FROM SBQQ__QuoteLine__c WHERE Id IN :qlCompl]) {
            ql.SentToSAP__c = true;
            ql.Status__c = 'Won';
            ql.ApprovalStatus__c = 'Approved';
            quoteLines.add(ql);
        }
        // Marc T (Simplus) - Prevent Nested Events by disabling the Quote Line Trigger Handler before the update
       // QuoteLineTrigger_Handler.runOnceAfter();
        //update qCompl;
        
        update quoteLines;
        

    }

    /*
    private void sendEmailNotification(Id quoteId) {
        Mulesoft_ContractEndpoint__c mc = Mulesoft_ContractEndpoint__c.getOrgDefaults();
        SBQQ__Quote__c quote = [SELECT Id, RecordTypeId, SBQQ__SalesRep__c, Price_Request_Version__c FROM SBQQ__Quote__c 
            WHERE Id = :quoteId LIMIT 1];
              
        EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE DeveloperName =: mc.Sent_to_SAP_Email_Template__c LIMIT 1];
        
        List<Messaging.singleEmailMessage> mailsToSend = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setTargetObjectId(quote.SBQQ__SalesRep__c);
        message.optOutPolicy = 'FILTER';
        message.saveAsActivity = false;
        message.setWhatId(quote.Id);
        message.setTemplateId(template.Id);
        mailsToSend.add(message);

        if(!mailsToSend.isEmpty()){
            Messaging.SendEmailResult[] results = messaging.sendEmail(mailsToSend);
            for (Messaging.SendEmailResult result : results) {
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
    */

    public static String getAccessToken() {
        Http h = new Http();
        HttpRequest req = new HttpRequest();

        Mulesoft_OAuth_Setting__mdt ms = Mulesoft_OAuth_Setting__mdt.getInstance('Pricing_Condition_OAuth_Settings');

        req.setEndpoint(ms.Endpoint__c);
        req.setMethod(ms.Method__c);
        req.setHeader('Content-Type', ms.Content_Type__c);

        // Set the request body with the required parameters
        String requestBody = 'grant_type=' + ms.Grant_Type__c
            + '&client_id=' + ms.Client_Id__c
            + '&client_secret=' + ms.Client_Secret__c
            + '&scope=' + ms.Scope__c;

        req.setBody(requestBody);

        HttpResponse response = h.send(req);

        // Parse the response to obtain the access token
        if (response.getStatusCode() == 200) {
            Map<String, Object> tokenResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            String accessToken = (String) tokenResponse.get('access_token');
            return accessToken;
        } else {
            // Handle error response
            System.debug('Error: ' + response.getStatusCode() + ' ' + response.getStatus());
            System.debug('Response Body: ' + response.getBody());
            return null;
        }
    }
}