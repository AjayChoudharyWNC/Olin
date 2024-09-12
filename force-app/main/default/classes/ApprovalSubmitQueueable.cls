public class ApprovalSubmitQueueable implements Queueable, Database.AllowsCallouts {

    private List<Id> quoteLineIds;

    public ApprovalSubmitQueueable(List<Id> quoteLineIds) {
        this.quoteLineIds = quoteLineIds;
    }

    public ApprovalSubmitQueueable(Set<Id> quoteLineIds) {
        this.quoteLineIds = new List<Id>(quoteLineIds);
    }

    public void execute(QueueableContext context) {
        Id quoteLineId = quoteLineIds.remove(0);
        SBQQ.TriggerControl.disable(); //TKT-121
        try {
            SBAA.ApprovalAPI.submit(quoteLineId, SBAA__Approval__c.Quote_Line__c);
        } catch (Exception ex) {
            throw ex;
        } finally { //TKT-121
            SBQQ.TriggerControl.enable();
        }
        
        
        if (quoteLineIds.size() > 0) {
            System.enqueueJob(new ApprovalSubmitQueueable(quoteLineIds));
        }
    }
}