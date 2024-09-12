trigger AccountTrigger on Account (before insert, before update, after insert, after update) {
    /*
        Requirement: Update PRICE_ZONE__C field on Account on the basis of Country and State
        Date on which requirement was shared with Gaurish at gaurish@cipaq.com: 3rd April 2019 "Spec for Prize Zone"
    */
    if(Trigger.isBefore){
      /*  List<Price_Zones__c> allPriceZoneList = [SELECT Id,Country__c,CountryCode__c,PriceZoneCode__c,State_Province__c,State_Province_Code__c 
                                                 FROM Price_Zones__c];
        for(Account acc: Trigger.new){
            if(Trigger.isUpdate){
                if (AccountTrigger_Handler.runOnceBefore() || Test.isRunningTest()){
                    if(acc.BillingCountryCode != Trigger.oldMap.get(acc.Id).BillingCountryCode || acc.BillingStateCode != Trigger.oldMap.get(acc.Id).BillingStateCode){
                        AccountTrigger_Handler.processAccountsForPriceZone(acc, allPriceZoneList);
                    }
                }
            } else {
                if (AccountTrigger_Handler.runOnceBefore() || Test.isRunningTest()){
                    AccountTrigger_Handler.processAccountsForPriceZone(acc, allPriceZoneList);
                }
            }
        }*/
    }//----END isBefore-------
    
    if(Trigger.isInsert){
        if(Trigger.isAfter){
            if (AccountTrigger_Handler.runOnceAfter() || Test.isRunningTest()){
                /*//-------Inserting Team__c record as the Account Owner when an account is created-----------
                List<Team__c> teamList = new List<Team__c>();
                for(Account acc: Trigger.new){
                    teamList.add(AccountTrigger_Handler.createTeamRecord(acc, true, null));
                    System.debug('teamList');
                }
                if(teamList.size() > 0){
                    insert teamList;
                }*/
                AccountTrigger_Handler.handleAccountTeamOnInsert(Trigger.New);
            }
        }
    }
    
    if(Trigger.isUpdate) {
        if(Trigger.isAfter) {
            if (AccountTrigger_Handler.runOnceAfter() || Test.isRunningTest()){
                // When Account Owner is changed, then All Programmatic Shares are Deleted therefore they must be restored
                AccountTrigger_Handler.processSharing(Trigger.new, Trigger.oldMap);
                /*
                //-------When account owner is changed then the previous AccountOwner in Team__c object has REMOVED access and a new AccountOwner is inserted-----------
                List<Team__c> teamList = new List<Team__c>();
                Set<Id> accIDs = new Set<Id>();
                
                for(Account acc: Trigger.new){
                    if(acc.OwnerId != Trigger.oldMap.get(acc.Id).OwnerId){
                        accIDs.add(acc.Id);
                    }
                }
                if(accIDs.size() > 0){
                    AccountTrigger_Handler.updateAccountTeamOwner(accIDs, Trigger.new, Trigger.oldMap);
                }*/
            }
        }
    }//---END Update-----A    
}