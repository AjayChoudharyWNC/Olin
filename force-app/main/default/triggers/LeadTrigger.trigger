trigger LeadTrigger on Lead (after insert, after update) {
    List<Lead> leadList = new List<Lead>();
    List<Lead> oldLeadList = new List<Lead>();
    if(Trigger.isInsert){
        for(Lead l: Trigger.new){
            if(l.Campaign__c != null){
                leadList.add(l);
            }
        }
    }
    if(Trigger.isUpdate){
        for(Lead l: Trigger.new){
            if(l.Campaign__c != null && l.Campaign__c != Trigger.oldMap.get(l.Id).Campaign__c){
                leadList.add(l);
                oldLeadList.add(Trigger.oldMap.get(l.Id));
            }
            if(l.Campaign__c == null && l.Campaign__c != Trigger.oldMap.get(l.Id).Campaign__c){
                oldLeadList.add(Trigger.oldMap.get(l.Id));
            }
        }
    }
    if(leadList.size() > 0){
        LeadTrigger_Handler.insertCampaignHistory(leadList);
    }
    if(oldLeadList.size() > 0){
        LeadTrigger_Handler.deleteCampaignHistory(oldLeadList);
    }
}