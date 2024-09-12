({
    
	getLanguageFile : function(component){
        var action = component.get('c.getLanguageFileBody');
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS'){
                component.set('v.languageFileAsString', response.getReturnValue());
                this.processLanguageFileHeaders(component);
            }
        });
        $A.enqueueAction(action);
    },
    
    processLanguageFileHeaders : function(component){
        var languageFileAsString = component.get('v.languageFileAsString');
         if(languageFileAsString){
            var translationMapObj = Papa.parse(languageFileAsString,{'header' : true, 'skipEmptyLines' : true});
            var headers = translationMapObj.meta.fields;
            var languageOptions = [];
            for(var i=1;i<headers.length;i++){
                if(headers[i]){
                    languageOptions.push(headers[i]);
                }
            }
            component.set('v.languageOptions', languageOptions);
            this.fetchAppUser(component);
            this.processTranslation(component, false);
         }
    },
    processTranslation : function(component, callChildMethod){
        var languageFileAsString = component.get('v.languageFileAsString');
        var pageLanguage = component.get('v.pageLanguage');
        if(languageFileAsString){
            var translationMapObj = Papa.parse(languageFileAsString,{'header' : true, 'skipEmptyLines' : true});
            console.log('translationMapObj', translationMapObj);
            var languageTextMap = {};
            var englishLanguageTextMap = {};
            var data = translationMapObj.data;
            component.set('v.languageData', data);
            for(var i=0; i<data.length;i++){
                languageTextMap[data[i]['ID']] = data[i][pageLanguage];
                englishLanguageTextMap[data[i]['ID']] = data[i]['English'];
            }
            console.log('languageTextMap', JSON.stringify(languageTextMap));
            component.set('v.languageTextMap', languageTextMap);
            component.set('v.englishLanguageTextMap', englishLanguageTextMap);
            component.set('v.isLanguageLoaded', true);
            var appEvent = $A.get("e.c:OCO_HandleLanguageChange_CA");
            appEvent.fire();
            if(callChildMethod){
                if(Array.isArray(component.find('OCO_LeftCmp'))){
                    component.find('OCO_LeftCmp').forEach(function(e){
                        e.handleLanguageChange();
                    });
                }
                else{
                    component.find('OCO_LeftCmp').handleLanguageChange();
                }
            }
        }
        
    },
    
    fetchAppUser : function(component){
        var userLang;
        var action = component.get('c.getAppUserRecord');
        var languageOptions = component.get('v.languageOptions');
        action.setParams({
            appUserEmail : component.get('v.appUserEmail')
        });
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS'){
                var appUser = response.getReturnValue();
                if(appUser.Language__c){
                    component.set('v.pageLanguage', appUser.Language__c);
                }
                else{
                    var userLang = navigator.language || navigator.userLanguage;
                    if(userLang){
                        for(var i = 0;i< languageOptions.length; i++){
                            if(languageOptions[i].includes(userLang)){
                                component.set('v.pageLanguage', languageOptions[i]);
                                appUser.Language__c =  languageOptions[i];
                                this.saveAppUserRecord(component);
                                break;
                            }
                        }
                    }
                }
                if(!appUser.Language__c){
                    appUser.Language__c = component.get('v.pageLanguage');
                    this.saveAppUserRecord(component, appUser);
                }
                this.processTranslation(component, false);
                component.set('v.appUserRecord', appUser);
            }
        });
        $A.enqueueAction(action);
    },
    
    saveAppUserRecord : function(component){
        var action = component.get('c.saveAppUser');
        action.setParams({
            appUserEmail : component.get('v.appUserEmail'),
            language : component.get('v.pageLanguage')
        });
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS'){
                console.log('app user saved');
            }
        });
        $A.enqueueAction(action);
    }
})