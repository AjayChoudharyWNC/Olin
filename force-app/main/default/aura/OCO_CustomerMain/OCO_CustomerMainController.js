({
    
    doInit : function(component, event, helper){
       helper.getLanguageFile(component);
        
        
    },
    closeLeftPanel : function(component, event, helper){
        document.getElementById("mySidenav").style.width = "0";
    },
    
    openLeftPanel : function(component, event, helper){
       document.getElementById("mySidenav").style.width = "450px";
    },
    
    handleLanguage : function(component, event, helper){
        helper.processTranslation(component, true);
        helper.saveAppUserRecord(component);
    }
	    
    
})