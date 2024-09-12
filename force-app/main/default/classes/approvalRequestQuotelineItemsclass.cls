public class approvalRequestQuotelineItemsclass
{
   
//public Id quoteid {get;set;}
public Id quotelineId {get;set;}
    public String percentDiscount{get;set;}
    public String flatDiscount{get;set;}
    
    public List<SBQQ__Quoteline__c> getquotelines()
    {
        if(quoteLineId == null){
            return new List<SBQQ__Quoteline__c>();
        }
        List<SBQQ__Quoteline__c> quotelines;
        //TKT-144 added Display_Options__c field
        quotelines = [Select Name, Convtd_Netback__c,Display_Discount__c,Display_Product_Code__c,SBQQ__ProductName__c, Price_Period_Volume__c, Agreement_Volume_UOM_Concatenated__c, Avg_Annualize_Volume__c, Base_Volume__c, Current_Price__c, 
                      Ship_From_Plant_List__r.Name, Base_UOM__c, Base_Price__c, SBQQ__ListPrice__c, Price_Change_Mechanism__c, Price_Change_Frequency__c, 
                      Validity_Period__c, Ship_To_Name__c, SBQQ__CustomerPrice__c, Incoterm__c, Price_Start_Date__c, Price_Firm_Date__c, Freight_Charge__c, 
                      Freight_Component__c, SBQQ__NetPrice__c, Formula__c, Price_Freight_Info__c, Quantity_with_UOM__c, Shipping_Condition__c, 
                      Shipping_Condition_Label__c, Destination_City_State_Country_Ship_To__c, Convtd_PlantNet__c, Per_Quantity__c, Avg_Annualize_Volume_Display__c, 
                      CurrencyIsoCode, Previous_Price_Value__c, UOM__c, Price_Freight_Info_CAPV_NA__c, Total_Price_Approval_Email__c, Minimum_Price__c, 
                      Price_Change_Delta__c, Price_Change_Min_Price_Delta__c, Discount_Percent__c, SBQQ__DistributorDiscount__c, SBQQ__TotalDiscountAmount__c, 
                      Prior_Price_with_Multiplier_Conversion__c, Freight_Charges_with_Multiplier_Conversi__c, Freight_Component_with_Multiplier_Conver__c, 
                      Product_Discount_Amount__c, Quote_Document_Currency__c, Product_Name_on_Proposal__c, Minimum_Price_EMEIA__c, New_Price_with_Multiplier_Conversion__c, 
                      ProductName_Concatenated__c, Product_Commodity_Index_Name__c, Adjustment_Factor__c, Discount_Field__c, Volume_Period__c, Formula_Description__c, 
                      Customer_Product_Code__c, Product_Level__c, Volume_Template_Output__c, Discount_Percent_Template__c, Initial_Product_Price__c, 
                      SBQQ__Quote__r.Price_Request_Version__c, Hide_Prior_Price__c, Rebate_Information__c, Display_Options__c, Adder_Type__c, Net_Back__c 
                      FROM SBQQ__Quoteline__c where Id =: quotelineId ORDER BY    SBQQ__Number__c ASC];
                      //from SBQQ__Quoteline__c where SBQQ__Quote__r.id =: quoteid ORDER BY    SBQQ__Number__c ASC];            
       
        List<SBQQ__Quoteline__c> childrenQuotes = [SELECT Quote_Document_Currency__c, Adder_Type__c, Display_Product_Code__c, Display_Discount__c, SBQQ__CustomerPrice__c FROM SBQQ__Quoteline__c WHERE SBQQ__RequiredBy__c =: quotelineId];
        for(SBQQ__Quoteline__c quoteLine: childrenQuotes){
            if(quoteLine.Display_Product_Code__c.equals('Distributor Discount')){
                percentDiscount = quoteLine.Display_Discount__c;
            }else if(quoteLine.Display_Product_Code__c.contains('Product Discount Amount')){
                flatDiscount = quoteLine.Quote_Document_Currency__c + String.valueOf(quoteLine.SBQQ__CustomerPrice__c) + ' ' + quoteLine.Adder_Type__c;
            }
       }
        
        return quotelines;
    }
}