global class CustomProductSearchPlugin implements SBQQ.ProductSearchPlugin {
    /*
    * 1.0 Constructor()
    * 2.0 FOREACH(Search Input Field){
    *              2.1 isInputHidden()
    *              2.1 getInputDefaultValue()
    * }
    * 3.0 isSearchCustom (CUSTOM vs ENHANCED)
    * IF(isCustom){
    *		4.0 search()
    * }
    * ELSE{
    *              4.0 getAdditionalSearchFilters()
    * }
    */

    /**
    * Constructor. Not required for implementation
    */
    global CustomProductSearchPlugin() {
        System.debug('METHOD CALLED: CustomProductSearchPlugin Constructor');
    }

    global Boolean isFilterHidden(SObject quote, String fieldName) {
        /*
        if (fieldName == 'Ship_To__c') {
            System.debug('Filter hidden value: ' + fieldName);
            return TRUE;
        } else if (fieldName == 'Ship_To_Name__c') {
            System.debug('Filter hidden value: ' + fieldName);
            return TRUE;
        } else {
            return FALSE;
        }
        */
        /*
        // This would hide Product Code filter if Quote Status is Approved
        return fieldName == 'ProductCode' && quote.SBQQ__Status__c. == 'Approved';
        */
        return FALSE;
    }

    global String getFilterDefaultValue(SObject quote, String fieldName) {
        System.debug('METHOD CALLED: getFilterDefaultValue');
        //if (fieldName == 'Ship_To_Name__c') return 'Testing';
        /*
        // This would set Product Family filter to Service if Quote Type is Quote
        return (fieldName == 'Family' && quote.SBQQ__Type__c. == 'Quote') ? 'Service' : NULL;
        */
        return NULL;
    }

    global Boolean isSearchCustom(SObject quote, Map < String, Object > fieldValuesMap) {
        System.debug('METHOD CALLED: isSearchCustom');
        /*
        // This would use CUSTOM mode if a Search field for sorting was defined and used
        return fieldValuesMap.get('Sort_By__c') != '';
        */
        return TRUE;
    }

    global String getAdditionalSearchFilters(SObject quote, Map < String, Object > fieldValuesMap) {
        System.debug('METHOD CALLED: getAdditionalSearchFilters');
        /*
        // This would add an extra inventory filter if the family is Hardware
        String additionalFilter = NULL;

        if(fieldValuesMap.get('Family') == 'Hardware'){
                additionalFilter = 'AND Product2.Inventory_Level__c > 3';
        }

        return additionalFilter;
        */
        return NULL;
    }

    global String getAdditionalSuggestFilters(SObject quote, Map < String, Object > fieldValuesMap) {
        System.debug('METHOD CALLED: getAdditionalSuggestFilters');

        return NULL;
    }

    global Boolean isSuggestCustom(SObject quote, Map < String, Object > inputValuesMap) {

        return FALSE;
    }

    global List < PriceBookEntry > suggest(SObject quote, Map < String, Object > fieldValuesMap) {
        System.debug('METHOD CALLED: suggest');

        return NULL;
    }

    global List < PriceBookEntry > search(SObject quote, Map < String, Object > fieldValuesMap) {
        System.debug('METHOD CALLED: search');
        System.debug('ALL FILTERS: ' + JSON.serialize(fieldValuesMap));
        Id quoteId = (Id)quote.get('Id'); 

        SBQQ__Quote__c theQuote = [SELECT SBQQ__PriceBook__c, SBQQ__Account__c, Ship_To_Any__c, Ship_To__c, CurrencyIsoCode,
            SBQQ__Opportunity2__c, SBQQ__Opportunity2__r.Parent_Opportunity__c, SBQQ__Opportunity2__r.Parent_Opportunity__r.Opportunity_Type__c 
            FROM SBQQ__Quote__c WHERE Id =: quoteId LIMIT 1];
        System.debug('Quote searched: ' + quoteId);
        System.debug('Quote SBQQ__PriceBook__c: ' + theQuote.get('SBQQ__PriceBook__c'));

        List<Id> products = new List<Id>();
        Boolean showAll = (Boolean)fieldValuesMap.get('Show_All_Products__c');
        System.debug('Show all products: ' + showAll);
        //If we have the showAll filter checked then we want to override this custom logic and just show all products.
        if (!showAll) {
            System.debug(theQuote.SBQQ__Opportunity2__r.Parent_Opportunity__r.Opportunity_Type__c);
            if(theQuote.SBQQ__Opportunity2__c != null && theQuote.SBQQ__Opportunity2__r.Parent_Opportunity__c != null
                && theQuote.SBQQ__Opportunity2__r.Parent_Opportunity__r.Opportunity_Type__c == 'Long Term Opportunity') {
                
                Set<Id> tradeProductIds = new Set<Id>();
                List<OpportunityLineItem> parentOppLineItems = [SELECT Id, Product2Id FROM OpportunityLineItem
                    WHERE OpportunityId =:theQuote.SBQQ__Opportunity2__r.Parent_Opportunity__c 
                    AND Product2.Product_Level__c = 'Trade Product'];
                for(OpportunityLineItem parentOppLineItem : parentOppLineItems) {
                    if(String.isNotBlank(parentOppLineItem.Product2Id)) {
                        tradeProductIds.add(parentOppLineItem.Product2Id);
                    }
                }

                System.debug('tradeProductIds: ' + tradeProductIds);

                List<Product2> matchingProducts = [SELECT Id FROM Product2 WHERE Trade_Product__c IN:tradeProductIds
                    AND Product_Level__c = 'GMID'];
                for(Product2 product : matchingProducts) {
                    products.add(product.Id);
                }
            }
            else {
                Id soldTo = (Id)theQuote.get('SBQQ__Account__c');
                System.debug('Quote SBQQ__Account__c: ' + theQuote.get('SBQQ__Account__c'));
                List<PurchasedProduct_R1__c> pProducts = [SELECT Product_R1__c FROM PurchasedProduct_R1__c WHERE Account_R1__c =: soldTo];
                for (PurchasedProduct_R1__c pProduct : pProducts) {
                    products.add(pProduct.Product_R1__c);
                }
            }
        }
        System.debug('Products: ' + JSON.serialize(products));
        
        //SELECT Id, SBQQ__PriceBook__c FROM SBQQ__Quote__c WHERE Id = 'a1418000000njLrAAI'
        //GET ALL POSSIBLE FILTER FIELDS FROM THE SEARCH FILTER FIELD SET
        List < Schema.FieldSetMember > searchFilterFieldSetFields = SObjectType.Product2.FieldSets.SBQQ__SearchFilters.getFields();

        //GET ALL POSSIBLE FIELDS FROM THE SEARCH RESULTS FIELD SET
        List < Schema.FieldSetMember > searchResultFieldSetFields = SObjectType.Product2.FieldSets.SBQQ__SearchResults.getFields();

        //BUILD THE SELECT STRING
        String selectClause = 'SELECT ';

        for (Schema.FieldSetMember field: searchResultFieldSetFields) {
            selectClause += 'Product2.' + field.getFieldPath() + ', ';
        }
        selectClause += 'Id, UnitPrice, PriceBook2Id, Product2Id, Product2.Id';

        //BUILD THE WHERE CLAUSE
        //theQuote.get('CurrencyIsoCode')
        String whereClause = 'Product2.Product_Level__c = \'GMID\' AND CurrencyIsoCode = \'' + theQuote.get('CurrencyIsoCode') + '\' AND Product2.IsActive = TRUE AND ';

        for (Schema.FieldSetMember field: searchFilterFieldSetFields) {
            //Don't actually use the Show All Products filter as a 'filter' this is only to enable/disable this custom logic.
            if (field.getFieldPath() == 'Show_All_Products__c') {
                continue;
            }
            //If they don't have a value for the filter then don't include in the where clause.
            if (!fieldValuesMap.containsKey(field.getFieldPath())) {
                continue;
            }
            System.debug('Filtering by: ' + fieldValuesMap.get(field.getFieldPath()));
            //Add to the where clause based on the text values they are searching (filtering) for.
            if (field.getType() == Schema.DisplayType.String || field.getType() == Schema.DisplayType.Picklist) {
                whereClause += 'Product2.' + field.getFieldPath() + ' LIKE \'%' + fieldValuesMap.get(field.getFieldPath()) + '%\' AND ';
            }
            //Add to the where clause based on the reference values they are searching (filtering) for.
            if (field.getType() == Schema.DisplayType.Reference) {
                whereClause += 'Product2.' + field.getFieldPath() + ' = \'' + fieldValuesMap.get(field.getFieldPath()) + '\' AND ';
            }
        }

        if (products.size() > 0) {
            whereClause += 'PriceBook2Id = \'' + theQuote.get('SBQQ__PriceBook__c') + '\' AND Product2Id IN: products';
        } else {
            whereClause += 'PriceBook2Id = \'' + theQuote.get('SBQQ__PriceBook__c') + '\'';
        }

        //BUILD THE QUERY
        String query = selectClause + ' FROM PriceBookEntry WHERE ' + whereClause;
        System.debug('Search query: ' + query);

        //DO THE QUERY
        List < PriceBookEntry > pbes = new List < PriceBookEntry > ();
        pbes = Database.query(query);

        return pbes;
    }

    global Boolean isInputHidden(SObject quote, String input) {
        System.debug('METHOD CALLED: isInputHidden');
        /*
        // This would hide an Input called 'Urgent Shipment' on Fridays.
        return input == 'Urgent Shipment' && Datetime.now().format('F') == 5;
        */
        return FALSE;
    }

    global String getInputDefaultValue(SObject quote, String input) {
        System.debug('METHOD CALLED: getInputDefaultValue');

        return NULL;
    }
}