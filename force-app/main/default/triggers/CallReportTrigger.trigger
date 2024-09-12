/*
	DESCRIPTION: Sharing Non-Confidential Call Reports with Public Groups stored in a custom object named as "Sharing"
*/
trigger CallReportTrigger on FCM_VisitReport__c (after insert, before update, after update) 
{
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            if (CallReportTrigger_Handler.runOnceAfter() || Test.isRunningTest()){
                CallReportTrigger_Handler.processSharing(Trigger.new, Trigger.oldMap, true);
                /*
                List<FCM_VisitReport__c> crList = new List<FCM_VisitReport__c>();
                List<FCM_VisitReport__c> revokedCrList = new List<FCM_VisitReport__c>();
                for(FCM_VisitReport__c cr: [SELECT Id,Owner.UserRole.DeveloperName,Owner.Name,OwnerRoleName_R1__c,OwnerId,Owner.Id,Confidential__c,FCM_Account__c 
                                            FROM FCM_VisitReport__c 
                                            WHERE Id IN: Trigger.newMap.keySet() 
                                            LIMIT 50000])
                {
                    system.debug(cr.Owner.UserRole.DeveloperName+'='+cr.Owner.Name+'='+cr.Owner.Id+'='+cr.OwnerId);
                    if(!cr.Confidential__c){
                        crList.add(cr);
                    }
                    else if(Trigger.isUpdate && cr.Confidential__c && !trigger.oldMap.get(cr.Id).Confidential__c){
                        revokedCrList.add(cr); 
                    }
                }
                if(crList.size() > 0){
                    CallReportTrigger_Handler.apexSharing(crList);
                }
                if(!revokedCrList.isEmpty()){
                    CallReportTrigger_Handler.revokeSharing(revokedCrList);
                }*/
            }
        }
        
        if(Trigger.isUpdate) {
            if (CallReportTrigger_Handler.runOnceAfter() || Test.isRunningTest()){
                CallReportTrigger_Handler.processSharing(Trigger.new, Trigger.oldMap, false);
                /*
                List<FCM_VisitReport__c> crList = new List<FCM_VisitReport__c>();
                List<FCM_VisitReport__c> revokedCrList = new List<FCM_VisitReport__c>();
                for(FCM_VisitReport__c cr: [SELECT Id,Owner.UserRole.DeveloperName,Owner.Name,OwnerRoleName_R1__c,OwnerId,Owner.Id,Confidential__c,FCM_Account__c 
                                            FROM FCM_VisitReport__c 
                                            WHERE Id IN: Trigger.newMap.keySet() 
                                            LIMIT 50000])
                {
                    system.debug(cr.Owner.UserRole.DeveloperName+'='+cr.Owner.Name+'='+cr.Owner.Id+'='+cr.OwnerId);
                    if(!cr.Confidential__c){
                        crList.add(cr);
                    }
                    else if(Trigger.isUpdate && cr.Confidential__c && !trigger.oldMap.get(cr.Id).Confidential__c){
                        revokedCrList.add(cr); 
                    }
                }
                if(crList.size() > 0){
                    CallReportTrigger_Handler.apexSharing(crList);
                }
                if(!revokedCrList.isEmpty()){
                    CallReportTrigger_Handler.revokeSharing(revokedCrList);
                }*/
            }
        }
    }//---END Insert/Update
    
    if(Trigger.isUpdate && Trigger.isBefore){
        if (CallReportTrigger_Handler.runOnceBefore() || Test.isRunningTest()){
            //--------Validation to allow only owner to change the Confidential__c field---------
            for(FCM_VisitReport__c cr: Trigger.new){
                if(cr.Confidential__c != Trigger.oldMap.get(cr.Id).Confidential__c && UserInfo.getUserId() != cr.OwnerId){
                    cr.addError('Only the owner is allowed to change the confidentiality of call reports.');
                }
            }
        }//---END Before Update
    }
}