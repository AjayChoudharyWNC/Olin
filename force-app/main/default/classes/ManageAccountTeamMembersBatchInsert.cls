global class ManageAccountTeamMembersBatchInsert implements Database.batchable<sObject>{ 
   List<sObject> batchList;
   global ManageAccountTeamMembersBatchInsert(List<SObject> objList) {
      // modify list if necessary (e.g., trap null)
      if (objList == null) objList = new List<sObject>();      
      this.batchList = objList;
   } 
    
   global Iterable<SObject> start(Database.BatchableContext info){ 
       return this.batchList;
   }     
    
   global void execute(Database.BatchableContext info, List<SObject> scope){
       try{
           insert scope;
       }
       catch(Exception e){
           System.debug('The following exception has occurred: ' + e.getMessage());
       }
      
   }     
    
   global void finish(Database.BatchableContext info){     
   } 
}