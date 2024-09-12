@isTest
public class ManageAccTeamMemBatchTest {
    @isTest
    private static void WhenFinishedCalled_ShouldNotFail(){
        

        Test.startTest();
        List<Account> accList = new List<Account>();
        for(Integer i = 0 ; i < 200; i++){
            accList.add( new Account(Name= i + 'Name'));
        }
        ManageAccountTeamMembersBatchInsert testBatch = new ManageAccountTeamMembersBatchInsert(accList);
        Database.executeBatch(testBatch, 200);
        ManageAccountTeamMembersBatchDelete testBatchDelete = new ManageAccountTeamMembersBatchDelete(accList);
        Database.executeBatch(testBatchDelete, 200);
        Test.stopTest();
    }
}