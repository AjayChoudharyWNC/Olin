/**
* Class name : CustomerOrLeadLookupController
* Description : Controller class for 'CustomerOrLeadLookup.cmp'
*/
public without sharing class CustomerOrLeadLookupController {
    @AuraEnabled
    public static RecordsWrapper fetchRecords(String searchText, String sortDirectionLead, String sortDirectionAcc, String sortDirectionOpp, String sortDirectionCon, String sortByLead, String sortByAcc, String sortByOpp, String sortByCon) {
        List<Lead> lstLeads;
        List<AccountsWrapper> lstAccounts;
        List<LocationsWrapper> lstLocations;
        List<ContactsWrapper> lstContacts;
        lstLeads = fetchLeads(searchText, sortDirectionLead, sortByLead);
        lstAccounts = fetchAccounts(searchText, sortDirectionAcc, sortByAcc);
        lstLocations = fetchLocations(searchText, sortDirectionOpp, sortByOpp);
        lstContacts = fetchContacts(searchText, sortDirectionCon, sortByCon);
        return new RecordsWrapper(lstLeads, lstAccounts, lstLocations, lstContacts);
    }
    private static List<Lead> fetchLeads(String searchText, String sortDirectionLead, String sortByLead) {
        string sortFullExpLead = sortByLead + ' ' + sortDirectionLead;
        searchText = String.escapeSingleQuotes(searchText);
        String strSOSL ='FIND \'' +searchText + '\' IN ALL FIELDS RETURNING '+
            'Lead(Id,Name, Status, Company, State, Country, Owner.Name, OwnerId order by ' + sortFullExpLead + ' ) ';
        List<List<sObject>> searchList = search.query(strSOSL);
        List<Lead> accList = (List<Lead>)searchList[0];
        return accList;
    }
    private static List<AccountsWrapper> fetchAccounts(String searchText, String sortDirectionAcc, String sortByAcc) {
        string sortFullExpAcc = sortByAcc + ' ' + sortDirectionAcc;
        System.debug('sortFullExpAcc = '+sortFullExpAcc);
        searchText = String.escapeSingleQuotes(searchText);
        String strSOSL = 'FIND \''+searchText+'\' IN ALL FIELDS RETURNING Account(Id,Name,Type,Type_Icon__c,BillingCity,BillingStateCode,BillingCountryCode,Owner.Name,OwnerId,AccountNumber_R1__c,LineOfBusiness_R1__c,Area_R1__c WHERE Sold_To__c = true ORDER BY '+sortFullExpAcc+')';
        system.debug('strSOSL---'+strSOSL);
        List<List<sObject>> searchList = search.query(strSOSL);
        system.debug('searchList---'+searchList);
        List<Account> accList = (List<Account>)searchList[0];
        List<Id> accIDs = new List<Id>();
        List<AccountsWrapper> accWrapper = new List<AccountsWrapper>();
        if(accList != null && accList.size() > 0){
            for(Account acc: accList){
                accIDs.add(acc.Id);
            }
            Map<Id,String> sharingMap = getSharingDetails(accIDs);
            for(Account acc: accList){
                AccountsWrapper aw = new AccountsWrapper();
                aw.acc = acc;
                aw.accessLevel = sharingMap.get(acc.Id);
                accWrapper.add(aw);
            }
        }
        return accWrapper;
    }
    private static List<LocationsWrapper> fetchLocations(String searchText, String sortDirectionOpp, String sortByOpp) {
        string sortFullExpOpp = sortByOpp + ' ' + sortDirectionOpp;
        System.debug('sortFullExpOpp = '+sortFullExpOpp);
        searchText = String.escapeSingleQuotes(searchText);
        //String strSOSL = 'FIND \'' +searchText + '\' IN ALL FIELDS RETURNING '+
        //    'FCM_Address__c(Id,Name,FCM_Account__c,FCM_Account__r.Name,FCM_Account__r.AccountNumber_R1__c,FCM_City__c,FCM_StateProvince__c,FCM_Country__c,LineofBusiness_R1__c, FCM_ExternalId__c, FCM_Status__c  order by ' + sortFullExpOpp + ' ) ';
               String strSOSL = 'FIND \''+searchText+'\' IN ALL FIELDS RETURNING Account(Id,Name,Type,Type_Icon__c,BillingCity,BillingStateCode,BillingCountryCode,Owner.Name,OwnerId,AccountNumber_R1__c,LineOfBusiness_R1__c,Area_R1__c WHERE Ship_To__c = true ORDER BY '+sortFullExpOpp+')';
        List<List<sObject>> searchList = search.query(strSOSL);
        List<Account> accList = (List<Account>)searchList[0];
        List<Id> accIDs = new List<Id>();
        List<LocationsWrapper> accWrapper = new List<LocationsWrapper>();
        if(accList != null && accList.size() > 0){
            for(Account acc: accList){
                accIDs.add(acc.Id);
            }
            Map<Id,String> sharingMap = getSharingDetails(accIDs);
            for(Account acc: accList){
                LocationsWrapper aw = new LocationsWrapper();
                aw.loc = acc;
                aw.accessLevel = sharingMap.get(acc.Id);
                accWrapper.add(aw);
            }
        }
        return accWrapper;
    }
    private static List<ContactsWrapper> fetchContacts(String searchText, String sortDirectionCon, String sortByCon) {
        string sortFullExpCon = sortByCon + ' ' + sortDirectionCon;
        searchText = String.escapeSingleQuotes(searchText);
        String strSOSL = 'FIND \'' +searchText + '\' IN ALL FIELDS RETURNING '+
            'Contact(Id,FirstName, LastName,AccountId, Phone,Account.Name,Account.AccountNumber_R1__c,MailingStateCode,MailingCountryCode,Title,Account.Owner.Name,Account.Owner.Id,MailingCity,MailingCountry, Email order by ' + sortFullExpCon + ' ) ';
        List<List<sObject>> searchList = search.query(strSOSL);
        List<Contact> accList = (List<Contact>)searchList[0];
        List<Id> accIDs = new List<Id>();
        List<ContactsWrapper> accWrapper = new List<ContactsWrapper>();
        if(accList != null && accList.size() > 0){
            for(Contact acc: accList){
                if(acc.AccountId != null){
                    accIDs.add(acc.AccountId);
                }
            }
            if(accIDs.size() > 0){
                Map<Id,String> sharingMap = getSharingDetails(accIDs);
                for(Contact acc: accList){
                    if(sharingMap.containsKey(acc.AccountId)){
                        ContactsWrapper aw = new ContactsWrapper();
                        aw.con = acc;
                        aw.accessLevel = sharingMap.get(acc.AccountId);
                        accWrapper.add(aw);
                    }
                }
            }
        }
        return accWrapper;
    }
    public class RecordsWrapper {
        @AuraEnabled public List<Lead> lstLeads { get;set; }
        @AuraEnabled public List<AccountsWrapper> lstAccounts { get;set; }
        @AuraEnabled public List<LocationsWrapper> lstLocations { get;set; }
        @AuraEnabled public List<ContactsWrapper> lstContacts { get;set; }
        public RecordsWrapper(List<Lead> lstLeads, List<AccountsWrapper> lstAccounts, List<LocationsWrapper> lstLocations, List<ContactsWrapper> lstContacts)
        {
            this.lstLeads = lstLeads;
            this.lstAccounts = lstAccounts;
            this.lstLocations = lstLocations;
            this.lstContacts = lstContacts;
        }
    }
    public class AccountsWrapper{
        @AuraEnabled public Account acc;
        @AuraEnabled public String accessLevel;
    }
    public class LocationsWrapper{
        @AuraEnabled public Account loc;
        @AuraEnabled public String accessLevel;
    }
    public class ContactsWrapper{
        @AuraEnabled public Contact con;
        @AuraEnabled public String accessLevel;
    }
    
    public static Map<Id,String> getSharingDetails(List<Id> parentIds){
        Map<Id,String> sharingMap = new Map<Id,String>();
        
        if(parentIds != null && parentIds[0].getSObjectType() == Schema.Account.SObjectType){
            List<Account> accTeamList = [SELECT Id,(SELECT Id,Account__c FROM Teams__r WHERE Team_Member__c =: UserInfo.getuserId() 
                                                    AND (Account_Access__c = 'Read Only' OR Account_Access__c = 'Read/Write'))
                                         FROM Account WHERE Id IN: parentIds LIMIT 50000];
            if(accTeamList != null && accTeamList.size() > 0){
                for(Account acc: accTeamList){
                    if(acc.Teams__r != null && acc.Teams__r.size() > 0){
                        sharingMap.put(acc.Id, 'Yes');
                    }
                    else{
                        sharingMap.put(acc.Id, 'No Access');
                    }
                }
            }
        }
        return sharingMap;
    }
}