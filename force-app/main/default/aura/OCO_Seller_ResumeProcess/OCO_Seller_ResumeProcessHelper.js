({
    fetchRelatedProds : function(component, event, sapId){
        component.set('v.showSpinner',true);
        var getProducts = component.get('c.getRelatedProducts');
        getProducts.setParams({
            soldToAccId : component.get('v.recordId'),
            sapId : sapId
        });
        getProducts.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                component.set('v.relatedProducts', response.getReturnValue());
            }
            component.set('v.showSpinner',false);
        });
        $A.enqueueAction(getProducts);
    },
    
    fetchAccountDetails : function(component, event){
        component.set('v.showSpinner',true);
        var action = component.get('c.GetAccountInfo');
        action.setParams({
            acId : component.get('v.recordId')
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                component.set('v.mainAccount', response.getReturnValue());
            }
            component.set('v.showSpinner',false);
        });
        $A.enqueueAction(action);
    }
})