trigger AddMemberAccPlanTeam on Team__c (before insert, after insert) {
    Set<Id> accIdSet = new Set<Id>();
    for(Team__c t1 : trigger.new)
    {
        accIdSet.add(t1.Account__c);
    }
    if(trigger.isInsert)
    {
        if(trigger.isBefore)
        {
            Map<Id,Set<Id>> accIdSetTeamIdMapExist = new Map<Id,Set<Id>>();  
            accIdSetTeamIdMapExist = AddMemberAccPlanTeam_Handler.duplicateTeam(accIdSet);
            for(Team__c t0 : trigger.new)
            {
                if(accIdSetTeamIdMapExist.containsKey(t0.Account__c) && accIdSetTeamIdMapExist.get(t0.Account__c) != null)
                {
                    if(accIdSetTeamIdMapExist.get(t0.Account__c).contains(t0.Team_Member__c))
                    {
                        t0.Team_Member__c.addError('Team Member already exists');
                    }
                }
            }
        }
        if(trigger.isAfter)
        {
            Map<Id, Account> accIdAccMap = new Map<Id, Account>();           
            Map<Id,Set<Id>> accIdSetAccPlanId = new Map<Id,Set<Id>>();       
            Set<Id> accPlanIdSet = new Set<Id>();
            Map<Id, Set<Id>> accPlanIdSetAPTeamUserMap = new Map<Id, Set<Id>>();        
            List<Account_Plan_Team__c> newAccPlanTeamList = new List<Account_Plan_Team__c>();      
            Set<Id> pAccIdSet = new Set<Id>();                                                       
            Map<Id, Id> accIdpAccIdMap = new Map<Id, Id>(); 
            Map<Id,Set<Id>> pAccIdSetAccPlanId = new Map<Id,Set<Id>>();       
            Set<Id> pAccPlanIdSet = new Set<Id>();
            Map<Id, Set<Id>> pAccPlanIdSetAPTeamUserMap = new Map<Id, Set<Id>>();
            
            if(accIdSet.size() > 0)
            {
                List<Account> accList = [SELECT Id, Name, ParentAccount_R1__c, ParentId, (SELECT Id FROM Account_Plans__r) FROM Account WHERE Id IN: accIdSet LIMIT 50000];
                if(accList != null && accList.size() > 0) 
                {
                    for(Account acc : accList)
                    {
                        if(!accIdAccMap.containsKey(acc.Id))
                        {
                            accIdAccMap.put(acc.Id, acc);
                        }
                        if(acc.ParentAccount_R1__c == null && acc.Account_Plans__r != null)
                        {
                            for(Account_Plan__c ap : acc.Account_Plans__r)
                            {
                                if(!accIdSetAccPlanId.containsKey(acc.Id))
                                {
                                    accIdSetAccPlanId.put(acc.Id, new Set<Id>());
                                }
                                accIdSetAccPlanId.get(acc.Id).add(ap.Id);
                                accPlanIdSet.add(ap.Id);
                            }
                        }
                        else
                        {   
                            pAccIdSet.add(acc.ParentId);
                            if(!accIdpAccIdMap.containsKey(acc.Id))
                            {
                                accIdpAccIdMap.put(acc.Id, acc.ParentId);
                            }
                        }
                    }
                }
                accPlanIdSetAPTeamUserMap = AddMemberAccPlanTeam_Handler.AccountPlanGet(accPlanIdSet);
                if(pAccIdSet != null && pAccIdSet.size() > 0)
                {
                    List<Account> accList1 = [SELECT Id, Name, ParentAccount_R1__c, (SELECT Id FROM Account_Plans__r) FROM Account WHERE Id IN: pAccIdSet LIMIT 50000];
                    if(accList1 != null && accList1.size() > 0) 
                    {
                        for(Account acc1 : accList1)
                        {
                            if(acc1.ParentAccount_R1__c == null && acc1.Account_Plans__r != null)
                            {
                                for(Account_Plan__c ap1 : acc1.Account_Plans__r)
                                {
                                    if(!pAccIdSetAccPlanId.containsKey(acc1.Id))
                                    {
                                        pAccIdSetAccPlanId.put(acc1.Id, new Set<Id>());
                                    }
                                    pAccIdSetAccPlanId.get(acc1.Id).add(ap1.Id);
                                    pAccPlanIdSet.add(ap1.Id);
                                }
                            }
                        }
                    }
                }
                pAccPlanIdSetAPTeamUserMap = AddMemberAccPlanTeam_Handler.AccountPlanGet(pAccPlanIdSet);
            }
            
            for(Team__c t3 : trigger.new)
            {
                if(accIdAccMap.keySet().size() > 0 && accIdAccMap.containsKey(t3.Account__c))
                {
                    Account teamAcc = accIdAccMap.get(t3.Account__c);
                    if(teamAcc.ParentAccount_R1__c == null)
                    {
                        Set<Id> setAccPlanId = accIdSetAccPlanId.get(t3.Account__c);
                        if(setAccPlanId != null && setAccPlanId.size() > 0)
                        {
                            for(Id apId : setAccPlanId)
                            {
                                if(accPlanIdSetAPTeamUserMap.containsKey(apId))
                                {
                                    if(!accPlanIdSetAPTeamUserMap.get(apId).contains(t3.Team_Member__c))
                                    {
                                        newAccPlanTeamList.add(AddMemberAccPlanTeam_Handler.newAccountPlanTeam(t3.Team_Member__c,apId));
                                    }
                                }
                            }
                        }
                    }
                    else
                    {
                        if(pAccIdSet != null && pAccIdSet.size() > 0)
                        {
                            Set<Id> setAccPlanId = pAccIdSetAccPlanId.get(accIdpAccIdMap.get(t3.Account__c));
                            if(setAccPlanId != null && setAccPlanId.size() > 0)
                            {
                                for(Id apId : setAccPlanId)
                                {
                                    if(pAccPlanIdSetAPTeamUserMap.containsKey(apId))
                                    {
                                        if(!pAccPlanIdSetAPTeamUserMap.get(apId).contains(t3.Team_Member__c))
                                        {
                                            newAccPlanTeamList.add(AddMemberAccPlanTeam_Handler.newAccountPlanTeam(t3.Team_Member__c,apId));
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            if(newAccPlanTeamList != null && newAccPlanTeamList.size() > 0)
            {
                insert newAccPlanTeamList;
            }
        }
    }
}