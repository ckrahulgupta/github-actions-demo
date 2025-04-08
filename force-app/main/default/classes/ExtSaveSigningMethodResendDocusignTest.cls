/**
 * @description       : Test class for ExternalSaveSigningMethodAPI, to test the Resend Docusign Scenario
 * @author            : Suraj Kumar | 10-23-2024
 * @group             : 
 * @last modified on  : 01-11-2025
 * @last modified by  : Suraj Kumar
**/
@isTest
public with sharing class ExtSaveSigningMethodResendDocusignTest {
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

        Account anotherCoBorrowerAccObj = ExternalAPITestHelper.createSolePropAccount(entityObj, borrowerBusinessInfoObj.Id);
        anotherCoBorrowerAccObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CoApplicant').getRecordTypeId();
        anotherCoBorrowerAccObj.Unique_Id__c = 'TestCoBorrUniqueId005';

        Database.insert(new List<Account>{clAccountObj,borrowerAccountObj, coBorrowerAccObj, anotherCoBorrowerAccObj}, true);

        // Creating Contact for Certified Lender
        Contact clContactObj = ExternalAPITestHelper.createCLContact(clAccountObj.Id);

        Contact borrowerContactObj = ExternalAPITestHelper.createBorrowerContact(borrowerAccountObj.Id);

        Contact coBorrowerContactObj = ExternalAPITestHelper.createBorrowerContact(coBorrowerAccObj.Id);

        Contact anotherCoBorrowerContObj = ExternalAPITestHelper.createBorrowerContact(anotherCoBorrowerAccObj.Id);
        Database.insert(new List<Contact>{clContactObj, borrowerContactObj, coBorrowerContactObj, anotherCoBorrowerContObj},true);

        Dealer_Applicant_Relationship__c borrowerDealerRelObj = ExternalAPITestHelper.createApplicantDealerRelationship(borrowerAccountObj, borrowerContactObj, dealerAccountObj);
        Dealer_Applicant_Relationship__c coBorrowerDealerRelObj = ExternalAPITestHelper.createApplicantDealerRelationship(coBorrowerAccObj, coBorrowerContactObj, dealerAccountObj);
        Dealer_Applicant_Relationship__c anotherCoBorrowerDRObj = ExternalAPITestHelper.createApplicantDealerRelationship(anotherCoBorrowerAccObj, anotherCoBorrowerContObj, dealerAccountObj);
        Database.insert(new List<Dealer_Applicant_Relationship__c>{borrowerDealerRelObj,coBorrowerDealerRelObj,anotherCoBorrowerDRObj},true);

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

        Map<String,Id> anotherPrincipalPartyMap = new Map<String,Id>{
            'accountId' => anotherCoBorrowerAccObj.Id,
            'contactId' => anotherCoBorrowerContObj.Id,
            'partyTypeId' => principalPartyTypeObj.Id,
            'applicationId' => applicationObj.Id,
            'dealerApplicantRelId' => anotherCoBorrowerDRObj.Id
        };

        clcommon__Party__c anotherPrincipalPartyObj = ExternalAPITestHelper.createApplicantParty(anotherPrincipalPartyMap);
        anotherPrincipalPartyObj.Principal_Number__c = 2;

        Database.insert(new List<clcommon__Party__c>{borrowerPartyObj,principalPartyObj,anotherPrincipalPartyObj},true);

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
                                                            genesis__Account__r.Unique_Id__c
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Number__c = '300023456'
                                                        LIMIT 1];
        return applicationList[0];
    }

    /**
    * @description : Method to get entity
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
    * @description : method to get request map
    * @author Suraj Kumar | 10-23-2024
    * @return Map<String, Object> 
    **/
    public static Map<String,Object> getRequestMap(){
        genesis__Applications__c applicationObj = getApplication();

        Map<String,Object> applicationDetailsMap = new Map<String,Object>{
            'id' => applicationObj.Id
        };
        Map<String,Object> borrowerDetailsMap = new Map<String,Object>{
            'user_id' => applicationObj.genesis__Account__r.Unique_Id__c
        };
        Map<String,Object> signingDetailsMap = new Map<String,Object>{
            'signing_type' => ExternalConstants.IN_PERSON_HYBRID
        };

        Map<String,Object> requestMap = new Map<String,Object>{
            'application_details' => applicationDetailsMap,
            'borrower_details' => borrowerDetailsMap,
            'signing_method_details' => signingDetailsMap
        };
        return requestMap;
    }
    /**
    * @description : Method to test resend docusign for sole prop
    * @author Suraj Kumar | 10-21-2024 
    **/
    @isTest
    private static void testResendDocuSignHybridSoleProp(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/saveSigningMethod';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
       
        Map<String,Object> signingDetailsMap = new Map<String,Object>{
            'signing_type' => ExternalConstants.IN_PERSON_HYBRID,
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

    /**
    * @description : Method to test resend docusign for sole prop without principal
    * @author Suraj Kumar | 10-21-2024 
    **/
    @isTest
    private static void testResendDSignHybridSolePropWithoutPrincipal(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        List<clcommon__Party__c> principalPartyList = [SELECT Id, 
                                                                genesis__Application__c
                                                            FROM clcommon__Party__c
                                                            WHERE genesis__Application__r.Id=:applicationObj.Id 
                                                            AND  clcommon__Type__r.Name =: ExternalConstants.PRINCIPAL_PARTY];
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
            'signing_type' => ExternalConstants.IN_PERSON_HYBRID,
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

    /**
    * @description : Method to test resend docusign for business
    * @author Suraj Kumar | 10-21-2024 
    **/
    @isTest
    private static void testResendDocuSignHybridBusiness(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        clcommon__Legal_Entity__c entityObj = getEntityType();
        entityObj.clcommon__Legal_Entity_Type__c = 'Corporation';
        entityObj.Name = 'Corporation';
        Database.update(entityObj,true);
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/saveSigningMethod';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
       
        Map<String,Object> signingDetailsMap = new Map<String,Object>{
            'signing_type' => ExternalConstants.IN_PERSON_HYBRID,
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

    /**
    * @description : Method to test resend docusign for business without principal
    * @author Suraj Kumar | 10-21-2024 
    **/
    @isTest
    private static void testResendDSignHybridBusinessWithoutPrincipal(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        clcommon__Legal_Entity__c entityObj = getEntityType();
        entityObj.clcommon__Legal_Entity_Type__c = 'Corporation';
        entityObj.Name = 'Corporation';
        Database.update(entityObj,true);
        genesis__Applications__c applicationObj = getApplication();
        List<clcommon__Party__c> principalPartyList = [SELECT Id, 
                                                                genesis__Application__c
                                                            FROM clcommon__Party__c
                                                            WHERE genesis__Application__r.Id=:applicationObj.Id 
                                                            AND  clcommon__Type__r.Name =: ExternalConstants.PRINCIPAL_PARTY];
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
            'signing_type' => ExternalConstants.IN_PERSON_HYBRID,
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
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Failure');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test resend docusign for business with one principal
    * @author Suraj Kumar | 10-21-2024 
    **/
    @isTest
    private static void testResendDSHybridBusinessWithOnePrincipal(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        clcommon__Legal_Entity__c entityObj = getEntityType();
        entityObj.clcommon__Legal_Entity_Type__c = 'Corporation';
        entityObj.Name = 'Corporation';
        Database.update(entityObj,true);
        genesis__Applications__c applicationObj = getApplication();
        List<clcommon__Party__c> principalPartyList = [SELECT Id, 
                                                                genesis__Application__c
                                                            FROM clcommon__Party__c
                                                            WHERE genesis__Application__r.Id=:applicationObj.Id 
                                                            AND  clcommon__Type__r.Name =: ExternalConstants.PRINCIPAL_PARTY
                                                            AND Principal_Number__c = 2];
        principalPartyList[0].genesis__Application__c = null;
        Database.update(principalPartyList[0],true);
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/saveSigningMethod';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
       
        Map<String,Object> signingDetailsMap = new Map<String,Object>{
            'signing_type' => ExternalConstants.IN_PERSON_HYBRID,
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

    /**
    * @description : Method to test docusign hybrid when passing the resend_docusign as false.
    * @author Suraj Kumar | 10-21-2024 
    **/
    @isTest
    private static void testResendDocuSignHybridFalse(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/saveSigningMethod';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
       
        Map<String,Object> signingDetailsMap = new Map<String,Object>{
            'signing_type' => ExternalConstants.IN_PERSON_HYBRID,
            'resend_docusign' => false
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
    * @description : Method to test docusign hybrid when passing the resend_docusign as blank string.
    * @author Suraj Kumar | 10-21-2024 
    **/
    @isTest
    private static void testResendDocuSignHybridBlank(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/saveSigningMethod';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
       
        Map<String,Object> signingDetailsMap = new Map<String,Object>{
            'signing_type' => ExternalConstants.IN_PERSON_HYBRID,
            'resend_docusign' => ''
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
    * @description : Method to test docusign hybrid when passing the resend_docusign as null.
    * @author Suraj Kumar | 10-21-2024 
    **/
    @isTest
    private static void testResendDocuSignHybridNull(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/saveSigningMethod';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
       
        Map<String,Object> signingDetailsMap = new Map<String,Object>{
            'signing_type' => ExternalConstants.IN_PERSON_HYBRID,
            'resend_docusign' => null
        };

        Map<String,Object> requestMap = getRequestMap();
        requestMap.put('signing_method_details',signingDetailsMap);
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalSaveSigningMethodAPI.doSaveSigningMethod();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Failure');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test docusign hybrid when not passing the resend_docusign.
    * @author Suraj Kumar | 10-21-2024 
    **/
    @isTest
    private static void testWithoutResendDocuSignHybrid(){
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
    * @description : Method to test resend docusign for invalid application status
    * @author Suraj Kumar | 10-21-2024 
    **/
    @isTest
    private static void testInvalidResendDocuSignHybrid(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        applicationObj.genesis__Status__c = 'ACTIVE';
        Database.update(applicationObj,true);
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/saveSigningMethod';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
       
        Map<String,Object> signingDetailsMap = new Map<String,Object>{
            'signing_type' => ExternalConstants.IN_PERSON_HYBRID,
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
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Failure');
            Test.stopTest();
        }
    }
     /**
    * @description : Method to test resend Email docusign for sole prop
    * @author Suraj Kumar | 10-21-2024 
    **/
    @isTest
    private static void testResendEmailDocusignSoleProp(){
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

    /**
    * @description : Method to test resend Email docusign for sole prop with no principal
    * @author Suraj Kumar | 10-21-2024 
    **/
    @isTest
    private static void testResendEmailSolePropWithoutPrincipal(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        List<clcommon__Party__c> principalPartyList = [SELECT Id, 
                                                                genesis__Application__c
                                                            FROM clcommon__Party__c
                                                            WHERE genesis__Application__r.Id=:applicationObj.Id 
                                                            AND  clcommon__Type__r.Name =: ExternalConstants.PRINCIPAL_PARTY];
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

    /**
    * @description : Method to test resend Email docusign for Business 
    * @author Suraj Kumar | 10-21-2024 
    **/
    @isTest
    private static void testResendEmailDocusignBusiness(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        clcommon__Legal_Entity__c entityObj = getEntityType();
        entityObj.clcommon__Legal_Entity_Type__c = 'Corporation';
        entityObj.Name = 'Corporation';
        Database.update(entityObj,true);
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

    /**
    * @description : Method to test resend Email docusign for Business without principal
    * @author Suraj Kumar | 10-21-2024 
    **/
    @isTest
    private static void testResendEmailBusinessWithoutPrincipal(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        clcommon__Legal_Entity__c entityObj = getEntityType();
        entityObj.clcommon__Legal_Entity_Type__c = 'Corporation';
        entityObj.Name = 'Corporation';
        Database.update(entityObj,true);
        genesis__Applications__c applicationObj = getApplication();
        List<clcommon__Party__c> principalPartyList = [SELECT Id, 
                                                                genesis__Application__c
                                                            FROM clcommon__Party__c
                                                            WHERE genesis__Application__r.Id=:applicationObj.Id 
                                                            AND  clcommon__Type__r.Name =: ExternalConstants.PRINCIPAL_PARTY];
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
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Failure');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test resend Email docusign for Business with One principal
    * @author Suraj Kumar | 10-21-2024 
    **/
    @isTest
    private static void testResendEmailBusinessWithOnePrincipal(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        clcommon__Legal_Entity__c entityObj = getEntityType();
        entityObj.clcommon__Legal_Entity_Type__c = 'Corporation';
        entityObj.Name = 'Corporation';
        Database.update(entityObj,true);
        genesis__Applications__c applicationObj = getApplication();
        List<clcommon__Party__c> principalPartyList = [SELECT Id, 
                                                                genesis__Application__c
                                                            FROM clcommon__Party__c
                                                            WHERE genesis__Application__r.Id=:applicationObj.Id 
                                                            AND  clcommon__Type__r.Name =: ExternalConstants.PRINCIPAL_PARTY
                                                            AND Principal_Number__c = 2];
        principalPartyList[0].genesis__Application__c = null;
        Database.update(principalPartyList[0],true);
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

    /**
    * @description : Method to test resend email docusign when passing the resend_docusign as false.
    * @author Suraj Kumar | 10-21-2024 
    **/
    @isTest
    private static void testResendEmailDocusignFalse(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/saveSigningMethod';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
       
        Map<String,Object> signingDetailsMap = new Map<String,Object>{
            'signing_type' => ExternalConstants.EMAIL_DOCUSIGN,
            'resend_docusign' => false
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
    * @description : Method to test resend email docusign when passing the resend_docusign as blank string.
    * @author Suraj Kumar | 10-21-2024 
    **/
    @isTest
    private static void testResendEmailDocusignBlank(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/saveSigningMethod';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
       
        Map<String,Object> signingDetailsMap = new Map<String,Object>{
            'signing_type' => ExternalConstants.EMAIL_DOCUSIGN,
            'resend_docusign' => ''
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
    * @description : Method to test resend email docusign when passing the resend_docusign as null.
    * @author Suraj Kumar | 10-21-2024 
    **/
    @isTest
    private static void testResendEmailDocusignNull(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/saveSigningMethod';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
       
        Map<String,Object> signingDetailsMap = new Map<String,Object>{
            'signing_type' => ExternalConstants.EMAIL_DOCUSIGN,
            'resend_docusign' => null
        };

        Map<String,Object> requestMap = getRequestMap();
        requestMap.put('signing_method_details',signingDetailsMap);
        request.requestBody = Blob.valueOf(JSON.serialize(requestMap));
        RestContext.request = request;
        RestContext.response = response;
        System.runAs(userList[0]){
            Test.startTest();
            ExternalSaveSigningMethodAPI.doSaveSigningMethod();
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Failure');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test resend email docusign when not passing the resend_docusign.
    * @author Suraj Kumar | 10-21-2024 
    **/
    @isTest
    private static void testWithoutResendEmailDocusign(){
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
    * @description : Method to test resend email docusign for invalid application status
    * @author Suraj Kumar | 10-21-2024 
    **/
    @isTest
    private static void testInvalidResendEmailDocusign(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        applicationObj.genesis__Status__c = 'ACTIVE';
        Database.update(applicationObj,true);
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
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Failure');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test resend docusign for invalid Signing method
    * @author Suraj Kumar | 10-21-2024 
    **/
    @isTest
    private static void testResendDocusignSigningTypeInvalid(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/saveSigningMethod';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
       
        Map<String,Object> signingDetailsMap = new Map<String,Object>{
            'signing_type' => 'PAPER SCANNED',
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
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Failure');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test resend docusign for Blank Signing method
    * @author Suraj Kumar | 10-21-2024 
    **/
    @isTest
    private static void testResendDocusignSigningTypeBlank(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/saveSigningMethod';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
       
        Map<String,Object> signingDetailsMap = new Map<String,Object>{
            'signing_type' => '',
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
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Failure');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test resend docusign for null Signing method
    * @author Suraj Kumar | 10-21-2024 
    **/
    @isTest
    private static void testResendDocusignSigningTypeNull(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/saveSigningMethod';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
       
        Map<String,Object> signingDetailsMap = new Map<String,Object>{
            'signing_type' => null,
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
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Failure');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test resend docusign for without Signing method
    * @author Suraj Kumar | 10-21-2024 
    **/
    @isTest
    private static void testResendDocusignWithoutSignType(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/saveSigningMethod';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
       
        Map<String,Object> signingDetailsMap = new Map<String,Object>{
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
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Failure');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test Email Docusign without principal business
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testDSEmailWithoutPrincipalBusiness(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        clcommon__Legal_Entity__c entityObj = getEntityType();
        entityObj.clcommon__Legal_Entity_Type__c = 'Corporation';
        entityObj.Name = 'Corporation';
        Database.update(entityObj,true);
        genesis__Applications__c applicationObj = getApplication();
        List<clcommon__Party__c> principalPartyList = [SELECT Id, 
                                                                genesis__Application__c
                                                            FROM clcommon__Party__c
                                                            WHERE genesis__Application__r.Id=:applicationObj.Id 
                                                            AND  clcommon__Type__r.Name =: ExternalConstants.PRINCIPAL_PARTY];
        for(clcommon__Party__c principalPartyObj: principalPartyList){
            principalPartyObj.genesis__Application__c = null;
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
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test DS Hybrid without principal business
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testDSHybridWithoutPrincipalBusiness(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        clcommon__Legal_Entity__c entityObj = getEntityType();
        entityObj.clcommon__Legal_Entity_Type__c = 'Corporation';
        entityObj.Name = 'Corporation';
        Database.update(entityObj,true);
        genesis__Applications__c applicationObj = getApplication();
        List<clcommon__Party__c> principalPartyList = [SELECT Id, 
                                                                genesis__Application__c
                                                            FROM clcommon__Party__c
                                                            WHERE genesis__Application__r.Id=:applicationObj.Id 
                                                            AND  clcommon__Type__r.Name =: ExternalConstants.PRINCIPAL_PARTY];
        for(clcommon__Party__c principalPartyObj: principalPartyList){
            principalPartyObj.genesis__Application__c = null;
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
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test DS Hybrid with one principal for business
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testDSHybridWithOnePrincipalBusiness(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        clcommon__Legal_Entity__c entityObj = getEntityType();
        entityObj.clcommon__Legal_Entity_Type__c = 'Corporation';
        entityObj.Name = 'Corporation';
        Database.update(entityObj,true);
        genesis__Applications__c applicationObj = getApplication();
        List<clcommon__Party__c> principalPartyList = [SELECT Id, 
                                                                genesis__Application__c
                                                            FROM clcommon__Party__c
                                                            WHERE genesis__Application__r.Id=:applicationObj.Id 
                                                            AND  clcommon__Type__r.Name =: ExternalConstants.PRINCIPAL_PARTY
                                                            AND Principal_Number__c = 2];
        principalPartyList[0].genesis__Application__c = null;
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
            System.assertEquals(ExternalConstants.TWO_HUNDRED_ONE_STATUS_CODE, RestContext.response.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test Email Docusign With One principal for business
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testDSEmailWithOnePrincipalBusiness(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        clcommon__Legal_Entity__c entityObj = getEntityType();
        entityObj.clcommon__Legal_Entity_Type__c = 'Corporation';
        entityObj.Name = 'Corporation';
        Database.update(entityObj,true);
        genesis__Applications__c applicationObj = getApplication();
        List<clcommon__Party__c> principalPartyList = [SELECT Id, 
                                                                genesis__Application__c
                                                            FROM clcommon__Party__c
                                                            WHERE genesis__Application__r.Id=:applicationObj.Id 
                                                            AND  clcommon__Type__r.Name =: ExternalConstants.PRINCIPAL_PARTY
                                                            AND Principal_Number__c = 2];
        principalPartyList[0].genesis__Application__c = null;
        Database.update(principalPartyList[0],true);
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
            System.assertEquals(ExternalConstants.TWO_HUNDRED_ONE_STATUS_CODE, RestContext.response.statusCode, 'Assertion Failed');
            Test.stopTest();
        }
    }
}