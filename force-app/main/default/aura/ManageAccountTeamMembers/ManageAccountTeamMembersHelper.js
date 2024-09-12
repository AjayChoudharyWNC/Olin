({
    getAccountTeamMember : function(component, event, helper) {
        component.set("v.saving", true);
        var action = component.get("c.getAccountTeamMembers");
        action.setParams({
            accountId : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            component.set("v.accountTeamMemberList", helper.setList(response));
            component.set("v.saving", false);
        });
        $A.enqueueAction(action);
    },

    getPicklistValue : function(component, event, helper) {
        var action = component.get("c.getPicklistValues");
        action.setCallback(this, function(response) {
            var returnList = response.getReturnValue();
            console.log('Result: ', returnList);
            component.set("v.teamRoleLPicklist", returnList);
        });
        $A.enqueueAction(action);
    },
    setList : function(response) {
        var queriedList = response.getReturnValue();
        queriedList.forEach(function(element) {
            element.utilAccount = {};
            element.utilOpp = {};
            element.utilAccount.read = element.AccountAccessLevel == 'Read' || element.AccountAccessLevel == 'Edit';
            element.utilAccount.write = element.AccountAccessLevel == 'Edit';
            element.utilOpp.read = element.OpportunityAccessLevel == 'Read' || element.OpportunityAccessLevel == 'Edit';
            element.utilOpp.write = element.OpportunityAccessLevel == 'Edit';
            
        });
        return queriedList;
    },
    
    handleSaveChanges : function(component, event, helper) {
        var objAccountTeamMember = {};
        var accountId = component.get("v.recordId");
        var userId = component.get("v.entityId");
        var selectedTeamRole = component.get("v.teamRole");
        var selectedAccountAccess = component.get("v.accountAccess");
        var selectedOpportunityAccess = component.get("v.oppoAccess");
        
        objAccountTeamMember.UserId = userId;
        objAccountTeamMember.AccountId = accountId;
        objAccountTeamMember.TeamMemberRole = selectedTeamRole;
        objAccountTeamMember.AccountAccessLevel = selectedAccountAccess;
        objAccountTeamMember.OpportunityAccessLevel = selectedOpportunityAccess;

        var action = component.get("c.createAccountTeamMember");
        action.setParams({
            teamMember : JSON.stringify(objAccountTeamMember),
            accountId : component.get("v.recordId")
		});
        action.setCallback(this, function(response) {
            console.log("Insert response: ", response.getState());
            var returnList = response.getReturnValue();
            component.set("v.accountTeamMemberList", helper.setList(response));
        });
        $A.enqueueAction(action);

    },
    
    handleFullSave : function(component, event, helper) {
        component.set("v.saving", true);
        console.log("saving >> ", component.get("v.saving"))
        var getSave = component.get("c.saveAllItems");
        var fullList = JSON.parse(JSON.stringify(component.get("v.accountTeamMemberList")));
        fullList.forEach(function(element) {
            if(element.utilAccount.read && element.utilAccount.write) {
                element.AccountAccessLevel = 'Edit';
            } else if(element.utilAccount.read && !element.utilAccount.write) {
                element.AccountAccessLevel = 'Read';
            } else {
                element.AccountAccessLevel = 'None';
            }
            delete element.utilAccount;
            
            if(element.utilOpp.read && element.utilOpp.write) {
                element.OpportunityAccessLevel = 'Edit';
            } else if(element.utilOpp.read && !element.utilOpp.write) {
                element.OpportunityAccessLevel = 'Read';
            } else {
                element.OpportunityAccessLevel = 'None';
            }
            delete element.utilOpp;
            delete element.User;
            element.sobjectType = 'AccountTeamMember';
        });
        
        getSave.setParams({
            teamMember : JSON.stringify(fullList),
            accountId : component.get("v.recordId")
        });
        getSave.setCallback(this, function(response) {
            console.log(response, response.getState());
            if(response.getState() == 'SUCCESS') {
                component.set("v.accountTeamMemberList", helper.setList(response));
            }

            var accountIds = [];
            accountIds.push(component.get("v.recordId"));
            var action = component.get("c.ShareAccess");
            action.setParams({
                lstAccount : accountIds
            });
            action.setCallback(this, function(response) {
            	component.set("v.saving", false);
                console.log("Create Share response 2: ", response.getState());
        		$A.get("e.force:closeQuickAction").fire();
            });
            $A.enqueueAction(action);
        });
        $A.enqueueAction(getSave);
    },

    handleDelete : function(component, event, helper) {
        var getDelete = component.get("c.deleteAccountTeamMember");
		getDelete.setParams({
            teamMembers : component.get("v.selectedAccountTeamMembers"),
            accountId : component.get("v.recordId")
		});
		getDelete.setCallback(this, function(response) {
            console.log("Delete response: ", response.getState());
            console.log(response)
            var returnList = response.getReturnValue();
            //component.set("v.accountTeamMemberList", returnList);
            
            var accountIds = [];
            accountIds.push(component.get("v.recordId"));
            var action = component.get("c.ShareAccess");
            action.setParams({
                lstAccount : accountIds
            });
            action.setCallback(this, function(response) {
                console.log("Delete Share response 2: ", response.getState());
            });
            $A.enqueueAction(action);
		});
		$A.enqueueAction(getDelete);
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
    }
})