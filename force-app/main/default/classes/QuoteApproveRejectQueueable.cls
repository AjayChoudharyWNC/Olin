public class QuoteApproveRejectQueueable implements Queueable, Database.AllowsCallouts {

    private List<Id> quoteLineIds;
    private String comments;
    private Boolean doApprove;

    public QuoteApproveRejectQueueable(List<Id> quoteLineIds, Boolean doApprove, String comments) {
        this.quoteLineIds = quoteLineIds;
        this.comments = comments;
        this.doApprove = doApprove;
    }

    public QuoteApproveRejectQueueable(Set<Id> quoteLineIds, Boolean doApprove, String comments) {
        this.quoteLineIds = new List<Id>(quoteLineIds);
        this.comments = comments;
        this.doApprove = doApprove;
    }

    public void execute(QueueableContext context) {
        Id quoteLineId = quoteLineIds.remove(0);

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        request.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/sbaa/ServiceRouter');
        request.setMethod('POST');
        request.setBody('{"model" :"{\\"approvalId\\" : \\"' + quoteLineId + '\\",\\"comments\\" : \\"' + comments + '\\"}","saver":"SBAA.ApprovalRestApiProvider.' + (doApprove ? 'Approve' : 'Reject' ) + '"}');
        HttpResponse response = http.send(request);

        if (quoteLineIds.size() > 0) {
            System.enqueueJob(new QuoteApproveRejectQueueable(this.quoteLineIds, this.doApprove, this.comments));
        }
    }
}