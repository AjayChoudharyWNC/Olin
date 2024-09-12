({
    doInit : function(component, event, helper) {
        var action = component.get('c.getQuestionnaire');
        action.setParams({
            "recordId": component.get('v.recordId')
        });
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                var ques = response.getReturnValue();
                var recordTypeName = ques.RecordType.Name;
                var vfPageName = '';
                var setup = ques.Questionnaire_Setup_Type__c;
                if (recordTypeName == 'Hydrochloric Acid - Rail') {
                    vfPageName = 'HydrochloricAcidRailCarPDF';
        
                }
                else if (recordTypeName == 'Hydrochloric Acid - Truck') {
                    vfPageName = 'HydrochloricAcidTankTruckPDF';
        
                }
                else if (recordTypeName == 'Potassium Hydroxide - Barge') {
                    vfPageName = 'PotassiumHydroxideBargePDF';
        
                }
                else if (recordTypeName == 'Potassium Hydroxide - Rail') {
                    vfPageName = 'PotassiumHydroxideRailCarPDF';
        
                }
                else if (recordTypeName == 'Potassium Hydroxide - Truck') {
                    vfPageName = 'PotassiumHydroxideTankTruckPDF';
        
                }
                else if (recordTypeName == 'Sodium Hydroxide - Barge') {
                    vfPageName = 'SodiumHydroxideBargePDF';
        
                }
                else if (recordTypeName == 'Sodium Hydroxide - Rail') {
                    vfPageName = 'SodiumHydroxideRailCarPDF';
        
                }
                else if (recordTypeName == 'Sodium Hydroxide - Truck') {
                    vfPageName = 'SodiumHydroxideTankTruckPDF';
        
                }
                else if (recordTypeName == 'Sodium Hypochlorite - Rail') {
                    vfPageName = 'SodiumHypochloriteRailCarPDF';
        
                }
                else if (recordTypeName == 'Sodium Hypochlorite - Truck') {
                    vfPageName = 'SodiumHypochloriteTankTruckPDF';
        
                }
                else if (recordTypeName == 'Sulfuric Acid - Rail Car') {
                    vfPageName = 'SulfuricAcidRailCarPDF';
        
                }
                else if (recordTypeName == 'Sulfuric Acid - Truck') {
                    vfPageName = 'SulfuricAcidTankTruckPDF';
        
                }
                    else if(recordTypeName == 'Standard Truck'){
                        vfPageName = 'StandardTruckPDF';
                    }
                if (setup == 'Offline') {
                    alert('No Pdf is available for offline assessment, Please refer to attached documents.');
                    $A.get("e.force:closeQuickAction").fire();
                }
                else {
                    component.set('v.redirectUrl', '/apex/' + vfPageName + '?id=' + ques.Id);
                }
            }
        });
        $A.enqueueAction(action);
    }
})