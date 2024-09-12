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
                console.log('result',result);
                var callreportId = component.get("v.recordId");
                var createRecordEvent = $A.get("e.force:createRecord");
                createRecordEvent.setParams({
                    "entityApiName": 'Competitor_R1__c',
                    "defaultFieldValues": {
                        'CallReport_R1__c' : callreportId,
                        'Customer_R1__c' : result
                    }
                });
                createRecordEvent.fire();
            }
        });
        $A.enqueueAction(action);     
    }
})