({
    doInit : function(component, event, helper) {
        helper.fetchPurchasedProducts(component, true);
    },
    
    closeModel : function(componnet, event, helper){
        $A.get("e.force:closeQuickAction").fire();
    },
    
    handleWalletShareUpdate : function(component, event, helper){
        component.set('v.currentPurchasedProdid', event.getSource().get('v.name'));
        component.set('v.showWalletShare', true);
    },
    
    closeShareOfWallet : function(component, event, helper){
        component.set('v.showWalletShare', false);
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