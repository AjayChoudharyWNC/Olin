/*
 * Description: This Apex Class exposes method(s) that can be utilized by 
 * other Apex Classes to create Persistent Logs of type Error or
 * Information as opposed to native Debug Logs. 
 * 
 * Created By: 
 * 
 * Created Date: 
 * 
 * Revisions:
*/
global class ApexDebugLog{
    /*
        A Virtual Class that Defines the 
        Structure of a Log
    */
    public virtual class Log{
        public String Type;
        public String ApexClass;
        public String Method;

        public String RecordId;
        public String Message;
        public String StackTrace;
    }
    
    /*
        A Class that Extends the Virtual Class - Log
        to define a log of type - Error
    */
    public class Error extends Log{
        public Error(String cls, String routine, String recId, Exception ex){
            this.Type = 'Error';
            this.ApexClass = cls;
            this.Method = routine;
            this.RecordId = recId;
            this.Message = ex.getMessage();
            this.StackTrace = ex.getStackTraceString();
        }
    }

    /*
        A Class that Extends the Virtual Class - Log
        to define a log of type - Information
    */
    public class Information extends Log{
        public Information(String cls, String routine, String recId, String msg){
            this.Type = 'Information';
            this.ApexClass = cls;
            this.Method = routine;
            this.RecordId = recId;
            this.Message = msg;
            this.StackTrace = NULL;
        }
    }

    /*
        A Public Method that can be utilized by
        other Apex Classes to create a record into
        the Apex Debug Log object stating the Error
        or Information.
    */
    public void createLog(Log logToCreate){
        try{
            /*
                Ensure that we're well within the Governor Limits.
                The creation of the Log shouldn't disturb the execution
                of that Apex Class that utilizes this method to
                create a log.
            */
            if(
                (Limits.getDMLRows() < Limits.getLimitDMLRows()) && 
                (Limits.getDMLStatements() < Limits.getLimitDMLStatements())
            )
            {
                ApexDebuglog_R1__c apexDebuglog = new ApexDebuglog_R1__c(
                    Type_R1__c         = logToCreate.Type,
                    ApexClass_R1__c   = logToCreate.ApexClass,
                    Method_R1__c       = logToCreate.Method,
                    RecordId_R1__c    = logToCreate.RecordId,
                    Message_R1__c      = logToCreate.Message,
                    StackTrace_R1__c  = logToCreate.StackTrace
					
					
                );

                Database.insert(apexDebuglog, FALSE);
            }
            else{
                System.debug('The Governor Limits have already been exhausted and hence failed to create a Log!');
            }
        }
        catch(DMLException ex){
            System.debug('Something fatal has occurred and hence failed to create a Log! Error:' + ex.getMessage());
        }
    }

    /*
        A Public Method that can be utilized from
        JavaScript to create record(s) [aka Logs] into the
        Custom Object.
    */
    webService
    static void createLog(String log){
        try{
            /*
                Expects a JSON of the form - 
                {
                    "Type"       : "---",
                    "ApexClass"  : "---",
                    "Method"     : "---",
                    "RecordId"   : "---",
                    "Message"    : "---",
                    "StackTrace" : "---",
                }
            */

            /*Deserialize the same to create an instance of the virtual class - ApexDebugLog.Log*/
            ApexDebugLog.Log logToCreate = (ApexDebugLog.Log)JSON.deserialize(log, ApexDebugLog.Log.class);
            
            new ApexDebugLog().createLog(logToCreate);
        }
        catch(Exception ex){
            System.debug('Something fatal has occurred and hence failed to create a Log! Error:' + ex.getMessage());
        }
    }
}