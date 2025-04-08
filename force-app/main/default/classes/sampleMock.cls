/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-11-2022
 * @last modified by  : Arka Jyoti Deb
**/
@isTest
global class sampleMock implements HttpCalloutMock {
    // Implement this interface method
    global static System.HttpResponse respond(System.HttpRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setStatus('SUCCESS');
        response.setHeader('Content-Type', 'application/json');
        if(request.getEndpoint().contains('token')){
            String token = '{"access_token":"eyJhbGciOiJSUzI1NiIsI","expires_in":300,"token_type":"Bearer"}';
            response.setBody(token);
        }
        else{
            response.setBody('{"status":{"code":200,"message":"Success"},"payload":{"data":{"Acctrefno":134390,'
                                    +'"Loan_Type":2,"Portfolio_Code_Id":0,"Loan_Group_No":0}}}');
        }
        return response; 
    }
}