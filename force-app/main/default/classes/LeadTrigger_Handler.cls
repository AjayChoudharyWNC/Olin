public class LeadTrigger_Handler {
    public static void insertCampaignHistory(List<Lead> leadList){
        List<CampaignMember> cmList = new List<CampaignMember>();
        for(Lead l: leadList){
            CampaignMember cm = new CampaignMember();
            cm.CampaignId = l.Campaign__c;
            cm.LeadId = l.Id;
            cmList.add(cm);
        }
        insert cmList;
    }
    public static void deleteCampaignHistory(List<Lead> leadList){
        Set<Id> leadIDs = new Set<Id>();
        Set<Id> campaignIDs = new Set<Id>();
        for(Lead l: leadList){
            leadIDs.add(l.Id);
            campaignIDs.add(l.Campaign__c);
        }
        delete [SELECT Id FROM CampaignMember WHERE CampaignId IN: campaignIDs AND LeadId IN: leadIDs LIMIT 50000];
    }
}