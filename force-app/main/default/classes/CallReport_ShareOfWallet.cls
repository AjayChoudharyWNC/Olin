public class CallReport_ShareOfWallet {
    
    @AuraEnabled
    public static CallReportWrapper getAllPurchasedProducts(String recordId, List<String> accountIds){
        CallReportWrapper wrapper = new CallReportWrapper();
        wrapper.prodList = new List<PurchasedProduct_R1__c>();
        String currentYear = String.valueOf(System.now().year());
        if(accountIds == NULL || accountIds.size() == 0){
            accountIds = new List<String>();
            FCM_VisitReport__c callReport = [SELECT Id, FCM_Account__c, FCM_Account__r.Account_Type_Text_Only__c FROM FCM_VisitReport__c WHERE Id =:recordId];
            accountIds.add(callReport.FCM_Account__c);
            wrapper.accountType = callReport.FCM_Account__r.Account_Type_Text_Only__c;
            wrapper.accountId = callReport.FCM_Account__c;
        }
        else{
            wrapper.accountType = 'Customer';
        }
        
        for(PurchasedProduct_R1__c prod : [SELECT Id, Name, Ship_To__c, Ship_To__r.Name, Ship_To__r.BillingCity, Ship_To__r.BillingStateCode, Ship_To__r.BillingCountryCode, Account_R1__c,
                                           Ship_To__r.AccountNumber_R1__c, Account_R1__r.AccountNumber_R1__c, Account_R1__r.Name, Account_R1__r.BillingCity, Account_R1__r.BillingStateCode, Account_R1__r.BillingCountryCode, Product_R1__r.Name,
                                           (SELECT LastModifiedBy.Name, LastModifiedDate FROM Total_Consumptions__r WHERE Year__c =:currentYear) FROM PurchasedProduct_R1__c 
                                           WHERE Account_R1__c IN :accountIds ORDER BY Name DESC])
        {
            if(prod.Total_Consumptions__r.size() > 0){
                wrapper.prodList.add(prod);
            }
        }
        return wrapper;
    }
    
    @AuraEnabled
    public static List<Account> getRelatedSoldToAccounts(String parentAccountId){
        return [SELECT Id, Name, AccountNumber_R1__c, BillingCity, BillingStateCode, BillingCountryCode FROM Account WHERE ParentId =:parentAccountId AND Account_Type_Text_Only__c IN ('Sold To', 'Sold To & Ship To', 'Prospect') ORDER BY Name ASC];
    }
    
    @TestVisible class CallReportWrapper{
        @AuraEnabled public string accountType;
        @AuraEnabled public string accountId;
        @AuraEnabled public List<PurchasedProduct_R1__c> prodList;
    }
    
}