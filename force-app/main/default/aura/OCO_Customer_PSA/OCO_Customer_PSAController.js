({
    doInit : function(component, event, helper) {
        component.set('v.showCmp', false);
        component.set('v.showCmp', true);
        if(component.get('v.prodId')){
            helper.fetchQuestionnaires(component);
            helper.fetchProductDetails(component);
            helper.checkForAllSections(component, event);
        }
        
    },
    handleSaveProgress : function(component, event, helper){
        component.set('v.spinner', true);
        var response = helper.uploadFiles(component);
        if(response != 'sizeError'){
            var psaForms = component.find('PSAForm');
            if(psaForms){
                if(Array.isArray(psaForms)){
                    psaForms.forEach(function(e){
                        e.submit();
                    });
                }
                else{
                    psaForms.submit();
                }
            }
            var oprForms = component.find('oprForm');
            if(oprForms){
                if(Array.isArray(oprForms)){
                    oprForms.forEach(function(e){
                        e.submit();
                    });
                }
                else{
                    oprForms.submit();
                }
            }
            //component.find('oprForm').submit();
            component.set('v.isFormSubmitManual', true);
            //helper.handleSaveProgress(component);
        }
    },
    
    handleProdFormSuccess : function(component, event, helper) {
        var sap = event.getParams().response;
        var parent = component.get('v.parent');
        var quesList = component.get('v.questionnaireList');
        console.log('sapId',sap,sap.id);
        helper.checkForAllSections(component, event);
        if(sap.id && !component.get('v.isFormSubmitManual')){
            if(quesList.length == 0){
                component.set('v.spinner', false);
                parent.openToast('utility:success', 'JS_20', 'success');
            }
            window.setTimeout(
                $A.getCallback(function() {
                    var parent  = component.get('v.parent');
                    if(parent)
                    parent.getSapRecord();
                    var sapRecord = component.get('v.sapRecord');
                    var appEvent = $A.get("e.c:OCO_CustomerTreeClick");
                    appEvent.setParams({ "nodeClicked" : 'PS', "nodeId": sapRecord.Id, "sapNo": sapRecord.Name});
                    appEvent.fire();
                }), 
                2000
            );
            
        }
        else{
            component.set('v.spinner', false);
            parent.openToast('utility:success', 'JS_21', 'success');
        }
    },
    
    handleQuesFormSuccess : function(component, event, helper){
        component.set('v.spinner', false);
        var ques = event.getParams().response;
        if(ques.id){
            var parent = component.get('v.parent');
            if(!component.get('v.isFormSubmitManual')){
                var ques = {
                    "sObjectType" : "Questionnaire__c",
                    "Id" : ques.id,
                    "Questionnaire_Section_Completed__c" : true
                    
                };
                helper.saveQuestionnaireRecord(component, true, '', [ques]);
                parent.openToast('utility:success', 'JS_20', 'success');
                window.setTimeout(
                    $A.getCallback(function() {
                        var parent  = component.get('v.parent');
                        if(parent)
                            parent.getSapRecord();
                    }), 
                    3000
                );
            }
            else{
                parent.openToast('utility:success', 'JS_21', 'success');
            }
        }
        
    },
    
    handleFormSubmit : function(component, event, helper){
        event.preventDefault();
        var oprForm = component.find('oprForm');
        var setupValue = component.get('v.setupValue');
        if(!setupValue && component.find('setupType')){
            component.find('setupType').showHelpMessageIfInvalid();
        }
        else{
            var fields = event.getParam('fields');
            fields['Product_Section_Completed__c'] = true;
            fields['All_Questionnaire_Completed__c'] = true;
            var isOffline = component.get('v.isOffline');
            var quesDocFileList = component.get('v.quesDocFileList');
            if(isOffline){
                var hasError = false;
                var psaForms = component.find('PSAForm');
                var ques = component.get('v.mainQuestionnaire');
                ques.Questionnaire_Section_Completed__c = true;
                var childCmps = component.find('childCmp');
                if(childCmps){
                    var requiredFields = [];
                    if(component.find('psaField')){
                        requiredFields = requiredFields.concat(component.find('psaField'));
                    }
                    if(Array.isArray(childCmps)){
                        childCmps.forEach(function(e){
                            if(e.getElements().length > 0)
                                requiredFields = requiredFields.concat(e.find('psaField'));
                        });
                    }
                    else{
                        requiredFields = requiredFields.concat(childCmps.find('psaField'));
                    }
                    for(var i = 0; i<requiredFields.length;i++){
                        if(requiredFields[i].get('v.required') && !requiredFields[i].get('v.value')){
                            hasError = true;
                            requiredFields[i].reportValidity();
                            requiredFields[i].focus();
                            break;
                        }
                    }
                }
                if(!hasError){
                    if(quesDocFileList.length == 0){
                        var fileInput = component.find('quesDocFile');
                        var languageMap = component.get('v.languageLabelMap');
                        if(fileInput){
                            if(Array.isArray(fileInput)){
                                fileInput[0].setCustomValidity(languageMap['JS_22']);
                                fileInput[0].reportValidity();
                                fileInput[0].focus();
                            }
                            else{
                                fileInput.setCustomValidity(languageMap['JS_22']);
                                fileInput.reportValidity();
                                fileInput.focus();
                            }
                        }
                    }
                    else{
                        var fileResponse = helper.uploadFiles(component);
                        if(fileResponse != "sizeError"){
                            if(psaForms){
                                if(Array.isArray(psaForms)){
                                    psaForms.forEach(function(e){
                                        e.submit();
                                    });
                                }
                                else{
                                    psaForms.submit();
                                }
                            }
                            component.set('v.spinner', true);
                            component.set('v.isFormSubmitManual', false);
                            if(Array.isArray(oprForm)){
                                oprForm[0].submit(fields);
                            }
                            else{
                                oprForm.submit(fields);
                            }
                            component.set('v.mainQuestionnaire', ques);
                            helper.handleSaveProgress(component);
                        }
                    }
                }
            }
            else{ 
                var quesList = component.get('v.questionnaireList');
                if(quesList.length == 0){
                    component.set('v.spinner', true);
                    component.set('v.isFormSubmitManual', false);
                    if(Array.isArray(oprForm)){
                        oprForm[0].submit(fields);
                    }
                    else{
                        oprForm.submit(fields);
                    }
                }
                else{
                    var fileInput = component.find('quesDocFileForTruck');
                    if(quesDocFileList.length == 0 && fileInput){
                        var languageMap = component.get('v.languageLabelMap');
                        if(fileInput){
                            if(Array.isArray(fileInput)){
                                fileInput.forEach(function(input){
                                    input.setCustomValidity(languageMap['JS_22']);
                                    input.reportValidity();
                                    input.focus();
                                });
                            }
                            else{
                                fileInput.setCustomValidity(languageMap['JS_22']);
                                fileInput.reportValidity();
                                fileInput.focus();
                            }
                        }
                    }
                    var requiredFields = [];
                    var childCmps = component.find('childCmp');
                    if(childCmps){
                        if(Array.isArray(childCmps)){
                            childCmps.forEach(function(e){
                                if(e.getElements().length > 0)
                                    requiredFields = requiredFields.concat(e.find('psaField'));
                            });
                        }
                        else{
                            requiredFields = requiredFields.concat(childCmps.find('psaField'));
                        }
                    }
                    if(component.find('psaField')){
                        requiredFields = requiredFields.concat(component.find('psaField'));
                    }
                    
                    var hasError = false;
                    var psaForms = component.find('PSAForm');
                    for(var i = 0; i<requiredFields.length;i++){
                        if(requiredFields[i].get('v.required') && !requiredFields[i].get('v.value')){
                            hasError = true;
                            requiredFields[i].reportValidity();
                            requiredFields[i].focus();
                            break;
                        }
                    }
                    if(!hasError){
                        var fileResponse = helper.uploadFiles(component);
                        if(fileResponse != 'sizeError'){
                            if(Array.isArray(psaForms)){
                                psaForms.forEach(function(e){
                                    e.submit();
                                });
                            }
                            else{
                                psaForms.submit();
                            }
                            if(Array.isArray(oprForm)){
                                oprForm[0].submit(fields);
                            }
                            else{
                                oprForm.submit(fields);
                            }
                            component.set('v.spinner', true);
                            component.set('v.isFormSubmitManual', false);
                        }
                    }
                }
            }
        }
    },
    handleSaveProgressOffline : function(component, event, helper){
        var quesDocFileList = component.get('v.quesDocFileList');
        if(quesDocFileList.length == 0){
            var parent = component.get('v.parent');
            parent.openToast('utility:warning', 'JS_23', 'warning');
        }
        else{
            component.set('v.spinner', true);
            helper.uploadFiles(component);
        }
    },
    
    handleShareWithColleague : function(component, event, helper){
        var parent = component.get('v.parent');
        parent.openShareWithColleague();
    },
    handleConfirmDialog : function(component, event, helper){
        var name = event.getSource().get('v.name');
        if(name == 'No'){
            component.set('v.showConfirmDialog', false);
        }
        if(name == 'switchQues'){
            helper.quesSwitchOffline(component);
            component.set('v.showConfirmDialog', false);
        }
        if(name == 'deleteFile'){
            helper.handleFileDelete(component);
            component.set('v.showConfirmDialog', false);
        }
        if(name == 'deleteQues'){
            helper.handleDeleteQues(component);
            component.set('v.showConfirmDialog', false);
        }
        if(name == 'fileSize'){
            component.set('v.showConfirmDialog', false);
        }
        if(name == 'submit'){
            component.set('v.spinner', true);
            component.set('v.showConfirmDialog', false);
            var response = helper.uploadFiles(component);
            if(response != 'sizeError'){
                var sapRecord = component.get('v.sapRecord');
                sapRecord.Product_Stewardship_Status__c = 'Customer Submitted';
                component.set('v.sapRecord', sapRecord);
                helper.updateSapRecord(component);
            }
        }
    },
    addQuestionnaire: function(component,event,helper){
        component.set('v.spinner', true);
        var prodId = event.getSource().get('v.name').split(' | ')[0];
        var quesList = component.get('v.questionnaireList');
        var mainQues = component.get('v.mainQuestionnaire');
        var ques = {
            "sObjectType" : 'Questionnaire__c',
            "RecordTypeId" : event.getSource().get('v.name').split(' | ')[1],
            "Onboarding_Product__c": prodId,
            "SAP_Onboarding__c" : mainQues.SAP_Onboarding__c,
            "Account_Name__c": event.getSource().get('v.name').split(' | ')[2],
            "Status__c": "Customer In Progress",
            "Onboarding_Ship_To__c": mainQues.Onboarding_Product__r.Onboarding_Ship_To__c,
            "Questionnaire_Setup_Type__c" : "Online"
        };
        var action  = component.get('c.saveQuestionnaire');
        action.setParams({
            recordList : [ques],
            isFormSubmit : false
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                quesList.push(response.getReturnValue());
                component.set('v.questionnaireList',quesList);
                component.set('v.finalErrors',[]);
                component.set('v.spinner', false);
                var parent = component.get('v.parent');
                parent.openToast('utility:success', 'JS_24', 'success');
            }
        });
        $A.enqueueAction(action);
        
        
    },
    deleteQues: function(component,event, helper){
        component.set('v.toDeleteQuesIndx', event.getSource().get('v.name'));
        var languageMap = component.get('v.languageLabelMap');
        component.set('v.confirmMessage', languageMap['JS_30']);
        component.set('v.confirmEventName', 'deleteQues');   
        component.set('v.confirmCancelLabel',languageMap['HP_32']);
        component.set('v.confirmSubmitLabel',languageMap['HP_31']);
        component.set('v.showConfirmDialog', true);
    },
    
    handleQuesFileChange : function(component, event, helper){
        var files = event.getSource().get('v.files');
        var quesId = event.getSource().get('v.name');
        var quesFiles = component.get('v.quesFileList');
        if(files.length > 0){
            for(var i=0;i<files.length;i++){
                files[i].ParentId = quesId;
                files[i].Id ='';
                quesFiles.push(files[i]);
            }
        }
        component.set('v.quesFileList', quesFiles);
    },
    
    handleQuesDocFileChange : function(component, event, helper){
        component.set('v.finalErrors', []);
        var files = event.getSource().get('v.files');
        var quesId = event.getSource().get('v.name');
        var quesDocFiles = component.get('v.quesDocFileList');
        if(files.length > 0){
            event.getSource().setCustomValidity('');
            for(var i=0;i<files.length;i++){
                files[i].ParentId = quesId;
                files[i].Id ='';
                quesDocFiles.push(files[i]);
            }
        }
        component.set('v.quesDocFileList', quesDocFiles);
    },
    
    handleTankRegFileChange: function (component, event, helper) {
        component.set('v.finalErrors', []);
        var files = event.getSource().get('v.files');
        var quesId = event.getSource().get('v.name');
        var quesTankRegFiles = component.get('v.quesTankRegFileList');
        if (files.length > 0) {
            for (var i = 0; i < files.length; i++) {
                files[i].ParentId = quesId;
                files[i].Id = '';
                quesTankRegFiles.push(files[i]);
            }
        }
        component.set('v.quesTankRegFileList', quesTankRegFiles);
    },
    
    handleProdFileChange : function(component, event, helper){
        var files = event.getSource().get('v.files');
        var prodId = event.getSource().get('v.name');
        var prodFiles = component.get('v.prodFileList');
        if(files.length > 0){
            for(var i=0;i<files.length;i++){
                files[i].ParentId = prodId;
                files[i].Id ='';
                prodFiles.push(files[i]);
            }
        }
        component.set('v.prodFileList', prodFiles);
    },
    deleteFile : function(component, event, helper){
        component.set('v.toDeleteFileId', event.target.id);
        component.set('v.fileType', event.target.name);
        var languageMap = component.get('v.languageLabelMap');
        component.set('v.confirmMessage', languageMap['JS_16']);
        component.set('v.confirmEventName', 'deleteFile');
        component.set('v.confirmCancelLabel',languageMap['HP_32']);
        component.set('v.confirmSubmitLabel',languageMap['HP_31']);
        component.set('v.showConfirmDialog', true);
    },
    handleError : function(component, event, helper){
        console.log('error',JSON.stringify(event.getParams()));
        var formId = event.getSource().getLocalId();
    },
    
    saveSetupValue : function(component, event, helper){
        var mainQuestionnaire = component.get('v.mainQuestionnaire');
        var value = component.get('v.setupValue');
        var quesType = mainQuestionnaire.RecordType.Name;
        var resName = '';
        mainQuestionnaire.Questionnaire_Setup_Type__c = value;
        if(!value){
            if(Array.isArray(component.find('setupType'))){
                component.find('setupType')[0].showHelpMessageIfInvalid();
            }
            else{
                component.find('setupType').showHelpMessageIfInvalid();
            }
            //component.find('setupType').showHelpMessageIfInvalid();
        }else{
            helper.saveQuestionnaireRecord(component, false, '', [mainQuestionnaire]);
            if(value == 'Offline'){
                helper.handleQuestionnaireLink(component);
                if(Array.isArray(component.find('setupType'))){
                    component.find('setupType')[0].set('v.disabled', true);
                }
                else{
                    component.find('setupType').set('v.disabled', true);
                }
                if(Array.isArray(component.find('setupButton'))){
                    component.find('setupButton')[0].set('v.disabled', true);
                }
                else{
                    component.find('setupButton').set('v.disabled', true);
                }
                //component.find('setupType').set('v.disabled', true);
                //component.find('setupButton').set('v.disabled', true);
                component.set('v.isOffline', true);
                component.set('v.mainQuestionnaire', mainQuestionnaire);
            }
            else{
                component.set('v.isOffline', false);
            }
        }
    },
    handleSwitchOffline : function(component, event, helper){
        var languageMap = component.get('v.languageLabelMap');
        component.set('v.confirmMessage', languageMap['JS_25']);
        component.set('v.confirmEventName', 'switchQues'); 
        component.set('v.confirmCancelLabel',languageMap['HP_32']);
        component.set('v.confirmSubmitLabel',languageMap['HP_31']);
        component.set('v.showConfirmDialog', true);
    },
    
    removeFile : function(component, event, helper){
        var type = event.getSource().getLocalId();
        var indx = event.getSource().get('v.id');   
        var quesFileList = component.get('v.quesFileList');
        var quesDocFileList = component.get('v.quesDocFileList');;
        var quesTankRegFileList = component.get('v.quesTankRegFileList');
        var prodFileList = component.get('v.prodFileList');
        if(type == 'quesFile'){
            quesFileList.splice(indx, 1);
            component.set('v.quesFileList', quesFileList);
        }
        if(type == 'quesDocFile'){
            quesDocFileList.splice(indx, 1);
            component.set('v.quesDocFileList', quesDocFileList);
        }
        if(type == 'quesTankRegFile'){
            quesTankRegFileList.splice(indx, 1);
            component.set('v.quesTankRegFileList', quesTankRegFileList);
        }
        if(type == 'prodFile'){
            prodFileList.splice(indx, 1);
            component.set('v.prodFileList', prodFileList);
        }
    },
    
    handleSubmit : function(component, event , helper){
        var languageMap = component.get('v.languageLabelMap');
        component.set('v.confirmMessage',languageMap['CI_143']);
        component.set('v.confirmCancelLabel',languageMap['PS_41']);
        component.set('v.confirmSubmitLabel',languageMap['CI_5']);
        component.set('v.confirmEventName', 'submit');
        component.set('v.showConfirmDialog', true);
    },
    
    handleQuestionnaireLinks : function(component, event, helper){
        helper.handleQuestionnaireLink(component);
    }
    
})