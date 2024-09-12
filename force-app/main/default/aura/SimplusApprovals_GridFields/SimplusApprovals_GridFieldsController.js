({
	doInit : function(component, event, helper) {
		helper.init(component, event, helper);
	},

	fieldChange : function(component, event, helper) {
		var record = {};
		var field = component.get("v.field");

		record[field.fieldName] = component.get("v.cellValue");
		component.set("v.record." + field.fieldName, component.get("v.cellValue"));
		if( !component.get("v.hasPendingMassChange") ) {
			component.set("v.isSaving", true);
			record.sobjectType = "sbaa__Approval__c";
			record.Id = component.get("v.record.Id");
	
			var updateRecordAction = component.get("c.updateGridRecord");
			updateRecordAction.setParams({
				"s" : record
			});
			updateRecordAction.setCallback(this, function(ret){
				component.set("v.isSaving", false);
				component.set("v.editToggle", false);
				//todo: add error message handling
			});
			$A.enqueueAction(updateRecordAction);
		}
	},

	disableEdit : function(component, event, helper) {
		setTimeout($A.getCallback(() => component.set("v.editToggle", false)), 150);
	},

	fieldKeyPress : function(component, event, helper) {
		console.log(event);
	},

	toggleEdit : function(component, event, helper) {
		if(component.get("v.isEditable") && !component.get("v.isLocked")) component.set("v.editToggle", true);
	},

	revertValue : function(component, event, helper) {
		helper.revertChange(component);
	},

	catchToggleEditAll : function(component, event, helper) {
		var fldName = event.getParam("columnName");
		if(fldName == component.get("v.field.fieldName") && !component.get("v.isLocked")) {
			if(component.get("v.isEditable")) component.set("v.editToggle", true);
		}
	}
})