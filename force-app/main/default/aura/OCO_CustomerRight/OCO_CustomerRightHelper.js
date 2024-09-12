({
    MAX_FILE_SIZE: 4500000, //Max file size 4.5 MB 
    CHUNK_SIZE: 750000, //Chunk Max size 750Kb 
    fetchSapRecord : function(component, sapId, sapNo, isFromChild) {
        if(!isFromChild)
            component.set('v.spinner', true);
        var action = component.get('c.getSapRecord');
        action.setParams({
            'sapRecordId' : sapId,
            'sapNo' : sapNo
        });
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS'){
                var sapRecord = response.getReturnValue();
                if(!sapRecord.Preferred_Method_of_Order_Confirmation__c){
                    sapRecord.Preferred_Method_of_Order_Confirmation__c = 'Do Not Wish to Receive';
                }
                if(!sapRecord.Preferred_Method_of_Bill_of_Lading__c){
                    sapRecord.Preferred_Method_of_Bill_of_Lading__c = 'Do Not Wish to Receive';
                }
                if(!sapRecord.Preferred_Method_of_Certifi_of_Analysis__c){
                    sapRecord.Preferred_Method_of_Certifi_of_Analysis__c = 'Do Not Wish to Receive';
                }
                if(sapRecord.Customer_Information_Status__c == 'Sent To Customer'){
                    sapRecord.Customer_Information_Status__c = 'Customer In Progress';
                }
                 if(sapRecord.Order_Placement_Status__c == 'Sent To Customer'){
                    sapRecord.Order_Placement_Status__c = 'Customer In Progress';
                }
                 if(sapRecord.Credit_Application_Status__c == 'Sent To Customer'){
                    sapRecord.Credit_Application_Status__c = 'Customer In Progress';
                }
                 if(sapRecord.Product_Stewardship_Status__c == 'Sent To Customer'){
                    sapRecord.Product_Stewardship_Status__c = 'Customer In Progress';
                 }
                if((sapRecord.Customer_Information_Status__c == 'Customer Submitted' || sapRecord.Customer_Information_Status__c == 'New') && (sapRecord.Order_Placement_Status__c == 'Customer Submitted' || sapRecord.Order_Placement_Status__c == 'New') &&
                   (sapRecord.Credit_Application_Status__c == 'Customer Submitted' || sapRecord.Credit_Application_Status__c == 'New') && (sapRecord.Product_Stewardship_Status__c == 'Customer Submitted' || sapRecord.Product_Stewardship_Status__c == 'New')){
                    component.set('v.allSectionCompleted', true);
                    if(isFromChild){
                        component.set('v.nodeToShow','CF');
                        component.set('v.screenName','');
                        var nodeName = sapRecord.Id+'-CF-'+sapRecord.Name;
                        var evt = $A.get('e.c:OCO_SectionCompletedEvt');
                        evt.setParams({"selectedNode" : nodeName});
                        evt.fire();
                    }
                }
                else{
                    component.set('v.allSectionCompleted', false);
                }
                component.set('v.sapRecord', sapRecord);
                this.setColorCodeForStatus(component);
                if(!isFromChild){
                    if(sapRecord.VAT1__r){
                        var vatList = sapRecord.VAT1__r;
                    }
                    else{
                        vatList = [];
                    }
                    if(sapRecord.Application_User__r){
                        for(var i=0;i<sapRecord.Application_User__r.length;i++){
                            if(sapRecord.Application_User__r[i].Email__c == component.get('v.email')){
                                component.set('v.currentAppUser', sapRecord.Application_User__r[i].Id);
                                break;
                            }
                        }
                    }
                    component.set('v.vatList', vatList);
                }
                var childCACmp = component.find('childCACmp');
                if(childCACmp){
                    childCACmp.callDoInit();
                }
                this.checkDisableForProfile(component, event);
                component.set('v.spinner', false);
            }
        });
        $A.enqueueAction(action);
    },
    
    checkDisableForProfile : function(component, event){
        component.set('v.spinner', true);
        var action = component.get('c.disbleForProfile');
        action.setParams({
            recId : component.get('v.sapRecord').Id
        });
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                component.set('v.spinner', false);
                //console.log('profile status ;', response.getReturnValue());
                if(response.getReturnValue() == 'false'){
                    component.set('v.isDisabledForProfile', false);
                }
                else{
                    //component.set('v.isDisabledForProfile', true);
                }
            }
            else{
                component.set('v.spinner', false);
            }
        });
        $A.enqueueAction(action);
    },
    
    setColorCodeForStatus : function(component){
        var sapRecord = component.get('v.sapRecord');
        //Custoemr Information Div Color Coding
        if(sapRecord.Customer_Information_Status__c == 'New'){
            component.set('v.ciDivClass', 'notStartedDiv');
        }
        else if(sapRecord.Customer_Information_Status__c == 'Sent To Customer'){
            component.set('v.ciDivClass', 'stBySalesDiv');
        }
            else if(sapRecord.Customer_Information_Status__c == 'Customer In Progress'){
                component.set('v.ciDivClass', 'ciInProgressDiv');
            }
                else if(sapRecord.Customer_Information_Status__c == 'Customer Submitted'){
                    component.set('v.ciDivClass', 'cSubmittedDiv');
                }
                    else if(sapRecord.Customer_Information_Status__c == 'In Olin Review'){
                        component.set('v.ciDivClass', 'inOlinReviewDiv');
                    }
                        else if(sapRecord.Customer_Information_Status__c == 'Complete'){
                            component.set('v.ciDivClass', 'completeDiv');
                        }
                            else{
                                component.set('v.ciDivClass', 'notStartedDiv');
                            }

        
        //Document Delivery Div Color Coding
        if(sapRecord.Order_Placement_Status__c == 'New'){
            component.set('v.ddDivClass', 'notStartedDiv');
        }
        else if(sapRecord.Order_Placement_Status__c == 'Sent To Customer'){
            component.set('v.ddDivClass', 'stBySalesDiv');
        }
            else if(sapRecord.Order_Placement_Status__c == 'Customer In Progress'){
                component.set('v.ddDivClass', 'ciInProgressDiv');
            }
                else if(sapRecord.Order_Placement_Status__c == 'Customer Submitted'){
                    component.set('v.ddDivClass', 'cSubmittedDiv');
                }
                    else if(sapRecord.Order_Placement_Status__c == 'In Olin Review'){
                        component.set('v.ddDivClass', 'inOlinReviewDiv');
                    }
                        else if(sapRecord.Order_Placement_Status__c == 'Complete'){
                            component.set('v.ddDivClass', 'completeDiv');
                        }
                            else{
                                component.set('v.ddDivClass', 'notStartedDiv');
                            }
        
        //Credit Application Div Color Coding
        if(sapRecord.Credit_Application_Status__c == 'New' || sapRecord.Credit_Application_Status__c == 'N/A'){
            component.set('v.caDivClass', 'notStartedDiv');
        }
        else if(sapRecord.Credit_Application_Status__c == 'Sent To Customer'){
            component.set('v.caDivClass', 'stBySalesDiv');
        }
            else if(sapRecord.Credit_Application_Status__c == 'Customer In Progress'){
                component.set('v.caDivClass', 'ciInProgressDiv');
            }
                else if(sapRecord.Credit_Application_Status__c == 'Customer Submitted'){
                    component.set('v.caDivClass', 'cSubmittedDiv');
                }
                    else if(sapRecord.Credit_Application_Status__c == 'In Olin Review'){
                        component.set('v.caDivClass', 'inOlinReviewDiv');
                    }
                        else if(sapRecord.Credit_Application_Status__c == 'Complete'){
                            component.set('v.caDivClass', 'completeDiv');
                        }
                            else{
                                component.set('v.caDivClass', 'notStartedDiv');
                            }
        
        
        
        //PSA Div Color Coding
        if(sapRecord.Product_Stewardship_Status__c == 'New'){
            component.set('v.psaDivClass', 'notStartedDiv');
        }
        else if(sapRecord.Product_Stewardship_Status__c == 'Sent To Customer'){
            component.set('v.psaDivClass', 'stBySalesDiv');
        }
            else if(sapRecord.Product_Stewardship_Status__c == 'Customer In Progress'){
                component.set('v.psaDivClass', 'ciInProgressDiv');
            }
                else if(sapRecord.Product_Stewardship_Status__c == 'Customer Submitted'){
                    component.set('v.psaDivClass', 'cSubmittedDiv');
                }
                    else if(sapRecord.Product_Stewardship_Status__c == 'In Olin Review'){
                        component.set('v.psaDivClass', 'inOlinReviewDiv');
                    }
                        else if(sapRecord.Product_Stewardship_Status__c == 'Complete'){
                            component.set('v.psaDivClass', 'completeDiv');
                        }  
                            else{
                                component.set('v.psaDivClass', 'notStartedDiv');
                            }
        
        var ciDivClass = component.get('v.ciDivClass');
        var caDivClass = component.get('v.caDivClass');
        var psaDivClass = component.get('v.psaDivClass');
        if(!ciDivClass.includes('notStartedDiv')){
            if(caDivClass.includes('notStartedDiv') && psaDivClass.includes('notStartedDiv')){
                ciDivClass += ' slds-large-size_1-of-1 slds-medium-size_1-of-1 slds-small-size_4-of-4';
            }
            if((!caDivClass.includes('notStartedDiv') && psaDivClass.includes('notStartedDiv')) || (caDivClass.includes('notStartedDiv') && !psaDivClass.includes('notStartedDiv'))){
                ciDivClass += ' slds-large-size_1-of-2 slds-medium-size_1-of-2 slds-small-size_4-of-4';
            }
            if(!caDivClass.includes('notStartedDiv') && !psaDivClass.includes('notStartedDiv')){
                ciDivClass += ' slds-large-size_1-of-3 slds-medium-size_1-of-3 slds-small-size_4-of-4';
            }
        }
        
        if(!caDivClass.includes('notStartedDiv')){
            if(ciDivClass.includes('notStartedDiv') && psaDivClass.includes('notStartedDiv')){
                caDivClass += ' slds-large-size_1-of-1 slds-medium-size_1-of-1 slds-small-size_4-of-4';
            }
            if((!ciDivClass.includes('notStartedDiv') && psaDivClass.includes('notStartedDiv')) || (ciDivClass.includes('notStartedDiv') && !psaDivClass.includes('notStartedDiv'))){
                caDivClass += ' slds-large-size_1-of-2 slds-medium-size_1-of-2 slds-small-size_4-of-4';
            }
            if(!ciDivClass.includes('notStartedDiv') && !psaDivClass.includes('notStartedDiv')){
                caDivClass += ' slds-large-size_1-of-3 slds-medium-size_1-of-3 slds-small-size_4-of-4';
            }
        }
        
        if(!psaDivClass.includes('notStartedDiv')){
            if(ciDivClass.includes('notStartedDiv') && caDivClass.includes('notStartedDiv')){
                psaDivClass += ' slds-large-size_1-of-1 slds-medium-size_1-of-1 slds-small-size_4-of-4';
            }
            if((!ciDivClass.includes('notStartedDiv') && caDivClass.includes('notStartedDiv')) || (ciDivClass.includes('notStartedDiv') && !caDivClass.includes('notStartedDiv'))){
                psaDivClass += ' slds-large-size_1-of-2 slds-medium-size_1-of-2 slds-small-size_4-of-4';
            }
            if(!ciDivClass.includes('notStartedDiv') && !caDivClass.includes('notStartedDiv')){
                psaDivClass += ' slds-large-size_1-of-3 slds-medium-size_1-of-3 slds-small-size_4-of-4';
            }
        }
        component.set('v.ciDivClass', ciDivClass);
        component.set('v.caDivClass', caDivClass);
        component.set('v.psaDivClass', psaDivClass);
    },    
    fetchAppUsers: function (component, sapId, sapNo) {
        var action = component.get('c.fetchAppUsers');
        action.setParams({
            "sapRecordId": sapId,
            "email": component.get('v.email'),
            "sapNo" : sapNo
        });
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                component.set('v.appUserList', response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    sendEmail: function (component, toRecordId) {
        var action = component.get('c.sendEmailToAppUser');
        action.setParams({
            toRecordId: toRecordId,
            fromRecordId: component.get('v.currentAppUser')
        });
        action.setCallback(this, function (response) {
            if (response.getState() === 'SUCCESS') {
                console.log('email sent');
                component.set('v.spinner',false);
                if(this.mobileCheck(component)){
                    
              var languageMap=component.get('v.languageLabelMap');
                alert(languageMap['JS_6']); 
                   
                }
                else
                    this.showToast(component, 'success','JS_6','utility:success');
            }
        });
        $A.enqueueAction(action);
    },
   
    
    mobileCheck: function (component) {
        let check = false;
        (function (a) { if (/(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows ce|xda|xiino/i.test(a) || /1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(a.substr(0, 4))) check = true; })(navigator.userAgent || navigator.vendor || window.opera);
        return check;
    },
    
    showToast: function (component, type, messageId, iconName) {
        var languageMap = component.get('v.languageLabelMap');
        var message  = languageMap[messageId];
        component.set('v.toastIconName', iconName);
        component.set('v.toastMessage', message);
        component.set('v.showToast', true);
        var toast = document.getElementById("toast");
        var toastMessage = document.getElementById('toastMessage');
        if (type == "success") {
            component.set('v.toastColor', '#04844b');
            component.set('v.toastTextColor', 'white');
        }
        else if (type == 'warning') {
            component.set('v.toastColor', '#ffb75d');
            component.set('v.toastTextColor', '#080707');
            
        }
            else {
                component.set('v.toastColor', '#c23934');
                component.set('v.toastTextColor', 'white');
            }
        component.set('v.showToast', true);
        //toast.classList.add("show");
        setTimeout(function () {
            component.set('v.showToast', false);
            //toast.classList.remove('show');
        }, 5000);
        
    },
})