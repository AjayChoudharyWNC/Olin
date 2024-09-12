/**
 * Created by deesingh on 30.10.2017.
 */

public with sharing class FCM_Common_Utility {


    public enum FLS_ACCESS {ACCESSIBILE, CREATEBLE, UPDATEBLE}


    public static void CheckFLSAccess(string objectName,List<string>fieldList,FLS_ACCESS access){
        
        // Obtain the field name/token map for the object
        Map<String,Schema.SObjectField> m = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();

        for (String fieldToCheck : fieldList) {
            // Check if the user has access to view field
                if (access == FLS_ACCESS.ACCESSIBILE && !m.get(fieldToCheck).getDescribe().isAccessible()) {

                    throw new System.NoAccessException();

                }
                else if (access == FLS_ACCESS.CREATEBLE && !m.get(fieldToCheck).getDescribe().isCreateable()) {

                    throw new System.NoAccessException();

                }
                else if (access == FLS_ACCESS.UPDATEBLE && !m.get(fieldToCheck).getDescribe().isUpdateable()) {

                    throw new System.NoAccessException();

                }
        }


    }

}