({
    doInit: function(component, event, helper) {
        var callreportId = component.get("v.recordId");
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": 'Sample__c',
            "defaultFieldValues": {
                'Call_Report_Sample__c' : callreportId
            }
        });
        createRecordEvent.fire();
    }
})