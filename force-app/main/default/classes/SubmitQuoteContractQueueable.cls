// * Caleld in QuoteTrigger_Handler
public with sharing class SubmitQuoteContractQueueable implements Queueable, Database.AllowsCallouts {

    public Id quoteId;
    public Boolean isVersion1;

    public SubmitQuoteContractQueueable(Id quoteId, Boolean isVersion1) {
        this.quoteId = quoteId;
        this.isVersion1 = isVersion1;
    }

    public void execute(QueueableContext context) {
        system.debug('submitQuoteContract quoteId >>> ' + quoteId);
        String accessToken;
        Mulesoft_ContractEndpoint__c mc = Mulesoft_ContractEndpoint__c.getOrgDefaults();
        Boolean isSuccess = false;
        SBQQ__Quote__c quote = new SBQQ__Quote__c(Id = quoteId);
        system.debug('MC Enabled :::' + mc.Enabled__c);
        if (mc.Enabled__c == false) {
            isSuccess = true;
        }
        else {
            Http h = new Http();
            HttpRequest req = new HttpRequest();

            // Mulesoft OAuth - active CNM
            if (!Test.isRunningTest()){
                accessToken = getAccessToken();
            } else {
                accessToken = 'mocked_access_token';
            }

            if (accessToken != null) {
                req.setHeader('Authorization', 'Bearer ' + accessToken);
            
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
                isSuccess = response.getStatusCode() == 200;
                System.debug('check isSuccess--'+ isSuccess);
                if (!isSuccess) {
                    quote.Mulesoft_Debug__c = response.getStatus();
                    //quote.SentToSAP__c = false;
                }
            } else {
                System.debug('No access token');
            }

            
        }

        if (isSuccess){
            quote.SentToSAP__c = true;
            quote.Mulesoft_Debug__c = 'SUCCESS';
            update quote;
            if(!isVersion1){
				System.enqueueJob(new sendEmailNotificationQueueable(quoteId, mc));
            }
        }
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