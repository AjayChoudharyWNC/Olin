public with sharing class QuoteExtController {
    private Id quoteId;
    public QuoteExtController(ApexPages.StandardController stdController) {
        quoteId = stdController.getId();
    }
    public PageReference onSubmit() {
        if (quoteId != null) {
            SBQQ.TriggerControl.disable(); //TKT-121
            try{
                SBAA.ApprovalAPI.submit(quoteId, SBAA__Approval__c.Quote__c);
            }catch (Exception ex) {
                throw ex;
            } finally {
                SBQQ.TriggerControl.enable(); //TKT-121
            }
            
        }
        return new PageReference('/' + quoteId);
    }
    public PageReference onRecall() {
        if (quoteId != null) {
            SBAA.ApprovalAPI.recall(quoteId, SBAA__Approval__c.Quote__c);
        }
        return new PageReference('/' + quoteId);
    }
}