public class MigrateFeedItem {
    
    @InvocableMethod(label='Migrate Chatter' Description='Migrate chatter feed from one record to another')
    public static void migrateFeed(List<CallReportClass> params){
        String oldParent = params.get(0).oldParentId;
        String newParent = params.get(0).newParentId;
        Map<String, FeedItem> clonedFeedItemMap = new Map<String, FeedItem>();
        Map<String, FeedComment> clonedFeedCommentMap = new Map<String, FeedComment>();
        for(FeedItem original : [SELECT BestCommentId, Body, CommentCount, CreatedById, CreatedDate, CreatedBy.IsActive, CreatedBy.Name, 
                                 HasContent, HasLink, Id, IsDeleted, LastEditById, LastEditDate, LastModifiedDate, LikeCount, CreatedBy.Profile.UserType,
                                 LinkUrl, ParentId, RelatedRecordId, Revision, SystemModstamp, Title, Type,
                                 (SELECT CommentBody, CommentType, CreatedById, CreatedDate, FeedItemId,
                                  IsDeleted, LastEditById, LastEditDate, ParentId, RelatedRecordId, Revision FROM FeedComments)
                                 FROM FeedItem WHERE ParentId = :oldParent AND (NOT Type IN ('TrackedChange'))]) {
                                     
                                     FeedItem clone = original.clone(false, false, true, true);
                                     clone.ParentId = newParent;
                                     if(original.CreatedBy.Profile.UserType != 'Standard' || !original.CreatedBy.IsActive){
                                         clone.CreatedById = UserInfo.getUserId();
                                     }
                                     clonedFeedItemMap.put(original.Id, clone);
                                     for(FeedComment comment : original.FeedComments){
                                         FeedComment cloneComment = comment.clone(false, false, true, true);
                                         clonedFeedCommentMap.put(comment.Id+'--'+comment.FeedItemId, cloneComment);
                                     }
                                 }
        if(clonedFeedItemMap != null && clonedFeedItemMap.values() != null){
            insert clonedFeedItemMap.values();
        }
        for(String commentId : clonedFeedCommentMap.keySet()){
            String feedItemId = commentId.split('--')[1];
            if(clonedFeedItemMap.containsKey(feedItemId)){
                clonedFeedCommentMap.get(commentId).FeedItemId = clonedFeedItemMap.get(feedItemId).Id;
            }
        }
        if(clonedFeedCommentMap != null && clonedFeedCommentMap.values() != null){
            insert clonedFeedCommentMap.values();
        }
        
    }
    
    public class CallReportClass{
        @InvocableVariable
        public String oldParentId;
        @InvocableVariable
        public String newParentId;
    }
}