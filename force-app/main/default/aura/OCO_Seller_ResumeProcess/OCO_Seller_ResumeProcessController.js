({
    doInit: function (component, event, helper) {
        var action = component.get('c.fetchSapRecords');
        action.setParams({
            "accId": component.get('v.recordId')
        });
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                component.set('v.sapRecords', response.getReturnValue());
            }
        });
        var getSalesOrgData = component.get('c.getSalesOrgs');
        getSalesOrgData.setParams({
            soldToAccId : component.get('v.recordId')
        });
        getSalesOrgData.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                component.set('v.salesOrgs', response.getReturnValue());
            }
        });
        $A.enqueueAction(getSalesOrgData);
        $A.enqueueAction(action);
        helper.fetchRelatedProds(component, event, '');
        helper.fetchAccountDetails(component, event);
        
    },
    handleResumeSap: function (component, event, helper) {
        var sap = component.get('v.selectedSap');
        var sapRecords = component.get('v.sapRecords');
        if (!sap) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title" : 'Error',
                "message": 'Please select a Customer Setup Form',
                "duration": "5000",
                "key": "info_alt",
                "type": 'Error',
                "mode": "dismissible"
            });
            toastEvent.fire();
        }
        else {
            for (var i = 0; i < sapRecords.length; i++){
                if (sap == sapRecords[i].Id) {
                    if(sapRecords[i].Ship_To_Accounts__c && sapRecords[i].Ship_To_Accounts__c != '')
                        component.set('v.selectedShipToAccounts', sapRecords[i].Ship_To_Accounts__c.split(';'));
                    component.set('v.sapType', sapRecords[i].On_boarding_Request_Type__c);
                    component.set('v.dueDate', sapRecords[i].Form_Due_Date__c);
                    component.set('v.estDate', sapRecords[i].Estimated_Date_of_First_Shipment__c); 
                    component.set('v.selectedSalesOrg', sapRecords[i].Sales_Organization__c);
                    component.set('v.salesRep', sapRecords[i].Sales_Rep__c);
                    break;
                }
            }
            document.getElementById('modelB').style.height = '500px !important';
            component.set('v.showSapScreen', true);
            component.set('v.showResumeSap', true);
        }
    },
    handleCreateSap: function (component, event, helper) {
        component.set('v.spinner', true);
        $A.createComponent("c:OCO_Seller_ProcessInitiator", {"recordId" : component.get('v.recordId')},
                           function(content, status) {
                               if (status === "SUCCESS") {
                                   component.find('cmp1').showCustomModal({
                                       body: content,
                                       showCloseButton: true
                                   });
                                   component.set('v.spinner', false);
                                   //$A.get("e.force:closeQuickAction").fire();
                               }
                           });        
    }
})