public with sharing class QuoteApprovalService {
    
    public static void submit(Set<Id> quoteIds) {
        List<SBQQ__Quote__c> updatedQuotes = new List<SBQQ__Quote__c>();

        SBQQ.TriggerControl.disable();
        for(Id quoteId : quoteIds) {
            updatedQuotes.add(
                new SBQQ__Quote__c(
                    Id = quoteId,
                    SubmitForApproval__c = true
                )
            );
        }
        update updatedQuotes;
        SBQQ.TriggerControl.enable(); //TKT-121
    }

    /*@AuraEnabled
    public static String massApproveReject(List<Id> approvalIds, Boolean doApprove, String comment) {
        MassApproveRejectResponse response = new MassApproveRejectResponse();
        System.debug('entered in massApproveReject from QuoteApprovalService');
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage>();
        Set<Id> setApprovalIds = new Set<Id>(approvalIds);
        String inboundApprovalEmail = sbaa__ApprovalSettings__c.getOrgDefaults().sbaa__InboundApprovalEmailLong__c;
        for (Id approvalId : setApprovalIds) {
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            String whatAction = doApprove ? 'Approved ' : 'Rejected ';
            message.toAddresses = new String[] { inboundApprovalEmail };
            message.optOutPolicy = 'FILTER';
            message.subject = 'mass approve/reject';
            message.setHtmlBody('<html><body>' + whatAction + '<br>' + comment + ' <br> <p>' + approvalId + '</p></body></html>');
            messages.add(message);
        }
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        response.isSuccess = true;
        response.errors = new String[]{};
        response.respMsg = 'test msg';
        for (Messaging.SendEmailResult result : results) {
            if (!result.success) {
                System.debug('The email failed to send: ' + result.errors[0].message);
                response.isSuccess = false;
                response.errors.add('The email failed to send: ' + result.errors[0].message);
            }
        }
        return JSON.serialize(response);
    }*/

    //@future(callout=true) 
    //public static void approveReject(Id approvalId, Boolean doApprove, String comments) {
    public static void approveReject(List<Id> approvalIds, Boolean doApprove, String comments) {
        system.debug('>>>>>>> TEST APPROVAL >>>>>>>'+ approvalIds);
        
        Map<Id, Set<Id>> mQuoteApproval = new Map<Id, Set<Id>>();
        List<sbaa__Approval__c> lApproval = [SELECT Id ,Quote__c, Quote_Line__c FROM sbaa__Approval__c WHERE Id IN :approvalIds];

        for (sbaa__Approval__c ap : lApproval){
            system.debug('>>>>>>> QuoteApproval TEST  >>>>>>>'+ap);
            Id approvalIdtmp = ap.Id;
            if (mQuoteApproval.containsKey(ap.Quote__c)){
                mQuoteApproval.get(ap.Quote__c).add(approvalIdtmp);
            } else {
                Set<Id> lApprovalIdtmp = new Set<Id>();
                lApprovalIdtmp.add(approvalIdtmp);
                mQuoteApproval.put(ap.Quote__c,lApprovalIdtmp);
            }
        }
        if(!Test.isRunningTest()){
        System.enqueueJob(new QueueableQuoteLineApprovals(mQuoteApproval, doApprove, comments));
        }
    }

    public static void waitUntilQuoteUnlocked(Id quoteId) {
        while (Approval.isLocked(quoteId)) {
            // The quote is locked, wait for 5 seconds before checking again
            DateTime start = system.now();
            while(system.now()< start.addseconds(2)){}
        }
    }
    
    public static Boolean isQuoteLocked(Id quoteId) {
        // Check if the quote is locked by another process
        List<RecordType> rt = [SELECT Id, SobjectType, DeveloperName, Name FROM RecordType wHERE sObjectType = 'SBQQ__Quote__c' AND Name = 'Submitted for Approval'];
        List<SBQQ__Quote__c> lockedQuotes = [SELECT Id, isRecordLocked__c FROM SBQQ__Quote__c WHERE Id = :quoteId AND isRecordLocked__c = true AND RecordTypeId =:rt[0].Id];
        if (!lockedQuotes.isEmpty()) {
            return true;
        } else {
            return false;
        }
    }
    
    // @future(callout=true) 
    // public static void submitQuoteLines(List<Id> lApproval) {
    //     System.enqueueJob(new QueueableQuoteLineSubmit(lApproval));
    // }

    private class MassApproveRejectResponse {
        Boolean isSuccess;
        String[] errors;
        String respMsg;
    }

}