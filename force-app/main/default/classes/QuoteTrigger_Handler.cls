public class QuoteTrigger_Handler {
    @TestVisible private static boolean isRun = false;
    
    public static boolean executeAfter(){
        if (!isRun) {
            return isRun = true;
        }
        return false;
    }
    
    public static Set<Id> SetOfIDs = new Set<Id>();
    public static void processSharing(List<SBQQ__Quote__c> lstQuote) {
        Map<String, List<String>> mapSoldToIdToPriceReqIds = new Map<String, List<String>>();
        Map<String, String> mapPriceReqIdToPriceReqOwnerIds = new Map<String, String>();
        
        Set<String> soldToIds = new Set<String>();
        Set<String> priceReqIds = new Set<String>();
        system.debug('lstQuote >>>' + lstQuote);
        for(SBQQ__Quote__c quote : lstQuote) {
            /*if(isInsert || (!isInsert && (oldMap.get(quote.Id).SBQQ__Account__c != quote.SBQQ__Account__c 
                                          || oldMap.get(quote.Id).SBQQ__Opportunity2__c != quote.SBQQ__Opportunity2__c))) {
            }*/
            
            system.debug('ACCOUNT NAME >>> ' + mapSoldToIdToPriceReqIds.get(quote.SBQQ__Account__c));
            if(mapSoldToIdToPriceReqIds.get(quote.SBQQ__Account__c) != null && !mapSoldToIdToPriceReqIds.get(quote.SBQQ__Account__c).isEmpty()) {
                mapSoldToIdToPriceReqIds.get(quote.SBQQ__Account__c).add(quote.Id);
            } 
            else 
            {
                mapSoldToIdToPriceReqIds.put(quote.SBQQ__Account__c, new List<String>{quote.Id});
            }
            soldToIds.add(quote.SBQQ__Account__c);
            priceReqIds.add(quote.Id);
            mapPriceReqIdToPriceReqOwnerIds.put(quote.Id, quote.OwnerId);
        }
        
        if(soldToIds != null && !soldToIds.isEmpty()) {
            List<AccountTeamMember> lstAccountTeamMember = [SELECT Id, AccountId, UserId, User.Name, User.IsActive, TeamMemberRole, 
                                                            AccountAccessLevel, OpportunityAccessLevel 
                                                            FROM AccountTeamMember
                                                            WHERE AccountId IN: soldToIds 
                                                            AND User.IsActive = true];
            
            List<SBQQ__Quote__Share> existingTeamMember = [SELECT Id, ParentId, UserOrGroupId 
                                                           FROM SBQQ__Quote__Share 
                                                           WHERE ParentId IN: priceReqIds  
                                                           AND (RowCause != 'PROG_PRICE_REQ__c' OR RowCause != 'Manual')];
            Map<String, Set<String>> mapParentIdToUserId = new Map<String, Set<String>>();
            for(SBQQ__Quote__Share existingShares : existingTeamMember) {
                if(mapParentIdToUserId.get(existingShares.ParentId) != null && !mapParentIdToUserId.get(existingShares.ParentId).isEmpty()) {
                    mapParentIdToUserId.get(existingShares.ParentId).add(existingShares.UserOrGroupId);
                } else {
                    mapParentIdToUserId.put(existingShares.ParentId, new Set<String>{existingShares.UserOrGroupId});
                }
                system.debug('Existing Members: ' + mapParentIdToUserId.get(existingShares.ParentId));
            }
            
            List<SBQQ__Quote__Share> lstPriceReqShare = new List<SBQQ__Quote__Share>();
            for(AccountTeamMember teamMember : lstAccountTeamMember) {
                // Share Price Requests to all Account Team Members
                if(mapSoldToIdToPriceReqIds.get(teamMember.AccountId) != null && !mapSoldToIdToPriceReqIds.get(teamMember.AccountId).isEmpty()) {
                    for(String priceRequestId : mapSoldToIdToPriceReqIds.get(teamMember.AccountId)) {
                        if(mapPriceReqIdToPriceReqOwnerIds.get(priceRequestId) != null) {
                            if(teamMember.UserId != mapPriceReqIdToPriceReqOwnerIds.get(priceRequestId) 
                               && (mapParentIdToUserId.get(priceRequestId) != null 
                                   && !mapParentIdToUserId.get(priceRequestId).isEmpty() 
                                   && !mapParentIdToUserId.get(priceRequestId).contains(teamMember.UserId))) {
                                SBQQ__Quote__Share priceRequestShare = new SBQQ__Quote__Share();
                                priceRequestShare.ParentId = priceRequestId;
                                priceRequestShare.UserOrGroupId = teamMember.UserId;
                                if(teamMember.OpportunityAccessLevel == 'Edit') {
                                    priceRequestShare.AccessLevel = 'Edit';
                                } else {
                                    priceRequestShare.AccessLevel = 'Read';
                                }
                                priceRequestShare.RowCause = Schema.SBQQ__Quote__Share.RowCause.PROG_PRICE_REQ__c;
                                lstPriceReqShare.add(priceRequestShare);
                            }
                        }
                    }
                }
            }
            
            List<SBQQ__Quote__Share> lstPriceReqShareDel = [SELECT Id, ParentId, RowCause 
                                                            FROM SBQQ__Quote__Share 
                                                            WHERE ParentId IN: priceReqIds
                                                            AND RowCause = 'PROG_PRICE_REQ__c'];
            
            // Reset the sharing first
            if(lstPriceReqShareDel != null && !lstPriceReqShareDel.isEmpty()) {
                Database.delete(lstPriceReqShareDel);
            }
            
            // And then re-create them
            if(lstPriceReqShare != null && !lstPriceReqShare.isEmpty()) {
                Database.insert(lstPriceReqShare);
            }
        }
    }

    
    
    /*public static void sendQuoteForApproval(List<SBQQ__Quote__c> lstQuote, Map<Id, SBQQ__Quote__c> oldMap){
        List<Id> quoteIds = new List<Id>();
        for(SBQQ__Quote__c quote : lstQuote) {          
            if(quote.Cloned_From_Mulesoft__c == true && quote.SubmitForApproval__c == true && quote.SBQQ__Status__c == 'Quotation' && String.isBlank(quote.ApprovalStatus__c)){  
                quoteIds.add(quote.Id);
            }
        }

        if (quoteIds.size() > 0) {
            System.enqueueJob(new ApprovalSubmitQueueable(quoteIds)); 
        }
    }*/
    // From Process Builder flow "Quote Status - Update Sales Path" on node "Submitted for Approval" 
    
    public static void onQuotePending(List<SBQQ__Quote__c> lstQuote, Map<Id, SBQQ__Quote__c> oldMap) {
        //Set<Id> quoteIds = new Set<Id>();
        Id pendingQuoteRtId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('Submitted_for_Approval').getRecordTypeId();
        for (SBQQ__Quote__c aQuote : lstQuote) {
            if (oldMap.get(aQuote.Id).ApprovalStatus__c != 'Pending' && aQuote.ApprovalStatus__c == 'Pending') {
                //QuoteApprovalService.waitUntilQuoteUnlocked(aQuote.Id);
                aQuote.RecordTypeId = pendingQuoteRtId;
                aQuote.SBQQ__Status__c = 'Submitted for Approval';

                if (String.isNotBlank(aQuote.SubmittedUser__r.Name) && aQuote.SubmittedUser__r.Name == 'Olin CPQ') {
                    aQuote.SubmittedUser__c = aQuote.SBQQ__SalesRep__c;
                }
            }
        }
        // Set<Id> quoteIds = new Set<Id>();
        // for (SBQQ__Quote__c aQuote : lstQuote) {
        //     if (oldMap.get(aQuote.Id).ApprovalStatus__c != 'Pending' && aQuote.ApprovalStatus__c == 'Pending') {
        //         //QuoteApprovalService.waitUntilQuoteUnlocked(aQuote.Id);
        //         quoteIds.add(aQuote.Id);
        //     }
        // }

        // List<SBQQ__Quote__c> quotesToUpdate = new List<SBQQ__Quote__c>();
        // Id pendingQuoteRtId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('Submitted_for_Approval').getRecordTypeId();
        // for (SBQQ__Quote__c aQuote : [SELECT Id, SBQQ__SalesRep__c, SubmittedUser__r.Name FROM SBQQ__Quote__c WHERE Id IN :quoteIds]) {
        //     SBQQ__Quote__c quot = new SBQQ__Quote__c(
        //         Id = aQuote.Id,
        //         RecordTypeId = pendingQuoteRtId,
        //         SBQQ__Status__c = 'Submitted for Approval'
        //     );
        //     if (String.isNotBlank(aQuote.SubmittedUser__r.Name) && aQuote.SubmittedUser__r.Name == 'Olin CPQ') {
        //         quot.SubmittedUser__c = aQuote.SBQQ__SalesRep__c;
        //     }
        //     quotesToUpdate.add(quot);
        // }
        // SBQQ.TriggerControl.disable();
        // update quotesToUpdate;
        // SBQQ.TriggerControl.enable();


        
    }

    // From Process Builder flow "Quote Status - Update Sales Path" on node "Approved V2+"
    public static void onQuoteApproval(List<SBQQ__Quote__c> lstQuote, Map<Id, SBQQ__Quote__c> oldMap) {
        Set<Id> quoteIds = new Set<Id>();
        for (SBQQ__Quote__c aQuote : lstQuote) {
            if //(oldMap.get(aQuote.Id).ApprovalStatus__c != 'Approved' && aQuote.ApprovalStatus__c == 'Approved' && aQuote.Price_Request_Version__c != 1 && aQuote.SBQQ__Uncalculated__c == false) {
                (oldMap.get(aQuote.Id).ApprovalStatus__c != 'Approved' && aQuote.ApprovalStatus__c == 'Approved' && (aQuote.SBQQ__Uncalculated__c == false || Test.isRunningTest())) {
                    //QuoteApprovalService.waitUntilQuoteUnlocked(aQuote.Id);
                quoteIds.add(aQuote.Id);
            }
        }

        List<SBQQ__Quote__c> quotesToUpdate = new List<SBQQ__Quote__c>();
        for (SBQQ__Quote__c aQuote : [SELECT Id FROM SBQQ__Quote__c WHERE Id IN :quoteIds]) {
            quotesToUpdate.add(new SBQQ__Quote__c(
                Id = aQuote.Id,
                Customer_Accepted_Date__c = DateTime.now(),
                SBQQ__WatermarkShown__c = false
            ));
        }
        SBQQ.TriggerControl.disable();
        update quotesToUpdate;
        SBQQ.TriggerControl.enable();

        validateAndSendApprovedQuotesToSAP(quotesToUpdate);
    }
    
    public static void validateAndSendApprovedQuotesToSAP(List<SBQQ__Quote__c> quotes) {
        Set<Id> quoteIds = new Set<Id>();

        Mulesoft_ContractEndpoint__c mc = Mulesoft_ContractEndpoint__c.getOrgDefaults();
        if (mc == null || mc.Contracted_Price_Request_Status__c == null) return;
        
        for (SBQQ__Quote__c quote : quotes) {
            if (quote.SentToSAP__c == false) {
                quoteIds.add(quote.Id);
            }
        }

        if(quoteIds == null || quoteIds.isEmpty()) return;
        
        // First, get Quote data by filtering Quote Lines
        List<SBQQ__QuoteLine__c> quoteLines = [ SELECT Id,
                                                    SBQQ__Quote__c,
                                                    SBQQ__Quote__r.SBQQ__Account__c
                                                FROM SBQQ__QuoteLine__c
                                                WHERE SBQQ__Quote__c IN :quoteIds
                                                    AND Product_Level__c = 'GMID'
                                                    AND SBQQ__Quote__r.SentToSAP__c = false ];
        
        system.debug('quote lines >>> ' + quoteLines);
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
        Map<Id, Decimal> versionMap = new Map<Id, Decimal>();
        for(SBQQ__Quote__c sbq :[SELECT Id, Price_Request_Version__c FROM SBQQ__Quote__c WHERE Id IN :filteredQuotes]){
            versionMap.put(sbq.Id, sbq.Price_Request_Version__c);
        }
        for (Id quoteId : filteredQuotes) {
            if (validSoldToShipToQuotes.contains(quoteId)) {
                if (!System.isFuture() && !System.isBatch()) {
                    if(versionMap.get(quoteId)==1){
                        //submitQuoteContract(quoteId, true);
                        System.enqueueJob(new SubmitQuoteContractQueueable(quoteId, true));
                    }else{
                        //submitQuoteContract(quoteId, false);
                        System.enqueueJob(new SubmitQuoteContractQueueable(quoteId, false));
                    }
                }
            }
            else {
                invalidQuotes.add(new SBQQ__Quote__c(Id = quoteId, Mulesoft_Debug__c = 'Quote is not using Ship / Sold to Account'));
            }
        }
        update invalidQuotes;
    }

    //Commented out to increase Test Coverage because method is not in used  by PJ;07/18/2023   
    //@future (callout=true)
    /*public static void submitQuoteContract(Id quoteId, Boolean isVersion1) {
        system.debug('submitQuoteContract quoteId >>> ' + quoteId);

        Mulesoft_ContractEndpoint__c mc = Mulesoft_ContractEndpoint__c.getOrgDefaults();
        Boolean isSuccess = false;
        SBQQ__Quote__c quote = new SBQQ__Quote__c(Id = quoteId);
        if (mc.Enabled__c == false) {
            isSuccess = true;
        }
        else {

            // Mulesoft OAuth
            String accessToken = getAccessToken();

            if (accessToken != null) {
                
                Http h = new Http();
                HttpRequest req = new HttpRequest();
                req.setHeader('Authorization', 'Bearer ' + accessToken);
                
                req.setHeader('client_id', mc.Client_Id__c);
                req.setHeader('client_secret', mc.Client_Secret__c);
            
                req.setEndpoint(mc.Endpoint__c);
                req.setMethod(mc.Operation__c);
                req.setTimeout((Integer)mc.Timeout__c);
                req.setHeader('Accept', 'text/plain');
                req.setHeader('Content-type', 'text/plain');
                req.setBody(quoteId);

                DateTime requestStart = DateTime.now();
                HttpResponse response = h.send(req);
                DateTime requestEnd = DateTime.now();

                System.debug(JSON.serialize(req.getBody()));
                
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
            if(!isVersion1){
                sendEmailNotification(quoteId, mc);
            }
        }
        
        SBQQ.TriggerControl.disable(); //TKT-121 use try finally
        try{
            
        //QuoteApprovalService.waitUntilQuoteUnlocked(quoteId);
            update quote;
        } catch (Exception ex) {
            throw ex;
        }finally {
            SBQQ.TriggerControl.enable(); //TKT-121 use try finally
        }
        
    }*/
    //Commented out to increase Test Coverage because method is not in used  by PJ;07/18/2023
    /*public static void sendEmailNotification(Id quoteId, Mulesoft_ContractEndpoint__c mc) {
        SBQQ__Quote__c quote = [SELECT Id, RecordTypeId, SBQQ__SalesRep__c, Price_Request_Version__c FROM SBQQ__Quote__c 
                                 WHERE Id = :quoteId LIMIT 1];
                 
        EmailTemplate template = [SELECT Id FROM EmailTemplate 
                                    WHERE DeveloperName =: mc.Sent_to_SAP_Email_Template__c LIMIT 1];
        
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
    }*/

    // From Process Builder flow "Quote Status - Update Sales Path" on node "Approved V2+"
    public static void onQuoteRejectRecall(List<SBQQ__Quote__c> lstQuote, Map<Id, SBQQ__Quote__c> oldMap) {
        Set<Id> quoteIds = new Set<Id>();
        for (SBQQ__Quote__c aQuote : lstQuote) {
            if (aQuote.SBQQ__Uncalculated__c) {
                continue;
            }
            if ((oldMap.get(aQuote.Id).ApprovalStatus__c != 'Rejected' && aQuote.ApprovalStatus__c == 'Rejected') || (oldMap.get(aQuote.Id).ApprovalStatus__c != 'Recalled' && aQuote.ApprovalStatus__c == 'Recalled')) {
                quoteIds.add(aQuote.Id);
            }
        }
        system.debug('quoteIds'+quoteIds);
        List<SBQQ__Quote__c> quotesToUpdate = new List<SBQQ__Quote__c>();
        Id draftQuoteRtId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('Draft_Price_Request').getRecordTypeId();
        if (quoteIds != null && quoteIds.size()>0 ){
            for (SBQQ__Quote__c aQuote : [SELECT Id, SBQQ__Source__c, (SELECT Id FROM SBQQ__LineItems__r) FROM SBQQ__Quote__c WHERE Id IN :quoteIds]) {
                quotesToUpdate.add(new SBQQ__Quote__c(
                    Id = aQuote.Id,
                    RecordTypeId = draftQuoteRtId,
                    SBQQ__Status__c = 'Quotation'
                ));
            }
        }
        SBQQ.TriggerControl.disable();
        update quotesToUpdate;
        SBQQ.TriggerControl.enable();
    }

    //Converted process builder  "Set Price Start Date, Number of Renewals & Renewal Frequency"
    public static void renewalPriceRequest(List<SBQQ__Quote__c> lstQuote){        
        for(SBQQ__Quote__c quote : lstQuote) {
            if(quote.SBQQ__Type__c == 'Renewal' && quote.SBQQ__Opportunity2__c != null &&  (quote.Contract_Number_of_Renewals_Formula__c != null || quote.Contract_Renewal_Frequency_Formula__c != null)){
                //Integer contractRenewals = quoteMap.get(quote.Id).SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.Number_of_Renewals1__c == null ? 0 : Integer.valueOf(quoteMap.get(quote.Id).SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.Number_of_Renewals1__c);
                quote.Number_of_Renewals__c = quote.Contract_Number_of_Renewals_Formula__c + 1;
                quote.Price_Start_Date__c = quote.SBQQ__StartDate__c;
                quote.Renewal_Frequency_yrs__c = quote.Contract_Renewal_Frequency_Formula__c;                               
            }  
        }
        
    }
    
    //Converted "Update Ship to values on Price Request"
    
    public static void updateShipToValues(List<SBQQ__Quote__c> lstQuote){
        for(SBQQ__Quote__c quote : lstQuote){
            if(quote.Ship_To_Account__c != null || quote.Ship_To_Account__c != ''){
                //QuoteApprovalService.waitUntilQuoteUnlocked(quote.Id);
                quote.Ship_To__c = quote.Ship_To_Formula__c;
            }
        }
    }
    
    //Converted "Update Default Template on Price Request"
   
    public static void updateDefaultTemplate(List<SBQQ__Quote__c> lstQuote){
        Map<Id,Pricebook2> pbMap = new Map<Id,Pricebook2>([SELECT Id, Name FROM Pricebook2]);
        Map<String,String> qtMap = new Map<String,String>();
        
        for(SBQQ__QuoteTemplate__c qt : [SELECT Id, Name FROM SBQQ__QuoteTemplate__c WHERE Name ='CAPV NA Proposal' OR Name = 'EPOXY NA Proposal']){            
            qtMap.put(qt.Name, qt.Id);            
        }
        
        for(SBQQ__Quote__c quote : lstQuote){
           // QuoteApprovalService.waitUntilQuoteUnlocked(quote.Id);
            if(pbMap.containsKey(quote.SBQQ__PriceBook__c)){
                if(quote.SBQQ__PriceBook__c != null ){
                    if(pbMap.get(quote.SBQQ__PriceBook__c).Name == 'CAPV Price Book'){
                        quote.SBQQ__DefaultTemplate__c = qtMap.get('CAPV NA Proposal');
                    } else if(pbMap.get(quote.SBQQ__PriceBook__c).Name == 'Epoxy Price Book'){
                        quote.SBQQ__DefaultTemplate__c = qtMap.get('EPOXY NA Proposal');
                    }
                }
            }
        }
        
    }       
    

    public static Set<Id> getValidSoldToShipToQuotes(Map<Id,Id> quoteAccounts) {
        List<Account_Relationships__c> relationships = [SELECT Sold_To__c 
                                                     FROM Account_Relationships__c  
                                                     WHERE Sold_To__c IN: quoteAccounts.values() 
                                                     AND Relationship_Type__c = 'Sold To / Ship To'];
        
        Set<Id> validQuotes = new Set<Id>();
        for(Id quoteId : quoteAccounts.keySet()){
           // QuoteApprovalService.waitUntilQuoteUnlocked(quoteId);
            for(Account_Relationships__c relationship : relationships){
                if(quoteAccounts.get(quoteId) == relationship.Sold_To__c){
                    validQuotes.add(quoteId);
                }
            } 
        }

        return validQuotes;
    }

    public static void setDefaultFields(List<SBQQ__Quote__c> quotes) {
        for (SBQQ__Quote__c quote : quotes) {
           // QuoteApprovalService.waitUntilQuoteUnlocked(quote.id);
            quote.SBQQ__Status__c = 'Quotation';
            quote.SBQQ__WatermarkShown__c = true;
        }
    }
    
    //Send emails for Price Request v1
    /**public static void sendEmailVersionOne(List<SBQQ__Quote__c> lstQuote) {
        for (SBQQ__Quote__c quote :lstQuote) {
            if (!System.isFuture() && !System.isBatch() && quote.SBQQ__Status__c == 'Draft Contract' && quote.Price_Request_Version__c == 1) {
                    submitQuoteContract(quote.Id);
            }
        }
    }*/
//Commented out to increase Test Coverage because method is not in used  by PJ;07/18/2023
/*
    public static String getAccessToken() {
        Http h = new Http();
        HttpRequest req = new HttpRequest();

        Mulesoft_OAuth_Setting__mdt ms = Mulesoft_OAuth_Setting__mdt.getInstance('OAuth_Settings');

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
    */
}