({
    doInit : function(component, event, helper) {
        if(component.get("v.showFieldLabel") == 'false' || component.get("v.showFieldLabel") == 'False' ){
            component.set("v.showLabel",'label-hidden');
            component.set("v.showhideClass",'hide-label');
        }
        var action = component.get("c.FetchType");
        action.setParams({'recordId':component.get("v.recordId"),'fieldApiName':component.get("v.fieldApiName")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result',result);
                console.log('objectName',result.objname);
                component.set('v.objectName',result.objname);
                if(result.isRichText == false){
                    console.log('ok')
                    component.set("v.showError",true);
                    component.set("v.showSucces",false);
                }
                if(result.isRichText == true){
                    component.set("v.showSucces",true);
                    component.set("v.showError",false);
                    
                }
                if(result.showEdit == false){
                     component.set("v.showEditBttn",'hide-label');
                }
                if(result.msg == true){
                    component.set("v.showError1",true);
                    component.set("v.showSucces",false);
                }
            }
        });
        $A.enqueueAction(action);	
    },
    handleSubmit : function(cmp, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success",
            "type": "success",
            "message": "The record has been saved successfully."
        });
        toastEvent.fire();
        cmp.set("v.showSucces",true);
        cmp.set("v.showEditForm",false);
    },
    handleEdit : function(component, event, helper) {
        component.set("v.showEditForm",true);
        component.set("v.showSucces",false);
    },
    handleCancelClick: function(component, event, helper) {
        component.set("v.showSucces",true);
        component.set("v.showEditForm",false);
    }
    
})