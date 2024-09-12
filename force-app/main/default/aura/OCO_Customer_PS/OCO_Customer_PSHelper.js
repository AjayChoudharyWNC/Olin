({
    updateSapRecord : function(component){
        var action = component.get('c.saveSapOnboarding');
        action.setParams({
            sapRecord : component.get('v.sapRecord'),
            currentAppUser : component.get('v.appUserId')
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                var parent = component.get('v.parent');
                parent.openToast('utility:success','JS_17', 'success');     
                parent.getSapRecord();
                component.set('v.spinner', false);
            }
        });
        $A.enqueueAction(action);
    }   
})