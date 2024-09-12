({
    setPopulateFields: function (component, fieldName, setNull) {
        var sapRecord = component.get('v.sapRecord');
        if (fieldName == 'ship to') {
            if (!setNull) {
                sapRecord.Ship_To_City__c = sapRecord.Sold_To_City__c;
                sapRecord.Ship_To_Company_Name__c = sapRecord.Sold_To_Company_Name__c;
                sapRecord.Ship_To_Country__c = sapRecord.Sold_To_Country__c;
                sapRecord.Ship_To_Postal_Code__c = sapRecord.Sold_To_Postal_Code__c;
                sapRecord.Ship_To_State_Province__c = sapRecord.Sold_To_State_Province__c;
                sapRecord.Ship_To_Street__c = sapRecord.Sold_To_Street__c;
                sapRecord.Ship_To_Street_2__c = sapRecord.Sold_To_Street_2__c;
            }
            else {
                sapRecord.Ship_To_City__c = '';
                sapRecord.Ship_To_Company_Name__c = '';
                sapRecord.Ship_To_Country__c = '';
                sapRecord.Ship_To_Postal_Code__c = '';
                sapRecord.Ship_To_State_Province__c = '';
                sapRecord.Ship_To_Street__c = '';
                sapRecord.Ship_To_Street_2__c = '';
            }
        }
        if (fieldName == 'parent to') {
            if (!setNull) {
                sapRecord.Parent_City__c = sapRecord.Sold_To_City__c;
                sapRecord.Parent_Company_Name__c = sapRecord.Sold_To_Company_Name__c;
                sapRecord.Parent_Country__c = sapRecord.Sold_To_Country__c;
                sapRecord.Parent_Postal_Code__c = sapRecord.Sold_To_Postal_Code__c;
                sapRecord.Parent_State_Province__c = sapRecord.Sold_To_State_Province__c;
                sapRecord.Parent_Street__c = sapRecord.Sold_To_Street__c;
                sapRecord.Parent_Street_2__c = sapRecord.Sold_To_Street_2__c;
            }
            else {
                sapRecord.Parent_City__c = '';
                sapRecord.Parent_Company_Name__c = '';
                sapRecord.Parent_Country__c = '';
                sapRecord.Parent_Postal_Code__c = '';
                sapRecord.Parent_State_Province__c = '';
                sapRecord.Parent_Street__c = '';
                sapRecord.Parent_Street_2__c = '';
            }
        }
        if (fieldName == 'bill to') {
            if (!setNull) {
                sapRecord.Bill_To_City__c = sapRecord.Sold_To_City__c;
                sapRecord.Bill_To_Company_Name__c = sapRecord.Sold_To_Company_Name__c;
                sapRecord.Bill_To_Country__c = sapRecord.Sold_To_Country__c;
                sapRecord.Bill_To_Postal_Code__c = sapRecord.Sold_To_Postal_Code__c;
                sapRecord.Bill_To_State_Province__c = sapRecord.Sold_To_State_Province__c;
                sapRecord.Bill_To_Street__c = sapRecord.Sold_To_Street__c;
                sapRecord.Bill_To_Street_2__c = sapRecord.Sold_To_Street_2__c;
            }
            else {
                sapRecord.Bill_To_City__c = '';
                sapRecord.Bill_To_Company_Name__c = '';
                sapRecord.Bill_To_Country__c = '';
                sapRecord.Bill_To_Postal_Code__c = '';
                sapRecord.Bill_To_State_Province__c = '';
                sapRecord.Bill_To_Street__c = '';
                sapRecord.Bill_To_Street_2__c = '';
            }
        }
        if (fieldName == 'contractContact') {
            sapRecord.Contract_Notification_Email__c = sapRecord.Order_Placement_Email__c;
            sapRecord.Contract_Notification_First_Name__c = sapRecord.Order_Placement_First_Name__c;
            sapRecord.Contract_Notification_Last_Name__c = sapRecord.Order_Placement_Last_Name__c;
            sapRecord.Contract_Notification_Title__c = sapRecord.Order_Placement_Title__c;
            sapRecord.Contract_Notification_Phone__c = sapRecord.Order_Placement_Phone__c;
        }
        if (fieldName == 'afterHourContact') {
            sapRecord.After_Hours_Email__c = sapRecord.Order_Placement_Email__c;
            sapRecord.After_Hours_First_Name__c = sapRecord.Order_Placement_First_Name__c;
            sapRecord.After_Hours_Last_Name__c = sapRecord.Order_Placement_Last_Name__c;
            sapRecord.After_Hours_Title__c = sapRecord.Order_Placement_Title__c;
            sapRecord.After_Hours_Phone__c = sapRecord.Order_Placement_Phone__c;
        }
        if (fieldName == 'creditContact') {
            sapRecord.Credit_Email__c = sapRecord.Order_Placement_Email__c;
            sapRecord.Credit_First_Name__c = sapRecord.Order_Placement_First_Name__c;
            sapRecord.Credit_Last_Name__c = sapRecord.Order_Placement_Last_Name__c;
            sapRecord.Credit_Title__c = sapRecord.Order_Placement_Title__c;
            sapRecord.Credit_Phone__c = sapRecord.Order_Placement_Phone__c;
        }
        if (fieldName == 'emailInvoiceContact') {
            sapRecord.Email_Invoice_Email_Address__c = sapRecord.Order_Placement_Email__c;
            sapRecord.Email_Invoice_First_Name__c = sapRecord.Order_Placement_First_Name__c;
            sapRecord.Email_Invoice_Last_Name__c = sapRecord.Order_Placement_Last_Name__c;
            sapRecord.Email_Invoice_Title__c = sapRecord.Order_Placement_Title__c;
            sapRecord.Email_Invoice_Phone__c = sapRecord.Order_Placement_Phone__c;
        }
        if (fieldName == 'regCustomerContact') {
            sapRecord.Regulatory_Email__c = sapRecord.Order_Placement_Email__c;
            sapRecord.Regulatory_First_Name__c = sapRecord.Order_Placement_First_Name__c;
            sapRecord.Regulatory_Last_Name__c = sapRecord.Order_Placement_Last_Name__c;
            sapRecord.Regulatory_Title__c = sapRecord.Order_Placement_Title__c;
            sapRecord.Regulatory_Phone__c = sapRecord.Order_Placement_Phone__c;
        }
        if (fieldName == 'sdsContact') {
            sapRecord.Quality_SDS_Email__c = sapRecord.Order_Placement_Email__c;
            sapRecord.Quality_SDS_First_Name__c = sapRecord.Order_Placement_First_Name__c;
            sapRecord.Quality_SDS_Last_Name__c = sapRecord.Order_Placement_Last_Name__c;
            sapRecord.Quality_SDS_Title__c = sapRecord.Order_Placement_Title__c;
            sapRecord.Quality_SDS_Phone__c = sapRecord.Order_Placement_Phone__c;
        }
        if (fieldName == 'cxoContact') {
            sapRecord.CXO_Officer_Email__c = sapRecord.Order_Placement_Email__c;
            sapRecord.CXO_Officer_First_Name__c = sapRecord.Order_Placement_First_Name__c;
            sapRecord.CXO_Officer_Last_Name__c = sapRecord.Order_Placement_Last_Name__c;
            sapRecord.CXO_Officer_Title__c = sapRecord.Order_Placement_Title__c;
            sapRecord.CXO_Officer_Phone__c = sapRecord.Order_Placement_Phone__c;
        }
        if (fieldName == 'accountPayableContact') {
            sapRecord.Account_Payable_Email__c = sapRecord.Order_Placement_Email__c;
            sapRecord.Account_Payable_First_Name__c = sapRecord.Order_Placement_First_Name__c;
            sapRecord.Account_Payable_Last_Name__c = sapRecord.Order_Placement_Last_Name__c;
            sapRecord.Account_Payable_Title__c = sapRecord.Order_Placement_Title__c;
            sapRecord.Account_Payable_Phone__c = sapRecord.Order_Placement_Phone__c;
        }
        component.set('v.sapRecord', sapRecord);
    },
    
    updateSapRecord : function(component, isSubmit){
      var action = component.get('c.saveSapOnboarding');
        action.setParams({
            sapRecord : component.get('v.sapRecord'),
            currentAppUser : component.get('v.appUserId')
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                 var parent = component.get('v.parent');
                if(!isSubmit)
                    parent.openToast('utility:success', 'JS_9', 'success');
                else
                    parent.openToast('utility:success', 'JS_10', 'success');
                component.set('v.spinner', false);
                var sapRefreshEvt = $A.get('e.c:OCO_Customer_RefreshSapRecord');
                sapRefreshEvt.setParams({"sapId" : component.get('v.sapRecord').Id});
                sapRefreshEvt.fire();
            }
        });
        $A.enqueueAction(action);
    }   
})