/**
 * @description       : 
 * @author            : Arun Mudaliar
 * @group             : 
 * @last modified on  : 11-01-2021
 * @last modified by  : Arun Mudaliar
**/
public class QuoteCloningService {

    public static void cloneAsync(Set<Id> quoteIds, Set<Id> quoteLineIds) {
        String quoteLineSubQuery = 'SELECT Id, SBQQ__Quote__r.SBQQ__Opportunity2__r.OriginalOpportunity__c, CUPS_Eligible__c, New_Price_Start_Date__c, CUPS_End_User__c, CUPS_Support_Price__c, New_CUPS_Support_Price__c, CUPS_Start_Date__c, CUPS_End_Date__c, CUPS_Discount_Percent__c, New_Price_Firm_Date__c, New_Delivered_Price__c,'
                       				+ 'CUPS_End_User2__c, CUPS_End_User3__c, CUPS_End_User4__c, CUPS_Support_Price2__c, CUPS_Support_Price3__c, CUPS_Support_Price4__c, CUPS_Start_Date2__c, CUPS_Start_Date3__c, CUPS_Start_Date4__c, CUPS_End_Date2__c, CUPS_End_Date3__c, CUPS_End_Date4__c, '
            						+ 'CUPS_Discount_Percent2__c, CUPS_Discount_Percent3__c,CUPS_Discount_Percent4__c, New_CUPS_Support_Price2__c, New_CUPS_Support_Price3__c, New_CUPS_Support_Price4__c, New_CUPS_Start_Date__c, New_CUPS_Start_Date2__c, New_CUPS_Start_Date3__c, New_CUPS_Start_Date4__c,'
            						+ 'New_CUPS_End_Date__c, New_CUPS_End_Date2__c, New_CUPS_End_Date3__c, New_CUPS_End_Date4__c, Competitive_Manufacturer__c, Competitive_Price__c, Competitor_Product__c, Competitive_Distributor__c, '
                                    + 'New_Competitive_Manufacturer__c, New_Competitive_Price__c, New_Competitor_Product__c, New_Competitor__c, ApprovalStatus__c, SBQQ__RequiredBy__c, Status__c, SBQQ__PricebookEntryId__c, SBQQ__ProductSubscriptionType__c, SBQQ__SubscriptionType__c, Base_UOM__c, PH3__c, '  
                                    + UtilityClass.getFieldSetSoqlString('MassPricing', 'SBQQ__QuoteLine__c') 
                                    + ' FROM SBQQ__LineItems__r';
        String quoteQuery = 'SELECT Id, Original_Price_Request__c, Price_Request_Version__c, ' 
                                + UtilityClass.getFieldSetSoqlString('MassPricing', 'SBQQ__Quote__c') 
                                + ', '
                                + '(' + quoteLineSubQuery + ')'
                                + ' FROM SBQQ__Quote__c WHERE Id IN :quoteIds';
        List<SBQQ__Quote__c> origQuotes = Database.query(quoteQuery);
        Map<Id, SBQQ__Quote__c> mapOrigQuoteToClonedQuote = new Map<Id, SBQQ__Quote__c>();
        
        for (SBQQ__Quote__c quot : origQuotes) {
            mapOrigQuoteToClonedQuote.put(quot.Id, QuoteCloningService.cloneQuote(quot));
        }
        
        insert mapOrigQuoteToClonedQuote.values();
        
        List<Set<Id>> quoteLineIdList = new List<Set<Id>>();
        for(Id quoteLineId : quoteLineIds) {
            quoteLineIdList.add(new Set<Id> {quoteLineId});
        }
        
        List<SBQQ__Quote__c> forceRecalculateQuotes = new List<SBQQ__Quote__c>();
        for (SBQQ__Quote__c quot : mapOrigQuoteToClonedQuote.values()) {
            quot.SBQQ__Primary__c = true;
            quot.ForceRecalculate__c = DateTime.now();
            forceRecalculateQuotes.add(quot);
        }
        update forceRecalculateQuotes;
        
       /* CloneServiceAsync asyncService = new CloneServiceAsync();
        asyncService.origQuotes = origQuotes;
        asyncService.mapOrigQuoteToClonedQuote = mapOrigQuoteToClonedQuote;
        asyncService.quoteLineIdList = quoteLineIdList;
                
        if(!quoteLineIdList.isEmpty()) {
        
            TKT-102
            System.enqueueJob(asyncService);
            
        }*/
    }
    //Commented out by Simplus because Line 53, the actual enqueueing of the Job was Commented out
   /* public class CloneServiceAsync implements Queueable {
        
        List<SBQQ__Quote__c> origQuotes = new List<SBQQ__Quote__c> ();
        Map<Id, SBQQ__Quote__c> mapOrigQuoteToClonedQuote = new Map<Id, SBQQ__Quote__c>();
        List<Set<Id>> quoteLineIdList = new List<Set<Id>>();

        Id defaultQlRtId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByDeveloperName().get('Quote_Lines').getRecordTypeId();
        
       // public CloneServiceAsync() {}
        
       public void execute(QueueableContext context) {
            Set<Id> quoteLineIds = quoteLineIdList.get(0);
            Map<Id, SBQQ__QuoteLine__c> mapOrigQuoteLineToClonedQuoteLine = new Map<Id, SBQQ__QuoteLine__c>();
            List<SBQQ__QuoteLine__c> updateOrigQuoteLines = new List<SBQQ__QuoteLine__c>();
            
            for (SBQQ__Quote__c quot : origQuotes) {    
                for (SBQQ__QuoteLine__c quoteLn : quot.SBQQ__LineItems__r) {
                    // Marc T (Simplus) - Do NOT Clone when RequiredBy is set, this is handled in the QuoteLineTrigger_Handler.onCloneQuoteLineInsert!
                    if(quoteLineIds.contains(quoteLn.Id) && quoteLn.SBQQ__RequiredBy__c == null) {
                        SBQQ__QuoteLine__c clonedQuoteLn = QuoteCloningService.cloneQuoteLine(quoteLn, quoteLineIds.contains(quoteLn.Id));
                        if (quoteLineIds.contains(quoteLn.Id)) {
                            clonedQuoteLn.RecordTypeId = defaultQlRtId;
                        }
                        updateOrigQuoteLines.add(new SBQQ__QuoteLine__c(Id = quoteLn.Id, Price_Status__c = 'Cloned'));
                        mapOrigQuoteLineToClonedQuoteLine.put(quoteLn.Id, clonedQuoteLn);
                    }
                }
            }
               
            for (SBQQ__Quote__c quot : origQuotes) {
                SBQQ__Quote__c clonedQuote = mapOrigQuoteToClonedQuote.get(quot.Id);
                for (SBQQ__QuoteLine__c quoteLn : quot.SBQQ__LineItems__r) {
                    if(mapOrigQuoteLineToClonedQuoteLine.containsKey(quoteLn.Id)) {
                        SBQQ__QuoteLine__c clonedQuoteLn = mapOrigQuoteLineToClonedQuoteLine.get(quoteLn.Id);
                        clonedQuoteLn.SBQQ__Quote__c = clonedQuote.Id;
                        if(quoteLn.Status__c == 'Won') {
                            clonedQuoteLn.Status__c = 'Negotiation';
                        }
                    }
                }
            }
            
            SBQQ.TriggerControl.disable();
            insert mapOrigQuoteLineToClonedQuoteLine.values(); */
            
            /*TKT-102
            try{*/
            
               // update updateOrigQuoteLines;
            
            /*TKT-102
            }
            catch(Exception e){
            }*/
            
            //Clone Contract Number Mapping & add it related to the cloned quote 
            /*Map<Id, List<Contract_Number_Mapping__c>> quoteContractNumberMap = new Map<Id, List<Contract_Number_Mapping__c>>();
            List<Contract_Number_Mapping__c> contractNumberMappingList = [SELECT Id,Original_Quote__c, Name, Originating_Contract_Number__c, Last_SAP_POSEX_Number__c, Quote_Line__c,Related_Sold_To__c,SAP_Contract_Number__c,
                                                                            SFDC_Contract_Id__c,
                                                                            SFDC_Contract_Key__c,
                                                                            Ship_To__c,
                                                                            Ship_To_Code__c,
                                                                            Shipping_Condition__c,
                                                                            Incoterm__c
                                                                    FROM Contract_Number_Mapping__c 
                                                                    WHERE Original_Quote__c IN: origQuotes];
            for (Contract_Number_Mapping__c cnm : contractNumberMappingList) {
                if (!quoteContractNumberMap.containsKey(cnm.Original_Quote__c)) {
                    quoteContractNumberMap.put(cnm.Original_Quote__c, new List<Contract_Number_Mapping__c>());
                }
                quoteContractNumberMap.get(cnm.Original_Quote__c).add(cnm);
            }
    
            if (!quoteContractNumberMap.isEmpty()) {
                cloneContractNumberMapping(quoteContractNumberMap, mapOrigQuoteToClonedQuote);
            }
            SBQQ.TriggerControl.enable();
    
            insertPMA(mapOrigQuoteLineToClonedQuoteLine.values());
            // for( SBQQ__QuoteLine__c ql : mapOrigQuoteLineToClonedQuoteLine.values()){
            //     try {
            //         SBAA.ApprovalAPI.submit(ql.Id, SBAA__Approval__c.Quote_Line__c);
            //     }
            //     catch (Exception e) {
            //         system.debug('ERROR MESSAGE ::: '+e.getMessage());
                    
            //     }
            // }
            quoteLineIdList.remove(0);
            if(quoteLineIdList != null && !quoteLineIdList.isEmpty()) {
                CloneServiceAsync asyncService = new CloneServiceAsync();
                asyncService.origQuotes = origQuotes;
                asyncService.mapOrigQuoteToClonedQuote = mapOrigQuoteToClonedQuote;
                asyncService.quoteLineIdList = quoteLineIdList;
                
                System.enqueueJob(asyncService); 
            }
        }
        
    }*/

    
    public static Set<Id> clone(Set<Id> quoteIds, Set<Id> quoteLineIds, Boolean doSubmit) {
        String quoteLineSubQuery = 'SELECT Id, SBQQ__Quote__r.SBQQ__Opportunity2__r.OriginalOpportunity__c, New_Price_Start_Date__c, CUPS_Eligible__c, CUPS_End_User__c, CUPS_Support_Price__c, New_CUPS_Support_Price__c, New_CUPS_Support_Price2__c, New_CUPS_Support_Price3__c, New_CUPS_Support_Price4__c, New_CUPS_Start_Date__c, New_CUPS_Start_Date2__c, New_CUPS_Start_Date3__c, New_CUPS_Start_Date4__c, New_CUPS_End_Date__c, New_CUPS_End_Date2__c, New_CUPS_End_Date3__c, New_CUPS_End_Date4__c, CUPS_Start_Date__c, CUPS_End_Date__c, CUPS_Discount_Percent__c, New_Price_Firm_Date__c, New_Delivered_Price__c,'
            						+ 'CUPS_End_User2__c, CUPS_End_User3__c, CUPS_End_User4__c, CUPS_Support_Price2__c, CUPS_Support_Price3__c, CUPS_Support_Price4__c, CUPS_Start_Date2__c, CUPS_Start_Date3__c, CUPS_Start_Date4__c, CUPS_End_Date2__c, CUPS_End_Date3__c, CUPS_End_Date4__c, '
            						+ 'CUPS_Discount_Percent2__c, CUPS_Discount_Percent3__c,CUPS_Discount_Percent4__c, Competitive_Manufacturer__c, Competitive_Price__c, Competitor_Product__c, Competitive_Distributor__c, Price_Start_Date__c, Price_Firm_Date__c, '
                                    + 'New_Competitive_Manufacturer__c, New_Competitive_Price__c, New_Competitor_Product__c, New_Competitor__c, ApprovalStatus__c, SBQQ__RequiredBy__c, Status__c, SBQQ__PricebookEntryId__c, SBQQ__ProductSubscriptionType__c, SBQQ__SubscriptionType__c, Base_UOM__c, PH3__c, ' 
                                    + UtilityClass.getFieldSetSoqlString('MassPricing', 'SBQQ__QuoteLine__c') 
                                    + ' FROM SBQQ__LineItems__r';
        String quoteQuery = 'SELECT Id, Original_Price_Request__c, Price_Request_Version__c, ' 
                                + UtilityClass.getFieldSetSoqlString('MassPricing', 'SBQQ__Quote__c') 
                                + ', '
                                + '(' + quoteLineSubQuery + ')'
                                + ' FROM SBQQ__Quote__c WHERE Id IN :quoteIds';
        List<SBQQ__Quote__c> origQuotes = Database.query(quoteQuery);
        Map<Id, SBQQ__Quote__c> mapOrigQuoteToClonedQuote = new Map<Id, SBQQ__Quote__c>();
        Map<Id, SBQQ__QuoteLine__c> mapOrigQuoteLineToClonedQuoteLine = new Map<Id, SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> updateOrigQuoteLines = new List<SBQQ__QuoteLine__c>();
        Id defaultQlRtId = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByDeveloperName().get('Quote_Lines').getRecordTypeId();
        
        for (SBQQ__Quote__c quot : origQuotes) {
            mapOrigQuoteToClonedQuote.put(quot.Id, QuoteCloningService.cloneQuote(quot));

            for (SBQQ__QuoteLine__c quoteLn : quot.SBQQ__LineItems__r) {
                // Marc T (Simplus) - Do NOT Clone when RequiredBy is set, this is handled in the QuoteLineTrigger_Handler.onCloneQuoteLineInsert!
                if(quoteLineIds.contains(quoteLn.Id) && quoteLn.SBQQ__RequiredBy__c == null) {
                    SBQQ__QuoteLine__c clonedQuoteLn = QuoteCloningService.cloneQuoteLine(quoteLn, quoteLineIds.contains(quoteLn.Id));
                    if (quoteLineIds.contains(quoteLn.Id)) {
                        clonedQuoteLn.SubmitForApproval__c = doSubmit;
                        clonedQuoteLn.RecordTypeId = defaultQlRtId;
                    }
                    updateOrigQuoteLines.add(new SBQQ__QuoteLine__c(Id = quoteLn.Id, Price_Status__c = doSubmit ? 'Cloned & Submitted' : 'Cloned'));
                    mapOrigQuoteLineToClonedQuoteLine.put(quoteLn.Id, clonedQuoteLn);
                }
            }
        }

        //SBQQ.TriggerControl.disable();
        insert mapOrigQuoteToClonedQuote.values();
       
        for (SBQQ__Quote__c quot : origQuotes) {
            SBQQ__Quote__c clonedQuote = mapOrigQuoteToClonedQuote.get(quot.Id);
            for (SBQQ__QuoteLine__c quoteLn : quot.SBQQ__LineItems__r) {
                if(mapOrigQuoteLineToClonedQuoteLine.containsKey(quoteLn.Id)) {
                    SBQQ__QuoteLine__c clonedQuoteLn = mapOrigQuoteLineToClonedQuoteLine.get(quoteLn.Id);
                    clonedQuoteLn.SBQQ__Quote__c = clonedQuote.Id;
                    clonedQuoteLn.Status__c = 'Negotiation';
                    //clonedQuoteLn.SBQQ__Source__c = quoteLn.Id;
                }
            }
        }
        insert mapOrigQuoteLineToClonedQuoteLine.values();
        update updateOrigQuoteLines;
        
        //Clone Contract Number Mapping & add it related to the cloned quote 
        // List<Contract_Number_Mapping__c> contractNumberMappingList = new List<Contract_Number_Mapping__c>(); //List for Contract_Number_Mapping__c
        // contractNumberMappingList = [SELECT Id,Original_Quote__c, Name, Originating_Contract_Number__c, Last_SAP_POSEX_Number__c, Quote_Line__c,Related_Sold_To__c,SAP_Contract_Number__c,
        //                                  SFDC_Contract_Id__c,
        //                                  SFDC_Contract_Key__c,
        //                                  Ship_To__c,
        //                                  Ship_To_Code__c,
        //                                  Shipping_Condition__c,
        //                                  Incoterm__c
        //                                  FROM Contract_Number_Mapping__c 
        //                                  WHERE Original_Quote__c IN: origQuotes]; //Query Contract_Number_Mapping__c from Original Quote

        Map<Id, List<Contract_Number_Mapping__c>> quoteContractNumberMap = new Map<Id, List<Contract_Number_Mapping__c>>();
        
        List<Contract_Number_Mapping__c> contractNumberMappingList = [SELECT Id,Original_Quote__c, Name, Originating_Contract_Number__c, Last_SAP_POSEX_Number__c, Quote_Line__c,Related_Sold_To__c,SAP_Contract_Number__c,
                                                                        SFDC_Contract_Id__c,
                                                                        SFDC_Contract_Key__c,
                                                                        Ship_To__c,
                                                                        Ship_To_Code__c,
                                                                        Shipping_Condition__c,
                                                                        Incoterm__c
                                                                FROM Contract_Number_Mapping__c 
                                                                WHERE Original_Quote__c IN: origQuotes];
        for (Contract_Number_Mapping__c cnm : contractNumberMappingList) {
            if (!quoteContractNumberMap.containsKey(cnm.Original_Quote__c)) {
                quoteContractNumberMap.put(cnm.Original_Quote__c, new List<Contract_Number_Mapping__c>());
            }
            quoteContractNumberMap.get(cnm.Original_Quote__c).add(cnm);
        }

        if (!quoteContractNumberMap.isEmpty()) {
            cloneContractNumberMapping(quoteContractNumberMap, mapOrigQuoteToClonedQuote);
        }

        insertPMA(mapOrigQuoteLineToClonedQuoteLine.values());
        
        List<SBQQ__Quote__c> forceRecalculateQuotes = new List<SBQQ__Quote__c>();
        for (SBQQ__Quote__c quot : mapOrigQuoteToClonedQuote.values()) {
            quot.SBQQ__Primary__c = true;
            quot.ForceRecalculate__c = DateTime.now();
            forceRecalculateQuotes.add(quot);
        }
        update forceRecalculateQuotes;

        //System.enqueueJob(new ApprovalSubmitQueueable(UtilityClass.getListRecordIds(mapOrigQuoteLineToClonedQuoteLine.values()))); 
        return UtilityClass.getListRecordIds(mapOrigQuoteLineToClonedQuoteLine.values());
    }

    private static SBQQ__Quote__c cloneQuote(SBQQ__Quote__c aQuote) {
        SObject quot = Schema.getGlobalDescribe().get('SBQQ__Quote__c').newSObject();

        for (String fieldApiName : UtilityClass.getEditableFieldApiNames('MassPricing', 'SBQQ__Quote__c').keySet()) {
            quot.put(fieldApiName, aQuote.get(fieldApiName));
        }
        quot.put('Original_Price_Request__c', aQuote.Original_Price_Request__c == null ? aQuote.Id : aQuote.Original_Price_Request__c);
        quot.put('Price_Request_Version__c', aQuote.Price_Request_Version__c + 1);
        quot.put('Price_Start_Date__c', getPriceStartDate(aQuote));
        quot.put('Cloned_From_Mulesoft__c', true);
        quot.put('SBQQ__Source__c', aQuote.Id);
        quot.put('ApprovalStatus__c', null);

        return (SBQQ__Quote__c) quot;
    }

    public static SBQQ__QuoteLine__c cloneQuoteLine(SBQQ__QuoteLine__c aQuoteLine, Boolean doGenerateNewValues) {
        SObject ql = Schema.getGlobalDescribe().get('SBQQ__QuoteLine__c').newSObject();

        for (String fieldApiName : UtilityClass.getEditableFieldApiNames('MassPricing', 'SBQQ__QuoteLine__c').keySet()) {
            ql.put(fieldApiName, aQuoteLine.get(fieldApiName));
        }
        ql.put('SBQQ__Source__c', aQuoteLine.Id);
        ql.put('Source_Quote_Line__c', aQuoteLine.Id);
        ql.put('ApprovalStatus__c', null);
        ql.put('SubmitForApproval__c', false);
        ql.put('PosexNo__c', aQuoteLine.PosexNo__c);
        if (doGenerateNewValues) {
            ql.put('New_Delivered_Price__c', null);

            //Bill 10/19 - Missing Date Fields
            // ql.put('New_Price_Start_Date__c', null);
            // ql.put('New_Price_Firm_Date__c', null);
            ql.put('New_Price_Start_Date__c', aQuoteLine.New_Price_Start_Date__c);
            ql.put('New_Price_Firm_Date__c', aQuoteLine.New_Price_Firm_Date__c);
            ql.put('Prior_Start_Date__c', aQuoteLine.Price_Start_Date__c);
            ql.put('Prior_Expiration_Date__c', aQuoteLine.Price_Firm_Date__c);
            //Bill 10/19

            ql.put('SBQQ__ListPrice__c', aQuoteLine.New_Delivered_Price__c != null ? aQuoteLine.New_Delivered_Price__c : aQuoteLine.SBQQ__ListPrice__c);
			ql.put('Competitive_Manufacturer__c', aQuoteLine.New_Competitive_Manufacturer__c != null ? aQuoteLine.New_Competitive_Manufacturer__c : aQuoteLine.Competitive_Manufacturer__c);
			ql.put('Competitive_Price__c', aQuoteLine.New_Competitive_Price__c != null ? aQuoteLine.New_Competitive_Price__c : aQuoteLine.Competitive_Price__c);
			ql.put('Competitor_Product__c', aQuoteLine.New_Competitor_Product__c != null ? aQuoteLine.New_Competitor_Product__c : aQuoteLine.Competitor_Product__c);
			ql.put('Competitive_Distributor__c', aQuoteLine.New_Competitor__c != null ? aQuoteLine.New_Competitor__c : aQuoteLine.Competitive_Distributor__c);
            ql.put('Price_Firm_Date__c', aQuoteLine.New_Price_Firm_Date__c);
            ql.put('Price_Start_Date__c', aQuoteLine.New_Price_Start_Date__c);
            ql.put('CUPS_End_User__c', aQuoteLine.CUPS_End_User__c);
            ql.put('CUPS_End_User2__c', aQuoteLine.CUPS_End_User2__c);
            ql.put('CUPS_End_User3__c', aQuoteLine.CUPS_End_User3__c);
            ql.put('CUPS_End_User4__c', aQuoteLine.CUPS_End_User4__c);
			ql.put('CUPS_Support_Price__c', aQuoteLine.New_CUPS_Support_Price__c != null ? aQuoteLine.New_CUPS_Support_Price__c : aQuoteLine.CUPS_Support_Price__c);
            ql.put('CUPS_Support_Price2__c', aQuoteLine.New_CUPS_Support_Price2__c != null ? aQuoteLine.New_CUPS_Support_Price2__c : aQuoteLine.CUPS_Support_Price2__c);
			ql.put('CUPS_Support_Price3__c', aQuoteLine.New_CUPS_Support_Price3__c != null ? aQuoteLine.New_CUPS_Support_Price3__c : aQuoteLine.CUPS_Support_Price3__c);
			ql.put('CUPS_Support_Price4__c', aQuoteLine.New_CUPS_Support_Price4__c != null ? aQuoteLine.New_CUPS_Support_Price4__c : aQuoteLine.CUPS_Support_Price4__c);
            ql.put('CUPS_Start_Date__c', aQuoteLine.New_CUPS_Start_Date__c != null ? aQuoteLine.New_CUPS_Start_Date__c : aQuoteLine.CUPS_Start_Date__c);
            ql.put('CUPS_Start_Date2__c', aQuoteLine.New_CUPS_Start_Date2__c != null ? aQuoteLine.New_CUPS_Start_Date2__c : aQuoteLine.CUPS_Start_Date2__c);
            ql.put('CUPS_Start_Date3__c', aQuoteLine.New_CUPS_Start_Date3__c != null ? aQuoteLine.New_CUPS_Start_Date3__c : aQuoteLine.CUPS_Start_Date3__c);
            ql.put('CUPS_Start_Date4__c', aQuoteLine.New_CUPS_Start_Date4__c != null ? aQuoteLine.New_CUPS_Start_Date4__c : aQuoteLine.CUPS_Start_Date4__c);
			ql.put('CUPS_End_Date__c', aQuoteLine.New_CUPS_End_Date__c != null ? aQuoteLine.New_CUPS_End_Date__c : aQuoteLine.CUPS_End_Date__c);
            ql.put('CUPS_End_Date2__c', aQuoteLine.New_CUPS_End_Date2__c != null ? aQuoteLine.New_CUPS_End_Date2__c : aQuoteLine.CUPS_End_Date2__c);
			ql.put('CUPS_End_Date3__c', aQuoteLine.New_CUPS_End_Date3__c != null ? aQuoteLine.New_CUPS_End_Date3__c : aQuoteLine.CUPS_End_Date3__c);
			ql.put('CUPS_End_Date4__c', aQuoteLine.New_CUPS_End_Date4__c != null ? aQuoteLine.New_CUPS_End_Date4__c : aQuoteLine.CUPS_End_Date4__c);
            ql.put('CUPS_Discount_Percent__c', aQuoteLine.CUPS_Discount_Percent__c);
            ql.put('CUPS_Discount_Percent2__c', aQuoteLine.CUPS_Discount_Percent2__c);
            ql.put('CUPS_Discount_Percent3__c', aQuoteLine.CUPS_Discount_Percent3__c);
            ql.put('CUPS_Discount_Percent4__c', aQuoteLine.CUPS_Discount_Percent4__c);
            ql.put('CUPS_Eligible__c', aQuoteLine.CUPS_Eligible__c);
            //TKT-143 - Start 
            ql.put('Adder_Type__c', aQuoteLine.Adder_Type__c);
            ql.put('Display_Options__c', aQuoteLine.Display_Options__c);
            ql.put('Shipping_Condition__c', aQuoteLine.Shipping_Condition__c);
            ql.put('Display_Price__c', aQuoteLine.Display_Price__c);
            ql.put('Display_Price_Decimal__c', aQuoteLine.Display_Price_Decimal__c);
            ql.put('Display_Price_Whole_Numbers__c', aQuoteLine.Display_Price_Whole_Numbers__c); 

            ql.put('Min_Volume__c', aQuoteLine.Min_Volume__c);
            ql.put('Scale_UOM__c', aQuoteLine.Scale_UOM__c);
            ql.put('SBQQ__PricebookEntryId__c', aQuoteLine.SBQQ__PricebookEntryId__c);
            ql.put('SBQQ__ProductSubscriptionType__c', aQuoteLine.SBQQ__ProductSubscriptionType__c);
            ql.put('SBQQ__SubscriptionType__c', aQuoteLine.SBQQ__SubscriptionType__c);
            ql.put('Base_UOM__c', aQuoteLine.Base_UOM__c);
            ql.put('PH3__c', aQuoteLine.PH3__c);
            //TKT-143 - End
        }

        return (SBQQ__QuoteLine__c) ql;
    }

    public static void cloneContractNumberMapping(Map<Id,List<Contract_Number_Mapping__c>> contractNumberMappingList, Map<Id, SBQQ__Quote__c> mapOrigAndClonedQuote)
    {
        system.debug('Inside Contact Number Mapping');
        List<Contract_Number_Mapping__c> cloneList = new List<Contract_Number_Mapping__c>(); // List for Clone Contract_Number_Mapping__c
        for(Id CNMId : contractNumberMappingList.keySet()) // Iterating the List
        {   
            for(Contract_Number_Mapping__c CNM : contractNumberMappingList.get(CNMId)) // Iterating the List
            {
                CNM.Original_Quote__c = mapOrigAndClonedQuote.get(CNMId).Id;
                Contract_Number_Mapping__c cnmClone  = CNM.clone(false, false, false, false);
                cloneList.add(cnmClone); // adding new Cloned Contract_Number_Mapping__c to the List
            }
        }
        System.debug('Clone List :- '+cloneList); 
        if(!cloneList.isEmpty())
        {
            insert cloneList; // Inserting Cloned Contract_Number_Mapping__c
        }
        // for(Contract_Number_Mapping__c CNMcloneObj : cloneList) {
        //    CNMcloneObj.Original_Quote__c = clonedQuoteId; //Passing ClonedQuote Id to the Original_Quote__c field of Contract_Number_Mapping__c
        //     cloneListtoUpdate.add(CNMcloneObj);
        // }
        // if(!cloneListtoUpdate.isEmpty())
        // {
        //     update cloneListtoUpdate; // Update Cloned Contract_Number_Mapping__c to add cloned Quote reference
        // }
        
    }
    
    private static Date getPriceStartDate(SBQQ__Quote__c aQuote) {
        SBQQ__QuoteLine__c aQuoteLine;
        for (SBQQ__QuoteLine__c ql : aQuote.SBQQ__LineItems__r) {
            if (ql.New_Price_Start_Date__c != null) {
                return ql.New_Price_Start_Date__c;
            }
        }
        return null;
    }

    public static void insertPMA(List<SBQQ__QuoteLine__c> lstQuoteLine){
        List<Price_Movement_Audit__c> pmaInsertList = new List<Price_Movement_Audit__c>();
        for(SBQQ__QuoteLine__c ql : [SELECT Id,
                                        CreatedById,
                                        Source_Quote_Line__c, 
                                        SBQQ__Quote__c, 
                                        SBQQ__Quote__r.SBQQ__Source__c,
                                        SBQQ__Quote__r.SBQQ__Source__r.SBQQ__SalesRep__c,
                                        SBQQ__Quote__r.SBQQ__Source__r.Submitted_By__c,
                                        SBQQ__Quote__r.Cloned_From_Mulesoft__c,
                                        Source_Quote_Line__r.SBQQ__ListPrice__c,
                                        Source_Quote_Line__r.New_Delivered_Price__c,
                                        Source_Quote_Line__r.Price_Start_Date__c,
                                        Source_Quote_Line__r.Price_Firm_Date__c,
                                        Source_Quote_Line__r.New_Price_Start_Date__c,
                                        Source_Quote_Line__r.New_Price_Firm_Date__c,
                                        Source_Quote_Line__r.CurrencyIsoCode,
                                        Source_Quote_Line__r.End_Use_Customer__c,
                                        Source_Quote_Line__r.Support_Discount__c,
                                        Source_Quote_Line__r.Support_Price__c,
                                        Source_Quote_Line__r.Competitive_Distributor__c,
                                        Source_Quote_Line__r.Competitive_Manufacturer__c,
                                        Source_Quote_Line__r.Competitive_Price__c,
                                        Source_Quote_Line__r.Competitor_Product__c,
                                        Source_Quote_Line__r.New_Competitor__c,
                                        Source_Quote_Line__r.New_Competitive_Manufacturer__c,
                                        Source_Quote_Line__r.New_Competitive_Price__c,
                                        Source_Quote_Line__r.New_Competitor_Product__c,
                                        Source_Quote_Line__r.CUPS_Support_Price__c,
                                        Source_Quote_Line__r.CUPS_Start_Date__c,
                                        Source_Quote_Line__r.CUPS_End_Date__c,
                                        Source_Quote_Line__r.New_CUPS_Support_Price__c,
                                        Source_Quote_Line__r.New_CUPS_Start_Date__c,
                                        Source_Quote_Line__r.New_CUPS_End_Date__c,
                                        Source_Quote_Line__r.CUPS_Eligible__c
                                            FROM SBQQ__QuoteLine__c
                                            WHERE Source_Quote_Line__c IN :lstQuoteLine]){
            Price_Movement_Audit__c pma = new Price_Movement_Audit__c();
            pma.Price__c = ql.Source_Quote_Line__r.SBQQ__ListPrice__c;
            pma.New_Price__c = ql.Source_Quote_Line__r.New_Delivered_Price__c != null ? ql.Source_Quote_Line__r.New_Delivered_Price__c : ql.Source_Quote_Line__r.SBQQ__ListPrice__c;
            pma.Price_Start_Date__c = ql.Source_Quote_Line__r.Price_Start_Date__c;
            pma.Price_Expiration_Date__c = ql.Source_Quote_Line__r.Price_Firm_Date__c;
            pma.New_Price_Start_Date__c = ql.Source_Quote_Line__r.New_Price_Start_Date__c != null ? ql.Source_Quote_Line__r.New_Price_Start_Date__c : pma.New_Price_Start_Date__c;
            pma.New_Price_Expiration_Date__c = ql.Source_Quote_Line__r.New_Price_Firm_Date__c != null ? ql.Source_Quote_Line__r.New_Price_Firm_Date__c : pma.New_Price_Expiration_Date__c;
            pma.Quote_Line__c = ql.Source_Quote_Line__c;
            pma.Price_Request__c = ql.SBQQ__Quote__r.SBQQ__Source__c;
            pma.Cloned_Quote_Line__c = ql.Id;
            pma.Cloned_Price_Request__c = ql.SBQQ__Quote__c;
            pma.Sales_Rep__c = ql.SBQQ__Quote__r.SBQQ__Source__r.SBQQ__SalesRep__c != null ? ql.SBQQ__Quote__r.SBQQ__Source__r.SBQQ__SalesRep__c : pma.Sales_Rep__c;
            pma.Submitted_By__c = UserInfo.getUserId();
            pma.CurrencyIsoCode = ql.Source_Quote_Line__r.CurrencyIsoCode;
            pma.Price_Movement_Date__c = Datetime.now();

            pma.End_Use_Customer__c = ql.Source_Quote_Line__r.End_Use_Customer__c;
            pma.Support_Discount__c = ql.Source_Quote_Line__r.Support_Discount__c;
            pma.Support_Price__c = ql.Source_Quote_Line__r.Support_Price__c;
            pma.Competitive_Distributor__c = ql.Source_Quote_Line__r.Competitive_Distributor__c;
            pma.Competitive_Manufacturer__c = ql.Source_Quote_Line__r.Competitive_Manufacturer__c;
            pma.Competitive_Price__c = ql.Source_Quote_Line__r.Competitive_Price__c;
            pma.Competitive_Product_2__c = ql.Source_Quote_Line__r.Competitor_Product__c;
            pma.New_Competitive_Distributor__c = ql.Source_Quote_Line__r.New_Competitor__c;
            pma.New_Competitive_Manufacturer__c = ql.Source_Quote_Line__r.New_Competitive_Manufacturer__c;
            pma.New_Competitive_Price__c = ql.Source_Quote_Line__r.New_Competitive_Price__c;
            pma.New_Competitive_Product_2__c = ql.Source_Quote_Line__r.New_Competitor_Product__c;
            pma.CUPS_Support_Price__c = ql.Source_Quote_Line__r.CUPS_Support_Price__c;
            pma.CUPS_Start_Date__c = ql.Source_Quote_Line__r.CUPS_Start_Date__c;
            pma.CUPS_End_Date__c = ql.Source_Quote_Line__r.CUPS_End_Date__c;
            pma.New_CUPS_Support_Price__c = ql.Source_Quote_Line__r.New_CUPS_Support_Price__c;
            pma.New_CUPS_Start_Date__c = ql.Source_Quote_Line__r.New_CUPS_Start_Date__c;
            pma.New_CUPS_End_Date__c = ql.Source_Quote_Line__r.New_CUPS_End_Date__c;
            pmaInsertList.add(pma);
        }
        
        insert pmaInsertList;
    }
}