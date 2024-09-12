global class AccountTeamAccessShareBatch implements Database.Batchable<sObject> {
    global final String query;
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String customerRecordType = 'Customer';
        String prospectRecordType = 'Prospect';
        String query = 'SELECT Id, RecordTypeId, RecordType.Name FROM Account WHERE RecordType.Name =: customerRecordType OR RecordType.Name =: prospectRecordType';
        system.debug('QUERY -- ' + Database.getQueryLocator(query));
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope) {
        system.debug('EXECUTE -- ' + scope);
        system.debug('EXECUTE Job ID -- ' + BC.getJobId());
        List<String> lstAccount = new List<String>();
        for(Account accounts : scope) {
            lstAccount.add(accounts.Id);
        }
        AccountTeamAccessShare.BatchShareAccess(lstAccount, BC.getJobId());
    }
    
    global void finish(Database.BatchableContext BC) {
    }
}