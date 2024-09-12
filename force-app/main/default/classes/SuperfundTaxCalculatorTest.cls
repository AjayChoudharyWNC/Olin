@isTest         
public class SuperfundTaxCalculatorTest {
    
    static testMethod void test(){
        Product2 testProduct = new Product2(
            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
            Name = 'Test Product',
            ProductCode = '105001',
            Product_Level__c = 'GMID',
            IsActive = true
        );
        insert testProduct;
        Product_Charge__c pr = new Product_Charge__c();
        pr.Product__c = testProduct.Id;
        pr.Charge_Amount__c = 6.00;
        pr.Charge_Type__c = 'Superfund Excise Tax';
        pr.UOM__c = 'DT';
        pr.Country_Code__c = 'US';
        insert pr;
        
        UOM_Conversion__c uc = new UOM_Conversion__c();
        uc.Product__c = testProduct.Id;
        uc.Base_UOM__c = 'DT';
        uc.Quoted_UOM__c = 'DT';
        uc.Denominator__c = 1;
        uc.Numerator__c = 1;
        insert uc;
        SuperfundTaxCalculator.fetchUOMList(testProduct.Id);
        SuperfundTaxCalculator.getProductCharges(testProduct.Id);
        SuperfundTaxCalculator.getProductId(pr.Id, 'Product_Charge__c', 'Product__c');
        SuperfundTaxCalculator.getProductId(pr.Id, 'Product_Charge__c', 'Product');
    }

}