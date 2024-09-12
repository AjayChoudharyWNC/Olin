public class CallReportTrigger_Utility {
	public static FCM_VisitReport__share getSharingRow(Id groupId, Id crId, String access){
        FCM_VisitReport__share crs = new FCM_VisitReport__share();
        crs.RowCause = 'Manual';
        crs.AccessLevel = access;
        crs.ParentID = crId;
        crs.UserOrGroupId = groupId;
        return crs;
    }
}