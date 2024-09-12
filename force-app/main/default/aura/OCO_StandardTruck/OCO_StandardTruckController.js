({
	handlePSFittingChange : function(component, event, helper) {
        var val = event.getSource().get('v.value');
        if(val == 'Other'){
            component.set('v.plantSideCommentReqd',true);
        }
        else{
        	component.set('v.plantSideCommentReqd',false);
        }
	},
    handlePlantSideConnChange: function(component,event){
        var val = event.getSource().get('v.value');
        if(val == 'No' || val == 'N/A'){
            component.set('v.plantSideConnectionCmntReq',true);
        }
        else{
        	component.set('v.plantSideConnectionCmntReq',false);
        }
    },
    handleCustAirUsedChange: function(component,event){
        var val = event.getSource().get('v.value');
        if(val == 'No'){
            component.set('v.customerAirUsedCmntReq',true);
        }
        else{
        	component.set('v.customerAirUsedCmntReq',false);
        }
    },
    handleTrainingProcCheckChange: function(component,event){
        var val = event.getSource().get('v.value');
        if(val == 'No' || val == 'N/A'){
            component.set('v.trainingProcChecklistCmntReq',true);
        }
        else{
        	component.set('v.trainingProcChecklistCmntReq',false);
        }
    },
    handleEmergencyChange: function(component,event){
        var val = event.getSource().get('v.value');
        if(val == 'No' || val == 'N/A'){
            component.set('v.trainingEmergencyCmntReq',true);
        }
        else{
        	component.set('v.trainingEmergencyCmntReq',false);
        }
    },
    handleEmpTrainedChange: function(component,event){
        var val = event.getSource().get('v.value');
        if(val == 'No' || val == 'N/A'){
            component.set('v.trainingEmpTrainedCmntReq',true);
        }
        else{
        	component.set('v.trainingEmpTrainedCmntReq',false);
        }
    }
})