/**
 * @description       : Test class for ExternalScoreApplicationAPI
 * @author            : Soumik Pattanayak
 * @group             : 
 * @last modified on  : 03-01-2025
 * @last modified by  : Krishanu Chinya
**/
@isTest
public with sharing class ExternalScoreApplicationAPITest {
    /**
    * @description : setup method to create test data
    * @author Suraj Kumar | 12-27-2024 
    **/
    @TestSetup
    static void setup(){
        // Creating Business Information
        genesis__Business_Information__c dealerBusinessInfoObj = ExternalAPITestHelper.createBusinessInfoForDealer();
        genesis__Business_Information__c borrowerBusinessInfoObj = ExternalAPITestHelper.createBusinessInfoForBorrower();
        Database.insert(new List<genesis__Business_Information__c>{dealerBusinessInfoObj,borrowerBusinessInfoObj},true);

        // Creating Legal Entity for Borrower
        clcommon__Legal_Entity__c entityObj = ExternalAPITestHelper.createSolePropLegalEntity();
        Database.insert(entityObj, true);

        // Creating Account for Dealer
        Account dealerAccountObj = ExternalAPITestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        dealerAccountObj.CIF_Number__c = '102555';
        dealerAccountObj.Enable_ERP_Id__c = true;
        dealerAccountObj.Unique_Id__c = 'abc@123';
        Database.insert(dealerAccountObj, true);

        // Creating Account for Certified Lender
        Account clAccountObj = ExternalAPITestHelper.createCLAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);

        Account borrowerAccountObj = ExternalAPITestHelper.createSolePropAccount(entityObj, borrowerBusinessInfoObj.Id);
        borrowerAccountObj.Unique_Id__c = 'TestBorrUniqueId004';

        Account coBorrowerAccObj = ExternalAPITestHelper.createSolePropAccount(entityObj, borrowerBusinessInfoObj.Id);
        coBorrowerAccObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CoApplicant').getRecordTypeId();
        coBorrowerAccObj.Unique_Id__c = 'TestCoBorrUniqueId004';

        Account scoredBorrowerAccObj = ExternalAPITestHelper.createAccount();
        scoredBorrowerAccObj.Score_1__c='710';
        scoredBorrowerAccObj.SBSS70_Score__c='190';
        scoredBorrowerAccObj.FICO_Recorded_On__c=Date.today().addDays(-1);
        scoredBorrowerAccObj.Unique_Id__c = 'TestScored01';

        Database.insert(new List<Account>{clAccountObj,borrowerAccountObj, coBorrowerAccObj,scoredBorrowerAccObj}, true);

        // Creating Contact for Certified Lender
        Contact clContactObj = ExternalAPITestHelper.createCLContact(clAccountObj.Id);

        Contact borrowerContactObj = ExternalAPITestHelper.createBorrowerContact(borrowerAccountObj.Id);

        Contact coBorrowerContactObj = ExternalAPITestHelper.createBorrowerContact(coBorrowerAccObj.Id);

        Contact scoredBorrowerContObj = ExternalAPITestHelper.createContact();
        scoredBorrowerContObj.AccountId = scoredBorrowerAccObj.Id;
        scoredBorrowerContObj.genesis__SSN__c = 'GHFB67666';
        scoredBorrowerContObj.Confirm_SSN__c = 'GHFB67666';

        Database.insert(new List<Contact>{clContactObj, borrowerContactObj, coBorrowerContactObj,scoredBorrowerContObj},true);

        Dealer_Applicant_Relationship__c borrowerDealerRelObj = ExternalAPITestHelper.createApplicantDealerRelationship(borrowerAccountObj, borrowerContactObj, dealerAccountObj);
        Dealer_Applicant_Relationship__c coBorrowerDealerRelObj = ExternalAPITestHelper.createApplicantDealerRelationship(coBorrowerAccObj, coBorrowerContactObj, dealerAccountObj);
        Database.insert(new List<Dealer_Applicant_Relationship__c>{borrowerDealerRelObj,coBorrowerDealerRelObj},true);

        // Creating CL Purpose of Application
        clcommon__CL_Purpose__c clPurposeObj = ExternalAPITestHelper.createCLPurposeForApplication();
        Database.insert(clPurposeObj, true);

        // Creating Cl Product of Application
        clcommon__CL_Product__c clProductObj = ExternalAPITestHelper.createCLProductForApplication();
        Database.insert(clProductObj, true);

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
        applicationObj.genesis__Status__c = ExternalConstants.SIGNATURE_COMPLETED_APPLICATION_STATUS;
        applicationObj.Dealer_Applicant_Relationship__c = borrowerDealerRelObj.Id;
        Database.insert(applicationObj, true);

        // Creating Reciprocal Role 
        clcommon__Reciprocal_Role__c roleObj = ExternalAPITestHelper.createCertifiedLenderRole();
        Database.insert(roleObj, true);

        // Creating Relationship between Dealer and Certified Lender
        clcommon__Relationship__c clDealerRelationshipObj = ExternalAPITestHelper.createCLDealerRelationship(roleObj,dealerAccountObj.Id,clAccountObj.Id);
        Database.insert(clDealerRelationshipObj, true);

        clcommon__Party_Type__c borrowerPartyTypeObj = ExternalAPITestHelper.createPartyType('BORROWER');
        clcommon__Party_Type__c principalPartyTypeObj = ExternalAPITestHelper.createPartyType('PRINCIPAL');
        Database.insert( new List<clcommon__Party_Type__c>{borrowerPartyTypeObj,principalPartyTypeObj},true);

        // Creating borrower Party for current application
        Map<String,Id> paramForborrowerPartyMap = new Map<String,Id>{
            'accountId' => borrowerAccountObj.Id,
            'contactId' => borrowerContactObj.Id,
            'partyTypeId' => borrowerPartyTypeObj.Id,
            'applicationId' => applicationObj.Id,
            'dealerApplicantRelId' => borrowerDealerRelObj.Id
        };

        clcommon__Party__c borrowerPartyObj = ExternalAPITestHelper.createApplicantParty(paramForborrowerPartyMap);

        // Creating Principal Party for current application
        Map<String,Id> paramForPrincipalPartyMap = new Map<String,Id>{
            'accountId' => coBorrowerAccObj.Id,
            'contactId' => coBorrowerContactObj.Id,
            'partyTypeId' => principalPartyTypeObj.Id,
            'applicationId' => applicationObj.Id,
            'dealerApplicantRelId' => coBorrowerDealerRelObj.Id
        };

        clcommon__Party__c principalPartyObj = ExternalAPITestHelper.createApplicantParty(paramForPrincipalPartyMap);
        principalPartyObj.Principal_Number__c = 1;

        Database.insert(new List<clcommon__Party__c>{borrowerPartyObj,principalPartyObj},true);
    }

    /**
    * @description : Method to get application
    * @author Suraj Kumar | 01-11-2025 
    * @return genesis__Applications__c 
    **/
    private static genesis__Applications__c getApplication(){
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                genesis__Account__c,
                                                                genesis__Account__r.Unique_Id__c,
                                                                Dealer_Name__c
                                                            FROM genesis__Applications__c 
                                                            WHERE genesis__Loan_Number__c = '300023456'
                                                            LIMIT 1];
        return applicationList[0];
    }

    /**
    * @description generates the request body
    * @author Soumik Pattanayak | 28-08-2024 
    * @return Map<String, Object> 
    **/
    private static Map<String,Object> getRequestMap(){
        genesis__Applications__c applicationObj = getApplication();

        Map<String,Object> applicationDetailsMap = new Map<String,Object>{
            'id' => applicationObj.Id
        };
        Map<String,Object> borrowerDetailsMap = new Map<String,Object>{
            'user_id' => applicationObj.genesis__Account__r.Unique_Id__c
        };

        Map<String,Object> requestMap = new Map<String,Object>{
            'application_details' => applicationDetailsMap,
            'borrower_details' => borrowerDetailsMap
        };
        return requestMap;
    }

    /**
    * @description : Method to get legal entity
    * @author Suraj Kumar | 01-11-2025 
    * @return clcommon__Legal_Entity__c 
    **/
    private static clcommon__Legal_Entity__c getEntityType(){
        List<clcommon__Legal_Entity__c> entityList = [SELECT Id, 
                                                            clcommon__Legal_Entity_Type__c,
                                                            Name 
                                                        FROM clcommon__Legal_Entity__c LIMIT 1];
        return entityList[0];
    }

    /**
    * @description : Method to get scored account
    * @author Suraj Kumar | 01-11-2025 
    * @return Account 
    **/
    private static Account getScoredAccount(){
        List<Account> accountList = [SELECT Id, 
                                            Score_1__c, 
                                            SBSS70_Score__c, 
                                            FICO_Recorded_On__c 
                                        FROM Account 
                                        WHERE Unique_Id__c = 'TestScored01'];
        return accountList[0];
    }



    /**
    * @description Test for unauthorized user when userId is invalid
    * @author Soumik Pattanayak | 04-09-2024 
    **/
    @isTest
    private static void testUnauthorizeUser(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/scoreApplication';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc@123');
       
        Map<String,Object> borrowerDetailsMap = new Map<String,Object>{
            'user_id' => 'Invalid'
        };

        Map<String,Object> requestMap = getRequestMap();
        requestMap.put('borrower_details',borrowerDetailsMap);
        
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalScoreApplicationAPI.generateScore();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_ONE_STATUS_CODE, RestContext.response.statusCode, 'Assertion failed');
            Test.stopTest();
        }
    }

    /**
    * @description test when request body is empty
    * @author Soumik Pattanayak | 04-09-2024 
    **/
    @isTest
    private static void testEmptyRequestBody(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/scoreApplication';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc@123');
        
        request.requestBody = Blob.valueOf(JSON.serialize(new Map<String,Object>()));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalScoreApplicationAPI.generateScore();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description test when application details are missing
    * @author Soumik Pattanayak | 04-09-2024 
    **/
    @isTest
    private static void testApplicationDetailMissing(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/scoreApplication';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc@123');
        Map<String,Object> requestMap = getRequestMap();
        requestMap.remove('application_details');
    
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalScoreApplicationAPI.generateScore();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description Test when Borrower details are missing
    * @author Soumik Pattanayak | 04-09-2024 
    **/
    @isTest
    private static void testBorrowerDetailMissing(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/scoreApplication';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc@123');
        Map<String,Object> requestMap = getRequestMap();
        requestMap.remove('borrower_details');
        
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalScoreApplicationAPI.generateScore();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description Test when Application Id is null
    * @author Soumik Pattanayak | 04-09-2024 
    **/
    @isTest
    private static void testAppIdNull(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/scoreApplication';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc@123');

        Map<String,Object> applicationDetailsMap = new Map<String,Object>{
            'id' => null
        };
        Map<String,Object> requestMap = getRequestMap();
        requestMap.put('application_details',applicationDetailsMap);
        
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalScoreApplicationAPI.generateScore();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

   
    /**
    * @description : Method to test when application id missing
    * @author Suraj Kumar | 12-27-2024 
    **/
    @isTest
    private static void testAppIdMissing(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/scoreApplication';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc@123');

        Map<String,Object> requestMap = getRequestMap();
        requestMap.put('application_details',new Map<String,Object>());
        
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalScoreApplicationAPI.generateScore();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description Test when Application Id is invalid
    * @author Soumik Pattanayak | 04-09-2024 
    **/
    @isTest
    private static void testAppIdInvalid(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/scoreApplication';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc@123');

        Map<String,Object> applicationDetailsMap = new Map<String,Object>{
            'id' => '12mVeO'
        };
        Map<String,Object> requestMap = getRequestMap();
        requestMap.put('application_details',applicationDetailsMap);
        
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalScoreApplicationAPI.generateScore();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description Test when User Id(Borrower Id) is null
    * @author Soumik Pattanayak | 04-09-2024 
    **/
    @isTest
    private static void testUserIdNull(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/scoreApplication';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc@123');
        Map<String,Object> borrowerDetailsMap = new Map<String,Object>{
            'user_id' => null
        };
        Map<String,Object> requestMap = getRequestMap();
        requestMap.put('borrower_details',borrowerDetailsMap);
        
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalScoreApplicationAPI.generateScore();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test for user id missing
    * @author Suraj Kumar | 12-27-2024 
    **/
    @isTest
    private static void testUserIdMissing(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/scoreApplication';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc@123');

        Map<String,Object> requestMap = getRequestMap();
        requestMap.put('borrower_details',new Map<String,Object>());
        
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalScoreApplicationAPI.generateScore();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test application belongs to another dealer
    * @author Suraj Kumar | 12-27-2024 
    **/
    @isTest
    private static void testAnotherDealerApplication(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/scoreApplication';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc@123');

        genesis__Applications__c applicationObj = getApplication();
        applicationObj.Dealer_Name__c = null;
        Database.update(applicationObj,true);
    
        Map<String,Object> requestMap = getRequestMap();
        requestMap.put('application_details',new Map<String,Object>{
            'id' => applicationObj.Id
        });

        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalScoreApplicationAPI.generateScore();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_ONE_STATUS_CODE, RestContext.response.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test invalid request body
    * @author Suraj Kumar | 12-27-2024 
    **/
    @isTest
    private static void testInvalidRequestBody(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/scoreApplication';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc@123');

        request.requestBody = Blob.valueOf(JSON.serialize(''));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalScoreApplicationAPI.generateScore();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description  Test when no parties in the application is scored
    * @author Soumik Pattanayak | 04-09-2024 
    **/
    @isTest
    private static void testScoringWithNoPartiesScored(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/scoreApplication';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc@123');
        Map<String,Object> requestMap = getRequestMap();
        
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalScoreApplicationAPI.generateScore();
            System.assertEquals(ExternalConstants.TWO_HUNDRED_ONE_STATUS_CODE, RestContext.response.statusCode,  'Assertion failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test for applicant is already scored within six month , Tier 1
    * @author Suraj Kumar | 12-27-2024 
    **/
    @isTest
    private static void testScoredWithinSixMonthTierOne(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/scoreApplication';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc@123');

        Account accountObj = getScoredAccount();

        accountObj.Score_1__c='849';
        accountObj.SBSS70_Score__c='210';
        accountObj.FICO_Recorded_On__c=Date.today().addDays(-1);
        Database.update(accountObj,true);
        
        Map<String,Object> requestMap = getRequestMap();
        
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalScoreApplicationAPI.generateScore();
            System.assertEquals(ExternalConstants.TWO_HUNDRED_ONE_STATUS_CODE, RestContext.response.statusCode, 'Assertion failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test for applicant is already scored within six month , Tier 2
    * @author Suraj Kumar | 12-27-2024 
    **/
    @isTest
    private static void testScoredWithinSixMonthTierTwo(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/scoreApplication';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc@123');

        Account accountObj = getScoredAccount();

        accountObj.Score_1__c='701';
        accountObj.SBSS70_Score__c='190';
        accountObj.FICO_Recorded_On__c=Date.today().addDays(-1);
        Database.update(accountObj,true);
        
        Map<String,Object> requestMap = getRequestMap();
        
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalScoreApplicationAPI.generateScore();
            System.assertEquals(ExternalConstants.TWO_HUNDRED_ONE_STATUS_CODE, RestContext.response.statusCode, 'Assertion failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test for applicant is already scored within six month , Tier 3
    * @author Suraj Kumar | 12-27-2024 
    **/
    @isTest
    private static void testScoredWithinSixMonthTierThree(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/scoreApplication';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc@123');

        
        Account accountObj = getScoredAccount();

        accountObj.Score_1__c='601';
        accountObj.SBSS70_Score__c='150';
        accountObj.FICO_Recorded_On__c=Date.today().addDays(-1);
        Database.update(accountObj,true);
        
        Map<String,Object> requestMap = getRequestMap();
        
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalScoreApplicationAPI.generateScore();
            System.assertEquals(ExternalConstants.TWO_HUNDRED_ONE_STATUS_CODE, RestContext.response.statusCode, 'Assertion failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test for applicant is already scored within six month , Tier 4
    * @author Suraj Kumar | 12-27-2024 
    **/
    @isTest
    private static void testScoredWithinSixMonthTierFour(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/scoreApplication';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc@123');

        
        Account accountObj = getScoredAccount();

        accountObj.Score_1__c='550';
        accountObj.SBSS70_Score__c='140';
        accountObj.FICO_Recorded_On__c=Date.today().addDays(-1);
        Database.update(accountObj,true);
        
        Map<String,Object> requestMap = getRequestMap();
        
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalScoreApplicationAPI.generateScore();
            System.assertEquals(ExternalConstants.TWO_HUNDRED_ONE_STATUS_CODE, RestContext.response.statusCode, 'Assertion failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test for applicant is already scored above six month 
    * @author Suraj Kumar | 12-27-2024 
    **/
    @isTest
    private static void testScoredAboveSixMonth(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/scoreApplication';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc@123');

        Account accountObj = getScoredAccount();

        accountObj.Score_1__c='850';
        accountObj.SBSS70_Score__c='201';
        accountObj.FICO_Recorded_On__c=Date.today().addDays(-240);
        Database.update(accountObj,true);
        
        Map<String,Object> requestMap = getRequestMap();
        
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalScoreApplicationAPI.generateScore();
            System.assertEquals(ExternalConstants.TWO_HUNDRED_ONE_STATUS_CODE, RestContext.response.statusCode, 'Assertion failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test for applicant is already scored within six month , Tier 1 for corporation
    * @author Suraj Kumar | 12-27-2024 
    **/
    @isTest
    private static void testScoredWithinSixMonthTierOneCorporation(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        clcommon__Legal_Entity__c entityObj = getEntityType();
        entityObj.clcommon__Legal_Entity_Type__c = 'Corporation';
        entityObj.Name = 'Corporation';
        Database.update(entityObj,true);
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/scoreApplication';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc@123');

        Account accountObj = getScoredAccount();

        accountObj.Score_1__c='849';
        accountObj.SBSS70_Score__c='210';
        accountObj.FICO_Recorded_On__c=Date.today().addDays(-1);
        Database.update(accountObj,true);
        
        Map<String,Object> requestMap = getRequestMap();
        
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalScoreApplicationAPI.generateScore();
            System.assertEquals(ExternalConstants.TWO_HUNDRED_ONE_STATUS_CODE, RestContext.response.statusCode, 'Assertion failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test for applicant is already scored within six month , Tier 2 for corporation
    * @author Suraj Kumar | 12-27-2024 
    **/
    @isTest
    private static void testScoredWithinSixMonthTierTwoCorporation(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        clcommon__Legal_Entity__c entityObj = getEntityType();
        entityObj.clcommon__Legal_Entity_Type__c = 'Corporation';
        entityObj.Name = 'Corporation';
        Database.update(entityObj,true);
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/scoreApplication';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc@123');

        Account accountObj = getScoredAccount();

        accountObj.Score_1__c='701';
        accountObj.SBSS70_Score__c='190';
        accountObj.FICO_Recorded_On__c=Date.today().addDays(-1);
        Database.update(accountObj,true);
        
        Map<String,Object> requestMap = getRequestMap();
        
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalScoreApplicationAPI.generateScore();
            System.assertEquals(ExternalConstants.TWO_HUNDRED_ONE_STATUS_CODE, RestContext.response.statusCode, 'Assertion failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test for applicant is already scored within six month , Tier 3 for corporation
    * @author Suraj Kumar | 12-27-2024 
    **/
    @isTest
    private static void testScoredWithinSixMonthTierThreeCorporation(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        clcommon__Legal_Entity__c entityObj = getEntityType();
        entityObj.clcommon__Legal_Entity_Type__c = 'Corporation';
        entityObj.Name = 'Corporation';
        Database.update(entityObj,true);
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/scoreApplication';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc@123');

        
        Account accountObj = getScoredAccount();

        accountObj.Score_1__c='601';
        accountObj.SBSS70_Score__c='150';
        accountObj.FICO_Recorded_On__c=Date.today().addDays(-1);
        Database.update(accountObj,true);
        
        Map<String,Object> requestMap = getRequestMap();
        
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalScoreApplicationAPI.generateScore();
            System.assertEquals(ExternalConstants.TWO_HUNDRED_ONE_STATUS_CODE, RestContext.response.statusCode, 'Assertion failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test for applicant is already scored within six month , Tier 4 for corporation
    * @author Suraj Kumar | 12-27-2024 
    **/
    @isTest
    private static void testScoredWithinSixMonthTierFourCorporation(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        clcommon__Legal_Entity__c entityObj = getEntityType();
        entityObj.clcommon__Legal_Entity_Type__c = 'Corporation';
        entityObj.Name = 'Corporation';
        Database.update(entityObj,true);
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/scoreApplication';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc@123');

        
        Account accountObj = getScoredAccount();

        accountObj.Score_1__c='550';
        accountObj.SBSS70_Score__c='140';
        accountObj.FICO_Recorded_On__c=Date.today().addDays(-1);
        Database.update(accountObj,true);
        
        Map<String,Object> requestMap = getRequestMap();
        
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalScoreApplicationAPI.generateScore();
            System.assertEquals(ExternalConstants.TWO_HUNDRED_ONE_STATUS_CODE, RestContext.response.statusCode, 'Assertion failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test for applicant is already scored above six month for corporation
    * @author Suraj Kumar | 12-27-2024 
    **/
    @isTest
    private static void testScoredAboveSixMonthCorporation(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        clcommon__Legal_Entity__c entityObj = getEntityType();
        entityObj.clcommon__Legal_Entity_Type__c = 'Corporation';
        entityObj.Name = 'Corporation';
        Database.update(entityObj,true);
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/scoreApplication';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc@123');

        Account accountObj = getScoredAccount();

        accountObj.Score_1__c='850';
        accountObj.SBSS70_Score__c='201';
        accountObj.FICO_Recorded_On__c=Date.today().addDays(-240);
        Database.update(accountObj,true);
        
        Map<String,Object> requestMap = getRequestMap();
        
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalScoreApplicationAPI.generateScore();
            System.assertEquals(ExternalConstants.TWO_HUNDRED_ONE_STATUS_CODE, RestContext.response.statusCode, 'Assertion failed');
            Test.stopTest();
        }
    }
    /**
    * @description : method to test scenario Dealer Cif key is missing
    * @author Kabir Pramanik | 09-25-2024 
    **/
    @isTest
    private static void testDealerCifMissing(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/scoreApplication';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc@123');
        Map<String,Object> requestMap = getRequestMap();
        
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalScoreApplicationAPI.generateScore();
            Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(response.responseBody.toString());
            Map<String,Object> responseContentMap = (Map<String,Object>)responseMap.get('content');
            String message = (String)responseContentMap.get('message');
            System.assertEquals(ExternalConstants.DEALER_CIF_MISSING, message, 'Assertion Failed');
            Test.stopTest();
        }
    }
    /**
    * @description : method to test scenario Dealer Token key is missing
    * @author Kabir Pramanik | 09-25-2024 
    **/
    @isTest
    private static void testDealerTokenMissing(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/scoreApplication';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        Map<String,Object> requestMap = getRequestMap();
        
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalScoreApplicationAPI.generateScore();
            Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(response.responseBody.toString());
            Map<String,Object> responseContentMap = (Map<String,Object>)responseMap.get('content');
            String message = (String)responseContentMap.get('message');
            System.assertEquals(ExternalConstants.DEALER_TOKEN_MISSING, message, 'Assertion Failed');
            Test.stopTest();
        }
    }
    /**
    * @description : method to test scenario Dealer CIF value is missing
    * @author Kabir Pramanik | 09-25-2024 
    **/
    @isTest
    private static void testDealeCifValueMissing(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/scoreApplication';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc@123');
        Map<String,Object> requestMap = getRequestMap();
        
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalScoreApplicationAPI.generateScore();
            Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(response.responseBody.toString());
            Map<String,Object> responseContentMap = (Map<String,Object>)responseMap.get('content');
            String message = (String)responseContentMap.get('message');
            System.assertEquals(ExternalConstants.DEALER_CIF_MISSING, message, 'Assertion Failed');
            Test.stopTest();
        }
    }
    /**
    * @description : method to test scenario Dealer Token value is missing
    * @author Kabir Pramanik | 09-25-2024 
    **/
    @isTest
    private static void testDealerTokenValueMissing(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/scoreApplication';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, '');
        Map<String,Object> requestMap = getRequestMap();
        
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalScoreApplicationAPI.generateScore();
            Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(response.responseBody.toString());
            Map<String,Object> responseContentMap = (Map<String,Object>)responseMap.get('content');
            String message = (String)responseContentMap.get('message');
            System.assertEquals(ExternalConstants.DEALER_TOKEN_MISSING, message, 'Assertion Failed');
            Test.stopTest();
        }
    }
    /**
    * @description : method to test scenario Dealer CIF value is invalid
    * @author Kabir Pramanik | 09-25-2024 
    **/
    @isTest
    private static void testInvalidDealerCif(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/scoreApplication';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555000');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc@123');
        Map<String,Object> requestMap = getRequestMap();
        
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalScoreApplicationAPI.generateScore();
            Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(response.responseBody.toString());
            Map<String,Object> responseContentMap = (Map<String,Object>)responseMap.get('content');
            String message = (String)responseContentMap.get('message');
            System.assertEquals(ExternalConstants.DEALER_CIF_INVALID, message, 'Assertion Failed');
            Test.stopTest();
        }
    }
    /**
    * @description : method to test scenario Dealer Token value is invalid
    * @author Kabir Pramanik | 09-25-2024 
    **/
    @isTest
    private static void testInvalidDealeToken(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/scoreApplication';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc@123098789');
        Map<String,Object> requestMap = getRequestMap();
        
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalScoreApplicationAPI.generateScore();
            Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(response.responseBody.toString());
            Map<String,Object> responseContentMap = (Map<String,Object>)responseMap.get('content');
            String message = (String)responseContentMap.get('message');
            System.assertEquals(ExternalConstants.DEALER_TOKEN_INVALID, message, 'Assertion Failed');
            Test.stopTest();
        }
    }

    @isTest
    private static void testScoringWithNoSigningMethod(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();

        genesis__Applications__c applicationObj = getApplication();
        applicationObj.signing_method__c = null;
        Database.update(applicationObj,true);

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/scoreApplication';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc@123');
        Map<String,Object> requestMap = getRequestMap();
        
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalScoreApplicationAPI.generateScore();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode,  'Assertion failed');
            Test.stopTest();
        }
    }

    @isTest
    private static void testScoringWithInvalidApplicationStatus(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();

        genesis__Applications__c applicationObj = getApplication();
        applicationObj.signing_method__c = ExternalConstants.IN_PERSON_HYBRID;
        applicationObj.genesis__Status__c = ExternalConstants.NEW_ENTERED_APPLICATION_STATUS;
        Database.update(applicationObj,true);

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/scoreApplication';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc@123');
        Map<String,Object> requestMap = getRequestMap();
        
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalScoreApplicationAPI.generateScore();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode,  'Assertion failed');
            Test.stopTest();
        }
    }
}