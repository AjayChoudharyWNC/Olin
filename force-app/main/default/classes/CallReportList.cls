public class CallReportList {
	@AuraEnabled
    public static List<Account> myCallReportList(String type){
        String queryString = 'SELECT Id,Name,AccountNumber_R1__c,OwnerId,DaysSinceLastCallReport_R1__c,Last_Call_Report_Owner__c,Last_Call_Report_Owner__r.Name,Owner.Name,Interval_Days__c,Interval_Status__c,MostRecentCallReport_R1__c,BillingCity,BillingState,BillingCountry FROM Account ';
        String whereClause = 'WHERE OwnerId =\''+ UserInfo.getUserId()+'\' AND Interval_Days__c != null AND Interval_Status__c != \'No Action Required\' ';
        String extras = ' ORDER BY DaysSinceLastCallReport_R1__c DESC NULLS LAST LIMIT 50000';
        system.debug(queryString+whereClause+extras);
        List<Account> accList = Database.query(queryString+whereClause+extras);
        if(String.isNotBlank(type))
        	return findWhereClause(accList, type);
        else
            return accList;
    }
    
    private static List<Account> findWhereClause(List<Account> accList, String type){
        String whereClause = '';
        List<Account> returnList = new List<Account>();
        for(Account acc: accList){
            if(type == 'overdue' && acc.DaysSinceLastCallReport_R1__c > acc.Interval_Days__c)
                returnList.add(acc);
            else if(type == 'upcoming' && acc.DaysSinceLastCallReport_R1__c > 0 && acc.DaysSinceLastCallReport_R1__c < acc.Interval_Days__c)
                returnList.add(acc);
            else if(type == 'noAction' && acc.DaysSinceLastCallReport_R1__c == 0)
                returnList.add(acc);
        }
        return returnList;
    }
    
    @AuraEnabled
    public static List<Account> myTeamCallReportList(String type){
        String queryString = 'SELECT Id,Name,AccountNumber_R1__c,OwnerId,DaysSinceLastCallReport_R1__c,Last_Call_Report_Owner__c,Last_Call_Report_Owner__r.Name,Owner.Name,Interval_Days__c,Interval_Status__c,MostRecentCallReport_R1__c,BillingCity,BillingState,BillingCountry,(SELECT Id FROM Teams__r WHERE Team_Member__c =\''+ UserInfo.getUserId()+'\') FROM Account ';
        string whereClause = ' WHERE OwnerId !=\''+ UserInfo.getUserId()+'\' AND Interval_Days__c != null AND Interval_Status__c != \'No Action Required\' ';
        String extras = ' ORDER BY DaysSinceLastCallReport_R1__c DESC NULLS LAST LIMIT 50000';
        system.debug(queryString+whereClause+extras);
        List<Account> accList = Database.query(queryString+whereClause+extras);
        if(String.isNotBlank(type))
        	return findWhereClause(accList, type);
        else
            return accList;
    }
    @AuraEnabled
    public static void updCallReportList(List<Account> accList){
        system.debug('accList'+accList);
        update accList;
    }
}