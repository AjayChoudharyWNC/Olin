({
	instructClick : function(component, event, helper) {
		component.set('v.showInstruction',true);
        component.set('v.showVideo',false);
	},
    videoClick : function(component, event, helper) {
		component.set('v.showInstruction',false);
        component.set('v.showVideo',true);
	},
    cancel: function(component, event, helper) {
		component.set('v.showInstruction',false);
        component.set('v.showVideo',false);
	}
})