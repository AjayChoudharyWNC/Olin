public class TaskHomePageController {
    @AuraEnabled
    public static list<Task> taskList(String filter){
        List<Task> taskLst1 = new List<Task>();
        if(filter=='onLoad'){
            taskLst1 = [SELECT Id,Who.Name,ActivityDate,Subject,Priority,Status,What.Name FROM Task WHERE OwnerId =: UserInfo.getUserId() 
                        AND Status = 'Open' Order by ActivityDate DESC];
        }
        else if(filter=='AllOverDue'){
            taskLst1 = [SELECT Id,Who.Name,ActivityDate,Subject,Priority,Status,What.Name FROM Task WHERE ActivityDate <: System.today() AND OwnerId =: UserInfo.getUserId() 
                        AND Status = 'Open' Order by ActivityDate DESC];
        }
        else if(filter=='Todaystask') {
            taskLst1 = [SELECT Id,Who.Name,ActivityDate,Subject,Priority,Status,What.Name FROM Task WHERE ActivityDate =: System.today() AND OwnerId =: UserInfo.getUserId() 
                        AND Status = 'Open' Order by ActivityDate DESC];
        }                                                                  
        else if(filter=='ThisMonth'){
            taskLst1 = [SELECT Id,Who.Name,ActivityDate,Subject,Priority,Status,What.Name FROM Task 
                        WHERE ActivityDate = THIS_MONTH AND OwnerId =: UserInfo.getUserId() 
                        AND Status = 'Open' Order by ActivityDate DESC];
        }
        else if(filter == 'Open'){
            taskLst1 = [SELECT Id,Who.Name,ActivityDate,Subject,Priority,Status,What.Name FROM Task 
                        WHERE Status = 'Open' AND OwnerId =: UserInfo.getUserId() Order by ActivityDate DESC];
        }
        return taskLst1;
    }
    
    @AuraEnabled
    public static list<Task> updateTask(String tId, Boolean isChecked){
        Task t = new Task(Id=tId);
        if(isChecked){
            t.Status = 'Completed';
        }
        else{
            t.Status = 'Open';
        }
        update t;
        return [SELECT Id,Who.Name,ActivityDate,Subject,Priority,Status,What.Name FROM Task 
                WHERE Status = 'Open' AND  OwnerId =: UserInfo.getUserId() Order by ActivityDate DESC];
    }
}