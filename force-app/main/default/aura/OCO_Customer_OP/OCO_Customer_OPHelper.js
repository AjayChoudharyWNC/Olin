({

	updateSapRecord : function(component, isSubmit){
      var action = component.get('c.saveSapOnboarding');
        action.setParams({
            sapRecord : component.get('v.sapRecord'),
            currentAppUser : component.get('v.appUserId')
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                component.set('v.spinner', false);
                var parent = component.get('v.parent');
                if(!isSubmit)
                parent.openToast('utility:success', 'JS_11', 'success');
                else
                    parent.openToast('utility:success', 'JS_12', 'success');
                parent.getSapRecord();
            }
        });
        $A.enqueueAction(action);
    },
})