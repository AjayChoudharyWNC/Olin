trigger ForecastTrigger on Forecast__c (after insert, after update, before insert, before update) {
    if(Label.Execute_Forecast_Trigger == 'Yes' || Test.isRunningTest()){
        if(Trigger.isAfter) {
            if(Trigger.isInsert) {
                if (ForecastTrigger_Handler.runOnceAfter()){
                    /* Modified Jimmy Daresta to change to forecast to master detail */
/*                    ForecastTrigger_Handler.processSharing(Trigger.new, Trigger.oldMap, true); */
                   /* ForecastTrigger_Handler.updateManagementFields(Trigger.NewMap.keyset()); */
                    
                }
            }
            
            if(Trigger.isUpdate) {
                if (ForecastTrigger_Handler.runOnceAfter()){
            /* Modified Jimmy Daresta to change to forecast to master detail */
/*                    ForecastTrigger_Handler.processSharing(Trigger.new, Trigger.oldMap, false); */
                    ForecastTrigger_Handler.updateManagementFields(Trigger.NewMap.keyset());
                }
            }
        }
    }
}