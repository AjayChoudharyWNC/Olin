({
    init : function(component, event, helper) {
		var record = component.get("v.record");
        var field = component.get("v.field");
		
        component.set("v.record.util." + field.fieldName + ".acceptChange", function(fieldTarget, newVal, newLabel){
           
            helper.acceptChange(component, fieldTarget, newVal, newLabel);
            //helper.runFieldValidation(component);
        });
         //console.log('7-->v.record.util',JSON.stringify(component.get("v.record.util")));

        component.set("v.record.util." + field.fieldName + ".runFieldValidation", function(){
            return helper.runFieldValidation(component);
        });

        component.set("v.record.util." + field.fieldName + ".clearCellValidations", function(){
            helper.clearCellValidations(component);
        });

        component.set("v.record.util." + field.fieldName + ".toggleCellLock", function(isEditable){
            helper.toggleCellLock(component, isEditable);
        });

        component.set("v.record.util." + field.fieldName + ".resetFieldValue", function(){
            helper.resetFieldValue(component);
        });

        component.set("v.record.util." + field.fieldName + ".setPendingInlineEdit", function(hasInlineEdit){
            helper.setPendingInlineEdit(component, hasInlineEdit);
        });
        
        component.set("v.record.util." + field.fieldName + ".acceptFormulaChange", function(fieldTarget, newVal, formula){
            helper.acceptFormulaChange(component, fieldTarget, newVal, formula);
        });

        component.set("v.record.util." + field.fieldName + ".revertChange", function(){
            helper.revertChange(component);
            helper.clearCellValidations(component);
        });
        
        component.set("v.previousValue", record[field.fieldName]);
        if(field.fieldName.includes('__r.')) {
            var referenceFields = field.fieldName.split('.');
            component.set("v.cellValue", record[[referenceFields[0]][referenceFields[1]]]);
        } else {
            component.set("v.cellValue", record[field.fieldName]);
        }

        if(field.fieldName == 'Name' || field.fieldName.split('.').pop().fieldName == 'Name') {
            field.fieldType = 'REFERENCE';
            component.set("v.isReferenceField", true);
            component.set("v.cellLabel", record.Name);
            component.set("v.cellValue", record.Id);
            component.set("v.previousLabel", record.Name);
            component.set("v.previousValue", record.Id);
            return;
        }

        if(!component.get("v.isLocked")) component.set("v.isEditable", field.fieldEditable);

        if(field.fieldType == 'STRING' || field.fieldType == 'PICKLIST')
            component.set("v.isTextField", true);
        else if(field.fieldType == 'DATE'){
        	component.set("v.isDateField", true);
        }
        else if(field.fieldType == 'DATETIME'){
        	component.set("v.isDateTimeField", true);
        }
        else if(field.fieldType == 'CURRENCY'){
        	component.set("v.isCurrencyField", true);
        }
        else if(field.fieldType == 'DOUBLE'){
        	component.set("v.isNumberField", true);
        }
        else if(field.fieldType == 'PERCENT'){
        	component.set("v.isPercentField", true);
            if (component.get("v.cellValue") > 0.99) {
				component.set("v.cellValue", component.get("v.cellValue") * 0.01);
			}
        }
        else if(field.fieldType == 'REFERENCE'){
        	component.set("v.isReferenceField", true);
            var relationShipName = '';
            if(field.fieldName.indexOf('__c') == -1) {
                relationShipName = field.fieldName.substring(0, field.fieldName.indexOf('Id'));
            }
            else {
                relationShipName = field.fieldName.substring(0, field.fieldName.indexOf('__c')) + '__r';
            }
            if(record[relationShipName]) {
                component.set("v.cellLabel", record[relationShipName].Name);
                component.set("v.cellValue", record[relationShipName].Id);
                component.set("v.previousLabel", record[relationShipName].Name);
                component.set("v.previousValue", record[relationShipName].Id);
                
                // Initialize pre-selected value on the lookup dropdown.

                component.set("v.defaultLookupValue", {
                    id: record[relationShipName].Id, 
                    sObjectType: 'Account', 
                    icon: 'standard:default',
                    title: record[relationShipName].Name,
                    subtitle: 'Account'});

            }
            else {
                component.set("v.cellLabel", '');
                component.set("v.cellValue", '');
                component.set("v.previousLabel", '');
                component.set("v.previousValue", '');
            }

            
        }
    },

    acceptChange : function(component, fieldTarget, newVal) {
        var record = component.get("v.record");
        console.log('116 log',record);
        if(component.get("v.record")[fieldTarget] != newVal) {
            //if(!component.get("v.previousValue") && record[fieldTarget]) component.set("v.previousValue", JSON.parse(JSON.stringify(record[fieldTarget])));
            component.set("v.hasUpdate", true);
            component.get("v.record")[fieldTarget] = newVal;
            component.set("v.cellValue", record[fieldTarget]);
        }
    },

    acceptFormulaChange : function(component, fieldTarget, newVal, formula) {
        var record = component.get("v.record");

        var func = new Function("record","newVal", formula);
        newVal = func(record, newVal);
		console.log("fieldTarget >> ", fieldTarget);
        
        if(component.get("v.record")[fieldTarget] != newVal) {
            //if(!component.get("v.previousValue") && record[fieldTarget]) component.set("v.previousValue", JSON.parse(JSON.stringify(record[fieldTarget])));
            component.set("v.hasUpdate", true);
            component.get("v.record")[fieldTarget] = newVal;
            component.set("v.cellValue", record[fieldTarget]);
        }
    },

    revertChange : function(component) {
        if(component.get("v.hasUpdate") || component.get("v.hasPendingInlineUpdate")) {
            var record = component.get("v.record");
            var field = component.get("v.field");
            console.log(component.get("v.previousValue"));
            if(field.fieldType == 'REFERENCE'){
                console.log(component.get("v.previousLabel"));
                component.set("v.cellLabel", component.get("v.previousLabel"));
                component.set("v.cellValue", component.get("v.previousValue"));
            }
            else {
                record[field.fieldName] = component.get("v.previousValue");
                component.set("v.cellValue", record[field.fieldName]);
                component.set("v.hasUpdate", false);
                component.set("v.hasPendingInlineUpdate", false);
                if (component.get("v.isReferenceField")) {
                    component.set("v.cellLabel", component.get("v.previousLabel"));
                }
            }
        }
    },

    resetFieldValue : function(component) {
        if(component.get("v.hasPendingInlineUpdate")) {
            var record = component.get("v.record");
            var field = component.get("v.field");
            component.set("v.cellValue", record[field.fieldName]);
            component.set("v.hasPendingInlineUpdate", false);
        }
    },

    clearCellValidations: function(component) {
		component.set("v.hasValidationError", false);
		component.set("v.validationMessage", "");
		
		component.set("v.hasWarnings", false);
		component.set("v.warningMessages", []);
    },

    toggleCellLock: function(component, isEditable) {
		component.set("v.isEditable", isEditable);
    },

    setPendingInlineEdit: function(component, hasUpdate) {
		component.set("v.hasPendingInlineUpdate", hasUpdate);
        //component.set("v.previousValue", component.get("v.cellValue"));
        //component.set("v.previousLabel", component.get("v.cellLabel"));
    },

    runFieldValidation: function(component) {
        if (!component) {
            console.log("component is undefined");
        }
        console.log("field validation helper running for this field: " + component.get("v.field").fieldName);
		component.set("v.hasValidationError", false);
		component.set("v.validationMessage", "");
		
		component.set("v.hasWarnings", false);
		component.set("v.warningMessages", []);

		var validationResult = this.runRecordValidation(JSON.stringify(component.get("v.record")));

		if (validationResult.hasWarnings && validationResult.warnFields.includes(component.get("v.field").fieldName)) {
			component.set("v.hasWarnings", true);
			component.set("v.warningMessages", validationResult.warnings.join(", "));
		}

		if(validationResult.isSuccess === false && validationResult.warnFields.includes(component.get("v.field").fieldName)) {
			component.set("v.hasValidationError", true);
			component.set("v.validationMessage", validationResult.message);
        }
        return validationResult;
	},

    // Added by Errol Yatar. This function contains all the validations needed for cleaner input for mass pricing.
    runRecordValidation: function(recordJson) {
        var record = JSON.parse(recordJson);
        var result = {isSuccess: true, hasWarnings: false, warnFields: [], warnings: []};
        console.log(record);

        // WARNINGS
        if (record.New_Price_Start_Date__c !== "" && record.New_Price_Firm_Date__c !== "") {
            let newStartDate = new Date(record.New_Price_Start_Date__c);
            let newEndDate = new Date(record.New_Price_Firm_Date__c);
            let previousEndDate = new Date(record.Price_Firm_Date__c);

            // Warn the user if there is an overlap on the dates.
            if (newStartDate < previousEndDate) {
                result.warnings.push("New Price Start Date is earlier than the Previous Price Expiration Date.");
                result.warnFields = [...result.warnFields, "New_Price_Start_Date__c", "New_Price_Firm_Date__c"];
            } 

            // Warn the user if the dates exceed the pricing change frequency
            let dateDiffs = this.dateDiff(newStartDate, newEndDate);
            let hasDateRangeWarning = false;
            if (record.Price_Change_Frequency__c === "Monthly" &&
                (dateDiffs.years > 0 || 
                    dateDiffs.months > 1 ||
                    (dateDiffs.months == 1 && dateDiffs.days > 0))) {
                hasDateRangeWarning = true;
            }
            else if (record.Price_Change_Frequency__c === "Bi-Monthly" && 
                (dateDiffs.years > 0 || 
                    dateDiffs.months > 2 ||
                    (dateDiffs.months == 2 && dateDiffs.days > 0))) {
                hasDateRangeWarning = true;
            }
            else if (record.Price_Change_Frequency__c === "Quarterly" && 
                (dateDiffs.years > 0 || 
                    dateDiffs.months > 3 ||
                    (dateDiffs.months == 3 && dateDiffs.days > 0))) {
                hasDateRangeWarning = true;
            }
            else if (record.Price_Change_Frequency__c === "Semi-Annual" && 
                (dateDiffs.years > 0 || 
                    dateDiffs.months > 6 ||
                    (dateDiffs.months == 6 && dateDiffs.days > 0))) {
                hasDateRangeWarning = true;
            }
            else if (record.Price_Change_Frequency__c === "Annual" && 
                (dateDiffs.years > 1 || 
                    (dateDiffs.years == 1 && dateDiffs.months > 0) || 
                    (dateDiffs.years == 1 && dateDiffs.days > 0))) {
                hasDateRangeWarning = true;
            }
            if (hasDateRangeWarning) {
                result.warnings.push("Date range is greater than the price change frequency.");
                result.warnFields = [...result.warnFields, "New_Price_Start_Date__c", "New_Price_Firm_Date__c"];
            }
        }

        // ERRORS
        // New start date should not be greater than New end date.
        if (record.New_Price_Start_Date__c !== "" && record.New_Price_Firm_Date__c !== "") {
            let newStartDate = new Date(record.New_Price_Start_Date__c);
            let newEndDate = new Date(record.New_Price_Firm_Date__c);

            if (newStartDate > newEndDate) {
                result.isSuccess = false;
                result.message = "Start Date should not be later than End Date.";
                result.warnFields = ["New_Price_Start_Date__c", "New_Price_Firm_Date__c"];
            }
        }

        // Finalize the result response here
        result.hasWarnings = result.warnings.length > 0;
        console.log(result);
        return result;
    },

    /*
    * Function to calculate the absolute difference in days, months and years between 2 days taking into account variable month lengths and leap years
    * It ignores any time component (ie hours, minutes and seconds)
    *   From: https://gist.github.com/clecuona/2945438
    */
    dateDiff: function (dt1, dt2) {
        /*
        * setup 'empty' return object
        */
        var ret = {days:0, months:0, years:0};

        /*
        * If the dates are equal, return the 'empty' object
        */
        if (dt1 == dt2) return ret;

        /*
        * ensure dt2 > dt1
        */
        if (dt1 > dt2) {
            var dtmp = dt2;
            dt2 = dt1;
            dt1 = dtmp;
        }

        /*
        * First get the number of full years
        */

        var year1 = dt1.getFullYear();
        var year2 = dt2.getFullYear();

        var month1 = dt1.getMonth();
        var month2 = dt2.getMonth();

        var day1 = dt1.getDate();
        var day2 = dt2.getDate();

        /*
        * Set initial values bearing in mind the months or days may be negative
        */

        ret['years'] = year2 - year1;
        ret['months'] = month2 - month1;
        ret['days'] = day2 - day1;

        /*
        * Now we deal with the negatives
        */

        /*
        * First if the day difference is negative
        * eg dt2 = 13 oct, dt1 = 25 sept
        */
        if (ret['days'] < 0) {
            /*
            * Use temporary dates to get the number of days remaining in the month
            */
            var dtmp1 = new Date(dt1.getFullYear(), dt1.getMonth() + 1, 1, 0, 0, -1);

            var numDays = dtmp1.getDate();

            ret['months'] -= 1;
            ret['days'] += numDays;

        }

        /*
        * Now if the month difference is negative
        */
        if (ret['months'] < 0) {
            ret['months'] += 12;
            ret['years'] -= 1;
        }

        return ret;
    }
})