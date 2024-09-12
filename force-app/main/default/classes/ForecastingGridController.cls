public with sharing class ForecastingGridController {
    public static final String DEFAULT_LIST_SOURCE = 'GridForecasting';
    public static final String DEFAULT_CHANGE_TRACKER = '000000000000000000000000000000000000';
    public static Integer DEFAULT_PAGE_SIZE = 40; //changed by Ajay Choudhary
    private static Integer pageMax = 1;
    public static Boolean isBeyond = false;
    public static Boolean preventLoadDml = false;
    
    @AuraEnabled
    public static string getUserRole() {
        String ret = 'viewer';
        List<PermissionSetAssignment> perms = [SELECT Id, PermissionSetId, PermissionSet.Name
                                               FROM PermissionSetAssignment
                                               WHERE AssigneeId = :Userinfo.getUserId() AND PermissionSet.Name IN ('ForecastingAccountRepresentative', 'ForecastingAccountManager')];
        if(perms.size() == 1) {
            ret = perms[0].PermissionSet.Name;
        } else if(perms.size() > 1){
            ret = 'rep_mgr';
        }
        return ret;
    }
    
    @AuraEnabled
    public static Map<String, FieldGridControl> getControlFields(List<String> fieldSetNames){
        Map<String, FieldGridControl> fieldAccess = new Map<String, FieldGridControl>();
        for(SimplusGridControlField__mdt gfa : [SELECT Id,FieldApi__c,MasterLabel,Editable__c,EnableMassUpdate__c,MassUpdateType__c,MultiUpdateParameters__c,SortOrder__c
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
       //Added By Ajay Choudhary ---30th Jan 2023--------Start-----------> Column show/hide functionality
        Map<String, Forecasting_Columns_Config__c> columnConfigMap = new Map<String, Forecasting_Columns_Config__c>();
        for(Forecasting_Columns_Config__c config : [SELECT Column_Name__c, Active__c FROM Forecasting_Columns_Config__c WHERE OwnerId =: UserInfo.getUserId()]){
            columnConfigMap.put(config.Column_Name__c, config);
        }
        //Added By Ajay Choudhary ---30th Jan 2023--------End-----------> Column show/hide functionality
        Map<String, FieldGridControl> fieldAccess = getControlFields(fieldSetNames);
        
        //GET SCHEMA DEFINITION TO CHECK IF FIELD IS EDITABLE ON A PROFILE LEVEL
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Forecast__c.fields.getMap();
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
                    if(f.getLabel() != 'Unique Id' && f.getLabel() != 'Name'){ //---------Added By Ajay
                        FieldSetWrapper fs = new FieldSetWrapper();
                        if(f.getLabel().contains('Billing')) {
                            List<String> newLabel = f.getLabel().split(' ');
                            fs.fieldLabel = newLabel[1];
                        } else {
                            fs.fieldLabel = f.getLabel();
                        }
                        fs.fieldRequired = f.getDBRequired() || f.getRequired();
                        fs.fieldType = string.valueOf(f.getType());
                        fs.fieldName = f.getFieldPath();
                        if(columnConfigMap.containsKey(fs.fieldLabel)){                     //Added By Ajay Choudhary ---30th Jan 2023-----Start-------> Column show/hide functionality
                            fs.showFieldColumn = columnConfigMap.get(fs.fieldLabel).Active__c;
                            fs.columnConfigId = columnConfigMap.get(fs.fieldLabel).Id;
                        }
                        else{
                            fs.columnConfigId = '';
                            fs.showFieldColumn = true;
                        }                                                                 //Added By Ajay Choudhary ---30th Jan 2023------End-------> Column show/hide functionality
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
            }
            
            if(FsMap.containsKey(filterFieldSet)) {
                List<FieldSetWrapper> fieldSetWrapperClass = new List<FieldSetWrapper>();
                fieldSetWrapperClassList.filteringFieldSet = new List<FieldSetWrapper>();
                for(Schema.FieldSetMember f : FsMap.get(filterFieldSet).getFields()) {
                    FieldSetWrapper fs = new FieldSetWrapper();
                    if(f.getLabel().contains('Billing')) {
                        List<String> newLabel = f.getLabel().split(' ');
                        fs.fieldLabel = newLabel[1];
                    } else {
                        fs.fieldLabel = f.getLabel();
                    }
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
            
            fieldSetWrapperClassList.sortingWrapper = querySort(mainListSource); //lstSortingWrapper;
            fieldSetWrapperClassList.filteringWrapper = queryFilter(mainListSource); //lstFilteringWrapper;
            fieldSetWrapperClassList.sortingOrderResult = dynamicQuerySort(mainListSource); // Dynamic query for Sorting
            fieldSetWrapperClassList.filteringOrderResult = dynamicQueryFilter(mainListSource); // Dynamic query for Filtering
            system.debug('fieldSetWrapperClassList >> ' + fieldSetWrapperClassList);
            
            Set<String> setfieldNames = new Set<String>();
            for(FieldSetWrapper fs : fieldSetWrapperClassList.sortingFieldSet) {
                if(fs.fieldName != null) {
                    setfieldNames.add(fs.fieldName);
                    if(fs.fieldType == 'REFERENCE') {
                        if(fs.fieldName == 'OwnerId') {
                            setfieldNames.add('Owner.Name');
                        } else if(fs.fieldName.indexOf('__c') == -1) {
                            setfieldNames.add(fs.fieldName.substring(0, fs.fieldName.indexOf('Id')) + '.Name');
                        } else {
                            setfieldNames.add(fs.fieldName.substring(0, fs.fieldName.indexOf('__c')) + '__r.Name');
                        }
                    }
                }
            }
            
            String quotelines = getRecords(JSON.serialize(setfieldNames), fieldSetWrapperClassList.sortingOrderResult, fieldSetWrapperClassList.filteringOrderResult, 1, null);
            system.debug('181 >> '+ quotelines);
            List<ForecastWrapper> lstSobject = (List<ForecastWrapper>) JSON.deserialize(quotelines, List<ForecastWrapper>.class);
            fieldSetWrapperClassList.lstObject = lstSobject;
            fieldSetWrapperClassList.pageMax = pageMax;
            fieldSetWrapperClassList.isBeyond = isBeyond;
        }
        catch(Exception e){
            result += e.getLineNumber() + ' : ' + e.getMessage();
            system.debug('RESULT ');
        }
        system.debug('RESULT fieldSetWrapperClassList ' + JSON.serialize(fieldSetWrapperClassList));
        return fieldSetWrapperClassList;
    }
    
    @AuraEnabled
    public static List<SortColumWrapper> querySort(String mainListSource){
        if(mainListSource == null || mainListSource == '') mainListSource = DEFAULT_LIST_SOURCE;
        List<SortColumWrapper> lstSortingWrapper = new List<SortColumWrapper>();
        List<SimplusGrid_Sorting__c> lstSortingRec = [SELECT Id, Column__c, Column_Name__c, Order__c, Priority__c, OwnerId, Active__c
                                                      FROM SimplusGrid_Sorting__c
                                                      WHERE OwnerId =: userInfo.getUserId()
                                                      AND List_Source__c = :mainListSource
                                                      ORDER BY Priority__c];
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
    public static List<FilterColumWrapper> queryFilter(String mainListSource){
        if(mainListSource == null || mainListSource == '') mainListSource = DEFAULT_LIST_SOURCE;
        List<FilterColumWrapper> lstFilteringWrapper = new List<FilterColumWrapper>();
        List<SimplusGrid_Filtering__c> lstFilteringRec = [SELECT Id, Column__c, Column_Name__c, Operation__c, Value__c, Priority__c, OwnerId, Active__c, Global__c, Column_Type__c
                                                          FROM SimplusGrid_Filtering__c
                                                          WHERE (OwnerId =: userInfo.getUserId() OR Global__c = true)
                                                          AND List_Source__c = :mainListSource
                                                          ORDER BY Global__c DESC, Priority__c];
        
        for(SimplusGrid_Filtering__c filteringList : lstFilteringRec) {
            FilterColumWrapper wrapperFilter = new FilterColumWrapper();
            wrapperFilter.id = filteringList.id;
            wrapperFilter.filterUser = filteringList.OwnerId;
            wrapperFilter.filterColumn = filteringList.Column__c;
            wrapperFilter.filterColumnName = filteringList.Column_Name__c;
            wrapperFilter.filterColumnType = filteringList.Column_Type__c;
            wrapperFilter.filterOperation = filteringList.Operation__c;
            wrapperFilter.filterValue = filteringList.Value__c;
            wrapperFilter.filterPriority = integer.valueOf(filteringList.Priority__c);
            wrapperFilter.isActive = filteringList.Active__c;
            wrapperFilter.isGlobal = filteringList.Global__c;
            lstFilteringWrapper.add(wrapperFilter); 
        }
        return lstFilteringWrapper;
    }
    
    //Added by Ajay Choudhary on 30th Sept 2022-------Reference -->Edit Filter Functionality.
    @AuraEnabled
    public static FieldSetWrapperGroup updateFilter(String filter, Integer page, Integer year){
        String listSrc;
        FilterColumWrapper wrapperFilter = (FilterColumWrapper)JSON.deserialize(filter, FilterColumWrapper.class);
        SimplusGrid_Filtering__c f = new SimplusGrid_Filtering__c();
        f.Id = wrapperFilter.id;
        f.Operation__c = wrapperFilter.filterOperation;
        f.Value__c = wrapperFilter.filterValue;
        update f;
        List<SimplusGrid_Filtering__c> filterItem = [SELECT Id, List_Source__c FROM SimplusGrid_Filtering__c WHERE Id = :f.Id LIMIT 1];
        if(!filterItem.isEmpty()) listSrc = filterItem[0].List_Source__c;
        return toggle(listSrc != null ? listSrc : DEFAULT_LIST_SOURCE, page, year);
    }
    
    //Added by Ajay Choudhary ---- 30th Jan 2023 ----> Column Show/Hide functionality
    @AuraEnabled
    public static void updateColumnConfigs(List<Forecasting_Columns_Config__c> columns){
        upsert columns;
    }
    @AuraEnabled
    public static FieldSetWrapperGroup toggle(String mainListSource, Integer page, Integer year){
        if(page == null) page = 1;
        if(mainListSource == null || mainListSource == '') mainListSource = DEFAULT_LIST_SOURCE;
        List<FieldSetConfig> lstFieldSetConfig = new List<FieldSetConfig>();
        FieldSetConfig fieldSetConfig = new FieldSetConfig();
        fieldSetConfig.name = 'GridForecasting';
        fieldSetConfig.type = 'display';
        lstFieldSetConfig.add(fieldSetConfig);
        fieldSetConfig = new FieldSetConfig();
        fieldSetConfig.name = 'GridForecasting_Controls';
        fieldSetConfig.type = 'filter';
        lstFieldSetConfig.add(fieldSetConfig);
        
        FieldSetWrapperGroup filterGroup = new FieldSetWrapperGroup();
        filterGroup = getFieldSet('Forecast__c', lstFieldSetConfig, mainListSource);
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
        String quotelines = getRecords(JSON.serialize(setfieldNames), filterGroup.sortingOrderResult, filterGroup.filteringOrderResult, page, year);
        system.debug('181 >> '+ quotelines);
        List<ForecastWrapper> lstSobject = (List<ForecastWrapper>) JSON.deserialize(quotelines, List<ForecastWrapper>.class);
        filterGroup.lstObject = lstSobject;
        filterGroup.pageMax = pageMax;
        filterGroup.isBeyond = isBeyond;
        return filterGroup;                                             
    }
    
    @AuraEnabled
    public static String dynamicQuerySort(String mainListSource){
        Map<String, Schema.SObjectField> M;
        M = Schema.SObjectType.Forecast__c.fields.getMap();
        if(mainListSource == null || mainListSource == '') mainListSource = DEFAULT_LIST_SOURCE;
        List<SimplusGrid_Sorting__c> lstSortingRec = [SELECT Id, Column__c, Column_Name__c, Order__c, Priority__c, OwnerId, Active__c
                                                      FROM SimplusGrid_Sorting__c
                                                      WHERE OwnerId =: userInfo.getUserId()
                                                      AND List_Source__c = :mainListSource
                                                      ORDER BY Priority__c];
        system.debug('SORT query >> ' + lstSortingRec);
        String sortingQuery = '';
        Integer sortingCount = 0;
        Map<String, Schema.SObjectField> fieldMap;
        
        fieldMap = Schema.SObjectType.Forecast__c.fields.getMap();
        
        for(SimplusGrid_Sorting__c sortingList : lstSortingRec) {
            if(sortingList.Active__c) {
                sortingCount++;
                if(sortingCount > 1) {
                    sortingQuery += ', ';
                } else if(sortingCount == 1) {
                    sortingQuery += ' ORDER BY ';
                }
                
                String col = sortingList.Column__c;
                if(fieldMap.get(sortingList.Column__c).getDescribe().getType() == DisplayType.REFERENCE) {
                    if(col.endsWith('Id')) {
                        col = col.replace('Id', '.Name');
                    } else {
                        col = col.replace('__c', '__r.Name');
                    }
                } 
                sortingQuery += col + ' ' + sortingList.Order__c;
            }
        }
        system.debug('SORT >> ' + sortingQuery);
        return sortingQuery;
    }
    
    @AuraEnabled
    public static String dynamicQueryFilter(String mainListSource){
        Map<String, Schema.SObjectField> M;
        M = Schema.SObjectType.Forecast__c.fields.getMap();
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
                 //Added by Ajay Choudhary on 30th Sept 2022-------Reference -->To Support OR WIth Multiple Values.
                List<String> allValues = new List<String>();
                if(filteringList.Value__c.contains(',')){
                    allValues = filteringList.Value__c.split(',(?=(?:[^\"]*\"[^\"]*\")*[^\"]*$)');
                }
                else{
                    allValues.add(filteringList.Value__c);
                }
                System.debug('allValues=='+allValues);
                String innerFilterString = '(';
                for(Integer i=0;i<allValues.size();i++){
                    String filterValue = allValues[i].replaceAll('"','');
                    String filterUsed = '';
                    //Date formatting for SOQL use.  Use dateTimeValue.formatGMT with format string as comparison.
                    String dateValStr;
                    Date dateValue;
                    Datetime dateTimeValue;
                    if(filteringList.Column_Type__c == 'DATE') {
                        dateValue = date.valueOf(filterValue);
                        dateTimeValue = DateTime.newInstance(dateValue, Time.newInstance(0, 0, 0, 0));
                    } else if (filteringList.Column_Type__c == 'DATETIME') {
                        dateTimeValue = Datetime.valueOf(filterValue);
                    }
                    
                    if(filteringList.Operation__c == 'starts with') {
                        filterUsed = 'LIKE' + ' \'' + filterValue + '%\' ';
                    } else if(filteringList.Operation__c == 'ends with') {
                        filterUsed = 'LIKE' + ' \'%' + filterValue + '\' ';
                    } else if(filteringList.Operation__c == 'contains') {
                        filterUsed = 'LIKE' + ' \'%' + filterValue + '%\' ';
                    } else if(filteringList.Operation__c == 'equals') {
                        filterUsed = '=' + ' \'' + filterValue + '\' ';
                    } else if(filteringList.Operation__c == 'eq') {
                        filterUsed = '= ' + filterValue + ' ';
                    } else if(filteringList.Operation__c == 'lt') {
                        filterUsed = '< ' + filterValue + ' ';
                    } else if(filteringList.Operation__c == 'gt') {
                        filterUsed = '> ' + filterValue + ' ';
                        //---------Added 4/13/2021 By Jimmy Daresta due to missing filter operation of not equal
                    } else if(filteringList.Operation__c == 'not equals') {
                        filterUsed = '<>' + ' \'' + filterValue + '\' ';
                        
                    } else if(filteringList.Column_Type__c == 'DATE' && filteringList.Operation__c == 'equal') {
                        filterUsed = '= ' + String.valueOf(dateValue) + ' ';  //.formatGMT('yyyy-MM-dd') + ' ';
                    } else if(filteringList.Column_Type__c == 'DATETIME' && filteringList.Operation__c == 'equal') {
                        filterUsed = '= ' + dateTimeValue.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ') + ' ';
                        
                        //---------Added 4/13/2021 By Jimmy Daresta due to missing filter operation of not equal
                    } else if(filteringList.Column_Type__c == 'DATE' && filteringList.Operation__c == ' not equals') {
                        filterUsed = '= ' + String.valueOf(dateValue) + ' ';//.formatGMT('yyyy-MM-dd') + ' ';
                    } else if(filteringList.Column_Type__c == 'DATETIME' && filteringList.Operation__c == 'not equals') {
                        filterUsed = '= ' + dateTimeValue.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ') + ' ';
                        
                    } else if(filteringList.Column_Type__c == 'DATE' && filteringList.Operation__c == 'before') {
                        filterUsed = '< ' + String.valueOf(dateValue) + ' ';//.formatGMT('yyyy-MM-dd') + ' ';
                    } else if(filteringList.Column_Type__c == 'DATETIME' && filteringList.Operation__c == 'before') {
                        filterUsed = '< ' + dateTimeValue.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ') + ' ';
                        
                    } else if(filteringList.Column_Type__c == 'DATE' && filteringList.Operation__c == 'after') {
                        filterUsed = '> ' + String.valueOf(dateValue) + ' ';//.formatGMT('yyyy-MM-dd') + ' ';
                    } else if(filteringList.Column_Type__c == 'DATETIME' && filteringList.Operation__c == 'after') {
                        filterUsed = '> ' + dateTimeValue.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ') + ' ';
                    }else if(filteringList.Column_Type__c == 'DATE' && filteringList.Operation__c == 'equal or after') {
                        filterUsed = '>= ' + String.valueOf(dateValue) + ' ';//.formatGMT('yyyy-MM-dd') + ' ';
                    } else if(filteringList.Column_Type__c == 'DATETIME' && filteringList.Operation__c == 'equal or after') {
                        filterUsed = '>= ' + dateTimeValue.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ') + ' ';
                    }else if(filteringList.Column_Type__c == 'DATE' && filteringList.Operation__c == 'equal or before') {
                        filterUsed = '<= ' + String.valueOf(dateValue) + ' ';//.formatGMT('yyyy-MM-dd') + ' ';
                    } else if(filteringList.Column_Type__c == 'DATETIME' && filteringList.Operation__c == 'equal or before') {
                        filterUsed = '<= ' + dateTimeValue.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ') + ' ';
                    }
                    
                    String fieldName = filteringList.Column__c;
                    Schema.SObjectField field = M.get(filteringList.Column__c);
                    System.debug('FIELD >> ' + field);
                    System.debug('FIELDNAME >> ' + fieldName);
                    
                    
                    //Schema.DisplayType FldType = field.getDescribe().getType();
                    //system.debug('FIELD TYPE >> ' + FldType);
                    
                    if(filteringList.Column_Type__c == 'REFERENCE') { //FldType == DisplayType.REFERENCE) {
                        if(fieldName.indexOf('OwnerId') > -1) fieldName = fieldName.substring(0, fieldName.indexOf('OwnerId')) + 'Owner.Name';
                        else fieldName = fieldName.substring(0, fieldName.indexOf('__c')) + '__r.Name';
                    }
                    if(i+1 == allValues.size()){
                        innerFilterString += fieldName + ' '+filterUsed+') ';
                    }
                    else{
                        innerFilterString += fieldName + ' '+filterUsed+' OR ';
                    }
                }
                filteringQuery += ' ' + innerFilterString;
            }
        }
        system.debug('FILTER >> ' + filteringQuery);
        return filteringQuery;
    }
    
    @AuraEnabled 
    public static FieldSetWrapperGroup deleteSortFilterItem(String type, Id id, Integer page, Integer year) {
        String listSrc;
        if(type == 'sort') {
            List<SimplusGrid_Sorting__c> sortItem = [SELECT Id, List_Source__c FROM SimplusGrid_Sorting__c WHERE Id = :id LIMIT 1];
            if(!sortItem.isEmpty()) listSrc = sortItem[0].List_Source__c;
            delete sortItem;
        } else if(type == 'filter') {
            List<SimplusGrid_Filtering__c> filterItem = [SELECT Id, List_Source__c FROM SimplusGrid_Filtering__c WHERE Id = :id LIMIT 1];
            if(!filterItem.isEmpty()) listSrc = filterItem[0].List_Source__c;
            delete filterItem;
        }
        return toggle(listSrc != null ? listSrc : DEFAULT_LIST_SOURCE, page, year);
    }
    
    @AuraEnabled 
    public static FieldSetWrapperGroup toggleSortFilterItem(String type, Id id, Boolean currentState, Integer page, Integer year) {
        String listSrc;
        if(type == 'sort') {
            List<SimplusGrid_Sorting__c> sortItem = [SELECT Id, List_Source__c FROM SimplusGrid_Sorting__c WHERE Id = :id LIMIT 1];
            if(!sortItem.isEmpty()) {
                listSrc = sortItem[0].List_Source__c;
                for(SimplusGrid_Sorting__c sc : sortItem) sc.Active__c = currentState;
                update sortItem;
            }
        } else if(type == 'filter') {
            List<SimplusGrid_Filtering__c> filterItem = [SELECT Id, List_Source__c FROM SimplusGrid_Filtering__c WHERE Id = :id LIMIT 1];
            if(!filterItem.isEmpty()) {
                listSrc = filterItem[0].List_Source__c;
                for(SimplusGrid_Filtering__c sc : filterItem) sc.Active__c = currentState;
                update filterItem;
            }
        }
        return toggle(listSrc != null ? listSrc : DEFAULT_LIST_SOURCE, page, year);
    }
    /*******Added By Ajay Choudhary on 22 June 2021 *******Start****/
     @AuraEnabled 
    public static FieldSetWrapperGroup toggleSortFilterItemNew(String type, List<sObject> objList, Integer page, Integer year) {
        String listSrc;
        if(type == 'sort') {
            List<SimplusGrid_Sorting__c> sortItem = (List<SimplusGrid_Sorting__c>)objList;
            if(!sortItem.isEmpty()) {
                listSrc = sortItem[0].List_Source__c;
                update sortItem;
            }
        } else if(type == 'filter') {
            List<SimplusGrid_Filtering__c> filterItem =(List<SimplusGrid_Filtering__c>)objList;
            if(!filterItem.isEmpty()) {
                listSrc = filterItem[0].List_Source__c;
                update filterItem;
            }
        }
        return toggle(listSrc != null ? listSrc : DEFAULT_LIST_SOURCE, page, year);
    }
    /*******Added By Ajay Choudhary on 22 June 2021 *******End****/
    
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
    //---------Added By Ajay Choudhary on 7th June 2021----------------------------------------START----------------------------------------------------------------------
    //This method is used to get records to calculate all totals on forecast
    @AuraEnabled
    public static List<Forecast__c> getRecordTotals(String fieldNameJson, String sortingOrderResult, String filteringOrderResult, Integer page, Integer year){
        if(year == null) year = Date.today().year();
        List<Forecast__c> lstResult = new List<Forecast__c>();
        String result = '[]';
        try{
            List<String> fieldNames = (List<String>) JSON.deserialize(fieldNameJson, List<String>.class);
            
            Set<String> setFieldNames = new Set<String>();
            for(Integer i = 0; i < 12; i+=1) {
                fieldNames.add('Management_M' + (i+1) + '__c');
                fieldNames.add('Acct_Rep_M' + (i+1) + '__c');
                fieldNames.add('PriorActuals_M' + (i+1) + '__c');
            //    fieldNames.add('Prior_Month_Act' + (i+1) + '__c');  // 12th july///
                fieldNames.add('SixMonthRunningAverage_' + (i+1) + '__c');
                fieldNames.add('Allocation_M' + (i+1) + '__c');
                fieldNames.add('Statistical_M' + (i+1) + '__c');
                /*****Code Added on 12th Nov 2021 to remove change tracker*****Start*********-----Ajay Choudhary-----*/
                fieldNames.add('Acct_Rep_Last_Modified_M' + (i+1) + '__c');
                fieldNames.add('Management_Last_Modified_M' + (i+1) + '__c');
                fieldNames.add('Allocation_Last_Modified_By_M' + (i+1) + '__c');
                fieldNames.add('Statistical_Last_Modified_By_M' + (i+1) + '__c');
                /*****Code Added on 12th Nov 2021 to remove change tracker*****End***********-----Ajay Choudhary-----*/
            }
            //fieldNames.add('ChangeTracker__c');/*****Code commented on 12th Nov 2021 to remove change tracker****************-----Ajay Choudhary-----*/
            fieldNames.add('Year__c');
            fieldNames.add('UniqueId__c');
            fieldNames.add('ForecastFindKey__c');
            fieldNames.add('Sold_To_Forecast__r.AccountNumber_R1__c ');
            fieldNames.add('Ship_To_Forecast__r.AccountNumber_R1__c ');
            fieldNames.add('Sold_To_Forecast__r.Name');
            fieldNames.add('Ship_To_Forecast__r.Name');
            fieldNames.add('Product_Forecast__r.Name');
            fieldNames.add('Product_Forecast__r.ProductCode');
            fieldNames.add('Product_Forecast__r.IsActive');
            for(String s : fieldNames) setFieldNames.add(s);
            
            fieldNames.clear();
            fieldNames.addAll(setFieldNames);
            
            system.debug('filteringOrderResult >> ' + filteringOrderResult);
            
            filteringOrderResult = dynamicQueryFilter(null);
            sortingOrderResult = dynamicQuerySort(null);
            
            
            String query = 'SELECT ' + String.join(fieldNames, ',') + ' FROM Forecast__c';
            
            if (filteringOrderResult != '' && filteringOrderResult != null){
                query += ' ' + filteringOrderResult;
            }
            
            if(query.indexOf('WHERE') > -1) {
                query += ' AND ';
            } else {
                query += ' WHERE ';
            }
            Integer nextYear = Integer.valueOf(year)+1; 
            String nextYearQuery = query;
/*            query += ' Ship_To_Forecast__c <> null AND Sold_To_Forecast__c <> null AND Product_Forecast__c <> null AND Year__c = ' + year + ' ';
            nextYearQuery += ' Ship_To_Forecast__c <> null AND Sold_To_Forecast__c <> null AND Year__c = ' + nextYear + ' '; */
            /* Added by Jimmy Daresta to exclude the records where the product might be null also. Data error. */
            query += ' Ship_To_Forecast__c <> null AND Sold_To_Forecast__c <> null AND Product_Forecast__c <> null AND Year__c = ' + year + ' ';
            nextYearQuery += ' Ship_To_Forecast__c <> null AND Sold_To_Forecast__c <> null AND Product_Forecast__c <> null AND Year__c = '  + nextYear + ' '; 
            
            
            query += ' AND Product_Forecast__r.IsActive = True';
            nextYearQuery += ' AND Product_Forecast__r.IsActive = True';
            
            system.debug('FIELDS >> ' + JSON.serialize(fieldNames));
            if (sortingOrderResult != '' && sortingOrderResult != null){
                query += ' ' + sortingOrderResult;
            }  else {
                query += ' ORDER BY CreatedDate DESC';
            }
            
            query += ' LIMIT 1600';
            
            system.debug('QUERY >> ' + query);
            List<Forecast__c> currentYearForecasts = Database.query(query); 
            Set<Id> ppIds = new Set<Id>();
            for(Forecast__c cyf : currentYearForecasts){
                ppIds.add(cyf.Purchased_Product__c);
            }
            nextYearQuery += ' AND Purchased_Product__c IN :ppIds';
            if (sortingOrderResult != '' && sortingOrderResult != null){
                nextYearQuery += ' ' + sortingOrderResult;
            }  else {
                nextYearQuery += ' ORDER BY CreatedDate DESC';
            }
            
            nextYearQuery += ' LIMIT 1600';
            system.debug('nextYearQuery >> ' + nextYearQuery);
            List<Forecast__c> nextYearForecasts = Database.query(nextYearQuery);
            List<Forecast__c> lstForecast = new List<Forecast__c>();
            lstForecast.addAll(currentYearForecasts);
            lstForecast.addAll(nextYearForecasts);
            /*
            //Map<String, Decimal> priorVal = getSfStageSales(lstForecast, Date.today().year()-1);
            Map<String, ForecastWrapper> returnWrap = new Map<String, ForecastWrapper>();
            for(sObject s : lstForecast){
                //lstResult.add(s);
                Forecast__c f = (Forecast__c) s;
                /*for(Integer i = 0; i < 12; i+=1) {
                    Integer mon = i + 1;
                    String monStr = (mon < 10 ? '0' : '') + mon;
                    if(priorVal.containsKey(f.UniqueId__c + '/' + monStr)) {
                        f.put('PriorActuals_M' + mon + '__c', priorVal.get(f.UniqueId__c + '/' + monStr));
                    } 
                }
                */
               /* String fKey = f.Sold_To_Forecast__r.AccountNumber_R1__c + f.Ship_To_Forecast__r.AccountNumber_R1__c + f.Product_Forecast__r.ProductCode;
                if(returnWrap.containsKey(fKey)) {
                    if(f.Year__c != null) returnWrap.get(fKey).forecastsPerYear.put(f.Year__c, new ForecastYear(f));
                } else {
                    ForecastWrapper fcw = new ForecastWrapper();
                    fcw.forecastsPerYear.put(f.Year__c,  new ForecastYear(f));
                    fcw.key = fKey;
                    fcw.fieldSetValues = s;
                    if(f.Year__c != null) returnWrap.put(fKey, fcw);
                }
            }
            if(returnWrap.values().size() > 0) {
                result = JSON.serialize(returnWrap.values());
            }*/
           return lstForecast; 
        }
        catch(Exception e){
            System.debug('exception in total is'+e);
            result += e.getLineNumber() + ' : ' + e.getMessage();
            return null;
        }
        
    }    
    //---------Added By Ajay Choudhary on 7th June 2021 ----------------------------------------End----------------------------------------------------------------------
    @AuraEnabled
    public static String getRecords(String fieldNameJson, String sortingOrderResult, String filteringOrderResult, Integer page, Integer year){
        
        if(year == null) year = Date.today().year();
        List<Forecast__c> lstResult = new List<Forecast__c>();
        String result = '[]';
        try{
            List<String> fieldNames = (List<String>) JSON.deserialize(fieldNameJson, List<String>.class);
            
            Set<String> setFieldNames = new Set<String>();
            for(Integer i = 0; i < 12; i+=1) {
                fieldNames.add('Management_M' + (i+1) + '__c');
                fieldNames.add('Acct_Rep_M' + (i+1) + '__c');
                fieldNames.add('PriorActuals_M' + (i+1) + '__c');
             //   fieldNames.add('Prior_Month_Act' + (i+1) + '__c'); // 12 july
                fieldNames.add('SixMonthRunningAverage_' + (i+1) + '__c');
                fieldNames.add('Allocation_M' + (i+1) + '__c');
                fieldNames.add('Statistical_M' + (i+1) + '__c');
                /*****Code Added on 12th Nov 2021 to remove change tracker*****Start*********-----Ajay Choudhary-----*/
                fieldNames.add('Acct_Rep_Last_Modified_M' + (i+1) + '__c');
                fieldNames.add('Management_Last_Modified_M' + (i+1) + '__c');
                fieldNames.add('Allocation_Last_Modified_By_M' + (i+1) + '__c');
                fieldNames.add('Statistical_Last_Modified_By_M' + (i+1) + '__c');
                /*****Code Added on 12th Nov 2021 to remove change tracker*****End***********-----Ajay Choudhary-----*/
            }
            //fieldNames.add('ChangeTracker__c');/*****Code commented on 12th Nov 2021 to remove change tracker****************-----Ajay Choudhary-----*/
            fieldNames.add('Year__c');
            fieldNames.add('UniqueId__c');
            fieldNames.add('ForecastFindKey__c');
            fieldNames.add('Sold_To_Forecast__r.AccountNumber_R1__c ');
            fieldNames.add('Ship_To_Forecast__r.AccountNumber_R1__c ');
            fieldNames.add('Sold_To_Forecast__r.Name');
            fieldNames.add('Ship_To_Forecast__r.Name');
            fieldNames.add('Product_Forecast__r.Name');
            fieldNames.add('Product_Forecast__r.Business_Group__c');
            fieldNames.add('Product_Forecast__r.ProductCode');
            fieldNames.add('Product_Forecast__r.IsActive');//-------Added by Gaurish
            for(String s : fieldNames) setFieldNames.add(s);
            
            fieldNames.clear();
            fieldNames.addAll(setFieldNames);
            
            system.debug('filteringOrderResult >> ' + filteringOrderResult);
            
            filteringOrderResult = dynamicQueryFilter(null);
            sortingOrderResult = dynamicQuerySort(null);
            
            
            String query = 'SELECT ' + String.join(fieldNames, ',') + ' FROM Forecast__c';
            String queryCount = 'SELECT COUNT(Id) cnt FROM Forecast__c';
            
            if (filteringOrderResult != '' && filteringOrderResult != null){
                query += ' ' + filteringOrderResult;
                queryCount += ' ' + filteringOrderResult;
            }
            
            if(query.indexOf('WHERE') > -1) {
                query += ' AND ';
                queryCount += ' AND ';
            } else {
                query += ' WHERE ';
                queryCount += ' WHERE ';
            }
            Integer nextYear = Integer.valueOf(year)+1; //---------Added By Ajay Choudhary
            String nextYearQuery = query; //---------Added By Ajay Choudhary
            query += ' Ship_To_Forecast__c <> null AND Sold_To_Forecast__c <> null AND Year__c = ' + year + ' ';
            nextYearQuery += ' Ship_To_Forecast__c <> null AND Sold_To_Forecast__c <> null AND Year__c = ' + nextYear + ' '; //---------Added By Ajay Choudhary
            queryCount += ' Ship_To_Forecast__c <> null AND Sold_To_Forecast__c <> null AND Year__c = ' + year + ' ';
            query += ' AND Product_Forecast__r.IsActive = True';//-------Added by Gaurish
            nextYearQuery += ' AND Product_Forecast__r.IsActive = True'; //---------Added By Ajay Choudhary 
            queryCount += ' AND Product_Forecast__r.IsActive = True';//-------Added by Gaurish
            
            system.debug('FIELDS >> ' + JSON.serialize(fieldNames));
            if (sortingOrderResult != '' && sortingOrderResult != null){
                query += ' ' + sortingOrderResult;
            }  else {
                query += ' ORDER BY CreatedDate DESC';
            }
            
            query += ' LIMIT ' + DEFAULT_PAGE_SIZE + ' OFFSET ' + ((page-1) * DEFAULT_PAGE_SIZE );
            
            system.debug('QUERY >> ' + query);
            //---------Added By Ajay Choudhary----------------------------------------START----------------------------------------------------------------------
            List<Forecast__c> currentYearForecasts = Database.query(query); 
            Set<Id> ppIds = new Set<Id>();
            for(Forecast__c cyf : currentYearForecasts){
                ppIds.add(cyf.Purchased_Product__c);
            }
            System.debug('ppIds=='+ppIds);
            nextYearQuery += ' AND Purchased_Product__c IN :ppIds';
            if (sortingOrderResult != '' && sortingOrderResult != null){
                nextYearQuery += ' ' + sortingOrderResult;
            }  else {
                nextYearQuery += ' ORDER BY CreatedDate DESC';
            }
            
            nextYearQuery += ' LIMIT ' + DEFAULT_PAGE_SIZE;
            system.debug('nextYearQuery >> ' + nextYearQuery);
            List<Forecast__c> nextYearForecasts = Database.query(nextYearQuery);
            System.debug('nextYearForecasts=='+nextYearForecasts);
            List<Forecast__c> lstForecast = new List<Forecast__c>();
            lstForecast.addAll(currentYearForecasts);
            lstForecast.addAll(nextYearForecasts);
            //----------Added By Ajay Choudhary----------------------------------------END--------------------------------------------------------------------------
            System.debug('lstForecast=='+lstForecast);
             System.debug('queryCount=='+queryCount);
            AggregateResult ag = Database.query(queryCount);
            Integer recordCnt = Integer.valueOf(ag.get('cnt'));
             System.debug('recordCnt=='+recordCnt);
            pageMax = recordCnt / DEFAULT_PAGE_SIZE;
            if(Math.mod(recordCnt,DEFAULT_PAGE_SIZE) > 0) pageMax +=1;
            
            /*Removed because we store the prior year in the field that is populated by the batch job - Jimmy Daresta 8/3/2021 */ 
            /* Map<String, Decimal> priorVal = getSfStageSales(lstForecast, Date.today().year()-1);
            System.debug('Priorvals >> ' + priorVal); */
            Map<String, ForecastWrapper> returnWrap = new Map<String, ForecastWrapper>();
            
            for(sObject s : lstForecast){
                //lstResult.add(s);
                Forecast__c f = (Forecast__c) s;
                
                /*Removed because we store the prior year in the field that is populated by the batch job - Jimmy Daresta 8/3/2021 */ 
                /* for(Integer i = 0; i < 12; i+=1) {
                    Integer mon = i + 1;
                    String monStr = (mon < 10 ? '0' : '') + mon;
                     if(priorVal.containsKey(f.UniqueId__c + '/' + monStr)) {
                       f.put('PriorActuals_M' + mon + '__c', priorVal.get(f.UniqueId__c + '/' + monStr)); 
                    } 
                     if(priorVal.containsKey(f.UniqueId__c + '/' + monStr)) {
                        f.put('Prior_Month_Act' + mon + '__c', priorVal.get(f.UniqueId__c + '/' + monStr)); //12 july/////
                    } 
                    //Remmed out by Jimmy Daresta to determine why sales rep and market manager values were not coming up
                    //Reason is the collection priorVal is coming from the SFStage table, but pointing to the wrong data field.
                    //Options are to implement in the stage table read the same logic as UOM.
                    //Or one could determine the logic here by determing if the Business Group was Epoxy and using the previous year avg or if CAPV
                    //the previous year field. I like the second option because those fields would be populated by the nightly job and would be apples
                    //to apples
                    
                    //if(f.ChangeTracker__c <> null && f.ChangeTracker__c.charAt(i) == 48) //48 is char zero
                    //                    f.put('Acct_Rep_M' + mon + '__c', priorVal.get(f.UniqueId__c + '/' + monStr));
                    //f.put('Acct_Rep_M' + mon + '__c', f.get('PriorActuals_M' + mon + '__c'));
                    
                    //if(f.ChangeTracker__c <> null && f.ChangeTracker__c.charAt(i + 12) == 48) //48 is char zero 
                    // f.put('Management_M' + mon + '__c', priorVal.get(f.UniqueId__c + '/' + monStr));
                } */
                
                String fKey = f.Sold_To_Forecast__r.AccountNumber_R1__c + f.Ship_To_Forecast__r.AccountNumber_R1__c + f.Product_Forecast__r.ProductCode;
                if(returnWrap.containsKey(fKey)) {
                    if(f.Year__c != null) returnWrap.get(fKey).forecastsPerYear.put(f.Year__c, new ForecastYear(f));
                    System.debug('year==If='+f.Year__c);
                } else {
                    ForecastWrapper fcw = new ForecastWrapper();
                    fcw.forecastsPerYear.put(f.Year__c,  new ForecastYear(f));
                    fcw.key = fKey;
                    fcw.fieldSetValues = s;
                    if(f.Year__c != null) returnWrap.put(fKey, fcw);
                    System.debug('year==else='+f.Year__c);
                }
            }
            
            //if(!preventLoadDml) update lstForecast;
            
            if(pageMax > 40) { //changed by Ajay Choudhary
                isBeyond = true;
                pageMax = 40;
            } else if(pageMax == 0) {
                pageMax = 1;
            }
            
            if(returnWrap.values().size() > 0) {
                System.debug('<< returnWrap >>');
                System.debug(returnWrap.keySet());
                System.debug(returnWrap);
                result = JSON.serializePretty(returnWrap.values(), false);
            }
        } catch(Exception e){
            result += e.getLineNumber() + ' : ' + e.getMessage();
            System.debug('exception==='+e);
        }
        system.debug('RESULT >> ' + result);
        return result;
    }
    @AuraEnabled 
    public static user fetchUser(){
        User u = [SELECT Id, Name, Forecasting_Lock_Column__c,Forecasting_Settings__c FROM User WHERE id =: userInfo.getUserId()];
        return u;
    }
    
    @AuraEnabled 
    public static void saveUserDetail(Integer noOfColumns, String settings){
        User u = [SELECT Id, Name, Forecasting_Lock_Column__c,Forecasting_Settings__c FROM User WHERE id =: userInfo.getUserId()];
        u.Forecasting_Lock_Column__c = noOfColumns;
        u.Forecasting_Settings__c = settings;
        update u;
    }
    @AuraEnabled
    public static String createForecastRecords(List<String> previousForecastId, String fieldNameJson, String sortingOrderResult, String filteringOrderResult, Integer year) {
        List<String> fieldNames = (List<String>) JSON.deserialize(fieldNameJson, List<String>.class);
        
        Set<String> setFieldNames = new Set<String>();
        for(Integer i = 0; i < 12; i+=1) {
            fieldNames.add('Management_M' + (i+1) + '__c');
            fieldNames.add('Acct_Rep_M' + (i+1) + '__c');
            fieldNames.add('PriorActuals_M' + (i+1) + '__c');
            //    fieldNames.add('Prior_Month_Act' + (i+1) + '__c');    // 12 july//////
            fieldNames.add('SixMonthRunningAverage_' + (i+1) + '__c');
            /*****Code Added on 12th Nov 2021 to remove change tracker*****Start*********-----Ajay Choudhary-----*/
            fieldNames.add('Acct_Rep_Last_Modified_M' + (i+1) + '__c');
            fieldNames.add('Management_Last_Modified_M' + (i+1) + '__c');
            fieldNames.add('Allocation_Last_Modified_By_M' + (i+1) + '__c');
            fieldNames.add('Statistical_Last_Modified_By_M' + (i+1) + '__c');
            /*****Code Added on 12th Nov 2021 to remove change tracker*****End***********-----Ajay Choudhary-----*/
            
            
        }
        //fieldNames.add('ChangeTracker__c');/*****Code commented on 12th Nov 2021 to remove change tracker****************-----Ajay Choudhary-----*/
        fieldNames.add('Unit_Of_Measure__c');//-----Added by Gaurish
        fieldNames.add('Year__c');
        fieldNames.add('ForecastFindKey__c');
        fieldNames.add('Sold_To_Forecast__r.AccountNumber_R1__c');
        fieldNames.add('Ship_To_Forecast__r.AccountNumber_R1__c');
        fieldNames.add('Product_Forecast__r.ProductCode');
        fieldNames.add('Sold_To_Forecast__r.Name');
        fieldNames.add('Ship_To_Forecast__r.Name');
        fieldNames.add('Product_Forecast__r.Name');
        for(String s : fieldNames) setFieldNames.add(s);
        if(year == null) year = Date.today().year();
        fieldNames.clear();
        fieldNames.addAll(setFieldNames);
        
        system.debug('filteringOrderResult >> ' + filteringOrderResult);
        String query = 'SELECT ' + String.join(fieldNames, ',') + ' FROM Forecast__c';
        query += ' WHERE Id IN: previousForecastId';
        
        if (filteringOrderResult != '' && filteringOrderResult != null){
            query += ' ' + (filteringOrderResult.indexOf('WHERE') > -1 ? filteringOrderResult.replace('WHERE', 'AND') : filteringOrderResult);
        }
        
        system.debug('FIELDS >> ' + JSON.serialize(fieldNames));
        if (sortingOrderResult != '' && sortingOrderResult != null){
            query += ' ' + sortingOrderResult;
        }  else {
            query += ' ORDER BY CreatedDate DESC';
        }
        System.debug('QUERY >> ' + query);
        List<Forecast__c> lstForecast = Database.query(query);
        List<Forecast__c> lstNewForecast = new List<Forecast__c>();
        
        Map<String, Decimal> priorVal = getSfStageSales(lstForecast, year);
        priorVal.putAll(getSfStageSales(lstForecast, year-1));
        
        system.debug('FORECAST QUERY >> ' + lstForecast);
        User u = [SELECT Id, Name, FederationIdentifier FROM User WHERE Id =:UserInfo.getUserId()]; //code added to remove change tracker on 12th Nov 2021 by Ajay Choudhary
        String lastModifiedBy = u.Name+'-'+u.FederationIdentifier != null ? u.FederationIdentifier : u.Id; //code added to remove change tracker on 12th Nov 2021 by Ajay Choudhary
        for(Forecast__c forecast : lstForecast) {
            Forecast__c newForecast = forecast.clone();
            newForecast.Year__c += 1;
            newForecast.UniqueId__c = forecast.Sold_To_Forecast__r.AccountNumber_R1__c 
                + forecast.Ship_To_Forecast__r.AccountNumber_R1__c 
                + forecast.Product_Forecast__r.ProductCode
                + String.valueOf(newForecast.Year__c);
            //newForecast.ChangeTracker__c = DEFAULT_CHANGE_TRACKER;  /*****Code commented on 12th Nov 2021 to remove change tracker****************-----Ajay Choudhary-----*/
            newForecast.UOM_Past__c = forecast.Unit_Of_Measure__c;//-----Added by Gaurish
            for(Integer i = 0; i < 12; i+=1) {
                Integer mon = i + 1;
                String monStr = (mon < 10 ? '0' : '') + mon;
                
                if(priorVal.containsKey(newForecast.UniqueId__c + '/' + monStr)) {
                    newForecast.put('Management_M' + mon + '__c', priorVal.get(newForecast.UniqueId__c + '/' + monStr));
                    newForecast.put('Acct_Rep_M' + mon + '__c', priorVal.get(newForecast.UniqueId__c + '/' + monStr));
                    //code added to remove change tracker on 12th Nov 2021 by Ajay Choudhary------Start----
                    newForecast.put('Management_Last_Modified_By_M'+ mon + '__c', lastModifiedBy);
                    newForecast.put('Management_Last_Modified_M'+ mon + '__c', System.now());
                    newForecast.put('Acct_Rep_Last_Modified_By_M'+ mon + '__c', lastModifiedBy);
                    newForecast.put('Acct_Rep_Last_Modified_M'+ mon + '__c', System.now());
                    //code added to remove change tracker on 12th Nov 2021 by Ajay Choudhary------End----
                    newForecast.put('PriorActuals_M' + mon + '__c', priorVal.get(newForecast.UniqueId__c + '/' + monStr));
                  //   newForecast.put('Prior_Month_Act' + mon + '__c', priorVal.get(newForecast.UniqueId__c + '/' + monStr)); /// 12 july ////
                } 
            }
            
            lstNewForecast.add(newForecast);
        }
        system.debug('NEW LIST >> ' + JSON.serialize(lstNewForecast));
        Database.insert(lstNewForecast, false);
        
        String records = getRecords(fieldNameJson, sortingOrderResult, filteringOrderResult, 1, year);
        system.debug('records ' + records);
        return records;
    }
    
    @AuraEnabled
    public static HistoricalActualsWrapper getPriorActualsData(String findKey, Decimal month, Decimal year) {
        HistoricalActualsWrapper ret = new HistoricalActualsWrapper();
        if(year == null) {
            Date d = Date.today();
            month = d.month() - 1;
            year = d.year();
        }
        
        Decimal prevYear = year - 1;
        String yearQuery = '%' + String.valueOf(year);
        String prevYearQuery = '%' + String.valueOf(prevYear);
        String findKeyTag1 = findKey + '' + year;
        String findKeyTag2 = findKey + '' + prevYear;
        ret.month = month;
        ret.year = year;
        ret.prevYear = prevYear;
        
        
        List<AggregateResult> groupedResults = [SELECT SOLD_TO_PARTY__c, SHIP_TO_PARTY__c, GMID__c, FISCAL_MONTH_YEAR__c, UNIT_OF_MEASURE__c, /*SUM(VOLUME_ACTUAL_UL__c) VOLUME*/ //-----Commented by Gaurish
                                                SUM(QUANTITY_CAL_NEW__c) VOLUMECAL, SUM(QUANTITY_CUOM_CAL__c) VOLUMEC, SUM(QUANTITY_GUOM_CAL__c) VOLUMEGL, SUM(QUANTITY_SUOM_CAL__c) VOLUMEST //----Added by Gaurish
                                                FROM SF_STAGE_SALES__c 
                                                WHERE (ForecastFindKey__c = :findKeyTag1 OR ForecastFindKey__c = :findKeyTag2)
                                                AND (YEAR__c = :year OR YEAR__c = :prevYear) GROUP BY SOLD_TO_PARTY__c, SHIP_TO_PARTY__c, GMID__c, FISCAL_MONTH_YEAR__c, UNIT_OF_MEASURE__c];
        Set<String> accSapId = new Set<String>();
        Set<String> prodGmid = new Set<String>();
        
        for(AggregateResult ag : groupedResults) {
            accSapId.add(ag.get('SOLD_TO_PARTY__c') + '');
            accSapId.add(ag.get('SHIP_TO_PARTY__c') + '');
            prodGmid.add(ag.get('GMID__c') + '');
        }
        String findForecast = findKey + year;
        Forecast__c f = [SELECT Id, Name, Sold_To_Forecast__r.Name, Ship_To_Forecast__r.Name, Product_Forecast__r.Name,
                         Product_Forecast__r.Business_Group__c,Product_Forecast__r.PH1_Performance_Center__c,Sold_To_Forecast__r.Area_R1__c//----Added by Gaurish
                         FROM Forecast__c 
                         WHERE UniqueId__c =:findForecast LIMIT 1];
        
        ret.soldTo = f.Sold_To_Forecast__r;//acctMap.get(ag.get('SOLD_TO_PARTY__c') + '');
        ret.shipTo = f.Ship_To_Forecast__r;//acctMap.get(ag.get('SHIP_TO_PARTY__c') + '');
        ret.product = f.Product_Forecast__r;//prodMap.get(ag.get('GMID__c') + '');
        
        for(AggregateResult ag : groupedResults) {
            List<String> ymSplit = ((String) ag.get('FISCAL_MONTH_YEAR__c')).split('/');
            String baseKey = ag.get('SOLD_TO_PARTY__c') + '' + ag.get('SHIP_TO_PARTY__c') + '' + ag.get('GMID__c');
            String dtKey = ymSplit[0] + '-' + (Integer.valueOf(ymSplit[1]));
            String key = baseKey + '' + dtKey;
            
            //ret.data.put(dtKey, (Decimal)ag.get('VOLUME'));-----Commented by Gaurish
            //ret.dataList.add(new HistoricalActualsDataWrapper(dtKey, (Decimal)ag.get('VOLUME')));-----Commented by Gaurish
            //-------Added by Gaurish  ------ START-----------
            IF(f.Product_Forecast__r.Business_Group__c == 'OCAV' && 
               (f.Product_Forecast__r.PH1_Performance_Center__c != 'CAUSTIC' || 
                (f.Product_Forecast__r.PH1_Performance_Center__c == 'CAUSTIC' && f.Sold_To_Forecast__r.Area_R1__c == 'North America'))){
                    ret.data.put(dtKey, (Decimal)ag.get('VOLUMEST'));
                    ret.dataList.add(new HistoricalActualsDataWrapper(dtKey, (Decimal)ag.get('VOLUMEST')));
                }
            ELSE IF(f.Product_Forecast__r.Business_Group__c == 'OCAV' && f.Product_Forecast__r.PH1_Performance_Center__c == 'CAUSTIC' && f.Sold_To_Forecast__r.Area_R1__c != 'North America'){
                ret.data.put(dtKey, (Decimal)ag.get('VOLUMEGL'));
                ret.dataList.add(new HistoricalActualsDataWrapper(dtKey, (Decimal)ag.get('VOLUMEGL')));
            }
            ELSE IF((f.Product_Forecast__r.Business_Group__c == 'GCO' || f.Product_Forecast__r.Business_Group__c == 'ALLYLICS & AROMATICS' || f.Product_Forecast__r.Business_Group__c == 'RESINS' || f.Product_Forecast__r.Business_Group__c == 'SYSTEMS & GROWTH') && f.Sold_To_Forecast__r.Area_R1__c == 'North America'){
                ret.data.put(dtKey, (Decimal)ag.get('VOLUMEST'));
                ret.dataList.add(new HistoricalActualsDataWrapper(dtKey, (Decimal)ag.get('VOLUMEST')));
            }
            ELSE IF((f.Product_Forecast__r.Business_Group__c == 'GCO' || f.Product_Forecast__r.Business_Group__c == 'ALLYLICS & AROMATICS' || f.Product_Forecast__r.Business_Group__c == 'RESINS' || f.Product_Forecast__r.Business_Group__c == 'SYSTEMS & GROWTH') && f.Sold_To_Forecast__r.Area_R1__c != 'North America'){
                ret.data.put(dtKey, (Decimal)ag.get('VOLUMEGL'));
                ret.dataList.add(new HistoricalActualsDataWrapper(dtKey, (Decimal)ag.get('VOLUMEGL')));
            }
            ELSE{
                ret.data.put(dtKey, (Decimal)ag.get('VOLUMECAL'));
                ret.dataList.add(new HistoricalActualsDataWrapper(dtKey, (Decimal)ag.get('VOLUMECAL')));    
            }
            //-------Added by Gaurish  ------ END---------------
        }
        System.debug('ret======'+ret);
        ret.fixData();
        return ret;
    }
    
    public class HistoricalActualsWrapper {
        @AuraEnabled public Account soldTo;
        @AuraEnabled public Account shipTo;
        @AuraEnabled public Product2 product;
        @AuraEnabled public Decimal month;
        @AuraEnabled public Decimal year;
        @AuraEnabled public Decimal prevYear;
        @AuraEnabled public String findKey;
        
        @AuraEnabled public Decimal average = 0;
        @AuraEnabled public Decimal total = 0;
        
        @AuraEnabled public Map<String, Decimal> data = new Map<String, Decimal>();
        @AuraEnabled public List<HistoricalActualsDataWrapper> dataList = new List<HistoricalActualsDataWrapper>();
        @AuraEnabled public List<HistoricalActualsDataWrapper> dataListFixed = new List<HistoricalActualsDataWrapper>();
        private final List<String> months = new List<String>{'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'};
            
            public void fixData() {
                Integer monthsPrior = 6;
                for(Integer i = 0; i < monthsPrior; i+=1) {
                    String dtKey = (month < 10 ? '0' + month : String.valueOf(month)) + '-' + year;
                    if(data.containsKey(dtKey)) {
                        dataListFixed.add(new HistoricalActualsDataWrapper(months[Integer.valueOf(month)-1] + ' ' + year, data.get(dtKey)));
                        this.total += data.get(dtKey);
                    } else {
                        System.debug('months====='+months+'  month====='+month+' dataListFixed==='+dataListFixed);
                        dataListFixed.add(new HistoricalActualsDataWrapper(months[month == 0 ? Integer.valueOf(month) : Integer.valueOf(month)-1] + ' ' + year, 0));
                    }
                    month = month >= 1 ? month - 1 : month; // added by Ajay
                    if(month == 0) {
                        year -= 1;
                        month = 12;
                    }
                }
                this.average = this.total / monthsPrior;
            }
        
    }
    public class HistoricalActualsDataWrapper {
        @AuraEnabled public String dtMonth;
        @AuraEnabled public Decimal val;
        
        public HistoricalActualsDataWrapper(String s, Decimal d) {
            this.dtMonth = s;
            this.val = d;
        }
    }
    
    public static Map<String, Decimal> getSfStageSales(List<Forecast__c> lstForecast, Integer year) {
        Map<String, Decimal> ret = new Map<String, Decimal>();
        Set<Decimal> yearSet = new Set<Decimal>();
        Set<String> soldTo = new Set<String>();
        Set<String> shipTo = new Set<String>();
        Set<String> gMid = new Set<String>();
        
        for(Forecast__c f : lstForecast) {
            yearSet.add(f.Year__c);
            soldTo.add(f.Sold_To_Forecast__r.AccountNumber_R1__c );
            shipTo.add(f.Ship_To_Forecast__r.AccountNumber_R1__c );
            if(f.Product_Forecast__r.ProductCode != null) {
                String pCode = f.Product_Forecast__r.ProductCode;
                while(pCode.length() < 10) {
                    pCode = '0' + pCode;
                }
                gMid.add(pCode);
            }
        }
        String yearQuery = '%' + year, nextYearQuery = '%' + (year + 1);
        System.debug('soldTo>> ' + soldTo);
        System.debug('shipTo>> ' + shipTo);
        System.debug('gMid>> ' + gMid);
        System.debug('yearQuery>> ' + yearQuery);
        System.debug('nextYearQuery>> ' + nextYearQuery);
        List<AggregateResult> groupedResults = [SELECT SOLD_TO_PARTY__c, SHIP_TO_PARTY__c, GMID__c, FISCAL_MONTH_YEAR__c, UNIT_OF_MEASURE__c, SUM(VOLUME_ACTUAL_UL__c) VOLUME,/**/ //-----Commented by Gaurish
                                                SUM(QUANTITY_CAL_NEW__c) VOLUMECAL, SUM(QUANTITY_CUOM_CAL__c) VOLUMEC, SUM(QUANTITY_GUOM_CAL__c) VOLUMEGL, SUM(QUANTITY_SUOM_CAL__c) VOLUMEST //----Added by Gaurish
                                                FROM SF_STAGE_SALES__c 
                                                WHERE SOLD_TO_PARTY__c IN :soldTo AND SHIP_TO_PARTY__c IN :shipTo AND GMID__c IN :gMid
                                                AND (FISCAL_MONTH_YEAR__c LIKE :yearQuery OR FISCAL_MONTH_YEAR__c LIKE :nextYearQuery) GROUP BY SOLD_TO_PARTY__c, SHIP_TO_PARTY__c, GMID__c, FISCAL_MONTH_YEAR__c, UNIT_OF_MEASURE__c];
        
        for(AggregateResult ag : groupedResults) {
            List<String> ymSplit = ((String) ag.get('FISCAL_MONTH_YEAR__c')).split('/');
            String key = ag.get('SOLD_TO_PARTY__c') + '' + ag.get('SHIP_TO_PARTY__c') + '' + Double.valueOf(ag.get('GMID__c')) + '' + (Double.valueOf(ymSplit[1]) + 1) + '/' + ymSplit[0];
            ret.put(key, (Decimal)ag.get('VOLUME'));
            /*IF(f.Product_Forecast__r.Business_Group__c == 'OCAV' && 
(f.Product_Forecast__r.PH1_Performance_Center__c != 'CAUSTIC' || 
(f.Product_Forecast__r.PH1_Performance_Center__c == 'CAUSTIC' && f.Sold_To_Forecast__r.Area_R1__c == 'North America'))){
ret.data.put(dtKey, (Decimal)ag.get('VOLUMEST'));
ret.dataList.add(new HistoricalActualsDataWrapper(dtKey, (Decimal)ag.get('VOLUMEST')));
}
ELSE IF(f.Product_Forecast__r.Business_Group__c == 'OCAV' && f.Product_Forecast__r.PH1_Performance_Center__c == 'CAUSTIC' && f.Sold_To_Forecast__r.Area_R1__c != 'North America'){
ret.data.put(dtKey, (Decimal)ag.get('VOLUMEGL'));
ret.dataList.add(new HistoricalActualsDataWrapper(dtKey, (Decimal)ag.get('VOLUMEGL')));
}
ELSE IF((f.Product_Forecast__r.Business_Group__c == 'GCO' || f.Product_Forecast__r.Business_Group__c == 'ALLYLICS & AROMATICS' || f.Product_Forecast__r.Business_Group__c == 'RESINS' || f.Product_Forecast__r.Business_Group__c == 'SYSTEMS & GROWTH') && f.Sold_To_Forecast__r.Area_R1__c == 'North America'){
ret.data.put(dtKey, (Decimal)ag.get('VOLUMEST'));
ret.dataList.add(new HistoricalActualsDataWrapper(dtKey, (Decimal)ag.get('VOLUMEST')));
}
ELSE IF((f.Product_Forecast__r.Business_Group__c == 'GCO' || f.Product_Forecast__r.Business_Group__c == 'ALLYLICS & AROMATICS' || f.Product_Forecast__r.Business_Group__c == 'RESINS' || f.Product_Forecast__r.Business_Group__c == 'SYSTEMS & GROWTH') && f.Sold_To_Forecast__r.Area_R1__c != 'North America'){
ret.data.put(dtKey, (Decimal)ag.get('VOLUMEGL'));
ret.dataList.add(new HistoricalActualsDataWrapper(dtKey, (Decimal)ag.get('VOLUMEGL')));
}
ELSE{
ret.data.put(dtKey, (Decimal)ag.get('VOLUMECAL'));
ret.dataList.add(new HistoricalActualsDataWrapper(dtKey, (Decimal)ag.get('VOLUMECAL')));    
}*/
        }
        return ret;
    }
    
    @AuraEnabled
    public static String saveRecords(String saveList){
        System.debug(saveList);
        SaveItem sitm = (SaveItem) JSON.deserialize(saveList, SaveItem.class);
        //SaveItem sitm = saveList;
        List<Forecast__c> forecastUpdate = sitm.runBuild();
        System.debug(forecastUpdate);
        try{
            upsert forecastUpdate Forecast__c.UniqueId__c;
        }
        catch(Exception e){
            System.debug('exception while upserting records'+e);
        }
        return String.valueOf(forecastUpdate);
    }
    
    @AuraEnabled
    public static String saveLine(String saveId, Decimal saveValue){
        List<String> splitStr = saveId.split('/');
        List<Forecast__c> fList = [SELECT Id,Unit_Of_Measure__c/*ChangeTracker__c*/ FROM Forecast__c WHERE UniqueId__c = :splitStr LIMIT 1]; //Code commented to remove change tracker on 12th Nov 2021 By Ajay Choudhary
        User u = [SELECT Id, Name, FederationIdentifier FROM User WHERE Id =:UserInfo.getUserId()]; //code added to remove change tracker on 12th Nov 2021 by Ajay Choudhary
        System.debug('u==='+u.Name+u.FederationIdentifier);
        String lastModifiedBy = u.Name+'-'+(u.FederationIdentifier != null ? u.FederationIdentifier : u.Id); //code added to remove change tracker on 12th Nov 2021 by Ajay Choudhary
        Forecast__c f = new Forecast__c();
        f.UOM_Past__c = f.Unit_Of_Measure__c;//-----------Added by Gaurish
        if(!fList.isEmpty()) {
            //Code commented to remove change tracker on 12th Nov 2021 By Ajay Choudhary
            /*String chTracker = fList[0].ChangeTracker__c == null ? DEFAULT_CHANGE_TRACKER : fList[0].ChangeTracker__c.length() == 24 ? fList[0].ChangeTracker__c+'000000000000' : fList[0].ChangeTracker__c;//-----Added by Ajay Choudhary
            System.debug('chTracker==='+chTracker);
            List<String> chList = chTracker.split('');
            
            chList[splitStr[2] == 'rep' ? (Integer.valueOf(splitStr[1]) - 1) : splitStr[2] == 'mgr' ? (Integer.valueOf(splitStr[1]) + 11) : (Integer.valueOf(splitStr[1]) + 23)] = '1';*/
            
            f.Id = fList[0].Id;
            //f.ChangeTracker__c = String.join(chList,''); //Code commented to remove change tracker on 12th Nov 2021 By Ajay Choudhary
            System.debug('lastModifiedBy==='+lastModifiedBy);
            if(splitStr[2] == 'rep')  {
                f.put('Acct_Rep_M' + splitStr[1] + '__c', saveValue);
                f.put('Acct_Rep_Last_Modified_By_M'+splitStr[1]+'__c', lastModifiedBy);//code added to remove change tracker on 12th Nov 2021 by Ajay Choudhary
                f.put('Acct_Rep_Last_Modified_M'+splitStr[1]+'__c', System.now());//code added to remove change tracker on 12th Nov 2021 by Ajay Choudhary
            }
            else if(splitStr[2] == 'mgr'){
                f.put('Management_M' + splitStr[1] + '__c', saveValue);
                f.put('Management_Last_Modified_By_M'+splitStr[1]+'__c', lastModifiedBy);//code added to remove change tracker on 12th Nov 2021 by Ajay Choudhary
                f.put('Management_Last_Modified_M'+splitStr[1]+'__c', System.now());//code added to remove change tracker on 12th Nov 2021 by Ajay Choudhary
            }
            else {
                f.put('Allocation_M' + splitStr[1] + '__c', saveValue);
                f.put('Allocation_Last_Modified_By_M'+splitStr[1]+'__c', lastModifiedBy);//code added to remove change tracker on 12th Nov 2021 by Ajay Choudhary
                f.put('Allocation_Last_Modified_M'+splitStr[1]+'__c', System.now());//code added to remove change tracker on 12th Nov 2021 by Ajay Choudhary
            }
            system.debug('f====='+f);
            update f;
            return String.valueOf(f);
        }
        
        return null;
    }
    
    public class SaveItem {
        @AuraEnabled public Decimal monthSet;
        @AuraEnabled public Decimal yearStart;
        @AuraEnabled public Decimal monthStart;
        @AUraEnabled public Map<String, List<ColListWrapper>> saveList;
        @AuraEnabled public Map<String, Map<Decimal, ForecastYear>> mapForecastYear;
        
        public List<Forecast__c> runBuild() {
            Map<String, Forecast__c> retList = new Map<String, Forecast__c>();
            User u = [SELECT Id, Name, FederationIdentifier FROM User WHERE Id =:UserInfo.getUserId()]; //code added to remove change tracker on 12th Nov 2021 by Ajay Choudhary
            String lastModifiedBy = u.Name+'-'+u.FederationIdentifier != null ? u.FederationIdentifier : u.Id; //code added to remove change tracker on 12th Nov 2021 by Ajay Choudhary
            System.debug(JSON.serialize(saveList));
            
            
            List<Forecast__c> forecastList = [SELECT Id, Sold_To_Forecast__c, Ship_To_Forecast__c, Purchased_Product__c, Product_Forecast__c, Year__c, UniqueId__c, /*ChangeTracker__c,*/ Product_Forecast__r.ProductCode, //code commented to remove change tracker on 12th Nov 2021 by Ajay Choudhary
                                              Acct_Rep_M1__c, Acct_Rep_M2__c, Acct_Rep_M3__c, Acct_Rep_M4__c, Acct_Rep_M5__c, Acct_Rep_M6__c, Acct_Rep_M7__c, Acct_Rep_M8__c, Acct_Rep_M9__c, Acct_Rep_M10__c, Acct_Rep_M11__c, Acct_Rep_M12__c,
                                              Management_M1__c, Management_M2__c, Management_M3__c, Management_M4__c, Management_M5__c, Management_M6__c, Management_M7__c, Management_M8__c, Management_M9__c, Management_M10__c, Management_M11__c, Management_M12__c
                                              FROM Forecast__c 
                                              WHERE ForecastFindKey__c LIKE :saveList.keySet() AND Year__c >=: yearStart];
            Map<String, Forecast__c> mapForecast = new Map<String, Forecast__c>();
            for(Forecast__c forecast : forecastList) {
                mapForecast.put(forecast.UniqueId__c, forecast);
            }
            System.debug('map >>>>>' + mapForecast);
            
            for(String s : saveList.keySet()) {
                Decimal monthTrack = monthStart;
                Decimal yearTrack = yearStart;
                Forecast__c f = new Forecast__c();
                f.UniqueId__c = s + yearStart;
                System.debug('key is'+s + yearStart);
                //code commented to remove change tracker on 12th Nov 2021 by Ajay Choudhary---Start------//
                /*String strRep = '';
                String strMgr = '';
                if(mapForecast.containsKey(s + yearStart)){
                    strRep = mapForecast.get(s + yearStart).ChangeTracker__c != null ? mapForecast.get(s + yearStart).ChangeTracker__c.substring(0,12) : '000000000000';
                    strMgr = mapForecast.get(s + yearStart).ChangeTracker__c!= null ? mapForecast.get(s + yearStart).ChangeTracker__c.substring(12,24) : '000000000000';
                }
                String repMgr = '';*/
                //code commented to remove change tracker on 12th Nov 2021 by Ajay Choudhary---End------//
                for(Integer i = 0; i < monthSet; i+=1) {
                    Integer mTrack = integer.valueOf(monthTrack);
                    f.put('Management_M' + (monthTrack+1) + '__c', saveList.get(s)[i].mgr);
                    f.put('Acct_Rep_M' + (monthTrack+1) + '__c', saveList.get(s)[i].rep);
                    f.put('Acct_Rep_Last_Modified_By_M'+(monthTrack+1)+'__c', lastModifiedBy);//code added to remove change tracker on 12th Nov 2021 by Ajay Choudhary
                    f.put('Acct_Rep_Last_Modified_M'+(monthTrack+1)+'__c', System.now());//code added to remove change tracker on 12th Nov 2021 by Ajay Choudhary
                    f.put('Management_Last_Modified_By_M'+(monthTrack+1)+'__c', lastModifiedBy);//code added to remove change tracker on 12th Nov 2021 by Ajay Choudhary
                    f.put('Management_Last_Modified_M'+(monthTrack+1)+'__c', System.now());//code added to remove change tracker on 12th Nov 2021 by Ajay Choudhary
                    //code commented to remove change tracker on 12th Nov 2021 by Ajay Choudhary---Start------//
                    /*strRep = strRep.left(mTrack)+(saveList.get(s)[i].repIsChanged) + strRep.right(strRep.length()-mTrack-1);
                    strMgr = strMgr.left(mTrack)+(saveList.get(s)[i].mgrIsChanged) + strMgr.right(strMgr.length()-mTrack-1);
                    repMgr = (strRep+strMgr);
                    
                    f.put('ChangeTracker__c', repMgr.left(24));*/
                    //code commented to remove change tracker on 12th Nov 2021 by Ajay Choudhary---End------//
                    monthTrack += 1;
                    
                    if(monthTrack == 12) {//december
                        monthTrack = 0;//reset
                        yearTrack += 1;//increment
                        retList.put(f.UniqueId__c, f);
                        //reset
                        if(mapForecast.get(s + yearTrack) != null) {
                            f = new Forecast__c();
                            f.UniqueId__c = s + yearTrack;
                            //code commented to remove change tracker on 12th Nov 2021 by Ajay Choudhary---Start------//
                            /*strRep = mapForecast.get(s + yearTrack).ChangeTracker__c != null ? mapForecast.get(s + yearTrack).ChangeTracker__c.substring(0,12) : '000000000000';
                            strMgr = mapForecast.get(s + yearTrack).ChangeTracker__c!= null ? mapForecast.get(s + yearTrack).ChangeTracker__c.substring(12,24) : '000000000000';*/
                            //code commented to remove change tracker on 12th Nov 2021 by Ajay Choudhary---End------//
                        }
                        
                    }
                }
                system.debug('FORECAST >> ' + f);
                if(!retList.containsKey(f.UniqueId__c)) retList.put(f.UniqueId__c, f);
            }
            System.debug(retList);
            return retList.values();
        }
    }
    public class ForecastWrapper {
        @AuraEnabled public String key;
        @AuraEnabled public String label;
        @AuraEnabled public sObject fieldSetValues;
        @AuraEnabled public Map<Decimal, ForecastYear> forecastsPerYear = new Map<Decimal, ForecastYear>();
        @AuraEnabled public List<ColListWrapper> colList;
    }
    public class ForecastYear {
        @AuraEnabled public Decimal year;
        @AuraEnabled public String changeMatrix;
        @AuraEnabled public List<Decimal> mgrMonthly = new List<Decimal>(); 
        @AuraEnabled public List<Decimal> repMonthly = new List<Decimal>();
        @AuraEnabled public List<Decimal> priorMonthly = new List<Decimal>();
      //  @AuraEnabled public List<Decimal> priorActMonthly = new List<Decimal>();// 12th july///////
        @AuraEnabled public List<Decimal> aveMonthly = new List<Decimal>();
        @AuraEnabled public List<Decimal> allocationMonthly = new List<Decimal>();
        @AuraEnabled public List<Decimal> statisticalMonthly = new List<Decimal>();
        public ForecastYear(Forecast__c f) {
            this.year = f.Year__c;
            /*****Code Changed on 12th Nov 2021 to remove change tracker****************-----Ajay Choudhary-----*------Start--------*/
            this.changeMatrix = '';
            for(Integer i = 1; i <=12; i+=1) {
                if(f.get('Acct_Rep_Last_Modified_M' + i + '__c') == null){
                    changeMatrix += '0';
                }
                else{
                    changeMatrix += '1';
                }
            }
            for(Integer i = 1; i <=12; i+=1) {
                if(f.get('Management_Last_Modified_M' + i + '__c') == null){
                    changeMatrix += '0';
                }
                else{
                    changeMatrix += '1';
                }
            }
            for(Integer i = 1; i <=12; i+=1) {
                if(f.get('Allocation_Last_Modified_By_M' + i + '__c') == null){
                    changeMatrix += '0';
                }
                else{
                    changeMatrix += '1';
                }
            }
            /*for(Integer i = 1; i <=12; i+=1) {
                if(f.get('Statistical_Last_Modified_By_M' + i + '__c') == null){
                    changeMatrix += '0';
                }
                else{
                    changeMatrix += '1';
                }
            }*/
            if(changeMatrix == null){
                changeMatrix = DEFAULT_CHANGE_TRACKER;
            }
            /*****Code Changed on 12th Nov 2021 to remove change tracker****************-----Ajay Choudhary-----*------End--------*/
            for(Integer i = 0; i < 12; i+=1) {
                Decimal mgr = (Decimal) f.get('Management_M' + (i+1) + '__c');
                if(mgr == null) this.mgrMonthly.add(0); else this.mgrMonthly.add(mgr);
                
                Decimal rep = (Decimal) f.get('Acct_Rep_M' + (i+1) + '__c');
                if(rep == null) this.repMonthly.add(0); else this.repMonthly.add(rep);
                
                Decimal prior = (Decimal) f.get('PriorActuals_M' + (i+1) + '__c');
                if(prior == null) this.priorMonthly.add(0); else this.priorMonthly.add(prior);
                // 12th July 2021
               //   Decimal priorAct = (Decimal) f.get('Prior_Month_Act' + (i+1) + '__c');
              //  if(priorAct == null) this.priorActMonthly.add(0); else this.priorActMonthly.add(priorAct);
                
                Decimal ave = (Decimal) f.get('SixMonthRunningAverage_' + (i+1) + '__c');
                if(ave == null) this.aveMonthly.add(0); else this.aveMonthly.add(ave);
                
                Decimal alc = (Decimal) f.get('Allocation_M' + (i+1) + '__c');
                if(alc == null) this.allocationMonthly.add(0); else this.allocationMonthly.add(alc);
                
                Decimal sts = (Decimal) f.get('Statistical_M' + (i+1) + '__c');
                if(sts == null) this.statisticalMonthly.add(0); else this.statisticalMonthly.add(sts);
            }
        }
    }
    
    public class ColListWrapper {
        @AuraEnabled public Integer mgr;
        @AuraEnabled public Integer rep;
        @AuraEnabled public Boolean isChanged;
        @AuraEnabled public String fieldNameRep;
        @AuraEnabled public String fieldNameMgr;
        @AuraEnabled public Decimal mgrOld;
        @AuraEnabled public Decimal repOld;
        @AuraEnabled public String mgrIsChanged;
        @AuraEnabled public String repIsChanged;
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
        @AuraEnabled public Decimal sortOrder;
        
        public FieldGridControl(SimplusGridControlField__mdt control) {
            this.name = control.FieldApi__c;
            this.label = control.MasterLabel;
            this.editable = control.Editable__c;
            this.enableMassUpdate = control.EnableMassUpdate__c;
            this.massUpdateType = control.MassUpdateType__c;
            this.massUpdateParams = control.MultiUpdateParameters__c;
            this.sortOrder = control.SortOrder__c;
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
        @AuraEnabled public Boolean showFieldColumn {get;set;}  // Added by Ajay Choudhary on 30th Jan 2023 -----> Column Show/Hide functionality
        @AuraEnabled public String columnConfigId {get;set;}    // Added by Ajay Choudhary on 30th Jan 2023 -----> Column Show/Hide functionality
    }
    
    public class FieldSetWrapperGroup {
        @AuraEnabled public List<FieldSetWrapper> sortingFieldSet {get;set;}
        @AuraEnabled public List<FieldSetWrapper> filteringFieldSet {get;set;}
        @AuraEnabled public List<SortColumWrapper> sortingWrapper {get;set;}
        @AuraEnabled public List<FilterColumWrapper> filteringWrapper {get;set;}
        @AuraEnabled public String sortingOrderResult {get;set;}
        @AuraEnabled public String filteringOrderResult {get;set;}
        @AuraEnabled public List<ForecastWrapper> lstObject {get;set;}
        @AuraEnabled public Integer pageMax;
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
    
}