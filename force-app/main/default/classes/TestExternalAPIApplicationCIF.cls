/**********************************************************************************************
 * @className         : TestExternalAPIApplicationCIF
 * @description       : Test Class for ExternalAPIApplicationCIF 
 * @author            : simranjha
 * @created Date      : 01-03-2022
 * @last modified on  : 03-19-2025
 * @last modified by  : Kabir Pramanik
 **********************************************************************************************/

@IsTest
public without sharing class TestExternalAPIApplicationCIF {
    private static final String ASSERTION_FAILED = 'Assertion failed';
    private static final String URL = '/SearchLoan';
    private static final String POST_METHOD = 'POST';
    private static final String GET_METHOD = 'GET';
    private static final String PROFILE_CFA_ADMIN = 'CFA Admin User';
    private static final String PROFILE_GMK_API_INTEGRATION = 'Growmark API Only Integration Profile';
    private static final String PROFILE_CFA_EXTERNAL_API = 'CFA External API Profile';
    private static final String PROFILE_AGVEND_EXTERNAL_USER = 'AgVend External User Profile';
    private static final String PROFILE_LOAN_ACCOUNTING = 'Loan Accounting';
    private static final String PROFILE_MASTER_CREDIT = 'Master Credit';
    private static final String PROFILE_CREDIT = 'Credit';

    /**
    * @description Creating test data
    * @author Kabir Pramanik | 03-11-2025 
    **/
    @TestSetup
    static void makeData(){
        // Creating Business Information
        genesis__Business_Information__c dealerBusinessInfoObj = ExternalAPITestHelper.createBusinessInfoForDealer();
        genesis__Business_Information__c borrowerBusinessInfoObj = ExternalAPITestHelper.createBusinessInfoForBorrower();
        genesis__Business_Information__c borrowerBusinessInfoTwo = ExternalAPITestHelper.createBusinessInfoForBorrower();
        Database.insert(new List<genesis__Business_Information__c>{dealerBusinessInfoObj, borrowerBusinessInfoObj, borrowerBusinessInfoTwo},true);

        // Creating Legal Entity for Borrower
        clcommon__Legal_Entity__c entityObj = ExternalAPITestHelper.createSolePropLegalEntity();
        Database.insert(entityObj, true);

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
        Account agvendAccObj = ExternalAPITestHelper.createAccount();
        agvendAccObj.Name = 'Agvend Account';
        agvendAccObj.CIF_Number__c = '111198';
        clAccountObj.CIF_Number__c = '106763';
        clAccountObj.Coop_Type__c = ExternalConstants.GROWMARK_COOP_TYPE;
        borrowerAccountObj.Coop_Type__c = ExternalConstants.GROWMARK_COOP_TYPE;
        borrowerAccountObj.CIF_Number__c = '106755';
        Database.insert(new List<Account>{borrowerAccountObj, clAccountObj, agvendAccObj}, true);

        // Creating Contact for Certified Lender, Borrower
        Contact clContactObj = ExternalAPITestHelper.createCLContact(clAccountObj.Id);
        Contact borrowerContactObj = ExternalAPITestHelper.createBorrowerContact(borrowerAccountObj.Id);
        Contact agvendContactObj = ExternalAPITestHelper.createBorrowerContact(agvendAccObj.Id);
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
        applicationObj.Note_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        genesis__Applications__c appObjTwo = ExternalAPITestHelper.createCurrCropYearApplication(paramForApplicationMap);
        appObjTwo.My_Program__c = rateCardHeaderObj.Id;
        appObjTwo.Dealer_Name__c = dealerAccountObj.Id;
        appObjTwo.genesis__Loan_Number__c = '123456';
        appObjTwo.Loan_Id__c = '55555';
        appObjTwo.Note_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        appObjTwo.Crop_Year__c = null;
        Database.insert(new List<genesis__Applications__c>{applicationObj, appObjTwo}, true);

        // Creating party types
        clcommon__Party_Type__c clPartyTypeObj = ExternalAPITestHelper.createPartyType(ExternalConstants.CERTIFIED_LENDER_PARTY);
        clcommon__Party_Type__c borrowerPartyTypeObj = ExternalAPITestHelper.createPartyType(ExternalConstants.BORROWER_PARTY);
        Database.insert(new List<clcommon__Party_Type__c> {clPartyTypeObj, borrowerPartyTypeObj}, true);

        // Creating Borrower Party map
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

        clcommon__Party__c clPartyObj = ExternalAPITestHelper.createParty(paramForClPartyMap);
        clcommon__Party__c borrowerPartyObj = ExternalAPITestHelper.createApplicantParty(paramForBorrowerPartyMap);

        paramForClPartyMap.put('applicationId', appObjTwo.Id);
        paramForBorrowerPartyMap.put('applicationId', appObjTwo.Id);
        clcommon__party__c clPartyObjTwo = ExternalAPITestHelper.createParty(paramForClPartyMap);
        clcommon__Party__c borrowerPartyObjTwo = ExternalAPITestHelper.createApplicantParty(paramForBorrowerPartyMap);
        Database.insert(new List<clcommon__Party__c> {clPartyObj,borrowerPartyObj, clPartyObjTwo, borrowerPartyObjTwo}, true);

        List<genesis__Application_Pricing_Detail__c> pricingDetailsObjList = ExternalAPITestHelper.createApplicationPricings(applicationObj);
        List<genesis__Application_Pricing_Detail__c> pricingObjListTwo = ExternalAPITestHelper.createApplicationPricings(appObjTwo);
        pricingDetailsObjList.addALL(pricingObjListTwo);
        Database.insert(pricingDetailsObjList, true);

        //Create Payment Modes
        Map<String, clcommon__Payment_Mode__c> paymentModeMap = ExternalAPITestHelper.createPaymentMode();
        Database.insert(new List<clcommon__Payment_Mode__c> {
            paymentModeMap.get(ConstantValues.ACH)
        }, true);

        genesis__Funding_Transaction__c achTxnObj = ExternalAPITestHelper.createFundingTransaction(paymentModeMap.get(ConstantValues.ACH).Id, null, applicationObj.Id);
        achTxnObj.Pricing_Detail__c = pricingDetailsObjList[0].Id;
        achTxnObj.genesis__Cleared__c = true;
        achTxnObj.Posted_to_NLS__c = false;
        achTxnObj.Is_Clearing_Suspense__c = false;
        genesis__Funding_Transaction__c achTxnObjTwo = ExternalAPITestHelper.createFundingTransaction(paymentModeMap.get(ConstantValues.ACH).Id, null, appObjTwo.Id);
        achTxnObj.Pricing_Detail__c = pricingObjListTwo[0].Id;
        achTxnObj.genesis__Cleared__c = true;
        achTxnObj.Posted_to_NLS__c = false;
        achTxnObj.Is_Clearing_Suspense__c = false;
        Database.insert(new List<genesis__Funding_Transaction__c>{achTxnObj, achTxnObjTwo}, true);

        createMultipleProfileUsers(new Map<String, Id>{
            'clContactId' => clContactObj.Id,
            'agvendContactId' => agvendContactObj.Id
        });
    }
    
    /**
    * @description This method is to create different users with different profiles
    * @author Kabir Pramanik | 03-19-2025 
    * @param contactIdMap 
    **/
    private static void createMultipleProfileUsers(Map<String, Id> contactIdMap){
        User clUser = ExternalAPITestHelper.createCLUser(contactIdMap.get('clContactId'));
        User cfaAdminUser = ExternalAPITestHelper.createUserByProfileName(PROFILE_CFA_ADMIN, 'cfa.adminuser919@yopmail.com');
        User gmkApiOnlyUser = ExternalAPITestHelper.createUserByProfileName(PROFILE_GMK_API_INTEGRATION, 'growmark.apionly111@yopmail.com');
        User cfaExternalApiUser = ExternalAPITestHelper.createUserByProfileName(PROFILE_CFA_EXTERNAL_API, 'cfa.externalapi333@yopmail.com');
        User agvendExternalUser = ExternalAPITestHelper.createUserByProfileName(PROFILE_AGVEND_EXTERNAL_USER, 'agvend.external101@yopmail.com');
        agvendExternalUser.ContactId = contactIdMap.get('agvendContactId');
        Database.insert(new List<User>{clUser, cfaAdminUser, gmkApiOnlyUser, cfaExternalApiUser, agvendExternalUser},true);
    }
    /**
    * @description This method returns the user of the certified lender
    * @author Kabir Pramanik | 03-12-2025 
    * @return User 
    **/
    private static User getCLUser(){
        return [SELECT Id 
                FROM User 
                WHERE username = 'ross.geller@yopmail.com' 
                AND Profile.Name = :ExternalConstants.CERTIFIED_LENDER
                LIMIT 1][0];
    }
    /**
    * @description This method is to test exception when null value passed as a dealer cif
    * @author Kabir Pramanik | 03-12-2025 
    **/
    @isTest 
    static void testNullDealerCifException(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = URL;
        request.httpMethod = POST_METHOD;
        RestContext.request = request;
        RestContext.response = response;
        List<genesis__Applications__c> appList = new List<genesis__Applications__c>();
        List<clcommon__Log__c> logList = new List<clcommon__Log__c>();
        System.runAs(getCLUser()){
            Test.startTest();
            ExternalAPIApplicationCIF.applicationRecordCIF(null);
            appList = (List<genesis__Applications__c>) JSON.deserialize(response.responseBody.toString(), List<genesis__Applications__c>.class);
            logList = [SELECT Id FROM clcommon__Log__c WHERE Name = :ExternalAPIApplicationCIF.class.getName() LIMIT 1];
            System.assertEquals(true, appList.isEmpty(), ASSERTION_FAILED);
            System.assertEquals(false, logList.isEmpty(), ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is to test exception when blank value is passed as cif number
    * @author Kabir Pramanik | 03-19-2025 
    **/
    @isTest 
    static void testBlankDealerCifException(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = URL;
        request.httpMethod = POST_METHOD;
        RestContext.request = request;
        RestContext.response = response;
        List<genesis__Applications__c> appList = new List<genesis__Applications__c>();
        List<clcommon__Log__c> logList = new List<clcommon__Log__c>();
        System.runAs(getCLUser()){
            Test.startTest();
            ExternalAPIApplicationCIF.applicationRecordCIF('');
            appList = (List<genesis__Applications__c>) JSON.deserialize(response.responseBody.toString(), List<genesis__Applications__c>.class);
            logList = [SELECT Id FROM clcommon__Log__c WHERE Name = :ExternalAPIApplicationCIF.class.getName() LIMIT 1];
            System.assertEquals(true, appList.isEmpty(), ASSERTION_FAILED);
            System.assertEquals(false, logList.isEmpty(), ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is to test exception when the loggedIn user has Agvend profile but the cif number passed does not come under the listed external api dealer cif numbers
    * @author Kabir Pramanik | 03-13-2025 
    **/
    @isTest 
    static void testAgvendProfileInvalidExternalApiDealerCif(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = URL;
        request.httpMethod = POST_METHOD;
        RestContext.request = request;
        RestContext.response = response;
        List<genesis__Applications__c> appList = new List<genesis__Applications__c>();
        List<clcommon__Log__c> logList = new List<clcommon__Log__c>();
        
        System.runAs(ExternalAPITestHelper.getUserByProfileName(PROFILE_AGVEND_EXTERNAL_USER)){
            Test.startTest();
            ExternalAPIApplicationCIF.applicationRecordCIF('102555');
            appList = (List<genesis__Applications__c>) JSON.deserialize(response.responseBody.toString(), List<genesis__Applications__c>.class);
            logList = [SELECT Id FROM clcommon__Log__c WHERE Name = :ExternalAPIApplicationCIF.class.getName() LIMIT 1];
            System.assertEquals(true, appList.isEmpty(), ASSERTION_FAILED);
            System.assertEquals(false, logList.isEmpty(), ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is to test exception when the user is CL and cif number passed does not come under the listed external api dealer cif numbers
    * @author Kabir Pramanik | 03-13-2025 
    **/
    @isTest 
    static void testClInvalidExternalApiDealerCif(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = URL;
        request.httpMethod = POST_METHOD;
        RestContext.request = request;
        RestContext.response = response;
        List<genesis__Applications__c> appList = new List<genesis__Applications__c>();
        List<clcommon__Log__c> logList = new List<clcommon__Log__c>();
        User clUser = getCLUser();
        System.runAs(clUser){
            Test.startTest();
            ExternalAPIApplicationCIF.applicationRecordCIF('102555');
            appList = (List<genesis__Applications__c>) JSON.deserialize(response.responseBody.toString(), List<genesis__Applications__c>.class);
            logList = [SELECT Id FROM clcommon__Log__c WHERE Name = :ExternalAPIApplicationCIF.class.getName() LIMIT 1];
            System.assertEquals(true, appList.isEmpty(), ASSERTION_FAILED);
            System.assertEquals(false, logList.isEmpty(), ASSERTION_FAILED);
            Test.stopTest(); 
        }
    }

    /**
    * @description This method is to test success scenario when the loggedIn user has Agvend profile and the cif number passed come under the listed external api dealer cif numbers
    * @author Kabir Pramanik | 03-13-2025 
    **/
    @isTest 
    static void testAgvendProfileValidExternalApiDealerCif(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = URL;
        request.httpMethod = POST_METHOD;
        RestContext.request = request;
        RestContext.response = response;
        List<Object> responseList = new List<Object>();
        Map<String, Object> individualAppResMap = new Map<String, Object>();
        Map<String,Object> pricingResponseMap = new Map<String,Object>();
        
        System.runAs(ExternalAPITestHelper.getUserByProfileName(PROFILE_AGVEND_EXTERNAL_USER)){
            Test.startTest();
            ExternalAPIApplicationCIF.applicationRecordCIF('106763');
            responseList = (List<Object>) JSON.deserializeUntyped(response.responseBody.toString());
            individualAppResMap = (Map<String, Object>)responseList[0];
            pricingResponseMap = (Map<String, Object>)individualAppResMap.get(ExternalConstants.PRICING_DETAIL_KEY);
            System.assertEquals(ExternalConstants.TWO_HUNDRED_STATUS_CODE, response.statusCode, ASSERTION_FAILED);
            System.assertEquals(2, responseList.size(), ASSERTION_FAILED);
            System.assertEquals('300023456', individualAppResMap.get('genesis__Loan_Number__c'), ASSERTION_FAILED);
            System.assertEquals(2, pricingResponseMap.get(ExternalConstants.TOTAL_SIZE_KEY), ASSERTION_FAILED);
            Test.stopTest(); 
        }
    }
    
    /**
    * @description This method is to test success scenario when the loggedIn user is CL and the cif number passed come under the listed external api dealer cif numbers
    * @author Kabir Pramanik | 03-13-2025 
    **/
    @isTest 
    static void testClValidExternalApiDealerCif(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = URL;
        request.httpMethod = POST_METHOD;
        RestContext.request = request;
        RestContext.response = response;
        List<Object> responseList = new List<Object>();
        Map<String, Object> individualAppResMap = new Map<String, Object>();
        Map<String,Object> pricingResponseMap = new Map<String,Object>();

        System.runAs(getCLUser()){
            Test.startTest();
            ExternalAPIApplicationCIF.applicationRecordCIF('106763');
            responseList = (List<Object>) JSON.deserializeUntyped(response.responseBody.toString());
            individualAppResMap = (Map<String, Object>)responseList[0];
            pricingResponseMap = (Map<String, Object>)individualAppResMap.get(ExternalConstants.PRICING_DETAIL_KEY);
            System.assertEquals(ExternalConstants.TWO_HUNDRED_STATUS_CODE, response.statusCode, ASSERTION_FAILED);
            System.assertEquals(2, responseList.size(), ASSERTION_FAILED);
            System.assertEquals('300023456', individualAppResMap.get('genesis__Loan_Number__c'), ASSERTION_FAILED);
            System.assertEquals(2, pricingResponseMap.get(ExternalConstants.TOTAL_SIZE_KEY), ASSERTION_FAILED);
            Test.stopTest(); 
        }
    }
    /**
    * @description This method is to test scneraio where there is no active application present under the dealer
    * @author Kabir Pramanik | 03-13-2025 
    **/
    @isTest 
    static void testNoActiveApplicationUnderDealer(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = URL;
        request.httpMethod = POST_METHOD;
        RestContext.request = request;
        RestContext.response = response;
        List<clcommon__Log__c> logList = new List<clcommon__Log__c>();
        List<genesis__Applications__c> appList = [SELECT Id FROM genesis__Applications__c WHERE Dealer_Name__r.CIF_Number__c = '106763'];
        Database.delete(appList, true);
        System.runAs(getCLUser()){
            Test.startTest();
            ExternalAPIApplicationCIF.applicationRecordCIF('106763');
            appList = (List<genesis__Applications__c>) JSON.deserialize(response.responseBody.toString(), List<genesis__Applications__c>.class);
            logList = [SELECT Id FROM clcommon__Log__c WHERE Name = :ExternalAPIApplicationCIF.class.getName() LIMIT 1];
            System.assertEquals(true, appList.isEmpty(), ASSERTION_FAILED);
            System.assertEquals(false, logList.isEmpty(), ASSERTION_FAILED);
            Test.stopTest(); 
        }
    }
    /**
    * @description This method is to test scneraio where there is active application present under the dealer
    * @author Kabir Pramanik | 03-13-2025 
    **/
    @isTest
    static void testActiveApplicationPresentUnderDealer(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = URL;
        request.httpMethod = POST_METHOD;
        RestContext.request = request;
        RestContext.response = response;
        List<Object> responseList = new List<Object>();
        Map<String, Object> individualAppResMap = new Map<String, Object>();
        Map<String,Object> pricingResponseMap = new Map<String,Object>();
        System.runAs(getCLUser()){
            Test.startTest();
            ExternalAPIApplicationCIF.applicationRecordCIF('106763');
            responseList = (List<Object>) JSON.deserializeUntyped(response.responseBody.toString());
            individualAppResMap = (Map<String, Object>)responseList[0];
            pricingResponseMap = (Map<String, Object>)individualAppResMap.get(ExternalConstants.PRICING_DETAIL_KEY);
            System.assertEquals(ExternalConstants.TWO_HUNDRED_STATUS_CODE, response.statusCode, ASSERTION_FAILED);
            System.assertEquals(2, responseList.size(), ASSERTION_FAILED);
            System.assertEquals('300023456', individualAppResMap.get('genesis__Loan_Number__c'), ASSERTION_FAILED);
            System.assertEquals(2, pricingResponseMap.get(ExternalConstants.TOTAL_SIZE_KEY), ASSERTION_FAILED);
            Test.stopTest(); 
        }
    }
    /**
    * @description This method is to test scneraio where there is active application present under the dealer whose ERP Id and Maturity Date are set as null
    * @author Kabir Pramanik | 03-13-2025 
    **/
    @isTest 
    static void testErpIdMaturityDateNullValueOfApplication(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = URL;
        request.httpMethod = POST_METHOD;
        RestContext.request = request;
        RestContext.response = response;
        List<Object> responseList = new List<Object>();
        Map<String, Object> individualAppResMap = new Map<String, Object>();
        Map<String,Object> pricingResponseMap = new Map<String,Object>();
        List<genesis__Applications__c> activeAppList = [SELECT Id 
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Number__c = '300023456' 
                                                        AND genesis__Status__c = :ExternalConstants.ACTIVE_APPLICATION_STATUS];
        activeAppList[0].ERP_Id__c = null;
        activeAppList[0].genesis__Maturity_Date__c = null;
        Database.update(activeAppList, true);
        System.runAs(getCLUser()){
            Test.startTest();
            ExternalAPIApplicationCIF.applicationRecordCIF('106763');
            responseList = (List<Object>) JSON.deserializeUntyped(response.responseBody.toString());
            individualAppResMap = (Map<String, Object>)responseList[0];
            pricingResponseMap = (Map<String, Object>)individualAppResMap.get(ExternalConstants.PRICING_DETAIL_KEY);
            System.assertEquals(ExternalConstants.TWO_HUNDRED_STATUS_CODE, response.statusCode, ASSERTION_FAILED);
            System.assertEquals(2, responseList.size(), ASSERTION_FAILED);
            System.assertEquals('300023456', individualAppResMap.get('genesis__Loan_Number__c'), ASSERTION_FAILED);
            System.assertEquals(2, pricingResponseMap.get(ExternalConstants.TOTAL_SIZE_KEY), ASSERTION_FAILED);
            Test.stopTest(); 
        }
    }
    /**
    * @description This method is to test what we get as response when the application does not have any pricing detail associated with it
    * @author Kabir Pramanik | 03-13-2025 
    **/
    @isTest 
    static void testActiveApplicationWithNoPricing(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = URL;
        request.httpMethod = POST_METHOD;
        RestContext.request = request;
        RestContext.response = response;
        List<Object> responseList = new List<Object>();
        Map<String, Object> individualAppResMap = new Map<String, Object>();
        List<genesis__Application_Pricing_Detail__c> appPricingList = [SELECT Id 
                                                                        FROM genesis__Application_Pricing_Detail__c 
                                                                        WHERE genesis__Application__r.genesis__Loan_Number__c In ('300023456', '12345')];
        Database.delete(appPricingList, true);
        System.runAs(getCLUser()){
            Test.startTest();
            ExternalAPIApplicationCIF.applicationRecordCIF('106763');
            responseList = (List<Object>)JSON.deserializeUntyped(response.responseBody.toString());
            individualAppResMap = (Map<String, Object>)responseList[0];
            System.assertEquals(ExternalConstants.TWO_HUNDRED_STATUS_CODE, response.statusCode, ASSERTION_FAILED);
            System.assertEquals(2, responseList.size(), ASSERTION_FAILED);
            System.assertEquals(null, individualAppResMap.get(ExternalConstants.PRICING_DETAIL_KEY), ASSERTION_FAILED);
            Test.stopTest(); 
        }
    }
    /**
    * @description This method is to test exception scenarion where the api is being called by system admin who does not have any party with any application
    * @author Kabir Pramanik | 03-19-2025 
    **/
    @isTest 
    static void testSystemAdminApplicationAccessException(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = URL;
        request.httpMethod = POST_METHOD;
        RestContext.request = request;
        RestContext.response = response;
        List<genesis__Applications__c> appList = new List<genesis__Applications__c>();
        List<clcommon__Log__c> logList = new List<clcommon__Log__c>();
        System.runAs(ExternalAPITestHelper.getAdminUser()){
            Test.startTest();
            ExternalAPIApplicationCIF.applicationRecordCIF('106763');
            appList = (List<genesis__Applications__c>) JSON.deserialize(response.responseBody.toString(), List<genesis__Applications__c>.class);
            logList = [SELECT Id FROM clcommon__Log__c WHERE Name = :ExternalAPIApplicationCIF.class.getName() LIMIT 1];
            System.assertEquals(true, appList.isEmpty(), ASSERTION_FAILED);
            System.assertEquals(false, logList.isEmpty(), ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is to test exception scenarion where the api is being called by cfa admin user who does not have any party with any application
    * @author Kabir Pramanik | 03-19-2025 
    **/
    @isTest 
    static void testCFAAdminApplicationAccessException(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = URL;
        request.httpMethod = POST_METHOD;
        RestContext.request = request;
        RestContext.response = response;
        List<genesis__Applications__c> appList = new List<genesis__Applications__c>();
        List<clcommon__Log__c> logList = new List<clcommon__Log__c>();
        System.runAs(ExternalAPITestHelper.getUserByProfileName(PROFILE_CFA_ADMIN)){
            Test.startTest();
            ExternalAPIApplicationCIF.applicationRecordCIF('106763');
            appList = (List<genesis__Applications__c>) JSON.deserialize(response.responseBody.toString(), List<genesis__Applications__c>.class);
            logList = [SELECT Id FROM clcommon__Log__c WHERE Name = :ExternalAPIApplicationCIF.class.getName() LIMIT 1];
            System.assertEquals(true, appList.isEmpty(), ASSERTION_FAILED);
            System.assertEquals(false, logList.isEmpty(), ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is to test exception scenarion where the api is being called by cfa admin user who does not have any party with any application
    * @author Kabir Pramanik | 03-19-2025 
    **/
    @isTest 
    static void testLoanAccountingApplicationAccessException(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = URL;
        request.httpMethod = POST_METHOD;
        RestContext.request = request;
        RestContext.response = response;
        List<genesis__Applications__c> appList = new List<genesis__Applications__c>();
        List<clcommon__Log__c> logList = new List<clcommon__Log__c>();
        System.runAs(ExternalAPITestHelper.getUserByProfileName(PROFILE_LOAN_ACCOUNTING)){
            Test.startTest();
            ExternalAPIApplicationCIF.applicationRecordCIF('106763');
            appList = (List<genesis__Applications__c>) JSON.deserialize(response.responseBody.toString(), List<genesis__Applications__c>.class);
            logList = [SELECT Id FROM clcommon__Log__c WHERE Name = :ExternalAPIApplicationCIF.class.getName() LIMIT 1];
            System.assertEquals(true, appList.isEmpty(), ASSERTION_FAILED);
            System.assertEquals(false, logList.isEmpty(), ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is to test exception scenarion where the api is being called by credit user who does not have any party with any application
    * @author Kabir Pramanik | 03-19-2025 
    **/
    @isTest 
    static void testCreditUserApplicatioinAccessException(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = URL;
        request.httpMethod = POST_METHOD;
        RestContext.request = request;
        RestContext.response = response;
        List<genesis__Applications__c> appList = new List<genesis__Applications__c>();
        List<clcommon__Log__c> logList = new List<clcommon__Log__c>();
        System.runAs(ExternalAPITestHelper.getUserByProfileName(PROFILE_CREDIT)){
            Test.startTest();
            ExternalAPIApplicationCIF.applicationRecordCIF('106763');
            appList = (List<genesis__Applications__c>) JSON.deserialize(response.responseBody.toString(), List<genesis__Applications__c>.class);
            logList = [SELECT Id FROM clcommon__Log__c WHERE Name = :ExternalAPIApplicationCIF.class.getName() LIMIT 1];
            System.assertEquals(true, appList.isEmpty(), ASSERTION_FAILED);
            System.assertEquals(false, logList.isEmpty(), ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is to test exception scenarion where the api is being called by master credit user who does not have any party with any application
    * @author Kabir Pramanik | 03-19-2025 
    **/
    @isTest 
    static void testMasterCreditUserApplicationAccessException(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = URL;
        request.httpMethod = POST_METHOD;
        RestContext.request = request;
        RestContext.response = response;
        List<genesis__Applications__c> appList = new List<genesis__Applications__c>();
        List<clcommon__Log__c> logList = new List<clcommon__Log__c>();
        System.runAs(ExternalAPITestHelper.getUserByProfileName(PROFILE_MASTER_CREDIT)){
            Test.startTest();
            ExternalAPIApplicationCIF.applicationRecordCIF('106763');
            appList = (List<genesis__Applications__c>) JSON.deserialize(response.responseBody.toString(), List<genesis__Applications__c>.class);
            logList = [SELECT Id FROM clcommon__Log__c WHERE Name = :ExternalAPIApplicationCIF.class.getName() LIMIT 1];
            System.assertEquals(true, appList.isEmpty(), ASSERTION_FAILED);
            System.assertEquals(false, logList.isEmpty(), ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    // --------------------------------GET request endpoint scenarios----------------------------------
    /**
    * @description This method is to test the api by passing the cif number in the requestUri and calling the api with a CL
    * @author Kabir Pramanik | 03-18-2025 
    **/
    @isTest 
    static void testGetLoansWithCifPassed(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri =  URL + '/106763';
        request.httpMethod = GET_METHOD;
        RestContext.request = request;
        RestContext.response = response;
        List<genesis__Applications__c> appList = new List<genesis__Applications__c>();
        System.runAs(getCLUser()){
            Test.startTest();
            appList= ExternalAPIApplicationCIF.getLoansByCIFNumber();
            System.assertEquals(null, response.statusCode, ASSERTION_FAILED);
            System.assertEquals(2, appList.size(), ASSERTION_FAILED);
            System.assertEquals(2, appList[0].genesis__Pricing_Details__r.size(), ASSERTION_FAILED);
            System.assertEquals(2, appList[1].genesis__Pricing_Details__r.size(), ASSERTION_FAILED);
            System.assertEquals(1, appList[0].genesis__Funding_Transactions__r.size(), ASSERTION_FAILED);
            System.assertEquals(ExternalConstants.ACTIVE_APPLICATION_STATUS, appList[0].genesis__Status__c, ASSERTION_FAILED);
            System.assertEquals(ExternalConstants.GROWMARK_COOP_TYPE, appList[0].genesis__Account__r.Coop_Type__c, ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is to test the api by not passing the cif number in the requestUri and calling the api with a CL
    * @author Kabir Pramanik | 03-18-2025 
    **/
    @isTest
    static void testGetLoansWithoutCifPassed(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        //cif number is not appended in the requestUri
        request.requestUri =  URL;
        request.httpMethod = GET_METHOD;
        RestContext.request = request;
        RestContext.response = response;
        Boolean isExceptionThrown = false;
        List<genesis__Applications__c> appList = new List<genesis__Applications__c>();
        System.runAs(getCLUser()){
            Test.startTest();
            try{
                appList = ExternalAPIApplicationCIF.getLoansByCIFNumber();
            }catch (Exception exp){
                isExceptionThrown = true;
            }
            System.assertEquals(true, isExceptionThrown, ASSERTION_FAILED);
            System.assertEquals(0, appList.size(), ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is to test the api by passing the cif number in the requestUri and calling the api with a System Admin
    * @author Kabir Pramanik | 03-18-2025 
    **/
    @isTest 
    static void testSystemAdminGetLoansWithCifPassed(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri =  URL + '/106763';
        request.httpMethod = GET_METHOD;
        RestContext.request = request;
        RestContext.response = response;
        List<genesis__Applications__c> appList = new List<genesis__Applications__c>();
        System.runAs(ExternalAPITestHelper.getAdminUser()){
            Test.startTest();
            appList= ExternalAPIApplicationCIF.getLoansByCIFNumber();
            System.assertEquals(null, response.statusCode, ASSERTION_FAILED);
            System.assertEquals(2, appList.size(), ASSERTION_FAILED);
            System.assertEquals(2, appList[0].genesis__Pricing_Details__r.size(), ASSERTION_FAILED);
            System.assertEquals(2, appList[1].genesis__Pricing_Details__r.size(), ASSERTION_FAILED);
            System.assertEquals(1, appList[0].genesis__Funding_Transactions__r.size(), ASSERTION_FAILED);
            System.assertEquals(ExternalConstants.ACTIVE_APPLICATION_STATUS, appList[0].genesis__Status__c, ASSERTION_FAILED);
            System.assertEquals(ExternalConstants.GROWMARK_COOP_TYPE, appList[0].genesis__Account__r.Coop_Type__c, ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    
    /**
    * @description This method is to test the api by passing the cif number in the requestUri and calling the api with a CFA Admin user
    * @author Kabir Pramanik | 03-18-2025 
    **/
    @isTest 
    static void testCFAAdminGetLoansWithCifPassed(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri =  URL + '/106763';
        request.httpMethod = GET_METHOD;
        RestContext.request = request;
        RestContext.response = response;
        List<genesis__Applications__c> appList = new List<genesis__Applications__c>();
        System.runAs(ExternalAPITestHelper.getUserByProfileName(PROFILE_CFA_ADMIN)){
            Test.startTest();
            appList= ExternalAPIApplicationCIF.getLoansByCIFNumber();
            System.assertEquals(null, response.statusCode, ASSERTION_FAILED);
            System.assertEquals(2, appList.size(), ASSERTION_FAILED);
            System.assertEquals(2, appList[0].genesis__Pricing_Details__r.size(), ASSERTION_FAILED);
            System.assertEquals(2, appList[1].genesis__Pricing_Details__r.size(), ASSERTION_FAILED);
            System.assertEquals(1, appList[0].genesis__Funding_Transactions__r.size(), ASSERTION_FAILED);
            System.assertEquals(ExternalConstants.ACTIVE_APPLICATION_STATUS, appList[0].genesis__Status__c, ASSERTION_FAILED);
            System.assertEquals(ExternalConstants.GROWMARK_COOP_TYPE, appList[0].genesis__Account__r.Coop_Type__c, ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    
    /**
    * @description This method is to test the api by passing the cif number in the requestUri and calling the api with a Growmark API Only Integration Profile user
    * @author Kabir Pramanik | 03-18-2025 
    **/
    @isTest 
    static void testGmkApiOnlyUserGetLoansWithCifPassed(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri =  URL + '/106763';
        request.httpMethod = GET_METHOD;
        RestContext.request = request;
        RestContext.response = response;
        List<genesis__Applications__c> appList = new List<genesis__Applications__c>();
        System.runAs(ExternalAPITestHelper.getUserByProfileName(PROFILE_GMK_API_INTEGRATION)){
            Test.startTest();
            appList = ExternalAPIApplicationCIF.getLoansByCIFNumber();
            System.assertEquals(null, response.statusCode, ASSERTION_FAILED);
            System.assertEquals(2, appList.size(), ASSERTION_FAILED);
            System.assertEquals(2, appList[0].genesis__Pricing_Details__r.size(), ASSERTION_FAILED);
            System.assertEquals(2, appList[1].genesis__Pricing_Details__r.size(), ASSERTION_FAILED);
            System.assertEquals(1, appList[0].genesis__Funding_Transactions__r.size(), ASSERTION_FAILED);
            System.assertEquals(ExternalConstants.ACTIVE_APPLICATION_STATUS, appList[0].genesis__Status__c, ASSERTION_FAILED);
            System.assertEquals(ExternalConstants.GROWMARK_COOP_TYPE, appList[0].genesis__Account__r.Coop_Type__c, ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is to test the api where the cl doesn't have  any party with any application. So no application should be accessed by him
    * @author Kabir Pramanik | 03-18-2025 
    **/
    @isTest 
    static void testNoClPartyWithLoan(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri =  URL + '/106763';
        request.httpMethod = GET_METHOD;
        RestContext.request = request;
        RestContext.response = response;
        List<genesis__Applications__c> appList = new List<genesis__Applications__c>();
        List<clcommon__Log__c> logList = new List<clcommon__Log__c>();
        List<clcommon__Party__c> clPartyList = [SELECT Id 
                                                FROM clcommon__Party__c 
                                                WHERE genesis__Application__r.Loan_Id__c In('139000', '55555')
                                                AND clcommon__Type__r.Name = :ExternalConstants.CERTIFIED_LENDER_PARTY];
        Database.delete(clPartyList, true);
        
        System.runAs(getCLUser()){
            Test.startTest();
            appList = ExternalAPIApplicationCIF.getLoansByCIFNumber();
            logList = [SELECT Id 
                        FROM clcommon__Log__c 
                        WHERE Name = :ExternalAPIUtilities.class.getName() 
                        LIMIT 1];
            System.assertEquals(false, logList.isEmpty(), ASSERTION_FAILED);
            System.assertEquals(0, appList.size(), ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is to test scenario where application has no pricing details associated with it
    * @author Kabir Pramanik | 03-18-2025 
    **/
    @isTest 
    static void testLoanWithNoPricingDetails(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri =  URL + '/106763';
        request.httpMethod = GET_METHOD;
        RestContext.request = request;
        RestContext.response = response;
        List<genesis__Applications__c> appList = new List<genesis__Applications__c>();
        List<genesis__Application_Pricing_Detail__c> pricingList = [SELECT Id 
                                                                    FROM genesis__Application_Pricing_Detail__c];
        Database.delete(pricingList, true);
        
        System.runAs(getCLUser()){
            Test.startTest();
            appList = ExternalAPIApplicationCIF.getLoansByCIFNumber();
            System.assertEquals(null, response.statusCode, ASSERTION_FAILED);
            System.assertEquals(2, appList.size(), ASSERTION_FAILED);
            System.assertEquals(0, appList[0].genesis__Pricing_Details__r.size(), ASSERTION_FAILED);
            System.assertEquals(0, appList[1].genesis__Pricing_Details__r.size(), ASSERTION_FAILED);
            System.assertEquals(0, appList[0].genesis__Funding_Transactions__r.size(), ASSERTION_FAILED);
            System.assertEquals(0, appList[1].genesis__Funding_Transactions__r.size(), ASSERTION_FAILED);
            System.assertEquals(ExternalConstants.ACTIVE_APPLICATION_STATUS, appList[0].genesis__Status__c, ASSERTION_FAILED);
            System.assertEquals(ExternalConstants.GROWMARK_COOP_TYPE, appList[0].genesis__Account__r.Coop_Type__c, ASSERTION_FAILED);
        }
    }
    /**
    * @description This method is to test scenario where application has no funding transaction associated with it
    * @author Kabir Pramanik | 03-18-2025 
    **/
    @isTest 
    static void testLoanWithNoFundingTrnx(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri =  URL + '/106763';
        request.httpMethod = GET_METHOD;
        RestContext.request = request;
        RestContext.response = response;
        List<genesis__Applications__c> appList = new List<genesis__Applications__c>();
        List<genesis__Funding_Transaction__c> fundTranxList = [SELECT Id FROM genesis__Funding_Transaction__c];
        Database.delete(fundTranxList, true);
        
        System.runAs(getCLUser()){
            Test.startTest();
            appList = ExternalAPIApplicationCIF.getLoansByCIFNumber();
            System.assertEquals(null, response.statusCode, ASSERTION_FAILED);
            System.assertEquals(2, appList.size(), ASSERTION_FAILED);
            System.assertEquals(2, appList[0].genesis__Pricing_Details__r.size(), ASSERTION_FAILED);
            System.assertEquals(2, appList[1].genesis__Pricing_Details__r.size(), ASSERTION_FAILED);
            System.assertEquals(0, appList[0].genesis__Funding_Transactions__r.size(), ASSERTION_FAILED);
            System.assertEquals(0, appList[1].genesis__Funding_Transactions__r.size(), ASSERTION_FAILED);
            System.assertEquals(ExternalConstants.ACTIVE_APPLICATION_STATUS, appList[0].genesis__Status__c, ASSERTION_FAILED);
            System.assertEquals(ExternalConstants.GROWMARK_COOP_TYPE, appList[0].genesis__Account__r.Coop_Type__c, ASSERTION_FAILED);
        }
    }
    /**
    * @description This method is to test scenario where there is no active application associated with the cl user
    * @author Kabir Pramanik | 03-18-2025 
    **/
    @isTest 
    static void testNoActiveApplication(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri =  URL + '/106763';
        request.httpMethod = GET_METHOD;
        RestContext.request = request;
        RestContext.response = response;
        List<genesis__Applications__c> appList = new List<genesis__Applications__c>();
        List<genesis__Applications__c> activeAppList = [SELECT Id 
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Status__c = :ExternalConstants.ACTIVE_APPLICATION_STATUS];
        for(genesis__Applications__c app : activeAppList){
            app.genesis__Status__c = ExternalConstants.NEW_ENTERED_APPLICATION_STATUS;
        }
        Database.update(activeAppList, true);
        System.runAs(getCLUser()){
            Test.startTest();
            appList = ExternalAPIApplicationCIF.getLoansByCIFNumber();
            System.assertEquals(null, response.statusCode, ASSERTION_FAILED);
            System.assertEquals(0, appList.size(), ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is to test scenario where the api is being called by a certified lender whose coop type is not Growmark
    * @author Kabir Pramanik | 03-19-2025 
    **/
    @isTest 
    static void testNonGmkClLoanAccessException(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri =  URL + '/106763';
        request.httpMethod = GET_METHOD;
        RestContext.request = request;
        RestContext.response = response;
        List<genesis__Applications__c> appList = new List<genesis__Applications__c>();
        List<clcommon__Log__c> logList = new List<clcommon__Log__c>();
        List<Account> clAccountObjList = [SELECT Id FROM Account WHERE Name = 'Ross Geller' AND RecordType.Name = :ExternalConstants.CERTIFIED_LENDER];
        clAccountObjList[0].Coop_Type__c = ExternalConstants.LANDUS_COOP_TYPE;
        Database.update(clAccountObjList, true);
        
        System.runAs(getCLUser()){
            Test.startTest();
            appList = ExternalAPIApplicationCIF.getLoansByCIFNumber();
            logList = [SELECT Id 
                        FROM clcommon__Log__c 
                        WHERE Name = :ExternalAPIUtilities.class.getName() 
                        LIMIT 1];
            System.assertEquals(false, logList.isEmpty(), ASSERTION_FAILED);
            System.assertEquals(0, appList.size(), ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is to test scenario where the api is being called by a loan accounting user 
    * @author Kabir Pramanik | 03-19-2025 
    **/
    @isTest 
    static void testLoanAccountingUserGetLoanException(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri =  URL + '/106763';
        request.httpMethod = GET_METHOD;
        RestContext.request = request;
        RestContext.response = response;
        List<genesis__Applications__c> appList = new List<genesis__Applications__c>();
        List<clcommon__Log__c> logList = new List<clcommon__Log__c>();

        System.runAs(ExternalAPITestHelper.getUserByProfileName(PROFILE_LOAN_ACCOUNTING)){
            Test.startTest();
            appList = ExternalAPIApplicationCIF.getLoansByCIFNumber();
            logList = [SELECT Id 
                        FROM clcommon__Log__c 
                        WHERE Name = :ExternalAPIUtilities.class.getName() 
                        LIMIT 1];
            System.assertEquals(false, logList.isEmpty(), ASSERTION_FAILED);
            System.assertEquals(0, appList.size(), ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is to test scenario where the api is being called by a master credit user
    * @author Kabir Pramanik | 03-19-2025 
    **/
    @isTest 
    static void testMasterCreditUserGetLoanException(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri =  URL + '/106763';
        request.httpMethod = GET_METHOD;
        RestContext.request = request;
        RestContext.response = response;
        List<genesis__Applications__c> appList = new List<genesis__Applications__c>();
        List<clcommon__Log__c> logList = new List<clcommon__Log__c>();

        System.runAs(ExternalAPITestHelper.getUserByProfileName(PROFILE_MASTER_CREDIT)){
            Test.startTest();
            appList = ExternalAPIApplicationCIF.getLoansByCIFNumber();
            logList = [SELECT Id 
                        FROM clcommon__Log__c 
                        WHERE Name = :ExternalAPIUtilities.class.getName() 
                        LIMIT 1];
            System.assertEquals(false, logList.isEmpty(), ASSERTION_FAILED);
            System.assertEquals(0, appList.size(), ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description This method is to test scenario where the api is being called by a credit user
    * @author Kabir Pramanik | 03-19-2025 
    **/
    @isTest 
    static void testCreditUserGetLoanException(){
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri =  URL + '/106763';
        request.httpMethod = GET_METHOD;
        RestContext.request = request;
        RestContext.response = response;
        List<genesis__Applications__c> appList = new List<genesis__Applications__c>();
        List<clcommon__Log__c> logList = new List<clcommon__Log__c>();

        System.runAs(ExternalAPITestHelper.getUserByProfileName(PROFILE_CREDIT)){
            Test.startTest();
            appList = ExternalAPIApplicationCIF.getLoansByCIFNumber();
            logList = [SELECT Id 
                        FROM clcommon__Log__c 
                        WHERE Name = :ExternalAPIUtilities.class.getName() 
                        LIMIT 1];
            System.assertEquals(false, logList.isEmpty(), ASSERTION_FAILED);
            System.assertEquals(0, appList.size(), ASSERTION_FAILED);
            Test.stopTest();
        }
    }
}