@isTest
public class CreateTechOpportunityTest {
    
    static testMethod void testController(){
        Account ac = new Account(Name='test', AccountNumber_R1__c='12345',AccountSource = 'Blue Cube');
        insert ac;
        Product2 testProduct = new Product2(
            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
            Name = 'Test Product',
            Product_Level__c = 'GMID',
            isActive = true
        );
        insert testProduct;
        
        //Create Purchased Product
        PurchasedProduct_R1__c testPurchasedProduct = new PurchasedProduct_R1__c(
            Account_R1__c = ac.Id,
            Product_R1__c = testProduct.Id
        );
        insert testPurchasedProduct;
        CreateTechOpportunity.GetProducts(ac.id);
        CreateTechOpportunity.getRecordTypeId('Long Term Opportunity');
        try{
            CreateTechOpportunity.getRecordTypeId('');
        }
        catch(AuraHandledException e){
            system.assert(e.getMessage().containsIgnoreCase('null object'), 'message='+e.getMessage());
        }
    }
    
}