@isTest
public class CallReportTrigger_Test {
    /*
    static testmethod void newFCM()
    {
        // Create internal account
        Account acc = new Account(Name = 'FastChem Cooperation', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId());
        insert acc;
        
        User usr = [SELECT Id,UserRole.DeveloperName FROM User WHERE UserRoleId != null AND UserRole.DeveloperName != null AND Id !=: UserInfo.getUserId() LIMIT 1];
        
        Sharing__c sc = new Sharing__c();
        sc.Role_Name__c = usr.UserRole.DeveloperName;
        sc.Public_Group_s__c = 'CAPV_Midwest_Sales_Mgr_Up';
        insert sc;
        
        Team__c tem = new Team__c();
        tem.Account__c = acc.Id;
        tem.Team_Member__c = usr.id;
        tem.Team_Role__c = 'Account Manager';
        tem.Account_Access__c = 'Read/Write';
        tem.Opportunity_Access__c = 'Read Only';
        tem.Case_Access__c = 'Read Only';
        insert tem;
        
        System.runAs(usr){            
            FCM_VisitReport__c visitReport = new FCM_VisitReport__c(
                FCM_Account__c = acc.Id,
                FCM_Status__c = 'Planned',
                FCM_VisitDate__c = Date.today(),
                Confidential__c = false
            );
            insert visitReport;
        }
    }
    
    static testmethod void newFCM1()
    {
        // Create internal account
        Account acc = new Account(Name = 'FastChem Cooperation', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId());
        insert acc;
        
        User usr = [SELECT Id,UserRole.DeveloperName FROM User WHERE UserRoleId != null AND UserRole.DeveloperName != null AND Id !=: UserInfo.getUserId() LIMIT 1];
        
        Sharing__c sc = new Sharing__c();
        sc.Role_Name__c = usr.UserRole.DeveloperName;
        sc.Public_Group_s__c = 'CAPV_Midwest_Sales_Mgr_Up, NA_CST_Up';
        insert sc;
        
        Team__c tem = new Team__c();
        tem.Account__c = acc.Id;
        tem.Team_Member__c = usr.id;
        tem.Team_Role__c = 'Account Manager';
        tem.Account_Access__c = 'Read Only';
        tem.Opportunity_Access__c = 'Read Only';
        tem.Case_Access__c = 'Read Only';
        insert tem;
        
        System.runAs(usr){            
            FCM_VisitReport__c visitReport = new FCM_VisitReport__c(
                FCM_Account__c = acc.Id,
                FCM_Status__c = 'Planned',
                FCM_VisitDate__c = Date.today(),
                Confidential__c = false
            );
            insert visitReport;
        }
    }
    
    static testmethod void updFCM(){
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;
        
        // Create Users
        List<User> lstTestUser = new List<User>();
        Profile adminProfile = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator'];
        User testUser = new User(
            LastName = adminProfile.Name,
            FirstName = 'Test1',
            Email = adminProfile.Name.remove(' ') + '.' + 'Test1@fastchem.com.dev.test',
            Username = adminProfile.Name.remove(' ') + '.' + 'Test1@fastchem.com.dev.test',
            Alias = 'testusr1',
            CommunityNickname = 'test1' + adminProfile.Name.right(7),
            ProfileId = adminProfile.Id,
            TimeZoneSidKey = 'America/Chicago',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            CurrencyIsoCode = 'USD',
            UserRoleId = r.Id);
        lstTestUser.add(testUser);
        insert lstTestUser;
        
        system.runAs(lstTestUser[0]) {
            // Create internal account
            Account acc = new Account(Name = 'FastChem Cooperation', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId());
            insert acc;
            
            FCM_VisitReport__c vist = new FCM_VisitReport__c();
            vist.FCM_Account__c = acc.Id;
            vist.FCM_Status__c = 'Planned';
            vist.FCM_VisitDate__c = Date.today();
            vist.Confidential__c = false;
            insert vist;
            
            vist.Confidential__c = true;
            
            test.startTest();
            update vist;          
            test.stopTest();
        }
        
    }
    
    static testmethod void testError(){
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;
        
        // Create Users
        List<User> lstTestUser = new List<User>();
        Profile adminProfile = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator'];
        User testUser = new User(
            LastName = adminProfile.Name,
            FirstName = 'Test1',
            Email = adminProfile.Name.remove(' ') + '.' + 'Test1@fastchem.com.dev.test',
            Username = adminProfile.Name.remove(' ') + '.' + 'Test1@fastchem.com.dev.test',
            Alias = 'testusr1',
            CommunityNickname = 'test1' + adminProfile.Name.right(7),
            ProfileId = adminProfile.Id,
            TimeZoneSidKey = 'America/Chicago',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            CurrencyIsoCode = 'USD',
            UserRoleId = r.Id);
        lstTestUser.add(testUser);
        insert lstTestUser;
        
        system.runAs(lstTestUser[0]) {
            
            // Create internal account
            Account acc = new Account(Name = 'FastChem Cooperation', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId());
            insert acc;
            
            FCM_VisitReport__c vist = new FCM_VisitReport__c();
            vist.FCM_Account__c = acc.Id;
            vist.FCM_Status__c = 'Planned';
            vist.FCM_VisitDate__c = Date.today();
            vist.Confidential__c = false;
            insert vist;
            
            vist.Confidential__c = true;
            
            
            test.startTest();
            try{
                update vist;
            }
            catch(Exception e){}
            test.stopTest();
        }
    }*/
    
    testMethod static void testApexSharing() {
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;
        
        // Create Users
        List<User> lstTestUser = new List<User>();
        Profile adminProfile = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator'];
        User testUser = new User(
            LastName = adminProfile.Name,
            FirstName = 'Test1',
            Email = adminProfile.Name.remove(' ') + '.' + 'Test1@fastchem.com.dev.test',
            Username = adminProfile.Name.remove(' ') + '.' + 'Test1@fastchem.com.dev.test',
            Alias = 'testusr1',
            CommunityNickname = 'test1' + adminProfile.Name.right(7),
            ProfileId = adminProfile.Id,
            TimeZoneSidKey = 'America/Chicago',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            CurrencyIsoCode = 'USD',
            UserRoleId = r.Id);
        lstTestUser.add(testUser);
        
        testUser = new User(
            LastName = adminProfile.Name,
            FirstName = 'Test2',
            Email = adminProfile.Name.remove(' ') + '.' + 'Test2@fastchem.com.dev.test',
            Username = adminProfile.Name.remove(' ') + '.' + 'Test2@fastchem.com.dev.test',
            Alias = 'testusr2',
            CommunityNickname = 'test2' + adminProfile.Name.right(7),
            ProfileId = adminProfile.Id,
            TimeZoneSidKey = 'America/Chicago',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            CurrencyIsoCode = 'USD',
            UserRoleId = r.Id);
        lstTestUser.add(testUser);
        insert lstTestUser;
        
        system.runAs(lstTestUser[0]) {
            // Create internal account
            Account acc = new Account(Name = 'FastChem Cooperation', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Olin Corp').getRecordTypeId());
            insert acc;
            
            AccountName__c acctName = new AccountName__c();
            acctName.Name = 'FastChem Corp';
            acctName.OlinAccountValue__c = acc.id;
            insert acctName;
            
            // Create Account
            Account soldToAccount = new Account(
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
                Name = 'Sold To Account',
                AccountNumber_R1__c = '267687',
                Ship_To__c = true,
                Sold_To__c = true
            );
            insert soldToAccount;
            
            Account soldToAccount2 = new Account(
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
                Name = 'Second Sold To Account',
                AccountNumber_R1__c = '267687',
                Ship_To__c = true,
                Sold_To__c = true
            );
            insert soldToAccount2;
            
            List<Account> lstShipToAccount = new List<Account>();
            Account shipToAccount = new Account(
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
                Name = 'Ship To Account',
                AccountNumber_R1__c = '267687',
                Ship_To__c = true,
                ParentId = soldToAccount.Id
            );
            lstShipToAccount.add(shipToAccount);
            
            shipToAccount = new Account(
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
                Name = 'Test Ship To Account 2',
                AccountNumber_R1__c = '267688',
                Ship_To__c = true,
                ParentId = soldToAccount.Id
            );
            lstShipToAccount.add(shipToAccount);
            insert lstShipToAccount;
            
            // Create Account Relationship
            List<Account_Relationships__c> lstTestAccountRelationship = new List<Account_Relationships__c>();
            Account_Relationships__c testAccountRel = new Account_Relationships__c(
                Name = 'Test Account Relationship',
                Sold_To__c = soldToAccount.Id,
                Ship_To__c = lstShipToAccount[0].Id
            );
            lstTestAccountRelationship.add(testAccountRel);
            
            testAccountRel = new Account_Relationships__c(
                Name = 'Test Account Relationship 2',
                Sold_To__c = soldToAccount2.Id,
                Ship_To__c = lstShipToAccount[1].Id
            );
            lstTestAccountRelationship.add(testAccountRel);
            insert lstTestAccountRelationship;
            
            // Create Account Team Members
            List<AccountTeamMember> lstTestAccountTeamMember = new List<AccountTeamMember>();
            AccountTeamMember teamMember = new AccountTeamMember(
                AccountId = soldToAccount.Id,
                UserId = lstTestUser[0].Id
            );
            lstTestAccountTeamMember.add(teamMember);
            
            teamMember = new AccountTeamMember(
                AccountId = soldToAccount.Id,
                UserId = lstTestUser[1].Id
            );
            lstTestAccountTeamMember.add(teamMember);
            insert lstTestAccountTeamMember;
            
            // Create Call Report
            FCM_VisitReport__c callReport = new FCM_VisitReport__c(
                FCM_Account__c = soldToAccount.Id
            );
            insert callReport;
            
            Test.startTest();
            callReport.FCM_Account__c = soldToAccount2.Id;
            update callReport;
            Test.stopTest();
        }
    }
}