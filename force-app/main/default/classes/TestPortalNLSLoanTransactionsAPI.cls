/**
 * @description       : Test class for PortalNLSLoanTransactionsAPI
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 03-11-2024
 * @last modified by  : Simran
**/
@isTest
public with sharing class TestPortalNLSLoanTransactionsAPI {

    @testSetup
    static void setup() {
        //Inserting Integration Family
        intframework__Integration_Family__c family = IntegrationTestInitHelper.getFamily(
            'NLS Integration');
        //Inserting Integration API Type
        intframework__Integration_API_Type__c loanTransactionApiType = IntegrationTestInitHelper.getIntegrationAPIType(
            family.Id, 'Loan Transactions Integration API Type');
        //Inserting Integration Provider
        intframework__Integration_Provider__c loanTransactionProvider = IntegrationTestInitHelper.getIntegrationProvider(
            family.Id, 'Loan Transactions');
        //Inserting Integration Configuration
        intframework__Integration_Configuration__c loanTransactionConfig = IntegrationTestInitHelper.getIntegrationConfiguration(
            loanTransactionProvider.Id,'NLS Loan Transactions Integration Configuration','NLS');
        //Inserting Integration API Configuration
        intframework__Integration_API_Configuration__c loanTransactioApiConfig = IntegrationTestInitHelper.getIntegrationAPIConfiguration(
            family.Id,
            loanTransactionApiType.Id,
            loanTransactionProvider.Id,
            loanTransactionConfig.Id,
            false,
            'NLSLoanTransactionsAdapter',
            'GET',
            'NLS',
            '/loans/',
            '{"thirdPartySystem": {"name": "Loan Transactions Test","dynamicDataParameters": [{"externalField": "accountId"},{"externalField": "loanId"}]}}',
            'application/json',
            1
        );
    }

    /**
     * @description       : Class of NLSGetNullAccessTokenMock to implement HttpCalloutMock interface
     * @author            : Simran
     * @group             : 
     * @last modified on  : 03-11-2024
     * @last modified by  : Simran
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
     * @description       : Class of NLSLoanTransactionHttpCalloutMock to implement HttpCalloutMock interface
     * @author            : Simran
     * @group             : 
     * @last modified on  : 03-11-2024
     * @last modified by  : Simran
    **/
    public class NLSLoanTransactionHttpCalloutMock implements HttpCalloutMock {

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
                                        +'"Loan_Type":2,"Portfolio_Code_Id":0,"Loan_Group_No":0,"Transaction_Code":100,"Transrefno":194062,"Reversal_Transrefno":0,"Participant_Detail_Flag":false,"Transaction_Date":"2022-09-09"},{"Acctrefno":134391,'
                                        +'"Loan_Type":2,"Portfolio_Code_Id":0,"Loan_Group_No":0,"Transaction_Code":107,"Transrefno":194020,"Reversal_Transrefno":0,"Participant_Detail_Flag":false,"Transaction_Date":"2022-09-09"}]}}');
            }
            return response;
        }
    }
    @isTest 
    static void testNlsLoanTransactionCalloutMethod() {
        Map<String, Object> requestMap = new Map<String, Object>();
        Profile profile = [SELECT Id FROM Profile WHERE Name='Certified Lender'];
        User objUser = IntegrationTestInitHelper.createUser(profile.Id);
        requestMap.put(ConstantValues.LOAN_ID, '134390' );
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new NLSLoanTransactionHttpCalloutMock());
        Test.startTest();
        System.runAs(objUser) {
            PortalNLSLoanTransactionsAPI testApi = new PortalNLSLoanTransactionsAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status);
        }
        Test.stopTest();
    }
    @isTest 
    static void testNlsLoanTransactionCalloutMethod1() {
        Map<String, Object> requestMap = new Map<String, Object>();
        Profile profile = [SELECT Id FROM Profile WHERE Name='Certified Lender'];
        User objUser = IntegrationTestInitHelper.createUser(profile.Id);
        requestMap.put(ConstantValues.LOAN_ID, '134390');
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new NLSGetNullAccessTokenMock());
        Test.startTest();
        System.runAs(objUser) {
            PortalNLSLoanTransactionsAPI testApi = new PortalNLSLoanTransactionsAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status);
        }
        Test.stopTest();
    }
    @isTest 
    static void testNlsLoanTransactionCalloutMethod2() {
        Map<String, Object> requestMap = new Map<String, Object>();
        Profile profile = [SELECT Id FROM Profile WHERE Name='Certified Lender'];
        User objUser = IntegrationTestInitHelper.createUser(profile.Id);
        requestMap.put(ConstantValues.LOAN_NUMBER, '134390' );
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new NLSLoanTransactionHttpCalloutMock());
        Test.startTest();
        System.runAs(objUser) {
            PortalNLSLoanTransactionsAPI testApi = new PortalNLSLoanTransactionsAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status);
        }
        Test.stopTest();
    }
}