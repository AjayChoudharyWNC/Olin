({
	getAccountDetails : function(component, sapId, sapName) {
		var action = component.get('c.fetchAccountDetails');
        action.setParams({
            "sapId" : sapId,
            "sapName" : sapName
        });
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS'){
                component.set('v.mainAccount', response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	},
    
    getSapRecord : function(component, sapId, sapName){
        var action = component.get('c.getSapRecord');
        action.setParams({
            'sapRecordId' : sapId,
            'sapNo' : sapName
        });
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS'){
                component.set('v.sapRecord', response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    
    processTranslation : function(component, items){
        var languageLabelMap = component.get('v.languageLabelMap');
        items.forEach(function(e){
            if(e.nodeLangId && languageLabelMap.hasOwnProperty(e.nodeLangId)){
                var label = e.label;
                if(/\d/.test(label)){
                    var numberIndex = label.search(/\d/);
                    e.label = languageLabelMap[e.nodeLangId] +' '+label.substring(numberIndex, label.length);
                }
                else{
                    e.label = languageLabelMap[e.nodeLangId];
                }
                
            }
            if(e.items){
                e.items.forEach(function(s){
                    if(s.nodeLangId && languageLabelMap.hasOwnProperty(s.nodeLangId)){
                        var label = s.label;
                        if(/\d/.test(label)){
                            var numberIndex = label.search(/\d/);
                            s.label = languageLabelMap[s.nodeLangId] +' '+label.substring(numberIndex, label.length);
                        }
                        else{
                            s.label = languageLabelMap[s.nodeLangId];
                        }
                        
                    }
                    if(s.items){
                        s.items.forEach(function(p){
                            if(p.nodeLangId && languageLabelMap.hasOwnProperty(p.nodeLangId)){
                                var label = p.label;
                                if(/\d/.test(label)){
                                    var numberIndex = label.search(/\d/);
                                    p.label = languageLabelMap[p.nodeLangId] +' '+label.substring(numberIndex, label.length);
                                }
                                else{
                                    p.label = languageLabelMap[p.nodeLangId];
                                }
                                
                            }
                            if(p.items){
                                p.items.forEach(function(m){
                                    if(m.nodeLangId && languageLabelMap.hasOwnProperty(m.nodeLangId)){
                                        var label = m.label;
                                        if(/\d/.test(label)){
                                            var numberIndex = label.search(/\d/);
                                            m.label = languageLabelMap[m.nodeLangId] +' '+label.substring(numberIndex, label.length);
                                        }
                                        else{
                                            m.label = languageLabelMap[m.nodeLangId];
                                        }
                                        
                                    }
                                });
                            }
                        });
                    }
                });
            }
        });
        /*for(var i=0;i<items.length;i++){
            if(items[i].nodeLangId && languageLabelMap.hasOwnProperty(items[i].nodeLangId)){
                var label = items[i].label;
                if(/\d/.test(label)){
                    var numberIndex = label.search(/\d/);
                    items[i].label = languageLabelMap[items[i].nodeLangId] +' '+label.substring(numberIndex, label.length);
                }
                else{
                    items[i].label = languageLabelMap[items[i].nodeLangId];
                }
                
            }
        }*/
        component.set('v.items', items);
    }
})