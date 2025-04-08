/**
 * @description       : Test Class for Portal NLS Get Loan API 
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 03-11-2024
 * @last modified by  : Suraj Kumar
**/
@isTest 
public with sharing class TestPortalNLSLoanDetailsAPI {
    @testSetup
    static void setup() {
        //Inserting Integration Family
        intframework__Integration_Family__c family = IntegrationTestInitHelper.getFamily(
            'NLS Integration');
        //Inserting Integration API Type
        intframework__Integration_API_Type__c getLoanApiType = IntegrationTestInitHelper.getIntegrationAPIType(
            family.Id, 'Get loan Integration API Type');
        //Inserting Integration Provider
        intframework__Integration_Provider__c getLoanProvider = IntegrationTestInitHelper.getIntegrationProvider(
            family.Id, 'Get Loan');
        //Inserting Integration Configuration
        intframework__Integration_Configuration__c getLoanConfig = IntegrationTestInitHelper.getIntegrationConfiguration(
            getLoanProvider.Id,'NLS Get Loan Integration Configuration','NLS');
        //Inserting Integration API Configuration
        intframework__Integration_API_Configuration__c getLoanApiConfig = IntegrationTestInitHelper.getIntegrationAPIConfiguration(
            family.Id,
            getLoanApiType.Id,
            getLoanProvider.Id,
            getLoanConfig.Id,
            false,
            'NLSGetLoanAdapter',
            'GET',
            'NLS',
            '/loans/',
            '{"thirdPartySystem": { "name": "Get Loan Test","dynamicDataParameters": [{"externalField": "accountId"},{"externalField": "loanId"}]}}',
            'application/json',
            1
        );
    }
    /**
 * @description       : Setting up the Mock Response of SUCCESS status
 * @author            : Suraj kumar
 * @last modified on  : 03-11-2024
 * @last modified by  : Suraj Kumar
**/
    public class NLSGetLoanHttpCalloutMock implements HttpCalloutMock {
        // Implement this interface method
         /**
        * @description : return the mock response of success status
        * @author Suraj Kumar | 03-11-2024 
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
            else{
                response.setBody('{"status":{"code":200,"message":"Success"},"payload":{"data":{"Acctrefno":555555,'
                                        +'"Loan_Type":2,"Curr_Maturity_Date":"2022-03-15T00:00:00","Days_Past_Due": 0,"Portfolio_Code_Id":0,"Loan_Group_No":0}}}');
            }
            return response;
        }
    }
    /**
 * @description       : Setting up the Mock Response of FAILED status
 * @author            : Suraj kumar
 * @last modified on  : 03-11-2024
 * @last modified by  : Suraj Kumar
**/
    public class NLSGetNullAccessTokenMock implements HttpCalloutMock {
        // Implement this interface method
         /**
        * @description : return the mock response of FAILED status
        * @author Suraj Kumar | 03-11-2024 
        * @param request 
        * @return HTTPResponse 
        **/
        public HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            response.setStatusCode(400);
            response.setStatus('FAILED');
            response.setHeader('Content-Type', 'application/json');
            return response;
        }
    }
    @isTest 
    public static void testNlsGetLoanCalloutMethod1() {
        Map<String, Object> requestMap = new Map<String, Object>();
        Profile profile = [SELECT Id FROM Profile WHERE Name='Certified Lender'];
        User objUser = IntegrationTestInitHelper.createUser(profile.Id);
        requestMap.put(ConstantValues.LOAN_ID, 123456 );
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new NLSGetLoanHttpCalloutMock());
        Test.startTest();
        System.runAs(objUser) {
            PortalNLSLoanDetailsAPI testApi = new PortalNLSLoanDetailsAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status);
        }
        Test.stopTest();
    }
    @isTest 
    public static void testNlsGetLoanCalloutMethod3() {
        Map<String, Object> requestMap = new Map<String, Object>();
        Profile profile = [SELECT Id FROM Profile WHERE Name='Certified Lender'];
        User objUser = IntegrationTestInitHelper.createUser(profile.Id);
        requestMap.put(ConstantValues.LOAN_ID, 123456);
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new NLSGetNullAccessTokenMock());
        Test.startTest();
        System.runAs(objUser) {
            PortalNLSLoanDetailsAPI testApi = new PortalNLSLoanDetailsAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status);
        }
        Test.stopTest();
    }
}