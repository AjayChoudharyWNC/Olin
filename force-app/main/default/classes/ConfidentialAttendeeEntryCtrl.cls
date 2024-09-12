/*
* Controller for VRAttendeeEntry page which lets the user add multiple visit attendees within one transaction
* instead of creating one junction record after the other.
*/

public with sharing class ConfidentialAttendeeEntryCtrl {
    
    public String cntFirstName {get;set;}
    public String cntLastName {get;set;}
    public String accName {get;set;}
    public Boolean overLimit {get;set;}
    public String toSelect {get; set;}
    public user  currentuser{get;set;}
    public Account acc {get;set;}
    public string uid = userinfo.getUserId();
    public Set<Id> selectedContactId {get;set;}
    public List<Confidential_Call_Report_Attendee__c> existingContact {get;set;}
    public List<Contact> allAvailableContact {get;set;}
    public List<Contact> olinContact {get;set;}
    public List<Confidential_Call_Report_Attendee__c> forDeletion = new List<Confidential_Call_Report_Attendee__c>();
    public List<SelectOption> options = new List<SelectOption>();
    public string ContactTypeFilter{get; set;}
    
    //variables to keep ID's and objects
    public ID masterRecId{get;set;}
    private ID accId = null;
    private ID primContactId = null; 
    private Map<Id,Contact> cntMap = new Map<Id,Contact>();
    
    
    public ConfidentialAttendeeEntryCtrl(){
        
        selectedContactId = new Set<Id>();
        masterRecId = ApexPages.currentPage().getParameters().get('ID');
        system.debug(':::::: masterRecId ' + masterRecId);
        String accIdStr = ApexPages.currentPage().getParameters().get('ACCID');
        system.debug(':::::: accIdStr ' + accIdStr);
        currentuser=new User();
        currentuser =[Select Id from User where Id=:userinfo.getuserId()]; 
        system.debug('\n\n\n currentuser ='+currentuser);
        if(accIdStr != null && accIdStr.Length()>14){
            accId = ApexPages.currentPage().getParameters().get('ACCID');
            
            ContactTypeFilter = 'Related to Account';  
            
            
            acc = [ 
                SELECT 
                Id, Name, RecordTypeId, RecordType.DeveloperName, ParentId 
                FROM 
                Account 
                WHERE 
                Id =:accId LIMIT 1
            ];
            
        }
        else
        {
            //  useAccContact = false;
            //  useOlinAccContact = true; 
        }         
        searchContactRecords();
        adddefaultUserContact();
    }
    
    /*
* Method to search for all contact records which have already been related to the Visit Report record.
* Those will be displayed within the upper page section.
*/
    private void searchContactRecords(){
        existingContact = [
            SELECT 
            Id, Confidential_Call_Report__c, FCM_Contact__c , FCM_Contact__r.Email, FCM_Contact__r.Name, FCM_IsPrimaryContact__c, FCM_IsToBeDeleted__c,
            FCM_Contact__r.Account.Name
            FROM 
            Confidential_Call_Report_Attendee__c
            WHERE 
            Confidential_Call_Report__c =: masterRecId
        ];
        
        
        for(Confidential_Call_Report_Attendee__c va : existingContact){
            selectedContactId.add(va.FCM_Contact__c);
            system.debug('\n\n\n selectedContactId Confidential_Call_Report_Attendee__c ='+selectedContactId.size());
        }   
        System.debug('=== number of elements: outside for ' + selectedContactId.size());      
        updateAvailableList();
    }
    
    public void updateAvailableList() {
        String sWhere = getQueryCondition();
        String query = 'SELECT Id, Name, LastName, FirstName, Email, AccountId, Account.Name, Account.ParentId, Account.Parent.Name From Contact';
        system.debug('::::::::::::::: query ' + query);
        query+=' WHERE '+sWhere + ' ORDER BY Name LIMIT 101';
        system.debug('\n\n\n query by Dev ='+query);
        allAvailableContact = database.query(query);
        system.debug('::::: allAvailableContact '+ allAvailableContact.size());
        if(allAvailableContact.size()==101){
            allAvailableContact.remove(100);
            overLimit = true;
        }
        else{
            overLimit=false;
        }
    }
    
    public String getQueryCondition(){
        List<String> accSearch = new List<string>();
        // String AcctNameCode = AccountName__c.getValues('Name').OlinAccountValue__c;
        List<AccountName__c> mcs = AccountName__c.getall().values();
        String AcctNameCode = mcs[0].name;
        system.debug('::::: AcctNameCode by Dev ='+AcctNameCode);
        if(String.IsNotEmpty(accName))
            accSearch.Add ('Account.Name like \'' +  TranslateTOSoql(accName)+'%\'' );              //Account name. Next it will return all contacts related with this account      
        if(String.IsNotEmpty(cntFirstName))
            accSearch.Add ('FirstName like \'' +  TranslateTOSoql(cntFirstName)+'%\'' );           //Contact first name
        if(String.IsNotEmpty(cntLastName))
            accSearch.Add ('LastName like \'' +  TranslateTOSoql(cntLastName)+'%\'' );             //Contact last name
        if(ContactTypeFilter == 'Related to Account' &&  String.IsNotEmpty(accId)){
            //accSearch.Add ('AccountId= \'' +  acc.Id+'\'' );
            List<AccountContactRelation> acrList = [SELECT ContactId FROM AccountContactRelation WHERE AccountId =: accId 
                                                    AND ContactId != null AND IsActive = true LIMIT 50000];
            if(acrList != null && acrList.size() > 0){
                String conIDs = '';
                for(AccountContactRelation acr: acrList){
                    conIDs += '\''+acr.ContactId+'\',';
                }
                conIDs = conIDs.removeEnd(',');
                accSearch.Add ('Id IN ('+conIDs+')');
            }
        }
            
        if(ContactTypeFilter == 'Olin Contact')    
            accSearch.Add ('Account.Name like \'' +  TranslateTOSoql(AcctNameCode)+'%\'' ); 
        system.debug('\n\n\n accSearch ='+accSearch);
        return searchForRecords(accSearch);
    }
    
    public string searchForRecords(List<String> accSearch){
        system.debug('\n\n\n selectedContactId ='+selectedContactId);
        String sWhere='Id NOT IN: selectedContactId';       
        for(String sToken: accSearch){
            sWhere+= ' AND ' + sToken;
        }
        return sWhere;
    }
    
    public static string TranslateTOSoql(String sval){
        if(sval==null) return '';
        sval=sval.replace('*','%');
        sval=sval.replace('?','_');
        return String.escapeSingleQuotes(sval);
    }
    
    public void adddefaultUserContact(){
        for(Contact cont : [SELECT Id, UserId_R1__c,Name, LastName, FirstName, Email, AccountId, Account.Name, Account.ParentId, Account.Parent.Name  From Contact where UserId_R1__c =: uid]){
            if (!selectedContactId.contains(cont.Id)) { /* do stuff */           
                existingContact.add(
                    new Confidential_Call_Report_Attendee__c(
                        Confidential_Call_Report__c = masterRecId,
                        FCM_Contact__r = cont,
                        FCM_Contact__c = cont.Id, 
                        FCM_IsPrimaryContact__c = false,
                        FCM_IsToBeDeleted__c = false)
                );
                selectedContactId.add(cont.Id);
                break;                                  
            }         
            updateAvailableList();
        }
    }
    
    
    public void addToContactList(){
        system.debug('::::: in addToContactList allAvailableContact '+ allAvailableContact);
        for(Contact con : allAvailableContact){
            system.debug('::::: con.Id = '+ con.Id + '::::: toSelect = ' + toSelect);
            if(con.Id == toSelect){
                existingContact.add(
                    new Confidential_Call_Report_Attendee__c(
                        Confidential_Call_Report__c = masterRecId,
                        FCM_Contact__r = con,
                        FCM_Contact__c = con.Id, 
                        FCM_IsPrimaryContact__c = false,
                        FCM_IsToBeDeleted__c = false)
                );
                selectedContactId.add(con.Id);
                break;
            }            
        }         
        updateAvailableList();
    }
    
    /**
* This function runs when a user hits "remove" on an item in the "Selected Products" section
*/
    public PageReference removeFromContactList(){
        for (integer i = 0; i < existingContact.size() ; i++) {
            if (existingContact[i].FCM_isToBeDeleted__c == true) {
                if(existingContact[i].Id != null) {
                    forDeletion.add(existingContact[i]);
                }
                
                selectedContactId.remove(existingContact[i].FCM_Contact__c);
                existingContact.remove(i);
                
                i--;
            }
        }
        
        updateAvailableList();
        
        return null;
    }
    
    public void onSave(){
        // If previously selected products are now removed, we need to delete them
        delete forDeletion;
        
        // Previously selected products may have new quantities and amounts, and we may have new products listed, so we use upsert here
        try{
            upsert existingContact;
        }
        catch(Exception e){
            ApexPages.addMessages(e);
            //return null;
        }  
        
        //return new PageReference('/' + masterRecId);
        //lightning/r/Confidential_Call_Report__c/a071D000000G7lfQAC/view
        //PageReference returnPage = new PageReference('/lightning/r/' + masterRecId +'/related/FCM_VRAttendees__r/view');
        PageReference returnPage = new PageReference('/lightning/r/Confidential_Call_Report__c/'+ masterRecId +'/view?ts='+DateTime.now().getTime());
        //returnPage.setredirect(true);
        //return null;
    } 
    
    /**
* If user hits cancel we commit no changes and return them to the Opportunity   
*/
    public PageReference onCancel(){
        return new PageReference('/' + masterRecId);
    }
    Public List<Selectoption> getContactTypes(){
        
        Schema.DescribeFieldResult fieldResult = Confidential_Call_Report_Attendee__c.ContactFilterType_R1__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry p : ple)
            options.add(new SelectOption(p.getValue(), p.getValue()));
        //options.add(new SelectOption('All Contacts','All Contacts'));
        //options.add(new SelectOption('Related To Account','Related To Account'));
        //options.add(new SelectOption('Olin Contact','Olin Contact'));  
        return options;
    }
    
}