({
    doInit : function(component, event, helper) {
        component.set("v.spinner", false);
        var value = component.get('v.sapType');
        var recordType = '';
        if(value == 'New Sold-To w/Ship-To & Product' || value == 'New Ship-To & Product'){
            recordType =  'Prospect Location';
        }
        helper.fetchShipToAccounts(component, event, recordType);
        helper.fetchRelatedProds(component, event, '');
        helper.getInitialData(component,event);
    },
  
    handleMainConChange : function(component, event, helper){
        var relatedContacts = component.get('v.relatedContacts');
        var mainCon = component.get('v.mainOnboardContact');
        for(var i = 0;i<relatedContacts.length;i++){
            if(relatedContacts[i].Id == mainCon){
                component.set('v.conRecord', relatedContacts[i]);
                break;
            }
        }
    },
    handlePreNext: function (component, event, helper) {
        var selectedShipTos = [];
        var shipToSelect = document.getElementById('shipToAccounts');
        var options = shipToSelect.options;
        for(var i=0;i<options.length;i++){
            if(options[i].selected){
                selectedShipTos.push(options[i].value);
            }
        }
        var selectedCSR = component.find('CSR_Mgr__c');
        if(selectedCSR){
            if(Array.isArray(selectedCSR)){
                selectedCSR = selectedCSR[0].get('v.value');;
            }
            else{
                selectedCSR = selectedCSR.get('v.value');
            }
            
            if(Array.isArray(selectedCSR)){
                selectedCSR = selectedCSR[0];
            }
            component.set('v.selectedCSR', selectedCSR);
        }
        else{
            component.set('v.selectedCSR', null);
        }
        var mainAccount = component.get('v.mainAccount');
        var sapType = component.get('v.sapType');
        var selectedUser = component.get('v.selectedUser');
        var relatedContacts = component.get('v.relatedContacts');
        var mainOnbaordConId = component.get('v.mainOnboardContact');
        var selectedSalesOrg = component.get('v.selectedSalesOrg');
        var isCusType = component.get('v.isCusTypeDisabled');
        var isSalesOrg = component.get('v.isSalesOrgDisabled');
        var estDate = component.get('v.estDate');
        var cusType = component.get('v.cusType');
        var dueDate = component.get('v.dueDate');
        var hasError = false;
        if(sapType == 'Modify Sold-To' || sapType == 'Modify Ship-To' || sapType == 'Modify Global Customer' || sapType == 'Update Sales Org'){
            component.set('v.showAppUser',false);
        }
        else{
            component.set('v.showAppUser',true);
        }
        if(selectedShipTos.length == 0 && sapType != 'Modify Sold-To'){
            helper.showToast('Ship To Account is missing !!', 'error', 'Error');
            hasError = true;
        }
        if(estDate < dueDate){
            helper.showToast('Estimate Date of First Shipment can not be before Form Due Date !!', 'error', 'Error');
            hasError = true;
        }
        if (!selectedUser) {
            helper.showToast('Sales Rep is missing !!', 'error', 'Error');
            hasError = true;
        }
        if(component.find('CSR_Mgr__c')){
            if(!selectedCSR){
                helper.showToast('CSR is missing !!', 'error', 'Error');
                hasError = true;
            }
        }
        if (!estDate && sapType == 'New Ship-To & Product') {
            helper.showToast('Estimate Date Of First Shipment is missing !!', 'error', 'Error');
            hasError = true;
        }
        
        if(!dueDate){
            hasError = true;
            helper.showToast('Due date is missing!!', 'error', 'Error');
        }
        if(!cusType && !isCusType){
            hasError = true;
            helper.showToast('Customer type is missing!!', 'error', 'Error');
        }
        if(!mainOnbaordConId){
            hasError = true;
            helper.showToast('Main Onboarding contact is missing!!', 'error', 'Error');
        }
        if(!selectedSalesOrg && !isSalesOrg){
            hasError = true;
            helper.showToast('Sales Org is missing!!', 'error', 'Error');
        }
        else{
            var mainCon;
            for(var i=0;i<relatedContacts.length;i++){
                if(mainOnbaordConId == relatedContacts[i].Id){
                    mainCon = relatedContacts[i];
                    break;
                }
            }
            if(mainCon){
                if(!mainCon.Email || mainCon.Email == ''){
                    hasError = true;
                    helper.showToast('Main Onboarding contact\'s email is missing!!', 'error', 'Error');
                }
            }
        }
        if(hasError){
            console.log('error in first screen');
        }
        else{
            component.set('v.spinner', true);
            component.set('v.selectedShipToAccounts', selectedShipTos);
            var mainOnboardcon = component.get('v.mainOnboardContact');
            component.set("v.sapType", sapType);
            if (component.get('v.creditType') == 'No Credit') {
                component.set('v.spinner', true);
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
                var sapRecord = {
                    "sObjectType": 'SAP_Onboarding__c',
                    "On_boarding_Request_Type__c": sapType,
                    "Sales_Organization__c": selectedSalesOrg,
                    "Customer_Type__c": cusType,
                    "Form_Due_Date__c": dueDate,
                    "Estimated_Date_of_First_Shipment__c": estDate,
                    "Main_Onboarding_Contact__c": mainOnbaordConId,
                    "Account__c": component.get('v.recordId'),
                    "Sales_Rep__c": selectedUser,
                    "Customer_Service_Rep__c" : mainAccount.RecordType.Name != 'Prospect' ? selectedCSR : null ,
                    "Status__c": 'In Progress',
                    "Ship_To_Accounts__c" : shipToString
                };

                helper.saveSapRecord(component, sapRecord);
            }
            else {
                component.set("v.screen", 'post');
                component.set('v.spinner', false);
            }
        }
        console.log('selectedShipTos',selectedShipTos);
    },    

    hideSpinner : function(component, event, helper){
       // component.set('v.spinner', false);
    },
    
    handleSapType : function(component, event, helper){
        var value = event.getSource().get('v.value');
        component.set('v.sapType', value);
        if(value == 'Modify Ship-To'){
            component.set('v.isMultipleShipTo', false);
        }
        else{
            component.set('v.isMultipleShipTo', true);
        }
        if(value == 'Modify Sold-To' || value == 'Modify Ship-To'){
            component.set('v.showInfo', false);
        }
        else{
             component.set('v.showInfo', true);
        }
        if(value == 'New Sold-To w/Ship-To & Product' || value == 'New Ship-To & Product'){
            helper.fetchShipToAccounts(component, event, 'Prospect Location');
        }
        else if(value == 'Modify Ship-To' || value == 'New Product'){
            helper.fetchShipToAccounts(component, event, 'Customer Location');
        }
        else{
             helper.fetchShipToAccounts(component, event, '');
        }
    }
})