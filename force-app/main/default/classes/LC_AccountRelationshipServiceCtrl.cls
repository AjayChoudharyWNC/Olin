public class LC_AccountRelationshipServiceCtrl {
    
    @AuraEnabled
    public static List<Id> getAccountShipTo(String soldToId) {

        List<Account_Relationships__c> accRelationships = [SELECT Ship_To__c FROM Account_Relationships__c WHERE
                Sold_To__c = :soldToId];
        
        List<Id> shipToIds = new List<Id>();

        for(Account_Relationships__c accRelationship : accRelationships) {
            shipToIds.add(accRelationship.Ship_To__c);
        }

        return shipToIds;

    }
    
    @AuraEnabled
    public static void insertNewAccountRelationshipRecord(String soldToId, String shipToId) {
        
        Map<Id, Account> mapOfIdAndAccs = new Map<Id, Account>([SELECT Id, Name FROM Account WHERE Id = :soldToId OR Id = :shipToId]);
        
        Account soldToAcc = mapOfIdAndAccs.get(soldToId);
        Account shipToAcc = mapOfIdAndAccs.get(shipToId);
        
        Account_Relationships__c newAccRelationship = new Account_Relationships__c(
            Name = soldToAcc.Name + ' - ' + shipToAcc.Name,
            Sold_To__c = soldToAcc.Id,
            Ship_To__c = shipToAcc.Id,
            Relationship_Type__c = 'Sold To / Ship To'
        );
        
        insert newAccRelationship;
        
    }
}