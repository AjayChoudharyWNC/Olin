({	
	doInit : function(component, event, helper) {
		console.log("Record id: " + component.get("v.recordId"));
		var action = component.get("c.Initialize");
		action.setCallback(this, function(response) {
			var returnValue = response.getReturnValue();
			console.log("DefinedFormulas: " + returnValue);
			component.set("v.definedFormulas", returnValue);
			
			var jsonResult = JSON.parse(returnValue);
			console.log("Formula Definition", jsonResult.formulas);
			component.set("v.formulaDefinitions", jsonResult.formulas);
			component.set("v.isOnFocus", false);
		});
		$A.enqueueAction(action);
		var getRecord = component.get("c.getFormulaRecord");
		getRecord.setParams({
			recId : component.get("v.recordId")
		});
		getRecord.setCallback(this, function(a){
			var ret = a.getReturnValue();
			if(ret) {
				component.set("v.textAreaContents", ret.Formula__c);
				if(ret.Formula__c) {
					var textSplit = ret.Formula__c.split("");
					var splitFinal = [];
					textSplit.forEach(el => {
						if(el == '\n') {
							el = ':br:';
						}
						splitFinal.push(el);
					});
					component.set("v.textAreaContentsList",  splitFinal);
					helper.validate(component, event, helper);
				}
			}
		});
		$A.enqueueAction(getRecord);
	},

	validate : function(component, event, helper) {
		helper.validate(component, event, helper);
	},

	process : function(component, event, helper) {
		var action = component.get("c.Process");
		console.log("Saved Implmentation Record: " + component.get("v.implementation"));

		action.setParams({
			implementation : component.get("v.implementation")
		});
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {
				var result = response.getReturnValue();
				console.log("Process result: " + result);
				component.set("v.messageResult2", "Calculation Result: " + result);
				component.set("v.messageResult1", "");
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

    validateFormula : function(component, event, helper){
        var action = component.get("c.processFormula");
		var formulaValue = component.find("formulaValue");
		var formula = formulaValue.get("v.value");
		
		console.log("formulaValue: " + formula);
        action.setParams({
			formula : formula
		});
		action.setCallback(this, function(response) {
			console.log("Something happened: " + response);
			component.set('v.liked', true);
		});
		$A.enqueueAction(action);
	},

    resetValidation : function(component, event, helper){
		if(event.target) {
			component.set("v.textAreaContents", event.target.value);
			var textSplit = event.target.value.split("");
			var splitFinal = [];
			textSplit.forEach(el => {
				if(el == '\n') {
					el = ':br:';
				}
				splitFinal.push(el);
			});
			component.set("v.textAreaContentsList",  splitFinal);
		}
        component.set('v.liked', false);
	},

	handleOnChange : function(component, event, helper){
		var selectedValue = component.find("selectedFormula").get("v.value");
		var formulaDefinition = component.get("v.formulaDefinitions");
		if(selectedValue) {
			var selectedDefinition = formulaDefinition.find(element => {
				if(element.name == selectedValue) {
					component.set("v.enableInsert", false);
					return element;
				}
			});
			
			console.log("SELECTED FORMULA >> ", selectedDefinition);
			component.set("v.formulaStructure", selectedDefinition.formulaStructure);
			component.set("v.formulaDescription", selectedDefinition.description);
			component.set("v.formulaAttributes", selectedDefinition.attributes);
			component.set("v.selectedFormulaValue", selectedValue);
			helper.handleValidation(component, event, helper, selectedDefinition);
		}
	},

	handleInsert : function(component, event, helper){
		var selectedValue = component.find("selectedFormula").get("v.value");
		var formulaValue = component.get("v.textAreaContents"); //component.find("formulaValue").get("v.value");
		var attribs = component.get("v.formulaAttributes");
		var formulaParameter = '';
		var formula = '';
		var ag = component.get("v.autoGroup");
		var ab = component.get("v.autoBreak");
		var startPos = component.get("v.lastTextStartPt");
		var endPos = component.get("v.lastTextEndPt");
        
		if(!formulaValue) formulaValue = "";
		console.log("insert");
		console.log("attribs >> ", attribs);
		attribs.forEach(function(element) {
			if (element.isOutput == false || element.type == 'Picklist' || element.type == 'Boolean') {
				formulaParameter += (formulaParameter != '' ? ', ' : '' ) + element.entered;			
            }
		});
		formula = 
			(ab && startPos ? '\n' : '')
			+ (ag ? '( ' : '') 
			+ selectedValue 
			+ '(' + formulaParameter + ')' 
			+ (ag ? ' )' : '')
			+ (ab ? '\n' : '') ;
		formulaValue += formula;

		//component.find("formulaValue").set("v.value", formulaValue);
		console.log("formulaValue >> ", formulaValue);


		
		var startText = component.get("v.textAreaContents");
        if(!startText) startText = '';
		var insertInto = (src, idx, rem, str) => {
			return src.slice(0, idx) + str + src.slice(idx + Math.abs(rem));
		}

		//has value
		if(startPos || startPos === 0) {
			startText = insertInto(startText, startPos, endPos-startPos, formula);
			component.set("v.lastTextEndPt", startPos + formula.length);
		} else {
			startText += formula;
			component.set("v.lastTextStartPt", 0);
			component.set("v.lastTextEndPt", formula.length);
		}

		component.set("v.textAreaContents",  startText);
		var textSplit = startText.split("");
		var splitFinal = [];
		textSplit.forEach(el => {
			if(el == '\n') {
				el = ':br:';
			}
			splitFinal.push(el);
		});
		component.set('v.liked', false);
		component.set("v.textAreaContentsList",  splitFinal);
		
	},

	getPosition : function(component, event, helper){
		var txtArea = event.target;
        var startPos = txtArea.selectionStart;
        var endPos = txtArea.selectionEnd;
		component.set("v.lastTextStartPt", startPos);
		component.set("v.lastTextEndPt", endPos);
	},
	getPositionReset : function(component, event, helper){
		var txtArea = event.target;
        var startPos = txtArea.selectionStart;
        var endPos = txtArea.selectionEnd;
		component.set("v.lastTextStartPt", startPos);
		component.set("v.lastTextEndPt", endPos);
        component.set('v.liked', false);
	},

	focusText : function(component, event, helper) {
		component.set("v.isOnFocus",true);
		console.log(document.getElementById("formulaValue"));
		setTimeout(function(){document.getElementById("formulaValue").focus();}, 50);
	},

	blurText : function(component, event, helper) {
		component.set("v.isOnFocus",false);
	},

	autoGroup : function(component, event, helper) {
		component.set("v.autoGroup", !component.get("v.autoGroup"));
	},

	autoBreak : function(component, event, helper) {
		component.set("v.autoBreak", !component.get("v.autoBreak"));
	},

	toggleFormula : function(component, event, helper) {
		var tfDiv = component.find("formulaBuilder").getElement();
		var tfparentDiv = component.find("formulaContainer").getElement();
		var formulaControls = document.getElementById("formulaControls");
		
		console.log(formulaControls.offsetLeft, tfDiv.getClientRects().width);
		//tfDiv.style.left = (formulaControls.offsetLeft - (240 - tfDiv.getClientRects().width))  + "px";
		tfDiv.style.top = (formulaControls.offsetTop + 35) + "px";
		tfDiv.style.right = 45 + "px";

		if(tfDiv.style.display == "initial") tfDiv.style.display = "none";
		else tfDiv.style.display = "initial";

		event.stopPropagation();
	},
	closeBuilder : function(component, event, helper) {
		var tfDiv = component.find("formulaBuilder").getElement();
		tfDiv.style.display = "none";
	},
	preventPropagation : function(component, event, helper) {
		event.stopPropagation();
	},
	save : function(component, event, helper) {
		component.set('v.liked', false);
		var save = component.get("c.saveFormulaRecord");
		save.setParams({
			recId : component.get("v.recordId"),
			formula : component.get("v.textAreaContents"),
			implem : component.get("v.implementation")
		});
		save.setCallback(this, function(a){
			if(!a.getReturnValue()) {
				$A.get('e.force:refreshView').fire();
				$A.get("e.force:closeQuickAction").fire()
			} else {
				alert(a.getReturnValue());
			}
		});
		helper.validate(component, event, helper, save);
	}

})