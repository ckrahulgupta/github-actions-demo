@isTest
public class externalAPIDummyKabirTest {
    @isTest
    static void testPostMethod() {
        RestRequest request = new RestRequest();
        request.requestUri = '/services/apexrest/api/v1/external/apidummykabir';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        
        Map<String, Object> applicantDetailsMap = new Map<String, Object>{
            'first_name' => 'John',
            'last_name' => 'Parker',
            'middle_name' => 'Rohan'
        };
        Map<String, Object> requestMap = new Map<String, Object>{
            'applicant_details' => applicantDetailsMap
        };
                    
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;

        RestResponse response = new RestResponse();
        RestContext.response = response;

        Test.startTest();
        externalAPIDummyKabir.PostMethod();
        Test.stopTest();

        System.assertEquals(201, response.statusCode, 'Expected status code 201 for success');

        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(response.responseBody.toString());
        System.assertNotEquals(null, responseMap.get('content'), 'Expected content to be present');

        Map<String, Object> contentMap = (Map<String, Object>) responseMap.get('content');
        System.assertEquals('Success', responseMap.get('status'), 'Expected status: Success');
        System.assertEquals('Parker, John Rohan', contentMap.get('account_Name'), 'Expected Name: Parker, John Rohan');
        
        System.assertNotEquals(null, contentMap.get('accountId'), 'Expected accountId to be present');
        System.assertNotEquals(null, contentMap.get('contactId'), 'Expected contactId to be present');
        System.assertEquals('John Rohan Parker', contentMap.get('contact_Name'), 'Expected Name: John Rohan Parker');
    }
    
}