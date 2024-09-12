({
    doValidations: function (records, columns) {
        var rows = [];
        records.forEach((quoteLine) => {
            quoteLine.hasError = false;
            quoteLine.hasWarnings = false;
            quoteLine.errors = [];
            quoteLine.warnings = [];

            // ERRORS
            columns.forEach((column) => {
                if (!quoteLine.line[column.fieldPath]) {
                    quoteLine.errors.push(column.label + " is required.");
                }
            });

            // Finalizing properties
            quoteLine.hasErrors = quoteLine.errors.length > 0;
            quoteLine.hasWarnings = quoteLine.warnings.length > 0;

            quoteLine.errorMessages = quoteLine.errors.length > 0 ? quoteLine.errors.join('\n') : '';
            quoteLine.warnMessages = quoteLine.warnings.length > 0 ? quoteLine.warnings.join('\n') : '';

            if (quoteLine.isSelected && quoteLine.hasErrors) {
                quoteLine.isSelected = false;
            }

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

            rows.push(quoteLine);
        });

        return rows;
    },

    doServerCall: function (component, method, params) {
        // var promiseInstance = new Promise($A.getCallback(function (resolve, reject) {
        //     var action = component.get(method);
        //     if (params) {
        //         action.setParams(params);
        //     }
        //     console.log('****param to controller:' + JSON.stringify(params));
        //     action.setCallback(this, function (response) {
        //         var state = response.getState();
        //         if (state === "SUCCESS") {
        //             resolve(response.getReturnValue());
        //         } else if (state === "ERROR") {
        //             var errors = response.getError();
        //             console.error(errors);
        //             console.log('>>>SERVER CALL ERROR<<<');
        //             reject(response.getError());
        //         }
        //     });
        //     $A.enqueueAction(action);
        // }));
        // return promiseInstance;
        return new Promise(function (resolve, reject) {
            var action = component.get(method);
            action.setParams(params);
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    resolve(response.getReturnValue());
                } else if (state === "ERROR") {
                    reject(response.getError());
                }
            });
            $A.enqueueAction(action);
        });
    }
})