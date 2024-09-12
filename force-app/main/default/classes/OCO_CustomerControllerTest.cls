@isTest
public class OCO_CustomerControllerTest {
    
    static testMethod void test1(){
        Horizon_Year__c hz = new Horizon_Year__c();
        hz.Name = 'Default';
        hz.Year__c = 2024;
        insert hz;
        Account ac1 = new Account(Name='test account1',AccountNumber_R1__c='123', AccountSource='Olin Heritage', RecordTypeId='012f4000000bAVAAA2',Ship_To__c = True, Sold_To__c = True);
        insert ac1;
        Account ac2 = new Account(Name='test account2',AccountNumber_R1__c='1234', AccountSource='Olin Heritage',RecordTypeId='012f4000000bAVAAA2',Ship_To__c = True, Sold_To__c = True);
        insert ac2;
        AccountTeamMember tm = new AccountTeamMember();
        tm.AccountId = ac1.Id;
        tm.UserId = UserInfo.getUserId();
        insert tm;
        
        Contact con = new Contact();
        con.LastName = 'test con';
        con.AccountId = ac2.Id;
        con.Email = 'test@gmail.com';
        insert con;
        Contact con1 = new Contact();
        con1.LastName = 'test con';
        con1.AccountId = ac1.Id;
        con1.Email = 'test+5@gmail.com';
        insert con1;
        Contact con2 = new Contact();
        con2.LastName = 'test con';
        con2.AccountId = ac2.Id;
        con2.Email = 'test+1@gmail.com';
        insert con2;
        Contact con3 = new Contact();
        con3.LastName = 'test con';
        con3.AccountId = ac2.Id;
        con3.Email = 'test+2@gmail.com';
        insert con3;
        Contact con4 = new Contact();
        con4.LastName = 'test con';
        con4.AccountId = ac2.Id;
        con4.Email = 'test+3@gmail.com';
        insert con4;
         Contact con5 = new Contact();
        con5.LastName = 'test con';
        con5.AccountId = ac2.Id;
        con5.Email = 'test+4@gmail.com';
        insert con5;
         Contact con6 = new Contact();
        con6.LastName = 'test con';
        con6.AccountId = ac2.Id;
        con6.Email = 'test+6@gmail.com';
        insert con6;
        Product2 testProduct = new Product2(
            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
            Name = 'Test Product',
            ProductCode = '105001',
            Product_Level__c = 'GMID',
            Business_Group__c = 'GCO'
        );
        testProduct.IsActive = true;
        insert testProduct;
        SAP_Onboarding__c sap = new SAP_Onboarding__c();
        sap.On_boarding_Request_Type__c = 'New Sold-To w/ Ship-to & Product';
        sap.Account__c = ac1.Id;
        sap.Ship_To_Account__c = ac2.Id;
        sap.Send_Invitation_Email_to_Main_Contact__c = 'Yes';
        sap.Main_Onboarding_Contact__c = con1.Id;
        sap.Form_Due_Date__c = Date.today().addDays(5);
        sap.Customer_Information_Status__c = 'Sent To Customer';
        sap.Order_Placement_Status__c = 'Sent To Customer';
        sap.Credit_Application_Status__c = 'Sent To Customer';
        sap.Product_Stewardship_Status__c = 'Sent To Customer';
        sap.Account_Payable_Email__c = 'test+6@gmail.com';
        sap.Contract_Notification_Email__c = 'test+4@gmail.com';
        sap.Credit_Email__c = 'test@gmail.com';
        sap.Sales_Rep__c = UserInfo.getUserId();
        sap.Credit_Last_Name__c = 'test9';
        sap.CXO_Officer_Email__c = 'test+1@gmail.com';
        sap.Account_Payable_Last_Name__c = 'test7';
        sap.CXO_Officer_Last_Name__c = 'test8';
        sap.Order_Placement_Email__c = 'test+2@gmail.com';
        sap.Order_Placement_Last_Name__c = 'test10';
        sap.Email_Invoice_Email_Address__c = 'test+3@gmail.com';
        sap.Email_Invoice_Last_Name__c = 'test11';
        sap.Contract_Notification_Last_Name__c = 'test55';
        insert sap;
        sap.CXO_Officer_Email__c = 'test+11@gmail.com';
        update sap;
        Application_User__c ap = new Application_User__c();
        ap.First_Name__c = 'test';
        ap.Last_Name__c = 'test';
        ap.Email__c = 'test@gmail.com';
        ap.Active__c = true;
        ap.SAP_Onboarding__c = sap.Id;
        ap.Title__c = 'Manager';
        ap.Contact__c = con.Id;
        insert ap;
        
        Application_User__c ap1 = new Application_User__c();
        ap1.First_Name__c = 'test';
        ap1.Last_Name__c = 'test';
        ap1.Email__c = 'test123@gmail.com';
        ap1.Active__c = true;
        ap1.SAP_Onboarding__c = sap.Id;
        ap1.Title__c = 'Manager';
        ap1.Contact__c = con.Id;
        insert ap1;
        
        Onboarding_Ship_To__c ship = new Onboarding_Ship_To__c();
        ship.SAP_Onboarding__c = sap.Id;
        insert ship;
        Assessment_Selector__c ast = new Assessment_Selector__c();
        ast.Product__c = testProduct.Id;
        ast.Ship_Mode__c = 'Barge';
        ast.Hazard_Category__c = 'Low';
        ast.Assessment_Document__c = 'Sodium Hydroxide';
        ast.Site_Assessment_Needed__c = 'Yes';
        insert ast;
        PurchasedProduct_R1__c purchased = new PurchasedProduct_R1__c();
        purchased.Account_R1__c = ac1.id;
        purchased.Product_R1__c = testProduct.Id;
        purchased.Performance_Center__c = 'CHLORINE';	
        insert purchased;
        Onboarding_Product__c op = new Onboarding_Product__c();
        op.SAP_Onboarding__c = sap.id;
        op.Business_Group__c = 'GCO';
        op.Ship_Mode__c = '04';
        op.Purchased_Product__c = purchased.id;
        op.Estimated_Volume__c = 3;
        op.Volume_Period__c = 'Year';
        op.Is_a_Ship_To_Site_Assessment_Needed__c = 'Yes';
        op.Is_a_Shipment_Questionnaire_Needed__c = 'Yes';
        op.Onboarding_Ship_To__c = ship.Id;
        insert op;
        
        Questionnaire__c ques = new Questionnaire__c();
        ques.SAP_Onboarding__c = sap.Id;
        ques.Onboarding_Product__c = op.id;
        ques.Account_Name__c = ac1.Id;
        ques.RecordTypeId = schema.SObjectType.Questionnaire__c.getRecordTypeInfosByName().get('Sodium Hydroxide - Barge').getRecordTypeId();
        insert ques;
        
        
        Test.startTest();
        OCO_CustomerController.getForms('', sap.Id);
        OCO_CustomerController.getShipToDetails(ship.Id);
        OCO_CustomerController.getShipToAndProducts(sap.Id);
        OCO_CustomerController.fetchAppUsers(sap.Id, 'FORM946', 'test@gmail.com');
        OCO_CustomerController.fetchAccountDetails(sap.Id, '');
        VAT__c vt = new VAT__c();
        vt.Country__c = 'Afghanistan  (AF)';
        vt.Tax_Type__c = 'Tax Number';
        vt.SAP_Onboarding__c = sap.Id;
        OCO_CustomerController.saveVat(new List<VAT__c>{vt}, true);
        VAT__c vat = new VAT__c();
        vat.Country__c = 'Afghanistan  (AF)';
        vat.Tax_Type__c = 'Tax Number';
        vat.SAP_Onboarding__c = sap.Id;
        insert vat;
        String vatFileId = OCO_CustomerController.saveFile(vat.Id, 'taxFile', 'tejbkfnsfer', 'image/jpeg', '', 'taxFile');
        OCO_CustomerController.saveFile(vat.Id, 'taxFile', 'tejbkfnsfer', 'image/jpeg', vatFileId, 'taxFile');
        String quesFileId = OCO_CustomerController.saveFile(ques.Id, 'QuestionnaireFile', 'tejbkfnsfer', 'image/jpeg', '', 'QuestionnaireFile');
        OCO_CustomerController.fetchAttachments('', 'taxFile');
        OCO_CustomerController.disbleForProfile(sap.Id);
        OCO_CustomerController.getCurrentUser();
        OCO_CustomerController.getCreditInfo(ap.Id);
        OCO_CustomerController.saveAppUser('test123@gmail.com', 'English');
        OCO_CustomerController.getLanguageFileBody();
        OCO_CustomerController.getSapRecord(sap.Id, '');
        OCO_CustomerController.getVatRecords(sap.Id);
        OCO_CustomerController.fetchAttachments('', 'QuestionnaireFile');
        op.After_Hours_Email__c = 'test@gmail.com';
        OCO_CustomerController.updateOnboardingProduct(op);
        OCO_CustomerController.updateOnboardingShipTo(ship);
        OCO_CustomerController.getProductDetails(op.Id);
        OCO_CustomerController.sendEmailToAppUser(ap.Id, ap1.Id);
        OCO_CustomerController.getQuestionnaire(op.Id);
        OCO_CustomerController.getCurrentUser();
        OCO_CustomerController.getAppUserRecord('test@gmail.com');
        vt.VAT_Tax_Number__c = '1653';
        OCO_CustomerController.updateVatRecords(new List<VAT__c> {vt});
        OCO_CustomerController.saveQuestionnaire(new List<Questionnaire__c>{ques}, false);
        OCO_CustomerController.deleteVat(vt.Id);
        OCO_CustomerController.deleteAttachment(vatFileId);
        OCO_CustomerController.deleteAppUserRecord(ap1.Id);
        sap.Customer_Information_Status__c = 'Customer Submitted';
        OCO_CustomerController.saveSapOnboarding(sap, ap.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(sap);
        StewardshipPDFMain sf = new StewardshipPDFMain(sc);
        sf.hasChlorine = true;
        CustomerSetupPDFController cs = new CustomerSetupPDFController(sc);
        OCO_CustomerController.deleteAndSwitchQuestionnaire(ques.Id);
        OCO_CustomerController.deleteQuestionnaire(ques.Id);
        Test.stopTest();
        
    }
}