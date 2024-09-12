({
    checkForAllSections : function(component, event){
        if(component.get('v.sapId')){
            var action = component.get('c.getShipToAndProducts');
            action.setParams({
                "sapId" : component.get('v.sapId')
            });
            action.setCallback(this, function(response){
                if(response.getState() === 'SUCCESS'){
                    var shipTos = response.getReturnValue();
                    var isAllSectionCompleted = false;
                    var isAllShipToCompleted = false;
                    for(var i=0;i<shipTos.length;i++){
                        if(shipTos[i].Ship_To_Section_Completed__c){
                            isAllShipToCompleted = true;
                        }
                        else{
                            isAllShipToCompleted = false;
                        }
                        if(shipTos[i].Onboarding_Products__r){
                            for(var j=0; j<shipTos[i].Onboarding_Products__r.length;j++){
                                var prod = shipTos[i].Onboarding_Products__r[j];
                                if(prod.Product_Section_Completed__c && prod.All_Questionnaire_Completed__c){
                                    isAllSectionCompleted = true
                                }
                                else{
                                    isAllSectionCompleted = false;
                                    break;
                                }
                            }
                        }
                    }
                    if(isAllShipToCompleted && isAllSectionCompleted)
                        component.set('v.isAllSectionCompleted', isAllSectionCompleted);
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    updateSapRecord : function(component){
        var action = component.get('c.saveSapOnboarding');
        action.setParams({
            sapRecord : component.get('v.sapRecord')
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                var parent = component.get('v.parent');
                parent.openToast('utility:success','JS_17', 'success'); 
                parent.getSapRecord();
                component.set('v.spinner', false);
            }
        });
        $A.enqueueAction(action);
    }   
})