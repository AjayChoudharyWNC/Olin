public class AccountPlanPDFController {
    //public Account parentAcc {get; set;}
    public Account_Plan__c accPlan {get; set;}
    public List<Account_Plan_Team__c> accPlanTeamList {get; set;}
    public List<Account> soldtoAccList {get; set;}
    public List<Account> soldtoAccList1 {get; set;}
    public List<Account> soldtoAccList2 {get; set;}
    public List<Key_Contact__c> accPlanKeyConList {get; set;}
    public List<Contact_Relationship__c> accPlanConRelationList {get; set;}
    public List<Meeting_Agenda__c> accPlanObjectiveList {get; set;}
    public String currentRecordId {get;set;}
    public String accPlanCreDate {get;set;}   
    public String pdfFileName {get;set;}
    
    public Boolean logo{get;set;}
    public Boolean sta{get;set;}
    public Boolean exes{get;set;}
    public Boolean apro{get;set;}
    public Boolean asg{get;set;}
    public Boolean ets{get;set;}
    public Boolean cps{get;set;}
    public Boolean cbs{get;set;}
    public Boolean cana{get;set;}
    public Boolean swot{get;set;}
    public Boolean apt{get;set;}
    public Boolean kc{get;set;}
    public Boolean cr{get;set;}
    public Boolean mp{get;set;}
    public Boolean isNormal{get;set;}
    
    public AccountPlanPDFController(ApexPages.StandardController controller)
    {
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
        String sections = ApexPages.CurrentPage().getparameters().get('sec');
        isNormal = true;
        if(String.isNotBlank(sections)){
            isNormal = false;
            logo = sections.substring(0,1) == 't' ? true: false;
            sta = sections.substring(1,2) == 't' ? true: false;
            exes = sections.substring(2,3) == 't' ? true: false;
            apro = sections.substring(3,4) == 't' ? true: false;
            asg = sections.substring(4,5) == 't' ? true: false;
            ets = sections.substring(5,6) == 't' ? true: false;
            cps = sections.substring(6,7) == 't' ? true: false;
            cbs = sections.substring(7,8) == 't' ? true: false;
            cana = sections.substring(8,9) == 't' ? true: false;
            swot = sections.substring(9,10) == 't' ? true: false;
            apt = sections.substring(10,11) == 't' ? true: false;
            kc = sections.substring(11,12) == 't' ? true: false;
            cr = sections.substring(12,13) == 't' ? true: false;
            mp = sections.substring(13) == 't' ? true: false;
        }
        Set<Id> soldToAccIdSet = new Set<Id>();
        for( Account_Plan__c accP : [SELECT Id, Name, Status__c, Planning_Year__c, Logo__c, Owner.Name, CreatedDate, Executive_Summary__c, Account_Profile__c, Account_Strategies_Goals__c, Marketing_Initiatives__c, Customer_Purchasing_Strategy__c,Customer_Business_Strategy__c,Consumption_Analysis_Market_View__c, Consumption_Analysis_Product_View__c, Strengths__c, Weaknesses__c, Opportunities__c, Threats__c, Account__r.Name, Account__r.BillingStreet, Account__r.BillingCity, Account__r.BillingState, Account__r.BillingPostalCode, Account__r.BillingCountry, Account__r.Sic, Account__r.TickerSymbol, Account__r.AccountNumber_R1__c, Account__r.MarketSegmentParent_R1__c, Account__c , (SELECT Id, Name, Account__c, Account_Plan__c FROM Account_Plan_Relationship__r) FROM Account_Plan__c WHERE Id = : currentRecordId])
        {
            accPlan = accP;
            List<Account_Sold_To__c> accSToList;
            try
            {
                accSToList = accP.Account_Plan_Relationship__r;
            }
            catch( QueryException e )
            {
                accSToList = new List<Account_Sold_To__c>();
                for( Account_Sold_To__c aST : accP.Account_Plan_Relationship__r )
                {
                    accSToList.add( aST );
                }
            }
            if(accSToList != null && accSToList.size() > 0)
            {
                for(Account_Sold_To__c accST : accSToList)
                {
                    soldToAccIdSet.add(accST.Account__c);
                }
            }
        }
        
       // accPlan = [SELECT Id, Name, Status__c, Planning_Year__c, Logo__c, Owner.Name, CreatedDate, Executive_Summary__c, Account_Profile__c, Account_Strategies_Goals__c, Marketing_Initiatives__c, Customer_Purchasing_Strategy__c,Customer_Business_Strategy__c,Consumption_Analysis_Market_View__c, Consumption_Analysis_Product_View__c, Strengths__c, Weaknesses__c, Opportunities__c, Threats__c, Account__r.Name, Account__r.BillingStreet, Account__r.BillingCity, Account__r.BillingState, Account__r.BillingPostalCode, Account__r.BillingCountry, Account__r.Sic, Account__r.TickerSymbol, Account__r.AccountNumber_R1__c, Account__r.MarketSegmentParent_R1__c, Account__c , (SELECT Id, Name, Account__c, Account_Plan__c FROM Account_Plan_Relationship__r) FROM Account_Plan__c WHERE Id = : currentRecordId];
        System.debug('accPlan pid @@ '+accPlan.Account__c);
        accPlanCreDate = String.valueOf(accPlan.CreatedDate.formatGMT('MMM dd, yyyy'));
        String pdfFName = accPlan.Name+'_'+accPlan.Status__c+'_'+String.valueOf(accPlan.CreatedDate.formatGMT('MMM dd yyyy HH:mm:ss'));
        pdfFName = pdfFName.replace(' ', '_');
        pdfFName = pdfFName.replace(':', '');
        pdfFName = pdfFName.replace('-', '');
        pdfFName = pdfFName.replace('|', '');
        pdfFName = pdfFName.replace('/', '');
        pdfFileName = pdfFName;
        Apexpages.currentPage().getHeaders().put( 'content-disposition', 'inline; filename=' +pdfFName+'.pdf' );
        //Apexpages.currentPage().getHeaders().put('content-disposition', 'attachment; filename='+pdfFName+'.pdf');
        accPlanTeamList = [SELECT Team_Member__c, Title__c, Account_Plan_Member_Role__c, Email__c, Phone__c, Comments__c  FROM Account_Plan_Team__c WHERE Account_Plan__c =: currentRecordId];
        accPlanKeyConList = [SELECT Key_Contact__r.FirstName, Key_Contact__r.LastName, Title__c, Key_Contact__r.MailingCity, 
                             Key_Contact__r.MailingState, Key_Contact__r.MailingCountry, Key_Contact__r.Email, Key_Contact__r.Phone, Comments__c 
                             FROM Key_Contact__c 
                             WHERE Account_Plan__c =: currentRecordId];
        accPlanObjectiveList = [SELECT Id,Name, Account_Plan__c, CurrencyIsoCode, Meeting_Date__c, Meeting_Location__c, Meeting_Report__c ,Type__c,Topics_to_Discuss__c,
                                Topics_to_Avoid__c,Meeting_Attendees__c,Sales_Data__c
                                FROM Meeting_Agenda__c 
                                WHERE Account_Plan__c =: currentRecordId];
        accPlanConRelationList = [SELECT Id, Contact__r.Name, Contact_Title__c, Olin_Representative__r.Name, Oline_Representative_Title__c, Relationship__c  FROM Contact_Relationship__c WHERE Account_Plan__c =: currentRecordId];
        
        /*if(accPlan.Account_Plan_Relationship__r != null && accPlan.Account_Plan_Relationship__r.size() > 0)
        {
            for(Account_Sold_To__c accST : accPlan.Account_Plan_Relationship__r)
            {
                soldToAccIdSet.add(accST.Account__c);
            }
        }*/
        //Account pAcc = [SELECT Id, Name From Account WHERE Id =: accPlan.Account__c];
        //soldtoAccList = [SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, AccountNumber_R1__c, ParentAccount_R1__c FROM Account WHERE ParentAccount_R1__c =: pAcc.Name ORDER BY Name ASC];
        soldtoAccList1 = new List<Account>();
        soldtoAccList2 = new List<Account>();
        if(soldToAccIdSet.size() > 0)
        {
            soldtoAccList = [SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, AccountNumber_R1__c, ParentAccount_R1__c FROM Account WHERE Id IN: soldToAccIdSet ORDER BY Name ASC];
            Integer count = 0;
            if(soldtoAccList != null && soldtoAccList.Size() > 0)
            {
                for(Account  sacc : soldtoAccList)
                {
                    Integer mode = math.mod(count,2);
                    if(mode == 0)
                    {
                        soldtoAccList1.add(sacc);
                        count++;
                    }
                    else
                    {
                        soldtoAccList2.add(sacc);
                        count++;
                    }
                }
            }
        } 
    }
}