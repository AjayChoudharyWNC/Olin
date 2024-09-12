({		
    searchRecords : function(component, event) {		
        		
        component.set('v.isCallingServer',true);		
        component.set('v.sortByLead', 'Company');		
        component.set('v.sortByAcc', 'Name');		
        component.set('v.sortByOpp', 'Name');		
        component.set('v.sortByCon', 'Account.Name');		
        component.set("v.sortDirectionLead", 'ASC');		
        component.set("v.sortDirectionAcc", 'ASC' );		
        component.set("v.sortDirectionOpp", 'ASC');		
        component.set("v.sortDirectionCon", 'ASC');		
        		
        var action = component.get("c.fetchRecords");		
        		
        action.setParams({		
            'searchText': component.get("v.searchKeyword"),		
            'sortDirectionLead': component.get("v.sortDirectionLead"),		
            'sortDirectionAcc': component.get("v.sortDirectionAcc"),		
            'sortDirectionOpp': component.get("v.sortDirectionOpp"),		
            'sortDirectionCon': component.get("v.sortDirectionCon"),		
            'sortByLead': component.get("v.sortByLead"),		
            'sortByAcc': component.get("v.sortByAcc"),		
            'sortByOpp': component.get("v.sortByOpp"),		
            'sortByCon': component.get("v.sortByCon")		
        });		
        		
        action.setCallback(this, function(response) {		
            		
            var state = response.getState();		
            		
            if (state === "SUCCESS") {		
            		
                component.set('v.isRecordsPresent', false);		
                var responseReturned = response.getReturnValue();		
                		
                if(responseReturned.lstLeads.length > 0) { 		
                    		
                    component.set('v.lstLeads', responseReturned.lstLeads);		
                    component.set('v.isRecordsPresent', true);		
                    component.set("v.totalRecordsLead", component.get("v.lstLeads").length);		
                    		
                    var pageSize = component.get("v.pageSizeLead");		
                    		
                    component.set("v.startPageLead", 0);		
                    component.set("v.endPageLead", pageSize-1);		
                    		
                    var paginationList = [];		
                    for(var i=0; i< pageSize; i++){		
                        if(component.get("v.lstLeads").length> i)		
                            paginationList.push(responseReturned.lstLeads[i]);    		
                    }		
                    component.set('v.lstCurrentPageLeads', paginationList);		
                    		
                } else {		
                    component.set('v.lstLeads', []);		
                } 		
                		
                if(responseReturned.lstAccounts.length > 0) { 		
                    		
                    component.set('v.lstAccounts', responseReturned.lstAccounts);		
                    component.set('v.isRecordsPresent', true);		
                    component.set("v.totalRecordsAcc", component.get("v.lstAccounts").length);		
                    		
                    var pageSize = component.get("v.pageSizeAcc");		
                    component.set("v.startPageAcc", 0);		
                    component.set("v.endPageAcc", pageSize-1);		
                    		
                    var paginationList = [];		
                    for(var i=0; i< pageSize; i++){		
                        if(component.get("v.lstAccounts").length> i)		
                            paginationList.push(responseReturned.lstAccounts[i]);    		
                    }		
                    component.set('v.lstCurrentPageAccs', paginationList);		
                    		
                } else {		
                    component.set('v.lstAccounts', []);		
                } 		
                		
                if(responseReturned.lstLocations.length > 0) { 		
                    		
                    component.set('v.lstLocations', responseReturned.lstLocations);		
                    component.set('v.isRecordsPresent', true);		
                    component.set("v.totalRecordsOpp", component.get("v.lstLocations").length);		
                    		
                    var pageSize = component.get("v.pageSizeOpp");		
                    component.set("v.startPageOpp", 0);		
                    component.set("v.endPageOpp", pageSize-1);		
                    		
                    var paginationList = [];		
                    for(var i=0; i< pageSize; i++){		
                        if(component.get("v.lstLocations").length> i)		
                            paginationList.push(responseReturned.lstLocations[i]);    		
                    }		
                    component.set('v.lstCurrentPageOpps', paginationList);		
                    		
                } else {		
                    component.set('v.lstLocations', []);		
                } 		
                		
                if(responseReturned.lstContacts.length > 0) { 		
                   		
                    component.set('v.lstContacts', responseReturned.lstContacts);		
                    component.set('v.isRecordsPresent', true);		
                    component.set("v.totalRecordsCon", component.get("v.lstContacts").length);		
                    component.set("v.startPageCon", 0);		
                    var pageSize = component.get("v.pageSizeCon");		
                    		
                    component.set("v.endPageCon", pageSize-1);		
                    		
                    var paginationList = [];		
                    for(var i=0; i< pageSize; i++){		
                        if(component.get("v.lstContacts").length> i)		
                            paginationList.push(responseReturned.lstContacts[i]);    		
                    }		
                    component.set('v.lstCurrentPageCons', paginationList);		
                    		
                } else {		
                    component.set('v.lstContacts', []);		
                } 		
                		
                component.set('v.isRecordsSearched',true);		
                		
            } else {		
                		
                component.set("v.isValidationError", true);		
                component.set("v.errorMessage", 'Search again using at least two characters, excluding *, ?, (), or " "');		
            }		
            		
            component.set('v.isCallingServer',false);		
        });		
        $A.enqueueAction(action);		
    },		
    		
	toggleSection : function(component, event, secId) {	
        		
		var acc = component.find(secId);
        		
        for(var cmp in acc) {		
            		
            $A.util.toggleClass(acc[cmp], 'slds-show');  		
            $A.util.toggleClass(acc[cmp], 'slds-hide');  		
        }		
	},	
    		
    /*		
     * Method will be called when use clicks on next button and performs the 		
     * calculation to show the next set of records		
	*/	
    next : function(component, event, clickedFrom, sObjectList, end, start, pageSize) {		
        		
        var Paginationlist = [];		
        var counter = 0;		
        		
        for(var i = end + 1; i < end + pageSize + 1; i++) {		
            		
            if(sObjectList.length > i){		
                Paginationlist.push(sObjectList[i]);		
            }		
            counter++ ;		
        }		
        		
        start = start + counter;		
        end = end + counter;		
        		
        if(clickedFrom === 'Lead') {		
            		
            component.set("v.startPageLead",start);		
            component.set("v.endPageLead",end);		
            component.set('v.lstCurrentPageLeads', Paginationlist);		
            		
        } else if(clickedFrom === 'Account') {		
            		
            component.set("v.startPageAcc",start);		
            component.set("v.endPageAcc",end);		
            component.set('v.lstCurrentPageAccs', Paginationlist);		
            		
        } else if(clickedFrom === 'Loc') {		
            		
            component.set("v.startPageOpp",start);		
            component.set("v.endPageOpp",end);		
            component.set('v.lstCurrentPageOpps', Paginationlist);		
            		
        } else if(clickedFrom === 'Contact') {		
            		
            component.set("v.startPageCon",start);		
            component.set("v.endPageCon",end);		
            component.set('v.lstCurrentPageCons', Paginationlist);		
        }		
    },		
    		
    /*		
     * Method will be called when use clicks on previous button and performs the 		
     * calculation to show the previous set of records		
	*/	
    previous : function(component, event, clickedFrom, sObjectList, end, start, pageSize) {		
        		
        var Paginationlist = [];		
        		
        var counter = 0;		
        		
        for(var i = start - pageSize; i < start ; i++) {		
            		
            if(i > -1) {		
                		
                Paginationlist.push(sObjectList[i]);		
                counter ++;		
                		
            } else {		
                start++;		
            }		
        }		
        		
        start = start - counter;		
        end = end - counter;		
        		
        if(clickedFrom === 'Lead') {		
            		
            component.set("v.startPageLead",start);		
            component.set("v.endPageLead",end);		
            component.set('v.lstCurrentPageLeads', Paginationlist);		
            		
        } else if(clickedFrom === 'Account') {		
            		
            component.set("v.startPageAcc",start);		
            component.set("v.endPageAcc",end);		
            component.set('v.lstCurrentPageAccs', Paginationlist);		
            		
        } else if(clickedFrom === 'Loc') {		
            		
            component.set("v.startPageOpp",start);		
            component.set("v.endPageOpp",end);		
            component.set('v.lstCurrentPageOpps', Paginationlist);		
            		
        } else if(clickedFrom === 'Contact') {		
            		
            component.set("v.startPageCon",start);		
            component.set("v.endPageCon",end);		
            component.set('v.lstCurrentPageCons', Paginationlist);		
        }		
    },		
    		
    sortData: function (cmp, field, sortDirection, records) {		
        		
        var sortAsc;		
        		
        if(sortDirection === 'ASC')		
            sortAsc = true;		
        else		
            sortAsc = false;		
        		
        records.sort(function(a,b) {		
            		
            var val1, val2;		
            		
            if(field.includes(".")) {		
                		
                var res = field.split(".");		
                		
                if(a[res[0]] != undefined)		
                	val1 = a[res[0]][res[1]];	
                if(b[res[0]] != undefined)		
                	val2 = b[res[0]][res[1]];	
                		
            } else {		
                		
                val1 = a[field];		
                val2 = b[field];		
            }		
            console.log('val1 = ',val1);		
            if(val1 != undefined)
            {
                if(typeof(val1) === 'object')
                    val1 = val1['Name'].toLowerCase();
                else
                    val1 = val1.toLowerCase();
            }
            
                		
            if(val2 != undefined)
            {
                if(typeof(val2) === 'object')
                    val2 = val2['Name'].toLowerCase();
                else
                    val2 = val2.toLowerCase();
            }
                		
            		
            var t1 = val1 == val2,		
                t2 = (!val1 && val2) || (val1 < val2);		
            		
            return t1 ? 0 : (sortAsc ? -1 : 1) * (t2 ? 1 : -1);		
        });		
        		
        return records;		
    }		
})