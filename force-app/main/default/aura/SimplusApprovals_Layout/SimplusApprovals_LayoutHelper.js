({
	init : function(component, event, helper) {
        var action = component.get("c.fetchUser");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                component.set("v.userInfo", storeResponse);
                component.set("v.inputField", 'String');
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
            console.log('getTableFieldSet RESPONSE >> ', response.getReturnValue());
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
                    }else if(selectedFilterType == 'BOOLEAN') {
                        component.set("v.selectedFilter", component.get("v.filterCompareBOOLEAN"));
                        component.set("v.inputField", "Boolean");
                    }
                    console.log(JSON.stringify(element));
                }
            });
        } else {
            component.set("v.selectedFilterColumn", "");
        }
        component.find('selectedFilterOperation').set("v.value", null);
    },

    sortBy : function(component, event, helper, objWrapper) {
        var objWrapperList = component.get("v.currentList");
        var db = component.find("newtag");
        var action = component.get("c.sortColumns");
        console.log("objWrapper >> ", objWrapper);
        console.log("objWrapper >> ", objWrapperList);
        component.set("v.isLoading", true);
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
            component.set("v.isLoading", false);
            //KAI - changed to a lightning component to accommodate deletion and edit
            //db.set("v.body","");
            //if(returnList && returnList.length) this.printBody(component, event, helper, returnList, 'Sorting');
        })
        $A.enqueueAction(action);
        helper.helperRepaintSort(component, event, helper);
    },

    filterBy : function(component, event, helper, objWrapper) {
        var objWrapperList = component.get("v.currentListFilter");
        var db = component.find("newtag2");
        var action = component.get("c.filterColumns");
        console.log("objWrapper >> ", objWrapper);
        console.log("objWrapper >> ", objWrapperList);

        component.set("v.isLoading", true);
        action.setParams({
            objWrapper: JSON.stringify(objWrapper),
            objWrapperList: JSON.stringify(objWrapperList),
            mainListSource : component.get("v.mainListSource")
        });

        action.setCallback(this, function(response) {
            component.set("v.isLoading", false);
            var returnList = response.getReturnValue();
            console.log('RESULT >> ', returnList);

            component.set("v.currentListFilter", returnList.filteringWrapper);
            component.set("v.filteringOrderResult", returnList.filteringOrderResult);
            console.log('FILTER BY >> ', returnList.filteringOrderResult);
            //KAI - changed to a lightning component to accommodate deletion and edit
            //db.set("v.body","");
            //if(returnList && returnList.length) this.printBody(component, event, helper, returnList, 'Filtering');
            helper.helperRepaintFilter(component, event, helper);
        })
        $A.enqueueAction(action);
    },

    helperRepaintSort : function(component, event, helper) {
        console.log('160');
        component.set("v.isLoading", true);
        var getSort = component.get("c.toggle");
        console.log('object Name -- ' + component.get("v.sObjectName"));
        getSort.setParams({
            sObjectName : component.get("v.sObjectName"),
            mainListSource : component.get("v.mainListSource")
        });
        getSort.setCallback(this, function(a) {
            component.set("v.isLoading", false);
            var returnValue = a.getReturnValue();
            console.log('SORT RETURN VALUE >> ', returnValue);
            console.log('a repaintSort', a.getState());
            component.set("v.currentList", returnValue.sortingWrapper);
            component.set("v.tableRecords", returnValue.lstObject);
            console.log('SORT >> ', returnValue.sortingWrapper);
            component.find("gridTable").doGridRepaint();
        });
        $A.enqueueAction(getSort);
    },

    helperRepaintFilter : function(component, event, helper) {
        component.set("v.isLoading", true);
        var getFilter = component.get("c.toggle");
        getFilter.setParams({
            sObjectName: component.get("v.sObjectName"),
            mainListSource : component.get("v.mainListSource")
        });
        getFilter.setCallback(this, function(a) {
            component.set("v.isLoading", false);
            var returnValue = a.getReturnValue();
            console.log('FILTER RETURN VALUE >> ', returnValue);
            console.log('a repaintFilter', a.getState());
            component.set("v.currentListFilter");
            component.set("v.currentListFilter", returnValue.filteringWrapper);
            component.set("v.tableRecords", returnValue.lstObject);
            console.log('194 FILTER >> ', returnValue.filteringWrapper);
            
            component.find("gridTable").doGridRepaint();
        });
        $A.enqueueAction(getFilter);
    },
    
})