({
    showSpinner : function(component) {
		component.set("v.IsSpinner",true);
	},
    hideSpinner : function(component) {
		component.set("v.IsSpinner",false);
	},
	callAccShipToSearch : function(component, soldToAccountId) {
        /*var accRelationshipService = component.find("accRelationshipService");
        var callback = function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                if (storeResponse.length > 0) {
                    var whereClause = "Sold_To__c IN (";
                    storeResponse.forEach(function(accId) {
                        whereClause += "'" + accId + "', ";
                    });
                    whereClause = whereClause.substring(0, whereClause.length - 2) + ")";
                    console.log('whereClause====',whereClause);
                    component.set("v.locationWhereClause", whereClause);
                }
            }
        };
        accRelationshipService.searchShipToAccount(soldToAccountId, callback);*/
        var whereClause = "Sold_To__c = '"+soldToAccountId+"'";
        component.set("v.locationWhereClause", whereClause);
    }
})