({
    doInit : function(component, event, helper){
        var recordId = component.get('v.recordId');
        var sObjectName = component.get('v.sObjectName');
        var productApiName = component.get('v.ProductApiName');
        if(recordId && sObjectName && productApiName){
            var action = component.get('c.getProductId');
            action.setParams({
                'recordId' : recordId,
                'sObjectName' : sObjectName,
                'productApiName' : productApiName
            });
            action.setCallback(this, function(response){
                if(response.getState() === 'SUCCESS'){
                    var productId = response.getReturnValue();
                    if (productId) {
                        component.set('v.selectedProd', productId);
                        helper.fetchUOMList(component, productId);
                        helper.fetchProductCharges(component, productId);
                    }
                } 
            });
            $A.enqueueAction(action);
        }
    },
    
    handleProductSelected : function(component, event, helper) {
        var productId = event.getSource().get('v.value');
        if(Array.isArray(productId)){
            productId = productId[0];
        }
        if (productId) {
            component.set('v.selectedProd', productId);
            helper.fetchUOMList(component, productId);
            helper.fetchProductCharges(component, productId);
        }
        else{
            component.set('v.uomList', []);
            component.set('v.productCharges', null);
            component.set('v.selectedUOM', null);
            component.set('v.selectedProd', null);
            helper.resetForm(component);
        }
        
    },
    handleUOMChange : function(component, event, helper) {
        if(component.find('AIP').get('v.disabled')){
            component.set('v.AIP', null);
        }
        if(component.find('productPrice').get('v.disabled')){
            component.set('v.productPrice', null);
        }
         component.find('calculateBtn').set('v.disabled', false);
        component.set('v.calculatedTax', null);
    },
    
    handleAIPChange :  function(component, event, helper) {
        if(event.getSource().get('v.value')){
            component.find('productPrice').set('v.disabled', true);
        }
        else{
            component.find('productPrice').set('v.disabled', false);
        }
    },
    
    handleProductPriceChange :  function(component, event, helper) {
        if(event.getSource().get('v.value')){
            component.find('AIP').set('v.disabled', true);
        }
        else{
            component.find('AIP').set('v.disabled', false);
        }
    },
    
    handleCalculateTax : function(component, event, helper){
        var uomList = component.get('v.uomList');
        var productCharges = component.get('v.productCharges');
        var productPrice = component.get('v.productPrice');
        var AIP = component.get('v.AIP');
        var selectedUOM = component.get('v.selectedUOM');
        var selectedProd = component.get('v.selectedProd');
        var superFundTax;
        var calculatedAIP;
        var calculatedTax;
        var calculatedProdPrice;
        if(!selectedProd){
            helper.showToast('error', 'Error', 'Please select a product to proceed.');
            return;
        }
        if(!uomList || uomList.length == 0){
            helper.showToast('info', 'Info', 'There are currently no UOM Conversion records for this product. Please contact the Olin Salesforce Team.');
            return;
        }
        if(!productCharges){
            helper.showToast('info', 'Info', 'This product currently does not have a Superfund Excise Tax record or value associated with it. If it should please contact the Olin Salesforce Team.');
            return;
        }
        else{
            superFundTax = productCharges.Charge_Amount__c;            
        }
        if(!AIP && !productPrice){
            helper.showToast('error', 'Error', 'Please provide the value for one of these: Product Price or AIP');
            return;
        }
        if(AIP){
            calculatedTax = parseFloat(selectedUOM) * superFundTax;
            calculatedProdPrice = parseFloat(AIP) - calculatedTax;
            component.set('v.productPrice', calculatedProdPrice);
            component.set('v.calculatedTax', calculatedTax);
            component.find('calculateBtn').set('v.disabled', true);
            return;
        }
        if(productPrice){
            calculatedTax = parseFloat(selectedUOM) * superFundTax;
            calculatedAIP = parseFloat(productPrice) + calculatedTax;
            component.set('v.AIP', calculatedAIP);
            component.set('v.calculatedTax', calculatedTax);
            component.find('calculateBtn').set('v.disabled', true);
            return;
        }
        
    },
    
    handleResetForm : function(component, event, helper){
       helper.resetForm(component);
    }
})