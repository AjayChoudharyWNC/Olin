({
	handleFormSuccess : function(component, event, helper) {
       // component.set('v.spinner', false);
		var sap = event.getParams().response;
        console.log('sapId',sap,sap.id);
        if(sap.id){
            var sapRecord = component.get('v.sapRecord');
            sapRecord.Customer_Information_Status__c = 'Customer Submitted';
            component.set('v.sapRecord', sapRecord);
            helper.updateSapRecord(component, true);
            window.setTimeout(
                $A.getCallback(function() {
                    var parent  = component.get('v.parent');
                    parent.getSapRecord();
                }), 
                2000
            );
            
        }
    },
    handleError : function(component, event, helper) {
        var error = event.getParam("error");
        console.log(error);
        component.set('v.spinner', false);
    },
    handleFormSubmit : function(component, event, helper){
        event.preventDefault();
        if(event.charCode != 13){
            var languageMap = component.get('v.languageLabelMap');
            component.set('v.confirmMessage',languageMap['CI_143']);
            component.set('v.showConfirmDialog', true);
        }
        
    },
    
    handleConfirmDialog : function(component, event, helper){
        var name = event.getSource().get('v.name');
        if(name == 'Cancel'){
            component.set('v.showConfirmDialog', false);
        }
        if(name == 'Submit'){
            component.set('v.showConfirmDialog', false);
            var form = component.find('CIForm');
            component.set('v.spinner', true);
            if(Array.isArray(form)){
                form[0].submit();
            }
            else{
                form.submit();
            }
        }
        
    },
    
    handleCopyAddresses : function(component, event, helper){
        var id = event.currentTarget.id;
        var value = true;
        if(id == 'sameAddressCheck' && value){
            helper.setPopulateFields(component,'ship to',false);
        }
        else if(id == 'sameAddressCheck' && !value){
            helper.setPopulateFields(component,'ship to',true);
        }
            else if(id == 'parentAndBillToggle' && value){
                helper.setPopulateFields(component,'parent to',false);
            }
                else if(id == 'parentAndBillToggle' && !value){
                    helper.setPopulateFields(component,'parent to',true);
                }
        
                    else if(id == 'billToSameSoldTo' && value){
                        helper.setPopulateFields(component,'bill to',false);
                    }
                        else if(id == 'billToSameSoldTo' && !value){
                            helper.setPopulateFields(component,'bill to',true);
                        }
        
    },
    
    handleSaveProgress : function(component, event, helper){
        component.set('v.spinner', true);
        helper.updateSapRecord(component, false);
    },
    
    handleShareWithColleague : function(component, event, helper){
        var parent = component.get('v.parent');
        parent.openShareWithColleague();
    }
    
})