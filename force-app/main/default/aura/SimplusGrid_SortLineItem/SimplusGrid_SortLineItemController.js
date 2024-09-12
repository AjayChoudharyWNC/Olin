({
	deleteButtonClick : function(component, event, helper) {
		component.getEvent("startLoading").fire();
		var getDelete = component.get("c.deleteSortFilterItem");
		getDelete.setParams({
            sObjectName : component.get("v.sObjectName"),
			type : "sort",
			id : component.get("v.lineItem.id")
		});
		getDelete.setCallback(this, function(a) {
			console.log("delete response >> ", a);
			console.log("delete response >> ", a.getState());
			var fireUp = component.getEvent("pushUpdate");
			fireUp.setParams({
				jsonParam : a.getReturnValue()
			})
			fireUp.fire();
		});
		$A.enqueueAction(getDelete);
	},

	toggleButtonClick : function(component, event, helper) {
		component.getEvent("startLoading").fire();
		component.set("v.lineItem.isActive", event.currentTarget.checked);

		var getToggle = component.get("c.toggleSortFilterItem");
		getToggle.setParams({
            sObjectName : component.get("v.sObjectName"),
			type : "sort",
			id : component.get("v.lineItem.id"),
			currentState : !component.get("v.lineItem.isActive")
		});
		getToggle.setCallback(this, function(a) {
			console.log("toggle response >> ", a);
			console.log("toggle response >> ", a.getState());
			var fireUp = component.getEvent("pushUpdate");
			fireUp.setParams({
				jsonParam : a.getReturnValue()
			})
			fireUp.fire();
		});
		$A.enqueueAction(getToggle);
	},
	
    dragstart: function(component, event, helper) {
		var drag = component.getEvent("drag");
		drag.setParams({
			jsonParam : event.target.dataset.dragId
		});
		component.set("v.dragid", event.target.dataset.dragId);
		drag.fire();
	},
	
    drop: function(component, event, helper) {
		var tg = event.target;
		while(tg.localName != "tr") {
			tg = tg.parentNode;
		}

		var drag = component.getEvent("drop");
		console.log(event);
		drag.setParams({
			jsonParam : {
				index : tg.dataset.dragId,
				targetTable : "sort"
			}
		});
		drag.fire();
        event.preventDefault();
	},
	
    cancel: function(component, event, helper) {
        event.preventDefault();
    }
})