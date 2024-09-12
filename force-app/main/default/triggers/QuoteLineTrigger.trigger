trigger QuoteLineTrigger on SBQQ__QuoteLine__c (before delete, after insert, after update, before update) {
    //SBQQ.TriggerControl.disable();
    if(Trigger.isAfter) {
        if(Trigger.isInsert && QuoteLineTrigger_Handler.runOnceAfterInsert()) {
            // QuoteLineTrigger_Handler.processSharing(Trigger.newMap, Trigger.oldMap);
            QuoteLineTrigger_Handler.calculateGMIDPriorPrice(Trigger.new);
            //QuoteLineTrigger_Handler.submitForApproval(Trigger.new, null);
            QuoteLineTrigger_Handler.onCloneQuoteLineInsert(Trigger.new);
        }
        
        else if(Trigger.isUpdate && QuoteLineTrigger_Handler.runOnceAfterUpdate()) {
            SBQQ.TriggerControl.disable();
            System.debug('in after update');
           //QuoteLineTrigger_Handler.onQuoteLineShipDetailsChange(Trigger.new, Trigger.oldMap);
            QuoteLineTrigger_Handler.onQuoteLineSave(Trigger.newMap, Trigger.oldMap);
            QuoteLineTrigger_Handler.onQuoteLineApproval(Trigger.new, Trigger.oldMap); //to test //did not trigger calculation
            // QuoteLineTrigger_Handler.processSharing(Trigger.newMap, Trigger.oldMap);
            //QuoteLineTrigger_Handler.copyDatesValues(Trigger.new, Trigger.newMap, Trigger.oldMap);
            
            //QuoteLineTrigger_Handler.submitForApproval(Trigger.new, Trigger.oldMap); //to test
           QuoteLineTrigger_Handler.onQuoteLineWon(Trigger.new, Trigger.oldMap); //to test //did not trigger calculation
            QuoteLineTrigger_Handler.onQuoteLineStatusChange(Trigger.new, Trigger.oldMap);
            QuoteLineTrigger_Handler.validateNewPrice(Trigger.newMap, Trigger.oldMap);
            //QuoteLineTrigger_Handler.onParentQuoteLineSentToSAP(Trigger.new, Trigger.oldMap);
           //QuoteLineTrigger_Handler.updateQuoteLineRecType(Trigger.new, Trigger.oldMap);
        }
    }

    if(Trigger.isBefore) {
        if((Trigger.isInsert && QuoteLineTrigger_Handler.runOnceBeforeInsert()) || 
        	(Trigger.isUpdate && QuoteLineTrigger_Handler.runOnceBeforeUpdate())) {
            SBQQ.TriggerControl.disable();
            QuoteLineTrigger_Handler.copyFieldValues(Trigger.new); //to test //did not trigger calculation
            QuoteLineTrigger_Handler.populateFieldsFromParentQL(Trigger.new);
            QuoteLineTrigger_Handler.populateCustomerProductCode(Trigger.new); //to test //did not trigger calculation
            QuoteLineTrigger_Handler.populateStatus(Trigger.new, Trigger.oldMap); //to test //did not trigger calculation
            QuoteLineTrigger_Handler.populatePriceDates(Trigger.newMap, Trigger.oldMap); 
            QuoteLineTrigger_Handler.consolidateApproval(Trigger.new, Trigger.newMap, Trigger.oldMap); //to test //trigger calculation
            QuoteLineTrigger_Handler.onRejectRecall(Trigger.new, Trigger.oldMap);
        }

        if(Trigger.isDelete && QuoteLineTrigger_Handler.runOnceBeforeDelete()) {
            QuoteLineTrigger_Handler.beforeQuoteLinesDelete(Trigger.oldMap);
        }
    
        /*if(Trigger.isDelete) {
            if (QuoteLineTrigger_Handler.runOnceBefore()){
                QuoteLineTrigger_Handler.processSharing(new Map<Id, SBQQ__QuoteLine__c>(), Trigger.oldMap);
            }
        }*/
    }
}