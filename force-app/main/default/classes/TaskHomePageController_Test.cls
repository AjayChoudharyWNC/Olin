@isTest
public class TaskHomePageController_Test {
    static testMethod void taskHomeMethod(){
        Account a1= new Account(Name='Test',CurrencyIsoCode = 'USD',AccountNumber_R1__c='test123123',AccountSource='Blue Cube');
        insert a1;
        AccountName__c acctName = new AccountName__c();
        acctName.Name = 'FastChem Corp';
        acctName.OlinAccountValue__c = a1.id;
        insert acctName;
        Lead c1= new Lead(LastName='test1', Company ='Test');
        insert c1;
        Id AdminProfileID = [Select Id From profile Where Name = 'System Administrator' Limit 1].Id;
        User objUser = new User(
            email='test@gmail.com',
            profileid = AdminProfileID ,
            UserName='ad123min123test@gmail.com',
            alias='Admin',
            TimeZoneSidKey='America/New_York',
            LocaleSidKey='en_US',
            EmailEncodingKey='ISO-8859-1',
            LanguageLocaleKey='en_US',
            FirstName = 'testAdminFirstName',
            LastName = 'testAdminLastName',
            IsActive = true
        );
        insert objUser;
        
        Task t1 = new Task(WhoId =c1.Id,Subject='Call',Priority= 'High',Status='Open',OwnerId=objUser.Id);
        insert t1;
        Task t2 = new Task(WhoId =c1.Id,Subject='Call',Priority= 'High',Status='Open',ActivityDate =System.today() );
        insert t2;  
        Task t3 = new Task(WhoId =c1.Id,Subject='Call',Priority= 'High',Status='Open',ActivityDate =System.today().addMonths(1) );
        insert t3;
        Task t4 = new Task(WhoId =c1.Id,Subject='Call',Priority= 'High',Status='Open',ActivityDate =System.today().addMonths(2) );
        insert t4;
        
        test.startTest();
        TaskHomePageController.taskList('onLoad');
        TaskHomePageController.taskList('AllOverDue');
        TaskHomePageController.taskList('Todaystask');
        TaskHomePageController.taskList('ThisMonth');
        TaskHomePageController.taskList('Open');
        
        TaskHomePageController.updateTask(t1.Id, true);
        TaskHomePageController.updateTask(t1.Id, false);
        
        test.stopTest();
    }
}