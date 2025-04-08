/**
 * @description       : Test class for NLSGetParentLoanDetailsSchedule, NLSLoanDetailsCalloutBatch, NLSLoanDetailsAdapter
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 11-29-2024
 * @last modified by  : Ayan Bhowmik
**/

@isTest 
public with sharing class TestNLSLoanDetailsCalloutBatch {
    @testSetup
    static void setup() {
        //Inserting Integration Family
        intframework__Integration_Family__c intFamilyObj = IntegrationTestInitHelper.getFamily(
            'NLS Integration');
        //Inserting Integration API Type
        intframework__Integration_API_Type__c getLoanApiTypeObj = IntegrationTestInitHelper.getIntegrationAPIType(
            intFamilyObj.Id, 'Get loan Integration API Type');
        intframework__Integration_API_Type__c getLoanDetailsApiTypeObj = IntegrationTestInitHelper.getIntegrationAPIType(
            intFamilyObj.Id, 'Get Loan Details Integration API Type');
        intframework__Integration_API_Type__c getCreditLinesApiTypeObj = IntegrationTestInitHelper.getIntegrationAPIType(
            intFamilyObj.Id, 'Get Credit Lines Integration API Type');
        intframework__Integration_API_Type__c getPayoffDetailApiTypeObj = IntegrationTestInitHelper.getIntegrationAPIType(
            intFamilyObj.Id, 'Get Payoff Details Integration API Type');
        //Inserting Integration Provider
        intframework__Integration_Provider__c getLoanProviderObj = IntegrationTestInitHelper.getIntegrationProvider(
            intFamilyObj.Id, 'Get Loan');
        intframework__Integration_Provider__c getLoanDetailsProviderObj = IntegrationTestInitHelper.getIntegrationProvider(
            intFamilyObj.Id, 'Loan Details');
        intframework__Integration_Provider__c getCreditLinesProviderObj = IntegrationTestInitHelper.getIntegrationProvider(
            intFamilyObj.Id, 'Credit Lines');
        intframework__Integration_Provider__c getPayofDetailProviderObj = IntegrationTestInitHelper.getIntegrationProvider(
            intFamilyObj.Id, 'Payoff Details');
        //Inserting Integration Configuration
        intframework__Integration_Configuration__c getLoanConfigObj = IntegrationTestInitHelper.getIntegrationConfiguration(
            getLoanProviderObj.Id,'NLS Get Loan Integration Configuration','NLS');
        intframework__Integration_Configuration__c getLoanDetailsConfigObj = IntegrationTestInitHelper.getIntegrationConfiguration(
            getLoanDetailsProviderObj.Id,'NLS Loan Details Integration Configuration','NLS');
        intframework__Integration_Configuration__c getCreditLinesConfigObj = IntegrationTestInitHelper.getIntegrationConfiguration(
            getCreditLinesProviderObj.Id,'NLS Credit Lines Integration Configuration','NLS');
        intframework__Integration_Configuration__c getPayoffDetailsConfigObj = IntegrationTestInitHelper.getIntegrationConfiguration(
            getPayofDetailProviderObj.Id,'NLS Payoff Details Integration Configuration','NLS');
        //Inserting Integration API Configuration
        IntegrationTestInitHelper.getIntegrationAPIConfiguration(
            intFamilyObj.Id,
            getLoanApiTypeObj.Id,
            getLoanProviderObj.Id,
            getLoanConfigObj.Id,
            false,
            'NLSGetLoanAdapter',
            'GET',
            'NLS',
            'loans/loanId',
            '{"thirdPartySystem": {"name": "Get Loan","filters": [{"objectAPI": "genesis__Applications__c","objectAlias": "Application","fields": [{"externalField": "ID","fieldAPI": "Id"},{"externalField": "loanId","fieldAPI": "Loan_Id__c"}],"whereClause": "Id IN :applicationIdList"}]}}',
            'application/json',
            1
        );
        IntegrationTestInitHelper.getIntegrationAPIConfiguration(
            intFamilyObj.Id,
            getLoanDetailsApiTypeObj.Id,
            getLoanDetailsProviderObj.Id,
            getLoanDetailsConfigObj.Id,
            false,
            'NLSLoanDetailsAdapter',
            'GET',
            'NLS',
            'loans/loanId/detail1',
            '{"thirdPartySystem": {"name": "Get Loan Details","filters": [{"objectAPI": "genesis__Applications__c","objectAlias": "Application","fields": [{"externalField": "ID","fieldAPI": "Id"},{"externalField": "loanId","fieldAPI": "Loan_Id__c"}],"whereClause": "Id IN :applicationIdList"}]}}',
            'application/json',
            1
        );
        IntegrationTestInitHelper.getIntegrationAPIConfiguration(
            intFamilyObj.Id,
            getCreditLinesApiTypeObj.Id,
            getCreditLinesProviderObj.Id,
            getCreditLinesConfigObj.Id,
            false,
            'NLSCreditLinesAdapter',
            'GET',
            'NLS',
            'loans/loanId/credit-lines',
            '{"thirdPartySystem": {"name": "Get Credit Lines","filters": [{"objectAPI": "genesis__Applications__c","objectAlias": "Application","fields": [{"externalField": "ID","fieldAPI": "Id"},{"externalField": "loanId","fieldAPI": "Loan_Id__c"},{"externalField": "totalProductReturnAmount","fieldAPI": "Product_Return_Amount__c"}],"whereClause": "Id IN :applicationIdList"}]}}',
            'application/json',
            1
        );
        IntegrationTestInitHelper.getIntegrationAPIConfiguration(
            intFamilyObj.Id,
            getPayoffDetailApiTypeObj.Id,
            getPayofDetailProviderObj.Id,
            getPayoffDetailsConfigObj.Id,
            false,
            'NLSPayoffDetailsAdapter',
            'GET',
            'NLS',
            'loans/{!loan_id}/payoff-details?payoffDate={!payoffDate}',
            '{"thirdPartySystem": {"name": "Get Payoff Details","filters": [{"objectAPI": "genesis__Applications__c","objectAlias": "Application","fields": [{"externalField": "ID","fieldAPI": "Id"},{"externalField": "loanId","fieldAPI": "Loan_Id__c"}],"whereClause": "Id IN :applicationIdList"}]}}',
            'application/json',
            1
        );

        genesis__Business_Information__c businessInfoObj = LoanServicingTestHelper.createBusinessInfoForDealer();
        Database.insert(businessInfoObj,true);

        Account dealerAccountObj = LoanServicingTestHelper.createDealerAccount(businessInfoObj.Id);
        Database.insert(dealerAccountObj,true);

        Account clAccountObj = LoanServicingTestHelper.createCLAccount(businessInfoObj.Id, dealerAccountObj.Id);
        Database.insert(clAccountObj,true);

        Contact clContactObj = LoanServicingTestHelper.createCLContact(clAccountObj.Id);
        Database.insert(clContactObj,true);

        clcommon__Legal_Entity__c legalEntityObj = LoanServicingTestHelper.createLegalEntity('Individual(s) - Sole Proprietorship');
        Database.insert(legalEntityObj,true);
        
        Account borrowerAccountObj = LoanServicingTestHelper.createSolePropAccount(legalEntityObj,businessInfoObj.Id);
        Database.insert(borrowerAccountObj,true);

        Contact borrowerContactObj = LoanServicingTestHelper.createBorrowerContact(borrowerAccountObj.Id);
        Database.insert(borrowerContactObj,true);

        clcommon__CL_Purpose__c clPurposeObj = LoanServicingTestHelper.createCLPurposeForApplication();
        Database.insert(clPurposeObj, true);

        clcommon__CL_Product__c clProductObj = LoanServicingTestHelper.createCLProductForApplication();
        Database.insert(clProductObj, true);

        List<genesis__Credit_Rating_Matrix__c> creditRatingMatrixList = new List<genesis__Credit_Rating_Matrix__c>();
        creditRatingMatrixList.add(LoanServicingTestHelper.getCreditRatingMatrix('Tier 1'));
        creditRatingMatrixList.add(LoanServicingTestHelper.getCreditRatingMatrix('Tier 2'));
        creditRatingMatrixList.add(LoanServicingTestHelper.getCreditRatingMatrix('Tier 3'));
        creditRatingMatrixList.add(LoanServicingTestHelper.getCreditRatingMatrix('Tier 4'));
        Database.insert(creditRatingMatrixList,true);

        Map<String,Id> applicationParamMap = new Map<String,Id>{
            'dealerAccountId' => dealerAccountObj.Id,
            'borrowerAccountId' => borrowerAccountObj.Id,
            'borrowerContactId' => borrowerContactObj.Id,
            'clAccountId' => clAccountObj.Id,
            'clProductId' => clProductObj.Id,
            'clPurposeId' => clPurposeObj.Id
        };
        genesis__Applications__c applicationObj = LoanServicingTestHelper.createCurrCropYearApplication(applicationParamMap);
        Database.insert(applicationObj,true);
    }

    /**
     * @description       : Setting up the Mock Response of for Userdef03 Streamline
     * @author            : Suraj kumar
     * @last modified on  : 11-29-2024
     * @last modified by  : Ayan Bhowmik
    **/
    public class StreamlineCalloutMock implements HttpCalloutMock {
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
            else if(request.getEndpoint().contains('detail1')){
                response.setBody('{"status": {"code": 200,"message": "Success"},"payload": {"data": {"Acctrefno": 135567,"Userdef01": "2020","Userdef02": "30%","Userdef03": "STREAMLINE","Userdef04": null,"Userdef05": "115282"}}}');
            }
            else if(request.getEndpoint().contains('credit-lines')){
                response.setBody('{"status": {"code": 200,"message": "Success"},"payload": {"totalCount": 1,"count": 1,"data": [{"Acctrefno": 262947,"Credit_Line_Limit": 9000.00,"Credit_Total_Draw_Limit": 1100.00,"Option_Flags": 0}]}}');
            }
            else if(request.getEndpoint().contains('payoff-details')){
                response.setBody('');
            }
            else{
                response.setBody('');
            }
            return response;
        }
    }

    /**
     * @description       : Setting up the Mock Response of for Userdef03 TIER 2
     * @author            : Suraj kumar
     * @last modified on  : 11-29-2024
     * @last modified by  : Ayan Bhowmik
    **/
    public class TierTwoCalloutMock implements HttpCalloutMock {
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
            else if(request.getEndpoint().contains('detail1')){
                response.setBody('{"status": {"code": 200,"message": "Success"},"payload": {"data": {"Acctrefno": 135567,"Userdef01": "2020","Userdef02": "30%","Userdef03": "TIER 2","Userdef04": null,"Userdef05": "115282"}}}');
            }
            else if(request.getEndpoint().contains('credit-lines')){
                response.setBody('{"status": {"code": 200,"message": "Success"},"payload": {"totalCount": 1,"count": 1,"data": [{"Acctrefno": 262947,"Credit_Line_Limit": 9000.00,"Credit_Total_Draw_Limit": 1100.00,"Option_Flags": 0}]}}');
            }
            else if(request.getEndpoint().contains('payoff-details')){
                response.setBody('');
            }
            else{
                response.setBody('');
            }
            return response;
        }
    }
    /**
     * @description       : Setting up the Mock Response of for Userdef03 TIER 1
     * @author            : Suraj kumar
     * @last modified on  : 11-29-2024
     * @last modified by  : Ayan Bhowmik
    **/
    public class TierOneCalloutMock implements HttpCalloutMock {
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
            else if(request.getEndpoint().contains('detail1')){
                response.setBody('{"status": {"code": 200,"message": "Success"},"payload": {"data": {"Acctrefno": 135567,"Userdef01": "2020","Userdef02": "30%","Userdef03": "TIER 1","Userdef04": null,"Userdef05": "115282"}}}');
            }
            else if(request.getEndpoint().contains('credit-lines')){
                response.setBody('{"status": {"code": 200,"message": "Success"},"payload": {"totalCount": 1,"count": 1,"data": [{"Acctrefno": 262947,"Credit_Line_Limit": 9000.00,"Credit_Total_Draw_Limit": 1100.00,"Option_Flags": 0}]}}');
            }
            else if(request.getEndpoint().contains('payoff-details')){
                response.setBody('');
            }
            else{
                response.setBody('');
            }
            return response;
        }
    }
    /**
     * @description       : Setting up the Mock Response of for Userdef03 UNSECURED
     * @author            : Suraj kumar
     * @last modified on  : 11-29-2024
     * @last modified by  : Ayan Bhowmik
    **/
    public class UnsecuredCalloutMock implements HttpCalloutMock {
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
            else if(request.getEndpoint().contains('detail1')){
                response.setBody('{"status": {"code": 200,"message": "Success"},"payload": {"data": {"Acctrefno": 135567,"Userdef01": "2020","Userdef02": "30%","Userdef03": "UNSECURED","Userdef04": null,"Userdef05": "115282"}}}');
            }
            else if(request.getEndpoint().contains('credit-lines')){
                response.setBody('{"status": {"code": 200,"message": "Success"},"payload": {"totalCount": 1,"count": 1,"data": [{"Acctrefno": 262947,"Credit_Line_Limit": 9000.00,"Credit_Total_Draw_Limit": 1100.00,"Option_Flags": 0}]}}');
            }
            else if(request.getEndpoint().contains('payoff-details')){
                response.setBody('');
            }
            else{
                response.setBody('');
            }
            return response;
        }
    }
    /**
     * @description       : Setting up the Mock Response of for Userdef03 TIER 3
     * @author            : Suraj kumar
     * @last modified on  : 11-29-2024
     * @last modified by  : Ayan Bhowmik
    **/
    public class TierThreeCalloutMock implements HttpCalloutMock {
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
            else if(request.getEndpoint().contains('detail1')){
                response.setBody('{"status": {"code": 200,"message": "Success"},"payload": {"data": {"Acctrefno": 135567,"Userdef01": "2020","Userdef02": "30%","Userdef03": "TIER 3","Userdef04": null,"Userdef05": "115282"}}}');
            }
            else if(request.getEndpoint().contains('credit-lines')){
                response.setBody('{"status": {"code": 200,"message": "Success"},"payload": {"totalCount": 1,"count": 1,"data": [{"Acctrefno": 262947,"Credit_Line_Limit": 9000.00,"Credit_Total_Draw_Limit": 1100.00,"Option_Flags": 0}]}}');
            }
            else if(request.getEndpoint().contains('payoff-details')){
                response.setBody('');
            }
            else{
                response.setBody('');
            }
            return response;
        }
    }
    /**
     * @description       : Setting up the Mock Response of for Userdef03 STANDARD
     * @author            : Suraj kumar
     * @last modified on  : 11-29-2024
     * @last modified by  : Ayan Bhowmik
    **/
    public class StandardCalloutMock implements HttpCalloutMock {
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
            else if(request.getEndpoint().contains('detail1')){
                response.setBody('{"status": {"code": 200,"message": "Success"},"payload": {"data": {"Acctrefno": 135567,"Userdef01": "2020","Userdef02": "30%","Userdef03": "STANDARD","Userdef04": null,"Userdef05": "115282"}}}');
            }
            else if(request.getEndpoint().contains('credit-lines')){
                response.setBody('{"status": {"code": 200,"message": "Success"},"payload": {"totalCount": 1,"count": 1,"data": [{"Acctrefno": 262947,"Credit_Line_Limit": 9000.00,"Credit_Total_Draw_Limit": 1100.00,"Option_Flags": 0}]}}');
            }
            else if(request.getEndpoint().contains('payoff-details')){
                response.setBody('');
            }
            else{
                response.setBody('');
            }
            return response;
        }
    }

    /**
     * @description       : Setting up the Mock Response of for Userdef03 Tier 4
     * @author            : Suraj kumar
     * @last modified on  : 11-29-2024
     * @last modified by  : Ayan Bhowmik
    **/
    public class TierFourCalloutMock implements HttpCalloutMock {
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
            else if(request.getEndpoint().contains('detail1')){
                response.setBody('{"status": {"code": 200,"message": "Success"},"payload": {"data": {"Acctrefno": 135567,"Userdef01": "2020","Userdef02": "30%","Userdef03": "TIER 4","Userdef04": null,"Userdef05": "115282"}}}');
            }
            else if(request.getEndpoint().contains('credit-lines')){
                response.setBody('{"status": {"code": 200,"message": "Success"},"payload": {"totalCount": 1,"count": 1,"data": [{"Acctrefno": 262947,"Credit_Line_Limit": 9000.00,"Credit_Total_Draw_Limit": 1100.00,"Option_Flags": 0}]}}');
            }
            else if(request.getEndpoint().contains('payoff-details')){
                response.setBody('');
            }
            else{
                response.setBody('');
            }
            return response;
        }
    }

    /**
     * @description       : Setting up the Mock Response of for Empty Payload body.
     * @author            : Suraj kumar
     * @last modified on  : 11-29-2024
     * @last modified by  : Ayan Bhowmik
    **/
    public class EmptyPayloadCalloutMock implements HttpCalloutMock {
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
            else if(request.getEndpoint().contains('detail1')){
                response.setBody('{"status": {"code": 200,"message": "Success"},"payload": ""}');
            }
            else if(request.getEndpoint().contains('credit-lines')){
                response.setBody('{"status": {"code": 200,"message": "Success"},"payload": {"totalCount": 1,"count": 1,"data": [{"Acctrefno": 262947,"Credit_Line_Limit": 9000.00,"Credit_Total_Draw_Limit": 1100.00,"Option_Flags": 0}]}}');
            }
            else if(request.getEndpoint().contains('payoff-details')){
                response.setBody('');
            }
            else{
                response.setBody('');
            }
            return response;
        }
    }

    /**
     * @description       : Setting up the Mock Response of FAILED status
     * @author            : Suraj kumar
     * @last modified on  : 11-29-2024
     * @last modified by  : Ayan Bhowmik
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
    * @description : Test class for NLSLoanDetailsAdapter for Streamline
    * @author Suraj Kumar | 09-10-2024 
    **/
    @isTest
    private static void testCalloutBatchStreamline(){
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new StreamlineCalloutMock());
        System.runAs(userObj){
            Test.startTest();
            NLSGetParentLoanDetailsSchedule schedulePricing = new NLSGetParentLoanDetailsSchedule();
            String cronExpression = '0 0 23 * * ?';
            System.schedule('Test Get Parent Loan', cronExpression, schedulePricing);
            Test.stopTest();
            ApexClass calloutBatch = [SELECT Id FROM ApexClass WHERE Name = 'NLSLoanDetailsCalloutBatch'];
            AsyncApexJob jobObj = [SELECT Id, ApexClassId, Status FROM AsyncApexJob WHERE ApexClassId =:calloutBatch.Id];
            System.assert(jobObj.Status != null, 'Assertion Failed');
        }
    }
    /**
    * @description : Test class for NLSLoanDetailsAdapter for Tier 2
    * @author Suraj Kumar | 09-10-2024 
    **/
    @isTest
    private static void testCalloutBatchTierTwo(){
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new TierTwoCalloutMock());
        System.runAs(userObj){
            Test.startTest();
            NLSGetParentLoanDetailsSchedule schedulePricing = new NLSGetParentLoanDetailsSchedule();
            String cronExpression = '0 0 23 * * ?';
            System.schedule('Test Get Parent Loan', cronExpression, schedulePricing);
            Test.stopTest();
            ApexClass calloutBatch = [SELECT Id FROM ApexClass WHERE Name = 'NLSLoanDetailsCalloutBatch'];
            AsyncApexJob jobObj = [SELECT Id, ApexClassId, Status FROM AsyncApexJob WHERE ApexClassId =:calloutBatch.Id];
            System.assert(jobObj.Status != null, 'Assertion Failed');
        }
    }

    /**
    * @description : Test class for NLSLoanDetailsAdapter for Tier 1
    * @author Suraj Kumar | 09-10-2024 
    **/
    @isTest
    private static void testCalloutBatchTierOne(){
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new TierOneCalloutMock());
        System.runAs(userObj){
            Test.startTest();
            NLSGetParentLoanDetailsSchedule schedulePricing = new NLSGetParentLoanDetailsSchedule();
            String cronExpression = '0 0 23 * * ?';
            System.schedule('Test Get Parent Loan', cronExpression, schedulePricing);
            Test.stopTest();
            ApexClass calloutBatch = [SELECT Id FROM ApexClass WHERE Name = 'NLSLoanDetailsCalloutBatch'];
            AsyncApexJob jobObj = [SELECT Id, ApexClassId, Status FROM AsyncApexJob WHERE ApexClassId =:calloutBatch.Id];
            System.assert(jobObj.Status != null, 'Assertion Failed');
        }
    }

    /**
    * @description : Test class for NLSLoanDetailsAdapter for Unsecured
    * @author Suraj Kumar | 09-10-2024 
    **/
    @isTest
    private static void testCalloutBatchUnsecured(){
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new UnsecuredCalloutMock());
        System.runAs(userObj){
            Test.startTest();
            NLSGetParentLoanDetailsSchedule schedulePricing = new NLSGetParentLoanDetailsSchedule();
            String cronExpression = '0 0 23 * * ?';
            System.schedule('Test Get Parent Loan', cronExpression, schedulePricing);
            Test.stopTest();
            ApexClass calloutBatch = [SELECT Id FROM ApexClass WHERE Name = 'NLSLoanDetailsCalloutBatch'];
            AsyncApexJob jobObj = [SELECT Id, ApexClassId, Status FROM AsyncApexJob WHERE ApexClassId =:calloutBatch.Id];
            System.assert(jobObj.Status != null, 'Assertion Failed');
        }
    }

    /**
    * @description : Test class for NLSLoanDetailsAdapter for Tier 3
    * @author Suraj Kumar | 09-10-2024 
    **/
    @isTest
    private static void testCalloutBatchTierThree(){
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new TierThreeCalloutMock());
        System.runAs(userObj){
            Test.startTest();
            NLSGetParentLoanDetailsSchedule schedulePricing = new NLSGetParentLoanDetailsSchedule();
            String cronExpression = '0 0 23 * * ?';
            System.schedule('Test Get Parent Loan', cronExpression, schedulePricing);
            Test.stopTest();
            ApexClass calloutBatch = [SELECT Id FROM ApexClass WHERE Name = 'NLSLoanDetailsCalloutBatch'];
            AsyncApexJob jobObj = [SELECT Id, ApexClassId, Status FROM AsyncApexJob WHERE ApexClassId =:calloutBatch.Id];
            System.assert(jobObj.Status != null, 'Assertion Failed');
        }
    }

    /**
    * @description : Test class for NLSLoanDetailsAdapter for Standard
    * @author Suraj Kumar | 09-10-2024 
    **/
    @isTest
    private static void testCalloutBatchStandard(){
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new StandardCalloutMock());
        System.runAs(userObj){
            Test.startTest();
            NLSGetParentLoanDetailsSchedule schedulePricing = new NLSGetParentLoanDetailsSchedule();
            String cronExpression = '0 0 23 * * ?';
            System.schedule('Test Get Parent Loan', cronExpression, schedulePricing);
            Test.stopTest();
            ApexClass calloutBatch = [SELECT Id FROM ApexClass WHERE Name = 'NLSLoanDetailsCalloutBatch'];
            AsyncApexJob jobObj = [SELECT Id, ApexClassId, Status FROM AsyncApexJob WHERE ApexClassId =:calloutBatch.Id];
            System.assert(jobObj.Status != null, 'Assertion Failed');
        }
    }

    /**
    * @description : Test class for NLSLoanDetailsAdapter for Tier 4
    * @author Suraj Kumar | 09-10-2024 
    **/
    @isTest
    private static void testCalloutBatchTierFour(){
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new TierFourCalloutMock());
        System.runAs(userObj){
            Test.startTest();
            NLSGetParentLoanDetailsSchedule schedulePricing = new NLSGetParentLoanDetailsSchedule();
            String cronExpression = '0 0 23 * * ?';
            System.schedule('Test Get Parent Loan', cronExpression, schedulePricing);
            Test.stopTest();
            ApexClass calloutBatch = [SELECT Id FROM ApexClass WHERE Name = 'NLSLoanDetailsCalloutBatch'];
            AsyncApexJob jobObj = [SELECT Id, ApexClassId, Status FROM AsyncApexJob WHERE ApexClassId =:calloutBatch.Id];
            System.assert(jobObj.Status != null, 'Assertion Failed');
        }
    }

    /**
    * @description : Test class for NLSLoanDetailsAdapter for Null Mock response
    * @author Suraj Kumar | 09-10-2024 
    **/
    @isTest
    private static void testCalloutBatchNullAccessToken(){
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new NLSGetNullAccessTokenMock());
        System.runAs(userObj){
            Test.startTest();
            NLSGetParentLoanDetailsSchedule schedulePricing = new NLSGetParentLoanDetailsSchedule();
            String cronExpression = '0 0 23 * * ?';
            System.schedule('Test Get Parent Loan', cronExpression, schedulePricing);
            Test.stopTest();
            ApexClass calloutBatch = [SELECT Id FROM ApexClass WHERE Name = 'NLSLoanDetailsCalloutBatch'];
            AsyncApexJob jobObj = [SELECT Id, ApexClassId, Status FROM AsyncApexJob WHERE ApexClassId =:calloutBatch.Id];
            System.assert(jobObj.Status != null, 'Assertion Failed');
        }
    }

    /**
    * @description : Test class for NLSLoanDetailsAdapter for Zero active applications
    * @author Suraj Kumar | 09-10-2024 
    **/
    @isTest
    private static void testCalloutBatchZeroActiveApp(){
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new TierFourCalloutMock());
        System.runAs(userObj){
            List<genesis__Applications__c> applicationList = [SELECT Id, genesis__Status__c FROM genesis__Applications__c];
            for(genesis__Applications__c appObj: applicationList){
                appObj.genesis__Status__c = 'CLOSED';
            }
            Database.update(applicationList,true);
            Test.startTest();
            NLSGetParentLoanDetailsSchedule schedulePricing = new NLSGetParentLoanDetailsSchedule();
            String cronExpression = '0 0 23 * * ?';
            System.schedule('Test Get Parent Loan', cronExpression, schedulePricing);
            Test.stopTest();
            ApexClass calloutBatch = [SELECT Id FROM ApexClass WHERE Name = 'NLSLoanDetailsCalloutBatch'];
            AsyncApexJob jobObj = [SELECT Id, ApexClassId, Status FROM AsyncApexJob WHERE ApexClassId =:calloutBatch.Id];
            System.assert(jobObj.Status != null, 'Assertion Failed');
        }
    }

    /**
    * @description : Test class for NLSLoanDetailsAdapter for Empty payload
    * @author Suraj Kumar | 09-10-2024 
    **/
    @isTest
    private static void testCalloutBatchEmptyPayload(){
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new EmptyPayloadCalloutMock());
        System.runAs(userObj){
            Test.startTest();
            NLSGetParentLoanDetailsSchedule schedulePricing = new NLSGetParentLoanDetailsSchedule();
            String cronExpression = '0 0 23 * * ?';
            System.schedule('Test Get Parent Loan', cronExpression, schedulePricing);
            Test.stopTest();
            ApexClass calloutBatch = [SELECT Id FROM ApexClass WHERE Name = 'NLSLoanDetailsCalloutBatch'];
            AsyncApexJob jobObj = [SELECT Id, ApexClassId, Status FROM AsyncApexJob WHERE ApexClassId =:calloutBatch.Id];
            System.assert(jobObj.Status != null, 'Assertion Failed');
        }
    }
}