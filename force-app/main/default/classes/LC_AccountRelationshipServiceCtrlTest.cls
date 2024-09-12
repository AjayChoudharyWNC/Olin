@isTest
public class LC_AccountRelationshipServiceCtrlTest {
    
	@TestSetup
    private static void setup() {
        
        RecordType accRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Customer'];
        RecordType shipToRecordType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Account' AND Name = 'Customer Location'];
        
        Account newSoldToAccount = new Account(
            Name = 'Test Sold To Account',
            RecordTypeId = accRecordType.Id,
            CurrencyIsoCode = 'USD',
            Type = 'Competitor',
            Sold_To__c = True,
            Region_R1__c = 'UNITED STATES'
        );
        
        insert newSoldToAccount;
        
        Account newShipToAccount = new Account(
            Name = 'Test Ship To Account',
            RecordTypeId = shipToRecordType.Id,
            CurrencyIsoCode = 'USD',
            Type = 'Competitor',
            Region_R1__c = 'UNITED STATES',
            Ship_To__c = true
        );
        
        insert newShipToAccount;
        
    }
    
    @isTest
    private static void testAccountRelationshipServiceCtrl() {
        
        List<Account> listOfAccs = [SELECT Id, Name FROM Account ORDER BY Name];
        
        Account shipToAcc = listOfAccs.get(0);
        Account soldToAcc = listOfAccs.get(1);
        
        Test.startTest();
        	LC_AccountRelationshipServiceCtrl.insertNewAccountRelationshipRecord(soldToAcc.Id, shipToAcc.Id);
        	List<Id> shipToIds = LC_AccountRelationshipServiceCtrl.getAccountShipTo(soldToAcc.Id);
        Test.stopTest();
        
        List<Account_Relationships__c> newAccRelationships = [SELECT Id, Sold_To__c, Ship_To__c FROM Account_Relationships__c];
        
        // Check for insertNewAccountRelationshipRecord method
        System.assert(newAccRelationships.size() == 1);
        
        Account_Relationships__c newAccRelationship = newAccRelationships.get(0);
        
        System.assertEquals(soldToAcc.Id, newAccRelationship.Sold_To__c);
        System.assertEquals(shipToAcc.Id, newAccRelationship.Ship_To__c);
        
        // Check for getAccountShipTo method
        System.assert(shipToIds.size() == 1);
        
        Id shipToId = shipToIds.get(0);
        
        System.assertEquals(shipToAcc.Id, shipToId);
        
    }
    
}