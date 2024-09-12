({
	hanldeSSEWChanges : function(component, event, helper) {
		var value = event.getSource().get('v.value');
        if(value.includes('No')){
            component.set('v.SSEWCommentRequired', true);
        }
        else{
            component.set('v.SSEWCommentRequired', false);
        }
    },
    
     handleIndStandardChange :  function(component, event, helper) {
        var value = event.getSource().get('v.value');
        var valueSplit = value.split(';');
        if(valueSplit.length < 6){
            component.set('v.IndStandardCommentReq', true);
        }
        else{
            component.set('v.IndStandardCommentReq', false);
        }
    }
})