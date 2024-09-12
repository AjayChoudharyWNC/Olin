public class StewardshipPDFMain {
    
    public List<Questionnaire__c> quesList {get;set;}
    public Boolean hasChlorine{get;set;}
    
    public StewardshipPDFMain(ApexPages.StandardController sc){
        quesList = new List<Questionnaire__c>();
        String sapId = sc.getId();
        quesList = [SELECT Id, RecordType.Name, Name, Primary_Ship_Mode__c, Account_Name__r.BillingCity, Account_Name__r.BillingCountry, Onboarding_Product_Name__c, Questionnaire_Setup_Type__c,
                    Onboarding_Product__r.Purchased_Product__r.Performance_Center__c, Onboarding_Ship_To__r.Ship_To_City__c, Onboarding_Ship_To__r.Ship_To_State_Province__c, Onboarding_Ship_To__r.Ship_To_Country__c, Account_Name__r.ShippingCountry FROM Questionnaire__c WHERE SAP_Onboarding__c =:sapId];
        for(Integer i=0;i<quesList.size();i++){
            if(quesList[i].Onboarding_Product__r.Purchased_Product__r.Performance_Center__c == 'CHLORINE' || quesList[i].Onboarding_Product__r.Purchased_Product__r.Performance_Center__c == 'Chlorine'){
                hasChlorine = true;
                break;
            }
        }
    }

}