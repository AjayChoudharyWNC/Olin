({
	doInit : function(component, event, helper) {
        var action = component.get('c.createFileWrapper');
        action.setParams({type: component.get('v.type'), recId: component.get('v.recId')});
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var result = response.getReturnValue();
                if(Array.isArray(result)){
                    component.set('v.fileList', result);
                }
                else{
                    component.set('v.emptyListMsg', result);
                }
            }
        });
        $A.enqueueAction(action);
	}
})