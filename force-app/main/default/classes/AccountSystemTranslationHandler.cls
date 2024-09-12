public class AccountSystemTranslationHandler {
    // Method call in Insert and Update
    public static List<Account> getAccountForUpdate(Set<Id> accIdSet)
    {
        List<Account> updAccList = new List<Account>();
        Map<Id, Account> mapAccIdAcc = new Map<Id, Account>([SELECT Id,Legacy_ID_s__c FROM Account WHERE Id IN: accIdSet]);
        Map<Id, List<Account_Systems_Translation__c>> mapAccIdAstList = new Map<Id, List<Account_Systems_Translation__c>>();
        for(Account_Systems_Translation__c ast :[SELECT Id,Legacy_Account_Id__c,Account__c,CreatedDate FROM Account_Systems_Translation__c WHERE Account__c IN: accIdSet ORDER BY Account__c, CreatedDate ASC])
        {
            if(!mapAccIdAstList.containsKey(ast.Account__c))
            {
                mapAccIdAstList.put(ast.Account__c, new List<Account_Systems_Translation__c>());
            }
            mapAccIdAstList.get(ast.Account__c).add(ast);
        }
        if(!mapAccIdAcc.keySet().isEmpty() && mapAccIdAcc.keySet() != null)
        {
            for(Id aId : mapAccIdAcc.keySet())
            {
                if(mapAccIdAstList.ContainsKey(aId))
                {
                    if(!mapAccIdAstList.get(aId).isEmpty() && mapAccIdAstList.get(aId) != null)
                    {
                        String accLegacyIds = AccountSystemTranslationHandler.getAccLegacyIDs(mapAccIdAstList.get(aId));
                        if(accLegacyIds != Null && accLegacyIds != '')
                        {
                            Account acc = new Account();
                            acc.Id = aId;
                            acc.Legacy_ID_s__c = accLegacyIds;
                            updAccList.add(acc);
                        }
                    }
                }
                else 
                {
                    Account acc = new Account();
                    acc.Id = aId;
                    acc.Legacy_ID_s__c = '';
                    updAccList.add(acc);
                }
            }
        }
        return updAccList;
    }
    // Method to create Account LegacyIDs
    public static String getAccLegacyIDs(List<Account_Systems_Translation__c> astList)
    {
        String LegacyIDsFinal;
        if(!astList.isEmpty() && astList != null)
        {
            String LegacyIDs = '';
            for(Account_Systems_Translation__c ast : astList)
            {
                LegacyIDs = LegacyIDs +' '+ast.Legacy_Account_Id__c;
            } 
            if(LegacyIDs.length() <= 255)
            {
               LegacyIDsFinal = LegacyIDs;
            }
            else
            {
               LegacyIDsFinal = LegacyIDs.substring(0, 256); 
            }
        }
        return LegacyIDsFinal;
    }
}