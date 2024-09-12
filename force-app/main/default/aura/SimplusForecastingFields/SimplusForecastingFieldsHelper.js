({
    init : function(component, event, helper) {
		var record = component.get("v.record");
        var field = component.get("v.field");

        component.set("v.record.util." + field.fieldName + ".acceptChange", function(fieldTarget, newVal){
            helper.acceptChange(component, fieldTarget, newVal);
        });
        
        component.set("v.record.util." + field.fieldName + ".acceptFormulaChange", function(fieldTarget, newVal, formula){
            helper.acceptFormulaChange(component, fieldTarget, newVal, formula);
        });

        component.set("v.record.util." + field.fieldName + ".revertChange", function(){
            helper.revertChange(component);
        });

        component.set("v.cellValue", record.fieldSetValues[field.fieldName]);
        component.set("v.isEditable", field.fieldEditable);

        if(field.fieldType == 'STRING' || field.fieldType == 'PICKLIST')
            component.set("v.isTextField", true);
        else if(field.fieldType == 'DATE'){
        	component.set("v.isDateField", true);
        }
        else if(field.fieldType == 'DATETIME'){
        	component.set("v.isDateTimeField", true);
        }
        else if(field.fieldType == 'CURRENCY'){
        	component.set("v.isCurrencyField", true);
        }
        else if(field.fieldType == 'DOUBLE'){
        	component.set("v.isNumberField", true);
        }
        else if(field.fieldType == 'REFERENCE'){
        	component.set("v.isReferenceField", true);
            var relationShipName = '';
            if(field.fieldName.indexOf('__c') == -1) {
                relationShipName = field.fieldName.substring(0, field.fieldName.indexOf('Id'));
            }
            else {
                relationShipName = field.fieldName.substring(0, field.fieldName.indexOf('__c')) + '__r';
            }
            if(record.fieldSetValues[relationShipName]) component.set("v.cellLabel", record.fieldSetValues[relationShipName].Name);
            else component.set("v.cellLabel");
        }
    },

    acceptChange : function(component, fieldTarget, newVal) {
        var record = component.get("v.record");

        if(component.get("v.record").fieldSetValues[fieldTarget] != newVal) {
            if(!component.get("v.previousValue") && record.fieldSetValues[fieldTarget]) component.set("v.previousValue", JSON.parse(JSON.stringify(record.fieldSetValues[fieldTarget])));
            component.set("v.hasUpdate", true);
            component.get("v.record")[fieldTarget] = newVal;
            component.set("v.cellValue", record.fieldSetValues[fieldTarget]);
        }
    },

    acceptFormulaChange : function(component, fieldTarget, newVal, formula) {
        var record = component.get("v.record");

        var func = new Function("record","newVal", formula);
        newVal = func(record, newVal);

        if(component.get("v.record").fieldSetValues[fieldTarget] != newVal) {
            if(!component.get("v.previousValue") && record.fieldSetValues[fieldTarget]) component.set("v.previousValue", JSON.parse(JSON.stringify(record.fieldSetValues[fieldTarget])));
            component.set("v.hasUpdate", true);
            component.get("v.record")[fieldTarget] = newVal;
            component.set("v.cellValue", record.fieldSetValues[fieldTarget]);
        }
    },

    revertChange : function(component) {
        if(component.get("v.hasUpdate")) {
            var record = component.get("v.record");
            var field = component.get("v.field");
            record.fieldSetValues[field.fieldName] = component.get("v.previousValue");
            component.set("v.previousValue");
            component.set("v.cellValue", record.fieldSetValues[field.fieldName]);
            component.set("v.hasUpdate", false);
        }
    }


})