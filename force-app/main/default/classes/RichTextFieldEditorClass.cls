public class RichTextFieldEditorClass {
    @AuraEnabled
    public static RichWrapper FetchType(String recordId,String fieldApiName) {
        boolean showEdit;
        boolean msg;
        boolean isRichText;
        String objname ;
        String keyCode  = recordId.subString(0,3);
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        for(Schema.SObjectType objectInstance : gd.values()){
            if(objectInstance.getDescribe().getKeyPrefix() == keyCode)
            {
                objname =  objectInstance.getDescribe().getName();
            }
        }
        
        Map<String, Schema.sObjectField> schemaFieldMap = gd.get(objname).getDescribe().fields.getMap();
        Schema.DisplayType field = schemaFieldMap.get(fieldApiName).getDescribe().getType();
        if (schemaFieldMap.get(fieldApiName).getDescribe().getType() == Schema.DisplayType.TEXTAREA && schemaFieldMap.get(fieldApiName).getDescribe().isHtmlFormatted()) {
            isRichText = true;
            system.debug('isRichText'+isRichText);
        }
        else
        {isRichText =  false;}
        
        SObjectType schemaType = Schema.getGlobalDescribe().get(objname);
        Map<String, SObjectField> fields = schemaType.getDescribe().fields.getMap();
        DescribeFieldResult fieldDescribe = fields.get(fieldApiName).getDescribe();
        if(fieldDescribe.isAccessible()){
            if(fieldDescribe.isUpdateable()){
                showEdit = true;
            }
            else
            {
                showEdit =  false;
            }
        }
        else{
            msg = true;
        }
        RichWrapper obj = new RichWrapper();
        obj.objname = objname;
        obj.isRichText = isRichText;
        obj.showEdit = showEdit;
        obj.msg = msg;
        return obj;
        
    }
    public class RichWrapper{
        @AuraEnabled public String objname;
        @AuraEnabled public boolean isRichText;
        @AuraEnabled public boolean showEdit;
        @AuraEnabled public boolean msg;
    }
}