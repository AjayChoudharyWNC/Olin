public class MeetingAgendaVFController {
    
    public List<Meeting_Agenda__c> accPlanIdList {get; set;}
    public String meetingAgendaDate {get; set;}
    public Account_Plan__c accPlan {get; set;}
    public String accPlanCreDate {get;set;}   
    public String currentRecordId {get; set;}
    public Meeting_Agenda__c meAgendaRecords {get;set;}
    public String pdfFileName {get;set;}
    public Id accPlanId;
    public List<Account> soldtoAccList {get; set;}
    public List<Account> soldtoAccList1 {get; set;}
    public List<Account> soldtoAccList2 {get; set;}
    
    public MeetingAgendaVFController(ApexPages.StandardController controller) {
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
        accPlanIdList = [SELECT Id,Name,Account_Plan__c, Account_Plan__r.Account__r.Id FROM Meeting_Agenda__c WHERE Id =: currentRecordId];
        accPlanId = accPlanIdList[0].Account_Plan__c;
        accPlan = [SELECT  Id, Name, Status__c, Planning_Year__c, Logo__c, Owner.Name, CreatedDate, Executive_Summary__c, Account_Strategies_Goals__c,
                   Account__r.Name, Account__r.BillingStreet, Account__r.BillingCity, Account__r.BillingState, Account__r.BillingPostalCode, Account__r.BillingCountry,
                   Account__r.Sic, Account__r.TickerSymbol, Account__r.AccountNumber_R1__c, Account__r.MarketSegmentParent_R1__c, Account__c  
                   FROM Account_Plan__c 
                   WHERE Id = : accPlanIdList[0].Account_Plan__c];
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
        meAgendaRecords=[Select Id, Name, Meeting_Date__c, Meeting_Report__c, Topics_to_Avoid__c, Topics_to_Discuss__c, Type__c, Meeting_Location__c, Meeting_Attendees__c, Sales_Data__c FROM Meeting_Agenda__c WHERE Id = : currentRecordId ];
        if(meAgendaRecords.Meeting_Date__c != null)
        {
            Datetime dt = (Datetime)meAgendaRecords.Meeting_Date__c;
            meetingAgendaDate = dt.format('dd/MM/yyyy');
        }
        Account pAcc = [SELECT Id, Name From Account WHERE Id =: accPlan.Account__c];
        soldtoAccList = [SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, AccountNumber_R1__c, ParentAccount_R1__c FROM Account WHERE ParentAccount_R1__c =: pAcc.Name ORDER BY Name ASC];
        Integer count = 0;
        soldtoAccList1 = new List<Account>();
        soldtoAccList2 = new List<Account>();
        if(soldtoAccList != null && soldtoAccList.Size() > 0)
        {
            for(Account sacc : soldtoAccList)
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
    
    public PageReference init(){
        System.debug('accPlanId@@@@11 '+accPlanId);
        return new PageReference('/' + accPlanId).setRedirect(true);
    }
}