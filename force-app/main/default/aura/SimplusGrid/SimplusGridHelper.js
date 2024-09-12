({
    init: function (component, event, helper) {
        helper.getUserDetails(component, event, helper);
        helper.getTableFieldSet(component, event, helper);

        window.addEventListener('resize', $A.getCallback(function () {
            helper.handleWindowScroll(component, event, helper);
            helper.handleDimensionsUpdate(component, event, helper);
        }));
        window.addEventListener('scroll', $A.getCallback(function () {
            helper.handleWindowScroll(component, event, helper);
        }));
    },

    getTableFieldSet: function (component, event, helper) {
        component.set("v.isLoadingList", true);
        var action = component.get("c.getFieldSet");
        action.setParams({
            sObjectName: component.get("v.sObjectName"),
            fieldSets: component.get("v.fieldSets")
        });
        action.setCallback(this, function (response) {
            console.log('RESPONSE >> ', response.getReturnValue());
            //var fieldSetObj = JSON.parse(response.getReturnValue());
            var fieldSetObj = response.getReturnValue();
            console.log('PJ PJ PJ FIELDSET >> ', fieldSetObj);

            var colFreeze = component.get("v.noOfColumns");
            var leftCols = [], rightCols = [], allCols = [];
            for (var i = 0; i < colFreeze; i += 1) {
                leftCols.push(fieldSetObj.sortingFieldSet[i]);
                allCols.push(fieldSetObj.sortingFieldSet[i]);
            }
            for (var i = colFreeze; i < fieldSetObj.sortingFieldSet.length; i += 1) {
                rightCols.push(fieldSetObj.sortingFieldSet[i]);
                allCols.push(fieldSetObj.sortingFieldSet[i]);
            }

            component.set("v.fieldSetValues", allCols);
            component.set("v.fieldSetValues1", leftCols);
            component.set("v.fieldSetValues2", rightCols);
            component.set("v.pageMax", fieldSetObj.pageMax);
            component.set("v.isBeyond", fieldSetObj.isBeyond);

            component.set("v.sortingOrderResult", fieldSetObj.sortingOrderResult);
            component.set("v.filteringOrderResult", fieldSetObj.filteringOrderResult);
            //Call helper method to fetch the records
            //helper.getTableRows(component, event, helper);
            //
            try {
                console.log(fieldSetObj.lstObject);
                var list = fieldSetObj.lstObject;
            } catch (ex) {
                console.log('Error caught: ' + ex);
                return;
            }
            console.log('LIST >> ', list);
            component.set("v.tableRecords", list);
            component.set("v.tableRecordsUpdated", list);
            component.set("v.hasPendingMassChange", false);
            component.set("v.isLoadingList", false);
            /*var tbList = list;
        var quoteLineIds = [];
        tbList.forEach(function(element) {
            quoteLineIds.push(element.Id);
        });

        var action = component.get("c.retrievedProductListPrice"); 
        action.setParams({
            "quoteLineIds" : quoteLineIds
        });

        action.setCallback(this, function(response){
            console.log('STATE :::: ', response.getState());
            if(response.getState() === 'SUCCESS'){
                var retVal = response.getReturnValue();
                console.log('PJ PJ PJ return value  :: ',JSON.stringify(retVal)); 
                component.set("v.lineProductListPriceMap",retVal )

                window.setTimeout(
                    $A.getCallback(function() {
                        helper.handleDimensionsUpdate(component, event, helper);
                    }), 100
                );
            }else{
                var error = response.getError();
                alert(error[0].message);
            }

        });
        $A.enqueueAction(action);*/

            window.setTimeout(
                $A.getCallback(function () {
                    helper.handleDimensionsUpdate(component, event, helper);
                }), 100
            );
            /*window.setTimeout(
                $A.getCallback(function() {
                    helper.handleDimensionsUpdate(component, event, helper);
                }), 500
            );*/
        })

        $A.enqueueAction(action);


    },

    getTableRows: function (component, event, helper) {
        component.set("v.isLoadingList", true);

        //TKT-277 Start
        var selectionsAllPages = component.get("v.selectionsAllPages") || [];
        var tableRecordsUpdated = component.get("v.tableRecordsUpdated");
        tableRecordsUpdated.forEach(function (itm) {
            if (selectionsAllPages.includes(itm)) {
                itm.util.isSelected = true;
            }
        });
        component.set("v.tableRecordsUpdated", tableRecordsUpdated);
        console.log('tableRecordsUpdated >> ', tableRecordsUpdated);
        console.log('selectionsAllPages >> ', selectionsAllPages);
        //TKT-277 End

        var action = component.get("c.getRecords");
        var fieldSetValues = component.get("v.fieldSetValues");



        var setfieldNames = new Set();
        for (var c = 0, clang = fieldSetValues.length; c < clang; c++) {
            if (!setfieldNames.has(fieldSetValues[c].fieldName)) {
                setfieldNames.add(fieldSetValues[c].fieldName);
                if (fieldSetValues[c].fieldType == 'REFERENCE') {
                    if (fieldSetValues[c].fieldName.indexOf('__c') == -1 && fieldSetValues[c].fieldName.indexOf('Id') != -1) {
                        setfieldNames.add(fieldSetValues[c].fieldName.substring(0, fieldSetValues[c].fieldName.indexOf('Id')) + '.Name');
                    }
                    else if (fieldSetValues[c].fieldName.indexOf('__c') != -1) {
                        setfieldNames.add(fieldSetValues[c].fieldName.substring(0, fieldSetValues[c].fieldName.indexOf('__c')) + '__r.Name');
                    }
                }
            }
        }
        var arrfieldNames = [];
        setfieldNames.forEach(v => arrfieldNames.push(v));
        action.setParams({
            sObjectName: component.get("v.sObjectName"),
            fieldNameJson: JSON.stringify(arrfieldNames),
            sortingOrderResult: component.get("v.sortingOrderResult"),
            filteringOrderResult: component.get("v.filteringOrderResult"),
            page: component.get("v.page")
        });
        action.setCallback(this, function (response) {
            try {
                var list = JSON.parse(response.getReturnValue());
            } catch (ex) {
                console.log('Error caught: ' + ex);
                return;
            }
            console.log('LIST >> ', list);
            component.set("v.tableRecords", list);
            component.set("v.tableRecordsUpdated", list);
            component.set("v.hasPendingMassChange", false);
            component.set("v.isLoadingList", false);
            /*var tbList = list;
        var quoteLineIds = [];
        tbList.forEach(function(element) {
            quoteLineIds.push(element.Id);
        });

        var action = component.get("c.retrievedProductListPrice"); 
        action.setParams({
            "quoteLineIds" : quoteLineIds
        });

        action.setCallback(this, function(response){
            console.log('STATE :::: ', response.getState());
            if(response.getState() === 'SUCCESS'){
                var retVal = response.getReturnValue();
                console.log('PJ PJ PJ return value  :: ',JSON.stringify(retVal)); 
                component.set("v.lineProductListPriceMap",retVal )

                window.setTimeout(
                    $A.getCallback(function() {
                        helper.handleDimensionsUpdate(component, event, helper);
                    }), 100
                );
            }else{
                var error = response.getError();
                alert(error[0].message);
            }

        });
        $A.enqueueAction(action);*/
            window.setTimeout(
                $A.getCallback(function () {
                    helper.handleDimensionsUpdate(component, event, helper);
                }), 50
            );

        })
        $A.enqueueAction(action);

    },

    refreshList: function (component) {
        var getSort = component.get("c.toggle");
        getSort.setParams({
            sObjectName: component.get("v.sObjectName"),
            mainListSource: component.get("v.mainListSource"),
            page: 1
        });
        getSort.setCallback(this, function (a) {
            var returnValue = a.getReturnValue();
            console.log("refresh From refList");
            component.set("v.tableRecords", returnValue.lstObject);
            component.set("v.pageMax", returnValue.pageMax);
            component.set("v.isBeyond", returnValue.isBeyond);
            component.set("v.hasPendingMassChange", false);
            component.set("v.isLoadingList", false);
        });
        $A.enqueueAction(getSort);
    },

    handleDimensionsUpdate: function (component, event, helper) {
        try {

            var leftFloaterWidth = document.getElementById("grid_fixedColumns").getBoundingClientRect().width,
                leftColumns = document.getElementsByClassName("grid_leftTh"),
                leftColsFloat = document.getElementsByClassName("grid_leftThFloat"),

                rightColumn = document.getElementsByClassName("grid_rightColumn"),
                rightColumnFloat = document.getElementsByClassName("grid_rightColumnFloat"),

                grid_fixedColumnsTableFloating = document.getElementById("grid_fixedColumnsTableFloating"),
                grid_rightTableFloatContainer = document.getElementById("grid_rightTableFloatContainer"),
                grid_rightTableFloat = document.getElementById("grid_rightTableFloat"),
                grid_floatersContainers = document.getElementById("grid_floatersContainers"),
                grid_floatersPositioner = document.getElementById("grid_floatersPositioner"),
                grid_fullTableContainer = document.getElementById("grid_fullTableContainer"),
                grid_rightTable = document.getElementById("grid_rightTable");

            if (grid_fixedColumnsTableFloating && leftFloaterWidth) grid_fixedColumnsTableFloating.style.width = (leftFloaterWidth - 11) + "px";

            if (grid_fullTableContainer) {
                if (grid_rightTableFloatContainer && leftFloaterWidth) grid_rightTableFloatContainer.style.width = (grid_fullTableContainer.getBoundingClientRect().width - leftFloaterWidth + 11) + "px)";
                if (grid_floatersContainers) grid_floatersContainers.style.width = (grid_fullTableContainer.getBoundingClientRect().width) + "px";
                if (grid_floatersPositioner) grid_floatersPositioner.style.width = (grid_fullTableContainer.getBoundingClientRect().width) + "px";
            }

            if (grid_rightTableFloat && grid_rightTable) grid_rightTableFloat.style.width = (grid_rightTable.getBoundingClientRect().width) + "px";

            for (var i = 0; i < leftColumns.length; i += 1) {
                leftColsFloat[i].style.width = (leftColumns[i].getBoundingClientRect().width - 17) + "px";
            }
            for (var i = 0; i < rightColumn.length; i += 1) {
                rightColumnFloat[i].style.width = rightColumn[i].getBoundingClientRect().width + "px";
                rightColumnFloat[i].style.minWidth = rightColumn[i].getBoundingClientRect().width + "px";
            }

        } catch (e) {
            console.log(e);
        }
    },
    handleWindowScroll: function (component, event, helper) {
        //floatersContainers
        var grid_floatersPositioner = document.getElementById("grid_floatersPositioner");
        if (window.innerHeight <= 650 && window.scrollY >= 240) {
            if (grid_floatersPositioner) {
                grid_floatersPositioner.style.top = "135px";
            }
            if (grid_floatersPositioner) {
                grid_floatersPositioner.style.position = "fixed";
            }
        } else {
            if (grid_floatersPositioner) {
                grid_floatersPositioner.style.position = "relative";
            }
        }
    },

    getUserDetails: function (component, event, helper) {
        var action = component.get("c.fetchUser");

        action.setCallback(this, function (response) {
            var userDetail = response.getReturnValue();
            if (userDetail.Mass_Pricing_Lock_Column__c == null || userDetail.Mass_Pricing_Lock_Column__c == '' || userDetail.Mass_Pricing_Lock_Column__c == 0) {
                component.set("v.noOfColumns", 3);
            }
            else {
                component.set("v.noOfColumns", response.getReturnValue().Mass_Pricing_Lock_Column__c);
            }

        });
        $A.enqueueAction(action);
    },

    saveSubmittedUser: function (component, event, helper) {
        var action = component.get("c.saveSubmittedUser");
        var saveList = [];
        saveList = event.getParam("jsonParam");
        action.setParams({
            "saveList": JSON.stringify(saveList)
        })
        $A.enqueueAction(action);
    },
    //TKT-277 Start
    doGetSelections: function (component, event) {
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
        console.log('YONG returnList >> ', returnList);
    },
    //TKT-277 End

    doClone: function (quoteLineIds, doSubmit, cmp) {
        console.log('doSubmit function');
        console.log(quoteLineIds);
        console.log(doSubmit);
        var self = this;
        var runClone = cmp.get("c.cloneRecords");
        runClone.setParams({
            quoteLineIds,
            doSubmit
        });
        runClone.setCallback(self, (a) => {
            console.log(a.getReturnValue());
            var actualResponse = JSON.parse(a.getReturnValue());
            console.log("clone result >>> ");
            console.log(actualResponse);

            // evaluate if each of the quotes has finished cloning...
            if (actualResponse.result == 'success') {
                var showToast = $A.get("e.force:showToast");
                showToast.setParams({
                    'mode': 'dismissable',
                    'title': 'Clone successful!',
                    'message': 'Success',
                    'type': 'success'
                });
                showToast.fire();
                console.log('new quote ids: ');
                console.log(actualResponse.quoteLineIds);

                if (!doSubmit) {
                    $A.get('e.force:refreshView').fire();
                }

                // polling wait
                var pollWait = () => {
                    var checkQuoteCalculationStatus = cmp.get("c.areQuotesCalculated");
                    console.log('quoteLineIds: ' + actualResponse.quoteLineIds);
                    checkQuoteCalculationStatus.setParams({ 'quoteLineIds': actualResponse.quoteLineIds });
                    checkQuoteCalculationStatus.setCallback(self, (resp) => {
                        console.log('response: ' + resp.getReturnValue());
                        var pollWaitResp = JSON.parse(resp.getReturnValue());
                        if (pollWaitResp.result === 'success') {
                            if (pollWaitResp.areAllCalculated) {
                                var clonedQuoteLineIds = JSON.parse(actualResponse.quoteLineIds);
                                var promiseArray = [];
                                clonedQuoteLineIds.forEach((quoteLineId) => {


                                    promiseArray.push(this.doServerCall(cmp, 'c.submitRecordForApproval', { quoteLineId: quoteLineId }));
                                    var combinedPromise = Promise.all(promiseArray);
                                    combinedPromise.then($A.getCallback(function (results) {
                                        if (results) {
                                            $A.get('e.force:refreshView').fire();
                                            $A.get("e.force:closeQuickAction").fire();
                                        }
                                    }))
                                        .catch($A.getCallback(function () {
                                            console.log('Some error has occured');
                                        }));
                                });
                            }
                            else {
                                window.setTimeout(
                                    $A.getCallback(() => {
                                        pollWait();
                                    })
                                    , 500 // wait for 500ms til next poll
                                );
                            }
                        }
                        else {
                            var showToast = $A.get("e.force:showToast");
                            showToast.setParams({
                                'mode': 'sticky',
                                'title': 'Poll wait failed!',
                                'type': 'error',
                                'message': 'error',
                                'messageTemplate': 'Failed cloning due to the following error: {0}',
                                'messageTemplateData': [
                                    pollWaitResp.errormsg
                                ]
                            });
                            showToast.fire();
                        }
                    });
                    $A.enqueueAction(checkQuoteCalculationStatus);
                }

                if (doSubmit) {
                    pollWait();
                }

                // end polling wait

                /*window.setTimeout(
                    $A.getCallback( () => {
                        
                    })
                    ,5000
                );*/
            }
            else if (actualResponse.result == 'error') {
                var showToast = $A.get("e.force:showToast");
                showToast.setParams({
                    'mode': 'sticky',
                    'title': 'Clone failed!',
                    'type': 'error',
                    'message': 'error',
                    'messageTemplate': 'Failed cloning due to the following error: {0}',
                    'messageTemplateData': [
                        actualResponse.errormsg
                    ]
                });
                showToast.fire();

            }
        });

        $A.enqueueAction(runClone);
    },

    doServerCall: function (component, method, params) {
        var promiseInstance = new Promise($A.getCallback(function (resolve, reject) {
            var action = component.get(method);
            if (params) {
                action.setParams(params);
            }
            console.log('****param to controller:' + JSON.stringify(params));
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    resolve(response.getReturnValue());
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    console.error(errors);
                    console.log('>>>SERVER CALL ERROR<<<');
                    reject(response.getError());
                }
            });
            $A.enqueueAction(action);
        }));
        return promiseInstance;
    }
})