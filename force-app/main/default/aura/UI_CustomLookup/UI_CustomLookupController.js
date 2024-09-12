({
    onInputType : function(component, event, helper) {
        component.set("v.message");
        var getRecords = component.get("c.doSearch");
		var inputVal = event.target.value;
        console.log("inputVal >> ", inputVal);
        
        getRecords.setParams({
            objSrc : component.get("v.srcObject"),
            fieldList : component.get("v.display"),
            filter : component.get("v.filter"), 
            orderStr : "",
            inputVal : inputVal,
            searchFrom : component.get("v.searchFrom")
        });
        getRecords.setCallback(this, function(a){
            console.log(a, a.getReturnValue());
            var result = a.getReturnValue();
            if(a.getState() == 'SUCCESS') {
                if(inputVal == result.searchFilter) {
                    component.set("v.results", result.returnList);   
                    component.set("v.message", result.message);
                }
            } else {
        		component.set("v.message", a.getError()[0]);
            }
        });
        if(inputVal.length > 0) $A.enqueueAction(getRecords);
        else component.set("v.results", []);
    },
    
    //move to helper
    runSearch : function(component, event, helper) {
        component.set("v.message");
        var getRecords = component.get("c.doSearch");
        console.log(component.find("inputField"));
		var inputVal = component.find("inputField").getElement().value;
        console.log("inputVal >> ", inputVal);
        
        getRecords.setParams({
            objSrc : component.get("v.srcObject"),
            fieldList : component.get("v.display"),
            filter : component.get("v.filter"), 
            orderStr : "",
            inputVal : inputVal,
            searchFrom : component.get("v.searchFrom")
        });
        getRecords.setCallback(this, function(a){
            console.log(a, a.getReturnValue());
            var result = a.getReturnValue();
            if(a.getState() == 'SUCCESS') {
                if(inputVal == result.searchFilter) {
                    component.set("v.results", result.returnList);   
                    component.set("v.message", result.message);
                }
            } else {
        		component.set("v.message", a.getError()[0]);
            }
        });
        if(inputVal.length > -1) $A.enqueueAction(getRecords);
        else component.set("v.results", []);
    },

    clearResults : function(component, event, helper) {
        window.setTimeout(
            $A.getCallback(function() {
                component.set("v.results", []);
        		component.set("v.message");
            }), 200
        );
    },

    onItemSelect : function(component, event, helper) {
        var results = component.get("v.results");
        var idx = event.target.getAttribute("data-src-index");
        component.set("v.labelVal", results[idx].Name);
        component.set("v.idVal", results[idx].Id);
        component.set("v.results", []);
        component.set("v.message");

        console.log(component.get("v.labelVal"), component.get("v.idVal"));

        var getPush = component.getEvent("pushNewVal");
        getPush.setParams({
            "jsonParam" : JSON.stringify({
                "name" : component.get("v.labelVal"),
                "id" : component.get("v.idVal")
            })
        });
        getPush.fire();
    },

    revertValue : function(component, event, helper) {
        component.set("v.labelVal");
        component.set("v.idVal");
        var getPush = component.getEvent("pushNewVal");
        getPush.setParams({
            jsonParam : {
                name : null,
                id : null
            }
        });
        getPush.fire();
    },

    pushVal : function(component, event, helper) {
        var getPush = component.getEvent("pushNewVal");
        getPush.setParams({
            jsonParams : {
                name : component.get("v.labelVal"),
                id : component.get("v.idVal")
            }
        });
        getPush.fire();
    }

})