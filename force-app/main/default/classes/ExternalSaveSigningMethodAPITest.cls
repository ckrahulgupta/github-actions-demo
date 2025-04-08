/**
 * @description       : Test class for ExternalSaveSigningMethodAPI
 * @author            : Suraj Kumar
 * @group             : 
 * @last modified on  : 03-02-2025
 * @last modified by  : Krishanu Chinya
**/
@isTest
public with sharing class ExternalSaveSigningMethodAPITest {
    /**
    * @description : Setup method to create test data
    * @author Suraj Kumar | 12-23-2024 
    **/
    @TestSetup
    static void setup() {
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
        dealerAccountObj.Unique_Id__c = 'testd001';
        Database.insert(dealerAccountObj, true);

        // Creating Account for Certified Lender
        Account clAccountObj = ExternalAPITestHelper.createCLAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);

        Account borrowerAccountObj = ExternalAPITestHelper.createSolePropAccount(entityObj, borrowerBusinessInfoObj.Id);
        borrowerAccountObj.Unique_Id__c = 'TestBorrUniqueId004';

        Account coBorrowerAccObj = ExternalAPITestHelper.createSolePropAccount(entityObj, borrowerBusinessInfoObj.Id);
        coBorrowerAccObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CoApplicant').getRecordTypeId();
        coBorrowerAccObj.Unique_Id__c = 'TestCoBorrUniqueId004';

        Database.insert(new List<Account>{clAccountObj,borrowerAccountObj, coBorrowerAccObj}, true);

        // Creating Contact for Certified Lender
        Contact clContactObj = ExternalAPITestHelper.createCLContact(clAccountObj.Id);

        Contact borrowerContactObj = ExternalAPITestHelper.createBorrowerContact(borrowerAccountObj.Id);

        Contact coBorrowerContactObj = ExternalAPITestHelper.createBorrowerContact(coBorrowerAccObj.Id);
        Database.insert(new List<Contact>{clContactObj, borrowerContactObj, coBorrowerContactObj},true);

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
        applicationObj.genesis__Status__c = 'SIGNATURE PENDING';
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
        borrowerPartyObj.marital_status__c = 'Married';

        // Creating Principal Party for current application
        Map<String,Id> paramForPrincipalPartyMap = new Map<String,Id>{
            'accountId' => coBorrowerAccObj.Id,
            'contactId' => coBorrowerContactObj.Id,
            'partyTypeId' => principalPartyTypeObj.Id,
            'applicationId' => applicationObj.Id,
            'dealerApplicantRelId' => coBorrowerDealerRelObj.Id
        };

        clcommon__Party__c principalPartyObj = ExternalAPITestHelper.createApplicantParty(paramForPrincipalPartyMap);
        principalPartyObj.Marital_Status__c = 'Unmarried';
        principalPartyObj.Principal_Number__c = 1;

        Database.insert(new List<clcommon__Party__c>{borrowerPartyObj,principalPartyObj},true);

        Task taskObj = ExternalAPITestHelper.createTask(applicationObj.id, 'Signed Credit Agreement');
        Database.insert(taskObj,true);

        clcommon__document_category__c docCategoryObj = ExternalAPITestHelper.createDocCategory(applicationObj.id,'Signed Credit Agreement');
        Database.insert(docCategoryObj,true);

        ContentVersion contentVersionObj = ExternalAPITestHelper.createContentVersion('Credit Application Agreement.pdf');
        Database.insert(contentVersionObj,true); 

        List<ContentDocument> contentDocumentList = [SELECT Id FROM ContentDocument WHERE Title = 'Credit Application Agreement.pdf' LIMIT 1];

        ContentDocumentLink contentDocumentLinkObj = ExternalAPITestHelper.createContentDocumentLink(contentDocumentList[0].id,applicationObj.id);
        Database.insert(contentDocumentLinkObj,true);
    }

    /**
    * @description : Method to get application
    * @author Suraj Kumar | 01-11-2025 
    * @return genesis__Applications__c 
    **/
    private static genesis__Applications__c getApplication(){
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                            genesis__Account__c,
                                                            genesis__Status__c,
                                                            genesis__Account__r.Unique_Id__c,
                                                            genesis__Loan_Amount__c
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Number__c = '300023456'
                                                        LIMIT 1];
        return applicationList[0];
    }

    /**
    * @description : method to get request map
    * @author Suraj Kumar | 06-06-2024 
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
        Map<String,Object> signingDetailsMap = new Map<String,Object>{
            'signing_type' => 'DocuSign Hybrid'
        };

        Map<String,Object> requestMap = new Map<String,Object>{
            'application_details' => applicationDetailsMap,
            'borrower_details' => borrowerDetailsMap,
            'signing_method_details' => signingDetailsMap
        };
        return requestMap;
    }

    /**
    * @description : method to get principal contact
    * @author Suraj Kumar | 06-06-2024 
    * @return Contact 
    **/
    private static Contact getPrincipalContact(){
        List<clcommon__Party__c> principalPartyList = getPrincipalParty();

        List<Contact> contactList = [SELECT Id,
                                        FirstName,
                                        genesis__SSN__c,
                                        Confirm_SSN__c,
                                        Birthdate,
                                        Email
                                    FROM Contact 
                                    WHERE Id = :principalPartyList[0].clcommon__Contact__c];
        return contactList[0];
       
    }

    /**
    * @description : Method to get principal Party
    * @author Suraj Kumar | 01-11-2025 
    * @return List<clcommon__Party__c> 
    **/
    private static List<clcommon__Party__c> getPrincipalParty(){
        genesis__Applications__c applicationObj = getApplication();
        List<clcommon__Party__c> principalPartyList = [SELECT Id, 
                                                                genesis__Application__c,
                                                                Street__c,
                                                                City__c,
                                                                State__c,
                                                                County__c,
                                                                Postal_Code__c,
                                                                Mobile_Number__c,
                                                                Work_Number__c,
                                                                Home_Number__c,
                                                                clcommon__Contact__c
                                                            FROM clcommon__Party__c
                                                            WHERE genesis__Application__r.Id=:applicationObj.Id 
                                                            AND  clcommon__Type__r.Name =: ExternalConstants.PRINCIPAL_PARTY];
        return principalPartyList;
    }

    /**
    * @description : Method to get Borrower Party
    * @author Suraj Kumar | 01-11-2025 
    * @return clcommon__Party__c 
    **/
    private static clcommon__Party__c getBorrowerParty(){
        genesis__Applications__c applicationObj = getApplication();
        List<clcommon__Party__c> borrowerPartyList = [SELECT Id, 
                                                        Total_Assets__c,
                                                        Total_Liabilities__c,
                                                        DocuSign_URL__c
                                                    FROM clcommon__Party__c
                                                    WHERE genesis__Application__r.Id=:applicationObj.Id 
                                                    AND  clcommon__Type__r.Name =: ExternalConstants.BORROWER_PARTY];
        return borrowerPartyList[0];
    }

    /**
    * @description : Method to test Docusign Hybrid for sole prop with principal
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testDocuSigningHybridSoleProp(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/saveSigningMethod';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
       
        Map<String,Object> requestMap = getRequestMap();
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalSaveSigningMethodAPI.doSaveSigningMethod();
            System.assertEquals(ExternalConstants.TWO_HUNDRED_ONE_STATUS_CODE, RestContext.response.statusCode, 'Failure');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test Docusign Hybrid for Business
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testDocuSigningHybridBusiness(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        List<clcommon__Legal_Entity__c> entityList = [SELECT Id, 
                                                        clcommon__Legal_Entity_Type__c,
                                                        Name 
                                                    FROM clcommon__Legal_Entity__c LIMIT 1];
        entityList[0].clcommon__Legal_Entity_Type__c = 'Corporation';
        entityList[0].Name = 'Corporation';
        Database.update(entityList[0],true);
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/saveSigningMethod';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
       
        Map<String,Object> requestMap = getRequestMap();
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalSaveSigningMethodAPI.doSaveSigningMethod();
            System.assertEquals(ExternalConstants.TWO_HUNDRED_ONE_STATUS_CODE, RestContext.response.statusCode, 'Failure');
            Test.stopTest();
        }
    }


    /**
    * @description : Method to test Docusign Hybrid for sole prop without principal
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testDSHybridSolePropWithoutPrincipal(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        List<clcommon__Party__c> principalPartyList = getPrincipalParty();
        for(clcommon__Party__c partyObj: principalPartyList){
            partyObj.genesis__Application__c = null;
        }
        Database.update(principalPartyList,true);
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/saveSigningMethod';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
       
        Map<String,Object> requestMap = getRequestMap();
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalSaveSigningMethodAPI.doSaveSigningMethod();
            System.assertEquals(ExternalConstants.TWO_HUNDRED_ONE_STATUS_CODE, RestContext.response.statusCode, 'Failure');
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test Email Docusign for sole prop with principal
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testEmailSigningMethodSoleProp(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/saveSigningMethod';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
       
        Map<String,Object> signingDetailsMap = new Map<String,Object>{
            'signing_type' => ExternalConstants.EMAIL_DOCUSIGN
        };

        Map<String,Object> requestMap = getRequestMap();
        requestMap.put('signing_method_details',signingDetailsMap);

        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalSaveSigningMethodAPI.doSaveSigningMethod();
            System.assertEquals(ExternalConstants.TWO_HUNDRED_ONE_STATUS_CODE, RestContext.response.statusCode, 'Failure');
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test Email Docusign for Business
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testEmailSigningMethodBusiness(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        List<clcommon__Legal_Entity__c> entityList = [SELECT Id, 
                                                        clcommon__Legal_Entity_Type__c,
                                                        Name 
                                                    FROM clcommon__Legal_Entity__c LIMIT 1];
        entityList[0].clcommon__Legal_Entity_Type__c = 'Corporation';
        entityList[0].Name = 'Corporation';
        Database.update(entityList[0],true);
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/saveSigningMethod';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
       
        Map<String,Object> signingDetailsMap = new Map<String,Object>{
            'signing_type' => ExternalConstants.EMAIL_DOCUSIGN
        };

        Map<String,Object> requestMap = getRequestMap();
        requestMap.put('signing_method_details',signingDetailsMap);

        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalSaveSigningMethodAPI.doSaveSigningMethod();
            System.assertEquals(ExternalConstants.TWO_HUNDRED_ONE_STATUS_CODE, RestContext.response.statusCode, 'Failure');
            Test.stopTest();
        }
    }

     /**
    * @description : Method to test Email Docusign for sole prop without principal
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
private static void testDSEmailSolePropWithoutPrincipal(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        List<clcommon__Party__c> principalPartyList = getPrincipalParty();
        for(clcommon__Party__c partyObj: principalPartyList){
            partyObj.genesis__Application__c = null;
        }
        Database.update(principalPartyList,true);
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/saveSigningMethod';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
       
        Map<String,Object> signingDetailsMap = new Map<String,Object>{
            'signing_type' => ExternalConstants.EMAIL_DOCUSIGN
        };

        Map<String,Object> requestMap = getRequestMap();
        requestMap.put('signing_method_details',signingDetailsMap);

        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalSaveSigningMethodAPI.doSaveSigningMethod();
            System.assertEquals(ExternalConstants.TWO_HUNDRED_ONE_STATUS_CODE, RestContext.response.statusCode, 'Failure');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test Unauthorize user
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testUnauthorizeUser(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/saveSigningMethod';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
       
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
            ExternalSaveSigningMethodAPI.doSaveSigningMethod();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_ONE_STATUS_CODE, RestContext.response.statusCode, 'Assertion failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test request body empty
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testEmptyRequestBody(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/saveSigningMethod';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        
        request.requestBody = Blob.valueOf(JSON.serialize(new Map<String,Object>()));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalSaveSigningMethodAPI.doSaveSigningMethod();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode,  'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test applicant detail missing
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testApplicantDetailMissing(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/saveSigningMethod';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        Map<String,Object> requestMap = getRequestMap();
        requestMap.remove('application_details');
    
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalSaveSigningMethodAPI.doSaveSigningMethod();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Assertion failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test borrower detail missing
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testBorrowerDetailMissing(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/saveSigningMethod';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        Map<String,Object> requestMap = getRequestMap();
        requestMap.remove('borrower_details');
        
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalSaveSigningMethodAPI.doSaveSigningMethod();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Assertion failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test singning detail missing
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testSigningDetailMissing(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/saveSigningMethod';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        Map<String,Object> requestMap = getRequestMap();
        requestMap.remove('signing_method_details');
        
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalSaveSigningMethodAPI.doSaveSigningMethod();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Assertion failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test application id null
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testAppIdNull(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/saveSigningMethod';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');

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
            ExternalSaveSigningMethodAPI.doSaveSigningMethod();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Assertion failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test application id invalid
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testAppIdInvalid(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/saveSigningMethod';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');

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
            ExternalSaveSigningMethodAPI.doSaveSigningMethod();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Assertion failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test user id null
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testUserIdNull(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/saveSigningMethod';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
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
            ExternalSaveSigningMethodAPI.doSaveSigningMethod();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Assertion failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test signing method null
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testSigningMethodNull(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/saveSigningMethod';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        Map<String,Object> signingDetailsMap = new Map<String,Object>{
            'signing_type' => null
        };
        Map<String,Object> requestMap = getRequestMap();
        requestMap.put('signing_method_details', signingDetailsMap);
        
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalSaveSigningMethodAPI.doSaveSigningMethod();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Assertion failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test signing method invalid
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testSigningMethodInvalid(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/saveSigningMethod';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        Map<String,Object> signingDetailsMap = new Map<String,Object>{
            'signing_type' => 'Not Docusign'
        };
        Map<String,Object> requestMap = getRequestMap();
        requestMap.put('signing_method_details', signingDetailsMap);
        
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalSaveSigningMethodAPI.doSaveSigningMethod();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Assertion failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test without applicant email
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testApplicantEmailMissing(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        List<Contact> contactList = [SELECT Id, 
                                        Email 
                                    FROM Contact 
                                    WHERE AccountId = :applicationObj.genesis__Account__c];
        contactList[0].Email = null;
        Database.update(contactList[0],true);
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/saveSigningMethod';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
       
        Map<String,Object> requestMap = getRequestMap();
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalSaveSigningMethodAPI.doSaveSigningMethod();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test total asset null
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testTotalAssetNull(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        clcommon__Party__c borrowerPartyObj = getBorrowerParty();
        borrowerPartyObj.Total_Assets__c = null;
        Database.update(borrowerPartyObj,true);
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/saveSigningMethod';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
       
        Map<String,Object> requestMap = getRequestMap();
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalSaveSigningMethodAPI.doSaveSigningMethod();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test total asset less than zero
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testTotalAssetLessZero(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        clcommon__Party__c borrowerPartyObj = getBorrowerParty();
        borrowerPartyObj.Total_Assets__c = -10;
        Database.update(borrowerPartyObj,true);
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/saveSigningMethod';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
       
        Map<String,Object> requestMap = getRequestMap();
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalSaveSigningMethodAPI.doSaveSigningMethod();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test total libalities null
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testTotalLibalitiesNull(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        clcommon__Party__c borrowerPartyObj = getBorrowerParty();
        borrowerPartyObj.Total_Liabilities__c = null;
        Database.update(borrowerPartyObj,true);
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/saveSigningMethod';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
       
        Map<String,Object> requestMap = getRequestMap();
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalSaveSigningMethodAPI.doSaveSigningMethod();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test total libalities less than zero
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testTotalLibalitiesLessZero(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        clcommon__Party__c borrowerPartyObj = getBorrowerParty();
        borrowerPartyObj.Total_Liabilities__c = -10;
        Database.update(borrowerPartyObj,true);
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/saveSigningMethod';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
       
        Map<String,Object> requestMap = getRequestMap();
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalSaveSigningMethodAPI.doSaveSigningMethod();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test without principal first name
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testWithoutPrincipalFirstName(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Contact contactObj = getPrincipalContact();
        contactObj.FirstName = null;
        Database.update(contactObj,true);
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/saveSigningMethod';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
       
        Map<String,Object> requestMap = getRequestMap();
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalSaveSigningMethodAPI.doSaveSigningMethod();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test without principal street
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testWithoutPrincipalStreet(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        List<clcommon__Party__c> principalPartyList = getPrincipalParty();
        principalPartyList[0].Street__c = null;
        Database.update(principalPartyList[0],true);
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/saveSigningMethod';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
       
        Map<String,Object> requestMap = getRequestMap();
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalSaveSigningMethodAPI.doSaveSigningMethod();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test without principal city
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testWithoutPrincipalCity(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        List<clcommon__Party__c> principalPartyList = getPrincipalParty();
        principalPartyList[0].City__c = null;
        Database.update(principalPartyList[0],true);
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/saveSigningMethod';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
       
        Map<String,Object> requestMap = getRequestMap();
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalSaveSigningMethodAPI.doSaveSigningMethod();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode,'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test without principal state
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testWithoutPrincipalState(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        List<clcommon__Party__c> principalPartyList = getPrincipalParty();
        principalPartyList[0].State__c = null;
        Database.update(principalPartyList[0],true);
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/saveSigningMethod';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
       
        Map<String,Object> requestMap = getRequestMap();
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalSaveSigningMethodAPI.doSaveSigningMethod();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode,  'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test without principal county
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testWithoutPrincipalCounty(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        List<clcommon__Party__c> principalPartyList = getPrincipalParty();
        principalPartyList[0].County__c = null;
        Database.update(principalPartyList[0],true);
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/saveSigningMethod';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
       
        Map<String,Object> requestMap = getRequestMap();
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalSaveSigningMethodAPI.doSaveSigningMethod();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test without principal postal code
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testWithoutPrincipalPostalCode(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        List<clcommon__Party__c> principalPartyList = getPrincipalParty();
        principalPartyList[0].Postal_Code__c = null;
        Database.update(principalPartyList[0],true);
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/saveSigningMethod';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
       
        Map<String,Object> requestMap = getRequestMap();
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalSaveSigningMethodAPI.doSaveSigningMethod();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode,'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test invalid postal code
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testPrincipalPostalCodeInvalid(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        List<clcommon__Party__c> principalPartyList = getPrincipalParty();
        principalPartyList[0].Postal_Code__c = '123456';
        Database.update(principalPartyList[0],true);
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/saveSigningMethod';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
       
        Map<String,Object> requestMap = getRequestMap();
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalSaveSigningMethodAPI.doSaveSigningMethod();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test without principal SSN
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testWithoutPrincipalSSN(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Contact contactObj = getPrincipalContact();
        contactObj.genesis__SSN__c = null;
        Database.update(contactObj,true);
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/saveSigningMethod';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
       
        Map<String,Object> requestMap = getRequestMap();
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalSaveSigningMethodAPI.doSaveSigningMethod();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test invalid SSN
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testPrincipalSSNInvalid(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Contact contactObj = getPrincipalContact();
        contactObj.genesis__SSN__c = '12345678';
        Database.update(contactObj,true);
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/saveSigningMethod';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
       
        Map<String,Object> requestMap = getRequestMap();
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalSaveSigningMethodAPI.doSaveSigningMethod();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test without principal DOB
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testWithoutPrincipalDob(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Contact contactObj = getPrincipalContact();
        contactObj.Birthdate = null;
        Database.update(contactObj,true);
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/saveSigningMethod';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
       
        Map<String,Object> requestMap = getRequestMap();
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalSaveSigningMethodAPI.doSaveSigningMethod();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test without principal contact number
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testWithoutPrincipalContactNumber(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        List<clcommon__Party__c> principalPartyList = getPrincipalParty();
        principalPartyList[0].Mobile_Number__c = null;
        principalPartyList[0].Work_Number__c = null;
        principalPartyList[0].Home_Number__c = null;
        Database.update(principalPartyList[0],true);
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/saveSigningMethod';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
       
        Map<String,Object> requestMap = getRequestMap();
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalSaveSigningMethodAPI.doSaveSigningMethod();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test loan amount null
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testLoanAmountNull(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        applicationObj.genesis__Loan_Amount__c = null;
        Database.update(applicationObj,true);
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/saveSigningMethod';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        Map<String,Object> requestMap = getRequestMap();
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalSaveSigningMethodAPI.doSaveSigningMethod();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test with old document
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testWithOldDocument(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/saveSigningMethod';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');

        clcommon__Party__c borrowerPartyObj = getBorrowerParty();
        borrowerPartyObj.DocuSign_URL__c = 'https//:www.google.com';
        Database.update(borrowerPartyObj,true);
       
        Map<String,Object> requestMap = getRequestMap();
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalSaveSigningMethodAPI.doSaveSigningMethod();
            System.assertEquals(ExternalConstants.TWO_HUNDRED_ONE_STATUS_CODE, RestContext.response.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }


    @isTest
    private static void testResendDocusign(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/saveSigningMethod';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
       
        Map<String,Object> signingDetailsMap = new Map<String,Object>{
            'signing_type' => ExternalConstants.EMAIL_DOCUSIGN,
            'resend_docusign' => true
        };

        Map<String,Object> requestMap = getRequestMap();
        requestMap.put('signing_method_details',signingDetailsMap);

        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalSaveSigningMethodAPI.doSaveSigningMethod();
            System.assertEquals(ExternalConstants.TWO_HUNDRED_ONE_STATUS_CODE, RestContext.response.statusCode, 'Failure');
            Test.stopTest();
        }
    }
}