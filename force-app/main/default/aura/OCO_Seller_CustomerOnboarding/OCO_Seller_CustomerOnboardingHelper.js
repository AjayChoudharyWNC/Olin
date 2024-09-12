({
    fetchSapRecord: function (component) {
        var action = component.get('c.fetchRecord');
        action.setParams({
            "soldToAccId": component.get('v.recordId'),
            "shipToAccId": component.get('v.sapType') == 'Modify Ship-To' ? component.get('v.selectedShipToAccounts')[0] : ''
        });
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                component.set('v.sapRecord', response.getReturnValue());
                component.set('v.spinner', false);
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchCustomerSetupRecord : function(component, event){
        var action = component.get('c.fetchSapRecord');
        action.setParams({
            sapId : component.get('v.sapId')
        });
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                component.set('v.existingSapRecord', response.getReturnValue());
                //component.set('v.spinner', false);
            }
        });
        $A.enqueueAction(action);
    },
    
    fatchConData: function(component,event,conId){
        var contId = conId;
        if(Array.isArray(conId)){
            contId = conId[0];
        }
        var action = component.get('c.fetchContactRec');
        action.setParams({contId: contId});
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                //if SUCCESS then saves the Applicant
                var result = response.getReturnValue();
                //if(!fieldName){
                component.set('v.conRecord',result);
               /* if(result.Application_User__r && result.Application_User__r.length > 0){
                    component.set('v.showAppUser', false);
                }
                else{
                    component.set('v.showAppUser', true);
                }*/
                /*}
                else{
                    this.populateFieldValues(component, fieldName, result,sectionNumber, sapCount);
                }*/
            }
            else if (state === "ERROR") {
                this.errorHandling(component,response);
            }
        });
        $A.enqueueAction(action);
        var getContacts = component.get('c.getRelatedContact');
        getContacts.setParams({
            soldToAccId : component.get('v.recordId')
        });
        getContacts.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                component.set('v.relatedContacts', response.getReturnValue());
            }
            component.set('v.spinner',false);
        });
        $A.enqueueAction(getContacts);
    },
    
    updateSapRecords : function(component, event, sapId, sendEmail, isLast, sendToSap, cancelSap){
        component.set('v.spinner', true);
        var action = component.get('c.updateSapOnboarding');
        action.setParams({
            "sapId" :  sapId,
            "sendEmail" : sendEmail,
            "sendToSap" : sendToSap,
            "cancelSap" : cancelSap
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                if(isLast){
                    component.set('v.spinner', false);
                    if(!sendToSap && sendEmail){
                        this.showToast('Form has been sent to customer !!', 'success', 'Success');
                        $A.get("e.force:closeQuickAction").fire();
                        window.location.reload();
                    }
                    else{
                        this.showToast('Form has been sent to SAP!!', 'success', 'Success');
                        
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    
    showToast : function(message,type,title){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title" : title,
            "message": message,
            "duration": "5000",
            "key": "info_alt",
            "type": type,
            "mode": "dismissible"
        });
        toastEvent.fire();
    },

    populateContactFields: function (component, fieldName, value) {
        var contacts = component.get('v.relatedContacts');
        var con;
        for (var i = 0; i < contacts.length; i++){
            if (value == contacts[i].Id) {
                con = contacts[i];
            }
        }
        var sapRecord = component.get('v.sapRecord');
        if (value && fieldName == 'Order_Placement_Contact__c') {
            sapRecord.Order_Placement_Contact__c = con.Id;
            sapRecord.Order_Placement_First_Name__c = con.FirstName;
            sapRecord.Order_Placement_Last_Name__c = con.LastName;
            sapRecord.Order_Placement_Title__c = con.Title;
            sapRecord.Order_Placement_Phone__c = con.Phone;
            sapRecord.Order_Placement_Email__c = con.Email;

        }
        else if (!value && fieldName == 'Order_Placement_Contact__c') {
            sapRecord.Order_Placement_Contact__c = '';
            sapRecord.Order_Placement_First_Name__c = '';
            sapRecord.Order_Placement_Last_Name__c = '';
            sapRecord.Order_Placement_Title__c = '';
            sapRecord.Order_Placement_Phone__c = '';
            sapRecord.Order_Placement_Email__c = '';
        }

        if (value && fieldName == 'Contract_Notification_Contact__c') {
            sapRecord.Contract_Notification_Contact__c = con.Id;
            sapRecord.Contract_Notification_First_Name__c = con.FirstName;
            sapRecord.Contract_Notification_Last_Name__c = con.LastName;
            sapRecord.Contract_Notification_Title__c = con.Title;
            sapRecord.Contract_Notification_Phone__c = con.Phone;
            sapRecord.Contract_Notification_Email__c = con.Email;

        }
        else if (!value && fieldName == 'Contract_Notification_Contact__c') {
            sapRecord.Contract_Notification_Contact__c = '';
            sapRecord.Contract_Notification_First_Name__c = '';
            sapRecord.Contract_Notification_Last_Name__c = '';
            sapRecord.Contract_Notification_Title__c = '';
            sapRecord.Contract_Notification_Phone__c = '';
            sapRecord.Contract_Notification_Email__c = '';
        }

        if (value && fieldName == 'Account_Payable_Contact__c') {
            sapRecord.Account_Payable_Contact__c = con.Id;
            sapRecord.Account_Payable_First_Name__c = con.FirstName;
            sapRecord.Account_Payable_Last_Name__c = con.LastName;
            sapRecord.Account_Payable_Title__c = con.Title;
            sapRecord.Account_Payable_Phone__c = con.Phone;
            sapRecord.Account_Payable_Email__c = con.Email;

        }
        else if (!value && fieldName == 'Account_Payable_Contact__c') {
            sapRecord.Account_Payable_Contact__c = '';
            sapRecord.Account_Payable_First_Name__c = '';
            sapRecord.Account_Payable_Last_Name__c = '';
            sapRecord.Account_Payable_Title__c = '';
            sapRecord.Account_Payable_Phone__c = '';
            sapRecord.Account_Payable_Email__c = '';
        }

        if (value && fieldName == 'Email_Invoice_Contact__c') {
            sapRecord.Email_Invoice_Contact__c = con.Id;
            sapRecord.Email_Invoice_First_Name__c = con.FirstName;
            sapRecord.Email_Invoice_Last_Name__c = con.LastName;
            sapRecord.Email_Invoice_Title__c = con.Title;
            sapRecord.Email_Invoice_Phone__c = con.Phone;
            sapRecord.Email_Invoice_Email_Address__c = con.Email;

        }
        else if (!value && fieldName == 'Email_Invoice_Contact__c') {
            sapRecord.Email_Invoice_Contact__c = '';
            sapRecord.Email_Invoice_First_Name__c = '';
            sapRecord.Email_Invoice_Last_Name__c = '';
            sapRecord.Email_Invoice_Title__c = '';
            sapRecord.Email_Invoice_Phone__c = '';
            sapRecord.Email_Invoice_Email_Address__c = '';
        }

        if (value && fieldName == 'Credit_Contact__c') {
            sapRecord.Credit_Contact__c = con.Id;
            sapRecord.Credit_First_Name__c = con.FirstName;
            sapRecord.Credit_Last_Name__c = con.LastName;
            sapRecord.Credit_Title__c = con.Title;
            sapRecord.Credit_Phone__c = con.Phone;
            sapRecord.Credit_Email__c = con.Email;

        }
        else if (!value && fieldName == 'Credit_Contact__c') {
            sapRecord.Credit_Contact__c = '';
            sapRecord.Credit_First_Name__c = '';
            sapRecord.Credit_Last_Name__c = '';
            sapRecord.Credit_Title__c = '';
            sapRecord.Credit_Phone__c = '';
            sapRecord.Credit_Email__c = '';
        }

        if (value && fieldName == 'CXO_Officer_Contact__c') {
            sapRecord.CXO_Officer_Contact__c = con.Id;
            sapRecord.CXO_Officer_First_Name__c = con.FirstName;
            sapRecord.CXO_Officer_Last_Name__c = con.LastName;
            sapRecord.CXO_Officer_Title__c = con.Title;
            sapRecord.CXO_Officer_Phone__c = con.Phone;
            sapRecord.CXO_Officer_Email__c = con.Email;

        }
        else if (!value && fieldName == 'CXO_Officer_Contact__c') {
            sapRecord.CXO_Officer_Contact__c = '';
            sapRecord.CXO_Officer_First_Name__c = '';
            sapRecord.CXO_Officer_Last_Name__c = '';
            sapRecord.CXO_Officer_Title__c = '';
            sapRecord.CXO_Officer_Phone__c = '';
            sapRecord.CXO_Officer_Email__c = '';
        }
        component.set('v.sapRecord', sapRecord);
    }
    
})