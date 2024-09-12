({
    handleSuccess : function(component, event, helper) {
        var payload = event.getParams().response;
        var e = $A.get( 'e.force:navigateToSObject' );
        if(e) {
            e.setParams({'recordId' : payload.id}).fire();
        }
    },
    
    handleError: function(component,event,helper){
        var err = event.getParams().error;
        if(!err.message.includes('CDA_R1__c'))
        {
            if(err.message == 'An error occurred while trying to update the record. Please try again.'){
                err.message = 'Some required fields are missing. Please fill the asterisk marked fields: Account, Call Type and Date of Call.';
            }
            component.set('v.errMsg',err.message);
        }
    },
    
    handleSubmit: function(component,event,helper) {
        
        event.preventDefault();
        
        var fields = event.getParams().fields;
        
        var account = fields.FCM_Account__c;
        var endUser = fields.End_User_Account__c;
        var influencer = fields.Influencer_Account__c;
        var callType = fields.Call_Type__c;
        var dateOfCall = fields.FCM_VisitDate__c;
        
        var selectedOpp = component.get("v.selectedOpp");
        
        if(selectedOpp)
        	fields.Opportunity__c = selectedOpp.Id;
        
        var locationAccount = component.get("v.locationAccount");
        
        if(locationAccount)
        	fields.Location_Account__c = locationAccount.Id;
        
        var em = false;
        
        if(account == null || callType == null || callType == '' || dateOfCall == null){
            em = true;
        }
        
        if(em){
            component.set('v.errMsg','Account, Call Type and Date of Call are Required to Save.');
        } else {
            var action = component.get('c.getRecordType');
            action.setParams({accId: account});
            action.setCallback(this, function(response){
                var state = response.getState();
                var recType = response.getReturnValue();
                if(recType == 'End User' && endUser != null){
                    component.set('v.errMsg','Cannot have an End User account value when the call report account is an End User type.');
                } else if(recType == 'Influencer' && influencer != null){
                    component.set('v.errMsg','Cannot have an Influencer account value when the call report account is an Influencer type.');
                } else {
                    component.find("form").submit(fields);
                }
            });
            
            $A.enqueueAction(action);
            
        }
        
    },
    
    cancel: function(component,event,helper){
        var homeEvent = $A.get("e.force:navigateToObjectHome");
        homeEvent.setParams({
            "scope": "Confidential_Call_Report__c"
        });
        homeEvent.fire();
    },
    
    handleAccountValueChange : function(component,event,helper){
        
        var soldToAccountId = event.getSource().get("v.value");
        
        component.set("v.locationAccount", null);
        component.set("v.selectedOpp", null);
        
        if(soldToAccountId) {
            helper.callAccShipToSearch(component, soldToAccountId);
            component.set("v.oppWhereClause", "AccountId = '" + soldToAccountId +"'");
        } else {
            component.set("v.locationWhereClause", "");
            component.set("v.oppWhereClause", "");
        }
        
    }
    
})