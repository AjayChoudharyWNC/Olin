({
	doInit : function(component, event, helper) {
		component.set("v.yearNow", new Date().getFullYear() + '');
		console.log('Init controller: ', component.get("v.yearNow"), component.get("v.currentYear"), component.get("v.yearNow") === component.get("v.currentYear"), component.get("v.yearNow") == component.get("v.currentYear"));
		component.set("v.allowNew", component.get("v.yearNow") === component.get("v.currentYear"));
		helper.init(component, event, helper);
	},

	catchConsumptionAmount : function(component, event, helper) {
		helper.recalculateValue(component, event, helper, 'Share_Amount__c', event.getParam('jsonParam'));
		
	},

	catchConsumptionPercent : function(component, event, helper) {
		helper.recalculateValue(component, event, helper, 'Share_Percent__c', event.getParam('jsonParam'));
		
	},

	catchConsumption : function(component, event, helper) {
		helper.recalcConsumpChange(component, event, helper, event.getParam("arguments").consumptionField);
	},


	//deprecated - moved unknown to a line item
	catchUkConsumptionPercent : function(component, event, helper) {
		helper.recalculateValue(component, event, helper, 'UnknownPercent__c', event.getParam('jsonParam'));
	},
	
	//deprecated - moved unknown to a line item
	catchUkConsumptionAmount : function(component, event, helper) {
		helper.recalculateValue(component, event, helper, 'UnknownAmount__c', event.getParam('jsonParam'));
	},

	toggleAddMode : function(component, event, helper) {
		component.set("v.addToggle", true);
	},

	cancelStaging : function(component, event, helper) {
		component.set("v.addToggle", false);
	},

	returnDeleted : function(component, event, helper) {
		return component.get("v.deletedRecords");
	},

	deleteLine : function(component, event, helper) {
		var idxVar = event.getSource().get("v.name");
		var currentYr = component.get("v.currentYear");

		var tableRecordsUpdated = component.get("v.totalConsumptionList");
		var yrConsumpRec;
		var deletedRecords = component.get("v.deletedRecords");
		var deletedList;
		tableRecordsUpdated.forEach(
			element => {
				if(component.get("v.currentYear") === element.totalConsumption.Year__c) {
					deletedList = element.lstConsumptionShare.splice(idxVar, 1);
				}
			}
		);

		deletedRecords.push(deletedList[0]);
		console.log(deletedRecords);
		component.set("v.deletedRecords", deletedRecords);
		component.set("v.totalConsumptionList", tableRecordsUpdated);
		
		helper.recalcConsumpChange(component, event, helper, component.get("v.consumptionValue"));
	},

	updateStage :function(component, event, helper) {
		var jsonParam = JSON.parse(event.getParam("jsonParam"));
		component.set("v.entityStageId", jsonParam.id);
		component.set("v.entityStageName", jsonParam.name);
	},


	catchNewVal : function(component, event, helper) {
		var tableRecordsUpdated = component.get("v.totalConsumptionList");		
		console.log("Catch new val running");
		var params = event.getParam("arguments");
		console.log(event, params);

		component.set("v.newObjPush", {consumptionShare : {}});
		component.set("v.newObjPush.consumptionShare", {
			Olin_Produced__c : false,
			Seller_Account_SOW__c : params.entityStageId,
			Consumption_ShareOfWallet__c : params.parentId,
			Annual_Actuals_Updated__c : false,
			Share_Amount__c : 0,
			Share_Percent__c : 0,
			Seller_Account_SOW__r : {
				Name : params.entityStageName, //component.get("v.entityStageName"),
				Id : params.entityStageId //component.get("v.entityStageId")
			}
		});
		
		if(params.entityStageId) {
			var yrConsumpRec;
			tableRecordsUpdated.forEach(
				element => {
					if(component.get("v.currentYear") === element.totalConsumption.Year__c) {
						element.lstConsumptionShare.push(component.get("v.newObjPush"));
					}
				}
			);
			//tableRecordsUpdated.push(component.get("v.newObjPush"));
			component.set("v.totalConsumptionList", tableRecordsUpdated);
			component.set("v.newObjPush");
			component.set("v.newObjPush",{"consumptionShare" : {}, isSelected : false});
		}
	}
})