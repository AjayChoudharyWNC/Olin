({
    doInit: function (component, event, helper) {
        console.log("Save # 3");
        helper.init(component, event, helper);
    },

    doGridRepaint: function (component, event, helper) {
        var params = event.getParam('arguments');
        console.log("grid repaint", params);
        if (params) {
            component.set("v.pageMax", params[0]);
            component.set("v.isBeyond", params[1]);
        }

        window.setTimeout(
            $A.getCallback(function () {
                helper.handleDimensionsUpdate(component, event, helper);
            }), 100
        );
    },
    onRender: function (component, event, helper) {
    },

    colMouseDown: function (component, event, helper) {
        event.preventDefault();
        var tg = event.target;
        while (!tg.getAttribute("data-column-header")) tg = tg.parentNode;

        if (tg.getAttribute("data-isfloat")) {
            component.set("v.colDragElement", tg);
            component.set("v.colDragElementSub", document.getElementById("col_" + tg.getAttribute("data-idx")));
        } else {
            component.set("v.colDragElement", tg);
            component.set("v.colDragElementSub", document.getElementById("floatcol_" + tg.getAttribute("data-idx")));
        }
        component.set("v.mouseIsDragging", true);
    },

    colMouseDrag: function (component, event, helper) {
        if (component.get("v.mouseIsDragging")) {
            var widthAdj = event.movementX;


            var thElement = component.get("v.colDragElement")
            var currWidth = thElement.offsetWidth;
            thElement.style.width = (currWidth + (widthAdj)) + "px";

            var thSib = thElement.nextSibling;
            var currSibWidth = thSib.offsetWidth;
            thSib.style.width = (currSibWidth - (widthAdj)) + "px";



            var thElementSub = component.get("v.colDragElementSub")
            var currWidthSub = thElementSub.offsetWidth;
            thElementSub.style.width = (currWidthSub + (widthAdj)) + "px";

            var thSibSub = thElementSub.nextSibling;
            var currSibWidthSub = thSibSub.offsetWidth;
            thSibSub.style.width = (currSibWidthSub - (widthAdj)) + "px";

        }
    },

    colMouseUp: function (component, event, helper) {
        component.set("v.colDragElement");
        component.set("v.colDragElementSub");
        component.set("v.mouseIsDragging", false);
    },

    toggleAllEditMode: function (component, event, helper) {
        var fldApi = event.getSource().get("v.name");
        var toggleAllEdit = $A.get("e.c:SimplusGrid_ColumnToggleEdit");
        toggleAllEdit.setParams({
            "columnName": fldApi,
            "editable": true
        });
        toggleAllEdit.fire();
    },

    checkUncheckAll: function (component, event, helper) {
        var tbList = component.get("v.tableRecordsUpdated");
        tbList.forEach(function (element) {
            if (element.QuoteStatus__c != 'Proposal' && element.QuoteStatus__c != 'Quotation') element.util.isSelected = event.target.checked;
        });

        component.set("v.tableRecordsUpdated", tbList);

        console.log("RUNNING RUNNING checkUncheckAll");
    },

    checkUncheckLineItem: function (component, event, helper) {
        var tbList = component.get("v.tableRecordsUpdated");
        tbList[event.target.name].util.isSelected = event.target.checked;

        var isAllSelected = tbList.every((ele) => ele.util.isSelected);
        component.set("v.allItemsChecked", isAllSelected);
        document.getElementById("toggleAll").checked = isAllSelected;
        component.set("v.tableRecordsUpdated", tbList);

        console.log('PJ PJ PJ CHECKED');
    },

    /*catchMassChange : function(component, event, helper) {
        var fldName = event.getParam("fieldApi");
        var newVal = event.getParam("newValue");
        var formula = event.getParam("formula");
        var multiDecision = event.getParam("multiDecision");
        
        
        var tbList = component.get("v.tableRecordsUpdated");
        
        tbList.forEach(function(element) {
            if(element.util.isSelected) {
                element.util.hasChange = true;
                var finalFldName = fldName;
                
                if(fldName.indexOf("||") > -1) {
                    var fieldItms = fldName.split("||");
                    var runDecision = new Function("record",multiDecision);
                    var result = runDecision(element);
                    finalFldName = fieldItms[result];
                    console.log("final >>>", result, fldName);
                }
                
                if(element.util[finalFldName]) { 
                    if(formula) element.util[finalFldName].acceptFormulaChange(finalFldName, newVal, formula)
                    else element.util[finalFldName].acceptChange(finalFldName, newVal);
                }
            }
        });
        component.set("v.hasPendingMassChange", true);
        window.setTimeout(
            $A.getCallback(function() {
                helper.handleDimensionsUpdate(component, event, helper);
            }), 100
        );
    },*/

    clearCellValidationsOnRow: function (component, event, helper) {
        var recordId = event.getParam("Id");
        var actionType = event.getParam("type");
        console.log('clearCellValidationsOnRow');
        console.log(recordId);
        console.log(actionType);
        if (actionType === "clear") {
            console.log("clearing validations on cells for record id: " + recordId);

            component.get("v.tableRecordsUpdated").forEach(function (element) {
                if (element.Id === recordId) {
                    element.util["New_Price_Start_Date__c"].clearCellValidations();
                    element.util["New_Price_Firm_Date__c"].clearCellValidations();
                    return;
                }
            });
        }
        else if (actionType === "unlock" || actionType === "lock") {
            var isCellUnlocked = actionType === "unlock";
            console.log("locked? " + isCellUnlocked + " cells for this record id: " + recordId);

            component.get("v.tableRecordsUpdated").forEach(function (element) {
                if (element.Id === recordId) {
                    element.util["New_Delivered_Price__c"].toggleCellLock(isCellUnlocked);
                    element.util["New_Price_Start_Date__c"].toggleCellLock(isCellUnlocked);
                    element.util["New_Price_Firm_Date__c"].toggleCellLock(isCellUnlocked);
                    return;
                }
            });
        }
    },

    onInlineEdit: function (component, event, helper) {
        var recordId = event.getParam("recordId");
        var field = event.getParam("field");
        var value = event.getParam("value");
        var hasWarnings = event.getParam("hasWarnings");

        var inlineEditRecords = component.get("v.inlineEditRecords");

        console.log('PJ PJ PJ onInlineEdit');

        var record = inlineEditRecords[recordId];
        if (!record) {
            record = {
                sobjectType: "SBQQ__QuoteLine__c",
                Id: recordId
            }
        }
        record[field] = value;
        // record["MarketingApprovalRequired__c"] = hasWarnings;

        inlineEditRecords[recordId] = record;
        console.dir(inlineEditRecords);
        component.set("v.inlineEditRecords", inlineEditRecords);

        component.get("v.tableRecordsUpdated").forEach(function (element) {
            if (element.Id === recordId) {
                element.util[field].setPendingInlineEdit(true);
                return;
            }
        });

        component.set("v.hasPendingInlineChanges", true);
        component.find("controlFields").set("v.isDisabled", true);
    },

    commitInlineEdit: function (cmp, evt, hlp) {
        cmp.find("saveInlineBtn").set("v.disabled", true);
        cmp.set("v.isLoadingList", true);

        var updateRecordAction = cmp.get("c.saveInlineEditRecords");
        console.log('PJ PJ PJ commitInlineEdit');
        updateRecordAction.setParams({
            "quoteLineMap": cmp.get('v.inlineEditRecords'),
            "priceStartDate": null,
            "priceEndDate": null
        });
        updateRecordAction.setCallback(this, function (ret) {
            if (ret.getReturnValue() !== 'Updates successfully saved.') {
                var showToast = $A.get("e.force:showToast");
                showToast.setParams({
                    'mode': 'sticky',
                    'title': 'Error',
                    'type': 'error',
                    'message': ret.getReturnValue()
                });
                showToast.fire();
                cmp.set("v.isLoadingList", false);
            }
            else {
                var showToast = $A.get("e.force:showToast");
                showToast.setParams({
                    'title': 'Success',
                    'type': 'success',
                    'message': 'Updates successfully saved.'
                });
                showToast.fire();
                //$A.get('e.force:refreshView').fire();
                Object.keys(cmp.get('v.inlineEditRecords')).forEach((key) => {
                    cmp.get("v.tableRecordsUpdated").forEach(function (element) {
                        if (element.Id === key) {
                            element.util["New_Delivered_Price__c"].setPendingInlineEdit(false);
                            element.util["New_Price_Start_Date__c"].setPendingInlineEdit(false);
                            element.util["New_Price_Firm_Date__c"].setPendingInlineEdit(false);
                            return;
                        }
                    });
                });

                cmp.set("v.inlineEditRecords", {});
                cmp.set("v.hasPendingInlineChanges", false);
                cmp.find("controlFields").set("v.isDisabled", false);
                cmp.set("v.isLoadingList", false);
            }
        });
        $A.enqueueAction(updateRecordAction);
    },

    cancelInlineEdit: function (cmp, evt, hlp) {
        var inlineEditRecords = cmp.get("v.inlineEditRecords");

        for (const [key, value] of Object.entries(inlineEditRecords)) {
            //console.log(`${key}: ${value}`);
            cmp.get("v.tableRecordsUpdated").forEach(function (element) {

                if (element.Id === key) {
                    element.util["New_Delivered_Price__c"].revertChange();
                    element.util["New_Price_Start_Date__c"].revertChange();
                    element.util["New_Price_Firm_Date__c"].revertChange();
                    //element.util["End_Use_Customer__c"].revertChange();
                    //element.util["Support_Price__c"].revertChange();
                    //element.util["Support_Discount__c"].revertChange();
                    element.util["New_Competitive_Manufacturer__c"].revertChange();
                    element.util["New_Competitive_Price__c"].revertChange();
                    element.util["New_Competitor_Product__c"].revertChange();
                    element.util["New_Competitor__c"].revertChange();
                    element.util["New_CUPS_Support_Price__c"].revertChange();
                    element.util["New_CUPS_Start_Date__c"].revertChange();
                    element.util["New_CUPS_End_Date__c"].revertChange();
                    element.util["New_CUPS_Support_Price2__c"].revertChange();
                    element.util["New_CUPS_Start_Date2__c"].revertChange();
                    element.util["New_CUPS_End_Date2__c"].revertChange();
                    element.util["New_CUPS_Support_Price3__c"].revertChange();
                    element.util["New_CUPS_Start_Date3__c"].revertChange();
                    element.util["New_CUPS_End_Date3__c"].revertChange();
                    element.util["New_CUPS_Support_Price4__c"].revertChange();
                    element.util["New_CUPS_Start_Date4__c"].revertChange();
                    element.util["New_CUPS_End_Date4__c"].revertChange();
                    return;
                }
            });
        }

        cmp.set("v.inlineEditRecords", {});
        cmp.set("v.hasPendingInlineChanges", false);
        cmp.find("controlFields").set("v.isDisabled", false);
    },

    catchMassChange: function (component, event, helper) {
        var priceChangeBehavior = event.getParam("priceChangeBehavior");
        var priceAdjustment = Number(event.getParam("priceAdjustment"));
        var priceStartDate = event.getParam("priceStartDate");
        var priceEndDate = event.getParam("priceEndDate");

        component.set('v.priceAdjustment', event.getParam("priceAdjustment"));
        component.set('v.priceStartDate', priceStartDate);
        component.set('v.priceEndDate', priceEndDate);

        //helper.refreshList(component);
        console.log("event details: " + JSON.stringify({
            priceChangeBehavior,
            priceAdjustment,
            priceStartDate,
            priceEndDate
        }));
        //$A.enqueueAction(action1);
        console.log('PJ PJ PJ v.inlineEditRecords ::: ', component.get('v.inlineEditRecords'));
        //console.log('PJ PJ PJ v.lineProductListPrice ::: ',JSON.stringify(component.get('v.lineProductListPriceMap')));

        //var linePLPMap = component.get('v.lineProductListPriceMap');
        var tbList = component.get("v.tableRecordsUpdated");
        var quoteLineIds = [];
        tbList.forEach(function (element) {
            quoteLineIds.push(element.Id);
        });

        var action = component.get("c.retrievedProductListPrice");
        action.setParams({
            "quoteLineIds": quoteLineIds,
            "priceStartDate": priceStartDate,
            "priceEndDate": priceEndDate
        });

        action.setCallback(this, function (response) {
            console.log('STATE :::: ', response.getState());
            if (response.getState() === 'SUCCESS') {
                var retVal = response.getReturnValue();
                console.log('PJ PJ PJ return value  :: ', JSON.stringify(retVal));
                component.set("v.lineProductListPriceMap", retVal)
                tbList.forEach(function (element) {
                    if (element.util.isSelected) {
                        console.log('PJ PJ PJ ++++ ', element);
                        element.util.hasChange = true;
                        //console.log('PJ PJ PJ ++++PRICE PRICE ::: ' ,linePLPMap[element.Id]);
                        // Price Adjustment
                        var priceField = element.Price_Entry_Preference__c == "Base Price" ? "New_Base_Price__c" : "New_Delivered_Price__c";
                        var newPrice = isNaN(element.SBQQ__ListPrice__c) ? 0 : element.SBQQ__ListPrice__c;
                        if (priceChangeBehavior === "Set") {
                            newPrice = priceAdjustment;
                        } else if (priceChangeBehavior === "Add") {
                            if (!isNaN(priceAdjustment) || priceAdjustment != 0) {
                                newPrice += priceAdjustment;
                            }
                        } else if (priceChangeBehavior === "Percent") {
                            if (!isNaN(priceAdjustment) || priceAdjustment != 0) {
                                newPrice += (newPrice * priceAdjustment);
                            }
                        }
                        console.log('PJ PJ PJ newPrice  ::: ', newPrice);
                        element.util[priceField].acceptChange(priceField, newPrice);
                        // Dates Adjustment
                        if (priceStartDate) {
                            element.util["New_Price_Start_Date__c"].acceptChange("New_Price_Start_Date__c", priceStartDate);
                        }
                        if (priceEndDate) {
                            element.util["New_Price_Firm_Date__c"].acceptChange("New_Price_Firm_Date__c", priceEndDate);
                        }
                        element.util["New_Price_Start_Date__c"].runFieldValidation();
                        element.util["New_Price_Firm_Date__c"].runFieldValidation();
                    }
                });


                component.set("v.hasPendingMassChange", true);

                window.setTimeout(
                    $A.getCallback(function () {
                        helper.handleDimensionsUpdate(component, event, helper);
                    }), 100
                );
            } else {
                var error = response.getError();
                alert(error[0].message);
            }

        });
        $A.enqueueAction(action);


        /* window.setTimeout(
             $A.getCallback(function() {
             helper.handleDimensionsUpdate(component, event, helper);
             }), 100
         ); */

    },

    catchCancel: function (component, event, helper) {
        var tbList = component.get("v.tableRecordsUpdated");
        var fldLst = event.getParam("jsonParam");
        tbList.forEach(function (element) {
            if (element.util.isSelected) {
                console.log(">>> ", fldLst);
                console.log(">>>> ", element);
                fldLst.forEach(function (fld) {
                    element.util.hasChange = false;
                    if (element.util[fld] && element.util[fld]) element.util[fld].revertChange();
                });
            }
        });
        component.set("v.hasPendingMassChange", false);
        window.setTimeout(
            $A.getCallback(function () {
                helper.handleDimensionsUpdate(component, event, helper);
            }), 100
        );

    },

    catchSave: function (component, event, helper) {

        console.log('catchSave catchSave catchSaveis running');
        component.set("v.isLoadingList", true);


        var saveList = {};
        var newPrice;
        component.get("v.tableRecordsUpdated").forEach(
            function (itm) {
                if (itm.util.isSelected) {
                    console.log('PJ PJ save');
                    console.log('PJ PJ :: ', itm);
                    newPrice = itm.SBQQ__ListPrice__c + Number(component.get('v.priceAdjustment'));
                    console.log('PJ PJ PJ newPrice :::: ', newPrice);
                    //Assign SBQQ__ListPrice__c instead of New_Delivered_Price__c for New_Delivered_Price__c to reflect the update Product List Price - Simplus, July 2023 TKT-266 
                    saveList[itm.Id] = {
                        sObjectType: "SBQQ__QuoteLine__c",
                        Id: itm.Id,
                        New_Delivered_Price__c: newPrice,
                        New_Price_Firm_Date__c: itm.New_Price_Firm_Date__c,
                        New_Price_Start_Date__c: itm.New_Price_Start_Date__c
                    }
                }
            }
        );
        console.log("full list >> ", saveList);
        var runSave = component.get("c.saveInlineEditRecords");
        runSave.setParams({
            quoteLineMap: saveList,
            priceStartDate: component.get('v.priceStartDate'),
            priceEndDate: component.get('v.priceEndDate')
        });
        runSave.setCallback(this, function (a) {
            if (a.getReturnValue()) {
                var showToast = $A.get("e.force:showToast");
                if (a.getReturnValue() === 'Updates successfully saved.') {
                    showToast.setParams({
                        'title': 'Success',
                        'message': a.getReturnValue(),
                        'type': 'success'
                    });
                }
                else {
                    showToast.setParams({
                        'mode': 'sticky',
                        'title': 'An error occured while saving record/s.',
                        'message': a.getReturnValue(),
                        'type': 'error'
                    });
                }
                showToast.fire();
            }
            helper.refreshList(component);
            window.setTimeout(
                $A.getCallback(function () {
                    helper.handleDimensionsUpdate(component, event, helper);
                }), 150
            );
        });

        $A.enqueueAction(runSave);
    },

    refreshPage: function (component, event, helper) {
        helper.refreshList(component);
    },

    catchClone: function (component, event, helper) {
        component.set("v.isLoadingList", true);
        var saveList = event.getParam("jsonParam");
        console.log(saveList);

        component.set('v.cloneStatus', []);
        component.set('v.failedRecords', []);

        helper.doClone(saveList, false, component);
    },

    catchCloneandSubmit: function (component, event, helper) {
        component.set("v.isLoadingList", true);
        var saveList = event.getParam("jsonParam");
        console.log(saveList);
        console.log('copy this!');
        console.log(`SELECT Id, Name, SBQQ__Uncalculated__c, Recalculated__c, Recalculation_Complete__c, Ready_For_Approval__c, ApprovalStatus__c, Customer_Accepted_Date__c, SBQQ__Status__c, SentToSAP__c, Mulesoft_Debug__c FROM SBQQ__Quote__c WHERE SBQQ__Source__c IN ('${saveList.join("','")}')`);

        component.set('v.cloneStatus', []);
        component.set('v.failedRecords', []);

        helper.doClone(saveList, true, component);
    },


    fieldChange: function (component, event, helper) {
        var x = 0;
        var freezeColumns = component.get("v.noOfColumns");
        var fieldSetValues = component.get("v.fieldSetValues");
        var fieldSetValues1 = [];
        var fieldSetValues2 = [];

        var action = component.get("c.saveUserDetail");
        action.setParams({
            noOfColumns: component.get("v.noOfColumns")
        });
        action.setCallback(this, function (response) {
            console.log('User save response', response.getReturnValue());
        });
        $A.enqueueAction(action);

        fieldSetValues.forEach(function (element) {
            x++;
            if (x <= freezeColumns) {
                fieldSetValues1.push(element);
            } else {
                fieldSetValues2.push(element);
            }
        });
        component.set("v.fieldSetValues1", fieldSetValues1);
        component.set("v.fieldSetValues2", fieldSetValues2);

        window.setTimeout(
            $A.getCallback(function () {
                helper.handleDimensionsUpdate(component, event, helper);
            }), 50
        );

    },

    handleScroll: function (component, event, helper) {
        var floatTable = document.getElementById("grid_rightTableFloat");
        if (floatTable) floatTable.style.left = ((0 - event.currentTarget.scrollLeft) + 1) + "px";
    },

    prevPage: function (component, event, helper) {
        var page = component.get("v.page")
        if (page > 1) {
            console.log("prev", page);
            helper.doGetSelections(component, event, helper);
            component.set("v.page", page - 1);
            console.log("preve", component.get("v.page"));
            helper.getTableRows(component, event, helper);
        }
    },
    nextPage: function (component, event, helper) {
        var page = component.get("v.page")
        if (page < component.get("v.pageMax")) {
            console.log("next", page);
            helper.doGetSelections(component, event, helper);
            component.set("v.page", page + 1);
            console.log("next", component.get("v.page"));
            helper.getTableRows(component, event, helper);
        }
    },

    firstPage: function (component, event, helper) {
        var page = component.get("v.page")
        if (page > 1) {
            console.log("prev", page);
            helper.doGetSelections(component, event, helper);
            component.set("v.page", 1);
            console.log("preve", component.get("v.page"));
            helper.getTableRows(component, event, helper);
        }
    },
    lastPage: function (component, event, helper) {
        var page = component.get("v.page")
        if (page < component.get("v.pageMax")) {
            console.log("next", page);
            helper.doGetSelections(component, event, helper);
            component.set("v.page", component.get("v.pageMax"));
            console.log("next", component.get("v.page"));
            helper.getTableRows(component, event, helper);
        }
    },
    doGetSelections: function (component, event, helper) {
        // var returnList = [];
        // var quoteSet = [];
        // var iterateList = component.get("v.tableRecordsUpdated");
        // iterateList.forEach(function(itm) {
        //     if(itm.util.isSelected) {
        //         //console.log(itm.SBQQ__Quote__r);
        //         returnList.push(itm);
        //         //quoteSet.push(itm.SBQQ__Quote__c)
        //     }
        // });
        // console.log(returnList);
        // component.set("v.selections", returnList);

        //TKT-277 Start
        var returnList = component.get("v.selectionsAllPages") || [];
        var iterateList = component.get("v.tableRecordsUpdated");
        iterateList.forEach(function (itm) {
            if (itm.util.isSelected && !returnList.includes(itm)) {
                returnList.push(itm);
            } else if (!itm.util.isSelected && returnList.includes(itm)) {
                returnList = returnList.filter(function (item) {
                    return item !== itm;
                });
            }
        });
        component.set("v.selectionsAllPages", returnList);
        component.set("v.selections", returnList);
        //TKT-277 End
    },
    closeClone: function (component, event, helper) {
        component.set("v.selections");
    }
})