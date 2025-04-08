/**
 * @description       : 
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 03-07-2024
 * @last modified by  :  Pritam Roy
**/
@isTest
public with sharing class NLSCalloutTest {

    @testSetup
    static void setup() {
        //Inserting Integration Family
        intframework__Integration_Family__c family = IntegrationTestInitHelper.getFamily(
            'NLS Integration');
        //Inserting Integration API Type
        intframework__Integration_API_Type__c searchLoanApiType = IntegrationTestInitHelper.getIntegrationAPIType(
            family.Id, 'Search Loans Integration API Type');
        intframework__Integration_API_Type__c getLoanApiType = IntegrationTestInitHelper.getIntegrationAPIType(
            family.Id, 'Get loan Integration API Type');
        intframework__Integration_API_Type__c loanTransactionApiType = IntegrationTestInitHelper.getIntegrationAPIType(
            family.Id, 'Loan Transactions Integration API Type');
        //Inserting Integration Provider
        intframework__Integration_Provider__c searchLoanProvider = IntegrationTestInitHelper.getIntegrationProvider(
            family.Id, 'Search Loans');
        intframework__Integration_Provider__c getLoanProvider = IntegrationTestInitHelper.getIntegrationProvider(
            family.Id, 'Get Loan');
        intframework__Integration_Provider__c loanTransactionProvider = IntegrationTestInitHelper.getIntegrationProvider(
            family.Id, 'Loan Transactions');
        //Inserting Integration Configuration
        intframework__Integration_Configuration__c searchLoanConfig = IntegrationTestInitHelper.getIntegrationConfiguration(
            searchLoanProvider.Id,'NLS Search Loans Integration Configuration','NLS');
        intframework__Integration_Configuration__c getLoanConfig = IntegrationTestInitHelper.getIntegrationConfiguration(
            getLoanProvider.Id,'NLS Get Loan Integration Configuration','NLS');
        intframework__Integration_Configuration__c loanTransactionConfig = IntegrationTestInitHelper.getIntegrationConfiguration(
            loanTransactionProvider.Id,'NLS Loan Transactions Integration Configuration','NLS');
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
                    +'"whereClause": "Id = :accountId"}],"dynamicDataParameters": [{"externalField": "partyType"},{"externalField": "statusCode"}]}}',
            'application/json',
            1
        );
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
        genesis__Business_Information__c dealerBusinessInfoObj = TestClassHelper.createBusinessInfoForDealer();
        Database.insert(dealerBusinessInfoObj, true);

        // Creating Account for Dealer
        Account dealerAccountObj = TestClassHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        Database.insert(dealerAccountObj, true);

        // Creating Contact for Dealer
        Contact dealerContactObj = TestClassHelper.createDealerContact(dealerAccountObj.Id);
        Database.insert(dealerContactObj, true);

        // creating Account for Certified Lender
        Account clAccountObj = TestClassHelper.createCLAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
        Database.insert(clAccountObj, true);

        // Creating Contact for Certified Lender
        Contact clContactObj = TestClassHelper.createCLContact(clAccountObj.Id);
        Database.insert(clContactObj, true);

        // creating user for certified lender
        User clUser = TestClassHelper.createCLUser(clContactObj.Id);
        Database.insert(clUser, true);

        // creating relationship of certified lender
        clcommon__Reciprocal_Role__c clRoleObj = TestClassHelper.createReciprocalRole('Certified Lender');
        Database.insert(clRoleObj, true);
        clcommon__Relationship__c objRelationship = TestClassHelper.createCLDealerRelationship(clRoleObj, 
                                                                                                    dealerAccountObj.Id, 
                                                                                                    clAccountObj.Id);
        Database.insert(objRelationship, true);
        
        // creating borrower
        clcommon__Legal_Entity__c entityObj = TestClassHelper.createLegalEntity(PortalConstants.SOLE_PROP_ENTITY);
        Database.insert(entityObj, true);

        Account borrowerAccountObj = TestClassHelper.createSolePropAccount(entityObj,dealerBusinessInfoObj.Id);
        Database.insert(borrowerAccountObj, true);

        Contact borrowerContactObj = TestClassHelper.createBorrowerContact(borrowerAccountObj.Id);    
        Database.insert(borrowerContactObj, true);

        User borrowerUserObj = TestClassHelper.createBorrowerUser(borrowerContactObj.Id);
        Database.insert(borrowerUserObj, true);

        // Creating CL Product for Application
        clcommon__CL_Product__c clProductObj = TestClassHelper.createCLProductForApplication();
        Database.insert(clProductObj, true);

        // Creating CL Purpose for Application
        clcommon__CL_Purpose__c clPurposeObj = TestClassHelper.createCLPurposeForApplication();
        Database.insert(clPurposeObj, true);


        Map<String,Id> paramForApplicationMap = new Map<String,Id>();
        paramForApplicationMap.put('dealerAccountId', dealerAccountObj.Id);
        paramForApplicationMap.put('clProductId', clProductObj.Id);
        paramForApplicationMap.put('clPurposeId', clPurposeObj.Id);
        paramForApplicationMap.put('borrowerAccountId', borrowerAccountObj.Id);
        paramForApplicationMap.put('borrowerContactId', borrowerContactObj.Id);
        paramForApplicationMap.put('clAccountId', clAccountObj.Id);
        genesis__Applications__c applicationObj = TestClassHelper.createCurrCropYearApplication(paramForApplicationMap);
        applicationObj.Entity_Documents_Task_Pending__c = true;
        applicationObj.AOI_Task_Pending__c = true;
        applicationObj.Collateral_Report_Task_Pending__c = true;
        applicationObj.Payoff_Confirmation_Task_Pending__c = true;
        applicationObj.Lien_Search_Task_Pending__c = true;
        applicationObj.Lien_Subordination_Task_Pending__c = true;
        applicationObj.Security_Notice_Task_Pending__c = true;
        applicationObj.CNS_Task_Pending__c = true;
        applicationObj.Signed_Agreement_Task_Pending__c = true;
        applicationObj.Spousal_Consent_Task_Pending__c = true;
        applicationObj.UCC_Amendment_Task_Pending__c = true;
        applicationObj.UCC_Filing_Task_Pending__c = true;
        applicationObj.Customized_Approval_Task_Pending__c = true;
 
        Database.insert(applicationObj, true);


    }
    /**
     * @description       : Mock Class For Failed Response
     * @author            : Arka Jyoti Deb
    **/
    public class NLSGetNullAccessTokenMock implements HttpCalloutMock {
        
        /**
        * @description : Response Method for Failiure
        * @author  Pritam Roy | 03-07-2024 
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
     * @description       : Mock Class For Success Response
     * @author            : Arka Jyoti Deb
    **/
    public class NLSGetAccessTokenMock implements HttpCalloutMock {
        /**
         * @description : Response Method for Success
         * @param request 
         * @return  `HTTPResponse`
         */
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setStatus('SUCCESS');
            response.setHeader('Content-Type', 'application/json');
            if(request.getEndpoint().contains('token')){
                String token = '{"access_token":"eyJhbGciOiJSUzI1NiIsI","expires_in":300,"token_type":"Bearer"}';
                response.setBody(token);
            }
            else{
                response.setBody('{ "status": { "code": 200, "message": "Success" }, "payload": { "data": "" }}');
            }
            return response;
        }
     }

    /**
    * @description : Test NLS Loan Search Callout with status code 1
    * @author  Pritam Roy | 03-07-2024 
    **/
    @isTest 
    static void testNlsSearchLoanCalloutMethod() {
        Map<String, Object> requestMap = new Map<String, Object>();
        Profile profile = [SELECT Id FROM Profile WHERE Name='Certified Lender'];
        User objUser = IntegrationTestInitHelper.createUser(profile.Id);
        requestMap.put(ConstantValues.STATUS_CODE, '1');
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new NLSGetLoanHttpCalloutMock());
        Test.startTest();
        System.runAs(objUser) {
            PortalNLSActiveLoanAPI testApi = new PortalNLSActiveLoanAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status);
        }
        Test.stopTest();
    }
    /**
    * @description : Test NLS Loan Search Callout with status code 0
    * @author  Pritam Roy | 03-07-2024 
    **/
    @isTest 
    static void testNlsSearchLoanCalloutMethodSuccess() {
        Map<String, Object> requestMap = new Map<String, Object>();
        Profile profile = [SELECT Id FROM Profile WHERE Name='Grower'];
        User objUser = IntegrationTestInitHelper.createUser(profile.Id);
        requestMap.put(ConstantValues.STATUS_CODE, '0');
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new NLSGetLoanHttpCalloutMock());
        Test.startTest();
        System.runAs(objUser) {
            PortalNLSActiveLoanAPI testApi = new PortalNLSActiveLoanAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Assertion Failed');
        }
        Test.stopTest();
    }
    /**
    * @description : Test NLS Loan Search Callout Exception
    * @author  Pritam Roy | 03-07-2024 
    **/
    @isTest 
    static void testNlsSearchLoanCalloutMethodException() {
        Map<String, Object> requestMap = new Map<String, Object>();
        Profile profile = [SELECT Id FROM Profile WHERE Name='Certified Lender'];
        User objUser = IntegrationTestInitHelper.createUser(profile.Id);
        requestMap.put(ConstantValues.STATUS_CODE, '5');
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new NLSGetNullAccessTokenMock());
        Test.startTest();
        System.runAs(objUser) {
            PortalNLSActiveLoanAPI testApi = new PortalNLSActiveLoanAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
        }
        Test.stopTest();
    }
    /**
    * @description : Test NLSGetLoanCallout Exception
    * @author  Pritam Roy | 03-07-2024 
    **/
    @isTest 
    static void testNlsGetLoanCalloutMethod() {
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
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
        }
        Test.stopTest();
    }
    /**
    * @description :Test NLSGetLoanCallout Exception for Null Access Token
    * @author  Pritam Roy | 03-07-2024 
    **/
    @isTest 
    static void testNlsGetLoanCalloutMethod1() {
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
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
        }
        Test.stopTest();
    }

    /**
    * @description : NlsLoanTransactionCallout Exception
    * @author  Pritam Roy | 03-07-2024 
    **/
    @isTest 
    static void testNlsLoanTransactionCalloutMethod() {
        Map<String, Object> requestMap = new Map<String, Object>();
        Profile profile = [SELECT Id FROM Profile WHERE Name='Certified Lender'];
        User objUser = IntegrationTestInitHelper.createUser(profile.Id);
        requestMap.put(ConstantValues.LOAN_ID, 123456 );
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new NLSGetLoanHttpCalloutMock());
        Test.startTest();
        System.runAs(objUser) {
            PortalNLSLoanTransactionsAPI testApi = new PortalNLSLoanTransactionsAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
        }
        Test.stopTest();
    }
    /**
    * @description : NlsLoanTransactionCallout Exception for Null Access Token
    * @author  Pritam Roy | 03-07-2024 
    **/
    @isTest 
    static void testNlsLoanTransactionCalloutMethod1() {
        Map<String, Object> requestMap = new Map<String, Object>();
        Profile profile = [SELECT Id FROM Profile WHERE Name='Certified Lender'];
        User objUser = IntegrationTestInitHelper.createUser(profile.Id);
        requestMap.put(ConstantValues.LOAN_ID, 123456);
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new NLSGetNullAccessTokenMock());
        Test.startTest();
        System.runAs(objUser) {
            PortalNLSLoanTransactionsAPI testApi = new PortalNLSLoanTransactionsAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
        }
        Test.stopTest();
    }


    /**
    * @description : Test NLSXmlImportCallout for ACH
    * @author  Pritam Roy | 03-07-2024 
    **/
    @isTest
    static void testNLSXmlImportCalloutMethodForACH(){
        genesis__Funding_Transaction__c objFundingTransaction = new genesis__Funding_Transaction__c();
        objFundingTransaction.genesis__Cleared__c = true;
        objFundingTransaction.Posted_to_NLS__c = false;

        clcommon__Payment_Mode__c paymentMode= new clcommon__Payment_Mode__c();
        paymentMode.Name = ConstantValues.ACH;
        Database.insert(paymentMode);
        Profile profile = [SELECT Id FROM Profile WHERE Name='Certified Lender'];
        User objUser = IntegrationTestInitHelper.createUser(profile.Id);
        Test.setMock(HttpCalloutMock.class, new NLSGetAccessTokenMock());
        Test.startTest();
        System.runAs(objUser) {
            NLSCallout.nlsXmlImportCalloutMethod(new List<String>{ConstantValues.ACH});
        }
        Test.stopTest();
    }

    /**
    * @description : Test NLSXmlImportCallout for Draft
    * @author  Pritam Roy | 03-07-2024 
    **/
    @isTest
    static void testNLSXmlImportCalloutMethodForDraft(){
        genesis__Funding_Transaction__c objFundingTransaction = new genesis__Funding_Transaction__c();
        objFundingTransaction.genesis__Cleared__c = true;
        objFundingTransaction.Posted_to_NLS__c = false;

        clcommon__Payment_Mode__c paymentMode= new clcommon__Payment_Mode__c();
        paymentMode.Name = ConstantValues.DRAFT;
        Database.insert(paymentMode);
        Profile profile = [SELECT Id FROM Profile WHERE Name='Certified Lender'];
        User objUser = IntegrationTestInitHelper.createUser(profile.Id);
        Test.setMock(HttpCalloutMock.class, new NLSGetAccessTokenMock());
        Test.startTest();
        System.runAs(objUser) {
            NLSCallout.nlsXmlImportCalloutMethod(new List<String>{ConstantValues.DRAFT});
        }
        Test.stopTest();
    }

    /**
    * @description : Test NLSXmlImportCallout fro MobileDeposit
    * @author  Pritam Roy | 03-07-2024 
    **/
    @isTest
    static void testNLSXmlImportCalloutMethodForMobileDeposit(){
        genesis__Funding_Transaction__c objFundingTransaction = new genesis__Funding_Transaction__c();
        objFundingTransaction.genesis__Cleared__c = true;
        objFundingTransaction.Posted_to_NLS__c = false;

        clcommon__Payment_Mode__c paymentMode= new clcommon__Payment_Mode__c();
        paymentMode.Name = ConstantValues.MOBILE_DEPOSIT;
        Database.insert(paymentMode);
        Profile profile = [SELECT Id FROM Profile WHERE Name='Certified Lender'];
        User objUser = IntegrationTestInitHelper.createUser(profile.Id);
        Test.setMock(HttpCalloutMock.class, new NLSGetAccessTokenMock());
        Test.startTest();
        System.runAs(objUser) {
            NLSCallout.nlsXmlImportCalloutMethod(new List<String>{ConstantValues.MOBILE_DEPOSIT});
        }
        Test.stopTest();
    }

    /**
    * @description : Test NLSGetLoanStatementsFileCallout
    * @author  Pritam Roy | 03-07-2024 
    **/
    @isTest
    static void testNLSGetLoanStatementsFileCalloutMethod(){
        Statement_Code__mdt statementCode = [SELECT Id, DeveloperName, Label FROM Statement_Code__mdt 
        Limit 1];
        Profile profile = [SELECT Id FROM Profile WHERE Name='Certified Lender'];
        User objUser = IntegrationTestInitHelper.createUser(profile.Id);
        Test.setMock(HttpCalloutMock.class, new NLSGetAccessTokenMock());
        Test.startTest();
        System.runAs(objUser) {
            NLSCallout.nlsGetLoanStatementsFileCalloutMethod(objUser.accountId,statementCode.id);
        }
        Test.stopTest();
    }

    /**
    * @description : Test NLSGetLoanTransactionsCallout
    * @author  Pritam Roy | 03-07-2024 
    **/
    @isTest
    static void testNLSGetLoanTransactionsCalloutMethod(){
        genesis__Applications__c application = [Select id FROM genesis__Applications__c LIMIT 1];

        Profile profile = [SELECT Id FROM Profile WHERE Name='Certified Lender'];
        User objUser = IntegrationTestInitHelper.createUser(profile.Id);
        Test.setMock(HttpCalloutMock.class, new NLSGetAccessTokenMock());
        Test.startTest();
        System.runAs(objUser) {
            NLSCallout.nlsGetLoanTransactionsCalloutMethod(objUser.accountId,application.id);
        }
        Test.stopTest();
    }

    /**
    * @description : Test NLSGetLoanStatementsCallout
    * @author  Pritam Roy | 03-07-2024 
    **/
    @isTest
    static void testNLSGetLoanStatementsCalloutMethod(){
        genesis__Applications__c application = [Select id FROM genesis__Applications__c LIMIT 1];

        Profile profile = [SELECT Id FROM Profile WHERE Name='Certified Lender'];
        User objUser = IntegrationTestInitHelper.createUser(profile.Id);
        Test.setMock(HttpCalloutMock.class, new NLSGetAccessTokenMock());
        Test.startTest();
        System.runAs(objUser) {
            NLSCallout.nlsGetLoanStatementsCalloutMethod(objUser.accountId,application.id,'Loan Statement');
        }
        Test.stopTest();
    }

}