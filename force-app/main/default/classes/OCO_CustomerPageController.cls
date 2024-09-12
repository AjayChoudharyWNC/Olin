public class OCO_CustomerPageController {
    public static String appUserEmail{get;set;}
    public String appUserId;
    public Boolean hasLogout {get; set;}
    
    public PageReference init(){
        String response = validate();
        system.debug('resposne'+response);
        if(response == 'LoginError'){
            PageReference pr = new PageReference('/OCO_Logout');
            return pr.setRedirect(true);
        }
        return null;
    }
    public String validate(){
        Cookie cooEmail = ApexPages.currentPage().getCookies().get('cook');
        if(cooEmail != null){
            String acc = cooEmail.getValue().split(':')[0];
            String email = cooEmail.getValue().split(':')[1];
            return validateCookies(acc,email);
        }
        else{
            return 'LoginError';
        }
    }
    
    @RemoteAction
    public static String validateCookies(String accCode, String email) {
        if(String.isBlank(accCode) || String.isBlank(email)){
            return 'LoginError';
        }
        else{
            if(email.contains('%40')){
                email = email.replace('%40','@');
            }
            OnboardingUserAccess__c mc = OnboardingUserAccess__c.getValues(email.toLowerCase());
            if(mc != null){
                if(accCode != mc.Access_Code__c){
                    appUserEmail = '';
                    return 'LoginError';
                }
                else{
                    appUserEmail = email;
                    return 'success';
                }
            }
            else{
                appUserEmail = '';
                return 'LoginError';
            }
        }
        
    }
    
}