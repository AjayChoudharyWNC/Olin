public class ManageAttendeesConfidential {
	@AuraEnabled
    public static  List<Contact> fetchContacts(String recordId , String conId){
        Set<Id> ContId = new Set<Id>();
        List<contact> availCon = new  List<contact>();
        List<Confidential_Call_Report_Attendee__c> existingContacts = [SELECT  Id, Confidential_Call_Report__c,  Confidential_Call_Report__r.Name, Confidential_Call_Report__r.FCM_Account__c, FCM_Contact__c , FCM_Contact__r.Email, FCM_Contact__r.Name, FCM_IsPrimaryContact__c, FCM_IsToBeDeleted__c, FCM_Contact__r.Account.Name 
                                                    FROM  Confidential_Call_Report_Attendee__c WHERE  Confidential_Call_Report__c =: recordId];
        for(Confidential_Call_Report_Attendee__c fc : existingContacts){
            ContId.add(fc.FCM_Contact__c);
        }
         List <Confidential_Call_Report__c> fcmlist =[ Select Id, Name , FCM_Account__c From Confidential_Call_Report__c where Id = : recordId];
        String  acc=  fcmlist[0].FCM_Account__c;
        String query = 'SELECT Id, Name, LastName, FirstName, Email, AccountId, Account.Name From Contact Where AccountId = :acc ';
        if(conId != '' && conId != null){
            query += ' AND Id !=\''+conId+'\'';
        }
        if(ContId.size()> 0){
            query += ' AND Id NOT IN : ContId';
        }
        system.debug('query'+query);
        query +=  ' ORDER BY Name ';
        availCon = database.query(query);
        return availCon;   
    }
      @AuraEnabled
    public static String FetchAccountName(String recordId){
        Confidential_Call_Report__c fcm =[ Select Id, Name , FCM_Account__c,FCM_Account__r.Name From Confidential_Call_Report__c where Id = : recordId];      
        String AccName = '';
        if(fcm.FCM_Account__c != null){
            AccName = String.valueof(fcm.FCM_Account__c) ;
        }
        return AccName;
    }
    @AuraEnabled
    public static List<Confidential_Call_Report_Attendee__c> searchContactRecords(String recordId){
        List<Confidential_Call_Report_Attendee__c> existingContacts = [SELECT  Id, Confidential_Call_Report__c, Confidential_Call_Report__r.FCM_Account__c, Confidential_Call_Report__r.Name, FCM_Contact__c , FCM_Contact__r.Email, FCM_Contact__r.Name, FCM_IsPrimaryContact__c, FCM_IsToBeDeleted__c, 
                                                    FCM_Contact__r.Account.Name FROM  Confidential_Call_Report_Attendee__c WHERE  Confidential_Call_Report__c =: recordId];
        system.debug('existingContacts'+existingContacts);
        return existingContacts;
    }
    @AuraEnabled
    Public Static void updatePrimaryField(String Selected, String recordId){
        List<Confidential_Call_Report_Attendee__c> attendeelist = new List<Confidential_Call_Report_Attendee__c>();
        List<Confidential_Call_Report_Attendee__c> existingContacts = [SELECT  Id, Confidential_Call_Report__c, Confidential_Call_Report__r.FCM_Account__c,  FCM_Contact__r.Name, FCM_IsPrimaryContact__c, FCM_IsToBeDeleted__c 
                                                    FROM  Confidential_Call_Report_Attendee__c WHERE  Confidential_Call_Report__c =: recordId];
        system.debug('existingContacts'+existingContacts);
        for(Confidential_Call_Report_Attendee__c fcm : existingContacts){
            if(fcm.id == Selected){
                fcm.FCM_IsPrimaryContact__c = true;
            }
            else{
                fcm.FCM_IsPrimaryContact__c = false; 
            }
            attendeelist.add(fcm);
        }
        update attendeelist;
    } 
    @AuraEnabled
    Public Static List<String> getContactTypes(){
        List<String> alloptionlist = new List<String>();
        Schema.DescribeFieldResult fieldResult = Confidential_Call_Report_Attendee__c.ContactFilterType_R1__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry p : ple)
            alloptionlist.add(p.getValue());
        return alloptionlist;
    }
    
    @AuraEnabled
    public Static void updateavailableList( String toSelect, String recordId){
        List<Confidential_Call_Report_Attendee__c>  attndeeList = new List<Confidential_Call_Report_Attendee__c>();
        for(Contact con : [SELECT Id, Name, LastName, FirstName, Email, AccountId, Account.Name From Contact]){
            if(con.Id ==  toSelect){
                Confidential_Call_Report_Attendee__c fc = new Confidential_Call_Report_Attendee__c();
                fc.Confidential_Call_Report__c = recordId;
                fc.FCM_Contact__c = con.Id;
                fc.FCM_IsPrimaryContact__c = false;
                fc.FCM_IsToBeDeleted__c = false;
                if(!attndeeList.contains(fc)){
                    attndeeList.add(fc); 
                }
            }
        }
        insert attndeeList ;  
    }
    
    @AuraEnabled
    public Static  List <Contact>  fetchSearchContacts( String fname, String Lname, String Aname , String Filters, String emailfilter, String recordId){
        Set<Id> ContId = new Set<Id>();
        List<Confidential_Call_Report_Attendee__c> existingContacts = [SELECT  Id, Confidential_Call_Report__c,  Confidential_Call_Report__r.Name, FCM_Contact__c , FCM_Contact__r.Email, FCM_Contact__r.Name, FCM_IsPrimaryContact__c, FCM_IsToBeDeleted__c, FCM_Contact__r.Account.Name 
                                                    FROM  Confidential_Call_Report_Attendee__c WHERE  Confidential_Call_Report__c =: recordId];
        for(Confidential_Call_Report_Attendee__c fc : existingContacts){
            ContId.add(fc.FCM_Contact__c);
        }
        List<String> querylist = new list <String>();
        List <Contact> availCon = new  List <Contact>();
        
        String query = 'SELECT Id, Name, LastName, FirstName, Email, AccountId, Account.Name From Contact Where Id NOT IN : ContId AND CreatedDate != null';
        if(fname != '' && fname != null){
            query +=' AND FirstName like \'%'+fname+'%\'';
        }
        if(Lname != '' && Lname != null){
            query += ' AND LastName like \'%'+Lname+'%\'';
        }
        if(Aname != '' && Aname != null){
            query += ' AND Account.Name like \'%'+Aname+'%\'';
        }
        if(emailfilter != '' && emailfilter != null){ 
            query += ' AND Email like \'%'+emailfilter+'%\'';
        }
        if(Filters != '' && Filters != null && String.isNotBlank(Filters)){
            if(Filters == 'Olin Contact'){ 
                String name = 'Olin Employee';
                query += ' AND RecordType.Name = \''+name+'\'';
            }
            else if(Filters == 'All Contacts'){    
                query += ' ORDER BY Name LIMIT 1000';
            }
            else if(Filters == 'Related to Account'){    
                List <Confidential_Call_Report__c> fcmlist = [Select Id, Name , FCM_Account__c From Confidential_Call_Report__c where Id = : recordId];
                query += ' AND AccountId =\''+fcmlist[0].FCM_Account__c+'\'';
            }
        }
        availCon = database.query(query);
        return availCon;  
    }
    @AuraEnabled
    public Static String  CreateContact(String Fname, String Lname, String Email ,String title, String Phone , String Avalue,  String recordId){
        string message;
        List<Contact> conList = [SELECT Id,Email FROM Contact WHERE (FirstName =: Fname AND LastName =: Lname AND AccountId =: Avalue) OR (Email != '' AND Email =: Email)];
        if(conList != null && conList.size() > 0){
            if(String.isNotBlank(conList[0].Email) && conList[0].Email == Email){
                message = 'New Contact could not be created because a contact is found with matching email in the system. Please try to search your contact using email filter in Search Contacts section';
            }
            else{
                message = 'New Contact could not be created because a contact is found for this account with matching name in the system. Please try to search your contact using First Name or Last Name filter in Search Contacts section';
            }
        }
        else{
            contact con = new Contact();
            con.FirstName = Fname;
            con.LastName = Lname;
            con.Email = Email;
            con.Title = title;
            con.Phone = Phone;
            con.AccountId = Avalue;
            con.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('External Contact').getRecordTypeId();
            insert con;
            Confidential_Call_Report_Attendee__c fcm = new  Confidential_Call_Report_Attendee__c();
            fcm.Confidential_Call_Report__c = recordId;
            fcm.FCM_Contact__r = con;
            fcm.FCM_Contact__c = con.Id; 
            fcm.FCM_IsPrimaryContact__c = false;
            fcm.FCM_IsToBeDeleted__c = false;
            insert fcm;
            message = 'Success';
        }
        return message;
    }
    @AuraEnabled
    public Static void removeContacts (String RecordId){
        List<Confidential_Call_Report_Attendee__c> removeAttendee = [SELECT Id FROM Confidential_Call_Report_Attendee__c WHERE  Id = : RecordId];
        Delete removeAttendee;
    }
}