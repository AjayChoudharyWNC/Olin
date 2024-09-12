({
	init : function(component, event, helper) {
        //helper.getTableFieldSet(component, event, helper);
    },

    getTableFieldSet : function(component, event, helper) {
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
    },

    getTableRows : function(component, event, helper){
        var action = component.get("c.getRecords");
        var fieldSetValues = component.get("v.fieldSetValues");
        var setfieldNames = new Set();
        for(var c=0, clang=fieldSetValues.length; c<clang; c++){             
            if(!setfieldNames.has(fieldSetValues[c].name)) {                 
                setfieldNames.add(fieldSetValues[c].name);                   
                if(fieldSetValues[c].type == 'REFERENCE') {                     
                    if(fieldSetValues[c].name.indexOf('__c') == -1) {                     	
                        setfieldNames.add(fieldSetValues[c].name.substring(0, fieldSetValues[c].name.indexOf('Id')) + '.Name');                          
                    }                     
                    else {                     	
                        setfieldNames.add(fieldSetValues[c].name.substring(0, fieldSetValues[c].name.indexOf('__c')) + '__r.Name');                              
                    }                 
                }             
            }         
        }         
        var arrfieldNames = [];         
        setfieldNames.forEach(v => arrfieldNames.push(v));
        console.log('FIELDS >> ', arrfieldNames);
        action.setParams({
            sObjectName: component.get("v.sObjectName"),
            parentRecordId: component.get("v.recordId"),
            fieldNameJson: JSON.stringify(arrfieldNames)
        });
        action.setCallback(this, function(response) {
            console.log('RESPONSE 2 >> ', response.getReturnValue());
            var list = JSON.parse(response.getReturnValue());
            console.log('LIST >> ', list);
            component.set("v.tableRecords", list);
            component.set("v.tableRecordsUpdated", list);
        })
        $A.enqueueAction(action);
    },

    recalculateValue : function(component, event, helper, fieldSrc, jsonParam) {
		var updatedTotalConsumption = [];
		var total = 0, totalPercent = 0;
		var consumptionShareRec = jsonParam; //event.getParam('jsonParam');
		var currentYr = component.get("v.currentYear");
		var consumption = component.get("v.consumptionValue");
        var tbList = component.get("v.totalConsumptionList");
        var isPercent = (fieldSrc == 'Share_Percent__c');
        

		tbList.forEach(element => {
            if(currentYr == element.totalConsumption.Year__c) {
                var consump = {};
                consump.totalConsumption = element.totalConsumption;
                console.log('% after unknowns >> ', totalPercent);
                var unknownIndex;
                var ukItem;
                var shareIdx = 0;
                element.lstConsumptionShare.forEach(elementShare => {
                    console.log("elementShare >> ", elementShare);
                    if(elementShare.consumptionShare.Seller_Account_SOW__r.Name == 'UNKNOWN') {
                        unknownIndex = shareIdx;
                        ukItem = elementShare;
                    } else {
                        if(elementShare.consumptionShare.Id == consumptionShareRec[0].Id) {
                            if(fieldSrc == 'Share_Percent__c' && !isNaN(elementShare.consumptionShare.Share_Percent__c)) {
                                if(elementShare.consumptionShare.Share_Percent__c == ''){
                                    elementShare.consumptionShare.Share_Percent__c = 0;
                                }
                                elementShare.consumptionShare.Share_Amount__c = (elementShare.consumptionShare.Share_Percent__c * consumption) / 100;
                                console.log('amount in iteration >> ', elementShare.consumptionShare.Share_Amount__c);
                            } else if(fieldSrc == 'Share_Amount__c' && !isNaN(elementShare.consumptionShare.Share_Amount__c)) {
                                elementShare.consumptionShare.Share_Percent__c = 0;
                                    if(consumption > 0){
                                    elementShare.consumptionShare.Share_Percent__c = (parseFloat(elementShare.consumptionShare.Share_Amount__c) / consumption) * 100;
                                }                                                                                            
                                if(elementShare.consumptionShare.Share_Percent__c && elementShare.consumptionShare.Share_Percent__c.toFixed){ 
                                    elementShare.consumptionShare.Share_Percent__c = Math.floor(elementShare.consumptionShare.Share_Percent__c);
                                }	
                            } 
                            element.hasError = false;
                        }
                        
                        if(!isNaN(elementShare.consumptionShare.Share_Amount__c) && !isNaN(elementShare.consumptionShare.Share_Percent__c)) {
                            if(typeof elementShare.consumptionShare.Share_Amount__c == 'string') elementShare.consumptionShare.Share_Amount__c = parseFloat(elementShare.consumptionShare.Share_Amount__c);
                            total += elementShare.consumptionShare.Share_Amount__c;
    
                            if(typeof elementShare.consumptionShare.Share_Percent__c == 'string') elementShare.consumptionShare.Share_Percent__c = parseFloat(elementShare.consumptionShare.Share_Percent__c);
                            totalPercent += elementShare.consumptionShare.Share_Percent__c;
                        }

                        console.log('% after iteration >> ', total);
                        console.log('% after iteration >> ', totalPercent);
                    }

                    shareIdx += 1;
                });

                if(ukItem) {
                    //if(total <= consumption) {
                        ukItem.consumptionShare.Share_Amount__c = consumption - total;
                        //total += ukItem.consumptionShare.Share_Amount__c;
                    //} else ukItem.consumptionShare.Share_Amount__c = 0;

                    //if(totalPercent <= 100) {
                        ukItem.consumptionShare.Share_Percent__c = 100 - totalPercent;
                        //totalPercent += ukItem.consumptionShare.Share_Percent__c;
                    //} else ukItem.consumptionShare.Share_Percent__c = 0;
                    
                }


                consump.lstConsumptionShare = element.lstConsumptionShare;
                updatedTotalConsumption.push(consump);
            }
		});
		//console.log('TOTAL PERCENT >> ', totalPercent);
            console.log('% after all vals >> ', totalPercent);
        component.set("v.totalConsumptionList", updatedTotalConsumption);
        
		if(totalPercent > 100) {
            
		}
        var pushUpAmount = component.getEvent("pushTotalAmount");
        pushUpAmount.setParams({
            jsonParam : total
        });
        pushUpAmount.fire();

        var pushUpPercent = component.getEvent("pushTotalPercent");
        pushUpPercent.setParams({
            jsonParam : totalPercent
        });
        pushUpPercent.fire();
    },

    recalcConsumpChange : function(component, event, helper, consumption) {
		var updatedTotalConsumption = [];
		var total = 0, totalPercent = 0;
		//var consumptionShareRec = jsonParam; //event.getParam('jsonParam');
		var currentYr = component.get("v.currentYear");
		var consumption = component.get("v.consumptionValue");
        var tbList = component.get("v.totalConsumptionList");
        
        var index = 0;
		tbList.forEach(element => {
            if(currentYr == element.totalConsumption.Year__c) {
                var consump = {};
                consump.totalConsumption = element.totalConsumption;
                console.log('% after unknowns >> ', totalPercent);
                var unknownIndex;
                var ukItem;
                var shareIdx = 0;
                element.lstConsumptionShare.forEach(elementShare => {
                    if(elementShare.consumptionShare.Seller_Account_SOW__r.Name == 'UNKNOWN') {
                        unknownIndex = shareIdx;
                        ukItem = elementShare;
                    } else {
                        if(!isNaN(elementShare.consumptionShare.Share_Percent__c)) {
                            elementShare.consumptionShare.Share_Amount__c = (elementShare.consumptionShare.Share_Percent__c * consumption) / 100;
                            console.log('amount in recalc iteration >> ', elementShare.consumptionShare.Share_Amount__c);
                        }
                        element.hasError = false;
                        
                        if(!isNaN(elementShare.consumptionShare.Share_Amount__c) && !isNaN(elementShare.consumptionShare.Share_Percent__c)) {
                            if(typeof elementShare.consumptionShare.Share_Amount__c == 'string') elementShare.consumptionShare.Share_Amount__c = parseFloat(elementShare.consumptionShare.Share_Amount__c);
                            total += elementShare.consumptionShare.Share_Amount__c;
    
                            if(typeof elementShare.consumptionShare.Share_Percent__c == 'string') elementShare.consumptionShare.Share_Percent__c = parseFloat(elementShare.consumptionShare.Share_Percent__c);
                            totalPercent += elementShare.consumptionShare.Share_Percent__c;
                        }
                        console.log('% after recalc iteration >> ', total);
                        console.log('% after recalc iteration >> ', totalPercent);
                    }

                    shareIdx += 1;
                });

                if(ukItem) {
                    ukItem.consumptionShare.Share_Amount__c = consumption - total;
                    ukItem.consumptionShare.Share_Percent__c = 100 - totalPercent;
                }


                consump.lstConsumptionShare = element.lstConsumptionShare;
                tbList[index] = consump;
            }
            index += 1;
		});
		//console.log('TOTAL PERCENT >> ', totalPercent);
        console.log('Consump after compute >> ', updatedTotalConsumption);
        component.set("v.totalConsumptionList", tbList);
		if(totalPercent > 100) {
            
		}
        var pushUp = component.getEvent("pushTotalPercent");
        pushUp.setParams({
            jsonParam : totalPercent
        });
        pushUp.fire();
    }
})