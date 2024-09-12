({
    deleteButtonClick : function(component, event, helper) {
        if(confirm('Are you sure?')){
            component.getEvent("startLoading").fire();
            var getDelete = component.get("c.deleteSortFilterItem");
            getDelete.setParams({
                type : "filter",
                id : component.get("v.lineItem.id")
            });
            getDelete.setCallback(this, function(a) {
                console.log("delete response >> ", a);
                console.log("delete response >> ", a.getState());
                var fireUp = component.getEvent("pushUpdate");
                fireUp.setParams({
                    jsonParam : a.getReturnValue()
                })
                fireUp.fire();
            });
            $A.enqueueAction(getDelete);
        }
    },
    
   

	toggleButtonClick : function(component, event, helper) {
		//component.getEvent("startLoading").fire();
		component.set("v.lineItem.isActive", event.currentTarget.checked);
/*//-----Commented By Ajay Choudhary on 16th June 2021-------------
		var getToggle = component.get("c.toggleSortFilterItem");
		console.log(">>>", component.get("v.lineItem.id"));
		getToggle.setParams({
			type : "filter",
			id : component.get("v.lineItem.id"),
			currentState : !component.get("v.lineItem.isActive")
		});
		getToggle.setCallback(this, function(a) {
			console.log("delete response >> ", a);
			console.log("delete response >> ", a.getState());
			var fireUp = component.getEvent("pushUpdate");
			fireUp.setParams({
				jsonParam : a.getReturnValue()
			})
			fireUp.fire();
            
		});
		$A.enqueueAction(getToggle);*/
        //-----Commented By Ajay Choudhary on 16th June 2021-------------
	},

	dragstart: function(component, event, helper) {
		var drag = component.getEvent("dragFilter");
		drag.setParams({
			jsonParam : event.target.dataset.dragId
		});
		component.set("v.dragid", event.target.dataset.dragId);
		drag.fire();
	},
	
    drop: function(component, event, helper) {
		var tg = event.target;
		while(tg.localName != "tr") {
			tg = tg.parentNode;
		}

		var drag = component.getEvent("dropFilter");
		console.log(event);
		drag.setParams({
			jsonParam : {
				index : tg.dataset.dragId,
				targetTable : "filter"
			}
		});
		drag.fire();
        event.preventDefault();
	},
	
    cancel: function(component, event, helper) {
        event.preventDefault();
    },
    //Added by Ajay Choudhary on 30 Sept 2022 **********Edit Filter Functionality**************Start******
    openEditPopup : function(component, event, helper){
        var element = component.get('v.lineItem');
         console.log(JSON.stringify(element));
        var selectedFilterType = element.filterColumnType;
        if(selectedFilterType == 'STRING') {
            component.set("v.selectedFilter", component.get("v.filterCompareSTRING"));
        } else if(selectedFilterType == 'DOUBLE') {
            component.set("v.selectedFilter", component.get("v.filterCompareDOUBLE"));
        } else if(selectedFilterType == 'PICKLIST') {
            component.set("v.selectedFilter", component.get("v.filterComparePICKLIST"));
        } else if(selectedFilterType == 'DATE') {
            component.set("v.selectedFilter", component.get("v.filterCompareDATE"));
        } else if(selectedFilterType == 'DATETIME') {
            component.set("v.selectedFilter", component.get("v.filterCompareDATETIME"));
        } else if(selectedFilterType == 'CURRENCY') {
            component.set("v.selectedFilter", component.get("v.filterCompareCURRENCY"));
            component.set("v.inputField", "Currency");
        } else if(selectedFilterType == 'REFERENCE') {
            component.set("v.selectedFilter", component.get("v.filterCompareREFERENCE"));
        }
        component.set('v.isEditFilter', true);
    },
    
    closeEditPopup : function(component, event, helper){
        component.set('v.isEditFilter', false);
    },
    
    saveFilter : function(component, event, helper){
        component.getEvent("startLoading").fire();
        var filter = component.get('v.lineItem');
        var action = component.get('c.updateFilter');
        action.setParams({
            filter : JSON.stringify(filter)
        });
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS'){
                var fireUp = component.getEvent("pushUpdate");
                fireUp.setParams({
                    jsonParam : response.getReturnValue()
                })
                fireUp.fire();
            }
        })
        $A.enqueueAction(action);
    }
    //Added by Ajay Choudhary on 30 Sept 2022 **********Edit Filter Functionality**************End******
})