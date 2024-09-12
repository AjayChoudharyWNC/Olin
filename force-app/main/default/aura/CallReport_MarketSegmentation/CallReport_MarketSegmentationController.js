({
    doInit : function(component, event, helper) {
        helper.fetchPurchasedProducts(component, true);
    },
    
    closeModel : function(componnet, event, helper){
        $A.get("e.force:closeQuickAction").fire();
    },
    
    handleMarketSegmentUpdate : function(component, event, helper){
        component.set('v.currentPurchasedProdid', event.getSource().get('v.name'));
        component.set('v.showMarketSegment', true);
    },
    
    closeMarketSegment : function(component, event, helper){
        component.set('v.showMarketSegment', false);
    },
    
    saveMarketSegment : function(component, event, helper){
        component.find('recordForm').submit();
    },
    
    handleFormSuccess : function(component, event, helper){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title" : 'Successs',
            "message": 'Market Segmentation updated successfully',
            "duration": "5000",
            "key": "info_alt",
            "type": 'success',
            "mode": "dismissible"
        });
        toastEvent.fire();
        component.set('v.showMarketSegment', false);
    },
    
    handleError : function(component, event, helper){
        debugger;
        var toastEvent = $A.get("e.force:showToast");
        event.preventDefault();
         var error = event.getParams();
        console.log("Error : " + JSON.stringify(error));
        toastEvent.setParams({
            "title" : 'Error',
            "message": event.getParam("detail"),
            "duration": "5000",
            "key": "info_alt",
            "type": 'error',
            "mode": "dismissible"
        });
        toastEvent.fire();
    },
    
    handleAccountChange : function(component, event, helper){
        component.set('v.loaded', false);
        let pickValue = event.getSource().get('v.value');
        let accountIds = [];
        if(pickValue == 'All'){
            let soldToAccountList = component.get('v.soldToAccountList');
            soldToAccountList.forEach((acc) => {
               accountIds.push(acc.Id); 
            });
        }
                else{
                accountIds.push(pickValue);
            }
        component.set('v.accountIds', accountIds);
        helper.fetchPurchasedProducts(component, false);
    }
})