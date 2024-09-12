public class VRProductEntry {
    @AuraEnabled
    public static List<FCM_VRProduct__c> selectedProductRecords(String recordId){
        return [SELECT  Id, FCM_IsToBeDeleted__c, FCM_VisitReport__c,FCM_VisitReport__r.Name, FCM_Product__c, FCM_Product__r.LegacyBCCode_R1__c,FCM_Product__r.LegacyOCAPCode_R1__c,FCM_Product__r.Name, FCM_Product__r.ProductCode, FCM_ShortComment__c FROM 
                FCM_VRProduct__c WHERE FCM_VisitReport__c =: recordId];
    }
    @AuraEnabled
    public static List<Product2> fetchProducts(String recordId , String ProdId){
        Set<Id> ProdIdSet = new Set<Id>();
        Set<String>   PurchasedProdId = new Set<String>();
        FCM_VisitReport__c fcm =[ Select Id, Name , FCM_Account__c From FCM_VisitReport__c where Id = : recordId];
        List<PurchasedProduct_R1__c> prlist= [SELECT Id, Product_R1__r.id,Product_R1__r.Name,Product_R1__r.LineOfBusiness_R1__c FROM  PurchasedProduct_R1__c  WHERE Account_R1__c = : fcm.FCM_Account__c];
        for(PurchasedProduct_R1__c pr :prlist){
            if (pr.Id != null){
                PurchasedProdId.add(pr.Product_R1__r.id);            
            }
        }
        List<Product2> availProd = new  List<Product2>();
        List<FCM_VRProduct__c> existingProd = [SELECT  Id, FCM_VisitReport__c, FCM_Product__c, FCM_Product__r.LegacyBCCode_R1__c,FCM_Product__r.LegacyOCAPCode_R1__c,FCM_Product__r.Name, FCM_Product__r.ProductCode, FCM_ShortComment__c 
                                               FROM FCM_VRProduct__c WHERE FCM_VisitReport__c =: recordId];
        for(FCM_VRProduct__c fc : existingProd){
            ProdIdSet.add(fc.FCM_Product__c);
        }
        String query = 'select Id, IsActive, Name,LegacyBCCode_R1__c,LegacyOCAPCode_R1__c, ProductCode,UnitOfMeasure_R1__c, Family, Description,Product_Level__c from Product2 WHERE Id in :PurchasedProdId AND IsActive=True';
        if(ProdId != '' && ProdId != null){
            query += ' AND Id !=\''+ProdId+'\'';
        }
        if(ProdIdSet.size()> 0){
            query += ' AND Id NOT IN : ProdIdSet';
        }
        query +=  ' ORDER BY Name ';
        availProd = database.query(query);
        return availProd;   
    }
    @AuraEnabled
    Public static List<String> getFilterTypes(){
        List<String> filteroptions = new List<String>();
        Schema.DescribeFieldResult fieldResult = FCM_VRProduct__c.ProductTypeFilter_R1__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry p : ple)
            filteroptions.add(p.getValue());
        return filteroptions;
    }
    @AuraEnabled
    Public static List<String> getListLineofBussiness(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = FCM_VRProduct__c.LineofBusiness_R1__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry p : ple)
            options.add(p.getValue());
        return options;
    }
    @AuraEnabled
    public Static void updateavailableList( String toSelect, String recordId){
        List<FCM_VRProduct__c>  ProdList = new List<FCM_VRProduct__c>();
        for(Product2 pr : [select Id, IsActive, Name,LegacyBCCode_R1__c,LegacyOCAPCode_R1__c, ProductCode,UnitOfMeasure_R1__c, Family, Description  from Product2]){
            if(pr.Id ==  toSelect){
                FCM_VRProduct__c fc = new FCM_VRProduct__c();
                fc.FCM_VisitReport__c = recordId;
                fc.FCM_Product__r = pr;
                fc.FCM_Product__c = pr.Id;
                fc.Name = pr.Name;
                if(!ProdList.contains(fc)){
                    ProdList.add(fc); 
                }
            }
        }
        insert ProdList ;  
    }
    @AuraEnabled
    public Static  List <Product2>  fetchSearchProducts( String Pname,String LOB, String Filters, String recordId){
        Set<Id> ProdId = new Set<Id>();
        String lineOfBusiness = [Select LineOfBusiness_R1__c From User Where Id = :UserInfo.getUserId() limit 1].lineOfBusiness_R1__c;               
        
        List<FCM_VRProduct__c> existingProd = [SELECT  Id, FCM_VisitReport__c, FCM_Product__c, FCM_Product__r.LegacyBCCode_R1__c,FCM_Product__r.LegacyOCAPCode_R1__c,FCM_Product__r.Name, FCM_Product__r.ProductCode, FCM_ShortComment__c FROM  FCM_VRProduct__c WHERE FCM_VisitReport__c =: recordId];
        for(FCM_VRProduct__c fc : existingProd){
            ProdId.add(fc.FCM_Product__c);
        }
        List <Product2> availProd = new  List <Product2>();
        
        String query = 'SELECT Id, IsActive, Name,LegacyBCCode_R1__c,LegacyOCAPCode_R1__c, ProductCode,UnitOfMeasure_R1__c, Family, Description,Product_Level__c  from Product2 Where Id NOT IN : ProdId AND IsActive=True ';
        if(Pname != '' && Pname != null){
            query += ' AND Name like \'%'+Pname+'%\'';
        }
        if(LOB != '' && LOB != null && String.isNotBlank(LOB)){
            if(LOB == 'BOTH'){
                string cav = 'CAPV'; string cavp = 'family = \''+ cav +'\'';
                string epox = 'Epoxy'; string epoxy = 'family = \''+ epox +'\'';
                query += ' AND ('+ cavp +'OR '+ epoxy +')' ;
            }
            else if(LOB != 'BOTH'){
                query += ' AND family = \''+LOB+'\'';
            }
        }
        if(Filters != '' && Filters != null && String.isNotBlank(Filters)){
            if(Filters == 'Experimental Products'){ 
                String name =  'Experimental';
                query += ' AND RecordType.Name = \''+name+'\'';
            }
            else if(Filters == 'GMID Products'){    
                query += ' AND Product_Level__c = \'GMID\'';
            }
            else if(Filters == 'Trade Products'){    
                query += ' AND Product_Level__c = \'Trade Product\'';
            }
            else if(Filters == 'All Products'){
                 /* Added 7/7/2021 by Jimmy Daresta to only pull back these types of products and exclude adders and surcharges */
                String name =  'Experimental';
                query += ' AND (RecordType.Name = \''+name+'\'';
                query += ' OR Product_Level__c = \'GMID\'';
                query += ' OR Product_Level__c = \'Trade Product\')';
            
                query += ' ORDER BY Name LIMIT 1000';
            }
            else if(Filters == 'Purchased Products'){  
                Set<String>   PurchasedProdId = new Set<String>();
               FCM_VisitReport__c fc =[ Select Id, Name , FCM_Account__c From FCM_VisitReport__c where Id = : recordId];
                system.debug('fc'+fc.FCM_Account__c);
                List<PurchasedProduct_R1__c> prlist= [SELECT  Id, Product_R1__r.id,Product_R1__r.Name,Product_R1__r.LineOfBusiness_R1__c FROM  PurchasedProduct_R1__c WHERE Account_R1__c = : fc.FCM_Account__c];
                for(PurchasedProduct_R1__c pr :prlist){
                    if (pr.Id != null){
                        PurchasedProdId.add(pr.Product_R1__r.id);            
                    }
                }
                query += ' AND id in :PurchasedProdId';
            }
        }
        availProd = database.query(query);
        return availProd;  
    }
    @AuraEnabled
    public Static void removeProductRecords (String RecordId){
        List<FCM_VRProduct__c> removeProd = [SELECT  Id FROM FCM_VRProduct__c WHERE ID = : RecordId];
        Delete removeProd;
    }
}