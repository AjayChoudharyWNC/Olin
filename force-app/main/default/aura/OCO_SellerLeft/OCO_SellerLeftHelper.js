({
    MAX_FILE_SIZE: 4500000, //Max file size 4.5 MB 
    CHUNK_SIZE: 750000, //Chunk Max size 750Kb 
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
                    if(cancelSap){
                        this.showToast('All changes have been discarded successfully, now you can start over!!', 'success', 'Success');
                        window.location.reload();//$A.get("e.force:closeQuickAction").fire();
                    }
                    if (!cancelSap && sendEmail) {
                        window.location.reload();// $A.get("e.force:closeQuickAction").fire();
                        this.showToast('Form has been sent to customer !!', 'success', 'Success');
                        
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    getSapRecordDetails : function(component){
        if(component.get('v.sapId') && component.get('v.sapId') != ''){
            component.set('v.spinner', true);
            var action = component.get('c.fetchSapRecord');
            action.setParams({
                "sapId" : component.get('v.sapId')
            });
            action.setCallback(this, function (response) {
                if (response.getState() === "SUCCESS") {
                    var sapRecord = response.getReturnValue();
                    component.set('v.customerStatus', sapRecord.Customer_Status__c);
                    if(!sapRecord.Order_Placement_Status__c){
                        sapRecord.Order_Placement_Status__c = 'New';
                    }
                    if(!sapRecord.Product_Stewardship_Status__c){
                        sapRecord.Product_Stewardship_Status__c = 'New';
                    }
                    if(!sapRecord.Credit_Application_Status__c){
                        sapRecord.Credit_Application_Status__c = 'New';
                    }
                    if(component.get('v.oldCreditType') && component.get('v.oldCreditType') != component.get('v.creditType')){
                        sapRecord.Credit_Application_Status__c = 'New';
                    }
                    if(component.get('v.creditType') != 'No Credit' && sapRecord.Credit_Application_Status__c == 'N/A'){
                        sapRecord.Credit_Application_Status__c = 'New';
                    }
                    component.set('v.sapRecord',sapRecord);
                    var emailSubject = 'Olin Customer Setup ('+sapRecord.Name+') - '+sapRecord.Full_Legal_Name__c+', ';
                    if(sapRecord.Onboarding_Ship_To__r){
                        if(sapRecord.Onboarding_Ship_To__r[0].Ship_To_City__c){
                            emailSubject += sapRecord.Onboarding_Ship_To__r[0].Ship_To_City__c;
                        }
                        if(sapRecord.Onboarding_Ship_To__r[0].Ship_To_State_Province__c){
                            emailSubject += ' '+sapRecord.Onboarding_Ship_To__r[0].Ship_To_State_Province__c;
                        }
                        if(sapRecord.Onboarding_Ship_To__r[0].Ship_To_Country__c){
                            emailSubject += ', '+sapRecord.Onboarding_Ship_To__r[0].Ship_To_Country__c;
                        }                    }
                    component.set('v.emailSubject', emailSubject);
                    component.set('v.toEmails', sapRecord.Main_Onboarding_Contact__r.Email);
                    component.set('v.spinner', false);
                }
            });
            $A.enqueueAction(action);
        }
    },
    getEmailTemplate : function(component, sapRecord){
        this.getSapRecordDetails(component);
        var action = component.get('c.getTemplateDetails');
        action.setParams({
            'sapRecord' : sapRecord,
            'language' : component.get('v.selectedLanguage')
        });
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS'){
                var template = response.getReturnValue();
                component.set('v.emailTemplate', template);
                if(template.Subject){
                    //component.set('v.emailSubject', template.Subject);
                }
                if(template.HtmlValue){
                    component.set('v.emailBody', template.HtmlValue);
                }
                if(template.Subject && template.Subject != ''){
                    component.set('v.showEmailComposer', true);
                }
                else{
                    this.showToast('Please select a new process to send to customer', 'warning', 'Warning');
                }
                component.set('v.spinner', false);
            }
        });
        $A.enqueueAction(action);
    },
    updateSapStatus : function(component){
        //sapRecord.Send_Invitation_Email_to_Main_Contact__c = 'Yes';
        var files = component.get('v.shareFileList');
        var action = component.get('c.updateSapOnboardingStatus');
        action.setParams({
            'sapRecord' : component.get('v.tempSapRecord'),
            "emailBody" : component.get('v.emailBody'),
            "emailSubject" : component.get('v.emailSubject'),
            "toEmails" : component.get('v.toEmails'),
            "ccEmails" : component.get('v.ccEmails'),
            "bccEmails" : component.get('v.bccEmails'),
            "template" : component.get('v.emailTemplate')
        });
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS'){
                component.set('v.sapRecord', response.getReturnValue());
                component.set('v.showEmailComposer', false);
                component.set('v.oldCreditType', component.get('v.creditType'));
                if(component.get('v.emailTemplate'))
                    this.showToast('Form has been sent to customer !!', 'success', 'Success');
                component.set('v.spinner', false);
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
    
    sendEmailAndSaveFiles : function (component, toRecordId){
        var shareFiles = component.get('v.shareFileList');
        if(shareFiles){
            var fileCount = shareFiles.length;
            if (fileCount > 0) {
                for (var i = 0; i < fileCount; i++) 
                {
                    this.uploadHelper(component, event,shareFiles[i], 'Share Colleague File', toRecordId, i==fileCount-1 ? true : false);
                }
            }
            else{
                this.updateSapStatus(component);
            }
        }
    },
    
    uploadHelper: function (component, event, f, fileType, parentId, isLast) {
        var file = f;
        var self = this;
        // check the selected file size, if select file size greter then MAX_FILE_SIZE,
        // then show a alert msg to user,hide the loading spinner and return from function  
        if (file.size > self.MAX_FILE_SIZE) {
            alert('File size exceeded!');
            return;
        }
        
        // Convert file content in Base64
        var objFileReader = new FileReader();
        objFileReader.onload = $A.getCallback(function () {
            var fileContents = objFileReader.result;
            var base64 = 'base64,';
            var dataStart = fileContents.indexOf(base64) + base64.length;
            fileContents = fileContents.substring(dataStart);
            self.uploadProcess(component, file, fileContents, fileType, parentId, isLast);
        });
        
        objFileReader.readAsDataURL(file);
    },
    
    uploadProcess: function (component, file, fileContents, fileType, parentId, isLast) {
        // set a default size or startpostiton as 0 
        var startPosition = 0;
        // calculate the end size or endPostion using Math.min() function which is return the min. value   
        var endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
        
        // start with the initial chunk, and set the attachId(last parameter)is null in begin
        this.uploadInChunk(component, file, fileContents, startPosition, endPosition, '', fileType,  parentId, isLast);
    },
    
    
    uploadInChunk: function (component, file, fileContents, startPosition, endPosition, attachId, fileType,  parentId, isLast) {
        // call the apex method 'saveFile'
        var getchunk = fileContents.substring(startPosition, endPosition);
        var action = component.get("c.saveFile")
        action.setParams({
            // Take current object's opened record. You can set dynamic values here as well
            parentId: parentId,
            fileName: file.name,
            base64Data: encodeURIComponent(getchunk),
            contentType: file.type,
            fileId: attachId,
            description: fileType
        });
        
        // set call back 
        action.setCallback(this, function (response) {
            attachId = response.getReturnValue();
            var state = response.getState();
            if (state === "SUCCESS") {
                // update the start position with end postion
                startPosition = endPosition;
                endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
                if (startPosition < endPosition) {
                    this.uploadInChunk(component, file, fileContents, startPosition, endPosition, attachId, fileType,parentId, isLast);
                } else {
                    if(isLast){
                        this.updateSapStatus(component);
                    }
                }
                // handel the response errors        
            } else if (state === "INCOMPLETE") {
                console.log("From server: " + response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    }

})