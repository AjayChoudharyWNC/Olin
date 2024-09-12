@isTest
public class SapOnboardingAttachmentTest {
    
    static testMethod void test1(){
        Account ac1 = new Account(Name='test account1',AccountNumber_R1__c='123', AccountSource='Olin Heritage');
        insert ac1;
        Account ac2 = new Account(Name='test account32322',AccountNumber_R1__c='1243', AccountSource='Olin Heritage');
        insert ac2;
        Contact con = new Contact();
        con.LastName = 'test con';
        con.AccountId = ac1.Id;
        con.Email = 'test@gmail.com';
        insert con;
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
        sap.Form_Due_Date__c = Date.today().addDays(5);
        sap.Send_Invitation_Email_to_Main_Contact__c = 'No';
        insert sap;
        Application_User__c ap = new Application_User__c();
        ap.First_Name__c = 'test';
        ap.Last_Name__c = 'test';
        ap.Email__c = 'test@gmail.com';
        ap.Active__c = true;
        ap.SAP_Onboarding__c = sap.Id;
        ap.Title__c = 'Manager';
        ap.Contact__c = con.Id;
        insert ap;
        
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
         VAT__c vt = new VAT__c();
        vt.Country__c = 'Afghanistan  (AF)';
        vt.Tax_Type__c = 'Tax Number';
        vt.SAP_Onboarding__c = sap.Id;
        insert vt;
        Attachment att = new Attachment();
        att.ParentId = sap.Id;
        att.Body = Blob.valueOf('dada');
        att.Name = 'Test';
        insert att;
        Attachment att1 = new Attachment();
        att1.ParentId = ques.Id;
        att1.Body = Blob.valueOf('dada');
        att1.Name = 'Test';
        insert att1;
        Attachment att2 = new Attachment();
        att2.ParentId = vt.Id;
        att2.Body = Blob.valueOf('dada');
        att2.Name = 'Test';
        insert att2;
        //test for SapOnboardingAttachmentCard
        SapOnboardingAttachmentCard.prepareWrapper(new List<Attachment>{att});
        SapOnboardingAttachmentCard.createFileWrapper('Tax', sap.Id);
        SapOnboardingAttachmentCard.createFileWrapper('Finance', sap.Id);
        SapOnboardingAttachmentCard.createFileWrapper('Product', sap.Id);
        SapOnboardingAttachmentCard.createFileWrapper('Assessment', sap.Id);
        SapOnboardingAttachments.getCreditPermission();
      
       
    }

}