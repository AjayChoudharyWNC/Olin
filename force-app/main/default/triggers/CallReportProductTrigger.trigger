trigger CallReportProductTrigger on FCM_VRProduct__c (after insert, after delete) {
    
    Set<Id> callReportIds = new Set<Id>();
    
    if(Trigger.isAfter){
        if(Trigger.isDelete){
            for(FCM_VRProduct__c prod : Trigger.old){
                callReportIds.add(prod.FCM_VisitReport__c);
            }
        }
        if(Trigger.isInsert){
            for(FCM_VRProduct__c prod : Trigger.New){
                callReportIds.add(prod.FCM_VisitReport__c);
            }
        }
    }
    
    List<FCM_VisitReport__c> toUpdateCalllReports = new List<FCM_VisitReport__c>();
    if(callReportIds.size() > 0){
        for(FCM_VisitReport__c report : [SELECT Id, (SELECT Id, FCM_Product__r.Name FROM FCM_VisitReportProducts__r) FROM FCM_VisitReport__c WHERE Id IN :callReportIds]){
            String discussedProdNames = '';
            for(FCM_VRProduct__c prod : report.FCM_VisitReportProducts__r){
                discussedProdNames += prod.FCM_Product__r.Name+'; ';
            }
            report.Discussed_Products__c = discussedProdNames;
            toUpdateCalllReports.add(report);
        }
        
        if(toUpdateCalllReports.size() > 0){
            update toUpdateCalllReports;
        }
    }

}