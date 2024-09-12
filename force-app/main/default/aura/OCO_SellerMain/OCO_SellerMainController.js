({
	doInit : function(component, event, helper) {
        component.set('v.spinner', true);
		var action = component.get('c.GetAccountInfo');
        action.setParams({
            acId : component.get('v.recordId')
        });
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS'){
                component.set('v.mainAccount', response.getReturnValue());
                component.set('v.spinner', false);
            }
        });
        $A.enqueueAction(action);
        if(component.get('v.selectedSapId')){
            helper.fetchSapRecord(component);
        }
        else{
            var sapType = component.get('v.sapType');
            if(sapType == 'New Ship-To & Product' || sapType == "New Product"){
                component.set('v.showCreditQuestions', true);
            }
            component.set('v.renderComponent', true);
        }
	},
    
    handleCreditInfo : function(component, event, helper){
        var purchasedProd12Month = component.find('purchasedProd12Month');
        var exceedingCredit = component.find('exceedingCredit');
        var creditType;
        if(!purchasedProd12Month.get('v.value') || purchasedProd12Month.get('v.value') == ''){
            purchasedProd12Month.reportValidity();
            purchasedProd12Month.focus();
            return;
        }
        if(purchasedProd12Month.get('v.value') == 'Yes' && (!exceedingCredit.get('v.value') || exceedingCredit.get('v.value') == '')){
            exceedingCredit.reportValidity();
            exceedingCredit.focus();
            return;
        }
        component.set('v.purchasedProd12Month', purchasedProd12Month.get('v.value'));
        component.set('v.exceedingCredit', exceedingCredit.get('v.value'));
        if(purchasedProd12Month.get('v.value') == "Yes"){
            if(exceedingCredit.get('v.value') == "Yes"){
                creditType = 'Partial';
            }
            if(exceedingCredit.get('v.value') == "No" || exceedingCredit.get('v.value') == "Unsure"){
                creditType = "No Credit";
            }
        }
        if(purchasedProd12Month.get('v.value') == "No"){
            creditType = 'Full';
        }
        if(creditType == "No Credit"){
            var mainAccount = component.get('v.mainAccount');
            var sapType = component.get('v.sapType');
            var selectedUser = component.get('v.salesRepId');
            var mainOnbaordConId = component.get('v.mainOnboardContact');
            var selectedSalesOrg = component.get('v.selectedSalesOrgId');
            var estDate = component.get('v.estDate');
            var cusType = component.get('v.cusType');
            var dueDate = component.get('v.formDueDate');
            var selectedCSR  = component.get('v.CSRId');
            component.set('v.spinner', true);
            var shipTos = component.get('v.selectedShipToAccounts');
            var shipToString = '';
            for (var i = 0; i < shipTos.length; i++){
                if (i == 0) {
                    shipToString += shipTos[i];
                }
                else {
                    shipToString += ';' + shipTos[i];
                }
            }
            var sapRecord;
            if(component.get('v.selectedSapId')){
                sapRecord = component.get('v.sapRecord');
                sapRecord.Customer_Purchased_Prod_In_Last_12_Month__c = purchasedProd12Month.get('v.value');
                sapRecord.New_Business_Result_In_Exceeding_Credit__c = exceedingCredit.get('v.value');
            }
            else{
                sapRecord = {
                    "sObjectType": 'SAP_Onboarding__c',
                    "On_boarding_Request_Type__c": sapType,
                    "Sales_Organization__c": selectedSalesOrg,
                    "Customer_Type__c": cusType,
                    "Form_Due_Date__c": dueDate,
                    "Estimated_Date_of_First_Shipment__c": estDate,
                    "Main_Onboarding_Contact__c": mainOnbaordConId,
                    "Account__c": component.get('v.recordId'),
                    "Sales_Rep__c": selectedUser,
                    "Customer_Service_Rep__c" : mainAccount.RecordType.Name != 'Prospect' ? selectedCSR : null ,
                    "Status__c": 'In Progress',
                    "Ship_To_Accounts__c" : shipToString,
                    "Customer_Purchased_Prod_In_Last_12_Month__c" : purchasedProd12Month.get('v.value'),
                    "New_Business_Result_In_Exceeding_Credit__c" : exceedingCredit.get('v.value')
                };
            }
            
            helper.saveSapRecord(component, sapRecord, creditType);
        }
        else{
            component.set('v.creditType', creditType);
            component.set('v.showCreditQuestions', false);
        }
    }
})