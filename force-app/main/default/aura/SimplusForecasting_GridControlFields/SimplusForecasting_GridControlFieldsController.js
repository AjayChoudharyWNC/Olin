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

	clearAllClick : function(component, event, helper) {
		var fieldsList = component.get("v.fieldsList");
		fieldsList.forEach(function(entry) {
			entry.clearVal();
		});
	},

	applyChangesClick : function(component, event, helper) {
		var fieldsList = component.get("v.fieldsList");
		fieldsList.forEach(function(entry) {
			entry.pushValToTable();
		});
		var pushUpdate = component.getEvent("pushUpdate");
		/*pushUpdate.setParams({
			"jsonParam" : {
				hasPendingUpdates: true
			}
		});*/
		pushUpdate.fire();
		component.set("v.showEdit", true);
	},

	saveClicked : function(component, event, helper) {
		component.set("v.showEdit", false);
		var pushUpdate = component.getEvent("pushSave");
		pushUpdate.fire();
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