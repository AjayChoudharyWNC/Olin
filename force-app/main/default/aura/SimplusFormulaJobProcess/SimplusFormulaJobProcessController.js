({
	doInit : function(component, event, helper) {
		console.log('Calling processResult');
        
        component.set("v.isLoadingList", true);
		var action = component.get("c.RunFormula");
        action.setParams({
            quote : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            console.log('Record Id: ', component.get("v.recordId"));
            if(!response.getReturnValue()) {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "Success",
                    "title": "Success!",
                    "message": "Recalculation on process for a while."
                });
                toastEvent.fire();
                
                window.setTimeout(
                    $A.getCallback(function() {                        
                        window.location.reload();
                        $A.get("e.force:closeQuickAction").fire();
                    }), 5000
                );
                
            }
        });
        $A.enqueueAction(action);
        
        
	}
})