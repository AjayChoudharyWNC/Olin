({
    doInit : function(component, event, helper){
        var sapId = component.get('v.sapId');
        var vatList = component.get('v.vatList');
        var sapRecord = component.get('v.sapRecord');
       
        console.log('Data TF: ',component.get('v.isDisabledForProfile'));
        if(sapId){
            if(sapRecord){
                var creditType = 'Full';
                if(sapRecord.Customer_Purchased_Prod_In_Last_12_Month__c == "Yes"){
                    if(sapRecord.New_Business_Result_In_Exceeding_Credit__c == "Yes"){
                        creditType = 'Partial';
                    }
                    if(sapRecord.New_Business_Result_In_Exceeding_Credit__c == "No" || sapRecord.New_Business_Result_In_Exceeding_Credit__c == 'Unsure'){
                        creditType = "No Credit";
                    }
                }
                if(sapRecord.Customer_Purchased_Prod_In_Last_12_Month__c == "No"){
                    creditType = 'Full';
                }
                component.set('v.creditType', creditType);
                if(!sapRecord.Bank_Institution_Name_2__c){
                    sapRecord.Bank_Institution_Name_2__c = '';
                }
                if(!sapRecord.Bank_Institution_Name_3__c){
                    sapRecord.Bank_Institution_Name_3__c = '';
                }
                if(!sapRecord.Company_Name_2__c){
                    sapRecord.Company_Name_2__c = '';
                }
                if(!sapRecord.Company_Name_3__c){
                    sapRecord.Company_Name_3__c = '';
                }
                component.set('v.sapRecord', sapRecord);
                if(!sapRecord.VAT1__r){
                    var vatList = [];
                    var vatRecord = { "sObjectType" : "VAT__c",
                                     "SAP_Onboarding__c" : sapId
                                    };
                    vatList.push(vatRecord);
                    helper.saveVatRecords(component, vatList, true);
                }
            }
            helper.fetchFiles(component, 'bankReferenceFile');
            helper.fetchFiles(component, 'tradeReferenceFile');
            helper.fetchFiles(component, 'financialFile');
        }
        if(vatList && vatList.length>0){
            if(!component.get('v.isTaxTypeLoaded')){
                //helper.fetchTaxTypeDependentOptions(component);
            }
            helper.fetchFiles(component, 'taxFile');
            
        }
        helper.getCreditInformation(component);
    },
    handleTaxFileChange : function(component, event, helper){
        var files = event.getSource().get('v.files');
        var vatId = event.getSource().get('v.name');
        var taxFiles = component.get('v.taxFileList');
        if(files.length > 0){
            for(var i=0;i<files.length;i++){
                files[i].ParentId = vatId;
                files[i].Id ='';
                taxFiles.push(files[i]);
            }
        }
        component.set('v.taxFileList', taxFiles);
    },
    
    handleConfirmDialog : function(component, event, helper){
        var name = event.getSource().get('v.name');
        if(name == 'No'){
            component.set('v.showConfirmDialog', false);
        }
        if(name == 'deleteFile'){
            helper.handleFileDelete(component);
            component.set('v.showConfirmDialog', false);
        }
        if(name == 'submit'){
            var response = helper.uploadFiles(component);
            if(response != 'sizeError'){
                component.find('CAForm').submit();
                helper.saveVatRecords(component, component.get('v.vatList'), false);
                component.set('v.isFormSubmitManual', false);
                component.set('v.spinner', true);
                component.set('v.showConfirmDialog', false);
            }
        }
        if(name == 'submitCreditPartial'){
            var response = helper.uploadFiles(component);
            if(response != 'sizeError'){
                var sapRefreshEvt = $A.get('e.c:OCO_Customer_RefreshSapRecord');
                sapRefreshEvt.setParams({"sapId" : component.get('v.sapRecord').Id});
                sapRefreshEvt.fire();
                var sapRecord = component.get('v.sapRecord');
                sapRecord.Credit_Application_Status__c = 'Customer Submitted';
                component.set('v.sapRecord', sapRecord);
                helper.updateSapRecord(component, true);
                window.setTimeout(
                    $A.getCallback(function() {
                        var parent  = component.get('v.parent');
                        parent.getSapRecord();
                    }), 
                    2000
                );
                component.set('v.isFormSubmitManual', false);
                component.set('v.spinner', true);
                component.set('v.showConfirmDialog', false);
            }
        }
    },
    handleCopyAddresses : function(component, event, helper){
        var id = event.currentTarget.id;
        var value = true;
        if(id == 'sameAddressCheck' && value){
            helper.setPopulateFields(component,'ship to',false);
        }
        else if(id == 'sameAddressCheck' && !value){
            helper.setPopulateFields(component,'ship to',true);
        }
            else if(id == 'parentAndBillToggle' && value){
                helper.setPopulateFields(component,'parent to',false);
            }
                else if(id == 'parentAndBillToggle' && !value){
                    helper.setPopulateFields(component,'parent to',true);
                }
        
                    else if(id == 'billToSameSoldTo' && value){
                        helper.setPopulateFields(component,'bill to',false);
                    }
                        else if(id == 'billToSameSoldTo' && !value){
                            helper.setPopulateFields(component,'bill to',true);
                        }
        
    },
    handleBankReferenceFileChange : function(component, event, helper){
        var files = event.getSource().get('v.files');
        var sapId = event.getSource().get('v.name');
        var bankReferenceFiles = component.get('v.bankReferenceFileList');
        if(files.length > 0){
            component.set('v.showBankRefFields', false);
            component.set('v.showBankRefFields', true);
            for(var i=0;i<files.length;i++){
                files[i].ParentId = sapId;
                files[i].Id ='';
                bankReferenceFiles.push(files[i]);
            }
        }
        component.set('v.bankReferenceFileList', bankReferenceFiles);
    },
    
    handleTradeReferenceFileChange : function(component, event, helper){
        var files = event.getSource().get('v.files');
        var sapId = event.getSource().get('v.name');
        var tradeReferenceFiles = component.get('v.tradeReferenceFileList');
        if(files.length > 0){
            component.set('v.showTradeRefFields', false);
            component.set('v.showTradeRefFields', true);
            for(var i=0;i<files.length;i++){
                files[i].ParentId = sapId;
                files[i].Id ='';
                tradeReferenceFiles.push(files[i]);
            }
        }
        component.set('v.tradeReferenceFileList', tradeReferenceFiles);
    },
    
    handleFinancialFileChange : function(component, event, helper){
        var files = event.getSource().get('v.files');
        var sapId = event.getSource().get('v.name');
        var financialFiles = component.get('v.financialFileList');
        if(files.length > 0){
            for(var i=0;i<files.length;i++){
                files[i].ParentId = sapId;
                files[i].Id ='';
                financialFiles.push(files[i]);
            }
        }
        component.set('v.financialFileList', financialFiles);
    },
    handleFormSuccess : function(component, event, helper) {
        //component.set('v.spinner', false);
        var sap = event.getParams().response;
        console.log('sapId',sap,sap.id);
        if(sap.id){
            var sapRefreshEvt = $A.get('e.c:OCO_Customer_RefreshSapRecord');
            sapRefreshEvt.setParams({"sapId" : component.get('v.sapRecord').Id});
            sapRefreshEvt.fire();
            if(!component.get('v.isFormSubmitManual')){
                helper.uploadFiles(component);
                var sapRecord = component.get('v.sapRecord');
                sapRecord.Credit_Application_Status__c = 'Customer Submitted';
                component.set('v.sapRecord', sapRecord);
                helper.updateSapRecord(component, true);
                window.setTimeout(
                    $A.getCallback(function() {
                        var parent  = component.get('v.parent');
                        parent.getSapRecord();
                    }), 
                    2000
                );
                
            }
            else{
                component.set('v.spinner', false);
                var parent = component.get('v.parent');
                parent.openToast('utility:success', 'JS_13', 'success');
            }
        }
    },
    
    handleFormSubmit : function(component, event, helper){
        event.preventDefault();
        var languageMap = component.get('v.languageLabelMap');
        var languageMap=component.get('v.languageLabelMap');
        var allVatFiles = component.find('vatNumber');
        var hasError = false;
        if(Array.isArray(allVatFiles)){
            for(var i=0;i<allVatFiles.length;i++){
                if(!allVatFiles[i].checkValidity()){
                    hasError = true;
                    allVatFiles[i].setCustomValidity(languageMap['JS_14']);
                    allVatFiles[i].focus();
                }
                
            }
        }
        else{
            if(allVatFiles && !allVatFiles.checkValidity()){
                hasError = true;
                allVatFiles.setCustomValidity(languageMap['JS_14']);
                allVatFiles.focus();
            }
        }
        if(!hasError){
            
            component.set('v.confirmMessage',languageMap['CI_143']);
            component.set('v.confirmCancelLabel',languageMap['PS_41']);
            component.set('v.confirmSubmitLabel',languageMap['CI_5']);
            component.set('v.confirmEventName', 'submit');
            component.set('v.showConfirmDialog', true);
        }
        
    },
    
    handleSubmitPartialCredit : function(component, event, helper){
        var languageMap = component.get('v.languageLabelMap');
        var languageMap=component.get('v.languageLabelMap');
        var financialFileInput = component.find('financialFileInput');
        if(Array.isArray(financialFileInput)){
            financialFileInput = financialFileInput[0];
        }
        if(!financialFileInput.checkValidity()){
            financialFileInput.reportValidity();
            financialFileInput.focus();
            return;
        }
        component.set('v.confirmMessage',languageMap['CI_143']);
        component.set('v.confirmCancelLabel',languageMap['PS_41']);
        component.set('v.confirmSubmitLabel',languageMap['CI_5']);
        component.set('v.confirmEventName', 'submitCreditPartial');
        component.set('v.showConfirmDialog', true);
    },
    
    handleError : function(component, event, helper){
        event.getParam("message"); 
        console.log(JSON.stringify(event.getParams()));  
    },
    addNewTax : function(component, event, helper){
        var vatList = component.get('v.vatList');
        var vatRecord = { "sObjectType" : "VAT__c",
                         "SAP_Onboarding__c" : component.get('v.sapId')
                        };
        vatList.push(vatRecord);
        helper.saveVatRecords(component, vatList, false);
    },
    
    removeTax: function(component,event,helper){
        var indx = event.getSource().get('v.value');
        var vatId = indx.split('/')[1];
        var vatList = component.get('v.vatList');
        var tempVatList =[];
        for(var i=0;i<vatList.length;i++){
            if(vatList[i].Id != vatId){
                tempVatList.push(vatList[i]);
            }
        }
        component.set('v.vatList', tempVatList);
        helper.deleteVatRecord(component, vatId);
    },
    
    handleSaveProgress : function(component, event, helper){
        component.set('v.spinner', true);
        var response = helper.uploadFiles(component);
        if(response != 'sizeError'){
            if(component.get('v.creditType') != 'Partial'){
                component.set('v.isFormSubmitManual', true);
                component.find('CAForm').submit();
                helper.saveVatRecords(component, component.get('v.vatList'), false);
            } 
            else{
                var parent = component.get('v.parent');
                parent.openToast('utility:success', 'JS_13', 'success');
            }
            helper.updateSapRecord(component, false);
           
        }
    },
    
    handleShareWithColleague : function(component, event, helper){
        var parent = component.get('v.parent');
        parent.openShareWithColleague();
    },
    deleteFile : function(component, event, helper){
        component.set('v.toDeleteFileId', event.target.id);
        component.set('v.fileType', event.target.name);
        var languageMap=component.get('v.languageLabelMap')
        component.set('v.confirmMessage', languageMap['JS_16']);
        component.set('v.confirmEventName', 'deleteFile');
        component.set('v.confirmCancelLabel',languageMap['HP_32']);
        component.set('v.confirmSubmitLabel',languageMap['HP_31']);
        component.set('v.showConfirmDialog', true);
    },
    
    removeFile : function(component, event, helper){
        var type = event.getSource().getLocalId();
        var indx = event.getSource().get('v.id');
        var taxFileList = component.get('v.taxFileList');
        var bankReferenceFileList = component.get('v.bankReferenceFileList');;
        var tradeReferenceFileList = component.get('v.tradeReferenceFileList');
        var financialFileList = component.get('v.financialFileList');
        if(type == 'taxFile'){
            taxFileList.splice(indx, 1);
            component.set('v.taxFileList', taxFileList);
        }
        if(type == 'bankReferenceFile'){
            bankReferenceFileList.splice(indx, 1);
            component.set('v.bankReferenceFileList', bankReferenceFileList);
        }
        if(type == 'tradeReferenceFile'){
            tradeReferenceFileList.splice(indx, 1);
            component.set('v.tradeReferenceFileList', tradeReferenceFileList);
        }
        if(type == 'financialFile'){
            financialFileList.splice(indx, 1);
            component.set('v.financialFileList', financialFileList);
            component.set('v.showCreditInfo', false);
            component.set('v.showCreditInfo', true);
        }
    },
    
    handleTaxOptions : function(component, event, helper){
        helper.handleCountryTaxType(component);
    }
})