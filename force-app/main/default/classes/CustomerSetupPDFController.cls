public class CustomerSetupPDFController {
    public List<Application_User__c> appUserList{get;set;}
    public List<Onboarding_Product__c> prodList{get;set;}
    public List<Onboarding_Ship_To__c> shipToList{get;set;}
    public List<Vat__c> vatList{get;set;}    
    Public List<Attachment> bankRefFiles{get;set;}
    Public List<Attachment> tradeRefFiles{get;set;}
    
    public CustomerSetupPDFController(ApexPages.StandardController controller){
        String sapId = controller.getId();
        appUserList = new List<Application_User__c>();
        bankRefFiles = new List<Attachment>();
        tradeRefFiles = new List<Attachment>();
        prodList = new List<Onboarding_Product__c>();
        shipToList = new List<Onboarding_Ship_To__c>();
        vatList = new List<Vat__c>();
        bankRefFiles = [SELECT Id, Name FROM Attachment WHERE ParentId =:sapId AND Description LIKE :'%bankReferenceFile%'];
        tradeRefFiles = [SELECT Id, Name FROM Attachment WHERE ParentId =:sapId AND Description LIKE :'%tradeReferenceFile%'];
        appUserList = [SELECT Id, Name, First_Name__c, Last_Name__c, Email__c, Mobile_Phone__c, Title__c FROM Application_User__c WHERE SAP_Onboarding__c =:sapId];
        shipToList = [Select Id , Name , Account__r.SFACCTNUM__c,Ship_To_Street__c, Ship_To_State_Province__c , Ship_To_Postal_Code__c, Ship_To_No__c,Ship_To_Country__c,Ship_To_City__c,SAP_Onboarding__r.Status__c, Regulatory_First_Name__c, Regulatory_Last_Name__c,Regulatory_Email__c, Regulatory_Phone__c, 
                      Regulatory_Title__c, Regulatory_Fax__c,Ship_To_Company_Name__c, Ship_To_Street_2__c, Order_Confirmation_Email_Fax__c, Preferred_Method_of_Order_Confirmation__c, Bill_of_Lading_Email_Fax__c, Preferred_Method_of_Bill_of_Lading__c,Buyer_First_Name__c,Buyer_Last_Name__c, Buyer_Title__c,
                      Buyer_Email__c, Buyer_Phone__c, Buyer_Fax__c, SDS_Delivery_Email_Fax__c, Preferred_Method_of_MSDS_Delivery__c, Certificate_of_Analysis_Email_Fax__c, Preferred_Method_of_Certifi_of_Analysis__c, Delivery_Point_First_Name__c, Delivery_Point_Last_Name__c, Delivery_Point_Title__c, Delivery_Point_Email__c,
                      Delivery_Point_Phone__c, Delivery_Point_Fax__c, After_Hours_First_Name__c, After_Hours_Last_Name__c, After_Hours_Title__c, After_Hours_Email__c, After_Hours_Phone__c, After_Hours_Fax__c from Onboarding_Ship_To__c Where SAP_Onboarding__c =:sapId];
        prodList = [SELECT Id, Name, Purchased_Product__r.Product_R1__r.Name, Purchased_Product__r.Product_R1__r.Business_Group__c, Ship_Mode__c, Volume_Period__c, Estimated_Volume__c, Product_UOM__c, Estimated_Date_of_First_Shipment__c,Onboarding_Ship_To__c,
                    Any_Customer_Specifications__c, Onboarding_Ship_To__r.Name, Onboarding_Ship_To__r.Ship_To_No__c,New_Customer_Ship_Mode__c,  Regulatory_First_Name__c, Regulatory_Last_Name__c,Regulatory_Email__c, Regulatory_Phone__c, 
                    Regulatory_Title__c, On_Site_Assessment_First_Name__c, On_Site_Assessment_Last_Name__c, On_Site_Assessment_Email__c, On_Site_Assessment_Phone__c, On_Site_Assessment_Title__c, Is_a_Ship_To_Site_Assessment_Needed__c,
                    SAP_Onboarding__r.Status__c,Any_Non_Standard_Product_Specifications__c,Primary_Ship_From__r.Name,Primary_Ship_From__r.SAP_ID__c, CA_Mill_Tax__c,Scale_UOM__c,Energy_Surcharge__c,Scales__c,UOM__c,FSC_Exempt__c,INCO_Terms__c,Validity_Start_Date__c,Validity_End_Date__c,GradeConcentration__c,Initial_Price__c,Currency__c,
                    Scale_1_Volume__c,Scale_2_Volume__c,Scale_3_Volume__c,Scale_4_Volume__c,Scale_5_Volume__c,Scale_1_Price__c,Scale_2_Price__c,Scale_3_Price__c,Scale_4_Price__c,Scale_5_Price__c,Has_Regulatory_Info__c,
                    X2nd_Scales__c,X2nd_Scale_3_Volume__c,X2nd_Scale_4_Volume__c,X2nd_Scale_5_Volume__c,X2nd_Scale_2_Volume__c, X2nd_Scale_UOM__c,X2nd_Scale_1_Volume__c,Additional_Ship_From_Price__c,Is_a_Shipment_Questionnaire_Needed__c,
                    X2nd_Scale_1_Price__c,X2nd_Scale_2_Price__c,X2nd_Scale_3_Price__c,X2nd_Scale_4_Price__c,List_Price__c,X2nd_Scale_5_Price__c,Additional_Alternate_ship_From__c,Additional_Pricing_Comments_Charges__c,Additional_Volume__c,Additional_Price__c,
                    Customer_Establishment_No__c,Any_Specific_Quality_Standards__c, Specific_Quality_Standards_Other__c,How_Is_California_Mill_Tax_Priced__c,Is_EPA_FIFRA_PMRA_PCP_Registration__c,Additional_Alternate_ship_From__r.Name,Does_the_California_Mill_Tax_Apply__c,How_are_you_using_your_product__c,Is_EUP_or_MUP__c,Customer_Has_Registered_Label__c,
                    Customer_Pickup__c, Truck_Type__c, Customer_Material_Number__c, Customer_Material_Number_Free_Text__c, Purchased_Product__r.Product_R1__r.GMID_Number__c, (SELECT Id FROM Attachments WHERE Description ='Product Specification Attachment') FROM Onboarding_Product__c WHERE SAP_Onboarding__c =:sapId];
        vatList = [SELECT Country__c, Tax_VAT1_Exempt__c, VAT_Tax_Number__c,Tax_Type__c, Tax_Type_Code__c FROM VAT__c WHERE SAP_Onboarding__c =:sapId];
    }
}