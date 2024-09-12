({
    onInit: function (component, event, helper) {
        var list = component.get("v.quoteList");
        var quoteLineIds = [];
        component.find("btnClone").set("v.disabled", false);
        component.find("btnCloneSubmit").set("v.disabled", false);
        list.forEach(function (el) {
            if (quoteLineIds.indexOf(el.Id) < 0) {
                quoteLineIds.push(el.Id);
            }
            /*if(fixedListId.indexOf(el.SBQQ__Quote__c) < 0) {
                fixedListId.push(el.SBQQ__Quote__c);
                fixedList.push({
                    isSelected : true,
                    quote : el.SBQQ__Quote__r,
                    lines : []
                });
            }
            var findIdx = fixedListId.indexOf(el.SBQQ__Quote__c);
            fixedList[findIdx].lines.push(el);*/
        });
        //component.set("v.fixedList", fixedList);

        //TKT-272
        var validateQuotes = component.get("c.validateQuotesForCloning");
        validateQuotes.setParams({
            quoteLineIds: quoteLineIds
        });

        validateQuotes.setCallback(this, function (resp) {
            var isValid = resp.getReturnValue();
            console.log("isValid: " + isValid);
            if (isValid) {
                // Proceed with getList call
                var getList = component.get("c.getQuotesForCloning");
                getList.setParams({
                    quoteLineIds: quoteLineIds
                });
                getList.setCallback(this, function (resp) {
                    var fixedList = [];
                    var ret = resp.getReturnValue();
                    ret.forEach(function (quoteLine) {
                        console.log("line: " + JSON.stringify(quoteLine));
                        fixedList.push({
                            isSelected: true,
                            line: quoteLine
                        });
                    });
                    console.log('fixedList: ');
                    console.log(fixedList);
                    component.set("v.fixedList", fixedList);
                    // Validate the quote lines here
                    fixedList = helper.doValidations(fixedList);
                    //Disasble Clone and CloneandSubmit buttons if nothing selected
                    var isSelectedCount = 0;
                    fixedList.forEach(function (itm) {
                        if (itm.isSelected) isSelectedCount++;
                    });
                    console.log(isSelectedCount);
                    if (isSelectedCount == 0) {
                        component.find("btnClone").set("v.disabled", true);
                        component.find("btnCloneSubmit").set("v.disabled", true);
                    }
                });
                $A.enqueueAction(getList);
            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: "Validation Error",
                    message: "Please select all product lines and scale lines before proceeding.",
                    type: "error"
                });
                toastEvent.fire();

                component.find("btnClone").set("v.disabled", true);
                component.find("btnCloneSubmit").set("v.disabled", true);
                console.log("Validation failed...");
            }
        });
        $A.enqueueAction(validateQuotes);
    },

    updateSelect: function (component, event, helper) {
        //console.log(event.target.getAttribute("data-idx"));
        var idx = event.target.getAttribute("data-idx");
        var fixedList = component.get("v.fixedList");
        console.log(fixedList[idx]);
        fixedList[idx].isSelected = !fixedList[idx].hasErrors && !fixedList[idx].isSelected;
        component.set("v.fixedList", fixedList);

        var isSelectedCount = 0;
        fixedList.forEach(function (itm) {
            if (itm.isSelected) isSelectedCount++;
        });
        if (isSelectedCount == 0) {
            component.find("btnClone").set("v.disabled", true);
            component.find("btnCloneSubmit").set("v.disabled", true);
        } else {
            component.find("btnClone").set("v.disabled", false);
            component.find("btnCloneSubmit").set("v.disabled", false);
        }
    },

    doClone: function (component, event, helper) {
        var runClone = component.getEvent("pushClone");
        var sendUp = [];

        var fixedList = component.get("v.fixedList");
        fixedList.forEach(function (itm) {
            if (itm.isSelected) sendUp.push(itm.line.Id);
        });

        runClone.setParams({
            jsonParam: sendUp
        });
        runClone.fire();
        //component.getEvent("pushClose").fire();
    },

    doCloneandSubmit: function (component, event, helper) {
        var runClone = component.getEvent("pushCloneandSubmit");
        var sendUp = [];

        var fixedList = component.get("v.fixedList");
        fixedList.forEach(function (itm) {
            console.log('itm--', itm);
            if (itm.isSelected) sendUp.push(itm.line.Id);
        });

        runClone.setParams({
            jsonParam: sendUp
        });
        runClone.fire();
        //component.getEvent("pushClose").fire();
    },

    close: function (component, event, helper) {
        component.getEvent("pushClose").fire();
    }
})