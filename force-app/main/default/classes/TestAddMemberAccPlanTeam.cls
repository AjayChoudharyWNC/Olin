@isTest
public class TestAddMemberAccPlanTeam {
    public static testMethod void Method(){
        Account acc= new Account();
        acc.Name='test';
        acc.AccountNumber_R1__c='value';
        acc.AccountSource='Blue Cube';
        acc.CurrencyIsoCode='USD';
        acc.type='Customer';
        insert acc;
        User u = [Select id, name, email from User where name = 'Jonathan Major'];
        
        Account soldToAcc= new Account();
        soldToAcc.Name='test';
        soldToAcc.AccountNumber_R1__c='value';
        soldToAcc.AccountSource='Blue Cube';
        soldToAcc.CurrencyIsoCode='USD';
        soldToAcc.type='Customer';
        soldToAcc.CustomerSubtype_R1__c='Standard';
        soldToAcc.ParentId = acc.Id;
        insert soldToAcc;
        List<String> soldToAccList = new List<String>();
        soldToAccList.add(soldToAcc.Id);
        
        Account_Plan__c accPlan= new Account_Plan__c();
        accPlan.Account__c=acc.Id;
        accPlan.Name='test1';
        accPlan.Planning_Year__c='2019';
        accPlan.Status__c='In Progress';
        insert accPlan;
        
        Account_Plan__c accPlan1= new Account_Plan__c();
        accPlan1.Account__c=acc.Id;
        accPlan1.Name='test1';
        accPlan1.Planning_Year__c='2019';
        accPlan1.Status__c='In Progress';
        insert accPlan1;
        
        User u1 = [Select id, name, email from User where name = 'Jorge Carrero'];
        Account_Plan_Team__c accPlanTeam = new Account_Plan_Team__c();
        accPlanTeam.Account_Plan_Member__c = u1.Id;
        accPlanTeam.Account_Plan__c = accPlan.Id;
        accPlanTeam.Account_Plan_Access__c = 'Read Only';
        insert accPlanTeam;
        
        User u2 = [Select id, name, email from User where name = 'John Schabacker'];
        Account_Plan_Team__c accPlanTeam1 = new Account_Plan_Team__c();
        accPlanTeam1.Account_Plan_Member__c = u2.Id;
        accPlanTeam1.Account_Plan__c = accPlan1.Id;
        accPlanTeam1.Account_Plan_Access__c = 'Read Only';
        insert accPlanTeam1;
        User u3 = [Select id, name, email from User where name = 'Journey Zhu'];
        
        Test.startTest();
        Team__c team = new Team__c(
            Account__c=acc.Id,
            Team_Member__c=u.id,
            Team_Role__c='R&D',
            Account_Access__c='	Read Only',
            Opportunity_Access__c='Private',
            Case_Access__c='Private'
        );
        //insert team;
        Team__c team1 = new Team__c(
            Account__c=soldToAcc.Id,
            Team_Member__c=u3.id,
            Team_Role__c='R&D',
            Account_Access__c='	Read Only',
            Opportunity_Access__c='Private',
            Case_Access__c='Private'
        );
        //insert team1;
        Test.stopTest();
    }
    
    public static testMethod void Method1(){
        Account acc= new Account();
        acc.Name='test';
        acc.AccountNumber_R1__c='value';
        acc.AccountSource='Blue Cube';
        acc.CurrencyIsoCode='USD';
        acc.type='Customer';
        insert acc;
        User u = [Select id, name, email from User where name = 'Jonathan Major'];
        Team__c team0 = new Team__c(
            Account__c=acc.Id,
            Team_Member__c=u.id,
            Team_Role__c='R&D',
            Account_Access__c='	Read Only',
            Opportunity_Access__c='Private',
            Case_Access__c='Private'
        );
        //insert team0;
        
        Account soldToAcc= new Account();
        soldToAcc.Name='test';
        soldToAcc.AccountNumber_R1__c='value';
        soldToAcc.AccountSource='Blue Cube';
        soldToAcc.CurrencyIsoCode='USD';
        soldToAcc.type='Customer';
        soldToAcc.CustomerSubtype_R1__c='Standard';
        soldToAcc.ParentId = acc.Id;
        insert soldToAcc;
        List<String> soldToAccList = new List<String>();
        soldToAccList.add(soldToAcc.Id);
        
        Account_Plan__c accPlan= new Account_Plan__c();
        accPlan.Account__c=acc.Id;
        accPlan.Name='test1';
        accPlan.Planning_Year__c='2019';
        accPlan.Status__c='In Progress';
        insert accPlan;
        
        Account_Plan__c accPlan1= new Account_Plan__c();
        accPlan1.Account__c=acc.Id;
        accPlan1.Name='test1';
        accPlan1.Planning_Year__c='2019';
        accPlan1.Status__c='In Progress';
        insert accPlan1;
        
        User u1 = [Select id, name, email from User where name = 'Jorge Carrero'];
        Account_Plan_Team__c accPlanTeam = new Account_Plan_Team__c();
        accPlanTeam.Account_Plan_Member__c = u1.Id;
        accPlanTeam.Account_Plan__c = accPlan.Id;
        accPlanTeam.Account_Plan_Access__c = 'Read Only';
        insert accPlanTeam;
        
        User u2 = [Select id, name, email from User where name = 'John Schabacker'];
        Account_Plan_Team__c accPlanTeam1 = new Account_Plan_Team__c();
        accPlanTeam1.Account_Plan_Member__c = u2.Id;
        accPlanTeam1.Account_Plan__c = accPlan1.Id;
        accPlanTeam1.Account_Plan_Access__c = 'Read Only';
        insert accPlanTeam1;
        User u3 = [Select id, name, email from User where name = 'Journey Zhu'];
        
        Test.startTest();
        Team__c team = new Team__c(
            Account__c=acc.Id,
            Team_Member__c=u.id,
            Team_Role__c='R&D',
            Account_Access__c='	Read Only',
            Opportunity_Access__c='Private',
            Case_Access__c='Private'
        );
        //insert team;
        Team__c team1 = new Team__c(
            Account__c=soldToAcc.Id,
            Team_Member__c=u3.id,
            Team_Role__c='R&D',
            Account_Access__c='	Read Only',
            Opportunity_Access__c='Private',
            Case_Access__c='Private'
        );
        insert team1;
        Test.stopTest();
    }
    
}