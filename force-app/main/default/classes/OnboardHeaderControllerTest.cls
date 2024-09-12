@isTest
public class OnboardHeaderControllerTest {
    
    static testMethod void test(){
        PageReference pref = Page.OnboardLogin;
        Test.setCurrentPage(pref);
        OnboardHeaderController header = new OnboardHeaderController();
        header.ClosePopUp();
        header.ShowPopup();
        header.validateCookies();
    }

}