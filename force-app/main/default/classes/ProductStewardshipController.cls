public class ProductStewardshipController {
    public Boolean showUsaQuestions{get;set;}
    public Boolean showCanadaQuestions{get;set;}
    public Boolean showEup{get;set;}
    public Boolean showMup{get;set;}
    public Boolean showPmraLabel{get;set;}
    public Boolean showQuality {get;set;}
    
    public ProductStewardshipController(ApexPages.StandardController sc){
        String psaId = sc.getId();
        showUsaQuestions = false;
        showCanadaQuestions = false;
        showPmraLabel = false;
        showEup = false;
        showMup = false;
        showQuality = false;
        Questionnaire__c q = [SELECT SAP_Onboarding__r.Name, Name, Onboarding_Product__r.Purchased_Product__r.Product_R1__r.PH1_Performance_Center__c, Onboarding_Product__r.Onboarding_Ship_To__r.Ship_To_Country__c, Onboarding_Product__r.Location_required_FIFRA_Registration__c, 
                              Onboarding_Product__r.Is_Customer_a_Direct_EUP_End_User__c, Onboarding_Product__r.EPA_FIFRA_or_PMRA_PCP_Required__c, Onboarding_Product__r.Does_the_California_Mill_Tax_Apply__c, Onboarding_Product__r.How_Is_California_Mill_Tax_Priced__c,
                              Onboarding_Product__r.Any_Specific_Quality_Standards__c, Onboarding_Product__r.Specific_Quality_Standards_Other__c, Onboarding_Product__r.Any_Customer_Specifications__c, Onboarding_Product__r.Purchased_Product__r.Product_Family__c,
                              Onboarding_Product__r.Onboarding_Ship_To__r.Ship_To_Company_Name__c, Onboarding_Product__r.Onboarding_Ship_To__r.Ship_To_City__c, Onboarding_Product__r.Onboarding_Ship_To__r.Ship_To_State_Province__c FROM Questionnaire__c WHERE Id =:psaId];
        String fileName = q.SAP_Onboarding__r.Name+'-'+q.Name;
        Apexpages.currentPage().getHeaders().put('content-disposition', 'attachment; filename='+fileName+'-'+ApexPages.currentPage().getUrl().substringBetween('apex/', '?')+'.pdf');
        String country = q.Onboarding_Product__r.Onboarding_Ship_To__r.Ship_To_Country__c;
        String p2 = q.Onboarding_Product__r.Purchased_Product__r.Product_R1__r.PH1_Performance_Center__c;
        if(String.isNotBlank(p2) && String.isNotBlank(country)){
            if ((country == 'US' || country == 'United States' || country == 'USA') &&
                ((p2.contains('Chlorine') || p2.contains('CHLORINE') || p2.contains('Sodium Hypochlorite') || p2.contains('SODIUM HYPOCHLORITE') || p2.contains('Bleach') || p2.contains('BLEACH')))) {
                    showUSAQuestions = true;
                }
            else {
                showUSAQuestions = false;
            }
            
            if ((country == 'CA' || country == 'Canada') && 
                ((String.isNotBlank(p2) && (p2.contains('Sodium Hypochlorite') || p2.contains('Bleach') || p2.contains('SODIUM HYPOCHLORITE') || p2.contains('BLEACH'))))) {
                    showCanadaQuestions = true;
                }
            else {
                showCanadaQuestions = false;
            }
        }
        else{
            showUSAQuestions = false;
            showCanadaQuestions = false;
            
        }
        if(q.Onboarding_Product__r.Location_required_FIFRA_Registration__c == 'Yes'){
            showMup = true;
            if(q.Onboarding_Product__r.Is_Customer_a_Direct_EUP_End_User__c == 'No'){
                showEup = true;
            }
        }
        if(showCanadaQuestions && q.Onboarding_Product__r.EPA_FIFRA_or_PMRA_PCP_Required__c == 'Yes'){
            showPmraLabel = true;
        }
        if(q.Onboarding_Product__r.Purchased_Product__r.Product_Family__c == 'CAPV'){
            showQuality = true;
        }
    }
}