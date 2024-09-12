({
	
	elementDrag : function(component, event, helper) {
		event.preventDefault();
		var elmnt = component.find("historicalDataHeader").getElement().parentNode;
		// calculate the new cursor position:
		component.set("v.pos1", component.get("v.pos3") - event.pageX);
		component.set("v.pos2", component.get("v.pos4") - event.pageY);
		component.set("v.pos3", event.pageX);
		component.set("v.pos4", event.pageY);
		// set the element's new position:
		var top = (elmnt.parentNode.offsetTop - component.get("v.pos2"));
		var left = (elmnt.parentNode.offsetLeft - component.get("v.pos1"));
		elmnt.parentNode.style.top = top + "px";
		elmnt.parentNode.style.left = left + "px";
		component.set("v.initialTop", top);
		component.set("v.initialLeft", left);

	},

	closeDragElement : function(component, event, helper) {
		// stop moving when mouse button is released:
		document.onmouseup = null;
		document.onmousemove = null;
	  }
})