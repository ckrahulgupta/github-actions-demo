/**
 * @description       : Test Class for Portal NLS Active Loan API 
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 03-11-2024
 * @last modified by  : Suraj Kumar
**/

@isTest
public with sharing class TestPortalNLSActiveLoanAPI {
    @testSetup
    static void setup() {
        //Inserting Integration Family
        intframework__Integration_Family__c family = IntegrationTestInitHelper.getFamily(
            'NLS Integration');
        //Inserting Integration API Type
        intframework__Integration_API_Type__c searchLoanApiType = IntegrationTestInitHelper.getIntegrationAPIType(
            family.Id, 'Search Loans Integration API Type');
        //Inserting Integration Provider
        intframework__Integration_Provider__c searchLoanProvider = IntegrationTestInitHelper.getIntegrationProvider(
            family.Id, 'Search Loans');
        //Inserting Integration Configuration
        intframework__Integration_Configuration__c searchLoanConfig = IntegrationTestInitHelper.getIntegrationConfiguration(
            searchLoanProvider.Id,'NLS Search Loans Integration Configuration','NLS');
        //Inserting Integration API Configuration
        intframework__Integration_API_Configuration__c searchLoanApiConfig = IntegrationTestInitHelper.getIntegrationAPIConfiguration(
            family.Id,
            searchLoanApiType.Id,
            searchLoanProvider.Id,
            searchLoanConfig.Id,
            false,
            'NLSLoanSearchAdapter',
            'POST',
            'NLS',
            '/loans/search',
            '{"thirdPartySystem": {"name": "Test","filters": [{"objectAPI": "Account","objectAlias": "Account",'
                    +'"fields": [{"externalField": "ID","fieldAPI": "Id"},{"externalField": "CIF","fieldAPI": "CIF_Number__c"}],'
                    +'"whereClause": "Id = :accountId"}],"dynamicDataParameters": [{"externalField": "partyType"},'
                    +'{"externalField": "statusCode"},{"externalField": "loanType"},{"externalField": "masterAcctrefno"}]}}',
            'application/json',
            1
        );
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
     /**
 * @description       : Setting up the Mock Response of SUCCESS status
 * @author            : Suraj kumar
 * @last modified on  : 03-11-2024
 * @last modified by  : Suraj Kumar
**/
    public class NLSActiveLoanHttpCalloutMock implements HttpCalloutMock {
        // Implement this interface method
        /**
        * @description : return the mock response of SUCCESS status
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
                response.setBody('{"status":{"code":200,"message":"Success"},"payload":{"data":[{"Acctrefno":134390,'
                                        +'"Loan_Type":2,"Portfolio_Code_Id":0,"Loan_Group_No":0},{"Acctrefno":134391,'
                                        +'"Loan_Type":2,"Portfolio_Code_Id":0,"Loan_Group_No":0}]}}');
            }
            return response;
        }
    }

    @isTest 
    public static void testPortalNLSActiveLoanAPI1() {
        Map<String, Object> requestMap = new Map<String, Object>();
        Profile profile = [SELECT Id FROM Profile WHERE Name='Certified Lender'];
        User objUser = IntegrationTestInitHelper.createUser(profile.Id);
        requestMap.put(ConstantValues.STATUS_CODE, '1');
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new NLSActiveLoanHttpCalloutMock());
        Test.startTest();
        System.runAs(objUser) {
            PortalNLSActiveLoanAPI testApi = new PortalNLSActiveLoanAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status);
        }
        Test.stopTest();
    }
    @isTest 
    public static void testPortalNLSActiveLoanAPI2() {
        Map<String, Object> requestMap = new Map<String, Object>();
        Profile profile = [SELECT Id FROM Profile WHERE Name='Grower'];
        User objUser = IntegrationTestInitHelper.createUser(profile.Id);
        requestMap.put(ConstantValues.STATUS_CODE, '0');
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new NLSActiveLoanHttpCalloutMock());
        Test.startTest();
        System.runAs(objUser) {
            PortalNLSActiveLoanAPI testApi = new PortalNLSActiveLoanAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status);
        }
        Test.stopTest();
    }
    @isTest 
    public static void testPortalNLSActiveLoanAPI3() {
        Map<String, Object> requestMap = new Map<String, Object>();
        Profile profile = [SELECT Id FROM Profile WHERE Name='Certified Lender'];
        User objUser = IntegrationTestInitHelper.createUser(profile.Id);
        requestMap.put(ConstantValues.STATUS_CODE, '5');
        requestMap.put(ConstantValues.LOAN_TYPE, '2');
        requestMap.put(ConstantValues.MASTER_ACCTREFNO, 139000);
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new NLSGetNullAccessTokenMock());
        Test.startTest();
        System.runAs(objUser) {
            PortalNLSActiveLoanAPI testApi = new PortalNLSActiveLoanAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status);
        }
        Test.stopTest();
    }
    @isTest 
    public static void testPortalNLSActiveLoanAPI4() {
        Map<String, Object> requestMap = new Map<String, Object>();
        Profile profile = [SELECT Id FROM Profile WHERE Name='Certified Lender'];
        User objUser = IntegrationTestInitHelper.createUser(profile.Id);
        requestMap.put(ConstantValues.STATUS_CODE, '5');
        requestMap.put(ConstantValues.LOAN_TYPE, '2');
        requestMap.put(ConstantValues.MASTER_ACCTREFNO, 139000);
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new NLSGetNullAccessTokenMock());
        Test.startTest();
        PortalNLSActiveLoanAPI testApi = new PortalNLSActiveLoanAPI();
        clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
        System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status);
        Test.stopTest();
    }
}