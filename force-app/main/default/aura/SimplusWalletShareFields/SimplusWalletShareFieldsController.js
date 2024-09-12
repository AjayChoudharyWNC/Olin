({
	doInit : function(component, event, helper) {
		helper.init(component, event, helper);
	},

	fieldChange : function(component, event, helper) {
		var record = {};
		var field = component.get("v.field");
		console.log("field onchang e>>>", field);
		var consumptionVal = component.get("v.consumptionValue");
		console.log('Consumption Value >> ', consumptionVal);
		record[field.name] = component.get("v.cellValue");
		
		if(field.name == 'Share_Amount__c') {
			record['Share_Percent__c'] = (record['Share_Amount__c'] / consumptionVal) * 100;
		} else if(field.name == 'Share_Percent__c') {
            record['Share_Amount__c'] = (record['Share_Percent__c'] * consumptionVal) / 100;
		} 		
		else if(field.name == 'UnknownAmount__c') {
			record['UnknownPercent__c'] = (record['UnknownAmount__c'] / consumptionVal) * 100;
		} 
        else if(field.name == 'UnknownPercent__c') {
			record['UnknownAmount__c'] = (record['UnknownPercent__c'] * consumptionVal) / 100;
		}
        
        //Added 9-27-2021 by Jimmy Daresta to handle empty field.
        if(field.name == 'Contact_Expiration_Date__c') 
        {      
            if(record['Contact_Expiration_Date__c'].replace(/\s/g, '') == '') 
            {
              component.set("v.record." + field.name, null);
            }
            else
            {
                var currentDate = Date.parse(component.get("v.cellValue").replace(/(^|-)0+/g, "$1"));
                if (isNaN(currentDate))
                {
                    component.set("v.record." + field.name, null);
                    component.set("v.cellValue", null);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error Message',
                        message:'Invalid Contract Expiration Date. Please enter a valid date.',
                        messageTemplate: 'Invalid Contract Expiration Date Format. Please use format mm/dd/yy, mm/dd/yyyy, mm-dd-yy, mm-dd-yyyy or yyyy-mm-dd.',
                        duration:'8000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                }
                else
                {
                    var newDate = new Date(currentDate);
                    var month = (1 + newDate.getMonth());
                    var day = newDate.getDate().toString();
                    var year = newDate.getFullYear();
                    
                    component.set("v.cellValue",newDate.toISOString());
                    component.set("v.record." + field.name, year + '-' + month + '-' + day);
                }
            }
        }
        else
        {
            component.set("v.record." + field.name, component.get("v.cellValue"));
        }


        //component.set("v.record." + field.name, component.get("v.cellValue"));
        if( !component.get("v.hasPendingMassChange") ) {
            record.Id = component.get("v.record.Id");
            console.log('RECORD >> ', record);
            if(field.name == 'Share_Amount__c' || field.name == 'UnknownAmount__c') {
                var pushUp = component.getEvent("pushConsumptionAmount");
                pushUp.setParams({
                    jsonParam : [record]
                });
                pushUp.fire();
            } else if(field.name == 'Share_Percent__c' || field.name == 'UnknownPercent__c') {
                var pushUpPercent = component.getEvent("pushConsumptionPercent");
                pushUpPercent.setParams({
                    jsonParam : [record]
                });
                pushUpPercent.fire();
            }
        }
	},

	disableEdit : function(component, event, helper) {
		component.set("v.editToggle", false);
	},

	fieldKeyPress : function(component, event, helper) {
		console.log(event);
	},

	toggleEdit : function(component, event, helper) {
		if(component.get("v.isEditable")) component.set("v.editToggle", true);
	},

	revertValue : function(component, event, helper) {
		helper.revertChange(component);
	},

})