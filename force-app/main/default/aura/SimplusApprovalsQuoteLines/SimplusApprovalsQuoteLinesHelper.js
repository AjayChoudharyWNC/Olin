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
	},

	renderSection : function(component, event, helper) {
		var data = component.get("v.data");
        console.log('BEFORE COMPETITIVE PJ PJ PJ ');
        console.log('Account :::::  ',data.Competitive_Distributor__c);
        console.log('Product :::::  ',data.Competitor_Product__c);
        console.log('Price :::::  ',data.Competitive_Price__c);
        
		if(data.CUPS_Support_Price__c && data.CUPS_Discount_Percent__c && data.CUPS_Start_Date__c && data.CUPS_End_Date__c) {
			component.set("v.showCUPSInfo1", true);
			component.set("v.showCUPSInfo", true);
		}
		if(data.CUPS_Support_Price2__c && data.CUPS_Discount_Percent2__c && data.CUPS_Start_Date2__c && data.CUPS_End_Date2__c) {
			component.set("v.showCUPSInfo2", true);
			component.set("v.showCUPSInfo", true);
		}
		if(data.CUPS_Support_Price3__c && data.CUPS_Discount_Percent3__c && data.CUPS_Start_Date3__c && data.CUPS_End_Date3__c) {
			component.set("v.showCUPSInfo3", true);
			component.set("v.showCUPSInfo", true);
		}
		if(data.CUPS_Support_Price3__c && data.CUPS_Discount_Percent4__c && data.CUPS_Start_Date4__c && data.CUPS_End_Date4__c) {
			component.set("v.showCUPSInfo4", true);
			component.set("v.showCUPSInfo", true);
		}
		if(data.Competitive_Distributor__c || data.Competitor_Product__c || data.Competitive_Price__c) {
			component.set("v.showCompetitiveInfo", true);
            console.log('SHOW COMPETITIVE PJ PJ PJ ');
		}
        console.log('SHOW COMPETITIVE? :::::  ',component.get("v.showCompetitiveInfo"));
	}
})