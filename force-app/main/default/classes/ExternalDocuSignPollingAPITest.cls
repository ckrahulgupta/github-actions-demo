/**
 * @description       : Test class for ExternalDocuSignPollingAPI
 * @author            : Suraj Kumar | 06-20-2024
 * @group             : 
 * @last modified on  : 01-11-2025
 * @last modified by  : Suraj Kumar
**/
@isTest
public with sharing class ExternalDocuSignPollingAPITest {
    /**
    * @description : setup method to create test data
    * @author Suraj Kumar | 12-27-2024 
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
        borrowerAccountObj.Unique_Id__c = 'TestBorrUniqueId003';

        Account coBorrowerAccObj = ExternalAPITestHelper.createSolePropAccount(entityObj, borrowerBusinessInfoObj.Id);
        coBorrowerAccObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CoApplicant').getRecordTypeId();
        coBorrowerAccObj.Unique_Id__c = 'TestCoBorrUniqueId003';

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

        Task taskObj = ExternalAPITestHelper.createTask(applicationObj.id, 'Signed Credit Agreement');
        Database.insert(taskObj,true);

        clcommon__document_category__c docCategoryObj = ExternalAPITestHelper.createDocCategory(applicationObj.id,'Signed Credit Agreement');
        Database.insert(docCategoryObj,true);

        ContentVersion contentVersionObj = ExternalAPITestHelper.createContentVersion('Credit Application Agreement.pdf');
        Database.insert(contentVersionObj,true); 

        List<ContentDocument> contentDocumentList = [SELECT Id FROM ContentDocument WHERE Title = 'Credit Application Agreement.pdf' LIMIT 1];

        ContentDocumentLink contentDocumentLinkObj = ExternalAPITestHelper.createContentDocumentLink(contentDocumentList[0].id,applicationObj.id);
        Database.insert(contentDocumentLinkObj,true);

        dfsle__Envelope__c dsEnvelopeObj = ExternalAPITestHelper.createEnvelope(applicationObj.Id);
        Database.insert(dsEnvelopeObj);

        dfsle__EnvelopeStatus__c dsEnvelopeStatusObj = ExternalAPITestHelper.createEnvelopeStatus(applicationObj.Id);
        Database.insert(dsEnvelopeStatusObj);


        dfsle__Recipient__c dsRecipientObj = new dfsle__Recipient__c(dfsle__Role__c = 'Signer 1',
                                                                        dfsle__Envelope__c = dsEnvelopeObj.Id, 
                                                                        dfsle__Email__c = 'abc@yopmail.com', 
                                                                        dfsle__SourceId__c = borrowerContactObj.Id);
        Database.insert(dsRecipientObj,true);

        dfsle__RecipientStatus__c dsRecipientStatusObj = new dfsle__RecipientStatus__c(dfsle__EnvelopeStatus__c = dsEnvelopeStatusObj.Id,
                                                                                            dfsle__Status__c = 'Sent',
                                                                                            dfsle__SourceId__c = borrowerContactObj.Id);
        Database.insert(dsRecipientStatusObj);

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
                                                            Dealer_Name__c,
                                                            Agreement_Sign__c
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Number__c = '300023456'
                                                        LIMIT 1];
        return applicationList[0];
    }

    /**
    * @description : method to get request map
    * @author Suraj Kumar | 06-20-2024
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
    * @description : Method to test get docusign url for sole prop
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testSentDocusignUrlSoleProp(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/docuSignPolling';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        genesis__Applications__c applicationObj = getApplication();
        List<clcommon__party__c> applicantPartyList =  [SELECT Id,
                                                                DocuSign_URL__c,
                                                                DocuSign_Generation_Time__c
                                                            FROM clcommon__Party__c
                                                            WHERE genesis__Application__r.Id=:applicationObj.Id 
                                                            AND clcommon__Type__r.Name =: ExternalConstants.BORROWER_PARTY];
        applicantPartyList[0].DocuSign_URL__c='https://embeddedURLSigning.docusign';
        applicantPartyList[0].DocuSign_Generation_Time__c = System.now();
        Database.update(applicantPartyList);

        Map<String,Object> requestMap = getRequestMap();
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalDocuSignPollingAPI.doSentDocuSignUrl();
            System.assertEquals(ExternalConstants.TWO_HUNDRED_STATUS_CODE, RestContext.response.statusCode, 'Assertion failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test get docusign url for corporation
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testSentDocusignUrlBusiness(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        List<clcommon__Legal_Entity__c> entityList = [SELECT Id, 
                                                        clcommon__Legal_Entity_Type__c,
                                                        Name 
                                                    FROM clcommon__Legal_Entity__c];
        entityList[0].clcommon__Legal_Entity_Type__c = 'Corporation';
        entityList[0].Name = 'Corporation';
        Database.update(entityList[0],true);
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/docuSignPolling';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        genesis__Applications__c applicationObj = getApplication();
        List<clcommon__party__c> applicantPartyList =  [SELECT Id,
                                                                DocuSign_URL__c,
                                                                DocuSign_Generation_Time__c
                                                            FROM clcommon__Party__c
                                                            WHERE genesis__Application__r.Id=:applicationObj.Id 
                                                            AND clcommon__Type__r.Name =: ExternalConstants.PRINCIPAL_PARTY
                                                            AND Principal_Number__c = 1];
        applicantPartyList[0].DocuSign_URL__c='https://embeddedURLSigning.docusign';
        applicantPartyList[0].DocuSign_Generation_Time__c = System.now();
        Database.update(applicantPartyList);

        Map<String,Object> requestMap = getRequestMap();
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalDocuSignPollingAPI.doSentDocuSignUrl();
            System.assertEquals(ExternalConstants.TWO_HUNDRED_STATUS_CODE, RestContext.response.statusCode, 'Assertion Failed');
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
        request.requestUri = '/api/v1/external/docuSignPolling';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        
        request.requestBody = Blob.valueOf(JSON.serialize(new Map<String,Object>()));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalDocuSignPollingAPI.doSentDocuSignUrl();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test application detail missing
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testApplicationDetailMissing(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/docuSignPolling';
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
            ExternalDocuSignPollingAPI.doSentDocuSignUrl();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test application id missing
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testApplicationIdMissing(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/docuSignPolling';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
    
        Map<String,Object> requestMap = getRequestMap();
        requestMap.put('application_details',new Map<String,Object>());

        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalDocuSignPollingAPI.doSentDocuSignUrl();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Assertion Failed');
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
        request.requestUri = '/api/v1/external/docuSignPolling';
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
            ExternalDocuSignPollingAPI.doSentDocuSignUrl();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test user id missing
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testUserIdMissing(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/docuSignPolling';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
    
        Map<String,Object> requestMap = getRequestMap();
        requestMap.put('borrower_details',new Map<String,Object>());

        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalDocuSignPollingAPI.doSentDocuSignUrl();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test application id invalid
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testApplicationIdInvalid(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/docuSignPolling';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
    
        Map<String,Object> requestMap = getRequestMap();
        requestMap.put('application_details',new Map<String,Object>{
            'id' => 'test12345'
        });

        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalDocuSignPollingAPI.doSentDocuSignUrl();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test user id invalid
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testUserIdInvalid(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/docuSignPolling';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
    
        Map<String,Object> requestMap = getRequestMap();
        requestMap.put('borrower_details',new Map<String,Object>{
            'user_id' => 'abcde12'
        });

        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalDocuSignPollingAPI.doSentDocuSignUrl();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_ONE_STATUS_CODE, RestContext.response.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test application belongs to another dealer
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testAnotherDealerApplication(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/docuSignPolling';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');

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
            ExternalDocuSignPollingAPI.doSentDocuSignUrl();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_ONE_STATUS_CODE, RestContext.response.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test invalid application status
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testInvalidAppStatus(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/docuSignPolling';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');

        Map<String,Object> requestMap = getRequestMap();
        genesis__Applications__c applicationObj = getApplication();
        applicationObj.genesis__Status__c = 'SIGNATURE COMPLETED';
        Database.update(applicationObj,true);
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalDocuSignPollingAPI.doSentDocuSignUrl();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test url not stored
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testUrlNotStored(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/docuSignPolling';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');

        Map<String,Object> requestMap = getRequestMap();
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalDocuSignPollingAPI.doSentDocuSignUrl();
            System.assertEquals(ExternalConstants.TWO_HUNDRED_TWO_STATUS_CODE, RestContext.response.statusCode, 'Failure');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test for expired url
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testExpiredUrl(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/docuSignPolling';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        genesis__Applications__c applicationObj = getApplication();
        List<clcommon__party__c> applicantPartyList =  [SELECT Id,
                                                                DocuSign_URL__c,
                                                                DocuSign_Generation_Time__c
                                                            FROM clcommon__Party__c
                                                            WHERE genesis__Application__r.Id=:applicationObj.Id 
                                                            AND clcommon__Type__r.Name =: ExternalConstants.BORROWER_PARTY];
        applicantPartyList[0].DocuSign_URL__c='https://embeddedURLSigning.docusign';
        applicantPartyList[0].DocuSign_Generation_Time__c = System.now().addHours(-2);
        Database.update(applicantPartyList);

        Map<String,Object> requestMap = getRequestMap();
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalDocuSignPollingAPI.doSentDocuSignUrl();
            System.assertEquals(ExternalConstants.TWO_HUNDRED_TWO_STATUS_CODE, RestContext.response.statusCode, 'Failure');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test for signing completed
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testSigningCompleted(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/docuSignPolling';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        genesis__Applications__c applicationObj = getApplication();
        applicationObj.Agreement_Sign__c = true;
        Database.update(applicationObj,true);

        Map<String,Object> requestMap = getRequestMap();
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalDocuSignPollingAPI.doSentDocuSignUrl();
            System.assertEquals(ExternalConstants.TWO_HUNDRED_STATUS_CODE, RestContext.response.statusCode, 'Failure');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test for url sent already
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testUrlSentAlready(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/docuSignPolling';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        genesis__Applications__c applicationObj = getApplication();
        List<clcommon__party__c> applicantPartyList =  [SELECT Id,
                                                                DocuSign_URL__c,
                                                                Sent_Url__c,
                                                                DocuSign_Generation_Time__c
                                                            FROM clcommon__Party__c
                                                            WHERE genesis__Application__r.Id=:applicationObj.Id 
                                                            AND clcommon__Type__r.Name =: ExternalConstants.BORROWER_PARTY];
        applicantPartyList[0].DocuSign_URL__c='https://embeddedURLSigning.docusign';
        applicantPartyList[0].DocuSign_Generation_Time__c = System.now();
        applicantPartyList[0].Sent_Url__c = true;
        Database.update(applicantPartyList);

        Map<String,Object> requestMap = getRequestMap();
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalDocuSignPollingAPI.doSentDocuSignUrl();
            System.assertEquals(ExternalConstants.TWO_HUNDRED_TWO_STATUS_CODE, RestContext.response.statusCode, 'Failure');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test for applicant signed already
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testApplicantSignedAlready(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/docuSignPolling';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        genesis__Applications__c applicationObj = getApplication();
        List<clcommon__party__c> applicantPartyList =  [SELECT Id,
                                                                DocuSign_URL__c,
                                                                Sent_Url__c,
                                                                DocuSign_Generation_Time__c,
                                                                DocuSign_Signing_Status__c 
                                                            FROM clcommon__Party__c
                                                            WHERE genesis__Application__r.Id=:applicationObj.Id 
                                                            AND clcommon__Type__r.Name =: ExternalConstants.BORROWER_PARTY];
        applicantPartyList[0].DocuSign_URL__c='https://embeddedURLSigning.docusign';
        applicantPartyList[0].DocuSign_Generation_Time__c = System.now();
        applicantPartyList[0].Sent_Url__c = true;
        applicantPartyList[0].DocuSign_Signing_Status__c = ExternalConstants.PARTY_STATUS_COMPLETED;
        Database.update(applicantPartyList);

        Map<String,Object> requestMap = getRequestMap();
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalDocuSignPollingAPI.doSentDocuSignUrl();
            System.assertEquals(ExternalConstants.TWO_HUNDRED_STATUS_CODE, RestContext.response.statusCode, 'Failure');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test invalid request body
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testInvalidRequestBody(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/docuSignPolling';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');

        request.requestBody = Blob.valueOf(JSON.serialize(''));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalDocuSignPollingAPI.doSentDocuSignUrl();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test dealer cif missing
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testDealerCifMissing(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/docuSignPolling';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');

        Map<String,Object> requestMap = getRequestMap();
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalDocuSignPollingAPI.doSentDocuSignUrl();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test invalid dealer cif
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testInvalidDealerCif(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/docuSignPolling';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '10255567');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');

        Map<String,Object> requestMap = getRequestMap();
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalDocuSignPollingAPI.doSentDocuSignUrl();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test invalid dealer token
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testInvalidDealerToken(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/docuSignPolling';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001121');

        Map<String,Object> requestMap = getRequestMap();
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalDocuSignPollingAPI.doSentDocuSignUrl();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test dealer token missing
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testDealerTokenMissing(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/docuSignPolling';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');

        Map<String,Object> requestMap = getRequestMap();
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalDocuSignPollingAPI.doSentDocuSignUrl();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }
}