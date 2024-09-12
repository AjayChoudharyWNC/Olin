({
	onInit : function(component, event, helper) {
        var columnDef = component.get("v.columnDef");
        var row = component.get("v.row");
        component.set("v.fieldValue",  row[columnDef.fieldPath]);
        if(columnDef.type == 'reference') {
            var parentObject = row[columnDef.fieldPath.replace('__c', '__r')];
            if(parentObject) {
                component.set("v.isReference", true);
                component.set("v.refrenceValue", parentObject.Name);
            }
        }
        else if(columnDef.type == 'currency') {
            component.set("v.isNumber", true);
        }
        else {
            component.set("v.isString", true);
        }
    }
})