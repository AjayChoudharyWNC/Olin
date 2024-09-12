({
    SelectedProducts : function(component,event,helper) {
        component.set('v.showSpinner', true);
        var action = component.get('c.selectedProductRecords');
        action.setParams({
            'recordId' : component.get("v.recordId"),
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result.length > 0){
                    var temp = [];
                    for ( var i = 0; i < result.length; i++ ) {
                        if(result[i].FCM_Product__r){
                            result[i].ProductName = result[i].FCM_Product__r.Name;
                        }
                        result[i].Code = result[i].FCM_Product__r.ProductCode;
                        temp.push(result);
                    } 
                    component.set('v.data',result);
                }
                else{
                    component.set('v.data',[]);
                }
            }
            component.set('v.showSpinner', false);
        });
        $A.enqueueAction(action);
    },
    fetchProductrecords : function(component,event,helper) {
        component.set('v.showSpinner', true);
        var action = component.get('c.fetchProducts');
        action.setParams({
            'recordId' : component.get("v.recordId"),
            'ProdId' : ''
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result.length > 0){
                    var temp = [];
                    var ps = component.get("v.pageSize");
                    component.set('v.totalPages',Math.floor((result.length+(ps-1))/ps));
                    for ( var i = 0; i < result.length; i++ ) {
                        result[i].Code = result[i].ProductCode;
                        temp.push(result);
                    } 
                    component.set('v.data1',result);
                }
                else{
                    component.set('v.data1', []);
                    component.set('v.totalPages',0);
                    component.set('v.pageNumber',0);
                }
                this.renderList(component,event);
            }
            component.set('v.showSpinner', false);
        });
        $A.enqueueAction(action); 
    },
    fetchfiltertypes: function(component,event,helper) {
        component.set('v.showSpinner', true);
        var action = component.get('c.getFilterTypes');
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result.length > 0){
                    component.set('v.allfiltertypes',result);
                    console.log('filtertype',result[1]);
                    component.set('v.selectedObject','Purchased Products');
                }
            }
            component.set('v.showSpinner', false);
        });
        $A.enqueueAction(action);
    },
    fetchLobtype: function(component,event,helper) {
        component.set('v.showSpinner', true);
        var action = component.get('c.getListLineofBussiness');
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result.length > 0){
                    component.set('v.lobTypes',result);
                    component.set('v.selectedObject1','BOTH');
                }
            }
            component.set('v.showSpinner', false);
        });
        $A.enqueueAction(action);
    },
    filterChange : function(component,event,helper,Pname, LOB,Filters) {
        var action = component.get('c.fetchSearchProducts');
        action.setParams({
            'Pname' :Pname,
            'LOB' :LOB,
            'Filters' :Filters,
            'recordId' : component.get("v.recordId"),
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('filter',result);
                if(result.length > 0){
                    var temp = [];
                    var ps = component.get("v.pageSize");
                    component.set('v.pageNumber',1);
                    component.set('v.totalPages',Math.floor((result.length+(ps-1))/ps));
                    for ( var i = 0; i < result.length; i++ ) {
                        result[i].Code = result[i].ProductCode;
                        temp.push(result);
                    } 
                    component.set('v.data1',result);
                }
                else{
                    component.set('v.data1', []);
                    component.set('v.totalPages',0);
                    component.set('v.pageNumber',0);
                }
                this.renderList(component,event);
            }
            component.set('v.showSpinner', false);
        });
        $A.enqueueAction(action);
    },
    removeProducts : function(component,event,helper,rowId) {
        component.set('v.showSpinner', true);
        var action = component.get('c.removeProductRecords');
        action.setParams({
            'RecordId': rowId
        });
        action.setCallback(this, function(response) {           
            var state = response.getState();
            if(state == 'SUCCESS') {
                var result = response.getReturnValue();
            }
            component.set('v.showSpinner', false);
        });
        $A.enqueueAction(action);  
        this.fetchProductrecords(component,event,helper);
    },
     renderList: function(component,event){
        var ps = component.get("v.pageSize");
        var  records = component.get("v.data1");
        var pageNumber = component.get("v.pageNumber");  
        var pageRecords = records.slice((pageNumber-1)*ps, pageNumber*ps);
        component.set("v.datatsPaginated", pageRecords);
    }
})