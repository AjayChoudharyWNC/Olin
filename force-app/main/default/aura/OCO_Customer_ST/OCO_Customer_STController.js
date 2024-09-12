({
	init : function(component, event, helper) {
		var action = component.get('c.getShipToDetails');
        action.setParams({
            'ostId' : component.get('v.stId')
        });
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS'){
                var shipTo = response.getReturnValue();
                var isSteawrdshipContactRequired = false;
                var isAFterHoursContactRequired = false;
                if(shipTo.Onboarding_Products__r && shipTo.Onboarding_Products__r.length > 0){
                    for(var i=0;i<shipTo.Onboarding_Products__r.length;i++){
                        var prod = shipTo.Onboarding_Products__r[i];
                        if(prod.Product_Family__c == 'CAPV'){
                            isAFterHoursContactRequired = true;
                            if(shipTo.New_Customer_Ship_Mode__c != 'Truck' || shipTo.Customer_Pickup__c != 'Yes'){
                                isSteawrdshipContactRequired = true;
                            }
                        }
                        else{
                            if(prod.Shipment_Questionnaire__c && (prod.Shipment_Questionnaire__c.includes('Standard High Medium Checklist') || prod.Shipment_Questionnaire__c.includes('Chloroform Checklist') ||
                               prod.Shipment_Questionnaire__c.includes('Methyl Chloride Checklist') || prod.Shipment_Questionnaire__c.includes('Upstream Bisphenol') ||
                               prod.Shipment_Questionnaire__c.includes('Upstream EPI') || prod.Shipment_Questionnaire__c.includes('Upstream Dichloropropene'))){
                                isSteawrdshipContactRequired = true;
                            }
                        }
                    }
                }
                
                component.set('v.ostRecord',response.getReturnValue());
                component.set('v.isSteawrdshipContactRequired',isSteawrdshipContactRequired);
                component.set('v.isAFterHoursContactRequired',isAFterHoursContactRequired);
            }
        });
        $A.enqueueAction(action);
        helper.checkForAllSections(component, event);
	},
    onLoadShipToForm: function(component,event){
        //var sapId = component.find('sapId').get('v.value');
        // component.set('v.sapId', sapId);
    },
    
    handleFormSuccess : function(component, event, helper) {
        component.set('v.spinner', false);
        var parent = component.get('v.parent');
        var sap = event.getParams().response;
        console.log('sapId',sap,sap.id);
        helper.checkForAllSections(component, event);
        if(sap.id && !component.get('v.isFormSubmitManual')){
            parent.openToast('utility:success','JS_18', 'success'); 
            setTimeout(function(){
                //parent.getSapRecord();
            }, 3000);
            
        }
        else{
            parent.openToast('utility:success','JS_19', 'success');      
        }
    },
    
    handleError : function(component, event, helper){
        component.set('v.spinner', false);
    },
    
    handleFormSubmit : function(component, event, helper){
        event.preventDefault();
        var fields = event.getParam('fields');
        fields['Ship_To_Section_Completed__c'] = true;
        component.set('v.isFormSubmitManual', false);
        component.find('stForm').submit(fields);
        component.set('v.spinner', true);
    },
    handleSaveProgress : function(component, event, helper){
        component.set('v.isFormSubmitManual', true);
        component.set('v.spinner', true);
        component.find('stForm').submit();
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
    handleInputChange : function(component, event, helper){
        var fieldName = event.getSource().get('v.name');
        var ostRecord = component.get('v.ostRecord');
        var val = event.getSource().get('v.value');
        var languageLabelMap = component.get('v.languageLabelMap');
        if(val == 'Do Not Wish to Receive'){
            ostRecord[fieldName] = '';
        }
        if(fieldName=='Invoice_Copies_Email_Fax__c')
        {
            ostRecord['Invoice_Copies__c']=event.getSource().get("v.value");  
        }
        if(fieldName=='SDS_Delivery_Email_Fax__c')
        {
            ostRecord['Preferred_Method_of_MSDS_Delivery__c']=event.getSource().get("v.value");
        }
        if(fieldName=='Order_Confirmation_Email_Fax__c')
        {
            ostRecord['Preferred_Method_of_Order_Confirmation__c']=event.getSource().get("v.value");
        }
        if(fieldName=='Bill_of_Lading_Email_Fax__c')
        {
            ostRecord['Preferred_Method_of_Bill_of_Lading__c']=event.getSource().get("v.value");
        }
        if(fieldName=='Certificate_of_Analysis_Email_Fax__c')
        {
            ostRecord['Preferred_Method_of_Certifi_of_Analysis__c']=event.getSource().get("v.value");
        }
        component.set('v.ostRecord', ostRecord);
        
    }
})