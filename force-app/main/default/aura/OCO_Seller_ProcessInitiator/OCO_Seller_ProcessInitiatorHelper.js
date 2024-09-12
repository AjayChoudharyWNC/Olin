({
    getInitialData : function(component, event){
        component.set('v.spinner',true);
        var getContacts = component.get('c.getRelatedContact');
        getContacts.setParams({
            soldToAccId : component.get('v.recordId')
        });
        getContacts.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                component.set('v.relatedContacts', response.getReturnValue());
            }
        });
        $A.enqueueAction(getContacts);
        
        var getSalesOrgData = component.get('c.getSalesOrgs');
        getSalesOrgData.setParams({
            soldToAccId : component.get('v.recordId')
        });
        getSalesOrgData.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                component.set('v.salesOrgs', response.getReturnValue());
            }
        });
        $A.enqueueAction(getSalesOrgData);

        var getAccountInfo = component.get('c.GetAccountInfo');
        getAccountInfo.setParams({
            acId : component.get('v.recordId')
        });
        getAccountInfo.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                var account = response.getReturnValue();
                console.log('acInfo',account);
                component.set('v.mainAccount', response.getReturnValue());
                component.set('v.selectedUser', account.OwnerId);
                if(account.AccountTeamMembers){
                    for(var i=0; i<account.AccountTeamMembers.length; i++){
                        if(account.AccountTeamMembers[i].TeamMemberRole == 'Customer Service Rep'){
                            component.set('v.CSRTeamMember', account.AccountTeamMembers[i]);
                            component.set('v.selectedCSR', account.AccountTeamMembers[i].User.Id);
                            break;
                        }
                    }
                }
                if(account.RecordType.Name == 'Prospect'){
                    component.set('v.isProspect',true);
                    component.set('v.prodWhereClause','');
                    component.set('v.sapType', 'New Sold-To w/ Ship-to & Product');
                    component.set('v.isTypeDisabled', true);
                     this.fetchShipToAccounts(component, event, 'Prospect Location');
                }
                else{
                    component.set('v.isProspect',false);
                    component.set('v.prodWhereClause',"Account_R1__c = '"+account.Id+"'");
                    component.set('v.sapType', 'New Ship-To & Product');
                    this.fetchShipToAccounts(component, event, 'Prospect Location');
                }
            }
        });
        $A.enqueueAction(getAccountInfo);
        
        var getPickListValues = component.get('c.getPickListValues');
        getPickListValues.setParams({
            objectName : 'SAP_Onboarding__c',
            fieldName : 'On_boarding_Request_Type__c'
        });
        getPickListValues.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                component.set('v.requestTypes', response.getReturnValue());
                component.set('v.spinner',false);
            }
        });
        $A.enqueueAction(getPickListValues);
        
        var getUsers = component.get('c.getUserList');
        getUsers.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS'){
                var CSRUsers = [];
                var users = response.getReturnValue();
                users.forEach(function(e){
                    if(e.Profile && e.Profile.Name.includes('CSR')){
                        CSRUsers.push(e);
                    }
                });
                component.set('v.serviceRepUserList', CSRUsers);
            }
        });
        $A.enqueueAction(getUsers);
        
    },

    fetchRelatedProds : function(component, event, sapId){
        var getProducts = component.get('c.getRelatedProducts');
        getProducts.setParams({
            soldToAccId : component.get('v.recordId'),
            sapId : sapId
        });
        getProducts.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                component.set('v.relatedProducts', response.getReturnValue());
            }
        });
        $A.enqueueAction(getProducts);
    },
    
    fetchShipToAccounts : function(component, event, recordTypeName){
        component.set('v.spinner', true);
        var getShipAccounts = component.get('c.getShipToAccountList');
        getShipAccounts.setParams({
            soldToAccId : component.get('v.recordId'),
            recordType :recordTypeName
        });
        getShipAccounts.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                var shipTos = response.getReturnValue();
                component.set('v.shipToAccounts', response.getReturnValue());
                var temp = [];
                for(var i=0;i<shipTos.length;i++){
                    var tmp = {
                        label: shipTos[i].Name,
                        value: shipTos[i].Id
                    };
                    temp.push(tmp);
                }
                component.set('v.shipToAccountOptions',temp);
                component.set('v.spinner', false);
            }
        });
        $A.enqueueAction(getShipAccounts);  
    },    
    showToast : function(message,type,title){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title" : title,
            "message": message,
            "duration": "5000",
            "key": "info_alt",
            "type": type,
            "mode": "dismissible"
        });
        toastEvent.fire();
    },
    errorHandling: function(component,response){
        //component.set("v.spinner", false);
        var errors = response.getError(); 
        if(errors && Array.isArray(errors) && errors.length > 0){
            var errorMessage = errors[0].message; 
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "Error",
                "title": "Error!",
                "message": errorMessage,
                "mode": 'sticky'
            });
            toastEvent.fire();
        }
    },

    saveSapRecord: function (component, sapRecord) {
        var sapType = component.get('v.sapType');
        var action = component.get('c.insertSapRecord');
        action.setParams({
            "sapRecord": sapRecord
        });
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                var sapId = response.getReturnValue();
                component.set('v.sapId', sapId);
                if(sapType == 'New Ship-To & Product' || sapType == 'New Product'){
                    component.set('v.screen', 'ShipToScreen');
                }
                else{
                     component.set('v.screen', 'post');
                }
                component.set('v.spinner', false);
            };
        });
        $A.enqueueAction(action);
    }
})