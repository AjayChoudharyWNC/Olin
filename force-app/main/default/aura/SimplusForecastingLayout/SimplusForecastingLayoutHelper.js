({
	init : function(component, event, helper) {
        var action = component.get("c.fetchUser");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.userInfo", storeResponse);
                component.set("v.inputField", 'String');
                var forecastingSetting = storeResponse.Forecasting_Settings__c;
                var openSections = [];
                if(forecastingSetting){
                    if(forecastingSetting.includes('SHC')){
                        openSections.push('SHC');
                    }
                    if(forecastingSetting.includes('SORT')){
                        openSections.push('SORT');
                    }
                    if(forecastingSetting.includes('FILTER')){
                        openSections.push('FILTER');
                    }
                }
                component.set('v.activeSections',openSections);
                
            }
        });
        $A.enqueueAction(action);

        helper.getTableFieldSet(component, event, helper);
    },

    getTableFieldSet : function(component, event, helper) {
        var action = component.get("c.getFieldSet");
        action.setParams({
            sObjectName: component.get("v.sObjectName"),
            fieldSets: component.get("v.fieldSets"),
            mainListSource : component.get("v.mainListSource")
        });

        action.setCallback(this, function(response) {
            var fieldSetObj = response.getReturnValue();
            console.log('FIELDSET getTableFieldSet >> ', fieldSetObj);
            component.set("v.columnSorting", fieldSetObj.sortingFieldSet);
            component.set("v.columnFiltering", fieldSetObj.filteringFieldSet);
            component.set("v.currentList", fieldSetObj.sortingWrapper);
            component.set("v.currentListFilter", fieldSetObj.filteringWrapper);
            component.set("v.sortingOrderResult", fieldSetObj.sortingOrderResult);
            component.set("v.filteringOrderResult", fieldSetObj.filteringOrderResult);
            console.log('SORT QUERY >> ', fieldSetObj.sortingOrderResult);
            console.log('FILTER QUERY >> ', fieldSetObj.filteringOrderResult);
            var sortingFieldSet = fieldSetObj.sortingFieldSet;
            var columnConfigs = [];
            sortingFieldSet.forEach(function(e){
                var config = {};
                config.Column_Name__c = e.fieldLabel;
                if(e.columnConfigId)
                    config.Id = e.columnConfigId;
                config.Active__c = e.showFieldColumn;
                config.sObjectName = 'Forecasting_Columns_Config__c';
                columnConfigs.push(config);
            });
            component.set('v.columnConfigs', columnConfigs);
        })
        $A.enqueueAction(action);
    },

    getSortType: function(component, event, helper, selectedValue){
        var filters = component.get('v.columnSorting');
        if(selectedValue != null && selectedValue != '') {
            filters.forEach(function(element) {
                if (element.fieldLabel == selectedValue) {
                    component.set("v.selectedSortColumn", element.fieldName);
                    component.set("v.selectedSortColumnName", element.fieldLabel);
                    console.log(JSON.stringify(element));
                }
            });
        } else {
            component.set("v.selectedSortColumn", "");
        }
        
    },

    getFilterType: function(component, event, helper, selectedValue){
        var filters = component.get('v.columnFiltering');
        if(selectedValue != null && selectedValue != '') {
            filters.forEach(function(element) {
                if (element.fieldLabel == selectedValue) {
                    var selectedFilterType = element.fieldType;
                    component.set("v.selectedFilterColumn", element.fieldName);
                    component.set("v.selectedFilterColumnName", element.fieldLabel);
                    component.set("v.selectedFilterColumnType", selectedFilterType);
                    console.log('selectedFilterType: ' + JSON.stringify(selectedFilterType));
                    if(selectedFilterType == 'STRING') {
                        component.set("v.selectedFilter", component.get("v.filterCompareSTRING"));
                        component.set("v.inputField", "String");
                    } else if(selectedFilterType == 'DOUBLE') {
                        component.set("v.selectedFilter", component.get("v.filterCompareDOUBLE"));
                        component.set("v.inputField", "Double");
                    } else if(selectedFilterType == 'PICKLIST') {
                        component.set("v.selectedFilter", component.get("v.filterComparePICKLIST"));
                        component.set("v.inputField", "String");
                    } else if(selectedFilterType == 'DATE') {
                        component.set("v.selectedFilter", component.get("v.filterCompareDATE"));
                        component.set("v.inputField", "Date");
                    } else if(selectedFilterType == 'DATETIME') {
                        component.set("v.selectedFilter", component.get("v.filterCompareDATETIME"));
                        component.set("v.inputField", "DateTime");
                    } else if(selectedFilterType == 'CURRENCY') {
                        component.set("v.selectedFilter", component.get("v.filterCompareCURRENCY"));
                        component.set("v.inputField", "Currency");
                    } else if(selectedFilterType == 'REFERENCE') {
                        component.set("v.selectedFilter", component.get("v.filterCompareREFERENCE"));
                        component.set("v.inputField", "String");
                    }
                    console.log(JSON.stringify(element));
                }
            });
        } else {
            component.set("v.selectedFilterColumn", "");
        }
        
    },

    sortBy : function(component, event, helper, objWrapper) {
        var objWrapperList = component.get("v.currentList");
        var db = component.find("newtag");
        var action = component.get("c.sortColumns");

        action.setParams({
            objWrapper: JSON.stringify(objWrapper),
            objWrapperList: JSON.stringify(objWrapperList),
            mainListSource : component.get("v.mainListSource")
        });

        action.setCallback(this, function(response) {
            var returnList = response.getReturnValue();
            console.log('RESULT >> ', returnList);

            component.set("v.currentList", returnList.sortingWrapper);
            component.set("v.sortingOrderResult", returnList.sortingOrderResult);
            console.log('SORT BY >> ', returnList.sortingOrderResult);
            //helper.helperRepaintSort(component, event, helper);
        	component.find("forecastGrid").doGridRepaint(returnList.pageMax, returnList.isBeyond);
            component.set("v.isLoadingList", false);
        })
        $A.enqueueAction(action);
        
    },

    filterBy : function(component, event, helper, objWrapper) {
        component.set("v.isLoadingList", true);
        var objWrapperList = component.get("v.currentListFilter");
        var db = component.find("newtag2");
        var action = component.get("c.filterColumns");

        action.setParams({
            objWrapper: JSON.stringify(objWrapper),
            objWrapperList: JSON.stringify(objWrapperList),
            mainListSource : component.get("v.mainListSource")
        });

        action.setCallback(this, function(response) {
            var returnList = response.getReturnValue();
            console.log('RESULT >> ', returnList);

            component.set("v.currentListFilter", returnList.filteringWrapper);
            component.set("v.filteringOrderResult", returnList.filteringOrderResult);
            console.log('FILTER BY >> ', returnList.filteringOrderResult);
            //helper.helperRepaintFilter(component, event, helper);
            component.find("forecastGrid").hideAllTotals();//Added by Ajay Choudhary on 7th June 2021
        	component.find("forecastGrid").doGridRepaint(returnList.pageMax, returnList.isBeyond);
            component.set("v.isLoadingList", false);
        })
        $A.enqueueAction(action);
        
    },

    helperRepaintSort : function(component, event, helper) {
        var getSort = component.get("c.toggle");
        getSort.setParams({
            mainListSource : component.get("v.mainListSource")
        });
        getSort.setCallback(this, function(a) {
            component.set("v.isLoadingList", false);
            var returnValue = a.getReturnValue();
            console.log('SORT RETURN VALUE >> ', returnValue);
            component.set("v.currentList", returnValue.sortingWrapper);
            component.set("v.tableRecords", returnValue.lstObject);
            console.log('SORT helperRepaintSort >> ', returnValue.sortingWrapper);
            helper.buildMonthly(component, event, helper);
        	component.find("forecastGrid").doGridRepaint(returnValue.pageMax, returnValue.isBeyond);
        });
        $A.enqueueAction(getSort);
    },

    helperRepaintFilter : function(component, event, helper) {
        var getFilter = component.get("c.toggle");
        getFilter.setParams({
            mainListSource : component.get("v.mainListSource")
        });
        getFilter.setCallback(this, function(a) {
            component.set("v.isLoadingList", false);
            var returnValue = a.getReturnValue();
            component.set("v.currentListFilter", returnValue.filteringWrapper);
            component.set("v.tableRecords", returnValue.lstObject);
            helper.buildMonthly(component, event, helper);
        	component.find("forecastGrid").doGridRepaint(returnValue.pageMax, returnValue.isBeyond);
        });
        $A.enqueueAction(getFilter);
    },
	
    /*******Added By Ajay Choudhary on 22 June 2021 *******Start****/
    helperRepaintSortAndFilter : function(component, event, helper) {
        var action = component.get("c.toggle");
        action.setParams({
            mainListSource : component.get("v.mainListSource")
        });
        action.setCallback(this, function(a) {
            component.set("v.isLoadingList", false);
            var returnValue = a.getReturnValue();
       console.log("row count :::::: " +returnValue.lstObject.length);
            component.set("v.currentListFilter", returnValue.filteringWrapper);
            component.set("v.tableRecords", returnValue.lstObject);
            helper.buildMonthly(component, event, helper);
            component.find("forecastGrid").hideAllTotals();
        	component.find("forecastGrid").doGridRepaint(returnValue.pageMax, returnValue.isBeyond);
            
        });
        $A.enqueueAction(action);
    },
    
    // Added by Ajay Choudhary on 30th Jan 2023 -----> Column Show/Hide functionality
    updateColumnConfig : function(component, event, helper){
        var action = component.get('c.updateColumnConfigs');
        action.setParams({
            columns : component.get('v.columnConfigs')
        });
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS'){
                console.log('config updated');
                $A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(action);
    },
    /*******Added By Ajay Choudhary on 22 June 2021 *******End****/
    buildMonthly : function(component, event, helper) {
        var fullList = component.get("v.tableRecords");
        var defaultMonth = 12;
        var noOfMonths = component.get("v.selectedMonth") ? component.get("v.selectedMonth") : defaultMonth;
        var noOfMonthsCounter = 0;
        var isValidMonth = true;
        var selectedView = component.get("v.selectedView");
        var currentDate = new Date();
        var currentYear = currentDate.getFullYear();
        var currentMonth = currentDate.getMonth();
        var monthYear = helper.getMonths(currentMonth) + ' ' + currentYear;
        var selectedDate = component.get("v.selectedDate") ? component.get("v.selectedDate") : monthYear;
        var splitDate = selectedDate.split(' ');
        var getYear = parseInt(splitDate[1]);
        var getMonth = helper.getSelectedDates(splitDate[0]);
        //-------Added by Ajay Choudhary-----------Start------------
        var totalSales = [];
        var totalMktg = [];
        var totalPriorYr = [];
        var totalAve = [];
        for(var i = 0; i < noOfMonths; i++) {
            totalSales.push(0.00);
            totalMktg.push(0.00);
            totalPriorYr.push(0.00);
            totalAve.push(0.00);
        }
        //-------Added by Ajay Choudhary--------------End------------
        var total_totalSales=0;var total_totalPrior=0;var total_totalMktg=0;//-------Added by Ajay Choudhary on 25th May 2021
        fullList.forEach(element => {
            element.colList = [];
            var mon = getMonth;
            var yr = getYear;
            var currentYr = yr;
            isValidMonth = true;
            noOfMonthsCounter = 0;
			var mgrMonthTotal = 0.00; //-------Added by Ajay Choudhary on 25th May 2021
            var repMonthTotal = 0.00; //-------Added by Ajay Choudhary on 25th May 2021
            var priorYearTotal = 0.00;//-------Added by Ajay Choudhary on 25th May 2021
            for(var i = 0; i < noOfMonths; i+=1) {
                if(element.forecastsPerYear[yr]) {
                    currentYr = yr;
                } else {
                    currentYr = yr-1;
                    //forecastIds.push(element.fieldSetValues.Id);
                }
                
                if(element.forecastsPerYear[currentYr]) {
                    var mgrMonth = element.forecastsPerYear[currentYr].mgrMonthly[mon];
                    var repMonth = element.forecastsPerYear[currentYr].repMonthly[mon];
                    var priorMonth = element.forecastsPerYear[currentYr].priorMonthly[mon];
           			var aveMonth = element.forecastsPerYear[currentYr].aveMonthly[mon]; //---Added By Ajay Choudhary------
                    var chMatrix = element.forecastsPerYear[currentYr].changeMatrix;
                    var correctMonth = mon+1;
            		priorYearTotal += priorMonth ? parseInt(priorMonth) : 0.00;//-------Added by Ajay Choudhary on 25th May 2021
                    mgrMonthTotal += mgrMonth ? parseInt(mgrMonth) : 0.00; //-------Added by Ajay Choudhary on 25th May 2021
                    repMonthTotal += repMonth ? parseInt(repMonth) : 0.00; //-------Added by Ajay Choudhary on 25th May 2021
                    totalSales[i] += repMonth ? parseInt(repMonth) : 0.00; //-------Added by Ajay Choudhary on 25th May 2021
                    totalMktg[i] += mgrMonth ? parseInt(mgrMonth) : 0.00; //-------Added by Ajay Choudhary on 25th May 2021
                    totalPriorYr[i] += priorMonth ? parseInt(priorMonth) : 0.00; //-------Added by Ajay Choudhary on 25th May 2021
                    totalAve[i] += aveMonth ? parseInt(aveMonth) : 0.00;//-------Added by Ajay Choudhary on 3 June 2021
                    if(selectedView == 'rep') element.colList.push({
                            rep : (repMonth ? parseInt(repMonth) : 0)
                        });
                    else if(selectedView == 'mgr') element.colList.push({
                            mgr : (mgrMonth ? parseInt(mgrMonth) : 0)
                        });
                    else element.colList.push({
                            mgr : (mgrMonth ? parseInt(mgrMonth) : 0),
                            rep : (repMonth ? parseInt(repMonth) : 0)
                        });
                    
                    noOfMonthsCounter++;
                } else {
                    if(selectedView == 'rep') element.colList.push({
                            rep : 0
                        });
                    else if(selectedView == 'mgr') element.colList.push({
                            mgr : 0
                        });
                    else element.colList.push({
                            mgr : 0,
                            rep : 0
                        });
                }

                element.colList[element.colList.length -1].priorMonth = priorMonth ? parseInt(priorMonth) : 0;
				element.colList[element.colList.length -1].aveMonth = aveMonth ? parseInt(aveMonth) : 0; //---Added By Ajay Choudhary------
                element.colList[element.colList.length -1].fieldNameRep = 'Acct_Rep_M' + correctMonth + '__c';
                element.colList[element.colList.length -1].fieldNameMgr = 'Management_M' + correctMonth + '__c';
                element.colList[element.colList.length -1].repIsChanged = parseInt(chMatrix.charAt(mon));
                element.colList[element.colList.length -1].mgrIsChanged = parseInt(chMatrix.charAt(mon+ 12));
                element.colList[element.colList.length -1].identifier = element.key + yr + '/' + (mon + 1);
                element.colList[element.colList.length -1].chMatrix = chMatrix;

                mon += 1;
                if(mon == 12) {
                    mon = 0;
                    yr += 1;
                }
            }
            element.mgrMonthTotal = mgrMonthTotal; //-------Added by Ajay Choudhary on 25th May 2021
            element.repMonthTotal = repMonthTotal; //-------Added by Ajay Choudhary on 25th May 2021
            element.priorYearTotal = priorYearTotal;//-------Added by Ajay Choudhary on 25th May 2021
            total_totalSales += repMonthTotal;//-------Added by Ajay Choudhary on 25th May 2021
            total_totalPrior += priorYearTotal;//-------Added by Ajay Choudhary on 25th May 2021
            total_totalMktg += mgrMonthTotal;//-------Added by Ajay Choudhary on 25th May 2021
        });


        component.set("v.tableRecords", fullList);
		component.set('v.recordSalesTotal', totalSales); //-------Added by Ajay Choudhary on 25th May 2021
        component.set("v.recordMktgTotal", totalMktg); //-------Added by Ajay Choudhary on 25th May 2021
        component.set('v.total_totalSales',total_totalSales);//-------Added by Ajay Choudhary on 25th May 2021
        component.set('v.total_totalPrior',total_totalPrior);//-------Added by Ajay Choudhary on 25th May 2021
        component.set('v.total_totalMktg',total_totalMktg);//-------Added by Ajay Choudhary on 25th May 2021
        component.set('v.recordPriorYearTotal', totalPriorYr);//-------Added by Ajay Choudhary on 25th May 2021
		component.set('v.recordAveTotal', totalAve); //-------Added by Ajay Choudhary on 3 June 2021------
        console.log("AFTER MONTH FIX >> ", component.get("v.tableRecords"));
		

    },

    getSelectedDates : function(month) {
        var month_name = new Array(12);
        month_name["January"] = 0;
        month_name["February"] = 1;
        month_name["March"] = 2;
        month_name["April"] = 3;
        month_name["May"] = 4;
        month_name["June"] = 5;
        month_name["July"] = 6;
        month_name["August"] = 7;
        month_name["September"] = 8;
        month_name["October"] = 9;
        month_name["November"] = 10;
        month_name["December"] = 11;
        return month_name[month];
    },

    getMonths : function(month) {
        var month_name = new Array(12);
		month_name[0] = "January";
		month_name[1] = "February";
		month_name[2] = "March";
		month_name[3] = "April";
		month_name[4] = "May";
		month_name[5] = "June";
		month_name[6] = "July";
		month_name[7] = "August";
		month_name[8] = "September";
		month_name[9] = "October";
		month_name[10] = "November";
        month_name[11] = "December";
        return month_name[month];
    },
    
})