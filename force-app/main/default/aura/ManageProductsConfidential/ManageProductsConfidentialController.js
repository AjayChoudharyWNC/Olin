({
    
    doInit : function(component, event, helper) {
        component.set('v.columns', [
            {label: 'Products', fieldName: 'ProductName', type: 'text'},
            {label: 'Code', fieldName: 'Code', type: 'text'},
              { label : 'Delete', type : 'button', typeAttributes:  { label: '',name: 'delete', value: 'delete', iconName: 'utility:delete', variant : 'base',size:"medium"} }
        ]);
        var action = [ { label: 'SELECT', name: 'SELECT' }];
        component.set('v.columns1', [
            {label: '', type: 'button', typeAttributes: { rowActions: action,label: 'Select' } },
            {label: 'Products', fieldName: 'Name', type: 'text'},
            {label: 'Code', fieldName: 'Code', type: 'text'},
            {label: 'Level', fieldName: 'Product_Level__c', type: 'text'}
        ]);
        helper.SelectedProducts(component,event,helper);
        helper.fetchProductrecords(component,event,helper);
        helper.fetchfiltertypes(component,event,helper);
        helper.fetchLobtype(component,event,helper);
    },
     handleRowAction1:  function (component, event, helper) {
        var row = event.getParam('row');
        var rowId = row.Id;
        helper.removeProducts(component,event,helper,rowId);
        helper.SelectedProducts(component,event,helper);
        var Filters = component.get('v.Filters');
        helper.filterChange(component, event, helper, component.get('v.Pname'), component.get('v.LOB'), Filters);
      }, 
    
    handleRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        var rowId = row.Id;
        var action1 = component.get("c.updateavailableList");
        action1.setParams({ 
            'toSelect'   : rowId,
            'recordId' : component.get("v.recordId"),
        });
        action1.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'Success'){
            }
        });
        $A.enqueueAction(action1);
        helper.SelectedProducts(component,event,helper);
        helper.fetchProductrecords(component,event,helper);
        var Filters = component.get('v.Filters');
        helper.filterChange(component, event, helper, component.get('v.Pname'), component.get('v.LOB'), Filters);
    },
    handlePnameChange: function (component, event, helper) {
        var Pname = component.get('v.Pname');
        helper.filterChange(component, event, helper, Pname,component.get('v.LOB'),component.get('v.Filters'));
    },
    handlesLOBChange: function (component, event, helper) {
        var LOB = component.get('v.LOB');
        helper.filterChange(component, event, helper,component.get('v.Pname'),LOB,component.get('v.Filters'));
    },
    handlesfiltertypeChange: function (component, event, helper) {
        var Filters = component.get('v.Filters');
        helper.filterChange(component, event, helper, component.get('v.Pname'), component.get('v.LOB'), Filters);
    },
    handleSelectedRow: function(component, event, helper){
        var selectedRows = event.getParam('selectedRows');
        component.set("v.selectedRows", event.getParam('selectedRows'));
    },
    removeFromList : function (component, event, helper) {
        helper.removeProducts(component,event,helper);
        helper.SelectedProducts(component,event,helper);
        var Filters = component.get('v.Filters');
        helper.filterChange(component, event, helper, component.get('v.Pname'), component.get('v.LOB'), Filters);
        
      }, 
     renderList: function(component, event, helper) {
        helper.renderList(component, event);
    },
     handleExit : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        $A.get('e.force:refreshView').fire();  
        
    }   
     
})