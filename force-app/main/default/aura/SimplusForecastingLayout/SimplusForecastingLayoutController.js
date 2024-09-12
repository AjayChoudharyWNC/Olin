({
    doInit : function(component, event, helper) {
        var selectedItem = event.getSource();
        helper.init(component, event, helper);
        var getRole = component.get("c.getUserRole");
        getRole.setCallback(this, function(a) {
            var ret = a.getReturnValue();
            if(ret === 'ForecastingAccountRepresentative') component.set("v.userRole", "rep");
            else if(ret === 'ForecastingAccountManager') component.set("v.userRole", "mgr");
            else component.set("v.userRole", ret);
        });
        $A.enqueueAction(getRole);
    },

    handleSortChange : function(component, event, helper){
        var selectedItem = event.getSource();
        helper.getSortType(component, event, helper, selectedItem.get("v.value"));
    },
    
    handleFilterChange : function(component, event, helper){
        var selectedItem = event.getSource();
        helper.getFilterType(component, event, helper, selectedItem.get("v.value"));
    },

    handleFilterOperationChange : function(component, event, helper){
    },

    sortTab : function(component, event, helper) {
        var sortList = component.get("v.currentList");
        var clicked = component.get("v.onloadSorting");
        if(!clicked) {
            component.set("v.onloadSorting", true);
            //helper.printBody(component, event, helper, sortList, 'Sorting');
        }
    },
    
    filterTab : function(component, event, helper) {
        var filterList = component.get("v.currentListFilter");
        var clicked = component.get("v.onloadFiltering");
        if(!clicked) {
            component.set("v.onloadFiltering", true);
            //helper.printBody(component, event, helper, filterList, 'Filtering');
        }
    },

    createButton : function(component, event, helper) {
        var db = component.find("newtag");
        var user = component.get("v.userInfo");
        var column = component.get("v.selectedSortColumn");
        var columnName = component.get("v.selectedSortColumnName");
        var direction = component.find("selectedDirectionSorting").get("v.value");
        
        var objWrapper = {};
        var objWrapperList = component.get("v.currentList");
        objWrapper.sortUser = user.Id;
        objWrapper.sortColumn = column;
        objWrapper.sortColumnName = columnName;
        objWrapper.sortOrder = direction;
        objWrapper.sortPriority = objWrapperList.length + 1;
        objWrapper.isActive = true;
        console.log("objWrapper >> ", objWrapper);
        
        if(column && direction) {  
            component.set("v.isLoadingList", true);
            helper.sortBy(component, event, helper, objWrapper);
        } else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Failed",
                "message": "Column and Direction are required fields"
            });
            toastEvent.fire();
        }
        
    }, 
    
    removeAllButton : function(component, event, helper){
        //TODO: add a confirmation
        component.set("v.isLoadingList", true);
        var action = component.get("c.deleteAllSortFilterItem");
        var filterList = component.get("v.currentList");
        
        action.setParams({
			type : "sort",
			wrapperList : JSON.stringify(filterList)
		});
		action.setCallback(this, function(response) {
            component.set("v.isLoadingList", false);
            var returnList = response.getReturnValue();
            component.set("v.currentList", returnList.sortingWrapper);
			console.log("1 response >> ", returnList);
            console.log("2 response >> ", response.getState());
        	component.find("forecastGrid").doGridRepaint(returnList.pages, returnList.isBeyond);
            component.find("forecastGrid").hideAllTotals();//Added by Ajay Choudhary on 7th June 2021
		});
        $A.enqueueAction(action);
        helper.helperRepaintSort(component, event, helper);
    },

    saveChanges : function(component, event, helper){
        component.set("v.isLoadingList", true);
        var action = component.get("c.dragAndDrop");
        var sortList = component.get("v.currentList");
        
        action.setParams({
			type : "sort",
			wrapperList : JSON.stringify(sortList)
		});
		action.setCallback(this, function(response) {
            component.set("v.isLoadingList", false);
            var returnList = response.getReturnValue();
            component.set("v.currentList", returnList.sortingWrapper);
			console.log("1 response >> ", returnList);
            console.log("2 response >> ", response.getState());
		});
		$A.enqueueAction(action);
    },
    
    createButton2 : function(component, event, helper) {
        var db = component.find("newtag2");
        var user = component.get("v.userInfo");
        var column = component.get("v.selectedFilterColumn");
        var columnName = component.get("v.selectedFilterColumnName");
        var columnType = component.get("v.selectedFilterColumnType");
        var operation = component.find("selectedFilterOperation").get("v.value");
        var input = component.get("v.inputField");
        var inputValue;
        var hasError = false;
        if(input == 'String' || input == 'Reference') {
            inputValue = component.find("inputText").get("v.value");
        } else if(input == 'Date') {
            inputValue = component.find("inputDate").get("v.value");
            console.log("inputValue>>", inputValue);
            if(inputValue === null) {
                hasError = true;
            }

            var dateVal = new Date(inputValue);
            var year = dateVal.getUTCFullYear();
            var month = dateVal.getUTCMonth()+1;
            var day = dateVal.getUTCDate();
            var stringDate = year + '-' + month + '-' + day;
            inputValue = stringDate;
            console.log('DATE INPUT VALUE >> ', inputValue);
        } else if(input == 'DateTime') {
            inputValue = component.find("inputDateTime").get("v.value");
            var dateVal = new Date(inputValue);
            var year = dateVal.getUTCFullYear();
            var month = dateVal.getUTCMonth()+1;
            var day = dateVal.getUTCDate();
            var hour = dateVal.getUTCHours()+1;
            var minute = dateVal.getUTCMinutes()+1;
            var second = dateVal.getUTCSeconds()+1;
            var stringDate = year + '-' + month + '-' + day + ' ' + hour + ':'  + minute +  ':' + second;
            inputValue = stringDate;
            console.log('DATETIME INPUT VALUE >> ', inputValue);
        } else if(input == 'Currency' || input == 'Double') {
            inputValue = component.find("inputCurrency").get("v.value");
        } else if(input == 'Boolean') {
            inputValue = operation;
            operation = 'eq';
        }

        var objWrapper = {};
        var objWrapperList = component.get("v.currentListFilter");
        objWrapper.filterUser = user.Id;
        objWrapper.filterColumn = column;
        objWrapper.filterColumnName = columnName;
        objWrapper.filterColumnType = columnType;
        objWrapper.filterOperation = operation;
        objWrapper.filterValue = inputValue;
        objWrapper.filterPriority = objWrapperList.length + 1;
        objWrapper.isActive = true;
        console.log("objWrapper >> ", objWrapper);
        if(column && operation) {
            
            if(hasError) {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Failed",
                    "message": "An error was encountered with the value provided"
                });
                toastEvent.fire();
            } else {
                component.set("v.isLoadingList", true);
                helper.filterBy(component, event, helper, objWrapper);
            }
        } else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Failed",
                "message": "Column and Operation are required fields"
            });
            toastEvent.fire();
        }
    },
    
    removeAllButton2 : function(component, event, helper){
        //TODO: add a confirmation
        component.set("v.isLoadingList", true);
        var action = component.get("c.deleteAllSortFilterItem");
        var filterList = component.get("v.currentListFilter");
        
        action.setParams({
			type : "filter",
			wrapperList : JSON.stringify(filterList)
		});
		action.setCallback(this, function(response) {
            component.set("v.isLoadingList", false);
            var returnList = response.getReturnValue();
            component.set("v.currentListFilter", returnList.filteringWrapper);
			console.log("1 response >> ", returnList);
            console.log("2 response >> ", response.getState());
		});
        $A.enqueueAction(action);
        helper.helperRepaintFilter(component, event, helper);
    },

    saveChanges2 : function(component, event, helper){
        component.set("v.isLoadingList", true);
        var action = component.get("c.dragAndDrop");
        var filterList = component.get("v.currentListFilter");
        
        action.setParams({
			type : "filter",
			wrapperList : JSON.stringify(filterList)
		});
		action.setCallback(this, function(response) {
            component.set("v.isLoadingList", false);
            var returnList = response.getReturnValue();
            component.set("v.currentListFilter", returnList.filteringWrapper);
			console.log("1 response >> ", returnList);
            console.log("2 response >> ", response.getState());
		});
		$A.enqueueAction(action);
    },

    dragRowSort : function(component, event, helper){
        var x = event.getParam('jsonParam');
        component.set("v.dragSort", x);
        console.log(x);
    },

    dropRowSort : function(component, event, helper){
        var x = event.getParam('jsonParam').index;
        var dragId = component.get("v.dragSort"),
            values = component.get("v.currentList"),
            temp;
        temp = values[dragId];
        values[dragId] = values[x];
        values[x] = temp;
		component.set("v.currentList", values);
    },

    dragRowFilter : function(component, event, helper){
        var x = event.getParam('jsonParam');
        component.set("v.dragFilter", x);
        console.log(x);
    },

    dropRowFilter : function(component, event, helper){
        var x = event.getParam('jsonParam').index;
        var dragId = component.get("v.dragFilter"),
            values = component.get("v.currentListFilter"),
            temp;
        temp = values[dragId];
        values[dragId] = values[x];
        values[x] = temp;
		component.set("v.currentListFilter", values);
    },

    repaintSort : function(component, event, helper) {
        //helper.helperRepaintSort(component, event, helper); --------Commented By Ajay Choudhary on 15th Jube 2021-------
        component.set("v.isLoadingList", false);//Added by Ajay Choudhary on 15th June 2021
        var jsonParam = event.getParam("jsonParam");//Added by Ajay Choudhary on 15th June 2021
        component.set("v.currentList", jsonParam.sortingWrapper);//Added by Ajay Choudhary on 15th June 2021
        console.log("CAUGHT FROM REPAINT>> ", event.getParam("jsonParam"));
    },

    repaintFilter : function(component, event, helper) {
        //helper.helperRepaintFilter(component, event, helper); --------Commented By Ajay Choudhary on 15th June 2021-------
        component.set("v.isLoadingList", false);//Added by Ajay Choudhary on 15th June 2021
         component.find("forecastGrid").hideAllTotals();//Added by Ajay Choudhary on 7th June 2021
        var jsonParam = event.getParam("jsonParam");//Added by Ajay Choudhary on 15th June 2021
        component.set("v.currentListFilter", jsonParam.filteringWrapper);//Added by Ajay Choudhary on 15th June 2021
        console.log("CAUGHT FROM REPAINT>> ", event.getParam("jsonParam"));
    },

    catchPendingChange : function(component, event, helper) {
        console.log(event.getParam("jsonParam"));
    },

    toggleControls : function(component, event, helper) {
        component.set("v.sidebarHidden", !component.get("v.sidebarHidden"));
    },

    catchChanges : function(component, event, helper) {
        var returnValue = event.getParam("jsonParamType");
        var jsonResult = JSON.parse(returnValue);
        component.set("v.selectedDate", jsonResult.selectedDate);
        component.set("v.selectedMonth", jsonResult.selectedMonth);
        component.set("v.selectedView", jsonResult.selectedView);
        component.find("forecastGrid").hideAllTotals();
    },
    
    startLoading : function(component, event, helper) {
        component.set("v.isLoadingList", true);
    },
    
    /*******Added By Ajay Choudhary on 15th June 2021 *******Start****/
    handleApplyAll : function(component, event, helper){
        component.set("v.isLoadingList", true);
        helper.updateColumnConfig(component, event, helper); // Added by Ajay Choudhary on 30th Jan 2023 -----> Column Show/Hide functionality
        var allFilters = component.get('v.currentListFilter')
        var allSortItems = component.get('v.currentList');
        var allFilterSobject = [];
        var allSortSobject = [];
        for(var fIdx=0;fIdx<allFilters.length;fIdx++){
            allFilterSobject.push({
                sObjectType : 'SimplusGrid_Filtering__c',
                Id : allFilters[fIdx].id,
                Active__c : allFilters[fIdx].isActive
            });
        }
        for(var j=0;j<allSortItems.length;j++){
            allSortSobject.push({
                sObjectType : 'SimplusGrid_Sorting__c',
                Id : allSortItems[j].id,
                Active__c : allSortItems[j].isActive
            });
        }
        if(allFilterSobject.length > 0){
            var getToggle = component.get("c.toggleSortFilterItemNew");
            getToggle.setParams({
                type : "filter",
                objList : allFilterSobject
            });
            getToggle.setCallback(this, function(a) {
                component.set("v.currentListFilter", a.getReturnValue().filteringWrapper);
                if(allSortSobject.length > 0){
                    var getToggleSort = component.get("c.toggleSortFilterItemNew");
                    getToggleSort.setParams({
                        type : "sort",
                        objList : allSortSobject
                    });
                    getToggleSort.setCallback(this, function(a) {
                        component.set("v.currentList", a.getReturnValue().sortingWrapper);
                        helper.helperRepaintSortAndFilter(component, event, helper);
                        $A.get('e.force:refreshView').fire();
                    });
                    $A.enqueueAction(getToggleSort);
                }
                helper.helperRepaintSortAndFilter(component, event, helper);
            });
            $A.enqueueAction(getToggle);
        }
        
        
    },
    /*******Added By Ajay Choudhary on 15th June 2021 *******End****/
    
    handleSectionToggle : function(component, event, helper){
        var openSections = event.getParam('openSections');
        if(openSections.length > 0){
            var openSectionString = openSections.join('-');
            var user = component.get('v.userInfo');
            var forecastingSetting = user.Forecasting_Settings__c;
            if(!forecastingSetting){
                forecastingSetting = '';
            }
            forecastingSetting = forecastingSetting.replace('-SHC','');
            forecastingSetting = forecastingSetting.replace('-SORT','');
            forecastingSetting = forecastingSetting.replace('-FILTER','');
            forecastingSetting = forecastingSetting += '-'+openSectionString;
            var action = component.get('c.saveUserDetail');
            action.setParams({
                noOfColumns : user.Forecasting_Lock_Column__c,
                settings : forecastingSetting
            });
            action.setCallback(this, function(response){
                if(response.getState() === 'SUCCESS'){
                    console.log('user updated');
                }
            });
            $A.enqueueAction(action);
        }
        console.log(openSections);
    }
})