public class MulesoftCalloutTriggerHandler {

    public static void handleAfterInsert(List<MulesoftCallout__c> newMulesoftCallouts){
		setSentToSAPCheckbox(newMulesoftCallouts);
    }
    
    private static void setSentToSAPCheckbox(List<MulesoftCallout__c> newMulesoftCallouts){
        Integration_Endpoint__mdt integrationMetadata = Integration_Endpoint__mdt.getInstance('Mulesoft_Pricing');
		Map<MulesoftCallout__c, List<String>> mulesoftCalloutToQuoteLineNames = new Map<MulesoftCallout__c, List<String>>();
        Set<String> allQuoteLineNames = new Set<String>();
        for(MulesoftCallout__c mc: newMulesoftCallouts){
            if(isMulesoftCalloutValidForSentToSAP(mc, integrationMetadata)){
                mulesoftCalloutToQuoteLineNames.put(mc, mc.QuoteLines__c.split(';'));
                allQuoteLineNames.addAll(mc.QuoteLines__c.split(';'));
            }
        }
        List<SBQQ__QuoteLine__c> quoteLinesToUpdate = new List<SBQQ__QuoteLine__c>();
        for(SBQQ__QuoteLine__c ql: [SELECT Id FROM SBQQ__QuoteLine__c WHERE SentToSAP__c = false AND Name IN: allQuoteLineNames]){
			ql.SentToSAP__c = true;
            quoteLinesToUpdate.add(ql);
        }
       // update quoteLinesToUpdate;
    }
    
    private static Boolean isMulesoftCalloutValidForSentToSAP(MulesoftCallout__c mc, Integration_Endpoint__mdt im){
        return mc.ResponseStatusCode__c == 200 && !String.isEmpty(mc.QuoteLines__c) && mc.Endpoint__c == im.Endpoint__c && mc.Method__c == im.Operation__c;
    }
    
    
    
}