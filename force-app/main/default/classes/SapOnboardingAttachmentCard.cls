public class SapOnboardingAttachmentCard {
    
   
	
    @AuraEnabled
    public static Object createFileWrapper(String type, String recId){
        try{
            if(type == 'Tax'){
                List<Attachment> taxList = SapOnboardingAttachments.getTaxVatFiles(recId);
                if(taxList != null && !taxList.isEmpty()){
                    return prepareWrapper(taxList);
                }
                else{
                    return 'No Tax/VAT Documents are attached.';
                }
            }
            else if(type == 'Finance'){
                List<Attachment> fList = SapOnboardingAttachments.getSapOnboardingFiles(recId);
                if(fList != null && !fList.isEmpty()){
                    return prepareWrapper(fList);
                }
                else{
                    return 'No Financial Statements are attached.';
                }
            }
            else if(type == 'Product'){
                List<Attachment> fList = SapOnboardingAttachments.getProductFiles(recId);
                if(fList != null && !fList.isEmpty()){
                    return prepareWrapper(fList);
                }
                else{
                    return 'No Product Specification Documents are attached.';
                }
            }
            else if(type == 'Assessment'){
                List<Attachment> fList = SapOnboardingAttachments.getAssessmentFiles(recId);
                if(fList != null && !fList.isEmpty()){
                    return prepareWrapper(fList);
                }
                else{
                    return 'No Assessment Supporting Documents are attached.';
                }
            }
            else{
                return null;
            }
        }
        catch(Exception e){
            System.debug('exception=='+e+ e.getLineNumber());
            return e.getMessage();
        }
    }
    
    public static List<FileWrapper> prepareWrapper(List<Attachment> attList){
        List<FileWrapper> fwList = new List<FileWrapper>();
        for(Attachment att: attList){
            FileWrapper fw = new FileWrapper();
            fw.link = '/servlet/servlet.FileDownload?file='+att.Id;
            fw.relatedToId = att.ParentId;
            fw.relatedToName = att.Parent.Name;
            fw.name = att.Name;
            fw.createdDate = att.CreatedDate;
            fwList.add(fw);
        }
        return fwList;
    }
    
    public class FileWrapper{
        @AuraEnabled public String link;
        @AuraEnabled public String relatedToId;
        @AuraEnabled public String relatedToName;
        @AuraEnabled public String name;
        @AuraEnabled public DateTime createdDate;
    }
}