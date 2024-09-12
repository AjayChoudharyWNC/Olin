({
	init : function(component, event, helper) {
		var getConfigFields = component.get("c.getControlFields");
		getConfigFields.setParams({
			"fieldSetNames" : [component.get("v.mainListSource")]
		});
		
		getConfigFields.setCallback(this, function(a){
			var fieldMap = a.getReturnValue()
			var fldList = [];

			for (var key in fieldMap) {
				if (fieldMap.hasOwnProperty(key)) {
					if(fieldMap[key].enableMassUpdate) {
						fldList.push(fieldMap[key]);
					}
				}
			}

			fldList = helper.sortByOrder(fldList, "sortOrder");

			component.set("v.fieldsList", fldList);
		});
		$A.enqueueAction(getConfigFields);
	},

	onPricePicklistSelect: function(cmp, evt, hlp) {
		var selectedValue = cmp.find("priceChangeBehavior").get("v.value");
		var newPriceField = cmp.find("newPrice");
		var formatter = selectedValue === "Percent" ? "percent" : "currency";
		newPriceField.set("v.formatter", formatter);
	},

	validateDates: function(cmp, evt, hlp) {
		var field_startDate = cmp.find("priceStart");
		var field_endDate = cmp.find("priceEnd");
		var startDate = field_startDate.get("v.value");
		var endDate = field_endDate.get("v.value");

		field_startDate.setCustomValidity("");
		field_endDate.setCustomValidity("");
		if (new Date(startDate) > new Date(endDate)) {
			field_startDate.setCustomValidity("Invalid value.");
			field_endDate.setCustomValidity("Invalid value.");

			var toastEvent = $A.get("e.force:showToast");
			toastEvent.setParams({
				"type": "error",
				"title": "Error!",
				"message": "Price Start Date should not be later than the Price Expiration Date.",
				"variant": "sticky"
			});
			toastEvent.fire();
		}
		field_startDate.reportValidity();
		field_endDate.reportValidity();
	},

	adjustPercentageField: function(cmp, evt, hlp) {
		var adjustmentBehavior = cmp.find("priceChangeBehavior").get("v.value");
		console.log("adj: " + adjustmentBehavior);
		if (adjustmentBehavior !== "Percent") {
			return ;
		}

		var field = evt.getSource();
		if (field.get("v.value") > 0.99) {
			field.set("v.value", field.get("v.value") * 0.01);
		}
	},

	clearAllClick : function(component, event, helper) {
		/*var fieldsList = component.get("v.fieldsList");
		fieldsList.forEach(function(entry) {
			entry.clearVal();
		});*/
		component.find("priceChangeBehavior").set("v.value", "Add");
		component.find("newPrice").set("v.value");
		component.find("priceStart").set("v.value");
		component.find("priceEnd").set("v.value");
	},

	applyChangesClick : function(component, event, helper) {
		/*var fieldsList = component.get("v.fieldsList");
		fieldsList.forEach(function(entry) {
			entry.pushValToTable();
		});*/
		var pushChanges = $A.get("e.c:MassChangeEvent");
		
        pushChanges.setParams({
			"priceChangeBehavior" : component.find("priceChangeBehavior").get("v.value"),
            "priceAdjustment" : component.find("newPrice").get("v.value"),
            "priceStartDate" : component.find("priceStart").get("v.value"),
            "priceEndDate" : component.find("priceEnd").get("v.value")
		});
		pushChanges.fire();
		
		var pushUpdate = component.getEvent("pushUpdate");
		pushUpdate.fire();
		component.set("v.showEdit", true);
	},

	saveClicked : function(component, event, helper) {
		var pushChanges = $A.get("e.c:MassChangeEvent");
		
        pushChanges.setParams({
			"priceChangeBehavior" : component.find("priceChangeBehavior").get("v.value"),
            "priceAdjustment" : component.find("newPrice").get("v.value"),
            "priceStartDate" : component.find("priceStart").get("v.value"),
            "priceEndDate" : component.find("priceEnd").get("v.value")
		});
		pushChanges.fire();

		var pushUpdate = component.getEvent("pushUpdate");
		pushUpdate.fire();

		//component.set("v.showEdit", false);
		var pushSave = component.getEvent("pushSave");
		pushSave.fire();
	},

	cancelClicked : function(component, event, helper) {
		component.set("v.showEdit", false);
		var fldListNames = component.get("v.fieldsList");
		var fldList = [];
		fldListNames.forEach(element => {
			fldList.push(element.name);
		})
		var pushCancel = component.getEvent("pushCancel");
		pushCancel.setParams({"jsonParam" : fldList});
		pushCancel.fire();
	},

	cloneClicked : function(component, event, helper) {
		component.set("v.showEdit", false);
		var pushUpdate = component.getEvent("pushClone");
		pushUpdate.fire();
	}
})