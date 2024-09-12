trigger QuoteTrigger on SBQQ__Quote__c (before insert, before update, after insert, after update) {
    //SBQQ.TriggerControl.disable();
    if(Trigger.isAfter) {
        if (QuoteTrigger_Handler.executeAfter()) {
            
        }
        if(Trigger.isInsert) {
            QuoteTrigger_Handler.processSharing(Trigger.new);
        }
        else if(Trigger.isUpdate) {
            // QuoteTrigger_Handler.sendQuoteForApproval(Trigger.new, Trigger.oldMap);
            //QuoteTrigger_Handler.onQuotePending(Trigger.new, Trigger.oldMap);//test - commented out // move to before update
            QuoteTrigger_Handler.onQuoteApproval(Trigger.new, Trigger.oldMap);
            QuoteTrigger_Handler.onQuoteRejectRecall(Trigger.new, Trigger.oldMap);
            //QuoteTrigger_Handler.sendEmailVersionOne(Trigger.new, Trigger.oldMap);
        }
    }
    
    if(Trigger.isBefore){
        List < SBQQ__Quote__c > quoteList = Trigger.new;
        if(Trigger.isInsert){
            QuoteTrigger_Handler.setDefaultFields(Trigger.new);
            QuoteTrigger_Handler.renewalPriceRequest(quoteList);
            QuoteTrigger_Handler.updateShipToValues(quoteList);
            QuoteTrigger_Handler.updateDefaultTemplate(quoteList);
        }
        if(Trigger.isUpdate){
            Map <Id, SBQQ__Quote__c> quoteMap = new Map <Id, SBQQ__Quote__c>();
            for(SBQQ__Quote__c quote : quoteList){
                if(quote.Show_Quote_Line_Level_Detail__c){
                    quoteMap.put(quote.Id, quote);
                }
                else {
                    quote.Product_Name__c = NULL;
                    quote.GMID_List_Price__c = NULL;
                    quote.GMID_Net_Price__c = NULL;
                    quote.GMID_UOM__c = NULL;
                    quote.GMID_Ship_To__c = NULL;
                    quote.GMID_Ship_From__c = NULL;
                    quote.GMID_Shipping_Condition__c = NULL;
                    quote.GMID_Incoterm__c = NULL;
                    quote.GMID_Formula__c = NULL;
                    quote.GMID_Converted_Net_Back__c = NULL;
                    quote.GMID_Converted_Plant_Net__c = NULL;
                }
            }  
            if(quoteMap != null || !quoteMap.isEmpty() || quoteMap.keySet() != null){
                List <SBQQ__QuoteLine__c> quoteLineItems = [SELECT Id,  SBQQ__ProductName__c, SBQQ__Quote__c, SBQQ__ListPrice__c, SBQQ__NetPrice__c, UOM__c, Ship_To_Account__c, Ship_From_Plant_List__c, Shipping_Condition__c, Incoterm__c, Formula__c,
                                                            Convtd_Netback__c,Convtd_PlantNet__c, Freight_Component_with_Multiplier_Conver__c
                                                            from SBQQ__QuoteLine__c 
                                                            WHERE SBQQ__Quote__c IN: quoteMap.keySet() AND Product_Level__c ='GMID'];
                
                for(SBQQ__QuoteLine__c quoteLineItem : quoteLineItems){
                    SBQQ__Quote__c quote = quoteMap.get(quoteLineItem.SBQQ__Quote__c);
                    quote.Product_Name__c = quoteLineItem.SBQQ__ProductName__c;
                    quote.GMID_List_Price__c = quoteLineItem.SBQQ__ListPrice__c;
                    quote.GMID_Net_Price__c = quoteLineItem.SBQQ__NetPrice__c;
                    quote.GMID_UOM__c = quoteLineItem.UOM__c;
                    quote.GMID_Ship_To__c = quoteLineItem.Ship_To_Account__c;
                    quote.GMID_Ship_From__c = quoteLineItem.Ship_From_Plant_List__c;
                    quote.GMID_Shipping_Condition__c = quoteLineItem.Shipping_Condition__c;
                    quote.GMID_Incoterm__c = quoteLineItem.Incoterm__c;
                    quote.GMID_Formula__c = quoteLineItem.Formula__c;    
                    quote.GMID_Converted_Net_Back__c = quoteLineItem.Convtd_Netback__c;
                    quote.GMID_Converted_Plant_Net__c = quoteLineItem.Convtd_PlantNet__c;
                    quote.GMID_Freight_Override__c = quoteLineItem.Freight_Component_with_Multiplier_Conver__c;
                }
                QuoteTrigger_Handler.updateShipToValues(quoteList); //test - commented out
                QuoteTrigger_Handler.updateDefaultTemplate(quoteList); //test - commented out
            }
            QuoteTrigger_Handler.onQuotePending(Trigger.new, Trigger.oldMap);//test - commented out // move to before update
        }
        
    }
}