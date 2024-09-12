({
    MAX_FILE_SIZE: 4500000, //Max file size 4.5 MB 
    CHUNK_SIZE: 750000, //Chunk Max size 750Kb 
    
    checkForAllSections : function(component, event){
        if(component.get('v.sapId')){
            var action = component.get('c.getShipToAndProducts');
            action.setParams({
                "sapId" : component.get('v.sapId')
            });
            action.setCallback(this, function(response){
                if(response.getState() === 'SUCCESS'){
                    var shipTos = response.getReturnValue();
                    var isAllSectionCompleted = false;
                    var isAllShipToCompleted = false;
                    for(var i=0;i<shipTos.length;i++){
                        if(shipTos[i].Ship_To_Section_Completed__c){
                            isAllShipToCompleted = true;
                        }
                        else{
                            isAllShipToCompleted = false;
                        }
                        if(shipTos[i].Onboarding_Products__r){
                            for(var j=0; j<shipTos[i].Onboarding_Products__r.length;j++){
                                var prod = shipTos[i].Onboarding_Products__r[j];
                                if(prod.Product_Section_Completed__c && prod.All_Questionnaire_Completed__c){
                                    isAllSectionCompleted = true
                                }
                                else{
                                    isAllSectionCompleted = false;
                                    break;
                                }
                            }
                        }
                    }
                    if(isAllShipToCompleted && isAllSectionCompleted)
                        component.set('v.isAllSectionCompleted', isAllSectionCompleted);
                }
            });
            $A.enqueueAction(action);
        }
    },
    fetchQuestionnaires: function (component) {
        var action = component.get("c.getQuestionnaire");
        action.setParams({
            "prodId": component.get('v.prodId')
        });
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                var quesList = response.getReturnValue();
                if(quesList && quesList.length > 0){
                    if (quesList[0].Questionnaire_Setup_Type__c == 'Online') {
                        component.set('v.isOffline', false);
                        component.set('v.setupValue', 'Online');
                    }
                    else if (quesList[0].Questionnaire_Setup_Type__c == 'Offline') {
                        component.set('v.setupValue', 'Offline');
                        if (component.find('setupType')){
                            if(Array.isArray(component.find('setupType'))){
                                component.find('setupType')[0].set('v.disabled', true);
                            }
                            else{
                                component.find('setupType').set('v.disabled', true);
                            }
                        }
                        
                        if (component.find('setupButton')){
                            if(Array.isArray(component.find('setupButton'))){
                                component.find('setupButton')[0].set('v.disabled', true);
                            }
                            else{
                                component.find('setupButton').set('v.disabled', true);
                            }
                        }
                        component.set('v.isOffline', true);
                    }
                        else {
                            component.set('v.isOffline', true);
                        }
                    if (quesList[0].Onboarding_Product__r.Onboarding_Ship_To__r.Ship_To_State_Province__c == 'NY' ||
                        quesList[0].Onboarding_Product__r.Onboarding_Ship_To__r.Ship_To_State_Province__c == 'New York' ||
                        quesList[0].Onboarding_Product__r.Onboarding_Ship_To__r.Ship_To_State_Province__c == 'PA' || 
                        quesList[0].Onboarding_Product__r.Onboarding_Ship_To__r.Ship_To_State_Province__c == 'Pennsylvania' || 
                        quesList[0].Onboarding_Product__r.Onboarding_Ship_To__r.Ship_To_State_Province__c == 'KS' || 
                        quesList[0].Onboarding_Product__r.Onboarding_Ship_To__r.Ship_To_State_Province__c == 'Kansas') {
                        component.set('v.showTankRegFile', true);
                    }
                    component.set('v.ques', quesList[0]);
                    component.set('v.mainQuestionnaire', quesList[0]);
                    this.fetchFiles(component, 'Questionnaire File');
                    this.fetchFiles(component, 'Questionnaire Word File');
                    this.fetchFiles(component, 'Questionnaire Tank Registeration File');
                    this.handleQuestionnaireLink(component);
                }
                else{
                    component.set('v.isOffline', false);
                    component.set('v.spinner', false);
                }
                component.set('v.questionnaireList', quesList);
                console.log('quesList===', quesList);
            }
            else if (response.getState() === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
            
        });
        $A.enqueueAction(action);
    },
    
    fetchProductDetails : function(component) {
        var action = component.get('c.getProductDetails');
        action.setParams({
            'prodId' : component.get('v.prodId')
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                var prod = response.getReturnValue();
                /*if(prod.Shipment_Questionnaire__c == 'Epoxy High-Medium Hazard - Truck'){
                    //component.set('v.showStandardTruck', true);
                }
                else{
                    component.set('v.showStandardTruck', false);
                }*/
                
                if (!prod.Product_Name_Form__c) {
                    prod.Product_Name_Form__c = prod.Purchased_Product_Name__c;
                }
                var p2 = prod.Purchased_Product__r.Product_R1__r.PH1_Performance_Center__c;
                var shipMode = prod.New_Customer_Ship_Mode__c;
                if(p2 && shipMode){
                    if ((prod.Onboarding_Ship_To__r.Ship_To_Country__c == 'US' || prod.Onboarding_Ship_To__r.Ship_To_Country__c == 'United States' || prod.Onboarding_Ship_To__r.Ship_To_Country__c == 'USA') &&
                        ((p2 && p2.includes('Chlorine') || p2.includes('CHLORINE') || p2.includes('Sodium Hypochlorite') || p2.includes('SODIUM HYPOCHLORITE') || p2.includes('Bleach') || p2.includes('BLEACH')))) {
                        prod.showUSAQuestions = true;
                    }
                    else {
                        prod.showUSAQuestions = false;
                    }
                    if ((prod.Onboarding_Ship_To__r.Ship_To_Country__c == 'CA' || prod.Onboarding_Ship_To__r.Ship_To_Country__c == 'Canada') && 
                        ((p2 && (p2.includes('Sodium Hypochlorite') || p2.includes('Bleach') || p2.includes('SODIUM HYPOCHLORITE') || p2.includes('BLEACH'))))) {
                        prod.showCanadaQuestions = true;
                    }
                    else {
                        prod.showCanadaQuestions = false;
                    }
                }
                else{
                    prod.showUSAQuestions = false;
                    prod.showCanadaQuestions = false;
                }
                component.set('v.prod', prod);
                if(prod.Truck_Type__c == 'Bulk' && prod.Customer_Pickup__c == 'No')
                {
                    component.set('v.showBulkTruck',true);
                }
                else
                {
                    component.set('v.showBulkTruck',false);
                }
                this.fetchFiles(component, 'prodFile');
            }
        });
        $A.enqueueAction(action);
    },
    handleDeleteQues : function(component){
        component.set('v.spinner', true);
        var name = component.get('v.toDeleteQuesIndx');
        var quesList = component.get('v.questionnaireList');
        var action  = component.get('c.deleteQuestionnaire');
        action.setParams({
            recordId : quesList[name].Id
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                console.log('delete success');
                quesList.splice(name,1);
                component.set('v.questionnaireList',quesList);
                component.set('v.spinner', false);
                component.set('v.finalErrors',[]);
                var parent = component.get('v.parent');
                parent.openToast('utility:success', 'JS_31', 'success');
                
            }
        });
        $A.enqueueAction(action);
    },
    handleFileDelete : function(component){
        component.set('v.spinner', true);
        var id = component.get('v.toDeleteFileId');
        var action = component.get('c.deleteAttachment');
        action.setParams({
            "recordId" : id
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                this.fetchFiles(component, component.get('v.fileType'));
                component.set('v.spinner', false);
                var parent = component.get('v.parent');
                parent.openToast('utility:success', 'JS_27', 'success');
            }
        });
        $A.enqueueAction(action);  
    },
    quesSwitchOffline : function(component){
        component.set('v.spinner', true);
        var mainQuestionnaire = component.get('v.mainQuestionnaire');
        mainQuestionnaire.Questionnaire_Setup_Type__c = 'Offline';
        this.saveQuestionnaireRecord(component, false, '', [mainQuestionnaire]);
        this.switchToOfflineQues(component);  
    },
    handleSaveProgress : function(component){
        component.set('v.spinner', true);
        var action = component.get('c.saveQuestionnaire');
        action.setParams({
            recordList : [component.get('v.mainQuestionnaire')],
            isFormSubmit : false
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                component.set('v.spinner', false);
                component.set('v.mainQuestionnaire', response.getReturnValue());
                var parent = component.get('v.parent');
                //parent.openToast('utility:success', 'JS_21', 'success');
            }
        });
        $A.enqueueAction(action);
    },
    handleQuestionnaireLink: function (component) {
        var allQuestionnaire = component.get('v.questionnaireList');
        if(allQuestionnaire && allQuestionnaire.length > 0){
            var mainQuestionnaire = component.get('v.mainQuestionnaire');
            var value = component.get('v.setupValue');
            var quesType = mainQuestionnaire.Onboarding_Product__r.Shipment_Questionnaire__c;
            var resName = '';
            var language = component.get('v.selectedPageLanguage');
            if (value == 'Offline' || value == 'Online') {
                if (quesType == 'Hydrochloric Acid - Rail') {
                    resName = 'Hydrochloric_Acid_Railcar';
                }
                else if (quesType == 'Hydrochloric Acid - Truck') {
                    resName = 'Hydrochloric_Acid_TankTruck';
                }
                    else if (quesType == 'Potassium Hydroxide - Barge') {
                        resName = 'Potassium_Hydroxide_Barge';
                    }
                        else if (quesType == 'Potassium Hydroxide - Rail') {
                            resName = 'Potassium_Hydroxide_RailCar';
                        }
                            else if (quesType == 'Sodium Hydroxide - Barge') {
                                resName = 'Sodium_Hydroxide_Barge';
                            }
                                else if (quesType == 'Sodium Hydroxide - Rail') {
                                    resName = 'Sodium_Hydroxide_RailCar';
                                }
                                    else if (quesType == 'Sodium Hydroxide - Truck') {
                                        resName = 'Sodium_Hydroxide_TankTruck	';
                                    }
                                        else if (quesType == 'Sodium Hypochlorite - Rail') {
                                            resName = 'Sodium_Hypochlorite_RailCar';
                                        }
                                            else if (quesType == 'Sodium Hypochlorite - Truck') {
                                                resName = 'Sodium_Hypochlorite_TankTruck';
                                            }
                                                else if (quesType == 'Sulfuric Acid - Rail Car') {
                                                    resName = 'Sulfuric_Acid_RailCar';
                                                }
                                                    else if (quesType == 'Sulfuric Acid - Truck') {
                                                        resName = 'Sulfuric_Acid_TankTruck';
                                                    }
                                                        else if (quesType == 'Potassium Hydroxide - Truck') {
                                                            resName = 'Potassium_Hydroxide_TankTruck'
                                                        }
                                                            else if (quesType == 'Standard High Medium Checklist') {
                                                                component.set('v.hideSetupSelector', true);
                                                                resName = 'Epoxy_High_Medium_Hazard';
                                                            }
                                                                else if (quesType == 'Chloroform Checklist') {
                                                                    component.set('v.hideSetupSelector', true);
                                                                    resName = 'Epoxy_Chloroform';
                                                                }
                                                                    else if (quesType == 'Methyl Chloride Checklist') {
                                                                        component.set('v.hideSetupSelector', true);
                                                                        resName = 'Epoxy_Methyl_Chloride';
                                                                    }
                                                                        else if (quesType == 'Upstream Bisphenol') {
                                                                            component.set('v.hideSetupSelector', true);
                                                                            resName = 'Epoxy_Upstream_Bisphenol';
                                                                        }
                                                                            else if (quesType == 'Upstream EPI') {
                                                                                component.set('v.hideSetupSelector', true);
                                                                                resName = 'Epoxy_Upstream_EPI';
                                                                            }
                                                                                else if (quesType == 'Upstream Dichloropropene') {
                                                                                    component.set('v.hideSetupSelector', true);
                                                                                    resName = 'Epoxy_Upstream_Dichloropropene';
                                                                                }
                
                var questionnaireLink;
                var questionnaireLanguageLink;
                if (window.location.href.includes('SiteLogin')) {
                    questionnaireLink = '/SiteLogin/resource/'+resName;
                    questionnaireLanguageLink = language == 'French' ? '/SiteLogin/resource/'+resName+'_'+language : '/SiteLogin/resource/'+resName;
                }
                else {
                    questionnaireLink = '/resource/'+resName;
                    questionnaireLanguageLink = language == 'French' ? '/resource/'+resName+'_'+language : '/resource/'+resName;
                }
                component.set('v.questionnaireLink', questionnaireLink);
                component.set('v.questionnaireLanguageLink', questionnaireLanguageLink);
            }
        }
    },
    saveQuestionnaireRecord: function (component, isFormSubmit, quesIndx, quesList) {
        component.set('v.spinner', true);
        component.set('v.finalErrors', []);
        if (!quesList) {
            quesList = [];
            var allQuestionnaires = component.get('v.questionnaireList');
            for (var i = 0; i < allQuestionnaires.length; i++) {
                if (i == quesIndx) {
                    allQuestionnaires[i].Questionnaire_Section_Completed__c = true;
                    quesList.push(allQuestionnaires[i]);
                    break;
                }
            }
        }
        var action = component.get('c.saveQuestionnaire');
        action.setParams({
            recordList: quesList,
            isFormSubmit: isFormSubmit
        });
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                console.log('save success questionnaire');
                var languageMap = component.get('v.languageLabelMap');
                component.set('v.spinner', false);
                if (!isFormSubmit) {
                    if (this.mobileCheck())
                        alert(languageMap['JS_32']);
                    else{
                        var parent = component.get('v.parent');
                        parent.openToast('utility:success', 'JS_32', 'success');
                    }
                }
                else {
                    if (this.mobileCheck())
                        alert(languageMap['JS_32']);
                    else{
                        var parent = component.get('v.parent');
                        parent.openToast('utility:success', 'JS_20', 'success');
                    }
                    setTimeout(function () {
                        if (window.location.href.includes('SiteLogin')) {
                            window.location.href = '/SiteLogin/OnboardHome';
                        }
                        else {
                            window.location.href = '/apex/OnboardHome';
                        }
                    }, 2000);
                    
                }
            }
            else {
                console.log('error:', JSON.stringify(response.getError()));
            }
            component.set('v.spinner', false);
        });
        $A.enqueueAction(action);
    },
    
    handleChildCheckboxes: function (component, index) {
        var allCheckBoxes = component.find('headerCheck');
        if (Array.isArray(allCheckBoxes)) {
            for (var i = 0; i < allCheckBoxes.length; i++) {
                if (allCheckBoxes[i].get('v.name') == index) {
                    allCheckBoxes[i].set('v.checked', true);
                    break;
                }
            }
        }
        else {
            if (allCheckBoxes.get('v.name') == index) {
                allCheckBoxes.set('v.checked', true);
            }
        }
    },
    mobileCheck: function (component) {
        let check = false;
        (function (a) { if (/(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows ce|xda|xiino/i.test(a) || /1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(a.substr(0, 4))) check = true; })(navigator.userAgent || navigator.vendor || window.opera);
        return check;
    },
    handleSubmitButton: function (component) {
        var isAllChildChecked = false;
        var finalErrors = component.get('v.finalErrors');
        //if(finalErrors.length == 0){
        finalErrors = [];
        finalErrors.push('We have identified that certain required fields (*) are missing values for the following sections:');
        //}
        var childCheckBoxes = component.find('headerCheck');
        if (childCheckBoxes) {
            if (Array.isArray(childCheckBoxes)) {
                for (var i = 0; i < childCheckBoxes.length; i++) {
                    if (childCheckBoxes[i].get('v.checked')) {
                        isAllChildChecked = true;
                    }
                    else {
                        if (!finalErrors.includes(childCheckBoxes[i].get('v.label')))
                            finalErrors.push(childCheckBoxes[i].get('v.label'));
                        isAllChildChecked = false;
                        break;
                    }
                }
            }
            else {
                if (childCheckBoxes.get('v.checked')) {
                    isAllChildChecked = true;
                }
                else {
                    if (!finalErrors.includes(childCheckBoxes.get('v.label')))
                        finalErrors.push(childCheckBoxes.get('v.label'));
                    isAllChildChecked = false;
                }
            }
        }
        
        if (!isAllChildChecked) {
            component.set('v.finalErrors', finalErrors);
            return false;
        }
        else if (isAllChildChecked) {
            component.set('v.finalErrors', []);
            return true;
        }
        
        
    },
    
    uploadFiles : function(component){
        var quesFileList = component.get('v.quesFileList');
        var quesDocFileList = component.get('v.quesDocFileList');;
        var quesTankRegFileList = component.get('v.quesTankRegFileList');
        var prodFileList = component.get('v.prodFileList');
        if(prodFileList){
            var fileCount = prodFileList.length;
            if (fileCount > 0) {
                for (var i = 0; i < fileCount; i++) 
                {
                    if(prodFileList[i].Id == '')
                        return this.uploadHelper(component, event,prodFileList[i], 'prodFile');
                }
            }
        }
        if(quesFileList){
            var fileCount = quesFileList.length;
            if (fileCount > 0) {
                for (var i = 0; i < fileCount; i++) 
                {
                    if(quesFileList[i].Id == '')
                        return this.uploadHelper(component, event,quesFileList[i], 'Questionnaire File');
                }
            }
        }
        if(quesDocFileList){
            var fileCount = quesDocFileList.length;
            if (fileCount > 0) {
                for (var i = 0; i < fileCount; i++) 
                {
                    if(quesDocFileList[i].Id == '')
                        return this.uploadHelper(component, event,quesDocFileList[i], 'Questionnaire Word File');
                }
            }
        }
        if(quesTankRegFileList){
            var fileCount = quesTankRegFileList.length;
            if (fileCount > 0) {
                for (var j = 0; j < fileCount; j++) 
                {
                    if(quesTankRegFileList[j].Id == ''){
                        return this.uploadHelper(component, event,quesTankRegFileList[j], 'Questionnaire Tank Registeration File');
                    }
                }
            }
        }
    },
    
    uploadHelper: function (component, event, f, fileType) {
        var file = f;
        var self = this;
        // check the selected file size, if select file size greter then MAX_FILE_SIZE,
        // then show a alert msg to user,hide the loading spinner and return from function  
        if (file.size > self.MAX_FILE_SIZE) {
            var languageMap = component.get('v.languageLabelMap');
            component.set('v.confirmMessage', languageMap['JS_33']);
            component.set('v.confirmEventName', 'fileSize');
            component.set('v.confirmCancelLabel',languageMap['PS_41']);
            component.set('v.showConfirmDialog', true);
            component.set('v.spinner', false);
            return 'sizeError';
        }
        
        // Convert file content in Base64
        var objFileReader = new FileReader();
        objFileReader.onload = $A.getCallback(function () {
            var fileContents = objFileReader.result;
            var base64 = 'base64,';
            var dataStart = fileContents.indexOf(base64) + base64.length;
            fileContents = fileContents.substring(dataStart);
            self.uploadProcess(component, file, fileContents, fileType);
        });
        
        objFileReader.readAsDataURL(file);
    },
    
    uploadProcess: function (component, file, fileContents, fileType) {
        // set a default size or startpostiton as 0 
        var startPosition = 0;
        // calculate the end size or endPostion using Math.min() function which is return the min. value   
        var endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
        
        // start with the initial chunk, and set the attachId(last parameter)is null in begin
        this.uploadInChunk(component, file, fileContents, startPosition, endPosition, '', fileType);
    },
    
    
    uploadInChunk: function (component, file, fileContents, startPosition, endPosition, attachId, fileType) {
        // call the apex method 'saveFile'
        var getchunk = fileContents.substring(startPosition, endPosition);
        var action = component.get("c.saveFile")
        var parentId = file.ParentId;
        /*if (fileType == 'prodFile' || fileType == 'Questionnaire File' || fileType == 'taxFile') {
            parentId = file.ParentId;
        }
        else {
            parentId = component.get("v.recordId");
        }*/
        action.setParams({
            // Take current object's opened record. You can set dynamic values here as well
            parentId: parentId,
            fileName: file.name,
            base64Data: encodeURIComponent(getchunk),
            contentType: file.type,
            fileId: attachId,
            description: fileType
        });
        
        // set call back 
        action.setCallback(this, function (response) {
            attachId = response.getReturnValue();
            var state = response.getState();
            if (state === "SUCCESS") {
                // update the start position with end postion
                startPosition = endPosition;
                endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
                if (startPosition < endPosition) {
                    this.uploadInChunk(component, file, fileContents, startPosition, endPosition, attachId, fileType);
                } else {
                    //component.set('v.isSaveProgress', false);
                    var parent = component.get('v.parent');
                    //parent.openToast('utility:success', 'JS_21', 'success');
                    this.fetchFiles(component,fileType);
                    console.log('your File is uploaded successfully', true);
                    component.set('v.spinner', false);
                }
                // handel the response errors        
            } else if (state === "INCOMPLETE") {
                console.log("From server: " + response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchFiles: function (component, fileType) {
        var parentId = component.get('v.prodId');
        component.set('v.spinner', true);
        var action = component.get('c.fetchAttachments');
        action.setParams({
            "parentId": parentId,
            "fileDescString": fileType
        });
        action.setCallback(this, function (response) {
            if (response.getState() === 'SUCCESS') {
                var files = response.getReturnValue();
                for (var i = 0; i < files.length; i++) {
                    if (window.location.href.includes('SiteLogin')) {
                        files[i].link = "/SiteLogin/servlet/servlet.FileDownload?file=" + files[i].Id;
                    }
                    else {
                        files[i].link = "/servlet/servlet.FileDownload?file=" + files[i].Id;
                    }
                }
                if (fileType == 'Questionnaire File') {
                    component.set('v.quesFileList', response.getReturnValue());
                }
                else if (fileType == 'Questionnaire Word File') {
                    component.set('v.quesDocFileList', response.getReturnValue());
                }
                    else if (fileType == 'Questionnaire Tank Registeration File') {
                        component.set('v.quesTankRegFileList', response.getReturnValue());
                    }
                        else if(fileType == 'prodFile'){
                            component.set('v.prodFileList', response.getReturnValue());
                        }
                component.set('v.spinner', false);
            }
        });
        $A.enqueueAction(action);
    },
    switchToOfflineQues: function (component) {
        var action = component.get('c.deleteAndSwitchQuestionnaire');
        action.setParams({
            quesId: component.get('v.mainQuestionnaire').Id
        });
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                //component.set('v.psaId', component.get('v.mainQuestionnaire').Id);
                this.fetchQuestionnaires(component);
                //component.set('v.spinner', false);
                var parent = component.get('v.parent');
                parent.openToast('utility:success','JS_26', 'success');   
                component.set('v.showCmp', false);
                component.set('v.showCmp', true);
                setTimeout(function () {
                    // window.location.reload();
                }, 3000);
            }
        });
        $A.enqueueAction(action);
    },
    
    updateSapRecord : function(component){
        var action = component.get('c.saveSapOnboarding');
        action.setParams({
            sapRecord : component.get('v.sapRecord')
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                var parent = component.get('v.parent');
                parent.openToast('utility:success','JS_17', 'success');  
                window.setTimeout(
                    $A.getCallback(function() {
                        var parent  = component.get('v.parent');
                        parent.getSapRecord();
                    }), 
                    3000
                );
                component.set('v.spinner', false);
            }
        });
        $A.enqueueAction(action);
    }   
    
})