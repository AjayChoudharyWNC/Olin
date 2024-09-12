({
	getParameterByName: function(component, event, name) {
        name = name.replace(/[\[\]]/g, "\\$&");
        var url = window.location.href;
        var regex = new RegExp("[?&]" + name + "(=1\.([^&#]*)|&|#|$)");
        var results = regex.exec(url);
        if (!results) return null;
        if (!results[2]) return '';
        return decodeURIComponent(results[2].replace(/\+/g, " "));
    },
    
    getSalesOrg: function(component,event,fields){
        var orgId = component.find("orgField").get("v.value");
        var action = component.get('c.getOrgName');
        action.setParams({"orgId": orgId});
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                if(fields != null){
                    fields.Name = response.getReturnValue();
                    component.find('recordEditForm').submit(fields);
                }
                else{
                    component.find("nameField").set("v.value", response.getReturnValue());
                    component.find('recordEditForm').submit();
                }
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type": "success",
                    "message": "The Sales Organization has been added successfully."
                });
                toastEvent.fire();
                if(fields != null){
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": '/lightning/r/Account/'+component.get('v.parentRecordId')+'/view'
                    });
                    urlEvent.fire();
                }
                else{
                    window.location.reload();
                }
            }
        });
        $A.enqueueAction(action);
    }
})