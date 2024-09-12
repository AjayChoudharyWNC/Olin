({
    doInit : function(component, event, helper) {
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
                    component.set('v.shipTos', shipTos);
                    if(isAllShipToCompleted && isAllSectionCompleted)
                        component.set('v.isAllSectionCompleted', isAllSectionCompleted);
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    handleTabRedirect : function(component, event, helper){
        var oprId = event.currentTarget.name;
        var sapRecord = component.get('v.sapRecord');
        var appEvent = $A.get("e.c:OCO_CustomerTreeClick");
        appEvent.setParams({ "nodeClicked" : 'OPR', "nodeId": oprId, "sapNo": sapRecord.Name});
        appEvent.fire();
    }, 
    handleShareWithColleague : function(component, event, helper){
        var parent = component.get('v.parent');
        parent.openShareWithColleague();
    },
    
    handleSubmit : function(component, event , helper){
        var languageMap = component.get('v.languageLabelMap');
        component.set('v.confirmMessage',languageMap['CI_143']);
        component.set('v.showConfirmDialog', true);
    },
    
    handleConfirmDialog : function(component, event, helper){
        var name = event.getSource().get('v.name');
        if(name == 'Cancel'){
            component.set('v.showConfirmDialog', false);
        }
        if(name == 'Submit'){
            component.set('v.showConfirmDialog', false);
            component.set('v.spinner', true);
            var sapRecord = component.get('v.sapRecord');
            sapRecord.Product_Stewardship_Status__c = 'Customer Submitted';
            component.set('v.sapRecord', sapRecord);
            helper.updateSapRecord(component);
        }
        
    },
    videoClick : function(component, event, helper) {
        component.set('v.showVideo',true);
    },
    cancel: function(component, event, helper) {
        component.set('v.showVideo',false);
    }
})