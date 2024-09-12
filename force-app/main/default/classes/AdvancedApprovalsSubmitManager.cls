@RestResource(urlMapping='/approval/*')
global without sharing class AdvancedApprovalsSubmitManager {
    
    //https://olin--cpq.salesforce.com/services/apexrest/AdvancedApprovalsSubmitManager/approval/
    @HttpPost
    global static String doPost(String payload) {
        System.debug('payload: ' + payload);
        QuoteGroup qg = (QuoteGroup)JSON.deserialize(payload, AdvancedApprovalsSubmitManager.QuoteGroup.class);
        for(QuoteEntry entry: qg.quotes) {
            if (entry.isUpdate) {
                try {
                    SBAA.ApprovalAPI.recall(entry.id, SBAA__Approval__c.Quote__c);
                    SBAA.ApprovalAPI.submit(entry.id, SBAA__Approval__c.Quote__c);
                    entry.success = true;
                    entry.response = 'Recalled and Submitted';
                } catch (Exception ex) {
                    System.debug('Error: ' + ex.getMessage());
                    entry.success = false;
                    entry.error = ex.getMessage();
                }
            } else {
                try {
                    SBAA.ApprovalAPI.submit(entry.id, SBAA__Approval__c.Quote__c);
                    entry.success = true;
                    entry.response = 'Submitted';
                } catch (Exception ex) {
                    System.debug('Error: ' + ex.getMessage());
                    entry.success = false;
                    entry.error = ex.getMessage();
                }
            }
        }
        return JSON.serialize(qg);
    }

    public class QuoteGroup {
        public List<QuoteEntry> quotes;
    }

    public class QuoteEntry {
        public Id id;
        public String name;
        public String status;
        public String approvalStatus;
        public Boolean isUpdate;
        public Boolean success;
        public String response;
        public String error;
    }
}