@isTest
public class ProductTranslationTrigger_Test {
    static testMethod Void testInsertUpdateDelet(){
        List<product2> listProduct = new list<Product2>();
        product2 prod = new product2();
        prod.Name = 'TestProd';
        prod.ValueCenterPicklist_R1__c = 'ALLYLICS';
        prod.LineOfBusiness_R1__c = 'CAPV';
        prod.Description = 'testDescription';
        listProduct.add(prod);
        
        product2 prod1 = new product2();
        prod1.Name = 'TestProd';
        prod1.ValueCenterPicklist_R1__c = 'ALLYLICS';
        prod1.LineOfBusiness_R1__c = 'CAPV';
        prod1.Description = 'testDescription';
        listProduct.add(prod1);
        insert listProduct;
        
        List<Product_Systems_Translation__c> lstProdSystem = new List<Product_Systems_Translation__c>();
        Product_Systems_Translation__c PST = new Product_Systems_Translation__c();
        PST.Product__c = listProduct[0].id;
        PST.Legacy_Product_Data_Source__c = 'S4';
        PST.Legacy_Product_Id__c = '098';
        PST.Legacy_Product_name__c = 'H1';
        lstProdSystem.add(PSt);
        Product_Systems_Translation__c PST1 = new Product_Systems_Translation__c();
        PST1.Product__c = listProduct[1].id;
        PST1.Legacy_Product_Data_Source__c = 'S4';
        PST1.Legacy_Product_Id__c = '0987';
        PST1.Legacy_Product_name__c = 'H2';
        lstProdSystem.add(PST1);
        insert lstProdSystem;
        test.startTest();
        	Product_Systems_Translation__c PST2 = new Product_Systems_Translation__c();
            PST2.Product__c = listProduct[1].id;
            PST2.Legacy_Product_Data_Source__c = 'S4';
            PST2.Legacy_Product_Id__c = '0987';
            PST2.Legacy_Product_name__c = 'H2';
        	insert PST2;
        	
        	PST2.Legacy_Product_Id__c = '98';
        	update PST2;
        	
        	Delete PST1;
        test.stopTest();
    }
}