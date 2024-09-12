@isTest
public class OnboardLoginController_Test {
    public static testMethod void test1()
    {
        Onboard_Site_Access__c oc = new Onboard_Site_Access__c();
        oc.Name = 'Default';
        oc.UserName__c = 'ajay@wakencode.com.olincustomer.dev';
        oc.Password__c = 'Abcd@#1234';
        insert oc;
        Account acc = new Account(Name='Test Account',type='Customer', AccountNumber_R1__c='123',AccountSource='Blue Cube');
        insert acc;
        Contact con = new Contact(LastName = 'Test', Email = 'test@gmail.com', AccountId = acc.Id);
        insert con;
        SAP_Onboarding__c sap = new SAP_Onboarding__c(Send_Invitation_Email_to_Main_Contact__c = 'No',On_boarding_Request_Type__c = 'New Sold-To w/ Ship-to & Product', Form_Due_Date__c = Date.today().addDays(5), SAP_Onboarding_Form_Step__c = 'Contact', Account__c = acc.Id );
        insert sap;
        Application_User__c appU = new Application_User__c(First_Name__c = 'test',Last_Name__c = 'test', Email__c = 'test@gmail.com');
        insert appU;
        test.startTest();
        OnboardLoginController login = new OnboardLoginController();
        OnboardFooterController f = new OnboardFooterController();
        login.email = 'test@gmail.com';
        login.languageHeaderString = '["Id","English","Chinese"]';
        login.sendAccessCode();
        login.onBoardLogin();
        login.sendAccessCodeAgain();
        login.setLanguageHeders();
        test.stopTest();
    }
}