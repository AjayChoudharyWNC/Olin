public class HelperOwnerChangeTrigger {
    public static void ownerMethod(String accPlanId){
        List<Account_Plan__c> accPlanList = new List<Account_Plan__c>();
        List<Account_Plan_Team__c> accPlanTeamList = new List<Account_Plan_Team__c>();
        
        accPlanList=[Select Id, Name, Owner.Name from Account_Plan__c where Id =: accPlanId ];
        accPlanTeamList=[Select Id, Team_Member__c, Account_Plan_Owner__c, 	Account_Plan_Access__c from Account_Plan_Team__c where Account_Plan__c =: accPlanList[0].Id];
        
        for(Account_Plan_Team__c accplan:accPlanTeamList){
            Account_Plan_Team__c accPlnTeam = new Account_Plan_Team__c();
            accPlnTeam.Id = accplan.Id;
            if(accplan.Team_Member__c == accPlanList[0].Owner.Name){
                accPlnTeam.Account_Plan_Owner__c = true;
                accPlnTeam.Account_Plan_Access__c = 'Read/Write';
            }
            else{
                accPlnTeam.Account_Plan_Owner__c = false;
                accPlnTeam.Account_Plan_Access__c = 'Read Only'; 
            }
            update accPlnTeam;
        }
    }
}