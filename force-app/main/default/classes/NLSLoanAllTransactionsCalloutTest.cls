/**
 * @description       : Test class for NLSLoanAllTransactionsCallout
 * @author            : Sk Minsar
 * @group             : 
 * @last modified on  : 09-03-2024
 * @last modified by  : Sk Minsar
**/
@isTest
public inherited sharing class NLSLoanAllTransactionsCalloutTest {
    @testSetup
    static void setup() {
         //Inserting Integration Family
         intframework__Integration_Family__c family = IntegrationTestInitHelper.getFamily(
            'NLS Integration');
        //Inserting Integration API Type
        intframework__Integration_API_Type__c loanTransactionApiType = IntegrationTestInitHelper.getIntegrationAPIType(
            family.Id, 'Loan All Transactions Integration API Type');
        //Inserting Integration Provider
        intframework__Integration_Provider__c loanTransactionProvider = IntegrationTestInitHelper.getIntegrationProvider(
            family.Id, 'Loan All Transactions');
        //Inserting Integration Configuration
        intframework__Integration_Configuration__c loanTransactionConfig = IntegrationTestInitHelper.getIntegrationConfiguration(
            loanTransactionProvider.Id,'NLS Loan ALL Transactions API Configuration','NLS');
        //Inserting Integration API Configuration
        IntegrationTestInitHelper.getIntegrationAPIConfiguration(
            family.Id,
            loanTransactionApiType.Id,
            loanTransactionProvider.Id,
            loanTransactionConfig.Id,
            false,
            'NLSLoanAllTransactionsAdapter',
            'GET',
            'NLS',
            '/loans/',
            '{"thirdPartySystem": {"name": "Loan Transactions Test","dynamicDataParameters": [{"externalField": "accountId"},{"externalField": "loanIdList"}]}}',
            'application/json',
            1
        );
    }

    /**
     * @description       : Class of NLSGetNullAccessTokenMock to implement HttpCalloutMock interface
     * @author            : Sk Minsar
     * @group             : 
     * @last modified on  : 09-03-2024
     * @last modified by  : Sk Minsar
    **/
    public class NLSGetNullAccessTokenMock implements HttpCalloutMock {
        /**
        * @description Implement the interface method
        * @author Sk Minsar | 09-02-2024 
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
     * @author            : Sk Minsar
     * @group             : 
     * @last modified on  : 09-03-2024
     * @last modified by  : Sk Minsar
    **/
    public class NLSLoanTransactionHttpCalloutMock implements HttpCalloutMock {        
        /**
        * @description Implement the interface method
        * @author Sk Minsar | 09-02-2024
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
                response.setBody('{"status":{"code":200,"message":"Success"},"payload":{"data":[{"Acctrefno":194062,'
                                        +'"Loan_Type":2,"Portfolio_Code_Id":0,"Loan_Group_No":0,"Transaction_Code":100,"Transrefno":194062,"Reversal_Transrefno":0,"Participant_Detail_Flag":false,"Transaction_Date":"2022-09-09","Transaction_Description":"Product Return","Transaction_Amount":1000.00, "User_Reference":"PRODUCT RETURN Central Valley CFA - Seeds"},{"Acctrefno":194062,'
                                        +'"Loan_Type":2,"Portfolio_Code_Id":0,"Loan_Group_No":0,"Transaction_Code":107,"Transrefno":194020,"Reversal_Transrefno":0,"Participant_Detail_Flag":false,"Transaction_Date":"2022-09-09","Transaction_Description":"Product Return","Transaction_Amount":1000.00, "User_Reference":"PRODUCT RETURN Central Valley CFA - Seeds"}, {"Acctrefno":194064,'
                                        +'"Loan_Type":2,"Portfolio_Code_Id":0,"Loan_Group_No":0,"Transaction_Code":107,"Transrefno":194020,"Reversal_Transrefno":0,"Participant_Detail_Flag":false,"Transaction_Date":"2022-09-09","Transaction_Description":"Product Return","Transaction_Amount":1000.00, "User_Reference":"PRODUCT RETURN Central Valley CFA - Seeds"}]}}');
            }
            return response;
        }
    }

    /**
    * @description - Exception Sceanrio test with Cl User
    * @author Sk Minsar | 09-03-2024 
    **/
    @isTest 
    static void testCalloutWithCL() {
        Profile profile = [SELECT Id FROM Profile WHERE Name='Certified Lender'];
        User objUser = IntegrationTestInitHelper.createUser(profile.Id);
        Test.setMock(HttpCalloutMock.class, new NLSLoanTransactionHttpCalloutMock());
        Test.startTest();
        System.runAs(objUser) {
            Map<String, Object> response = NLSLoanAllTransactionsCallout.nlsGetLoanTransactionsCalloutMethod('38478374', new List<String>{'194062'});
            System.assertEquals(response.size(), 0, 'Assertion Failed');
        }
        Test.stopTest();
    }

    /**
    * @description - Success Scenario test with Admin user
    * @author Sk Minsar | 09-03-2024 
    **/
    @isTest 
    static void testSingleLoanIdCalloutWithAdmin() {
        User objUser = IntegrationTestInitHelper.createAdminUser('cfa.admin@yopmail.com');
        Test.setMock(HttpCalloutMock.class, new NLSLoanTransactionHttpCalloutMock());
        Test.startTest();
        System.runAs(objUser) {
            Map<String, Object> response = NLSLoanAllTransactionsCallout.nlsGetLoanTransactionsCalloutMethod('38478374', new List<String>{'194062'});
            System.assertEquals(response.size(), 1, 'Assertion Failed');
        }
        Test.stopTest();
    }

    /**
    * @description - Success Scenario for multiple loan Id test with Admin user
    * @author Sk Minsar | 09-03-2024 
    **/
    @isTest 
    static void testMultipleLoanIdCalloutWithAdmin() {
        User objUser = IntegrationTestInitHelper.createAdminUser('cfa.admin@yopmail.com');
        Test.setMock(HttpCalloutMock.class, new NLSLoanTransactionHttpCalloutMock());
        Test.startTest();
        System.runAs(objUser) {
            Map<String, Object> response = NLSLoanAllTransactionsCallout.nlsGetLoanTransactionsCalloutMethod('38478374', new List<String>{'194062', '194064'} );
            System.assertEquals(response.size(), 1, 'Assertion Failed');
        }
        Test.stopTest();
    }

    /**
    * @description - Exception sceanario test with Grower user
    * @author Sk Minsar | 09-03-2024 
    **/
    @isTest 
    static void testCalloutWithGrower() {
        Profile profile = [SELECT Id FROM Profile WHERE Name='Grower'];
        User objUser = IntegrationTestInitHelper.createUser(profile.Id);
        Test.setMock(HttpCalloutMock.class, new NLSLoanTransactionHttpCalloutMock());
        Test.startTest();
        System.runAs(objUser) {
            Map<String, Object> response = NLSLoanAllTransactionsCallout.nlsGetLoanTransactionsCalloutMethod('38478374', new List<String>{'194062'} );
            System.assertEquals(response.size(), 0, 'Assertion Failed');
        }
        Test.stopTest();
    }

    /**
    * @description - Exception sceanario test with Invalid account Id
    * @author Sk Minsar | 09-03-2024 
    **/
    @isTest 
    static void testWithInvalidAccountId() {
        User objUser = IntegrationTestInitHelper.createAdminUser('cfa.admin@yopmail.com');
        Test.setMock(HttpCalloutMock.class, new NLSLoanTransactionHttpCalloutMock());
        Test.startTest();
        System.runAs(objUser) {
            Map<String, Object> response = NLSLoanAllTransactionsCallout.nlsGetLoanTransactionsCalloutMethod(null , new List<String>{'194062'} );
            System.assertEquals(response.size(), 0, 'Assertion Failed');
        }
        Test.stopTest();
    }

    /**
    * @description - Exception sceanario test with Invalid Loan Id
    * @author Sk Minsar | 09-03-2024 
    **/
    @isTest 
    static void testWithInvalidLoanId() {
        User objUser = IntegrationTestInitHelper.createAdminUser('cfa.admin@yopmail.com');
        Test.setMock(HttpCalloutMock.class, new NLSLoanTransactionHttpCalloutMock());
        Test.startTest();
        System.runAs(objUser) {
            Map<String, Object> response = NLSLoanAllTransactionsCallout.nlsGetLoanTransactionsCalloutMethod('38478374', new List<String>());
            System.assertEquals(response.size(), 0, 'Assertion Failed');
        }
        Test.stopTest();
    }

    /**
    * @description - Exception scenario test with invalid access token
    * @author Sk Minsar | 09-03-2024 
    **/
    @isTest 
    static void testInvalidAccessToken() {
        User objUser = IntegrationTestInitHelper.createAdminUser('cfa.admin@yopmail.com');
        Test.setMock(HttpCalloutMock.class, new NLSGetNullAccessTokenMock());
        Test.startTest();
        System.runAs(objUser) {
            Map<String, Object> response = NLSLoanAllTransactionsCallout.nlsGetLoanTransactionsCalloutMethod('38478374', new List<String>{'194062'} );
            System.assertEquals(response.size(), 0, 'Assertion Failed');
        }
        Test.stopTest();
    }

    /**
    * @description - Test With invalid request params
    * @author Sk Minsar | 09-03-2024 
    **/
    @isTest 
    static void testInvalidRequestParams() {
        User objUser = IntegrationTestInitHelper.createAdminUser('cfa.admin@yopmail.com');
        Test.setMock(HttpCalloutMock.class, new NLSLoanTransactionHttpCalloutMock());
        Test.startTest();
        System.runAs(objUser) {
            Map<String, Object> response = NLSLoanAllTransactionsCallout.nlsGetLoanTransactionsCalloutMethod(null, new List<String>{} );
            System.assertEquals(response.size(), 0, 'Assertion Failed');
        }
        Test.stopTest();
    }
}