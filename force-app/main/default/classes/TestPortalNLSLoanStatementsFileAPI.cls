/**
 * @description       : Test class for PortalNLSLoanStatementsFileAPI
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 12-02-2024
 * @last modified by  : Ayan Bhowmik
**/
@isTest
public with sharing class TestPortalNLSLoanStatementsFileAPI {

    @testSetup
    static void setup() {
        //Inserting Integration Family
        intframework__Integration_Family__c family = IntegrationTestInitHelper.getFamily(
            'NLS Integration');
        //Inserting Integration API Type
        intframework__Integration_API_Type__c integrationApiType = IntegrationTestInitHelper.getIntegrationAPIType(
            family.Id, 'Get Loan Statements File Integration API Type');
        //Inserting Integration Provider
        intframework__Integration_Provider__c integrationProvider = IntegrationTestInitHelper.getIntegrationProvider(
            family.Id, 'Loan Statements File');
        //Inserting Integration Configuration
        intframework__Integration_Configuration__c integrationConfig = IntegrationTestInitHelper.getIntegrationConfiguration(
            integrationProvider.Id,'NLS Loan Statements File Integration Configuration','NLS');
        //Inserting Integration API Configuration
        intframework__Integration_API_Configuration__c integrationApiConfig = IntegrationTestInitHelper.getIntegrationAPIConfiguration(
            family.Id,
            integrationApiType.Id,
            integrationProvider.Id,
            integrationConfig.Id,
            false,
            'NLSLoanStatementsFileAdapter',
            'GET',
            'NLS',
            'loans/statements/{statementId}/file',
            '{"thirdPartySystem": {"name": "Loan StatementsFiles Test","dynamicDataParameters": [{"externalField": "accountId"},{"externalField": "statementId"},{"isPathParameter" : "true","externalField": "statementId"}]}}',
            'application/json',
            1
        );

        System.assertEquals(integrationApiConfig.intframework__Adapter_Class_Name__c,'NLSLoanStatementsFileAdapter','Different Adapter Class');
    }
    
    /**
     * @description       : Class of NLSGetNullAccessTokenMock to implement HttpCalloutMock interface
     * @author            : Simran
     * @group             : 
     * @last modified on  : 12-02-2024
     * @last modified by  : Ayan Bhowmik
    **/
    public class NLSGetNullAccessTokenMock implements HttpCalloutMock {
      
        /**
        * @description Implement the interface method
        * @author Simran | 03-11-2024 
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

    /**
     * @description       : Class of NLSLoanStatementFileHttpCalloutMock to implement HttpCalloutMock interface
     * @author            : Simran
     * @group             : 
     * @last modified on  : 12-02-2024
     * @last modified by  : Ayan Bhowmik
    **/
    public class NLSLoanStatementFileHttpCalloutMock implements HttpCalloutMock {
       
        /**
        * @description Implement the interface method
        * @author Simran | 03-11-2024 
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
                response.setBody('{"status":{"code":200,"message":"Success"},"payload":{"data":{"Acctrefno":134390}}}');
            }
            return response;
        }
    }
    /**
    * @description test for default success
    * @author Simran | 03-11-2024 
    **/
    @isTest 
    static void testDefaultSuccess() {
        Map<String, Object> requestMap = new Map<String, Object>();
        Profile profile = [SELECT Id FROM Profile WHERE Name='Sales Agent'];
        User objUser = IntegrationTestInitHelper.createUser(profile.Id);
        requestMap.put(ConstantValues.STATEMENT_ID, 123456 );
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new NLSLoanStatementFileHttpCalloutMock());
        Test.startTest();
        System.runAs(objUser) {
            PortalNLSLoanStatementsFileAPI testApi = new PortalNLSLoanStatementsFileAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Failure in NLS Loan Statements File API');
        }
        Test.stopTest();
    }
    /**
    * @description test for default failure
    * @author Simran | 03-11-2024 
    **/
    @isTest 
    static void testDefaultFailure() {
        Map<String, Object> requestMap = new Map<String, Object>();
        Profile profile = [SELECT Id FROM Profile WHERE Name='Sales Agent'];
        User objUser = IntegrationTestInitHelper.createUser(profile.Id);
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new NLSLoanStatementFileHttpCalloutMock());
        Test.startTest();
        System.runAs(objUser) {
            PortalNLSLoanStatementsFileAPI testApi = new PortalNLSLoanStatementsFileAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Failure in NLS Loan Statements File API');
        }
        Test.stopTest();
    }
    /**
    * @description test where the access token is null
    * @author Rakesh Saraf | 09-24-2024 
    **/
    @isTest 
    static void testNullAccessToken() {
        Map<String, Object> requestMap = new Map<String, Object>();
        Profile profile = [SELECT Id FROM Profile WHERE Name='Sales Agent'];
        User objUser = IntegrationTestInitHelper.createUser(profile.Id);
        requestMap.put(ConstantValues.STATEMENT_ID, 123456);
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new NLSGetNullAccessTokenMock());
        Test.startTest();
        System.runAs(objUser) {
            PortalNLSLoanStatementsFileAPI testApi = new PortalNLSLoanStatementsFileAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Throws Exception when access token is null');
        }
        Test.stopTest();
    }
}