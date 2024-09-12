@isTest
public class NewAccountSalesOrg_Test
{
    static testmethod void testGetOrgName()
    {
        Sales_Organization__c testSalesOrg = new Sales_Organization__c(
               Active__c = true,
               Datasource__c = 'S4',
               Name = 'Test SalesOrg',
               Sales_Organization_Code__c = 'test99' 
        );
        insert testSalesOrg;
        
        NewAccountSalesOrg.getOrgName(testSalesOrg.Id);
    }
}