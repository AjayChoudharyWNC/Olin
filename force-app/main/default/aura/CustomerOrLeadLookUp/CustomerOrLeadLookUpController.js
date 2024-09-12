({			
    checkForEnterKey : function(component, event, helper) {			
        			
        if(event.getParams().keyCode == 13) {			
            			
            var srcValue = component.get("v.searchKeyword");			
            			
            if(srcValue === undefined || srcValue == '' || srcValue.trim() == '' || srcValue.length === 1) {			
                			
                component.set("v.isValidationError", true);			
                component.set("v.errorMessage", 'Search term must be longer than one character');			
                			
            } else {			
                			
                component.set("v.isValidationError", false);			
                component.set("v.errorMessage", '');			
                			
                helper.searchRecords(component, event);			
            }			
        }			
    },			
    			
    search : function(component, event, helper) {			
        			
        var srcValue = component.get("v.searchKeyword");			
        			
        if(srcValue === undefined || srcValue == '' || srcValue.trim() == '' || srcValue.length === 1) {			
            			
            component.set("v.isValidationError", true);			
            component.set("v.errorMessage", 'Search term must be longer than one character');			
            			
        } else {			
            			
            component.set("v.isValidationError", false);			
            component.set("v.errorMessage", '');			
            			
            helper.searchRecords(component, event);			
        }			
	},		
    			
    hideOrDisplaySection : function(component, event, helper) {			
        			
		var clickedButton = event.currentTarget;	
        var sectionId = clickedButton.dataset.section;			
       	helper.toggleSection(component, event, sectionId);		
    },			
    			
    sortLeads : function(component, event, helper) {			
        			
        var clickedColumn = event.currentTarget;			
        var columnName = clickedColumn.dataset.column;			
        			
        if(component.get("v.sortByLead") === columnName) {			
            			
			component.set('v.sortByLead', columnName);
			
			if(component.get('v.sortDirectionLead') === 'ASC')
                component.set('v.sortDirectionLead', 'DESC');			
            else			
                component.set('v.sortDirectionLead', 'ASC');			
            			
        } else {			
            			
            component.set('v.sortDirectionLead', 'ASC');			
            component.set('v.sortByLead', columnName);			
        }			
        			
        var sortedRecords = helper.sortData(component, columnName, component.get('v.sortDirectionLead'), component.get('v.lstLeads'));			
        component.set('v.lstLeads', sortedRecords);			
        			
        var pageSize = component.get("v.pageSizeLead");			
                    			
        component.set("v.startPageLead", 0);			
        component.set("v.endPageLead", pageSize-1);			
        			
        var paginationList = [];			
        for(var i=0; i< pageSize; i++){			
            if(component.get("v.lstLeads").length> i)			
                paginationList.push(sortedRecords[i]);    			
        }			
        component.set('v.lstCurrentPageLeads', paginationList);			
        			
    },			
    			
    sortCompanies : function(component, event, helper) {			
        			
        var clickedColumn = event.currentTarget;			
        var columnName = clickedColumn.dataset.column;			
        			
        if(component.get("v.sortByAcc") === columnName) {			
            			
			component.set('v.sortByAcc', columnName);
			
			if(component.get('v.sortDirectionAcc') === 'ASC')
                component.set('v.sortDirectionAcc', 'DESC');			
            else			
                component.set('v.sortDirectionAcc', 'ASC');			
            			
        } else {			
            			
            component.set('v.sortDirectionAcc', 'ASC');			
            component.set('v.sortByAcc', columnName);			
        }			
        			
        var sortedRecords = helper.sortData(component, columnName, component.get('v.sortDirectionAcc'), component.get('v.lstAccounts'));			
        component.set('v.lstAccounts', sortedRecords);			
        			
        var pageSize = component.get("v.pageSizeAcc");			
                    			
        component.set("v.startPageAcc", 0);			
        component.set("v.endPageAcc", pageSize-1);			
        			
        var paginationList = [];			
        for(var i=0; i< pageSize; i++){			
            if(component.get("v.lstAccounts").length> i)			
                paginationList.push(sortedRecords[i]);    			
        }			
        component.set('v.lstCurrentPageAccs', paginationList);			
    },			
    			
    sortLocations : function(component, event, helper) {			
        			
        var clickedColumn = event.currentTarget;			
        var columnName = clickedColumn.dataset.column;			
        			
        if(component.get("v.sortByOpp") === columnName) {			
            			
			component.set('v.sortByOpp', columnName);
			
			if(component.get('v.sortDirectionOpp') === 'ASC')
                component.set('v.sortDirectionOpp', 'DESC');			
            else			
                component.set('v.sortDirectionOpp', 'ASC');			
            			
        } else {			
            			
            component.set('v.sortDirectionOpp', 'ASC');			
            component.set('v.sortByOpp', columnName);			
        }			
        			
        var sortedRecords = helper.sortData(component, columnName, component.get('v.sortDirectionOpp'), component.get('v.lstLocations'));			
        component.set('v.lstLocations', sortedRecords);			
        			
        var pageSize = component.get("v.pageSizeOpp");			
                    			
        component.set("v.startPageOpp", 0);			
        component.set("v.endPageOpp", pageSize-1);			
        			
        var paginationList = [];			
        for(var i=0; i< pageSize; i++){			
            if(component.get("v.lstLocations").length> i)			
                paginationList.push(sortedRecords[i]);    			
        }			
        component.set('v.lstCurrentPageOpps', paginationList);			
    },			
    			
    sortContacts : function(component, event, helper) {			
        			
        var clickedColumn = event.currentTarget;			
        var columnName = clickedColumn.dataset.column;			
        			
        if(component.get("v.sortByCon") === columnName) {			
            			
			component.set('v.sortByCon', columnName);
			
			if(component.get('v.sortDirectionCon') === 'ASC')
                component.set('v.sortDirectionCon', 'DESC');			
            else			
                component.set('v.sortDirectionCon', 'ASC');			
            			
        } else {			
            			
            component.set('v.sortDirectionCon', 'ASC');			
            component.set('v.sortByCon', columnName);			
        }			
        			
        var sortedRecords = helper.sortData(component, columnName, component.get('v.sortDirectionCon'), component.get('v.lstContacts'));			
        component.set('v.lstContacts', sortedRecords);			
        			
        var pageSize = component.get("v.pageSizeCon");			
                    			
        component.set("v.startPageCon", 0);			
        component.set("v.endPageCon", pageSize-1);			
        			
        var paginationList = [];			
        for(var i=0; i< pageSize; i++){			
            if(component.get("v.lstContacts").length> i)			
                paginationList.push(sortedRecords[i]);    			
        }			
        component.set('v.lstCurrentPageCons', paginationList);			
    },			
    			
    navigateToRecord : function(component, event, helper) {			
        			
        event.preventDefault();			
        var recordId = event.target.getAttribute('data-recId');			
        var sObjectEvent = $A.get("e.force:navigateToSObject");			
        			
        sObjectEvent .setParams({			
            "recordId": recordId,			
            "slideDevName": "detail"			
        });			
        			
        sObjectEvent.fire(); 			
    },			
    			
    next: function (component, event, helper) {			
        			
        var clickedFrom = event.getSource().get('v.class');			
        			
        var sObjectList;			
        var end;			
        var start;			
        var pageSize;			
        			
        if(clickedFrom === 'Lead') {			
            			
            sObjectList = component.get("v.lstLeads");			
            end = component.get("v.endPageLead");			
            start = component.get("v.startPageLead");			
            pageSize = component.get("v.pageSizeLead");			
            			
        } else if(clickedFrom === 'Account') {			
            			
			sObjectList = component.get("v.lstAccounts");
            end = component.get("v.endPageAcc");			
            start = component.get("v.startPageAcc");			
            pageSize = component.get("v.pageSizeAcc");   			
            			
        } else if(clickedFrom === 'Loc') {			
            			
			sObjectList = component.get("v.lstLocations");
            end = component.get("v.endPageOpp");			
            start = component.get("v.startPageOpp");			
            pageSize = component.get("v.pageSizeOpp"); 			
            			
        } else if(clickedFrom === 'Contact') {			
            			
			sObjectList = component.get("v.lstContacts");
            end = component.get("v.endPageCon");			
            start = component.get("v.startPageCon");			
            pageSize = component.get("v.pageSizeCon");            			
        }			
        			
        helper.next(component, event, clickedFrom, sObjectList, end, start, pageSize);			
    },			
    			
    previous: function (component, event, helper) {			
        			
        var clickedFrom = event.getSource().get('v.class');			
        			
        var sObjectList;			
        var end;			
        var start;			
        var pageSize;			
        			
        if(clickedFrom === 'Lead') {			
            			
            sObjectList = component.get("v.lstLeads");			
            end = component.get("v.endPageLead");			
            start = component.get("v.startPageLead");			
            pageSize = component.get("v.pageSizeLead");			
            			
        } else if(clickedFrom === 'Account') {			
            			
			sObjectList = component.get("v.lstAccounts");
            end = component.get("v.endPageAcc");			
            start = component.get("v.startPageAcc");			
            pageSize = component.get("v.pageSizeAcc");   			
            			
        } else if(clickedFrom === 'Loc') {			
            			
			sObjectList = component.get("v.lstLocations");
            end = component.get("v.endPageOpp");			
            start = component.get("v.startPageOpp");			
            pageSize = component.get("v.pageSizeOpp"); 			
            			
        } else if(clickedFrom === 'Contact') {			
            			
			sObjectList = component.get("v.lstContacts");
            end = component.get("v.endPageCon");			
            start = component.get("v.startPageCon");			
            pageSize = component.get("v.pageSizeCon");            			
        }        			
        			
        helper.previous(component, event, clickedFrom, sObjectList, end, start, pageSize);			
    }  			
})