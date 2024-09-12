({
     MAX_FILE_SIZE: 4500000, //Max file size 4.5 MB 
    CHUNK_SIZE: 750000, //Chunk Max size 750Kb 
    getShipToAccountDetails: function (component, event, shipToAccId, shipToCounter) {
        var shipToAccIds = component.get('v.shipToAccIds');
        var action = component.get('c.GetAccountInfo');
        action.setParams({
            "acId": shipToAccId
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                var account = response.getReturnValue();
                var shipToAndProds = component.get('v.shipToAndProds');
                var prodIds = [];
                var onShip = new Object();
                onShip.Ship_To_Company_Name__c = account.Name;
                onShip.Ship_To_City__c = account.BillingCity;
                onShip.Ship_To_Country__c = account.BillingCountry;
                onShip.Ship_To_No__c = account.AccountNumber_R1__c;
                onShip.Ship_To_Postal_Code__c = account.BillingPostalCode;
                onShip.Ship_To_State_Province__c = account.BillingState;
                onShip.Ship_To_Street__c = account.BillingStreet;
                onShip.Ship_To_Street_2__c = '';
                onShip.Account__c = account.Id;
                onShip.selectedTabId = (parseInt(shipToCounter)+1)+'ShipTo';
                var getShipTo = component.get('c.getShipToAccounts');
                getShipTo.setParams({
                    "acId": shipToAccId,
                    "sapId": component.get('v.sapId')
                });
                getShipTo.setCallback(this, function (response) {
                    if (response.getState() === "SUCCESS") {
                        var shipTo = response.getReturnValue();
                        if (shipTo && shipTo.Id) {
                            onShip.Id = shipTo.Id;
                            onShip.Ship_To_Company_Name__c = shipTo.Ship_To_Company_Name__c;
                            onShip.Ship_To_City__c = shipTo.Ship_To_City__c;
                            onShip.Ship_To_Country__c = shipTo.Ship_To_Country__c;
                            onShip.Ship_To_No__c = shipTo.Ship_To_No__c;
                            onShip.Ship_To_Postal_Code__c = shipTo.Ship_To_Postal_Code__c;
                            onShip.Ship_To_State_Province__c = shipTo.Ship_To_State_Province__c;
                            onShip.Ship_To_Street__c = shipTo.Ship_To_Street__c;
                            onShip.Ship_To_Street_2__c = shipTo.Ship_To_Street_2__c;
                            if (shipTo.Onboarding_Products__r) {
                                var prods = shipTo.Onboarding_Products__r;
                                for (var i = 0; i < prods.length; i++){
                                    prods[i].prodName = 'Product';
                                    prods[i].saved = true;
                                    prods[i].oldShipMode = prods[i].Ship_Mode__c;
                                    prods[i].selectedProd = prods[i].Purchased_Product__c;
                                    prods[i].purchasedProd = prods[i].Purchased_Product__c;
                                    prods[i].prodName = prods[i].Purchased_Product__r.Product_R1__r.Name;
                                    prods[i].prodFamily = prods[i].Purchased_Product__r.Product_R1__r.Family;
                                    prods[i].performanceCenter = prods[i].Purchased_Product__r.Performance_Center__c;
                                    if(prods[i].Id){
                                        prodIds.push(prods[i].Id);
                                    }
                                }
                                onShip.prods = prods;
                            }
                            else {
                                onShip.prods = [];
                            }
                        }
                        else {
                            onShip.prods = [];
                        }
                        shipToAndProds.push(onShip);
                        component.set('v.shipToAndProds', shipToAndProds);
                        component.set('v.OldShipToAndProds', shipToAndProds);
                        if(prodIds.length > 0){
							this.fetchFiles(component, event);
                        }
                        if(shipToAccIds.length == shipToAndProds.length && component.get('v.checkForFinalButton'))
                            this.checkForFinalButton(component, event, helper, false)
                            }
                })
                $A.enqueueAction(getShipTo);
                
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchFiles : function(component, event){
        var shipToAndProds = component.get('v.shipToAndProds');
        var prodIds = [];
        shipToAndProds.forEach(function(shipTo){
            shipTo.prods.forEach(function(prod){
                if(prod.Id){
                    prodIds.push(prod.Id); 
                }
            });
        });
        if(prodIds){
            var action = component.get('c.fetchProdFiles');
            action.setParams({
                prodIds : prodIds
            });
            action.setCallback(this, function(response){
                if(response.getState() === 'SUCCESS'){
                    var files = response.getReturnValue();
                    shipToAndProds.forEach(function(shipTo){
                        shipTo.prods.forEach(function(prod){
                            if(files && prod.Id && files[prod.Id]){
                                prod.Attachments = files[prod.Id];
                            }
                            else{
                                prod.Attachments = [];
                            }
                        })
                    });
                    component.set('v.shipToAndProds', shipToAndProds);
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    fetchCustomerSetupRecord : function(component, event){
        var action = component.get('c.fetchSapRecord');
        action.setParams({
            sapId : component.get('v.sapId')
        });
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                component.set('v.sapRecord', response.getReturnValue());
                //component.set('v.spinner', false);
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchLayoutFields : function(component, event, layoutName, shipToAccId, onboardShipToId, isReturn){
        component.set('v.spinner', true);
        var shipToAndProds = component.get('v.shipToAndProds');
        for (var i = 0; i < shipToAndProds.length; i++) {
            if (shipToAndProds[i].Id == onboardShipToId) {
                var prod = {};
                prod.prodName = 'Product';
                prod.saved = false;
                prod.selectedProd = '';
                prod.purchasedProd = '';
                shipToAndProds[i].prods.push(prod);
                shipToAndProds[i].selectedTabId = (i + 1) + 'Product' + (shipToAndProds[i].prods.length);
                break;
            }
        }
        component.set("v.shipToAndProds", shipToAndProds);
        component.set('v.spinner', false);
        
    },
    
    populateProductFields : function(component, fieldName, prodId, sectionNumber, sapCount, prodCount){
        var shipToAndProds = component.get('v.shipToAndProds');
        if (sectionNumber == 0)
            var mainAccount = component.get('v.mainAccount');
        var soldToCountry = mainAccount.BillingCountry;
        if(prodId){
            var action = component.get('c.getProductInfo');
            action.setParams({
                productId : prodId
            });
            action.setCallback(this, function(response){
                if(response.getState() === "SUCCESS"){
                    var product = response.getReturnValue();
                    component.set('v.prodFamily', product.Product_R1__r.Family);
                    console.log(product, product.Product_R1__r.Family);
                    shipToAndProds[sapCount].prods[prodCount].prodFamily = product.Product_R1__r.Family;
                    shipToAndProds[sapCount].prods[prodCount].prodName = product.Product_R1__r.Name;
                    shipToAndProds[sapCount].prods[prodCount].performanceCenter = product.Performance_Center__c;
                    if(product.Product_R1__r.Family == 'CAPV'){
                        component.set('v.truckType', 'Bulk');
                    }
                    else{
                        component.set('v.truckType', '');
                    }
                    shipToAndProds[sapCount].prods[prodCount].tabLabel = product.Product_R1__r.Name;
                    console.log(product.Ship_Mode__c);
                    if (fieldName == 'Purchased_Product__c') {
                        shipToAndProds[sapCount].prods[prodCount].Ship_Mode__c = product.Ship_Mode__c;
                        shipToAndProds[sapCount].prods[prodCount].Product_Name_Form__c = product.Product_R1__r.Name;
                        if (soldToCountry != 'Canada' && soldToCountry != 'United States') {
                            shipToAndProds[sapCount].prods[prodCount].Product_UOM__c = product.Global_UOM__c;
                        }
                        else{
                            shipToAndProds[sapCount].prods[prodCount].Product_UOM__c = product.Standard_UOM__c;
                        }
                        
                    }
                    component.set('v.shipToAndProds',shipToAndProds);
                }
            });
            $A.enqueueAction(action);
        }
        else{
            component.set('v.prodFamily', 'CAPV');
            shipToAndProds[sapCount].prods[prodCount].prodFamily = 'CAPV';
            if(fieldName == 'Purchased_Product__c'){
                shipToAndProds[sapCount].prods[prodCount].Ship_Mode__c = '';
                shipToAndProds[sapCount].prods[prodCount].Product_Name_Form__c = '';
                shipToAndProds[sapCount].prods[prodCount].Product_UOM__c = '';
                shipToAndProds[sapCount].prods[prodCount].tabLabel = '';
                shipToAndProds[sapCount].prods[prodCount].Primary_Ship_From__c = '';
            }
            component.set('v.shipToAndProds',shipToAndProds);
        }
    },
    
    fetchShipFromPlantAccounts : function(component, event, prodId){
        var action = component.get('c.getShipFromPlants');
        action.setParams({
            prodId : prodId
        });
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS'){
                component.set('v.shipFromPlantList', response.getReturnValue());
            } 
        });
        $A.enqueueAction(action);
    },
    populateContactFields: function (component, fieldName, conId, sapCount, prodCount) { 
        var contacts = component.get('v.relatedContacts');
        var con;
        var shipToAndProds = component.get('v.shipToAndProds'); 
        for (var i = 0; i < contacts.length; i++){
            if (contacts[i].Id == conId) {
                con = contacts[i];
            }
        }
        if (conId && fieldName == 'Regulatory_Contact__c') {
                                           // changed by shivam
            shipToAndProds[sapCount].Regulatory_Contact__c = con.Id;
            shipToAndProds[sapCount].Regulatory_First_Name__c = con.FirstName;
            shipToAndProds[sapCount].Regulatory_Last_Name__c = con.LastName; 
            shipToAndProds[sapCount].Regulatory_Title__c = con.Title;
            shipToAndProds[sapCount].Regulatory_Phone__c = con.Phone;
            shipToAndProds[sapCount].Regulatory_Email__c = con.Email;
            shipToAndProds[sapCount].Regulatory_Contact_Fax__c = con.Fax;
        }
        else if (!conId && fieldName == 'Regulatory_Contact__c') {

            shipToAndProds[sapCount].Regulatory_Contact__c = '';
            shipToAndProds[sapCount].Regulatory_First_Name__c = '';
            shipToAndProds[sapCount].Regulatory_Last_Name__c = '';
            shipToAndProds[sapCount].Regulatory_Title__c = '';
            shipToAndProds[sapCount].Regulatory_Phone__c = '';
            shipToAndProds[sapCount].Regulatory_Email__c = '';
            shipToAndProds[sapCount].Regulatory_Contact_Fax__c = '';
        }
        component.set('v.shipToAndProds', shipToAndProds);
    },
    
    checkForFinalButton : function(component, event, helper, isProd, isDeleteProd){
        var shipToAndProds = component.get('v.shipToAndProds');
        var isAllSapSaved = false;
        console.log('shipToAndProds===',shipToAndProds);
        for(var i=0;i<shipToAndProds.length;i++){
            if(shipToAndProds[i].prods.length == 0){
                isAllSapSaved = false;
                break;
            }
            else{
                for(var p=0;p<shipToAndProds[i].prods.length;p++){
                    if(p == 0){
                        if(shipToAndProds[i].prods[p].saved){
                            isAllSapSaved = true;
                            break;
                        }
                        else{
                            isAllSapSaved = false;
                            break;
                        }
                    }
                }
            }
        }
        if(isAllSapSaved){
            if(component.find('finalSubmitBtn'))
                component.find('finalSubmitBtn').set('v.disabled', false);
            if(component.find('sapSendButton')){
                component.find('sapSendButton').set('v.disabled', false);
            }
            if(!isDeleteProd)
                this.showToast('Product details saved. Now click on \'Save Form\' button, or \'Add Another Product\' button', 'success', 'Success');
        }
        else {
            if(component.find('finalSubmitBtn'))
                component.find('finalSubmitBtn').set('v.disabled', true);
            if(isProd)
                this.showToast('Product has been saved successfully!!', 'success', 'Success');
        }
        component.set('v.spinner',false);
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
                    if(cancelSap){
                        this.showToast('All changes have been discarded successfully, now you can start over!!', 'success', 'Success');
                        window.location.reload();//$A.get("e.force:closeQuickAction").fire();
                        this.callQuickAction(component, event);
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
    
    callQuickAction : function(component, event){
        var actionAPI = component.find("quickActionAPI");
        var args = { actionName :"Account.Reload_In_Progress_SAP_Onboarding"};
        actionAPI.selectAction(args).then(function(result) {
            
        }).catch(function(e) {
            if (e.errors) {
                
            }
        });
    },
    
    handleEpoxyProductSubmission : function(component, event, op){
        var shipMode = op.Ship_Mode__c;
        var oldShipMode = op.oldShipMode;
        var action = component.get('c.getAssessments');
        action.setParams({
            op : op
        });
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS'){
                var result = response.getReturnValue();
                if(result.length > 0){
                    event.getSource().submit();
                    component.set('v.spinner', true);
                }
                else if(oldShipMode == '01' && result.length == 0){
                    if(confirm("Warning! The ship mode has been changed. Changing the ship-mode will remove the current product assessment information/form and replace with the new mode information/form if applicable. Any data input by customer will be lost. Do you want to continue?")){
                        event.getSource().submit();
                        component.set('v.spinner', true);
                    }
                }
                    else{
                        event.getSource().submit();
                        component.set('v.spinner', true);
                    }
            } 
        });
        $A.enqueueAction(action);
    },
    
    updateProductAssessment : function(component, event, prodId){
        var action = component.get('c.updateAssessment');
        action.setParams({
            prodId : prodId
        });
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS'){
                console.log('assessment updated');
            }
        });
        $A.enqueueAction(action);
    },
    
    handleDeleteProduct : function(component, event, helper, prodId){
        var action = component.get('c.deleteOnboardingProduct');
        action.setParams({prodId : prodId});
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS'){
                component.set('v.spinner',false);
                this.checkForFinalButton(component, event, helper, false, true);
            } 
            else{
                component.set('v.spinner',false);
            }
        });
        $A.enqueueAction(action);
    },
    
    uploadHelper: function (component, event, f, fileType) {
        var file = f;
        var self = this;
        var languageMap = component.get('v.languageLabelMap');
        // check the selected file size, if select file size greter then MAX_FILE_SIZE,
        // then show a alert msg to user,hide the loading spinner and return from function  
        if (file.size > self.MAX_FILE_SIZE) {
            alert('File size exceeds!!');
            return;
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
                    console.log('your File is uploaded successfully', true);
                    component.set('v.spinner', false);
                    this.fetchFiles(component, event);
                }
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
    
    showToast : function(message,type,title){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title" : title,
            "message": message,
            "duration": "10000",
            "key": "info_alt",
            "type": type,
            "mode": "dismissible"
        });
        toastEvent.fire();
    }
})