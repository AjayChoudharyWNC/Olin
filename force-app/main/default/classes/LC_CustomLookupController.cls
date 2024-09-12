public class LC_CustomLookupController {
    
    @AuraEnabled
    public static List<sObject> fetchLookUpValues(String searchKeyword, String objectName, String whereClause) {
        
        String sQuery =  'SELECT Id, Name FROM ' + objectName;
        
        if(searchKeyword != null && searchKeyword != '') {
            sQuery += ' WHERE Name LIKE \'%' + searchKeyword + '%\'';
        }
        
        if(whereClause != null && whereClause != '') {
            
            if(sQuery.containsIgnoreCase('WHERE')) {
                sQuery += ' AND ' + whereClause;
            } else {
                sQuery += ' WHERE ' + whereClause;
            }
            
        }
        
        sQuery += ' ORDER BY CreatedDate DESC LIMIT 5';
        
        return Database.query(sQuery);
        
    }
    
}