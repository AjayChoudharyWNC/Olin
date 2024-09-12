({
    doInit : function(component, event, helper) {
        var action = component.get('c.getCreditPermission');
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set('v.hasCreditPermission', response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    }
})