({
    doInit : function(component, event, helper) {
        var value = helper.getParameterByName(component , event, 'inContextOfRef');
        var context = JSON.parse(window.atob(value));
        console.log('context.attributes.recordId@@@@',context.attributes.recordId);
        component.set("v.parentRecordId", context.attributes.recordId);
        var parentId = context.attributes.recordId;
        console.log('parentId@@@@',parentId);
        
    },
    navToRecord : function (component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.keycontact.Id")
        });
            navEvt.fire();
    },
    editRecord : function(component, event, helper) {
        helper.showHide(component);
    },
    handleSuccess : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({"title": "Success!","message": "The Key Contact has been inserted successfully.","type": "success"});toastEvent.fire();
        helper.showHide(component);
    },
    handleCancel : function(component, event, helper) {
        helper.showHide(component);
        event.preventDefault();
    },
    onCancel : function(component, event, helper) {
        // Navigate back to the record view
        var navigateEvent = $A.get("e.force:navigateToSObject");
        navigateEvent.setParams({ "recordId": component.get('v.parentRecordId') });
        navigateEvent.fire();
    },
    handleSubmit : function(component, event, helper) {
        
        var pId = component.get("v.parentRecordId");
        var kcname = component.find("name").get("v.value");;
        var keyconid = component.find("keycon").get("v.value");;
        var comment = component.find("com").get("v.value");;
        console.log('kcname &&&&&',kcname);
        console.log('parentRecordId &&&&&',pId);
        console.log('keyconid &&&&&',keyconid);
        console.log('comment &&&&&',comment);
        var action1 = component.get("c.saveRecords");
        action1.setParams({
            "kcname":kcname,
            "pId":pId,
            "keyconid":keyconid,
            "comment":comment
        });
        action1.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS") {
                var save = a.getReturnValue();
                // console.log('Record @@@@',save);
                if(save != '')
                {
                    //console.log('Record2 @@@@',save);
                    var navigateEvent1 = $A.get("e.force:navigateToSObject");
                    navigateEvent1.setParams({ "recordId" : save });
                    navigateEvent1.fire();
                }
            }
        });
        $A.enqueueAction(action1);
    },
})