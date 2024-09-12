public without sharing class OCO_CustomerController {
    
    @AuraEnabled
    public static String disbleForProfile(String recId){
        User userDetails  = [SELECT Id, Name, Email,Profile.Name FROM User WHERE Id =:UserInfo.getUserId()];
        SAP_Onboarding__c Ids = [SELECT Sales_Rep__c, Ownerid FROM SAP_Onboarding__c WHERE Id =:recId];
        String rValue;
            if(userDetails.Profile.Name.contains('CSR') || userDetails.Id == Ids.Sales_Rep__c || userDetails.Id == Ids.OwnerId || userDetails.Profile.Name == 'Customer Community User') {
                 rValue = 'false'; 
            }
        else{
             rValue = 'true'; 
        }
        return rValue;
    }
    @AuraEnabled
    public static User getCurrentUser(){
        return [SELECT Id, Name, Email FROM User WHERE Id =:UserInfo.getUserId()];
    }
    @AuraEnabled
    public static boolean getCreditInfo(String appUserId){
        Boolean showCreditInfo;
        Boolean hasCreditCustomPermission = FeatureManagement.checkPermission('Customer_Setup_Credit');
        String userName = UserInfo.getName();
        if(String.isBlank(appUserId) && !userName.containsIgnoreCase('customer')){
            if(hasCreditCustomPermission){
                showCreditInfo = true;
            }
            else{
                showCreditInfo = false;
            }
        }
        else if(String.isNotBlank(appUserId)){
            showCreditInfo = true;
        }
        return showCreditInfo;
    }
    @AuraEnabled 
    public static Application_User__c getAppUserRecord(String appUserEmail){
        return [SELECT Id, First_Name__c, Last_Name__c, Language__c FROM Application_User__c WHERE Email__c =: appUserEmail LIMIT 1];
    }
    @AuraEnabled
    public static void saveAppUser(String appUserEmail, String language){
        List<Application_User__c> allAppUser = new List<Application_User__c>();
        for(Application_User__c u : [SELECT Id FROM Application_User__c WHERE Email__c = :appUserEmail]){
            u.Language__c = language;
            allAppUser.add(u);
        }
        update allAppUser;
    }
    @AuraEnabled
    public static String getLanguageFileBody(){
        return [SELECT Id, Body FROM StaticResource WHERE Name = 'CustmerSetupTranslation'].Body.toString();
    }
    @AuraEnabled
    public static Object getForms(String appUserEmail, String sapId){
        try{
            Set<Id> shipIds = new Set<Id>();
            List<Node> nodeList = new List<Node>();
            Node inNode = new Node();
            inNode.label = 'Instructions';
            inNode.name = 'Instructions';
            inNode.color = 'blue';
            inNode.expanded = false;
            inNode.nodeLangId = 'HP_1';
            nodeList.add(inNode);
            Set<Id> sapIds = new Set<Id>();
            if(String.isNotBlank(appUserEmail)){
                for(Application_User__c app :[SELECT Id, SAP_Onboarding__c FROM Application_User__c WHERE Email__c =: appUserEmail]){
                    if(app.SAP_Onboarding__c != null){
                        sapIds.add(app.SAP_Onboarding__c);
                    }
                }
            }
            else{
                sapIds.add(sapId);
            }
            Map<Id,SAP_Onboarding__c> sapMap = new Map<Id, SAP_Onboarding__c>([SELECT Id,Name,Customer_Information_Status__c, Order_Placement_Status__c, Credit_Application_Status__c, Product_Stewardship_Status__c FROM SAP_Onboarding__c WHERE Id IN :sapIds AND Status__c != 'Cancelled' AND Status__c != 'Completed' ORDER BY CreatedDate DESC]);
            Map<Id,List<Onboarding_Ship_To__c>> shipMap = new Map<Id,List<Onboarding_Ship_To__c>>();
            Map<String,List<Questionnaire__c>> quesMap = new Map<String,List<Questionnaire__c>>();
            Map<String, List<Onboarding_Product__c>> prodMap = new Map<String, List<Onboarding_Product__c>>();
            if(sapMap != null && sapMap.keySet().size() > 0){
                List<Onboarding_Ship_To__c> shipList = [SELECT Id,SAP_Onboarding__c,Name,Ship_To_Company_Name__c,(SELECT Id FROM Onboarding_Products__r) FROM Onboarding_Ship_To__c WHERE SAP_Onboarding__c IN: sapMap.keySet()];
                if(shipList != null && shipList.size() > 0){
                    for(Onboarding_Ship_To__c q: shipList){
                        shipIds.add(q.Id);
                        if(!shipMap.containsKey(q.SAP_Onboarding__c)){
                            shipMap.put(q.SAP_Onboarding__c,new List<Onboarding_Ship_To__c>());
                        }
                        shipMap.get(q.SAP_Onboarding__c).add(q);
                    }
                    List<Onboarding_Product__c> prodList = [SELECT Id, Name, SAP_Onboarding__c,Purchased_Product_Name__c, Onboarding_Ship_To__c, Ship_Mode__c, New_Customer_Ship_Mode__c FROM Onboarding_Product__c WHERE Onboarding_Ship_To__c IN :shipIds];
                    if(prodList != null && prodList.size() > 0){
                        for(Onboarding_Product__c pr : prodList){
                            if(!prodMap.containsKey(pr.SAP_Onboarding__c+'-'+pr.Onboarding_Ship_To__c)){
                                prodMap.put(pr.SAP_Onboarding__c+'-'+pr.Onboarding_Ship_To__c,new List<Onboarding_Product__c>());
                            }
                            prodMap.get(pr.SAP_Onboarding__c+'-'+pr.Onboarding_Ship_To__c).add(pr);
                        }
                    }
                    List<Questionnaire__c> steList = [SELECT Id,Name,Onboarding_Ship_To__c,Onboarding_Product__c,Onboarding_Product__r.Purchased_Product_Name__c,SAP_Onboarding__c FROM Questionnaire__c WHERE Onboarding_Ship_To__c IN: shipIds];
                    System.debug('steList===='+steList+'shipIds===='+shipIds);
                    if(steList != null && steList.size() > 0){
                        for(Questionnaire__c q: steList){
                            if(!quesMap.containsKey(q.Onboarding_Product__c+'-'+q.Onboarding_Ship_To__c)){
                                quesMap.put(q.Onboarding_Product__c+'-'+q.Onboarding_Ship_To__c,new List<Questionnaire__c>());
                            }
                            quesMap.get(q.Onboarding_Product__c+'-'+q.Onboarding_Ship_To__c).add(q);
                        }
                    }
                }
                System.debug('shipMap===='+shipMap+'quesMap===='+quesMap);
                Integer sapNumber = 1;
                for(Id i: sapMap.keySet()){
                    SAP_Onboarding__c sap = sapMap.get(i);
                    if(sap.Customer_Information_Status__c != 'New' || sap.Order_Placement_Status__c != 'New' || sap.Credit_Application_Status__c != 'New' || sap.Product_Stewardship_Status__c != 'New'){
                        Node n = new Node();
                        n.label = 'Customer Setup Form: '+sap.Name;
                        n.name = sap.Id+'-CF-'+sap.name;
                        n.color = 'orange';
                        n.nodeLangId = 'HP_3';
                        if(sapNumber == 1)
                            n.expanded = true;
                        else
                            n.expanded = false;
                        
                        Node ciNode = new Node();
                        sapNumber++;
                        
                        if(sapMap.get(i).Customer_Information_Status__c != null && sapMap.get(i).Customer_Information_Status__c != 'New'){
                            ciNode.label = 'Customer Information';
                            ciNode.name = sap.Id+'-CI-'+sap.name;
                            ciNode.color = 'blue';
                            ciNode.nodeLangId = 'HP_4';
                            ciNode.expanded = false;
                        }
                       /* Node opNode = new Node();
                        if(sapMap.get(i).Order_Placement_Status__c != null && sapMap.get(i).Order_Placement_Status__c != 'New'){
                            opNode.label = 'Document Delivery';
                            opNode.name = sap.Id+'-OP-'+sap.name;
                            opNode.color = 'blue';
                            opNode.expanded = false;
                            opNode.nodeLangId = 'HP_5';
                        }*/
                        Node caNode = new Node();
                        if(sapMap.get(i).Credit_Application_Status__c != null && sapMap.get(i).Credit_Application_Status__c != 'New' && sapMap.get(i).Credit_Application_Status__c != 'N/A'){
                            caNode.label = 'Credit Application';
                            caNode.name = sap.Id+'-CA-'+sap.name;
                            caNode.color = 'blue';
                            caNode.expanded = false;
                            caNode.nodeLangId = 'HP_6';
                        }
                        Node psNode = new Node();
                        if(sapMap.get(i).Product_Stewardship_Status__c != null && sapMap.get(i).Product_Stewardship_Status__c != 'New'){
                            psNode.label = 'Product Stewardship';
                            psNode.name = sap.Id+'-PS-'+sap.name;
                            psNode.color = 'green';
                            psNode.expanded = true;
                            psNode.nodeLangId = 'HP_62';
                        }
                        
                        n.items = new List<Node>{};
                            if(String.isNotBlank(ciNode.label)){
                                n.items.add(ciNode);
                            }
                      /*  if(String.isNotBlank(opNode.label)){
                            n.items.add(opNode);
                        } */
                        if(String.isNotBlank(caNode.label)){
                            n.items.add(caNode);
                        }
                        if(String.isNotBlank(psNode.label)){
                            n.items.add(psNode);
                        }
                        
                        
                        
                        if(shipMap.containsKey(sap.Id)){
                            List<Node> shipNodes = new List<Node>();
                            Integer shipCount = 1;
                            for(Onboarding_Ship_To__c os: shipMap.get(sap.Id)){
                                Node n1 = new Node();
                                n1.label = 'Ship-To '+shipCount;
                                n1.metatext = os.Ship_To_Company_Name__c;
                                n1.name = os.Id+'-OST-'+sap.name;
                                n1.color = 'green';
                                n1.expanded = true;
                                n1.nodeLangId = 'HP_8';
                                shipNodes.add(n1);
                                shipCount++;
                                if(prodMap.containsKey(sap.Id+'-'+os.Id)){
                                    List<Node> prodNodes = new List<Node>();
                                    Integer prodCount = 1;
                                    for(Onboarding_Product__c pr : prodMap.get(sap.Id+'-'+os.Id)){
                                        Node n2 = new Node();
                                        n2.label = 'Product '+prodCount;
                                        n2.metatext = pr.Purchased_Product_Name__c+' - '+pr.New_Customer_Ship_Mode__c;
                                        n2.name = pr.Id+'-OPR-'+sap.name;
                                        n2.color = 'green';
                                        n2.expanded = true;
                                        n2.nodeLangId = 'HP_9';
                                        prodNodes.add(n2);
                                        /*if(quesMap.containsKey(pr.Id+'-'+os.Id)){
List<Node> quesNodes = new List<Node>();
Integer quesCount = 1;
for(Questionnaire__c q: quesMap.get(pr.Id+'-'+os.Id)){
Node n3 = new Node();
if(quesMap.get(pr.Id+'-'+os.Id).size() > 1)
n3.label = 'Product '+prodCount+' Stewardship '+quesCount;
else
n3.label = 'Product '+prodCount+' Stewardship';
n3.metatext = q.Onboarding_Product__r.Purchased_Product_Name__c;
n3.name = pr.Id+'-PSA-'+sap.name;
n3.color = 'green';
n3.expanded = false;
quesCount++;
quesNodes.add(n3);
}
n2.items = quesNodes;
}*/
                                        prodCount++;
                                    }
                                    n1.items = prodNodes;
                                }
                                
                            }
                            psNode.items = shipNodes;
                        }
                        nodeList.add(n);
                    }
                }
            }
            return nodeList;
        }
        catch(Exception e){
            return e.getMessage();
        }
    }
    @AuraEnabled
    public static Onboarding_Ship_To__c getShipToDetails(String ostId){
        return [SELECT Id, Name, Ship_To_Company_Name__c,Invoice_Copies__c,Invoice_Copies_Email_Fax__c,SDS_Delivery_Email_Fax__c,Order_Confirmation_Email_Fax__c,Bill_of_Lading_Email_Fax__c,Certificate_of_Analysis_Email_Fax__c,Preferred_Method_of_MSDS_Delivery__c,Preferred_Method_of_Order_Confirmation__c,Preferred_Method_of_Bill_of_Lading__c,
                Preferred_Method_of_Certifi_of_Analysis__c, Ship_To_Country__c, Ship_To_Section_Completed__c, (SELECT Id, Shipment_Questionnaire__c, Customer_Pickup__c, New_Customer_Ship_Mode__c, Product_Family__c FROM Onboarding_Products__r) FROM Onboarding_Ship_To__c WHERE Id =:ostId];
    }
    @AuraEnabled
    public static List<Onboarding_Ship_To__c> getShipToAndProducts(String sapId){
        return [SELECT Id, Name, Ship_To_Company_Name__c,Ship_To_Section_Completed__c ,(SELECT Id, Name,Product_Section_Completed__c, Purchased_Product_Name__c, All_Questionnaire_Completed__c FROM Onboarding_Products__r) FROM Onboarding_Ship_To__c WHERE SAP_Onboarding__c =:sapId];
    }
    
    @AuraEnabled
    public static List<Application_User__c> fetchAppUsers(String sapRecordId, String email, String sapNo){
        return [SELECT Id, First_Name__c, Email__c, Last_Name__c, Title__c FROM Application_User__c WHERE (SAP_Onboarding__c =:sapRecordId OR SAP_Onboarding__r.Name =:sapNo) AND (Email__c !=: email) ORDER BY CreatedDate ASC];
    }
    
    @AuraEnabled
    public static Account fetchAccountDetails(String sapId, String sapName){
        SAP_Onboarding__c sapRecord = New SAP_Onboarding__c();
        if(String.isNotBlank(sapId))
            sapRecord = [SELECT Id, Account__c FROM SAP_Onboarding__c WHERE Id =:sapId];
        else
            sapRecord = [SELECT Id, Account__c FROM SAP_Onboarding__c WHERE Name =:sapName];
        
        return [SELECT Id, Name, RecordType.Name, AccountNumber_R1__c, BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry, OwnerId, Owner.Name FROM Account WHERE Id=:sapRecord.Account__c];
    }
    @AuraEnabled
    public static void updateOnboardingProduct(Onboarding_Product__c prod){
        update prod;
    }
    @AuraEnabled
    public static void updateOnboardingShipTo(Onboarding_Ship_To__c shipTo){
        update shipTo;
    }
    
    @AuraEnabled
    public static List<Attachment> fetchAttachments(String parentId, String fileDescString){
        System.debug('parentId==='+parentId);
        System.debug('fileDescString==='+fileDescString);
        List<Attachment> returnList = new List<Attachment>();
        Set<Id> parentIds = new Set<Id>();
        if(fileDescString == 'taxFile'){
            for(VAT__c vt : [SELECT Id FROM VAT__c WHERE SAP_Onboarding__c =: parentId]){
                parentIds.add(vt.Id);
            }
        }
        else if(fileDescString.containsIgnoreCase('Questionnaire')){
            for(Questionnaire__c q : [SELECT Id FROM Questionnaire__c WHERE Onboarding_Product__c =:parentId]){
                parentIds.add(q.Id);
            }
        }
        else{
            parentIds.add(parentId);
        }
        System.debug('parentIds==='+parentIds);
        for(Attachment att : [SELECT Id, Name, ParentId, Description, body, ContentType FROM Attachment WHERE ParentId IN:parentIds]){
            if(String.isNotBlank(att.Description) && att.Description.containsIgnoreCase(fileDescString)){
                returnList.add(att);
            }
        }
        
        return returnList;
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
        oAttachment.Name = 'Customer-'+fileName;
        oAttachment.Description = description;
        oAttachment.ContentType = contentType;
        
        insert oAttachment;        
        return oAttachment.Id;
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
    public static void deleteAttachment(String recordId){
        if(String.isNotBlank(recordId)){
            delete new Attachment(Id = recordId);
        }
    }
    @AuraEnabled 
    public static Onboarding_Product__c getProductDetails(String prodId){
        Onboarding_Product__c op = new Onboarding_Product__c();     
        Set<String> allFields = fields(op.getSobjectType());
        allFields.add('Onboarding_Ship_To__r.Ship_To_Country__c');
        allFields.add('Onboarding_Ship_To__r.Ship_To_Company_Name__c');
        String query = 'SELECT Purchased_Product_Name__c,New_Customer_Ship_Mode__c, Purchased_Product__r.Product_R1__r.Business_Group__c, Purchased_Product__r.Product_R1__r.PerformanceCenter_R1__c, Purchased_Product__r.Product_R1__r.PH1_Performance_Center__c,Purchased_Product__r.Performance_Center__c, ';
        for(String fieldName : allFields){
            query += fieldName+',';
        }
        query = query.removeEnd(',');
        query += ' FROM Onboarding_Product__c WHERE Id =:prodId';
        return database.query(query);
    }
    @AuraEnabled 
    public static void sendEmailToAppUser(String toRecordId, String fromRecordId){
        Application_User__c toAppUser = [SELECT Id, Comment__c, Email__c, Shared__c FROM Application_User__c WHERE Id=:toRecordId];
        Application_User__c fromAppUser = new Application_User__c();
        OrgWideEmailAddress owe =  [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address='olinsalesforce@olin.com'];
        if(String.isNotBlank(fromRecordId)){
            fromAppUser = [SELECT Id, Email__c,First_Name__c, Last_Name__c, Comment__c, Shared__c FROM Application_User__c WHERE Id=:fromRecordId];
        }
        else{
            fromAppUser.First_Name__c = UserInfo.getFirstName();
            fromAppUser.Last_Name__c = UserInfo.getLastName();
            fromAppUser.Email__c = UserInfo.getUserEmail();
        }
        EmailTemplate shareEmailTemplate = [Select id, Subject, HtmlValue, Body from EmailTemplate where name ='SAP Onboarding Invite Colleague'];
        Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
        List<String> sendTo = new List<String>();
        sendTo.add(toAppUser.Email__c);
        mail.setToAddresses(sendTo);
        mail.setReplyTo('noreply@cipaq.com');
        //mail.setSenderDisplayName('Olin Support');
        //mail.setTargetObjectId(UserInfo.getUserId());
        mail.setOrgWideEmailAddressId(owe.Id);
        mail.setSaveAsActivity(false);
        // Set email contents
        String htmlBody = shareEmailTemplate.HtmlValue;
        htmlBody = htmlBody.replaceAll('FirstName', fromAppUser.First_Name__c);
        htmlBody = htmlBody.replaceAll('LastName', fromAppUser.Last_Name__c);
        htmlBody = htmlBody.replace('EmailAddress', fromAppUser.Email__c);
        htmlBody = htmlBody.replace('UserComment', String.isNotBlank(toAppUser.Comment__c) ? toAppUser.Comment__c : '');
        mail.setHtmlBody(htmlBody);
        mail.setSubject(shareEmailTemplate.Subject);
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {mail});
    }
    
    
    @AuraEnabled
    public static List<Questionnaire__c> getQuestionnaire(String prodId){
        System.debug('prodId===='+prodId);
        Questionnaire__c ques = new Questionnaire__c();
        Set<String> allFields = fields(ques.getSobjectType());
        if(!allFields.contains('Account_Name__c') && !allFields.contains('account_name__c'))
            allFields.add('Account_Name__c');
        if(!allFields.contains('Status__c') && !allFields.contains('status__c'))
            allFields.add('Status__c');
        
        String query = 'SELECT Onboarding_Product__r.Customer_Pickup__c	, Onboarding_Product__r.Onboarding_Ship_To__c, Onboarding_Product__r.Shipment_Questionnaire__c, Onboarding_Product__r.Product_Name_Form__c, Onboarding_Product__r.Ship_Mode__c, RecordType.Name,Onboarding_Product__r.Onboarding_Ship_To__r.Ship_To_Company_Name__c,Onboarding_Product__r.Onboarding_Ship_To__r.Ship_To_Country__c,Onboarding_Product__r.Onboarding_Ship_To__r.Ship_To_Street__c, Onboarding_Product__r.Onboarding_Ship_To__r.Ship_To_City__c, Onboarding_Product__r.Onboarding_Ship_To__r.Ship_To_State_Province__c, ';
        for(String fieldName : allFields){
            query += fieldName+',';
        }
        query = query.removeEnd(',');
        query += ' FROM Questionnaire__c WHERE Onboarding_Product__c =:prodId';
        system.debug('query is===='+query);
        List<Questionnaire__c> allQuestionnaires = new List<Questionnaire__c>();
        allQuestionnaires = Database.query(query);
        if(allQuestionnaires.size() > 0){
            if(allQuestionnaires[0].Status__c == 'New' || String.isBlank(allQuestionnaires[0].Status__c))
                Update new Questionnaire__c(Id = allQuestionnaires[0].Id, Status__c = 'Customer In Progress');
        }
        return Database.query(query);
    }
    
    
    @AuraEnabled
    public static List<VAT__c> saveVat(List<VAT__c> vatRecords, Boolean isFirstTime){
        List<Vat__c> existingVat = new List<Vat__c>();
        existingVat = [SELECT Id FROM VAT__c WHERE SAP_Onboarding__c =: vatRecords[0].SAP_Onboarding__c];
        if(isFirstTime && existingVat.size() == 0){
            upsert vatRecords;
        }
        else if(!isFirstTime){
            upsert vatRecords;
        }
        
        return [SELECT Country__c, SAP_Onboarding__c, Tax_VAT1_Exempt__c, VAT_Tax_Number__c,Tax_Type__c, Tax_Type_Code__c FROM VAT__c WHERE SAP_Onboarding__c =: vatRecords[0].SAP_Onboarding__c];
    }
    
    @AuraEnabled
    public static List<VAT__c> getVatRecords(String sapId){
        return [SELECT Country__c, SAP_Onboarding__c, Tax_VAT1_Exempt__c, VAT_Tax_Number__c,Tax_Type__c, Tax_Type_Code__c FROM VAT__c WHERE SAP_Onboarding__c =:sapId];
    }
    @AuraEnabled
    public static void deleteVat(String recordId){
        delete [SELECT Id FROM VAT__c WHERE Id =:recordId];
    }
    @AuraEnabled
    public static void deleteAndSwitchQuestionnaire(String quesId){
        String prodId = [SELECT Onboarding_Product__c FROM Questionnaire__c WHERE Id=:quesId].Onboarding_Product__c;
        delete [SELECT Id FROM Questionnaire__c WHERE Onboarding_Product__c =:prodId AND Id !=:quesId];
    }
    @AuraEnabled
    public static SAP_Onboarding__c getSapRecord(String sapRecordId, String sapNo){
        SAP_Onboarding__c sap = new SAP_Onboarding__c();
        Set<String> allFields = fields(sap.getSobjectType());
        if(!allFields.contains('Account__r.Name')){
            allFields.add('Account__r.Name');
        }
        if(!allFields.contains('Name')){
            allFields.add('Name');
        }
        allFields.add('Account__r.BillingCountry');
        String vatQuery = '(SELECT Country__c, SAP_Onboarding__c, Tax_VAT1_Exempt__c, VAT_Tax_Number__c,Tax_Type__c, Tax_Type_Code__c FROM VAT1__r)';
        String appUserQuery = '(SELECT Id, Name, Email__c FROM Application_User__r)';
        String query = 'SELECT ';
        for(String fieldName : allFields){
            query += fieldName+',';
        }
        query = query+vatQuery+','+appUserQuery;
        if(String.isNotBlank(sapRecordId)){
            query += ' FROM SAP_Onboarding__c WHERE Id =:sapRecordId';
        }
        else{
            query += ' FROM SAP_Onboarding__c WHERE Name =:sapNo';
        }
        system.debug('query is===='+query);
        return Database.query(query);
    }
    
    @AuraEnabled
    public static void saveSapOnboarding(SAP_Onboarding__c sapRecord, String currentAppUser){
        System.debug('sapRecord=='+sapRecord.Status__c);
        System.debug('@@@@'+sapRecord.VAT1__r);
        if(sapRecord.Customer_Information_Status__c == 'Customer Submitted' && String.isNotBlank(currentAppUser)){
            sapRecord.Customer_Information_Submitted_By__c = currentAppUser;
            sapRecord.Customer_Information_Submitted_On__c = System.now();
        }
        if(sapRecord.Order_Placement_Status__c == 'Customer Submitted' && String.isNotBlank(currentAppUser)){
            sapRecord.Document_Delivery_Submitted_By__c = currentAppUser;
            sapRecord.Document_Delivery_Submitted_On__c = System.now();
        }
        if(sapRecord.Credit_Application_Status__c == 'Customer Submitted' && String.isNotBlank(currentAppUser)){
            sapRecord.Credit_Application_Submitted_By__c = currentAppUser;
            sapRecord.Credit_Application_Submitted_On__c = System.now();
        }
        if(sapRecord.Product_Stewardship_Status__c == 'Customer Submitted' && String.isNotBlank(currentAppUser)){
            sapRecord.Product_Stewardship_Submitted_By__c = currentAppUser;
            sapRecord.Product_Stewardship_Submitted_On__c = System.now();
        }
        update sapRecord;
        System.debug('sapRecord=='+sapRecord.Status__c);
    }
    
    @AuraEnabled
    public static void updateVatRecords(List<VAT__c> recordList){
        upsert recordList;
    }
    
    @AuraEnabled
    public static Questionnaire__c saveQuestionnaire(List<Questionnaire__c> recordList, Boolean isFormSubmit){
        If(recordList[0].Questionnaire_Setup_Type__c == 'Offline'){
            recordList[0].RecordTypeId = Schema.SObjectType.Questionnaire__c.getRecordTypeInfosByName().get('Offline').getRecordTypeId();
        }
        String mainRecordId = '';
        if(!isFormSubmit){
            upsert recordList;
            mainRecordId = recordList[0].Id;
        }
        else{
            List<Questionnaire__c> toUpdateList = new List<Questionnaire__c>();
            for(Questionnaire__c ques : recordList){
                ques.Questionnaire_Section_Completed__c = true;
                ques.Status__c = 'Submitted';
                toUpdateList.add(ques);
            }
            upsert toUpdateList;
            mainRecordId = toUpdateList[0].Id;
            Onboarding_Product__c prod = new Onboarding_Product__c();
            prod.All_Questionnaire_Completed__c = true;
            prod.Id = recordList[0].Onboarding_Product__c;
            update prod;
        }
        Questionnaire__c ques = new Questionnaire__c();
        Set<String> allFields = fields(ques.getSobjectType());
        if(!allFields.contains('Account_Name__c') && !allFields.contains('account_name__c'))
            allFields.add('Account_Name__c');
        
        String query = 'SELECT Onboarding_Product__r.Onboarding_Ship_To__c, Onboarding_Product__r.Shipment_Questionnaire__c, Onboarding_Product__r.Product_Name_Form__c, Onboarding_Product__r.Ship_Mode__c, RecordType.Name,Onboarding_Product__r.Onboarding_Ship_To__r.Ship_To_Company_Name__c,Onboarding_Product__r.Onboarding_Ship_To__r.Ship_To_Country__c,Onboarding_Product__r.Onboarding_Ship_To__r.Ship_To_Street__c, Onboarding_Product__r.Onboarding_Ship_To__r.Ship_To_City__c, Onboarding_Product__r.Onboarding_Ship_To__r.Ship_To_State_Province__c, ';
        for(String fieldName : allFields){
            query += fieldName+',';
        }
        query = query.removeEnd(',');
        query += ' FROM Questionnaire__c WHERE Id =:mainRecordId';
        return Database.query(query);
    }
    
    @AuraEnabled
    public static void deleteQuestionnaire(String recordId){
        delete [SELECT Id FROM Questionnaire__c WHERE Id =:recordId];
    }
    
    @AuraEnabled
    public static void deleteAppUserRecord(string recordId){
        Application_User__c ap = new Application_User__c(Id=recordId);
        delete ap;
    }
    
    /*@AuraEnabled
    public static Map<String, List<String>> getTaxTypeDependentOptions(){
        return HL_FieldDescribeUtil.getDependentOptionsImpl(VAT__c.Tax_Type__c, VAT__c.Country__c);
    }*/
    
    private static Set<String> fields(Schema.sObjectType t) {
        Set<String> resultFields = new Set<String>();
        Map<String, Schema.SObjectField> fields = t.getDescribe().fields.getMap();
        for(String fieldName : fields.keySet()){
            Schema.SObjectField field = fields.get(fieldName);
            if(field.getDescribe().isAccessible() && field.getDescribe().isUpdateable() && field.getDescribe().isCreateable()){
                resultFields.add(fieldName);
            }
        }
        return resultFields;
    }
    
    class ShipToAccounts {
        @AuraEnabled public Onboarding_Ship_To__c shipTo;
        @AuraEnabled public List<Onboarding_Product__c> prodList;
        public ShipToAccounts(Onboarding_Ship_To__c ship, List<Onboarding_Product__c> prList){
            this.shipTo = ship;
            this.prodList = prList;
        }
    }
    
    
    
    public class Node{
        @AuraEnabled public String label;
        @AuraEnabled public String name;
        @AuraEnabled public String color;
        @AuraEnabled public Boolean expanded;
        @AuraEnabled public String nodeLangId;
        @AuraEnabled public String metatext;
        @AuraEnabled public List<Node> items;
        public Node(){
            this.items = new List<Node>();
        }
    }
}