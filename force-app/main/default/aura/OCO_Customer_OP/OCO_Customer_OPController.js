({
    doInit : function(component, event, helper){
        var sapRecord = component.get('v.sapRecord');
        if(sapRecord){
            if(!sapRecord.Preferred_Method_of_Order_Confirmation__c){
                sapRecord.Preferred_Method_of_Order_Confirmation__c = 'Do Not Wish to Receive';
            }
            if(!sapRecord.Preferred_Method_of_Bill_of_Lading__c){
                sapRecord.Preferred_Method_of_Bill_of_Lading__c = 'Do Not Wish to Receive';
            }
            if(!sapRecord.Preferred_Method_of_Certifi_of_Analysis__c){
                sapRecord.Preferred_Method_of_Certifi_of_Analysis__c = 'Do Not Wish to Receive';
            }
            component.set('v.sapRecord', sapRecord);
        }
    },
    handleSaveProgress : function(component, event, helper){
        component.set('v.spinner', true);
        helper.updateSapRecord(component, false);
    },
    
    handleShareWithColleague : function(component, event, helper){
        var parent = component.get('v.parent');
        parent.openShareWithColleague();
    },
    
    handleFormSuccess : function(component, event, helper) {
        var sap = event.getParams().response;
        console.log('sapId',sap,sap.id);
        if(sap.id){
            var sapRecord = component.get('v.sapRecord');
            sapRecord.Order_Placement_Status__c = 'Customer Submitted';
            component.set('v.sapRecord', sapRecord);
            helper.updateSapRecord(component, true);
   
            
        }
    },
    
    handleFormSubmit : function(component, event, helper){
        event.preventDefault();
        var languageMap = component.get('v.languageLabelMap');
        if(confirm(languageMap['CI_143'])){
            component.set('v.spinner', true);
            event.getSource().submit();
        }
    },
    
    handleInputChange : function(component, event, helper){
        var fieldName = event.getSource().get('v.name');
        var sapRecord = component.get('v.sapRecord');
        var val = event.getSource().get('v.value');
        var languageLabelMap = component.get('v.languageLabelMap');
        if(val == languageLabelMap['DD_16']){
            sapRecord[fieldName] = '';
        }
        component.set('v.sapRecord', sapRecord);
        
    }
})