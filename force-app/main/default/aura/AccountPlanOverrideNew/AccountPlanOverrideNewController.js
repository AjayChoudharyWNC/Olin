({
    doInit : function(component, event, helper) {
        var value = helper.getParameterByName(component , event, 'inContextOfRef');
        var context = JSON.parse(window.atob(value));
        console.log('context.attributes.recordId@@@@',context.attributes.recordId);
        component.set("v.parentRecordId", context.attributes.recordId);
        var parentId = context.attributes.recordId;
        console.log('parentId@@@@',parentId);
        if(parentId == '' || parentId == undefined)
        {
            alert('Please go to your Parent Account & create Account Plan.');
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": 'https://olin--zdev4.lightning.force.com/lightning/o/Account_Plan__c/list?filterName=00B0S000001LotpUAC'
            });
            urlEvent.fire();
        }
        var action = component.get("c.showAccSoldToRecord");
        action.setParams({
            "pId":parentId
        });
        
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === "SUCCESS") {
                var sToList = a.getReturnValue();
                console.log('value in SoldToWrapList@@@@',sToList);
                if(sToList == null)
                {
                    alert('There are no soldTo Account attached to this Account.');
                    var navigateEvent0 = $A.get("e.force:navigateToSObject");
                    navigateEvent0.setParams({ "recordId": component.get('v.parentRecordId') });
                    navigateEvent0.fire();
                }
                else
                {
                    component.set('v.SoldToWrapList',sToList);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    onCancel : function(component, event, helper) {
        // Navigate back to the record view
        console.log('onCancel@@@');
        var navigateEvent = $A.get("e.force:navigateToSObject");
        navigateEvent.setParams({ "recordId": component.get('v.parentRecordId') });
        navigateEvent.fire();
        console.log('onCancel@@@e');
    },
    
    onSave : function(component, event, helper) {
        var selectedAccounts = [];
        var wList = component.find('accCheck');
        console.log('wList &&&&&',wList);
        if($A.util.isArray(wList)){
            wList.forEach(function(w){
                console.log(w,w.get('v.checked'),w.get('v.value'),w.get('v.text'));
                if(w.get('v.checked') )
                {
                    selectedAccounts.push(w.get('v.value'));
                }
            });
        }
        else{
            if(wList.get('v.checked') )
            {
                selectedAccounts.push(wList.get('v.value'));
            }
        }
        console.log('onSave method call &&&&&',selectedAccounts);
        var pId = component.get("v.parentRecordId");
        console.log('parentRecordId &&&&&',pId);
        console.log('accIdList &&&&&',selectedAccounts);
        var action1 = component.get("c.saveRecords");
        action1.setParams({
            "accIdList":selectedAccounts,
            "parentAccId":pId
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
    
    
     handleSelectAllContact: function(component, event, helper) {
        var getID = component.get("v.contactList");
        var checkvalue = component.find("selectAll").get("v.value");        
        var checkContact = component.find("accCheck"); 
        if(checkvalue == true){
            console.log('checkContact.length',checkContact.length);
            if(checkContact instanceof Array){
                for(var i=0; i<checkContact.length; i++){
                    checkContact[i].set("v.checked",true);
                }
            }
            else{
                checkContact.set("v.checked",true);
            }
        }
        else{
            if(checkContact instanceof Array){
                for(var i=0; i<checkContact.length; i++){
                    checkContact[i].set("v.checked",false);
                }
            }
            else{
                checkContact.set("v.checked",false);
            }
        }
    },
})