global class CustomerSetupNotificationGCO {
    global String sfBaseUrl{
        get{
            return System.URL.getOrgDomainUrl().toExternalForm();
        }
        
        set;
    }
    
    global String sapRecordId{get;set;}
    global SAP_Onboarding__c sapRecord{
        get{
            sapRecord = [SELECT Id, Name, Form_Due_Date__c, Estimated_Date_Of_First_Shipment__c, Status__c, Credit_Application_Status__c, Customer_Information_Status__c, Order_Placement_Status__c, Product_Stewardship_Status__c, Account__r.Name, Account__r.BillingStreet, 
                         Account__r.BillingCity, Account__r.BillingState, Account__r.BillingPostalCode, Account__r.BillingCountry, Sold_To_Company_Name__c,Sold_To_Street__c, Sold_To_Street_2__c, Sold_To_City__c, Sold_To_State_Province__c,
                         Sold_To_Country__c, Sold_To_Postal_Code__c FROM SAP_Onboarding__c WHERE Id =:sapRecordId];
            return sapRecord;        
        }
        set;
    }
    
    global List<Onboarding_Ship_To__c> shipToList{
        get{
            shipToList = [SELECT Id, Name, Ship_To_Company_Name__c, Ship_To_Street__c, Ship_To_Street_2__c, Ship_To_City__c, Ship_To_Country__c, Ship_To_State_Province__c, Ship_To_Postal_Code__c,
                          (SELECT Id, Name, Purchased_Product__r.Product_R1__r.Name, Purchased_Product__r.Product_R1__r.Business_Group__c, Ship_Mode__c, Product_UOM__c, Volume_Period__c, Estimated_Volume__c, Shipment_Questionnaire__c,
                           Is_a_Ship_To_Site_Assessment_Needed__c, New_Customer_Ship_Mode__c FROM Onboarding_Products__r WHERE Purchased_Product__r.Product_R1__r.Business_Group__c LIKE '%GCO%') FROM Onboarding_Ship_To__c WHERE SAP_Onboarding__c =:sapRecordId];
            return shipToList;
        }
        set;
    }
}