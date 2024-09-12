public class OnboardLoginController {
    public Boolean isSignIn {get; set;}
    public String email {get; set;}
    public String accessCode {get; set;}
    public String errorMsg{get; Set;}
    public String fileBody{get;set;}
    public String languageHeaderString{get;set;}
    public List<String> languageHeaderList{get;set;}
    public String pagelanguage{get;set;}
    public map<String,String> languageBodyMap{get;set;}
    public String languageBody{get;set;}
    EmailTemplate templateId;
    public List<SelectOption> languageOption{get;set;}
    public OnboardLoginController(){
        isSignIn = false; 
        errorMsg = '';
        //pagelanguage = 'English';
        Cookie accCode = new Cookie('cook', '',null,0,false);
        ApexPages.currentPage().setCookies(new Cookie[]{accCode});
        
        String Store = [SELECT Id, Body FROM StaticResource WHERE Name = 'CustomerSetupLoginTranslation'].Body.toString();
        fileBody= JSON.serialize(Store);
        
    }
    
    public void setLanguageHeders(){
        languageHeaderList =(List<String>)JSON.deserialize(languageHeaderString, List<String>.class);
        languageOption=new List<SelectOption>();
        for(Integer i=1;i<languageHeaderList.size();i++){
            if(String.isNotBlank(languageHeaderList[i])){
            languageOption.add(new SelectOption(languageHeaderList[i],languageHeaderList[i]));
            }
        }
        
    }
    public void processTranslation(){
        System.debug('pagelanguage==='+pagelanguage);
        languageBodyMap = (map<String,String>)JSON.deserialize(languageBody,map<String,String>.class);
        System.debug('selectedLanguageBodyMap : '+languageBodyMap);
        
    }
    public PageReference sendAccessCode(){
        if(email != null && email != ''){
            List<Application_User__c> appUserList = [SELECT Id, Email__c, First_Name__c, SAP_Onboarding__r.SAP_S_4_No__c FROM Application_User__c WHERE Email__c =: email];
            if(!appUserList.isEmpty() && appUserList.size() > 0){
                errorMsg = '';
                isSignIn = True; 
                String randomNumber = String.valueof(Math.round((Math.random() * (900000) + 100000)));
                Map<string,OnboardingUserAccess__c> accessCodes = OnboardingUserAccess__c.getAll();
                if(accessCodes.containsKey(email.toLowercase())){
                    OnboardingUserAccess__c mc = OnboardingUserAccess__c.getValues(email.toLowercase());
                    mc.Access_Code__c = randomNumber;
                    update mc;
                    String dd = OnboardingUserAccess__c.getValues(email.toLowercase()).Access_Code__c;
                }
                else{
                    OnboardingUserAccess__c custSetting = new OnboardingUserAccess__c(name = email.toLowercase(), Access_Code__c = randomNumber);
                    insert custSetting;       
                }
                templateId = [Select id, Subject, HtmlValue, brandTemplateId, Body from EmailTemplate where name ='SAP Onboarding with Access Code' limit 1];
                String htmlBody = templateId.HtmlValue;
                htmlBody = htmlBody.replace('Code',randomNumber);
                Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
                //  list of people who should get the email
                List<String> sendTo = new List<String>();
                sendTo.add(email);
                mail.setToAddresses(sendTo);
                OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress LIMIT 1];
                if ( !owea.isEmpty()) {
                mail.setOrgWideEmailAddressId(owea[0].Id);
                }
                // Set email is sent from
                mail.setReplyTo('noreply@olin.com');
                //mail.setSenderDisplayName('Olin Support');
                mail.setTargetObjectId(UserInfo.getUserId());
                mail.setSaveAsActivity(false);
                mail.setSubject(templateId.Subject);
                mail.setTreatTargetObjectAsRecipient(false);
                mail.setHtmlBody(htmlBody);
                mail.setTemplateID(templateId.Id);
                System.debug('body '+mail.getHtmlBody());
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
            }
            else{
                errorMsg = 'VF_11';
            }
        }
        else{
            errorMsg = 'VF_12';
        }
        return null;
    }
    
    public PageReference onBoardLogin(){
        System.debug('pagelanguage==='+pagelanguage);
        OnboardingUserAccess__c mc = OnboardingUserAccess__c.getValues(email.toLowerCase());
        Onboard_Site_Access__c oc = Onboard_Site_Access__c.getValues('Default');
        system.debug(mc);
        system.debug('accessCode==='+accessCode);
        if(mc.Access_Code__c == accessCode){
            //PageReference pr = Page.OCO_CustomerPage;
            PageReference pr = Site.login(oc.UserName__c, oc.Password__c, '/s');
            pr.setRedirect(true);
            Cookie valEmail = new Cookie('cook',mc.Access_Code__c+':'+email,null,86400,false);
            pr.setCookies(new List<Cookie>{valEmail});
            OCO_CustomerController.saveAppUser(email.toLowerCase(), pagelanguage);
            system.debug('pr==='+pr);
            return pr;
        }
        else{
            errorMsg = 'VF_13';
        }
        isSignIn = True; 
        return null;
    }
    public void wrongEmail(){
        errorMsg = '';
        isSignIn = False; 
    }
    public void sendAccessCodeAgain(){
        if(email != null && email != ''){ 
            errorMsg = '';
            isSignIn = True; 
            String randomNumber = String.valueof(Math.round((Math.random() * (900000) + 100000)));
            Map<string,OnboardingUserAccess__c> accessCodes = OnboardingUserAccess__c.getAll();
            if(accessCodes.containsKey(email)){
                OnboardingUserAccess__c mc = OnboardingUserAccess__c.getValues(email);
                mc.Access_Code__c = randomNumber;
                update mc;
            }
            else{
                OnboardingUserAccess__c custSetting = new OnboardingUserAccess__c(name = email.toLowercase(), Access_Code__c = String.valueOf(randomNumber));
                insert custSetting;       
            }
            String htmlBody = templateId.HtmlValue;
            htmlBody = htmlBody.replace('Code',randomNumber);
            //htmlBody = htmlBody.replace(']]>', '');
            Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
            //  list of people who should get the email
            List<String> sendTo = new List<String>();
            sendTo.add(email);
            mail.setToAddresses(sendTo);
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress LIMIT 1];
            if ( !owea.isEmpty()) {
                mail.setOrgWideEmailAddressId(owea[0].Id);
            }
            // Set email is sent from
            mail.setReplyTo('noreply@cipaq.com');
            //mail.setSenderDisplayName('Olin Support');
            mail.setTargetObjectId(UserInfo.getUserId());
            mail.setSaveAsActivity(false);
            mail.setSubject(templateId.Subject);
            mail.setHtmlBody(htmlBody);
            // Set email contents
            mail.setTemplateID(templateId.Id);
            // Add your email to the master list
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
        }
    }
}