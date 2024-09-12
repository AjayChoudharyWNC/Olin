public class TeamTrigger_Handler {
    //-----------------ACCOUNT & CALL REPORT SHARING-----------------------------START
    public static void shareAccountCallReport(List<Team__c> teamList){
        Set<Id> teamMemberIDs = new Set<Id>();
        Set<Id> accIDs = new Set<ID>();
        Map<Id, List<Team__c>> accTeamMap = new Map<Id,List<Team__c>>();
        for(Team__c t: teamList){
            accIDs.add(t.Account__c);
            teamMemberIDs.add(t.Team_Member__c);
            if(!accTeamMap.containsKey(t.Account__c)){
                accTeamMap.put(t.Account__c, new List<Team__c>());
            }
            accTeamMap.get(t.Account__c).add(t);
        }
        if(accIDs.size() > 0){
            List<Account> accList = [SELECT Id,(SELECT Id FROM FCM_Visit_Reports__r) FROM Account WHERE Id IN: accIDs LIMIT 50000];
            if(accList != null && accList.size() > 0){
                Set<Id> callReportIDSet = new Set<Id>();
                
                List<FCM_VisitReport__Share> callReportShareList = new List<FCM_VisitReport__Share>();
                List<AccountShare> accountShareList = new List<AccountShare>();
                for(Account acc: accList){
                    if(acc.FCM_Visit_Reports__r != null && acc.FCM_Visit_Reports__r.size() > 0){
                        for(FCM_VisitReport__c fr: acc.FCM_Visit_Reports__r){
                            callReportIDSet.add(fr.Id);
                        }
                    }
                }
                accountShareList = [SELECT AccountAccessLevel,RowCause,AccountId,UserOrGroupId FROM AccountShare 
                                    WHERE UserOrGroupId IN: teamMemberIDs AND AccountId IN: accIDs AND (RowCause = 'Owner' OR RowCause = 'Team')];
                if(callReportIDSet.size() > 0){
                    callReportShareList = [SELECT AccessLevel,RowCause,ParentId,UserOrGroupId FROM FCM_VisitReport__Share 
                                           WHERE UserOrGroupId IN: teamMemberIDs AND ParentId IN: callReportIDSet AND RowCause = 'Owner'];
                }
                List<AccountShare> accShareList = new List<AccountShare>();
                List<FCM_VisitReport__Share> crShareList = new List<FCM_VisitReport__Share>();
                for(Account acc: accList){
                    if(accTeamMap.containsKey(acc.Id))
                    {
                        List<Team__c> teamList1 = accTeamMap.get(acc.Id);
                        for(Team__c t: teamList1)
                        {
                            AccountShare ash;
                            if(t.Account_Access__c == 'Read Only' && !t.Account_Owner__c){
                                ash = TeamTrigger_Utility.createAccountShareRecords(t.Team_Member__c, acc.Id, 'Read', 'None', accountShareList);
                            }
                            else if(t.Account_Access__c == 'Read/Write' && !t.Account_Owner__c){
                                ash = TeamTrigger_Utility.createAccountShareRecords(t.Team_Member__c, acc.Id, 'Edit', 'None', accountShareList);
                            }
                            if(ash != null)
                                accShareList.add(ash);
                            //---------------Call Report Sharing------------
                            if(acc.FCM_Visit_Reports__r != null && acc.FCM_Visit_Reports__r.size() > 0){
                                for(FCM_VisitReport__c cr: acc.FCM_Visit_Reports__r){
                                    FCM_VisitReport__Share sh;
                                    if(t.Account_Access__c == 'Read Only'){
                                        sh = TeamTrigger_Utility.createCRShareRecords(t.Team_Member__c, cr.Id, 'Read', callReportShareList);
                                    }
                                    else if(t.Account_Access__c == 'Read/Write'){
                                        sh = TeamTrigger_Utility.createCRShareRecords(t.Team_Member__c, cr.Id, 'Edit', callReportShareList);
                                    }
                                    if(sh != null)
                                        crShareList.add(sh);
                                }
                            }
                        }
                    }
                }
                if(accShareList.size() > 0){
                    Database.SaveResult[] srList1 = Database.insert(accShareList, false);
                    for (Database.SaveResult sr : srList1) {
                        if (!sr.isSuccess()) {
                            for(Database.Error err : sr.getErrors()) {
                                System.debug('The following error has occurred while inserting Account SHaring records.');                    
                                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                System.debug('fields that affected this error: ' + err.getFields());
                            }
                        }
                    }
                }
                if(crShareList.size() > 0){
                    system.debug(crShareList.size()+'---'+crShareList);
                    Database.SaveResult[] srList = Database.insert(crShareList, false);
                    for (Database.SaveResult sr : srList) {
                        if (!sr.isSuccess()) {
                            for(Database.Error err : sr.getErrors()) {
                                System.debug('The following error has occurred while inserting Call Report Sharing Records.');                    
                                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                System.debug('fields that affected this error: ' + err.getFields());
                            }
                        }
                    }
                }
            }
        }
    }
    
    //---------Updating existing Account & Call Report Sharing records' access level--------
    public static void updateShareAccCallReport(List<Team__c> teamList){
        Map<Id, Team__c> userTeamMap = new Map<Id, Team__c>();
        Set<Id> accIDs = new Set<Id>();
        Set<Id> callReportIDs = new Set<Id>();
        
        for(Team__c t: teamList){
            userTeamMap.put(t.Team_Member__c, t);
            accIDs.add(t.Account__c);
        }
        List<Account> accList = [SELECT Id,(SELECT Id FROM FCM_Visit_Reports__r) FROM Account WHERE Id IN: accIDs LIMIT 50000];
        for(Account acc: accList){
            for(FCM_VisitReport__c cr: acc.FCM_Visit_Reports__r){
                callReportIDs.add(cr.Id);
            }
        }
        List<AccountShare> osList = [SELECT Id,AccountAccessLevel,UserOrGroupId FROM AccountShare 
                                     WHERE AccountId IN: accList AND UserOrGroupId IN: userTeamMap.keySet() AND Rowcause != 'Owner' AND RowCause != 'Team' LIMIT 50000];
        if(osList != null && osList.size() > 0){
            for(AccountShare os: osList){
                String oppAccess = userTeamMap.get(os.UserOrGroupId).Account_Access__c;
                if(oppAccess == 'Read Only')
                    os.AccountAccessLevel = 'Read';
                else if(oppAccess == 'Read/Write')
                    os.AccountAccessLevel = 'Edit';
            }
            Database.SaveResult[] srList = Database.update(osList, false);
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred while updating Account Sharing Records.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }
        else{
            shareAccountCallReport(teamList);
        }
        List<FCM_VisitReport__share> crShareList = [SELECT Id,UserOrGroupId,AccessLevel FROM FCM_VisitReport__share WHERE ParentId IN: callReportIDs 
                                                    AND UserOrGroupId IN: userTeamMap.keySet() AND RowCause != 'Owner' LIMIT 50000];
        if(crShareList != null && crShareList.size() > 0){
            for(FCM_VisitReport__share os: crShareList){
                String oppAccess = userTeamMap.get(os.UserOrGroupId).Account_Access__c;
                if(oppAccess == 'Read Only')
                    os.AccessLevel = 'Read';
                else if(oppAccess == 'Read/Write')
                    os.AccessLevel = 'Edit';
            }
            Database.SaveResult[] srList = Database.update(crShareList, false);
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred while updating Call Report Sharing Records.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }
        else{
            shareAccountCallReport(teamList);
        }
    }
    
    //----------Removing access from the previous Team Member for Account & Call Report---------
    public static void removeShareAccCallReport(List<Team__c> teamList){
        Map<Id, Team__c> userTeamMap = new Map<Id, Team__c>();
        Set<Id> accIDs = new Set<Id>();
        Set<Id> callReportIDs = new Set<Id>();
        for(Team__c t: teamList){
            userTeamMap.put(t.Team_Member__c, t);
            accIDs.add(t.Account__c);
        }
        List<Account> oppList = [SELECT Id,(SELECT Id FROM FCM_Visit_Reports__r) FROM Account WHERE Id IN: accIDs LIMIT 50000];
        for(Account acc: oppList){
            for(FCM_VisitReport__c cr: acc.FCM_Visit_Reports__r){
                callReportIDs.add(cr.Id);
            }
        }
        List<AccountShare> osList = [SELECT Id,AccountAccessLevel,UserOrGroupId FROM AccountShare WHERE AccountId IN: oppList 
                                     AND UserOrGroupId IN: userTeamMap.keySet() AND RowCause != 'Owner' AND RowCause != 'Team' LIMIT 50000];
        if(osList != null && osList.size() > 0){
            Database.DeleteResult[] srList = Database.delete(osList, false);
            for (Database.DeleteResult sr : srList) {
                if (!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred while deleting Account Sharing Records.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }
        List<FCM_VisitReport__share> crShareList = [SELECT Id,UserOrGroupId,AccessLevel FROM FCM_VisitReport__share 
                                                    WHERE ParentId IN: callReportIDs 
                                                    AND UserOrGroupId IN: userTeamMap.keySet() AND RowCause != 'Owner' LIMIT 50000];
        if(crShareList != null && crShareList.size() > 0){
            Database.DeleteResult[] srList = Database.delete(crShareList, false);
            for (Database.DeleteResult sr : srList) {
                if (!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred while deleting Call Report Sharing Records.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }
    }
    //-----------------ACCOUNT & CALL REPORT SHARING-----------------------------END
    
    //-----------------OPPORTUNITY SHARING-----------------------------START
    //---------Creating new Sharing records-----------
    public static void shareOpportunity(List<Team__c> teamList){
        Set<Id> accIDs = new Set<ID>();
        for(Team__c t: teamList){
            accIDs.add(t.Account__c);
        }
        System.debug('accIDs'+accIDs);
        if(accIDs.size() > 0){
            List<Opportunity> oppList = [SELECT Id,Confidential__c FROM Opportunity WHERE AccountId IN: accIDs LIMIT 50000];
            System.debug('oppList'+oppList);
            if(oppList != null && oppList.size() > 0){
                List<OpportunityShare> oppShareList = new List<OpportunityShare>();
                for(Opportunity opp: oppList){
                    if(!opp.Confidential__c){
                        for(Team__c t: teamList){
                            if(t.Opportunity_Access__c == 'Read Only')
                                oppShareList.add(TeamTrigger_Utility.createOpportunityShareRecords(t.Team_Member__c, opp.Id, 'Read'));
                            else if(t.Opportunity_Access__c == 'Read/Write')
                                oppShareList.add(TeamTrigger_Utility.createOpportunityShareRecords(t.Team_Member__c, opp.Id, 'Edit'));
                        }
                    }
                }
                if(oppShareList.size() > 0){
                    Database.SaveResult[] srList = Database.insert(oppShareList, false);
                    for (Database.SaveResult sr : srList) {
                        if (!sr.isSuccess()) {
                            for(Database.Error err : sr.getErrors()) {
                                System.debug('The following error has occurred while inserting Opportunity Sharing Records.');                    
                                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                System.debug('fields that affected this error: ' + err.getFields());
                            }
                        }
                    }
                }
            }
        }
    }
    
    //---------Updating existing Sharing records' access level--------
    public static void updateShareOpportunity(List<Team__c> teamList){
        Map<Id, Team__c> userTeamMap = new Map<Id, Team__c>();
        Set<Id> accIDs = new Set<Id>();
        for(Team__c t: teamList){
            userTeamMap.put(t.Team_Member__c, t);
            accIDs.add(t.Account__c);
        }
        List<Opportunity> oppList = [SELECT Id FROM Opportunity WHERE AccountId IN: accIDs LIMIT 50000];
        List<OpportunityShare> osList = [SELECT Id,OpportunityAccessLevel,UserOrGroupId FROM OpportunityShare WHERE OpportunityId IN: oppList AND UserOrGroupId IN: userTeamMap.keySet() LIMIT 50000];
        if(osList != null && osList.size() > 0){
            for(OpportunityShare os: osList){
                String oppAccess = userTeamMap.get(os.UserOrGroupId).Opportunity_Access__c;
                if(oppAccess == 'Read Only')
                    os.OpportunityAccessLevel = 'Read';
                else if(oppAccess == 'Read/Write')
                    os.OpportunityAccessLevel = 'Edit';
            }
            Database.SaveResult[] srList = Database.update(osList, false);
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred while updating Opportunity Sharing Records.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }
        else{
            shareOpportunity(teamList);
        }
    }
    
    //----------Removing access from the previous Team Member---------
    public static void removeShareOpportunity(List<Team__c> teamList){
        Map<Id, Team__c> userTeamMap = new Map<Id, Team__c>();
        Set<Id> accIDs = new Set<Id>();
        for(Team__c t: teamList){
            userTeamMap.put(t.Team_Member__c, t);
            accIDs.add(t.Account__c);
        }
        List<Opportunity> oppList = [SELECT Id FROM Opportunity WHERE AccountId IN: accIDs LIMIT 50000];
        List<OpportunityShare> osList = [SELECT Id,OpportunityAccessLevel,UserOrGroupId FROM OpportunityShare 
                                         WHERE OpportunityId IN: oppList AND UserOrGroupId IN: userTeamMap.keySet() AND RowCause != 'Owner' LIMIT 50000];
        if(osList != null && osList.size() > 0){
            Database.Delete(osList, false);
        }
    }
    //-----------------OPPORTUNITY SHARING-----------------------------END
    
    //-----------------CASE SHARING-----------------------------START
    //---------Creating new Sharing records-----------
    public static void shareCase(List<Team__c> teamList){
        Set<Id> accIDs = new Set<ID>();
        for(Team__c t: teamList){
            accIDs.add(t.Account__c);
        }
        if(accIDs.size() > 0){
            List<Case> caseList = [SELECT Id FROM Case WHERE AccountId IN: accIDs LIMIT 50000];
            if(caseList != null && caseList.size() > 0){
                List<CaseShare> caseShareList = new List<CaseShare>();
                for(Case c: caseList){
                    for(Team__c t: teamList){
                        if(t.Case_Access__c == 'Read Only')
                            caseShareList.add(TeamTrigger_Utility.createCaseShareRecords(t.Team_Member__c, c.Id, 'Read'));
                        else if(t.Case_Access__c == 'Read/Write')
                            caseShareList.add(TeamTrigger_Utility.createCaseShareRecords(t.Team_Member__c, c.Id, 'Edit'));
                    }
                }
                if(caseShareList.size() > 0){
                    Database.insert(caseShareList,false);
                }
            }
        }
    }
    
    //---------Updating existing Sharing records' access level--------
    public static void updateCaseOpportunity(List<Team__c> teamList){
        Map<Id, Team__c> userTeamMap = new Map<Id, Team__c>();
        Set<Id> accIDs = new Set<Id>();
        for(Team__c t: teamList){
            userTeamMap.put(t.Team_Member__c, t);
            accIDs.add(t.Account__c);
        }
        List<Case> caseList = [SELECT Id FROM Case WHERE AccountId IN: accIDs LIMIT 50000];
        List<CaseShare> csList = [SELECT Id,CaseAccessLevel,UserOrGroupId FROM CaseShare WHERE CaseId IN: caseList AND UserOrGroupId IN: userTeamMap.keySet() LIMIT 50000];
        if(csList != null && csList.size() > 0){
            for(CaseShare os: csList){
                String cAccess = userTeamMap.get(os.UserOrGroupId).Case_Access__c;
                if(cAccess == 'Read Only')
                    os.CaseAccessLevel = 'Read';
                else if(cAccess == 'Read/Write')
                    os.CaseAccessLevel = 'Edit';
            }
            Database.update(csList);
        }
        else{
            shareCase(teamList);
        }
    }
    
    //----------Removing access from the previous Team Member---------
    public static void removeCaseOpportunity(List<Team__c> teamList){
        Map<Id, Team__c> userTeamMap = new Map<Id, Team__c>();
        Set<Id> accIDs = new Set<Id>();
        for(Team__c t: teamList){
            userTeamMap.put(t.Team_Member__c, t);
            accIDs.add(t.Account__c);
        }
        List<Case> caseList = [SELECT Id FROM Case WHERE AccountId IN: accIDs LIMIT 50000];
        List<CaseShare> csList = [SELECT Id,CaseAccessLevel,UserOrGroupId FROM CaseShare WHERE CaseId IN: caseList 
                                  AND UserOrGroupId IN: userTeamMap.keySet() AND RowCause != 'Owner' LIMIT 50000];
        if(csList != null && csList.size() > 0){
            Database.delete(csList);
        }
    }
    //----------------------------CASE SHARING-----------------------------------END
}