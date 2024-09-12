public class sapOnboardingTriggerHandler {
    public static Boolean isFirstTime = true;
    public static void afterupdateSap(List<SAP_Onboarding__c> saponboardinglist){
        Set<Id> setId = new Set <Id>();
        for(SAP_Onboarding__c op : saponboardinglist){
            setId.add(op.Id);
        }
        list<SAP_Onboarding__c> sapList = new list<SAP_Onboarding__c>([SELECT Id,Send_Invitation_Email_to_Main_Contact__c,Invitation_Email_sent__c, Main_Onboarding_Contact__r.Email,
                                                                       (SELECT Id from Onboarding_Products__r)
                                                                       FROM SAP_Onboarding__c Where Id IN :setId]);
        for(SAP_Onboarding__c sap : sapList){
            system.debug('sap'+sap);
            if( sap.Send_Invitation_Email_to_Main_Contact__c == 'Yes' && sap.Invitation_Email_sent__c == false){
                
                EmailTemplate et = [SELECT Id,subject,HTMLValue FROM EmailTemplate WHERE Name ='SAP Onboarding with Link'];
                Messaging.SingleEmailMessage emailTobesent = new Messaging.SingleEmailMessage();
                List<String> toAddresses=new list<String>{sap.Main_Onboarding_Contact__r.Email};
                    system.debug('toAddresses'+toAddresses);
                emailTobesent.setTemplateId(et.Id);
                emailTobesent.setSubject(et.subject);
                emailTobesent.setHtmlBody(et.HTMLValue);
                emailTobesent.setToAddresses(toAddresses);
                system.debug('emailTobesent'+emailTobesent);
                if(toAddresses != null && toAddresses.size() > 0){
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {emailTobesent});
                    sap.Invitation_Email_sent__c = True;
                }
            }
        }
        UPDATE sapList;
    }
    
    public static void processSharing(List<SAP_Onboarding__c> lstSapOnboarding, Map<Id, SAP_Onboarding__c> oldMap, Boolean isInsert) {
        Map<String, List<String>> mapSoldToIdToSapOnboardingIds = new Map<String, List<String>>();
        Map<String, String> mapSapOnboardingIdToSapOnboardingOwnerIds = new Map<String, String>();
        Set<String> sapOnboardingIds = new Set<String>();
        Set<String> soldToIds = new Set<String>();
        List<SAP_Onboarding__Share> lstSapOnboardingShare = new List<SAP_Onboarding__Share>();
        List<SAP_Onboarding__Share> lstSapOnboardingDel = new List<SAP_Onboarding__Share>();
        for(SAP_Onboarding__c so: lstSapOnboarding){
            if(isInsert || (!IsInsert && (oldMap.get(so.Id).Account__c != so.Account__c))) {
                if(!mapSoldToIdToSapOnboardingIds.containsKey(so.Account__c)){
                    mapSoldToIdToSapOnboardingIds.put(so.Account__c, new List<String>());
                }
                mapSoldToIdToSapOnboardingIds.get(so.Account__c).add(so.Id);
                sapOnboardingIds.add(so.Id);
                mapSapOnboardingIdToSapOnboardingOwnerIds.put(so.Id, so.OwnerId);
                soldToIds.add(so.Account__c);
            }
        }
        
        List<AccountTeamMember> newLstAccountTeamMember = [SELECT Id, AccountId, UserId, User.Name, User.IsActive, TeamMemberRole, AccountAccessLevel, OpportunityAccessLevel 
                                                           FROM AccountTeamMember
                                                           WHERE AccountId IN: soldToIds AND User.IsActive = true];
        for(AccountTeamMember teamMember : newLstAccountTeamMember) {
            if(mapSoldToIdToSapOnboardingIds.get(teamMember.AccountId) != null && !mapSoldToIdToSapOnboardingIds.get(teamMember.AccountId).isEmpty()) {
                for(String soId : mapSoldToIdToSapOnboardingIds.get(teamMember.AccountId)) {
                    if(mapSapOnboardingIdToSapOnboardingOwnerIds.get(soId) != null) {
                        if(teamMember.UserId != mapSapOnboardingIdToSapOnboardingOwnerIds.get(soId)) {
                            SAP_Onboarding__Share soShare = new SAP_Onboarding__Share();
                            soShare.ParentId = soId;
                            soShare.UserOrGroupId = teamMember.UserId;
                            if(teamMember.OpportunityAccessLevel == 'Edit') {
                                soShare.AccessLevel = 'Edit';
                            } 
                            else {
                                soShare.AccessLevel = 'Read';
                            }
                            soShare.RowCause = 'Manual';
                            lstSapOnboardingShare.add(soShare);
                        }
                    }
                }
            }
        }
        
        lstSapOnboardingDel = [SELECT Id, ParentId, RowCause FROM SAP_Onboarding__Share WHERE ParentId IN: sapOnboardingIds AND RowCause = 'PROG_FORECAST__c'];
        if(lstSapOnboardingDel.size() > 0){
            delete lstSapOnboardingDel;
        }
        
        if(lstSapOnboardingShare.size() > 0){
            insert lstSapOnboardingShare;
        }
    }
    
    /*public static void handleContacts(List<SAP_Onboarding__c> sapList){
        Set<String> allEmails = new Set<String>();
        List<Contact> contactsToUpdate = new List<Contact>();
        Map<String, List<Contact>> contactsMap = new Map<String, List<Contact>>();
        Map<String, Set<Id>> accountContactMap = new Map<String, Set<Id>>();
        Set<Id> accIds = new Set<Id>();
        List<Contact> newContactList = new List<Contact>();
        Map<Id, Contact> toUpdateContactMap = new Map<Id, Contact>();
        List<AccountContactRelation> newRelations = new List<AccountContactRelation>();
        for(SAP_Onboarding__c sap : sapList){
            accIds.add(sap.Account__c);
            if(String.isNotBlank(sap.Order_Placement_Email__c)){
                allEmails.add(sap.Order_Placement_Email__c);
            }
            if(String.isNotBlank(sap.Contract_Notification_Email__c)){
                allEmails.add(sap.Contract_Notification_Email__c);
            }
            if(String.isNotBlank(sap.Account_Payable_Email__c)){
                allEmails.add(sap.Account_Payable_Email__c);
            }
            if(String.isNotBlank(sap.Email_Invoice_Email_Address__c)){
                allEmails.add(sap.Email_Invoice_Email_Address__c);
            }
            if(String.isNotBlank(sap.Credit_Email__c)){
                allEmails.add(sap.Credit_Email__c);
            }
            if(String.isNotBlank(sap.CXO_Officer_Email__c)){
                allEmails.add(sap.CXO_Officer_Email__c);
            }
        }
        for(AccountContactRelation ar : [SELECT Id, AccountId, ContactId FROM AccountContactRelation WHERE AccountId IN :accIds]){
            if(!accountContactMap.containsKey(ar.AccountId)){
                accountContactMap.put(ar.AccountId, new Set<Id>());
            }
            accountContactMap.get(ar.AccountId).add(ar.ContactId);
        }
        for(Contact con : [SELECT Id, Email, FirstName, LastName, Phone, Title, Fax FROM Contact WHERE Email IN :allEmails]){
            if(!contactsMap.containsKey(con.Email)){
                contactsMap.put(con.Email, new List<Contact>());
            }
            contactsMap.get(con.Email).add(con);
        }
        System.debug('accountContactMap=='+accountContactMap);
        System.debug('contactsMap=='+contactsMap);
        for(SAP_Onboarding__c sap : sapList){
            if(String.isNotBlank(sap.Order_Placement_Email__c)){
                if(contactsMap.containsKey(sap.Order_Placement_Email__c) && contactsMap.get(sap.Order_Placement_Email__c).size() > 0){
                    for(Contact con : contactsMap.get(sap.Order_Placement_Email__c)){
                        con.FirstName = sap.Order_Placement_First_Name__c == null  ? con.FirstName : sap.Order_Placement_First_Name__c;
                        con.LastName = sap.Order_Placement_Last_Name__c == null  ? con.LastName : sap.Order_Placement_Last_Name__c;
                        con.Title = sap.Order_Placement_Title__c == null ? con.Title : sap.Order_Placement_Title__c;
                        con.Phone = sap.Order_Placement_Phone__c == null ? con.Phone : sap.Order_Placement_Phone__c;
                        con.Customer_Setup_Responsibility__c = 'Order Placement';
                        toUpdateContactMap.put(con.Id, con);
                        //contactsToUpdate.add(con);
                        if(accountContactMap.containsKey(sap.Account__c) && !accountContactMap.get(sap.Account__c).contains(con.Id)){
                            AccountContactRelation ar = new AccountContactRelation();
                            ar.AccountId = sap.Account__c;
                            ar.ContactId = con.Id;
                            ar.IsActive = true;
                            newRelations.add(ar);
                        }
                    }
                }
                else{
                    if(sap.Order_Placement_Last_Name__c != null){
                        Contact con = new Contact();
                        con.FirstName = sap.Order_Placement_First_Name__c;
                        con.LastName = sap.Order_Placement_Last_Name__c;
                        con.Title = sap.Order_Placement_Title__c;
                        con.Email = sap.Order_Placement_Email__c;
                        con.Phone = sap.Order_Placement_Phone__c;
                        con.AccountId = sap.Account__c;
                        newContactList.add(con);
                    }
                }
            }
            if(String.isNotBlank(sap.Contract_Notification_Email__c)){
                if(contactsMap.containsKey(sap.Contract_Notification_Email__c) && contactsMap.get(sap.Contract_Notification_Email__c).size() > 0){
                    for(Contact con : contactsMap.get(sap.Contract_Notification_Email__c)){
                        con.FirstName = sap.Contract_Notification_First_Name__c == null  ? con.FirstName : sap.Contract_Notification_First_Name__c;
                        con.LastName = sap.Contract_Notification_Last_Name__c == null  ? con.LastName : sap.Contract_Notification_Last_Name__c;
                        con.Title = sap.Contract_Notification_Title__c == null ? con.Title : sap.Contract_Notification_Title__c;
                        con.Phone = sap.Contract_Notification_Phone__c == null ? con.Phone : sap.Contract_Notification_Phone__c;
                        con.Customer_Setup_Responsibility__c = 'Contract Notification';
                        toUpdateContactMap.put(con.Id, con);
                        //contactsToUpdate.add(con);
                        if(accountContactMap.containsKey(sap.Account__c) && !accountContactMap.get(sap.Account__c).contains(con.Id)){
                            AccountContactRelation ar = new AccountContactRelation();
                            ar.AccountId = sap.Account__c;
                            ar.ContactId = con.Id;
                            ar.IsActive = true;
                            newRelations.add(ar);
                        }
                    }
                }
                else{
                    if(sap.Contract_Notification_Last_Name__c != null){
                        Contact con = new Contact();
                        con.FirstName = sap.Contract_Notification_First_Name__c;
                        con.LastName = sap.Contract_Notification_Last_Name__c;
                        con.Title = sap.Contract_Notification_Title__c;
                        con.Email = sap.Contract_Notification_Email__c;
                        con.Phone = sap.Contract_Notification_Phone__c;
                        con.AccountId = sap.Account__c;
                        newContactList.add(con);
                    }
                }
            }
            if(String.isNotBlank(sap.Account_Payable_Email__c)){
                if(contactsMap.containsKey(sap.Account_Payable_Email__c) && contactsMap.get(sap.Account_Payable_Email__c).size() > 0){
                    for(Contact con : contactsMap.get(sap.Account_Payable_Email__c)){
                        con.FirstName = sap.Account_Payable_First_Name__c == null  ? con.FirstName : sap.Account_Payable_First_Name__c;
                        con.LastName = sap.Account_Payable_Last_Name__c == null  ? con.LastName : sap.Account_Payable_Last_Name__c;
                        con.Title = sap.Account_Payable_Title__c == null ? con.Title : sap.Account_Payable_Title__c;
                        con.Phone = sap.Account_Payable_Phone__c == null ? con.Phone : sap.Account_Payable_Phone__c;
                        con.Customer_Setup_Responsibility__c = 'Accounts Payable';
                        toUpdateContactMap.put(con.Id, con);
                        //contactsToUpdate.add(con);
                        if(accountContactMap.containsKey(sap.Account__c) && !accountContactMap.get(sap.Account__c).contains(con.Id)){
                            AccountContactRelation ar = new AccountContactRelation();
                            ar.AccountId = sap.Account__c;
                            ar.ContactId = con.Id;
                            ar.IsActive = true;
                            newRelations.add(ar);
                        }
                    }
                }
                else{
                    if(sap.Account_Payable_Last_Name__c != null){
                        Contact con = new Contact();
                        con.FirstName = sap.Account_Payable_First_Name__c;
                        con.LastName = sap.Account_Payable_Last_Name__c;
                        con.Title = sap.Account_Payable_Title__c;
                        con.Email = sap.Account_Payable_Email__c;
                        con.Phone = sap.Account_Payable_Phone__c;
                        con.AccountId = sap.Account__c;
                        newContactList.add(con);
                    }
                }
            }
            if(String.isNotBlank(sap.Email_Invoice_Email_Address__c)){
                if(contactsMap.containsKey(sap.Email_Invoice_Email_Address__c) && contactsMap.get(sap.Email_Invoice_Email_Address__c).size() > 0){
                    for(Contact con : contactsMap.get(sap.Email_Invoice_Email_Address__c)){
                        con.FirstName = sap.Email_Invoice_First_Name__c == null  ? con.FirstName : sap.Email_Invoice_First_Name__c;
                        con.LastName = sap.Email_Invoice_Last_Name__c == null  ? con.LastName : sap.Email_Invoice_Last_Name__c;
                        con.Title = sap.Email_Invoice_Title__c == null ? con.Title : sap.Email_Invoice_Title__c;
                        con.Phone = sap.Email_Invoice_Phone__c == null ? con.Phone : sap.Email_Invoice_Phone__c;
                        con.Customer_Setup_Responsibility__c = 'Invoice';
                        toUpdateContactMap.put(con.Id, con);
                        //contactsToUpdate.add(con);
                        if(accountContactMap.containsKey(sap.Account__c) && !accountContactMap.get(sap.Account__c).contains(con.Id)){
                            AccountContactRelation ar = new AccountContactRelation();
                            ar.AccountId = sap.Account__c;
                            ar.ContactId = con.Id;
                            ar.IsActive = true;
                            newRelations.add(ar);
                        }
                    }
                }
                else{
                    if(sap.Email_Invoice_Last_Name__c != null){
                        Contact con = new Contact();
                        con.FirstName = sap.Email_Invoice_First_Name__c;
                        con.LastName = sap.Email_Invoice_Last_Name__c;
                        con.Title = sap.Email_Invoice_Title__c;
                        con.Email = sap.Email_Invoice_Email_Address__c;
                        con.Phone = sap.Email_Invoice_Phone__c;
                        con.AccountId = sap.Account__c;
                        newContactList.add(con);
                    }
                }
            }
            if(String.isNotBlank(sap.Credit_Email__c)){
                if(contactsMap.containsKey(sap.Credit_Email__c) && contactsMap.get(sap.Credit_Email__c).size() > 0){
                    for(Contact con : contactsMap.get(sap.Credit_Email__c)){
                        con.FirstName = sap.Credit_First_Name__c == null  ? con.FirstName : sap.Credit_First_Name__c;
                        con.LastName = sap.Credit_Last_Name__c == null  ? con.LastName : sap.Credit_Last_Name__c;
                        con.Title = sap.Credit_Title__c == null ? con.Title : sap.Credit_Title__c;
                        con.Phone = sap.Credit_Phone__c == null ? con.Phone : sap.Credit_Phone__c;
                        con.Customer_Setup_Responsibility__c = 'Credit';
                        toUpdateContactMap.put(con.Id, con);
                        //contactsToUpdate.add(con);
                        if(accountContactMap.containsKey(sap.Account__c) && !accountContactMap.get(sap.Account__c).contains(con.Id)){
                            AccountContactRelation ar = new AccountContactRelation();
                            ar.AccountId = sap.Account__c;
                            ar.ContactId = con.Id;
                            ar.IsActive = true;
                            newRelations.add(ar);
                        }
                    }
                }
                else{
                    if(sap.Credit_Last_Name__c != null){
                        Contact con = new Contact();
                        con.FirstName = sap.Credit_First_Name__c;
                        con.LastName = sap.Credit_Last_Name__c;
                        con.Title = sap.Credit_Title__c;
                        con.Email = sap.Credit_Email__c;
                        con.AccountId = sap.Account__c;
                        con.Phone = sap.Credit_Phone__c;
                        newContactList.add(con);
                    }
                }
            }
            if(String.isNotBlank(sap.CXO_Officer_Email__c)){
                if(contactsMap.containsKey(sap.CXO_Officer_Email__c) && contactsMap.get(sap.CXO_Officer_Email__c).size() > 0){
                    for(Contact con : contactsMap.get(sap.CXO_Officer_Email__c)){
                        con.FirstName = sap.CXO_Officer_First_Name__c == null  ? con.FirstName : sap.CXO_Officer_First_Name__c;
                        con.LastName = sap.CXO_Officer_Last_Name__c == null  ? con.LastName : sap.CXO_Officer_Last_Name__c;
                        con.Title = sap.CXO_Officer_Title__c == null ? con.Title : sap.CXO_Officer_Title__c;
                        con.Phone = sap.CXO_Officer_Phone__c == null ? con.Phone : sap.CXO_Officer_Phone__c;
                        con.Customer_Setup_Responsibility__c = 'CFO';
                        toUpdateContactMap.put(con.Id, con);
                        //contactsToUpdate.add(con);
                        if(accountContactMap.containsKey(sap.Account__c) && !accountContactMap.get(sap.Account__c).contains(con.Id)){
                            AccountContactRelation ar = new AccountContactRelation();
                            ar.AccountId = sap.Account__c;
                            ar.ContactId = con.Id;
                            ar.IsActive = true;
                            newRelations.add(ar);
                        }
                    }
                }
                else{
                    if(sap.CXO_Officer_Last_Name__c != null){
                        Contact con = new Contact();
                        con.FirstName = sap.CXO_Officer_First_Name__c;
                        con.LastName = sap.CXO_Officer_Last_Name__c;
                        con.Title = sap.CXO_Officer_Title__c;
                        con.Email = sap.CXO_Officer_Email__c;
                        con.Phone = sap.CXO_Officer_Phone__c;
                        con.AccountId = sap.Account__c;
                        newContactList.add(con);
                    }
                }
            }
        }
        if(toUpdateContactMap.size() > 0){
            update toUpdateContactMap.values();
        }
        
        if(newContactList.size() > 0){
            insert newContactList;
        }
        
        if(newRelations.size() > 0){
            insert newRelations;
            
            //----Adding Customer Setup's Sales Rep as an Account Team Member if a matching Contact is found related to a different account---Code Added by Gaurish on 6th Dec'21
            Set<Id> newAccIds = new Set<Id>();
            Map<Id,Set<Id>> accUserIdMap = new Map<Id,Set<Id>>();
            List<AccountTeamMember> newAccTeamMem = new List<AccountTeamMember>();
            
            for(AccountContactRelation ar: newRelations){
                newAccIds.add(ar.AccountId);
            }
            for(AccountTeamMember atm: [SELECT Id,AccountId,UserId From AccountTeamMember WHERE AccountId IN: newAccIds]){
                if(!accUserIdMap.containsKey(atm.AccountId)){
                    accUserIdMap.put(atm.AccountId, new Set<Id>());
                }
                accUserIdMap.get(atm.AccountId).add(atm.UserId);
            }
            for(SAP_Onboarding__c sap: sapList){
                if(sap.Account__c != null && sap.Sales_Rep__c != null && accUserIdMap.containsKey(sap.Account__c) && !accUserIdMap.get(sap.Account__c).contains(sap.Sales_Rep__c)){
                    newAccTeamMem.add(new AccountTeamMember(AccountId=sap.Account__c,UserId=sap.Sales_Rep__c,TeamMemberRole='Customer Service Rep', AccountAccessLevel='Read',OpportunityAccessLevel='Read'));
                }
            }
            if(newAccTeamMem.size() > 0){
                insert newAccTeamMem;
            }
        }
    }*/
}