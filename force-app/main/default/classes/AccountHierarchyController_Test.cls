@isTest
public class AccountHierarchyController_Test {
    
    @isTest static void testController(){
        Account acc = new Account(Name = 'FastChem Cooperation', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Olin Corp').getRecordTypeId());
        insert acc;
        
        List<Account> accList = new List<Account>();
        Account soldToAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
            Name = 'Sold To Account',
            AccountNumber_R1__c = '267686',
            Ship_To__c = true,
            Sold_To__c = true,
            ParentId = acc.Id
        );
        accList.add(soldToAccount);
        
        Account shipToAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
            Name = 'First Ship To Account',
            AccountNumber_R1__c = '267687',
            Ship_To__c = true,
            ParentId = soldToAccount.Id
        );
        accList.add(shipToAccount);
        
        Account shipToAccount2 = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
            Name = 'Second Ship To Account',
            AccountNumber_R1__c = '267688',
            Ship_To__c = true,
            ParentId = acc.Id
        );
        accList.add(shipToAccount2);
        insert accList;
        
        List<Account_Relationships__c> lstTestAccountRelationship = new List<Account_Relationships__c>();
        Account_Relationships__c testAccountRel = new Account_Relationships__c(
            Name = 'Test Account Relationship',
            Relationship_Type__c = 'Sold To / Ship To',
            Sold_To__c = soldToAccount.Id,
            Ship_To__c = shipToAccount.Id
        );
        lstTestAccountRelationship.add(testAccountRel);
        
        testAccountRel = new Account_Relationships__c(
            Name = 'Test Account Relationship 2',
            Relationship_Type__c = 'Sold To / Ship To',
            Sold_To__c = soldToAccount.Id,
            Ship_To__c = shipToAccount2.Id
        );
        lstTestAccountRelationship.add(testAccountRel);
        insert lstTestAccountRelationship;
        
        AccountHierarchyController.findAllHierarchyAccounts(soldToAccount.Id, 'Sold To');
        AccountHierarchyController.findAllHierarchyAccounts(shipToAccount2.Id, 'Ship To');
    }

}