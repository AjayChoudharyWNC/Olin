@isTest
public class SimplusFormulasTest {

    @testsetup
    public static void setupData() {

        // Create Formula
        List<Formula__c> lstTestFormula = new List<Formula__c>();
        Formula__c testFormula = new Formula__c(
            Name = 'Test Add and Multi Formula',
            Active__c = true,
            Formula__c = '(10000 + 65) * 0.375',
            Implementation__c = '{"implementations":[{"result":null,"placeholder":"#1#","formulaName":"PercentOf","formulaAttributes":["#0#"," 117"],"definition":{"value":"({0}/100)*{1}","name":"PercentOf","formulaStructure":"PercentOf(Amount, Percent)","description":"","attributes":[{"value":null,"type":"Double","position":0,"picklistValues":null,"picklist":null,"name":"Amount","isOutput":false,"description":"Amount"},{"value":null,"type":"Double","position":1,"picklistValues":null,"picklist":null,"name":"Percent","isOutput":false,"description":"Percent Of"}]}},{"result":null,"placeholder":"#1#","formulaName":"PercentOf","formulaAttributes":["#0#"," 117"],"definition":{"value":"({0}/100)*{1}","name":"PercentOf","formulaStructure":"PercentOf(Amount, Percent)","description":"","attributes":[{"value":null,"type":"Double","position":0,"picklistValues":null,"picklist":null,"name":"Amount","isOutput":false,"description":"Amount"},{"value":null,"type":"Double","position":1,"picklistValues":null,"picklist":null,"name":"Percent","isOutput":false,"description":"Percent Of"}]}}],"formulaOut":"#1#"}'
        );
        lstTestFormula.add(testFormula);

        testFormula = new Formula__c(
            Name = 'Test Min and Div Formula',
            Active__c = true,
            Formula__c = '(10000 - 65) / 0.375',
            Implementation__c = '{"implementations":[{"result":null,"placeholder":"#1#","formulaName":"PercentOf","formulaAttributes":["#0#"," 117"],"definition":{"value":"({0}/100)*{1}","name":"PercentOf","formulaStructure":"PercentOf(Amount, Percent)","description":"","attributes":[{"value":null,"type":"Double","position":0,"picklistValues":null,"picklist":null,"name":"Amount","isOutput":false,"description":"Amount"},{"value":null,"type":"Double","position":1,"picklistValues":null,"picklist":null,"name":"Percent","isOutput":false,"description":"Percent Of"}]}},{"result":null,"placeholder":"#1#","formulaName":"PercentOf","formulaAttributes":["#0#"," 117"],"definition":{"value":"({0}/100)*{1}","name":"PercentOf","formulaStructure":"PercentOf(Amount, Percent)","description":"","attributes":[{"value":null,"type":"Double","position":0,"picklistValues":null,"picklist":null,"name":"Amount","isOutput":false,"description":"Amount"},{"value":null,"type":"Double","position":1,"picklistValues":null,"picklist":null,"name":"Percent","isOutput":false,"description":"Percent Of"}]}}],"formulaOut":"#1#"}'
        );
        lstTestFormula.add(testFormula);

        testFormula = new Formula__c(
            Name = 'Test Formula',
            Active__c = true,
            Formula__c = 'PercentOf(5000, 10)',
            Implementation__c = '{"implementations":[{"result":null,"placeholder":"#0#","formulaName":"PercentOf","formulaAttributes":["5000"," 10"],"definition":{"value":"({0}/100)*{1}","utilityType":null,"type":"Formula","name":"PercentOf","formulaStructure":"PercentOf(Amount, Percent)","description":"Get a percent of a value","dateType":null,"attributes":[{"value":null,"type":"Double","position":0,"picklistValues":null,"picklist":null,"name":"Amount","isOutput":false,"description":"Amount"},{"value":null,"type":"Double","position":1,"picklistValues":null,"picklist":null,"name":"Percent","isOutput":false,"description":"Percent Of"}]}}],"formulaOut":"#0#"}'
        );
        lstTestFormula.add(testFormula);
        
        testFormula = new Formula__c(
            Name = 'Test Date',
            Active__c = true,
            Formula__c = 'Calc_Day(2019-01-01, 10)',
            Implementation__c = '{"implementations":[{"result":null,"placeholder":"#0#","formulaName":"Calc_Day","formulaAttributes":["2019-01-01"," 10"],"definition":{"value":null,"utilityType":null,"type":"Date","name":"Calc_Day","formulaStructure":"Calc_Day(Date, Number)","description":null,"dateType":"Day","attributes":[{"value":null,"type":"Date","position":0,"picklistValues":null,"picklist":null,"name":"Date","isOutput":false,"description":null},{"value":null,"type":"Integer","position":1,"picklistValues":null,"picklist":null,"name":"Number","isOutput":false,"description":null}]}}],"formulaOut":"#0#"}'
        );
        lstTestFormula.add(testFormula);

        testFormula = new Formula__c(
            Name = 'Test Date Month',
            Active__c = true,
            Formula__c = 'Calc_Month(2019-01-01, 05)',
            Implementation__c = '{"implementations":[{"result":null,"placeholder":"#0#","formulaName":"Calc_Month","formulaAttributes":["2019-01-01"," 05"],"definition":{"value":null,"utilityType":null,"type":"Date","name":"Calc_Month","formulaStructure":"Calc_Month(Date, Number)","description":null,"dateType":"Month","attributes":[{"value":null,"type":"Date","position":0,"picklistValues":null,"picklist":null,"name":"Date","isOutput":false,"description":"Date to use to calculate"},{"value":null,"type":"Integer","position":1,"picklistValues":null,"picklist":null,"name":"Number","isOutput":false,"description":"Number to alter the date by"}]}}],"formulaOut":"#0#"}'
        );
        lstTestFormula.add(testFormula);

        testFormula = new Formula__c(
            Name = 'Test Date Year',
            Active__c = true,
            Formula__c = 'Calc_Year(2019-01-01, 02)',
            Implementation__c = '{"implementations":[{"result":null,"placeholder":"#0#","formulaName":"Calc_Year","formulaAttributes":["2019-01-01"," 02"],"definition":{"value":null,"utilityType":null,"type":"Date","name":"Calc_Year","formulaStructure":"Calc_Year(Date, Number)","description":null,"dateType":"Year","attributes":[{"value":null,"type":"Date","position":0,"picklistValues":null,"picklist":null,"name":"Date","isOutput":false,"description":null},{"value":null,"type":"Integer","position":1,"picklistValues":null,"picklist":null,"name":"Number","isOutput":false,"description":null}]}}],"formulaOut":"#0#"}'
        );
        lstTestFormula.add(testFormula);

        testFormula = new Formula__c(
            Name = 'Test Query and Utility Type',
            Active__c = true,
            Formula__c = 'QL_PPVol(Matt_Crazy_Testing())',
            Implementation__c = '{"implementations":[{"result":null,"placeholder":"#0#","formulaName":"Matt_Crazy_Testing","formulaAttributes":[""],"definition":{"value":null,"utilityType":"Get Id","type":"Utility","name":"Matt_Crazy_Testing","formulaStructure":"Matt_Crazy_Testing()","description":"Dont worry this is just me doing crazy things.","dateType":null,"attributes":[]}},{"result":null,"placeholder":"#1#","formulaName":"QL_PPVol","formulaAttributes":["#0#"],"definition":{"value":"SBQQ__QuoteLine__c","utilityType":null,"type":"Query","name":"QL_PPVol","formulaStructure":"QL_PPVol(Quote Line Id, Price Period Volume)","description":"Price Period Volume from Quote Line","dateType":null,"attributes":[{"value":"Id","type":"String","position":0,"picklistValues":null,"picklist":null,"name":"Quote Line Id","isOutput":false,"description":"Name of the Quote Line"},{"value":"SBQQ__Quantity__c","type":"Number","position":1,"picklistValues":null,"picklist":null,"name":"Price Period Volume","isOutput":true,"description":"Price Period Volume price for Quote Line"}]}}],"formulaOut":"#1#"}'
        );
        lstTestFormula.add(testFormula);
        
        testFormula = new Formula__c(
            Name = 'Test Query and Utility Type Start Date',
            Active__c = true,
            Formula__c = '((GetIndex(ICIS, Monthly, MEK TANK USD, Calc_Month(QL_Date(), -4), Avg) + GetIndex(ICIS, Monthly, MEK TANK USD, Calc_Month(QL_Date(), -5), Avg)) + GetIndex(ICIS, Monthly, MEK TANK USD, Calc_Month(QL_Date(), -6), Avg)) / 3',
            Implementation__c = '{"implementations":[{"result":null,"placeholder":"#0#","formulaName":"QL_Date","formulaAttributes":[""],"definition":{"value":null,"utilityType":"Get Start Date","type":"Utility","name":"QL_Date","formulaStructure":"QL_Date()","description":"Get the Start Date from the Quote Line","dateType":null,"attributes":[]}},{"result":null,"placeholder":"#1#","formulaName":"Calc_Month","formulaAttributes":["#0#"," -4"],"definition":{"value":null,"utilityType":null,"type":"Date","name":"Calc_Month","formulaStructure":"Calc_Month(Date, Number)","description":null,"dateType":"Month","attributes":[{"value":null,"type":"Date","position":0,"picklistValues":null,"picklist":null,"name":"Date","isOutput":false,"description":"Date to use to calculate"},{"value":null,"type":"Integer","position":1,"picklistValues":null,"picklist":null,"name":"Number","isOutput":false,"description":"Number to alter the date by"}]}},{"result":null,"placeholder":"#2#","formulaName":"GetIndex","formulaAttributes":["ICIS"," Monthly"," MEK TANK USD"," #1#"," Avg"],"definition":{"value":"Commodity_Index__c","utilityType":null,"type":"Query","name":"GetIndex","formulaStructure":"GetIndex(Commodity, Frequency, Name, Start Date, Target Value)","description":"Get index for commodity","dateType":null,"attributes":[{"value":"Commodity_Index__c","type":"String","position":0,"picklistValues":null,"picklist":null,"name":"Commodity","isOutput":false,"description":"Commodity name"},{"value":"Frequency__c","type":"String","position":1,"picklistValues":null,"picklist":null,"name":"Frequency","isOutput":false,"description":"Commodity Year"},{"value":"Name","type":"String","position":2,"picklistValues":null,"picklist":null,"name":"Name","isOutput":false,"description":"Name of the Commodity Index"},{"value":"Start_Date__c","type":"Date","position":3,"picklistValues":null,"picklist":null,"name":"Start Date","isOutput":false,"description":"Target date for Index"},{"value":"","type":"Picklist","position":4,"picklistValues":["High","Low","Avg"],"picklist":{"High":"High__c","Low":"Low__c","Avg":"Average__c"},"name":"Target Value","isOutput":true,"description":"Value to get: High|Low|Avg"}]}},{"result":null,"placeholder":"#3#","formulaName":"QL_Date","formulaAttributes":[""],"definition":{"value":null,"utilityType":"Get Start Date","type":"Utility","name":"QL_Date","formulaStructure":"QL_Date()","description":"Get the Start Date from the Quote Line","dateType":null,"attributes":[]}},{"result":null,"placeholder":"#4#","formulaName":"Calc_Month","formulaAttributes":["#3#"," -5"],"definition":{"value":null,"utilityType":null,"type":"Date","name":"Calc_Month","formulaStructure":"Calc_Month(Date, Number)","description":null,"dateType":"Month","attributes":[{"value":null,"type":"Date","position":0,"picklistValues":null,"picklist":null,"name":"Date","isOutput":false,"description":"Date to use to calculate"},{"value":null,"type":"Integer","position":1,"picklistValues":null,"picklist":null,"name":"Number","isOutput":false,"description":"Number to alter the date by"}]}},{"result":null,"placeholder":"#5#","formulaName":"GetIndex","formulaAttributes":["ICIS"," Monthly"," MEK TANK USD"," #4#"," Avg"],"definition":{"value":"Commodity_Index__c","utilityType":null,"type":"Query","name":"GetIndex","formulaStructure":"GetIndex(Commodity, Frequency, Name, Start Date, Target Value)","description":"Get index for commodity","dateType":null,"attributes":[{"value":"Commodity_Index__c","type":"String","position":0,"picklistValues":null,"picklist":null,"name":"Commodity","isOutput":false,"description":"Commodity name"},{"value":"Frequency__c","type":"String","position":1,"picklistValues":null,"picklist":null,"name":"Frequency","isOutput":false,"description":"Commodity Year"},{"value":"Name","type":"String","position":2,"picklistValues":null,"picklist":null,"name":"Name","isOutput":false,"description":"Name of the Commodity Index"},{"value":"Start_Date__c","type":"Date","position":3,"picklistValues":null,"picklist":null,"name":"Start Date","isOutput":false,"description":"Target date for Index"},{"value":"","type":"Picklist","position":4,"picklistValues":["High","Low","Avg"],"picklist":{"High":"High__c","Low":"Low__c","Avg":"Average__c"},"name":"Target Value","isOutput":true,"description":"Value to get: High|Low|Avg"}]}},{"result":null,"placeholder":"#6#","formulaName":"QL_Date","formulaAttributes":[""],"definition":{"value":null,"utilityType":"Get Start Date","type":"Utility","name":"QL_Date","formulaStructure":"QL_Date()","description":"Get the Start Date from the Quote Line","dateType":null,"attributes":[]}},{"result":null,"placeholder":"#7#","formulaName":"Calc_Month","formulaAttributes":["#6#"," -6"],"definition":{"value":null,"utilityType":null,"type":"Date","name":"Calc_Month","formulaStructure":"Calc_Month(Date, Number)","description":null,"dateType":"Month","attributes":[{"value":null,"type":"Date","position":0,"picklistValues":null,"picklist":null,"name":"Date","isOutput":false,"description":"Date to use to calculate"},{"value":null,"type":"Integer","position":1,"picklistValues":null,"picklist":null,"name":"Number","isOutput":false,"description":"Number to alter the date by"}]}},{"result":null,"placeholder":"#8#","formulaName":"GetIndex","formulaAttributes":["ICIS"," Monthly"," MEK TANK USD"," #7#"," Avg"],"definition":{"value":"Commodity_Index__c","utilityType":null,"type":"Query","name":"GetIndex","formulaStructure":"GetIndex(Commodity, Frequency, Name, Start Date, Target Value)","description":"Get index for commodity","dateType":null,"attributes":[{"value":"Commodity_Index__c","type":"String","position":0,"picklistValues":null,"picklist":null,"name":"Commodity","isOutput":false,"description":"Commodity name"},{"value":"Frequency__c","type":"String","position":1,"picklistValues":null,"picklist":null,"name":"Frequency","isOutput":false,"description":"Commodity Year"},{"value":"Name","type":"String","position":2,"picklistValues":null,"picklist":null,"name":"Name","isOutput":false,"description":"Name of the Commodity Index"},{"value":"Start_Date__c","type":"Date","position":3,"picklistValues":null,"picklist":null,"name":"Start Date","isOutput":false,"description":"Target date for Index"},{"value":"","type":"Picklist","position":4,"picklistValues":["High","Low","Avg"],"picklist":{"High":"High__c","Low":"Low__c","Avg":"Average__c"},"name":"Target Value","isOutput":true,"description":"Value to get: High|Low|Avg"}]}}],"formulaOut":"((#2# + #5#) + #8#) / 3"}'
        );
        lstTestFormula.add(testFormula);
        insert lstTestFormula;

        // Create Formula Definition
        List<FormulaDefinition__c> fd = new List<FormulaDefinition__c> {
            new FormulaDefinition__c(
                Name = 'add',
                API_Name__c = '({0} + {1})',
                Type__c = 'Formula',
                Date_Type__c = null,
                Description__c = 'Test Formula',
                Active__c = true
            ),
            new FormulaDefinition__c(
                Name = 'min',
                API_Name__c = '({0} - {1})',
                Type__c = 'Formula',
                Date_Type__c = null,
                Description__c = 'Test Formula',
                Active__c = true
            ),
            new FormulaDefinition__c(
                Name = 'mul',
                API_Name__c = '({0} * {1})',
                Type__c = 'Formula',
                Date_Type__c = null,
                Description__c = 'Test Formula',
                Active__c = true
            ),
            new FormulaDefinition__c(
                Name = 'div',
                API_Name__c = '({0} / {1})',
                Type__c = 'Formula',
                Date_Type__c = null,
                Description__c = 'Test Formula',
                Active__c = true
            ),
            new FormulaDefinition__c(
                Name = 'PercentOf',
                API_Name__c = '({0}/100)*{1}',
                Type__c = 'Formula',
                Date_Type__c = null,
                Description__c = 'Get a percent of a value',
                Active__c = true
            ),
            new FormulaDefinition__c(
                Name = 'Calc_Day',
                API_Name__c = '',
                Type__c = 'Date',
                Date_Type__c = 'Day',
                Description__c = 'Test Formula',
                Active__c = true
            ),
            new FormulaDefinition__c(
                Name = 'Calc_Month',
                API_Name__c = '',
                Type__c = 'Date',
                Date_Type__c = 'Month',
                Description__c = 'Test Formula',
                Active__c = true
            ),
            new FormulaDefinition__c(
                Name = 'Calc_Year',
                API_Name__c = '',
                Type__c = 'Date',
                Date_Type__c = 'Year',
                Description__c = 'Test Formula',
                Active__c = true
            ),
            new FormulaDefinition__c(
                Name = 'QL_PPVol',
                API_Name__c = 'SBQQ__QuoteLine__c',
                Type__c = 'Query',
                Date_Type__c = null,
                Description__c = 'Price Period Volume from Quote  Line',
                Active__c = true
            ),
            new FormulaDefinition__c(
                Name = 'GetIndex',
                API_Name__c = 'Commodity_Index__c',
                Type__c = 'Query',
                Date_Type__c = null,
                Description__c = 'Get Index for commodity',
                Active__c = true
            ),
            new FormulaDefinition__c(
                Name = 'QL_Date',
                API_Name__c = '',
                Type__c = 'Utility',
                Date_Type__c = null,
                Description__c = 'Get the Start Date from the Quote Line',
                Active__c = true,
                Utility_Type__c = 'Get Start Date'
            )
        };
        insert fd;
        
        // Create Formula Attribute
        List<FormulaAttribute__c> faList = new List<FormulaAttribute__c>();
        for(FormulaDefinition__c fdItm : fd) {
            faList.add(new FormulaAttribute__c(
                Name = 'add_1',
                FormulaDefinition__c = fdItm.Id,
                Description__c = 'number 1',
                Position__c = 0,
                Output__c = false,
                Type__c = 'Double'
            ));
            faList.add(new FormulaAttribute__c(
                Name = 'add_2',
                FormulaDefinition__c = fdItm.Id,
                Description__c = 'number 2',
                Position__c = 1,
                Output__c = false,
                Type__c = 'Double'
            ));
        }
        insert faList;
        
        FormulaDefinition__c fdComplex = new FormulaDefinition__c(
            Name = 'getName',
            API_Name__c = 'Account',
            Type__c = 'Query',
            Date_Type__c = null,
            Description__c = 'test',
            Active__c = true,
            Utility_Type__c = null
        );
        insert fdComplex;

        insert new List<FormulaAttribute__c> {
            new FormulaAttribute__c(
                Name = 'Id',
                FormulaDefinition__c = fdComplex.Id,
                Position__c = 0,
                Output__c = false,
                Value__c = 'Id',
                Type__c = 'String'
            ),
            new FormulaAttribute__c(
                Name = 'NumberOfEmployees',
                FormulaDefinition__c = fdComplex.Id,
                Position__c = 1,
                Output__c = false,
                Value__c = 'NumberOfEmployees',
                Type__c = 'Integer'
            ),
            new FormulaAttribute__c(
                Name = 'Date',
                FormulaDefinition__c = fdComplex.Id,
                Position__c = 2,
                Output__c = false,
                Value__c = '',
                Type__c = 'Date'
            ),
            new FormulaAttribute__c(
                Name = 'Picklist',
                FormulaDefinition__c = fdComplex.Id,
                Position__c = 3,
                Output__c = true,
                Value__c = '',
                Type__c = 'Picklist',
                Picklist_Values__c = '{"High": "High__c", "Low": "Low__c", "Avg": "Avg__c"}'
            )
        };
        insert new Account(
            Name='TestAcct', 
            NumberOfEmployees=100,
            AccountNumber_R1__c = '123',
            AccountSource = 'Olin Heritage'
        );

        // Create Account
        Account testAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Competitor').getRecordTypeId(),
            Name = 'Test Account',
            AccountNumber_R1__c = '102110',
            AccountSource = 'Olin Heritage'
        );
        insert testAccount;

        // Create Product
        Product2 testProduct = new Product2(
            RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Standard').getRecordTypeId(),
            Name = 'Test Product',
            ProductCode = '105001'
        );
        insert testProduct;
        /***
        // Standard PriceBook
        Id pricebookId = Test.getStandardPricebookId();
        
        // Create PricebookEntry
        PricebookEntry testPriceBook = new PricebookEntry( 
            Pricebook2Id = pricebookId,
            Product2Id = testProduct.id,
            CurrencyIsoCode = 'USD',
            IsActive = TRUE,
            UnitPrice = 100.0,
            UseStandardPrice = FALSE
        );
        insert testPriceBook;
        ***/
        Id pricebookId = Test.getStandardPricebookId();
        PricebookEntry testPriceBookEntry;
        system.debug('Test Pricebook: ' + pricebookId);
      
        list<PricebookEntry> priceBookTestUS = [select id from PricebookEntry where Product2Id = :testProduct.Id and Pricebook2Id = :pricebookId and CurrencyIsoCode = 'USD'];
        if(priceBookTestUS.size() == 1){
            testPriceBookEntry = priceBookTestUS[0];
        }
        else
        {
            // Create PricebookEntry
            testPriceBookEntry = new PricebookEntry( 
                Pricebook2Id = pricebookId,
                Product2Id = testProduct.id,
                CurrencyIsoCode = 'USD',
                IsActive = TRUE,
                UnitPrice = 100.0,
                UseStandardPrice = FALSE
            );
            insert testPriceBookEntry;
        }
        system.debug('Test Pricebook Entry: ' + testPriceBookEntry);
        
        
        // Create Opportunity 
        Opportunity testOpportunity = new Opportunity(
            RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('CAPV Commercial').getRecordTypeId(),
            Name = 'Test Opportunity',
            CloseDate = date.newInstance(2019, 03, 01),
            StageName = 'Proposal',
            CurrencyIsoCode = 'USD',
            AccountId = testAccount.Id
        );
        insert testOpportunity;

        // Create Quote
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c(
            RecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Draft Price Request').getRecordTypeId(),
            SBQQ__Primary__c = true,
            Price_Start_Date__c = date.newInstance(2019, 03, 01),
            SBQQ__Opportunity2__c = testOpportunity.Id,
            Ship_To_Any__c= true
        );
        insert testQuote;

        // Create Quote Lines
        SBQQ__QuoteLine__c testQuoteLine = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = testQuote.Id,
            Formula_Name__c = testFormula.Id,
            SBQQ__Product__c = testProduct.Id,
            SBQQ__Quantity__c = 1,
            SBQQ__ListPrice__c = 10,
            SBQQ__NetPrice__c = 10,
            SBQQ__Number__c = 1,
            SBQQ__SubscriptionPricing__c = 'Fixed Price',
            Price_Start_Date__c = date.newInstance(2019, 12, 31)
        );
        insert testQuoteLine;

    }

    public testmethod static void testPicklistFormula() {
        String definedFormulas = SimplusFormulaController.Initialize();
        Account acct = [SELECT Id, NumberOfEmployees FROM Account LIMIT 1];
        String formulaFinal = 'getName(' + acct.Id + ')';
        List<Formula__c> lstFormula = [SELECT Id, Formula__c, Implementation__c FROM Formula__c];
        
        Test.startTest();
        //String implementation = SimplusFormulaController.Validate(definedFormulas, formulaFinal).implementation;
        SimplusFormulaController.Process(lstFormula[0].Implementation__c, lstFormula[0].Id);
        Test.stopTest();
    }
    
    public testmethod static void testValidate() {
        List<Formula__c> lstFormula = [SELECT Id, Formula__c, Implementation__c FROM Formula__c];
        List<FormulaDefinition__c> lstFormulaDefinition = [SELECT Id, Name, Description__c, Type__c, Date_Type__c, API_Name__c FROM FormulaDefinition__c WHERE Name != 'Name'];
        List<FormulaAttribute__c> lstFormulaAttribute = [SELECT Id, Name, Description__c, Type__c, Picklist_Values__c, Position__c, Value__c, Output__c, Encoded__c FROM FormulaAttribute__c];
        String picklistValues = '{"High": "High__c", "Low": "Low__c", "Avg": "Avg__c"}';
        List<SimplusFormulaController.FormulaAttribute> formulaAttributes = new List<SimplusFormulaController.FormulaAttribute>();
        for(FormulaAttribute__c formulaAttributeRec : lstFormulaAttribute) {
            SimplusFormulaController.FormulaAttribute attr = new SimplusFormulaController.FormulaAttribute(formulaAttributeRec.Name, formulaAttributeRec.Description__c, formulaAttributeRec.Type__c, picklistValues, integer.valueOf(formulaAttributeRec.Position__c), formulaAttributeRec.Value__c, formulaAttributeRec.Output__c, formulaAttributeRec.Encoded__c);
            attr.Verify(formulaAttributeRec.Type__c);
            formulaAttributes.add(attr);
        }

        SimplusFormulaController.FormulaDefinitions formulaDef = new SimplusFormulaController.FormulaDefinitions();
        formulaDef.formulas = new List<SimplusFormulaController.FormulaDefinition>();
        for(FormulaDefinition__c formulaDefinitionRec : lstFormulaDefinition) {
            SimplusFormulaController.FormulaDefinition def = new SimplusFormulaController.FormulaDefinition(formulaDefinitionRec.Name, formulaDefinitionRec.Description__c, formulaDefinitionRec.Type__c, formulaDefinitionRec.Date_Type__c, '', formulaDefinitionRec.API_Name__c, '', formulaAttributes);
            def.GetOutput();
            formulaDef.formulas.add(def);
        }
        String formulas = JSON.serialize(formulaDef);
        
        Test.startTest();
        SimplusFormulaController.Validate(formulas, lstFormula[1].Formula__c);
        SimplusFormulaController.Validate(formulas, lstFormula[2].Formula__c);
        Test.stopTest();
    }

    public testmethod static void testFormula() {
        List<SBQQ__QuoteLine__c> lstQuoteLine = [SELECT Id FROM SBQQ__QuoteLine__c];
        List<Formula__c> lstFormula = [SELECT Id, Formula__c, Implementation__c FROM Formula__c];
        List<FormulaDefinition__c> lstFormulaDefinition = [SELECT Id, Name, Description__c, Type__c, Date_Type__c, API_Name__c FROM FormulaDefinition__c WHERE Name = 'PercentOf'];
        List<SimplusFormulaController.FormulaAttribute> formulaAttributes = new List<SimplusFormulaController.FormulaAttribute>();

        SimplusFormulaController.FormulaDefinitions formulaDef = new SimplusFormulaController.FormulaDefinitions();
        formulaDef.formulas = new List<SimplusFormulaController.FormulaDefinition>();
        for(FormulaDefinition__c formulaDefinitionRec : lstFormulaDefinition) {
            SimplusFormulaController.FormulaDefinition def = new SimplusFormulaController.FormulaDefinition(formulaDefinitionRec.Name, formulaDefinitionRec.Description__c, formulaDefinitionRec.Type__c, formulaDefinitionRec.Date_Type__c, '', formulaDefinitionRec.API_Name__c, '', formulaAttributes);
            formulaDef.formulas.add(def);
        }
        String formulas = JSON.serialize(formulaDef);

        Test.startTest();
        SimplusFormulaController.getFormulaRecord(lstFormula[0].Id);
        SimplusFormulaController.saveFormulaRecord(lstFormula[0].Id, lstFormula[0].Formula__c, lstFormula[0].Implementation__c);
        SimplusFormulaController.Process(lstFormula[2].Implementation__c, lstFormula[2].Id);
        SimplusFormulaController.processResult(lstQuoteLine[0].Id);
        Test.stopTest();
    }
    
    public testmethod static void testDay() {
        List<SBQQ__QuoteLine__c> lstQuoteLine = [SELECT Id FROM SBQQ__QuoteLine__c];
        List<Formula__c> lstFormula = [SELECT Id, Formula__c, Implementation__c FROM Formula__c WHERE Name = 'Test Date'];
        List<FormulaDefinition__c> lstFormulaDefinition = [SELECT Id, Name, Description__c, Type__c, Date_Type__c, API_Name__c FROM FormulaDefinition__c WHERE Name = 'Calc_Day'];
        List<SimplusFormulaController.FormulaAttribute> formulaAttributes = new List<SimplusFormulaController.FormulaAttribute>();

        SimplusFormulaController.FormulaDefinitions formulaDef = new SimplusFormulaController.FormulaDefinitions();
        formulaDef.formulas = new List<SimplusFormulaController.FormulaDefinition>();
        for(FormulaDefinition__c formulaDefinitionRec : lstFormulaDefinition) {
            SimplusFormulaController.FormulaDefinition def = new SimplusFormulaController.FormulaDefinition(formulaDefinitionRec.Name, formulaDefinitionRec.Description__c, formulaDefinitionRec.Type__c, formulaDefinitionRec.Date_Type__c, '', formulaDefinitionRec.API_Name__c, '', formulaAttributes);
            formulaDef.formulas.add(def);
        }
        String formulas = JSON.serialize(formulaDef);

        Test.startTest();
        SimplusFormulaController.getFormulaRecord(lstFormula[0].Id);
        SimplusFormulaController.saveFormulaRecord(lstFormula[0].Id, lstFormula[0].Formula__c, lstFormula[0].Implementation__c);
        try {
            SimplusFormulaController.Process(lstFormula[0].Implementation__c, lstFormula[0].Id);
        } catch(Exception ex) {
            system.debug('Error: ' + ex);
        }
        SimplusFormulaController.processResult(lstQuoteLine[0].Id);
        Test.stopTest();
    }

    public testmethod static void testMonth() {
        List<SBQQ__QuoteLine__c> lstQuoteLine = [SELECT Id FROM SBQQ__QuoteLine__c];
        List<Formula__c> lstFormula = [SELECT Id, Formula__c, Implementation__c FROM Formula__c WHERE Name = 'Test Date Month'];
        List<FormulaDefinition__c> lstFormulaDefinition = [SELECT Id, Name, Description__c, Type__c, Date_Type__c, API_Name__c FROM FormulaDefinition__c WHERE Name = 'Calc_Month'];
        List<SimplusFormulaController.FormulaAttribute> formulaAttributes = new List<SimplusFormulaController.FormulaAttribute>();

        SimplusFormulaController.FormulaDefinitions formulaDef = new SimplusFormulaController.FormulaDefinitions();
        formulaDef.formulas = new List<SimplusFormulaController.FormulaDefinition>();
        for(FormulaDefinition__c formulaDefinitionRec : lstFormulaDefinition) {
            SimplusFormulaController.FormulaDefinition def = new SimplusFormulaController.FormulaDefinition(formulaDefinitionRec.Name, formulaDefinitionRec.Description__c, formulaDefinitionRec.Type__c, formulaDefinitionRec.Date_Type__c, '', formulaDefinitionRec.API_Name__c, '', formulaAttributes);
            formulaDef.formulas.add(def);
        }
        String formulas = JSON.serialize(formulaDef);

        Test.startTest();
        SimplusFormulaController.getFormulaRecord(lstFormula[0].Id);
        SimplusFormulaController.saveFormulaRecord(lstFormula[0].Id, lstFormula[0].Formula__c, lstFormula[0].Implementation__c);
        try {
            SimplusFormulaController.Process(lstFormula[0].Implementation__c, lstFormula[0].Id);
        } catch(Exception ex) {
            system.debug('Error: ' + ex);
        }
        SimplusFormulaController.processResult(lstQuoteLine[0].Id);
        Test.stopTest();
    }

    public testmethod static void testYear() {
        List<SBQQ__QuoteLine__c> lstQuoteLine = [SELECT Id FROM SBQQ__QuoteLine__c];
        List<Formula__c> lstFormula = [SELECT Id, Formula__c, Implementation__c FROM Formula__c WHERE Name = 'Test Date year'];
        List<FormulaDefinition__c> lstFormulaDefinition = [SELECT Id, Name, Description__c, Type__c, Date_Type__c, API_Name__c FROM FormulaDefinition__c WHERE Name = 'Calc_Year'];
        List<SimplusFormulaController.FormulaAttribute> formulaAttributes = new List<SimplusFormulaController.FormulaAttribute>();
        
        SimplusFormulaController.FormulaDefinitions formulaDef = new SimplusFormulaController.FormulaDefinitions();
        formulaDef.formulas = new List<SimplusFormulaController.FormulaDefinition>();
        for(FormulaDefinition__c formulaDefinitionRec : lstFormulaDefinition) {
            SimplusFormulaController.FormulaDefinition def = new SimplusFormulaController.FormulaDefinition(formulaDefinitionRec.Name, formulaDefinitionRec.Description__c, formulaDefinitionRec.Type__c, formulaDefinitionRec.Date_Type__c, '', formulaDefinitionRec.API_Name__c, '', formulaAttributes);
            formulaDef.formulas.add(def);
        }
        String formulas = JSON.serialize(formulaDef);

        Test.startTest();
        SimplusFormulaController.getFormulaRecord(lstFormula[0].Id);
        SimplusFormulaController.saveFormulaRecord(lstFormula[0].Id, lstFormula[0].Formula__c, lstFormula[0].Implementation__c);
        try {
            SimplusFormulaController.Process(lstFormula[0].Implementation__c, lstFormula[0].Id);
        } catch(Exception ex) {
            system.debug('Error: ' + ex);
        }
        SimplusFormulaController.processResult(lstQuoteLine[0].Id);
        Test.stopTest();
    }
    

}