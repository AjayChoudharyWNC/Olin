public with sharing class QuoteApprovalActionController {

    @AuraEnabled
    public static String getFieldsAndRecords(String strObjectApiName, String strfieldSetName, String criteriaField, String criteriaFieldValue){
        
        Map<String, String> returnMap = new Map<String,String>();
        
        if(!String.isEmpty(strObjectApiName) && !String.isEmpty(strfieldSetName)) {
            //get fields from FieldSet
            SObject sObj = (SObject)(Type.forName('Schema.'+ strObjectApiName).newInstance());
            List<Schema.FieldSetMember> lstFSMember = sObj.getSObjectType().getDescribe().fieldSets.getMap().get(strfieldSetName).getFields();

            //prepare SOQL query based on fieldAPIs	
            String query = 'SELECT ';
            for(Schema.FieldSetMember f : lstFSMember) {
                query += f.getFieldPath() + ', ';
                if(f.getType() == Schema.DisplayType.Reference) {
                    query += f.getFieldPath().replace('__c', '__r') + '.Name' + ', ';
                }
            }
            query += 'Id, Name FROM ' + strObjectApiName ;

            //Just in case criteria field not specified then it will return all records
            if(!(String.isEmpty(criteriaField) && String.isEmpty(criteriaFieldValue))){
                query += ' WHERE ' + criteriaField + '=\'' + criteriaFieldValue + '\'';
            }
            if(strObjectApiName == 'SBQQ__Quoteline__c') {
                query += ' AND ( ApprovalStatus__c = null OR ApprovalStatus__c = \'Rejected\' OR ApprovalStatus__c = \'Recalled\') AND SBQQ__RequiredBy__c = null';
            }
                        
	        //execute query
            List<SObject> lstRecords = Database.query(query);
            
            //prepare a map which will hold fieldList and recordList and return it
	        returnMap.put('FIELD_LIST', JSON.serialize(lstFSMember));
	        returnMap.put('RECORD_LIST', JSON.serialize(lstRecords));
	        return JSON.serialize(returnMap);
        }
        return null;
    }

    @AuraEnabled
    public static List<id> getQuoteLineIds(String quoteId){
        List<Id> quoteLineIds = new List<Id>();
        List<SBQQ__Quoteline__c> quoteLines = [SELECt Id, ApprovalStatus__c FROM SBQQ__Quoteline__c WHERE SBQQ__Quote__c =:quoteId
            AND ApprovalStatus__c != 'Approved'];    
        for(SBQQ__Quoteline__c quoteLine : quoteLines) {
            quoteLineIds.add(quoteLine.Id);
        }
        return quoteLineIds;
    }

    
    @AuraEnabled
    public static Boolean approveQuoteLine(String quoteLineId){

        Boolean success = false;

        SBQQ.TriggerControl.disable(); //TKT-121
        try {
            DateTime start = system.now();
            //while(system.now()< start.addseconds(10)){}
            SBAA.ApprovalAPI.submit(quoteLineId, SBAA__Approval__c.Quote_Line__c);
            success = true;
        }
        catch (Exception ex) {
            success = false;
            throw ex;
        } finally { //TKT-121
            //SBQQ.TriggerControl.enable();
        }

        return success;
    }

}