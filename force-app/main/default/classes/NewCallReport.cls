public class NewCallReport {
    public FCM_VisitReport__c callReport{get;set;}
    public string url{get;set;}
    
    public NewCallReport(ApexPages.StandardController controller){
        callReport = new FCM_VisitReport__c();
        //url = ApexPages.currentPage().getUrl();
        callReport.FCM_Account__c = ApexPages.currentPage().getParameters().get('CF00Nf400000Aiqkl_lkid');
    }
    
    public PageReference save(){
        return null;
    }
    
    public PageReference cancel(){
        return null;
    }
}