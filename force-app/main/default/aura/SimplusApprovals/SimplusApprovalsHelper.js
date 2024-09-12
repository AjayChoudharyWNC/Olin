({
    init : function(component, event, helper) {

        /*var getRecords=  component.get("c.getLinesFromApproval");
        console.log('getRecords======'+getRecords);

		getRecords.setCallback(this, function(a) {
            console.log('================ ', a.getReturnValue());
            component.set("v.dataList", a.getReturnValue());
            component.set("v.loading", false);
		});
        $A.enqueueAction(getRecords); */

        helper.getUserDetails(component, event, helper);
        helper.getTableFieldSet(component, event, helper);      
        //helper.returnLinesFromApproval(component, event, helper);   
        window.addEventListener('resize', $A.getCallback(function(){ 
            helper.handleWindowScroll(component, event, helper); 
            helper.handleDimensionsUpdate(component, event, helper); 
        }));
        window.addEventListener('scroll', $A.getCallback(function(){ 
            helper.handleWindowScroll(component, event, helper); 
        }));

        
    },

    returnLinesFromApproval: function(component, event, helper) {
        var getRecords=  component.get("c.getLinesFromApproval");
        console.debug('getRecords======'+getRecords);

		getRecords.setCallback(this, function(a) {
            console.log('>>> ', a.getReturnValue());
            component.set("v.dataList", a.getReturnValue());
            component.set("v.loading", false);
		});
        $A.enqueueAction(getRecords); 
    },
    
    getTableFieldSet : function(component, event, helper) {
        console.log('fieldSets -->'+component.get("v.fieldSets"));
        component.set("v.isLoadingList", true);
        var action = component.get("c.getFieldSet");
        action.setParams({
            sObjectName: component.get("v.sObjectName"),
            fieldSets: component.get("v.fieldSets"),
            mainListSource : 'SimplusApprovals'
        });
        
        action.setCallback(this, function(response) {
            console.log('RESPONSE >> ', response, response.getReturnValue());
            //var fieldSetObj = JSON.parse(response.getReturnValue());
            var fieldSetObj = response.getReturnValue();
            console.log('FIELDSET >> ', fieldSetObj);
            
            var colFreeze = component.get("v.noOfColumns");
            var leftCols = [], rightCols = [], allCols = [];
            for(var i =0; i < colFreeze; i+=1) {
                leftCols.push(fieldSetObj.sortingFieldSet[i]);
                allCols.push(fieldSetObj.sortingFieldSet[i]);
            }
            for(var i = colFreeze; i < fieldSetObj.sortingFieldSet.length; i+=1) {
                rightCols.push(fieldSetObj.sortingFieldSet[i]);
                allCols.push(fieldSetObj.sortingFieldSet[i]);
            }
            console.debug('allCols===='+allCols);
            
            component.set("v.fieldSetValues", allCols);
            component.set("v.fieldSetValues1", leftCols);
            component.set("v.fieldSetValues2", rightCols);
            component.set("v.pageMax", fieldSetObj.pageMax);
            component.set("v.isBeyond", fieldSetObj.isBeyond);
            
            //component.set("v.sortingOrderResult", fieldSetObj.sortingOrderResult);
            //component.set("v.filteringOrderResult", fieldSetObj.filteringOrderResult);
            //Call helper method to fetch the records
            //helper.getTableRows(component, event, helper);
            //
            try {
                console.log(fieldSetObj.lstObject);
                var list = fieldSetObj.lstObject;
            } catch (ex) {
                console.log('Error caught: ' + ex);
                return;
            }
            console.log('LIST >> ', list);
            component.set("v.tableRecords", list);
            component.set("v.tableRecordsUpdated", list);
            component.set("v.hasPendingMassChange", false);
            component.set("v.isLoadingList", false);
            
            window.setTimeout(
                $A.getCallback(function() {
                    helper.handleDimensionsUpdate(component, event, helper);
                }), 100
            );
            /*window.setTimeout(
                $A.getCallback(function() {
                    helper.handleDimensionsUpdate(component, event, helper);
                }), 500
            );*/
        })
        $A.enqueueAction(action);
    },
    
    getTableRows : function(component, event, helper){
        component.set("v.isLoadingList", true);
        var action = component.get("c.getRecords");
        var fieldSetValues = component.get("v.fieldSetValues");
        
        var setfieldNames = new Set();
        for(var c=0, clang = fieldSetValues.length; c<clang; c++){             
            if(!setfieldNames.has(fieldSetValues[c].fieldName)) {                 
                setfieldNames.add(fieldSetValues[c].fieldName);                   
                if(fieldSetValues[c].fieldType == 'REFERENCE') {                     
                    if(fieldSetValues[c].fieldName.indexOf('__c') == -1) {                     	
                        setfieldNames.add(fieldSetValues[c].fieldName.substring(0, fieldSetValues[c].fieldName.indexOf('Id')) + '.Name');                          
                    }                     
                    else {                     	
                        setfieldNames.add(fieldSetValues[c].fieldName.substring(0, fieldSetValues[c].fieldName.indexOf('__c')) + '__r.Name');                              
                    }                 
                }             
            }         
        }         
        var arrfieldNames = [];         
        setfieldNames.forEach(v => arrfieldNames.push(v));
        action.setParams({
            sObjectName: component.get("v.sObjectName"),
            fieldNameJson: JSON.stringify(arrfieldNames),
            sortingOrderResult: component.get("v.sortingOrderResult"),
            filteringOrderResult: component.get("v.filteringOrderResult"),
            page : component.get("v.page")
        });
        action.setCallback(this, function(response) {
            try {
                var list = JSON.parse(response.getReturnValue());
            } catch (ex) {
                console.log('Error caught: ' + ex);
                return;
            }
            console.log('LIST >> ', list);
            component.set("v.tableRecords", list);
            component.set("v.tableRecordsUpdated", list);
            component.set("v.hasPendingMassChange", false);
            component.set("v.isLoadingList", false);
            
            window.setTimeout(
                $A.getCallback(function() {
                    helper.handleDimensionsUpdate(component, event, helper);
                }), 50
            );
            
        })
        $A.enqueueAction(action);
    },
    
    refreshList : function(component, event, helper) {
        var getSort = component.get("c.toggle");
        getSort.setCallback(this, function(a) {
            var returnValue = a.getReturnValue();
            component.set("v.tableRecords", returnValue.lstObject);
            component.set("v.pageMax", returnValue.pageMax);
            component.set("v.isBeyond", returnValue.isBeyond);
            component.set("v.hasPendingMassChange", false);
            component.set("v.isLoadingList", false);
        });
        $A.enqueueAction(getSort);
    },
    
    handleDimensionsUpdate : function(component, event, helper) {
        try {
            var leftFloaterWidth = document.getElementById("app_fixedColumns").getBoundingClientRect().width;
            
            document.getElementById("app_fixedColumnsTableFloating").style.width = (leftFloaterWidth - 11) + "px";
            document.getElementById("app_rightTableFloatContainer").style.width = (document.getElementById("app_fullTableContainer").getBoundingClientRect().width - leftFloaterWidth + 11) + "px)";
            
            document.getElementById("app_rightTableFloat").style.width = (document.getElementById("app_rightTable").getBoundingClientRect().width) + "px";
            document.getElementById("app_floatersContainers").style.width = (document.getElementById("app_fullTableContainer").getBoundingClientRect().width) + "px";
            document.getElementById("app_floatersPositioner").style.width = (document.getElementById("app_fullTableContainer").getBoundingClientRect().width) + "px";
            
            var leftColumns = document.getElementsByClassName("app_leftTh1");
            var leftColsFloat = document.getElementsByClassName("app_leftThFloat1");
            
            for(var i = 0; i < leftColumns.length; i+=1) {
                leftColsFloat[i].style.width = (leftColumns[i].getBoundingClientRect().width - 17) + "px";
                //leftColsFloat[i].parentNode.style.width = (leftColumns[i].getBoundingClientRect().width - 8) + "px";
                //leftColsFloat[i].style.minWidth = leftColumns[i].getBoundingClientRect().width + "px";
            }
            
            var rightColumn = document.getElementsByClassName("app_rightColumn");
            var rightColumnFloat = document.getElementsByClassName("app_rightColumnFloat");
            
            for(var i = 0; i < rightColumn.length; i+=1) {
                rightColumnFloat[i].style.width = rightColumn[i].getBoundingClientRect().width + "px";
                rightColumnFloat[i].style.minWidth = rightColumn[i].getBoundingClientRect().width + "px";
            }
        } catch(e) {
            console.log(e);
        }
    },
    handleWindowScroll : function(component, event, helper) {
        //floatersContainers
        document.getElementById("app_floatersPositioner").style.top = "-" + window.scrollY + "px";
    },
    
    getUserDetails : function(component, event, helper){
        var action = component.get("c.fetchUser");
        
        action.setCallback(this, function(response) {
            var userDetail = response.getReturnValue();
            if(userDetail.Approval_Lock_Column__c == null || userDetail.Approval_Lock_Column__c == '' || userDetail.Approval_Lock_Column__c == 0){
                component.set("v.noOfColumns", 3);
            }
            else{
                component.set("v.noOfColumns", response.getReturnValue().Approval_Lock_Column__c);
            }
            
            
        });
        $A.enqueueAction(action);
    },
    
    
    adjustWidth : function(component, event, helper) {
        //var table1 = component.getElements();
        var table1=  document.getElementById("app_fixedColumnsTableFloating");
        
        let widthArray = [];
        let heightVar;
        
        console.log('table1>>>'+table1);
        
        for (var i = 0, row; row = table1.rows[i]; i++) {
            
            //iterate through rows
            //rows would be accessed using the "row" variable assigned in the for loop
            for (var j = 0, col; col = row.cells[j]; j++) {
                //iterate through columns
                //columns would be accessed using the "col" variable assigned in the for loop
                widthArray[j]= col.offsetWidth;
                
                console.log('col.width>>>'+col.offsetWidth);
                console.log('table1.rows[i].cells[j].width>>>'+table1.rows[i].cells[j].offsetWidth);
                console.log('widthArray[j]>>>'+widthArray[j]);
            } 
        }
        
        console.log('widthArray>>>'+widthArray);        
        var table2 = document.getElementById("app_staticTable");      
        console.log('table2>>>'+table2);
        //var table2 = component.find("table2").getElement();
        
        for (var i1 = 0, row; row = table2.rows[i1];i1++ ) {
            
            heightVar= row.offsetHeight;
            console.log('table2.row.offsetHeight>>>'+row.offsetHeight);
            console.log('table2.heightVar>>>'+heightVar);
            
            //iterate through rows
            //rows would be accessed using the "row" variable assigned in the for loop
            for (var j1 = 0, col; col = row.cells[j1]; j1++) {
                //iterate through columns
                //columns would be accessed using the "col" variable assigned in the for loop
                col.width = widthArray[j1];
                
                console.log('widthArray['+j1+']>>>'+widthArray[j1]);
                console.log('table2.col.width>>>'+col.width);
                console.log('table2.rows[i1].cells[j1].width>>>'+table2.rows[i1].cells[j1].width);
                
            }  
        }
        
         var table3 = document.getElementById("table3");  
           console.log('table3>>>'+table3);
         
        
        for (var i2 = 0, row; row = table3.rows[i2];i2++ ) {
              row.height = heightVar;
               console.log('table3.heightVar>>>'+heightVar);
              console.log('table3.row.height>>>'+row.height);
            //iterate through rows
            //rows would be accessed using the "row" variable assigned in the for loop
           /* for (var j2 = 0, col; col = row.cells[j2]; j2++) {
                //iterate through columns
                //columns would be accessed using the "col" variable assigned in the for loop
                col.height = heightVar;
                
               console.log('table3.col.height>>>'+col.height);
                
            }  */
        }
        
    },

    evaluateSelectionCount : function (cmp) {
        cmp.set("v.hasSelections", false);
        cmp.get("v.tableRecordsUpdated").forEach(
            function(itm) {
                if(itm.util.isSelected) {
                    cmp.set("v.hasSelections", true);
                    return ;
                }
            }
        );
    },
})