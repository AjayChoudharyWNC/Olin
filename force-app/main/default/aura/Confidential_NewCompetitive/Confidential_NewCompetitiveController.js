({
    doInit: function(component, event, helper) {
        var action = component.get('c.fetchRelatedAccount');
        action.setParams({
            'recordId' : component.get("v.recordId"),
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var callreportId = component.get("v.recordId");
                var createRecordEvent = $A.get("e.force:createRecord");
                createRecordEvent.setParams({
                    "entityApiName": 'Confidential_Competitive__c',
                    "defaultFieldValues": {
                        'Confidential_Call_Report__c' : callreportId,
                        'Customer_R1__c' : result
                    }
                });
                createRecordEvent.fire();
            }
        });
        $A.enqueueAction(action);    
    }
})