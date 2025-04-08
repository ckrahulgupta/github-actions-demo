public class FetchPicklistValues {

    // Define the input structure for the Flow
    public class FlowInput {
        @InvocableVariable(required=true)
        public String fieldName;
    }

    // Define the output structure for the Flow
    public class FlowOutput {
        @InvocableVariable
        public String picklistValues;
        @InvocableVariable
        public String errorMessage;
        public FlowOutput(String picklistValues, String errorMessage) {
            this.picklistValues = picklistValues;
            this.errorMessage = errorMessage;
        }
    }

    // Define the method to be invoked from the Flow
    @InvocableMethod(label='Get Picklist Values' description='Returns a semicolon-separated list of picklist values')
    public static List<FlowOutput> getPicklistValues(List<FlowInput> requests) {
        List<FlowOutput> results = new List<FlowOutput>();
        for (FlowInput req : requests) {
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
            } catch (Exception e) {
                errorMessage = 'Error fetching picklist values: ' + e.getMessage();
            }
            results.add(new FlowOutput(picklistValues, errorMessage));
        }
        return results;
    }
}