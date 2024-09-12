public class OnboardHeaderController {
    public Boolean hasLogout {get; set;}
    public boolean displayPopUp{get;set;}
    public OnboardHeaderController(){
        //Change made by Ajay Choudhary on line 6 only
        if(ApexPages.currentPage().getUrl().containsIgnoreCase('onboardlogin')){
            hasLogout = false;
        }
        else{
            hasLogout = true;
        }
    }
    
    public void ShowPopup() { 
        displayPopUp = true;
      
    }
        public void ClosePopUp() {       
        displayPopUp = false;  
    }
    public PageReference validateCookies() {
        /*Cookie cook = ApexPages.currentPage().getCookies().get('cook');
        PageReference pr = Page.OnBoardLogin;
        if(cook != null && String.isNotBlank(cook.getValue())){
            String accCode = cook.getValue().split(':')[0];
            String email = cook.getValue().split(':')[1];
            if(String.isNotBlank(accCode) && String.isNotBlank(email)){
                if(email.contains('%40')){
                    email = email.replace('%40','@');
                }
                OnboardingUserAccess__c mc = OnboardingUserAccess__c.getValues(email);
                if((mc != null && accCode != mc.Access_Code__c) || mc == null){
                    return pr.setRedirect(true);
                }
                else{
                    return null;
                }
            }
            else{
                return pr.setRedirect(true);
            }
        }
        else{
            return pr.setRedirect(true);
        }*/
        return null;
    }
}