@isTest
public class CallReportList_Test {
    static testMethod void Test1(){
        list<Account>  accList = new list<Account>();
        Account acc = new Account( Name = 'test',CurrencyIsoCode = 'USD',AccountNumber_R1__c = '12345',AccountSource = 'Blue Cube',type='Customer',
                                 MostRecentCallReport_R1__c = date.today().addDays(-7),Interval_Days__c =2 );
        accList.add(acc);
        Insert accList;
        Contact con = new Contact( LastName = 'testAcc', AccountID = acc.id);
        insert con;
        
        CallReportList.myCallReportList(  'overdue' );
        CallReportList.myTeamCallReportList( 'null' );
        
    }
     
    static testMethod void TestforUpcoming(){
        list<Account>  accList = new list<Account>();
        Account accOve = new Account( Name = 'test',CurrencyIsoCode = 'USD',AccountNumber_R1__c = '12345',AccountSource = 'Blue Cube',type='Customer',
                                 MostRecentCallReport_R1__c = date.today().addDays(-7),Interval_Days__c = 10 );
        accList.add(accOve);
        Insert accList;
        Contact con = new Contact( LastName = 'testAcc', AccountID = accOve.id);
        insert con;
        
        CallReportList.myCallReportList(  'upcoming' );
        CallReportList.myTeamCallReportList( 'null' );
    }
     static testMethod void TestforNoAction(){
        list<Account>  accList = new list<Account>();
        Account accAct = new Account( Name = 'test',CurrencyIsoCode = 'USD',AccountNumber_R1__c = '12346',AccountSource = 'Blue Cube',type='Customer',
                                 MostRecentCallReport_R1__c = date.today().adddays(5) );
         insert accAct;
        accList.add(accAct);
       
         system.debug( accAct.DaysSinceLastCallReport_R1__c );  
         System.debug('accList'+ accList);
        Contact con = new Contact( LastName = 'testAcc', AccountID = accAct.id);
        insert con;
        
        CallReportList.myCallReportList('noAction');
        CallReportList.myTeamCallReportList( 'null' );
    }
    static testMethod void Test1Forelse(){
        list<Account>  accList = new list<Account>();
        Account accEls = new Account( Name = 'test',CurrencyIsoCode = 'USD',AccountNumber_R1__c = '12345',AccountSource = 'Blue Cube',type='Customer',
                                 MostRecentCallReport_R1__c = date.today().addDays(-7),Interval_Days__c =2 );
        accList.add(accEls);
        Insert accList;
        Contact con = new Contact( LastName = 'testAcc', AccountID = accEls.id);
        insert con;
        
        CallReportList.myCallReportList(  '' );
        CallReportList.myTeamCallReportList( '' );
        
    }
}