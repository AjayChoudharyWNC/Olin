/*------------------------------------------------------------
Author:        Taurun Kaushik
Company:       Deloitte
Description:   Trigger on user to invoke creation / update of related contact
User Story:    -              
History
<Date>      <Authors Name>     <Brief Description of Change>
15.12.2017  Christian Conrad   Adjusted according to security review
06.11.2017  Taruan Kaushik     Initial version
------------------------------------------------------------*/

trigger FCM_UserTrigger on User (after insert, after update) {
    if (Trigger.isInsert || Trigger.isUpdate) {
        List<Id> ids = new List<Id>();
        for( User item: Trigger.new )
            ids.add(item.id);
        FCM_UserHandler.HandleContactForTheNewUser( ids );
    }
}