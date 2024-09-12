@isTest
public class ConfidentialAttendeeEntryCtrlTest {
    
    @testSetup static void setUp(){
        
        // Create internal account
        Id BusinessAccRecTypeId = [SELECT id,Name,SObjectType FROM RecordType where SObjectType = 'Account' and Name = 'Olin Corp'].id;
        Account acct1 = new Account(Name = 'FastChem Cooperation', RecordTypeId = BusinessAccRecTypeId);
        insert acct1;
        
        AccountName__c acctName = new AccountName__c();
        acctName.Name = 'FastChem Corp';
        acctName.OlinAccountValue__c = acct1.id;
        insert acctName;    
        
        Profile profileAdmin = [Select Id from Profile where name = 'System Administrator'];
        system.debug('::ID Profile::'+profileAdmin.id);             
        
        Id acctId = [Select Id,name From RecordType where sobjecttype = 'Account' and DeveloperName = 'Customer' and isActive = True Limit 1].id;
        Account acct = new Account (name='test account',recordtypeid = acctId,AccountNumber_R1__c='1234567890',AccountSource='Blue Cube');
        insert acct;
        
        //contacts = FCM_TestDataFactory.createContacts(new List<Account>{acct}, 3);
        Id contId = [Select Id,name From RecordType where sobjecttype = 'Contact'  and DeveloperName = 'Contacts' and isActive = True limit 1].id;
        List<Contact> contacts = new List<Contact>();
        for (Integer i = 0; i < 102; i++) {
            contacts.add(new Contact(
                AccountId = acct.Id,
                LastName = 'Test ' + i,
                FirstName = 'Olin ',
                RecordTypeId = contId));
        }
        insert contacts;
        
        Confidential_Call_Report__c visitReport = new Confidential_Call_Report__c(
            FCM_Account__c = acct.Id,
            FCM_Status__c = 'Planned',
            FCM_VisitDate__c = Date.today()
        );
        
        insert visitReport;
        
        Confidential_Call_Report_Attendee__c objAtendee = new Confidential_Call_Report_Attendee__c(
            Confidential_Call_Report__c = visitReport.Id, 
            FCM_Contact__c = [Select ID From Contact Where AccountId = :acct.Id and LastName = 'Test 1' and RecordTypeId = :contId Limit 1 ].id
        );
        
        insert objAtendee;
        
    }
    
    // The first test will check whether the search engine is working as expected
    static testMethod void testContactSearch(){
        
        Test.startTest();
            
            ID accountID = [Select Id,name From Account where name='test account' Limit 1].id;
            ID callReportID = [Select Id,name From Confidential_Call_Report__c where FCM_Account__c= :accountID Limit 1].id;
            
            PageReference pageRef = Page.FCM_VRAttendeeEntry;
            Test.setCurrentPageReference(pageRef);
            
            pageRef.getParameters().put('ID',callReportID);
            
            pageRef.getParameters().put('ACCID',accountID);
            
            // First we test searching for contacts which are related to the account linked to the Visit Report. 
            ConfidentialAttendeeEntryCtrl vrcc = new ConfidentialAttendeeEntryCtrl();
            vrcc.ContactTypeFilter = 'Related to Account'; 
            vrcc.updateAvailableList();
            
            // Now we for a specific Contact within the List.
            vrcc.CntLastName = 'Test 1';
            vrcc.cntFirstName = 'Olin';
            vrcc.accName ='test account';
            vrcc.updateAvailableList();
        
        Test.stopTest();
        
    }
    
    @isTest
    private static void testAddingAndDeletingContacts(){
        
        Test.startTest();
        
            ID accountID = [Select Id,name From Account where name='test account' Limit 1].id;
            ID callReportID = [Select Id,name From Confidential_Call_Report__c where FCM_Account__c= :accountID Limit 1].id;
            
            PageReference pageRef = Page.FCM_VRAttendeeEntry;
            Test.setCurrentPageReference(pageRef);
            
            pageRef.getParameters().put('ID',callReportID);
            
            pageRef.getParameters().put('ACCID',accountID);
            
            ConfidentialAttendeeEntryCtrl vrcc = new ConfidentialAttendeeEntryCtrl();
            vrcc.CntLastName = 'Test 1';
            vrcc.cntFirstName = 'Olin';
            vrcc.accName ='test account'; 
            vrcc.ContactTypeFilter = 'Related to Account';
            
            ID contactId = [Select Id, Name From Contact where  AccountId = :accountID And FirstName = 'Olin' And LastName = 'Test 101' ].ID;
            
            // We select one contact from the list and add him to the list of visit attendees. 
            vrcc.toSelect = contactId;
            vrcc.updateAvailableList();
            vrcc.addToContactList();
            vrcc.onSave();
            
            // We remove the attendees added before and check that the have been removed with success. The list of available contacts will increase again to 3.
            for (Confidential_Call_Report_Attendee__c var : vrcc.existingContact){
                var.FCM_IsToBeDeleted__c = true;
                break;
            }
            vrcc.removeFromContactList();
            vrcc.onSave();
        
        Test.stopTest();
    }
    
}