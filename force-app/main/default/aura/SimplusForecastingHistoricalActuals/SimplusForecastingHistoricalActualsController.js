({
	onInit : function(component, event, helper) {
		var getRecords=  component.get("c.getPriorActualsData");
		getRecords.setParams({
			findKey : component.get("v.forecastKeyForHistory"),
			month : component.get("v.activeDateMonth"),
			year : component.get("v.activeDateYear")
		});
        console.log(component.get("v.forecastKeyForHistory"), component.get("v.activeDateMonth"), component.get("v.activeDateYear"));
		getRecords.setCallback(this, function(a){
			console.log(a.getReturnValue());
			component.set("v.historyObject", a.getReturnValue());
		});
		$A.enqueueAction(getRecords);
	},


	dragMouseDown : function(component, event, helper) {
		event.preventDefault();
		component.set("v.pos3", event.clientX);
		component.set("v.pos4", event.clientY);
    	document.onmouseup = function(e){ helper.closeDragElement(component, e, helper); };
		document.onmousemove = function(e){ helper.elementDrag(component, e, helper); };
	},

	elementDrag : function(component, event, helper) {
		helper.elementDrag(component, event, helper);
	},

	toggleOpacity : function(component, event, helper) {
		if(component.get("v.opacity") == 4) component.set("v.opacity", 1);
		else component.set("v.opacity", component.get("v.opacity") + 1);
	},

	runCloseMe : function(component, event, helper) {
		component.getEvent("pushClose").fire();
	}
})