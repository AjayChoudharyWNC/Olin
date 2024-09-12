@isTest
public class TestOwnerChangeTrigger {
    public static testMethod void method(){
        Test.startTest();   
        // Create internal account
        Id BusinessAccRecTypeId = [SELECT id,Name,SObjectType FROM RecordType where SObjectType = 'Account' and Name = 'Corporate'].id;
        Account acc = new Account(Name = 'FastChem Cooperation', RecordTypeId = BusinessAccRecTypeId);
        insert acc;
        
        AccountName__c acctName = new AccountName__c();
        acctName.Name = 'FastChem Corp';
        acctName.OlinAccountValue__c = acc.id;
        insert acctName;
        
        Id testUsers  = [select Id from user where isactive = true AND Profile.Name like '%System Admin%' limit 1 ].Id;
        Id tesUsers2  = [select Id from user where isactive = true AND Profile.Name like '%System Admin%' limit 1 ].Id;
        
        Account_Plan__c accPlan= new Account_Plan__c();
        accPlan.Name='Test';
        accPlan.OwnerId= testUsers;
        insert accPlan;
        
        Account_Plan_Team__c accPlanTeam= new Account_Plan_Team__c();
        accPlanTeam.Account_Plan__c=accPlan.Id;
        accPlanTeam.Account_Plan_Owner__c=true;
        accPlanTeam.Account_Plan_Access__c='Read/Write';
        insert accPlanTeam;
        
        accPlan.OwnerId= tesUsers2;
        update accPlan;
        
        HelperOwnerChangeTrigger.ownerMethod(accPlan.Id);
        
        accPlanTeam.Account_Plan_Owner__c=false;
        accPlanTeam.Account_Plan_Access__c='Read Only';
        update accPlanTeam;
        
        HelperOwnerChangeTrigger.ownerMethod(accPlan.Id);
        
        Test.stopTest();
    }
}