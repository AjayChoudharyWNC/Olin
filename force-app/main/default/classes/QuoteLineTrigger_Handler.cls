public class QuoteLineTrigger_Handler {

    // //Static run variables
    // @TestVisible 
    // private static boolean runBefore = true;
    // @TestVisible 
    // private static boolean runAfter = true;

    // //Run Singleton
    // public static boolean runOnceBefore(){
    //     if(runBefore){
    //         runBefore=false;
    //         return true;
    //     }else{
    //         return runBefore;
    //     }
    // }

    // //Run Singleton
    // public static boolean runOnceAfter(){
    //     if(runAfter){
    //         runAfter=false;
    //         return true;
    //     }else{
    //         return runAfter;
    //     }
    // }

    //Static run variables
    @TestVisible 
    private static boolean runBeforeInsert = true;
    
    @TestVisible 
    private static boolean runAfterInsert = true;

    @TestVisible 
    private static boolean runBeforeUpdate = true;
    
    @TestVisible 
    private static boolean runAfterUpdate = true;

    @TestVisible
    private static boolean runBeforeDelete = true;

    public static boolean disableDLRSTrigger = false;

    //Run Singleton
    public static boolean runOnceBefore(){
        if(runBeforeInsert || runBeforeUpdate){
            runBeforeInsert=false;
            runBeforeUpdate=false;
            runBeforeDelete=false;
            return true;
        }else{
            return false;
        }
    }

    //Run Singleton
    public static boolean runOnceAfter(){
        if(runAfterInsert||runAfterUpdate){
            runAfterInsert=false;
            runAfterUpdate=false;
            return true;
        }else{
            return false;
        }
    }

    //Run Singleton
    public static boolean runOnceBeforeInsert(){
        if(runBeforeInsert){
            runBeforeInsert=false;
            return true;
        }else{
            return runBeforeInsert;
        }
    }

    //Run Singleton
    public static boolean runOnceAfterInsert(){
        if(runAfterInsert){
            runAfterInsert=false;
            return true;
        }else{
            return runAfterInsert;
        }
    }

    //Run Singleton
    public static boolean runOnceBeforeUpdate(){
        if(runBeforeUpdate){
            runBeforeUpdate=false;
            return true;
        }else{
            return runBeforeUpdate;
        }
    }

    //Run Singleton
    public static boolean runOnceAfterUpdate(){
        if(runAfterUpdate){
            runAfterUpdate=false;
            return true;
        }else{
            return runAfterUpdate;
        }
    }

    //Run Singleton
    public static boolean runOnceBeforeDelete(){
        if(runBeforeDelete){
            runBeforeDelete=false;
            return true;
        }else{
            return runBeforeDelete;
        }
    }
    public static void populateStatus(List<SBQQ__QuoteLine__c> lstQuoteLine, Map<Id, SBQQ__QuoteLine__c> oldMapQuoteLine) {     
        //Set<Id> sApprovedQuoteLines = new Set<Id>(); 
        //List<SBQQ__QuoteLine__c> lUpdateChildItems = new List<SBQQ__QuoteLine__c>();
        for(SBQQ__QuoteLine__c quoteLine : lstQuoteLine) {
            if(quoteLine.ApprovalStatus__c == 'Approved' && oldMapQuoteLine.get(quoteLine.Id).ApprovalStatus__c != 'Approved' 
            && quoteLine.Source_Quote_Line__c != null && quoteLine.Status__c != 'Won' && quoteLine.SBQQ__RequiredBy__c == NULL) {
                quoteLine.Status__c = 'Won';
                //sApprovedQuoteLines.add(quoteLine.Id);
            }
        }
    }
    public static void populateFieldsFromParentQL(List<SBQQ__QuoteLine__c> lstQuoteLine){
        Map<Id, SBQQ__QuoteLine__c> parentQLtoChildQL = new Map<Id, SBQQ__QuoteLine__c>();
        for(SBQQ__QuoteLine__c ql: lstQuoteLine){
            if(ql.SBQQ__RequiredBy__c != null && ql.Customer_Product_Code__c == null){
                parentQLtoChildQL.put(ql.SBQQ__RequiredBy__c, ql);
            }
        }
        for(SBQQ__QuoteLine__c parentQl: [SELECT Id, Customer_Product_Code__c, PosexNo__c, ApprovalStatus__c FROM SBQQ__QuoteLine__c WHERE Id IN: parentQLtoChildQL.keySet()]){
            if(parentQLtoChildQL.containsKey(parentQl.Id)){
                //parentQLtoChildQL.get(parentQl.Id).Customer_Product_Code__c = parentQl.Customer_Product_Code__c;
                parentQLtoChildQL.get(parentQl.Id).PosexNo__c = parentQl.PosexNo__c;
            }
        }
    }

    public static void populateCustomerProductCode(List<SBQQ__QuoteLine__c> lstQuoteLine) {        
        Set<String> salesOrgCodes = new Set<String>(); 
        Set<Id> accountIds = new Set<Id>(); 
        Set<Id> productIds = new Set<Id>(); 
        
        for(SBQQ__QuoteLine__c quoteLine : lstQuoteLine) {
            if(quoteLine.Customer_Product_Code__c == null) {
                salesOrgCodes.add(quoteLine.SAP_Sales_Org__c);
                productIds.add(quoteLine.SBQQ__Product__c);
                if(quoteLine.Price_Request_Account__c != null) {
                    accountIds.add(quoteLine.Price_Request_Account__c);
                }
                else if(quoteLine.Ship_To_Account__c != null) {
                    accountIds.add(quoteLine.Ship_To_Account__c);
                }
            }
        }
        
        System.debug('salesOrgCodes'+salesOrgCodes);
        System.debug('productIds'+productIds);
        System.debug('accountIds'+accountIds);
        
        if(!accountIds.isEmpty()) {
            List<CMIR__c> lstCMIR = [SELECT Id, Account__c, Sales_Organization_Code__c, Product__c, Customer_Material_Number__c
                FROM CMIR__c WHERE Account__c IN:accountIds AND Sales_Organization_Code__c IN:salesOrgCodes AND Product__c IN:productIds];
            Map<String, CMIR__c> cmirByKey = new Map<String, CMIR__c>();
            for(CMIR__c cmir : lstCMIR) {
                cmirByKey.put(cmir.Account__c + '' + cmir.Product__c + '' + cmir.Sales_Organization_Code__c, cmir);
            }
            
            String key = '';
            for(SBQQ__QuoteLine__c quoteLine : lstQuoteLine) {
                if(quoteLine.Price_Request_Account__c != null) {
                    key = quoteLine.Price_Request_Account__c + '' + quoteLine.SBQQ__Product__c + '' + quoteLine.SAP_Sales_Org__c;
                    if(cmirByKey.containsKey(key)) {
                        quoteLine.Customer_Product_Code__c = cmirByKey.get(key).Customer_Material_Number__c;
                        continue;
                    }
                }
                if(quoteLine.Ship_To_Account__c != null) {
                    key = quoteLine.Ship_To_Account__c + '' + quoteLine.SBQQ__Product__c + '' + quoteLine.SAP_Sales_Org__c;
                    if(cmirByKey.containsKey(key)) {
                        quoteLine.Customer_Product_Code__c = cmirByKey.get(key).Customer_Material_Number__c;
                    }
                }
            }
        }
    }
    
    public static void copyFieldValues(List<SBQQ__QuoteLine__c> lstQuoteLine) {
        
        // includes too many SOQL queries
        
        
        Map<String, List<QuoteLineCrossObjectFieldMapping__mdt>> fieldMappings = new Map<String, List<QuoteLineCrossObjectFieldMapping__mdt>>();
        Map<String, Map<String, String>> queryFields = new Map<String, Map<String, String>>();
        
        for(QuoteLineCrossObjectFieldMapping__mdt mdt : [SELECT FromQuoteField__c, ToQuoteLineField__c, Source__c, SourceField__c FROM QuoteLineCrossObjectFieldMapping__mdt]) {
            if(!fieldMappings.containsKey(mdt.Source__c)) {
                fieldMappings.put(mdt.Source__c, new List<QuoteLineCrossObjectFieldMapping__mdt>());
                queryFields.put(mdt.Source__c, new Map<String, String>());
            }
            
            fieldMappings.get(mdt.Source__c).add(mdt);
            if(!queryFields.containsKey(mdt.Source__c)) queryFields.put(mdt.Source__c, new Map<String, String>());
            queryFields.get(mdt.Source__c).put(mdt.ToQuoteLineField__c, mdt.FromQuoteField__c);
        }
        
        Map<String, Set<Id>> srcData = new Map<String, Set<Id>>();
        for(String s : fieldMappings.keySet()) {
            if(!srcData.containsKey(s)) srcData.put(s, new Set<Id>());
            for(QuoteLineCrossObjectFieldMapping__mdt  mdt : fieldMappings.get(s)) {
                for(SBQQ__QuoteLine__c ql : lstQuoteLine) {
                    if(ql.get(mdt.SourceField__c) != null) srcData.get(s).add( (Id) ql.get(mdt.SourceField__c));
                }
            }
        }
        Map<String, Map<Id, sObject>> dataSource = new Map<String, Map<Id, sObject>>();
        for(String s : queryFields.keySet()) {
          String fields = '';
            for(String sField : queryFields.get(s).values()) {
                if(fields.indexOf(sField) == -1) fields += ',' + sField;
            }    
            if(srcData.containsKey(s) && !srcData.get(s).isEmpty()) {
                System.debug('s'+s);
                //controlled query inside for loop - only executes 2x max
                Set<Id> queryIds = srcData.get(s);
                     dataSource.put(s, new Map<Id, sObject>(Database.query('SELECT Id' + fields + ' FROM ' + s + ' WHERE Id IN :queryIds')));
            }
        }
        
         for(SBQQ__QuoteLine__c ql : lstQuoteLine) {
            for(String s : fieldMappings.keySet()) {
                for(QuoteLineCrossObjectFieldMapping__mdt  mdt : fieldMappings.get(s)) {
                    if(dataSource.containsKey(s) && dataSource.get(s).containsKey( (Id)ql.get(mdt.SourceField__c)) ) {
                        ql.put(mdt.ToQuoteLineField__c, dataSource.get(s).get((Id)ql.get(mdt.SourceField__c)).get(mdt.FromQuoteField__c));
                    }
                }
            }
        }
        
    }

    public static void calculateGMIDPriorPrice(List<SBQQ__QuoteLine__c> qlList) {
        Set<Id> quoteIds = new Set<Id>();

        for (SBQQ__QuoteLine__c ql : qlList) {
            quoteIds.add(ql.SBQQ__Quote__c);
            
        }

        for (List<SBQQ__Quote__c> quoteList : [SELECT Id, SBQQ__Source__c, SBQQ__Source__r.SBQQ__ListAmount__c, (SELECT Id FROM SBQQ__LineItems__r) FROM SBQQ__Quote__c WHERE Id IN :quoteIds]) {
            for (SBQQ__Quote__c aQuot : quoteList) {
                if (aQuot.SBQQ__LineItems__r.size() == 1) {
                    aQuot.GMID_Prior_Price__c = aQuot.SBQQ__Source__r.SBQQ__ListAmount__c;
                }
                else {
                    aQuot.GMID_Prior_Price__c = null;
                }
            }
            SBQQ.TriggerControl.disable();
            try {
                update quoteList;
            } finally {
                //SBQQ.TriggerControl.enable();
            }
            
        }
    }


    public static void onRejectRecall(List<SBQQ__QuoteLine__c> quoteLines, Map<Id, SBQQ__QuoteLine__c> oldMap) {
        //List<SBQQ__QuoteLine__c> quoteLinesToUpdate = new List<SBQQ__QuoteLine__c>();
        Map<Id, SBQQ__QuoteLine__c> sourceLineNewLineMap = new Map<Id, SBQQ__QuoteLine__c>();
        //Set<Id> sourceQuoteLineIdSet = new Set<Id>();
        for (SBQQ__QuoteLine__c ql : quoteLines) {
             if (oldMap.get(ql.Id).ApprovalStatus__c != ql.ApprovalStatus__c && (ql.ApprovalStatus__c == 'Rejected' || ql.ApprovalStatus__c == 'Recalled') && ql.SBQQ__Source__c != null) {
            	//sourceQuoteLineIdSet.add(ql.SBQQ__Source__c);
                 sourceLineNewLineMap.put(ql.SBQQ__Source__c, ql );
             }
        }
        List<SBQQ__QuoteLine__c> sourceQouteLineList = [SELECT Id, SBQQ__CustomerPrice__c, New_Price_Start_Date__c, New_Price_Firm_Date__c, Price_Start_Date__c, Price_Firm_Date__c, 
                                                        New_Delivered_Price__c, Status__c, SentToSAP__c FROM SBQQ__QuoteLine__c WHERE Id IN :sourceLineNewLineMap.keySet()];
        
        for(SBQQ__QuoteLine__c sourceLine : sourceQouteLineList){
           SBQQ__QuoteLine__c currLine = sourceLineNewLineMap.get(sourceLine.Id);
           currLine.SBQQ__CustomerPrice__c = sourceLine.SBQQ__CustomerPrice__c;
           currLine.New_Price_Start_Date__c = sourceLine.New_Price_Start_Date__c;
           currLine.New_Price_Firm_Date__c = sourceLine.New_Price_Firm_Date__c;
           currLine.Price_Start_Date__c = sourceLine.Price_Start_Date__c;
           currLine.Price_Firm_Date__c = sourceLine.Price_Firm_Date__c;
           currLine.New_Delivered_Price__c = sourceLine.New_Delivered_Price__c;
            
           //quoteLinesToUpdate.add(currLine);
        }
        
    }

    public static void consolidateApproval(List<SBQQ__QuoteLine__c> quoteLines, Map<Id, SBQQ__QuoteLine__c> newMap, Map<Id, SBQQ__QuoteLine__c> oldMap) {
        Set<Id> quoteIds = new Set<Id>();
        for (SBQQ__QuoteLine__c ql : quoteLines) {
            quoteIds.add(ql.SBQQ__Quote__c);
        }

        Map<Id, SBQQ__Quote__c> mapQuotes = new Map<Id, SBQQ__Quote__c>([SELECT Id, (SELECT Id, ApprovalStatus__c, SubmittedUser__c, SubmittedDate__c FROM SBQQ__LineItems__r) FROM SBQQ__Quote__c WHERE Id IN :quoteIds]);
        Map<Id, SBQQ__Quote__c> quotesToUpdate = new Map<Id, SBQQ__Quote__c>();
        Id approvedQlRtId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByDeveloperName().get('Approved_Quote_Lines').getRecordTypeId();
        Id pendingQlRtId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByDeveloperName().get('Submitted_Quote_Line').getRecordTypeId();
        Id defaultQlRtId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByDeveloperName().get('Quote_Lines').getRecordTypeId();
        for (SBQQ__QuoteLine__c ql : quoteLines) {
            if (oldMap.get(ql.Id).ApprovalStatus__c != ql.ApprovalStatus__c) {
                if (oldMap.get(ql.Id).ApprovalStatus__c !='Approved' && ql.ApprovalStatus__c == 'Approved') {

                    ql.Approved_Date__c = Date.today();
                    ql.RecordTypeId = approvedQlRtId;

                }
                else if (oldMap.get(ql.Id).ApprovalStatus__c !='Pending' && ql.ApprovalStatus__c == 'Pending') {
                    ql.RecordTypeId = pendingQlRtId;
                }
                else if (ql.ApprovalStatus__c == 'Rejected' || ql.ApprovalStatus__c == 'Recalled') {
                    if (!quotesToUpdate.containsKey(ql.SBQQ__Quote__c)) {
                        quotesToUpdate.put(ql.SBQQ__Quote__c, new SBQQ__Quote__c(Id = ql.SBQQ__Quote__c));
                    }
                    SBQQ__Quote__c quot = quotesToUpdate.get(ql.SBQQ__Quote__c);
                    ql.RecordTypeId = defaultQlRtId;
                    quot.ApprovalStatus__c = ql.ApprovalStatus__c;
                }
            }
        }

    }

    // Marc T (Simplus) - Handles List Scale Cloning
    public static void onCloneQuoteLineInsert(List<SBQQ__QuoteLine__c> quoteLines) {
        // Uses the *SOURCE*! quote line ID as the Key to get the cloned Parent
        Map<Id, SBQQ__QuoteLine__c> clonedParentQuotesMap = new Map<Id, SBQQ__QuoteLine__c>();
        for (SBQQ__QuoteLine__c ql : quoteLines) {
            // No RequiredBy Set (IE not a List Scale) AND Has a Source ID (IE CLoned)
            if (ql.SBQQ__RequiredBy__c == null && ql.Source_Quote_Line__c != null) {
                clonedParentQuotesMap.put(ql.Source_Quote_Line__c, ql);
            }
        }

        // We have Cloned Parent Quote Lines, get all of the corresponding children and clone them
        if (!clonedParentQuotesMap.isEmpty()) {
            List<SBQQ__QuoteLine__c> quoteLinesToInsertList = new List<SBQQ__QuoteLine__c>();
            List<SBQQ__QuoteLine__c> updateOrigQuoteLines = new List<SBQQ__QuoteLine__c>();
            Set<Id> clonedParentQuoteIds = clonedParentQuotesMap.keySet();
            String quoteLineQuery = 'SELECT Id, SBQQ__Quote__r.SBQQ__Opportunity2__r.OriginalOpportunity__c, New_Price_Start_Date__c, New_Price_Firm_Date__c, New_Delivered_Price__c, Status__c, Price_Start_Date__c, Price_Firm_Date__c, '
                                    + 'New_Competitive_Manufacturer__c, New_Competitive_Price__c, New_Competitor_Product__c, New_Competitor__c, ApprovalStatus__c, SBQQ__RequiredBy__c, SBQQ__EndDate__c,' 
                                    + 'SBQQ__DynamicOptionId__c, SBQQ__OptionLevel__c,SBQQ__OptionType__c, SBQQ__PricebookEntryId__c, SBQQ__ProductSubscriptionType__c, CUPS_End_User__c, CUPS_End_User2__c, CUPS_End_User3__c, CUPS_End_User4__c, New_CUPS_Support_Price__c, New_CUPS_Start_Date__c, New_CUPS_End_Date__c, '
                                    + 'CUPS_Support_Price__c, CUPS_Support_Price2__c, CUPS_Support_Price3__c, CUPS_Support_Price4__c, CUPS_Start_Date__c, CUPS_Start_Date2__c, CUPS_Start_Date3__c, CUPS_Start_Date4__c, CUPS_End_Date__c, CUPS_End_Date2__c, CUPS_End_Date3__c, CUPS_End_Date4__c, '
                                    + 'CUPS_Discount_Percent__c, CUPS_Discount_Percent2__c, CUPS_Discount_Percent3__c,CUPS_Discount_Percent4__c, Competitive_Manufacturer__c, Competitive_Price__c, Competitor_Product__c, Competitive_Distributor__c, Base_UOM__c, PH3__c, '                   
                                    + 'SBQQ__SubscriptionType__c, New_CUPS_Support_Price2__c, New_CUPS_Support_Price3__c, New_CUPS_Support_Price4__c, New_CUPS_Start_Date2__c, New_CUPS_Start_Date3__c, New_CUPS_Start_Date4__c, New_CUPS_End_Date2__c, New_CUPS_End_Date3__c, New_CUPS_End_Date4__c, CUPS_Eligible__c, ' 
                                    + UtilityClass.getFieldSetSoqlString('MassPricing', 'SBQQ__QuoteLine__c') 
                                    + ' FROM SBQQ__QuoteLine__c'
                                    + ' WHERE SBQQ__RequiredBy__c IN :clonedParentQuoteIds';
            List<SBQQ__QuoteLine__c> childQuoteLinesOriginalsList = Database.query(quoteLineQuery);
            // Taken from quoteCloningService because for some reason it builds an sObject initially, so this isn't defined by default
            Id defaultQlRtId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByDeveloperName().get('Quote_Lines').getRecordTypeId();

            for (SBQQ__QuoteLine__c childQuoteLine : childQuoteLinesOriginalsList) {
                SBQQ__QuoteLine__c parentQuoteLine = clonedParentQuotesMap.get(childQuoteLine.SBQQ__RequiredBy__c);

                // Clone the child, and then set the requiredBy to the Parent ID
                SBQQ__QuoteLine__c clonedChild = QuoteCLoningService.cloneQuoteLine(childQuoteLine, true);
                clonedChild.SBQQ__Quote__c = parentQuoteLine.SBQQ__Quote__c;
                clonedChild.SBQQ__RequiredBy__c = parentQuoteLine.Id;
                clonedChild.SBQQ__DynamicOptionId__c = childQuoteLine.SBQQ__DynamicOptionId__c;
                clonedChild.SBQQ__OptionLevel__c = childQuoteLine.SBQQ__OptionLevel__c;
                clonedChild.SBQQ__OptionType__c = childQuoteLine.SBQQ__OptionType__c;
                clonedChild.SBQQ__PricebookEntryId__c = childQuoteLine.SBQQ__PricebookEntryId__c;
                // clonedChild.SBQQ__ProductOption__c = childQuoteLine.SBQQ__ProductOption__c;
                clonedChild.SBQQ__ProductSubscriptionType__c = childQuoteLine.SBQQ__ProductSubscriptionType__c;
                //clonedChild.SBQQ__SubscriptionBase__c = childQuoteLine.SBQQ__SubscriptionBase__c;
                clonedChild.SBQQ__SubscriptionType__c = childQuoteLine.SBQQ__SubscriptionType__c;
                //clonedChild.SBQQ__PriceEditable__c = childQuoteLine.SBQQ__PriceEditable__c;
                // If the parent is submitted for approval, the Child should be as well
                clonedChild.SubmitForApproval__c = parentQuoteLine.SubmitForApproval__c;
                // The *Original* Child needs to be updated as well (Based on what QuoteCloningService does)
                updateOrigQuoteLines.add(new SBQQ__QuoteLine__c(Id = childQuoteLine.Id, 
                    Price_Status__c = parentQuoteLine.SubmitForApproval__c ? 'Cloned & Submitted' : 'Cloned'));
                clonedChild.RecordTypeId = defaultQlRtId;
                //TKT-274
                clonedChild.SBQQ__StartDate__c = childQuoteLine.SBQQ__StartDate__c;
                clonedChild.SBQQ__EndDate__c = childQuoteLine.SBQQ__EndDate__c;
                clonedChild.Price_Firm_Date__c = parentQuoteLine.New_Price_Firm_Date__c;
                clonedChild.Price_Start_Date__c = parentQuoteLine.New_Price_Start_Date__c;
                if(parentQuoteLine.Status__c == 'Won') {
                    clonedChild.Status__c = 'Negotiation';
                }
                
                quoteLinesToInsertList.add(clonedChild);
            }

            insert quoteLinesToInsertList;
            update updateOrigQuoteLines;
        }
    }
    
    public static void onQuoteLineSave(Map<Id, SBQQ__QuoteLine__c> newQuoteLines, Map<Id, SBQQ__QuoteLine__c> oldQuoteLineMap) {
        List<SBQQ__QuoteLine__c> quoteLinessToUpdate = new List<SBQQ__QuoteLine__c>();
        Set<id> scaleItemsToDelete = new Set<id>();
        
        Map<Id, Id> relationshipIdByLineId = new Map<Id, Id>();
        Map<Id, Set<Id>> productIdsByQuoteId = new Map<Id, Set<Id>>();
        Map<Id, List<SBQQ__ProductOption__c>> optionsByProductId = new Map<Id, List<SBQQ__ProductOption__c>>();
        Map<String, Product_List_Price__c> listPriceByKey = new Map<String, Product_List_Price__c>();
        Set<Id> priceBooksIdSet = new Set<Id>();
        
        Set<Id> relationIds = new Set<Id>();
        Set<Id> distributorRelationIds = new Set<Id>();
        Map<Id, Set<Id>> quoteLinesByQuoteId = new Map<Id, Set<Id>>();
        Set<Id> quoteIds = new Set<Id>();
        Set<Id> productIds = new Set<Id>();
        Set<String> salesOrg = new Set<String>();
        
        for (SBQQ__QuoteLine__c quoteLine : newQuoteLines.values()) {
           SBQQ__QuoteLine__c oldQL = oldQuoteLineMap.get(quoteLine.Id);
           if (oldQL.Ship_To_Account__c != quoteLine.Ship_To_Account__c){
                quoteIds.add(quoteLine.SBQQ__Quote__c);
                relationIds.add(quoteLine.Ship_To_Account__c);
                relationshipIdByLineId.put(quoteLine.Id, quoteLine.Ship_To_Account__c);
           }
        }

        if (quoteIds.isEmpty()){
            return;
        }
        
        System.debug('quoteIds'+quoteIds);
        System.debug('relationIds'+relationIds);
        
        Map<Id, SBQQ__QuoteLine__c> allLines = new Map<Id, SBQQ__QuoteLine__c>([SELECT Id, SBQQ__Product__c, SBQQ__Quote__c, SBQQ__Number__c,
            Status__c, PaymentTerms__c, Ship_From_Plant_List__c, Ship_Mode__c, Shipping_Condition__c, Per_Quantity__c,
            Incoterm__c, Price_Change_Mechanism__c, Price_Change_Frequency__c, SBQQ__Quote__r.SBQQ__Account__c,
            SBQQ__Quote__r.SBQQ__PriceBook__c, Ship_To__c, SBQQ__RequiredBy__c, Product_Level__c, Fuel_Surcharge_Exemption__c, SAP_Sales_Org__c
            FROM SBQQ__QuoteLine__c
            WHERE SBQQ__Quote__c IN:quoteIds ORDER BY SBQQ__Number__c]);
        for (SBQQ__QuoteLine__c quoteLine : allLines.values()) {
            if(!quoteLinesByQuoteId.containsKey(quoteLine.SBQQ__Quote__c)) {
                quoteLinesByQuoteId.put(quoteLine.SBQQ__Quote__c, new Set<Id>());
            }
            quoteLinesByQuoteId.get(quoteLine.SBQQ__Quote__c).add(quoteLine.Id);
 
            if(!priceBooksIdSet.contains(quoteLine.SBQQ__Quote__r.SBQQ__PriceBook__c)) {
                priceBooksIdSet.add(quoteLine.SBQQ__Quote__r.SBQQ__PriceBook__c);
            }
            if(!productIdsByQuoteId.containsKey(quoteLine.SBQQ__Quote__c)) {
                productIdsByQuoteId.put(quoteLine.SBQQ__Quote__c, new Set<Id>());
            }
            productIdsByQuoteId.get(quoteLine.SBQQ__Quote__c).add(quoteLine.SBQQ__Product__c);
        }
        System.debug('productIdsByQuoteId'+productIdsByQuoteId);
        
        List<Account_Relationships__c> accountRelations = [SELECT Id FROM Account_Relationships__c 
            WHERE Is_Distribution_Relationship__c = true AND Id IN:relationIds];
        for(Account_Relationships__c accountRelation : accountRelations) {
            distributorRelationIds.add(accountRelation.Id);
        }
        System.debug('distributorRelationIds'+distributorRelationIds);
        
        if(!distributorRelationIds.isEmpty()) {
            for (SBQQ__QuoteLine__c quoteLine : newQuoteLines.values()) {



                Id relationId = relationshipIdByLineId.get(quoteLine.Id);
                if(distributorRelationIds.contains(relationId)) {
                    productIds.add(quoteLine.SBQQ__Product__c);
                    salesOrg.add(quoteLine.SAP_Sales_Org__c);
                }
            }
            
            System.debug('productIds'+productIds);

            List<PricebookEntry> pbEntriesList = [SELECT Id, Pricebook2Id, Product2Id
                                                    FROM PricebookEntry
                                                    WHERE Pricebook2Id IN :priceBooksIdSet
                                                    AND Product2Id IN :productIds];
            
            // Marc T (Simplus) - Map for Price Book Entries by Price Book and Product
            // Key -> PriceBook.Id + '' + Product.Id
            Map<String, PricebookEntry> pbeByPBAndProdMap = new Map<String, PricebookEntry>();
            for (PricebookEntry pbe : pbEntriesList) {
                if (!pbeByPBAndProdMap.containsKey(pbe.Pricebook2Id +''+ pbe.Product2Id)) {
                    pbeByPBAndProdMap.put(pbe.Pricebook2Id +''+ pbe.Product2Id, pbe);
                }
            }
            
            List<SBQQ__ProductOption__c> productOptions = [SELECT Id, SBQQ__ConfiguredSKU__c, SBQQ__OptionalSKU__c, SBQQ__OptionalSKU__r.Product_Level__c, 
                SBQQ__OptionalSKU__r.Name, SBQQ__Feature__c, SBQQ__Type__c
                FROM SBQQ__ProductOption__c 
                WHERE SBQQ__Feature__r.Name = 'Scale Pricing' 
                AND SBQQ__ConfiguredSKU__c IN:productIds        
                ORDER BY SBQQ__ConfiguredSKU__c, SBQQ__OptionalSKU__r.Name];
            for(SBQQ__ProductOption__c productOption : productOptions) {
                if(!optionsByProductId.containsKey(productOption.SBQQ__ConfiguredSKU__c)) {
                    optionsByProductId.put(productOption.SBQQ__ConfiguredSKU__c, new List<SBQQ__ProductOption__c>());
                }
                optionsByProductId.get(productOption.SBQQ__ConfiguredSKU__c).add(productOption);
            }
            System.debug('productOptions'+productOptions);
            
            List<Product_List_Price__c> productListPrices = [SELECT Id, Valid_From__c, Valid_To__c, Scale_UOM__c, Index_Order_Number__c, Product__c,
                Sales_Organization__c, UOM__c, Per_Quantity__c, List_Price__c, ScaleQty__c FROM Product_List_Price__c WHERE Product__c IN:productIds AND Valid_From__c <= TODAY 
AND Valid_To__c >= TODAY AND Sales_Organization__r.Sales_Organization_Code__c IN:salesOrg ORDER BY Index_Order_Number__c];
            for(Product_List_Price__c productListPrice : productListPrices) {
                listPriceByKey.put(productListPrice.Product__c + '' + productListPrice.Index_Order_Number__c, productListPrice);
            }
            List<SBQQ__Quote__c> forceRecalculateQuotes = new List<SBQQ__Quote__c>();
            // Marc T (Simplus) - Refactored this to work by quote - Multiple Quotes worth of quote lines would have broken this on existing implementation
            for (Id quoteId : quoteIds) {
                SBQQ__Quote__c quot = new SBQQ__Quote__c(Id = quoteId, SBQQ__Primary__c = true, ForceRecalculate__c = DateTime.now());
                forceRecalculateQuotes.add(quot);
                Integer i = 1;
                Set<Id> allQuoteLineIdsForQuote = quoteLinesByQuoteId.get(quoteId);
                
                Set<Id> lineItemsToHandle = new Set<Id>();

                Map<Id, Set<Id>> lineItemNonScaleChildren = new Map<Id, Set<Id>>();
                
                // Marc T (Simplus) - Gather all of the Scale items to delete at once, as we'll be inserting new ones per what Jimmy wants
                // This will likely be ugly, but don't have the time to figure out a better solution
                for (Id quoteLineId : allQuoteLineIdsForQuote) {
                    SBQQ__QuoteLine__c lineItem = allLines.get(quoteLineId);
                    
                    if (lineItem.SBQQ__RequiredBy__c != null) {
                        SBQQ__QuoteLine__c parentLine = allLines.get(lineItem.SBQQ__RequiredBy__c);
                        //if (optionsByProductId.containsKey(parentLine.SBQQ__Product__c) && lineItem.Product_Level__c == 'Scale') {
                            // Has to be a scale item at this point, because the only options we've pulled are scales
                            //scaleItemsToDelete.add(lineItem.Id);
                        //}
                       //else {
                            // Child is NOT a scale
                            if(!lineItemNonScaleChildren.containsKey(parentLine.Id)) {
                                lineItemNonScaleChildren.put(parentLine.Id, new Set<Id>());
                            }
                            lineItemNonScaleChildren.get(parentLine.Id).add(lineItem.Id);
                       // }
                    }
                    else {
                        lineItemsToHandle.add(quoteLineId);
                    }
                }

                System.debug('QL Trigger Handler lineItemNonScaleChildren');
                System.debug(lineItemNonScaleChildren);
                
                System.debug('QLIs to handle: ' + lineItemsToHandle);
                // Marc T (Simplus) - This is now unsorted due to iterating over a set now. Not sure if that matters.
                for (Id quoteLineId : lineItemsToHandle) {
                    SBQQ__QuoteLine__c quoteLine = allLines.get(quoteLineId);
                    SBQQ__QuoteLine__c updatedLine = new SBQQ__QuoteLine__c(Id = quoteLine.Id);
                    //updatedLine.SBQQ__Number__c = i;
                    i++;
                    
                    Id relationId = relationshipIdByLineId.get(quoteLine.Id);
                    if(distributorRelationIds.contains(relationId)) {
                        List<SBQQ__ProductOption__c> options = optionsByProductId.get(quoteLine.SBQQ__Product__c);
                        if(options != null && !options.isEmpty()) {
                            quoteLinessToUpdate.add(updatedLine);
                            for(SBQQ__ProductOption__c productOption : options) {
                                System.debug('productOption'+productOption);
                                Id configuredProductId = quoteLine.SBQQ__Product__c;
                                //Id quoteId = quoteLine.SBQQ__Quote__c;
                                
                                System.debug('configuredProductId'+configuredProductId);
                                System.debug('quoteId'+quoteId);
                                
                                String order = productOption.SBQQ__OptionalSKU__r.Name.substringBetween('(',')');
                                System.debug('quoteId'+quoteId);
                                System.debug('quoteLine'+quoteLine);
                                System.debug('productIdsByQuoteId.containsKey(quoteId)'+productIdsByQuoteId.containsKey(quoteId));
                                if(productIdsByQuoteId.containsKey(quoteId) 
                                //&& !productIdsByQuoteId.get(quoteId).contains(productOption.SBQQ__OptionalSKU__c)
                                && quoteLine.SBQQ__Product__c == productOption.SBQQ__ConfiguredSKU__c) {
                                    
                                    SBQQ__QuoteLine__c newLine = new SBQQ__QuoteLine__c();
                                    newLine.Ship_To__c = quoteLine.Ship_To__c;
                                    newLine.SBQQ__PricebookEntryId__c = (String)pbeByPBAndProdMap.get(
                                    quoteLine.SBQQ__Quote__r.SBQQ__PriceBook__c+''+productOption.SBQQ__OptionalSKU__c)?.Id;
                                    newLine.Price_Request_Account__c = quoteLine.SBQQ__Quote__r.SBQQ__Account__c;
                                    newLine.SBQQ__DynamicOptionId__c = productOption.SBQQ__Feature__c;
                                    newLine.SBQQ__ProductOption__c = productOption.Id;
                                    newLine.SBQQ__OptionType__c = productOption.SBQQ__Type__c;
                                    newLine.SBQQ__OptionLevel__c = 1;
                                    newLine.SBQQ__Product__c = productOption.SBQQ__OptionalSKU__c;
                                    newLine.SBQQ__Quote__c = quoteLine.SBQQ__Quote__c;
                                    newLine.Fuel_Surcharge_Exemption__c = quoteLine.Fuel_Surcharge_Exemption__c;
                                    
                                    newLine.Product_Level__c = productOption.SBQQ__OptionalSKU__r.Product_Level__c;
                                    newLine.SBQQ__RequiredBy__c = quoteLine.Id;
                                    newLine.Status__c = quoteLine.Status__c;
                                    newLine.PaymentTerms__c = quoteLine.PaymentTerms__c;
                                    if (relationshipIdByLineId.containsKey(quoteLine.Id)) {
                                        newLine.Ship_To_Account__c = relationshipIdByLineId.get(quoteLine.Id);
                                    }
                                    newLine.Ship_From_Plant_List__c = quoteLine.Ship_From_Plant_List__c;
                                    newLine.Ship_Mode__c = quoteLine.Ship_Mode__c;
                                    newLine.Shipping_Condition__c = quoteLine.Shipping_Condition__c;
                                    newLine.Incoterm__c = quoteLine.Incoterm__c;
                                    newLine.Price_Change_Mechanism__c = quoteLine.Price_Change_Mechanism__c;
                                    newLine.Price_Change_Frequency__c = quoteLine.Price_Change_Frequency__c;
                                    Product_List_Price__c listPrice = listPriceByKey.get(configuredProductId + '' + order);
                                    if(listPrice == null) {
                                        continue;
                                    }
                                    if(listPrice != null) {
                                        newLine.Validity_Start_Date__c = listPrice.Valid_From__c;
                                        newLine.Validity_End_Date__c = listPrice.Valid_To__c;
                                        newLine.SAP_Sales_Org__c = listPrice.Sales_Organization__c;
                                        /*  Marc T - List Price Cares about per quantity, because the PLP's base list price is implicitly per 1.
                                        *   Should be safe enough to multiply as it's only in multiples of 10 so shouldn't have any rounding
                                        *   issues. If there are any, modify this to use the pre-populated formula values for 1/10/100.
                                        */
                                        newLine.SBQQ__ListPrice__c = listPrice.List_Price__c * Integer.valueOf(quoteLine.Per_Quantity__c);
                                        newLine.UOM__c = listPrice.UOM__c;
                                        newLine.Scale_UOM__c = listPrice.Scale_UOM__c;
                                        newline.Min_Volume__c = listPrice.ScaleQty__c;
                                        newLine.Per_Quantity__c = quoteLine.Per_Quantity__c;
                                        newLine.Avg_Annualize_Volume__c = listPrice.ScaleQty__c;
                                        if (order == '1') {
                                            updatedLine.SBQQ__ListPrice__c = newLine.SBQQ__ListPrice__c;
                                        }
                                        if(listPrice.List_Price__c == 0) {
                                            continue;
                                        }
                                    }
                                    
                                    newLine.SBQQ__Number__c = quoteLine.SBQQ__Number__c + Decimal.valueOf(order);
                                   // newLine.SBQQ__Number__c = i;
                                    //i++;
                                    quoteLinessToUpdate.add(newLine);
                                }
                            }
                        } 
                            // Done with Scale Options, do the rest of the Children if there are any
                            Set<Id> childIds = lineItemNonScaleChildren.get(quoteLineId);
                            if (childIds != null) {
                                // Process the Non-Scales with proper numbering
                                for (Id childId : childIds) {
                                    SBQQ__QuoteLine__c childLine = allLines.get(childId);
                                    if (childLine != null) {
                                        SBQQ__QuoteLine__c updatedChild = new SBQQ__QuoteLine__c(Id = childLine.Id);
                                        updatedChild.SBQQ__Number__c = i;
                                        quoteLinessToUpdate.add(updatedChild);
                                        i++;
                                    }
                                }
                            }
                    }
                    // else {
                        // Why would we want to do this? - MT (Simplus)
                        // quoteLinessToUpdate.clear();
                    // }

                    
                }
            }
        }
        else {
            // Distributor relationships is EMPTY, find and delete all scales for these quotes
            for (Id quoteId : quoteIds) {
                Integer i = 1;
                Set<Id> allQuoteLineIdsForQuote = quoteLinesByQuoteId.get(quoteId);
                
                Set<Id> lineItemsToHandle = new Set<Id>();

                Map<Id, Set<Id>> lineItemNonScaleChildren = new Map<Id, Set<Id>>();
                
                // Marc T (Simplus) - Gather all of the Scale items to delete at once, as we'll be inserting new ones per what Jimmy wants
                // This will likely be ugly, but don't have the time to figure out a better solution
                for (Id quoteLineId : allQuoteLineIdsForQuote) {
                    SBQQ__QuoteLine__c lineItem = allLines.get(quoteLineId);
                    
                    if (lineItem.SBQQ__RequiredBy__c != null) {
                        //if (lineItem.Product_Level__c == 'Scale') { //test 
                        //    scaleItemsToDelete.add(lineItem.Id);
                       // }
                       // else {
                            // Child is NOT a scale
                            if(!lineItemNonScaleChildren.containsKey(lineItem.Id)) {
                                lineItemNonScaleChildren.put(lineItem.Id, new Set<Id>());
                            }
                            lineItemNonScaleChildren.get(lineItem.Id).add(lineItem.Id);
                       // }
                    }
                    else {
                        lineItemsToHandle.add(quoteLineId);
                    }
                }

                for (Id quoteLineId : lineItemsToHandle) {
                    SBQQ__QuoteLine__c quoteLine = allLines.get(quoteLineId);
                    if (quoteLine != null) {
                        SBQQ__QuoteLine__c updatedLine = new SBQQ__QuoteLine__c(Id = quoteLine.Id);
                        updatedLine.SBQQ__Number__c = i;
                        quoteLinessToUpdate.add(updatedLine);
                        i++;
    
                        Set<Id> childIds = lineItemNonScaleChildren.get(quoteLineId);
                        if (childIds != null) {
                            // Process the Non-Scales with proper numbering
                            for (Id childId : childIds) {
                                SBQQ__QuoteLine__c childLine = allLines.get(childId);
                                if (childLine != null) {
                                    SBQQ__QuoteLine__c updatedChild = new SBQQ__QuoteLine__c(Id = childLine.Id);
                                    updatedChild.SBQQ__Number__c = i;
                                    quoteLinessToUpdate.add(updatedChild);
                                    i++;
                                }
                            }
                        }
                    }
                }
                System.debug('QL Trigger Handler lineItemNonScaleChildren');
                System.debug(lineItemNonScaleChildren);
            }
        }
        

        System.debug('quoteLinessToUpdate'+quoteLinessToUpdate);
        
        if(!quoteLinessToUpdate.isEmpty()) {
            try {
                disableDLRSTrigger = true;
                SBQQ.TriggerControl.disable();
                upsert quoteLinessToUpdate;
            }
            catch(Exception ex) {
                System.debug(ex);
                System.debug(ex.getMessage());
            }
        }
        
        System.debug('scaleItemsToDelete'+scaleItemsToDelete);

        if (!scaleItemsToDelete.isEmpty()) {
            try {
                deleteScaleItems(scaleItemsToDelete);
            }
            catch(Exception ex) {
                System.debug(ex);
                System.debug(ex.getMessage());
            }
        }

        SBQQ.TriggerControl.enable();
        disableDLRSTrigger = false;
    }

    @Testvisible
    @future
    private static void deleteScaleItems(Set<Id> scaleItemsToDelete) {
        QuoteLineTrigger_Handler.runOnceBeforeDelete();
        disableDLRSTrigger = true;
        SBQQ.TriggerControl.disable();
        List<SBQQ__QuoteLine__c> itemsToDelete = [SELECT Id FROM SBQQ__QuoteLine__c WHERE Id IN :scaleItemsToDelete];
        delete itemsToDelete;
    }

    public static void onQuoteLineWon(List<SBQQ__QuoteLine__c> quoteLines, Map<Id, SBQQ__QuoteLine__c> oldMap) {
        Set<Id> quoteIds = new Set<Id>();
        Set<Id> quoteLineIds = new Set<Id>();
        List<SBQQ__QuoteLine__c> quoteLinessToUpdate = new List<SBQQ__QuoteLine__c>();
        for (SBQQ__QuoteLine__c quoteLine : quoteLines) {
            if (oldMap.get(quoteLine.Id).Status__c != 'Won' && quoteLine.Status__c == 'Won' && quoteLine.SBQQ__RequiredBy__c == null) {
                quoteLineIds.add(quoteLine.Id);
                quoteLinessToUpdate.add(quoteLine);
            }
        }
        if(!quoteLineIds.isEmpty()){
            List<SBQQ__QuoteLine__c> lUpdateChildItems = new List<SBQQ__QuoteLine__c>();
            for (SBQQ__QuoteLine__c childQL : [SELECT Id, ApprovalStatus__c, Status__c, SBQQ__Quote__c FROM SBQQ__QuoteLine__c WHERE SBQQ__RequiredBy__c IN : quoteLineIds]) {
                if(childQL.Status__c != 'Won'){
                    SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c(Id = childQL.Id, Status__c = 'Won',  ApprovalStatus__c = 'Approved');
                    lUpdateChildItems.add(ql);
                    quoteLinessToUpdate.add(childQL);
                }
            }
        }

        
        if(!quoteLinessToUpdate.isEmpty()) {
                validateAndSendWonQuoteLinesToSAP(quoteLinessToUpdate);
        }
    }

    public static void onQuoteLineStatusChange(List<SBQQ__QuoteLine__c> quoteLines, Map<Id, SBQQ__QuoteLine__c> oldMap) {
        System.debug('In QuoteLineStatusChange');
        Id contractedPriceReqRtId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('Contracted_Price_Requests').getRecordTypeId();
        Id contractFieldsLockedRtId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('Contract_Fields_Locked').getRecordTypeId();
        
        Map<Id, List<SBQQ__QuoteLine__c>> quoteToQuoteLines = getQuoteToQuoteLines(quoteLines);
        
        Map<Id, Integer> totalQuoteLineCount = new Map<Id, Integer>();
        Map<Id, Integer> totalApprovedCount = new Map<Id, Integer>();
        Map<Id, Integer> totalWonCount = new Map<Id, Integer>();
        Map<Id, Integer> totalLostCount = new Map<Id, Integer>();
        
        for(Id quoteId:quoteToQuoteLines.keySet()){
            List<SBQQ__QuoteLine__c> currentQuoteLines = quoteToQuoteLines.get(quoteId);
            for(SBQQ__QuoteLine__c ql:currentQuoteLines){
                if(ql.SBQQ__RequiredBy__c == null){
                    incrementQuoteLineCount(quoteId, totalQuoteLineCount);
                    if(ql.ApprovalStatus__c == 'Approved' && ql.Status__c != 'Negotiation'){
                        incrementQuoteLineCount(quoteId, totalApprovedCount);
                       // if(ql.Status__c == 'Won' && (oldMap.containsKey(ql.Id) || oldMap.get(ql.Id).Status__c != 'Won')){
                        if(oldMap.get(ql.Id) != NULL){
                            if(ql.Status__c == 'Won' && oldMap.get(ql.Id).Status__c != 'Won'){
                                incrementQuoteLineCount(quoteId, totalWonCount);
                                system.debug('PJ PJ PJ UPDATED TO WON ');
                            }
                            //if(ql.Status__c == 'Lost' && (oldMap.containsKey(ql.Id) || oldMap.get(ql.Id).Status__c != 'Lost')){
                            if(ql.Status__c == 'Lost' && oldMap.get(ql.Id).Status__c != 'Lost'){
                                incrementQuoteLineCount(quoteId, totalLostCount);
                            }
                        }
                    } 
                }
            }   
        }
        system.debug('PJ PJ PJ totalWonCount ::::::::  '+totalWonCount);
        List<Id> quotesWithAllApprovedQuoteLines = new List<Id>();
        
        for(Id quoteId:quoteToQuoteLines.keySet()){
            if(totalQuoteLineCount.get(quoteId) == totalApprovedCount.get(quoteId)){
                quotesWithAllApprovedQuoteLines.add(quoteId);
            }
        }
        
        List<Id> quotesWithAllQuoteLinesLost = new List<Id>();
        List<Id> quotesWithAtleastOneQuoteLineWon = new List<Id>();
        List<Id> otherQuotes = new List<Id>();
        
        for(Id approvedQuoteId:quotesWithAllApprovedQuoteLines){
            if(totalQuoteLineCount.get(approvedQuoteId) == totalLostCount.get(approvedQuoteId)){
                quotesWithAllQuoteLinesLost.add(approvedQuoteId);
            }else if(totalWonCount.get(approvedQuoteId) > 0){
                quotesWithAtleastOneQuoteLineWon.add(approvedQuoteId);
            }else{
                otherQuotes.add(approvedQuoteId);
            }
        }
        
        List<SBQQ__Quote__c> approvedQuotes = [SELECT Id, SBQQ__Opportunity2__c, SBQQ__Opportunity2__r.SBQQ__Contracted__c, SBQQ__Opportunity2__r.StageName FROM SBQQ__Quote__c WHERE Id IN: quotesWithAllApprovedQuoteLines];
        Set<Id> contractedOppppId = new Set<Id>();
        Map<Id, Boolean> isContractedOppMap = new Map<Id, Boolean>();
        Map<Id, Boolean> isCompletedOppMap = new Map<Id, Boolean>();
        for(SBQQ__Quote__c approvedQuote:approvedQuotes){
            if(quotesWithAllQuoteLinesLost.contains(approvedQuote.Id)){
                approvedQuote.RecordTypeId = contractFieldsLockedRtId;
            }else if(quotesWithAtleastOneQuoteLineWon.contains(approvedQuote.Id)){
                approvedQuote.RecordTypeId = contractedPriceReqRtId;
                //contractedOppppId.add(approvedQuote.SBQQ__Opportunity2__c);//added to update Opportunity by PJ Buanghug 02/10/2023
                isContractedOppMap.put(approvedQuote.SBQQ__Opportunity2__c, true);
                //approvedQuote.SBQQ__Opportunity2__r.SBQQ__Contracted__c = true;
            }
            if(!otherQuotes.contains(approvedQuote.Id)){
                approvedQuote.SBQQ__Status__c = 'Draft Contract';
                //approvedQuote.SBQQ__Opportunity2__r.StageName = 'Completed';
                isCompletedOppMap.put(approvedQuote.SBQQ__Opportunity2__c, true);
            }
        }
        if(approvedQuotes.size() > 0){
            update approvedQuotes;
        }
         /*  PJ Buanghug (Simplus) 02/10/2023
            *  Actual Update on the Opportunity to make it contracted
            */
        List<Opportunity> oppToUpdate = new List<Opportunity>();
        System.debug('isContractedOppMap >>' + isContractedOppMap.keySet());
        List<Opportunity> oppList = [SELECT Id, SBQQ__Contracted__c FROM Opportunity WHERE Id IN: isContractedOppMap.keySet() OR Id IN: isCompletedOppMap.keySet()];
        for(Opportunity opp : oppList){
            if(isContractedOppMap.get(opp.Id) != NULL){
                if(isContractedOppMap.get(opp.Id)){
                    if(!opp.SBQQ__Contracted__c){
                        opp.SBQQ__Contracted__c = TRUE;
                        oppToUpdate.add(opp);
                    }
                }
                if(isCompletedOppMap.get(opp.Id)){
                    opp.StageName = 'Completed';
                }
            }
        }
        if(oppToUpdate.size() > 0){
            update oppToUpdate;
        }
    }
    
    private static Map<Id, List<SBQQ__QuoteLine__c>> getQuoteToQuoteLines(List<SBQQ__QuoteLine__c> quoteLines){
        Set<Id> quoteIds = new Set<Id>();
        for(SBQQ__QuoteLine__c ql:quoteLines){
            quoteIds.add(ql.SBQQ__Quote__c);
        }
        Map<Id, List<SBQQ__QuoteLine__c>> quoteToQuoteLines = new Map<Id, List<SBQQ__QuoteLine__c>>();
        //Map<Id, SBQQ__Quote__c> quotes = new Map<Id, SBQQ__Quote__c>([SELECT Id FROM SBQQ__Quote__c WHERE Id IN: quoteIds]);
        List<SBQQ__QuoteLine__c> allQuoteLines = [SELECT Id, SBQQ__RequiredBy__c, ApprovalStatus__c, Status__c, SBQQ__Quote__c, SentToSAP__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN: quoteIds];
        
        for(SBQQ__QuoteLine__c quoteLine: allQuoteLines){
            Id quoteId = quoteLine.SBQQ__Quote__c;
            if(quoteToQuoteLines.containsKey(quoteId)){
                List<SBQQ__QuoteLine__c> currentQuoteLines = quoteToQuoteLines.get(quoteId);
                currentQuoteLines.add(quoteLine);
                quoteToQuoteLines.put(quoteId, currentQuoteLines);
            }else{
                quoteToQuoteLines.put(quoteId, new List<SBQQ__QuoteLine__c>{quoteLine});
            }
        }
        
        return quoteToQuoteLines;
    }
    
    private static void incrementQuoteLineCount(Id quoteId, Map<Id, Integer> countToIncrement){
        if(countToIncrement.containsKey(quoteId)){
            countToIncrement.put(quoteId, countToIncrement.get(quoteId)+1);
        }else{
            countToIncrement.put(quoteId, 1);
        }
    }
    
    public static void onQuoteLineApproval(List<SBQQ__QuoteLine__c> quoteLines, Map<Id, SBQQ__QuoteLine__c> oldMap) {


        Id approvedQlRtId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByDeveloperName().get('Approved_Quote_Lines').getRecordTypeId();
        Id pendingQlRtId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByDeveloperName().get('Submitted_Quote_Line').getRecordTypeId();
        Map <Id, List<Id>> mapChildQuoteLines = new Map <Id, List<Id>>(); // to test
        Set<Id> quoteIds = new Set<Id>();
        for (SBQQ__QuoteLine__c ql : quoteLines) {
            quoteIds.add(ql.SBQQ__Quote__c);
        }

        for (SBQQ__QuoteLine__c quoteLineIds : [SELECT Id, SBQQ__RequiredBy__c, ApprovalStatus__c FROM SBQQ__QuoteLine__c WHERE SBQQ__RequiredBy__c != NULL AND SBQQ__RequiredBy__c IN :quoteLines] ){ // to test
            List<Id> tempQLId = new List<Id>();
            if (!mapChildQuoteLines.containsKey(quoteLineIds.SBQQ__RequiredBy__c)) {
                tempQLId.add(quoteLineIds.Id);
                mapChildQuoteLines.put(quoteLineIds.SBQQ__RequiredBy__c, tempQLId);
            } else {
                tempQLId = mapChildQuoteLines.get(quoteLineIds.SBQQ__RequiredBy__c);
                tempQLId.add(quoteLineIds.Id);
                mapChildQuoteLines.put(quoteLineIds.SBQQ__RequiredBy__c, tempQLId);
            }
        }
        
        Map<Id, SBQQ__Quote__c> mapQuotes = new Map<Id, SBQQ__Quote__c>([SELECT Id, (SELECT Id, ApprovalStatus__c, SubmittedUser__c, SubmittedDate__c FROM SBQQ__LineItems__r WHERE Product_Level__c = 'GMID') FROM SBQQ__Quote__c WHERE Id IN :quoteIds]);

        List<SBQQ__QuoteLine__c> quoteLineToUpdate = new List<SBQQ__QuoteLine__c>();
        Map<Id, SBQQ__Quote__c> quotesToUpdate = new Map<Id, SBQQ__Quote__c>();
        for (SBQQ__QuoteLine__c ql : quoteLines) {

            // Map<Id, SBQQ__Quote__c> quotesToUpdate = new Map<Id, SBQQ__Quote__c>();

            SBQQ__QuoteLine__c listQuoteLine = new SBQQ__QuoteLine__c();
            if (ql.ApprovalStatus__c == '' || ql.ApprovalStatus__c == null){
                continue;
            }
            if (ql.ApprovalStatus__c == 'Approved' && oldMap.get(ql.Id).ApprovalStatus__c != 'Approved') {
                Boolean allApproved = true;
                for (SBQQ__QuoteLine__c quotLn : mapQuotes.get(ql.SBQQ__Quote__c).SBQQ__LineItems__r) {
                    if (quotLn.Id != ql.Id) {
                        allApproved = allApproved && quotLn.ApprovalStatus__c == 'Approved';
                    }
                }
                if (allApproved == true) {
                    if (!quotesToUpdate.containsKey(ql.SBQQ__Quote__c)) {
                        quotesToUpdate.put(ql.SBQQ__Quote__c, new SBQQ__Quote__c(Id = ql.SBQQ__Quote__c));
                    }
                    SBQQ__Quote__c quot = quotesToUpdate.get(ql.SBQQ__Quote__c);
                    quot.ApprovalStatus__c = 'Approved';
                }

                if (mapChildQuoteLines.containsKey(ql.Id)) {
                    for (Id childQL : mapChildQuoteLines.get(ql.Id)) {
                        quoteLineToUpdate.add(new SBQQ__QuoteLine__c(Id = childQL, ApprovalStatus__c = 'Approved'));
                    }
                }
            }

            if (ql.ApprovalStatus__c == 'Rejected' && oldMap.get(ql.Id).ApprovalStatus__c != 'Rejected') {
                
                if (mapChildQuoteLines.containsKey(ql.Id)) {
                    for (Id childQL : mapChildQuoteLines.get(ql.Id)) {
                        quoteLineToUpdate.add(new SBQQ__QuoteLine__c(Id = childQL, ApprovalStatus__c = 'Rejected'));
                    }
                }
            }
            if (ql.ApprovalStatus__c == 'Recalled' && oldMap.get(ql.Id).ApprovalStatus__c != 'Recalled') {
                //update the childQLs to Recalled as well
                if (mapChildQuoteLines.containsKey(ql.Id)) {
                    for (Id childQL : mapChildQuoteLines.get(ql.Id)) {
                        quoteLineToUpdate.add(new SBQQ__QuoteLine__c(Id = childQL, ApprovalStatus__c = 'Recalled'));
                    }
                }
            }
            
            if (ql.ApprovalStatus__c == 'Pending' && oldMap.get(ql.Id).ApprovalStatus__c != 'Pending') {
                if (!quotesToUpdate.containsKey(ql.SBQQ__Quote__c)) {
                    quotesToUpdate.put(ql.SBQQ__Quote__c, new SBQQ__Quote__c(Id = ql.SBQQ__Quote__c));
                }
                SBQQ__Quote__c quot = quotesToUpdate.get(ql.SBQQ__Quote__c);
                
                quot.SubmittedUser__c = ql.SubmittedUser__c;
                quot.SubmittedDate__c = ql.SubmittedDate__c;
                quot.ApprovalStatus__c = 'Pending';

                //update the childQLs to pending as well
                if (mapChildQuoteLines.containsKey(ql.Id)) {
                    for (Id childQL : mapChildQuoteLines.get(ql.Id)) {
                        quoteLineToUpdate.add(new SBQQ__QuoteLine__c(Id = childQL, ApprovalStatus__c = 'Pending'));
                    }
                }
                
            } 
        }

        if (!quotesToUpdate.isEmpty()) {
            //SBQQ.TriggerControl.disable();
            QuoteStatusUpdateQueueable quoteStatusUpdate = new QuoteStatusUpdateQueueable(quotesToUpdate.values());
            System.enqueueJob(quoteStatusUpdate);
            // SBQQ.TriggerControl.enable();
        }
        // if (!quoteToUpdateList.isEmpty()) {
        //     update quoteToUpdateList;
        // }
        // system.debug(quoteLineToUpdate.size());
        if (quoteLineToUpdate.size()>0 || !(quoteLineToUpdate.isEmpty())){
            QuoteLineStatusUpdateQueueable statusUpdate = new QuoteLineStatusUpdateQueueable(quoteLineToUpdate);
            System.enqueueJob(statusUpdate);
        }
        
        List<SBQQ__QuoteLine__c> quoteLinessToUpdate = new List<SBQQ__QuoteLine__c>();
        // Set<Id> quoteIds = new Set<Id>();
        // for (SBQQ__QuoteLine__c quoteLine : quoteLines) {
        //     quoteIds.add(quoteLine.SBQQ__Quote__c);
        // }

        Map<Id, SBQQ__Quote__c> quoteById = new Map<Id, SBQQ__Quote__c>([SELECT Id, SBQQ__Uncalculated__c FROM SBQQ__Quote__c WHERE Id IN :quoteIds]);

        for (SBQQ__QuoteLine__c quoteLine : quoteLines) {
            if (oldMap.get(quoteLine.Id).ApprovalStatus__c != 'Approved' && quoteLine.ApprovalStatus__c == 'Approved' /* && quoteLine.Status__c == 'Won'*/ && (quoteById.get(quoteLine.SBQQ__Quote__c).SBQQ__Uncalculated__c == false || Test.isRunningTest())) {
                quoteLinessToUpdate.add(quoteLine);
                system.debug('APPROVED QL >>>> '+ quoteLine);
            }
        }
        if(!quoteLinessToUpdate.isEmpty()) {
            validateAndSendApprovedQuoteLinesToSAP(quoteLinessToUpdate);
        }
    }
    
    public static void validateAndSendWonQuoteLinesToSAP(List<SBQQ__QuoteLine__c> quoteLines) {
        Integration_Endpoint__mdt mc = Integration_Endpoint__mdt.getInstance('Mulesoft_Pricing');
        if (mc == null) return;
        
        Set<Id> quoteIds = new Set<Id>();
        Map<Id, Set<Id>> quoteLineIdsByQuoteId = new Map<Id, Set<Id>>();
        for (SBQQ__QuoteLine__c quoteLine : quoteLines) {
            quoteIds.add(quoteLine.SBQQ__Quote__c);
            if(!quoteLineIdsByQuoteId.containsKey(quoteLine.SBQQ__Quote__c)) {
                quoteLineIdsByQuoteId.put(quoteLine.SBQQ__Quote__c, new Set<Id>());
            }
            quoteLineIdsByQuoteId.get(quoteLine.SBQQ__Quote__c).add(quoteLine.Id);
        }
        
        system.debug('PJ PJ PJ quoteLineIdsByQuoteId ::::: '+quoteLineIdsByQuoteId);

        if (!quoteLineIdsByQuoteId.isEmpty()) {
            System.enqueueJob(new QuoteLineWonQueueable(quoteLineIdsByQuoteId));
        }
        
        // 8/23/2022 - Removing Won Events as the driver for this and using queuable instead
        // List<Quote_Line_Won__e> quoteLineWonEvents = new List<Quote_Line_Won__e>();
        // for (Id quoteId : quoteIds) {
        //     Quote_Line_Won__e quoteLineWonEvent = new Quote_Line_Won__e();
        //     quoteLineWonEvent.Quote_Id__c = quoteId;
        //     quoteLineWonEvent.Quote_Line_Ids__c = String.join(new List<Id>( quoteLineIdsByQuoteId.get(quoteId)), ',');
        //     quoteLineWonEvents.add(quoteLineWonEvent);
        // }
        
        // if(!quoteLineWonEvents.isEmpty()) {
        //     List<Database.SaveResult> resList = EventBus.publish(quoteLineWonEvents);
        //     for (Database.SaveResult res : resList) {
        //         System.debug('validateAndSendWonQuoteLinesToSAP Publish Quote Line Won Events Success: ' + res.isSuccess());
        //         System.debug(res);
        //     }
        // } 
    }
        
 // * Called from onQuoteLineApproval method
    public static void validateAndSendApprovedQuoteLinesToSAP(List<SBQQ__QuoteLine__c> quoteLines) {
        Set<Id> quoteIds = new Set<Id>();

        Mulesoft_ContractEndpoint__c mc = Mulesoft_ContractEndpoint__c.getOrgDefaults();
        if (mc == null || mc.Contracted_Price_Request_Status__c == null) return;
        
        List<SBQQ__QuoteLine__c> filteredQuoteLines = new List<SBQQ__QuoteLine__c>();
        Map<Id, Set<Id>> quoteLineIdsByQuoteId = new Map<Id, Set<Id>>();
        for (SBQQ__QuoteLine__c quoteLine : quoteLines) {
            if (quoteLine.SentToSAP__c == false && quoteLine.Product_Level__c == 'GMID' && quoteLine.Source_Quote_Line__c == null) {
            //if (quoteLine.SentToSAP__c == false ) {
                quoteIds.add(quoteLine.SBQQ__Quote__c);
                filteredQuoteLines.add(quoteLine);
                if(!quoteLineIdsByQuoteId.containsKey(quoteLine.SBQQ__Quote__c)) {
                    quoteLineIdsByQuoteId.put(quoteLine.SBQQ__Quote__c, new Set<Id>());
                }
                quoteLineIdsByQuoteId.get(quoteLine.SBQQ__Quote__c).add(quoteLine.Id);
            }
        }

        List<SBQQ__QuoteLine__c> quoteLinesAccount = [ SELECT Id,
                                                    SBQQ__Quote__c,
                                                    SBQQ__Quote__r.SBQQ__Account__c
                                                FROM SBQQ__QuoteLine__c
                                                WHERE Id IN :filteredQuoteLines];

        if(quoteIds == null || quoteIds.isEmpty()) return;

        // Use the filtered Quote Line data to get our unique set of Quotes and build a Quote:Account map
        Set<Id> filteredQuotes = new Set<Id>();
        Map<Id, Id> quoteAccountMap = new Map<Id, Id>();
        for(SBQQ__QuoteLine__c ql : quoteLinesAccount) {  
            system.debug('YONG QL:::: ' + ql.Id);
            system.debug('YONG Quote:::: ' + ql.SBQQ__Quote__c);
            system.debug('YONG Quote NAME:::: ' + ql.SBQQ__Quote__r);
            system.debug('YONG SOLD TO ACCOUNT ID:::: ' + ql.SBQQ__Quote__r.SBQQ__Account__c);
            quoteAccountMap.put(ql.SBQQ__Quote__c, ql.SBQQ__Quote__r.SBQQ__Account__c);
            filteredQuotes.add(ql.SBQQ__Quote__c);
        }
        
        // Validate and collect the set of Quotes that use Ship To / Sold To
        Set<Id> validSoldToShipToQuotes = getValidSoldToShipToQuotes(quoteAccountMap);

        // Loop through filtered quotes and check if the Quote is in the valid set
        // Valid quotes are submitted individually to SAP
        // Invalid quotes are updated with an error message
        List<SBQQ__Quote__c> invalidQuotes = new List<SBQQ__Quote__c>();
        Map<Id, Decimal> versionMap = new Map<Id, Decimal>();
        for(SBQQ__Quote__c sbq :[SELECT Id, Price_Request_Version__c FROM SBQQ__Quote__c WHERE Id IN :filteredQuotes]){
            versionMap.put(sbq.Id, sbq.Price_Request_Version__c);
        }

        List<Quote_Line_Approval__e> quoteLineApprovalEvents = new List<Quote_Line_Approval__e>();
        for (Id quoteId : filteredQuotes) {
            if (validSoldToShipToQuotes.contains(quoteId)) {
                /*if (!System.isFuture() && !System.isBatch() && !System.isQueueable()) {
                    if(versionMap.get(quoteId)==1){
                        submitQuoteContract(quoteId, quoteLineIdsByQuoteId.get(quoteId), true);
                    }else{
                        submitQuoteContract(quoteId, quoteLineIdsByQuoteId.get(quoteId), false);
                    }
                }*/
                Quote_Line_Approval__e quoteLineApprovalEvent = new Quote_Line_Approval__e();
                quoteLineApprovalEvent.Quote_Id__c = quoteId;
                quoteLineApprovalEvent.Quote_Line_Ids__c = String.join(new List<Id>( quoteLineIdsByQuoteId.get(quoteId)), ',');
                quoteLineApprovalEvents.add(quoteLineApprovalEvent);
                // 12/20/2022 add debugs logs - bill joson
                system.debug('Validate Event>>>>>'+quoteLineApprovalEvent);
            }
            else {
                invalidQuotes.add(new SBQQ__Quote__c(Id = quoteId, Mulesoft_Debug__c = 'Quote is not using Ship / Sold to Account'));
            }
        }
        update invalidQuotes;
        if(!quoteLineApprovalEvents.isEmpty()) {
            EventBus.publish(quoteLineApprovalEvents);
        } 
    }
    

    public static Set<Id> getValidSoldToShipToQuotes(Map<Id,Id> quoteAccounts) {
        List<Account_Relationships__c> relationships = [SELECT Sold_To__c 
                                                     FROM Account_Relationships__c  
                                                     WHERE Sold_To__c IN: quoteAccounts.values() 
                                                     AND Relationship_Type__c = 'Sold To / Ship To'];
        
        Set<Id> validQuotes = new Set<Id>();
        for(Id quoteId : quoteAccounts.keySet()){
            for(Account_Relationships__c relationship : relationships){
                if(quoteAccounts.get(quoteId) == relationship.Sold_To__c){
                    validQuotes.add(quoteId);
                }
            } 
        }

        return validQuotes;
    }

    // Marc T (Simplus) - Prevents Deletion of records with Approval Status of Pending or Approved
    public static void beforeQuoteLinesDelete(Map<Id,SBQQ__QuoteLine__c> quoteMap) {
        List<SBQQ__QuoteLine__c> quoteLines = [SELECT Id, ApprovalStatus__c FROM SBQQ__QuoteLine__c WHERE Id IN :quoteMap.keySet()];
        for (SBQQ__QuoteLine__c ql : quoteLines) {
            if (ql.ApprovalStatus__c == 'Pending' || ql.ApprovalStatus__c == 'Approved') {
                SBQQ__QuoteLine__c quoteLine = quoteMap.get(ql.Id);
                quoteLine.addError('Products and Features with an Approval Status may not be deleted!');
            }
        }
    }
     public static void validateNewPrice(Map<Id,SBQQ__QuoteLine__c> newMap, Map<Id,SBQQ__QuoteLine__c> oldMap){
        //Boolean samePrice = true;
        Map<Id, SBQQ__QuoteLine__c> toCheckQuoteLines = new Map<Id, SBQQ__QuoteLine__c>();
        Set<Id> toCheckParentQuoteLineIdSet = new Set<Id>();
         for(SBQQ__QuoteLine__c ql : newMap.values()){
             if(ql.New_Delivered_Price__c != oldMap.get(ql.Id).New_Delivered_Price__c){
                 if(ql.SBQQ__RequiredBy__c == NULL){
                     if(!toCheckQuoteLines.containsKey(ql.Id)){
                         toCheckQuoteLines.put(ql.id, ql);
                     }
                 }else{
                     if(!toCheckQuoteLines.containsKey(ql.SBQQ__RequiredBy__c)){
                         toCheckParentQuoteLineIdSet.add(ql.SBQQ__RequiredBy__c);
                         //toCheckQuoteLines.put(ql.SBQQ__RequiredBy__c, new SBQQ__QuoteLine__c(Id = ql.SBQQ__RequiredBy__c, New_Delivered_Price__c = ql.SBQQ__RequiredBy__r.New_Delivered_Price__c));
                     }
                 }  
             }
         }
         for(SBQQ__QuoteLine__c prodLine : [SELECT Id, New_Delivered_Price__c FROM SBQQ__QuoteLine__c WHERE Id IN :toCheckParentQuoteLineIdSet]){
             if(!toCheckQuoteLines.containsKey(prodLine.Id)){
                 toCheckQuoteLines.put(prodLine.id, prodLine);
             }
         }
         system.debug('PJ PJ toCheckQuoteLines :: '+toCheckQuoteLines);
        Map<Id, SBQQ__QuoteLine__c> highestScaleParentMap = new Map<Id, SBQQ__QuoteLine__c>();
        for(SBQQ__QuoteLine__c scaleLine : [SELECT Id, SBQQ__Number__c,SBQQ__RequiredBy__c,New_Delivered_Price__c FROM SBQQ__QuoteLine__c WHERE SBQQ__RequiredBy__c IN : toCheckQuoteLines.keySet() AND Product_Level__c = 'Scale'  ORDER BY SBQQ__RequiredBy__c, Min_Volume__c desc]){
            if(!highestScaleParentMap.containsKey(scaleLine.SBQQ__RequiredBy__c)){
                highestScaleParentMap.put(scaleLine.SBQQ__RequiredBy__c, scaleLine);
            }
        }
         system.debug('PJ PJ highestScaleParentMap :: '+highestScaleParentMap);
        for(SBQQ__QuoteLine__c scale : toCheckQuoteLines.values()){
            if(highestScaleParentMap.get(scale.Id) != NULL){
                if(scale.New_Delivered_Price__c != highestScaleParentMap.get(scale.Id).New_Delivered_Price__c){
                   // samePrice = false;
                    if(newMap.get(scale.Id) != NULL){
                        newMap.get(scale.Id).New_Delivered_Price__c.addError('Product Quoteline and Highest Scale line item should have the same price.');
                    }else if(newMap.get(highestScaleParentMap.get(scale.Id).id) != NULL){
                        newMap.get(highestScaleParentMap.get(scale.Id).id).New_Delivered_Price__c.addError('Product Quoteline and Highest Scale line item should have the same price.');  
                    }
                    break;
                }
            }
        }
    }

    // TKT-304 Bill Joson (Simplus) 12/06/2023
    public static void populatePriceDates(Map<Id, SBQQ__QuoteLine__c> newMap, Map<Id, SBQQ__QuoteLine__c> oldMap) {
        for (SBQQ__QuoteLine__c ql : newMap.values()) {
            SBQQ__QuoteLine__c oldQL = oldMap.get(ql.Id);
            if (oldQL != null && ql.Price_Firm_Date__c != oldQL.Price_Firm_Date__c) {
                // Price_Firm_Date__c has been updated, so set Prior_Expiration_Date__c to the old value of Price_Firm_Date__c
                ql.Prior_Expiration_Date__c = oldQL.Price_Firm_Date__c;
            }
        }
    }
}