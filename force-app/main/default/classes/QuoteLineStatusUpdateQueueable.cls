public with sharing class QuoteLineStatusUpdateQueueable implements System.Queueable{
    private List<SBQQ__QuoteLine__c> quoteLinesToUpdate;

    public QuoteLineStatusUpdateQueueable(List<SBQQ__QuoteLine__c> quoteLinesToUpdate) {
        this.quoteLinesToUpdate = quoteLinesToUpdate;
    }

    public void execute(System.QueueableContext context) {
        update quoteLinesToUpdate;
    }
}