trigger AccountPlanPDFForm on Account_Plan__c (after update) {     
    if(trigger.isUpdate){
        List<Id> recIds = new List<Id>();
        for(Account_Plan__c acc: trigger.new){
            recIds.add(acc.Id);
            if((acc.Status__c != trigger.oldMap.get(acc.Id).Status__c) && (acc.Status__c == 'Approved')){
                HelperAccountPlanPDFForm.getBlob(acc.Id);
            }
        }
        List<Approval.UnlockResult> ulrList = Approval.unlock(recIds, false);
    }
}