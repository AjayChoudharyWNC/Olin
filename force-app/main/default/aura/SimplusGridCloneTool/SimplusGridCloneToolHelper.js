({
    doValidations: function (fl) {
        //console.log("start validation");
        var fixedList = [];
        var self = this;
        fl.forEach((quoteLine) => {
            quoteLine.hasError = false;
            quoteLine.hasWarnings = false;
            quoteLine.errors = [];
            quoteLine.warnings = [];
            // WARNINGS
            if (quoteLine.line.New_Price_Start_Date__c !== "" && quoteLine.line.New_Price_Firm_Date__c !== "") {
                let newStartDate = new Date(quoteLine.line.New_Price_Start_Date__c);
                let newEndDate = new Date(quoteLine.line.New_Price_Firm_Date__c);
                let previousEndDate = new Date(quoteLine.line.Price_Firm_Date__c);

                // Warn the user if there is an overlap on the dates.
                if (newStartDate < previousEndDate) {
                    quoteLine.warnings.push("New Price Start Date is earlier than the Previous Price Expiration Date.");
                }

                // Warn the user if the dates exceed the pricing change frequency
                let dateDiffs = self.dateDiff(newStartDate, newEndDate);
                //console.log(dateDiffs);
                //console.log(quoteLine.Price_Change_Frequency__c);
                let hasDateRangeWarning = false;
                if (quoteLine.line.Price_Change_Frequency__c === "Monthly" &&
                    (dateDiffs.years > 0 ||
                        dateDiffs.months > 1 ||
                        (dateDiffs.months == 1 && dateDiffs.days > 0))) {
                    hasDateRangeWarning = true;
                }
                else if (quoteLine.line.Price_Change_Frequency__c === "Bi-Monthly" &&
                    (dateDiffs.years > 0 ||
                        dateDiffs.months > 2 ||
                        (dateDiffs.months == 2 && dateDiffs.days > 0))) {
                    hasDateRangeWarning = true;
                }
                else if (quoteLine.line.Price_Change_Frequency__c === "Quarterly" &&
                    (dateDiffs.years > 0 ||
                        dateDiffs.months > 3 ||
                        (dateDiffs.months == 3 && dateDiffs.days > 0))) {
                    hasDateRangeWarning = true;
                }
                else if (quoteLine.line.Price_Change_Frequency__c === "Semi-Annual" &&
                    (dateDiffs.years > 0 ||
                        dateDiffs.months > 6 ||
                        (dateDiffs.months == 6 && dateDiffs.days > 0))) {
                    hasDateRangeWarning = true;
                }
                else if (quoteLine.line.Price_Change_Frequency__c === "Annual" &&
                    (dateDiffs.years > 1 ||
                        (dateDiffs.years == 1 && dateDiffs.months > 0) ||
                        (dateDiffs.years == 1 && dateDiffs.days > 0))) {
                    hasDateRangeWarning = true;
                }
                if (hasDateRangeWarning) {
                    quoteLine.warnings.push("Date range is greater than the price change frequency.");
                }
            }

            // ERRORS
            // New start date should not be greater than New end date.
            if (quoteLine.line.New_Price_Start_Date__c && quoteLine.line.New_Price_Firm_Date__c) {
                let newStartDate = new Date(quoteLine.line.New_Price_Start_Date__c);
                let newEndDate = new Date(quoteLine.line.New_Price_Firm_Date__c);

                if (newStartDate > newEndDate) {
                    quoteLine.errors.push("New Price Start Date should not be later than New Price Expiration Date.");
                }

                let agreementEndDate = new Date(quoteLine.line.SBQQ__Quote__r.SBQQ__EndDate__c);
                if (agreementEndDate < newStartDate || agreementEndDate < newEndDate) {
                    quoteLine.errors.push("Agreement end date should not be earlier than the New Price Start/Expiration Date.");
                }
            }
            // New Price Start Date and New Price Expiration Date is required,
            if (!quoteLine.line.New_Price_Start_Date__c) {
                quoteLine.errors.push("New Price Start Date is required.");
            }
            if (!quoteLine.line.New_Price_Firm_Date__c) {
                quoteLine.errors.push("New Price Expiration Date is required.");
            }

            // Finalizing properties
            quoteLine.hasErrors = quoteLine.errors.length > 0;
            quoteLine.hasWarnings = quoteLine.warnings.length > 0;

            quoteLine.errorMessages = quoteLine.errors.length > 0 ? quoteLine.errors.join('\n') : '';
            quoteLine.warnMessages = quoteLine.warnings.length > 0 ? quoteLine.warnings.join('\n') : '';

            if (quoteLine.isSelected && quoteLine.hasErrors) {
                quoteLine.isSelected = false;
            }

            //console.log('quoteLine warnings: ' + quoteLine.warnings);
            //console.log('quoteLine errors: ' + quoteLine.errors);

            //quote.hasError = quote.hasError || quoteLine.hasErrors;
            //quote.hasWarnings = quote.hasWarnings || quoteLine.hasWarnings;

            if (quoteLine.hasErrors) {
                quoteLine.icon = "utility:error";
                quoteLine.variant = "error";
                quoteLine.validationMsg = quoteLine.errorMessages;
            }
            else if (quoteLine.hasWarnings) {
                quoteLine.icon = "utility:warning";
                quoteLine.variant = "warning";
                quoteLine.validationMsg = quoteLine.warnMessages;
            }
            else {
                quoteLine.icon = "utility:success";
                quoteLine.variant = "success";
                quoteLine.validationMsg = "Validation passed.";
            }

            fixedList.push(quoteLine);
        });

        //console.log("fixedList: ");
        //console.log(fixedList);

        return fixedList;
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
        var ret = { days: 0, months: 0, years: 0 };

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