@isTest
public class OnboardingProductTriggerTest {
    
    static testMethod void test1(){
        Horizon_Year__c hz = new Horizon_Year__c();
        hz.Name = 'Default';
        hz.Year__c = System.today().year() + 1;
        insert hz;
        Account ac1 = new Account(Name='test account1',AccountNumber_R1__c='123', AccountSource='Olin Heritage');
        insert ac1;
        Account ac2 = new Account(Name='test account2',AccountNumber_R1__c='123458', AccountSource='Olin Heritage');
        insert ac2;
        Contact con = new Contact();
        con.LastName = 'test con';
        con.AccountId = ac1.Id;
        con.Email = 'test@gmail.com';
        insert con;
        Contact con1 = new Contact();
        con1.LastName = 'test con';
        con1.AccountId = ac2.Id;
        con1.Email = 'test+55@gmail.com';
        insert con1;
        Product2 testProduct = new Product2(
            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
            Name = 'Test Product',
            ProductCode = '105001',
            Product_Level__c = 'GMID',
            Business_Group__c = 'GCO'
        );
        testProduct.IsActive = true;
        insert testProduct;
        Product2 testProduct1 = new Product2(
            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
            Name = 'Test Product',
            ProductCode = '1050001',
            Product_Level__c = 'GMID',
            Business_Group__c = 'GCO'
        );
        testProduct1.IsActive = true;
        insert testProduct1;
        SAP_Onboarding__c sap = new SAP_Onboarding__c();
        sap.On_boarding_Request_Type__c = 'New Sold-To w/ Ship-to & Product';
        sap.Account__c = ac1.Id;
        sap.Ship_To_Account__c = ac2.Id;
        sap.Form_Due_Date__c = Date.today().addDays(5);
        sap.Send_Invitation_Email_to_Main_Contact__c = 'Yes';
        sap.Customer_Information_Status__c = 'Sent To Customer';
        sap.Order_Placement_Status__c = 'Sent To Customer';
        sap.Credit_Application_Status__c = 'Sent To Customer';
        sap.Product_Stewardship_Status__c = 'Sent To Customer';
        sap.Main_Onboarding_Contact__c = con.Id;
        sap.Invitation_Email_sent__c = false;
        insert sap;
        
        Onboarding_Ship_To__c ship = new Onboarding_Ship_To__c();
        ship.SAP_Onboarding__c = sap.Id;
        insert ship;
        Assessment_Selector__c ast = new Assessment_Selector__c();
        ast.Product__c = testProduct.Id;
        ast.Ship_Mode__c = 'Barge';
        ast.Hazard_Category__c = 'High';
        ast.Assessment_Document__c = 'Sodium Hydroxide';
        ast.Site_Assessment_Needed__c = 'Yes';
        ast.Site_Assessment_Needed__c = 'Yes';
        insert ast;
        PurchasedProduct_R1__c purchased = new PurchasedProduct_R1__c();
        purchased.Account_R1__c = ac1.id;
        purchased.Product_R1__c = testProduct.Id;
        insert purchased;
        
        PurchasedProduct_R1__c purchasedProd = new PurchasedProduct_R1__c();
        purchasedProd.Account_R1__c = ac2.id;
        purchasedProd.Product_R1__c = testProduct1.Id;
        insert purchasedProd;
        testProduct.GMID__c = '5498631';
        update testProduct;
        PurchasedProduct_R1__c purchasedProd1 = new PurchasedProduct_R1__c();
        purchasedProd1.Account_R1__c = ac2.id;
        purchasedProd1.Product_R1__c = testProduct.Id;
        insert purchasedProd1;
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
        op.Customer_Pickup__c = 'No';
        insert op;
        op.Regulatory_Email__c = 'test@gmail.com';
        op.On_Site_Assessment_Email__c = 'test+1@gmail.com';
        op.On_Site_Assessment_Last_Name__c = 'test';
        op.Product_Section_Completed__c = true;
        op.Purchased_Product__c = purchasedProd.Id;
        update op;
        delete ast;
        op.Regulatory_Email__c = 'test+2@gmail.com';
        op.Regulatory_Last_Name__c = 'test2';
        op.Purchased_Product__c = purchased.Id;
        update op;
        op.SAP_Onboarding_Sold_To_Account__c = ac1.Id;
        onboardingTriggerHandler.isFirstTime = true;
        update op;
        Questionnaire__c ques = new Questionnaire__c();
        ques.Account_Name__c = ac1.Id;
        ques.Onboarding_Ship_To__c = ship.Id;
        ques.Onboarding_Product__c = op.Id;
        ques.SAP_Onboarding__c = sap.Id;
        insert ques;
        ques.Delivery_Point_Email__c = 'test@gmail.com';
        ques.After_Hours_Email__c = 'test+5@gmail.com';
        ques.After_Hours_Last_Name__c = 'test5';
        ques.Questionnaire_Section_Completed__c = true;
        Test.startTest();
        update ques;
        ques.Delivery_Point_Email__c = 'test+6@gmail.com';
        ques.Delivery_Point_Last_Name__c = 'test6';
        update ques;
        sap.Account_Payable_Email__c = 'test@gmail.com';
        sap.Contract_Notification_Email__c = 'test+7@gmail.com';
        sap.Credit_Email__c = 'test+9@gmail.com';
        sap.Credit_Last_Name__c = 'test9';
        sap.CXO_Officer_Email__c = 'test+8@gmail.com';
        sap.Account_Payable_Last_Name__c = 'test7';
        sap.CXO_Officer_Last_Name__c = 'test8';
        sap.Order_Placement_Email__c = 'test+10@gmail.com';
        sap.Order_Placement_Last_Name__c = 'test10';
        sap.Email_Invoice_Email_Address__c = 'test+11@gmail.com';
        sap.Email_Invoice_Last_Name__c = 'test11';
        update sap;
        sap.Contract_Notification_Email__c = 'test+55@gmail.com';
        sap.Contract_Notification_Last_Name__c = 'test55';
        update sap;
        Test.stopTest();
        
        
    }
    
    static testMethod void test2(){
        
        Account acc = new Account(Name='Test Account',type='Customer',AccountNumber_R1__c='123',AccountSource='Blue Cube');
        insert acc;
        Account acc1 = new Account(Name='Test Account1',type='Customer',AccountNumber_R1__c='1234',AccountSource='Blue Cube');
        insert acc1;
        Contact con = new Contact(LastName = 'Test', Email = 'test@gmail.com', AccountId = acc.Id);
        insert con;
        
        Sales_Organization__c sc = new Sales_Organization__c();
        sc.Name = 'Test';
        sc.Sales_Organization_Code__c = '123';
        insert sc;        
        Account_Sales_Organization__c acs = new Account_Sales_Organization__c();
        acs.Account__c = acc.Id;
        acs.Sales_Organization__c = sc.Id;
        insert acs;
        
        Product2 pr = new Product2();
        pr.Name = 'test';
        pr.Product_Level__c = 'GMID';
        pr.IsActive = TRUE;
        insert pr;
        
        Product2 testProduct = new Product2(
            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
            Name = 'Test Product',
            ProductCode = '105001',
            Product_Level__c = 'GMID',
            Business_Group__c = 'GCO',
            Family = 'Epoxy',
            IsActive = TRUE
        );
        insert testProduct;
        Assessment_Selector__c ast = new Assessment_Selector__c();
        ast.Product__c = pr.Id;
        ast.Assessment_Document__c = 'Sodium Hypochlorite';
        ast.Ship_Mode__c = 'Rail';
        ast.Site_Assessment_Needed__c = 'Yes';
        ast.Hazard_Category__c = 'Low';
        insert ast;
        
        
        
        SAP_Onboarding__c sap = new SAP_Onboarding__c();
        sap.Account__c = acc.Id;
        sap.Send_Invitation_Email_to_Main_Contact__c = 'No';
        sap.Invitation_Email_sent__c = False;
        sap.Main_Onboarding_Contact__c = con.Id;
        sap.On_boarding_Request_Type__c = 'New Sold-To w/ Ship-to & Product';
        sap.Form_Due_Date__c =  System.today();
        insert sap;
        Onboarding_Ship_To__c ship = new Onboarding_Ship_To__c();
        ship.SAP_Onboarding__c = sap.Id;
        insert ship;
        
       
        
        Horizon_Year__c hz = new Horizon_Year__c(Name='Default',Year__c=2024);
        insert hz;
        
        PurchasedProduct_R1__c purchased = new PurchasedProduct_R1__c();
        purchased.Account_R1__c = acc.id;
        purchased.Product_R1__c = pr.Id;
        purchased.Ship_Mode__c = '02';
        purchased.Product_R1__c = testProduct.Id;
        insert purchased;
        
         PurchasedProduct_R1__c purchased1 = new PurchasedProduct_R1__c();
        purchased1.Account_R1__c = acc1.id;
        purchased1.Ship_Mode__c = '02';
        purchased1.Product_R1__c = testProduct.Id;
        insert purchased1;
        
        Onboarding_Product__c op = new Onboarding_Product__c();
        op.SAP_Onboarding__c = sap.Id;
        op.Onboarding_Ship_To__c = ship.Id;
        op.Estimated_Volume__c = 10000;
        op.Ship_Mode__c = '01';
        op.Volume_Period__c = 'Month';
        op.Purchased_Product__c = purchased1.Id;
        op.Customer_Pickup__c = 'No';
        insert op;
        
        Assessment_Selector__c ast2 = new Assessment_Selector__c();
        ast2.Product__c = testProduct.Id;
        ast2.Assessment_Document__c = 'Sodium Hypochlorite';
        ast2.Ship_Mode__c = 'Rail';
        ast2.Site_Assessment_Needed__c = 'Yes';
        ast2.Hazard_Category__c = 'Low';
        insert ast2;
        op.Purchased_Product__c = purchased.Id;
        onboardingTriggerHandler.isFirstTime = true;
        update op;
    }
}