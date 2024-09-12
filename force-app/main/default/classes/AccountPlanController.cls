public with sharing class AccountPlanController {
    @AuraEnabled
    public static List<wrapsoldToAcc> wrapsoldToAccList{get; set;}
    
    @AuraEnabled
    public static List<wrapsoldToAcc> showAccSoldToRecord(String pId) {
        //system.debug('pId@@@@@@@@ '+pId);       
        List<Account> accList = [SELECT Id, Name FROM Account WHERE id =: pId];
        List<Account> soldToAccList = [SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, AccountNumber_R1__c,ParentAccount_R1__c, Region_R1__c, Owner.Name FROM Account WHERE ParentAccount_R1__c =: accList[0].Name ORDER BY Name ASC];
        if(soldToAccList == null || soldToAccList.size() == 0)
        {
            return null;
        }
        wrapsoldToAccList = new List<wrapsoldToAcc>();
        for(Account acc : soldToAccList)
        {
            wrapsoldToAccList.add(new wrapsoldToAcc(false,acc));
            //system.debug('acc@@@@@@@@ '+ acc); 
        }
        return wrapsoldToAccList;
    }
    @AuraEnabled
    public static String saveRecords(List<String> accIdList,String parentAccId){
        system.debug('soldToAccIdList '+accIdList);
        system.debug('parentAccId '+parentAccId);
        Set<Id> sToAccIdSet = new Set<Id>();
        Id recordTypeId = Schema.SObjectType.Account_Plan__c.getRecordTypeInfosByName().get('Account Plan').getRecordTypeId();
        //system.debug('recordTypeId '+recordTypeId);
        Account_Plan__c accPlan = new Account_Plan__c(Name = 'New Account Plan', Account__c = parentAccId, Status__c = 'New', RecordTypeId = recordTypeId);
        insert accPlan;
        //system.debug('accPlan '+accPlan);
        if(accIdList != null && accIdList.size() > 0)
        {
            List<Account_Sold_To__c> soldToAccList = new List<Account_Sold_To__c>();
            for(String sToId : accIdList)
            {
                Account_Sold_To__c soldToAcc = new Account_Sold_To__c(Account__c = sToId,	Account_Plan__c = accPlan.Id);
                soldToAccList.add(soldToAcc);
                sToAccIdSet.add(sToId);
            }
            insert soldToAccList;
            //system.debug('soldToAccList '+soldToAccList);
        }
        List<Team__c> pAccTeam = [SELECT Id, Name, Account__r.Name, Team_Member__r.Name, Team_Member__c FROM Team__c WHERE Account__c =: parentAccId];
        List<Team__c> sToAccTeam ;
        if(sToAccIdSet.size() > 0)
        {
            sToAccTeam = [SELECT Id, Name, Account__r.Name, Team_Member__r.Name, Team_Member__c FROM Team__c WHERE Account__c IN: sToAccIdSet];
        }
        Set<Id> allTeamMemId = new Set<Id>();
        if(pAccTeam != null && pAccTeam.size() > 0)
        {
            for(Team__c t1 : pAccTeam)
            {
                if(!allTeamMemId.contains(t1.Team_Member__c))
                {
                    allTeamMemId.add(t1.Team_Member__c);
                }
            }
        }
        if(sToAccTeam != null && sToAccTeam.size() > 0)
        {
            for(Team__c t2 : sToAccTeam)
            {
                if(!allTeamMemId.contains(t2.Team_Member__c))
                {
                    allTeamMemId.add(t2.Team_Member__c);
                }
            }
        }
        List<Account> pAccList = [SELECT id, Name, OwnerId FROM Account WHERE id =: parentAccId];
        //String pAccOwnerId = pAccList[0].OwnerId;
        List<Account_Plan_Team__c> accPlanTeamList = new List<Account_Plan_Team__c>();
        String currentUserId = UserInfo.getUserId();
        //system.debug('currentUserId = '+currentUserId);
        //system.debug('pAccOwnerId = '+pAccOwnerId);
        if(allTeamMemId.size() > 0)
        {
            for(Id tmId : allTeamMemId)
            {
                //system.debug('tmId = '+tmId);
                Account_Plan_Team__c accPlanTeam;
                if(currentUserId == tmId)
                {
                    accPlanTeam = new Account_Plan_Team__c(Account_Plan__c = accPlan.Id, Account_Plan_Member__c = tmId, Comments__c = '', 	Account_Plan_Access__c = 'Read/Write', Account_Plan_Owner__c = true);
                }
                else
                {
                    accPlanTeam = new Account_Plan_Team__c(Account_Plan__c = accPlan.Id, Account_Plan_Member__c = tmId, Comments__c = '', 	Account_Plan_Access__c = 'Read Only', Account_Plan_Owner__c = false);
                }
                accPlanTeamList.add(accPlanTeam);
            }
        }
        if(accPlanTeamList.Size() > 0)
        {
            insert accPlanTeamList;
            //system.debug('accPlanTeamList '+accPlanTeamList);
        }
        return accPlan.Id;
    }
   /*  @AuraEnabled
    public static List<wrapsoldToAcc> allSelect(List<wrapsoldToAcc> wlist) {
        system.debug('pId@@@@@@@@xyz '+ wlist);  
        List<wrapsoldToAcc> wrapsoldToAccListAllSel = new List<wrapsoldToAcc>();                  
        for(sObject wrapData : wlist)
        {
           wrapData.selected = true;
          // wrapsoldToAccListAllSel.add(wrapData); 
        }
        system.debug('wrapsoldToAccListAllSel@@@@@@@@xyz 2 '+wlist);  
        return wrapsoldToAccListAllSel;
    }*/
    
    
    public class wrapsoldToAcc {
        @AuraEnabled public boolean selected {get; set;}
        @AuraEnabled public Account acc {get; set;}
        public wrapsoldToAcc(boolean s,Account a) {
            this.selected = s;
            this.acc = a;
        }
    }
}