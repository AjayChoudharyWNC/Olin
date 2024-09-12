({
	doInit : function(component, event, helper) {
		helper.init(component, event, helper);
	},

	fieldChange : function(component, event, helper) {
        console.log('isTextField? ' + component.get("v.field"));
		var record = {};
		var field = component.get("v.field");

		console.log('FIELD NAME: ');
		console.log(field.fieldName);
		console.log('CELL VALUE: ');
		//console.log(event);
		record[field.fieldName] = component.get("v.cellValue");
		component.set("v.record." + field.fieldName, component.get("v.cellValue"));
        //console.log('18-->v.record',JSON.stringify(v.record));

		var clearValidations = $A.get("e.c:ClearCellValidations");
		
        clearValidations.setParams({
			"Id" : component.get("v.record.Id"),
			"type" : 'clear'
		});
		clearValidations.fire();

		var validationResult = helper.runFieldValidation(component);
		console.log("validationResult:");
		console.log(validationResult);
		
		if( !component.get("v.hasPendingMassChange") ) {
			var inlineEditAction = $A.get("e.c:InlineEditEvent");
			inlineEditAction.setParams({
				"recordId": component.get("v.record.Id"),
				"field": field.fieldName,
				"value": component.get("v.cellValue"),
				"hasWarnings": validationResult && validationResult.hasWarnings
			});
			inlineEditAction.fire();
		}

		if (component.get('v.isPercentField')) {
			var field = event.getSource();
			if (field.get("v.value") > 0.99) {
				field.set("v.value", field.get("v.value") * 0.01);
			}
            console.log('Percent----'+field.get("v.value"));
		}
	},

	disableEdit : function(component, event, helper) {
		setTimeout($A.getCallback(() => component.set("v.editToggle", false)), 150);
	},

	fieldKeyPress : function(component, event, helper) {
		console.log(event);
	},

	toggleEdit : function(component, event, helper) {
		if(component.get("v.isEditable") && !component.get("v.isLocked")) {
			component.set("v.editToggle", true);
			setTimeout($A.getCallback(() => {
				component.find("formInput").focus();
			}), 150);
		}
	},

	revertValue : function(component, event, helper) {
		helper.revertChange(component);
	},

	catchToggleEditAll : function(component, event, helper) {
		var fldName = event.getParam("columnName");
		if(fldName == component.get("v.field.fieldName") && !component.get("v.isLocked")) {
			if(component.get("v.isEditable")) component.set("v.editToggle", true);
		}
	},

	handleSearch : function(component, event, helper) {
        const target = event.target;
		var getLookupResults = component.get("c.getLookupResults");
		console.log(event);
		console.log(event.getParam('searchTerm'));
		getLookupResults.setParams({
			"searchTerm" : event.getParam('searchTerm'),
			"sObjType": "SBQQ__QuoteLine__c",
			"field" : component.get("v.field").fieldName
		});
		getLookupResults.setCallback(this, function(ret){
			if (ret.getReturnValue()) {
				console.log(event.target);
				console.log(ret.getReturnValue());
				component.find('formInput').setSearchResults(ret.getReturnValue());
			}
		});
		$A.enqueueAction(getLookupResults);
    },

	handleLookupChange : function(component, event, helper) {
		var field = component.get("v.field");
		var selection = component.find('formInput').getSelection();
		console.log(selection);
		var hasSelection = selection.length > 0;
		// component.set("v.record." + field.fieldName, event.detail);
		component.set("v.cellValue", hasSelection ? selection[0].id : '');
		component.set("v.cellLabel", hasSelection ? selection[0].title : '');
		if( !component.get("v.hasPendingMassChange") ) {
			var inlineEditAction = $A.get("e.c:InlineEditEvent");
			inlineEditAction.setParams({
				"recordId": component.get("v.record.Id"),
				"field": field.fieldName,
				"value": hasSelection ? selection[0].id : '',
				"hasWarnings": false
			});
			inlineEditAction.fire();
			setTimeout($A.getCallback(() => component.set("v.editToggle", false)), 150);
		}
    },

	formatPercentage : function (cmp, evt, hlp) {
	}
})