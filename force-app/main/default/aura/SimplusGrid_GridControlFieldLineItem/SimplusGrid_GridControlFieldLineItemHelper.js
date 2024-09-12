({
	runPushValue : function(component, helper) {
		var pushChanges = $A.get("e.c:SimplusGrid_GridControlFieldPushChanges");
		
        pushChanges.setParams({
			"fieldApi" : component.get("v.field.name"),
            "newValue" : component.get("v.valueHolder"),
            "formula" : component.get("v.formulaHolder"),
            "multiDecision" : component.get("v.field.multiDecision")
        });
        
		if(component.get("v.valueHolder")) {
			console.log("pushing from ", component.get("v.field.name"));
			pushChanges.fire();
		}
	},
    buildMulti : function(component, helper, field) {
        console.log(field);
        console.log("params:::>> ", field.massUpdateParams);


        var params = JSON.parse(field.massUpdateParams);

        component.set("v.customFieldUtil", new Object());
        var customFieldUtil = component.get("v.customFieldUtil");

        var pushToBody = function(newField, status, errorMessage) {
            if (status === "SUCCESS") {
                var body = component.get("v.dynamicBody");
                body.push(newField);
                component.set("v.dynamicBody", body);
            }
        };
        
        component.set("v.customFieldUtil.label", params.label);
        params.fields.forEach(
            element => {
                component.set("v.customFieldUtil." + element.id, element);
                if(element.type == 'radiogroup') {
                	element.options.forEach(
                        opt => {
                            component.set("v.customFieldUtil." + element.id + "." + opt.id, opt);
                            component.set("v.customFieldUtil." + opt.id, opt);
                            component.set("v.customFieldUtil." + opt.id + ".parent", element.id);

                            helper.buildField(
                                component, 
                                helper, 
                                "ui:inputRadio", 
                                {
                                    value: false,
                                    id : opt.id,
                            		"aura:id" : opt.id,
                                    label : opt.label,
                					name : element.id,
                                    change : component.getReference("c.dynamicChangeEvent")
                                },
                                pushToBody
                            );
                    	}
                	);
            	} else if(element.type == 'number') {
                    helper.buildField(
                        component, 
                        helper, 
                		"ui:inputNumber", 
                		{
                			value: ("v.customFieldUtil." + element.id),
                			label : element.label,
                			id : element.id,
                            "aura:id" : element.id,
                            name : element.id,
                			change : component.getReference("c.dynamicChangeEvent"),
                            format : '.00'
            			},
                        pushToBody
                    );
                } else if(element.type == 'text') {
                    helper.buildField(
                        component, 
                        helper, 
                		"ui:inputText", 
                		{
                			value: ("v.customFieldUtil." + element.id),
                			label : element.label,
                			id : element.id,
                            "aura:id" : element.id,
                            name : element.id,
                			change : component.getReference("c.dynamicChangeEvent")
            			},
                        pushToBody
                    );
                }
            }
        );
        //component.set("v.customFieldUtil", customFieldUtil);
    },
    buildField : function(component, helper, elType, elParams, callback) {
        $A.createComponent(elType,elParams,callback);
    }
})