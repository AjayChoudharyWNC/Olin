@isTest
private class MigrateFeedItem_Test {
    
    private static String RAND = 'abcd' + System.now();
    
    
    @isTest
    private static void testMigration() {
     
         Account acc = new Account(Name='Test Account',RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Parent').getRecordTypeId(),AccountNumber_R1__c='12345',AccountSource='S4');
        insert acc;        
        FeedItem post = new FeedItem();
		post.ParentId = acc.Id; 
		post.Body = RAND;
    	insert post;
        
        FeedComment cmt = new FeedComment();
        cmt.FeedItemId = post.Id; 
		cmt.CommentBody = RAND;
    	insert cmt;
        
        Contact con = new Contact(LastName='Doe');
        insert con;
        
        
        // Exercise
        MigrateFeedItem.CallReportClass wrapper = new MigrateFeedItem.CallReportClass();
        wrapper.oldParentId = acc.Id;
        wrapper.newParentId = con.Id;
        MigrateFeedItem.migrateFeed(new List<MigrateFeedItem.CallReportClass>{wrapper});
        
        // Verify
        FeedItem clone = [SELECT Body FROM FeedItem WHERE ParentId = :con.Id LIMIT 1];
        System.assertEquals(RAND, clone.Body); 
        
        FeedComment commentClone = [SELECT CommentBody FROM FeedComment WHERE FeedItemId = :clone.Id LIMIT 1];
        System.assertEquals(RAND, commentClone.CommentBody); 
    }
}