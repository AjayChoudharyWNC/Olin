trigger TeamTrigger on Team__c(after insert, after update){
    /*if(Trigger.isAfter){
        
        //-----Checking the user's access on Account who is inserting or updating Team record----------
        Set<Id> accIDs = new Set<Id>();
        Set<Id> sysAdminIDs = new Set<Id>();
        List<Profile> profileList = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'Super User'];
        if(profileList != null && profileList.size() > 0){
            for(Profile p: profileList){
                sysAdminIDs.add(p.Id);
            }
        }
        if(!sysAdminIDs.contains(UserInfo.getProfileId())){
            for(Team__c t: Trigger.new){
                accIDs.add(t.Account__c);
            }
            List<Team__c> existingTeamRecords = [SELECT Id,Account_Access__c,Account__c,Team_Member__c FROM Team__c 
                                                 WHERE Account__c IN: accIDs AND Team_Member__c =: UserInfo.getUserId() AND Account_Access__c = 'Read/Write' LIMIT 50000];
            system.debug('existingTeamRecords----'+existingTeamRecords);
            if(existingTeamRecords != null && existingTeamRecords.size() > 0){
                Map<Id,List<Team__c>> teamAccMap = new Map<Id,List<Team__c>>();
                for(Team__c t: existingTeamRecords){
                    if(!teamAccMap.containsKey(t.Account__c)){
                        teamAccMap.put(t.Account__c, new List<Team__c>());
                    }
                    teamAccMap.get(t.Account__c).add(t);
                }
                system.debug('teamAccMap----'+teamAccMap);
                for(Team__c t: Trigger.new){
                    if(!teamAccMap.containsKey(t.Account__c)){
                        system.debug('Error1----');
                        t.addError('You do not have access to add Team Member for this Account because you do not have Read/Write Access. Please contact a team member with Read/Write Access, a Super User or your System Administrator.');
                    }
                }
            }
            else
            {
                system.debug('Error2----');
                Trigger.new[0].addError('You do not have access to add Team Member for this Account because you do not have Read/Write Access. Please contact a team member with Read/Write Access, a Super User or your System Administrator.');
            }
        }
        
    }//-----END After Insert & Update*/
    
    if(Trigger.isInsert){        
        if(Trigger.isAfter){
            
            //----Opportunity Sharing------------
            List<Team__c> oppSharingList = new List<Team__c>();
            for(Team__c t: Trigger.new){
                if(t.Opportunity_Access__c != 'Private' && t.Opportunity_Access__c != 'Removed'){
                    System.debug('Opportunity Sharing'+t);
                    oppSharingList.add(t);
                }
            }
            if(oppSharingList.size() > 0){
                TeamTrigger_Handler.shareOpportunity(oppSharingList);
            }
            
            //----Case Sharing----------------
            List<Team__c> caseSharingList = new List<Team__c>();
            for(Team__c t: Trigger.new){
                if(t.Case_Access__c != 'Private' && t.Case_Access__c != 'Removed'){
                    caseSharingList.add(t);
                }
            }
            if(caseSharingList.size() > 0){
                TeamTrigger_Handler.shareCase(caseSharingList);
            }
            
            //----Account & Call Report Sharing----------------
            List<Team__c> accSharingList = new List<Team__c>();
            for(Team__c t: Trigger.new){
                if(t.Account_Access__c != 'Removed'){
                    accSharingList.add(t);
                }
            }
            if(accSharingList.size() > 0){
                TeamTrigger_Handler.shareAccountCallReport(accSharingList);
            }
        }//----END After Insert
    }//---END Insert
    
    if(Trigger.isUpdate){
        if(Trigger.isAfter){
            //----Opportunity Sharing------------
            List<Team__c> oppShareUpdate = new List<Team__c>();
            List<Team__c> oppShareRemove = new List<Team__c>();
            for(Team__c t: Trigger.new){
                if(t.Opportunity_Access__c != 'Private' && t.Opportunity_Access__c != 'Removed' && Trigger.oldMap.get(t.Id).Opportunity_Access__c != t.Opportunity_Access__c){
                    oppShareUpdate.add(t);
                }
                else if(t.Opportunity_Access__c == 'Private' && Trigger.oldMap.get(t.Id).Opportunity_Access__c != t.Opportunity_Access__c){
                    oppShareRemove.add(Trigger.oldMap.get(t.Id));
                }
            }
            if(oppShareUpdate.size() > 0){
                TeamTrigger_Handler.updateShareOpportunity(oppShareUpdate);
            }
            if(oppShareRemove.size() > 0){
                TeamTrigger_Handler.removeShareOpportunity(oppShareRemove);
            }
            
            //----Case Sharing------------
            List<Team__c> caseShareUpdate = new List<Team__c>();
            List<Team__c> caseShareRemove = new List<Team__c>();
            for(Team__c t: Trigger.new){
                if(t.Case_Access__c != 'Private' && t.Case_Access__c != 'Removed' && Trigger.oldMap.get(t.Id).Case_Access__c != t.Case_Access__c){
                    caseShareUpdate.add(t);
                }
                else if(t.Case_Access__c == 'Private' && Trigger.oldMap.get(t.Id).Case_Access__c != t.Case_Access__c){
                    caseShareRemove.add(Trigger.oldMap.get(t.Id));
                }
            }
            if(caseShareUpdate.size() > 0){
                TeamTrigger_Handler.updateCaseOpportunity(caseShareUpdate);
            }
            if(caseShareRemove.size() > 0){
                TeamTrigger_Handler.removeCaseOpportunity(caseShareRemove);
            }
            
            //----Account & Call Report Sharing------------
            List<Team__c> accShareUpdate = new List<Team__c>();
            List<Team__c> accShareRemove = new List<Team__c>();
            List<Team__c> accShareRemovedList = new List<Team__c>();
            for(Team__c t: Trigger.new){
                if(t.Account_Access__c != 'Removed' && Trigger.oldMap.get(t.Id).Account_Access__c != t.Account_Access__c){
                    accShareUpdate.add(t);
                }
                else if(t.Account_Access__c == 'Removed' && Trigger.oldMap.get(t.Id).Account_Access__c != t.Account_Access__c){
                    accShareRemovedList.add(t);
                }
            }
            if(accShareUpdate.size() > 0){
                TeamTrigger_Handler.updateShareAccCallReport(accShareUpdate);
            }
            if(accShareRemovedList.size() > 0){
                TeamTrigger_Handler.removeShareAccCallReport(accShareRemovedList);
                TeamTrigger_Handler.removeCaseOpportunity(accShareRemovedList);
                TeamTrigger_Handler.removeShareOpportunity(accShareRemovedList);
            }
        }//----END After Update
    }//---END Update    
}