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
        if (field.fieldName.includes('__r.')) {
            var fieldNames = field.fieldName.split('.');
            component.set("v.cellValue", record[fieldNames[0]][fieldNames[1]]);
        }
        else {
            component.set("v.cellValue", record[field.fieldName]);
        }
        if(!component.get("v.isLocked")) component.set("v.isEditable", field.fieldEditable);

        if(field.fieldName == 'Name' || field.fieldName.split('.').pop() == 'Name') {
            field.fieldType = 'REFERENCE';
            component.set("v.isReferenceField", true);
            if (field.fieldName.includes('__r.')) {
                var fieldNames = field.fieldName.split('.');
                component.set("v.cellLabel", record[fieldNames[0]][fieldNames[1]]);
                component.set("v.cellValue", record[fieldNames[0].replace('__r','__c')]);
            }
            else {
                component.set("v.cellLabel", record.Name);
                component.set("v.cellValue", record.Id);
            }
            return;
        }

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
            if(record[relationShipName]) component.set("v.cellLabel", record[relationShipName].Name);
            else component.set("v.cellLabel");
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

    acceptFormulaChange : function(component, fieldTarget, newVal, formula) {
        var record = component.get("v.record");

        var func = new Function("record","newVal", formula);
        newVal = func(record, newVal);
		console.log("fieldTarget >> ", fieldTarget);
        
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
    }


})