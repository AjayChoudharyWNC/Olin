({
	addMessageListener : function(component) {
		window.addEventListener("message", function(event) {
            console.log("----------------caught");
            console.log(event.data);
            var data = JSON.parse(event.data);
            
            if(component.get("v.recordId").indexOf(data.source) === 0 && component.get("v.isApprove") === data.isApprove) {
                console.log("close me");
                if(data.isReload) {
                    window.setTimeout(
                        $A.getCallback(
                            function(){window.location.reload()}
                            ),
                        3000);
                }
                else component.set("v.display", false);
            } else {
                console.log("dont close me");
            }
            
        }, false);
        console.log("add message listener called");
	}
})