/**
 * @description       :
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 03-11-2024
 * @last modified by  :  Pritam Roy
**/
@isTest
public with sharing class NLSGetLoanHttpCalloutMock implements HttpCalloutMock {
    
    /**
    * @description : Implement this interface method to set success response
    * @author  Pritam Roy | 03-11-2024 
    * @param request 
    * @return HTTPResponse 
    **/
    public HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setStatus('SUCCESS');
        response.setHeader('Content-Type', 'application/json');
        if(request.getEndpoint().contains('token')){
            String token = '{"access_token":"eyJhbGciOiJSUzI1NiIsI","expires_in":300,"token_type":"Bearer"}';
            response.setBody(token);
        }
        else if(!request.getEndpoint().contains('transactions') && !request.getEndpoint().contains('/loans/search')){
            response.setBody('{"status":{"code":200,"message":"Success"},"payload":{"data":{"Acctrefno":555555,'
                                    +'"Loan_Type":2,"Portfolio_Code_Id":0,"Loan_Group_No":0}}}');
        }
        else{
            response.setBody('{"status":{"code":200,"message":"Success"},"payload":{"data":[{"Acctrefno":134390,'
                                    +'"Loan_Type":2,"Portfolio_Code_Id":0,"Loan_Group_No":0},{"Acctrefno":134391,'
                                    +'"Loan_Type":2,"Portfolio_Code_Id":0,"Loan_Group_No":0}]}}');
        }
        return response;
    }
}