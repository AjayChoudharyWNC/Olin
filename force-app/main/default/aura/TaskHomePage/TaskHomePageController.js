({
    doInit  : function(component, event, helper){
        helper.fetchTaskList(component, event, 'onLoad');
    },
    onCheck : function(component, event, helper){
        var tId = event.getSource().get('v.value');
        var isChecked = event.getSource().get('v.checked');
        var subLink = document.getElementById(tId);
        if(isChecked){
            subLink.style = 'text-decoration:line-through';
        }
        else{
            subLink.style = 'text-decoration:none';
        }
        helper.check(component, event, tId, isChecked);
    },
    filterTask : function(component, event, helper){
        var filter = event.getSource().get('v.name');
        helper.fetchTaskList(component, event, filter);
    },
    
    navigate : function(component, event, helper){
        var pageNumber=0;
        pageNumber = component.get('v.currentPage');
        var dir = event.getSource().get('v.name');
        console.log('dir',dir);
        if(dir == 'PreviousPage'){
            pageNumber -= 1;
        }
        else if(dir == 'NextPage'){
            pageNumber += 1;
        }
            else if(dir == 'select'){
                pageNumber = Number(component.find("recordSelect").get("v.value"))

            }
        console.log('pageNumber---',pageNumber);
        helper.paginate(component, pageNumber);
    }
})