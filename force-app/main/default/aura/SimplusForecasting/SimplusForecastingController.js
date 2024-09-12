({
    doInit : function(component, event, helper) {
        helper.init(component, event, helper);
        window.setInterval(
            $A.getCallback(function() {
                helper.dimensionsUpdate(component, event, helper); 
            })
            , 3000);
    },
    doGridRepaint : function(component, event, helper) {
        var params = event.getParam('arguments');
        console.log("grid repaint", params);
        
        if(params) {
            component.set("v.pageMax", params[0]);
            component.set("v.isBeyond", params[1]);
        }
        
        helper.dimensionsUpdate(component, event, helper);
        window.setTimeout(
            $A.getCallback(function() {
                helper.dimensionsUpdate(component, event, helper);
            }), 100
        );
        window.setTimeout(
            $A.getCallback(function() {
                helper.dimensionsUpdate(component, event, helper);
            }), 500
        );
    },
    colMouseDown : function(component, event, helper) {
        event.preventDefault();
        var tg = event.target;
        while(!tg.getAttribute("data-column-header")) tg = tg.parentNode;
        component.set("v.colDragElement", tg);
        component.set("v.mouseIsDragging", true);
    },
    colMouseDownTable : function(component, event, helper) {
        event.preventDefault();
        component.set("v.mouseIsDraggingFullTable", true);
    },
    
    colMouseDrag : function(component, event, helper) {
        var widthAdj = event.movementX;
        if(component.get("v.mouseIsDragging")) {
            var thElement = component.get("v.colDragElement")
            var currWidth = thElement.offsetWidth;
            thElement.style.width = (currWidth + (widthAdj)) + "px";
            
            var thSib = thElement.nextSibling;
            var currSibWidth = thSib.offsetWidth;
            thSib.style.width = (currSibWidth - (widthAdj)) + "px";
        }
        if(component.get("v.mouseIsDraggingFullTable")) {
            var table = document.getElementById("fixedColumns");
            var tableWidth = table.offsetWidth;
            table.style.width = (tableWidth + (widthAdj)) + "px";
        }
    },
    
    colMouseUp : function(component, event, helper) {
        component.set("v.colDragElement");
        component.set("v.mouseIsDragging", false);
        component.set("v.mouseIsDraggingFullTable", false);
        var table = document.getElementById("fixedColumns");
        var fullTable = document.getElementById("fixedColumnsTable");
        if(fullTable.offsetWidth > table.offsetWidth) {
            table.style.width = (fullTable.offsetWidth + 3) + "px";
        }
    },
    
    toggleAllEditMode : function(component, event, helper) {
        var fldApi = event.getSource().get("v.name");
        var toggleAllEdit = $A.get("e.c:SimplusGrid_ColumnToggleEdit");
        toggleAllEdit.setParams({
            "columnName" : fldApi,
            "editable" : true
        });
        toggleAllEdit.fire();
    },
    
    checkUncheckAll : function(component, event, helper) {
        var tbList = component.get("v.tableRecordsUpdated");
        tbList.forEach(function(element) {
            element.util.isSelected = event.target.checked;
        });
        component.set("v.tableRecordsUpdated", tbList);
    },
    
    checkUncheckLineItem : function(component, event, helper) {
        var tbList = component.get("v.tableRecordsUpdated");
        var isAllSelected = true;
        
        tbList[event.target.name].util.isSelected = event.target.checked;
        tbList.forEach(function(element) {
            if(!element.util.isSelected) {
                isAllSelected = false;
            } 
        });
        
        component.set("v.allItemsChecked", isAllSelected);
        document.getElementById("toggleAll").checked = isAllSelected;
    },
    
    catchMassChange : function(component, event, helper) {
        var fldName = event.getParam("fieldApi");
        var newVal = event.getParam("newValue");
        var formula = event.getParam("formula");
        
        console.log("catchMassChange >> ", formula);
        
        var tbList = component.get("v.tableRecordsUpdated");
        
        tbList.forEach(function(element) {
            if(element.util.isSelected) {
                element.util.hasChange = true;
                if(element.util[fldName]) { 
                    if(formula) element.util[fldName].acceptFormulaChange(fldName, newVal, formula)
                    else element.util[fldName].acceptChange(fldName, newVal);
                }
            }
        });
        component.set("v.hasPendingMassChange", true);
    },
    
    catchCancel : function(component, event, helper) {
        var tbList = component.get("v.tableRecordsUpdated");
        var fldLst = event.getParam("jsonParam");
        tbList.forEach(function(element) {
            if(element.util.isSelected) {
                console.log(">>> ", fldLst);
                console.log(">>>> ", element);
                fldLst.forEach(function(fld) {
                    element.util.hasChange = false;
                    if(element.util[fld] && element.util[fld]) element.util[fld].revertChange();
                })
            }
        });
        component.set("v.hasPendingMassChange", false);
        
    },
    
    catchSave : function(component, event, helper) {
        component.set("v.isLoadingList", true);
        var runSave = component.get("c.saveRecords");
        var saveList = [];
        component.get("v.tableRecordsUpdated").forEach(
            function(itm) {
                if(itm.util.isSelected) {
                    var saveCopy = JSON.parse(JSON.stringify(itm));
                    delete saveCopy.util;
                    saveCopy.sobjectType = component.get("v.sObjectName");
                    console.log("saveCopy >> ", saveCopy);
                    saveList.push(saveCopy);
                }
            }
        );
        console.log("full list >> ", saveList);
        console.log("In save");
        console.log("full list JSON>> ", JSON.stringify(saveList));
        runSave.setParams({
            saveList : JSON.stringify(saveList)
        });
        runSave.setCallback(this, function(a) {
            helper.refreshList(component, event, helper);
        });
        
        $A.enqueueAction(runSave);
    },
    
    refreshPage : function(component, event, helper) {
        helper.refreshList(component, event, helper);
    },
    
    catchClone : function(component, event, helper) {
        component.set("v.isLoadingList", true);
        var runClone = component.get("c.cloneRecords");
        var saveList = [];
        component.get("v.tableRecordsUpdated").forEach(
            function(itm) {
                if(itm.util.isSelected) {
                    var quoteId = itm.SBQQ__Quote__c;
                    console.log("Selected quote: " + quoteId);
                    saveList.push(quoteId);
                }
            }
        );
        console.log("full list >> ", JSON.stringify(saveList));
        runClone.setParams({
            saveList : JSON.stringify(saveList)
        });
        runClone.setCallback(this, function(a) {
            helper.refreshList(component, event, helper);
            console.log("clone result >>> ", a.getReturnValue());
            var showToast = $A.get("e.force:showToast"); 
            showToast.setParams({ 
                'title' : 'Message', 
                'message' : a.getReturnValue() 
            }); 
            showToast.fire(); 
        });
        
        $A.enqueueAction(runClone);
    },
    
    scriptsLoaded : function(component, event, helper) {
        $(document).ready(function() {
            var lastScrollLeft = 0;
            var lastScrollTop = 0;
            $('#scrollableColumns').on('scroll', function () {
                var st = $(this).scrollTop();
                var sl = $(this).scrollLeft();
                if (st != lastScrollTop){
                    lastScrollTop = st;
                    var Right = document.getElementById('fixedColumns');
                    Right.scrollTop = lastScrollTop;
                    
                } else if(sl != lastScrollLeft){
                    lastScrollLeft = sl;
                    $('#child').scrollLeft($(this).scrollLeft());
                }
            });
        } );
    },
    
	fieldChange : function(component, event, helper) {
        var x = 0;
        var freezeColumns = component.get("v.noOfColumns");
        var fieldSetValues = component.get("v.fieldSetValues");
        var fieldSetValues1 = [];
        var fieldSetValues2 = [];
        
        var action = component.get("c.saveUserDetail");
        var settings = component.get('v.selectedSDate')+'-'+component.get('v.selectedSMonth')+'-'+component.get('v.selectedSView')+'-'+component.get('v.displayPrior')+'-'+component.get('v.displayAve')+'-'+component.get('v.displayAlloc');
        debugger;
        action.setParams({
            noOfColumns: component.get("v.noOfColumns"),
            settings: settings
        });
        action.setCallback(this, function(response) {
            console.log('User save response', response.getReturnValue()); 
        });
        $A.enqueueAction(action);
        
        fieldSetValues.forEach(function(element) {
            if(element.showFieldColumn){ // Added by Ajay Choudhary on 30th Jan 2023 -----> Column Show/Hide functionality
                x++;
                if(x <= freezeColumns) {
                    fieldSetValues1.push(element);
                } else {
                    fieldSetValues2.push(element);
                }
            }
        });
        component.set("v.fieldSetValues1", fieldSetValues1);
        component.set("v.fieldSetValues2", fieldSetValues2);
        
        window.setTimeout(
            $A.getCallback(function() {
                helper.dimensionsUpdate(component, event, helper);
            }), 50
        );
        
    },
    
    handleApply : function(component, event, helper) {
        component.set("v.isLoadingList", true);
        helper.getColumns(component, event, helper);
        //helper.buildMonthly(component, event, helper); //-------Commented By Ajay Choudhary on 25th June 2021
        var selectedDate = component.find("startDate").get("v.value");
        var selectedMonth = component.find("months").get("v.value");
        var selectedView = component.find("views").get("v.value");
        var jsonParam = {};
        jsonParam.selectedDate = selectedDate;
        jsonParam.selectedMonth = selectedMonth;
        jsonParam.selectedView = selectedView;
        
        helper.saveSelections(component, helper, selectedDate, selectedMonth);
        
        var pushUpdate = component.getEvent("pushUpdates");
        pushUpdate.setParams({
            "jsonParamType" : JSON.stringify(jsonParam)
        });
        pushUpdate.fire();
        helper.getTableFieldSet(component, event, helper, true);//-----Added by Gaurish(27th Jan 2021)
        helper.dimensionsUpdate(component, event, helper);
        
    },
    
    inputChange : function(component, event, helper) {
        var saveId = event.currentTarget.getAttribute("data-saveid");
        var saveVal = event.currentTarget.value;
        helper.handleInput(component, event, helper, saveId, saveVal);
        helper.dimensionsUpdate(component, event, helper);
    },
    
    handleSave : function(component, event, helper) {
        var tableList = component.get("v.tableRecordsUpdated");
        //set defaults
        var defaultDate = component.get("v.selectedDate");
        var selectedDate = component.find("startDate").get("v.value") ? component.find("startDate").get("v.value") : defaultDate[0];
        var splitDate = selectedDate.split(' ');
        var getYear = parseInt(splitDate[1]);
        var getMonth = helper.getSelectedDates(splitDate[0]);
        if(!component.get("v.activeDisplaySize") && component.get("v.activeDisplaySize") !== "0") component.set("v.activeDisplaySize", 12);
        if(!component.get("v.activeDateMonth")) {
            component.set("v.activeDateMonth", new Date().getMonth() );
            component.set("v.activeDateYear", getYear );
        }
        var monthLoop = JSON.parse(JSON.stringify(component.get("v.activeDateMonth")));
        var yearLoop = JSON.parse(JSON.stringify(component.get("v.activeDateMonth")));
        var saveList = {};
        var forecastPerYear = {};
        
        tableList.forEach(function(el) {
            saveList[el.key] = el.colList,
                forecastPerYear[el.key] = el.forecastsPerYear
        });
        
        var saveItem = {
            monthSet : parseInt(component.get("v.activeDisplaySize")),
            yearStart : getYear,
            monthStart : getMonth,
            saveList : saveList,
            forecastsPerYear : forecastPerYear
        };
        var getSaveFunction = component.get("c.saveRecords");
        console.log('JSON List',JSON.stringify(saveItem));
        getSaveFunction.setParams({
            saveList : JSON.stringify(saveItem)
        });
        getSaveFunction.setCallback(this, function(a) {
            var ret = a.getReturnValue();
            helper.getTableRows(component, event, helper);
        });
        $A.enqueueAction(getSaveFunction);
    },
    
    handleExport : function(component,event, helper) {
        /*******Added By Ajay Choudhary on 11th June 2021 **********Start*********/
        var allDates = component.get('v.selectedDate');
        var selectedDate = component.find("startDate").get("v.value");
        var selectedMonth = component.find("months").get("v.value");
        var selectedView = component.find("views").get("v.value");
        if(selectedView == ''){
			selectedView = 'rep_mgr';
        }
        if(selectedDate == ''){
            selectedDate = allDates[0];
        }
        if(selectedMonth == ''){
            selectedMonth = '12';
        }
        var splitDate = selectedDate.split(' ');
        var getYear = parseInt(splitDate[1]);
        var getMonth = helper.getSelectedDates(splitDate[0]);
        debugger;
        window.open('/apex/ForecastingExtract?stmonth='+getMonth+'&styear='+getYear+'&months='+selectedMonth+'&view='+selectedView+'&showAlloc='+component.get('v.displayAlloc'));
        /*******Added By Ajay Choudhary on 11th June 2021 **********End*********/ 
    },
    
    handleScroll : function(component, event, helper) {
        var floatTable = document.getElementById("rightTableFloat");
        floatTable.style.left = (0 - event.currentTarget.scrollLeft) + "px";
    },
    
    historicalDataView : function(component, event, helper) {
        console.log(event.getSource(), event);
        var key = event.getSource().get("v.name");
        component.set("v.forecastKeyForHistory");
        component.set("v.forecastKeyForHistory", key);
        console.log(component.get("v.tableRecordsUpdated"));
    },
    
    closeHistoryWindow : function(component, event, helper) {
        component.set("v.forecastKeyForHistory");
    },
    prevPage : function(component, event, helper) {
        var page = component.get("v.page")
        if(page > 1) {
            console.log("prev", page);
            component.set("v.page", page-1);
            console.log("preve", component.get("v.page"));
            helper.getTableRows(component,event,helper);
        }
    },
    nextPage : function(component, event, helper) {
        var page = component.get("v.page")
        if(page < component.get("v.pageMax")) {
            console.log("next", page);
            component.set("v.page", page+1);
            console.log("next", component.get("v.page"));
            helper.getTableRows(component,event,helper);
        }
    },
    firstPage : function(component, event, helper) {
        var page = component.get("v.page")
        if(page > 1) {
            console.log("prev", page);
            component.set("v.page", 1);
            console.log("preve", component.get("v.page"));
            helper.getTableRows(component,event,helper);
        }
    },
    lastPage : function(component, event, helper) {
        var page = component.get("v.page")
        if(page < component.get("v.pageMax")) {
            console.log("next", page);
            component.set("v.page", component.get("v.pageMax"));
            console.log("next", component.get("v.page"));
            helper.getTableRows(component,event,helper);
        }
    },
    //Added by Ajay Choudhary on 7th June 2021
    handleTotalAll: function(component,event,helper){
        helper.getRecordsForTotal(component, event, helper);
    },
    //Added by Ajay Choudhary on 7th June 2021
    hideAllTotals : function(component,event,helper){
        component.set('v.showAllTotals', false);
    }
})