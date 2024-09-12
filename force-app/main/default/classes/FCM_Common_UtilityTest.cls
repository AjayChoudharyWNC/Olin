/**
 * Created by deesingh on 30.10.2017.
 */

@IsTest
private class FCM_Common_UtilityTest {

    static testMethod void testCheckFLSAccess() {

        //for test coverage
        FCM_Common_Utility.CheckFLSAccess('Opportunity',new List<string>{'Name'},FCM_Common_Utility.FLS_ACCESS.ACCESSIBILE);

        FCM_Common_Utility.CheckFLSAccess('Opportunity',new List<string>{'StageName'},FCM_Common_Utility.FLS_ACCESS.CREATEBLE);


    }


}