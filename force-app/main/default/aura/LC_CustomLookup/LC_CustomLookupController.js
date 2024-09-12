({
    onClicked : function(component, event, helper) {
        
        var listOfSearchResults = component.get("v.listOfSearchResults");
        
        if(!listOfSearchResults || listOfSearchResults.length == 0) {
        
            var getKeywordInput = event.target.value;
            helper.openSearchComponents(component);
            helper.searchHelper(component, getKeywordInput);
            
        }
        
    },
    
    onKeyPressed : function(component, event, helper) {
        
        var getKeywordInput = event.target.value;
        
        helper.openSearchComponents(component);
        helper.searchHelper(component, getKeywordInput);
        
    }, 
    
    onMouseLeave : function(component, event, helper) {
        
        component.set("v.listOfSearchResults", null); 
        
        helper.removeSearchComponents(component);
        
    },
    
    handleSelectedRecord : function(component, event, helper) {
        
        var resultIndex = event.currentTarget.getAttribute("value");;
        
        var selectedRecord = component.get("v.listOfSearchResults[" + resultIndex + "]");
        component.set("v.selectedRecord", selectedRecord);
        
        helper.removeSearchComponents(component);
        
    },
    
    handleRemoveSelectedRecord  : function(component, event, helper) {
        
        component.set("v.keyWord", "");
        component.set("v.selectedRecord", null);
        component.set("v.listOfSearchResults", null); 
        
        helper.openSearchComponents(component);
        helper.searchHelper(component, "");
            
    }
    
})