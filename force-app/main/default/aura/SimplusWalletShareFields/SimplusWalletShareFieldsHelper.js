({
	init : function(component, event, helper) {
		var record = component.get("v.record");
        var field = component.get("v.field");

        if(typeof field === 'string') field = JSON.parse(field);
        component.set("v.field", field);
        component.set("v.cellValue", record[field.name]);

        if(field.type == 'STRING' || field.type == 'PICKLIST')
            component.set("v.isTextField", true);
        else if(field.type == 'DATE'){
        	component.set("v.isDateField", true);
        }
        else if(field.type == 'DATETIME'){
        	component.set("v.isDateTimeField", true);
        }
        else if(field.type == 'CURRENCY'){
        	component.set("v.isCurrencyField", true);
        }
        else if(field.type == 'NUMBER'){
        	component.set("v.isNumberField", true);
        }
        else if(field.type == 'DOUBLE'){
        	component.set("v.isDoubleField", true);
        }
        else if(field.type == 'PERCENT'){
        	component.set("v.isPercentField", true);
        }
        else if(field.type == 'REFERENCE'){
        	component.set("v.isReferenceField", true);
            var relationShipName = '';
            if(field.name.indexOf('__c') == -1) {
                relationShipName = field.name.substring(0, field.name.indexOf('Id'));
            }
            else {
                relationShipName = field.name.substring(0, field.name.indexOf('__c')) + '__r';
            }
            if(record[relationShipName]) component.set("v.cellLabel", record[relationShipName].Name);
        }
    },
    
    acceptChange : function(component, fieldTarget, newVal) {
        var record = component.get("v.record");

        if(component.get("v.record")[fieldTarget] != newVal) {
            if(!component.get("v.previousValue") && record[fieldTarget]) component.set("v.previousValue", JSON.parse(JSON.stringify(record[fieldTarget])));
            component.set("v.hasUpdate", true);
            component.get("v.record")[fieldTarget] = newVal;
            component.set("v.cellValue", record[fieldTarget]);
        }
    },

    revertChange : function(component) {
        if(component.get("v.hasUpdate")) {
            var record = component.get("v.record");
            var field = component.get("v.field");
            record[field.fieldName] = component.get("v.previousValue");
            component.set("v.previousValue");
            component.set("v.cellValue", record[field.fieldName]);
            component.set("v.hasUpdate", false);
        }
    },
})