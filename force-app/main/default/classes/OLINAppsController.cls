public without sharing class OLINAppsController {
    
    @AuraEnabled
    public static List<Home_Page_Link__c> getIntlAppLinks() {
        
        return [  SELECT Name, URL__c 
                FROM Home_Page_Link__c
                WHERE Order__c != null AND Fixed_Link__c = true
                ORDER BY Order__c ASC, Name ASC
                LIMIT 15
               ];
    }
}