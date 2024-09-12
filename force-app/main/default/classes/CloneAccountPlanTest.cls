/* * * * * * * * * * * * * * * * * * * *
 Author : Ajay Choudhary
 Date   : 05/06/2019
 Desc   : Test Class for CloneAccountPlan.apxc

* * * * * * * * * * * * * * * * * * * */ 
@isTest
public class CloneAccountPlanTest {
    
    static testMethod void test1(){
        Account_Plan__c ac = insertTestData();
        ApexPages.StandardController controller = new ApexPages.StandardController(ac);
        CloneAccountPlan ca = new CloneAccountPlan(controller);
        PageReference pageRef = Page.CloneAccountPlanVF;
        test.setCurrentPage(pageRef);
        ca.cloneAccountPlan();
     //   CloneAccountPlan.cloneRecord(new Set<Id>{planId});
    }
    
    static testMethod Account_Plan__c insertTestData(){
        Account acc = new Account();
        acc.Name = 'test';
        acc.AccountNumber_R1__c = '123456';
        acc.AccountSource = 'Blue Cube';
        insert acc;
        
        Contact con = new Contact(LastName = 'test');
        insert con;
        
        Account_Plan__c accPlan = new Account_Plan__C();
        accPlan.Account__c = acc.Id;
        accPlan.Name = 'test account plan';
        accPlan.Planning_Year__c = '2019';
        accPlan.Status__c = 'In Progress';
        insert accPlan;
        
        Account_Plan_Team__c accTeam = new Account_Plan_Team__c();
        accTeam.Account_Plan__c = accPlan.Id;
        accTeam.Account_Plan_Member__c = UserInfo.getUserId();
        accTeam.Account_Plan_Member_Role__c = 'Account Manager';
        insert accTeam;
        
        Account_Sold_To__c accSoldTo = new Account_Sold_To__C();
        accSoldTo.Account_Plan__c = accPlan.Id;
        accSoldTo.Account__c = acc.Id;
        insert accSoldTo;
        
        Key_Contact__c keyCon = new Key_Contact__c();
        keyCon.Account_Plan__c = accPlan.Id;
        keyCon.Name = 'test Key con';
        keyCon.Key_Contact__c = con.Id;
        insert keyCon;
        
        Contact_Relationship__c conRel = new Contact_Relationship__c();
        conRel.Account_Plan__c = accPlan.Id;
        conRel.Contact__c = keyCon.Id;
        conRel.Olin_Representative__c = UserInfo.getUserId();
        insert conRel;
        
        return accPlan;
    }
    
}