({
    searchHelper : function(component, getKeywordInput) {
        
        var action = component.get("c.fetchLookUpValues");
        
        action.setParams({
            'searchKeyword': getKeywordInput,
            'objectName' : component.get("v.objectName"),
            'whereClause' : component.get("v.whereClause")
        });
        
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            
            if (state === "SUCCESS") {
                
                var storeResponse = response.getReturnValue();
                
                $A.util.addClass(component.find("mySpinner"), "slds-hide");
                
                if (storeResponse.length == 0) {
                    component.set("v.noResultMessage", 'No Result Found...');
                    component.set("v.listOfSearchResults", null);
                } else {
                    component.set("v.noResultMessage", '');
                    component.set("v.listOfSearchResults", storeResponse);
                }
                
                
            } else if(state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            
        });
        
        $A.enqueueAction(action);
        
    },
    
    openSearchComponents : function(component) {
        
        $A.util.removeClass(component.find("mySpinner"), "slds-hide");
        $A.util.addClass(component.find("searchResult"), 'slds-is-open');
        
    },
    
    removeSearchComponents : function(component) {
        
        $A.util.addClass(component.find("mySpinner"), "slds-hide");
        $A.util.removeClass(component.find("searchResult"), 'slds-is-open');
        
    }
    
})