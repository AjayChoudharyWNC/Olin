@isTest
public class ApexDebugLog_Test{
    testMethod
    static void createErrorLog(){
        try{
            Integer result = 1 / 0;
        }
        catch(Exception ex){
            new ApexDebugLog().createLog(
                new ApexDebugLog.Error(
                    'ApexDebugLog_Test',
                    'createErrorLog',
                    NULL,
                    ex
                )
            );

            List<ApexDebuglog_R1__c> lstLogsCreated = [
                SELECT  Id, Type_R1__c, ApexClass_R1__c, Method_R1__c
                FROM    ApexDebuglog_R1__c
                WHERE   Method_R1__c = 'createErrorLog'
            ];

            System.assertEquals(1, lstLogsCreated.size());
            System.assertEquals('Error', lstLogsCreated.get(0).Type_R1__c);
            System.assertEquals('ApexDebugLog_Test', lstLogsCreated.get(0).ApexClass_R1__c);
        }
    }

    testMethod
    static void createInformationLog(){
        new ApexDebugLog().createLog(
            new ApexDebugLog.Information(
                'ApexDebugLog_Test',
                'createInformationLog',
                NULL,
                'Logging Information from an Apex Class - ApexDebugLog_Test'
            )
        );

        List<ApexDebuglog_R1__c> lstLogsCreated = [
            SELECT  Id, Type_R1__c, ApexClass_R1__c, Method_R1__c, Message_R1__c
            FROM    ApexDebuglog_R1__c
            WHERE   Method_R1__c = 'createInformationLog'
        ];

        System.assertEquals(1, lstLogsCreated.size());
        System.assertEquals('Information', lstLogsCreated.get(0).Type_R1__c);
        System.assertEquals('ApexDebugLog_Test', lstLogsCreated.get(0).ApexClass_R1__c);
        System.assertEquals('Logging Information from an Apex Class - ApexDebugLog_Test', lstLogsCreated.get(0).Message_R1__c);
    }

    testMethod
    static void ws_createErrorLog(){
        try{
            Integer result = 1 / 0;
        }
        catch(Exception ex){
            ApexDebugLog.createLog(
                '{"Type" : "Error","ApexClass" : "ApexDebugLog_Test","Method" : "createErrorLog","RecordId" : "","Message" : "System.MathException: Divide by 0","StackTrace" : "Line: 1, Column: 1 System.MathException: Divide by 0"}'
            );

            List<ApexDebuglog_R1__c> lstLogsCreated = [
                SELECT  Id, Type_R1__c, ApexClass_R1__c, Method_R1__c
                FROM    ApexDebuglog_R1__c
                WHERE   Method_R1__c = 'createErrorLog'
            ];

            System.assertEquals(1, lstLogsCreated.size());
            System.assertEquals('Error', lstLogsCreated.get(0).Type_R1__c);
            System.assertEquals('ApexDebugLog_Test', lstLogsCreated.get(0).ApexClass_R1__c);
        }
    }

    testMethod
    static void ws_createInformationLog(){
        ApexDebugLog.createLog(
            '{"Type" : "Information","ApexClass" : "ApexDebugLog_Test","Method" : "createInformationLog","RecordId" : "","Message" : "Logging Information from an Apex Class - ApexDebugLog_Test"}'
        );

        List<ApexDebuglog_R1__c> lstLogsCreated = [
            SELECT  Id, Type_R1__c, ApexClass_R1__c, Method_R1__c, Message_R1__c
            FROM    ApexDebuglog_R1__c
            WHERE   Method_R1__c = 'createInformationLog'
        ];

        System.assertEquals(1, lstLogsCreated.size());
        System.assertEquals('Information', lstLogsCreated.get(0).Type_R1__c);
        System.assertEquals('ApexDebugLog_Test', lstLogsCreated.get(0).ApexClass_R1__c);
        System.assertEquals('Logging Information from an Apex Class - ApexDebugLog_Test', lstLogsCreated.get(0).Message_R1__c);
    }
}