trigger CallReportAttendeeTrigger on FCM_VRAttendee__c (after insert, after delete) {
    Set<Id> callReportIds = new Set<Id>();
    
    if(Trigger.isAfter){
        if(Trigger.isDelete){
            for(FCM_VRAttendee__c att : Trigger.old){
                callReportIds.add(att.FCM_VisitReport__c);
            }
        }
        if(Trigger.isInsert){
            for(FCM_VRAttendee__c att : Trigger.New){
                callReportIds.add(att.FCM_VisitReport__c);
            }
        }
    }
    
    List<FCM_VisitReport__c> toUpdateCalllReports = new List<FCM_VisitReport__c>();
    if(callReportIds.size() > 0){
        for(FCM_VisitReport__c report : [SELECT Id, (SELECT Id, FCM_Contact__r.Name, FCM_Contact__r.Account.Name FROM FCM_VRAttendees__r) FROM FCM_VisitReport__c WHERE Id IN :callReportIds]){
            String attendeeName = '';
            for(FCM_VRAttendee__c att : report.FCM_VRAttendees__r){
                attendeeName += att.FCM_Contact__r.Name+' - '+ att.FCM_Contact__r.Account.Name+'; ';
            }
            report.Attendees__c = attendeeName;
            toUpdateCalllReports.add(report);
        }
        
        if(toUpdateCalllReports.size() > 0){
            update toUpdateCalllReports;
        }
    }
}