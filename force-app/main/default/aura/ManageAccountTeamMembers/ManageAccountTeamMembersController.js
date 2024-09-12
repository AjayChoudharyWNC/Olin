({
    doInit : function(component, event, helper) {
        console.log('Loaded doInit');
        var getUser = component.get("c.getUser");
        getUser.setParams({
            acctId : component.get("v.recordId")
		});
        getUser.setCallback(this, function(a){
            console.log('Has edit: ', a.getReturnValue());
            component.set("v.hasEdit", a.getReturnValue());
        });
        $A.enqueueAction(getUser);
        
        helper.getAccountTeamMember(component, event, helper);
        helper.getPicklistValue(component, event, helper);
    },

    onChangeTeamRole : function(component, event, helper) {
        var selectedItem = event.getSource();
        var selectedValue = selectedItem.get("v.value");
        console.log('Selected Team Role: ', selectedValue);
        component.set("v.teamRole", selectedValue);
    },

    onChangeAccountAccess : function(component, event, helper) {
        var selectedItem = event.getSource();
        var selectedValue = selectedItem.get("v.value");
        console.log('Selected Account Access: ', selectedValue);
        component.set("v.accountAccess", selectedValue);
    },

    onChangeOppAccess : function(component, event, helper) {
        var selectedItem = event.getSource();
        var selectedValue = selectedItem.get("v.value");
        console.log('Selected Opportunity Access: ', selectedValue);
        component.set("v.oppoAccess", selectedValue);
    },

    onClick : function(component, event, helper) {
        var selectedLineItem = event.currentTarget.id;
        console.log('Clicked line item: ', selectedLineItem);
        var allLineItems = component.get("v.selectedAccountTeamMembers");
        allLineItems.push(selectedLineItem);
        component.set("v.selectedAccountTeamMembers", allLineItems);
    },

    saveChanges : function(component, event, helper) {
        helper.handleSaveChanges(component, event, helper);
    },
    
    fullSave : function(component, event, helper) {
        helper.addUser(component, event, helper);
        helper.handleFullSave(component, event, helper);
    },

    deleteLines : function(component, event, helper) {
        helper.handleDelete(component, event, helper);
    },
    
    lineDelete : function(component, event, helper) {
        var idx = event.getSource().get("v.name");
        var list = component.get("v.accountTeamMemberList");
        var delList = [];
        if(list[idx].Id){
            delList.push(list[idx].Id);
            component.set("v.selectedAccountTeamMembers", delList);
            helper.handleDelete(component, event, helper);
        }
        list.splice(idx, 1);
        component.set("v.accountTeamMemberList", list);
        
    },

    cancelChanges : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },

    updateStage :function(component, event, helper) {
		try {
			var jsonParam = JSON.parse(event.getParam("jsonParam"));
			component.set("v.entityId", jsonParam.id);
            component.set("v.entityName", jsonParam.name);
		} catch(e) {
			component.set("v.entityId");
            component.set("v.entityName");
            console.log('ID: ', component.get("v.entityId"));
		}
	},
    
    addUser : function(component, event, helper) {
        var newMember = {};
        newMember.AccountId = component.get("v.recordId");
        newMember.TeamMemberRole = component.find("selectedTeamRole").get("v.value");
        newMember.UserId = component.get("v.entityId");
        newMember.User = {};
        newMember.User.Name = component.get("v.entityName");
        
        newMember.utilAccount = {};
        newMember.utilAccount.read = true;
        newMember.utilAccount.write = false;
        newMember.utilOpp = {};
        newMember.utilOpp.read = true;
        newMember.utilOpp.write = false;
        
        if(newMember.UserId && newMember.TeamMemberRole) {
            var memberList = component.get("v.accountTeamMemberList");
            memberList.push(newMember);
            component.set("v.accountTeamMemberList", memberList);
            component.find("selectedTeamRole").set("v.value");
            component.set("v.lookupRepaint", false);
            component.set("v.lookupRepaint", true);
        }
    },
    
    acctRead : function(component, event, helper) {
        var idx = event.getSource().get("v.name");
        var list = component.get("v.accountTeamMemberList");
        list[idx].utilAccount.read = !list[idx].utilAccount.read;
        if(!list[idx].utilAccount.read) list[idx].utilAccount.write = false;
        component.set("v.accountTeamMemberList", list);
    },
    
    acctWrite : function(component, event, helper) {
        var idx = event.getSource().get("v.name");
        var list = component.get("v.accountTeamMemberList");
        list[idx].utilAccount.write = !list[idx].utilAccount.write;
        if(list[idx].utilAccount.write) list[idx].utilAccount.read = true;
        component.set("v.accountTeamMemberList", list);
    },
    oppRead : function(component, event, helper) {
        var idx = event.getSource().get("v.name");
        var list = component.get("v.accountTeamMemberList");
        list[idx].utilOpp.read = !list[idx].utilOpp.read;
        if(!list[idx].utilOpp.read) list[idx].utilOpp.write = false;
        component.set("v.accountTeamMemberList", list);
    },
    
    oppWrite : function(component, event, helper) {
        var idx = event.getSource().get("v.name");
        var list = component.get("v.accountTeamMemberList");
        list[idx].utilOpp.write = !list[idx].utilOpp.write;
        if(list[idx].utilOpp.write) list[idx].utilOpp.read = true;
        component.set("v.accountTeamMemberList", list);
    }
})