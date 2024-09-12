public with sharing class SimplusFormulaController {

    @AuraEnabled 
    public static Formula__c getFormulaRecord(String recId) {
        Formula__c f = new Formula__c();
        if(recId != null && recId != '') {
            try {
                f = [SELECT Id, Formula__c, Implementation__c FROM Formula__c WHERE Id = :recId LIMIT 1];
            } catch(Exception e) {

            }
        }
        return f;
    }
    
    @AuraEnabled 
    public static String saveFormulaRecord(String recId, String formula, String implem) {
        
        Formula__c f = new Formula__c();
        try {
            f.Id = recId;
            f.Formula__c = formula;
            f.Implementation__c = implem;
        update f;
        } catch(Exception e) {
            return e.getMessage();
        }
        return null;
    }

    @AuraEnabled
    public static String Initialize(){
        FormulaDefinitions definedFormulas = new FormulaDefinitions();
        for (FormulaDefinition def : definedFormulas.formulas) {
           def.attributes.sort();
        }
        System.debug('Initialized formulas: ' + JSON.serialize(definedFormulas));
        return JSON.serialize(definedFormulas);
    }

    @AuraEnabled
    public static ValidationResult Validate(String formulas, String formula){
        FormulaDefinitions definedFormulas = (FormulaDefinitions)JSON.deserialize(formulas, FormulaDefinitions.class);
        String formulaOut = formula;
        System.debug('formula: ' + formula);  
        //GetIndex(IHS, CHLORINE, 1/21/2019, High)
        FormulaImplWrapper implWrapper = new FormulaImplWrapper();
        Integer matchCount = 0;

        //TODO create a Map of Formula Definitions keyed off of the def.name
        //  search for all def names followed directly by () and can have () inside () without a name preceeding.
        //  if we find

        Map<String, FormulaDefinition> formulaMap = new Map<String, FormulaDefinition>();
        for (FormulaDefinition def : definedFormulas.formulas) {
            formulaMap.put(def.name, def);
        }

        List<String> fName = new List<String>(formulaMap.keySet());
        String formulaNames = '(' + String.join(fName,'|') + ')';
        //System.debug('All formula names: ' + formulaNames);


        //Match the method call in the formula we will be translating and querying
        String regexPattern = formulaNames + '\\(([^\\(]*?)\\)';
        //System.debug('Regex pattern: ' + regexPattern);
        pattern regexFormula = pattern.compile(regexPattern);
        matcher matchFormula = regexFormula.matcher(formulaOut);

        //For each match in the formula of this function, replace with a placeholder
        while (matchFormula.find() == true) {
            String regexPlaceholder = '#'+matchCount+'#';
            String formulaName = matchFormula.group(1);
            FormulaDefinition def = formulaMap.get(formulaName);
            String inx = matchFormula.group(2);
            System.debug('Matches: 1 - ' + formulaName + ', 2 - ' + inx);
            formulaOut = formulaOut.replacefirst(regexPattern, regexPlaceholder);
            
            //Store the matched information to use for a SOQL query and eventual replacement
            implWrapper.implementations.add(new FormulaImplementation(def, def.name, inx.split(','), regexPlaceholder));
            System.debug(def.name + ': ' + inx);

            //Increment the placeholder count for the next match
            matchCount++;
            matchFormula = regexFormula.matcher(formulaOut);
        }


        implWrapper.formulaOut = formulaOut;
        ValidationResult result = new ValidationResult();
        if (!implWrapper.implementations.isEmpty()) {
            result.implementation = JSON.serialize(implWrapper);
            result.formulaValidation = implWrapper.Validate();
        } else {
            result.implementation = JSON.serialize(implWrapper);
            result.formulaValidation = true;
        }

        //Step 1 replace all spaces
        String regexSpace = ' ';
        formulaOut = formulaOut.replaceAll(regexSpace, '');
        System.debug('No spaces: ' + formulaOut);

        try {
            //Step 2 check for groupings
            formulaOut = ValidateGroups(formulaOut);

            //Step 3 calculate the entire formula to confirm all operators are used correctly
            formulaOut = Calculate(formulaOut);
            
            result.mathematicValidation = true;
        } catch (Exception ex) {
            if(!test.isRunningTest()) {
                throw new AuraHandledException('Validation exception occurred: ' + ex.getMessage());
            }
        }

        System.debug('Formula Validated: ' + formulaOut);
        System.debug('Formula Validation: ' + result.formulaValidation);
        System.debug('Mathematic Validation: ' + result.mathematicValidation);
        System.debug('implementations: ' + result.implementation);
        System.debug('formulaOut: ' + implWrapper.formulaOut);

        return result;
    }

    @AuraEnabled
    public static String ValidateGroups(String grouping){
        /*
        The operations WE support
        1   () Grouping
        2   * / Multiplication and division
        3   + - Addition and subtraction
        */

        system.debug('Validate Group check: ' + grouping);

        //Replace placeholders with 1 just for calculation
        String regexPlaceholder = '#\\d+#';
        grouping = grouping.replaceAll(regexPlaceholder, '1');

        //Check from left to right, inner to outer for any () grouping.
        // replace those values within the () with the evaluation of those elements.
        String regexGroup = '\\(([^a-z^_^A-Z^\\(]*?)\\)';
        pattern groupPattern = pattern.compile(regexGroup);
        matcher matcherGroup = groupPattern.matcher(grouping);     
        while (matcherGroup.find() == true) {
            String grp = matcherGroup.group(1);
            System.debug('Found group: ' + grp);
            grouping = grouping.replacefirst(regexGroup, Calculate(grp));
            ValidateGroups(grouping);
            matcherGroup = groupPattern.matcher(grouping);
            //grouping = matcherGroup.replaceFirst(ValidateGroups(grp));
        }
        return grouping;
        
        //Return with replacement
    }

    @AuraEnabled
    public static String Calculate(String expression){
        /*        
        The operations WE support
        1   * / Multiplication and division
        2   + - Addition and subtraction
        */
        
        //TODO evaluate each formula into left and right sides, then pass those same sides into this function
        // to evaluate any more operators and process them.
        // To preserve order of operations maybe return left and right with a "remainder" that would be 
        // equivalent to what needs to be calculated in the previous statement...

        //TODO don't just evaluate them all in any order, implement an order of operation.
        String regexOperators = '([-]?[\\d\\.]+)([\\+\\-\\*\\/])([-]?[\\d\\.]+)';
        pattern operatorPattern = pattern.compile(regexOperators);
        matcher matcherOperator = operatorPattern.matcher(expression);
        if (matcherOperator.find() == true) {
            Integer matchedValues = matcherOperator.groupCount();
            //System.debug('Operator: ' + operator);
            //System.debug('Groups: ' + matcherOperator.group(1) + ' ' + matcherOperator.group(2) + ' ' + matcherOperator.group(3));
            //System.debug('Hit end? ' + matcherOperator.hitEnd());
            if (matchedValues == 3 && matcherOperator.hitEnd()) {
                String left = matcherOperator.group(1);
                String operator = matcherOperator.group(2);
                String right = matcherOperator.group(3);
                if (operator == '*') {
                    Double result = Double.valueOf(left) * Double.valueOf(right);
                    System.debug('Multiply: ' + expression + ' product: ' + result);
                    return String.valueOf(result);
                } else if (operator == '/') {
                    Double result = Double.valueOf(left) / Double.valueOf(right);
                    System.debug('Divide: ' + expression + ' product: ' + result);
                    return String.valueOf(result);
                } else if (operator == '+') {
                    Double result = Double.valueOf(left) + Double.valueOf(right);
                    System.debug('Add: ' + expression + ' product: ' + result);
                    return String.valueOf(result);
                } else if (operator == '-') {
                    Double result = Double.valueOf(left) - Double.valueOf(right);
                    System.debug('Subtract: ' + expression + ' product: ' + result);
                    return String.valueOf(result);
                }
            } else {
                throw new CalculationException('Equation error, too many operators: ' + expression);
            }
        } else {
            Double result = Double.valueOf(expression);
            return String.valueOf(result);
        }
        return expression;
    }

    public class CalculationException extends Exception {}

    @AuraEnabled
    public static void processResult(String recordId) {
        System.debug('Starting Process Result for record: ' + recordId);
        FormulaSettings setting = new FormulaSettings('Settings');   
        String query = 'SELECT Id, ' + setting.resultColumn + ', ' + setting.lookupColumn + ', ' + setting.lookupRelated + '.Implementation__c FROM ' + setting.connectedObject + ' WHERE Id =: recordId ';
        System.debug('Formula process query: ' + query);
        List<SObject> ss = Database.query(query);
        SObject ssObj = ss[0];
        System.debug('Query Results: ' + JSON.serialize(ss));
        String id = (String)ssObj.get('Id');
        SObject so = ssObj.getSObject(setting.lookupRelated);
        String implementation = (String)so.get('Implementation__c');
        if (implementation != null) {
            String process = Process(implementation, id);
            ssObj.put(setting.resultColumn, Double.valueof(process));
            update ssObj;
            system.debug('Result: ' + process);
        }
    }

    @AuraEnabled
    public static String Process(String implementation, String id){
        FormulaImplWrapper implWrapper = (FormulaImplWrapper)JSON.deserialize(implementation, FormulaImplWrapper.class);

        String beginFormula = implWrapper.formulaOut;
        String endFormula = beginFormula;

        System.debug('Formula: ' + beginFormula);
        implWrapper.implementations.sort();
        System.debug('Implementations saved sorted: ' + JSON.serialize(implWrapper.implementations));
        for (FormulaImplementation impl : implWrapper.implementations) {
            System.debug('Passed in Id: ' + id);
            Object implResult = impl.Run(implWrapper.implementations, id);
            System.debug('Run result: ' + implResult);
            String outputType = impl.definition.GetOutputType();
            System.debug('Output type: ' + outputType);
            Boolean outputEncoding = impl.definition.GetOutputEncoding();
            System.debug('Output encoding: ' + outputEncoding);
            impl.isEncoded = outputEncoding;
            impl.result = String.valueOf(implResult);

            //Match the method call in the formula we will be translating and querying
            String regexPattern = impl.placeholder;
            pattern regexFormula = pattern.compile(regexPattern);
            matcher matchFormula = regexFormula.matcher(beginFormula);

            //For each match in the formula of a placeholder, update with the database value
            if (matchFormula.find() == true && implResult != null) {
                endFormula = endFormula.replacefirst(regexPattern, String.valueOf(implResult));
            }
            System.debug('Formula after replace: ' + endFormula);
        }

        beginFormula = endFormula;

        //Step 1 replace all spaces
        String regexSpace = ' ';
        beginFormula = beginFormula.replaceAll(regexSpace, '');
        System.debug('No spaces: ' + beginFormula);

        try {
            //Step 2 check for groupings
            beginFormula = ValidateGroups(beginFormula);

            //Step 3 calculate the entire formula to confirm all operators are used correctly
            beginFormula = Calculate(beginFormula);
        } catch (Exception ex) {
            throw new AuraHandledException('Validation exception occurred: ' + ex.getMessage());
        }

        System.debug('Interpreted formula: ' + beginFormula);

        //string toEval = '(1 + 2)';
        //system.debug('test Integer '+ Integer.valueOf(toEval));

        return beginFormula;
    }

    public class ValidationResult {
        @AuraEnabled public Boolean formulaValidation;
        @AuraEnabled public Boolean mathematicValidation;
        @AuraEnabled public String implementation;
    }
    
    public class FormulaImplWrapper {
        @AuraEnabled public List<FormulaImplementation> implementations;
        @AuraEnabled public String formulaOut;

        public FormulaImplWrapper() {
            this.implementations = new List<FormulaImplementation>();
        }

        public Boolean Validate() {
            try {
                if (this.implementations == null || this.implementations.isEmpty()) return false;
                for (FormulaImplementation impl : this.implementations) {
                    System.debug('Performing validation: on ' + impl.formulaName + ' attr: ' + JSON.serialize(impl.formulaAttributes));
                    
                    //Sort the attributes by position for verification
                    impl.definition.attributes.sort();

                    System.debug('Attribute count: ' + impl.definition.AttributeCount());
                    for (Integer i = 0; i < impl.definition.AttributeCount(); i++) {
                        //impl.definition.attributes[i].check(String) = true/false
                        String value = impl.formulaAttributes[i].trim();
                        FormulaAttribute attribute = impl.definition.attributes[i];
                        String regexPlaceholder = '#\\d+#';
                        pattern placeholderPattern = pattern.compile(regexPlaceholder);
                        matcher matcherPlaceholder = placeholderPattern.matcher(value);
                        if (matcherPlaceholder.matches() == true) {
                            System.debug('Type check: (placeholder) ' + value + ' =~ ' + attribute.type + ' Result: ' + true);
                        } else {
                            Boolean attrValidate = attribute.Verify(value);
                            System.debug('Type check: ' + value + ' =~ ' + attribute.type + ' Result: ' + attrValidate);
                            if (!attrValidate) return false;
                        }
                    }
                }
                return true;
            } catch (Exception ex) {
                System.debug('Validation Error: ' + ex.getMessage());
                return false;
            }
        }
    }

    public class FormulaSettings {
        @AuraEnabled public String resultColumn;
        @AuraEnabled public String lookupColumn;
        @AuraEnabled public String dateColumn;
        @AuraEnabled public String connectedObject;
        @AuraEnabled public String lookupRelated;
        @AuraEnabled public Decimal batchSize;
        @AuraEnabled public Decimal jobDelay;

        public FormulaSettings(String masterLabel) {
            Simplus_Formula_Settings__mdt setting = [SELECT Batch_Size__c, Job_Delay__c, Result_Column__c, Lookup_Column__c, Date_Column__c, Connected_Object__c FROM Simplus_Formula_Settings__mdt WHERE MasterLabel =: masterLabel LIMIT 1];
            if (setting != null) {
                this.resultColumn = setting.Result_Column__c;
                this.lookupColumn = setting.Lookup_Column__c;
                this.dateColumn = setting.Date_Column__c;
                this.connectedObject = setting.Connected_Object__c;
                this.lookupRelated = this.lookupColumn.replacefirst('__c', '__r');
                this.batchSize = setting.Batch_Size__c;
                this.jobDelay = setting.Job_Delay__c;
            } else {
                this.resultColumn = '';
                this.lookupColumn = '';
                this.dateColumn = '';
                this.connectedObject = '';
                this.lookupRelated = '';
                this.batchSize = 50;
                this.jobDelay = 1;
            }
        }
    }

    public class FormulaImplementation implements Comparable {
        @AuraEnabled public FormulaDefinition definition;
        @AuraEnabled public String formulaName;
        @AuraEnabled public String[] formulaAttributes;
        @AuraEnabled public String placeholder;
        @AuraEnabled public String result;
        @AuraEnabled public Boolean isEncoded;

        public FormulaImplementation(FormulaDefinition a_def, String a_name, String[] a_attr, String a_placeholder) {
            this.definition = a_def;
            this.formulaName = a_name;
            this.formulaAttributes = a_attr;
            this.placeholder = a_placeholder;
            this.isEncoded = false;
        }

        public Integer compareTo(Object compareTo) {
            FormulaImplementation compared = (FormulaImplementation)compareTo;

            //Replace placeholders with numbers for ordering
            String regexPlaceholder = '#';
            Integer comparedPos = Integer.valueOf(compared.placeholder.replaceAll(regexPlaceholder, ''));
            Integer myPos = Integer.valueOf(this.placeholder.replaceAll(regexPlaceholder, ''));

            if (myPos == comparedPos) return 0;
            if (myPos < comparedPos) return -1;
            return 1;
        } 

        public Object Run(List<FormulaImplementation> implementations, String id) {
            try {
                List<String> limits = new List<String>();

                if (this.definition.type == 'Query') {
                    String target;
                    String targetType;
                    FormulaAttribute outAttr;

                    System.debug('Attribute count: ' + this.definition.AttributeCount());
                    for (Integer i = 0; i < this.definition.AttributeCount(); i++) {
                        String value = this.formulaAttributes[i].trim();
                        Boolean encoded = false;
                        FormulaAttribute attribute = this.definition.attributes[i];
                        

                        //Check for a placeholder for encoding, this has to be called BEFORE 'CheckForFormula' as that replaces the placeholder!
                        encoded = this.CheckForEncoding(value, implementations);
                        System.debug('encoded?: ' + encoded);
                        
                        //Check for a placeholder in the attribute value to then replace with the calculated value instead.
                        value = this.CheckForFormula(value, implementations);

                        //SQL injection protection on strings
                        value = String.escapeSingleQuotes(value);
                        System.debug('value to work with: ' + value);
                        System.debug('attribute record: ' + JSON.serialize(attribute));
                        if (attribute.isOutput) {
                            if (attribute.type == 'Picklist') {
                                target = attribute.getValue(value);
                                targetType = attribute.type;
                                outAttr = attribute;
                            }
                        } else {
                            if (!limits.isEmpty()) limits.add(' AND');
                            if (attribute.type == 'Picklist') {
                                limits.add(' ' + attribute.getValue(value) + ' = \'' + value + '\'');
                            } else if (attribute.type == 'Integer' || attribute.type == 'Double' || attribute.type == 'Boolean' || attribute.type == 'Date') {
                                limits.add(' ' + attribute.getValue() + ' = ' + value);
                            } else {
                                if (encoded) {
                                    Blob encodedBlob = EncodingUtil.base64Decode(value);
                                    // Convert the blob back to a string and print it in the debug log 
                                    System.debug(value + ' is now decoded as: ' + encodedBlob.toString());
                                    limits.add(' ' + attribute.getValue() + ' = \'' + encodedBlob.toString() + '\'');
                                } else {
                                    limits.add(' ' + attribute.getValue() + ' = \'' + value + '\'');
                                }
                            }
                        }
                    }

                    if (target == null) {
                        outAttr = this.definition.GetOutput();
                        target = outAttr.getValue();
                        targetType = outAttr.type;
                    }
                    String limiter = '';
                    for (String lim : limits) {
                    limiter += lim;
                    }
                    
                    //String sqlstuff = 'SELECT Id, High__c FROM Commodity_Index__c WHERE Commodity_Index__c = \'IHS\' and Material_Group__c = \'CHLORINE\'';
                    String sqlstuff = 'SELECT ' + target + ' FROM ' + this.definition.value + ' WHERE' + limiter;
                    System.debug('SOQL query (Run): ' + sqlstuff);
                    List<SObject> ss = Database.query(sqlstuff);
                    System.debug('Query Results: ' + JSON.serialize(ss));
                    System.debug('Output Target: ' + target + ' - ' + targetType);
                    List<String> targets = target.split('\\.');
                    SObject so = ss[0];
                    Object p;
                    for (Integer i = 0; i < targets.size(); i++) {
                        System.debug('Object to get: ' + targets[i]);
                        if (i+1 < targets.size()) {
                            so = so.getSObject(targets[i]);
                        } else {
                            p = so.get(targets[i]);
                        }
                    }

                    if (outAttr.isEncoded) {
                        Blob stringVal = Blob.valueOf(String.valueOf(p));
                        String encodedVal = EncodingUtil.base64Encode(stringVal);
                        System.debug('Encoded attribute output parameter: ' + encodedVal);
                        return (Object) encodedVal;
                    }
                    return p;
                } else if (this.definition.type == 'Formula') {
                    String expression = this.definition.value;
                    
                    //Parse the value formula and inject the values for calculation
                    for (Integer i = 0; i < this.definition.AttributeCount(); i++) {
                        String formulaValue = this.formulaAttributes[i].trim();
                        FormulaAttribute attribute = this.definition.attributes[i];
                        
                        //Check for a placeholder in the attribute value to then replace with the calculated value instead.
                        formulaValue = this.CheckForFormula(formulaValue, implementations);

                        //SQL injection protection on strings
                        formulaValue = String.escapeSingleQuotes(formulaValue);
                        /*
                        System.debug('value to work with: ' + formulaValue);
                        System.debug('attribute record: ' + JSON.serialize(attribute));

                        //Currently only support Double types for these formula parameters as we are performing calculations on them
                        if (attribute.type != 'Double') throw new AuraHandledException('Only Doubles are supported at this time');
                        */
                        Double dValue = Double.valueOf(formulaValue);

                        expression = expression.replacefirst('\\{'+i+'\\}', formulaValue);
                    }
                    //Step 1 replace all spaces
                    String regexSpace = ' ';
                    expression = expression.replaceAll(regexSpace, '');
                    System.debug('No spaces: ' + expression);
                    
                    //Step 2 check for groupings
                    expression = ValidateGroups(expression);

                    //Step 3 calculate the entire formula to confirm all operators are used correctly
                    expression = Calculate(expression);
                    return expression;
                } else if (this.definition.type == 'Utility') {
                    System.debug('Utility processing for record: ' + id);
                    System.debug('Utility type: ' + this.definition.utilityType);
                    if (id == null) throw new AuraHandledException('Id missing, run from record.');
                    if (this.definition.utilityType == 'Get Id') {
                        return id;
                    } else if (this.definition.utilityType == 'Get Start Date') {
                        FormulaSettings setting = new FormulaSettings('Settings');
                        String query = 'SELECT ' + setting.dateColumn + ' FROM ' + setting.connectedObject + ' WHERE Id =: id ';
                        System.debug('Formula date query: ' + query);
                        List<SObject> ss = Database.query(query);
                        SObject ssObj = ss[0];
                        System.debug('Query Results: ' + JSON.serialize(ss));
                        Date dateStart = (Date)ssObj.get(setting.dateColumn);
                        dateStart = dateStart.toStartOfMonth();
                        return dateStart;
                    }
                    return null;
                } else if (this.definition.type == 'Date') {
                    String expression = this.definition.value;
                    Date dateCalc;
                    Integer offset;

                    //Parse the value formula and inject the values for calculation
                    for (Integer i = 0; i < this.definition.AttributeCount(); i++) {
                        String formulaValue = this.formulaAttributes[i].trim();
                        FormulaAttribute attribute = this.definition.attributes[i];
                        
                        //Check for a placeholder in the attribute value to then replace with the calculated value instead.
                        formulaValue = this.CheckForFormula(formulaValue, implementations);

                        if (attribute.type == 'Date') {
                            dateCalc = Date.valueOf(formulaValue);
                        } else if (attribute.type == 'Integer') {
                            offset = Integer.valueOf(formulaValue);
                        }
                    }

                    /*
                    addDays(additionalDays)
                    Adds the specified number of additional days to a Date.
                    addMonths(additionalMonths)
                    Adds the specified number of additional months to a Date
                    addYears(additionalYears)
                    Adds the specified number of additional years to a Date
                    */

                    if (dateCalc != null && offset != null) {
                        if (this.definition.dateType == 'Day') {
                            return FormatDate(dateCalc.addDays(offset));
                        } else if (this.definition.dateType == 'Month') {
                            return FormatDate(dateCalc.addMonths(offset));
                        } else if (this.definition.dateType == 'Year') {
                            return FormatDate(dateCalc.addYears(offset));
                        }
                    }

                    return null;
                } else {
                    return null;
                }
            } catch (AuraHandledException ex) {
                System.debug(ex);
                if(!Test.isRunningTest()) {
                    throw ex;
                } else {
                    return null;
                }
            } catch (Exception ex) {
                System.debug(ex);
                if(!Test.isRunningTest()) {
                    throw new AuraHandledException('Unknown error: ' + ex.getMessage());
                } else {
                    return null;
                }
            }
        }

        public String FormatDate(Date dateVal) {
            if (dateVal == null) return '';
            return String.valueOf(dateVal);//'' + dateVal.year() + '-' + dateVal.month() + '-' + dateVal.day();
        }

        public String CheckForFormula(String attribute, List<FormulaImplementation> implementations) {                        
            String retVal = attribute;

            String regexPlaceholder = '(#\\d+#)';
            pattern placeholderPattern = pattern.compile(regexPlaceholder);
            matcher matcherPlaceholder = placeholderPattern.matcher(retVal);
            while (matcherPlaceholder.find() == true) {
                String grp = matcherPlaceholder.group(1);
                System.debug('Found attribute with placeholder: ' + grp);                
                for (FormulaImplementation impl : implementations) {
                    if (impl.placeholder == retVal) {
                        System.debug('Formula Definition placeholder value: ' + impl.definition.name);
                        retVal = retVal.replacefirst(regexPlaceholder, impl.result);
                        break;
                    }
                }
                matcherPlaceholder = placeholderPattern.matcher(retVal);
            }
            return retVal;
        }

        public Boolean CheckForEncoding(String attribute, List<FormulaImplementation> implementations) {               
            for (FormulaImplementation impl : implementations) {
                if (impl.placeholder == attribute) {
                    return impl.isEncoded;
                }
            }
            return false;
        }
    }

    public class FormulaDefinitions {
        @AuraEnabled public List<FormulaDefinition> formulas;

        public FormulaDefinitions() {
            this.formulas = new List<FormulaDefinition>();
            List<FormulaDefinition__c> lstFormulaDefinition = [SELECT Id, Name, Description__c, API_Name__c, Type__c, Date_Type__c, Utility_Type__c,
                                                               (SELECT Id, Name, FormulaDefinition__c, Description__c, Type__c, Position__c, Value__c, Output__c, Encoded__c, Picklist_Values__c FROM FormulaAttributes__r ORDER BY Position__c) 
                                                               FROM FormulaDefinition__c WHERE Active__c = true];
            system.debug('FORMULA DEFINITION >> ' + lstFormulaDefinition);
            for(FormulaDefinition__c formulaDefinition : lstFormulaDefinition) {
                List<FormulaAttribute> attr = new List<formulaAttribute>();
                String formulaStructure = '';
                String formulaStructureParameters = '';
                for(FormulaAttribute__c formulaAttribute : formulaDefinition.FormulaAttributes__r) {
                    formulaStructureParameters += (formulaStructureParameters == '' ? '' : ', ') + formulaAttribute.Name;
                    if(formulaAttribute.Type__c == 'Picklist') {
                        attr.add(new formulaAttribute(formulaAttribute.Name, formulaAttribute.Description__c, formulaAttribute.Type__c, formulaAttribute.Picklist_Values__c, integer.valueOf(formulaAttribute.Position__c), formulaAttribute.Value__c != null ? formulaAttribute.Value__c:'', formulaAttribute.Output__c, formulaAttribute.Encoded__c));
                    } else {
                        attr.add(new formulaAttribute(formulaAttribute.Name, formulaAttribute.Description__c, formulaAttribute.Type__c, integer.valueOf(formulaAttribute.Position__c), formulaAttribute.Value__c, formulaAttribute.Output__c, formulaAttribute.Encoded__c));
                    }
                }
                formulaStructure = formulaDefinition.Name + '(' + formulaStructureParameters + ')';
                FormulaDefinition def = new FormulaDefinition(formulaDefinition.Name, formulaDefinition.Description__c, formulaDefinition.Type__c, formulaDefinition.Date_Type__c, formulaDefinition.Utility_Type__c, formulaDefinition.API_Name__c, formulaStructure, attr);
                this.formulas.add(def);
            }

            System.debug('Formulas initialized');
        }
    }

    public class FormulaDefinition {
        @AuraEnabled public String name;
        @AuraEnabled public String description;
        @AuraEnabled public String type;
        @AuraEnabled public String dateType;
        @AuraEnabled public String utilityType;
        @AuraEnabled public String value;
        @AuraEnabled public String formulaStructure;
        @AuraEnabled public List<FormulaAttribute> attributes;

        public FormulaDefinition(String a_name, String a_desc, String a_type, String a_dateType, String a_utilityType, String a_value, String a_param, List<FormulaAttribute> a_attributes) {
            this.name = a_name;
            this.description = a_desc;
            this.type = a_type;
            this.dateType = a_dateType;
            this.utilityType = a_utilityType;
            this.value = a_value;
            this.formulaStructure = a_param;
            this.attributes = a_attributes;
        }

        public Integer AttributeCount() {
            Integer count = 0;
            for (FormulaAttribute attribute : attributes) {
                //If the attribute is an input parameter, then it counts or if it is a picklist then we need a parameter to select the target, so it counts
                if (!attribute.isOutput) count ++;
                else if (attribute.type == 'Picklist') count ++;
            }
            return count;
        }

        public FormulaAttribute GetOutput() {
            for (FormulaAttribute attribute : attributes) {
                //Find the output attribute and return that for the final SOQL query
                if (attribute.isOutput) return attribute;
            }
            return null;
        }

        public String GetOutputType() {
            for (FormulaAttribute attribute : attributes) {
                //Find the output attribute type and return that for the final SOQL query
                if (attribute.isOutput) return attribute.type;
            }
            return null;
        }

        public Boolean GetOutputEncoding() {
            for (FormulaAttribute attribute : attributes) {
                //Find the output attribute type and return that for the final SOQL query
                if (attribute.isOutput) return attribute.isEncoded;
            }
            return false;
        }
    }

    public class FormulaAttribute implements Comparable {
        @AuraEnabled public String name;
        @AuraEnabled public String description;
        @AuraEnabled public String type;
        @AuraEnabled public Map<String, String> picklist;
        @AuraEnabled public List<String> picklistValues;
        @AuraEnabled public Integer position;
        @AuraEnabled public String value;  //API name of the column
        @AuraEnabled public Boolean isOutput;
        @AuraEnabled public Boolean isEncoded;

        public FormulaAttribute(String a_name, String a_desc, String a_type, Integer a_pos, String a_value, Boolean a_isOutput, Boolean a_isEncoded) {
            this.name = a_name;
            this.description = a_desc;
            this.type = a_type;
            this.position = a_pos;
            this.value = a_value;
            this.isOutput = a_isOutput;
            this.isEncoded = a_isEncoded;
        }

        public FormulaAttribute(String a_name, String a_desc, String a_type, String a_picklist, Integer a_pos, String a_value, Boolean a_isOutput, Boolean a_isEncoded) {
            this.name = a_name;
            this.description = a_desc;
            this.type = a_type;
            this.picklist = (Map<String, String>)JSON.deserialize(a_picklist, Map<String, String>.class);
            this.picklistValues = new List<String>();
            for(String str : this.picklist.keySet()) {
                this.picklistValues.add(str);
            }
            this.position = a_pos;
            this.value = a_value;
            this.isOutput = a_isOutput;
            this.isEncoded = a_isEncoded;
        }

        public Integer compareTo(Object compareTo) {
            FormulaAttribute compared = (FormulaAttribute)compareTo;
            if (this.position == compared.position) return 0;
            if (this.position < compared.position) return -1;
            return 1;
        }

        public String getValue(String a_picklistName) {
            //SQL injection protection on strings
            return (String.escapeSingleQuotes(this.picklist.get(a_picklistName)));
        }

        public String getValue() {
            //SQL injection protection on strings
            return (String.escapeSingleQuotes(this.value));
        }

        public Boolean Verify(String value) {
            if (this.type == 'String') {
                try {
                    String retVal = String.valueOf(value);
                    retVal = String.escapeSingleQuotes(retVal);
                } catch (Exception ex) {
                    return false;
                }
                return true;
            } else if (this.type == 'Integer') {
                try {
                    Integer.valueOf(value);
                } catch (Exception ex) {
                    return false;
                }
                return true;
            } else if (this.type == 'Double') {
                try {
                    Double.valueOf(value);
                } catch (Exception ex) {
                    return false;
                }
                return true;
            } else if (this.type == 'Date') {
                try {
                    Date.valueOf(value);
                } catch (Exception ex) {
                    return false;
                }
                return true;
            } else if (this.type == 'Boolean') {
                try {
                    Boolean.valueOf(value);
                } catch (Exception ex) {
                    return false;
                }
                return true;
            } else if (this.type == 'Picklist') {
                //System.debug('Picklist: ' + JSON.serialize(this.picklist) + ' contains: ' + value + '?');
                if (this.picklist.containsKey(value)) {
                    return true;
                } else {
                    return false;
                }
            }
            return false;
        }
    }
}