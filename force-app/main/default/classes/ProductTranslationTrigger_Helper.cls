public class ProductTranslationTrigger_Helper {
    
    public Static void onProductSystemsInsertUpdateDelete(list<Product_Systems_Translation__c> listProductSystemTranslation){
        List<Product2> UpdateProductList = new list<product2>(); 
        Set<id> SetProdId = new Set<Id>();
        for(Product_Systems_Translation__c ProdSysTrans: listProductSystemTranslation){
            SetProdId.add(ProdSysTrans.Product__c);
        }
        for(Product2 prod : [select id,Name,Legacy_Product_Id__c,Legacy_Product_Name__c,(select id,Legacy_Product_Id__c,Legacy_Product_Name__c from Product_Systems_Translations__r) from Product2 where id In:SetProdId ]){
            prod.Legacy_Product_Id__c = '';
            prod.Legacy_Product_Name__c = '';
            if(prod.Product_Systems_Translations__r.size() > 0){
                List<Product_Systems_Translation__c> lstProdSystem = prod.Product_Systems_Translations__r;
                for(Product_Systems_Translation__c prodSys : lstProdSystem){
                    prod.Legacy_Product_Id__c +=  prodSys.Legacy_Product_Id__c+', ';
                    prod.Legacy_Product_Name__c += prodSys.Legacy_Product_Name__c+', ';
                }
                prod.Legacy_Product_Id__c = prod.Legacy_Product_Id__c.trim().removeEnd(',');
                prod.Legacy_Product_Name__c = prod.Legacy_Product_Name__c.trim().removeEnd(',');
            }
            UpdateProductList.add(prod);
        }
        if(UpdateProductList != null && UpdateProductList.size()> 0){
            update UpdateProductList;
        }
    }
}