({
	getCoords : function(elem) { // crossbrowser version
		var box = elem.getBoundingClientRect();
		console.log(box);
		var body = document.body;
		var docEl = document.documentElement;
	
		var scrollTop = window.pageYOffset || docEl.scrollTop || body.scrollTop;
		var scrollLeft = window.pageXOffset || docEl.scrollLeft || body.scrollLeft;
	
		var clientTop = docEl.clientTop || body.clientTop || 0;
		var clientLeft = docEl.clientLeft || body.clientLeft || 0;
	
		var top  = box.top +  scrollTop - clientTop;
		console.log(box.left, scrollLeft, clientLeft);
		var left = box.left + scrollLeft - clientLeft;
	
		return { top: Math.round(top), left: Math.round(left) };
	},

	validate : function(component, event, helper, save) {
		var action = component.get("c.Validate");
		//var formulaValue = component.find("formulaValue");
		var formula = component.get("v.textAreaContents"); //formulaValue.get("v.value");
		console.log("Saved Formula Setup: " + component.get("v.definedFormulas"));
		console.log("formula: " + formula);

		action.setParams({
			formulas : component.get("v.definedFormulas"),
			formula : formula
		});
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var result = response.getReturnValue();
				console.log("Formula Validation: " + result.formulaValidation);
				console.log("Mathematic Validation: " + result.mathematicValidation);
				component.set("v.liked", (result.formulaValidation && result.mathematicValidation));
				console.log("Implementation: " + result.implementation);
				component.set("v.implementation", result.implementation);
				component.set("v.messageResult2", "");
				component.set("v.messageResult1", "");
				if(save) {
					$A.enqueueAction(save);
				}
			} else if (state === "ERROR") {
				//TODO, show the error message.
				var errors = response.getError();
				var message = 'Unknown error'; // Default error message
				// Retrieve the error message sent by the server
				if (errors && Array.isArray(errors) && errors.length > 0) {
					message = errors[0].message;
				}
				// Display the message
				/*var showToast = $A.get("e.force:showToast");
				if (showToast) {
					showToast.setParams({ 
						mode  : "sticky",
						title : 'Error', 
						message : message 
					}); 
					showToast.fire();
				}*/
				console.error(message);
				component.set("v.messageResult2", "");
				component.set("v.messageResult1", message);
			} else {
				console.log("Unknown outcome");
				component.set("v.messageResult2", "No Error Detected");
				component.set("v.messageResult1", "Unknown Calculation Result");
			}
		});
		$A.enqueueAction(action);
	},

	handleValidation : function(component, event, helper, selectedDefinition) {
		// check if Type = Query
		// validate that 1 Formula Attribute record is marked as Output
		// 1 is valid, none or more than 1 is invalid
		var isValid = true;
		if(selectedDefinition.type == 'Query') {
			if(selectedDefinition.attributes.length > 0) {
				var counter = 0;
				for(var i = 0; i < selectedDefinition.attributes.length; i++) {
					if(selectedDefinition.attributes[i].isOutput == true) {
						counter++;
					}
				}
				if(counter != 1) {
					isValid = false;
					component.set("v.errorMessage", 'You must add only 1 Output Formula Attribute when the type of Query is selected');
					component.set("v.showErrorMessage", true);
				}
			} else {
				isValid = false;
				component.set("v.errorMessage", 'You must add only 1 Output Formula Attribute when the type of Query is selected');
				component.set("v.showErrorMessage", true);
			}

		// check if Type = Formula
		// validate that NO Formula Attribute is marked as Output
		// at least 1 Formula Attribute record is required
		} else if(selectedDefinition.type == 'Formula') {
			if(selectedDefinition.attributes.length > 0) {
				var counter = 0;
				for(var i = 0; i < selectedDefinition.attributes.length; i++) {
					if(selectedDefinition.attributes[i].isOutput == true) {
						counter++;
					} 
				}
				if(counter > 0) {
					isValid = false;
					component.set("v.errorMessage", 'Output Formula Attributes are not valid for this type of Formula Definition');
					component.set("v.showErrorMessage", true);
				}
			} else {
				isValid = false;
				component.set("v.errorMessage", 'At least 1 Formula Attribute is required for this type of Formula Definition');
				component.set("v.showErrorMessage", true);
			}

		// check if Type = Date and Date Type is not null
		// validate that NO Formula Attribute is marked as Output
		// at least 1 Formula Attribute record is required	
		} else if(selectedDefinition.type == 'Date') {
			if(selectedDefinition.dateType != null) {
				if(selectedDefinition.attributes.length > 0) {
					var counter = 0;
					for(var i = 0; i < selectedDefinition.attributes.length; i++) {
						if(selectedDefinition.attributes[i].isOutput == true) {
							counter++;
						} 
					}
					if(counter > 0) {
						isValid = false;
						component.set("v.errorMessage", 'Output Formula Attributes are not valid for this type of Formula Definition');
						component.set("v.showErrorMessage", true);
					}
				} else {
					isValid = false;
					component.set("v.errorMessage", 'At least 1 Formula Attribute is required for this type of Formula Definition');
					component.set("v.showErrorMessage", true);
				}
			} else {
				isValid = false;
				component.set("v.errorMessage", 'You must select Date Type for when the Type of Date is selected');
				component.set("v.showErrorMessage", true);
			}
		} 

		if(isValid == true) {
			component.set("v.showErrorMessage", false);
		}

	}
})