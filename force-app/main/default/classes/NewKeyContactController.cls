public class NewKeyContactController {
    @AuraEnabled
    public static String saveRecords(String kcname,String pId,String keyconid,String comment){
        Key_Contact__c kc = new Key_Contact__c();
        kc.Name = kcname;
        kc.Account_Plan__c = pId;
        kc.Key_Contact__c = keyconid;
        kc.Comments__c = comment;
        insert kc;
        return kc.Id;
    }
}