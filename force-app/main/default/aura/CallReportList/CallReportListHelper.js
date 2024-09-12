({
	openListView : function(component, event, boolDisplayMyCallList) {
		var teamCallListViewId = component.get('v.strTeamCallListViewIdFetched');
		var myCallListViewId = component.get('v.strMyCallListViewIdFetched');

		var navigationEvent = $A.get("e.force:navigateToList");
	    navigationEvent.setParams({
			"listViewId": boolDisplayMyCallList == false ? teamCallListViewId : myCallListViewId,
	      	"listViewName": null,
			"scope": "Contact"
	    });
	    navigationEvent.fire();
	},
    
    fetchMyCallReports: function(component,event,type){
        var action = component.get("c.myCallReportList");
        action.setParams({type: type});
        action.setCallback(this, function(response) {            
            var state = response.getState();
            if(state === "SUCCESS") {		
                var responseReturned = response.getReturnValue();
                component.set('v.myAccChecked',true);
                if(responseReturned && responseReturned.length > 0) { 		                       
                    component.set('v.myCallReports', responseReturned);
                    var ps = component.get("v.pageSize");
                    component.set('v.totalPages',Math.floor((responseReturned.length+(ps-1))/ps));
                }
                else{
                    component.set('v.myCallReports', []);
                    component.set('v.totalPages',0);
                }
                this.renderList(component,event);
            }
            else if(status === "ERROR"){                    
                console.log('>>>::::Error:::::');
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchMyTeamCallListRecords: function(component,event,type){
        var action = component.get("c.myTeamCallReportList");
        action.setParams({type: type});
        action.setCallback(this, function(response) {            
            var state = response.getState();
            if(state === "SUCCESS") {		
                var responseReturned = response.getReturnValue();
                component.set('v.myAccChecked',false);
                if(responseReturned && responseReturned.length > 0) { 		                       
                    component.set('v.myTeamCallReports', responseReturned);
                    var ps = component.get("v.pageSize");
                    component.set('v.totalPages',Math.floor((responseReturned.length+(ps-1))/ps));
                }
                else{
                    component.set('v.myTeamCallReports', []);
                    component.set('v.totalPages',0);
                }
                this.renderList(component,event);
            }
            else if(status === "ERROR"){                    
                console.log('>>>::::Error:::::');
            }
        });
        $A.enqueueAction(action);
    },
    
    filterMethods: function(component,event,type,isMyList){
        if(isMyList){
            this.fetchMyCallReports(component,event,type);
        }
        else{
            this.fetchMyTeamCallListRecords(component,event,type);
        }
    },
    
    renderList: function(component,event){
        var ps = component.get("v.pageSize");
        var records;
        if(component.get('v.myAccChecked'))
        	records = component.get("v.myCallReports");
        else
            records = component.get("v.myTeamCallReports");
        
        var pageNumber = component.get("v.pageNumber");
        var pageRecords = records.slice((pageNumber-1)*ps, pageNumber*ps);
        console.log('pageRecords ',pageRecords);
        component.set("v.myCallReportsPaginated", pageRecords);
    }
    
})