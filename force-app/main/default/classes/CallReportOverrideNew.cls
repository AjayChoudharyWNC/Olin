public class CallReportOverrideNew {
	@AuraEnabled
    public static String getRecordType(String accId){
        return [SELECT RecordType.Name FROM Account WHERE Id =: accId LIMIT 1][0].RecordType.Name;
    }
}