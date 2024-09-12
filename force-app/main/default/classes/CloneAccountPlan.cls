/* * * * * * * * * * * * * * * * * * * *
 Author : Ajay Choudhary
 Date   : 05/06/2019
 Desc   : Class to clone Account plan record and its related records

* * * * * * * * * * * * * * * * * * * */
public class CloneAccountPlan {
    public Id recordId {get; set;}
    public Account_Plan__c ac{get;set;}
    public CloneAccountPlan(ApexPages.StandardController controller){
        ac = (Account_Plan__c)Controller.getRecord();
        recordId = ac.Id;
    }
    
    public pageReference cloneAccountPlan(){
        String clonedRecordId = cloneRecord(new Set<Id>{recordId});
        if(clonedRecordId != null || String.isNotBlank(clonedRecordId)){
            PageReference pageRef = new PageReference('/'+clonedRecordId);
            pageRef.setRedirect(true);
            return pageRef; 
        }
        else{
            return null;
        }
    }
    
    public String cloneRecord(Set<Id> accountPlanIds){
        String clonedRecordId = '';
        Map<Id, Account_Plan__c> mapOfAccPlanAndCloneRec = new Map<Id, Account_Plan__c>();
        Map<id, Key_Contact__c> mapOfKeyConAndClonedKeyCon = new Map<id, Key_Contact__c>();
        List<Account_Plan_Team__c> toInsertAccountPlanTeams = new List<Account_Plan_Team__c>();
        List<Account_Plan__c> toInsertAccountPlan = new List<Account_Plan__c>();
        List<Contact_Relationship__c> toInsertAccountContactRelationShips = new List<Contact_Relationship__c>();
        List<Account_Sold_To__c> toInsertAccountSoldTo = new List<Account_Sold_To__c>();
        for(Account_Plan__c accPlan : [SELECT Id, Name, Logo__c, Account__c, Executive_Summary__c, Account_Profile__c, Account_Strategies_Goals__c, Marketing_Initiatives__c,
                                       Customer_Purchasing_Strategy__c, Customer_Business_Strategy__c, Consumption_Analysis_Market_View__c, Strengths__c,
                                       Weaknesses__c, Threats__c, Opportunities__c FROM Account_Plan__c WHERE Id IN :accountPlanIds]){
            Account_Plan__c  clonedAccPlan = accPlan.clone(false, true);
            clonedAccPlan.Name = 'New Account Plan';
            clonedAccPlan.Status__c = 'New';
            mapOfAccPlanAndCloneRec.put(accPlan.Id, clonedAccPlan);
            
        }
        
        if(mapOfAccPlanAndCloneRec.values().size() > 0 ){
            insert mapOfAccPlanAndCloneRec.values();
            clonedRecordId = mapOfAccPlanAndCloneRec.values()[0].Id;
        }
        //clone related account plan team records
        for(Account_Plan_Team__c accTeam : [SELECT Id, Name, Account_Plan__c, Account_Plan_Access__c, Account_Plan_Member__c, Account_Plan_Member_Role__c, Account_Plan_Owner__c,
                                            Comments__c, Email__c, Member_Not_in_SFDC__c, Phone__c, Team_Member__c, Title__c FROM Account_Plan_Team__c 
                                            WHERE Account_Plan__c IN :accountPlanIds]){
              
           Account_Plan_Team__c clonedAccTeam = accTeam.clone(false, true);
           clonedAccTeam.Account_Plan__c =  mapOfAccPlanAndCloneRec.get(accTeam.Account_Plan__c).Id;
           toInsertAccountPlanTeams.add(clonedAccTeam);                                     
        }
        
        if(toInsertAccountPlanTeams.size() > 0 ){
            insert toInsertAccountPlanTeams;
        }
        
        //clone related Account sold to records
        for(Account_Sold_To__c accSoldTo : [SELECT Id, Name, Account__c, Account_Plan__c, Account_Plan_Name__c, Created_By__c, Planning_Year__c, Status__c From Account_Sold_To__c WHERE Account_Plan__c IN :accountPlanIds]){
            Account_Sold_To__c clonedAccSoldTo = accSoldTo.clone(false, true); 
            clonedAccSoldTo.Account_Plan__c = mapOfAccPlanAndCloneRec.get(accSoldTo.Account_Plan__c).Id;
            toInsertAccountSoldTo.add(clonedAccSoldTo);
        }
        
        if(toInsertAccountSoldTo.size() > 0 ){
            insert toInsertAccountSoldTo;
        }
        
        //clone related key contact records
        for(Key_Contact__c keyCon : [SELECT Id, Name, Account_Plan__c, Comments__c, Email__c, Key_Contact__c, Mobile__c, Phone__c, Title__c FROM Key_Contact__c WHERE Account_Plan__c IN :accountPlanIds]){
            Key_Contact__c clonedKeyCon = keyCon.clone(false, true);
            clonedKeyCon.Account_Plan__c = mapOfAccPlanAndCloneRec.get(keyCon.Account_Plan__c).Id;
            mapOfKeyConAndClonedKeyCon.put(keyCon.Id, clonedKeyCon);
        }
        
        if(mapOfKeyConAndClonedKeyCon.values().size() > 0 ){
            insert mapOfKeyConAndClonedKeyCon.values();
        }
        
        //clone related contact relationships record
        for(Contact_Relationship__c conRel : [SELECT Id, Name, Account_Plan__c, Contact__c, Contact_Title__c, Influence_Level__c, Olin_Representative__c, Oline_Representative_Title__c, Relationship__c
                                              FROM Contact_Relationship__c WHERE Account_Plan__c IN :accountPlanIds]){
            Contact_Relationship__c clonedConRel = conRel.clone(false, true);
            clonedConRel.Account_Plan__c = mapOfAccPlanAndCloneRec.get(conRel.Account_Plan__c).Id;
            clonedConRel.Contact__c = mapOfKeyConAndClonedKeyCon.get(conRel.Contact__c).Id;
            toInsertAccountContactRelationShips.add(clonedConRel);
        }
        
        if(toInsertAccountContactRelationShips.size() > 0 ){
            insert toInsertAccountContactRelationShips;
        }
        
        if(clonedRecordId != null || String.isNotBlank(clonedRecordId)){
           
            return clonedRecordId; 
        }
        else{
            return null;
        }
      
    }

}