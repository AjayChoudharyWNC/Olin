({
	onInit : function(component, event, helper) {
        component.find("btnSubmit").set("v.disabled", false);
        component.set("v.isLoading", true);

        var getList = component.get("c.getFieldsAndRecords");
        getList.setParams({
            strObjectApiName : 'SBQQ__QuoteLine__c',
            strfieldSetName : 'MassSubmitApprovals',
            criteriaField : 'SBQQ__Quote__c',
            criteriaFieldValue : component.get("v.recordId")
        });
        getList.setCallback(this, function(resp) {
        	var rows =[];
            var ret = resp.getReturnValue();
            var recordList = JSON.parse(ret.RECORD_LIST);
            var fieldList = JSON.parse(ret.FIELD_LIST);

            recordList.forEach(function(quoteLine) {
                rows.push({
                    isSelected : true,
                    line : quoteLine
                });
            });
            console.log(rows);
            component.set("v.rows", rows);
            component.set("v.columns", fieldList);

            // Validate the rows here
            //rows = helper.doValidations(rows);
            //Disasble Submit button if nothing selected
            var isSelectedCount = 0;
            rows.forEach(function(itm){
                if(itm.isSelected) isSelectedCount++;
            });
            if(isSelectedCount == 0){
                component.find("btnSubmit").set("v.disabled", true);
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(getList);
    },
    
    updateSelect : function(component, event, helper) {
    },
    
    handleSubmit : function(component, event, helper) {

    },
    
    handleExit : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})