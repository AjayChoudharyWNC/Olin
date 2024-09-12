trigger AccountSystemsTranslationTrigger on Account_Systems_Translation__c (after insert,after update,after delete) {
    Set<Id> accIdSet = new Set<Id>();
    List<Account> updAccList = new List<Account>();
    if(Trigger.isInsert || Trigger.isUpdate){
        for(Account_Systems_Translation__c ast : Trigger.New){
            accIdSet.add(ast.Account__c);
        }
        if(!accIdSet.isEmpty() && accIdSet != null)
        {
            updAccList = AccountSystemTranslationHandler.getAccountForUpdate(accIdSet);
        }
        /*if(Trigger.isInsert)
        {
for(Account_Systems_Translation__c ast : Trigger.New)
{
if(ast.Legacy_Account_Id__c != null && ast.Legacy_Account_Id__c != '')
{
Integer buffSize = mapAccIdBuffStrIns.get(ast.Account__c).length();
Integer availableSize =  255 - mapAccIdAcc.get(ast.Account__c).Legacy_ID_s__c.length() - buffSize;
Integer currentSize = ast.Legacy_Account_Id__c.length() +1;
if(AvailableSize >= currentSize)
{
String buffStr = mapAccIdBuffStrIns.get(ast.Account__c)+ast.Legacy_Account_Id__c;
mapAccIdBuffStrIns.remove(ast.Account__c);
mapAccIdBuffStrIns.put(ast.Account__c, buffStr);
}
}
}
if(!mapAccIdBuffStrIns.keySet().isEmpty() && mapAccIdBuffStrIns.keySet() != null)
{
for(Id aId : mapAccIdBuffStrIns.keySet() )
{
if(mapAccIdBuffStrIns.get(aId) != null && mapAccIdBuffStrIns.get(aId) != '')
{
Account a = new Account(Id = aId,Legacy_ID_s__c = mapAccIdBuffStrIns.get(aId));
updAccList.add(a);
}
}
}
}*/
    }
    if(Trigger.isDelete){
        for(Account_Systems_Translation__c ast : Trigger.Old){
            accIdSet.add(ast.Account__c);
        }
        if(!accIdSet.isEmpty() && accIdSet != null)
        {
            updAccList = AccountSystemTranslationHandler.getAccountForUpdate(accIdSet);
        }
    }
    if(!updAccList.isEmpty() && updAccList != Null)
        {
            update updAccList;
        }
}