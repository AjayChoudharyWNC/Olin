public with sharing class QuoteLineApprovalEventTrigger_Handler {
    
    public static void onQuoteLineApprovalEventSave(List<Quote_Line_Approval__e> quoteLineApprovalEvents) {
        Map<String, Set<String>> quoteIdLineMap = new map<String, Set<String>>();
        for(Quote_Line_Approval__e quoteLineApprovalEvent : quoteLineApprovalEvents) {
            if(String.isNotBlank(quoteLineApprovalEvent.Quote_Id__c)){
                if(!quoteIdLineMap.containsKey(quoteLineApprovalEvent.Quote_Id__c)){
                    quoteIdLineMap.put(quoteLineApprovalEvent.Quote_Id__c, new Set<String>(quoteLineApprovalEvent.Quote_Line_Ids__c.split(',')));
                    // List<String> quoteLines = quoteLineApprovalEvent.Quote_Line_Ids__c.split(',');
                    //quoteIdLineMap.get(quoteLineApprovalEvent.Quote_Id__c);
                }
            }
        }
        system.debug('PJ PJ PJ quoteIdLineMap  ');
        if(!quoteIdLineMap.isEmpty() && quoteIdLineMap != NULL){
            for(String qId : quoteIdLineMap.keySet()){
                system.debug('PJ PJ PJ QUOTE ID quoteline Approval');
                submitQuoteContract(qId, quoteIdLineMap.get(qId));
            }
        }  
    }
    
    @future (callout=true)
    public static void submitQuoteContract(Id quoteId, Set<String> quoteLineIds) {
        //Convert Set<String> quoteLineIds to String separated by comma for MulesoftCallout__c
        List<String> quoteLineIdsList = new List<String>(quoteLineIds);
        String quoteLineIdsString = String.join(quoteLineIdsList,',');

        List<String> quoteLineNames = new List<String>();
        List<SBQQ__QuoteLine__c> quoteLines = [SELECT Id, Name, SentToSAP__c FROM SBQQ__QuoteLine__c WHERE Id IN:quoteLineIds];
        for(SBQQ__QuoteLine__c quoteLine : quoteLines) {
            quoteLineNames.add(quoteLine.Name);
        }
        
        Mulesoft_ContractEndpoint__c mc = Mulesoft_ContractEndpoint__c.getOrgDefaults();
        Boolean isSuccess = false;
        SBQQ__Quote__c toUpdateQuote = new SBQQ__Quote__c();

        SBQQ__Quote__c quote = new SBQQ__Quote__c(Id = quoteId);
        if (mc.Enabled__c == false) {
            isSuccess = true;
        }
        else {
            // Mulesoft OAuth - active CNM
            String accessToken = getAccessToken();

            if (accessToken != null) {
                Http h = new Http();
                HttpRequest req = new HttpRequest();
                
                req.setHeader('Authorization', 'Bearer ' + accessToken);
                // req.setHeader('client_id', mc.Client_Id__c);
                // req.setHeader('client_secret', mc.Client_Secret__c);

                req.setEndpoint(mc.Endpoint__c);
                req.setMethod(mc.Operation__c);
                req.setTimeout((Integer)mc.Timeout__c);
                req.setHeader('Accept', 'text/plain');
                req.setHeader('Content-type', 'text/plain');
                //Update body, use the quoteline id string
                req.setBody(quoteLineIdsString);

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
                isSuccess = response.getStatusCode() == 200;
                System.debug('check isSuccess--'+ isSuccess);
                if (!isSuccess) {
                    quote.Mulesoft_Debug__c = response.getStatus();
                    quote.SentToSAP__c = false; 
                    toUpdateQuote = quote;
                }
            } else {
                System.debug('No access token');
            }
            
        }
        SBQQ.TriggerControl.disable();
        if(toUpdateQuote.id != null){
            //update toUpdateQuote; //test - comment mulesoft debug update
        }
        SBQQ.TriggerControl.enable();

        if (isSuccess){
            for(SBQQ__QuoteLine__c quoteLine : quoteLines) {
                quoteLine.SentToSAP__c = true;
            }
        //    quote.SentToSAP__c = true;
            quote.Mulesoft_Debug__c = 'SUCCESS';
        }
        
        // try{
        //     SBQQ.TriggerControl.disable();
        //update quote;
        // }catch (Exception ex) {
        //     throw ex;
        // } 
        // SBQQ.TriggerControl.enable(); //TKT-121
        
       //update quoteLines;
    }

    public static String getAccessToken() {
        Http h = new Http();
        HttpRequest req = new HttpRequest();

        Mulesoft_OAuth_Setting__mdt ms = Mulesoft_OAuth_Setting__mdt.getInstance('CNM_OAuth_Settings');

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