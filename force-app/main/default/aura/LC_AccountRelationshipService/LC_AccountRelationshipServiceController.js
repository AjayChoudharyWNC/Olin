({
    doSearchShipToAccount : function(component, event, helper) {
        var params = event.getParam('arguments');
        if (params) {
            var soldToId = params.soldToId;
            var callback = params.callback;
            helper.callGetAccountShipToMethod(component, soldToId, callback);
        }
    },
    
    doInsertNewAccountRelationship : function(component, event, helper) {
        var params = event.getParam('arguments');
        if (params) {
            var soldToId = params.soldToId;
            var shipToId = params.shipToId;
            var callback = params.callback;
            helper.callInsertNewAccountRelationshipRecordMethod(component, soldToId, shipToId, callback);
        }
    }
})