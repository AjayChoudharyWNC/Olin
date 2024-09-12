({
    onInit: function (component, event, helper) {
        component.find("btnSubmit").set("v.disabled", false);
        component.set("v.isLoading", true);

        var getList = component.get("c.getFieldsAndRecords");
        getList.setParams({
            strObjectApiName: 'SBQQ__QuoteLine__c',
            strfieldSetName: 'MassSubmitApprovals',
            criteriaField: 'SBQQ__Quote__c',
            criteriaFieldValue: component.get("v.recordId")
        });
        getList.setCallback(this, function (resp) {
            var rows = [];
            var returnObject = JSON.parse(resp.getReturnValue());
            if (returnObject) {
                var recordList = [].concat(JSON.parse(returnObject.RECORD_LIST));
                var fieldList = [].concat(JSON.parse(returnObject.FIELD_LIST));

                recordList.forEach(function (quoteLine) {
                    rows.push({
                        isSelected: true,
                        line: quoteLine
                    });
                });
                console.log(rows);
                console.log(fieldList);
                component.set("v.rows", rows);
                component.set("v.columns", fieldList);

                // Validate the rows here
                rows = helper.doValidations(rows, fieldList);
                //Disasble Submit button if nothing selected
                var isSelectedCount = 0;
                rows.forEach(function (itm) {
                    if (itm.isSelected) isSelectedCount++;
                });
                if (isSelectedCount == 0) {
                    component.find("btnSubmit").set("v.disabled", true);
                }
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(getList);
    },


    updateSelect: function (component, event, helper) {
        var idx = event.target.getAttribute("data-idx");
        var rows = component.get("v.rows");
        rows[idx].isSelected = !rows[idx].hasErrors && !rows[idx].isSelected;
        component.set("v.rows", rows);

        var isSelectedCount = 0;
        rows.forEach(function (itm) {
            if (itm.isSelected) isSelectedCount++;
        });
        if (isSelectedCount == 0) {
            component.find("btnSubmit").set("v.disabled", true);
        } else {
            component.find("btnSubmit").set("v.disabled", false);
        }
    },

    handleSubmit: function (component, event, helper) {
        component.set("v.isLoading", true);
        var rows = component.get("v.rows");
        var promiseArray = [];
        var failedQuoteLines = []; // Array to store failed quote lines

        //create array of promise
        rows.forEach((row) => {
            if (row.isSelected) {
                var promise = helper.doServerCall(component, 'c.approveQuoteLine', { quoteLineId: row.line.Id });
                promise
                    .catch(function (error) {
                        // Retry failed item
                        return helper.doServerCall(component, 'c.approveQuoteLine', { quoteLineId: row.line.Id });
                    });
                promiseArray.push(promise);
            }
        });
        var combinedPromise = Promise.allSettled(promiseArray); // Use allSettled instead of all
        combinedPromise.then($A.getCallback(function (results) {
            if (results) {
                component.set("v.failedQuoteLines", failedQuoteLines); // Store failed quote lines in component
                component.set("v.isLoading", false);
                console.log('All promises have been resolved 1');
                $A.get("e.force:closeQuickAction").fire();
            }
        }))
            .finally($A.getCallback(function () {
                console.log('All promises have been resolved 2');
                component.set("v.isLoading", false);
            }));

        //create array of promise
        // rows.forEach((row) => {
        //     if (row.isSelected) {
        //         promiseArray.push(helper.doServerCall(component, 'c.approveQuoteLine', { quoteLineId: row.line.Id }));
        //     }
        // });
        // var combinedPromise = Promise.all(promiseArray);
        // combinedPromise.then($A.getCallback(function (results) {
        //     if (results) {
        //         component.set("v.isLoading", false);
        //         $A.get("e.force:closeQuickAction").fire();
        //     }
        // }))
        //     .catch($A.getCallback(function () {
        //         console.log('Some error has occured');
        //     }))
        //     .finally($A.getCallback(function () {
        //         component.set("v.isLoading", false);
        //     }));
    },

    handleExit: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})