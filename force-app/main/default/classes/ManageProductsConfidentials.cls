public class ManageProductsConfidentials {
    @AuraEnabled
    public static List<Confidential_Call_Report_Product__c> selectedProductRecords(String recordId){
        List<Confidential_Call_Report_Product__c> existingProd = [SELECT  Id, FCM_IsToBeDeleted__c, Confidential_Call_Report__c ,Confidential_Call_Report__r.Name, FCM_Product__c, FCM_Product__r.LegacyBCCode_R1__c,FCM_Product__r.LegacyOCAPCode_R1__c,FCM_Product__r.Name, FCM_Product__r.ProductCode, FCM_ShortComment__c FROM 
                                               Confidential_Call_Report_Product__c WHERE Confidential_Call_Report__c =: recordId];
        return existingProd;
    }
    @AuraEnabled
    public static  List<Product2> fetchProducts(String recordId , String ProdId){
        Set<Id> ProdIdSet = new Set<Id>();
        Set<String>   PurchasedProdId = new Set<String>();
        Confidential_Call_Report__c fcm =[ Select Id, Name , FCM_Account__c From Confidential_Call_Report__c where Id = : recordId];
        List<PurchasedProduct_R1__c> prlist= [SELECT  Id, Product_R1__r.id,Product_R1__r.Name,Product_R1__r.LineOfBusiness_R1__c FROM  PurchasedProduct_R1__c  WHERE Account_R1__c = : fcm.FCM_Account__c];
        for(PurchasedProduct_R1__c pr :prlist){
            if (pr.Id != null){
                PurchasedProdId.add(pr.Product_R1__r.id);            
            }
        }
        List<Product2> availProd = new  List<Product2>();
        List<Confidential_Call_Report_Product__c> existingProd = [SELECT  Id, Confidential_Call_Report__c , FCM_Product__c, FCM_Product__r.LegacyBCCode_R1__c,FCM_Product__r.LegacyOCAPCode_R1__c,FCM_Product__r.Name, FCM_Product__r.ProductCode, FCM_ShortComment__c FROM  Confidential_Call_Report_Product__c WHERE Confidential_Call_Report__c =: recordId];
        for(Confidential_Call_Report_Product__c fc : existingProd){
            ProdIdSet.add(fc.FCM_Product__c);
        }
        String query = 'select Id, IsActive, Name,LegacyBCCode_R1__c,LegacyOCAPCode_R1__c, ProductCode,UnitOfMeasure_R1__c, Family, Description,Product_Level__c  from Product2 WHERE Id in :PurchasedProdId AND IsActive=True';
        if(ProdId != '' && ProdId != null){
            query += ' AND Id !=\''+ProdId+'\'';
        }
        if(ProdIdSet.size()> 0){
            query += ' AND Id NOT IN : ProdIdSet';
        }
        system.debug('query'+query);
        query +=  ' ORDER BY Name ';
        availProd = database.query(query);
        return availProd;   
    }
    @AuraEnabled
    Public static List<String> getFilterTypes(){
        List<String> filteroptions = new List<String>();
        Schema.DescribeFieldResult fieldResult = Confidential_Call_Report_Product__c.ProductTypeFilter_R1__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry p : ple)
            filteroptions.add(p.getValue());
        return filteroptions;
    }
    @AuraEnabled
    Public static List<String> getListLineofBussiness(){
        List<String> options = new List<String>();
        Schema.DescribeFieldResult fieldResult = Confidential_Call_Report_Product__c.LineofBusiness_R1__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry p : ple)
            options.add(p.getValue());
        return options;
    }
    @AuraEnabled
    public Static void updateavailableList( String toSelect, String recordId){
        List<Confidential_Call_Report_Product__c>  ProdList = new List<Confidential_Call_Report_Product__c>();
        for(Product2 pr : [select Id, IsActive, Name,LegacyBCCode_R1__c,LegacyOCAPCode_R1__c, ProductCode,UnitOfMeasure_R1__c, Family, Description  from Product2]){
            if(pr.Id ==  toSelect){
                Confidential_Call_Report_Product__c fc = new Confidential_Call_Report_Product__c();
                fc.Confidential_Call_Report__c = recordId;
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
        
        List<Confidential_Call_Report_Product__c> existingProd = [SELECT  Id, Confidential_Call_Report__c , FCM_Product__c, FCM_Product__r.LegacyBCCode_R1__c,FCM_Product__r.LegacyOCAPCode_R1__c,FCM_Product__r.Name, FCM_Product__r.ProductCode, FCM_ShortComment__c FROM  Confidential_Call_Report_Product__c WHERE Confidential_Call_Report__c =: recordId];
        for(Confidential_Call_Report_Product__c fc : existingProd){
            ProdId.add(fc.FCM_Product__c);
        }
        List <Product2> availProd = new  List <Product2>();
        
        String query = 'SELECT Id, IsActive, Name,LegacyBCCode_R1__c,LegacyOCAPCode_R1__c, ProductCode,UnitOfMeasure_R1__c, Family, Description,Product_Level__c  from Product2 Where Id NOT IN : ProdId AND IsActive=True';
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
                query += ' ORDER BY Name LIMIT 1000';
            }
            else if(Filters == 'Purchased Products'){  
                Set<String>   PurchasedProdId = new Set<String>();
               Confidential_Call_Report__c fc =[ Select Id, Name , FCM_Account__c From Confidential_Call_Report__c where Id = : recordId];
                system.debug('fc'+fc.FCM_Account__c);
                List<PurchasedProduct_R1__c> prlist= [SELECT  Id, Product_R1__r.id,Product_R1__r.Name,Product_R1__r.LineOfBusiness_R1__c FROM  PurchasedProduct_R1__c  WHERE Account_R1__c = : fc.FCM_Account__c];
                for(PurchasedProduct_R1__c pr :prlist){
                    if (pr.Id != null){
                        PurchasedProdId.add(pr.Product_R1__r.id);            
                    }
                }
                query+= ' AND id in :PurchasedProdId';
            }
        }
        system.debug('query'+query);
        availProd = database.query(query);
        system.debug('availProd'+availProd);
        return availProd;  
    }
    @AuraEnabled
    public Static void removeProductRecords (String RecordId){
        List<Confidential_Call_Report_Product__c> removeProd = [SELECT  Id, FCM_IsToBeDeleted__c, Confidential_Call_Report__c ,Confidential_Call_Report__r.Name, FCM_Product__c, FCM_Product__r.LegacyBCCode_R1__c,FCM_Product__r.LegacyOCAPCode_R1__c,FCM_Product__r.Name, FCM_Product__r.ProductCode, FCM_ShortComment__c FROM 
                                             Confidential_Call_Report_Product__c WHERE ID = : RecordId];
        system.debug('removeProd'+removeProd);
        Delete removeProd;
    }
}