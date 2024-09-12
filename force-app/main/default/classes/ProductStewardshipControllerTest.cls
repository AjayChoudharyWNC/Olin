@isTest
public class ProductStewardshipControllerTest {

    static testMethod void test1(){
        Account ac1 = new Account(Name='test account1',AccountNumber_R1__c='123',Sold_To__c = TRUE, Ship_To__c = TRUE, RecordTypeId = '012f4000000bAVAAA2', AccountSource='S4');
        insert ac1;
        Account ac2 = new Account(Name='test account2',AccountNumber_R1__c='1234',Sold_To__c = TRUE, Ship_To__c = TRUE, RecordTypeId = '012f4000000bAVAAA2', AccountSource='S4');
        insert ac2;
        
        Account_Relationships__c ar1 = new Account_Relationships__c(Name='test account2',Sold_To__c=ac1.id, ship_To__c=ac2.id,Relationship_Type__c = 'Sold To / Ship To');
        
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
            Business_Group__c = 'GCO',
            PH1_Performance_Center__c = 'CHLORINE',
            IsActive = TRUE
        );
        insert testProduct;
        SAP_Onboarding__c sap = new SAP_Onboarding__c();
        sap.On_boarding_Request_Type__c = 'New Sold-To w/ Ship-to & Product';
        sap.Account__c = ac1.Id;
        sap.Ship_To_Account__c = ac2.Id;
        sap.Form_Due_Date__c = Date.today().addDays(5);
        sap.Send_Invitation_Email_to_Main_Contact__c = 'No';
        sap.Customer_Information_Status__c = 'Sent To Customer';
        sap.Order_Placement_Status__c = 'Sent To Customer';
        sap.Credit_Application_Status__c = 'Sent To Customer';
        sap.Product_Stewardship_Status__c = 'Sent To Customer';
        insert sap;
       
        
        Onboarding_Ship_To__c ship = new Onboarding_Ship_To__c();
        ship.SAP_Onboarding__c = sap.Id;
        ship.Ship_To_Country__c = 'US';
        insert ship;
       
        PurchasedProduct_R1__c purchased = new PurchasedProduct_R1__c();
        purchased.Account_R1__c = ac1.id;
        purchased.Product_R1__c = testProduct.Id;
        purchased.Account_Relationship__c = ar1.id;
        purchased.Ship_To__c = ac2.id;
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
        
        PageReference pageRef = Page.HydroChloricAcidRailCarPDF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', ques.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(ques);
        ProductStewardshipController pc = new ProductStewardshipController(sc);
        ship.Ship_To_Country__c = 'Canada';
        update ship;
        ProductStewardshipController pc1 = new ProductStewardshipController(sc);
         PageReference pageRef1 = Page.CreditApplicationPDF;
        Test.setCurrentPage(pageRef1);
        ApexPages.currentPage().getParameters().put('id', sap.Id);
        ApexPages.StandardController sc1 = new ApexPages.StandardController(sap);
        CreditApplicationPDFController ca = new CreditApplicationPDFController(sc1);
        //CustomerSetupPDFController cs = new CustomerSetupPDFController(sc1);
        
    }
}