({
	callAccShipToSearch : function(component, soldToAccountId) {
        
        var accRelationshipService = component.find("accRelationshipService");
        
        var callback = function(response) {
            
            var state = response.getState();
            
            if (state === "SUCCESS") {
                
                var storeResponse = response.getReturnValue();
                
                if (storeResponse.length > 0) {
                    
                    var whereClause = "Id IN (";
                    
                    storeResponse.forEach(function(accId) {
                        whereClause += "'" + accId + "', ";
                    });
                    
                    whereClause = whereClause.substring(0, whereClause.length - 2) + ")";
                    
                    component.set("v.whereClause", whereClause);
                    
                }
                
            }
            
        };
        
        accRelationshipService.searchShipToAccount(soldToAccountId, callback);
        
    }
})