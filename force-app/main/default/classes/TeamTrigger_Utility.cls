public class TeamTrigger_Utility {
    public static FCM_VisitReport__Share createCRShareRecords(Id userId, Id recordId, String access,List<FCM_VisitReport__Share> crShareList){
        List<FCM_VisitReport__Share> crShareList1 = new List<FCM_VisitReport__Share>();
        if(crShareList != null && crShareList.size() > 0){
            for(FCM_VisitReport__Share sh: crShareList){
                if(sh.ParentId == recordId && sh.UserOrGroupId == userId){
                    crShareList1.add(sh);
                }
            }
        }
        if(crShareList1 == null || crShareList1.size() <= 0){
            FCM_VisitReport__Share sh = new FCM_VisitReport__Share();
            sh.AccessLevel = access;
            sh.UserOrGroupId = userId;
            sh.ParentId = recordId;
            sh.RowCause = 'Manual';
            return sh;
        }
        else{
            return null;
        }
    }
    
    public static AccountShare createAccountShareRecords(Id userId, Id recordId, String accAccess, String oppAccess, List<AccountShare> ashList){
        List<AccountShare> ashList1 = new List<AccountShare>();
        if(ashList != null && ashList.size() > 0){
            for(AccountShare ash: ashList){
                if(ash.AccountId == recordId && ash.UserOrGroupId == userId){
                    ashList1.add(ash);
                }
            }
        }
        if(ashList1 == null || ashList1.size() <= 0){
            AccountShare accShare = new AccountShare();
            accShare.AccountAccessLevel = accAccess;
            accShare.OpportunityAccessLevel = oppAccess;
            accShare.UserOrGroupId = userId;
            accShare.AccountId = recordId;
            accShare.RowCause = 'Manual';
            return accShare;
        }
        else
            return null;
    }
    
    public static OpportunityShare createOpportunityShareRecords(Id userId, Id recordId, String access){
        OpportunityShare oppShare = new OpportunityShare();
        oppShare.OpportunityAccessLevel = access;
        oppShare.UserOrGroupId = userId;
        oppShare.OpportunityId = recordId;
        oppShare.RowCause = 'Manual';
        return oppShare;
    }
    
    public static CaseShare createCaseShareRecords(Id userId, Id recordId, String access){
        CaseShare cShare = new CaseShare();
        cShare.CaseAccessLevel = access;
        cShare.UserOrGroupId = userId;
        cShare.CaseId = recordId;
        cShare.RowCause = 'Manual';
        return cShare;
    }
}