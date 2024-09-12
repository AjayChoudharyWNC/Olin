public with sharing class QueueableQuoteLineApprovals implements Queueable, Database.AllowsCallouts {
    //Id approvalId;
    Map<Id, Set<Id>> mQuoteApproval;
    Boolean doApprove;
    String comments;

    //public QueueableQuoteLineApprovals(Id approvalId, Boolean doApprove, String comments) {
    public QueueableQuoteLineApprovals(Map<Id, Set<Id>> mQuoteApproval, Boolean doApprove, String comments) {
        this.mQuoteApproval = mQuoteApproval;
        this.doApprove = doApprove;
        this.comments = comments;
    }
    public void execute(QueueableContext context) {

        List<sbaa__Approval__c> lApproval = new List<sbaa__Approval__c>();
        Map<Id, Set<Id>> mQuoteCheck = new Map<Id, Set<Id>>();
        Boolean rerun =false;
        Integer processedIdCounter = 0;
        for(Id mKey : mQuoteApproval.keySet()){
            
            if (rerun){
                break;
            }
            
            Set<Id> processedIds = new Set<Id>();
           SBQQ.TriggerControl.disable();
            Set<Id> lApprovalId = mQuoteApproval.get(mKey);
            for(Id apprId : lApprovalId){
                Http http = new Http();
                HttpRequest request = new HttpRequest();
                request.setHeader('Content-Type', 'application/json');
                request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
                request.setEndpoint(URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/sbaa/ServiceRouter');
                request.setMethod('POST');
                request.setBody('{"model" :"{\\"approvalId\\" : \\"' + apprId + '\\",\\"comments\\" : \\"' + comments + '\\"}","saver":"SBAA.ApprovalRestApiProvider.' + (doApprove ? 'Approve' : 'Reject' ) + '"}');
                request.setTimeout(60000);
                HttpResponse response = http.send(request);
                if (response.getStatusCode() == 200) {
                    processedIdCounter += 1;
                   lApproval.add(new sbaa__Approval__c(Id = apprId, PendingMassApprovalRequest__c = false));
                    rerun = false;
                    processedIds.add(apprId);

                    Id approvalIdtmp = apprId;
                    if (mQuoteCheck.containsKey(mKey)){
                        mQuoteCheck.get(mKey).add(approvalIdtmp);
                    } else {
                        Set<Id> lApprovalIdtmp = new Set<Id>();
                        lApprovalIdtmp.add(approvalIdtmp);
                        mQuoteCheck.put(mKey,lApprovalIdtmp);
                    }
                    //continue;
                   // update new sbaa__Approval__c(Id = apprId, PendingMassApprovalRequest__c = false);
                    system.debug('>>>> Queueable Approval Success <<<<<<' + response.getStatusCode() + '    ' + apprId + '    ' +response.getBody());
                } 
                if (processedIdCounter == 4 || response.getStatusCode() != 200){
                    DateTime start = system.now();
                    while(system.now()< start.addseconds(10)){}
                    rerun = true;
                    break;
                }
            }
            //SBQQ.TriggerControl.enable();
            
        }
        if (mQuoteCheck.keySet().size()>0){
            for (Id mQKey : mQuoteCheck.keySet()) {
                mQuoteApproval.get(mQKey).removeAll(mQuoteCheck.get(mQKey));
                if (!(mQuoteApproval.get(mQKey).size()>0)) {
                    mQuoteApproval.remove(mQKey);
                }
            }
        }
    
        update lApproval;

        if (rerun) {
            System.enqueueJob(new QueueableQuoteLineApprovals(mQuoteApproval, doApprove, comments));
        }
        
    }
}