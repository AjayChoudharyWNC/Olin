({
    fetchProductDetails : function(component) {
        var action = component.get('c.getProductDetails');
        action.setParams({
            'prodId' : component.get('v.prodId')
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                var prod = response.getReturnValue();
                if (!prod.Product_Name_Form__c) {
                    prod.Product_Name_Form__c = prod.Purchased_Product_Name__c;
                }
                var p2 = prod.Purchased_Product__r.Product_R1__r.PH1_Performance_Center__c;
                var shipMode = prod.Primary_Ship_Mode__c;
                if ((prod.Onboarding_Ship_To__r.Ship_To_Country__c == 'US' || prod.Onboarding_Ship_To__r.Ship_To_Country__c == 'United States' || prod.Onboarding_Ship_To__r.Ship_To_Country__c == 'USA') &&
                    ((p2 && p2.includes('Chlorine') || p2.includes('CHLORINE') || p2.includes('Sodium Hypochlorite') || p2.includes('SODIUM HYPOCHLORITE') || p2.includes('Bleach') || p2.includes('BLEACH')))) {
                    prod.showUSAQuestions = true;
                }
                else {
                    prod.showUSAQuestions = false;
                }
                if ((prod.Onboarding_Ship_To__r.Ship_To_Country__c == 'CA' || prod.Onboarding_Ship_To__r.Ship_To_Country__c == 'Canada') && 
                    ((p2 && (p2.includes('Sodium Hypochlorite') || p2.includes('Bleach') || p2.includes('SODIUM HYPOCHLORITE') || p2.includes('BLEACH'))))) {
                    prod.showCanadaQuestions = true;
                }
                else {
                    prod.showCanadaQuestions = false;
                }
                component.set('v.prod', prod);
            }
        });
        $A.enqueueAction(action);
    }
})