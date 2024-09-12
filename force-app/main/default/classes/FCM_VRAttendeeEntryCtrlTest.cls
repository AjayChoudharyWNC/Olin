/*
* Created by beclassen on 4/24/2017.
*/

@isTest
private class FCM_VRAttendeeEntryCtrlTest {
    
    private static Account acct;
    private static List<Account> accounts;
    private static List<Contact> contacts;
    private static FCM_VisitReport__c visitReport;
    private static FCM_VRAttendee__c objAtendee;
    
    @testSetup static void setUp(){
        
       
        
        // Create internal account
        Id BusinessAccRecTypeId = [SELECT id,Name,SObjectType FROM RecordType where SObjectType = 'Account' and Name = 'Corporate'].id;
        Account acct1 = new Account(Name = 'FastChem Cooperation', RecordTypeId = BusinessAccRecTypeId);
        insert acct1;
        
        AccountName__c acctName = new AccountName__c();
        acctName.Name = 'FastChem Corp';
        acctName.OlinAccountValue__c = acct1.id;
        insert acctName;    
        
        Profile profileAdmin = [Select Id from Profile where name = 'System Administrator'];
        system.debug('::ID Profile::'+profileAdmin.id);             
        
      //  User user_test= new User( ProfileId = profileAdmin.id, Username = 'contactAdminOlin@test.com', Alias = 'Admin', Email = 'contactAdminOlin@test.com',userRoleId = userinfo.getUserRoleId(),
                            //     EmailEncodingKey = 'UTF-8',Firstname = 'test',Lastname = 'user', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US',TimeZoneSidKey = 'America/Los_Angeles');
       // insert user_test; 
          
       // system.debug('user_test'+user_test);
      //  User userAdmin = user_test;//[SELECT id,userRoleId FROM User Where email = 'contactAdminOlin@test.com' Limit 1]; 
      //  system.debug('userAdmin'+userAdmin.UserRoleId);
      //  system.debug('::::: ID user ::'+ userAdmin);
      //  System.runAs(userAdmin) {
            //now test data set
            Id acctId = [Select Id,name From RecordType where sobjecttype = 'Account' and DeveloperName = 'Standard' and isActive = True Limit 1].id;
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
                    //Email = 'Olin.Test.' + i + '@' + 'fastchem.com.dev',
                    RecordTypeId = contId));
            }
            insert contacts;
            
            //visitReport = FCM_TestDataFactory.createVisitReport(acct);
            FCM_VisitReport__c visitReport = new FCM_VisitReport__c(
                FCM_Account__c = acct.Id,
                FCM_Status__c = 'Planned',
                FCM_VisitDate__c = Date.today()
            );
            insert visitReport;
            
            system.debug(':::::: visitReport ' + visitReport.Id);
            
            FCM_VRAttendee__c objAtendee = new FCM_VRAttendee__c(
                FCM_VisitReport__c = visitReport.Id, 
                FCM_Contact__c = [Select ID From Contact Where AccountId = :acct.Id and LastName = 'Test 1' and RecordTypeId = :contId Limit 1 ].id
            );
            insert objAtendee;
            
            system.debug(':::::: objAtendee ' + objAtendee.Id);
       // }
    }
    // The first test will check whether the search engine is working as expected
    static testMethod void testContactSearch(){
        //setUp();
        
        test.startTest();
       // User userAdmin = [SELECT id FROM User Where email = 'contactAdminOlin@test.com' Limit 1]; 
       // System.runAs(userAdmin) {
            ID accountID = [Select Id,name From Account where name='test account' Limit 1].id;
            ID callReportID = [Select Id,name From FCM_VisitReport__c where FCM_Account__c= :accountID Limit 1].id;
            system.debug('####### visitReport.I 1 ########' + accountID);
            PageReference pageRef = Page.FCM_VRAttendeeEntry;
            Test.setCurrentPageReference(pageRef);
            system.debug('####### visitReport.I 2 ########' + callReportID);
            pageRef.getParameters().put('ID',callReportID);
            system.debug('####### acct.Id ########' + accountID);
            pageRef.getParameters().put('ACCID',accountID);
            
            
            // First we test searching for contacts which are related to the account linked to the Visit Report. 
            FCM_VRAttendeeEntryCtrl vrcc = new FCM_VRAttendeeEntryCtrl();
            vrcc.ContactTypeFilter = 'Related to Account'; 
            vrcc.updateAvailableList();
            
            // As there is no contact with the provided first name we expect the List of available contacts to be empty.
            //System.assertEquals(2, vrcc.allAvailableContact.size());
            
            // Now we for a specific Contact within the List.
            vrcc.CntLastName = 'Test 1';
            vrcc.cntFirstName = 'Olin';
            vrcc.accName ='test account';
            vrcc.updateAvailableList();
            
            // We expect 1 contact records within the available contact list
            //System.assertEquals(1, vrcc.allAvailableContact.size());
        //}
        test.stopTest();
    }
    
    static testMethod void testAddingAndDeletingContacts(){
        
        //setUp();
        
        test.startTest();
      //  User userAdmin = [SELECT id FROM User Where email = 'contactAdminOlin@test.com' Limit 1]; 
       // System.runAs(userAdmin) {
            ID accountID = [Select Id,name From Account where name='test account' Limit 1].id;
            ID callReportID = [Select Id,name From FCM_VisitReport__c where FCM_Account__c= :accountID Limit 1].id;
            system.debug('::::: visitReport.I 1 ' + accountID);
            PageReference pageRef = Page.FCM_VRAttendeeEntry;
            Test.setCurrentPageReference(pageRef);
            system.debug('::::: visitReport.I 2 ' + callReportID);
            pageRef.getParameters().put('ID',callReportID);
            system.debug('::::: acct.Id ' + accountID);
            pageRef.getParameters().put('ACCID',accountID);
            
            FCM_VRAttendeeEntryCtrl vrcc = new FCM_VRAttendeeEntryCtrl();
            vrcc.CntLastName = 'Test 1';
            vrcc.cntFirstName = 'Olin';
            vrcc.accName ='test account'; 
            vrcc.ContactTypeFilter = 'Related to Account';
            
            
            
            // We expect a list of three contacts within the list of contacts when the UseAccContact checkbox is set to true. 
            //System.assertEquals(3, vrcc.allAvailableContact.size());
            ID contactId = [Select Id, Name From Contact where  AccountId = :accountID And FirstName = 'Olin' And LastName = 'Test 101' ].ID;
            // We select one contact from the list and add him to the list of visit attendees. 
            vrcc.toSelect = contactId;
            vrcc.updateAvailableList();
            vrcc.addToContactList();
            vrcc.onSave();
            
            // We expect that one visit attendee is linked to the visit report and that the updated list of contacts now has 2 instead of 3 entries
            //System.assertEquals(1, vrcc.existingContact.size());
            //System.assertEquals(2, vrcc.allAvailableContact.size());
            
            
            // We remove the attendees added before and check that the have been removed with success. The list of available contacts will increase again to 3.
            for (FCM_VRAttendee__c var : vrcc.existingContact){
                var.FCM_IsToBeDeleted__c = true;
                break;
            }
            vrcc.removeFromContactList();
            vrcc.onSave();
            
            //System.assertEquals(0, vrcc.existingContact.size());
            //System.assertEquals(3, vrcc.allAvailableContact.size());
            vrcc.getContactTypes();
            vrcc.onCancel();
//        }
        test.stopTest();
    }
    
}