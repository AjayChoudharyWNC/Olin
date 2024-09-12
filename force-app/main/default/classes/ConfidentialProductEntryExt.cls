/*
* Controller for VRProductEntry page which lets the user add multiple products within one transaction
* instead of creating one junction record after the other.
 */
public with sharing class ConfidentialProductEntryExt { //extends AbstractManageProductsController {
    
    public Confidential_Call_Report__c visitReport {get;set;}
    public List<Confidential_Call_Report_Product__c> productLst {get;set;}
    public List<PurchasedProduct_R1__c> PurchasedproductLst = new List<PurchasedProduct_R1__c>();
    private List<Confidential_Call_Report_Product__c> forDeletion = new List<Confidential_Call_Report_Product__c>();
    public List<Product2> AvailableProducts{get;set;}
    public Set<String> existingProd{get;set;}
    
    public Boolean overLimit {get;set;}
    //public String LOB {get; set;}
    public Set<String> PurchasedProdId{get;set;}
    public String toSelect {get; set;}
    public String searchString {get;set;}
    public String type {get;set;}
    Public String AccntId;
    Public Id ExpProdRecTypeId;
    
    //public string LOBprofile{get; set;}
    public List<SelectOption> options = new List<SelectOption>();
    public List<SelectOption> filteroptions = new List<SelectOption>();
    public String lineOfBusiness {get; set;}
    public String prodTypeFilter {get; set;}

    public ConfidentialProductEntryExt(ApexPages.StandardController controller) {
        
        lineOfBusiness = [Select LineOfBusiness_R1__c From User Where Id = :UserInfo.getUserId() limit 1].lineOfBusiness_R1__c;               
        ExpProdRecTypeId = queryRecordType().id;
        System.debug('::::: lineOfBusiness 1 :::::' + lineOfBusiness);
        System.debug('::::: ExpProdRecTypeId 1 :::::' + ExpProdRecTypeId);
        //LOBprofile=UserLB.lineOfBusiness_R1__c;
        
        if (String.isEmpty(lineOfBusiness))
        lineOfBusiness = 'BOTH';

        prodTypeFilter = 'Purchased Products';
        visitReport = queryVisitReport(controller.getRecord().Id);
        AccntId = visitReport.FCM_Account__c;
        productLst = queryVisitReportProducts(controller.getRecord().Id);
        System.debug('::::: productLst ' + productLst );
      	PurchasedproductLst = queryPurchasedProducts();
        existingProd = new Set<String>();
        PurchasedProdId = new Set<String>();
       
                       
        for (Confidential_Call_Report_Product__c vr: productLst) {
            existingProd.add(vr.FCM_Product__c);
        }
        
        for (PurchasedProduct_R1__c pr: PurchasedproductLst){            
              if (pr.Id != null){
            	PurchasedProdId.add(pr.Product_R1__r.id);            
            }
        }
      
         //LOB = lineOfBusiness;
        //lineOfBusiness = LOBprofile;
        updateAvailableList();
    }
    
    private Confidential_Call_Report__c queryVisitReport(Id id) {
        return [
            SELECT 
                Id, Name, IsDeleted, CreatedDate, CreatedById, FCM_Account__c
            FROM 
                Confidential_Call_Report__c 
            WHERE 
                Id = :id
            LIMIT 1
        ];
    }
    
    private List<PurchasedProduct_R1__c> queryPurchasedProducts(){
        return [
            SELECT 
                Id, Product_R1__r.id,Product_R1__r.Name,Product_R1__r.LineOfBusiness_R1__c ,Product_R1__r.LegacyBCCode_R1__c,Product_R1__r.LegacyOCAPCode_R1__c
            FROM 
                PurchasedProduct_R1__c 
            WHERE 
                Account_R1__c = :AccntId           
        ];
        
    }
    private RecordType queryRecordType() {
        return [
            SELECT 
            	id,DeveloperName 
            FROM 
            	RecordType 
            WHERE 
            	SObjectType='Product2' 
            AND
            	DeveloperName='Experimental'
            AND
            	isActive = True 
            LIMIT 1
        ];
    }
    private List<Confidential_Call_Report_Product__c> queryVisitReportProducts(Id id) {
        return [
            SELECT 
                Id, FCM_IsToBeDeleted__c, Confidential_Call_Report__c, FCM_Product__c, FCM_Product__r.LegacyBCCode_R1__c,FCM_Product__r.LegacyOCAPCode_R1__c,FCM_Product__r.Name, FCM_Product__r.ProductCode, FCM_ShortComment__c
            FROM 
                Confidential_Call_Report_Product__c 
            WHERE 
                Confidential_Call_Report__c =: id
        ];
    }
    /**
     * List of Bussines values from User profile information
     */  

    Public List<Selectoption> getListLineofBussiness(){
                    
        Schema.DescribeFieldResult fieldResult = Confidential_Call_Report_Product__c.LineofBusiness_R1__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry p : ple)
        options.add(new SelectOption(p.getValue(), p.getValue()));
        
        /*
        options.add(new SelectOption('CAPV','CAPV'));
        options.add(new SelectOption('EPOXY','EPOXY'));
        options.add(new SelectOption('ALL','ALL'));
        */
        return options;
        }
    Public List<Selectoption> getListProductFilterType(){
                    
        Schema.DescribeFieldResult fieldResult = Confidential_Call_Report_Product__c.ProductTypeFilter_R1__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry p : ple)
        filteroptions.add(new SelectOption(p.getValue(), p.getValue()));

        return filteroptions;
        }
    /**
     * We dynamically build a query string and exclude items already in the shopping cart
     */     
    public void updateAvailableList() {
       
        System.debug('::::: Search Line :::::' + lineOfBusiness);
        //System.debug('::::: visitReport PurchasedproductLst :::::' + PurchasedproductLst.size());
        //System.debug('::::: PurchasedProductqueryPurchasedProducts :::::'+ queryPurchasedProducts().size());
        //System.debug('::::: OLB :::::' + LOB);       
        //String pString;
        String qString = 'select Id, IsActive, Name,LegacyBCCode_R1__c,LegacyOCAPCode_R1__c, ProductCode,UnitOfMeasure_R1__c, Family, Description ' + 
                         'from Product2 ' + 
                         'where Product2.IsActive = true ';
                       
                         
         if(lineOfBusiness != 'BOTH')      
             qString += 'and LineOfBusiness_R1__c = \'' + lineOfBusiness + '\'';
        
        /*if(lineOfBusiness == 'BOTH'){
            qString = 'select Id, IsActive, Name,LegacyBCCode_R1__c,LegacyOCAPCode_R1__c, ProductCode,UnitOfMeasure_R1__c, Family, Description ' + 
                         'from Product2 ' + 
                         'where Product2.IsActive = true ';
        }else{
            qString = 'select Id, IsActive, Name,LegacyBCCode_R1__c,LegacyOCAPCode_R1__c, ProductCode,UnitOfMeasure_R1__c, Family, Description ' + 
                         'from Product2 ' + 
                         'where Product2.IsActive = true ' +
                         'and LineOfBusiness_R1__c = \'' + lineOfBusiness + '\'';
        }
       */
        /*
        * If not needed at all we can delete the next section. Otherwise it provides a good overview about how to 
        * adjust the query string.
         */
        /*if (type == 'Product' || type == 'Product Grade') {
            qString += ' And Product2.Type__c = \'' + type + '\'';
        } else if (type == 'Non-SKU') {
            qString += ' And Product2.Type__c = \'Dummy\'';
        }  else {
            qString += ' And Product2.Type__c IN (\'Product Grade\', \'Product\')';
        }*/

        // note that we are looking for the search string entered by the user in the name OR description
        // modify this to search other fields if desired
        if (!String.isEmpty(searchString)) {
            
            system.debug('::::: searchString ::'+ searchString + ' String.isEmpty(searchString) ' + String.isEmpty(searchString));
            searchString = searchString.replace('*','%');
            system.debug('::::: searchString 2 ::'+ searchString );
            //DS: to resolve the potential soql injection issue
            //qString += '  and (Name like \'%' + searchString + '%\' or Description like \'%' + searchString + '%\' or ProductCode like \'%' + searchString + '%\' or Family like \'%' + searchString + '%\')';

            searchString = '%' + searchString + '%';
			system.debug('::::: searchString 3 ::'+ searchString );
            
            qString += '  and (Name like :searchString or Description like :searchString or ProductCode like :searchString or Family like :searchString)';
            system.debug('::::: qString ::'+ qString );
        }
        if(prodTypeFilter == 'Experimental Products')
            qString+= 'and RecordTypeId = \'' + ExpProdRecTypeId + '\'';
		if(prodTypeFilter == 'Purchased Products')
           qString+= ' and id in :PurchasedProdId';
        
        qString+= ' and id not in :existingProd';
        qString+= ' order by Name';
        qString+= ' limit 101';
        
        System.debug('::::: Query String 2:::::' + qString);
        System.debug('::::: ExpProdRecTypeId 2:::::' + ExpProdRecTypeId);
        availableProducts = database.query(qString);
        
        overLimit = false;
        // We only display up to 100 results... if there are more than we let the user know (see vf page) 
        System.debug('::::: AvailableProducts.size() ' + AvailableProducts.size());
        if (AvailableProducts.size() == 101) {
            AvailableProducts.remove(100);
            overLimit = true;
        }
    }
        
    
    /**
     * This function runs when a user hits "select" button next to a product
     */
    public void addToShoppingCart() {
        System.debug('::::: availableProducts ' + availableProducts );
        for (Product2 prod : availableProducts) {
            System.debug('::::: existingProd ' + existingProd + ' prod.Id ' + prod.Id);
            if(!existingProd.contains(prod.Id)){
            if ((String) prod.Id == toSelect) {
                productLst.add(
                  new Confidential_Call_Report_Product__c(
                      Confidential_Call_Report__c = visitReport.Id,
                      FCM_Product__r = prod,
                      FCM_Product__c = prod.Id,
                      Name = prod.Name,
                      FCM_IsToBeDeleted__c = false
                  )
                );
                break;
            }
          }     
        }
        
        existingProd.add(toSelect);
        updateAvailableList();
    }
    
    public void onSave(){
        // If previously selected products are now removed, we need to delete them
        delete forDeletion;
    
        // Previously selected products may have new quantities and amounts, and we may have new products listed, so we use upsert here
        for (Confidential_Call_Report_Product__c vrp: productLst) {
            vrp.FCM_isToBeDeleted__c = false;
        }
        
        try{
            upsert productLst;
        } catch(Exception e) {
            ApexPages.addMessages(e);
            //return null;
        }

        // After save return the user to the Opportunity
        PageReference returnpage = new PageReference('/' + visitReport.Id );
        returnpage.setredirect(true);
        //return returnpage;
        //return new PageReference('/' + visitReport.Id );
    }

    /**
     * This function runs when a user hits "remove" on an item in the "Selected Products" section
     */    
    public PageReference removeFromShoppingCart(){
        for (integer i= 0; i < productLst.size() ; i++) {
            if (productLst[i].FCM_IsToBeDeleted__c == true) {
                if(productLst[i].Id != null) {
                    forDeletion.add(productLst[i]);
                }
                
                if(existingProd.contains(productLst[i].FCM_Product__c)) {
                    existingProd.remove(productLst[i].FCM_Product__c);
                }
                
                productLst.remove(i);
                i--;
            }
        }
        
        updateAvailableList();
        return null;
    }

    /**
     * If user hits cancel we commit no changes and return them to the Opportunity
     */    
    public PageReference onCancel(){
        return new PageReference('/' + visitReport.Id );
    }
    
    /*public void updateAvailableList2() {
        
        String qString;
       
        if(LOB == 'BOTH'){
            qString = 'select Id, IsActive, Name,LegacyBCCode_R1__c,LegacyOCAPCode_R1__c, ProductCode,UnitOfMeasure_R1__c, Family, Description ' + 
                         'from Product2 ' + 
                         'where Product2.IsActive = true ';
        }else{
            qString = 'select Id, IsActive, Name,LegacyBCCode_R1__c,LegacyOCAPCode_R1__c, ProductCode,UnitOfMeasure_R1__c, Family, Description ' + 
                         'from Product2 ' + 
                         'where Product2.IsActive = true ' +
                         'and LineOfBusiness_R1__c = \'' + LOB + '\'';
        }

        // note that we are looking for the search string entered by the user in the name OR description
        // modify this to search other fields if desired
        if (!String.isEmpty(searchString)) {
            searchString = searchString.replace('*','%');
            
            searchString = '%' + searchString + '%';

            qString += '  and (Name like :searchString or Description like :searchString or ProductCode like :searchString or Family like :searchString)';
        }

        qString+= ' order by Name';
        qString+= ' limit 101';
        
        availableProducts = database.query(qString);
        
        overLimit = false;
        // We only display up to 100 results... if there are more than we let the user know (see vf page) 
        if (AvailableProducts.size() == 101) {
            AvailableProducts.remove(100);
            overLimit = true;
        }
    }
    */
}