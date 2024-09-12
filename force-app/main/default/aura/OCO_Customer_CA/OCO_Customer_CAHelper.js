({
    MAX_FILE_SIZE: 4500000, //Max file size 4.5 MB 
    CHUNK_SIZE: 750000, //Chunk Max size 750Kb 
    setPopulateFields: function (component, fieldName, setNull) {
        var sapRecord = component.get('v.sapRecord');
        if (fieldName == 'ship to') {
            if (!setNull) {
                sapRecord.Ship_To_City__c = sapRecord.Sold_To_City__c;
                sapRecord.Ship_To_Company_Name__c = sapRecord.Sold_To_Company_Name__c;
                sapRecord.Ship_To_Country__c = sapRecord.Sold_To_Country__c;
                sapRecord.Ship_To_Postal_Code__c = sapRecord.Sold_To_Postal_Code__c;
                sapRecord.Ship_To_State_Province__c = sapRecord.Sold_To_State_Province__c;
                sapRecord.Ship_To_Street__c = sapRecord.Sold_To_Street__c;
                sapRecord.Ship_To_Street_2__c = sapRecord.Sold_To_Street_2__c;
            }
            else {
                sapRecord.Ship_To_City__c = '';
                sapRecord.Ship_To_Company_Name__c = '';
                sapRecord.Ship_To_Country__c = '';
                sapRecord.Ship_To_Postal_Code__c = '';
                sapRecord.Ship_To_State_Province__c = '';
                sapRecord.Ship_To_Street__c = '';
                sapRecord.Ship_To_Street_2__c = '';
            }
        }
        if (fieldName == 'parent to') {
            if (!setNull) {
                sapRecord.Parent_City__c = sapRecord.Sold_To_City__c;
                sapRecord.Parent_Company_Name__c = sapRecord.Sold_To_Company_Name__c;
                sapRecord.Parent_Country__c = sapRecord.Sold_To_Country__c;
                sapRecord.Parent_Postal_Code__c = sapRecord.Sold_To_Postal_Code__c;
                sapRecord.Parent_State_Province__c = sapRecord.Sold_To_State_Province__c;
                sapRecord.Parent_Street__c = sapRecord.Sold_To_Street__c;
                sapRecord.Parent_Street_2__c = sapRecord.Sold_To_Street_2__c;
            }
            else {
                sapRecord.Parent_City__c = '';
                sapRecord.Parent_Company_Name__c = '';
                sapRecord.Parent_Country__c = '';
                sapRecord.Parent_Postal_Code__c = '';
                sapRecord.Parent_State_Province__c = '';
                sapRecord.Parent_Street__c = '';
                sapRecord.Parent_Street_2__c = '';
            }
        }
        if (fieldName == 'bill to') {
            if (!setNull) {
                sapRecord.Bill_To_City__c = sapRecord.Sold_To_City__c;
                sapRecord.Bill_To_Company_Name__c = sapRecord.Sold_To_Company_Name__c;
                sapRecord.Bill_To_Country__c = sapRecord.Sold_To_Country__c;
                sapRecord.Bill_To_Postal_Code__c = sapRecord.Sold_To_Postal_Code__c;
                sapRecord.Bill_To_State_Province__c = sapRecord.Sold_To_State_Province__c;
                sapRecord.Bill_To_Street__c = sapRecord.Sold_To_Street__c;
                sapRecord.Bill_To_Street_2__c = sapRecord.Sold_To_Street_2__c;
            }
            else {
                sapRecord.Bill_To_City__c = '';
                sapRecord.Bill_To_Company_Name__c = '';
                sapRecord.Bill_To_Country__c = '';
                sapRecord.Bill_To_Postal_Code__c = '';
                sapRecord.Bill_To_State_Province__c = '';
                sapRecord.Bill_To_Street__c = '';
                sapRecord.Bill_To_Street_2__c = '';
            }
        }
        if (fieldName == 'contractContact') {
            sapRecord.Contract_Notification_Email__c = sapRecord.Order_Placement_Email__c;
            sapRecord.Contract_Notification_First_Name__c = sapRecord.Order_Placement_First_Name__c;
            sapRecord.Contract_Notification_Last_Name__c = sapRecord.Order_Placement_Last_Name__c;
            sapRecord.Contract_Notification_Title__c = sapRecord.Order_Placement_Title__c;
            sapRecord.Contract_Notification_Phone__c = sapRecord.Order_Placement_Phone__c;
        }
        if (fieldName == 'afterHourContact') {
            sapRecord.After_Hours_Email__c = sapRecord.Order_Placement_Email__c;
            sapRecord.After_Hours_First_Name__c = sapRecord.Order_Placement_First_Name__c;
            sapRecord.After_Hours_Last_Name__c = sapRecord.Order_Placement_Last_Name__c;
            sapRecord.After_Hours_Title__c = sapRecord.Order_Placement_Title__c;
            sapRecord.After_Hours_Phone__c = sapRecord.Order_Placement_Phone__c;
        }
        if (fieldName == 'creditContact') {
            sapRecord.Credit_Email__c = sapRecord.Order_Placement_Email__c;
            sapRecord.Credit_First_Name__c = sapRecord.Order_Placement_First_Name__c;
            sapRecord.Credit_Last_Name__c = sapRecord.Order_Placement_Last_Name__c;
            sapRecord.Credit_Title__c = sapRecord.Order_Placement_Title__c;
            sapRecord.Credit_Phone__c = sapRecord.Order_Placement_Phone__c;
        }
        if (fieldName == 'emailInvoiceContact') {
            sapRecord.Email_Invoice_Email_Address__c = sapRecord.Order_Placement_Email__c;
            sapRecord.Email_Invoice_First_Name__c = sapRecord.Order_Placement_First_Name__c;
            sapRecord.Email_Invoice_Last_Name__c = sapRecord.Order_Placement_Last_Name__c;
            sapRecord.Email_Invoice_Title__c = sapRecord.Order_Placement_Title__c;
            sapRecord.Email_Invoice_Phone__c = sapRecord.Order_Placement_Phone__c;
        }
        if (fieldName == 'regCustomerContact') {
            sapRecord.Regulatory_Email__c = sapRecord.Order_Placement_Email__c;
            sapRecord.Regulatory_First_Name__c = sapRecord.Order_Placement_First_Name__c;
            sapRecord.Regulatory_Last_Name__c = sapRecord.Order_Placement_Last_Name__c;
            sapRecord.Regulatory_Title__c = sapRecord.Order_Placement_Title__c;
            sapRecord.Regulatory_Phone__c = sapRecord.Order_Placement_Phone__c;
        }
        if (fieldName == 'sdsContact') {
            sapRecord.Quality_SDS_Email__c = sapRecord.Order_Placement_Email__c;
            sapRecord.Quality_SDS_First_Name__c = sapRecord.Order_Placement_First_Name__c;
            sapRecord.Quality_SDS_Last_Name__c = sapRecord.Order_Placement_Last_Name__c;
            sapRecord.Quality_SDS_Title__c = sapRecord.Order_Placement_Title__c;
            sapRecord.Quality_SDS_Phone__c = sapRecord.Order_Placement_Phone__c;
        }
        if (fieldName == 'cxoContact') {
            sapRecord.CXO_Officer_Email__c = sapRecord.Order_Placement_Email__c;
            sapRecord.CXO_Officer_First_Name__c = sapRecord.Order_Placement_First_Name__c;
            sapRecord.CXO_Officer_Last_Name__c = sapRecord.Order_Placement_Last_Name__c;
            sapRecord.CXO_Officer_Title__c = sapRecord.Order_Placement_Title__c;
            sapRecord.CXO_Officer_Phone__c = sapRecord.Order_Placement_Phone__c;
        }
        if (fieldName == 'accountPayableContact') {
            sapRecord.Account_Payable_Email__c = sapRecord.Order_Placement_Email__c;
            sapRecord.Account_Payable_First_Name__c = sapRecord.Order_Placement_First_Name__c;
            sapRecord.Account_Payable_Last_Name__c = sapRecord.Order_Placement_Last_Name__c;
            sapRecord.Account_Payable_Title__c = sapRecord.Order_Placement_Title__c;
            sapRecord.Account_Payable_Phone__c = sapRecord.Order_Placement_Phone__c;
        }
        component.set('v.sapRecord', sapRecord);
    },
    deleteVatRecord: function (component, vatId) {
        var actionVat = component.get('c.deleteVat');
        actionVat.setParams({
            recordId: vatId
        });
        actionVat.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                console.log('vat deleted');
                 //this.handleCountryTaxType(component);
            }
        });
        $A.enqueueAction(actionVat);
        
    },
    handleFileDelete : function(component){
        component.set('v.spinner', true);
        var id = component.get('v.toDeleteFileId');
        var action = component.get('c.deleteAttachment');
        action.setParams({
            "recordId" : id
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                this.fetchFiles(component, component.get('v.fileType'));
                component.set('v.spinner', false);
                var parent = component.get('v.parent');
                parent.openToast('utility:success','JS_27', 'success');
            }
        });
        $A.enqueueAction(action);  
    },
    updateSapRecord : function(component, showToast){
        var action = component.get('c.saveSapOnboarding');
        action.setParams({
            sapRecord : component.get('v.sapRecord'),
            currentAppUser : component.get('v.appUserId')
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                component.set('v.spinner', false);
                if(showToast){
                    var parent = component.get('v.parent');
                    parent.openToast('utility:success', 'JS_28', 'success');
                }
                
                
            }
        });
        $A.enqueueAction(action);
    } ,
    saveVatRecords : function(component, vatList, isFirstTime){
        console.log('vatlist before==',vatList);
        var actionVat = component.get('c.saveVat');
        actionVat.setParams({
            vatRecords : vatList,
            isFirstTime : isFirstTime
        });
        actionVat.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                console.log('vatlist==', response.getReturnValue());
                component.set('v.vatList', response.getReturnValue());
                this.getVatList(component);
            }
        });
        $A.enqueueAction(actionVat);
    },
    
    getCreditInformation : function(component){
        var action = component.get('c.getCreditInfo');
        action.setParams({
            appUserId : component.get('v.appUserId')
        });
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS'){
                //component.set('v.showCreditInfo', response.getReturnValue());
            } 
        });
        $A.enqueueAction(action);
    },
    
    getVatList : function(component){
        var actionVat = component.get('c.getVatRecords');
        actionVat.setParams({
            sapId : component.get('v.sapId')
        });
        actionVat.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                component.set('v.vatList', response.getReturnValue());
            }
        });
        $A.enqueueAction(actionVat);
    },
    uploadFiles : function(component){
        var taxFileList = component.get('v.taxFileList');
        var bankReferenceFileList = component.get('v.bankReferenceFileList');;
        var tradeReferenceFileList = component.get('v.tradeReferenceFileList');
        var financialFileList = component.get('v.financialFileList');
        if(taxFileList){
            var fileCount = taxFileList.length;
            if (fileCount > 0) {
                for (var i = 0; i < fileCount; i++) 
                {
                    if(taxFileList[i].Id == '')
                        return this.uploadHelper(component, event,taxFileList[i], 'taxFile');
                }
            }
        }
        if(bankReferenceFileList){
            var fileCount = bankReferenceFileList.length;
            if (fileCount > 0) {
                for (var i = 0; i < fileCount; i++) 
                {
                    if(bankReferenceFileList[i].Id == '')
                        return this.uploadHelper(component, event,bankReferenceFileList[i], 'bankReferenceFile');
                }
            }
        }
        if(tradeReferenceFileList){
            var fileCount = tradeReferenceFileList.length;
            if (fileCount > 0) {
                for (var j = 0; j < fileCount; j++) 
                {
                    if(tradeReferenceFileList[j].Id == ''){
                        return this.uploadHelper(component, event,tradeReferenceFileList[j], 'tradeReferenceFile');
                    }
                }
            }
        }
        if(financialFileList){
            var fileCount = financialFileList.length;
            if (fileCount > 0) {
                for (var j = 0; j < fileCount; j++) 
                {
                    if(financialFileList[j].Id == ''){
                        return this.uploadHelper(component, event,financialFileList[j], 'financialFile');
                    }
                }
            }
        }
    },
    
    uploadHelper: function (component, event, f, fileType) {
        var file = f;
        var self = this;
        var languageMap = component.get('v.languageLabelMap');
        // check the selected file size, if select file size greter then MAX_FILE_SIZE,
        // then show a alert msg to user,hide the loading spinner and return from function  
        if (file.size > self.MAX_FILE_SIZE) {
            var languageMap = component.get('v.languageLabelMap');
            component.set('v.confirmMessage', languageMap['JS_33']);
            component.set('v.confirmEventName', 'fileSize');
            component.set('v.confirmCancelLabel',languageMap['PS_41']);
            component.set('v.showConfirmDialog', true);
            component.set('v.spinner', false);
            return 'sizeError';
        }
        
        // Convert file content in Base64
        var objFileReader = new FileReader();
        objFileReader.onload = $A.getCallback(function () {
            var fileContents = objFileReader.result;
            var base64 = 'base64,';
            var dataStart = fileContents.indexOf(base64) + base64.length;
            fileContents = fileContents.substring(dataStart);
            self.uploadProcess(component, file, fileContents, fileType);
        });
        
        objFileReader.readAsDataURL(file);
    },
    
    uploadProcess: function (component, file, fileContents, fileType) {
        // set a default size or startpostiton as 0 
        var startPosition = 0;
        // calculate the end size or endPostion using Math.min() function which is return the min. value   
        var endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
        
        // start with the initial chunk, and set the attachId(last parameter)is null in begin
        this.uploadInChunk(component, file, fileContents, startPosition, endPosition, '', fileType);
    },
    
    
    uploadInChunk: function (component, file, fileContents, startPosition, endPosition, attachId, fileType) {
        // call the apex method 'saveFile'
        var getchunk = fileContents.substring(startPosition, endPosition);
        var action = component.get("c.saveFile")
        var parentId = file.ParentId;
        /*if (fileType == 'prodFile' || fileType == 'Questionnaire File' || fileType == 'taxFile') {
            parentId = file.ParentId;
        }
        else {
            parentId = component.get("v.recordId");
        }*/
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
                    this.uploadInChunk(component, file, fileContents, startPosition, endPosition, attachId, fileType);
                } else {
                    //component.set('v.isSaveProgress', false);
                    this.fetchFiles(component,fileType);
                    console.log('your File is uploaded successfully', true);
                    component.set('v.spinner', false);
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
    },
    
    fetchFiles: function (component, fileType) {
        var parentId = component.get('v.sapId');
        component.set('v.spinner', true);
        var action = component.get('c.fetchAttachments');
        action.setParams({
            "parentId": parentId,
            "fileDescString": fileType
        });
        action.setCallback(this, function (response) {
            if (response.getState() === 'SUCCESS') {
                var files = response.getReturnValue();
                for (var i = 0; i < files.length; i++) {
                    if (window.location.href.includes('SiteLogin')) {
                        files[i].link = "/SiteLogin/servlet/servlet.FileDownload?file=" + files[i].Id;
                    }
                    else {
                        files[i].link = "/servlet/servlet.FileDownload?file=" + files[i].Id;
                    }
                }
                if (fileType == 'taxFile') {
                    component.set('v.taxFileList', response.getReturnValue());
                }
                else if (fileType == 'bankReferenceFile') {
                    component.set('v.bankReferenceFileList', response.getReturnValue());
                }
                    else if (fileType == 'tradeReferenceFile') {
                        component.set('v.tradeReferenceFileList', response.getReturnValue());
                    }
                        else if(fileType == 'financialFile') {
                            component.set('v.financialFileList', response.getReturnValue());
                            component.set('v.showCreditInfo', false);
                            component.set('v.showCreditInfo', true);
                        }
                component.set('v.spinner', false);
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchTaxTypeDependentOptions : function(component) {
        /*if(!component.get('v.isTaxTypeLoaded')){
            var action = component.get('c.getTaxTypeDependentOptions');
            action.setCallback(this, function(response){
                if(response.getState() === 'SUCCESS'){
                    console.log('options==', response.getReturnValue());
                    var result = response.getReturnValue();
                    var languageData = component.get('v.languageFileData');
                    var countryTaxTypeIdMap = new Map();
                    for(var key in result){
                        var taxtTypeIds = [];
                        result[key].forEach(function(e){
                            for(var i = 0;i<languageData.length;i++){
                                if(languageData[i]['English'] == e){
                                    taxtTypeIds.push(languageData[i]['ID']);
                                }
                            }
                        });
                        countryTaxTypeIdMap.set(key, taxtTypeIds);
                    }
                    component.set('v.taxTypeDependentIdMap', countryTaxTypeIdMap);
                    component.set('v.isTaxTypeLoaded', true);
                    this.handleCountryTaxType(component);
                    component.set('v.taxTypeDependentMap', response.getReturnValue());
                } 
            });
            $A.enqueueAction(action);
        }*/
        
    },
    
    handleCountryTaxType : function(component){
       /* var taxTypeDependentIdMap = component.get('v.taxTypeDependentIdMap');
        var vatList = component.get('v.vatList');
        var englishLanguageLabelMap = component.get('v.englishLanguageLabelMap');
        var languageLabelMap = component.get('v.languageLabelMap');
        vatList.forEach(function(e){
            if(e.Country__c){
                var ids =  taxTypeDependentIdMap.get(e.Country__c);
                var taxTypeOptions = [];
                ids.forEach(function(g){
                    var option = {};
                    option.text = languageLabelMap[g];
                    option.value = englishLanguageLabelMap[g];
                    taxTypeOptions.push(option);
                });
                e.taxTypeOptions = taxTypeOptions;
            }
            else{
                e.taxTypeOptions = [];
            }
        });
        component.set('v.vatList',vatList);
        */
    }
})