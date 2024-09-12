({
	onInit : function(component, event, helper) {

		var getApproverName=  component.get("c.getApproverName");
		getApproverName.setParams({
            approvalId : component.get("v.approvalId")
		});
		getApproverName.setCallback(this, function(a){
			component.set("v.approverName", a.getReturnValue());
            var getRecords = component.get("c.getLineFromApproval");
			getRecords.setParams({
				approvalId : component.get("v.approvalId")
			});
			getRecords.setCallback(this, function(a){
				component.set("v.data", a.getReturnValue());
				var getLines = component.get("c.getLinesToApprove");
				getLines.setParams({
					quoteLineId : component.get("v.data").Id
				});
				getLines.setCallback(this, function(a){
					component.set("v.loading", false);
					var lines = a.getReturnValue();
					var surcharges = [];
					var scales = [];
					var discounts = [];
					lines.forEach(function(line) {
						if(line.SBQQ__ProductOption__r && line.SBQQ__ProductOption__r.SBQQ__Feature__r && 
							component.get("v.data").SBQQ__Product__c == line.SBQQ__ProductOption__r.SBQQ__ConfiguredSKU__c) {
							if(line.SBQQ__ProductOption__r.SBQQ__Feature__r.SBQQ__Category__c == 'Discounts') {
								discounts.push(line);
							}
							else if(line.SBQQ__ProductOption__r.SBQQ__Feature__r.SBQQ__Category__c == 'OSS Adders' && line.Product_Level__c =='Scale') {
								scales.push(line);
							}
							else if(line.SBQQ__ProductOption__r.SBQQ__Feature__r.SBQQ__Category__c == 'A La Carte Surcharges') {
								surcharges.push(line);
							}
						}
					});
					console.log(JSON.stringify(scales));
					component.set("v.discounts", discounts);
					component.set("v.scales", scales);
					component.set("v.surcharges", surcharges);
					helper.renderSection(component, event, helper);
				});
				$A.enqueueAction(getLines);
			});
			$A.enqueueAction(getRecords);
		});
		$A.enqueueAction(getApproverName);
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