public with sharing class sendEmailNotificationQueueable implements Queueable, Database.AllowsCallouts {
    public Id quoteId;
    public Mulesoft_ContractEndpoint__c mc;

    public sendEmailNotificationQueueable(Id quoteId, Mulesoft_ContractEndpoint__c mc){
        this.quoteId = quoteId;
        this.mc = mc;

    }
    public void execute(QueueableContext context) {
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
    }
}