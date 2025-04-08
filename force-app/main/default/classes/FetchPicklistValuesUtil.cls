/**
 * @description       : Utility class to stringify the picklist values based on the field name
 * @author            : Aitijhya Sarkar
 * @last modified on  : 08-29-2024
 * @last modified by  : Aitijhya sarkar
**/
public class FetchPicklistValuesUtil {

    // Define the input structure for the Flow
    public class getFieldName {
        @InvocableVariable(required=true)
        public String fieldName;
    }

    // Define the output structure for the Flow
    public class FlowOutput {
        @InvocableVariable
        public String picklistValues;
        @InvocableVariable
        public String errorMessage;

        /**
        * @description 
        * @author Aitijhya Sarkar | 08-28-2024 
        * @param picklistValues 
        * @param errorMessage 
        **/
        public FlowOutput(String picklistValues, String errorMessage) {
            this.picklistValues = picklistValues;
            this.errorMessage = errorMessage;
        }
    }

    /**
    * @description ethod to be invoked from the Flow
    * @author Aitijhya Sarkar | 08-28-2024 
    * @param Field Names 
    * @return List<FlowOutput> 
    **/
    @InvocableMethod(label='Get Picklist Values' description='Returns a semicolon-separated list of picklist values')
    public static List<FlowOutput> getPicklistValues(List<getFieldName> requests) {
        List<FlowOutput> results = new List<FlowOutput>();
        for (getFieldName req : requests) {
            String picklistValues = '';
            String errorMessage = '';
            try {
                Schema.DescribeSObjectResult objSchema = CFA_Partner_Program__c.sObjectType.getDescribe(SObjectDescribeOptions.DEFAULT); // Get the Describe result of the object
                Map<String, Schema.SObjectField> fieldMap = objSchema.fields.getMap();
                List<Schema.PicklistEntry> picklistEntries = fieldMap.get(req.fieldName).getDescribe().getPicklistValues();
                List<String> picklistValuesList = new List<String>();
                for (Schema.PicklistEntry entry : picklistEntries) {
                    picklistValuesList.add(entry.getValue());
                }
                picklistValues = String.join(picklistValuesList, ';'); // Build a semicolon-separated string of picklist values
            } catch(Exception exceptionObj){
                errorMessage = exceptionObj.getMessage();
            }
            results.add(new FlowOutput(picklistValues, errorMessage));
        }
        return results;
    }
}