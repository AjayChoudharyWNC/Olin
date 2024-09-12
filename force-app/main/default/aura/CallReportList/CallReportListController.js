({
	doInit : function(component, event, helper) {
		component.set('v.displayText', 'Call Frequency Tracker');
		helper.fetchMyCallReports(component, event, null);
	},
    viewAllCallReports: function(component, event, helper){
        helper.openListView(component, event, component.get('v.boolDisplayMyCallList'));
    },
    handleMenuSelect: function(component, event, helper){
        var menuValue = event.detail.menuItem.get("v.value");
        switch(menuValue) {
            case "MyList": helper.fetchMyCallReports(component, event, null); break;
            case "TeamList": helper.fetchMyTeamCallListRecords(component, event, null); break;
        }
    },
    overdue: function(component,event,helper){
        helper.filterMethods(component,event,'overdue',component.get('v.myAccChecked'));
    },
    upcoming: function(component,event,helper){
        helper.filterMethods(component,event,'upcoming',component.get('v.myAccChecked'));
    },
    noAction: function(component,event,helper){
        helper.filterMethods(component,event,'noAction',component.get('v.myAccChecked'));
    },
    renderList: function(component, event, helper) {
        helper.renderList(component, event);
    },
    showToolTip: function(component,event,helper){
        var c = document.getElementById('help');
        c.classList.toggle('slds-hidden');
    },
    hideToolTip: function(component,event,helper){
        var c = document.getElementById('help');
        c.classList.add('slds-hidden');
    },
    intervalEdit: function(component, event, helper){
        var accid = event.target.id;
        component.set('v.editMode', accid);
        component.set('v.savebtn', true);
        console.log("div1: ", event.target.id); 
    },
    valueEdit: function(component, event, helper){
        console.log("value: ", event.target.value);
        var recordList = component.get('v.myCallReportsPaginated');
        console.log("myCallReportsPaginated ",component.get('v.myCallReportsPaginated'));
        var i;
        for (i = 0; i < recordList.length; i++) { 
           console.log("id: ", recordList[i].Id);
            if(recordList[i].Id == component.get('v.editMode'))
            {
                recordList[i].Interval_Days__c = event.target.value;
            }
        }
        console.log("myCallReportsPaginated2 ",component.get('v.myCallReportsPaginated'));
    },
    saveRecord: function(component, event, helper){
        var action = component.get("c.updCallReportList");
        action.setParams({accList: component.get('v.myCallReportsPaginated')});
        action.setCallback(this, function(response) {            
            var state = response.getState();
            if(state === "SUCCESS") {		
                console.log('>>>::::Success:::::');
            }
            else if(status === "ERROR"){                    
                console.log('>>>::::Error:::::');
            }
        });
        $A.enqueueAction(action);
        component.set('v.editMode', '123');
        component.set('v.savebtn', false);
        helper.fetchMyCallReports(component, event, null);
    },
    intervalEditCancel: function(component, event, helper){
        component.set('v.editMode', '123');
        component.set('v.savebtn', false);
        helper.fetchMyCallReports(component, event, null);
    }
})