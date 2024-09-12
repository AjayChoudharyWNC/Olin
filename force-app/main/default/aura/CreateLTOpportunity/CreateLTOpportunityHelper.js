({
    getLTRecordTypeId : function(component) {
        var action = component.get('c.getRecordTypeId');
        action.setParams({
            recordTypeName: 'Long Term Opportunity'
        });
        action.setCallback(this, function (response) {
            if (response.getState() === 'SUCCESS') {
                component.set('v.recordTypeId', response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    }
})