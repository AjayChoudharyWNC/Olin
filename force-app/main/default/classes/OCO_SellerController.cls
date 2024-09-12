public without sharing class OCO_SellerController {
    @AuraEnabled
    public static List<User> getUserList(){
        return [SELECT Id, Name, Profile.Name FROM USER WHERE IsActive = true ORDER BY Name ASC];
    }
    @AuraEnabled
    public static Account GetAccountInfo(String acId){
        return [SELECT Id, Name, RecordType.Name, AccountNumber_R1__c, BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry, OwnerId, Owner.Name, Owner.Email,
                (SELECT Id, TeamMemberRole,User.Email, UserId, User.Name FROM AccountTeamMembers WHERE TeamMemberRole = 'Account Manager' OR TeamMemberRole = 'Corporate Account Manager' OR
                 TeamMemberRole = 'Market Management' OR TeamMemberRole = 'Sales/Commercial Management' OR TeamMemberRole = 'Customer Service Rep' ORDER BY User.Name ASC )  FROM Account WHERE Id=:acId];
    }
    @AuraEnabled
    public static void deleteOnboardingProduct(String prodId){
        delete [SELECT Id FROM Onboarding_Product__c WHERE Id =:prodId];
    }
    @AuraEnabled
    public static void deleteFiles(String recordId){
        
        Attachment att = [SELECT Id, ParentId FROM Attachment WHERE Id =:recordId];
        Id parentId = att.ParentId;
        checkProductSpecification(parentId);
        delete att;
    }
    
    @AuraEnabled
    public static List<Account> getShipFromPlants(String prodId){
        PurchasedProduct_R1__c prod = [SELECT Id, Product_R1__C FROM PurchasedProduct_R1__c WHERE Id =:prodId];
        Set<Id> accIds = new Set<Id>();
        for(Ship_From_Plant_List__c shp : [SELECT Id, GMID_Product__c, Plant_Account__c FROM Ship_From_Plant_List__c WHERE GMID_Product__c =:prod.Product_R1__C AND Plant_Status__c = 'Active']){
            accIds.add(shp.Plant_Account__c);
        }
        return [SELECT Id, Name, AccountNumber_R1__c, BillingCity, BillingState FROM Account WHERE Id IN: accIds ORDER BY Name ASC];
    }
    @AuraEnabled
    public static Onboarding_Ship_To__c getShipToAccounts(String acId, String sapId){
        List<Onboarding_Ship_To__c> sh = new List<Onboarding_Ship_To__c>();
        sh = [SELECT Id, Name, Ship_To_Company_Name__c, Ship_To_City__c,Regulatory_Contact__c, Ship_To_Country__c, Ship_To_No__c, Ship_To_Postal_Code__c, Ship_To_State_Province__c,
              Ship_To_Street__c, Ship_To_Street_2__c, (SELECT Id, Name, Customer_Pickup__c, SAP_Onboarding__r.Product_Stewardship_Status__c, Regulatory_Contact__c,Is_a_Ship_To_Site_Assessment_Needed__c,Purchased_Product__r.Product_R1__r.Business_group__c,Purchased_Product__r.Product_R1__r.Family,
                                                       Purchased_Product__c, Purchased_Product__r.Product_R1__r.Name, Business_Group__c,Truck_Type__c, Product_Family__c,Ship_Mode__c, Primary_Ship_From__c, Alternative_Ship_From__c,INCO_Terms__c,Validity_Start_Date__c,Validity_End_Date__c,Volume__c,
                                                       GradeConcentration__c,Initial_Price__c,Currency__c,UOM__c,Energy_Surcharge__c,FSC_Exempt__c,CA_Mill_Tax__c,Scales__c,Scale_UOM__c,Scale_1_Volume__c,Scale_1_Price__c,Scale_2_Volume__c,Scale_2_Price__c,Scale_3_Price__c,Scale_4_Price__c,Scale_5_Price__c,
                                                       Scale_3_Volume__c,Scale_4_Volume__c,Scale_5_Volume__c,Additional_Ship_From_Price__c,X2nd_Scales__c,X2nd_Scale_UOM__c,X2nd_Scale_1_Volume__c,X2nd_Scale_2_Volume__c,X2nd_Scale_3_Volume__c,X2nd_Scale_4_Volume__c,X2nd_Scale_5_Volume__c,
                                                       X2nd_Scale_1_Price__c,X2nd_Scale_2_Price__c,X2nd_Scale_3_Price__c,X2nd_Scale_4_Price__c,X2nd_Scale_5_Price__c,Additional_Volume__c,Additional_Price__c,Purchased_Product__r.Performance_Center__c FROM Onboarding_Products__r) FROM Onboarding_Ship_To__c WHERE Account__c =:acId AND SAP_Onboarding__c =:sapId LIMIT 1];
        if(sh.size() > 0){
            return sh[0];
        }
        else {
            return null;
        }
    }
    
    @AuraEnabled
    public static Map<Id, List<Attachment>> fetchProdFiles(List<String> prodIds){
        Map<Id, List<Attachment>> prodAttMap = new Map<Id, List<Attachment>>();
        for(Attachment att : [SELECT Id, ParentId, Name FROM Attachment WHERE ParentId IN :prodIds AND Description = 'Product Specification Attachment']){
            if(!prodAttMap.containsKey(att.ParentId)){
                prodAttMap.put(att.ParentId, new List<Attachment>());
            }
            prodAttMap.get(att.ParentId).add(att);
        }
        return prodAttMap;
    }
    @AuraEnabled
    public static List<SAP_Onboarding__c> fetchSapRecords(String accId){
        return [SELECT Id, CreatedDate, Status__c,Name, Estimated_Date_of_First_Shipment__c, On_boarding_Request_Type__c, Customer_Type__c, Ship_To_Accounts__c, Sales_Organization__c, Sales_Rep__c, Form_Due_Date__c,Credit_Application_Form_Check__c,Customer_Information_Form_Check__c,
                Document_Delivery_Form_Check__c, Product_Stewardship_Form_Check__c, Full_Legal_Name__c FROM SAP_Onboarding__c WHERE Account__c =:accId AND 
                //(Credit_Application_Status__c = 'New' OR Customer_Information_Status__c = 'New' OR Order_Placement_Status__c = 'New' OR Product_Stewardship_Status__c = 'New') 
                (Status__c = 'New' OR Status__c = 'In Progress')
                ORDER BY Name DESC];
    }
    @AuraEnabled
    public static List<Account> getShipToAccountList(String soldToAccId, String recordType){
        List<Account> returnList = new List<Account>();
        if(String.isNotBlank(recordType)){
            if(recordType == 'Customer Location'){
                for(Account_Relationships__c ar : [SELECT Ship_To__c,Ship_To_Name_City_State_Country__c, Sold_To__c FROM Account_Relationships__c WHERE Sold_To__c =:soldToAccId AND Ship_To__r.RecordType.Name IN ('Customer Location', 'Customer') 
                                                   ORDER BY Ship_To_Name_City_State_Country__c ASC]){
                                                       returnList.add(new Account(Id=ar.Ship_To__c, Name = ar.Ship_To_Name_City_State_Country__c));
                                                   } 
            }
            else{
                for(Account_Relationships__c ar : [SELECT Ship_To__c,Ship_To_Name_City_State_Country__c, Sold_To__c FROM Account_Relationships__c WHERE Sold_To__c =:soldToAccId AND Ship_To__r.RecordType.Name IN ('Prospect Location', 'Prospect') ORDER BY Ship_To_Name_City_State_Country__c ASC]){
                    returnList.add(new Account(Id=ar.Ship_To__c, Name = ar.Ship_To_Name_City_State_Country__c));
                } 
            }
        }
        else{
            for(Account_Relationships__c ar : [SELECT Ship_To__c,Ship_To_Name_City_State_Country__c, Sold_To__c FROM Account_Relationships__c WHERE Sold_To__c =:soldToAccId ORDER BY Ship_To_Name_City_State_Country__c ASC]){
                returnList.add(new Account(Id=ar.Ship_To__c, Name = ar.Ship_To_Name_City_State_Country__c));
            }
        }
        return returnList;
    }
    
    /*@AuraEnabled 
public static void deleteOnboaringProduct(List<string> prodIds){
delete [SELECT Id FROM Onboarding_Product__c WHERE Id IN:prodIds];
}*/
    @AuraEnabled
    public static SAP_Onboarding__c fetchSapRecord(String sapId){
        Sap_Onboarding__c sap = [SELECT Id, Name, Account__c, Ship_To_Company_Name__c,Customer_Information_Status__c,Order_Placement_Status__c,Credit_Application_Status__c,Product_Stewardship_Status__c,Main_Onboarding_Contact__r.Email, Main_Onboarding_Contact__r.Name, Ship_To_City__c, Sold_To_Company_Name__c,Sold_To_Country__c,Credit_Application_Form_Check__c,Customer_Information_Form_Check__c,
                                 Document_Delivery_Form_Check__c, Product_Stewardship_Form_Check__c,Full_Legal_Name__c, Customer_Purchased_Prod_In_Last_12_Month__c, New_Business_Result_In_Exceeding_Credit__c, (SELECT Id, Ship_To_City__c, Ship_To_State_Province__c  , Ship_To_Country__c FROM Onboarding_Ship_To__r) FROM SAP_Onboarding__c WHERE Id =:sapId];
        
        return sap;
    }
    @AuraEnabled
    public static EmailTemplate getTemplateDetails(SAP_Onboarding__c sapRecord, String language){
        SAP_Onboarding__c sap = [SELECT Customer_Information_Status__c,Order_Placement_Status__c,Credit_Application_Status__c,Product_Stewardship_Status__c, Main_Onboarding_Contact__r.Email FROM SAP_Onboarding__c WHERE Id =:sapRecord.Id];
        EmailTemplate em = new EmailTemplate();
        if(language == 'English'){
            if(sap.Customer_Information_Status__c == 'New' && sapRecord.Customer_Information_Status__c == 'Sent To Customer'){
                em = [SELECT Id,subject,HTMLValue FROM EmailTemplate WHERE Name ='Customer Information Requested'];
            }
            if(sap.Order_Placement_Status__c == 'New' && sapRecord.Order_Placement_Status__c == 'Sent To Customer'){
                em = [SELECT Id,subject,HTMLValue FROM EmailTemplate WHERE Name ='Document Delivery Information Requested'];
            }
            if((sap.Credit_Application_Status__c == 'New' || sap.Credit_Application_Status__c == 'N/A') && sapRecord.Credit_Application_Status__c == 'Sent To Customer'){
                em = [SELECT Id,subject,HTMLValue FROM EmailTemplate WHERE Name ='Credit Application Information Requested'];
            }
            if(sap.Product_Stewardship_Status__c == 'New' && sapRecord.Product_Stewardship_Status__c == 'Sent To Customer'){
                em = [SELECT Id,subject,HTMLValue FROM EmailTemplate WHERE Name ='Product Stewardship Information Requested'];
            }
            if(sap.Customer_Information_Status__c == 'New' && sapRecord.Customer_Information_Status__c == 'Sent To Customer' && sap.Order_Placement_Status__c == 'New' && sapRecord.Order_Placement_Status__c == 'Sent To Customer'){
                em = [SELECT Id,subject,HTMLValue FROM EmailTemplate WHERE Name ='CI And DD Information Requested'];
            }
            if(sap.Customer_Information_Status__c == 'New' && sapRecord.Customer_Information_Status__c == 'Sent To Customer' && sap.Credit_Application_Status__c == 'New' && sapRecord.Credit_Application_Status__c == 'Sent To Customer'){
                em = [SELECT Id,subject,HTMLValue FROM EmailTemplate WHERE Name ='CI and CA Information Requested'];
            }
            if(sap.Customer_Information_Status__c == 'New' && sapRecord.Customer_Information_Status__c == 'Sent To Customer' && sap.Product_Stewardship_Status__c == 'New' && sapRecord.Product_Stewardship_Status__c == 'Sent To Customer'){
                em = [SELECT Id,subject,HTMLValue FROM EmailTemplate WHERE Name ='CI and PSA Information Requested'];
            }
            if(sap.Order_Placement_Status__c == 'New' && sapRecord.Order_Placement_Status__c == 'Sent To Customer' && sap.Credit_Application_Status__c == 'New' && sapRecord.Credit_Application_Status__c == 'Sent To Customer'){
                em = [SELECT Id,subject,HTMLValue FROM EmailTemplate WHERE Name ='DD and CA Information Requested'];
            }
            if(sap.Order_Placement_Status__c == 'New' && sapRecord.Order_Placement_Status__c == 'Sent To Customer' && sap.Product_Stewardship_Status__c == 'New' && sapRecord.Product_Stewardship_Status__c == 'Sent To Customer'){
                em = [SELECT Id,subject,HTMLValue FROM EmailTemplate WHERE Name ='DD and PSA Information Requested'];
            }
            if(sap.Credit_Application_Status__c == 'New' && sapRecord.Credit_Application_Status__c == 'Sent To Customer' && sap.Product_Stewardship_Status__c == 'New' && sapRecord.Product_Stewardship_Status__c == 'Sent To Customer'){
                em = [SELECT Id,subject,HTMLValue FROM EmailTemplate WHERE Name ='CA and PSA Information Requested'];
            }
            if(sap.Customer_Information_Status__c == 'New' && sapRecord.Customer_Information_Status__c == 'Sent To Customer' && sap.Order_Placement_Status__c == 'New' && sapRecord.Order_Placement_Status__c == 'Sent To Customer' && sap.Credit_Application_Status__c == 'New' && sapRecord.Credit_Application_Status__c == 'Sent To Customer'){
                em = [SELECT Id,subject,HTMLValue FROM EmailTemplate WHERE Name ='CI and DD and CA Information Requested'];
            }
            if(sap.Order_Placement_Status__c == 'New' && sapRecord.Order_Placement_Status__c == 'Sent To Customer' && sap.Credit_Application_Status__c == 'New' && sapRecord.Credit_Application_Status__c == 'Sent To Customer' && sap.Product_Stewardship_Status__c == 'New' && sapRecord.Product_Stewardship_Status__c == 'Sent To Customer'){
                em = [SELECT Id,subject,HTMLValue FROM EmailTemplate WHERE Name ='DD and CA and PSA Information Requested'];
            }
            if(sap.Customer_Information_Status__c == 'New' && sapRecord.Customer_Information_Status__c == 'Sent To Customer' && sap.Credit_Application_Status__c == 'New' && sapRecord.Credit_Application_Status__c == 'Sent To Customer' && sap.Product_Stewardship_Status__c == 'New' && sapRecord.Product_Stewardship_Status__c == 'Sent To Customer'){
                em = [SELECT Id,subject,HTMLValue FROM EmailTemplate WHERE Name ='CI and CA and PSA Information Requested'];
            }
            if(sap.Customer_Information_Status__c == 'New' && sapRecord.Customer_Information_Status__c == 'Sent To Customer' && sap.Order_Placement_Status__c == 'New' && sapRecord.Order_Placement_Status__c == 'Sent To Customer' && sap.Product_Stewardship_Status__c == 'New' && sapRecord.Product_Stewardship_Status__c == 'Sent To Customer'){
                em = [SELECT Id,subject,HTMLValue FROM EmailTemplate WHERE Name ='CI and DD and PSA Information Requested'];
            }
            if(sap.Customer_Information_Status__c == 'New' && sapRecord.Customer_Information_Status__c == 'Sent To Customer' && sap.Order_Placement_Status__c == 'New' && sapRecord.Order_Placement_Status__c == 'Sent To Customer' && sap.Credit_Application_Status__c == 'New' && sapRecord.Credit_Application_Status__c == 'Sent To Customer' && sap.Product_Stewardship_Status__c == 'New' && sapRecord.Product_Stewardship_Status__c == 'Sent To Customer'){
                em = [SELECT Id,subject,HTMLValue FROM EmailTemplate WHERE Name ='CI and DD and CA and PSA Information Requested'];
            }
            
            /***************** New Condition if no empail template is selected we will send Customer Info Requested **************/
            if(em.Subject==null && String.isBlank(em.Subject)){
              em = [SELECT Id,subject,HTMLValue FROM EmailTemplate WHERE Name ='Customer Information Requested'];
            }
            
        }
        else if(language == 'French'){
            em = [SELECT Id,subject,HTMLValue FROM EmailTemplate WHERE Name ='Customer Information Requested French'];
        }
        else if(language == 'Italian'){
            em = [SELECT Id,subject,HTMLValue FROM EmailTemplate WHERE Name ='Customer Information Requested Italian'];
        }
        else if(language == 'Spanish'){
            em = [SELECT Id,subject,HTMLValue FROM EmailTemplate WHERE Name ='Customer Information Requested Spanish'];
        }
        else if(language == 'German'){
            em = [SELECT Id,subject,HTMLValue FROM EmailTemplate WHERE Name ='Customer Information Requested German'];
        }
        else if(language == 'Portuguese'){
            em = [SELECT Id,subject,HTMLValue FROM EmailTemplate WHERE Name ='Customer Information Requested Portuguese'];
        }
        return em;
    }
    
    @AuraEnabled
    public static Id saveFile(Id parentId, String fileName, String base64Data, String contentType, String fileId, String description) {
        // check if fileId id ''(Always blank in first chunk), then call the saveTheFile method,
        //  which is save the check data and return the attachemnt Id after insert,
        //  next time (in else) we are call the appentTOFile() method
        //   for update the attachment with remains chunks
        if (fileId == '') {
            fileId = saveTheFile(parentId, fileName, base64Data, contentType, description);
        } else {
            appendToFile(fileId, base64Data);
        }
        
        return Id.valueOf(fileId);
    }
    
    public static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType, String description) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        
        Attachment oAttachment = new Attachment();
        oAttachment.parentId = parentId;
        
        oAttachment.Body = EncodingUtil.base64Decode(base64Data);
        oAttachment.Name = fileName;
        oAttachment.Description = description;
        oAttachment.ContentType = contentType;
        insert oAttachment;  
        if(description == 'Product Specification Attachment'){
            checkProductSpecification(parentId);
        }
        return oAttachment.Id;
    }
    
    public static void checkProductSpecification(Id prodId){
        List<Attachment> attList = new List<Attachment>();
        // List<Onboarding_Product__c> prodList = new List<Onboarding_Product__c>();
        // Onboarding_Product__c prod = new Onboarding_Product__c(Id = prodId);
        List<Onboarding_Product__c> prod = [SELECT Id, Has_Product_Spec__c FROM Onboarding_Product__c WHERE Id =: prodId LIMIT 1];
        attList = [SELECT Id, ParentId, Name FROM Attachment WHERE ParentId =: prodId AND Description = 'Product Specification Attachment'];
        
        for(Onboarding_Product__c op : prod){
            if(attList.size() > 0){
                op.Has_Product_Spec__c = true;
            }
            else{
                op.Has_Product_Spec__c = false;
            }
        }
        update prod;
    }
    
    private static void appendToFile(Id fileId, String base64Data) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');        
        Attachment a = [
            SELECT Id, Body
            FROM Attachment
            WHERE Id = : fileId
        ];
        
        String existingBody = EncodingUtil.base64Encode(a.Body);        
        a.Body = EncodingUtil.base64Decode(existingBody + base64Data);        
        update a;
    }
    @AuraEnabled
    public static List<Assessment_Selector__c> getAssessments(Onboarding_Product__c op){
        return [SELECT Id, Product__c, Assessment_Document__c, Ship_Mode__c, Site_Assessment_Needed__c FROM Assessment_Selector__c WHERE (Ship_Mode__c =:op.New_Customer_Ship_Mode__c OR Ship_Mode__c = 'All') AND Product__c =: op.Purchased_Product__r.Product_R1__c];
    }
    @AuraEnabled
    public static void updateAssessment(String prodId){
        Onboarding_Product__c prod = [SELECT Id,Purchased_Product__c, SAP_Onboarding__r.Account__c, SAP_Onboarding__c, SAP_Onboarding__r.Product_Stewardship_Status__c, Onboarding_Ship_To__c,Ship_Mode__c, New_Customer_Ship_Mode__c, Customer_Pickup__c,Purchased_Product__r.Product_R1__c,Purchased_Product__r.New_Customer_Ship_Mode__c, Purchased_Product__r.Ship_Mode__c, Purchased_Product__r.Product_R1__r.Family FROM Onboarding_Product__c WHERE Id=:prodId];
        System.debug('prod.New_Customer_Ship_Mode__c'+prod.New_Customer_Ship_Mode__c);
        System.debug('prod.New_Customer_Ship_Mode__c'+prod.Purchased_Product__r.Product_R1__r.Family);
        List<Assessment_Selector__c> astWithShipMode = new List<Assessment_Selector__c>();
        List<Assessment_Selector__c> astWithShipModeAll = new List<Assessment_Selector__c>();
        List<Questionnaire__c> existingProdAssessment = new List<Questionnaire__c>();
        existingProdAssessment = [SELECT Id FROM Questionnaire__c WHERE Onboarding_Product__c =:prod.Id];        
        astWithShipMode =  [SELECT Id, Product__c, Assessment_Document__c, Hazard_Category__c, Epoxy_Document_Type__c, Ship_Mode__c, Site_Assessment_Needed__c FROM Assessment_Selector__c WHERE Ship_Mode__c =:prod.New_Customer_Ship_Mode__c AND Product__c =: prod.Purchased_Product__r.Product_R1__c LIMIT 1];
        astWithShipModeAll =  [SELECT Id, Product__c, Assessment_Document__c, Hazard_Category__c, Epoxy_Document_Type__c, Ship_Mode__c, Site_Assessment_Needed__c FROM Assessment_Selector__c WHERE Ship_Mode__c = 'All' AND Product__c =: prod.Purchased_Product__r.Product_R1__c LIMIT 1];
        String recordTypeName;
        String setupType;
        String epoxyDocument;
        String hazardCategory;
        if(astWithShipMode.size() > 0){
            if(String.isNotBlank(astWithShipMode[0].Assessment_Document__c)){
                recordTypeName =  astWithShipMode[0].Assessment_Document__c+' - '+astWithShipMode[0].Ship_Mode__c;
            }
            if(astWithShipMode[0].Assessment_Document__c == 'Epoxy High-Medium Hazard'){
                setupType = 'Offline';
                epoxyDocument = astWithShipMode[0].Epoxy_Document_Type__c != null ? astWithShipMode[0].Epoxy_Document_Type__c : 'Standard High Medium Checklist';
            }
            hazardCategory = astWithShipMode[0].Hazard_Category__c;
        }
        else if(astWithShipModeAll.size() > 0){
            if(String.isNotBlank(astWithShipModeAll[0].Assessment_Document__c)){
                recordTypeName =  astWithShipModeAll[0].Assessment_Document__c;
            }
            if(astWithShipModeAll[0].Assessment_Document__c == 'Epoxy High-Medium Hazard'){
                setupType = 'Offline';
                epoxyDocument = astWithShipModeAll[0].Epoxy_Document_Type__c != null ? astWithShipModeAll[0].Epoxy_Document_Type__c : 'Standard High Medium Checklist';
            }
            hazardCategory = astWithShipModeAll[0].Hazard_Category__c;
        }
        if(recordTypeName == 'Epoxy High-Medium Hazard' && prod.New_Customer_Ship_Mode__c == 'Truck'){
            recordTypeName = 'Epoxy High-Medium Hazard - Truck';
            setupType = 'Online';
        }
        if(String.isNotBlank(recordTypeName)){
            prod.Shipment_Questionnaire__c = recordTypeName;
            if(recordTypeName.contains('Epoxy High-Medium Hazard')){
                prod.Shipment_Questionnaire__c = epoxyDocument;
            }
            prod.Is_a_Shipment_Questionnaire_Needed__c = 'Yes';
            prod.Hazard_Category__c = hazardCategory;
            Questionnaire__c ques = new Questionnaire__c(
                Account_Name__c = prod.SAP_Onboarding__r.Account__c,
                RecordTypeId = String.isNotBlank(recordTypeName) ? Schema.SObjectType.Questionnaire__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId() : null,
                Onboarding_Product__c = prod.id,
                SAP_Onboarding__c = prod.SAP_Onboarding__c,
                Onboarding_Ship_To__c = prod.Onboarding_Ship_To__c
            );
            if(String.isNotBlank(setupType)){
                ques.Questionnaire_Setup_Type__c = setupType;
            }
            if(prod.Customer_Pickup__c =='Yes' && prod.New_Customer_Ship_Mode__c =='Truck' && (prod.Purchased_Product__r.Product_R1__r.Family == 'CAPV' || prod.Purchased_Product__r.Product_R1__r.Family == 'EPOXY' || prod.Purchased_Product__r.Product_R1__r.Family == 'Epoxy'))
            {
                system.debug('we do not need any assessment');
            }
            else{
                insert ques;
            }
            
        }
        else if(prod.New_Customer_Ship_Mode__c == 'Truck' && prod.Purchased_Product__r.Product_R1__r.Family == 'Epoxy'){
            prod.Is_a_Shipment_Questionnaire_Needed__c = 'Yes';
            prod.Shipment_Questionnaire__c = 'Standard Truck';
            prod.Hazard_Category__c = 'Low';
            Questionnaire__c ques = new Questionnaire__c(
                Account_Name__c = prod.SAP_Onboarding__r.Account__c,
                RecordTypeId =  Schema.SObjectType.Questionnaire__c.getRecordTypeInfosByName().get('Standard Truck').getRecordTypeId(),
                Onboarding_Product__c = prod.id,
                Questionnaire_Setup_Type__c = 'Online',
                SAP_Onboarding__c = prod.SAP_Onboarding__c,
                Onboarding_Ship_To__c = prod.Onboarding_Ship_To__c
            );
            if(prod.Customer_Pickup__c =='Yes' && prod.New_Customer_Ship_Mode__c =='Truck' && (prod.Purchased_Product__r.Product_R1__r.Family == 'CAPV' || prod.Purchased_Product__r.Product_R1__r.Family == 'EPOXY' || prod.Purchased_Product__r.Product_R1__r.Family == 'Epoxy'))
            {
                system.debug('we do not need any assessment');
            }
            else{
                insert ques;
            }
            
        }
        update prod;
        if(existingProdAssessment.size() > 0){
            delete existingProdAssessment;
        }
        OnboardingTriggerHandler.updateCustomerSetup(new Set<Id>{prod.SAP_Onboarding__c});
    }
    @AuraEnabled
    public static SAP_Onboarding__c updateSapOnboardingStatus(SAP_Onboarding__c sapRecord, String emailBody, String emailSubject, String toEmails, String ccEmails, String bccEmails, EmailTemplate template){
        if(template != null){
            List<Messaging.EmailFileAttachment> emailAttList = new List<Messaging.EmailFileAttachment>();
            for(Attachment att : [SELECT Id, Name, Body, ContentType FROM Attachment WHERE ParentId =:sapRecord.Id AND Description = 'Share Colleague File']){
                Messaging.EmailFileAttachment eAtt = new Messaging.EmailFileAttachment();
                eAtt.filename = att.Name;
                eAtt.body = att.Body;
                eAtt.contenttype = att.ContentType;
                emailAttList.add(eAtt);
            }
            Messaging.SingleEmailMessage emailTobesent = new Messaging.SingleEmailMessage();
            emailTobesent.setTemplateId(template.Id);
            emailTobesent.setSubject(emailSubject);
            emailTobesent.setFileAttachments(emailAttList);
            emailTobesent.setHtmlBody(emailBody);
            emailTobesent.setToAddresses(toEmails.split(';'));
            if(String.isNotBlank(ccEmails)){
                emailTobesent.setCcAddresses(ccEmails.split(';'));
            }
            if(String.isNotBlank(bccEmails)){
                emailTobesent.setBccAddresses(bccEmails.split(';'));
            }
            system.debug('emailTobesent'+emailTobesent);
            if(String.isNotBlank(toEmails) && String.isNotBlank(emailBody)){
                Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {emailTobesent});
            }
        }
        update sapRecord;
        DELETE  [SELECT Id, Name, Body, ContentType FROM Attachment WHERE ParentId =:sapRecord.Id AND Description = 'Share Colleague File'];
        return sapRecord;
    }
    @AuraEnabled
    public static PurchasedProduct_R1__c getProductInfo(String productId){
        return [SELECT Id, Product_R1__r.Name, Product_R1__r.Business_Group__c,Performance_Center__c, Product_R1__r.Family, Global_UOM__c, Standard_UOM__c,Ship_Mode__c FROM PurchasedProduct_R1__c WHERE Id =:productId];
    }
    
    @AuraEnabled
    public static List<String> getPickListValues(String objectName, String fieldName){
        List<String> options = new List<String>();
        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            if(pickListVal.getValue() != 'Modify Sold-To' && pickListVal.getValue() != 'Modify Ship-To'){
                options.add(pickListVal.getValue());
            }
        }  
        return options;
    }
    @AuraEnabled
    public static List<Contact> getRelatedContact(String soldToAccId){
        Set<Id> contactIds = new Set<Id>();
        for(AccountContactRelation rel : [SELECT Id, ContactId FROM AccountContactRelation WHERE AccountId =:soldToAccId]){
            contactIds.add(rel.ContactId);
        }
        return [SELECT Id, Name, FirstName, LastName, Phone, Title, Email, Fax FROM Contact WHERE Id IN :contactIds ORDER BY Name ASC];
    }
    @AuraEnabled
    public static List<PurchasedProduct_R1__c> getRelatedProducts(String soldToAccId, String sapId){
        
        return [SELECT Id, Name, Product_Code__c,Product_Name__c,Product_R1__r.Name, Ship_To__c FROM PurchasedProduct_R1__c WHERE Account_R1__c =:soldToAccId ORDER BY Product_R1__r.Name ASC ];
        
    }
    @AuraEnabled
    public static Object getSalesOrgs(String soldToAccId){
        String recType = [SELECT RecordType.Name FROM Account WHERE Id=: soldToAccId].RecordType.Name;
        if(recType == 'Prospect'){
            return [SELECT Id, Name, Sales_Organization_Code__c FROM Sales_Organization__c ORDER BY Name ASC];
        }
        else{
            return [SELECT Id, Sales_Organization__r.Id,Sales_Org_Name_Code__c, Sales_Organization_Code__c FROM Account_Sales_Organization__c WHERE Account__c =: soldToAccId ORDER BY Name ASC];
        }
    }
    
    @AuraEnabled
    public static void updateSapOnboarding(String sapId, String sendEmail, Boolean sendToSap, Boolean cancelSap){
        Sap_Onboarding__c sap = new Sap_Onboarding__c();
        sap.Id = sapId;
        sap.Send_Invitation_Email_to_Main_Contact__c = sendEmail;
        sap.Send_to_SAP__c = sendToSap;
        sap.Cancel__c = cancelSap;
        if(cancelSap){
            sap.Status__c = 'Cancelled';
            sap.Credit_Application_Status__c = 'Cancelled';
            sap.Product_Stewardship_Status__c = 'Cancelled';
            sap.Customer_Information_Status__c = 'Cancelled';
            sap.Order_Placement_Status__c = 'Cancelled';
        }
        update sap;
        if(!sendToSap && !cancelSap){
            Task t = new Task();
            t.Subject = 'SAP Onboarding has been sent to customer';
            t.Status = 'Completed';
            t.ActivityDate = Date.today();
            t.WhatId = sapId;
            insert t;
        }
        
        //----Sending Email alert to Quality Team with Ship-To and Product details
        List<EmailTemplate> qEt = [SELECT Id,HTMLValue,Subject FROM EmailTemplate WHERE DeveloperName = 'ShipTo_And_Product_Email_to_Quality' LIMIT 1];
        if(!qEt.isEmpty()){
            List<Onboarding_Ship_To__c> onbShipTos = [SELECT Id,Ship_To_Company_Name__c,Ship_To_City__c,Ship_To_Country__c,Ship_To_Postal_Code__c,Ship_To_State_Province__c,Ship_To_Street__c,Ship_To_Street_2__c,
                                                      Ship_To_No__c,
                                                      (SELECT Id,Purchased_Product__r.Product_R1__r.Name,Any_Specific_Quality_Standards__c,Specific_Quality_Standards_Other__c,Quality_SDS_Email__c 
                                                       FROM Onboarding_Products__r)
                                                      FROM Onboarding_Ship_To__c 
                                                      WHERE SAP_Onboarding__c =: sapId ORDER BY CreatedDate ASC];
            if(!onbShipTos.isEmpty()){
                String[] toAddresses = new String[]{};
                    String body = '<br/><table>';
                for(Onboarding_Ship_To__c onb: onbShipTos){
                    body += '<tr><td colspan="2"><b>'+onb.Ship_To_Company_Name__c+' - </b>'+removeNull(onb.Ship_To_Street__c)+removeNull(onb.Ship_To_Street_2__c)+removeNull(onb.Ship_To_City__c)
                        +removeNull(onb.Ship_To_State_Province__c)+removeNull(onb.Ship_To_Postal_Code__c)+removeNull(onb.Ship_To_Country__c)+'</td></tr>';
                    if(!onb.Onboarding_Products__r.isEmpty()){
                        Integer count = 1;
                        for(Onboarding_Product__c onp: onb.Onboarding_Products__r){
                            if(String.isNotBlank(onp.Quality_SDS_Email__c)){
                                toAddresses.add(onp.Quality_SDS_Email__c);
                            }
                            body += '<tr><td></td><td style="font-size:12px;"><b>'+count+'.) '+onp.Purchased_Product__r.Product_R1__r.Name+'</b> - Quality Standards: '+onp.Any_Specific_Quality_Standards__c == null ? '' : onp.Any_Specific_Quality_Standards__c+' - '+onp.Specific_Quality_Standards_Other__c == null ? '' : onp.Specific_Quality_Standards_Other__c+'</td></tr>';
                            count++;
                        }
                    }
                    body += '<tr><td colspan="2"><hr/></td></tr>';
                }
                body += '<tr><td colspan="2" align="center"><a href="'+System.URL.getSalesforceBaseUrl().toExternalForm()+'/'+sapId+'">Click here to open the complete form</a></td></tr>';
                body += '</table>';
                toAddresses.add('gaurish@cipaq.com');
                if(!toAddresses.isEmpty()){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(toAddresses);
                    mail.setSubject(qET[0].Subject);
                    mail.setHtmlBody(qET[0].HtmlValue.replace('||SHIPTO PROD INFO||', body));
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
                }
            }            
        }
    }
    
    @TestVisible 
    static String removeNull(String obj){
        return String.isNotBlank(obj) ? ', '+obj : '';
    }
    @AuraEnabled
    public static string insertSapRecord(SAP_Onboarding__c sapRecord){
        if(String.isBlank(sapRecord.Id)){
            Account soldAcc = [SELECT Id, Name, AccountNumber_R1__c, Parent.AccountNumber_R1__c, ParentId, BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry From Account WHERE Id =: sapRecord.Account__c];
            if(String.isNotBlank(soldAcc.ParentId)){
                Account parentAcc = [SELECT BillingCity, BillingCountry, AccountNumber_R1__c,BillingStreet, Name, BillingState, BillingPostalCode FROM Account WHERE Id =:soldAcc.ParentId];
                sapRecord.Parent_City__c = parentAcc.BillingCity;
                sapRecord.SAP_S_4_No_Global_Customer__c = parentAcc.AccountNumber_R1__c;
                sapRecord.Parent_Company_Name__c = parentAcc.Name;
                sapRecord.Parent_Country__c = parentAcc.BillingCountry;
                sapRecord.Parent_Postal_Code__c = parentAcc.BillingPostalCode;
                sapRecord.Parent_State_Province__c = parentAcc.BillingState;
                sapRecord.Parent_Street__c = parentAcc.BillingStreet;
            }
            sapRecord.Full_Legal_Name__c = soldAcc.Name;
            sapRecord.Sold_To_Company_Name__c = soldAcc.Name;
            sapRecord.Sold_To_City__c = soldAcc.BillingCity;
            sapRecord.Sold_To_Country__c = soldAcc.BillingCountry;
            sapRecord.Sold_To_Postal_Code__c = soldAcc.BillingPostalCode;
            sapRecord.SAP_S_4_No_Sold_To__c = soldAcc.AccountNumber_R1__c;
            sapRecord.SAP_S_4_No_Global_Customer__c = soldAcc.Parent.AccountNumber_R1__c;
            sapRecord.Sold_To_State_Province__c = soldAcc.BillingState;
            sapRecord.Sold_To_Street__c = soldAcc.BillingStreet;
            sapRecord.Sold_To_Street_2__c = null;
            
            
            insert sapRecord;
            
            Contact con = [SELECT Id, FirstName, LastName,Email, Phone, Title FROM Contact WHERE Id =: sapRecord.Main_Onboarding_Contact__c];
            Application_User__c app = new Application_User__c();
            app.Contact__c = con.Id;
            app.First_Name__c = con.FirstName;
            app.Last_Name__c = con.LastName;
            app.SAP_Onboarding__c = sapRecord.Id;
            app.Mobile_Phone__c = con.Phone;
            app.Email__c = con.Email;
            app.Title__c = con.Title;
            insert app;
        }
        else{
            update sapRecord;
        }
        return sapRecord.Id;
    }
    @AuraEnabled
    public static SAP_Onboarding__c fetchRecord(String soldToAccId, String shipToAccId){
        try{
            Account soldAcc = [SELECT Id, Name, AccountNumber_R1__c, Parent.AccountNumber_R1__c, ParentId, BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry From Account WHERE Id =: soldToAccId];
            Account shipAcc;
            if(shipToAccId != null && shipToAccId != ''){
                shipAcc = [SELECT Id, Name, AccountNumber_R1__c, BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry From Account WHERE Id =: shipToAccId];
            }
            SAP_Onboarding__c sap = new SAP_Onboarding__c(Full_Legal_Name__c = soldAcc.Name, Sold_To_Company_Name__c = soldAcc.Name,Sold_To_City__c = soldAcc.BillingCity,
                                                          Sold_To_Country__c = soldAcc.BillingCountry,Sold_To_Postal_Code__c = soldAcc.BillingPostalCode,SAP_S_4_No_Sold_To__c = soldAcc.AccountNumber_R1__c,
                                                          SAP_S_4_No_Global_Customer__c = soldAcc.Parent.AccountNumber_R1__c ,Sold_To_State_Province__c = soldAcc.BillingState,Sold_To_Street__c = soldAcc.BillingStreet, Sold_To_Street_2__c = null);
            if(shipToAccId != null && shipToAccId != ''){
                sap.Ship_To_Account__c = shipAcc.Id;
                sap.SAP_S_4_No_Ship_To__c = shipAcc.AccountNumber_R1__c;
                sap.Ship_To_City__c = shipAcc.BillingCity;
                sap.Ship_To_Country__c = shipAcc.BillingCountry;
                sap.Ship_To_Postal_Code__c = shipAcc.BillingPostalCode;
                sap.Ship_To_State_Province__c = shipAcc.BillingState;
                sap.Ship_To_Street__c = shipAcc.BillingStreet;
                sap.Ship_To_Street_2__c = '';
                sap.Ship_To_Company_Name__c = shipAcc.Name;
            }
            if(String.isNotBlank(soldAcc.ParentId)){
                Account parentAcc = [SELECT BillingCity, BillingCountry, AccountNumber_R1__c,BillingStreet, Name, BillingState, BillingPostalCode FROM Account WHERE Id =:soldAcc.ParentId];
                sap.Parent_City__c = parentAcc.BillingCity;
                sap.SAP_S_4_No_Global_Customer__c = parentAcc.AccountNumber_R1__c;
                sap.Parent_Company_Name__c = parentAcc.Name;
                sap.Parent_Country__c = parentAcc.BillingCountry;
                sap.Parent_Postal_Code__c = parentAcc.BillingPostalCode;
                sap.Parent_State_Province__c = parentAcc.BillingState;
                sap.Parent_Street__c = parentAcc.BillingStreet;
            }
            return sap;
        }
        catch(Exception e){
            throw new AuraHandledException(e.getMessage()); 
        } 
    }
    @AuraEnabled
    public static Contact fetchContactRec(String contId){
        try{
            if(contId != null && contId != ''){
                return  [SELECT Id, FirstName, LastName, (SELECT Id FROM Application_User__r),Email, Phone, Title FROM Contact WHERE Id =: contId];
            }
            else{
                return new Contact();
            }
        }
        catch(Exception e){
            System.debug('exception in contact'+e);
            throw new AuraHandledException(e.getMessage()); 
        } 
    }
    
     @AuraEnabled
    public static void createApplicationUser(List<contact> contactList, String sapId){
        List<Application_User__c> applicationUsers = new List<Application_User__c>();
        Set<Id> conIds = new Set<Id>();
        for(Application_User__c appUser : [SELECT Contact__c FROM Application_User__c WHERE SAP_Onboarding__c =:sapId]){
            conIds.add(appUser.Contact__c);
        }
        for(Contact con : contactList){
            if(!conIds.contains(con.Id)){
                Application_User__c app = new Application_User__c();
                app.Contact__c = con.Id;
                app.First_Name__c = con.FirstName;
                app.Last_Name__c = con.LastName;
                app.SAP_Onboarding__c = sapId;
                app.Mobile_Phone__c = con.Phone;
                app.Email__c = con.Email;
                app.Title__c = con.Title;
                applicationUsers.add(app);
                conIds.add(con.Id);
            }
        }
        system.debug('applicationUsers'+applicationUsers);
        insert applicationUsers;
        
    }

    
    class ShipToWrapper{
        @AuraEnabled public Onboarding_Ship_To__c shipTo;
        @AuraEnabled public Map<Id, List<Attachment>> prodAttachmentMap;
    }
    
}