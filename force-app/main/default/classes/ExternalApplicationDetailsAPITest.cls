/**
 * @description       : Test class for ExternalApplicationDetailsAPI
 * @author            : Suraj Kumar | 07-05-2024
 * @group             : 
 * @last modified on  : 09-16-2024
 * @last modified by  : Kabir Pramanik
**/
@isTest
public with sharing class ExternalApplicationDetailsAPITest {
    @TestSetup
    static void setup() {
        // Creating Business Information
        genesis__Business_Information__c dealerBusinessInfoObj = ExternalAPITestHelper.createBusinessInfoForDealer();
        Database.insert(dealerBusinessInfoObj, true);

        // Creating Account for Dealer
        Account dealerAccountObj = ExternalAPITestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        dealerAccountObj.CIF_Number__c = '102555';
        dealerAccountObj.Enable_ERP_Id__c = true;
        dealerAccountObj.Unique_Id__c = 'abc@123';
        Database.insert(dealerAccountObj, true);

        // Creating Account for Certified Lender
        Account clAccountObj = ExternalAPITestHelper.createCLAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
        Database.insert(clAccountObj, true);

        // Creating Contact for Certified Lender
        Contact clContactObj = ExternalAPITestHelper.createCLContact(clAccountObj.Id);
        Database.insert(clContactObj,true);

        // Creating Legal Entity for Borrower
        clcommon__Legal_Entity__c entityObj = ExternalAPITestHelper.createSolePropLegalEntity();
        Database.insert(entityObj, true);
        
        //creating business info for borrower
        genesis__Business_Information__c borrowerBusinessInfoObj = ExternalAPITestHelper.createBusinessInfoForBorrower();
        Database.insert(borrowerBusinessInfoObj,true);

        // Creating Account for Borrower
        Account borrowerAccountObj = ExternalAPITestHelper.createSolePropAccount(entityObj, borrowerBusinessInfoObj.Id);
        //  borrowerAccountObj.Unique_Id__c = '001O100000E5kzvIAB';
        Database.insert(borrowerAccountObj, true);

        // Creating Contact for Borrower
        Contact borrowerContactObj = ExternalAPITestHelper.createBorrowerContact(borrowerAccountObj.Id);
        Database.insert(borrowerContactObj,true);

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
        Database.insert(applicationObj, true);

        // Creating Reciprocal Role 
        clcommon__Reciprocal_Role__c roleObj = ExternalAPITestHelper.createCertifiedLenderRole();
        Database.insert(roleObj, true);

        // Creating Relationship between Dealer and Certified Lender
        clcommon__Relationship__c clDealerRelationshipObj = ExternalAPITestHelper.createCLDealerRelationship(roleObj,dealerAccountObj.Id,clAccountObj.Id);
        Database.insert(clDealerRelationshipObj, true);
        clcommon__Collateral_Category__c collateralCategoryObj = ExternalAPITestHelper.createCollateralCategory();
        Database.insert(collateralCategoryObj,true);

        List<genesis__Credit_Rating_Matrix__c> creditRatingMatrixList = ExternalAPITestHelper.createCreditRatingMatrix();
        Database.insert(creditRatingMatrixList,true);
    }
    /**
    * @description : method to get request map
    * @author Suraj Kumar | 07-05-2024
    * @return Map<String, Object> 
    **/
    public static Map<String,Object> getRequestMap(){
        genesis__Applications__c applicationObj = [SELECT Id,
                                                            genesis__Account__c,
                                                            genesis__Account__r.Unique_Id__c,
                                                            genesis__Status__c
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Number__c = '300023456'
                                                        LIMIT 1];

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
    * @description : Method to test scenario request parameter Null
    * @author Suraj Kumar | 07-08-2024 
    **/
    @isTest 
    public static void testRequestBodyNull(){
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/getApplicationStatus';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc@123');

        request.requestBody = Blob.valueOf(JSON.serialize(null));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalApplicationDetailsAPI.doSentApplicationDetails();
            Test.stopTest();
            System.assertEquals(RestContext.response.statusCode, ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, 'Assertion Failed');
        }
    }

    /**
    * @description : method to test scanario application detail missing
    * @author Suraj Kumar | 07-08-2024 
    **/
    @isTest 
    public static void testAppDetailMissing(){
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/getApplicationStatus';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc@123');

        Map<String,Object> requestMap = getRequestMap();
        requestMap.remove('application_details');

        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalApplicationDetailsAPI.doSentApplicationDetails();
            Test.stopTest();
            System.assertEquals(RestContext.response.statusCode, ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, 'Assertion Failed');
        }
    }

    /**
    * @description : method to test scenario application id missing
    * @author Suraj Kumar | 07-08-2024 
    **/
    @isTest 
    public static void testAppIdMissing(){
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/getApplicationStatus';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc@123');

        Map<String,Object> requestMap = getRequestMap();
        requestMap.put('application_details',new Map<String,Object>());

        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalApplicationDetailsAPI.doSentApplicationDetails();
            Test.stopTest();
            System.assertEquals(RestContext.response.statusCode, ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, 'Assertion Failed');
        }
    }

    /**
    * @description : method to test scenario Borrower detail missing
    * @author Suraj Kumar | 07-08-2024 
    **/
    @isTest 
    public static void testBorrowerDetailMissing(){
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/getApplicationStatus';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc@123');

        Map<String,Object> requestMap = getRequestMap();
        requestMap.remove('borrower_details');

        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalApplicationDetailsAPI.doSentApplicationDetails();
            Test.stopTest();
            System.assertEquals(RestContext.response.statusCode, ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, 'Assertion Failed');
        }
    }

    /**
    * @description : method to test scenario user id missing
    * @author Suraj Kumar | 07-08-2024 
    **/
    @isTest 
    public static void testUserIdMissing(){
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/getApplicationStatus';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc@123');

        Map<String,Object> requestMap = getRequestMap();
        requestMap.put('borrower_details',new Map<String,Object>());

        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalApplicationDetailsAPI.doSentApplicationDetails();
            Test.stopTest();
            System.assertEquals(RestContext.response.statusCode, ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, 'Assertion Failed');
        }
    }

    /**
    * @description : method to test scenario Application id Invalid
    * @author Suraj Kumar | 07-08-2024 
    **/
    @isTest 
    public static void testAppIdInvalid(){
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/getApplicationStatus';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc@123');

        Map<String,Object> requestMap = getRequestMap();
        requestMap.put('application_details',new Map<String,Object>{
            'id' => 'test12345'
        });

        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalApplicationDetailsAPI.doSentApplicationDetails();
            Test.stopTest();
            System.assertEquals(RestContext.response.statusCode, ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, 'Assertion Failed');
        }
    }

    /**
    * @description : method to test scenario user id invalid
    * @author Suraj Kumar | 07-08-2024 
    **/
    @isTest 
    public static void testUserIdInvalid(){
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/getApplicationStatus';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc@123');

        Map<String,Object> requestMap = getRequestMap();
        requestMap.put('borrower_details',new Map<String,Object>{
            'user_id' => 'abcde12'
        });

        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalApplicationDetailsAPI.doSentApplicationDetails();
            Test.stopTest();
            System.assertEquals(RestContext.response.statusCode, ExternalConstants.FOUR_HUNDRED_ONE_STATUS_CODE, 'Assertion Failed');
        }
    }

    /**
    * @description : method to test scenario application status is not null and credit rating is Tier 3
    * @author Suraj Kumar | 07-08-2024 
    **/
    @isTest 
    public static void testAppDetailsTierThree(){
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        genesis__Applications__c applicationObj = [SELECT Id,
                                                            genesis__Status__c,
                                                            genesis__Credit_Rating__c
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Number__c = '300023456'
                                                        LIMIT 1];
        genesis__Credit_Rating_Matrix__c tier = [SELECT Id 
                                                        FROM genesis__Credit_Rating_Matrix__c 
                                                        WHERE Name = 'Tier 3'];
        applicationObj.genesis__Credit_Rating__c = tier.Id;
        Database.update(applicationObj, true);
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/getApplicationStatus';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc@123');

        Map<String,Object> requestMap = getRequestMap();
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalApplicationDetailsAPI.doSentApplicationDetails();
            Test.stopTest();
            Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(response.responseBody.toString());
            Map<String,Object> responseContentMap = (Map<String,Object>)responseMap.get('content');
            Map<String,Object> responseBodyMap = (Map<String,Object>)responseContentMap.get('body');
            System.assertEquals(applicationObj.genesis__Status__c, responseBodyMap.get('application_status'), 'Assertion Failed');
            System.assertEquals('Tier 3', responseBodyMap.get('credit_rating'), 'Assertion Failed');
        }
    }

    /**
    * @description : method to test scenario application status is not null and credit rating is Tier 1
    * @author Suraj Kumar | 07-08-2024 
    **/
    @isTest 
    public static void testAppDetailsTierOne(){
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        genesis__Applications__c applicationObj = [SELECT Id,
                                                            genesis__Status__c,
                                                            genesis__Credit_Rating__c
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Number__c = '300023456'
                                                        LIMIT 1];
        genesis__Credit_Rating_Matrix__c tier = [SELECT Id 
                                                        FROM genesis__Credit_Rating_Matrix__c 
                                                        WHERE Name = 'Tier 1'];
        applicationObj.genesis__Credit_Rating__c = tier.Id;
        Database.update(applicationObj, true);
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/getApplicationStatus';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc@123');

        Map<String,Object> requestMap = getRequestMap();
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalApplicationDetailsAPI.doSentApplicationDetails();
            Test.stopTest();
            Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(response.responseBody.toString());
            Map<String,Object> responseContentMap = (Map<String,Object>)responseMap.get('content');
            Map<String,Object> responseBodyMap = (Map<String,Object>)responseContentMap.get('body');
            System.assertEquals(applicationObj.genesis__Status__c, responseBodyMap.get('application_status'), 'Assertion Failed');
            System.assertEquals('Tier 1', responseBodyMap.get('credit_rating'), 'Assertion Failed');
        }
    }

    /**
    * @description : method to test scenario application status is not null and credit rating is Tier 2
    * @author Suraj Kumar | 07-08-2024 
    **/
    @isTest 
    public static void testAppDetailsTierTwo(){
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        genesis__Applications__c applicationObj = [SELECT Id,
                                                            genesis__Status__c,
                                                            genesis__Credit_Rating__c
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Number__c = '300023456'
                                                        LIMIT 1];
        genesis__Credit_Rating_Matrix__c tier = [SELECT Id 
                                                        FROM genesis__Credit_Rating_Matrix__c 
                                                        WHERE Name = 'Tier 2'];
        applicationObj.genesis__Credit_Rating__c = tier.Id;
        Database.update(applicationObj, true);
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/getApplicationStatus';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc@123');

        Map<String,Object> requestMap = getRequestMap();
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalApplicationDetailsAPI.doSentApplicationDetails();
            Test.stopTest();
            Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(response.responseBody.toString());
            Map<String,Object> responseContentMap = (Map<String,Object>)responseMap.get('content');
            Map<String,Object> responseBodyMap = (Map<String,Object>)responseContentMap.get('body');
            System.assertEquals(applicationObj.genesis__Status__c, responseBodyMap.get('application_status'), 'Assertion Failed');
            System.assertEquals('Tier 2', responseBodyMap.get('credit_rating'), 'Assertion Failed');
        }
    }

    /**
    * @description : method to test scenario application status is not null and credit rating is null
    * @author Suraj Kumar | 07-08-2024 
    **/
    @isTest 
    public static void testAppDetailsUnscored(){
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        genesis__Applications__c applicationObj = [SELECT Id,
                                                            genesis__Status__c,
                                                            genesis__Credit_Rating__c
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Number__c = '300023456'
                                                        LIMIT 1];
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/getApplicationStatus';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc@123');

        Map<String,Object> requestMap = getRequestMap();
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalApplicationDetailsAPI.doSentApplicationDetails();
            Test.stopTest();
            Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(response.responseBody.toString());
            Map<String,Object> responseContentMap = (Map<String,Object>)responseMap.get('content');
            Map<String,Object> responseBodyMap = (Map<String,Object>)responseContentMap.get('body');
            System.assertEquals(applicationObj.genesis__Status__c, responseBodyMap.get('application_status'), 'Assertion Failed');
            System.assertEquals('NA', responseBodyMap.get('credit_rating'), 'Assertion Failed');
        }
    }

    /**
    * @description : method to test scenario application status is null and credit rating is not null
    * @author Suraj Kumar | 07-08-2024 
    **/
    @isTest 
    public static void testAppStatusNull(){
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        genesis__Applications__c applicationObj = [SELECT Id,
                                                            genesis__Status__c,
                                                            genesis__Credit_Rating__c
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Number__c = '300023456'
                                                        LIMIT 1];
        genesis__Credit_Rating_Matrix__c tier = [SELECT Id 
                                                        FROM genesis__Credit_Rating_Matrix__c 
                                                        WHERE Name = 'Tier 2'];
        applicationObj.genesis__Credit_Rating__c = tier.Id;
        applicationObj.genesis__Status__c = null;
        Database.update(applicationObj, true);
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/getApplicationStatus';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc@123');

        Map<String,Object> requestMap = getRequestMap();
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalApplicationDetailsAPI.doSentApplicationDetails();
            Test.stopTest();
            Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(response.responseBody.toString());
            Map<String,Object> responseContentMap = (Map<String,Object>)responseMap.get('content');
            Map<String,Object> responseBodyMap = (Map<String,Object>)responseContentMap.get('body');
            System.assertEquals('NA', responseBodyMap.get('application_status'), 'Assertion Failed');
            System.assertEquals('Tier 2', responseBodyMap.get('credit_rating'), 'Assertion Failed');
        }
    }

    /**
    * @description : method to test scenario application status is null and credit rating is null
    * @author Suraj Kumar | 07-08-2024 
    **/
    @isTest 
    public static void testAppStatusNullUnscored(){
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        genesis__Applications__c applicationObj = [SELECT Id,
                                                            genesis__Status__c,
                                                            genesis__Credit_Rating__c
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Number__c = '300023456'
                                                        LIMIT 1];
        applicationObj.genesis__Status__c = null;
        Database.update(applicationObj, true);
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/getApplicationStatus';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc@123');

        Map<String,Object> requestMap = getRequestMap();
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalApplicationDetailsAPI.doSentApplicationDetails();
            Test.stopTest();
            Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(response.responseBody.toString());
            Map<String,Object> responseContentMap = (Map<String,Object>)responseMap.get('content');
            Map<String,Object> responseBodyMap = (Map<String,Object>)responseContentMap.get('body');
            System.assertEquals('NA', responseBodyMap.get('application_status'), 'Assertion Failed');
            System.assertEquals('NA', responseBodyMap.get('credit_rating'), 'Assertion Failed');
        }
    }

    /**
    * @description : method to test scenario Request parameter Invalid, not in correct JSON format
    * @author Suraj Kumar | 07-08-2024 
    **/
    @isTest 
    public static void testInvalidRequestBody(){
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/getApplicationStatus';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc@123');


        request.requestBody = Blob.valueOf(JSON.serialize('invalid'));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalApplicationDetailsAPI.doSentApplicationDetails();
            Test.stopTest();
            System.assertEquals(RestContext.response.statusCode, ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, 'Assertion Failed');
        }
    }

    /**
    * @description : method to test scenario Dealer Cif key missing
    * @author Kabir Pramanik | 09-12-2024 
    **/
    @isTest
    public static void testDealerCifMissing(){
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/getApplicationStatus';
        request.httpMethod = 'POST';

        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc@123');
        Map<String,Object> requestMap = getRequestMap();
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalApplicationDetailsAPI.doSentApplicationDetails();
            Test.stopTest();
            Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(response.responseBody.toString());
            Map<String,Object> responseContentMap = (Map<String,Object>)responseMap.get('content');
            String message = (String)responseContentMap.get('message');
            System.assertEquals(message, ExternalConstants.DEALER_CIF_MISSING, 'Assertion Failed');
        }
    }

    /**
    * @description : method to test scenario Dealer Token key missing
    * @author Kabir Pramanik | 09-12-2024 
    **/
    @isTest
    public static void testDealerTokenMissing(){
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/getApplicationStatus';
        request.httpMethod = 'POST';

        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        Map<String,Object> requestMap = getRequestMap();
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalApplicationDetailsAPI.doSentApplicationDetails();
            Test.stopTest();
            Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(response.responseBody.toString());
            Map<String,Object> responseContentMap = (Map<String,Object>)responseMap.get('content');
            String message = (String)responseContentMap.get('message');
            System.assertEquals(message, ExternalConstants.DEALER_TOKEN_MISSING, 'Assertion Failed');
        }
    }

    /**
    * @description : method to test scenario Dealer Cif value is missing
    * @author Kabir Pramanik | 09-12-2024 
    **/
    @isTest 
    public static void testDealeCifValueMissing(){
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/getApplicationStatus';
        request.httpMethod = 'POST';

        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc@123');
        Map<String,Object> requestMap = getRequestMap();
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalApplicationDetailsAPI.doSentApplicationDetails();
            Test.stopTest();
            Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(response.responseBody.toString());
            Map<String,Object> responseContentMap = (Map<String,Object>)responseMap.get('content');
            String message = (String)responseContentMap.get('message');
            System.assertEquals(message, ExternalConstants.DEALER_CIF_MISSING, 'Assertion Failed');
        }
    }

    /**
    * @description : method to test scenario Dealer Token value is missing
    * @author Kabir Pramanik | 09-12-2024 
    **/
    @isTest 
    public static void testDealerTokenValueMissing(){
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/getApplicationStatus';
        request.httpMethod = 'POST';

        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, '');
        Map<String,Object> requestMap = getRequestMap();
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalApplicationDetailsAPI.doSentApplicationDetails();
            Test.stopTest();
            Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(response.responseBody.toString());
            Map<String,Object> responseContentMap = (Map<String,Object>)responseMap.get('content');
            String message = (String)responseContentMap.get('message');
            System.assertEquals(message, ExternalConstants.DEALER_TOKEN_MISSING, 'Assertion Failed');
        }
    }
    /**
    * @description : method to test scenario Dealer Cif value is invalid
    * @author Kabir Pramanik | 09-12-2024 
    **/
    @isTest 
    public static void testInvalidDealerCif(){
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/getApplicationStatus';
        request.httpMethod = 'POST';

        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '100555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abc@123');
        Map<String,Object> requestMap = getRequestMap();
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalApplicationDetailsAPI.doSentApplicationDetails();
            Test.stopTest();
            Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(response.responseBody.toString());
            Map<String,Object> responseContentMap = (Map<String,Object>)responseMap.get('content');
            String message = (String)responseContentMap.get('message');
            System.assertEquals(message, ExternalConstants.DEALER_CIF_INVALID, 'Assertion Failed');
        }
    }
    /**
    * @description : method to test scenario Dealer Token value is invalid
    * @author Kabir Pramanik | 09-12-2024 
    **/
    @isTest 
    public static void testInvalidDealeToken(){
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/getApplicationStatus';
        request.httpMethod = 'POST';

        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'abcd@123');
        Map<String,Object> requestMap = getRequestMap();
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            ExternalApplicationDetailsAPI.doSentApplicationDetails();
            Test.stopTest();
            Map<String,Object> responseMap = (Map<String,Object>)JSON.deserializeUntyped(response.responseBody.toString());
            Map<String,Object> responseContentMap = (Map<String,Object>)responseMap.get('content');
            String message = (String)responseContentMap.get('message');
            System.assertEquals(message, ExternalConstants.DEALER_TOKEN_INVALID, 'Assertion Failed');
        }
    }
}