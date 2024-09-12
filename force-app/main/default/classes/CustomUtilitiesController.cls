public class CustomUtilitiesController {
    public class RecordListReturn {
        @AuraEnabled public String message;
        @AuraEnabled public List<sObject> returnList;
        @AuraEnabled public String searchFilter;
        @AuraEnabled public String query;
        
    }

    @AuraEnabled
    public static RecordListReturn doSearch(String objSrc, List<String> fieldList, String filter, String orderStr, String inputVal, List<String> searchFrom) {
        String query = 'SELECT ';
        for(String s : fieldList) {
            if(query.indexOf(s) < 0 && s != 'Id') query += s + ',';
        }
        if(query.indexOf('Id') < 0) query += 'Id';
        query += ' FROM ' + objSrc;
        
        if(searchFrom == null) searchFrom = new List<String> {'Id'};
        
        for(String s : searchFrom) {
            if(query.indexOf('WHERE') < 0) query += ' WHERE (';
            query += s + ' LIKE \'%' + inputVal + '%\' OR ';
        }
        query += ')';
        query = query.replace('OR )', ')');
        
        if(filter != null && filter != '') query += ' AND ' + filter;
        if(orderStr != null && orderStr != '') query += ' ORDER BY ' + filter;

        query += ' LIMIT 20';

        RecordListReturn ret = new RecordListReturn();
        ret.searchFilter = inputVal;
        ret.query = query;
        try {
            ret.returnList = Database.query(query);
            if(ret.returnList.size() == 0) ret.message = 'No records found';
        } catch(Exception e) {
            ret.message = e.getMessage();
        }
        
        return ret;
    }
    
}