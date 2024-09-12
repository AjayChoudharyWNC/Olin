({
	doInit : function(component, event, helper) {
        var value = helper.getParameterByName(component , event, 'inContextOfRef');
        var context = JSON.parse(window.atob(value));
        component.set("v.parentRecordId", context.attributes.recordId);
        var parentId = context.attributes.recordId;
        component.set('v.parentRecordId', parentId);
        if(parentId == '' || parentId == undefined){
            alert('Please go to a parent account & create Sales Organization.');
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": '/lightning/o/Account/list?filterName=Recent'
            });
            urlEvent.fire();
        }
    },
    
    handleCreateLoad: function(component,event,helper){
        component.find("accField").set("v.value", component.get('v.parentRecordId'));
    },
    
    handleSubmit: function(component, event, helper) {
        event.preventDefault();
        var fields = event.getParam('fields');
        helper.getSalesOrg(component,event,fields);
    },
    
    onCancel: function(component,event,helper){
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": '/lightning/r/Account/'+component.get('v.parentRecordId')+'/view'
        });
        urlEvent.fire();
    },
    
    onSaveNew: function(component,event,helper){
        helper.getSalesOrg(component,event,null);
    }
})