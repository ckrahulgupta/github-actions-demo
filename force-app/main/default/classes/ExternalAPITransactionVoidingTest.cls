/**
 * @description       : This is the test class for ExternalAPITransactionVoiding
 * @author            : Kabir Pramanik
 * @group             : 
 * @last modified on  : 03-19-2025
 * @last modified by  : Kabir Pramanik
**/
@isTest
public without sharing class ExternalAPITransactionVoidingTest {
    private static final String ASSERTION_FAILED = 'Assertion failed';
    private static final String VOIDED = 'Voided';
    private static final String POST_METHOD = 'POST';
    private static final String URL = '/api/v1/external/voidTransaction';
    private static final Integer SUCCESS_STATUS = 200;
    private static final String PROFILE_CFA_ADMIN = 'CFA Admin User';
    private static final String PROFILE_GMK_API_INTEGRATION = 'Growmark API Only Integration Profile';
    private static final String PROFILE_AGVEND_USER = 'AgVend External User Profile';
    private static final String PROFILE_CFA_EXTERNAL_API = 'CFA External API Profile';
    private static final String NAME_CONNECTIFY_USER = 'Connectify User';
    /**
    * @description Creating test data
    * @author Kabir Pramanik | 03-13-2025 
    **/
    @TestSetup
    static void makeData(){
        // Creating Business Information
        genesis__Business_Information__c dealerBusinessInfoObj = ExternalAPITestHelper.createBusinessInfoForDealer();
        genesis__Business_Information__c borrowerBusinessInfoObj = ExternalAPITestHelper.createBusinessInfoForBorrower();
        Database.insert(new List<genesis__Business_Information__c>{dealerBusinessInfoObj, borrowerBusinessInfoObj},true);

       // Creating Legal Entity for Borrower
       clcommon__Legal_Entity__c entityObj = ExternalAPITestHelper.createSolePropLegalEntity();
       Database.insert(entityObj, true);

       // Creating Reciprocal Role 
       clcommon__Reciprocal_Role__c roleObj = ExternalAPITestHelper.createCertifiedLenderRole();
       Database.insert(roleObj, true);

        // Creating Account for Dealer
        Account dealerAccountObj = ExternalAPITestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        dealerAccountObj.CIF_Number__c = '106763';
        dealerAccountObj.Enable_ERP_Id__c = true;
        dealerAccountObj.Unique_Id__c = 'abc@123';
        dealerAccountObj.Coop_Type__c = ExternalConstants.GROWMARK_COOP_TYPE;
        Database.insert(dealerAccountObj, true);

        // Creating Account for Certified Lender, Borrower
        Account clAccountObj = ExternalAPITestHelper.createCLAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
        Account borrowerAccountObj = ExternalAPITestHelper.createSolePropAccount(entityObj, borrowerBusinessInfoObj.Id);
        Database.insert(new List<Account>{borrowerAccountObj, clAccountObj}, true);

        // Creating Contact for Certified Lender, Borrower
        Contact clContactObj = ExternalAPITestHelper.createCLContact(clAccountObj.Id);
        Contact borrowerContactObj = ExternalAPITestHelper.createBorrowerContact(borrowerAccountObj.Id);
        Contact agvendContactObj = ExternalAPITestHelper.createContact();
        Database.insert(new List<Contact>{clContactObj,borrowerContactObj, agvendContactObj},true);

        // Creating CL Purpose of Application
        clcommon__CL_Purpose__c clPurposeObj = ExternalAPITestHelper.createCLPurposeForApplication();
        Database.insert(clPurposeObj, true);

        // Creating Cl Product of Application
        clcommon__CL_Product__c clProductObj = ExternalAPITestHelper.createCLProductForApplication();
        Database.insert(clProductObj, true);

        genesis__Rate_Card_Setup_Header__c rateCardHeaderObj = ExternalAPITestHelper.createRateCardSetupHeader(dealerAccountObj);
        Database.insert(rateCardHeaderObj,true);

        genesis__Rate_Card_Setup_Detail__c specialTermAA =  ExternalAPITestHelper.createRateCardSetupDetail(rateCardHeaderObj);
        specialTermAA.Special_Term_Reference__c = 'Special Term Sub-Tranche (A)';
        specialTermAA.Start_Date__c = System.Today();
        specialTermAA.End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);

        genesis__Rate_Card_Setup_Detail__c specialTermBA =  ExternalAPITestHelper.createRateCardSetupDetail(rateCardHeaderObj);
        specialTermBA.Special_Term_Reference__c = 'Special Term Sub-Tranche (B)';
        specialTermBA.Start_Date__c = System.Today();
        specialTermBA.End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        Database.insert(new List<genesis__Rate_Card_Setup_Detail__c> {specialTermAA,specialTermBA},true);

        // Creating map for Application
        Map<String,Id> paramForApplicationMap = new Map<String,Id>{
            'dealerAccountId' => dealerAccountObj.Id,
            'clProductId' => clProductObj.Id,
            'clPurposeId' => clPurposeObj.Id,
            'borrowerAccountId' => borrowerAccountObj.Id,
            'borrowerContactId' => borrowerContactObj.Id,
            'certifiedLender' =>  clAccountObj.Id
        };

        // Creating Application
        genesis__Applications__c applicationObj = ExternalAPITestHelper.createCurrCropYearApplication(paramForApplicationMap);
        applicationObj.My_Program__c = rateCardHeaderObj.Id;
        applicationObj.Dealer_Name__c = dealerAccountObj.Id;
        applicationObj.Peak_Loan_Volume__c = 10000;

        genesis__Applications__c appObjTwo = ExternalAPITestHelper.createCurrCropYearApplication(paramForApplicationMap);
        appObjTwo.My_Program__c = rateCardHeaderObj.Id;
        appObjTwo.Dealer_Name__c = dealerAccountObj.Id;
        appObjTwo.genesis__Loan_Number__c = '123456';
        appObjTwo.Loan_Id__c = '55555';
        applicationObj.Peak_Loan_Volume__c = 10000;
        Database.insert(new List<genesis__Applications__c>{applicationObj, appObjTwo}, true);

        // Creating party types
        clcommon__Party_Type__c dealerPartyTypeObj = ExternalAPITestHelper.createPartyType(ExternalConstants.DEALER_PARTY);
        clcommon__Party_Type__c clPartyTypeObj = ExternalAPITestHelper.createPartyType(ExternalConstants.CERTIFIED_LENDER_PARTY);
        clcommon__Party_Type__c borrowerPartyTypeObj = ExternalAPITestHelper.createPartyType(ExternalConstants.BORROWER_PARTY);
        Database.insert(new List<clcommon__Party_Type__c> {dealerPartyTypeObj,clPartyTypeObj, borrowerPartyTypeObj}, true);

        // Creating Cl Party map
        Map<String,Id> paramFoDealerPartyMap = new Map<String,Id>{
            'accountId' => dealerAccountObj.Id,
            'contactId' => null,
            'partyTypeId' => dealerPartyTypeObj.Id,
            'applicationId' => applicationObj.Id
        };
        // Creating Cl Party map
        Map<String,Id> paramForClPartyMap = new Map<String,Id>{
            'accountId' => clAccountObj.Id,
            'contactId' => clContactObj.Id,
            'partyTypeId' => clPartyTypeObj.Id,
            'applicationId' => applicationObj.Id
        };
        // Creating Borrower Party map
        Map<String,Id> paramForBorrowerPartyMap = new Map<String,Id>{
            'accountId' => borrowerAccountObj.Id,
            'contactId' => borrowerContactObj.Id,
            'partyTypeId' => borrowerPartyTypeObj.Id,
            'applicationId' => applicationObj.Id
        };

        clcommon__Party__c dealerPartyObj = ExternalAPITestHelper.createParty(paramFoDealerPartyMap);
        clcommon__Party__c clPartyObj = ExternalAPITestHelper.createParty(paramForClPartyMap);
        clcommon__Party__c borrowerPartyObj = ExternalAPITestHelper.createApplicantParty(paramForBorrowerPartyMap);
        Database.insert(new List<clcommon__Party__c> {dealerPartyObj,clPartyObj,borrowerPartyObj}, true);

        List<genesis__Application_Pricing_Detail__c> pricingDetailsObjList = ExternalAPITestHelper.createApplicationPricings(applicationObj);
        pricingDetailsObjList[0].Principal_Advanced__c = 5000;
        Database.insert(pricingDetailsObjList, true);

        //Create Payment Modes
        Map<String, clcommon__Payment_Mode__c> paymentModeMap = ExternalAPITestHelper.createPaymentMode();
        Database.insert(new List<clcommon__Payment_Mode__c> {
            paymentModeMap.get(ConstantValues.ACH)
        }, true);

        genesis__Funding_Transaction__c achTxnObj = ExternalAPITestHelper.createFundingTransaction(paymentModeMap.get(ConstantValues.ACH).Id, null, applicationObj.Id);
        achTxnObj.Pricing_Detail__c = pricingDetailsObjList[0].Id;
        achTxnObj.genesis__Cleared__c = false;
        achTxnObj.Posted_to_NLS__c = false;
        achTxnObj.Is_Clearing_Suspense__c = false;
        achTxnObj.Growmark_Transaction_Source_ID__c = '34256178';
        Database.insert(achTxnObj, true);

        User clUser = ExternalAPITestHelper.createCLUser(clContactObj.Id);
        User cfaAdminUser = ExternalAPITestHelper.createUserByProfileName(PROFILE_CFA_ADMIN, 'cfa.adminuser919@yopmail.com');
        User gmkApiOnlyUser = ExternalAPITestHelper.createUserByProfileName(PROFILE_GMK_API_INTEGRATION, 'growmark.apionly111@yopmail.com');
        // User agvendExternalUser = ExternalAPITestHelper.createUserByProfileName(PROFILE_AGVEND_USER, 'agvend.external222@yopmail.com');
        User cfaExternalApiUser = ExternalAPITestHelper.createUserByProfileName(PROFILE_CFA_EXTERNAL_API, 'cfa.externalapi333@yopmail.com');
        // agvendExternalUser.contactId = agvendContactObj.Id;
        // agvendExternalUser.portalRole = 'Manager';
        Database.insert(new List<User>{clUser, cfaAdminUser, gmkApiOnlyUser, cfaExternalApiUser},true);

    }
    /**
    * @description This method returns a list the funding transaction which is to be used for voiding
    * @author Kabir Pramanik | 03-16-2025 
    * @return List<genesis__Funding_Transaction__c> 
    **/
    private static List<genesis__Funding_Transaction__c> getFundingTxnList(){
        return [SELECT Id 
                FROM genesis__Funding_Transaction__c 
                WHERE genesis__Application__r.genesis__Loan_Number__c = '300023456' 
                LIMIT 1];
    }
    /**
    * @description This method is to test exception when trasactio id passed is null
    * @author Kabir Pramanik | 03-16-2025 
    **/
    @isTest 
    static void testInvalidFundingTxnIdException(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = URL;
        request.httpMethod = POST_METHOD;
        RestContext.response = response;
        System.runAs(ExternalAPITestHelper.getAdminUser()){
            Test.startTest();
            ExternalAPITransactionVoiding.voidTransaction(null, '300023456-A');
            System.assertEquals(null, response.statusCode, ASSERTION_FAILED);
            List<clcommon__Log__c> logList = [SELECT Id FROM clcommon__Log__c WHERE Name = :ExternalAPIUtilities.CLASS_NAME LIMIT 1];
            System.assertEquals(false, logList.isEmpty(), ASSERTION_FAILED);
            Test.stopTest(); 
        }
    }
    /**
    * @description This method is to test exception when loan id passed is null
    * @author Kabir Pramanik | 03-16-2025 
    **/
    @isTest 
    static void testInvalidLoaIdException(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = URL;
        request.httpMethod = POST_METHOD;
        RestContext.response = response;
        List<genesis__Funding_Transaction__c> fundingTxnList = getFundingTxnList();
        fundingTxnList[0].Growmark_Transaction_Source_ID__c = '111222333';
        Database.update(fundingTxnList, true);
        System.runAs(ExternalAPITestHelper.getAdminUser()){
            Test.startTest();
            ExternalAPITransactionVoiding.voidTransaction(fundingTxnList[0].Growmark_Transaction_Source_ID__c, null);
            System.assertEquals(null, response.statusCode, ASSERTION_FAILED);
            List<clcommon__Log__c> logList = [SELECT Id FROM clcommon__Log__c WHERE Name = :ExternalAPIUtilities.CLASS_NAME LIMIT 1];
            System.assertEquals(false, logList.isEmpty(), ASSERTION_FAILED);
            Test.stopTest(); 
        }
    }
    /**
    * @description This method is to test with funding transaction whose status is Voided and the request is being done by system admin
    * @author Kabir Pramanik | 03-16-2025 
    **/
    @isTest 
    static void testSystemAdminTxnWithVoidStatus(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = URL;
        request.httpMethod = POST_METHOD;
        RestContext.response = response;
        List<genesis__Funding_Transaction__c> fundingTxnList = getFundingTxnList();
        fundingTxnList[0].Growmark_Transaction_Source_ID__c = '111222333';
        fundingTxnList[0].Status__c = VOIDED;
        Database.update(fundingTxnList, true);
        System.runAs(ExternalAPITestHelper.getAdminUser()){
            Test.startTest();
            ExternalAPITransactionVoiding.voidTransaction('111222333', '300023456-A');
            System.assertEquals(null, response.statusCode, ASSERTION_FAILED);
            List<clcommon__Log__c> logList = [SELECT Id FROM clcommon__Log__c WHERE Name = :ExternalAPIUtilities.CLASS_NAME LIMIT 1];
            System.assertEquals(false, logList.isEmpty(), ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is to test with a funding transaction whose cleared status is true and the request is being done by system admin
    * @author Kabir Pramanik | 03-16-2025 
    **/
    @isTest 
    static void testSystemAdminTxnClearedTrue(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = URL;
        request.httpMethod = POST_METHOD;
        RestContext.response = response;
        List<genesis__Funding_Transaction__c> fundingTxnList = getFundingTxnList();
        fundingTxnList[0].Growmark_Transaction_Source_ID__c = '111222333';
        fundingTxnList[0].genesis__Cleared__c = true; 
        Database.update(fundingTxnList, true);
        System.runAs(ExternalAPITestHelper.getAdminUser()){
            Test.startTest();
            ExternalAPITransactionVoiding.voidTransaction('111222333', '300023456-A');
            System.assertEquals(null, response.statusCode, ASSERTION_FAILED);
            List<clcommon__Log__c> logList = [SELECT Id FROM clcommon__Log__c WHERE Name = :ExternalAPIUtilities.CLASS_NAME LIMIT 1];
            System.assertEquals(false, logList.isEmpty(), ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is to test with a regular transaction whose status is not voided or it is not cleared yet and the request is being done by system admin
    * @author Kabir Pramanik | 03-16-2025 
    **/
    @isTest 
    static void testSystemAdminRegularTxn(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = URL;
        request.httpMethod = POST_METHOD;
        RestContext.response = response;
        List<genesis__Funding_Transaction__c> fundingTxnList = getFundingTxnList();
        fundingTxnList[0].Is_Clearing_Suspense__c = false;
        fundingTxnList[0].Growmark_Transaction_Source_ID__c = '111222333';
        Database.update(fundingTxnList, true);
        System.runAs(ExternalAPITestHelper.getAdminUser()){
            Test.startTest();
            ExternalAPITransactionVoiding.voidTransaction('111222333', '300023456-A');
            List<genesis__Funding_Transaction__c> txnList = [SELECT Id,
                                                                    Status__c,
                                                                    Pricing_Detail__r.Principal_Advanced__c,
                                                                    Pricing_Detail__r.genesis__Application__r.Peak_Loan_Volume__c
                                                            FROM genesis__Funding_Transaction__c
                                                            WHERE genesis__Application__r.genesis__Loan_Number__c = '300023456'
                                                            LIMIT 1];
            System.assertEquals(VOIDED,txnList[0].Status__c, ASSERTION_FAILED);
            System.assertEquals(4000,txnList[0].Pricing_Detail__r.Principal_Advanced__c, ASSERTION_FAILED);
            System.assertEquals(9000, txnList[0].Pricing_Detail__r.genesis__Application__r.Peak_Loan_Volume__c, ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is to test with a funding transaction whose clearing suspense flag is true and the request is being done by system admin
    * @author Kabir Pramanik | 03-16-2025 
    **/
    @isTest 
    static void testSystemAdminClearingSuspenseTxn(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = URL;
        request.httpMethod = POST_METHOD;
        RestContext.response = response;
        List<genesis__Funding_Transaction__c> fundingTxnList = getFundingTxnList();
        fundingTxnList[0].Is_Clearing_Suspense__c = true;
        fundingTxnList[0].Growmark_Transaction_Source_ID__c = '111222333';
        Database.update(fundingTxnList, true);
        System.runAs(ExternalAPITestHelper.getAdminUser()){
            Test.startTest();
            ExternalAPITransactionVoiding.voidTransaction('111222333', '300023456-A');
            List<genesis__Funding_Transaction__c> txnList = [SELECT Id,
                                                                    Status__c,
                                                                    Pricing_Detail__r.Credit_Balance__c
                                                            FROM genesis__Funding_Transaction__c
                                                            WHERE genesis__Application__r.genesis__Loan_Number__c = '300023456'
                                                            LIMIT 1];
            System.assertEquals(VOIDED,txnList[0].Status__c, ASSERTION_FAILED);
            System.assertEquals(1000,txnList[0].Pricing_Detail__r.Credit_Balance__c, ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is to test where
    * @author Kabir Pramanik | 03-17-2025 
    **/
    @isTest 
    static void testCFAAdminTxnWithVoidStatus(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = URL;
        request.httpMethod = POST_METHOD;
        RestContext.response = response;
        List<genesis__Funding_Transaction__c> fundingTxnList = getFundingTxnList();
        fundingTxnList[0].Growmark_Transaction_Source_ID__c = '111222333';
        fundingTxnList[0].Status__c = VOIDED;
        Database.update(fundingTxnList, true);
        System.runAs(ExternalAPITestHelper.getUserByProfileName(PROFILE_CFA_ADMIN)){
            Test.startTest();
            ExternalAPITransactionVoiding.voidTransaction('111222333', '300023456-A');
            System.assertEquals(null, response.statusCode, ASSERTION_FAILED);
            List<clcommon__Log__c> logList = [SELECT Id FROM clcommon__Log__c WHERE Name = :ExternalAPIUtilities.CLASS_NAME LIMIT 1];
            System.assertEquals(false, logList.isEmpty(), ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is to test with a funding transaction whose cleared status is true and the request is being done by cfa admin user
    * @author Kabir Pramanik | 03-16-2025 
    **/
    @isTest 
    static void testCfaAdminTxnClearedTrue(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = URL;
        request.httpMethod = POST_METHOD;
        RestContext.response = response;
        List<genesis__Funding_Transaction__c> fundingTxnList = getFundingTxnList();
        fundingTxnList[0].Growmark_Transaction_Source_ID__c = '111222333';
        fundingTxnList[0].genesis__Cleared__c = true; 
        Database.update(fundingTxnList, true);
        System.runAs(ExternalAPITestHelper.getUserByProfileName(PROFILE_CFA_ADMIN)){
            Test.startTest();
            ExternalAPITransactionVoiding.voidTransaction('111222333', '300023456-A');
            System.assertEquals(null, response.statusCode, ASSERTION_FAILED);
            List<clcommon__Log__c> logList = [SELECT Id FROM clcommon__Log__c WHERE Name = :ExternalAPIUtilities.CLASS_NAME LIMIT 1];
            System.assertEquals(false, logList.isEmpty(), ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is to test with a regular transaction whose status is not voided or it is not cleared yet and the request is being done by system admin
    * @author Kabir Pramanik | 03-16-2025 
    **/
    @isTest 
    static void testCfaAdminRegularTxn(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = URL;
        request.httpMethod = POST_METHOD;
        RestContext.response = response;
        List<genesis__Funding_Transaction__c> fundingTxnList = getFundingTxnList();
        fundingTxnList[0].Is_Clearing_Suspense__c = false;
        fundingTxnList[0].Growmark_Transaction_Source_ID__c = '111222333';
        Database.update(fundingTxnList, true);
        System.runAs(ExternalAPITestHelper.getUserByProfileName(PROFILE_CFA_ADMIN)){
            Test.startTest();
            ExternalAPITransactionVoiding.voidTransaction('111222333', '300023456-A');
            List<genesis__Funding_Transaction__c> txnList = [SELECT Id,
                                                                        Status__c,
                                                                        Pricing_Detail__r.Principal_Advanced__c,
                                                                        Pricing_Detail__r.genesis__Application__r.Peak_Loan_Volume__c
                                                            FROM genesis__Funding_Transaction__c
                                                            WHERE genesis__Application__r.genesis__Loan_Number__c = '300023456'
                                                            LIMIT 1];
            System.assertEquals(VOIDED,txnList[0].Status__c, ASSERTION_FAILED);
            System.assertEquals(4000,txnList[0].Pricing_Detail__r.Principal_Advanced__c, ASSERTION_FAILED);
            System.assertEquals(9000, txnList[0].Pricing_Detail__r.genesis__Application__r.Peak_Loan_Volume__c, ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is to test with a funding transaction whose clearing suspense flag is true and the request is being done by system admin
    * @author Kabir Pramanik | 03-16-2025 
    **/
    @isTest 
    static void testCfaAdminClearingSuspenseTxn(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = URL;
        request.httpMethod = POST_METHOD;
        RestContext.response = response;
        List<genesis__Funding_Transaction__c> fundingTxnList = getFundingTxnList();
        fundingTxnList[0].Is_Clearing_Suspense__c = true;
        fundingTxnList[0].Growmark_Transaction_Source_ID__c = '111222333';
        Database.update(fundingTxnList, true);
        System.runAs(ExternalAPITestHelper.getUserByProfileName(PROFILE_CFA_ADMIN)){
            Test.startTest();
            ExternalAPITransactionVoiding.voidTransaction('111222333', '300023456-A');
            List<genesis__Funding_Transaction__c> txnList = [SELECT Id,
                                                                        Status__c,
                                                                        Pricing_Detail__r.Credit_Balance__c
                                                            FROM genesis__Funding_Transaction__c
                                                            WHERE genesis__Application__r.genesis__Loan_Number__c = '300023456'
                                                            LIMIT 1];
            System.assertEquals(VOIDED,txnList[0].Status__c, ASSERTION_FAILED);
            System.assertEquals(1000,txnList[0].Pricing_Detail__r.Credit_Balance__c, ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is to test with funding transaction whose status is Voided and the request is being done by growmark api only integration profile
    * @author Kabir Pramanik | 03-16-2025 
    **/
    @isTest 
    static void testGmkApiUserTxnWithVoidStatus(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = URL;
        request.httpMethod = POST_METHOD;
        RestContext.response = response;
        List<genesis__Funding_Transaction__c> fundingTxnList = getFundingTxnList();
        fundingTxnList[0].Growmark_Transaction_Source_ID__c = '111222333';
        fundingTxnList[0].Status__c = VOIDED;
        Database.update(fundingTxnList, true);
        System.runAs(ExternalAPITestHelper.getUserByProfileName(PROFILE_GMK_API_INTEGRATION)){
            Test.startTest();
            ExternalAPITransactionVoiding.voidTransaction('111222333', '300023456-A');
            System.assertEquals(null, response.statusCode, ASSERTION_FAILED);
            List<clcommon__Log__c> logList = [SELECT Id FROM clcommon__Log__c WHERE Name = :ExternalAPIUtilities.CLASS_NAME LIMIT 1];
            System.assertEquals(false, logList.isEmpty(), ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is to test with a funding transaction whose cleared status is true and the request is being done by growmark api only integration profile
    * @author Kabir Pramanik | 03-16-2025 
    **/
    @isTest 
    static void testGmkApiUserTxnClearedTrue(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = URL;
        request.httpMethod = POST_METHOD;
        RestContext.response = response;
        List<genesis__Funding_Transaction__c> fundingTxnList = getFundingTxnList();
        fundingTxnList[0].Growmark_Transaction_Source_ID__c = '111222333';
        fundingTxnList[0].genesis__Cleared__c = true; 
        Database.update(fundingTxnList, true);
        System.runAs(ExternalAPITestHelper.getUserByProfileName(PROFILE_GMK_API_INTEGRATION)){
            Test.startTest();
            ExternalAPITransactionVoiding.voidTransaction('111222333', '300023456-A');
            Test.stopTest();
            System.assertEquals(null, response.statusCode, ASSERTION_FAILED);
            List<clcommon__Log__c> logList = [SELECT Id FROM clcommon__Log__c WHERE Name = :ExternalAPIUtilities.CLASS_NAME LIMIT 1];
            System.assertEquals(false, logList.isEmpty(), ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is to test with a regular transaction whose status is not voided or it is not cleared yet and the request is being done by growmark api only integration profile
    * @author Kabir Pramanik | 03-16-2025 
    **/
    @isTest 
    static void testGmkApiUserRegularTxn(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = URL;
        request.httpMethod = POST_METHOD;
        RestContext.response = response;
        List<genesis__Funding_Transaction__c> fundingTxnList = getFundingTxnList();
        fundingTxnList[0].Is_Clearing_Suspense__c = false;
        fundingTxnList[0].Growmark_Transaction_Source_ID__c = '111222333';
        Database.update(fundingTxnList, true);
        System.runAs(ExternalAPITestHelper.getUserByProfileName(PROFILE_GMK_API_INTEGRATION)){
            Test.startTest();
            ExternalAPITransactionVoiding.voidTransaction('111222333', '300023456-A');
            List<genesis__Funding_Transaction__c> txnList = [SELECT Id,
                                                                        Status__c,
                                                                        Pricing_Detail__r.Principal_Advanced__c,
                                                                        Pricing_Detail__r.genesis__Application__r.Peak_Loan_Volume__c
                                                            FROM genesis__Funding_Transaction__c
                                                            WHERE genesis__Application__r.genesis__Loan_Number__c = '300023456'
                                                            LIMIT 1];
            System.assertEquals(VOIDED,txnList[0].Status__c, ASSERTION_FAILED);
            System.assertEquals(4000,txnList[0].Pricing_Detail__r.Principal_Advanced__c, ASSERTION_FAILED);
            System.assertEquals(9000, txnList[0].Pricing_Detail__r.genesis__Application__r.Peak_Loan_Volume__c, ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is to test with a funding transaction whose clearing suspense flag is true and the request is being done by growmark api only integration profile
    * @author Kabir Pramanik | 03-16-2025 
    **/
    @isTest 
    static void testGmkApiUserClearingSuspenseTxn(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = URL;
        request.httpMethod = POST_METHOD;
        RestContext.response = response;
        List<genesis__Funding_Transaction__c> fundingTxnList = getFundingTxnList();
        fundingTxnList[0].Is_Clearing_Suspense__c = true;
        fundingTxnList[0].Growmark_Transaction_Source_ID__c = '111222333';
        Database.update(fundingTxnList, true);
        System.runAs(ExternalAPITestHelper.getUserByProfileName(PROFILE_GMK_API_INTEGRATION)){
            Test.startTest();
            ExternalAPITransactionVoiding.voidTransaction('111222333', '300023456-A');
            List<genesis__Funding_Transaction__c> txnList = [SELECT Id,
                                                                        Status__c,
                                                                        Pricing_Detail__r.Credit_Balance__c
                                                            FROM genesis__Funding_Transaction__c
                                                            WHERE genesis__Application__r.genesis__Loan_Number__c = '300023456'
                                                            LIMIT 1];
            System.assertEquals(VOIDED,txnList[0].Status__c, ASSERTION_FAILED);
            System.assertEquals(1000,txnList[0].Pricing_Detail__r.Credit_Balance__c, ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is to test with funding transaction whose status is Voided and the request is being done by cfa external api profile user
    * @author Kabir Pramanik | 03-16-2025 
    **/
    @isTest 
    static void testCfaExtApiTxnWithVoidStatus(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '106763');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc@123');
        request.requestUri = URL;
        request.httpMethod = POST_METHOD;
        RestContext.response = response;
        List<genesis__Funding_Transaction__c> fundingTxnList = getFundingTxnList();
        fundingTxnList[0].Growmark_Transaction_Source_ID__c = '111222333';
        fundingTxnList[0].Status__c = VOIDED;
        Database.update(fundingTxnList, true);
        System.runAs(ExternalAPITestHelper.getUserByProfileName(PROFILE_CFA_EXTERNAL_API)){
            Test.startTest();
            ExternalAPITransactionVoiding.voidTransaction('111222333', '300023456-A');
            System.assertEquals(null, response.statusCode, ASSERTION_FAILED);
            List<clcommon__Log__c> logList = [SELECT Id FROM clcommon__Log__c WHERE Name = :ExternalAPIUtilities.CLASS_NAME LIMIT 1];
            System.assertEquals(false, logList.isEmpty(), ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is to test with a funding transaction whose cleared status is true and the request is being done by cfa external api profile user
    * @author Kabir Pramanik | 03-16-2025 
    **/
    @isTest 
    static void testCfaExtApiTxnClearedTrue(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '106763');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc@123');
        request.requestUri = URL;
        request.httpMethod = POST_METHOD;
        RestContext.response = response;
        List<genesis__Funding_Transaction__c> fundingTxnList = getFundingTxnList();
        fundingTxnList[0].Growmark_Transaction_Source_ID__c = '111222333';
        fundingTxnList[0].genesis__Cleared__c = true; 
        Database.update(fundingTxnList, true);
        System.runAs(ExternalAPITestHelper.getUserByProfileName(PROFILE_CFA_EXTERNAL_API)){
            Test.startTest();
            ExternalAPITransactionVoiding.voidTransaction('111222333', '300023456-A');
            System.assertEquals(null, response.statusCode, ASSERTION_FAILED);
            List<clcommon__Log__c> logList = [SELECT Id FROM clcommon__Log__c WHERE Name = :ExternalAPIUtilities.CLASS_NAME LIMIT 1];
            System.assertEquals(false, logList.isEmpty(), ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is to test with a regular transaction whose status is not voided or it is not cleared yet and the request is being done by cfa external api profile user
    * @author Kabir Pramanik | 03-16-2025 
    **/
    @isTest 
    static void testCfaExtApiRegularTxn(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '106763');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc@123');
        request.requestUri = URL;
        request.httpMethod = POST_METHOD;
        RestContext.response = response;
        List<genesis__Funding_Transaction__c> fundingTxnList = getFundingTxnList();
        fundingTxnList[0].Is_Clearing_Suspense__c = false;
        fundingTxnList[0].Growmark_Transaction_Source_ID__c = '111222333';
        Database.update(fundingTxnList, true);
        System.runAs(ExternalAPITestHelper.getUserByProfileName(PROFILE_CFA_EXTERNAL_API)){
            Test.startTest();
            ExternalAPITransactionVoiding.voidTransaction('111222333', '300023456-A');
            List<genesis__Funding_Transaction__c> txnList = [SELECT Id,
                                                                        Status__c,
                                                                        Pricing_Detail__r.Principal_Advanced__c,
                                                                        Pricing_Detail__r.genesis__Application__r.Peak_Loan_Volume__c
                                                            FROM genesis__Funding_Transaction__c
                                                            WHERE genesis__Application__r.genesis__Loan_Number__c = '300023456'
                                                            LIMIT 1];
            System.assertEquals(VOIDED,txnList[0].Status__c, ASSERTION_FAILED);
            System.assertEquals(4000,txnList[0].Pricing_Detail__r.Principal_Advanced__c, ASSERTION_FAILED);
            System.assertEquals(9000, txnList[0].Pricing_Detail__r.genesis__Application__r.Peak_Loan_Volume__c, ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is to test with a funding transaction whose clearing suspense flag is true and the request is being done by cfa external api profile user
    * @author Kabir Pramanik | 03-16-2025 
    **/
    @isTest 
    static void testCfaExtApiClearingSuspenseTxn(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '106763');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc@123');
        request.requestUri = URL;
        request.httpMethod = POST_METHOD;
        RestContext.response = response;
        List<genesis__Funding_Transaction__c> fundingTxnList = getFundingTxnList();
        fundingTxnList[0].Is_Clearing_Suspense__c = true;
        fundingTxnList[0].Growmark_Transaction_Source_ID__c = '111222333';
        Database.update(fundingTxnList, true);
        System.runAs(ExternalAPITestHelper.getUserByProfileName(PROFILE_CFA_EXTERNAL_API)){
            Test.startTest();
            ExternalAPITransactionVoiding.voidTransaction('111222333', '300023456-A');
            List<genesis__Funding_Transaction__c> txnList = [SELECT Id,
                                                                        Status__c,
                                                                        Pricing_Detail__r.Credit_Balance__c
                                                            FROM genesis__Funding_Transaction__c
                                                            WHERE genesis__Application__r.genesis__Loan_Number__c = '300023456'
                                                            LIMIT 1];
            System.assertEquals(VOIDED,txnList[0].Status__c, ASSERTION_FAILED);
            System.assertEquals(1000,txnList[0].Pricing_Detail__r.Credit_Balance__c, ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is to test with funding transaction whose status is Voided and the request is being done by certified lender
    * @author Kabir Pramanik | 03-16-2025 
    **/
    @isTest 
    static void testCertifiedLenderTxnWithVoidStatus(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '106763');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc@123');
        request.requestUri = URL;
        request.httpMethod = POST_METHOD;
        RestContext.response = response;
        List<genesis__Funding_Transaction__c> fundingTxnList = getFundingTxnList();
        fundingTxnList[0].Growmark_Transaction_Source_ID__c = '111222333';
        fundingTxnList[0].Status__c = VOIDED;
        Database.update(fundingTxnList, true);
        System.runAs(ExternalAPITestHelper.getUserByProfileName(ExternalConstants.CERTIFIED_LENDER)){
            Test.startTest();
            ExternalAPITransactionVoiding.voidTransaction('111222333', '300023456-A');
            System.assertEquals(null, response.statusCode, ASSERTION_FAILED);
            List<clcommon__Log__c> logList = [SELECT Id FROM clcommon__Log__c WHERE Name = :ExternalAPIUtilities.CLASS_NAME LIMIT 1];
            System.assertEquals(false, logList.isEmpty(), ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is to test with a funding transaction whose cleared status is true and the request is being done by certified lender
    * @author Kabir Pramanik | 03-16-2025 
    **/
    @isTest 
    static void testCertifiedLenderTxnClearedTrue(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '106763');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc@123');
        request.requestUri = URL;
        request.httpMethod = POST_METHOD;
        RestContext.response = response;
        List<genesis__Funding_Transaction__c> fundingTxnList = getFundingTxnList();
        fundingTxnList[0].Growmark_Transaction_Source_ID__c = '111222333';
        fundingTxnList[0].genesis__Cleared__c = true; 
        Database.update(fundingTxnList, true);
        System.runAs(ExternalAPITestHelper.getUserByProfileName(ExternalConstants.CERTIFIED_LENDER)){
            Test.startTest();
            ExternalAPITransactionVoiding.voidTransaction('111222333', '300023456-A');
            System.assertEquals(null, response.statusCode, ASSERTION_FAILED);
            List<clcommon__Log__c> logList = [SELECT Id FROM clcommon__Log__c WHERE Name = :ExternalAPIUtilities.CLASS_NAME LIMIT 1];
            System.assertEquals(false, logList.isEmpty(), ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is to test with a regular transaction whose status is not voided or it is not cleared yet and the request is being done by certified lender
    * @author Kabir Pramanik | 03-16-2025 
    **/
    @isTest 
    static void testCertifiedLenderRegularTxn(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '106763');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc@123');
        request.requestUri = URL;
        request.httpMethod = POST_METHOD;
        RestContext.response = response;
        List<genesis__Funding_Transaction__c> fundingTxnList = getFundingTxnList();
        fundingTxnList[0].Is_Clearing_Suspense__c = false;
        fundingTxnList[0].Growmark_Transaction_Source_ID__c = '111222333';
        Database.update(fundingTxnList, true);
        System.runAs(ExternalAPITestHelper.getUserByProfileName(ExternalConstants.CERTIFIED_LENDER)){
            Test.startTest();
            ExternalAPITransactionVoiding.voidTransaction('111222333', '300023456-A');
            List<genesis__Funding_Transaction__c> txnList = [SELECT Id,
                                                                        Status__c,
                                                                        Pricing_Detail__r.Principal_Advanced__c,
                                                                        Pricing_Detail__r.genesis__Application__r.Peak_Loan_Volume__c
                                                            FROM genesis__Funding_Transaction__c
                                                            WHERE genesis__Application__r.genesis__Loan_Number__c = '300023456'
                                                            LIMIT 1];
            System.assertEquals(VOIDED,txnList[0].Status__c, ASSERTION_FAILED);
            System.assertEquals(4000,txnList[0].Pricing_Detail__r.Principal_Advanced__c, ASSERTION_FAILED);
            System.assertEquals(9000, txnList[0].Pricing_Detail__r.genesis__Application__r.Peak_Loan_Volume__c, ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is to test with a funding transaction whose clearing suspense flag is true and the request is being done by certified lender
    * @author Kabir Pramanik | 03-16-2025 
    **/
    @isTest 
    static void testCertifiedLenderClearingSuspenseTxn(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '106763');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc@123');
        request.requestUri = URL;
        request.httpMethod = POST_METHOD;
        RestContext.response = response;
        List<genesis__Funding_Transaction__c> fundingTxnList = getFundingTxnList();
        fundingTxnList[0].Is_Clearing_Suspense__c = true;
        fundingTxnList[0].Growmark_Transaction_Source_ID__c = '111222333';
        Database.update(fundingTxnList, true);
        System.runAs(ExternalAPITestHelper.getUserByProfileName(ExternalConstants.CERTIFIED_LENDER)){
            Test.startTest();
            ExternalAPITransactionVoiding.voidTransaction('111222333', '300023456-A');
            List<genesis__Funding_Transaction__c> txnList = [SELECT Id,
                                                                        Status__c,
                                                                        Pricing_Detail__r.Credit_Balance__c
                                                            FROM genesis__Funding_Transaction__c
                                                            WHERE genesis__Application__r.genesis__Loan_Number__c = '300023456'
                                                            LIMIT 1];
            System.assertEquals(VOIDED,txnList[0].Status__c, ASSERTION_FAILED);
            System.assertEquals(1000,txnList[0].Pricing_Detail__r.Credit_Balance__c, ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is to test with a funding transaction whose clearing suspense flag is true and the request is being done by certified lender who does not have any party with the application
    * @author Kabir Pramanik | 03-16-2025 
    **/
    @isTest 
    static void testInvalidAccessTxnVoidingFailure(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '106763');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc@123');
        request.requestUri = URL;
        request.httpMethod = POST_METHOD;
        RestContext.response = response;
        List<genesis__Funding_Transaction__c> fundingTxnList = getFundingTxnList();
        fundingTxnList[0].Is_Clearing_Suspense__c = true;
        fundingTxnList[0].Growmark_Transaction_Source_ID__c = '111222333';
        Database.update(fundingTxnList, true);
        List<clcommon__Party__c> partyList = [SELECT Id 
                                                FROM clcommon__Party__c 
                                                WHERE genesis__Application__r.genesis__Loan_Number__c = '300023456' 
                                                AND clcommon__Type__r.Name = :ExternalConstants.CERTIFIED_LENDER_PARTY 
                                                LIMIT 1];
        Database.delete(partyList, true);
        System.runAs(ExternalAPITestHelper.getUserByProfileName(ExternalConstants.CERTIFIED_LENDER)){
            Test.startTest();
            ExternalAPITransactionVoiding.voidTransaction('111222333', '300023456-A');
            System.assertEquals(null, response.statusCode, ASSERTION_FAILED);
            List<clcommon__Log__c> logList = [SELECT Id FROM clcommon__Log__c WHERE Name = :ExternalAPIUtilities.CLASS_NAME LIMIT 1];
            System.assertEquals(false, logList.isEmpty(), ASSERTION_FAILED);
            Test.stopTest();
        }
    }
}