/**
 * @description       : Test class for PortalFetchAllTransactionsAPI, NLSLoanAllTransactionsCallout and NLSLoanAllTransactionsAdapter
 * @author            : Sk Minsar
 * @group             : 
 * @last modified on  : 04-05-2024
 * @last modified by  : Sk Minsar
**/
@isTest
public with sharing class PortalFetchAllTransactionsAPITest{

    @testSetup
    static void setup() {


        // Creating Legal Entity
        clcommon__Legal_Entity__c individualEntityObj = TestClassHelper.createLegalEntity(PortalConstants.SOLE_PROP_ENTITY);
        Database.Insert(individualEntityObj, true);

        // Creating Party Types
        clcommon__Party_Type__c borrowerPartyTypeObj = TestClassHelper.createPartyType(PortalConstants.BORROWER_PARTY_NAME);
        Database.Insert(borrowerPartyTypeObj);

        clcommon__Party_Type__c dealerPartyTypeObj = TestClassHelper.createPartyType(PortalConstants.DEALER_PARTY_NAME);
        Database.Insert(dealerPartyTypeObj, true);

        clcommon__Party_Type__c clPartyTypeObj = TestClassHelper.createPartyType(PortalConstants.CERTIFIED_LENDER);
        Database.Insert(clPartyTypeObj, true);

        // Creating CL Product for Application
        clcommon__CL_Product__c clProductObj = TestClassHelper.createCLProductForApplication();
        Database.Insert(clProductObj, true);

        // Creating CL Purpose for Application
        clcommon__CL_Purpose__c clPurposeObj = TestClassHelper.createCLPurposeForApplication();
        Database.Insert(clPurposeObj, true);

        // Creating business information
        genesis__Business_Information__c dealerBusinessInfoObj = TestClassHelper.createBusinessInfoForDealer();
        Database.Insert(dealerBusinessInfoObj, true);

        createBorrowerBusinessInfo();

        // Creating Accounts
        Account dealerAccountObj = TestClassHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        Database.Insert(dealerAccountObj, true);

        Account clAccountObj = TestClassHelper.createCLAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
        Database.Insert(clAccountObj, true);


        Account borrowerAccountObj = TestClassHelper.createSolePropAccount(individualEntityObj,dealerBusinessInfoObj.Id);
        Database.Insert(borrowerAccountObj, true);

        // Creating Contacts
        Contact clContactObj = TestClassHelper.createCLContact(clAccountObj.Id);
        Database.Insert(clContactObj, true);


        Contact borrowerContactObj = TestClassHelper.createBorrowerContact(borrowerAccountObj.Id);    
        Database.Insert(borrowerContactObj, true);

        // Creating Application
        Map<String,Id> applicationDataMap = new Map<String,Id>{
            'dealerAccountId'=> dealerAccountObj.Id,
            'clProductId'=> clProductObj.Id,
            'clPurposeId'=> clPurposeObj.Id,
            'borrowerAccountId'=> borrowerAccountObj.Id,
            'borrowerContactId'=> borrowerContactObj.Id,
            'clAccountId'=> clAccountObj.Id
        };
        genesis__Applications__c applicationObj = TestClassHelper.createCurrCropYearApplication(applicationDataMap);
        applicationObj.Loan_Id__c = '194062';
        Database.Insert(applicationObj);

        // Creating Dealer Party
        Map<String,Id> dealerPartyMapData = new Map<String,Id>{
            'accountId'=> dealerAccountObj.Id,
            'partyTypeId'=> dealerPartyTypeObj.Id,
            'applicationId'=> applicationObj.Id
        };
        clcommon__Party__c dealerPartyObj = TestClassHelper.createParty(dealerPartyMapData);
        Database.Insert(dealerPartyObj, true);

        // Creating CL Party
        Map<String,Id> clPartyMapData = new Map<String,Id>{
            'accountId'=> clAccountObj.Id,
            'contactId'=> clContactObj.Id,
            'partyTypeId'=> clPartyTypeObj.Id,
            'applicationId'=> applicationObj.Id
        };
        clcommon__Party__c clPartyObj = TestClassHelper.createParty(clPartyMapData);
        Database.Insert(clPartyObj, true);

            // Creating Borrower Party
        Map<String,Id> borrowerPartyMapData = new Map<String,Id>{
            'accountId'=> borrowerAccountObj.Id,
            'contactId'=> borrowerContactObj.Id,
            'partyTypeId'=> borrowerPartyTypeObj.Id,
            'applicationId'=> applicationObj.Id
        };
        clcommon__Party__c borrowerPartyObj = TestClassHelper.createParty(borrowerPartyMapData);
        Database.Insert(borrowerPartyObj, true);

        // Creating Reciprocal Roles
        clcommon__Reciprocal_Role__c clRoleObj = TestClassHelper.createReciprocalRole('Certified Lender');
        Database.Insert(clRoleObj, true);
        
        // Creating Relationships
        clcommon__Relationship__c clDealerRealtionshipObj = TestClassHelper.createCLDealerRelationship(clRoleObj, 
                                                                                                        dealerAccountObj.Id, 
                                                                                                        clAccountObj.Id);
        Database.Insert(clDealerRealtionshipObj, true);


        // Creating User
        User clUserObj = TestClassHelper.createCLUser(clContactObj.Id);
        Database.Insert(clUserObj, true);

        // create rate card and pricing detail

            // Creating My Program
        genesis__Rate_Card_Setup_Header__c rateCardSetupHeaderObj = TestClassHelper.createCurrYearRateCardHeader(dealerAccountObj);
        Database.Insert(rateCardSetupHeaderObj, true);

            // Creating Child loans
        genesis__Rate_Card_Setup_Detail__c rateCardSetupDetailObjOne = TestClassHelper.createRateCardSetupDetailOne(rateCardSetupHeaderObj);
        rateCardSetupDetailObjOne.Description__c = 'Seeds';
        Database.Insert(rateCardSetupDetailObjOne, true);
        genesis__Rate_Card_Setup_Detail__c rateCardSetupDetailObjTwo = TestClassHelper.createRateCardSetupDetailTwo(rateCardSetupHeaderObj);
        rateCardSetupDetailObjTwo.Description__c = 'Equipments';
        Database.Insert(rateCardSetupDetailObjTwo, true);

            // Creating Application Pricing Details
        genesis__Application_Pricing_Detail__c appPricingDetailObjOne = TestClassHelper.createEnabledPricingDetail(applicationObj, rateCardSetupDetailObjOne.Id);
        appPricingDetailObjOne.Loan_Id__c = '194062';
        Database.Insert(appPricingDetailObjOne, true);
        genesis__Application_Pricing_Detail__c appPricingDetailObjTwo = TestClassHelper.createEnabledPricingDetail(applicationObj, rateCardSetupDetailObjTwo.Id);
        appPricingDetailObjOne.Loan_Id__c = '194062';
        Database.Insert(appPricingDetailObjTwo, true);
        
        // Creating Payment Mode
        clcommon__Payment_Mode__c achPaymentModeObj = TestClassHelper.createPaymentMode().get(PortalConstants.ACH);
        Database.Insert(achPaymentModeObj, true);

        clcommon__Payment_Mode__c productReturnPayModeObj = TestClassHelper.createPaymentMode().get(PortalConstants.PRODUCT_RETURN);
        Database.Insert(productReturnPayModeObj, true);

        // Creating Funding Transaction Properties
        clcommon__Funding_Transactions_Properties__c achFundTransacPropObj = TestClassHelper.createFundingTransactionProperty('ACH - 07-09-2022');
        Database.insert(achFundTransacPropObj, true);

         // Creating ACH Funding Transaction
        Map<String, Id> achDataMap = new Map<String, Id>{
            'applicationId'=> applicationObj.Id,
            'pricingDetailId'=> appPricingDetailObjOne.Id,
            'paymentModeId'=> achPaymentModeObj.Id,
            'fundingTransactionPropertyId'=> achFundTransacPropObj.Id
        };

        createACHFT(achDataMap);

         // Creating Product Return Funding Transaction
        Map<String, Id> productReturnDataMap = new Map<String, Id>{
            'applicationId'=> applicationObj.Id,
            'pricingDetailId'=> appPricingDetailObjOne.Id,
            'paymentModeId'=> productReturnPayModeObj.Id
        };
        createPRFT(productReturnDataMap);
        createTestIntegrationAPIConfig();
    }

    /**
    * @description - This method creates borrower Business Info
    * @author Sk Minsar | 04-05-2024 
    **/
    private static void createBorrowerBusinessInfo(){
        genesis__Business_Information__c borrowerBusinessInfoObj = TestClassHelper.createBusinessInfoForBorrower();
        Database.Insert(borrowerBusinessInfoObj, true);
    }

    /**
    * @description - Create product return Funding Transaction
    * @author Sk Minsar | 04-05-2024 
    * @param productReturnDataMap 
    **/
    private static void createPRFT(Map<String, Id> productReturnDataMap){
        genesis__Funding_Transaction__c prodReturnFundTransacObj = TestClassHelper.createProductReturnWithoutPropertiesBatch(productReturnDataMap);
        prodReturnFundTransacObj.genesis__Reference__c = 'Seeds';
        prodReturnFundTransacObj.Posted_to_NLS__c = true;
        prodReturnFundTransacObj.Posted_Date__c = Datetime.newInstance(2022, 9, 9);
        Database.insert(prodReturnFundTransacObj, true);
    }

    /**
    * @description - creating ach Funding Transactions
    * @author Sk Minsar | 04-05-2024 
    * @param achDataMap 
    **/
    private static void createACHFT(Map<String, Id> achDataMap){

        genesis__Funding_Transaction__c achFundingTransactionObj = TestClassHelper.createACHFundingTransaction(achDataMap);
        achFundingTransactionObj.genesis__Amount__c = 1000;
        achFundingTransactionObj.Posted_to_NLS__c = false;
        Database.insert(achFundingTransactionObj, true);

        achFundingTransactionObj = TestClassHelper.createACHFundingTransaction(achDataMap);
        achFundingTransactionObj.genesis__Amount__c = 1000;
        achFundingTransactionObj.Posted_to_NLS__c = false;
        achFundingTransactionObj.Status__c = 'Voided';
        Database.insert(achFundingTransactionObj, true);
    }

    /**
    * @description - Creating integration api configuration
    * @author Sk Minsar | 04-05-2024 
    **/
    private static void createTestIntegrationAPIConfig(){
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
     * @last modified on  : 04-05-2024
     * @last modified by  : Sk Minsar
    **/
    public class NLSGetNullAccessTokenMock implements HttpCalloutMock {

        
        /**
        * @description Implement the interface method
        * @author Sk Minsar | 03-17-2024 
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
     * @last modified on  : 04-05-2024
     * @last modified by  : Sk Minsar
    **/
    public class NLSLoanTransactionHttpCalloutMock implements HttpCalloutMock {

        
        /**
        * @description Implement the interface method
        * @author Sk Minsar | 03-17-2024 
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
     * @description       : Class of NLSLoanTranExHttpCalloutMock to implement HttpCalloutMock interface
     * @author            : Sk Minsar
     * @group             : 
     * @last modified on  : 04-05-2024
     * @last modified by  : Sk Minsar
    **/
    public class NLSLoanTranExHttpCalloutMock implements HttpCalloutMock {

        
        /**
        * @description Implement the interface method
        * @author Sk Minsar | 03-17-2024 
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
                                        +'"Loan_Type":2,"Portfolio_Code_Id":0,"Loan_Group_No":0,"Transaction_Code":100,"Transrefno": null"Reversal_Transrefno":0,"Participant_Detail_Flag": null,"Transaction_Date": null,"Transaction_Description":"Product Return","Transaction_Amount":1000.00, "User_Reference":"PRODUCT RETURN Central Valley CFA - Seeds"},{"Acctrefno":194062,'
                                        +'"Loan_Type":2,"Portfolio_Code_Id":0,"Loan_Group_No":0,"Transaction_Code":107,"Transrefno": null,"Reversal_Transrefno":0,"Participant_Detail_Flag":false,"Transaction_Date":"2022-09-09","Transaction_Description":"Product Return","Transaction_Amount":1000.00, "User_Reference":"PRODUCT RETURN Central Valley CFA - Seeds"}]}}');
            }
            return response;
        }
    }
    @isTest 
    static void testNlsLoanTransactionCalloutMethod() {
        Map<String, Object> requestMap = new Map<String, Object>();
        User objUser = [SELECT Id FROM User WHERE UserName = 'ross.geller@yopmail.com' LIMIT 1];
        genesis__Applications__c applicationObj = [SELECT Id FROM genesis__Applications__c LIMIT 1];
        requestMap.put('applicationId', applicationObj.Id );
        requestMap.put('transactionsStatus', 'All' );
        requestMap.put('loanDescription', 'All Sub-Tranches' );
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new NLSLoanTransactionHttpCalloutMock());
        Test.startTest();
        System.runAs(objUser) {
            PortalFetchAllTransactionsAPI testApi = new PortalFetchAllTransactionsAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'SUCCESS');
        }
        Test.stopTest();
    }
    @isTest 
    static void testNlsLoanPostedTransactionCalloutMethod() {
        Map<String, Object> requestMap = new Map<String, Object>();
        User objUser = [SELECT Id FROM User WHERE UserName = 'ross.geller@yopmail.com' LIMIT 1];
        genesis__Applications__c applicationObj = [SELECT Id FROM genesis__Applications__c LIMIT 1];
        requestMap.put('applicationId', applicationObj.Id );
        requestMap.put('transactionsStatus', 'Posted' );
        requestMap.put('loanDescription', 'All Sub-Tranches' );
        Test.setMock(HttpCalloutMock.class, new NLSLoanTransactionHttpCalloutMock());
        Test.startTest();
        System.runAs(objUser) {
            PortalFetchAllTransactionsAPI testApi = new PortalFetchAllTransactionsAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'SUCCESS');
        }
        Test.stopTest();
    }
    @isTest 
    static void testNlsLoanPendingTransactionCalloutMethod() {
        Map<String, Object> requestMap = new Map<String, Object>();
        User objUser = [SELECT Id FROM User WHERE UserName = 'ross.geller@yopmail.com' LIMIT 1];
        genesis__Applications__c applicationObj = [SELECT Id FROM genesis__Applications__c LIMIT 1];
        requestMap.put('applicationId', applicationObj.Id );
        requestMap.put('transactionsStatus', 'Pending' );
        requestMap.put('loanDescription', 'All Sub-Tranches' );
        Test.setMock(HttpCalloutMock.class, new NLSLoanTransactionHttpCalloutMock());
        Test.startTest();
        System.runAs(objUser) {
            PortalFetchAllTransactionsAPI testApi = new PortalFetchAllTransactionsAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'SUCCESS');
        }
        Test.stopTest();
    }
@isTest 
    static void testNlsLoanVoidedTransactionCalloutMethod() {
        Map<String, Object> requestMap = new Map<String, Object>();
        User objUser = [SELECT Id FROM User WHERE UserName = 'ross.geller@yopmail.com' LIMIT 1];
        genesis__Applications__c applicationObj = [SELECT Id FROM genesis__Applications__c LIMIT 1];
        requestMap.put('applicationId', applicationObj.Id );
        requestMap.put('transactionsStatus', 'Voided' );
        requestMap.put('loanDescription', 'All Sub-Tranches' );
        Test.setMock(HttpCalloutMock.class, new NLSLoanTransactionHttpCalloutMock());
        Test.startTest();
        System.runAs(objUser) {
            PortalFetchAllTransactionsAPI testApi = new PortalFetchAllTransactionsAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'SUCCESS');
        }
        Test.stopTest();
    }
@isTest 
    static void testNlsLoanNullStatusTransactionCalloutMethod() {
        Map<String, Object> requestMap = new Map<String, Object>();
        User objUser = [SELECT Id FROM User WHERE UserName = 'ross.geller@yopmail.com' LIMIT 1];
        genesis__Applications__c applicationObj = [SELECT Id FROM genesis__Applications__c LIMIT 1];
        requestMap.put('applicationId', applicationObj.Id );
        requestMap.put('transactionsStatus', null );
        requestMap.put('loanDescription', 'All Sub-Tranches' );
        Test.setMock(HttpCalloutMock.class, new NLSLoanTransactionHttpCalloutMock());
        Test.startTest();
        System.runAs(objUser) {
            PortalFetchAllTransactionsAPI testApi = new PortalFetchAllTransactionsAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'EXCEPTION');
        }
        Test.stopTest();
    }
    @isTest 
    static void testNlsLoanTransactionCalloutMethodOne() {
        Map<String, Object> requestMap = new Map<String, Object>();
        Profile profile = [SELECT Id FROM Profile WHERE Name='Certified Lender'];
        User objUser = IntegrationTestInitHelper.createUser(profile.Id);
        requestMap.put(ConstantValues.LOAN_ID, '134390');
        Test.setMock(HttpCalloutMock.class, new NLSGetNullAccessTokenMock());
        Test.startTest();
        System.runAs(objUser) {
            PortalFetchAllTransactionsAPI testApi = new PortalFetchAllTransactionsAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'EXCEPTION');
        }
        Test.stopTest();
    }
    @isTest 
    static void testNlsLoanTransactionCalloutMethodTwo() {
        Map<String, Object> requestMap = new Map<String, Object>();
        Profile profile = [SELECT Id FROM Profile WHERE Name='Certified Lender'];
        User objUser = IntegrationTestInitHelper.createUser(profile.Id);
        requestMap.put(ConstantValues.LOAN_NUMBER, '134390' );
        Test.setMock(HttpCalloutMock.class, new NLSLoanTransactionHttpCalloutMock());
        Test.startTest();
        System.runAs(objUser) {
            PortalFetchAllTransactionsAPI testApi = new PortalFetchAllTransactionsAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'EXCEPTION');
        }
        Test.stopTest();
    }
@isTest 
    static void testNlsLoanTransactionCalloutMethodException() {
        Map<String, Object> requestMap = new Map<String, Object>();
        Profile profile = [SELECT Id FROM Profile WHERE Name='Certified Lender'];
        User objUser = IntegrationTestInitHelper.createUser(profile.Id);
        requestMap.put(ConstantValues.LOAN_NUMBER, '134390' );
        Test.setMock(HttpCalloutMock.class, new NLSLoanTransactionHttpCalloutMock());
        Test.startTest();
        System.runAs(objUser) {
            PortalFetchAllTransactionsAPI testApi = new PortalFetchAllTransactionsAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'EXCEPTION');
        }
        Test.stopTest();
    }
@isTest 
    static void testNlsLoanTransactionNotValidCalloutMethodException() {
        Map<String, Object> requestMap = new Map<String, Object>();
        Profile profile = [SELECT Id FROM Profile WHERE Name='Certified Lender'];
        User objUser = IntegrationTestInitHelper.createUser(profile.Id);
        requestMap.put(ConstantValues.LOAN_NUMBER, '134399' );
        Test.setMock(HttpCalloutMock.class, new NLSLoanTranExHttpCalloutMock());
        Test.startTest();
        System.runAs(objUser) {
            PortalFetchAllTransactionsAPI testApi = new PortalFetchAllTransactionsAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'EXCEPTION');
        }
        Test.stopTest();
    }
@isTest 
    static void testNlsLoanInvalidTypeStatusTransactionCalloutMethod() {
        Map<String, Object> requestMap = new Map<String, Object>();
        User objUser = [SELECT Id FROM User WHERE UserName = 'ross.geller@yopmail.com' LIMIT 1];
        genesis__Applications__c applicationObj = [SELECT Id FROM genesis__Applications__c LIMIT 1];
        requestMap.put('applicationId', applicationObj.Id );
        requestMap.put('transactionsStatus', null );
        requestMap.put('loanDescription', 123455 );
        Test.setMock(HttpCalloutMock.class, new NLSLoanTransactionHttpCalloutMock());
        Test.startTest();
        System.runAs(objUser) {
            PortalFetchAllTransactionsAPI testApi = new PortalFetchAllTransactionsAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'EXCEPTION');
        }
        Test.stopTest();
    }

}