@isTest
public class OCO_SellerControllerTest {
    
    static testMethod void test1(){
       
         Account pacc = new Account(Name='Test Account',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Parent').getRecordTypeId(),AccountNumber_R1__c='12345',AccountSource='S4');
        insert pacc;
        Account acc = new Account(Name='Test Account',ParentId= pacc.Id,type='Customer',AccountNumber_R1__c='123',AccountSource='S4');
        insert acc;
        Account acc1 = new Account(Name='Test Account1',type='Customer',AccountNumber_R1__c='1234',AccountSource='S4');
        insert acc1;
        Contact con = new Contact(LastName = 'Test', Email = 'test@gmail.com', AccountId = acc.Id);
        insert con;
        
        Sales_Organization__c sc = new Sales_Organization__c();
        sc.Name = 'Test';
        sc.Sales_Organization_Code__c = '123';
        sc.Active__c = true;
        insert sc;        
        Account_Sales_Organization__c acs = new Account_Sales_Organization__c();
        acs.Account__c = acc.Id;
        acs.Sales_Organization__c = sc.Id;
        insert acs;
        
        Product2 pr = new Product2();
        pr.Name = 'test';
        pr.Product_Level__c = 'GMID';
        pr.IsActive = TRUE;
        pr.Family='Epoxy';
        insert pr;

        Product2 testProduct = new Product2(
            // RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
            Name = 'Test Product',
            ProductCode = '105001',
            Product_Level__c = 'GMID',
            Business_Group__c = 'GCO',
            IsActive = TRUE
        );
        insert testProduct;
        
        List<Assessment_Selector__c> astList = new List<Assessment_Selector__c>();
        Assessment_Selector__c ast = new Assessment_Selector__c();
        ast.Product__c = pr.Id;
        ast.Assessment_Document__c = 'Sodium Hypochlorite';
        ast.Ship_Mode__c = 'All';
        ast.Hazard_Category__c = 'High';
        ast.Site_Assessment_Needed__c = 'Yes';
        // insert ast;
        astList.add(ast);

        // Assessment_Selector__c ast2 = new Assessment_Selector__c();
        // ast2.Product__c = testProduct.Id;
        // ast2.Assessment_Document__c = 'Sodium Hypochlorite';
        // ast2.Ship_Mode__c = 'All';
        // ast2.Site_Assessment_Needed__c = 'Yes';
        // // insert ast2;
        // astList.add(ast2);
        insert astList;

        
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
        List<PurchasedProduct_R1__c> ppList = new List<PurchasedProduct_R1__c>();
        PurchasedProduct_R1__c purchased = new PurchasedProduct_R1__c();
        purchased.Account_R1__c = acc.id;
        purchased.Product_R1__c = pr.Id;
        purchased.Ship_Mode__c = '02';
        purchased.Product_R1__c = testProduct.Id;
        ppList.add(purchased);
        
        PurchasedProduct_R1__c purchased1 = new PurchasedProduct_R1__c();
        purchased1.Account_R1__c = acc1.id;
        purchased1.Product_R1__c = pr.Id;
        purchased1.Ship_Mode__c = '02';
        purchased1.Product_R1__c = testProduct.Id;
        ppList.add(purchased1);
        
        insert ppList;
        
        Onboarding_Product__c op = new Onboarding_Product__c();
        op.SAP_Onboarding__c = sap.Id;
        op.Onboarding_Ship_To__c = ship.Id;
        op.Purchased_Product__c = purchased.Id;
        op.Estimated_Volume__c = 10000;
        op.Ship_Mode__c = '01';
        op.Volume_Period__c = 'Month';
        insert op;
        
        op.Purchased_Product__c = purchased1.Id;
        update op;
        
        system.debug('purchased >>> '+ purchased.Product_R1__c);
        system.debug('purchased1 >>> '+ purchased1.Product_R1__c);
       system.debug('prid >>> '+ pr.Id);
        
        SAP_Onboarding__c sap1 = new SAP_Onboarding__c();
        sap1.Account__c = acc.Id;
        sap1.Send_Invitation_Email_to_Main_Contact__c = 'No';
        sap1.Invitation_Email_sent__c = False;
        sap1.Main_Onboarding_Contact__c = con.Id;
        sap1.Form_Due_Date__c =  System.today();
        sap1.On_boarding_Request_Type__c = 'New Sold-To w/ Ship-to & Product';
        
        Attachment attach=new Attachment();    
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=sap.id;
        attach.Description='Share Colleague File';
        insert attach;

        Id attachId = [SELECT Id, ParentId FROM Attachment WHERE Name = 'Unit Test Attachment'].Id;

        // EmailTemplate emailTemp = new EmailTemplate(
        //     HtmlValue = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"><htm></html>',
        //     Subject = 'New Ship-To(s) has been created',
        //     DeveloperName = 'ShipTo_And_Product_Email_to_Quality'
        // );
        // insert emailTemp;

        Test.startTest();
        OCO_SellerController.createApplicationUser(new List<Contact> {con}, sap.Id);
        OCO_SellerController.getAssessments(op);
        OCO_SellerController.getShipFromPlants(purchased.Id);
        OCO_SellerController.fetchSapRecord(sap.Id);
        OCO_SellerController.fetchSapRecords(acc.Id);
        OCO_SellerController.getShipToAccounts(acc.Id, sap.Id);
        OCO_SellerController.fetchContactRec(con.Id);
        OCO_SellerController.fetchContactRec('');
        OCO_SellerController.fetchRecord(acc.Id, acc1.Id);
        OCO_SellerController.fetchRecord(acc.Id, '');
        OCO_SellerController.GetAccountInfo(acc.Id);
        OCO_SellerController.getPickListValues('SAP_Onboarding__c', 'On_boarding_Request_Type__c');
        OCO_SellerController.getRelatedContact(acc.Id);
        OCO_SellerController.getShipToAccountList(acc.Id, '');
        OCO_SellerController.getShipToAccountList(acc.Id, 'Customer Location');
        OCO_SellerController.getProductInfo(purchased.Id);
        OCO_SellerController.getSalesOrgs(acc.Id);
        OCO_SellerController.getRelatedProducts(acc.Id, sap.Id);
        OCO_SellerController.updateSapOnboarding(sap.Id, 'No', true, true);
        OCO_SellerController.updateSapOnboarding(sap.Id, 'No', false, false);
        OCO_SellerController.updateAssessment(op.Id);
        // OCO_SellerController.deleteFiles(attachId);
        OCO_SellerController.getUserList();
        String sapId = OCO_SellerController.insertSapRecord(sap1);
        String fileId = OCO_SellerController.saveFile(sapId, 'shareFile', 'tejbkfnsfer', 'image/jpeg', '', 'shareFile');
        OCO_SellerController.saveFile(sapId, 'shareFile', 'tejbkfnsfer', 'image/jpeg', fileId, 'shareFile');
        OCO_SellerController.saveFile(op.Id, 'shareFile', 'tejbkfnsfer', 'image/jpeg', '', 'Product Specification Attachment');
        OCO_SellerController.fetchProdFiles(new List<String>{op.Id});
        OCO_SellerController.deleteOnboardingProduct(op.Id);
        sap.Order_Placement_Status__c = 'Sent To Customer';
        EmailTemplate em = OCO_SellerController.getTemplateDetails(sap,'English');
        EmailTemplate emi = OCO_SellerController.getTemplateDetails(sap,'French');
        OCO_SellerController.updateSapOnboardingStatus(sap, em.HtmlValue, em.Subject, 'test@gmail.com', 'test@gmail.com', 'test@gmail.com', em);
        OCO_SellerController.removeNull('Assessment_Selector__c');
        Test.stopTest();
    }


    static testMethod void deleteFileTest(){
        Account acc = new Account(
            Name='Test Account',
            // ParentId= pacc.Id,
            type='Customer',
            AccountNumber_R1__c='123',
            AccountSource='S4');
        insert acc;

        SAP_Onboarding__c sap = new SAP_Onboarding__c();
        sap.Account__c = acc.Id;
        sap.Send_Invitation_Email_to_Main_Contact__c = 'No';
        sap.Invitation_Email_sent__c = False;
        // sap.Main_Onboarding_Contact__c = con.Id;
        sap.On_boarding_Request_Type__c = 'New Sold-To w/ Ship-to & Product';
        sap.Form_Due_Date__c =  System.today();
        insert sap;

        Attachment attach=new Attachment();    
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=sap.id;
        attach.Description='Product Specification Attachment';
        insert attach;

        Test.startTest();
        OCO_SellerController.deleteFiles(attach.Id);
        Test.stopTest();
    }
    
}