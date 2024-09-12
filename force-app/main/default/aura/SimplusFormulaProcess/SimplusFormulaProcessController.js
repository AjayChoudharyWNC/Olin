({
    doInit : function(component, event, helper) {
        console.log('Calling processResult');
        component.set("v.isLoadingList", true);
        var action = component.get("c.processResult");
        action.setParams({
            recordId : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            if(!response.getReturnValue()) {
                $A.get('e.force:refreshView').fire()
                $A.get("e.force:closeQuickAction").fire()
            }
        });
        $A.enqueueAction(action);
    }
})