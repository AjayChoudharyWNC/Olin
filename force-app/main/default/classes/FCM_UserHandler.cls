/*------------------------------------------------------------
Author:        Taurun Kaushik
Company:       Deloitte
Description:   This Controller helps in creating a contact for each new user
User Story:    -              
History
<Date>      <Authors Name>     <Brief Description of Change>
06.03.2017  Christian Conrad   Put method to future to avoid mixed DML operations
15.12.2017  Christian Conrad   Adjusted according to security review
06.11.2017  Taruan Kaushik     Initial version
------------------------------------------------------------*/
public class FCM_UserHandler
{
    /*
    MethodName :    HandleContactForTheNewUser
    Argument Type:  List of User IDs
    Return Type :   Void
    Description :   Helps in Creating a new Contact for the new User Asynchronously
    */
    @future
    public static void HandleContactForTheNewUser(List<Id> UserIDList)
    {
        List<Contact> conCreateUpdateList = new List<Contact>();


        //Fetch the RecordType Id and Account ID for Fastchem Employees from Contact
        Id ConRecTypeId = [SELECT id,Name,SObjectType FROM RecordType where SObjectType='Contact' and DeveloperName='Employees' and isActive = True LIMIT 1].id;
        Id fcmAccountId = [select OlinAccountValue__c from AccountName__c limit 1].OlinAccountValue__c;
/* Debug to verify the vlaues for the record types for each object.
 * 
 * System.debug('ConRecTypeId = ' + ConRecTypeId);
System.debug('fcmAccountId = ' + fcmAccountId);    */    
        
        List<string> accessFieldListUser = new List<string>{
                'Id',
                'FirstName',
                'MiddleName',
                'LastName',
                'Email',
                'Title',
                'Phone',
                'IsActive'
        };
        FCM_Common_Utility.CheckFLSAccess('User',accessFieldListUser,FCM_Common_Utility.FLS_ACCESS.ACCESSIBILE);

        List<string> accessFieldListContact = new List<string>{
                'AccountId',
                'FirstName',
                'MiddleName',
                'LastName',
                'Email',
                'Phone',
                'Title',
                'Active_R1__c',
                'UserId_R1__c'
        };
        FCM_Common_Utility.CheckFLSAccess('Contact',accessFieldListContact,FCM_Common_Utility.FLS_ACCESS.CREATEBLE);
        
        for(User usr:[SELECT Id,FirstName,MiddleName,LastName,Email,Title,phone,UserRole.Name,IsActive from User where Id IN :UserIDlist])
        {

            Contact con = New Contact();
            con.AccountId = fcmAccountId;
            con.RecordTypeId = ConRecTypeId;
            con.FirstName = usr.FirstName;
            con.MiddleName = usr.MiddleName;
            con.LastName = usr.LastName;
            con.Email = usr.Email;
            con.Phone = usr.Phone;
            con.Title = usr.Title;
            con.Active_R1__c = usr.IsActive;
            con.UserId_R1__c = usr.Id;
            conCreateUpdateList.add(con);
        }
        if(conCreateUpdateList.size()>0)
            upsert conCreateUpdateList UserId_R1__c;

    }
}