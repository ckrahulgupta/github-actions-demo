/**
 * @description       : Test class to test FetchPicklistValuesUtil.cls
 * @author            : Aitijhya Sarkar
 * @last modified on  : 08-29-2024
 * @last modified by  : Aitijhya sarkar
**/
@IsTest
public class FetchPicklistValuesUtilTest {

    /**
    * @description Ideal Case
    * @author Aitijhya Sarkar | 08-29-2024 
    **/
    @IsTest
    public static void testGetPicklistValues() {
        List<FetchPicklistValuesUtil.getFieldName> inputs = new List<FetchPicklistValuesUtil.getFieldName>();
        FetchPicklistValuesUtil.getFieldName input = new FetchPicklistValuesUtil.getFieldName();
        input.fieldName = 'Reports__c';
        inputs.add(input);
        List<FetchPicklistValuesUtil.FlowOutput> results = FetchPicklistValuesUtil.getPicklistValues(inputs);

        // Assert that results are returned
        System.assertNotEquals(0, results.size(), 'Results should not be empty');
        
        // Assert that the first result has no error message
        FetchPicklistValuesUtil.FlowOutput firstResult = results[0];
        System.assertNotEquals('', firstResult.picklistValues, 'Picklist values should not be empty');
        System.assertEquals('', firstResult.errorMessage, 'Error message should be empty');
    }

    /**
    * @description Giving an invalid Field as input
    * @author Aitijhya Sarkar | 08-29-2024 
    **/
    @IsTest
    public static void testGetPicklistValuesWithInvalidField() {
        List<FetchPicklistValuesUtil.getFieldName> inputs = new List<FetchPicklistValuesUtil.getFieldName>();

        // Create and populate a getFieldName instance with an invalid field name
        FetchPicklistValuesUtil.getFieldName input = new FetchPicklistValuesUtil.getFieldName();
        input.fieldName = 'InvalidField__c'; // This field doesn't exist
        inputs.add(input);
        List<FetchPicklistValuesUtil.FlowOutput> results = FetchPicklistValuesUtil.getPicklistValues(inputs);
        System.assertNotEquals(0, results.size(), 'Results should not be empty');
        FetchPicklistValuesUtil.FlowOutput firstResult = results[0];
        System.assertEquals('', firstResult.picklistValues, 'Picklist values should be empty for an invalid field');
        System.assertNotEquals('', firstResult.errorMessage, 'Error message should not be empty');
    }

    /**
    * @description Giving an empty list of input
    * @author Aitijhya Sarkar | 08-29-2024 
    **/
    @IsTest
    public static void testGetPicklistValuesWithEmptyInput() {
        // Create an empty list of getFieldName objects
        List<FetchPicklistValuesUtil.getFieldName> inputs = new List<FetchPicklistValuesUtil.getFieldName>();
        List<FetchPicklistValuesUtil.FlowOutput> results = FetchPicklistValuesUtil.getPicklistValues(inputs);
        System.assertEquals(0, results.size(), 'Results should be empty for empty input');
    }
}