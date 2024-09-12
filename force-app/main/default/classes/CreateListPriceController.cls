public with sharing class CreateListPriceController {
    public boolean inProgress {get;set;}
    public boolean hasId {get;set;}

    private String quoteId;
    private Map<Id, SBQQ__QuoteLine__c> allQuoteLines;
    List<SBQQ__QuoteLine__c> quoteLinesToUpdate = new List<SBQQ__QuoteLine__c>();
    List<SBQQ__QuoteLine__c> quoteLinesToDelete = new List<SBQQ__QuoteLine__c>();
    private Map<Id, Set<Id>> scaleChildQuoteLinesByParentIdMap;
    private Map<Id, Set<Id>> nonscaleChildQuoteLinesByParentIdMap;
    Set<Id> nonChildQuoteLineIds = new Set<Id>();
    Set<Id> productIds = new Set<Id>();
    Set<Id> priceBooksIdSet = new Set<Id>();

    Map<String, PricebookEntry> pbeByPBAndProdMap;
    Map<Id, List<SBQQ__ProductOption__c>> optionsByProductId;
    Map<String, Product_List_Price__c> listPriceByKey;
    Map<String, Date> salesOrgPriceStartMap;
    Map<String, Date> salesOrgPriceEndMap;
    set<String> salesOrgSet;

    public CreateListPriceController() {
        // Mandatory for this to pass by param
        system.debug(ApexPages.currentPage().getParameters());
        quoteId = ApexPages.currentPage().getParameters().get('quoteId');
        if (quoteId != null && quoteId != '') {
            initQuoteLines();
            initPriceBookEntries();
            initProductOptions();
            inProgress = true;
            hasId = true;
        }
        else {
            inProgress = false;
            hasId = false;
        }
    }

    private void initQuoteLines() {
        allQuoteLines = new Map<Id, SBQQ__QuoteLine__c>([SELECT Id, SBQQ__Product__c, SBQQ__Quote__c, SBQQ__Number__c,
        Status__c, PaymentTerms__c, Ship_From_Plant_List__c, Ship_Mode__c, Shipping_Condition__c, Per_Quantity__c,
        Incoterm__c, Price_Change_Mechanism__c, Price_Change_Frequency__c, SBQQ__Quote__r.SBQQ__Account__c, Name,
        SBQQ__Quote__r.SBQQ__PriceBook__c, Ship_To__c, SBQQ__RequiredBy__c, SBQQ__ProductName__c, Product_Level__c, Ship_To_Account__c,
        Create_List_Pricing__c, SBQQ__Quote__r.Minimum_Price_Change_Frequency__c,Price_Start_Date__c, Price_Firm_Date__c, SAP_Sales_Org__c
        FROM SBQQ__QuoteLine__c
        WHERE SBQQ__Quote__c =:quoteId AND Approval_Status_check__c=false ORDER BY SBQQ__Number__c]);
        scaleChildQuoteLinesByParentIdMap = new Map<Id, Set<Id>>();
        nonscaleChildQuoteLinesByParentIdMap = new Map<Id, Set<Id>>();
	salesOrgSet = new set<String>();
        salesOrgPriceStartMap = new Map<String, Date>();
        salesOrgPriceEndMap = new Map<String, Date>();
        for (SBQQ__QuoteLine__c quoteLine : allQuoteLines.values()) {
            if(!priceBooksIdSet.contains(quoteLine.SBQQ__Quote__r.SBQQ__PriceBook__c)) {
                priceBooksIdSet.add(quoteLine.SBQQ__Quote__r.SBQQ__PriceBook__c);
            }
            
            if (!productIds.contains(quoteLine.SBQQ__Product__c)) {
                productIds.add(quoteLine.SBQQ__Product__c);
            }

            if (quoteLine.SBQQ__RequiredBy__c != null) {
                SBQQ__QuoteLine__c parentLine = allQuoteLines.get(quoteLine.SBQQ__RequiredBy__c);
                if (quoteLine.Product_Level__c == 'Scale') {
                    salesOrgSet.add(parentLine.SAP_Sales_Org__c);
                    salesOrgPriceStartMap.put(parentLine.SBQQ__ProductName__c + parentLine.SAP_Sales_Org__c, quoteLine.Price_Start_Date__c);
                    salesOrgPriceEndMap.put(parentLine.SBQQ__ProductName__c + parentLine.SAP_Sales_Org__c, quoteLine.Price_Firm_Date__c);
                    // Not Sure if we still want to delete these
                    if(!scaleChildQuoteLinesByParentIdMap.containsKey(parentLine.Id)) {
                        scaleChildQuoteLinesByParentIdMap.put(parentLine.Id, new Set<Id>());
                    }
                    scaleChildQuoteLinesByParentIdMap.get(parentLine.Id).add(quoteLine.Id);
                }
                else {
                    // Child is NOT a scale
                    if(!nonscaleChildQuoteLinesByParentIdMap.containsKey(parentLine.Id)) {
                        nonscaleChildQuoteLinesByParentIdMap.put(parentLine.Id, new Set<Id>());
                    }
                    nonscaleChildQuoteLinesByParentIdMap.get(parentLine.Id).add(quoteLine.Id);
                }
            }
            else {
                nonChildQuoteLineIds.add(quoteLine.Id);
                salesOrgSet.add(quoteLine.SAP_Sales_Org__c);
                salesOrgPriceStartMap.put(quoteLine.SBQQ__ProductName__c + quoteLine.SAP_Sales_Org__c, quoteLine.Price_Start_Date__c);
                salesOrgPriceEndMap.put(quoteLine.SBQQ__ProductName__c + quoteLine.SAP_Sales_Org__c, quoteLine.Price_Firm_Date__c);
            }

        }
    }

    private void initPriceBookEntries() {
        List<PricebookEntry> pbEntriesList = [SELECT Id, Pricebook2Id, Product2Id
                                                    FROM PricebookEntry
                                                    WHERE Pricebook2Id IN :priceBooksIdSet
                                                    AND Product2Id IN :productIds];
            
        // Marc T (Simplus) - Map for Price Book Entries by Price Book and Product
        // Key -> PriceBook.Id + '' + Product.Id
        pbeByPBAndProdMap = new Map<String, PricebookEntry>();
        for (PricebookEntry pbe : pbEntriesList) {
            if (!pbeByPBAndProdMap.containsKey(pbe.Pricebook2Id +''+ pbe.Product2Id)) {
                pbeByPBAndProdMap.put(pbe.Pricebook2Id +''+ pbe.Product2Id, pbe);
            }
        }
    }

    private void initProductOptions() {
        List<SBQQ__ProductOption__c> productOptions = [SELECT Id, SBQQ__ConfiguredSKU__c, SBQQ__OptionalSKU__c, SBQQ__OptionalSKU__r.Product_Level__c, 
                SBQQ__OptionalSKU__r.Name, SBQQ__Feature__c, SBQQ__Type__c
                FROM SBQQ__ProductOption__c 
                WHERE SBQQ__Feature__r.Name = 'Scale Pricing' 
                AND SBQQ__ConfiguredSKU__c IN:productIds        
                ORDER BY SBQQ__ConfiguredSKU__c, SBQQ__OptionalSKU__r.Name];
        
        optionsByProductId = new Map<Id, List<SBQQ__ProductOption__c>>();
        for(SBQQ__ProductOption__c productOption : productOptions) {
            if(!optionsByProductId.containsKey(productOption.SBQQ__ConfiguredSKU__c)) {
                optionsByProductId.put(productOption.SBQQ__ConfiguredSKU__c, new List<SBQQ__ProductOption__c>());
            }
            optionsByProductId.get(productOption.SBQQ__ConfiguredSKU__c).add(productOption);
        }

        List<Product_List_Price__c> productListPrices = [SELECT Id, Valid_From__c, Valid_To__c, Scale_UOM__c, Index_Order_Number__c, Product__c,Product_Name__c,
                Sales_Organization__c, Sales_Organization__r.Sales_Organization_Code__c, UOM__c, Per_Quantity__c, List_Price__c, ScaleQty__c 
                FROM Product_List_Price__c WHERE Product__c IN:productIds AND Sales_Organization__r.Sales_Organization_Code__c IN :salesOrgSet ORDER BY Index_Order_Number__c];
        
        listPriceByKey = new Map<String, Product_List_Price__c>();
        for(Product_List_Price__c productListPrice : productListPrices) {
            if(productListPrice.Valid_From__c <= salesOrgPriceStartMap.get(productListPrice.Product_Name__c + productListPrice.Sales_Organization__r.Sales_Organization_Code__c) && 
               productListPrice.Valid_To__c >= salesOrgPriceEndMap.get(productListPrice.Product_Name__c + productListPrice.Sales_Organization__r.Sales_Organization_Code__c)){
                   listPriceByKey.put(productListPrice.Product__c + '' + productListPrice.Index_Order_Number__c, productListPrice);
               }
        }
    }

    public PageReference createListPricesForQuote() {
        if (quoteId != null) {
            try {
                buildListPrices();
                delete quoteLinesToDelete;
                upsert quoteLinesToUpdate;
                inProgress = false;
                return returnToPriceRequest();
            }
            catch (Exception ex) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'An Error has Occurred while Creating List Prices. Details: ' + ex.getMessage()));
                return null;
            }
        }
        else {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'No Price Request ID has been provided to this component. '
            + 'If you are a user, please contact your administrator with the details of how you accessed this page.'));
            return null;
        }
    }

    private void buildListPrices() {
        Integer i = 1;
        System.debug(nonChildQuoteLineIds);
        for (Id quoteLineId : nonChildQuoteLineIds) {
            SBQQ__QuoteLine__c quoteLine = allQuoteLines.get(quoteLineId);
            SBQQ__QuoteLine__c updatedLine = new SBQQ__QuoteLine__c(Id = quoteLine.Id);
            updatedLine.SBQQ__Number__c = i;
            i++;
            quoteLinesToUpdate.add(updatedLine);
            
            List<SBQQ__ProductOption__c> options = optionsByProductId.get(quoteLine.SBQQ__Product__c);
            Set<Id> scaleChildrenIds = scaleChildQuoteLinesByParentIdMap.get(quoteLineId);

            if(options != null && !options.isEmpty() && (quoteLine.Create_List_Pricing__c || Test.isRunningTest()) ) {
                updatedLine.Create_List_Pricing__c = false;
                
                if (scaleChildrenIds != null && scaleChildrenIds.size() > 0) {
                    for (Id childId : scaleChildrenIds) {
                        SBQQ__QuoteLine__c childLine = allQuoteLines.get(childId);
                        quoteLinesToDelete.add(childLine);
                    }
                }
                for(SBQQ__ProductOption__c productOption : options) {
                    Id configuredProductId = quoteLine.SBQQ__Product__c;
                    //Id quoteId = quoteLine.SBQQ__Quote__c;
                    
                    String order = productOption.SBQQ__OptionalSKU__r.Name.substringBetween('(',')');
                    
                    if(quoteLine.SBQQ__Product__c == productOption.SBQQ__ConfiguredSKU__c) {
                        
                        SBQQ__QuoteLine__c newLine = new SBQQ__QuoteLine__c();
                        newLine.Ship_To__c = quoteLine.Ship_To__c;
                        newLine.SBQQ__PricebookEntryId__c = (String)pbeByPBAndProdMap.get(
                        quoteLine.SBQQ__Quote__r.SBQQ__PriceBook__c+''+productOption.SBQQ__OptionalSKU__c)?.Id;
                        newLine.Price_Request_Account__c = quoteLine.SBQQ__Quote__r.SBQQ__Account__c;
                        newLine.SBQQ__DynamicOptionId__c = productOption.SBQQ__Feature__c;
                        newLine.SBQQ__ProductOption__c = productOption.Id;
                        newLine.SBQQ__OptionType__c = productOption.SBQQ__Type__c;
                        newLine.SBQQ__OptionLevel__c = 1;
                        newLine.Price_Change_Frequency__c = quoteLine.SBQQ__Quote__r.Minimum_Price_Change_Frequency__c; //Added by PJ; TKT-315
                        newLine.SBQQ__Product__c = productOption.SBQQ__OptionalSKU__c;
                        newLine.SBQQ__Quote__c = quoteLine.SBQQ__Quote__c;
                        
                        newLine.Product_Level__c = productOption.SBQQ__OptionalSKU__r.Product_Level__c;
                        newLine.SBQQ__RequiredBy__c = quoteLine.Id;
                        newLine.Status__c = quoteLine.Status__c;
                        newLine.PaymentTerms__c = quoteLine.PaymentTerms__c;
                        
                        newLine.Ship_To_Account__c = quoteLine.Ship_To_Account__c;
                        newLine.Ship_From_Plant_List__c = quoteLine.Ship_From_Plant_List__c;
                        newLine.Ship_Mode__c = quoteLine.Ship_Mode__c;
                        newLine.Shipping_Condition__c = quoteLine.Shipping_Condition__c;
                        newLine.Incoterm__c = quoteLine.Incoterm__c;
                        //newLine.Price_Change_Mechanism__c = quoteLine.Price_Change_Mechanism__c;
                        //newLine.Price_Change_Frequency__c = quoteLine.Price_Change_Frequency__c;
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
                            if (i == updatedLine.SBQQ__Number__c + 1) {
                                updatedLine.SBQQ__ListPrice__c = newLine.SBQQ__ListPrice__c;
                            }
                            if(listPrice.List_Price__c == 0) {
                                continue;
                            }
                        }
                        
                        newLine.SBQQ__Number__c = i;
                        i++;
                        quoteLinesToUpdate.add(newLine);
                    }
                }
            }
            else if (!quoteLine.Create_List_Pricing__c && scaleChildrenIds != null && scaleChildrenIds.size() > 0) {
                // Has Children, not creating scales, keep them in order.
                for (Id childId : scaleChildrenIds) {
                    SBQQ__QuoteLine__c updatedChildLine = new SBQQ__QuoteLine__c(Id = childId);
                    updatedChildLine.SBQQ__Number__c = i;
                    i++;
                    quoteLinesToUpdate.add(updatedChildLine);
                }
            }
            // Done with Scale Options, do the rest of the Children if there are any
            Set<Id> childIds = nonscaleChildQuoteLinesByParentIdMap.get(quoteLineId);
            if (childIds != null) {
                // Process the Non-Scales with proper numbering
                for (Id childId : childIds) {
                    SBQQ__QuoteLine__c childLine = allQuoteLines.get(childId);
                    if (childLine != null) {
                        SBQQ__QuoteLine__c updatedChild = new SBQQ__QuoteLine__c(Id = childLine.Id);
                        updatedChild.SBQQ__Number__c = i;
                        quoteLinesToUpdate.add(updatedChild);
                        i++;
                    }
                }
            }
        }
    }

    public PageReference returnToPriceRequest() {
        PageReference pageRef = Page.SBQQ__SB;
        pageRef.getParameters().put('scontrolCaching','1');
        pageRef.getParameters().put('id',quoteId);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
}