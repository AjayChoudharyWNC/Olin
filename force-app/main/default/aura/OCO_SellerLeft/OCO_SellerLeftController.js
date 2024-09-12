({
    doInit : function(component,event, helper){
        console.log('creditType', component.get('v.creditType'));
         console.log('oldCreditType', component.get('v.oldCreditType'));
        var account = component.get('v.mainAccount');
        var salesRep = component.get('v.salesRep');
        console.log('customerStatus', component.get('v.customerStatus'));
        if(salesRep == account.OwnerId){
            component.set('v.ccEmails', account.Owner.Email);
        }
        if(account.AccountTeamMembers){
            for(var i=0;i<account.AccountTeamMembers.length;i++){
                if(salesRep == account.AccountTeamMembers[i].UserId){
                    component.set('v.ccEmails', account.AccountTeamMembers[i].User.Email);
                }
                if(account.AccountTeamMembers[i].TeamMemberRole == 'Account Manager'){
                    component.set('v.bccEmails', account.AccountTeamMembers[i].User.Email);
                    break;
                }
            }
        }
        var bccEmails = component.get('v.bccEmails');
        if(!bccEmails || !bccEmails.includes($A.get("$SObjectType.CurrentUser.Email"))){
            component.set('v.bccEmails', $A.get("$SObjectType.CurrentUser.Email"));
        }
        helper.getSapRecordDetails(component);
    },
    
    handleSapId : function(component, event, helper){
        var sapId = event.getParam('sapRecordId');
        if(sapId && !component.get('v.sapId'))
            component.set('v.sapId', sapId);
        helper.getSapRecordDetails(component);
    },
	
    cancelAll: function(component,event,helper){
        var sapId = component.get('v.sapId');
        if(confirm('You are about to cancel the entire Customer Setup Request. Do you want to do this?')){
            if(sapId){
                helper.updateSapRecords(component, event, sapId, 'No', true, false, true);
            }
            else{
                helper.showToast('All changes have been discarded successfully, now you can start over!!', 'success', 'Success');
                window.location.reload();
            }
        }
    },
    closeEmailModal : function(component, event, helper){
        component.set('v.showEmailComposer', false);
        var ciCheck = component.find('customerInfoCheck');
        //var ddCheck = component.find('documentDeliveryCheck');
        var caCheck = component.find('creditCheck');
        var psaCheck = component.find('PSAInfoCheck');
        ciCheck.set('v.disabled', false);
        //ddCheck.set('v.disabled', false);
        if (caCheck) caCheck.set('v.disabled', false);
        psaCheck.set('v.disabled', false);
    },
    sendFormToCustomer : function(component, event, helper){
        var sapRecord = component.get('v.sapRecord');
        var ciCheck = component.find('customerInfoCheck');
        //var ddCheck = component.find('documentDeliveryCheck');
        var caCheck = component.find('creditCheck');
        var psaCheck = component.find('PSAInfoCheck');
        var isCiChecked = false;
        //var isDdChecked = false;
        var isCaChecked = false;
        var isPSAChecked = false;
        
        if(sapRecord.Customer_Information_Status__c != 'Customer Submitted'){
            if(ciCheck){
                if(!ciCheck.get('v.checked')){
                    isCiChecked = false;
                    sapRecord.Customer_Information_Status__c = 'New';
                }
                else{
                    isCiChecked = true;
                    sapRecord.Customer_Information_Status__c = 'Sent To Customer';
                }
            }
            else{
                sapRecord.Customer_Information_Status__c = 'New';
                isCiChecked = false;
            }
        }
        
/*        if(sapRecord.Order_Placement_Status__c != 'Customer Submitted'){
            if(ddCheck){
                if(!ddCheck.get('v.checked')){
                    isDdChecked = false;
                    sapRecord.Order_Placement_Status__c = 'New';
                }
                else{
                    isDdChecked = true;
                    sapRecord.Order_Placement_Status__c = 'Sent To Customer';
                }
            }
            else{
                sapRecord.Order_Placement_Status__c = 'New';
                isDdChecked = false;
            }
        }*/
        
        if(sapRecord.Credit_Application_Status__c != 'Customer Submitted'){
            if(caCheck){
                if(!caCheck.get('v.checked')){
                    isCaChecked = false;
                    sapRecord.Credit_Application_Status__c = 'New';
                }
                else{
                    isCaChecked = true;
                    sapRecord.Credit_Application_Status__c = 'Sent To Customer';
                }
            }
            else{
                sapRecord.Credit_Application_Status__c = 'N/A';
                isCaChecked = false;
            }
        }
        
        if(sapRecord.Product_Stewardship_Status__c != 'Customer Submitted'){
            if(psaCheck){
                if(!psaCheck.get('v.checked')){
                    sapRecord.Product_Stewardship_Status__c = 'New';
                    isPSAChecked = false;
                }
                else{
                    isPSAChecked = true;
                    sapRecord.Product_Stewardship_Status__c = 'Sent To Customer';
                }
            }
            else{
                sapRecord.Product_Stewardship_Status__c = 'New';
                isPSAChecked = false;
            }
        }
        
        if(!isPSAChecked && !isCaChecked && !isCiChecked){
            helper.showToast('Please select at least one process to send!!', 'warning', 'Warning');
        }
        else{
            component.set('v.spinner', true);
            component.set('v.tempSapRecord', sapRecord);
            helper.getEmailTemplate(component,sapRecord);
        }
    },
    sendEmailToCustomer : function(component, event, helper){
        component.set('v.spinner', true);
        var tempSapRecord = component.get('v.tempSapRecord');
        if(tempSapRecord.Customer_Information_Status__c == 'Sent To Customer'){
            component.find('customerInfoCheck').set('v.disabled', true);
            tempSapRecord.Customer_Information_Form_Check__c = false;
        }
        /*if(tempSapRecord.Order_Placement_Status__c == 'Sent To Customer'){
            component.find('documentDeliveryCheck').set('v.disabled', true);
            tempSapRecord.Document_Delivery_Form_Check__c = false;
        }*/
        if(tempSapRecord.Credit_Application_Status__c == 'Sent To Customer'){
            component.find('creditCheck').set('v.disabled', true);
            tempSapRecord.Credit_Application_Form_Check__c = false;
        }
        if(tempSapRecord.Product_Stewardship_Status__c == 'Sent To Customer'){
            component.find('PSAInfoCheck').set('v.disabled', true);
            tempSapRecord.Product_Stewardship_Form_Check__c = false;
        }
        component.set('v.tempSapRecord', tempSapRecord);
        helper.sendEmailAndSaveFiles(component, tempSapRecord.Id);
        //helper.updateSapStatus(component);
    },
    handleCheckboxes : function(component, event, helper){
        component.set('v.spinner', true);
        var sapRecord = component.get('v.sapRecord');
        if(component.find('customerInfoCheck') && sapRecord.Customer_Information_Status__c == 'New'){
            component.find('customerInfoCheck').set('v.disabled', false);
            sapRecord.Customer_Information_Form_Check__c = true;
        }
       /* if(component.find('documentDeliveryCheck') && sapRecord.Order_Placement_Status__c == 'New'){
            component.find('documentDeliveryCheck').set('v.disabled', false);
            sapRecord.Document_Delivery_Form_Check__c = true;
        } */
        if(component.find('creditCheck') && sapRecord.Credit_Application_Status__c == 'New'){
            component.find('creditCheck').set('v.disabled', false);
            sapRecord.Credit_Application_Form_Check__c = true;
        }
        if(component.find('PSAInfoCheck') && sapRecord.Product_Stewardship_Status__c == 'New'){
            component.find('PSAInfoCheck').set('v.disabled', false);
            sapRecord.Product_Stewardship_Form_Check__c = true;
        }
        component.set('v.tempSapRecord', sapRecord);
        //helper.updateSapStatus(component);
        component.set('v.spinner', false);
    },
    
     handleFileChange : function(component, event, helper){
        var files = event.getSource().get('v.files');
        var shareFiles = component.get('v.shareFileList');
        var self = this;
        if(files.length > 0){
            for(var i=0;i<files.length;i++){
                shareFiles.push(files[i]);
            }
        }
        component.set('v.shareFileList', shareFiles);
    },
    
    removeFile : function(component, event, helper){
        var indx = event.getSource().get('v.id');
        var shareFileList = component.get('v.shareFileList');
        shareFileList.splice(indx, 1);
        component.set('v.shareFileList', shareFileList);
    }
})