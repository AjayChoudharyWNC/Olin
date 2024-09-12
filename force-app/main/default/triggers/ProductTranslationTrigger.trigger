trigger ProductTranslationTrigger on Product_Systems_Translation__c (after insert,after update,after delete) {
    //-------ProductSystemTranslate is Insert then the Legacy Id and Legacy Name Will be Update on Product Legacy Id and Legacy Name object.
    if(trigger.isAfter){
        if(trigger.IsInsert){
            ProductTranslationTrigger_Helper.onProductSystemsInsertUpdateDelete(trigger.New);
        }
    //-----ProductSystemTranslate is Update And Delete then the Legacy Id and Legacy Name Will be Update on Product Legacy Id and Legacy Name object.
        if(trigger.isUpdate){
            list<Product_Systems_Translation__c> listprdSys = new list<Product_Systems_Translation__c>();
            for(Product_Systems_Translation__c prdSys: trigger.new){
                if(prdSys.Legacy_Product_Id__c != trigger.oldmap.get(prdSys.id).Legacy_Product_Id__c ||  prdSys.Legacy_Product_Name__c != trigger.oldmap.get(prdSys.id).Legacy_Product_name__c){
                       listprdSys.add(prdSys);
                   }
            }
            if(!listprdSys.isEmpty()){
                ProductTranslationTrigger_Helper.onProductSystemsInsertUpdateDelete(listprdSys);
            }
        }
        if(trigger.isDelete){
            ProductTranslationTrigger_Helper.onProductSystemsInsertUpdateDelete(trigger.old);
        }
    }
}