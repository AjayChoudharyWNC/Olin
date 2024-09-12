public class HelperAccountPlanPDFForm {
    
    @future(callout = true)
    public static void getBlob(String accId){
        
        PageReference pageRef =  new PageReference('/apex/accountplanpdf?id='+accId+'');
        
        Blob Blobfile = null; 
        
        if (Test.IsRunningTest()){
            Blobfile = Blob.valueOf('UNIT.TEST');
        }
        else{
            Blobfile = pageRef.getContent(); 
        }
        Account_Plan__c accPlan = [SELECT Id, Name, CreatedDate, Status__c FROM Account_Plan__c WHERE Id = : accId];
        String pdfName = accPlan.Name+'_'+accPlan.Status__c+'_'+String.valueOf(accPlan.CreatedDate.formatGMT('MMM dd, yyyy HH:mm:ss'));
        ContentVersion v = new ContentVersion();
        v.versionData = Blobfile;
        v.title = pdfName;
        v.pathOnClient ='test.pdf';
        v.ContentLocation = 'S';
        insert v;
        
        ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :v.Id];
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=accId;
        contentlink.ShareType= 'V';
        contentlink.ContentDocumentId=testcontent.ContentDocumentId;
        
        insert contentlink;
    }
}