({
    init : function(component, event, helper) {
        var email = component.get('v.email');
        var languageLabelMap = component.get('v.languageLabelMap');
        if(!email && !component.get('v.sapId')){
            //window.location.href = '/SiteLogin/OnboardLogin';
        }
        else{
            var action = component.get('c.getForms');
            action.setParams({
                'appUserEmail': component.get('v.email'),
                'sapId' : component.get('v.sapId')
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if(state === 'SUCCESS'){
                    var result = response.getReturnValue();
                    helper.processTranslation(component, result);
                    //component.set('v.items', result);
                    if(result && result.length > 1){
                        var name = result[1].name;
                        var nodeId = name.split('-')[0];
                        helper.getAccountDetails(component, nodeId, '');
                        helper.getSapRecord(component, nodeId, '');
                    }
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    handleLanguageFromParent : function(component, event, helper){
       helper.processTranslation(component, component.get('v.items'));
    },
    
    handleTreeNodeClickEvt : function(component, event, helper){
        var nodeId = event.getParam("nodeId");
        var nodeClicked = event.getParam("nodeClicked");
        var sapNo = event.getParam("sapNo");
        var selectedNode = component.get('v.selectedItem');
        var currentSelItem = nodeId+'-'+nodeClicked+'-'+sapNo;
        if(selectedNode != currentSelItem){
            component.set('v.selectedItem',currentSelItem);
        }
       
    },
    
    handleSelect: function(component,event,helper){
        event.preventDefault();
        var name = event.getParam('name');
        component.set('v.selectedItem', name);
        var nodeClicked = '';
        var nodeId = '';
        var sapNo = '';
        if(name && name != '' && name == 'Instructions'){
            nodeClicked = 'Instructions';
            nodeId = 'Instructions';
            sapNo = 'Instructions';
        }
        else if(name != undefined && name != null && name != ''){
            nodeClicked = name.split('-')[1];
            nodeId = name.split('-')[0];
            sapNo = name.split('-')[2];
        }
        if(nodeClicked == 'CI' || nodeClicked == 'OP' || nodeClicked == 'CA' || nodeClicked == 'PS'){
            helper.getAccountDetails(component, nodeId, '');
             helper.getSapRecord(component, nodeId, '');
        }
        else{
            helper.getAccountDetails(component, '', sapNo);
             helper.getSapRecord(component, '', sapNo);
        }
        var appEvent = $A.get("e.c:OCO_CustomerTreeClick");
        appEvent.setParams({ "nodeClicked" : nodeClicked, "nodeId": nodeId, "sapNo": sapNo});
        appEvent.fire();
    },  
    
    handleAllSectionCompleted : function(component, event, helper){
        component.set('v.selectedItem', event.getParam("selectedNode"));
    },
    
    fetchSapRecord : function(component, event, helper){
        helper.getSapRecord(component, event.getParam('sapId'), '');
    },
    
    handleShareWithColleague : function(component, event, helper){
        var appEvent = $A.get("e.c:OCO_CustomerOnboardingShareEvt");
        appEvent.fire();
    }
   

})