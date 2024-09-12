({
	fetchUOMList : function(component, productId) {
		var action = component.get('c.fetchUOMList');
        action.setParams({'productId' : productId});
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS'){
                var result = response.getReturnValue();
                if(result && result.length > 0){
                    component.set('v.uomList',result);
                    component.set('v.selectedUOM', result[0].Conversion_Factor__c);
                }
                else{
                    this.showToast('info', 'Info', 'There are currently no UOM Conversion records for this product. Please contact the Olin Salesforce Team.');
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchProductCharges : function(component, productId) {
		var action = component.get('c.getProductCharges');
        action.setParams({'productId' : productId});
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS'){
                var result = response.getReturnValue();
                if(result){
                    component.set('v.productCharges',result);
                }
                
            }
        });
        $A.enqueueAction(action);
    },

    
    showToast : function(type, title, message){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type" : type
        });
        toastEvent.fire();
    },
    
    resetForm : function(component){
        component.set('v.AIP', null);
        component.set('v.calculatedTax', null);
        component.set('v.productPrice',null);
        component.find('AIP').set('v.disabled', false);
        component.find('productPrice').set('v.disabled', false);
        component.find('calculateBtn').set('v.disabled', false);
    }
    
    
})