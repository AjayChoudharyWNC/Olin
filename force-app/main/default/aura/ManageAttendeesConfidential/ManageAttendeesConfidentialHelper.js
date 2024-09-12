({
      fetchAccount : function(component,event,helper) {
        var action = component.get('c.FetchAccountName');
        action.setParams({
            'recordId' : component.get("v.recordId"),
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result != ''){
                    console.log('result',result);
                    component.set('v.Avalue',result);
                    console.log('result',component.get('v.Avalue'));
                }
            }
        });
        $A.enqueueAction(action);
    },
    SearchContacts : function(component,event,helper) {
        component.set('v.showSpinner', true);
        var action = component.get('c.searchContactRecords');
        action.setParams({
            'recordId' : component.get("v.recordId"),
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log(result);
                if(result.length > 0){
                    var temp = [];
                    for ( var i = 0; i < result.length; i++ ) {
                        if(result[i].Confidential_Call_Report__r){
                         //   component.set('v.Avalue',result[i].Confidential_Call_Report__r.FCM_Account__c);
                        }
                        if ( result[i].FCM_Contact__r) {
                            result[i].ContactName = result[i].FCM_Contact__r.Name;
                            result[i].ContactEmail = result[i].FCM_Contact__r.Email;
                        } 
                        if ( result[i].FCM_Contact__r && result[i].FCM_Contact__r.Account &&  result[i].FCM_Contact__r.Account.Name) {
                            result[i].AccountName = result[i].FCM_Contact__r.Account.Name;
                        }   
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
    fetchContacts : function(component,event,helper) {
        component.set('v.showSpinner', true);
        var action = component.get('c.fetchContacts');
        action.setParams({
            'recordId' : component.get("v.recordId"),
            'conId' : ''
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log(result);
                if(result.length > 0){
                    console.log('pagenumber',component.get('v.pageNumber'));
                    var temp = [];
                    var ps = component.get("v.pageSize");
                    component.set('v.totalPages',Math.floor((result.length+(ps-1))/ps));
                    for ( var i = 0; i < result.length; i++ ) {
                        if(result[i].Account.Name){
                            result[i].AccountName = result[i].Account.Name;
                        }
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
    fetchContacts1 : function(component,event,helper,rowId) {
        component.set('v.showSpinner', true);
        var action = component.get('c.fetchContacts');
        action.setParams({
            'recordId' : component.get("v.recordId"),
            'conId' :rowId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log(result);
                if(result.length > 0){
                    component.set('v.data1',result);
                }
            }
            component.set('v.showSpinner', false);
        });
        $A.enqueueAction(action);
    },
    fetchContacttypes: function(component,event,helper) {
        component.set('v.showSpinner', true);
        var action = component.get('c.getContactTypes');
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('filtertype',result);
                if(result.length > 0){
                    component.set('v.allContacttypes',result);
                    console.log('filtertype',result[1]);
                    
                    component.set('v.selectedObject','Related to Account');
                }
            }
            component.set('v.showSpinner', false);
        });
        $A.enqueueAction(action);
    },
    fnameChange : function(component,event,helper,fname, Lname,Aname,Filters,emailfilter) {
       // component.set('v.showSpinner', true);
        var action = component.get('c.fetchSearchContacts');
        action.setParams({
            'fname' :fname,
            'Lname' :Lname,
            'Aname' :Aname,
            'Filters' :Filters,
            'emailfilter':emailfilter,
            'recordId' : component.get("v.recordId"),
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log(result);
                if(result.length > 0){
                    var temp = [];
                    var ps = component.get("v.pageSize");
                    component.set('v.pageNumber',1);
                    component.set('v.totalPages',Math.floor((result.length+(ps-1))/ps));
                    for ( var i = 0; i < result.length; i++ ) {
                        if(result[i].Account){
                            result[i].AccountName = result[i].Account.Name;
                        }
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
    CreateContact: function(component,event,helper,Fname,Lname,Email,Phone,title,Avalue) {
        component.set('v.showSpinner', true);
        var action = component.get('c.CreateContact');
        action.setParams({
            'Fname' :Fname,
            'Lname' :Lname,
            'Email' :Email,
            'title' : title,
            'Phone' :Phone,
            'Avalue': Avalue,
            'recordId' : component.get("v.recordId"),
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log(result);
                if(result != null){
                    if(result!= 'Success'){
                        var toastEvent = $A.get('e.force:showToast');
                        toastEvent.setParams({
                            "message": result,
                            "type": 'Warning',
                            "title": "Warning"
                        });
                        toastEvent.fire();
                        component.set('v.FirstName', '');
                        component.set('v.LastName','');
                        component.set('v.Email','');
                        component.set('v.Phone','');
                        component.set('v.title','');
                    }
                    if(result == 'Success'){
                        var toastEvent = $A.get('e.force:showToast');
                        toastEvent.setParams({
                            "message": 'Contact has been created and successfully added as an Attendee',
                            "type": 'Success',
                            "title": "Success"
                        });
                        toastEvent.fire();
                        component.set('v.showCreateContact', false);
                        component.set('v.FirstName', '');
                        component.set('v.LastName','');
                        component.set('v.Email','');
                        component.set('v.Phone','');
                        component.set('v.title','');
                    }
                }
            }
            component.set('v.showSpinner', false);
        });
        $A.enqueueAction(action);
    },
    removeContacts : function(component,event,helper,rowId) {
        component.set('v.showSpinner', true);
      /*  var selectedRows = component.get('v.selectedRows');
        if(selectedRows.length > 0){
            console.log('removelist');
            var selectedIds = [];
            for (var i = 0; i < selectedRows.length; i++) {
                selectedIds.push(selectedRows[i].Id);
            } */
            var action = component.get('c.removeContacts');
            action.setParams({
                'RecordId': rowId
            });
            action.setCallback(this, function(response) {           
                var state = response.getState();
                if(state == 'SUCCESS') {
                    console.log("state",state);
                    var result = response.getReturnValue();
                }
                component.set('v.showSpinner', false);
            });
            $A.enqueueAction(action);  
            this.fetchContacts(component,event,helper);
      //  }
    },
    renderList: function(component,event){
        var ps = component.get("v.pageSize");
        var  records = component.get("v.data1");
        var pageNumber = component.get("v.pageNumber");  
        console.log('pagenumber1',component.get('v.pageNumber'));
        var pageRecords = records.slice((pageNumber-1)*ps, pageNumber*ps);
        console.log('pageRecords ',pageRecords);
        component.set("v.datatsPaginated", pageRecords);
    }
})