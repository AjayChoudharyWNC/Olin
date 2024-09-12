({
    handleTreeNodeClickEvt : function(component, event, helper) {
        console.log('languageLabelMap=='+component.get('v.languageLabelMap'));
        var nodeId = event.getParam("nodeId");
        component.set('v.nodeId', nodeId);
        var nodeClicked = event.getParam("nodeClicked");
        component.set('v.nodeToShow', nodeClicked);
        component.set('v.sapNo', event.getParam("sapNo"));
       
        
        if(nodeClicked == 'CI' || nodeClicked == 'CF'|| nodeClicked == 'OP' || nodeClicked == 'CA' || nodeClicked == 'OST' || nodeClicked == 'PS' || nodeClicked == 'PSA' || nodeClicked == 'OPR'){
            helper.fetchAppUsers(component, nodeId, event.getParam("sapNo"));
            if(nodeClicked != 'OST' && nodeClicked != 'PSA' && nodeClicked != 'OPR'){
                helper.fetchSapRecord(component, nodeId, event.getParam("sapNo"), false);
            }
            else{
                helper.fetchSapRecord(component, '', event.getParam("sapNo"), false);
            }
            
        }
        if(nodeClicked == 'CI'){
            component.set('v.screenName','Customer Information');
        }
        if(nodeClicked == 'OP'){
            component.set('v.screenName','Document Delivery');
        }
        if(nodeClicked == 'OPR'){
            component.set('v.screenName','Product Stewardship');
        }
        if(nodeClicked == 'CA'){
            component.set('v.screenName','Credit Application');
        }
        if(nodeClicked == 'Instructions'){
            component.set('v.screenName','Instructions');
        }
        if(nodeClicked == 'OST' || nodeClicked == 'PSA' || nodeClicked == 'PS' || nodeClicked == 'OPR'){
            component.set('v.screenName','Product Stewardship');
            if(nodeClicked == 'OPR' || nodeClicked == 'PSA'){
                var childPSACmp = component.find('psaCmp');
                childPSACmp.callDoInit();
            }
            if(nodeClicked == 'PS'){
                var childPSCmp = component.find('psCmp');
                childPSCmp.callDoInit();
            }
        }
    },
    
    fetchSapRecordDetails : function(component, event, helper){
        var nodeClicked = component.get('v.nodeToShow');
        if(nodeClicked == 'CI' || nodeClicked == 'CF'|| nodeClicked == 'OP' || nodeClicked == 'CA' || nodeClicked == 'OST' || nodeClicked == 'PS' || nodeClicked == 'PSA' || nodeClicked == 'OPR'){
            if(nodeClicked != 'OST' && nodeClicked != 'PSA' && nodeClicked != 'OPR'){
                helper.fetchSapRecord(component, component.get('v.nodeId'),component.get("v.sapNo"), true);
            }
            else{
                helper.fetchSapRecord(component, '', component.get("v.sapNo"), true);
            }
            
        }
    },
    
    openLeftPanel : function(component, event, helper){
        var parent = component.get('v.parent');
        parent.openLeftPanel();
    },
    openHelp : function(component, event, helper){
        component.set('v.showHelp', true);  
    },
    closeHelp : function(component, event, helper){
        component.set('v.showHelp', false);  
    },
    openProfile : function(component, event, helper){
        component.set('v.showProfile', true);  
    },
    closeProfile : function(component, event, helper){
        component.set('v.showProfile', false);  
    },
    goToHome : function(component, event, helper){
      window.location.href = '/SiteLogin/OCO_CustomerHome';  
    },
    doLogout : function(component, event, helper){
         var languageMap = component.get('v.languageLabelMap');
            component.set('v.confirmMessage',languageMap['JS_1']);
            component.set('v.showConfirmDialog', true);
       
    },
    handleConfirmDialog : function(component, event, helper){
        var name = event.getSource().get('v.name');
        if(name == 'Cancel'){
            component.set('v.showConfirmDialog', false);
        }
        if(name == 'Submit'){
            component.set('v.showConfirmDialog', false);
            document.cookie = "apex__sapRecId=;expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;";
            document.cookie = "apex__accCode=;expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;";
            document.cookie = "apex__valEmail=;expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;";
            if(window.location.href.includes('SiteLogin')){
                console.log('log ',document.cookie);
                window.location.href = '/SiteLogin/OnboardLogin';
            }
            else{
                window.location.href = '/secur/logout.jsp';
            }
        }
        
    },
    handleFormSubmit : function(component, event, helper){
        var node = component.get('v.nodeToShow');
        if(node == 'CI'){
            component.find('CIForm').submit();
        }
    },
    
    closeModel : function(component, event, helper){
        component.set('v.appUserRecord', {'sobjectType' : 'Application_User__c', 'Shared__c' : true, 'SAP_Onboarding__c' : component.get('v.nodeId')});
        component.set('v.showShare',false);
    },
    
    handleAppUserSubmit : function(component, event, helper){
        event.preventDefault();
        var appUserList = component.get('v.appUserList');
        var fields = event.getParam('fields');
        var email = fields['Email__c'];
        var hasError = false;
        if(email && email == component.get('v.email')){
            hasError = true;
        }
        if(appUserList){
            for(var i=0;i<appUserList.length;i++){
                if(email && email == appUserList[i].Email__c){
                    hasError = true;
                    break;
                }
            }
        }
        
        if(hasError){
            if(helper.mobileCheck(component)){
                var languageMap=component.get('v.languageLabelMap');
                alert(languageMap['JS_3']);         //Changed by Neeraj
            }
            else
                helper.showToast(component, 'warning', 'JS_3','utility:warning'); //Changed by Neeraj
        }
        else{
            component.set('v.spinner', true);
            component.find('appUserForm').submit();
        }
    },
    handleError : function(component, event, helper){
        component.set('v.spinner', false);
        console.log('error',JSON.stringify(event.getParams()));
        var formId = event.getSource().getLocalId();
        //var sectionNumber = formId.substring(formId.length-1,formId.length);
        //helper.handleCheckBox(component, parseInt(sectionNumber), false);
    },
    handleAppUserSuccess : function(component, event, helper){
        var appUser = event.getParams().response;
        console.log('appuserid',appUser,appUser.id);
        if(appUser.id){
            helper.fetchAppUsers(component, component.get('v.sapRecord').Id, component.get('v.sapNo'));
            component.set('v.showShare',false);
            helper.sendEmail(component, appUser.id);
            component.set('v.appUserRecord', {'sobjectType' : 'Application_User__c', 'Shared__c' : true, 'SAP_Onboarding__c' : component.get('v.nodeId')});
            if(helper.mobileCheck(component)){
                var languageMap=component.get('v.languageLabelMap');
                alert(languageMap['JS_6']);           
            }
            else
                helper.showToast(component, 'success', 'JS_6','utility:success');  
        }
    },
    handleAppUserProfileSubmit : function(component, event, helper){
        component.set('v.spinner',true);
    },
    handleAppUserProfileSuccess : function(component, event, helper){
        component.set('v.spinner',false);
        component.set('v.showProfile', false);  
        helper.showToast(component,'success','JS_7','utility:success'); 
    },
    openSharePopup : function(component, event, helper){
        component.set('v.showShare',true);
    },
    openToastMessage : function(component, event, helper){
        var params = event.getParam('arguments');
        if(params){
            var messageId = params.childToastMessageId;
            var iconName = params.childToastIconName;
            var type = params.childToastType;
            helper.showToast(component, type, messageId,iconName);
        }
    },
    
    handleShareWithColleagueEvt : function(component, event, helper){
        component.set('v.showShare',true);
    }
   
})