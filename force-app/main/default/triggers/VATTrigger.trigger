trigger VATTrigger on VAT__c (before insert, before update) {
    
    List<Tax_Type__mdt> taxTypeList = [SELECT Id, DeveloperName, Country__c, Tax_Type__c,MasterLabel FROM Tax_Type__mdt];
    for(VAT__c vat : Trigger.New){
        if(String.isNotBlank(vat.Country__c) && String.isNotBlank(vat.Tax_Type__c)){
            for(Tax_Type__mdt t : taxTypeList){
                String vtCountry = vat.Country__c;
                if(vtCountry.split('\\(')[0].trim() == t.Country__c && vat.Tax_Type__c == t.Tax_Type__c){
                    vat.Tax_Type_Code__c = t.MasterLabel;
                    break;
                }
                else{
                    vat.Tax_Type_Code__c = '';
                }
            }
        }
    }
    
}