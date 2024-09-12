public class UtilityClass {
	// Get Field information from field set
	// Takes field set name and object name
	public static List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String objectName) {
		Map<String, Schema.SObjectType> globalDescribeMap = Schema.getGlobalDescribe(); 
		Schema.SObjectType sObjType = globalDescribeMap.get(ObjectName);
		Schema.DescribeSObjectResult DescribeSObjectResultObj = sObjType.getDescribe();

		Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
		return fieldSetObj.getFields(); 
	}  

    // Generates a of Map of Field API and Label based on the Field Set
	public static Map<String,String> getEditableFieldApiNames(String fieldSetName, String objectName) {
		Map<String, Schema.SObjectField> allFieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        Map<String,String> fieldApiNamesMap = new Map<String,String>();
		for(Schema.FieldSetMember fsm : readFieldSet(fieldSetName, objectName)) {
			if (allFieldMap.get(fsm.getFieldPath()).getDescribe().isCreateable() && allFieldMap.get(fsm.getFieldPath()).getDescribe().isUpdateable()) {
				fieldApiNamesMap.put(fsm.getFieldPath(), fsm.getLabel());
			}
		}
		return fieldApiNamesMap;
	}

	// Generates a of Map of Field API and Label based on the Field Set
	public static Map<String,String> getFieldApiNames(String fieldSetName, String objectName) {
        Map<String,String> fieldApiNamesMap = new Map<String,String>();
		for(Schema.FieldSetMember fsm : readFieldSet(fieldSetName, objectName)) {
            fieldApiNamesMap.put(fsm.getFieldPath(), fsm.getLabel());
		}
		return fieldApiNamesMap;
	}

	/*******************************************************************************************************
	* @description Allows us to compose a comma separated string of fields from a field set.
	* @param fieldSetName The name of the field set
	* @param objectName The name of the object to look up
	* @return A String of comma separated fields from the specified field set.
	*/
	public static String getFieldSetSoqlString(String fieldSetName, String objectName) {
		return getFieldSetSoqlString(readFieldSet(fieldSetName, objectName));
	}

	/*******************************************************************************************************
	* @description Allows us to compose a comma separated string of fields from a field set.
	* @param listFieldSetMember A list of FieldSetMember objects
	* @return A String of comma separated fields from the specified field set.
	*/
	public static String getFieldSetSoqlString(List<Schema.FieldSetMember> listFieldSetMember) {
		List<String> listFieldApiNames = new List<String>();
		for(Schema.FieldSetMember fieldSetMemberObj : listFieldSetMember) {
			listFieldApiNames.add(fieldSetMemberObj.getFieldPath());
		}
		return String.join(listFieldApiNames, ',');
	}

	/*******************************************************************************************************
	* @description Return a set of Ids from a list of sObjects
	* @param listSObject A list of SObjects
	* @return A Set of Ids
	*/
	public static Set<Id> getListRecordIds(List<SObject> lSobj) {
		Set<Id> ids = new Set<Id>();
		for (SObject sobj : lSobj) {
			ids.add((Id) sobj.get('Id'));
		}
		return ids;
	}
}