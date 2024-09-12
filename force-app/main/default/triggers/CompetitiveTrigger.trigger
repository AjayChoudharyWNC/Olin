trigger CompetitiveTrigger on Competitor_R1__c (after insert, after delete) {
    
    Set<Id> callReportIds = new Set<Id>();
    
    if(Trigger.isAfter){
        if(Trigger.isDelete){
            for(Competitor_R1__c comp : Trigger.old){
                callReportIds.add(comp.CallReport_R1__c);
            }
        }
        if(Trigger.isInsert){
            for(Competitor_R1__c comp : Trigger.New){
                callReportIds.add(comp.CallReport_R1__c);
            }
        }
    }
    
    
     List<FCM_VisitReport__c> toUpdateCalllReports = new List<FCM_VisitReport__c>();
    if(callReportIds.size() > 0){
        for(FCM_VisitReport__c report : [SELECT Id, (SELECT Id FROM CallReportCompetitors__r) FROM FCM_VisitReport__c WHERE Id IN :callReportIds]){
            report.Competitive_Count__c = report.CallReportCompetitors__r.size();
            toUpdateCalllReports.add(report);
        }
        
        if(toUpdateCalllReports.size() > 0){
            update toUpdateCalllReports;
        }
    }
    

}