@isTest
public class ForecastTriggerTest {
    
    static testMethod void test1(){
        Horizon_Year__c hz = new Horizon_Year__c();
        hz.Name = 'Default';
        hz.Year__c = 2025;
        insert hz;
        
        Product2 p1 = new Product2(
            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
            Product_Level__c = 'GMID',
            //SBQQ__SubscriptionTerm__c = 12,
            Fusion_Harmonized_Matl__c = '42276',
            TradeProduct_R1__c = '123456',
            LegacyBCCode_R1__c = '42276',
            ProductCode = '42276',
            TradeProdCode_R1__c = '42276',
            EXTERNALDATASOURCEID_R1__c = 'S4',
            Family = 'CAPV',
            Business_Group__c = 'OCAV',
            PH1_Performance_Center__c = 'CAUSTIC',
            PerformanceCenter_R1__c = 'CAUSTIC SALES', 
            Name = 'CAUSTIC SODA 25% IND GR',
            IsActive = true
            
        );
        insert p1;
        
        Product2 p3 = new Product2(
            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
            Product_Level__c = 'GMID',
            //SBQQ__SubscriptionTerm__c = 12,
            Fusion_Harmonized_Matl__c = '42271',
            TradeProduct_R1__c = '123456',
            LegacyBCCode_R1__c = '42271',
            ProductCode = '42271',
            TradeProdCode_R1__c = '42271',
            EXTERNALDATASOURCEID_R1__c = 'S4',
            Family = 'EPOXY',
            Business_Group__c = 'ALLYLICS & AROMATICS',
            PH1_Performance_Center__c = 'LER',
            PerformanceCenter_R1__c = 'LER',
            Name = 'EPOXY TEST GMID',
            IsActive = true
            
        );
        insert p3;
        
        Account acc1 = new Account(
            Name='TestAcct', 
            NumberOfEmployees=100,
            Sap_Id__c = '9000002',
            Sold_to__c = true,
            Ship_to__c = true,
            AccountNumber_R1__c = '9000002',
            AccountSource = 'S4',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
            Status_R1__c = 'Active'
            
        );
        insert acc1;
 
         Account acc2 = new Account(
            Name='TestAcct2', 
            NumberOfEmployees=100,
            Sap_Id__c = '90000023',
            Sold_to__c = true,
            Ship_to__c = true,
            AccountNumber_R1__c = '90000023',
            AccountSource = 'S4',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
            Status_R1__c = 'Active'
            
        );
        insert acc2;
 
 
        
        // Create Account Relationship
        Account_Relationships__c testAccountRel = new Account_Relationships__c(
            Name = 'Test Account Relationship',
            Relationship_Type__c = 'Sold To / Ship To',
            Sold_To__c = acc1 .Id,
            Ship_To__c = acc1 .Id
        );
        
        insert testAccountRel;
 
         // Create Account Relationship
        Account_Relationships__c testAccountRel2 = new Account_Relationships__c(
            Name = 'Test Account Relationship',
            Relationship_Type__c = 'Sold To / Ship To',
            Sold_To__c = acc2 .Id,
            Ship_To__c = acc2 .Id
        );
        
        insert testAccountRel2;
        
        PurchasedProduct_R1__c testPurchasedProduct = new PurchasedProduct_R1__c(
            Account_Relationship__c = testAccountRel.Id,
            Ship_To__c = acc1 .Id,
            Account_R1__c = acc1 .Id,
            Product_R1__c = p1.Id
        );     
        insert testPurchasedProduct;

        PurchasedProduct_R1__c testPurchasedProduct2 = new PurchasedProduct_R1__c(
            Account_Relationship__c = testAccountRel2.Id,
            Ship_To__c = acc2 .Id,
            Account_R1__c = acc2 .Id,
            Product_R1__c = p3.Id
        );     
        insert testPurchasedProduct2;
        
        
        List<Forecast__c> fList = new List<Forecast__c> ();
        
        Forecast__c f3 = new Forecast__c(Sold_to_Forecast__c = acc1.Id, Ship_To_Forecast__c = acc1.Id, Product_Forecast__c = p1.Id,Purchased_Product__c = testPurchasedProduct.Id);
        f3.Year__c = 2019;
        f3.PriorActuals_M10__c = 1;
        f3.PriorActuals_M11__c = 2;
        f3.PriorActuals_M12__c = 3;
        f3.PriorActuals_M1__c = 4;
        f3.PriorActuals_M2__c = 5;
        f3.PriorActuals_M3__c = 6;
        f3.PriorActuals_M4__c = 7;
        f3.PriorActuals_M5__c = 8;
        f3.PriorActuals_M6__c = 9;
        f3.PriorActuals_M7__c = 10;
        f3.PriorActuals_M8__c = 11;
        f3.PriorActuals_M9__c = 12;
        insert f3;
        f3.Product_Forecast__c = p1.Id;
        f3.Purchased_Product__c  = testPurchasedProduct.Id;
        update f3;
        
        Forecast__c f4 = new Forecast__c(Sold_to_Forecast__c = acc2.Id, Ship_To_Forecast__c = acc2.Id, Product_Forecast__c = p3.Id,Purchased_Product__c = testPurchasedProduct2.Id);
        f4.Year__c = 2019;
        f4.PriorActuals_M10__c = 1;
        f4.PriorActuals_M11__c = 2;
        f4.PriorActuals_M12__c = 3;
        f4.PriorActuals_M1__c = 4;
        f4.PriorActuals_M2__c = 5;
        f4.PriorActuals_M3__c = 6;
        f4.PriorActuals_M4__c = 7;
        f4.PriorActuals_M5__c = 8;
        f4.PriorActuals_M6__c = 9;
        f4.PriorActuals_M7__c = 10;
        f4.PriorActuals_M8__c = 11;
        f4.PriorActuals_M9__c = 12;
        insert f4;
        f4.Product_Forecast__c = p3.Id;
        f4.Purchased_Product__c  = testPurchasedProduct2.Id;
        update f4;
        
        
        ForecastTrigger_Handler.updateManagementFields(new set<Id>{f3.Id,f4.Id});
        //ForecastTrigger_Handler.updateManagementFields(new set<Id>{f4.Id});

    }
    
}