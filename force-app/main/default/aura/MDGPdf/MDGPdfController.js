({
	doInit : function(component, event, helper) {
		window.open('/apex/CreditApplicationPDF_New?id='+component.get('v.recordId'), '_blank');
        $A.get("e.force:closeQuickAction").fire();
	}
})