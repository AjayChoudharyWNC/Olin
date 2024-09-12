public class PicklistDependencyUtility {
    
    class MyPickListInfo {
        public String validFor;
    }

    public static Map<String, List<String>> getFieldDependencies(String objectName, String controllingField, String dependentField, Boolean isLabel) {
        Map<String, List<String>> controllingInfo = new Map<String, List<String>>();

        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectName);

        Schema.DescribeSObjectResult describeResult = objType.getDescribe();
        Schema.DescribeFieldResult controllingFieldInfo = describeResult.fields.getMap().get(controllingField).getDescribe();
        Schema.DescribeFieldResult dependentFieldInfo = describeResult.fields.getMap().get(dependentField).getDescribe();

        List<Schema.PicklistEntry> controllingValues = controllingFieldInfo.getPicklistValues();
        List<Schema.PicklistEntry> dependentValues = dependentFieldInfo.getPicklistValues();

        for(Schema.PicklistEntry currControllingValue : controllingValues) {
            if(isLabel) {
                controllingInfo.put(currControllingValue.getLabel(), new List<String>());
            } else {
                controllingInfo.put(currControllingValue.getValue(), new List<String>());
            }
            
        }

        for(Schema.PicklistEntry currDependentValue : dependentValues) {
            String jsonString = JSON.serialize(currDependentValue);

            MyPickListInfo info = (MyPickListInfo) JSON.deserialize(jsonString, MyPickListInfo.class);

            String hexString = EncodingUtil.convertToHex(EncodingUtil.base64Decode(info.validFor)).toUpperCase();

            Integer baseCount = 0;

            for(Integer curr : hexString.getChars()) {
                Integer val = 0;

                if(curr >= 65)
                {
                    val = curr - 65 + 10;
                }
                else
                {
                    val = curr - 48;
                }

                Integer index = -1;

                if((val & 8) == 8)
                {
                    index = baseCount + 0;
                }
                if((val & 4) == 4)
                {
                    index = baseCount + 1;                    
                }
                if((val & 2) == 2)
                {
                    index = baseCount + 2;                  
                }
                if((val & 1) == 1)
                {
                    index = baseCount + 3;                   
                }

                if(index != -1) {
                    if(isLabel) {
                        controllingInfo.get(controllingValues[index].getLabel()).add(currDependentValue.getLabel());
                    } else {
                        controllingInfo.get(controllingValues[index].getValue()).add(currDependentValue.getValue());
                    }
                }

                baseCount += 4;
            }            
        } 

        System.debug('ControllingInfo: ' + controllingInfo);

        return controllingInfo;
    }

}