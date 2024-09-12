({
    doInit : function(component, event, helper) {
        component.set("v.spinner", true);
        var layoutName = '';
        helper.fatchConData(component, event, component.get('v.mainOnboardContact'));
        var sapType = component.get('v.sapType');
        console.log('recordId==', component.get('v.recordId'),'sapType====', sapType, 'maincon==',component.get('v.mainOnboardContact'), 'salesOrg===',component.get('v.selectedSalesOrg'), 'sapId=====', component.get('v.sapId'));
        if(!component.get('v.sapId')){
            component.set('v.sapId', '');
        }
        else{
            helper.fetchCustomerSetupRecord(component);
        }
        helper.fetchSapRecord(component);
    },
    
    handleSubmitSap: function (component, event, helper) {
        event.preventDefault();
        var sapRecord = component.get('v.sapRecord');
        var fields = event.getParam('fields');
        var shipTos = component.get('v.selectedShipToAccounts');
        var shipToString = '';
        for (var i = 0; i < shipTos.length; i++){
            if (i == 0) {
                shipToString += shipTos[i];
            }
            else {
                shipToString += ';' + shipTos[i];
            }
        }
        fields['Ship_To_Accounts__c'] = shipToString;
        fields['Sales_Rep__c'] = component.get('v.salesRep');
        fields['Sales_Organization__c'] = component.get('v.selectedSalesOrg');
        if(component.get('v.creditType') == 'Partial'){
            fields['SAP_S_4_No_Sold_To__c'] = sapRecord.SAP_S_4_No_Sold_To__c;
            fields['Sold_To_Company_Name__c'] = sapRecord.Sold_To_Company_Name__c;
            fields['Sold_To_Street__c'] = sapRecord.Sold_To_Street__c;
            fields['Sold_To_Street_2__c'] = sapRecord.Sold_To_Street_2__c;
            fields['Sold_To_City__c'] = sapRecord.Sold_To_City__c;
            fields['Sold_To_State_Province__c'] = sapRecord.Sold_To_State_Province__c;
            fields['Sold_To_Postal_Code__c'] = sapRecord.Sold_To_Postal_Code__c;
            fields['Sold_To_Country__c'] = sapRecord.Sold_To_Country__c;
        }
        component.find('onboardForm').submit(fields);
        component.set('v.spinner', true);
    },
    
    handleSuccessSap : function(component, event, helper){
        var sap = event.getParams();
        var sapId = sap.response.id;
        var fields = sap.response.fields;
        var sapType = component.get('v.sapType');
        component.set('v.sapId', sapId);
        var updateSapEvt = $A.get('e.c:OCO_Seller_UpdateSapIdInLeft');
        updateSapEvt.setParams({
            'sapRecordId' : sapId
        });
        updateSapEvt.fire();
        component.set('v.oldCreditType', component.get('v.creditType'));
        if(component.find('ApplicationUser1'))
            component.find('ApplicationUser1').submit();
        if(component.get('v.sapType') == 'Modify Sold-To' || component.get('v.sapType') == 'Modify Ship-To'){
            helper.showToast('Customer Setup saved successfully, Now you can click on Save Form!!', 'success', 'Success');
        }
        else{
            helper.showToast('Sold-To details saved. Now click on \'Go To Ship-To\'s button\' !!', 'success', 'Success');
        }
        if(sapType == 'Modify Ship-To' || sapType == 'Modify Sold-To'){
            // component.find('sapSendButton').set('v.disabled', false);
            if(component.get('v.checkForFinalButton'))
                component.find('finalSubmitBtn').set('v.disabled', false);
        }
        component.set('v.spinner', false);
        
    },

    handleValueChange: function (component, event, helper) {
        var fieldName = event.getSource().getLocalId();
        var value = event.getSource().get('v.value');
        helper.populateContactFields(component, fieldName, value);
    },

    handleApplicationUserSuccess: function (component, event, helper) {
        
    },
    
    handleSoldToCopy : function(component, event, helper){
        var sapRecord = component.get('v.sapRecord');
        sapRecord.Parent_Company_Name__c = sapRecord.Sold_To_Company_Name__c;
        sapRecord.Parent_Street__c = sapRecord.Sold_To_Street__c;
        sapRecord.Parent_Street_2__c = sapRecord.Sold_To_Street_2__c;
        sapRecord.Parent_City__c = sapRecord.Sold_To_City__c;
        sapRecord.Parent_State_Province__c = sapRecord.Sold_To_State_Province__c;
        sapRecord.Parent_Postal_Code__c = sapRecord.Sold_To_Postal_Code__c;
        sapRecord.Parent_Country__c = sapRecord.Sold_To_Country__c;
        component.set('v.sapRecord', sapRecord);
    },
    
    handleError : function(component, event, helper){
        console.log(JSON.stringify(event.getParams()));
        //helper.showToast('Either required fields are missing or Some connectivity issue!!', 'error', 'Error');
    },
    
    openShipTos : function(component, event, helper){
        component.set('v.showOnboardingShipTo', true);
    },
    
    sendToSap: function(component,event,helper){
        var sapId = component.get('v.sapId');
        helper.updateSapRecords(component, event, sapId, 'No', true, true, false);
    },
    
    finalSubmit : function(component, event, helper){
        var checkboxEvent = $A.get('e.c:OCO_Seller_CheckboxUpdateEvt');
        checkboxEvent.fire();
        component.set('v.checkForFinalButton', false);
        component.find('finalSubmitBtn').set('v.disabled',true);
        helper.showToast('Customer Setup form has been saved successfully, you may now send this Form to customer', 'success', 'Success');
    }
})