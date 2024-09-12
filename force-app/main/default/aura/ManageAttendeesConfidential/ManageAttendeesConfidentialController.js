({
    doInit : function(component, event, helper) {
        component.set('v.columns', [
            {label: 'Contact', fieldName: 'ContactName', type: 'text'},
            {label: 'Account Name', fieldName: 'AccountName', type: 'Text'},
            {label: 'Email', fieldName: 'ContactEmail', type: 'Email'},
            {label: 'Primary Contact', fieldname : "FCM_IsPrimaryContact__c" , type:'text', cellAttributes: { class: { fieldName: 'FCM_IsPrimaryContact__c' } }},
            {label: '', type: 'button',typeAttributes: { name: 'Primary Contact', value: 'Primary Contact',label: 'Set Primary' } },
            { label : 'Delete', type : 'button', typeAttributes:  { label: '',name: 'delete', value: 'delete', iconName: 'utility:delete', variant : 'base',size:"medium"} }
        ]);
        var action = [ { label: 'SELECT', name: 'SELECT' }];
        component.set('v.columns1', [
            {label: '', type: 'button', typeAttributes: { rowActions: action,label: 'Select' } },
            {label: 'Contact', fieldName: 'Name', type: 'text'},
            {label: 'Account Name', fieldName: 'AccountName', type: 'Text'},
            {label: 'Email', fieldName: 'Email', type: 'Email'}
        ]);
        
        helper.SearchContacts(component,event,helper);
        helper.fetchContacts(component,event,helper);
        helper.fetchContacttypes(component,event,helper);
        helper.fetchAccount(component,event,helper);
    },
    handleRowAction1: function (component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        var rowId = row.Id;
        var actionName = event.getParam('action').name;
         console.log('row.Id',actionName);
        if ( actionName == 'Primary Contact' ) {
        var action1 = component.get("c.updatePrimaryField");
        action1.setParams({ 
            'Selected'   : rowId,
            'recordId' : component.get("v.recordId")
        });
        action1.setCallback(this,function(response){
            var state = response.getState();
            var result = response.getReturnValue();
            if (state === "SUCCESS") {
                var toastEvent = $A.get('e.force:showToast');
                toastEvent.setParams({
                    "message": 'Attendee has been set as a primary contact',
                    "type": 'Success',
                    "title": "Success"
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action1);
        helper.SearchContacts(component,event,helper);
        }
        else if ( actionName == 'delete' ){
         helper.removeContacts(component,event,helper,rowId);
        helper.SearchContacts(component,event,helper);
        var Filters = component.get('v.Filters');
        helper.fnameChange(component, event, helper, component.get('v.Fname'), component.get('v.Lname'), component.get('v.Aname'), Filters,component.get('v.emailfilter')); 
        }
    },
    handleRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        
        var row = event.getParam('row');
        var rowId = row.Id;
        console.log('row.Id',row.Id);
        var action1 = component.get("c.updateavailableList");
        action1.setParams({ 
            'toSelect'   : rowId,
            'recordId' : component.get("v.recordId"),
        });
        action1.setCallback(this,function(response){
            var state = response.getState();
            console.log('state',state);
            if(state === 'Success'){
                
            }
        });
        $A.enqueueAction(action1);
        helper.SearchContacts(component,event,helper);
        helper.fetchContacts(component,event,helper);
        var Filters = component.get('v.Filters');
        helper.fnameChange(component, event, helper, component.get('v.Fname'), component.get('v.Lname'), component.get('v.Aname'), Filters,component.get('v.emailfilter'));
    },
    handlefnameChange: function (component, event, helper) {
        var fname = component.get('v.Fname');
        console.log('fname',fname);
        helper.fnameChange(component, event, helper, fname, component.get('v.Lname'), component.get('v.Aname'), component.get('v.Filters'),component.get('v.emailfilter'));
    },
    handlesnameChange: function (component, event, helper) {
        var Lname = component.get('v.Lname');
        console.log('Lname',Lname);
        helper.fnameChange(component, event, helper, component.get('v.Fname'), Lname, component.get('v.Aname'),component.get('v.Filters'),component.get('v.emailfilter'));
    },
    handlesAnameChange: function (component, event, helper) {
        var Aname = component.get('v.Aname');
        console.log('Aname',Aname);
        helper.fnameChange(component, event, helper,component.get('v.Fname'), component.get('v.Lname'), Aname,component.get('v.Filters'),component.get('v.emailfilter'));
    },
    handlesfiltertypeChange: function (component, event, helper) {
        var Filters = component.get('v.Filters');
        helper.fnameChange(component, event, helper, component.get('v.Fname'), component.get('v.Lname'), component.get('v.Aname'), Filters,component.get('v.emailfilter'));
    },
    handleemailChange: function (component, event, helper) {
        var emailfilter = component.get('v.emailfilter');
        helper.fnameChange(component, event, helper, component.get('v.Fname'), component.get('v.Lname'), component.get('v.Aname'), component.get('v.Filters'),emailfilter);
    },
    showContactPopUp: function (component, event, helper) {
        component.set('v.showCreateContact', true);
    },
    closeModel: function (component, event, helper) {
        component.set('v.showCreateContact', false);
        component.set('v.FirstName', '');
        component.set('v.LastName','');
        component.set('v.Email','');
        component.set('v.Phone','');
        component.set('v.title','');
    },
    handleSelectedRow: function(component, event, helper){
        var selectedRows = event.getParam('selectedRows');
        component.set("v.selectedRows", event.getParam('selectedRows'));
    },
    handleCreateContact : function(component, event, helper) {
        var Fname = component.get('v.FirstName');
        var Lname = component.get('v.LastName');
        var Email = component.get('v.Email');
        var title = component.get('v.title');
        var Phone = component.get('v.Phone');
        var Avalue = component.get('v.Avalue');
        if(Email == '' || Email == undefined || Email == null){
            var toastEvent = $A.get('e.force:showToast');
            toastEvent.setParams({
                "message": 'Email is required',
                "type": 'Warning',
                "title": "Warning"
            });
            toastEvent.fire();
        }
        else{       
            helper.CreateContact(component,event,helper,Fname,Lname,Email,Phone,title,Avalue);
            helper.SearchContacts(component,event,helper);
            component.set('v.showCreateContact', false);
        }
    },
    removeFromList : function (component, event, helper) {
        helper.removeContacts(component,event,helper);
        helper.SearchContacts(component,event,helper);
        var Filters = component.get('v.Filters');
        helper.fnameChange(component, event, helper, component.get('v.Fname'), component.get('v.Lname'), component.get('v.Aname'), Filters,component.get('v.emailfilter'));
        
    },
    renderList: function(component, event, helper) {
        helper.renderList(component, event);
    },
     handleExit : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();  
        
    }   
})