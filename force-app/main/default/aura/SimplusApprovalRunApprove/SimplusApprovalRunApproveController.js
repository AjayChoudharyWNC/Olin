({
    doInit : function(component, event, helper) {
        console.log(component.get("v.recordId"));
        
        var domain = component.get("c.getmydomain");
        domain.setCallback(this, function(response){
            console.log('Domain Response:' + response);
            if (response.getState() === "SUCCESS") {
                var vfOrigin = 'https://' + response.getReturnValue() + '--c.visualforce.com';
                
                component.set("v.vfHost", vfOrigin); 
                
                helper.addMessageListener(component, helper);
                component.set("v.approveClicked", true);
            }
        });
        $A.enqueueAction(domain); 
    },
    
    toggleDisplay : function(component, event, helper) {
		component.set("v.display", !component.get("v.display"));
        console.log("toggle display >>> ", component.get("v.display"));
        
        
        if(!component.get("v.display")) component.set("v.approveClicked", false);
        var eve = $A.get("e.c:SimplusApproval_CloseOthers");
        eve.setParams({
            callerId : component.get("v.recordId") + component.get("v.isApprove")
        });
        eve.fire();
        
        if(component.get("v.display")) {
        } else {
            console.log("removing message catcher");
            window.removeEventListener("message");
            console.log("removed");
        }
        
	},
    
    closeMe : function(component, event, helper) {
        if(
            (component.get("v.recordId") + component.get("v.isApprove"))
           	!= 
        	(event.getParams().callerId)
        ) {
            window.removeEventListener("message");
            component.set("v.approveClicked", false);
            component.set("v.iframeLoaded", false);
            component.set("v.display", false);
        }
    },
    
    doConfirm : function(component, event, helper) {
        /*console.log("y");
        var message = {name:'test'};
        var vfOrigin = "https://" + component.get("v.vfHost");
        var vfWindow = document.getElementById(component.get("v.recordId")).contentWindow;
        console.log("y", vfWindow);
        vfWindow.postMessage(message, vfOrigin);
        console.log("x", vfWindow);
        */
    },
    
    loadComplete : function(component, event, helper) {
        console.log("loaded 1");
        if(component.get("v.approveClicked")) {
            //window.location.reload();
        }
        component.set("v.iframeLoaded", true);
    }
})