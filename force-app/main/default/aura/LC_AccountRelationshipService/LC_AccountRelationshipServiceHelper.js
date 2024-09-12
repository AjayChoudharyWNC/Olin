({
    callGetAccountShipToMethod : function(component, soldToId, callback) {

        var action = component.get("c.getAccountShipTo");
        
        action.setParams({
            'soldToId': soldToId
        });
        
        action.setCallback(this, callback);
        
        $A.enqueueAction(action);
        
    },
    
    callInsertNewAccountRelationshipRecordMethod : function(component, soldToId, shipToId, callback) {
        var action = component.get("c.insertNewAccountRelationshipRecord");
        
        action.setParams({
            'soldToId': soldToId,
            'shipToId': shipToId
        });
        
        action.setCallback(this, callback);
        
        $A.enqueueAction(action);
    }
})