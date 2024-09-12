({
    doInit : function(component, event, helper) {
        var shipToAccIds = component.get('v.shipToAccIds');
        for (var i = 0; i < shipToAccIds.length; i++) {
            helper.getShipToAccountDetails(component, event, shipToAccIds[i], i);
        }
        component.set('v.spinner',true);
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
        helper.fetchCustomerSetupRecord(component, event);
    },
    handleShipToLoad: function (component, event, helper) {
        var isFirst = component.get('v.isFirst');
        if (!isFirst) {
            var sapType = component.get('v.sapType');
            var allForms = component.find('shipToForm');
            if (sapType == 'New Product') {
                if (Array.isArray(allForms)) {
                    allForms.forEach(function (element) {
                        if (!element.get('v.recordId'))
                            element.submit();
                    });
                    component.set('v.isFirst', true);
                }
                else {
                    if (!allForms.get('v.recordId')) {
                        allForms.submit();
                    }
                    component.set('v.isFirst', true);
                }
            }
        }
        else {
            component.set('v.isFirst', false);
        }
    },
    
    handleProductLoad : function(component, event, helper){
        var recordId = event.getSource().get('v.class');
        if(recordId){
            helper.fetchShipFromPlantAccounts(component, event, recordId);
        }
    },
    
    handleShipToSubmit : function(component, event, helper){
        component.set('v.spinner', true);
    },
    
    handleSuccessShipTo : function(component, event, helper){
        var onboardShipTo = event.getParams();
        var onShipToId = onboardShipTo.response.id;
        var fields = onboardShipTo.response.fields;
        var companyName = fields['Ship_To_Company_Name__c'].value;
        var shipToNo = fields['Ship_To_No__c'].value;
        var shipToAndProds = component.get('v.shipToAndProds');
        for(var i=0;i<shipToAndProds.length;i++){
            if(shipToAndProds[i].Ship_To_No__c == shipToNo && shipToAndProds[i].Ship_To_Company_Name__c == companyName){
                shipToAndProds[i].Id = onShipToId;
                break;
            }
        }
        helper.showToast('Ship-To details saved. Now click on \'Add Product\' button!!', 'success', 'Success');
        component.set('v.shipToAndProds', shipToAndProds);
        component.set('v.spinner', false);
    },
    
    addProduct : function(component, event, helper){
        var shipToId = event.getSource().get('v.name');
        helper.fetchLayoutFields(component, event, 'Onboarding_Product__c-Main Onboarding Product Layout', '', shipToId, false);
    },
    
    handleRemoveProduct : function(component, event, helper){
        var localId = event.getSource().get('v.name');
        var shipToAndProds = component.get('v.shipToAndProds');
        var prodId = localId.split('/')[0];
        var sapCount = localId.split('/')[1];
        var prodCount = localId.split('/')[2];
        if(confirm('Are you sure, Do you want to remove this product?')){
            shipToAndProds[sapCount].prods.splice(prodCount,1);
            shipToAndProds[sapCount].selectedTabId = (parseInt(sapCount)+1) + 'Product' + (shipToAndProds[sapCount].prods.length);
            if(shipToAndProds[sapCount].prods.length == 0){
                shipToAndProds[sapCount].selectedTabId = (parseInt(sapCount)+1)+'ShipTo';
            }
            component.set('v.shipToAndProds',shipToAndProds);
            helper.checkForFinalButton(component, event, helper, false, false);
            if(prodId){
                component.set('v.spinner',true);
                helper.handleDeleteProduct(component, event, helper, prodId);
            }
        }
       	
    },
    
    handleSuccessProduct : function(component, event, helper){
        var product = event.getParams();
        var prodId = product.response.id;
        var localId = event.getSource().get('v.class');
        var sapCount = localId.split('/')[0];
        var prodCount = localId.split('/')[1];
        var fields = product.response.fields;
        var prodShipToId = fields['Onboarding_Ship_To__c'].value;
        var shipToAndProds = component.get('v.shipToAndProds');
        var isAlreadySaved = false;
        isAlreadySaved =  shipToAndProds[sapCount].prods[prodCount].saved;
        shipToAndProds[sapCount].prods[prodCount].saved = true;
        shipToAndProds[sapCount].prods[prodCount].Id = prodId;
        shipToAndProds[sapCount].prods[prodCount].oldShipMode = shipToAndProds[sapCount].prods[prodCount].Ship_Mode__c;
        shipToAndProds[sapCount].prods[prodCount].purchasedProd = fields['Purchased_Product__c'].value;
        var style = document.createElement('style');
        style.type = 'text/css';
        style.innerHTML = 'li[data-tab-value="'+(sapCount+1)+'Product'+(prodCount+1)+'"], a[data-tab-value="'+(sapCount+1)+'Product'+(prodCount+1)+'"] { pointer-events : none !important; }';
        /*for(var i=0;i<shipToAndProds.length;i++){
            if(shipToAndProds[i].Id == prodShipToId){
                var prods = shipToAndProds[i].prods;
                for(var p=0;p<prods.length;p++){
                    if(p+1 == prods.length){
                        isAlreadySaved =  prods[p].saved;
                        prods[p].saved = true;
                        prods[p].Id = prodId;
                        prods[p].oldShipMode = prods[p].Ship_Mode__c;
                        prods[p].purchasedProd = fields['Purchased_Product__c'].value;
                        var style = document.createElement('style');
                        style.type = 'text/css';
                        style.innerHTML = 'li[data-tab-value="'+(i+1)+'Product'+(p+1)+'"], a[data-tab-value="'+(i+1)+'Product'+(p+1)+'"] { pointer-events : none !important; }';
                        //document.getElementsByTagName('head')[0].appendChild(style);
                        break;
                    }
                }
                shipToAndProds[i].prods = prods;
            }
        }*/
        if(shipToAndProds[sapCount].prods[prodCount].Attachments && shipToAndProds[sapCount].prods[prodCount].Attachments.length > 0){
            var files = shipToAndProds[sapCount].prods[prodCount].Attachments;
                for (var j = 0; j < files.length; j++) 
                {
                    if(files[j].Id == ''){
                        files[j].ParentId = prodId;
                        helper.uploadHelper(component, event,files[j], 'Product Specification Attachment');
                    }
                }
        }
        component.set('v.shipToAndProds', shipToAndProds);
        //helper.fetchCustomerSetupRecord(component, event);
        if(isAlreadySaved)
            helper.updateProductAssessment(component, event, prodId);
        component.set('v.spinner', false);
        if(component.get('v.checkForFinalButton'))
            helper.checkForFinalButton(component, event, helper, true,false);
        // helper.fetchRelatedProds(component, event, prodSapId);
    },
    
    handleProdSubmit : function(component, event, helper){
        event.preventDefault();
        var sapRecord = component.get('v.sapRecord');
        var localId = event.getSource().get('v.class');
        var sapCount = localId.split('/')[0];
        var prodCount = localId.split('/')[1];
        var shipToAndProds = component.get('v.shipToAndProds');
        var isProdAndShipModeUsed = false;
        var prodFamily = shipToAndProds[sapCount].prods[prodCount].prodFamily;
        var prodId = shipToAndProds[sapCount].prods[prodCount].purchasedProd;
        var shipMode = shipToAndProds[sapCount].prods[prodCount].Ship_Mode__c;
        var oldShipMode = shipToAndProds[sapCount].prods[prodCount].oldShipMode; 
        var isAlreadySaved = shipToAndProds[sapCount].prods[prodCount].saved;
        for(var i=0;i<shipToAndProds[sapCount].prods.length;i++){
            if(i != prodCount && prodId == shipToAndProds[sapCount].prods[i].purchasedProd && shipMode == shipToAndProds[sapCount].prods[i].Ship_Mode__c){
                isProdAndShipModeUsed = true;
                break;
            }
        }
        if(isProdAndShipModeUsed){
            helper.showToast('The Purchased Product and Ship Mode combination already exists, Please choose another ship mode.', 'error', 'Error');
        }
        else{
            if(!isAlreadySaved){
                event.getSource().submit();
                component.set('v.spinner', true);
            }
            else{
                if(sapRecord.Product_Stewardship_Status__c == 'Sent To Customer' && shipMode != oldShipMode){
                    event.getSource().submit();
                    component.set('v.spinner', true);
                }
                else if(sapRecord.Product_Stewardship_Status__c == 'Customer In Progress' && shipMode != oldShipMode){
                    if(prodFamily == 'CAPV' || prodFamily == 'GCO'){
                        if(confirm("Warning! The ship mode has been changed. Changing the ship-mode will remove the current product assessment information/form and replace with the new mode information/form. Any data input by customer will be lost. Do you want to continue?")){
                            event.getSource().submit();
                            component.set('v.spinner', true);
                        }
                    }
                    else if(prodFamily == 'Epoxy' && shipMode != oldShipMode){
                       helper.handleEpoxyProductSubmission(component, event,shipToAndProds[sapCount].prods[prodCount]);
                    }
                }
                    else{
                        event.getSource().submit();
                        component.set('v.spinner', true);
                    }
            }
        }
    },  
    
    handleError : function(component, event, helper){
        var errorsArr  = event.getParam("errors");
        console.log('errors===',JSON.stringify(errorsArr));
        console.log(JSON.stringify(event.getParams()));
        //helper.showToast('Either required fields are missing or Some connectivity issue!!', 'error', 'Error');
    },
    
    onValueChange : function(component,event,helper){
        var fieldName = event.getSource().get('v.fieldName');
        var shipToAndProds = component.get('v.shipToAndProds');
        console.log('shipToAndProds::::' +JSON.stringify(shipToAndProds));
        if(!fieldName){
            fieldName = event.getSource().getLocalId();
        }
        var localId = event.getSource().get('v.name');
        if(fieldName == 'Ship_Mode__c'){
            localId = event.getSource().get('v.class');
        }
        var sapCount = localId.split('/')[1];
        
        var value = event.getSource().get('v.value');
        var prodCount = localId.split('/')[2];
        var sectionNumber = event.getSource().get('v.title');
        console.log('fieldName',fieldName,'value',value);
        if(value && fieldName == 'Ship_Mode__c'){
            var isProdAndShipModeUsed = false;
            var prodId = shipToAndProds[sapCount].prods[prodCount].purchasedProd;
            for(var i=0;i<shipToAndProds[sapCount].prods.length;i++){
                if(i != prodCount && prodId == shipToAndProds[sapCount].prods[i].purchasedProd && value == shipToAndProds[sapCount].prods[i].Ship_Mode__c){
                    isProdAndShipModeUsed = true;
                    break;
                }
            }
            
            if(isProdAndShipModeUsed){
                //shipToAndProds[sapCount].prods[prodCount].Ship_Mode__c = '';
                component.set('v.shipToAndProds', shipToAndProds);
                //event.getSource().set('v.value', '');
                component.set('v.showShipMode', false);
                component.set('v.showShipMode', true);
                helper.showToast('The Purchased Product and Ship Mode combination already exists, Please choose another ship mode.', 'warning', 'Warning');
            }
        }
        else if(value && fieldName == 'Purchased_Product__c'){
            var isProdUsed = false;
            shipToAndProds[sapCount].prods[prodCount].purchasedProd = event.getSource().get('v.value');
            component.set('v.shipToAndProds', shipToAndProds);
            /*for(var i=0;i<shipToAndProds[sapCount].prods.length;i++){
                if(value == shipToAndProds[sapCount].prods[i].purchasedProd){
                    isProdUsed = true;
                    event.getSource().set('v.value', '');
                    break;
                }
            }
            
            if(isProdUsed){
                helper.showToast('This product is already used for this Ship-To. Please select another product.', 'warning', 'Warning');
            }
            else{*/
                helper.populateProductFields(component,fieldName,value, sectionNumber, sapCount, prodCount);
            helper.fetchShipFromPlantAccounts(component, event, value);
            //}
        }
        else if(!value && fieldName == 'Purchased_Product__c'){
            var prodCount = localId.split('/')[2];
            helper.populateProductFields(component,fieldName,null, sectionNumber, sapCount, prodCount);
        }
        else if (fieldName == 'Regulatory_Contact__c') {
            helper.populateContactFields(component, fieldName, value, sapCount, prodCount);
        }
    },
    
    cancelAll: function(component,event,helper){
        var sapId = component.get('v.sapId');
        if(confirm('You are about to cancel the entire Customer Setup Request. Do you want to do this?')){
            helper.updateSapRecords(component, event, sapId, 'No', true, false, true);
        }
    },
    
    finalSubmit : function(component, event, helper){
        var checkboxEvent = $A.get('e.c:OCO_Seller_CheckboxUpdateEvt');
        checkboxEvent.fire();
        component.set('v.checkForFinalButton', false);
        component.find('finalSubmitBtn').set('v.disabled',true);
        helper.showToast('Onboarding form has been saved successfully, you may now send this to customer', 'success', 'Success');
    },
    sendToSap: function(component,event,helper){
        var sapId = component.get('v.sapId');
        helper.updateSapRecords(component, event, sapId, 'No', true, true, false);
    },
    
    handleUploadFinished: function (cmp, event) {
        var uploadedFiles = event.getParam("files");
        var files = [];
        uploadedFiles.forEach(function(file){
            file.link = '/'+file.documentId;
            console.log(file.name);
            files.push(file);
        });
        cmp.set('v.prodFiles', files);
    },
    
    deleteFile : function(component, event, helper){
        if(confirm('Are you sure?')){
            var localId = event.target.id;
            var sapCount = localId.split('/')[0];
            var prodCount = localId.split('/')[1];
            var fileIdx = localId.split('/')[2];
            var fileId = localId.split('/')[3];
            var shipToAndProds = component.get('v.shipToAndProds');
            shipToAndProds[sapCount].prods[prodCount].Attachments.splice(fileIdx, 1);
            var action = component.get('c.deleteFiles');
            action.setParams({
                "recordId" : fileId
            });
            action.setCallback(this, function(response){
                if(response.getState() === "SUCCESS"){
                    console.log('file deleted');
                    helper.showToast('File has been deleted!!', 'success', 'Success');
                    component.set('v.shipToAndProds', shipToAndProds);
                }
            });
            $A.enqueueAction(action);  
        }
    }, 
    
    handleProdFileChange : function(component, event, helper){
        var localId = event.getSource().get('v.name');
        var sapCount = localId.split('/')[0];
        var prodCount = localId.split('/')[1];
        var shipToAndProds = component.get('v.shipToAndProds');
        if(!shipToAndProds[sapCount].prods[prodCount].Attachments){
            shipToAndProds[sapCount].prods[prodCount].Attachments = [];
        }
        var files = event.getSource().get('v.files');
        if(files.length > 0){
            for(var i=0;i<files.length;i++){
                files[i].Id ='';
                files[i].Name = files[i].name;
                shipToAndProds[sapCount].prods[prodCount].Attachments.push(files[i]);
            }
        }
        component.set('v.shipToAndProds', shipToAndProds);
    },
    removeFile : function(component, event, helper){
        var localId = event.getSource().get('v.id');
        var sapCount = localId.split('/')[0];
        var prodCount = localId.split('/')[1];
        var fileIdx = localId.split('/')[2];
        var shipToAndProds = component.get('v.shipToAndProds');
        shipToAndProds[sapCount].prods[prodCount].Attachments.splice(fileIdx, 1);
        component.set('v.shipToAndProds', shipToAndProds);
    }
})