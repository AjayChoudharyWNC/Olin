@isTest
public class PicklistDependencyUtilityTest {
    
    @isTest
    private static void testGetFieldDependenciesValuesMethod() {
        
        Test.startTest();
            Map<String, List<String>> mapOfCountryAndStateCodes = 
                PicklistDependencyUtility.getFieldDependencies('Account', 'BillingCountryCode', 'BillingStateCode', false);
        Test.stopTest();
        
        System.debug(mapOfCountryAndStateCodes);
        
    }

    @isTest
    private static void testGetFieldDependenciesLabelsMethod() {
        Test.startTest();
            Map<String, List<String>> mapOfCountryAndState = 
                PicklistDependencyUtility.getFieldDependencies('Account', 'BillingCountryCode', 'BillingStateCode', true);
        Test.stopTest();

        System.debug(mapOfCountryAndState);
    }

}