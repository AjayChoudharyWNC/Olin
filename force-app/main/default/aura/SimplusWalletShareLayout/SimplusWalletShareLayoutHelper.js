({
	init : function(component, event, helper) {
		var action = component.get("c.getConsumptionShares");
		var year = (new Date()).getFullYear().toString();
		component.set("v.originalYear", year);

		action.setParams({
            recordId: component.get("v.recordId")
        });

        action.setCallback(this, function(response) {
			this.handleGetLimitDate(component, event, helper);
			component.set("v.hasNoConsumption", false);
			console.log('RESPONSE INIT 1 >> ', response);
			var state = response.getState();
			console.log('RESPONSE INIT 1 >> ', response.getReturnValue());
			console.log('RESPONSE STATE 1 >> ', state);
            if (state === "SUCCESS") {
				var response = response.getReturnValue();
				console.log('RESPONSE INIT 2 >> ', response);
				console.log("response.lstTotalConsumption >> ", response.lstTotalConsumption);
				if(response.lstTotalConsumption) {
					//01/06/2021 Jose Aguilar (Cipaq)
					//Added these 2 lines to validate the current year against the last Total Consumption's year found
					//So if the last Total consumption found is older than today's year then we use the last year that is found
					//for showing on the component controls
					/*if(year > response.lstYear[response.lstYear.length - 1])
						year = response.lstYear[response.lstYear.length - 1];*/

					response.lstTotalConsumption.forEach(element => {
						if(element.totalConsumption.Year__c == year) {
                        	var consumptionVal = element.totalConsumption.Consumption__c;
                            if(!consumptionVal) {
                                consumptionVal = 0;
                        		element.totalConsumption.Consumption__c = consumptionVal;
                            }
                            console.log('totalConsu ', element.totalConsumption);                             
							component.set("v.totalConsumption", element.totalConsumption);
						}
						component.set("v.record", element.objPurchasedProduct);
					});
				} else {
					component.set("v.hasNoConsumption", true);
				}
				component.set("v.totalConsumptionList", response.lstTotalConsumption);
				if(response.lstYear && response.lstYear.length) {
					console.log('years: ', response.lstYear);
					console.log('first year: ', response.lstYear[0]);
					console.log('last year: ', response.lstYear[response.lstYear.length - 1]);

					component.set("v.years", response.lstYear);
					component.set("v.firstYear", response.lstYear[0]);
					component.set("v.lastYear", response.lstYear[response.lstYear.length - 1]);
				}
				
				component.set("v.currentYear", year);
				component.set("v.nextYear", (parseInt(year) + 1).toString());

				if(response.mapTotal && response.mapTotal[year]) {
					component.set("v.amount", response.mapTotal[year].totalAmount);
					component.set("v.percent", response.mapTotal[year].totalPercent);
					component.set("v.maptotal", response.mapTotal);
				}
            }
			component.set('v.isLoading',false);
        });
        $A.enqueueAction(action);
	},

	handleGetLimitDate : function(component, event, helper) {
		var action = component.get("c.getLimitDate");
        action.setCallback(this, function(response) {
			console.log("allowEdit:: " + response.getReturnValue());
			component.set("v.allowEdit", response.getReturnValue());
		});

		$A.enqueueAction(action);

	},

	handlePrevious : function(component, event, helper) {
		component.set("v.repaint", false);
		component.set("v.totalConsumption");
		var currentYear = component.get("v.currentYear");
		var previous = parseInt(currentYear) - 1;
		var str = previous.toString();
		var firstYearStr = component.get("v.firstYear");
		var firstYear = parseInt(firstYearStr);
		var years = component.get("v.years");
		var total = component.get("v.maptotal");
		var totalConsumption = component.get("v.totalConsumptionList");
		
		if(years.includes(str)) {
			component.set("v.currentYear", str);
			component.set("v.nextYear", (parseInt(str) + 1).toString());
		} else {
			for(var i = previous; i >= firstYear; i--) {
				var updatedYears = i.toString();
				if(years.includes(updatedYears)) {
					component.set("v.currentYear", updatedYears);
					component.set("v.nextYear", (parseInt(updatedYears) + 1).toString());
					str = updatedYears;
					break;
				}
			}
		}
		console.log(">> list ");
		console.log(totalConsumption.length);
		console.log(totalConsumption.length);

		totalConsumption.forEach(element => {
			console.log(element.totalConsumption.Year__c, str);
			if(element.totalConsumption.Year__c == str) {
				console.log("found");
				component.set("v.totalConsumption", element.totalConsumption);
			}
		});

		if(total[str]) {
			component.set("v.amount", total[str].totalAmount);
			component.set("v.percent", total[str].totalPercent);
		}
		
		console.log('PREVIOUS >> ', str);
		component.set("v.repaint", true);

	},

	handleNext : function(component, event, helper) {
		component.set("v.repaint", false);
		component.set("v.totalConsumption");
		var currentYear = component.get("v.currentYear");
		var next = parseInt(currentYear) + 1;
		var str = next.toString();
		var lastYearStr = component.get("v.lastYear");
		var lastYear = parseInt(lastYearStr);
		var years = component.get("v.years");
		var total = component.get("v.maptotal");
		var totalConsumption = component.get("v.totalConsumptionList");

		if(years.includes(str)) {
			component.set("v.currentYear", str);
			component.set("v.nextYear", (parseInt(str) + 1).toString());
		} else {
			for(var i = next; i <= lastYear; i++) {
				var updatedYears = i.toString();
				if(years.includes(updatedYears)) {
					component.set("v.currentYear", updatedYears);
					component.set("v.nextYear", (parseInt(updatedYears) + 1).toString());
					str = updatedYears;
					break;
				}
			}
		}
		console.log(">> list ");
		console.log(totalConsumption.length);
		console.log(totalConsumption.length);

		totalConsumption.forEach(element => {
			console.log(element.totalConsumption.Year__c, str);
			if(element.totalConsumption.Year__c == str) {
				console.log("found");
				component.set("v.totalConsumption", element.totalConsumption);
			}
		});
		
		if(total[str]) {
			component.set("v.amount", total[str].totalAmount);
			component.set("v.percent", total[str].totalPercent);
		}
		console.log('NEXT >> ', str);
		component.set("v.repaint", true);
	},

})