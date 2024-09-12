({
    saveSapRecord: function (component, sapRecord, creditType) {
        var sapType = component.get('v.sapType');
        var action = component.get('c.insertSapRecord');
        action.setParams({
            "sapRecord": sapRecord
        });
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                var sapId = response.getReturnValue();
                component.set('v.selectedSapId', sapId);
                component.set('v.creditType', creditType);
                component.set('v.showCreditQuestions', false);
                component.set('v.spinner', false);
            };
        });
        $A.enqueueAction(action);
    },
    
     fetchSapRecord: function (component) {
         component.set('v.spinner', true);
        var action = component.get('c.fetchSapRecord');
        action.setParams({
            sapId : component.get('v.selectedSapId')
        });
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                var sapRecord = response.getReturnValue();
                component.set('v.sapRecord', sapRecord);
                if(sapRecord.New_Business_Result_In_Exceeding_Credit__c == 'Unsure'){
                    component.set('v.showCreditQuestions', true);
                }
                var creditType = component.get('v.creditType');
                if(sapRecord.Customer_Purchased_Prod_In_Last_12_Month__c == "Yes"){
                    if(sapRecord.New_Business_Result_In_Exceeding_Credit__c == "Yes"){
                        creditType = 'Partial';
                    }
                    if(sapRecord.New_Business_Result_In_Exceeding_Credit__c == "No" || sapRecord.New_Business_Result_In_Exceeding_Credit__c == 'Unsure'){
                        creditType = "No Credit";
                        component.set('v.showCreditQuestions', true);
                    }
                }
                if(sapRecord.Customer_Purchased_Prod_In_Last_12_Month__c == "No"){
                    creditType = 'Full';
                }
                component.set('v.creditType', creditType);
                component.set('v.oldCreditType', creditType);
                component.set('v.renderComponent', true);
                component.set('v.spinner', false);
            }
        });
        $A.enqueueAction(action);
    },
    
})