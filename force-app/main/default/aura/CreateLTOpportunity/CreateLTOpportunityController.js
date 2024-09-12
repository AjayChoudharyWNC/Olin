({
    doInit : function(component, event, helper){
        var action = component.get('c.GetProducts');
        action.setParams({
            accId : component.get('v.recordId')
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                component.set('v.products', response.getReturnValue());
            }
        })
        $A.enqueueAction(action);
        helper.getLTRecordTypeId(component);
    },
    
    handleLoad: function(cmp, event, helper) {
        cmp.set('v.showSpinner', false);
    },

    handleSubmit: function(cmp, event, helper) {
        event.preventDefault();
        /*var fields = event.getParam('fields');
        if(cmp.find('product').get('v.value')){
            fields['Purchased_Product__c'] = cmp.find('product').get('v.value');
        }*/
        cmp.find('recordEditForm').submit();
        cmp.set('v.disabled', true);
        cmp.set('v.showSpinner', true);
    },

    handleError: function(cmp, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error!",
            "type": "error",
            "message": "There are errors on this page, please review and save again."
        });
        toastEvent.fire();
        cmp.set('v.showSpinner', false);
        cmp.set('v.disabled', false);
    },

    handleSuccess: function(cmp, event, helper) {
        cmp.set('v.showSpinner', false);
        cmp.set('v.saved', true);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "type": "success",
            "message": "Long Term Opportunity created successfully."
        });
        toastEvent.fire();
        var payload = event.getParams().response;
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": payload.id,
            "slideDevName": "related"
        });
        navEvt.fire();
    },
    cancel: function(cmp, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": cmp.get('v.recordId'),
            "slideDevName": "related"
        });
        navEvt.fire();
    }
});