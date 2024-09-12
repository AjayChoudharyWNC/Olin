public with sharing class SimplusGridController {
    public static final String DEFAULT_LIST_SOURCE = 'SimplusGrid';
    public static final Integer DEFAULT_PAGE_SIZE = 40; //Mass Pricing Row Size
    private static Integer pageMax = 1;
    private static Boolean isBeyond = false;
    
    @AuraEnabled
    public static Map<String, FieldGridControl> getControlFields(List<String> fieldSetNames){
        Map<String, FieldGridControl> fieldAccess = new Map<String, FieldGridControl>();
        for(SimplusGridControlField__mdt gfa : [SELECT Id,FieldApi__c,MasterLabel,Editable__c,EnableMassUpdate__c,MassUpdateType__c,MultiUpdateParameters__c,SortOrder__c, MultiFieldDecision__c
                                                FROM SimplusGridControlField__mdt WHERE ListSource__c IN :fieldSetNames AND Active__c = true ORDER BY SortOrder__c]) {
                                                    fieldAccess.put(gfa.FieldApi__c, new FieldGridControl(gfa));
                                                }
        return fieldAccess;
    }
    
    @AuraEnabled
    public static FieldSetWrapperGroup getFieldSet(String sObjectName, List<FieldSetConfig> fieldSets, String mainListSource){
        if(mainListSource == null || mainListSource == '') mainListSource = DEFAULT_LIST_SOURCE;
        String displayFieldSet = '';
        String filterFieldSet = '';
        List<String> fieldSetNames = new List<String>();
        system.debug('Field set configs: ' + fieldSets);
        for (FieldSetConfig config : fieldSets) {
            if (config.type == 'display') {
                displayFieldSet = config.name;
            } else if (config.type == 'filter') {
                filterFieldSet = config.name;
            }
            fieldSetNames.add(config.name);
        }
        Map<String, FieldGridControl> fieldAccess = getControlFields(fieldSetNames);
        //GET SCHEMA DEFINITION TO CHECK IF FIELD IS EDITABLE ON A PROFILE LEVEL
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.SBQQ__QuoteLine__c.fields.getMap();
        FieldSetWrapperGroup fieldSetWrapperClassList = new FieldSetWrapperGroup();
        
        String result = '';
        try{
            SObjectType objToken = Schema.getGlobalDescribe().get(sObjectName);
            Schema.DescribeSObjectResult d = objToken.getDescribe();
            Map<String, Schema.FieldSet> FsMap = d.fieldSets.getMap();
            system.debug('>>>>>>> FsMap >>> ' + FsMap);
            
            if(FsMap.containsKey(displayFieldSet)) {
                List<FieldSetWrapper> fieldSetWrapperClass = new List<FieldSetWrapper>();
                fieldSetWrapperClassList.sortingFieldSet = new List<FieldSetWrapper>();
                for(Schema.FieldSetMember f : FsMap.get(displayFieldSet).getFields()) {
                    FieldSetWrapper fs = new FieldSetWrapper();
                    fs.fieldLabel = f.getLabel();
                    fs.fieldRequired = f.getDBRequired() || f.getRequired();
                    fs.fieldType = string.valueOf(f.getType());
                    fs.fieldName = f.getFieldPath();
                    if(fieldAccess.containsKey(f.getFieldPath())) {
                        Boolean isUpdateable = false;
                        if(fieldMap.get(f.getFieldPath()).getDescribe().isUpdateable()) {
                            isUpdateable = fieldAccess.get(f.getFieldPath()).editable;
                        }
                        fs.fieldEditable = isUpdateable;
                    } else {
                        fs.fieldEditable =  false;
                    }
                    fieldSetWrapperClassList.sortingFieldSet.add(fs);
                }
            }
            
            if(FsMap.containsKey(filterFieldSet)) {
                List<FieldSetWrapper> fieldSetWrapperClass = new List<FieldSetWrapper>();
                fieldSetWrapperClassList.filteringFieldSet = new List<FieldSetWrapper>();
                for(Schema.FieldSetMember f : FsMap.get(filterFieldSet).getFields()) {
                    FieldSetWrapper fs = new FieldSetWrapper();
                    fs.fieldLabel = f.getLabel();
                    fs.fieldRequired = f.getDBRequired() || f.getRequired();
                    fs.fieldType = string.valueOf(f.getType());
                    fs.fieldName = f.getFieldPath();
                    if(fieldAccess.containsKey(f.getFieldPath())) {
                        Boolean isUpdateable = false;
                        if(fieldMap.get(f.getFieldPath()).getDescribe().isUpdateable()) {
                            isUpdateable = fieldAccess.get(f.getFieldPath()).editable;
                        }
                        fs.fieldEditable = isUpdateable;
                    } else {
                        fs.fieldEditable =  false;
                    }
                    fieldSetWrapperClassList.filteringFieldSet.add(fs);
                }
            }
            system.debug('List Source: ' + mainListSource);
            system.debug('sObjectName: ' + sObjectName);
            fieldSetWrapperClassList.sortingWrapper = querySort(sObjectName, mainListSource); //lstSortingWrapper;
            fieldSetWrapperClassList.filteringWrapper = queryFilter(sObjectName, mainListSource); //lstFilteringWrapper;
            fieldSetWrapperClassList.sortingOrderResult = dynamicQuerySort(mainListSource); // Dynamic query for Sorting
            fieldSetWrapperClassList.filteringOrderResult = dynamicQueryFilter(mainListSource); // Dynamic query for Filtering
            
            Set<String> setfieldNames = new Set<String>();
            for(FieldSetWrapper fs : fieldSetWrapperClassList.sortingFieldSet) {
                if(fs.fieldName != null) {
                    setfieldNames.add(fs.fieldName);
                    if(fs.fieldType == 'REFERENCE') {
                        if(fs.fieldName.indexOf('__c') == -1) {
                            setfieldNames.add(fs.fieldName.substring(0, fs.fieldName.indexOf('Id')) + '.Name');
                        } else {
                            setfieldNames.add(fs.fieldName.substring(0, fs.fieldName.indexOf('__c')) + '__r.Name');
                        }
                    }
                }
            }
            
            String quotelines = '';
            if(sObjectName == 'sbaa__Approval__c') {
                quotelines = getRecords('sbaa__Approval__c', JSON.serialize(setfieldNames), fieldSetWrapperClassList.sortingOrderResult, fieldSetWrapperClassList.filteringOrderResult, 1);
            } else {
                quotelines = getRecords('SBQQ__QuoteLine__c', JSON.serialize(setfieldNames), fieldSetWrapperClassList.sortingOrderResult, fieldSetWrapperClassList.filteringOrderResult, 1);
            }
            
            List<sObject> lstSobject = (List<sObject>) JSON.deserialize(quotelines, List<sObject>.class);
            fieldSetWrapperClassList.lstObject = lstSobject;
            fieldSetWrapperClassList.pageMax = pageMax;
            fieldSetWrapperClassList.isBeyond = isBeyond;
        }
        catch(Exception e){
            result += e.getLineNumber() + ' : ' + e.getMessage();
        }
        return fieldSetWrapperClassList;
    }
    @AuraEnabled
    public static List<SortColumWrapper> querySort(String sObjectName, String mainListSource){
        if(mainListSource == null || mainListSource == '') mainListSource = DEFAULT_LIST_SOURCE;
        List<SortColumWrapper> lstSortingWrapper = new List<SortColumWrapper>();
        List<SimplusGrid_Sorting__c> lstSortingRec = new List<SimplusGrid_Sorting__c>();
        
        if(sObjectName == 'sbaa__Approval__c') {
            system.debug('querySort IF');
            lstSortingRec = [SELECT Id, Column__c, Column_Name__c, Order__c, Priority__c, OwnerId, Active__c
                             FROM SimplusGrid_Sorting__c
                             WHERE OwnerId =: userInfo.getUserId()
                             AND List_Source__c = 'SimplusApprovals'
                             ORDER BY Priority__c];
        } else {
            system.debug('querySort ELSE ');
            lstSortingRec = [SELECT Id, Column__c, Column_Name__c, Order__c, Priority__c, OwnerId, Active__c
                             FROM SimplusGrid_Sorting__c
                             WHERE OwnerId =: userInfo.getUserId()
                             AND List_Source__c = 'SimplusGrid'
                             ORDER BY Priority__c];
        }
        
        for(SimplusGrid_Sorting__c sortingList : lstSortingRec) {
            SortColumWrapper wrapperSort = new SortColumWrapper();
            wrapperSort.id = sortingList.id;
            wrapperSort.sortUser = sortingList.OwnerId;
            wrapperSort.sortColumn = sortingList.Column__c;
            wrapperSort.sortColumnName = sortingList.Column_Name__c;
            wrapperSort.sortOrder = sortingList.Order__c;
            wrapperSort.sortPriority = integer.valueOf(sortingList.Priority__c);
            wrapperSort.isActive = sortingList.Active__c;
            lstSortingWrapper.add(wrapperSort);
        }     
        return lstSortingWrapper;                                             
    }
    
    @AuraEnabled
    public static List<FilterColumWrapper> queryFilter(String sObjectName, String mainListSource){
        if(mainListSource == null || mainListSource == '') mainListSource = DEFAULT_LIST_SOURCE;
        List<FilterColumWrapper> lstFilteringWrapper = new List<FilterColumWrapper>();
        List<SimplusGrid_Filtering__c> lstFilteringRec = new List<SimplusGrid_Filtering__c>();
        
        if(sObjectName == 'sbaa__Approval__c') {
            lstFilteringRec = [SELECT Id, Column__c, Column_Name__c, Operation__c, Value__c, Priority__c, OwnerId, Active__c, Global__c 
                               FROM SimplusGrid_Filtering__c WHERE OwnerId =: userInfo.getUserId()
                               AND List_Source__c = 'SimplusApprovals'
                               ORDER BY Priority__c];
        } else {
            lstFilteringRec = [SELECT Id, Column__c, Column_Name__c, Operation__c, Value__c, Priority__c, OwnerId, Active__c, Global__c
                               FROM SimplusGrid_Filtering__c
                               WHERE (OwnerId =: userInfo.getUserId() OR Global__c = true)
                               AND List_Source__c = :mainListSource
                               ORDER BY Global__c DESC, Priority__c];
        }
        
        
        for(SimplusGrid_Filtering__c filteringList : lstFilteringRec) {
            FilterColumWrapper wrapperFilter = new FilterColumWrapper();
            wrapperFilter.id = filteringList.id;
            wrapperFilter.filterUser = filteringList.OwnerId;
            wrapperFilter.filterColumn = filteringList.Column__c;
            wrapperFilter.filterColumnName = filteringList.Column_Name__c;
            wrapperFilter.filterOperation = filteringList.Operation__c;
            wrapperFilter.filterValue = filteringList.Value__c;
            wrapperFilter.filterPriority = integer.valueOf(filteringList.Priority__c);
            wrapperFilter.isActive = filteringList.Active__c;
            wrapperFilter.isGlobal = filteringList.Global__c;
            lstFilteringWrapper.add(wrapperFilter); 
        }
        return lstFilteringWrapper;
    }
    
    
    @AuraEnabled
    public static FieldSetWrapperGroup toggle(String sObjectName, String mainListSource, Integer page){
        if(page == null) page = 1;
        if(mainListSource == null || mainListSource == '') mainListSource = DEFAULT_LIST_SOURCE;
        List<FieldSetConfig> lstFieldSetConfig = new List<FieldSetConfig>();
        FieldSetConfig fieldSetConfig = new FieldSetConfig();
        if(sObjectName == 'SBQQ__QuoteLine__c') {
            fieldSetConfig.name = 'SimplusGrid';
            fieldSetConfig.type = 'display';
            lstFieldSetConfig.add(fieldSetConfig);
            fieldSetConfig = new FieldSetConfig();
            fieldSetConfig.name = 'SimplusGrid_Filter';
            fieldSetConfig.type = 'filter';
            lstFieldSetConfig.add(fieldSetConfig);
        }
        else if(sObjectName == 'sbaa__Approval__c') {
            fieldSetConfig.name = 'SimplusApprovals';
            fieldSetConfig.type = 'display';
            lstFieldSetConfig.add(fieldSetConfig);
            fieldSetConfig = new FieldSetConfig();
            fieldSetConfig.name = 'SimplusApprovals_Filter';
            fieldSetConfig.type = 'filter';
            lstFieldSetConfig.add(fieldSetConfig);
        }
        
        FieldSetWrapperGroup filterGroup = new FieldSetWrapperGroup();
        System.debug('sObjectName'+sObjectName);
        if(sObjectName == 'sbaa__Approval__c') {
            filterGroup = getFieldSet('sbaa__Approval__c', lstFieldSetConfig, mainListSource);
        } else {
            filterGroup = getFieldSet('SBQQ__QuoteLine__c', lstFieldSetConfig, mainListSource);
        }
        List<FieldSetWrapper> lstFieldSet = new List<FieldSetWrapper>();
        lstFieldSet = filterGroup.sortingFieldSet;
        
        Set<String> setfieldNames = new Set<String>();
        for(FieldSetWrapper fs:lstFieldSet) {
            if(fs.fieldName != null) {
                setfieldNames.add(fs.fieldName);
                if(fs.fieldType == 'REFERENCE') {
                    if(fs.fieldName.indexOf('__c') == -1) {
                        setfieldNames.add(fs.fieldName.substring(0, fs.fieldName.indexOf('Id')) + '.Name');
                    } else {
                        setfieldNames.add(fs.fieldName.substring(0, fs.fieldName.indexOf('__c')) + '__r.Name');
                    }
                }
            }
        }
        
        system.debug('toggleSort >> ' + JSON.serialize(setfieldNames));
        String quotelines = '';
        
        if(sObjectName == 'sbaa__Approval__c') {
            quotelines = getRecords('sbaa__Approval__c', JSON.serialize(setfieldNames), filterGroup.sortingOrderResult, filterGroup.filteringOrderResult, page);
        } else {
            quotelines = getRecords('SBQQ__QuoteLine__c', JSON.serialize(setfieldNames), filterGroup.sortingOrderResult, filterGroup.filteringOrderResult, page);
        }
        System.debug('258 quotelines -- ' + quotelines);
        List<sObject> lstSobject = (List<sObject>) JSON.deserialize(quotelines, List<sObject>.class);
        System.debug('LIST SOBJECT ' + lstSobject);
        filterGroup.lstObject = lstSobject;
        filterGroup.pageMax = pageMax;
        filterGroup.isBeyond = isBeyond;
        System.debug('filterGroup -- ' + filterGroup);
        return filterGroup;                                             
    }
    
    @AuraEnabled
    public static String dynamicQuerySort(String mainListSource){
        if(mainListSource == null || mainListSource == '') mainListSource = DEFAULT_LIST_SOURCE;
        List<SimplusGrid_Sorting__c> lstSortingRec = [SELECT Id, Column__c, Column_Name__c, Order__c, Priority__c, OwnerId, Active__c
                                                      FROM SimplusGrid_Sorting__c
                                                      WHERE OwnerId =: userInfo.getUserId()
                                                      AND List_Source__c = :mainListSource
                                                      ORDER BY Priority__c];
        system.debug('SORT query >> ' + lstSortingRec);
        String sortingQuery = '';
        Integer sortingCount = 0;
        for(SimplusGrid_Sorting__c sortingList : lstSortingRec) {
            if(sortingList.Active__c) {
                sortingCount++;
                if(sortingCount > 1) {
                    sortingQuery += ', ';
                } else if(sortingCount == 1) {
                    sortingQuery += ' ORDER BY ';
                }
                sortingQuery += sortingList.Column__c + ' ' + sortingList.Order__c;
            }
        }
        system.debug('SORT >> ' + sortingQuery);
        return sortingQuery;
    }
    
    @AuraEnabled
    public static String dynamicQueryFilter(String mainListSource){
        if(mainListSource == null || mainListSource == '') mainListSource = DEFAULT_LIST_SOURCE;
        
        List<SimplusGrid_Filtering__c> lstFilteringRec = [SELECT Id, Column__c, Column_Name__c, Column_Type__c, Operation__c, Value__c, Priority__c, OwnerId, Active__c, Global__c
                                                          FROM SimplusGrid_Filtering__c
                                                          WHERE (OwnerId =: userInfo.getUserId() OR Global__c = true)
                                                          AND List_Source__c = :mainListSource];
        
        String filteringQuery = '';
        Integer filterCounter = 0;
        for(SimplusGrid_Filtering__c filteringList : lstFilteringRec) {
            if(filteringList.Active__c) {
                filterCounter++;
                if(filterCounter > 1) {
                    filteringQuery += 'AND';
                } else if(filterCounter == 1) {
                    filteringQuery += ' WHERE';
                }
                
                String filterUsed = '';
                
                //Date formatting for SOQL use.  Use dateTimeValue.formatGMT with format string as comparison.
                String dateValStr;
                Date dateValue;
                Datetime dateTimeValue;
                
                if(filteringList.Column_Type__c == 'DATE') {
                    dateValue = Date.valueOf(filteringList.Value__c);
                    dateValStr = (Date.valueOf(filteringList.Value__c) + '').split(' ')[0];
                    dateTimeValue = DateTime.newInstance(dateValue, Time.newInstance(0, 0, 0, 0));
                } else if (filteringList.Column_Type__c == 'DATETIME') {
                    dateTimeValue = Datetime.valueOf(filteringList.Value__c);
                }
                
                if(filteringList.Operation__c == 'starts with') {
                    filterUsed = 'LIKE' + ' \'' + filteringList.Value__c + '%\' ';
                } else if(filteringList.Operation__c == 'ends with') {
                    filterUsed = 'LIKE' + ' \'%' + filteringList.Value__c + '\' ';
                } else if(filteringList.Operation__c == 'contains') {
                    filterUsed = 'LIKE' + ' \'%' + filteringList.Value__c + '%\' ';
                } else if(filteringList.Operation__c == 'equals') {
                    filterUsed = '=' + ' \'' + filteringList.Value__c + '\' ';
                } else if(filteringList.Operation__c == 'not equals') {
                    filterUsed = '!=' + ' \'' + filteringList.Value__c + '\' ';
                } else if(filteringList.Operation__c == 'is null') {
                    filterUsed = '= null ';
                } else if(filteringList.Operation__c == 'not null') {
                    filterUsed = '!= null ';
                } else if(filteringList.Operation__c == 'eq') {
                    filterUsed = '= ' + filteringList.Value__c + ' ';
                } else if(filteringList.Operation__c == 'lt') {
                    filterUsed = '< ' + filteringList.Value__c + ' ';
                } else if(filteringList.Operation__c == 'gt') {
                    filterUsed = '> ' + filteringList.Value__c + ' ';
                    
                } else if(filteringList.Column_Type__c == 'DATE' && filteringList.Operation__c == 'equal') {
                    filterUsed = '= ' + dateValStr;//.formatGMT('yyyy-MM-dd') + ' ';
                } else if(filteringList.Column_Type__c == 'DATETIME' && filteringList.Operation__c == 'equal') {
                    filterUsed = '= ' + dateTimeValue.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ') + ' ';
                    
                } else if(filteringList.Column_Type__c == 'DATE' && filteringList.Operation__c == 'before') {
                    filterUsed = '< ' + dateValStr;//.formatGMT('yyyy-MM-dd') + ' ';
                } else if(filteringList.Column_Type__c == 'DATETIME' && filteringList.Operation__c == 'before') {
                    filterUsed = '< ' + dateTimeValue.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ') + ' ';
                    
                } else if(filteringList.Column_Type__c == 'DATE' && filteringList.Operation__c == 'after') {
                    filterUsed = '> ' + dateValStr;//.formatGMT('yyyy-MM-dd') + ' ';
                } else if(filteringList.Column_Type__c == 'DATETIME' && filteringList.Operation__c == 'after') {
                    filterUsed = '> ' + dateTimeValue.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ') + ' ';
                }                               
                
                if(filteringList.Column__c == 'SBQQ__Quote__c'){
                    filterUsed = 'LIKE' + ' \'%' + filteringList.Value__c + '%\' ';
                    filteringQuery += ' ' + 'SBQQ__Quote__r.Name' + ' ' + filterUsed;
                }
                else{
                    filteringQuery += ' ' + filteringList.Column__c + ' ' + filterUsed;
                }
            }
        }
        system.debug('FILTER >> ' + filteringQuery);
        return filteringQuery;
    }
    
    @AuraEnabled 
    public static FieldSetWrapperGroup deleteSortFilterItem(String sObjectName, String type, Id id, Integer page) {
        String listSrc;
        //try {
        if(type == 'sort') {
            SimplusGrid_Sorting__c sortItem = [SELECT Id, List_Source__c FROM SimplusGrid_Sorting__c WHERE Id = :id LIMIT 1];
            listSrc = sortItem.List_Source__c;
            delete new SimplusGrid_Sorting__c(Id = id);
        } else if(type == 'filter') {
            SimplusGrid_Filtering__c filterItem = [SELECT Id, List_Source__c FROM SimplusGrid_Filtering__c WHERE Id = :id LIMIT 1];
            listSrc = filterItem.List_Source__c;
            delete new SimplusGrid_Filtering__c(Id = id);
        }
        return toggle(sObjectName, listSrc, page);
        //} catch(Exception e) {
        //    returnStr = e.getMessage();
        //}
        //return returnStr;
    }
    
    @AuraEnabled 
    public static FieldSetWrapperGroup toggleSortFilterItem(String sObjectName, String type, Id id, Boolean currentState, Integer page) {
        String listSrc;
        //try {
        if(type == 'sort') {
            SimplusGrid_Sorting__c sortItem = [SELECT Id, List_Source__c FROM SimplusGrid_Sorting__c WHERE Id = :id LIMIT 1];
            listSrc = sortItem.List_Source__c;
            update new SimplusGrid_Sorting__c(Id = id, Active__c = !currentState);
        } else if(type == 'filter') {
            SimplusGrid_Filtering__c filterItem = [SELECT Id, List_Source__c FROM SimplusGrid_Filtering__c WHERE Id = :id LIMIT 1];
            listSrc = filterItem.List_Source__c;
            update new SimplusGrid_Filtering__c(Id = id, Active__c = !currentState);
        }
        return toggle(sObjectName, listSrc, page);
        //} catch(Exception e) {
        //    returnStr = e.getMessage();
        //    return null;
        //}
        //return null;
    }
    
    @AuraEnabled
    public static FieldSetWrapperGroup deleteAllSortFilterItem(String type, String wrapperList) {
        List<SortColumWrapper> lstSortWrapper = new List<SortColumWrapper>();
        List<FilterColumWrapper> lstFilterWrapper = new List<FilterColumWrapper>();
        List<SimplusGrid_Sorting__c> lstSorting = new List<SimplusGrid_Sorting__c>();
        List<SimplusGrid_Filtering__c> lstFiltering = new List<SimplusGrid_Filtering__c>();
        FieldSetWrapperGroup filterGroup = new FieldSetWrapperGroup();
        
        if(type == 'sort') {
            lstSortWrapper = (List<SortColumWrapper>)JSON.deserialize(wrapperList, List<SortColumWrapper>.class);
        } else if(type == 'filter') {
            lstFilterWrapper = (List<FilterColumWrapper>)JSON.deserialize(wrapperList, List<FilterColumWrapper>.class);
        }
        
        if(type == 'sort') {
            if(lstSortWrapper != null) {
                for(SortColumWrapper sortWrapper : lstSortWrapper) {
                    SimplusGrid_Sorting__c newSorting = new SimplusGrid_Sorting__c(Id = sortWrapper.id);
                    lstSorting.add(newSorting);
                }
                delete lstSorting;
                filterGroup.sortingWrapper = new List<SortColumWrapper>();
            }
            
        } else if(type == 'filter') {
            if(lstFilterWrapper != null) {
                for(FilterColumWrapper filterWrapper : lstFilterWrapper) {
                    if(!filterWrapper.isGlobal) {
                        SimplusGrid_Filtering__c newFiltering = new SimplusGrid_Filtering__c(Id = filterWrapper.id);
                        lstFiltering.add(newFiltering);
                    }
                }
                delete lstFiltering;
                filterGroup.filteringWrapper = new List<FilterColumWrapper>();
            }
        }
        return filterGroup;
    }
    
    @AuraEnabled
    public static FieldSetWrapperGroup dragAndDrop(String type, String wrapperList) {
        List<SortColumWrapper> lstSortWrapper = new List<SortColumWrapper>();
        List<FilterColumWrapper> lstFilterWrapper = new List<FilterColumWrapper>();
        List<SimplusGrid_Sorting__c> lstSorting = new List<SimplusGrid_Sorting__c>();
        List<SimplusGrid_Filtering__c> lstFiltering = new List<SimplusGrid_Filtering__c>();
        FieldSetWrapperGroup filterGroup = new FieldSetWrapperGroup();
        if(type == 'sort') {
            lstSortWrapper = (List<SortColumWrapper>)JSON.deserialize(wrapperList, List<SortColumWrapper>.class);
        } else if(type == 'filter') {
            lstFilterWrapper = (List<FilterColumWrapper>)JSON.deserialize(wrapperList, List<FilterColumWrapper>.class);
        }
        
        Integer counter = 0;
        if(type == 'sort') {
            
            for(SortColumWrapper sortWrapper : lstSortWrapper) {
                counter++;
                sortWrapper.sortPriority = counter;
                SimplusGrid_Sorting__c newSorting = new SimplusGrid_Sorting__c(Id = sortWrapper.id, Priority__c = counter);
                lstSorting.add(newSorting);
            }
            update lstSorting;
            filterGroup.sortingWrapper = lstSortWrapper;
            
        } else if(type == 'filter') {
            
            for(FilterColumWrapper filterWrapper : lstFilterWrapper) {
                counter++;
                filterWrapper.filterPriority = counter;
                SimplusGrid_Filtering__c newFiltering = new SimplusGrid_Filtering__c(Id = filterWrapper.id, Priority__c = counter);
                lstFiltering.add(newFiltering);
            }
            update lstFiltering;
            filterGroup.filteringWrapper = lstFilterWrapper;
        }
        return filterGroup;
    }
    
    @AuraEnabled
    public static String getRecords(String sObjectName, String fieldNameJson, String sortingOrderResult, String filteringOrderResult, Integer page){
        

        system.debug('>>>>>>> fieldNameJson >>> ' + fieldNameJson);
        
        List<sObject> lstResult = new List<sObject>();
        String result = '[]';
        try{
            List<String> fieldNames = (List<String>) JSON.deserialize(fieldNameJson, List<String>.class);
            if(sObjectName == 'SBQQ__QuoteLine__c') {
                if(fieldNames.indexOf('SentToSap__c') < 0) fieldNames.add('SentToSap__c');
                if(fieldNames.indexOf('Is_Locked__c') < 0) fieldNames.add('Is_Locked__c');
            } else if(sObjectName == 'sbaa__Approval__c') {
                
                if(fieldNames.indexOf('GMID_Currency__c') < 0) fieldNames.add('GMID_Currency__c');
            }
            Set<String> setFieldNames = new Set<String>();
            String query = 'SELECT '+ String.join(fieldNames, ',') + ' FROM ' + sObjectName;
            String queryCount = 'SELECT COUNT(Id) cnt FROM ' + sObjectName;
            String currentUser = userInfo.getUserId();
            
            if(sObjectName == 'SBQQ__QuoteLine__c') {
                if (filteringOrderResult != '' && filteringOrderResult != null){
                    query += ' ' + filteringOrderResult;
                    queryCount += ' ' + filteringOrderResult;
                    query += ' AND Product_Level__c != \'Adder\'';
                    queryCount += ' AND Product_Level__c != \'Adder\'';
                } else {
                    query += ' WHERE Product_Level__c != \'Adder\'';
                    queryCount += ' WHERE Product_Level__c != \'Adder\'';
                }

                query += ' AND Status__c = \'Won\' AND Status__c != \'Negotiated\' AND SentToSAP__c = true AND SBQQ__Quote__r.SBQQ__Status__c = \'Draft Contract\''; // AND SBQQ__Quote__r.OwnerId = \'' + currentUser + '\'';
                queryCount += ' AND Status__c = \'Won\' AND Status__c != \'Negotiated\' AND SentToSAP__c = true AND SBQQ__Quote__r.SBQQ__Status__c = \'Draft Contract\''; // AND SBQQ__Quote__r.OwnerId = \'' + currentUser + '\'';
                if (sortingOrderResult != '' && sortingOrderResult != null){
                    query += ' ' + sortingOrderResult;
                }  else {
                    query += ' ORDER BY CreatedDate DESC';
                }
            } else if(sObjectName == 'sbaa__Approval__c') {
                if (filteringOrderResult != '' && filteringOrderResult != null){
                    query += ' ' + filteringOrderResult;
                    queryCount += ' ' + filteringOrderResult;
                    query += ' AND sbaa__AssignedTo__c =: currentUser AND Quote_Line_Status__c = \'Pending\' AND (sbaa__Status__c = \'Requested\') AND PendingMassApprovalRequest__c = false';
                    queryCount += ' AND sbaa__AssignedTo__c =: currentUser AND Quote_Line_Status__c = \'Pending\' AND (sbaa__Status__c = \'Requested\') AND PendingMassApprovalRequest__c = false';
                } else {
                    query += ' WHERE sbaa__AssignedTo__c =: currentUser AND Quote_Line_Status__c = \'Pending\' AND (sbaa__Status__c = \'Requested\') AND PendingMassApprovalRequest__c = false';
                    queryCount += ' WHERE sbaa__AssignedTo__c =: currentUser AND Quote_Line_Status__c = \'Pending\' AND (sbaa__Status__c = \'Requested\') AND PendingMassApprovalRequest__c = false';
                }
                
                if (sortingOrderResult != '' && sortingOrderResult != null){
                    query += ' ' + sortingOrderResult;
                }  else {
                    query += ' ORDER BY CreatedDate DESC';
                }
            }
            
            query += ' LIMIT ' + DEFAULT_PAGE_SIZE;
            query += ' OFFSET ' + ((page - 1) * DEFAULT_PAGE_SIZE);
            
            system.debug('>>>>>>> query >>> ' + query);
            
            AggregateResult ag = Database.query(queryCount);
            
            Integer recordCnt = Integer.valueOf(ag.get('cnt'));
            System.debug('COUNT: ' + ag);
            pageMax = recordCnt / DEFAULT_PAGE_SIZE;
            if(Math.mod(recordCnt,DEFAULT_PAGE_SIZE) > 0) pageMax +=1;
            
            if(pageMax > 40) { //Mass Pricing Row Size
                isBeyond = true;
                pageMax = 40;
            } else if(pageMax == 0) {
                pageMax = 1;
            }
            
            for(sObject s : Database.query(query)){
                lstResult.add(s);
            }
            if(lstResult.size() > 0) {
                result = JSON.serialize(lstResult);
            }
        } catch(Exception e){
            system.debug('Error: >> ' + e.getLineNumber() + ' : ' + e.getMessage());
            return '[]';
        }
        system.debug('RESULT >> ' + result);
        return result;
    }
    
    @AuraEnabled
    public static String saveRecords(String saveList){
        System.debug(saveList);
        List<SBQQ__QuoteLine__c> sobjSaveList = (List<SBQQ__QuoteLine__c>) JSON.deserialize(saveList, List<SBQQ__QuoteLine__c>.class);
        
        try {
            Database.update(sobjSaveList, false);
        } catch(Exception e) {
            return e.getMessage();
        }
        
        return '';
    }

    @AuraEnabled
    public static void saveSubmittedUser(String saveList){
        List<String> sobjSaveList = (List<String>) JSON.deserialize(saveList, List<String>.class);
        Set<String> cloneSet = new Set<String>();
        for(String s : sobjSaveList) {
            cloneSet.add(s);
        }
        if(!cloneSet.isEmpty()){
            List<SBQQ__Quote__c> quoteLst = new List<SBQQ__Quote__c>();
            for(SBQQ__Quote__c q : [SELECT Id, Submitted_By__c FROM SBQQ__Quote__c WHERE Id IN :cloneSet]){
                q.Submitted_By__c = UserInfo.getUserId();
                quoteLst.add(q);
            }
            if(!quoteLst.isEmpty()){
                try{
                    update quoteLst;
                } catch (Exception e){
                    System.debug('Error update Submitted By>> ' +e.getMessage());
                }
            }
        }
    }

    // ! not in use
    /*
    private static void doClone(Id quoteId, Boolean doSubmit) {
        SBQQ__Quote__c origQuote = [SELECT Id, Approval_Justification__c, ApprovalStatus__c, Automatic_Price_Update_Letter__c, Base_Currency__c,
                                        Bid_Reference_PO__c, Cancellation_Period__c, CurrencyIsoCode, Default_Price_Change_Frequency__c, Default_Price_Change_Mechanism__c, Duplication_Status__c,
                                        Evergreen_Contract__c, Joint_IP_Development__c, Legal_Contact__c, Notify_Days_Before__c, Original_Price_Request__c, Override_Freight__c, OwnerId,
                                        Price_Firm_Date2__c, Price_Request_Version__c, Price_Start_Date__c, Response_Type__c, Renewal_Frequency_yrs__c,
                                        SBQQ__Account__c, SBQQ__BillingCity__c, SBQQ__BillingCountry__c, SBQQ__BillingName__c, SBQQ__BillingPostalCode__c, SBQQ__BillingState__c,
                                        SBQQ__BillingStreet__c, SBQQ__ContractingMethod__c, SBQQ__DefaultTemplate__c, SBQQ__Distributor__c, SBQQ__DistributorDiscount__c,
                                        SBQQ__EndDate__c, SBQQ__MasterContract__c, SBQQ__Opportunity2__c, SBQQ__OriginalQuote__c, SBQQ__Partner__c,
                                        SBQQ__PartnerDiscount__c, SBQQ__PaymentTerms__c, SBQQ__PriceBook__c, SBQQ__Primary__c, SBQQ__PrimaryContact__c,
                                        SBQQ__RenewalTerm__c, SBQQ__SalesRep__c, SBQQ__ShippingCity__c, SBQQ__ShippingCountry__c, SBQQ__ShippingName__c,
                                        SBQQ__ShippingPostalCode__c, SBQQ__ShippingState__c, SBQQ__ShippingStreet__c, SBQQ__Source__c, SBQQ__StartDate__c,
                                        SBQQ__SubscriptionTerm__c, SBQQ__Type__c, Ship_To__c, Ship_To_Any__c, Ship_To_Account__c, Olin_Legal_Entity__c, Olin_Legal_Contact__c,
                                        SAP_Sales_Org__c, Show_Contract_Details__c, SubmittedUser__c, Per_Quantity__c, SBQQ__PricebookId__c,
                                        (SELECT Id, Adj_Floor__c, Adj_Target__c, Adjustment_Factor__c, Adjustment_Factor_Pct__c,
                                                Avg_Annualize_Volume__c, Base_Currency__c, Base_Price__c, Base_UOM__c, Base_Volume__c,
                                                Business_Group__c, CurrencyIsoCode, Custom_Expiration_Date__c, Custom_Start_Date__c, Customer_Product_Code__c, Delivered_Price__c, Discount_Percent__c,
                                                Exchange_Rate__c, Exempt__c, Formula_Description__c, Formula_Name__c, Freight_Charge__c,
                                                Freight_Component__c, Freight_Discount__c, Freight_Fuel_Surcharge__c, Freight_Surcharge__c, Fuel_Surcharge_Exemption__c,
                                                Fusion_PH1__c, Fusion_PH1_Performance_Center__c, Fusion_PH2__c, Fusion_PH2_Plan_Product__c, Fusion_PH3__c,
                                                Fusion_PH3_Trade_Product__c, Fusion_Profit_Group__c, Fusion_Segment__c, GCO_Business_Segment__c, GCO_List_Price__c, Global_UOM__c, GMID__c, GMID_Number__c, High_Threshold__c,
                                                Inbound_Freight__c, Inco_Location__c, Inco_Port__c, Incoterm__c,
                                                Low_Threshold__c, Material_Group__c, Material_Group_Number__c, Material_Type__c, Maximum_Volume__c, Minimum_Volume__c,
                                                Net_Back_Target__c, Netback_Min__c, New_Base_Price__c, New_Delivered_Price__c, New_Price_Firm_Date__c, New_Price_Start_Date__c, Outbound_Charges__c,
                                                Payment_Method__c, Per_Quantity__c, PH1__c, PH1_Performance_Center__c,
                                                PH2__c, PH2_Plan_Product__c, PH3__c, Price_Change_Frequency__c, Price_Change_Mechanism__c,
                                                Price_Firm_Date__c, Price_Period_Volume__c, Price_Request_Account__c, Price_Start_Date__c, Prior_Expiration_Date__c,
                                                Prior_Start_Date__c, Product_Commodity_Index__c, Product_Name_Override__c, Product_Level__c, Profit_Center__c,
                                                Profit_Center_Number__c, Profit_Group__c, SAP_Sales_Org__c, SBQQ__Bundled__c, SBQQ__compoundDiscountRate__c,
                                                SBQQ__contractedPrice__c, SBQQ__costEditable__c, SBQQ__customerPrice__c, SBQQ__DefaultSubscriptionTerm__c, SBQQ__Description__c,
                                                SBQQ__Discount__c, SBQQ__DiscountSchedule__c, SBQQ__DiscountTier__c, SBQQ__Hidden__c, SBQQ__ListPrice__c,
                                                SBQQ__NonDiscountable__c, SBQQ__NonPartnerDiscountable__c, SBQQ__Number__c, SBQQ__OptionDiscount__c, SBQQ__OriginalPrice__c,
                                                SBQQ__PartnerDiscount__c, SBQQ__PriceEditable__c, SBQQ__PricingMethod__c, SBQQ__PricingMethodEditable__c, SBQQ__Product__c,
                                                SBQQ__ProductCode__c, SBQQ__ProductOption__c, SBQQ__ProratedListPrice__c, SBQQ__Quote__c, SBQQ__RegularPrice__c,
                                                SBQQ__Renewal__c, SBQQ__RequiredBy__c, SBQQ__SpecialPrice__c, SBQQ__SpecialPriceDescription__c, SBQQ__SpecialPriceType__c,
                                                SBQQ__StartDate__c, SBQQ__SubscriptionBase__c, SBQQ__SubscriptionPercent__c, SBQQ__SubscriptionPricing__c, SBQQ__SubscriptionScope__c,
                                                SBQQ__TermDiscount__c, SBQQ__TermDiscountSchedule__c, SBQQ__UnitCost__c, SBQQ__VolumeDiscount__c, Ship_From_Plant_List__c,
                                                Ship_Mode__c, Ship_To__c, Ship_To_Account__c, Shipped_Product__c, Shipping_Condition__c,
                                                Shipping_Point__c, Show_Freight_On_Output__c, Show_Freight_On_Proposal__c, Show_On_Output__c, Show_Price_Formula__c,
                                                Source_Quote_Line__c, Standard_UOM__c, Through_Charges__c, To_Charges__c, Trade_Product__c, UOM__c,
                                                UOM_Conversion_Factor__c, Validity_End_Date__c, Validity_Start_Date__c, Volume_Period__c, SBQQ__Quote__r.Price_Start_Date__c
                                            FROM SBQQ__LineItems__r)
                                        FROM SBQQ__Quote__c
                                        WHERE Id = :quoteId];

        // Insert quotes
        Map<Id, SBQQ__Quote__c> mapOrigQuoteIdToClonedQuote = new Map<Id, SBQQ__Quote__c>();
        //for (SBQQ__Quote__c aQuote : quoteMap.values()) {
        //    SBQQ__Quote__c clonedQuote = cloneQuote(aQuote);
        //    clonedQuote.SubmitForApproval__c = doSubmit;
        //    mapOrigQuoteIdToClonedQuote.put(aQuote.Id, clonedQuote);
        //}
        SBQQ__Quote__c clonedQuote = cloneQuote(origQuote);
        clonedQuote.SubmitForApproval__c = doSubmit;
        SBQQ.TriggerControl.disable();
        //insert mapOrigQuoteIdToClonedQuote.values();
        insert clonedQuote;

        // Collect original quote lines to update Price Status later.
        List<SBQQ__QuoteLine__c> quoteLinesToUpdate = new List<SBQQ__QuoteLine__c>();

        // Insert Parent QLs first
        Map<Id, SBQQ__QuoteLine__c> mapOrigQuoteLineIdToClonedQuoteLine_parent = new Map<Id, SBQQ__QuoteLine__c>();
        for (SBQQ__QuoteLine__c aQuoteLine : origQuote.SBQQ__LineItems__r) {
            if (aQuoteLine.SBQQ__RequiredBy__c == null) { // If the quoteline is a top level bundle product,
                SBQQ__QuoteLine__c newQuoteLine = cloneQuoteLine(aQuoteLine);
                // Determine the new parent quote using the map we have created earlier.
                newQuoteLine.SBQQ__Quote__c = clonedQuote.Id;
                mapOrigQuoteLineIdToClonedQuoteLine_parent.put(aQuoteLine.Id, newQuoteLine);
                // Add the original quote line to update its price status later.
                quoteLinesToUpdate.add(aQuoteLine);
            }
        }
        insert mapOrigQuoteLineIdToClonedQuoteLine_parent.values();

        // Then insert child QLs
        List<SBQQ__QuoteLine__c> childQuoteLines = new List<SBQQ__QuoteLine__c>();
        for (SBQQ__QuoteLine__c aQuoteLine : origQuote.SBQQ__LineItems__r) {
            if (aQuoteLine.SBQQ__RequiredBy__c != null) { // If the quoteline is a child of a product,
                SBQQ__QuoteLine__c newQuoteLine = cloneQuoteLine(aQuoteLine);
                // Determine the new parent quote using the map we have created earlier.
                newQuoteLine.SBQQ__Quote__c = clonedQuote.Id;

                // Determine the parent quote line
                newQuoteLine.SBQQ__RequiredBy__c = mapOrigQuoteLineIdToClonedQuoteLine_parent.get(aQuoteLine.SBQQ__RequiredBy__c).Id;
                childQuoteLines.add(newQuoteLine);
                // Add the original quote line to update its price status later.
                quoteLinesToUpdate.add(aQuoteLine);
            }
        }

        insert childQuoteLines;

        for (SBQQ__QuoteLine__c aQuoteLine : quoteLinesToUpdate) {
            aQuoteLine.Price_Status__c = doSubmit ? 'Cloned & Submitted' : 'Cloned';
        }

        update quoteLinesToUpdate;

        SBQQ.TriggerControl.enable();
        update new SBQQ__Quote__c(Id = clonedQuote.Id, SBQQ__Primary__c = origQuote.SBQQ__Primary__c, ForceRecalculate__c = DateTime.now());
        
        //insert Price Movement Audit
        insertPMA(quoteLinesToUpdate);
        
    }
    */
    // ! not in use
    /*
    private static SBQQ__QuoteLine__c cloneQuoteLine(SBQQ__QuoteLine__c aQuoteLine) {
        return new SBQQ__QuoteLine__c(
            Adj_Floor__c = aQuoteLine.Adj_Floor__c,
            Adj_Target__c = aQuoteLine.Adj_Target__c,
            Adjustment_Factor__c = aQuoteLine.Adjustment_Factor__c,
            Adjustment_Factor_Pct__c = aQuoteLine.Adjustment_Factor_Pct__c,
            Avg_Annualize_Volume__c = aQuoteLine.Avg_Annualize_Volume__c,
            Base_Currency__c = aQuoteLine.Base_Currency__c,
            Base_Price__c = aQuoteLine.Base_Price__c,
            Base_UOM__c = aQuoteLine.Base_UOM__c,
            Base_Volume__c = aQuoteLine.Base_Volume__c,
            Business_Group__c = aQuoteLine.Business_Group__c,
            CurrencyIsoCode = aQuoteLine.CurrencyIsoCode,
            Custom_Expiration_Date__c = aQuoteLine.New_Price_Firm_Date__c,
            Custom_Start_Date__c = aQuoteLine.New_Price_Start_Date__c,
            Customer_Product_Code__c = aQuoteLine.Customer_Product_Code__c,
            Delivered_Price__c = aQuoteLine.Delivered_Price__c,
            Discount_Percent__c = aQuoteLine.Discount_Percent__c,
            Exchange_Rate__c = aQuoteLine.Exchange_Rate__c,
            Exempt__c = aQuoteLine.Exempt__c,
            External_Quote_Line_Id__c = aQuoteLine.Id,
            Formula_Description__c = aQuoteLine.Formula_Description__c,
            Formula_Name__c = aQuoteLine.Formula_Name__c,
            Freight_Charge__c = aQuoteLine.Freight_Charge__c,
            Freight_Component__c = aQuoteLine.Freight_Component__c,
            Freight_Discount__c = aQuoteLine.Freight_Discount__c,
            Freight_Fuel_Surcharge__c = aQuoteLine.Freight_Fuel_Surcharge__c,
            Freight_Surcharge__c = aQuoteLine.Freight_Surcharge__c,
            Fuel_Surcharge_Exemption__c = aQuoteLine.Fuel_Surcharge_Exemption__c,
            Fusion_PH1__c = aQuoteLine.Fusion_PH1__c,
            Fusion_PH1_Performance_Center__c = aQuoteLine.Fusion_PH1_Performance_Center__c,
            Fusion_PH2__c = aQuoteLine.Fusion_PH2__c,
            Fusion_PH2_Plan_Product__c = aQuoteLine.Fusion_PH2_Plan_Product__c,
            Fusion_PH3__c = aQuoteLine.Fusion_PH3__c,
            Fusion_PH3_Trade_Product__c = aQuoteLine.Fusion_PH3_Trade_Product__c,
            Fusion_Profit_Group__c = aQuoteLine.Fusion_Profit_Group__c,
            Fusion_Segment__c = aQuoteLine.Fusion_Segment__c,
            GCO_Business_Segment__c = aQuoteLine.GCO_Business_Segment__c,
            GCO_List_Price__c = aQuoteLine.GCO_List_Price__c,
            Global_UOM__c = aQuoteLine.Global_UOM__c,
            GMID__c = aQuoteLine.GMID__c,
            GMID_Number__c = aQuoteLine.GMID_Number__c,
            High_Threshold__c = aQuoteLine.High_Threshold__c,
            Inbound_Freight__c = aQuoteLine.Inbound_Freight__c,
            Inco_Location__c = aQuoteLine.Inco_Location__c,
            Inco_Port__c = aQuoteLine.Inco_Port__c,
            Incoterm__c = aQuoteLine.Incoterm__c,
            Low_Threshold__c = aQuoteLine.Low_Threshold__c,
            Material_Group__c = aQuoteLine.Material_Group__c,
            Material_Group_Number__c = aQuoteLine.Material_Group_Number__c,
            Material_Type__c = aQuoteLine.Material_Type__c,
            Maximum_Volume__c = aQuoteLine.Maximum_Volume__c,
            Minimum_Volume__c = aQuoteLine.Minimum_Volume__c,
            Net_Back_Target__c = aQuoteLine.Net_Back_Target__c,
            Netback_Min__c = aQuoteLine.Netback_Min__c,
            New_Base_Price__c = aQuoteLine.New_Base_Price__c, 
            New_Delivered_Price__c = null, 
            New_Price_Firm_Date__c = null,
            New_Price_Start_Date__c = null,
            Prior_Expiration_Date__c = aQuoteLine.Price_Firm_Date__c,
            Prior_Start_Date__c = aQuoteLine.Price_Start_Date__c,
            Outbound_Charges__c = aQuoteLine.Outbound_Charges__c,
            Payment_Method__c = aQuoteLine.Payment_Method__c,
            Per_Quantity__c = aQuoteLine.Per_Quantity__c,
            PH1__c = aQuoteLine.PH1__c,
            PH1_Performance_Center__c = aQuoteLine.PH1_Performance_Center__c,
            PH2__c = aQuoteLine.PH2__c,
            PH2_Plan_Product__c = aQuoteLine.PH2_Plan_Product__c,
            PH3__c = aQuoteLine.PH3__c,
            Price_Change_Frequency__c = aQuoteLine.Price_Change_Frequency__c,
            Price_Change_Mechanism__c = aQuoteLine.Price_Change_Mechanism__c,
            Price_Firm_Date__c = aQuoteLine.New_Price_Firm_Date__c,
            Price_Period_Volume__c = aQuoteLine.Price_Period_Volume__c,
            Price_Request_Account__c = aQuoteLine.Price_Request_Account__c,
            Price_Start_Date__c = aQuoteLine.New_Price_Start_Date__c,
            Product_Commodity_Index__c = aQuoteLine.Product_Commodity_Index__c,
            Product_Name_Override__c = aQuoteLine.Product_Name_Override__c,
            Product_Level__c = aQuoteLine.Product_Level__c,
            Profit_Center__c = aQuoteLine.Profit_Center__c,
            Profit_Center_Number__c = aQuoteLine.Profit_Center_Number__c,
            Profit_Group__c = aQuoteLine.Profit_Group__c,
            SAP_Sales_Org__c = aQuoteLine.SAP_Sales_Org__c,
            SBQQ__Bundled__c = aQuoteLine.SBQQ__Bundled__c,
            SBQQ__compoundDiscountRate__c = aQuoteLine.SBQQ__compoundDiscountRate__c,
            SBQQ__ContractedPrice__c = aQuoteLine.SBQQ__ContractedPrice__c,
            SBQQ__CostEditable__c = aQuoteLine.SBQQ__CostEditable__c,
            SBQQ__CustomerPrice__c = aQuoteLine.SBQQ__CustomerPrice__c,
            SBQQ__DefaultSubscriptionTerm__c = aQuoteLine.SBQQ__DefaultSubscriptionTerm__c,
            SBQQ__Description__c = aQuoteLine.SBQQ__Description__c,
            SBQQ__Discount__c = aQuoteLine.SBQQ__Discount__c,
            SBQQ__DiscountSchedule__c = aQuoteLine.SBQQ__DiscountSchedule__c,
            SBQQ__DiscountTier__c = aQuoteLine.SBQQ__DiscountTier__c,
            SBQQ__Hidden__c = aQuoteLine.SBQQ__Hidden__c,
            SBQQ__ListPrice__c = aQuoteLine.New_Delivered_Price__c,
            SBQQ__NonDiscountable__c = aQuoteLine.SBQQ__NonDiscountable__c,
            SBQQ__NonPartnerDiscountable__c = aQuoteLine.SBQQ__NonPartnerDiscountable__c,
            SBQQ__Number__c = aQuoteLine.SBQQ__Number__c,
            SBQQ__OptionDiscount__c = aQuoteLine.SBQQ__OptionDiscount__c,
            SBQQ__OriginalPrice__c = aQuoteLine.SBQQ__OriginalPrice__c,
            SBQQ__PartnerDiscount__c = aQuoteLine.SBQQ__PartnerDiscount__c,
            SBQQ__PriceEditable__c = aQuoteLine.SBQQ__PriceEditable__c,
            SBQQ__PricingMethod__c = aQuoteLine.SBQQ__PricingMethod__c,
            SBQQ__PricingMethodEditable__c = aQuoteLine.SBQQ__PricingMethodEditable__c,
            SBQQ__Product__c = aQuoteLine.SBQQ__Product__c,
            SBQQ__ProductOption__c = aQuoteLine.SBQQ__ProductOption__c,
            SBQQ__ProratedListPrice__c = aQuoteLine.SBQQ__ProratedListPrice__c,
            SBQQ__Quote__c = aQuoteLine.SBQQ__Quote__c,
            SBQQ__RegularPrice__c = aQuoteLine.SBQQ__RegularPrice__c,
            SBQQ__Renewal__c = aQuoteLine.SBQQ__Renewal__c,
            SBQQ__Source__c = aQuoteLine.Id,
            SBQQ__SpecialPrice__c = aQuoteLine.SBQQ__SpecialPrice__c,
            SBQQ__SpecialPriceDescription__c = aQuoteLine.SBQQ__SpecialPriceDescription__c,
            SBQQ__SpecialPriceType__c = aQuoteLine.SBQQ__SpecialPriceType__c,
            SBQQ__StartDate__c = aQuoteLine.SBQQ__StartDate__c,
            SBQQ__SubscriptionBase__c = aQuoteLine.SBQQ__SubscriptionBase__c,
            SBQQ__SubscriptionPercent__c = aQuoteLine.SBQQ__SubscriptionPercent__c,
            SBQQ__SubscriptionPricing__c = aQuoteLine.SBQQ__SubscriptionPricing__c,
            SBQQ__SubscriptionScope__c = aQuoteLine.SBQQ__SubscriptionScope__c,
            SBQQ__TermDiscount__c = aQuoteLine.SBQQ__TermDiscount__c,
            SBQQ__TermDiscountSchedule__c = aQuoteLine.SBQQ__TermDiscountSchedule__c,
            SBQQ__UnitCost__c = aQuoteLine.SBQQ__UnitCost__c,
            SBQQ__VolumeDiscount__c = aQuoteLine.SBQQ__VolumeDiscount__c,
            Ship_From_Plant_List__c = aQuoteLine.Ship_From_Plant_List__c,
            Ship_Mode__c = aQuoteLine.Ship_Mode__c,
            Ship_To__c = aQuoteLine.Ship_To__c,
            Ship_To_Account__c = aQuoteLine.Ship_To_Account__c,
            Shipped_Product__c = aQuoteLine.Shipped_Product__c,
            Shipping_Condition__c = aQuoteLine.Shipping_Condition__c,
            Shipping_Point__c = aQuoteLine.Shipping_Point__c,
            Show_Freight_On_Output__c = aQuoteLine.Show_Freight_On_Output__c,
            Show_Freight_On_Proposal__c = aQuoteLine.Show_Freight_On_Proposal__c,
            Show_On_Output__c = aQuoteLine.Show_On_Output__c,
            Show_Price_Formula__c = aQuoteLine.Show_Price_Formula__c,
            Source_Quote_Line__c = aQuoteLine.Id,
            Standard_UOM__c = aQuoteLine.Standard_UOM__c,
            Through_Charges__c = aQuoteLine.Through_Charges__c,
            To_Charges__c = aQuoteLine.To_Charges__c,
            Trade_Product__c = aQuoteLine.Trade_Product__c, 
            UOM__c = aQuoteLine.UOM__c,
            UOM_Conversion_Factor__c = aQuoteLine.UOM_Conversion_Factor__c,
            Validity_End_Date__c = aQuoteLine.Validity_End_Date__c,
            Validity_Start_Date__c = aQuoteLine.Validity_Start_Date__c,
            Volume_Period__c = aQuoteLine.Volume_Period__c,
            New_Competitor__c = aQuoteLine.New_Competitor__c,
            New_Competitor_Product__c = aQuoteLine.New_Competitor_Product__c,
            New_Competitive_Price__c = aQuoteLine.New_Competitive_Price__c,
            Competitive_Manufacturer__c = aQuoteLine.New_Competitive_Manufacturer__c
        );
    }
    */
    // ! not in use
    /*
    private static Date getPriceStartDate(SBQQ__Quote__c aQuote) {
        SBQQ__QuoteLine__c aQuoteLine;
        for (SBQQ__QuoteLine__c ql : aQuote.SBQQ__LineItems__r) {
            if (ql.New_Price_Start_Date__c != null) {
                return ql.New_Price_Start_Date__c;
            }
        }
        return null;
    }
	*/
    // ! not in use
    /*
    private static Date getPriceFirmDate(SBQQ__Quote__c aQuote) {
        SBQQ__QuoteLine__c aQuoteLine;
        for (SBQQ__QuoteLine__c ql : aQuote.SBQQ__LineItems__r) {
            if (ql.New_Price_Firm_Date__c != null) {
                return ql.New_Price_Firm_Date__c;
            }
        }
        return null;
    }
	*/
    // ! not in use
    /*
    private static SBQQ__Quote__c cloneQuote(SBQQ__Quote__c aQuote) {
        return new SBQQ__Quote__c(
            Automatic_Price_Update_Letter__c = aQuote.Automatic_Price_Update_Letter__c,
            Base_Currency__c = aQuote.Base_Currency__c,
            Bid_Reference_PO__c = aQuote.Bid_Reference_PO__c,
            Cancellation_Period__c = aQuote.Cancellation_Period__c,
            CurrencyIsoCode = aQuote.CurrencyIsoCode,
            Default_Price_Change_Frequency__c = aQuote.Default_Price_Change_Frequency__c,
            Default_Price_Change_Mechanism__c = aQuote.Default_Price_Change_Mechanism__c,
            Duplication_Status__c = aQuote.Duplication_Status__c,
            Evergreen_Contract__c = aQuote.Evergreen_Contract__c,
            External_Price_Request_Id__c = aQuote.Id,
            Legal_Contact__c = aQuote.Legal_Contact__c,
            Notify_Days_Before__c = aQuote.Notify_Days_Before__c,
            Original_Price_Request__c = aQuote.Original_Price_Request__c == null ? aQuote.Id : aQuote.Original_Price_Request__c,
            Override_Freight__c = aQuote.Override_Freight__c,
            OwnerId = aQuote.OwnerId,
            Per_Quantity__c = aQuote.Per_Quantity__c,
            Price_Request_Version__c = aQuote.Price_Request_Version__c + 1,
            Price_Start_Date__c = getPriceStartDate(aQuote),
            Renewal_Frequency_yrs__c = aQuote.Renewal_Frequency_yrs__c,
            Response_Type__c = aQuote.Response_Type__c,
            SBQQ__Account__c = aQuote.SBQQ__Account__c,
            SBQQ__BillingCity__c = aQuote.SBQQ__BillingCity__c,
            SBQQ__BillingCountry__c = aQuote.SBQQ__BillingCountry__c,
            SBQQ__BillingName__c = aQuote.SBQQ__BillingName__c,
            SBQQ__BillingPostalCode__c = aQuote.SBQQ__BillingPostalCode__c,
            SBQQ__BillingState__c = aQuote.SBQQ__BillingState__c,
            SBQQ__BillingStreet__c = aQuote.SBQQ__BillingStreet__c,
            SBQQ__ContractingMethod__c = aQuote.SBQQ__ContractingMethod__c,
            SBQQ__DefaultTemplate__c = aQuote.SBQQ__DefaultTemplate__c,
            SBQQ__Distributor__c = aQuote.SBQQ__Distributor__c,
            SBQQ__DistributorDiscount__c = aQuote.SBQQ__DistributorDiscount__c,
            SBQQ__EndDate__c = aQuote.SBQQ__EndDate__c,
            SBQQ__MasterContract__c = aQuote.SBQQ__MasterContract__c,
            SBQQ__Opportunity2__c = aQuote.SBQQ__Opportunity2__c,
            SBQQ__OriginalQuote__c = aQuote.SBQQ__OriginalQuote__c,
            SBQQ__Partner__c = aQuote.SBQQ__Partner__c,
            SBQQ__PartnerDiscount__c = aQuote.SBQQ__PartnerDiscount__c,
            SBQQ__PaymentTerms__c = aQuote.SBQQ__PaymentTerms__c,
            SBQQ__PriceBook__c = aQuote.SBQQ__PriceBook__c,
            SBQQ__PriceBookId__c = aQuote.SBQQ__PriceBookId__c,
            SBQQ__PrimaryContact__c = aQuote.SBQQ__PrimaryContact__c,
            SBQQ__RenewalTerm__c = aQuote.SBQQ__RenewalTerm__c,
            SBQQ__SalesRep__c = aQuote.SBQQ__SalesRep__c,
            SBQQ__ShippingCity__c = aQuote.SBQQ__ShippingCity__c,
            SBQQ__ShippingCountry__c = aQuote.SBQQ__ShippingCountry__c,
            SBQQ__ShippingName__c = aQuote.SBQQ__ShippingName__c,
            SBQQ__ShippingPostalCode__c = aQuote.SBQQ__ShippingPostalCode__c,
            SBQQ__ShippingState__c = aQuote.SBQQ__ShippingState__c,
            SBQQ__ShippingStreet__c = aQuote.SBQQ__ShippingStreet__c,
            SBQQ__Source__c = aQuote.Id,
            SBQQ__StartDate__c = aQuote.SBQQ__StartDate__c,
            SBQQ__SubscriptionTerm__c = aQuote.SBQQ__SubscriptionTerm__c,
            SBQQ__Type__c = aQuote.SBQQ__Type__c,
            Ship_To__c = aQuote.Ship_To__c,
            Ship_To_Any__c = aQuote.Ship_To_Any__c,
            Ship_To_Account__c = aQuote.Ship_To_Account__c,
            Olin_Legal_Entity__c = aQuote.Olin_Legal_Entity__c,
            Olin_Legal_Contact__c = aQuote.Olin_Legal_Contact__c,
            Show_Contract_Details__c = aQuote.Show_Contract_Details__c,
            SAP_Sales_Org__c = aQuote.SAP_Sales_Org__c,
            // Modified 8/4
            Cloned_From_Mulesoft__c = true
        );
    }
    */
    @AuraEnabled
    public static String cloneRecords(List<Id> quoteLineIds, Boolean doSubmit){
        Map<String, String> response = new Map<String, String>();
        String returnStr = '';
        System.debug('quoteLineIds >>> ' + quoteLineIds);
        Savepoint sp = Database.setSavepoint();
        try {
            
            // doClone(quoteId, doSubmit);
            Set<Id> quoteIds = new Set<Id>();
            for (SBQQ__QuoteLine__c ql : [SELECT Id, SBQQ__Quote__c FROM SBQQ__QuoteLine__c WHERE Id IN :quoteLineIds]) {
                quoteIds.add(ql.SBQQ__Quote__c);
            }
            Set<Id> qlIds = QuoteCloningService.clone(quoteIds, new Set<Id>(quoteLineIds), doSubmit);
            
            returnStr = 'Clone successful!';
            response.put('result', 'success');
            response.put('quoteLineIds', JSON.serialize(qlIds));
        }
        catch(Exception ex) {
            Database.rollback(sp);
            returnStr = 'Failed to clone! ' + ex.getMessage(); 
            response.put('result', 'error');
            response.put('errormsg', ex.getMessage());
            response.put('stacktrace', ex.getStackTraceString());
        }
        System.debug('returnStr >>> ' + returnStr);

        return JSON.serialize(response);
    }

    @AuraEnabled
    public static Boolean submitRecordForApproval(String quoteLineId){
        //Map<String, String> response = new Map<String, String>();
        Boolean success = false;
        //SBQQ.TriggerControl.disable(); //TKT-121
        try {
            SBAA.ApprovalAPI.submit(quoteLineId, SBAA__Approval__c.Quote_Line__c);
            success = true;
            //response.put('result', 'success');
        }
        catch (Exception ex) {
            success = false;
            throw ex;
            // response.put('result', 'error');
            // response.put('errormsg', ex.getMessage());
            // response.put('stacktrace', ex.getStackTraceString());
        }
       // finally {
          // SBQQ.TriggerControl.enable(); //TKT-121
       // }
        //return JSON.serialize(response);
        return success;
        // System.enqueueJob(new ApprovalSubmitQueueable(quoteLineIds)); 
    }

    @AuraEnabled
    //public static Boolean areQuotesCalculated(Id[] quoteLineIds){
    public static String areQuotesCalculated(Id[] quoteLineIds){
        Map<String, Object> response = new Map<String, Object>();
        try {
            Set<Id> quoteIds = new Set<Id>();
            for (SBQQ__QuoteLine__c quoteLine : [SELECT Id, SBQQ__Quote__c FROM SBQQ__QuoteLine__c WHERE Id IN :quoteLineIds]) {
                quoteIds.add(quoteLine.SBQQ__Quote__c);
            }
            Boolean areAllCalculated = true;
            for (SBQQ__Quote__c quot : [SELECT Id, SBQQ__Uncalculated__c FROM SBQQ__Quote__c WHERE Id IN :quoteIds]) {
                areAllCalculated = areAllCalculated && !quot.SBQQ__Uncalculated__c;
            }
            response.put('result', 'success');
            response.put('areAllCalculated', areAllCalculated);
        } catch (Exception ex) {
            response.put('result', 'error');
            response.put('errormsg', ex.getMessage());
            response.put('stacktrace', ex.getStackTraceString());
        }
        return JSON.serialize(response);
        

        // Boolean success = false;

        // try {
        //     Set<Id> quoteIds = new Set<Id>();
        //     for (SBQQ__QuoteLine__c quoteLine : [SELECT Id, SBQQ__Quote__c FROM SBQQ__QuoteLine__c WHERE Id IN :quoteLineIds]) {
        //         quoteIds.add(quoteLine.SBQQ__Quote__c);
        //     }
        //     Boolean areAllCalculated = true;
        //     for (SBQQ__Quote__c quot : [SELECT Id, SBQQ__Uncalculated__c FROM SBQQ__Quote__c WHERE Id IN :quoteIds]) {
        //         areAllCalculated = areAllCalculated && !quot.SBQQ__Uncalculated__c;
        //     }
        //     success = areAllCalculated;
        // }
        // catch (Exception ex) {
        //     success = false;
        //     throw ex;
        // } 

        // return success;

    }
    // ! not in use
    /*
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
                                        SBQQ__Quote__r.CUPS_Support_Price__c,
                                        SBQQ__Quote__r.CUPS_Start_Date__c,
                                        SBQQ__Quote__r.CUPS_End_Date__c,
                                        Source_Quote_Line__r.SBQQ__ListPrice__c,
                                        Source_Quote_Line__r.New_Delivered_Price__c,
                                        Source_Quote_Line__r.Price_Start_Date__c,
                                        Source_Quote_Line__r.Price_Firm_Date__c,
                                        Source_Quote_Line__r.New_Price_Start_Date__c,
                                        Source_Quote_Line__r.New_Price_Firm_Date__c,
                                        Source_Quote_Line__r.CUPS_Support_Price__c,
                                        Source_Quote_Line__r.CUPS_Start_Date__c,
                                        Source_Quote_Line__r.CUPS_End_Date__c,
                                        Source_Quote_Line__r.CurrencyIsoCode
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
            pma.CUPS_Support_Price__c = ql.CUPS_Support_Price__c;
            pma.CUPS_Start_Date__c = ql.CUPS_Start_Date__c;
            pma.CUPS_End_Date__c = ql.CUPS_End_Date__c;
            pma.New_CUPS_Support_Price__c = ql.Source_Quote_Line__r.CUPS_Support_Price__c;
            pma.New_CUPS_Start_Date__c = ql.Source_Quote_Line__r.CUPS_Start_Date__c;
            pma.New_CUPS_End_Date__c = ql.Source_Quote_Line__r.CUPS_End_Date__c;

            pmaInsertList.add(pma);
        }
        
        insert pmaInsertList;
    }
	*/
    @AuraEnabled
    public static string saveInlineEditRecords(Map<Id, SBQQ__QuoteLine__c> quoteLineMap, Date priceStartDate, Date priceEndDate){
        system.debug(' PJ PJ PJ PJP saveInlineEditRecords running ');
        String retMsg = '';
        List<String> uncalculatedQuoteLines = new List<String>();
        for(SBQQ__QuoteLine__c qlm : quoteLineMap.values()){
           system.debug('QLM QLM New_Delivered_Price__c;   :::::  '+qlm.New_Delivered_Price__c);
            system.debug('QLM QLM Start Date;   :::::  '+ qlm.New_Price_Start_Date__c);
            system.debug('QLM QLM End Date;   :::::  '+qlm.New_Price_Firm_Date__c);
        }
        /*  Marc T (Simplus)
        *   Adding in Scale Pricing Handling for Distributor Child Quote Lines
        */
        Map<Id, SBQQ__QuoteLine__c> qlCalculationStatus = new Map<Id, SBQQ__QuoteLine__c>(
            [SELECT Id, SBQQ__Quote__r.Name, SBQQ__Quote__r.SBQQ__Uncalculated__c, SBQQ__RequiredBy__r.SBQQ__Product__c,
            SBQQ__RequiredBy__c, SBQQ__Quote__r.SBQQ__Distributor__c, SBQQ__Product__c, Distributor__c, SAP_Sales_Org__c,
		    SBQQ__Number__c, Per_Quantity__c, SBQQ__ListPrice__c, SBQQ__Quote__c,New_Delivered_Price__c, New_Price_Firm_Date__c, New_Price_Start_Date__c
            FROM SBQQ__QuoteLine__c 
            WHERE Id 
            IN :quoteLineMap.keySet()]);

        List<SBQQ__QuoteLine__c> forUpdate = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> forProductListPriceCheck = new List<SBQQ__QuoteLine__c>();
        for (SBQQ__QuoteLine__c ql:quoteLineMap.values()) {
            SBQQ__QuoteLine__c quoteLine = qlCalculationStatus.get(ql.Id);
            /*  Marc T (Simplus)
            *   If this is a Child of some other Quote Line, and the Quote has a Distributor
            *   then it has to be Scale Pricing. Skip this record.
            */
            system.debug('PJ PJ quoteLine.SBQQ__RequiredBy__c :: '+quoteLine.SBQQ__RequiredBy__c);
            system.debug('PJ PJ quoteLine.SBQQ__Quote__r.SBQQ__Distributor__c :: '+quoteLine.SBQQ__Quote__r.SBQQ__Distributor__c);
            //if (quoteLine.SBQQ__RequiredBy__c != null && quoteLine.SBQQ__Quote__r.SBQQ__Distributor__c != null) {
            if (quoteLine.SBQQ__RequiredBy__c != null && quoteLine.Distributor__c) {
                // Explicitly using the SOQL Queried Map QL
                // We do *NOT* want to persist Mass Pricing inputs for these
                forProductListPriceCheck.add(quoteLine);
                system.debug(' PJ PJ PJ PJP forProductListPriceCheck :::: '+forProductListPriceCheck);
               
                continue;
            }

            if (quoteLine.SBQQ__Quote__r.SBQQ__Uncalculated__c) {
                uncalculatedQuoteLines.add(quoteLine.SBQQ__Quote__r.Name);
            }
            else {
                system.debug('quoteLineMap New_Delivered_Price__c;   :::::  '+quoteLineMap.get(ql.Id).New_Delivered_Price__c);
                system.debug('QL QL QL New_Delivered_Price__c;   :::::  '+ql.New_Delivered_Price__c);
                system.debug('quoteLineMap.get(ql.Id).New_Price_Start_Date__c;   :::::  '+quoteLineMap.get(ql.Id).New_Price_Start_Date__c);
                system.debug('quoteLineMap.get(ql.Id).New_Price_Firm_Date__c;   :::::  '+quoteLineMap.get(ql.Id).New_Price_Firm_Date__c);
       
                if (ql.Support_Discount__c != null) ql.Support_Discount__c = ql.Support_Discount__c / 100;

                if (quoteLineMap.get(ql.Id).New_Delivered_Price__c != null){
                    ql.New_Delivered_Price__c = quoteLineMap.get(ql.Id).New_Delivered_Price__c;
                }
                
                if(priceStartDate != NULL) ql.New_Price_Start_Date__c = priceStartDate;
                if(priceEndDate != NULL) ql.New_Price_Firm_Date__c = priceEndDate;
                forUpdate.add(ql);
            }
        }
        // Marc T (Simplus) - Scale Pricing
        if (!forProductListPriceCheck.isEmpty()) { 
            handleScalePricingUpdateFromProductListPrice(forProductListPriceCheck, priceStartDate, priceEndDate);
        }

        if (uncalculatedQuoteLines.isEmpty()) {
            system.debug(' PJ PJ PJ PJP forUpdate :::: '+forUpdate);
            try {
                update forUpdate;
                retMsg = 'Updates successfully saved.';
            } catch(Exception e) {
                retMsg = e.getMessage();
            }
        }
        else {
            retMsg = 'You are trying to update some quote lines with parent quotes that are not yet calculated: ' 
                + String.join(uncalculatedQuoteLines, ', ') + '. Please calculate the quote or wait for a few moments to complete the calculation.';
        }
        return retMsg;
    }

    // Marc T (Simplus) - 8/19
    @TestVisible
    private static void handleScalePricingUpdateFromProductListPrice(List<SBQQ__QuoteLine__c> quoteLineList, Date priceStartDate, Date priceEndDate) {
        system.debug(' PJ PJ PJ PJP handleScalePricingUpdateFromProductListPrice  ENTER ENTER');
        // quoteLinesByProductMap: Product ID (Key) -> QuoteLine RequiredBy ID (Key) -> Quote Line List
        Map<Id, Map<Id, List<SBQQ__QuoteLine__c>>> quoteLinesByProductMap = new Map<Id, Map<Id, List<SBQQ__QuoteLine__c>>>();
        List<SBQQ__QuoteLine__c> quoteLinesToUpdate = new List<SBQQ__QuoteLine__c>();
        Set<Id> parentQuoteLineIds = new Set<Id>();
        Set<String> salesOrgSet = new Set<String>();
        
        
        // Finding corresponding Quote Lines by product is going to be key to matching indexes later.
        for (SBQQ__QuoteLine__c ql : quoteLineList) {
            Map<Id, List<SBQQ__QuoteLine__c>> requiredByQuoteLineMap;
            List<SBQQ__QuoteLine__c> qlList;
			
           
            if (!parentQuoteLineIds.contains(ql.SBQQ__RequiredBy__c)) {
                parentQuoteLineIds.add(ql.SBQQ__RequiredBy__c);
                salesOrgSet.add(ql.SAP_Sales_Org__c);
                system.debug(' PJ PJ PARENT QUOTE LINE ::::  '+parentQuoteLineIds);
            }   
                // Populate the Composite
           // if(ql.SBQQ__RequiredBy__c != NULL){ 
                if(quoteLinesByProductMap.containsKey(ql.SBQQ__RequiredBy__r.SBQQ__Product__c)) {
                    requiredByQuoteLineMap = quoteLinesByProductMap.get(ql.SBQQ__RequiredBy__r.SBQQ__Product__c);
                    if (requiredByQuoteLineMap.containsKey(ql.SBQQ__RequiredBy__c)) {
                        qlList = requiredByQuoteLineMap.get(ql.SBQQ__RequiredBy__c);
                    }
                    else {
                        qlList = new List<SBQQ__QuoteLine__c>();
                        requiredByQuoteLineMap.put(ql.SBQQ__RequiredBy__c, qlList);
                    }
                }
                else {
                    requiredByQuoteLineMap = new Map<Id, List<SBQQ__QuoteLine__c>>();
                    qlList = new List<SBQQ__QuoteLine__c>();
                    requiredByQuoteLineMap.put(ql.SBQQ__RequiredBy__c, qlList);
                    quoteLinesByProductMap.put(ql.SBQQ__RequiredBy__r.SBQQ__Product__c, requiredByQuoteLineMap);
                }
                qlList.add(ql);
            //}
            /*else{
                if(quoteLinesByProductMap.containsKey(ql.SBQQ__Product__c)) {
                    requiredByQuoteLineMap = quoteLinesByProductMap.get(ql.SBQQ__Product__c);
                    if (requiredByQuoteLineMap.containsKey(ql.Id)) {
                        qlList = requiredByQuoteLineMap.get(ql.Id);
                    }
                    else {
                        qlList = new List<SBQQ__QuoteLine__c>();
                        requiredByQuoteLineMap.put(ql.Id, qlList);
                    }
                }
                else {
                    requiredByQuoteLineMap = new Map<Id, List<SBQQ__QuoteLine__c>>();
                    qlList = new List<SBQQ__QuoteLine__c>();
                    requiredByQuoteLineMap.put(ql.Id, qlList);
                    quoteLinesByProductMap.put(ql.SBQQ__Product__c, requiredByQuoteLineMap);
                }
                qlList.add(ql);
            }*/
            
            
        }
		system.debug('PJ PJ PJ quoteLinesByProductMap  ::::  '+quoteLinesByProductMap);
        Map<Id,SBQQ__QuoteLine__c> parentQuoteLinesMap = new Map<Id, SBQQ__QuoteLine__c>([SELECT Id, SBQQ__ListPrice__c, SAP_Sales_Org__c
            FROM SBQQ__QuoteLine__c 
            WHERE Id IN :parentQuoteLineIds]);

        /*  Marc T (Simplus)
        *   Default Assumption here is that there will only be *ONE* Product List Price set per product
        *   in the valid date range!
        */
  
        List<Product_List_Price__c> productListPrices = [SELECT Id, Valid_From__c, Valid_To__c, 
            Index_Order_Number__c, Product__c, Per_Quantity__c, List_Price__c, Sales_Organization__r.Sales_Organization_Code__c,
            List_Price_Per_1__c, List_Price_Per_10__c, List_Price_Per_100__c
            FROM Product_List_Price__c 
            WHERE Product__c IN :quoteLinesByProductMap.keySet()
            AND Valid_From__c <= :priceStartDate
            AND Valid_To__c >= :priceEndDate
            AND Sales_Organization__r.Sales_Organization_Code__c IN :salesOrgSet
            ORDER BY Index_Order_Number__c];
        
        // Composite Data Structure is a necessary evil here, as we need to be able to keep the PLPs
        // sorted by Index
        Map<Id, Map<Integer, Product_List_Price__c>> productToListPriceIndexesMap = 
            new Map<Id, Map<Integer, Product_List_Price__c>>();
        system.debug('PJ PJ PJ productListPrices   ::::  '+productListPrices);
        for (Product_List_Price__c plp : productListPrices) {
            Map<Integer, Product_List_Price__c> plpByIndexMap;
			system.debug('plp.Id  :::   '+plp.Id);
            system.debug('plp.List_Price_Per_100__c  :::   '+plp.List_Price_Per_100__c);
            // Populate the Composite
            if (!productToListPriceIndexesMap.containsKey(plp.Product__c)) {
                plpByIndexMap = new Map<Integer, Product_List_Price__c>();
                productToListPriceIndexesMap.put(plp.Product__c, plpByIndexMap);
            }
            else {
                plpByIndexMap = productToListPriceIndexesMap.get(plp.Product__c);
            }

            plpByIndexMap.put((Integer) plp.Index_Order_Number__c, plp);
            system.debug('PJ PJ PJ plpByIndexMap  ::::  '+plpByIndexMap);
        }
        
		 system.debug('PJ PJ PJ quoteLinesByProductMap  ::::  '+quoteLinesByProductMap);
        
        // We now have Quote Lines grouped by Product, and Product List Prices by Product.
        // Now we just need to loop through the product keys and update values
        for (Id productId : quoteLinesByProductMap.keySet()) {
            Map<Id, List<SBQQ__QuoteLine__c>> requiredByQuoteLineMap = quoteLinesByProductMap.get(productId);
            for (Id requiredById : requiredByQuoteLineMap.keySet()) {
                // Lowest PLP Index is likely to always be 1, but I don't know this for a fact
                // Lowest QL Number can literally be anything, but whatever that is should essentially correspond
                // to lowestPLPIndex
                Integer lowestPLPIndex = -1;
                Integer lowestQLNumber = -1;

                // Not sure if ever Quote Line will ALWAYS have a corresponding PLP Product here. Null check, just in case
                Map<Integer, Product_List_Price__c> plpByIndexMap = productToListPriceIndexesMap.get(productId);
                List<SBQQ__QuoteLine__c> qlList = requiredByQuoteLineMap.get(requiredById);
                
                if (plpByIndexMap != null && qlList != null) {
                    // Set Lowest PLP Index
                    for (Integer plpIndex : plpByIndexMap.keySet()) {
                        if (lowestPLPIndex == -1) {
                            lowestPLPIndex = plpIndex;
                        }
                        else if (lowestPLPIndex > plpIndex) {
                            lowestPLPIndex = plpIndex;
                        }
                    }

                    // Set Lowest QL  Number
                    for (SBQQ__QuoteLine__c ql : qlList) {
                        if (lowestQLNumber == -1) {
                            lowestQLNumber = (Integer) ql.SBQQ__Number__c;
                        }
                        else if (lowestQLNumber > ql.SBQQ__Number__c) {
                            lowestQLNumber = (Integer) ql.SBQQ__Number__c;
                        }
                    }

                    // We need the difference because these are locked to incrementing order
                    // Subtract the Lowest PLP Index from the QL Number, because the QL Number
                    // Will almost always start at 2 or higher
                    Integer indexDifference = lowestQLNumber - lowestPLPIndex;

                    for (SBQQ__QuoteLine__c ql : qlList) {
                        Product_List_Price__c plp = plpByIndexMap.get((Integer) ql.SBQQ__Number__c - indexDifference);
                        if (ql.Per_Quantity__c == '1') {
                            if (ql.SBQQ__ListPrice__c != plp.List_Price_Per_1__c) {
                                ql.SBQQ__ListPrice__c = plp.List_Price_Per_1__c;
                                quoteLinesToUpdate.add(ql);
                            }

                            if (ql.SBQQ__Number__c == lowestQLNumber) {
                                SBQQ__QuoteLine__c parentQuote = parentQuoteLinesMap.get(requiredById);
                                if (parentQuote.SBQQ__ListPrice__c != plp.List_Price_Per_1__c) {
                                    parentQuote.SBQQ__ListPrice__c = plp.List_Price_Per_1__c;
                                    quoteLinesToUpdate.add(parentQuote);
                                }
                            }
                        }
                        else if (ql.Per_Quantity__c == '10') {
                            if (ql.SBQQ__ListPrice__c != plp.List_Price_Per_10__c) {
                                ql.SBQQ__ListPrice__c = plp.List_Price_Per_10__c;
                                quoteLinesToUpdate.add(ql);
                            }

                            if (ql.SBQQ__Number__c == lowestQLNumber) {
                                SBQQ__QuoteLine__c parentQuote = parentQuoteLinesMap.get(requiredById);
                                if (parentQuote.SBQQ__ListPrice__c != plp.List_Price_Per_10__c) {
                                    parentQuote.SBQQ__ListPrice__c = plp.List_Price_Per_10__c;
                                    quoteLinesToUpdate.add(parentQuote);
                                }
                            }
                        }
                        else if (ql.Per_Quantity__c == '100') {
                            
                            system.debug('plp.List_Price_Per_100__c  :::   '+plp.List_Price_Per_100__c);
                            system.debug('SBQQ__ListPrice__c   :::   '+ql.SBQQ__ListPrice__c);
                            system.debug('SAP_Sales_Org__c   :::   '+ql.SAP_Sales_Org__c);
                            system.debug('plp.Sales_Organization__r.Sales_Organization_Code__c  :::   '+plp.Sales_Organization__r.Sales_Organization_Code__c);
                            
                            if (ql.SBQQ__ListPrice__c != plp.List_Price_Per_100__c && ql.SAP_Sales_Org__c == plp.Sales_Organization__r.Sales_Organization_Code__c) {
                               // ql.SBQQ__ListPrice__c = plp.List_Price_Per_100__c;
                               ql.New_Delivered_Price__c = plp.List_Price_Per_100__c;
                               ql.New_Price_Start_Date__c = priceStartDate; 
                               ql.New_Price_Firm_Date__c = priceEndDate;
                              
                                 system.debug('AFTER ASSIGNMEN New_Delivered_Price__c   :::   '+ql.New_Delivered_Price__c);
                                quoteLinesToUpdate.add(ql);
                            }
                            system.debug('PJ PJ PJ QUote Line SBQQ__Number__c :::: '+ ql.SBQQ__Number__c);
                            if (ql.SBQQ__Number__c == lowestQLNumber) {
                                system.debug('PJ PJ PJ FIRST INSIDE IF ');
                                SBQQ__QuoteLine__c parentQuote = parentQuoteLinesMap.get(requiredById);
                                if (parentQuote.SBQQ__ListPrice__c != plp.List_Price_Per_100__c && ql.SAP_Sales_Org__c == plp.Sales_Organization__r.Sales_Organization_Code__c) {
                                    system.debug('PJ PJ PJ 2ND INSIDE IF ');
                                    //parentQuote.SBQQ__ListPrice__c = plp.List_Price_Per_100__c;
                                    parentQuote.New_Delivered_Price__c = plp.List_Price_Per_100__c;
                                    parentQuote.New_Price_Start_Date__c = priceStartDate; 
                                    parentQuote.New_Price_Firm_Date__c = priceEndDate;
                                    quoteLinesToUpdate.add(parentQuote);
                                }
                            }
                        }
                    }
                }
            }
        }

        if (!quoteLinesToUpdate.isEmpty()) {
            try {
                SBQQ.TriggerControl.disable(); //12/21/22
                update quoteLinesToUpdate;
                SBQQ.TriggerControl.enable(); //12/21/22
            }
            catch (Exception ex) {
                System.debug('SimplusGridController handleScalePricingUpdateFromProductListPrice encountered an error during SOQL update.');
                System.debug(ex.getMessage());
            }
        }
    }
    
    @AuraEnabled 
    public static user fetchUser(){
        User u = [SELECT Id, Name, Mass_Pricing_Lock_Column__c, Approval_Lock_Column__c FROM User WHERE id =: userInfo.getUserId()];
        return u;
    }
    
    
    @AuraEnabled 
    public static void saveUserDetail(Integer noOfColumns){ 
        User u = [SELECT Id, Name, Mass_Pricing_Lock_Column__c FROM User WHERE id =: userInfo.getUserId()];
        u.Mass_Pricing_Lock_Column__c = noOfColumns;
        update u;
    }
    
    @AuraEnabled 
    public static void saveUserApproval(Integer noOfColumns){       
        User u = [SELECT Id, Name, Approval_Lock_Column__c FROM User WHERE id =: userInfo.getUserId()];
        u.Approval_Lock_Column__c = noOfColumns;
        update u;
    }
    
    //validateQuotesForCloning method
    @AuraEnabled
    public static Boolean validateQuotesForCloning(List<Id> quoteLineIds) {
        Set<Id> mainProductLineIds = new Set<Id>();
        Set<Id> parentQLIds = new Set<Id>();
        Map<Id, Set<Id>> mainToScaleMap = new Map<Id, Set<Id>>();

        List<Id> idList = new List<Id>();
        List<SBQQ__QuoteLine__c> quoteLines = [SELECT Id FROM SBQQ__QuoteLine__c WHERE Id IN :quoteLineIds AND Product_Level__c = 'GMID'];

        for (SBQQ__QuoteLine__c quoteLine : quoteLines) {
            idList.add(quoteLine.Id);
        }
        if (idList.isEmpty()) {
            return false; // No main product line items
        }

        for (SBQQ__QuoteLine__c parentQl : [SELECT Id, Product_Level__c, SBQQ__RequiredBy__c FROM SBQQ__QuoteLine__c WHERE Id IN :quoteLineIds AND Product_Level__c = 'Scale' AND SBQQ__RequiredBy__c != null]){
            parentQLIds.add(parentQl.SBQQ__RequiredBy__c);
        }

        for (SBQQ__QuoteLine__c quoteLine : [SELECT Id, Product_Level__c, SBQQ__RequiredBy__c FROM SBQQ__QuoteLine__c WHERE Id IN :quoteLineIds OR SBQQ__RequiredBy__c IN :quoteLineIds ORDER by Product_Level__c]) {
            system.debug('quoteLine  :::   '+quoteLine.id);
            if (quoteLine.Product_Level__c == 'GMID') {
                mainProductLineIds.add(quoteLine.Id);
                mainToScaleMap.put(quoteLine.Id, new Set<Id>());
            } else if (quoteLine.Product_Level__c == 'Scale' && mainProductLineIds.contains(quoteLine.SBQQ__RequiredBy__c)) {
                system.debug('Scale  :::   '+quoteLine.id);
                Set<Id> scaleLineIds = mainToScaleMap.get(quoteLine.SBQQ__RequiredBy__c);
                scaleLineIds.add(quoteLine.Id);
                mainToScaleMap.put(quoteLine.SBQQ__RequiredBy__c, scaleLineIds);
            }
            system.debug('mainProductLineIds  :::   '+mainProductLineIds);
            system.debug('mainToScaleMap  :::   '+mainToScaleMap);
        }

        for (Id key : parentQLIds) {
            if (!idList.contains(key)) {
                return false;
            }
        }

        Set<Id> quoteLineIdSet = new Set<Id>(quoteLineIds);

        for (Set<Id> scaleLineIds : mainToScaleMap.values()) {
            if (!quoteLineIdSet.containsAll(scaleLineIds)) {
                system.debug('scaleLineIds  :::   '+scaleLineIds);
                return false; // Not all scale line items related to a main product line are selected
            }
        }

        return true; // All scale line items related to main product lines are selected or there are no main product line items
    }
    
    //getQuotesForCloning method

    @AuraEnabled
    public static List<SBQQ__QuoteLine__c> getQuotesForCloning(List<Id> quoteLineIds) {
        return [SELECT SBQQ__Quote__c, SBQQ__Quote__r.Name, SBQQ__Quote__r.SBQQ__EndDate__c, 
                    Id, Name, Price_Request_Account__c, Price_Request_Account__r.Name, Ship_To_Account__c, 
                    Ship_To_Account__r.Name, ProductName_Concatenated__c, SBQQ__ProductName__c, SBQQ__ListPrice__c, 
                    New_Base_Price__c, New_Delivered_Price__c, Current_Price__c, New_Price_Firm_Date__c, 
                    New_Price_Start_Date__c, Price_Change_Frequency__c, Price_Firm_Date__c,
                	Material_Type__c, Netback_Price_4_dcmls__c, SBQQ__TotalDiscountRate__c, CUPS_End_User__c, CUPS_End_User__r.Name,
                	CUPS_End_User2__c, CUPS_End_User2__r.Name, CUPS_End_User3__c, CUPS_End_User3__r.Name, CUPS_End_User4__c, CUPS_End_User4__r.Name
                FROM SBQQ__QuoteLine__c 
                WHERE Id IN :quoteLineIds 
                    AND (Product_Level__c = 'GMID' OR Product_Level__c = 'Scale')];
    }
    
    @AuraEnabled
    public static FieldSetWrapperGroup sortColumns(String objWrapper, String objWrapperList, String mainListSource){
        if(mainListSource == null || mainListSource == '') mainListSource = DEFAULT_LIST_SOURCE;
        List<SortColumWrapper> lstSortWrapper = (List<SortColumWrapper>)JSON.deserialize(objWrapperList, List<SortColumWrapper>.class);
        SortColumWrapper sortWrapper = (SortColumWrapper)JSON.deserialize(objWrapper, SortColumWrapper.class);
        system.debug('sortWrapper >> ' + sortWrapper);
        
        SimplusGrid_Sorting__c newSortingRec = new SimplusGrid_Sorting__c();
        newSortingRec.OwnerId = sortWrapper.sortUser;
        newSortingRec.Column__c = sortWrapper.sortColumn;
        newSortingRec.Column_Name__c = sortWrapper.sortColumnName;
        newSortingRec.Order__c = sortWrapper.sortOrder;
        newSortingRec.Priority__c = lstSortWrapper.size() + 1;
        newSortingRec.Active__c = true;
        newSortingRec.List_Source__c = mainListSource;
        insert newSortingRec;
        sortWrapper.id = newSortingRec.Id;
        lstSortWrapper.add(sortWrapper);
        for(SortColumWrapper wrapper : lstSortWrapper) {
            wrapper.sortCurrentOrder = sortWrapper.sortOrder;
        }
        lstSortWrapper.sort();
        
        FieldSetWrapperGroup sortGroup = new FieldSetWrapperGroup();
        sortGroup.sortingWrapper = lstSortWrapper;
        sortGroup.sortingOrderResult = dynamicQuerySort(mainListSource);
        return sortGroup;
    }
    
    @AuraEnabled
    public static FieldSetWrapperGroup filterColumns(String objWrapper, String objWrapperList, String mainListSource){
        if(mainListSource == null || mainListSource == '') mainListSource = DEFAULT_LIST_SOURCE;
        List<FilterColumWrapper> lstFilterWrapper = (List<FilterColumWrapper>)JSON.deserialize(objWrapperList, List<FilterColumWrapper>.class);
        FilterColumWrapper filterWrapper = (FilterColumWrapper)JSON.deserialize(objWrapper, FilterColumWrapper.class);
        system.debug('filterWrapper >> ' + JSON.serialize(filterWrapper));
        
        SimplusGrid_Filtering__c newFilteringRec = new SimplusGrid_Filtering__c();
        newFilteringRec.OwnerId = filterWrapper.filterUser;
        newFilteringRec.Column__c = filterWrapper.filterColumn;
        newFilteringRec.Column_Name__c = filterWrapper.filterColumnName;
        newFilteringRec.Column_Type__c = filterWrapper.filterColumnType;
        newFilteringRec.Operation__c = filterWrapper.filterOperation;
        newFilteringRec.Value__c = filterWrapper.filterValue;
        newFilteringRec.Priority__c = lstFilterWrapper.size() + 1;
        newFilteringRec.Active__c = true;
        newFilteringRec.List_Source__c = mainListSource;
        insert newFilteringRec;
        system.debug('INSERT >> ' + JSON.serialize(newFilteringRec));
        filterWrapper.id = newFilteringRec.Id;
        lstFilterWrapper.add(filterWrapper);
        
        FieldSetWrapperGroup filterGroup = new FieldSetWrapperGroup();
        filterGroup.filteringWrapper = lstFilterWrapper;
        filterGroup.filteringOrderResult = dynamicQueryFilter(mainListSource);
        return filterGroup;
    }
    
    public class FieldGridControl {
        @AuraEnabled public String name;
        @AuraEnabled public String label;
        @AuraEnabled public Boolean editable;
        @AuraEnabled public Boolean enableMassUpdate;
        @AuraEnabled public String massUpdateType;
        @AuraEnabled public String massUpdateParams;
        @AuraEnabled public String multiDecision;
        @AuraEnabled public Decimal sortOrder;
        
        public FieldGridControl(SimplusGridControlField__mdt control) {
            this.name = control.FieldApi__c;
            this.label = control.MasterLabel;
            this.editable = control.Editable__c;
            this.enableMassUpdate = control.EnableMassUpdate__c;
            this.massUpdateType = control.MassUpdateType__c;
            this.massUpdateParams = control.MultiUpdateParameters__c;
            this.sortOrder = control.SortOrder__c;
            this.multiDecision = control.MultiFieldDecision__c;
        }
    }
    
    public class FieldSetConfig {
        @AuraEnabled public String name {get;set;}
        @AuraEnabled public String type {get;set;}
    }
    
    public class FieldSetWrapper {
        @AuraEnabled public String fieldLabel {get;set;}
        @AuraEnabled public Boolean fieldRequired {get;set;}
        @AuraEnabled public String fieldType {get;set;}
        @AuraEnabled public String fieldName {get;set;}
        @AuraEnabled public Boolean fieldEditable {get;set;}
    }
    
    public class FieldSetWrapperGroup {
        @AuraEnabled public List<FieldSetWrapper> sortingFieldSet {get;set;}
        @AuraEnabled public List<FieldSetWrapper> filteringFieldSet {get;set;}
        @AuraEnabled public List<SortColumWrapper> sortingWrapper {get;set;}
        @AuraEnabled public List<FilterColumWrapper> filteringWrapper {get;set;}
        @AuraEnabled public String sortingOrderResult {get;set;}
        @AuraEnabled public String filteringOrderResult {get;set;}
        @AuraEnabled public List<sObject> lstObject {get;set;}
        @AuraEnabled public Integer pageMax {get;set;}
        @AuraEnabled public Boolean isBeyond = false;
    }
    
    public class SortColumWrapper implements Comparable {
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String sortUser {get;set;}
        @AuraEnabled public String sortColumn {get;set;}
        @AuraEnabled public String sortColumnName {get;set;}
        @AuraEnabled public String sortOrder {get;set;}
        @AuraEnabled public Integer sortPriority {get;set;}
        @AuraEnabled public String sortCurrentOrder {get;set;}
        @AuraEnabled public Boolean isActive {get;set;}
        
        public Integer compareTo(Object compareTo) {
            SortColumWrapper compareColumn = (SortColumWrapper)compareTo;
            if(sortCurrentOrder == 'ASC') {
                if(sortPriority == compareColumn.sortPriority) return 0;
                if(sortPriority < compareColumn.sortPriority) return -1;
                return 1;   
            } else {
                if(sortPriority == compareColumn.sortPriority) return 0;
                if(sortPriority < compareColumn.sortPriority) return 1;
                return -1;   
            }
        }
    }
    
    public class FilterColumWrapper {
        @AuraEnabled public String id {get;set;}
        @AuraEnabled public String filterUser {get;set;}
        @AuraEnabled public String filterColumn {get;set;}
        @AuraEnabled public String filterColumnName {get;set;}
        @AuraEnabled public String filterColumnType {get;set;}
        @AuraEnabled public String filterOperation {get;set;}
        @AuraEnabled public String filterValue {get;set;}
        @AuraEnabled public Integer filterPriority {get;set;}
        @AuraEnabled public Boolean isActive {get;set;}
        @AuraEnabled public Boolean isGlobal {get;set;}
    }
    
    @AuraEnabled
    public static void approveQuoteApproval(Id recordId, String comments) {
        
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get('SBAA__Approval__c').getDescribe().fields.getMap();
        String query = '';
        for(String s : fieldMap.keySet()) {
            query += ',' + s;
        }
        query = query.substring(1, query.length());
        query = 'SELECT ' + query + ' FROM SBAA__Approval__c WHERE Id = \'' + recordId + '\'';
        List<sObject> results = Database.query(query);
        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(results[0]);
        sbaa.ApprovalExtController aec = new sbaa.ApprovalExtController(sc);
        aec.comments = comments;
        aec.onApprove();
    }

    @AuraEnabled
    public static String getApproverName(String approvalId) {
        SBAA__Approval__c approval = [SELECT Quote_Line__c, Approver_Name__c FROM SBAA__Approval__c WHERE Id = :approvalId LIMIT 1];
        return approval.Approver_Name__c; 
    }
    
    @AuraEnabled
    public static SBQQ__QuoteLine__c getLineFromApproval(String approvalId) {
        SBAA__Approval__c approval = [SELECT Quote_Line__c FROM SBAA__Approval__c WHERE Id = :approvalId LIMIT 1];
        SBQQ__QuoteLine__c quoteLine = [SELECT Id, Name, ProductName_Concatenated__c, Ship_To_City_State_Country__c,
            Ship_From_Name__c, New_Delivered_Price__c, Previous_Price__c, Previous_Price_Value__c, Price_Change_Frequency__c, Min_Volume__c,
            Scale_UOM__c, Per_Quantity__c, SBQQ__UnitCost__c, CurrencyIsoCode, SBQQ__Quote__c, SBQQ__Product__c,
            SBQQ__ProductName__c, Product_Discount_Amount__c, Discount_Percent__c, SBQQ__StartDate__c, SBQQ__EndDate__c, 
            CUPS_End_User__r.Name, CUPS_Support_Price__c, CUPS_Discount_Percent__c, CUPS_Start_Date__c, CUPS_End_Date__c, SBQQ__ListPrice__c,
            CUPS_End_User2__r.Name, CUPS_Support_Price2__c, CUPS_Discount_Percent2__c, CUPS_Start_Date2__c, CUPS_End_Date2__c, 
            CUPS_End_User3__r.Name, CUPS_Support_Price3__c, CUPS_Discount_Percent3__c, CUPS_Start_Date3__c, CUPS_End_Date3__c, 
            CUPS_End_User4__r.Name, CUPS_Support_Price4__c, CUPS_Discount_Percent4__c, CUPS_Start_Date4__c, CUPS_End_Date4__c, 
            Competitive_Distributor__c, Competitor_Product__c, Competitive_Price__c, Competitive_Distributor__r.Name,
            Competitor_Product__r.Name
            FROM SBQQ__QuoteLine__c WHERE Id = :approval.Quote_Line__c];
        return quoteLine; 
    }
    @AuraEnabled
    public static List<SBQQ__QuoteLine__c> getLinesFromApproval(String quoteId) {
        List<SBQQ__QuoteLine__c> quoteLines = [SELECT Id, Name, SBQQ__ProductName__c, SBQQ__ListPrice__c, CurrencyIsoCode, 
            SBQQ__ProductOption__r.SBQQ__Feature__r.SBQQ__Category__c, Display_Price_Whole_Numbers__c, Discount_Percent__c, 
            Scale_UOM__c, Per_Quantity__c, SBQQ__UnitCost__c, SBQQ__StartDate__c, SBQQ__EndDate__c, Min_Volume__c, Product_Level__c, 
            Validity_Start_Date__c, Validity_End_Date__c, SBQQ__ProductOption__r.SBQQ__ConfiguredSKU__c, SBQQ__Quote__c FROM SBQQ__QuoteLine__c 
            WHERE SBQQ__Quote__c = :quoteId];
        return quoteLines; 
    }
    
    //get all related lines through SBQQ__RequiredBy__c [TKT-107 by PJ Buanghug]
    @AuraEnabled
    public static List<SBQQ__QuoteLine__c> getLinesToApprove(String quoteLineId) {
        List<SBQQ__QuoteLine__c> quoteLines = [SELECT Id, Name, SBQQ__ProductName__c, SBQQ__ListPrice__c, CurrencyIsoCode, Previous_Price__c, Previous_Price_Value__c, 
            SBQQ__ProductOption__r.SBQQ__Feature__r.SBQQ__Category__c, Display_Price_Whole_Numbers__c, Discount_Percent__c, 
            Scale_UOM__c, Per_Quantity__c, SBQQ__UnitCost__c, SBQQ__StartDate__c, SBQQ__EndDate__c, Min_Volume__c, Product_Level__c, 
            Validity_Start_Date__c, Validity_End_Date__c, SBQQ__ProductOption__r.SBQQ__ConfiguredSKU__c, SBQQ__Quote__c FROM SBQQ__QuoteLine__c 
            WHERE SBQQ__RequiredBy__c = :quoteLineId];
        return quoteLines; 
    }
    
    
    /*@AuraEnabled
    public static List<sbaa__Approval__c> getLinesFromApproval() {

        //SBAA__Approval__c approval = [SELECT Quote_Line__c,Quote__c FROM SBAA__Approval__c WHERE Id = :approvalId LIMIT 1];
        /*List<SBQQ__QuoteLine__c> quote = [SELECT Id, Name, ProductName_Concatenated__c, Ship_To_City_State_Country__c, Ship_From_Name__c
        , Ship_From_Source_Type__c, Shipping_Condition_Label__c, Incoterm_Label__c, Price_Period_Volume__c, Price_Change_Frequency__c
        , Validity_Period__c, Formula__c, CurrencyIsoCode, UOM__c, Per_Quantity__c
        FROM SBQQ__QuoteLine__c Limit 10 ];*//*

        List<sbaa__Approval__c> approval = [SELECT Id, Name,Quote_Line__c, Quote_Line__r.Name, sbaa__AssignedTo__r.Name 
        , sbaa__AssignedTo__c, Quote_Line_Status__c, sbaa__Status__c, PendingMassApprovalRequest__c
        FROM sbaa__Approval__c 
        WHERE sbaa__AssignedTo__c=:UserInfo.getUserId()  AND Quote_Line_Status__c =:'Pending' 
          AND sbaa__Status__c =:'Requested' AND PendingMassApprovalRequest__c = false];

        System.debug('approvals list ======'+approval);
        return approval;
    }*/
    

    @AuraEnabled   
    public static string getmydomain(){   
        String urlInstance = String.valueof(System.URL.getSalesforceBaseURL().gethost());
        String s2 = urlInstance.removeEndIgnoreCase('.my.salesforce.com');
        return s2;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<LookupSearchResult> getLookupResults(String searchTerm, String sObjType, String field) {
        // Describe parent object
        Schema.DescribeSObjectResult sObjDescribe = Schema.getGlobalDescribe().get(sObjType).getDescribe();
        String objectLabel = sObjDescribe.getLabel();
        String lookupObject = sObjDescribe.fields.getMap().get(field).getDescribe().getReferenceTo()[0].getDescribe().getName();
        String lookupObjectLabel = sObjDescribe.fields.getMap().get(field).getDescribe().getReferenceTo()[0].getDescribe().getLabel();

        searchTerm = searchTerm + '%';
        // Execute query
        List<SObject> sObjList = Database.query('SELECT Id, Name ' +
                                                    '   FROM ' + lookupObject + '   ' +
                                                    '   WHERE Name LIKE :searchTerm LIMIT 10');
        
        // Prepare results
        List<LookupSearchResult> results = new List<LookupSearchResult>();

        // Convert each sobject to LookupSearchResult
        for (SObject sObj : sObjList) {
            results.add(
                new LookupSearchResult(
                    (Id) sObj.get('Id'),
                    lookupObjectLabel,
                    'standard:default',
                    (String) sObj.get('Name'),
                    lookupObjectLabel
                )
            );
        }

        results.sort();

        return results;
    }

    @AuraEnabled
    public static void massApproveReject(List<Id> approvalIds, Boolean doApprove, String comments){
        System.enqueueJob(new QuoteApproveRejectQueueable(approvalIds, doApprove, comments));
    }

    @AuraEnabled
    // public static void approveReject(Id approvalId, Boolean doApprove, String comments) {
    //     update new sbaa__Approval__c(Id = approvalId, PendingMassApprovalRequest__c = true);
    //     QuoteApprovalService.approveReject(approvalId, doApprove, comments);
    // }

    public static void approveReject(String approvalId, Boolean doApprove, String comments) {
        system.debug('>>>>>>> TEST APPROVAL JSON >>>>>>>'+approvalId);
        Type idArrType = Type.forName('List<Id>');
        List<Id> wrapperList = (List<Id>) JSON.deserialize(approvalId, idArrType);
        List<sbaa__Approval__c> lApproval = new List<sbaa__Approval__c>();

       
        for (Id apprId : wrapperList) {
            system.debug('>>>>>>> TEST APPROVAL DESERIALIZE>>>>>>>'+apprId);
            lApproval.add(new sbaa__Approval__c(Id = apprId, PendingMassApprovalRequest__c = true));
        }

        SBQQ.TriggerControl.disable();
        update lApproval;
        SBQQ.TriggerControl.enable();

        QuoteApprovalService.approveReject(wrapperList, doApprove, comments);
    }
    
    
    @AuraEnabled
    Public static List<sbaa__Approval__c> getAllApprovals(){
        String currentUser = userInfo.getUserId();
        List<sbaa__Approval__c> approvalList = [SELECT id,Quote_Line__r.Name ,Name
                                                From sbaa__Approval__c 
                                                Where sbaa__AssignedTo__c  =:currentUser
                                                AND Quote_Status__c ='Submitted for Approval' 
                                                AND sbaa__Status__c = 'Requested' 
                                                AND PendingMassApprovalRequest__c = false];
        return approvalList;
    }
    
   @AuraEnabled
    public static Map<Id, Decimal> retrievedProductListPrice (List<Id> quoteLineIds, Date priceStartDate, Date priceEndDate){
       // try{
            system.debug('PJ PJ PJ retrievedProductListPrice quoteLineIds :::::: '+quoteLineIds);
            Map<Id, Decimal> quoteLinePriceListMap = new Map<Id, Decimal>();
            List<SBQQ__QuoteLine__c> distributorLineList = new List<SBQQ__QuoteLine__c>();
            Set<Id> productIdSet = new Set<Id>();
            Set<String> salesOrgSet = new Set<String>();
            
            List<SBQQ__QuoteLine__c> quoteLineList = [SELECT Id, SBQQ__Quote__r.Name, SBQQ__Quote__r.SBQQ__Uncalculated__c, SBQQ__RequiredBy__r.SBQQ__Product__c,
                                                      SBQQ__RequiredBy__c, SBQQ__Quote__r.SBQQ__Distributor__c, SBQQ__Product__c, Distributor__c, SAP_Sales_Org__c,
                                                      SBQQ__Number__c, Per_Quantity__c, SBQQ__ListPrice__c, SBQQ__Quote__c
                                                      FROM SBQQ__QuoteLine__c WHERE Id IN :quoteLineIds];
            for (SBQQ__QuoteLine__c ql : quoteLineList) {
                if (ql.Distributor__c) {
                    salesOrgSet.add(ql.SAP_Sales_Org__c);
                    distributorLineList.add(ql);

                    if (ql.SBQQ__RequiredBy__c != null) {
                        productIdSet.add(ql.SBQQ__RequiredBy__r.SBQQ__Product__c);
                    } else {
                        productIdSet.add(ql.SBQQ__Product__c);
                    }
                }
            }
            system.debug('PJ PJ PJ distributorLineList :::::: '+distributorLineList);
            List<Product_List_Price__c> productListPriceList = [SELECT Id, Valid_From__c, Valid_To__c, 
                                                                Index_Order_Number__c, Product__c, Per_Quantity__c, List_Price__c, Sales_Organization__r.Sales_Organization_Code__c,
                                                                List_Price_Per_1__c, List_Price_Per_10__c, List_Price_Per_100__c
                                                                FROM Product_List_Price__c 
                                                                WHERE Product__c IN :productIdSet
                                                                AND Valid_From__c <= :priceStartDate
                                                                AND Valid_To__c >= :priceEndDate
                                                                AND Sales_Organization__r.Sales_Organization_Code__c IN :salesOrgSet
                                                                ORDER BY Index_Order_Number__c];
            
            system.debug('PJ PJ {J productListPriceList   ::::  '+productListPriceList);
            Map<String, Decimal> prodIdSalesOrgIndexMap = new Map<String, Decimal>();
            
            for(Product_List_Price__c prodListPrice : productListPriceList){
                prodIdSalesOrgIndexMap.put(prodListPrice.Product__c+prodListPrice.Sales_Organization__r.Sales_Organization_Code__c+prodListPrice.Index_Order_Number__c, prodListPrice.List_Price_Per_100__c);
            }
            system.debug('PJ PJ {J prodIdSalesOrgIndexMap   ::::  '+prodIdSalesOrgIndexMap);
            List<SBQQ__QuoteLine__c> toUpdateLineList = new List<SBQQ__QuoteLine__c>();
            //SBQQ__QuoteLine__c ql;
            for(SBQQ__QuoteLine__c line : distributorLineList){
                system.debug('SEQUENCE :::: '+ (line.SBQQ__Number__c-1));
                if(line.SBQQ__Number__c-1 == 0){
                    system.debug('PJ PJ PJ KEY KEY :::: '+line.SBQQ__Product__c+line.SAP_Sales_Org__c+'1');
                    quoteLinePriceListMap.put(line.Id, prodIdSalesOrgIndexMap.get(line.SBQQ__Product__c+line.SAP_Sales_Org__c+'1'));
                    //line.New_Delivered_Price__c = prodIdSalesOrgIndexMap.get(line.SBQQ__Product__c+line.SAP_Sales_Org__c+'1');
                }else{ 
                    system.debug('PJ PJ PJ KEY KEY :::: '+line.SBQQ__Product__c+line.SAP_Sales_Org__c+(line.SBQQ__Number__c-1));
                    quoteLinePriceListMap.put(line.Id, prodIdSalesOrgIndexMap.get(line.SBQQ__RequiredBy__r.SBQQ__Product__c+line.SAP_Sales_Org__c+(line.SBQQ__Number__c-1)));
                    //line.New_Delivered_Price__c = prodIdSalesOrgIndexMap.get(line.SBQQ__Product__c+line.SAP_Sales_Org__c+(line.SBQQ__Number__c-1));
                }
               // toUpdateLineList.add(line);
                System.debug('PJ PJ PJ toUpdateLineList :::  '+toUpdateLineList);
            }
            system.debug('PJ PJ PJ quoteLinePriceListMap :::  '+quoteLinePriceListMap);
            return quoteLinePriceListMap;
       // }catch(Exception e){
           // throw new AuraHandledException('ERROR : '+e.getMessage());    
            
        //}
        
    }

}