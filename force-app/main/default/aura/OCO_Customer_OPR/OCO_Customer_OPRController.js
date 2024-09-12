({
	doInit : function(component, event, helper) {
		helper.fetchProductDetails(component);
	},
    
     handleFormSuccess : function(component, event, helper) {
        component.set('v.spinner', false);
        var sap = event.getParams().response;
        console.log('sapId',sap,sap.id);
        if(sap.id && !component.get('v.isFormSubmitManual')){
            setTimeout(function(){
                var parent = component.get('v.parent');
                parent.getSapRecord();
            }, 3000);
            
        }
        var parent = component.get('v.parent');
        parent.openToast('utility:success', 'Onboarding Product has been saved successfully!!', 'success');
    },
    
    handleFormSubmit : function(component, event, helper){
        event.preventDefault();
        var fields = event.getParams('fields');
        component.set('v.isFormSubmitManual', false);
        component.find('oprForm').submit(fields);
        component.set('v.spinner', true);
    },
    handleSaveProgress : function(component, event, helper){
        component.set('v.isFormSubmitManual', true);
        component.set('v.spinner', true);
        component.find('oprForm').submit();
    },
    
    handleShareWithColleague : function(component, event, helper){
        var parent = component.get('v.parent');
        parent.openShareWithColleague();
    }
})