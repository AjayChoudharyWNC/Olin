public class ComponentQuoteLineScaleController {
    
    public Id quotelineId {get;set;}
    Boolean hasScale ;
    Boolean hasSurcharge ;
    Boolean hasDiscount ;
    Boolean hasCompetitor ;
    Boolean hasCUPS ;
    
    
    public Boolean getHasScale() {
        List<SBQQ__Quoteline__c> quotelines = [SELECT Min_Volume__c, Scale_UOM__c, Per_Quantity__c, Per_Quantity_Email_Display__c, SBQQ__ListPrice__c, Price_Email_Display__c, Adder_Type__c, Previous_Price_Value__c, CurrencyIsoCode
                                               FROM SBQQ__Quoteline__c
                                               WHERE SBQQ__RequiredBy__c =: quotelineId AND Product_Level__c = 'Scale' ORDER BY SBQQ__Number__c ASC];
         if(quotelines.size() < 1){
            return false;
        } else {
           return true;
        } 
    }
  
    public List<SBQQ__Quoteline__c> getquotelines(){
        List<SBQQ__Quoteline__c> quotelines = [SELECT Min_Volume__c, Scale_UOM__c, Per_Quantity__c, Per_Quantity_Email_Display__c, SBQQ__ListPrice__c, Price_Email_Display__c, Adder_Type__c, Previous_Price_Value__c, CurrencyIsoCode
                      FROM SBQQ__Quoteline__c WHERE SBQQ__RequiredBy__c =: quotelineId AND Product_Level__c = 'Scale' ORDER BY SBQQ__Number__c ASC];
       
        return quotelines;
    }
    
    public Boolean getHasSurcharge() {
        List<SBQQ__Quoteline__c> quotelines = [SELECT SBQQ__ProductName__c, SBQQ__ListPrice__c, CurrencyIsoCode
                                               FROM SBQQ__Quoteline__c
                                               WHERE SBQQ__RequiredBy__c =: quotelineId AND SBQQ__ProductOption__r.SBQQ__Feature__r.SBQQ__Category__c = 'A La Carte Surcharges' ORDER BY SBQQ__Number__c ASC];
         if(quotelines.size() < 1){
            return false;
        } else {
           return true;
        } 
    }
    public List<SBQQ__Quoteline__c> getquotelinesSurcharge(){
        List<SBQQ__Quoteline__c> quotelines = [SELECT SBQQ__ProductName__c, SBQQ__ListPrice__c, CurrencyIsoCode
                                               FROM SBQQ__Quoteline__c
                                               WHERE SBQQ__RequiredBy__c =: quotelineId AND SBQQ__ProductOption__r.SBQQ__Feature__r.SBQQ__Category__c = 'A La Carte Surcharges' ORDER BY SBQQ__Number__c ASC];
       
        return quotelines;
    }
    
    public Boolean getHasDiscount() {
        List<SBQQ__Quoteline__c> quotelines = [SELECT SBQQ__ProductName__c, Discount_Percent__c, Display_Price_Whole_Numbers__c, Validity_Start_Date__c, Validity_End_Date__c
                                               FROM SBQQ__Quoteline__c
                                               WHERE SBQQ__RequiredBy__c =: quotelineId AND SBQQ__ProductOption__r.SBQQ__Feature__r.SBQQ__Category__c = 'Discounts' ORDER BY SBQQ__Number__c ASC];
         if(quotelines.size() < 1){
            return false;
        } else {
           return true;
        } 
    }
    
    public List<QuoteLineDiscountWrapper> getquotelinesDiscount(){
    	List<SBQQ__Quoteline__c> quotelines = [SELECT SBQQ__ProductName__c, Discount_Percent__c, Display_Price_Whole_Numbers__c, Validity_Start_Date__c, Validity_End_Date__c,CurrencyIsoCode
                                               FROM SBQQ__Quoteline__c
                                               WHERE SBQQ__RequiredBy__c =: quotelineId AND SBQQ__ProductOption__r.SBQQ__Feature__r.SBQQ__Category__c = 'Discounts' ORDER BY SBQQ__Number__c ASC];
       	
        List<QuoteLineDiscountWrapper> qlWrapperList = new List<QuoteLineDiscountWrapper>();
        for (SBQQ__Quoteline__c ql :quotelines){
            QuoteLineDiscountWrapper qlw = new QuoteLineDiscountWrapper();
            qlw.productName = ql.SBQQ__ProductName__c;
            qlw.startDate = '';
            qlw.endDate = '';
            if(ql.Validity_Start_Date__c!=null){
            	//qlw.startDate = ql.Validity_Start_Date__c.format();    
            	qlw.startDate = ql.Validity_Start_Date__c.year()+'-'+ql.Validity_Start_Date__c.month()+'-'+ql.Validity_Start_Date__c.day();
            }
            if(ql.Validity_End_Date__c!=null){
            	//qlw.endDate = ql.Validity_End_Date__c.format();    
            	qlw.endDate = ql.Validity_End_Date__c.year()+'-'+ql.Validity_End_Date__c.month()+'-'+ql.Validity_End_Date__c.day();
            }
            
            qlw.discountPercentOrPrice ='';
            if(ql.Discount_Percent__c !=0 && ql.Discount_Percent__c !=null){
            	qlw.discountPercentOrPrice = String.valueOf(ql.Discount_Percent__c)+'%';	
            }else if(string.isBlank(ql.Display_Price_Whole_Numbers__c)==false){
                qlw.discountPercentOrPrice = ql.CurrencyIsoCode+' '+ql.Display_Price_Whole_Numbers__c;
            }
            qlWrapperList.add(qlw);
        }
        return qlWrapperList;
    }
    
    public Boolean getHasCompetitor() {
        List<SBQQ__Quoteline__c> quotelines = [SELECT SBQQ__ProductName__c, Competitive_Distributor__c, Competitive_Manufacturer__c, Competitive_Price__c, Competitor_Product__c, Competitive_Distributor__r.Name, Competitor_Product__r.Name, CurrencyIsoCode
                                               FROM SBQQ__Quoteline__c
                                               WHERE Id =: quotelineId AND (Competitive_Distributor__c !=null OR Competitive_Price__c != null OR Competitor_Product__c!= null) ORDER BY SBQQ__Number__c ASC];
         if(quotelines.size() < 1){
            return false;
        } else {
           return true;
        } 
    }
    
    public List<SBQQ__Quoteline__c>  getquotelinesCompetitor() {
        List<SBQQ__Quoteline__c> quotelines = [SELECT SBQQ__ProductName__c, Competitive_Distributor__c, Competitive_Manufacturer__c, Competitive_Price__c, Competitor_Product__c, Competitive_Distributor__r.Name, Competitor_Product__r.Name, Competitive_Manufacturer__r.Name, CurrencyIsoCode
                                               FROM SBQQ__Quoteline__c
                                               WHERE Id =: quotelineId AND (Competitive_Distributor__c !=null  OR Competitive_Price__c != null OR Competitor_Product__c!= null) ORDER BY SBQQ__Number__c ASC];
        return quotelines; 
    }
  
    // Wrapper class for discount info for ql
    public class QuoteLineDiscountWrapper {
    	public String productName {get; set;}
        public String discountPercentOrPrice {get; set;}
        public String startDate {get; set;}
        public String endDate {get; set;}
    }
    
}