({
    fetchTaskList : function(component, event, filter){
        var action = component.get("c.taskList");
        action.setParams({filter:filter });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.Message", false);
                component.set("v.Tasks", response.getReturnValue());
                var pagePick = [];
                if(response.getReturnValue().length == 0){
                    component.set('v.Message',true);
                }
                else{
                    component.set('v.Message',false);
                }
                for(var i=1;i<=Math.ceil(response.getReturnValue().length/5);i++){
                    pagePick[i-1] = i;
                }
                component.set('v.pagePick',pagePick);
                this.paginate(component, 1);
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },
    
    paginate : function(component,currentPage){
        var totalPage;
        var pageSize = 5;
        var allRecords = component.get('v.Tasks');
        var pageRecords = [];
        totalPage = Math.ceil(allRecords.length/pageSize);
        console.log('totalPage--',totalPage);
         if(totalPage == 0){
            component.set('v.totalPage', 1);
        }else{
            component.set('v.totalPage', totalPage);
        }
        component.set('v.currentPage', currentPage);
        component.set('v.selectedValue', currentPage);
        if(allRecords.length <= pageSize){
             component.set('v.pageTaskList',allRecords); 
        }
        else{
            var firstIndex;
            var lastIndex;
            if(currentPage == totalPage){
                firstIndex = (currentPage-1)*pageSize;
                lastIndex = allRecords.length;
            }
            else{
                firstIndex = (currentPage-1)*pageSize;
                lastIndex = currentPage*pageSize;
            }
            for(var i=firstIndex;i<lastIndex;i++){
                pageRecords.push(allRecords[i]);
            }
            component.set('v.pageTaskList',pageRecords);
        }
    },
    check :  function(component, event, tId, isChecked){
        var action = component.get("c.updateTask");
        action.setParams({tId:tId,isChecked:isChecked });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
            }
            else {
                console.log("Failed with state:** " + state);
            }
        });
        $A.enqueueAction(action);
    }
})