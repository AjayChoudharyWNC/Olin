({
	doInit : function(component, event, helper) {
        component.set('v.isLoading',true);
        var action = component.get("c.getFieldSet");
        action.setParams({
            sObjectName: component.get("v.sObjectName"),
            fieldSetName: component.get("v.fieldSetName")
        });

        action.setCallback(this, function(response) {
            console.log('RESPONSE >> ', response.getReturnValue());
            var fieldSetObj = JSON.parse(response.getReturnValue());
            console.log('FIELDSET >> ', fieldSetObj);
            component.set("v.fieldSetValues", fieldSetObj);
            //Call helper method to fetch the records
            //helper.getTableRows(component, event, helper);
        })
        $A.enqueueAction(action);
		helper.init(component, event, helper);
	},
	
	previous : function(component, event, helper) {
		helper.handlePrevious(component, event, helper);
	},

	next : function(component, event, helper) {
		console.log(component.get("v.totalConsumptionList"));
		helper.handleNext(component, event, helper);
	},

	pushEvent : function(component, event, helper) {
		var x = event.getParam('jsonParam');
		component.set("v.years", x);
		console.log('YEARS PUSH EVENT >> ', x);
	},

	catchTotalAmount : function(component, event, helper) {
		var totalAmount = event.getParam('jsonParam');
		var currentYear = component.get("v.currentYear");
		var maptotal = component.get("v.maptotal");
		var consumption = component.get("v.totalConsumption.Consumption__c");
		//var percentFormula = (totalAmount / consumption) * 100;
		
		maptotal[currentYear].totalAmount = totalAmount;
		//maptotal[currentYear].totalPercent = percentFormula;

		console.log('Total Amount >> ', totalAmount);
		component.set("v.amount", totalAmount);
		//component.set("v.percent", percentFormula);
		component.set("v.maptotal", maptotal);
	},

	catchTotalPercent : function(component, event, helper) {
		var totalPercent = event.getParam('jsonParam');
		var currentYear = component.get("v.currentYear");
		var maptotal = component.get("v.maptotal");

		console.log('currentYear: ', currentYear);
		console.log('maptotal: ', maptotal);

		//var consumption = component.get("v.totalConsumption.Consumption__c");
		//var amountFormula = (totalPercent * consumption) / 100;
		
		console.log('Total Percent >> ', totalPercent);
        //console.log('Total Amount >> ', amountFormula);
		maptotal[currentYear].totalPercent = totalPercent;
		//maptotal[currentYear].totalAmount = amountFormula;

		component.set("v.percent", totalPercent);
		//component.set("v.amount", amountFormula);
		component.set("v.maptotal", maptotal);
	},

	onChange : function(component, event, helper) {
		var consumption = component.get("v.totalConsumption.Consumption__c");
		var currentYear = component.get("v.currentYear");
		var percent = component.get("v.percent");
		var maptotal = component.get("v.maptotal");
		var amountFormula = (percent * consumption) / 100;
		var childCmp = component.find('childComp');
		childCmp.catchConsumptionVal(consumption);
		/*if(maptotal[currentYear]) {
			if(isNaN(amountFormula)) maptotal[currentYear].totalAmount = 0;
			else maptotal[currentYear].totalAmount = amountFormula;
		} 
		console.log('ON CHANGE >> ', consumption);
		component.set("v.amount", amountFormula);
		component.set("v.maptotal", maptotal);*/
	},

	updateStage :function(component, event, helper) {
		try {
			var jsonParam = JSON.parse(event.getParam("jsonParam"));
			component.set("v.entityStageId", jsonParam.id);
			component.set("v.entityStageName", jsonParam.name);
		} catch(e) {
			component.set("v.entityStageId");
			component.set("v.entityStageName");
		}
	},

	
	toggleAddMode : function(component, event, helper) {
		component.set("v.addToggle", true);
	},
	cancelStaging : function(component, event, helper) {
		component.set("v.addToggle", false);
	},

	
	addStage : function(component, event, helper) {
		var grid = component.find('childComp');
		console.log(component.get("v.entityStageName"), component.get("v.entityStageId"));
		grid.addNewLine(component.get("v.entityStageName"), component.get("v.entityStageId"));
		component.set("v.addToggle", false);
	},

	triggerSave : function(component, event, helper) {
        component.set('v.isLoading',true);
		var toastEvent = $A.get("e.force:showToast");
		if(component.get("v.percent") > 100) {
            component.set('v.isLoading',false);
			//alert("TODO: Amount > 100");
			toastEvent.setParams({
				"title": "Error",
				"message": "The total amount is greater than 100%"
			});
			toastEvent.fire();
		/*
		} else if(component.get("v.percent") < 100) {
			//alert("TODO: Amount < 100");
			toastEvent.setParams({
				"title": "Error",
				"message": "The total amount is less than 100%"
			});
			toastEvent.fire();
		*/
		} else {
			var tc, csList = [];

			var tcFull = component.get("v.totalConsumptionList");	
			
			tcFull.forEach(element => {
				if(element.totalConsumption.Year__c == component.get("v.currentYear")) {
					tc = element.totalConsumption;
					element.lstConsumptionShare.forEach(cShare => {
						var newCopy = JSON.parse(JSON.stringify(cShare.consumptionShare));
						newCopy.attributes = {
							"type": "Consumption_Share__c"
						};
						delete newCopy.Seller_Account_SOW__r;
						delete newCopy.Name;
						newCopy.Consumption_ShareOfWallet__c = element.totalConsumption.Id;
						csList.push(newCopy);
					})
				}
			});

			var grid = component.find('childComp');
			var dl = grid.getDeleted();
			var dlList = [];
			dl.forEach(el => {
				console.log("delete list iterate >> ", el.consumptionShare.Id);
				if(el.consumptionShare.Id) dlList.push(el.consumptionShare.Id);
			});
			//trigger save
			var getSave = component.get("c.updateRecords");
			getSave.setParams({
				tc : tc,
				csListStr : JSON.stringify(csList),
				dlList : dlList
			});
			getSave.setCallback(this, function(a) {
				//helper.init(component, event, helper, component.get("v.currentYear"));
				//$A.get('e.force:refreshView').fire();
				
				// Raniel commented this line (06-27-2019)
				//window.location.reload(true);
				var state = a.getState();
                if(state === 'SUCCESS'){
                    var result = a.getReturnValue();
                    if(!$A.util.isArray(result)){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "type": "error",
                            "message": result
                        });
                        toastEvent.fire();
                    }
                    else{
                        helper.init(component, event, helper);
                    }
                }
			});

			$A.enqueueAction(getSave);
		}
	},

	createTotalConsumption : function(component, event, helper) {
		console.log("recordId >> ", component.get("v.recordId"));
		var initiateConsumptionForYear = component.get("c.initiateConsumptionForYear");
		initiateConsumptionForYear.setParams({
			prodId : component.get("v.record")
		});
		initiateConsumptionForYear.setCallback(this, function(a) {
			component.set("v.addToggle", false);
			helper.init(component, event, helper);
		});
		$A.enqueueAction(initiateConsumptionForYear);
	},

	toggleCancel : function(component, event, helper) {
		component.set("v.cancelConfirm", true);
	},

	confirmCancel : function(component, event, helper) {
		window.location.reload();
	},

	cancelRefresh : function(component, event, helper) {
		component.set("v.cancelConfirm", false);
	},

})