({
	init : function(component, event, helper) {
		var field = component.get("v.field");
        console.log("field >>> ", field.name, component.get("v.field.multiDecision"));
        if(field.massUpdateType == 'Multi') {
			helper.buildMulti(component, helper, field);
        }
        
		field.clearVal = function() {
			component.set("v.valueHolder");
		};
		field.pushValToTable = function() {
			helper.runPushValue(component, helper);
		};
		component.set("v.field", field);
	},
    
    dynamicChangeEvent : function(component, event, helper) {
		
		var details = component.get("v.customFieldUtil." + event.getSource().getLocalId());
		var newVal = event.getSource().get("v.value");
		var invokerDetails = details;
		
		if(details.parent) {
			invokerDetails = details;
			details = component.get("v.customFieldUtil." + details.parent);
		}
		
		if(details) console.log(details.id);
		if(invokerDetails) console.log(invokerDetails.id);

		var f = {
			c : component,
			e : event,
			setVal : function(newVal) {
				this.c.set("v.valueHolder", newVal);
			},
			setFunction : function(func) {
				this.c.set("v.formulaHolder", func);
			},
			deselectRadio : function() {
				console.log(this.e);
				this.e.getSource().set("v.value");
			}
		}
		
		if(invokerDetails.onchangeAction) {
			try {
				var runFunc = new Function("f","newVal", invokerDetails.onchangeAction);
				runFunc(f, newVal);
			} catch(e) {
				console.log(e);
			}
		}

    }
})