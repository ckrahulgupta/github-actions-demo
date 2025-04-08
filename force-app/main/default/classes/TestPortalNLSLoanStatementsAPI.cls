/**
 * @description       : Test class for PortalNLSLoanStatementsAPI
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 11-29-2024
 * @last modified by  : Ayan Bhowmik
**/

@isTest
public with sharing class TestPortalNLSLoanStatementsAPI {

    @testSetup
    static void setup() {
        //Inserting Integration Family
        intframework__Integration_Family__c family = IntegrationTestInitHelper.getFamily(
            'NLS Integration');
        //Inserting Integration API Type
        intframework__Integration_API_Type__c loanStatementsApiType = IntegrationTestInitHelper.getIntegrationAPIType(
            family.Id, 'Get Loan Statements Integration API Type');
        //Inserting Integration Provider
        intframework__Integration_Provider__c loanStatementsProvider = IntegrationTestInitHelper.getIntegrationProvider(
            family.Id, 'Loan Statements');
        //Inserting Integration Configuration
        intframework__Integration_Configuration__c loanStatementsConfig = IntegrationTestInitHelper.getIntegrationConfiguration(
            loanStatementsProvider.Id,'NLS Loan Statements Integration Configuration','NLS');
        //Inserting Integration API Configuration
        intframework__Integration_API_Configuration__c loanTransactioApiConfig = IntegrationTestInitHelper.getIntegrationAPIConfiguration(
            family.Id,
            loanStatementsApiType.Id,
            loanStatementsProvider.Id,
            loanStatementsConfig.Id,
            false,
            'NLSLoanStatementsAdapter',
            'GET',
            'NLS',
            '/loans/loanId/statements',
            '{"thirdPartySystem": {"name": "Loan Statements Test","dynamicDataParameters": [{"externalField": "accountId"},{"externalField": "loanId"},{"externalField": "statementType"}]}}',
            'application/json',
            1
        );
    }

    /**
     * @description       : Class of NLSGetNullAccessTokenMock to implement HttpCalloutMock interface
     * @author            : Simran
     * @group             : 
     * @last modified on  : 11-29-2024
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
     * @description       : Class of NLSLoanStatementHttpCalloutMock to implement HttpCalloutMock interface
     * @author            : Simran
     * @group             : 
     * @last modified on  : 11-29-2024
     * @last modified by  : Ayan Bhowmik
    **/
    public class NLSLoanStatementHttpCalloutMock implements HttpCalloutMock {
      
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
                response.setBody('{"status":{"code":200,"message":"Success"},"payload":{"data":[{"Acctrefno":134390,'
                                        +'"Loan_Type":2,"Portfolio_Code_Id":0,"Loan_Group_No":0,"Transaction_Code":100,"Transrefno":194062, "Statement_Date": "2023-02-09T00:00:00"},{"Acctrefno":134391,'
                                        +'"Loan_Type":2,"Portfolio_Code_Id":0,"Loan_Group_No":0,"Transaction_Code":107,"Statement_Date": "2023-02-09T00:00:00","Transrefno":194020}]}}');
            }
            return response;
        }
    }
    @isTest 
    static void testNlsLoanStatementsCalloutMethod1() {
        Map<String, Object> requestMap = new Map<String, Object>();
        Profile profile = [SELECT Id FROM Profile WHERE Name='Sales Agent'];
        User objUser = IntegrationTestInitHelper.createUser(profile.Id);
        requestMap.put(ConstantValues.LOAN_ID, 123456 );
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new NLSLoanStatementHttpCalloutMock());
        Test.startTest();
        System.runAs(objUser) {
            PortalNLSLoanStatementsAPI testApi = new PortalNLSLoanStatementsAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status);
        }
        Test.stopTest();
    }
    @isTest 
    static void testNlsLoanStatementsCalloutMethod2() {
        Map<String, Object> requestMap = new Map<String, Object>();
        Profile profile = [SELECT Id FROM Profile WHERE Name='Sales Agent'];
        User objUser = IntegrationTestInitHelper.createUser(profile.Id);
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new NLSLoanStatementHttpCalloutMock());
        Test.startTest();
        System.runAs(objUser) {
            PortalNLSLoanStatementsAPI testApi = new PortalNLSLoanStatementsAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status);
        }
        Test.stopTest();
    }
    @isTest 
    static void testNlsLoanStatementsCalloutMethod3() {
        Map<String, Object> requestMap = new Map<String, Object>();
        Profile profile = [SELECT Id FROM Profile WHERE Name='Sales Agent'];
        User objUser = IntegrationTestInitHelper.createUser(profile.Id);
        requestMap.put(ConstantValues.LOAN_ID, 123456);
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new NLSGetNullAccessTokenMock());
        Test.startTest();
        System.runAs(objUser) {
            PortalNLSLoanStatementsAPI testApi = new PortalNLSLoanStatementsAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status);
        }
        Test.stopTest();
    }
    @isTest 
    static void testNlsLoanStatementsCalloutMethod4() {
        Map<String, Object> requestMap = new Map<String, Object>();
        Profile profile = [SELECT Id FROM Profile WHERE Name='Sales Agent'];
        User objUser = IntegrationTestInitHelper.createUser(profile.Id);
        requestMap.put(ConstantValues.LOAN_ID, 123456 );
        requestMap.put(ConstantValues.STATEMENT_TYPE, 'Statement for Current Year' );
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new NLSLoanStatementHttpCalloutMock());
        Test.startTest();
        System.runAs(objUser) {
            PortalNLSLoanStatementsAPI testApi = new PortalNLSLoanStatementsAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status);
        }
        Test.stopTest();
    }
    @isTest 
    static void testNlsLoanStatementsCalloutMethod5() {
        Map<String, Object> requestMap = new Map<String, Object>();
        Profile profile = [SELECT Id FROM Profile WHERE Name='Sales Agent'];
        User objUser = IntegrationTestInitHelper.createUser(profile.Id);
        requestMap.put(ConstantValues.LOAN_ID, 123456 );
        requestMap.put(ConstantValues.STATEMENT_TYPE, 'Statement for Last Year' );
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new NLSLoanStatementHttpCalloutMock());
        Test.startTest();
        System.runAs(objUser) {
            PortalNLSLoanStatementsAPI testApi = new PortalNLSLoanStatementsAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status);
        }
        Test.stopTest();
    }
}