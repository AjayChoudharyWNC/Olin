@isTest
public class sendEmailNotificationQueueableTest {

    @testSetup
    static void setupTestData() {
        // Create internal account
        Account acc = new Account(Name = 'FastChem Cooperation', RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Olin Corp').getRecordTypeId());
        insert acc;
        
        AccountName__c acctName = new AccountName__c();
        acctName.Name = 'FastChem Corp';
        acctName.OlinAccountValue__c = acc.id;
        insert acctName;

         // Create Account
        List<Account> accList = new List<Account>();
        Account soldToAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Parent').getRecordTypeId(),
            Name = 'Sold To Account',
            AccountNumber_R1__c = '267687',
            Ship_To__c = true,
            Sold_To__c = true
        );
        insert soldToAccount;
        // accList.add(soldToAccount);
        
        Account shipToAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId(),
            Name = 'First Ship To Account',
            AccountNumber_R1__c = '267623',
            Ship_To__c = true,
            ParentId = soldToAccount.Id
        );
        insert shipToAccount;
        // accList.add(shipToAccount);
        // insert accList;

        //Create Product
        Product2 testProduct = new Product2(
            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
            Name = 'Test Product',
            TradeProduct_R1__c = '123456',
            Product_Level__c = 'GMID'
        );

        // Create Opportunity
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity testOpportunity = new Opportunity(
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Epoxy Commercial').getRecordTypeId(),
            Name = 'Test Opportunity',
            AccountId = soldToAccount.Id,
            CloseDate = date.newInstance(2019, 12, 31),
            StageName = 'Discovery/Qualification',
            CurrencyIsoCode = 'USD',
            Contract_Start_Date__c = date.newInstance(2019, 03, 01),
            Contract_End_Date__c = date.newInstance(2019, 12, 31)
        );
        //oppList.add(testOpportunity);
        insert testOpportunity;
        
        // Create Quote
        // List<SBQQ__Quote__c> qList = new List<SBQQ__Quote__c>();
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c(
            RecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Draft Price Request').getRecordTypeId(),
            SBQQ__Primary__c = true,
            Price_Start_Date__c = date.newInstance(2019, 03, 01),
            SBQQ__Opportunity2__c = testOpportunity.Id,
            Ship_To_Any__c= true,
            SBQQ__Account__c = soldToAccount.Id
        );
        insert testQuote;
        // qList.add(testQuote);
        // insert qList;
        
        
        // SBQQ__QuoteLine__c testQuoteLine= new SBQQ__QuoteLine__c(
        //     SBQQ__Quote__c = testQuote.Id,
        //     SBQQ__Product__c = testProduct.Id,
        //     SBQQ__Quantity__c = 1,
        //     SBQQ__ListPrice__c = 10,
        //     SBQQ__NetPrice__c = 10,
        //     SBQQ__Number__c = 1,
        //     SBQQ__SubscriptionPricing__c = 'Fixed Price',
        //     Price_Start_Date__c = date.newInstance(2019, 12, 31),
        //     Ship_To__c = shipToAccount.Id,
        //     Price_Request_Account__c = shipToAccount.Id,
        //     // Ship_To_Account__c = testAccountRel.Id,
        //     SBQQ__Bundle__c = true
        // );
        // insert testQuoteLine;

        // Create a test record for Mulesoft_ContractEndpoint__c
        Mulesoft_ContractEndpoint__c mc = new Mulesoft_ContractEndpoint__c();
        mc.Sent_to_SAP_Email_Template__c = 'Rejection_Salesforce_Admin_Template';
        mc.Enabled__c = true;
        insert mc;
    }

    static testMethod void testExecute() {
        Mulesoft_ContractEndpoint__c mc = [
            SELECT Id, Sent_to_SAP_Email_Template__c, Enabled__c
            FROM Mulesoft_ContractEndpoint__c
            LIMIT 1
        ];
        SBQQ__Quote__c testQuote = [
            SELECT Id, SBQQ__Opportunity2__c, SBQQ__Account__c
            FROM SBQQ__Quote__c
            LIMIT 1
        ];
        // Instantiate the Queueable class
        sendEmailNotificationQueueable queueable = new sendEmailNotificationQueueable(
            testQuote.Id, 
            mc
        );

        // Start the Queueable job
        Test.startTest();
        System.enqueueJob(queueable);
        Test.stopTest();

        // Verify the execution of the Queueable job
        // You can add assertions here to ensure that the expected email was sent successfully.
    }
}