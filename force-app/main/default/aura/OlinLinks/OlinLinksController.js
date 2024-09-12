({
	getIntlApps : function(component, event, helper) {
		
		var action = component.get("c.getIntlAppLinks");
		
		action.setCallback(this, function(response) {
		
		    var state = response.getState();
		    
		    if(state === "SUCCESS")
			    component.set("v.intlApps", response.getReturnValue());
			else
			    console.log("Failed with state: "+state);
		});
		
		$A.enqueueAction(action);
    }
})