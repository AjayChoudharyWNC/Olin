public without sharing  class AccountHierarchyController {
    
    @AuraEnabled
    public static list<AccountWrapper> findAllHierarchyAccounts(string recordId, String accountType){
        if(accountType == 'Ship To'){
            return findAllShipToHierarchyAccounts(recordId);
        }
        else{
            list<AccountWrapper> allAccountList=new List<AccountWrapper>();
            list<AccountWrapper> finalAccountList=new List<AccountWrapper>();
            string ultimateAccountId;
            string parentId;
            for(Account acc:[select id,Ultimate_Account_Id__c, Account_Type_Text_Only__c , ParentId from Account where Id=:recordId]){
                parentId = acc.ParentId;
                if(acc.Ultimate_Account_Id__c == acc.ParentId)
                    ultimateAccountId=acc.Ultimate_Account_Id__c;
                if(acc.Account_Type_Text_Only__c == 'Parent'){
                    ultimateAccountId = acc.Ultimate_Account_Id__c;
                    parentId = acc.Id;
                }
            }
            system.debug('ultimateAccountId=='+ultimateAccountId);
            Set<Id> accountIds = new Set<Id>();
            if(string.isNotBlank(ultimateAccountId)){
                for(Account acc:[select id,(select id, Name,AccountNumber_R1__c, Type_Icon__c, OwnerName_R1__c, LineOfBusiness_R1__c, BillingCity, BillingState, BillingCountry,Account_Type_Text_Only__c from ChildAccounts ORDER BY AccountNumber_R1__c DESC),Name,AccountNumber_R1__c, Type_Icon__c, OwnerName_R1__c, LineOfBusiness_R1__c, BillingCity, BillingState, BillingCountry,Account_Type_Text_Only__c,Parent.Name 
                                 from Account where Ultimate_Account_Id__c=:ultimateAccountId order by AccountNumber_R1__c DESC]){
                                     accountIds.add(acc.Id);
                                     AccountWrapper acWrap = new AccountWrapper();
                                     acWrap.act = acc;
                                     acWrap.parentId = parentId;
                                     acWrap.childAccounts = new List<Account>();
                                     for(Account child : acc.ChildAccounts){
                                         acWrap.childAccounts.add(child);
                                     }
                                     allAccountList.add(acWrap);
                                 }
            }
            else{
                for(Account acc:[select id,(select id, Name,AccountNumber_R1__c, Type_Icon__c, OwnerName_R1__c, LineOfBusiness_R1__c, BillingCity, BillingState, BillingCountry,Account_Type_Text_Only__c from ChildAccounts ORDER BY AccountNumber_R1__c DESC),Name,AccountNumber_R1__c, Type_Icon__c, OwnerName_R1__c, LineOfBusiness_R1__c, BillingCity, BillingState, BillingCountry,Account_Type_Text_Only__c,Parent.Name 
                                 from Account where Id=:recordId order by AccountNumber_R1__c DESC]){
                                     accountIds.add(acc.Id);
                                     AccountWrapper acWrap = new AccountWrapper();
                                     acWrap.act = acc;
                                     acWrap.parentId = acc.Id;
                                     acWrap.childAccounts = new List<Account>();
                                     for(Account child : acc.ChildAccounts){
                                         acWrap.childAccounts.add(child);
                                     }
                                     allAccountList.add(acWrap);
                                 }
            }
            Map<Id, List<Account>> accountShipToMap = new Map<Id, List<Account>>();
            for(Account_Relationships__c ar : [SELECT Id, Name, Sold_To__c, Ship_To__r.Type_Icon__c, Ship_To__r.Id, Ship_To__r.Name, Ship_To__r.AccountNumber_R1__c, Ship_To__r.OwnerName_R1__c, Ship_To__r.LineOfBusiness_R1__c, Ship_To__r.BillingCity, Ship_To__r.BillingState, Ship_To__r.BillingCountry,Ship_To__r.Account_Type_Text_Only__c,Ship_To__r.Parent.Name FROM Account_Relationships__c WHERE Sold_To__c IN: accountIds AND Ship_To__c != NULL ORDER BY Ship_To__r.AccountNumber_R1__c DESC]){
                if(!accountShipToMap.containsKey(ar.Sold_To__c)){
                    accountShipToMap.put(ar.Sold_To__c, new List<Account>());
                }
                accountShipToMap.get(ar.Sold_To__c).add(ar.Ship_To__r);
            }
            for(AccountWrapper actWrap : allAccountList){
                if(accountShipToMap.containsKey(actWrap.act.Id)){
                    actWrap.childShipToAccounts = new List<Account>();
                    actWrap.childShipToAccounts.addAll(accountShipToMap.get(actWrap.act.Id));
                }
                system.debug('finalAct==='+actWrap);
                finalAccountList.add(actWrap);
            }
            system.debug('***allAccountList size:'+finalAccountList);
            return finalAccountList;
        }
    }
    
    public static List<AccountWrapper> findAllShipToHierarchyAccounts(String recordId){
        Map<Id, Id> soldToParentMap = new Map<Id, Id>();
        Account act = [SELECT Id, Name,AccountNumber_R1__c, Type_Icon__c, OwnerName_R1__c, LineOfBusiness_R1__c, BillingCity, BillingState, BillingCountry,Account_Type_Text_Only__c, (SELECT Id FROM ChildAccounts ORDER BY AccountNumber_R1__c DESC) FROM Account WHERE Id =:recordId];
        String parentId = [SELECT ParentId FROM Account WHERE Id =:recordId].ParentId;
        list<AccountWrapper> allAccountList=new List<AccountWrapper>();
        AccountWrapper acWrap = new AccountWrapper();
        act.Account_Type__c = 'Main Account';
        acWrap.act = act;
        acWrap.ParentId = recordId;
        acWrap.childAccounts = new List<Account>();
        acWrap.childShipToAccounts = new List<Account>();
        acWrap.sameChildShipToAccounts = new List<Account>();
        for(Account_Relationships__c ar : [SELECT Id, Name, Sold_To__c, Ship_To__c, Sold_To__r.ParentId, Sold_To__r.Type_Icon__c, Sold_To__r.Id, Sold_To__r.Name, Sold_To__r.AccountNumber_R1__c, Sold_To__r.OwnerName_R1__c, Sold_To__r.LineOfBusiness_R1__c, Sold_To__r.BillingCity, Sold_To__r.BillingState, Sold_To__r.BillingCountry,Sold_To__r.Account_Type_Text_Only__c, Sold_To__r.Parent.Name FROM Account_Relationships__c WHERE Ship_To__c =:recordId AND Sold_To__c != NULL ORDER BY Sold_To__r.AccountNumber_R1__c DESC]){
            soldToParentMap.put(ar.Sold_To__r.ParentId, ar.Sold_To__c);
            Account ac = new Account();
            ac = ar.Sold_To__r;
            ac.ParentId = act.Id;
            ac.Parent = act;
            ac.Account_Type__c = 'Child Account';
            AccountWrapper acWrap1 = new AccountWrapper();
            acWrap1.act = ac;
            acWrap1.ParentId = recordId;
            acWrap1.childAccounts = new List<Account>();
            acWrap1.childShipToAccounts = new List<Account>();
            acWrap.childAccounts.add(ac);
            if(ar.Sold_To__c != ar.Ship_To__c){
                allAccountList.add(acWrap1);
            }
            else{
                acWrap.sameChildShipToAccounts.add(ac);
            }
            
        }
        
        
        for(Account acc : [SELECT Id, Name,AccountNumber_R1__c, Type_Icon__c, OwnerName_R1__c, LineOfBusiness_R1__c, BillingCity, BillingState, BillingCountry,Account_Type_Text_Only__c FROM Account WHERE Id IN:soldToParentMap.keySet() ORDER BY AccountNumber_R1__c DESC]){
            acc.ParentId = soldToParentMap.get(acc.Id);
            if(allAccountList.size() > 0){
                for(AccountWrapper actWrap : allAccountList){
                    if(soldToParentMap.get(acc.Id) == actWrap.act.Id){
                        actWrap.childShipToAccounts.add(acc);
                    }
                }
            }
            if(acWrap.sameChildShipToAccounts.size() > 0){
                for(Account sacc : acWrap.sameChildShipToAccounts){
                    if(soldToParentMap.get(acc.Id) == sacc.Id || acc.Id == parentId){
                        acWrap.childShipToAccounts.add(acc);
                    }
                }
            }
        }
        allAccountList.add(acWrap);
        return allAccountList;
    }
    
    class AccountWrapper{
        @AuraEnabled public Account act;
        @AuraEnabled public List<Account> childAccounts;
        @AuraEnabled public List<Account> childShipToAccounts;
        @AuraEnabled public List<Account> sameChildShipToAccounts;
        @AuraEnabled public string parentId;
    }
}