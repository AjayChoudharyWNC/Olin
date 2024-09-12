public with sharing class QuoteStatusUpdateQueueable implements System.Queueable{
    private List<SBQQ__Quote__c> quoteToUpdate;

    public QuoteStatusUpdateQueueable(List<SBQQ__Quote__c> quoteToUpdate) {
        this.quoteToUpdate = quoteToUpdate;
    }

    public void execute(System.QueueableContext context) {
        update quoteToUpdate;
    }
}