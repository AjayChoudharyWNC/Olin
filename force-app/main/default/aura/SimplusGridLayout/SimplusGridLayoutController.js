({
    doInit : function(component, event, helper) {
        var selectedItem = event.getSource();
        helper.init(component, event, helper);
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
        
        if(column && direction) helper.sortBy(component, event, helper, objWrapper);
        else {
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
        var action = component.get("c.deleteAllSortFilterItem");
        var filterList = component.get("v.currentList");
        
        action.setParams({
			type : "sort",
			wrapperList : JSON.stringify(filterList)
		});
		action.setCallback(this, function(response) {
            var returnList = response.getReturnValue();
            component.set("v.currentList", returnList.sortingWrapper);
        	helper.helperRepaintSort(component, event, helper);
            //component.find("gridTable").doGridRepaint(returnList.pageMax, returnList.isBeyond);
		});
        $A.enqueueAction(action);
    },

    saveChanges : function(component, event, helper){
        var action = component.get("c.dragAndDrop");
        var sortList = component.get("v.currentList");
        
        action.setParams({
			type : "sort",
			wrapperList : JSON.stringify(sortList)
		});
		action.setCallback(this, function(response) {
            var returnList = response.getReturnValue();
            component.set("v.currentList", returnList.sortingWrapper);
			console.log("1 response >> ", returnList);
            console.log("2 response >> ", response.getState());
            console.log("3 response >> ", response.pageMax);
            component.find("gridTable").doGridRepaint(returnList.pageMax);
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

        if(input == 'String') {
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
		console.log('operation ' + operation);
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
                helper.filterBy(component, event, helper, objWrapper);
            }
        } 
        else {
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
        var action = component.get("c.deleteAllSortFilterItem");
        var filterList = component.get("v.currentListFilter");
        
        component.set("v.isLoading", true);
        action.setParams({
			type : "filter",
			wrapperList : JSON.stringify(filterList)
		});
		action.setCallback(this, function(response) {
            component.set("v.isLoading", false);
            var returnList = response.getReturnValue();
            component.set("v.currentListFilter", returnList.filteringWrapper);
			console.log("1 response >> ", returnList);
            console.log("2 response >> ", response.getState());
        	helper.helperRepaintFilter(component, event, helper);
            //component.find("gridTable").doGridRepaint(returnList.pageMax, returnValue.isBeyond);
		});
        $A.enqueueAction(action);
    },

    saveChanges2 : function(component, event, helper){
        var action = component.get("c.dragAndDrop");
        var filterList = component.get("v.currentListFilter");
        
        component.set("v.isLoading", true);
        action.setParams({
			type : "filter",
			wrapperList : JSON.stringify(filterList)
		});
		action.setCallback(this, function(response) {
            component.set("v.isLoading", false);
            var returnList = response.getReturnValue();
            component.set("v.currentListFilter", returnList.filteringWrapper);
			console.log("1 response >> ", returnList);
            console.log("2 response >> ", response.getState());
			console.log("3 response >> ", returnList.pageMax);
            console.log("page max == ", returnList, returnList.pageMax, returnList.isBeyond);
            component.find("gridTable").doGridRepaint(returnList.pageMax, returnList.isBeyond);
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
        component.find("gridTable").doGridRepaint();
    },

    repaintSort : function(component, event, helper) {
        component.set("v.isLoading", true);
        //helper.helperRepaintSort(component, event, helper);
        console.log("CAUGHT FROM REPAINT>> ", event.getParam("jsonParam"));
        
        var returnValue = event.getParam("jsonParam");
        if (!returnValue) helper.helperRepaintSort(component, event, helper);
        else {
            console.log('SORT RETURN VALUE >> ', returnValue);
            component.set("v.currentList", returnValue.sortingWrapper);
            component.set("v.tableRecords", returnValue.lstObject);
            console.log('SORT >> ', returnValue.sortingWrapper);
            component.set("v.isLoading", false);
            console.log("page max == ", returnValue, returnValue.pageMax, returnValue.isBeyond);
            component.find("gridTable").doGridRepaint(returnValue.pageMax, returnValue.isBeyond);
        }
    },

    repaintFilter : function(component, event, helper) {
        component.set("v.isLoading", true);
        //helper.helperRepaintFilter(component, event, helper);
        console.log("CAUGHT FROM REPAINT>> ", event.getParam("jsonParam"));
        
        var returnValue = event.getParam("jsonParam");
        console.log('287 log',JSON.stringify(returnValue));
        if (!returnValue) helper.helperRepaintFilter(component, event, helper);
        else {
            // need to update filteringOrderResult too
            console.log('FILTER RETURN VALUE >> ', returnValue);
            component.set("v.currentList", returnValue.sortingWrapper);
            component.set("v.currentListFilter", returnValue.filteringWrapper);
            component.set("v.filteringOrderResult", returnValue.filteringOrderResult);
            component.set("v.sortingOrderResult", returnValue.sortingOrderResult);
            component.set("v.tableRecords", returnValue.lstObject);
            console.log('FILTER >> ', returnValue.filteringWrapper);
            component.set("v.isLoading", false);
            console.log("page max == ", returnValue, returnValue.pageMax, returnValue.isBeyond);
            component.find("gridTable").doGridRepaint(returnValue.pageMax, returnValue.isBeyond);
        }
    },

    catchPendingChange : function(component, event, helper) {
        console.log(event.getParam("jsonParam"));
    },
    catchStartLoading : function(component, event, helper) {
        component.set("v.isLoading", true);
    },
    toggleControls : function(component, event, helper) {
        component.set("v.sidebarHidden", !component.get("v.sidebarHidden"));
    },

    filterToggle : function(component, event, helper) {
        component.set("v.filterShown", !component.get("v.filterShown"));
    },
    sortToggle : function(component, event, helper) {
        component.set("v.sortShown", !component.get("v.sortShown"));
    },
    cloneClickHandler : function(component, event, helper) {
        
    }
})