({
    fetchAllSoldToAccounts : function(component, accountId) {
        var action = component.get('c.getRelatedSoldToAccounts');
        action.setParams({
            parentAccountId : accountId
        });
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS'){
                component.set('v.soldToAccountList', response.getReturnValue());
                let accountIds = [];
                let soldToAccountList = component.get('v.soldToAccountList');
                soldToAccountList.forEach((acc) => {
                    accountIds.push(acc.Id); 
                });
                    component.set('v.accountIds', accountIds);
                    this.fetchPurchasedProducts(component, false);
                }
                    else{
                    component.set('v.loaded', true);
                }
                });
                    $A.enqueueAction(action);
                },
                    
    fetchPurchasedProducts : function(component, isInit){
        var action = component.get('c.getAllPurchasedProducts');
        action.setParams({
            recordId : component.get('v.recordId'),
            accountIds : component.get('v.accountIds')
        });
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS'){
                var result = response.getReturnValue();
                component.set('v.purchasedProdList', result.prodList);
                if(isInit){
                    if(result.accountType == 'Parent'){
                        this.fetchAllSoldToAccounts(component, result.accountId);
                    }
                    else{
                        component.set('v.loaded', true);
                    }
                }
                else{
                    component.set('v.loaded', true);
                }
            }
        });
        $A.enqueueAction(action);
    }
})