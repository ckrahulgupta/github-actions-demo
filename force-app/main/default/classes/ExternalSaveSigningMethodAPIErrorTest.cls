/**
 * @description       : Test class for ExternalSaveSigningMethodAPI
 * @author            : Suraj Kumar | 06-07-2024
 * @group             : 
 * @last modified on  : 01-11-2025
 * @last modified by  : Suraj Kumar
**/
@isTest
public with sharing class ExternalSaveSigningMethodAPIErrorTest {
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
        borrowerAccountObj.Unique_Id__c = 'TestBorrUniqueId005';

        Account coBorrowerAccObj = ExternalAPITestHelper.createSolePropAccount(entityObj, borrowerBusinessInfoObj.Id);
        coBorrowerAccObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CoApplicant').getRecordTypeId();
        coBorrowerAccObj.Unique_Id__c = 'TestCoBorrUniqueId005';

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
    * @description : method to get borrower contact
    * @author Suraj Kumar | 06-06-2024 
    * @return Contact 
    **/
    private static Contact getBorrowerContact(){
        genesis__Applications__c applicationObj = getApplication();
        List<Contact> contactList = [SELECT Id,
                                        FirstName,
                                        genesis__SSN__c,
                                        Confirm_SSN__c,
                                        Birthdate,
                                        Email
                                    FROM Contact 
                                    WHERE AccountId = :applicationObj.genesis__Account__c];
        return contactList[0];
    }

    /**
    * @description : method to get Borrower party for Company
    * @author Suraj Kumar | 06-06-2024 
    * @return clcommon__Party__c 
    **/
    private static clcommon__Party__c getBussinessGrowerParty(){
        List<clcommon__Legal_Entity__c> entityList = [SELECT Id, 
                                                        clcommon__Legal_Entity_Type__c,
                                                        Name 
                                                    FROM clcommon__Legal_Entity__c LIMIT 1];
        entityList[0].clcommon__Legal_Entity_Type__c = 'Corporation';
        entityList[0].Name = 'Corporation';
        Database.update(entityList[0],true);
        genesis__Applications__c applicationObj = getApplication();
        List<clcommon__Party__c> borrowerPartyList = [SELECT Id, 
                                                        genesis__Application__c,
                                                        Street__c,
                                                        City__c,
                                                        State__c,
                                                        Postal_Code__c,
                                                        County__c,
                                                        Mobile_Number__c,
                                                        Work_Number__c,
                                                        Home_Number__c,
                                                        clcommon__Contact__c,
                                                        clcommon__Account__c,
                                                        clcommon__Account__r.genesis__Business_Information__c
                                                    FROM clcommon__Party__c
                                                    WHERE genesis__Application__r.Id=:applicationObj.Id 
                                                    AND  clcommon__Type__r.Name =: ExternalConstants.BORROWER_PARTY];
        return borrowerPartyList[0];
    }

     /**
    * @description : method to get Borrower party for Sole Prop
    * @author Suraj Kumar | 06-06-2024 
    * @return clcommon__Party__c 
    **/
    private static clcommon__Party__c getSolePropGrowerParty(){
        genesis__Applications__c applicationObj = getApplication();
        List<clcommon__Party__c> borrowerPartyList = [SELECT Id, 
                                                        genesis__Application__c,
                                                        Street__c,
                                                        City__c,
                                                        State__c,
                                                        Postal_Code__c,
                                                        County__c,
                                                        Mobile_Number__c,
                                                        Work_Number__c,
                                                        Home_Number__c,
                                                        clcommon__Contact__c,
                                                        clcommon__Account__c,
                                                        clcommon__Account__r.genesis__Business_Information__c
                                                    FROM clcommon__Party__c
                                                    WHERE genesis__Application__r.Id=:applicationObj.Id 
                                                    AND  clcommon__Type__r.Name =: ExternalConstants.BORROWER_PARTY];
        return borrowerPartyList[0];
    }

    /**
    * @description : Method to test firstName missing
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testWithoutFirstName(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Contact contactObj = getBorrowerContact();
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
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode,  'Assertion Failed');
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test city missing for sole prop 
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testWithoutCitySoleProp(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        clcommon__Party__c borrowerPartyObj = getSolePropGrowerParty();
        borrowerPartyObj.City__c = null;
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
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode,  'Assertion Failed');
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test street missing for sole prop borrower
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testWithoutStreetSoleProp(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        clcommon__Party__c borrowerPartyObj = getSolePropGrowerParty();
        borrowerPartyObj.Street__c = null;
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
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode,  'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test state missing for sole prop borrower
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testWithoutStateSoleProp(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        clcommon__Party__c borrowerPartyObj = getSolePropGrowerParty();
        borrowerPartyObj.State__c = null;
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
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode,  'Assertion Failed');
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test county missing for sole prop borrower
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testWithoutCountySoleProp(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        clcommon__Party__c borrowerPartyObj = getSolePropGrowerParty();
        borrowerPartyObj.County__c = null;
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
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode,  'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test postal code missing for sole prop borrower
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testWithoutPostalCode(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        clcommon__Party__c borrowerPartyObj = getSolePropGrowerParty();
        borrowerPartyObj.Postal_Code__c = null;
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
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode,  'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test invalid postal code for sole prop borrower
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testInvalidPostalCode(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        clcommon__Party__c borrowerPartyObj = getSolePropGrowerParty();
        borrowerPartyObj.Postal_Code__c = '123456';
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
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode,  'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test SSN missing for sole prop borrower
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testWithoutSSN(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Contact contactObj = getBorrowerContact();
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
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode,  'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test invalid SSN for sole prop borrower
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testInvalidSSN(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Contact contactObj = getBorrowerContact();
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
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode,  'Assertion Failed');
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test DOB missing for sole prop borrower
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testWithoutDob(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Contact contactObj = getBorrowerContact();
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
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode,  'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test contact number missing for sole prop borrower
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testWithoutContactNumberSoleProp(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        clcommon__Party__c borrowerPartyObj = getSolePropGrowerParty();
        borrowerPartyObj.Mobile_Number__c = null;
        borrowerPartyObj.Work_Number__c = null;
        borrowerPartyObj.Home_Number__c = null;
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
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode,  'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test state missing for bussiness 
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testBusinessWithoutState(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        clcommon__Party__c borrowerPartyObj = getBussinessGrowerParty();
        borrowerPartyObj.State__c = null;
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
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode,  'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test street missing for business
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testBusinessWithoutStreet(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        clcommon__Party__c borrowerPartyObj = getBussinessGrowerParty();
        borrowerPartyObj.Street__c = null;
        Database.update(borrowerPartyObj,true);
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/saveSigningMethod';
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
    * @description : Method to test city missing for business
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testBusinessWithoutCity(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        clcommon__Party__c borrowerPartyObj = getBussinessGrowerParty();
        borrowerPartyObj.City__c = null;
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
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode,  'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test postal code missing for business
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testBusinessWithoutPostalCode(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        clcommon__Party__c borrowerPartyObj = getBussinessGrowerParty();
        borrowerPartyObj.Postal_Code__c = null;
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
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode,  'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test invalid postal code for business
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testBusinessInvalidPostalCode(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        clcommon__Party__c borrowerPartyObj = getBussinessGrowerParty();
        borrowerPartyObj.Postal_Code__c = '123456';
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
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode,  'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test county missing for business
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testBusinessWithoutCounty(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        clcommon__Party__c borrowerPartyObj = getBussinessGrowerParty();
        borrowerPartyObj.County__c = null;
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
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode,  'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test number missing for business
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testBusinessWithoutNumber(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        clcommon__Party__c borrowerPartyObj = getBussinessGrowerParty();
        borrowerPartyObj.Mobile_Number__c = null;
        borrowerPartyObj.Work_Number__c = null;
        borrowerPartyObj.Home_Number__c = null;
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
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode,  'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test TIN missing for business
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testBusinessWithoutTIN(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        clcommon__Party__c borrowerPartyObj = getBussinessGrowerParty();
        List<genesis__Business_Information__c> borrowerBInfoList =  [SELECT Id,
                                                                        genesis__Tax_Identification_Number__c
                                                                    FROM genesis__Business_Information__c
                                                                    WHERE Id=:borrowerPartyObj.clcommon__Account__r.genesis__Business_Information__c];
        borrowerBInfoList[0].genesis__Tax_Identification_Number__c = null;
        Database.update(borrowerBInfoList[0],true);
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
    * @description : Method to test email missing
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testSolePropWithoutEmail(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        List<Account> accountList = [SELECT Id,
                                        clcommon__Email__c
                                    FROM Account
                                    WHERE Id=:applicationObj.genesis__Account__c];
        accountList[0].clcommon__Email__c = null;
        Database.update(accountList[0],true);
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
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode,  'Assertion Failed');
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
        request.requestUri = '/api/v1/external/saveSigningMethod';
        request.httpMethod = 'POST';
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
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode,  'Assertion Failed');
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
        request.requestUri = '/api/v1/external/saveSigningMethod';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '10255125');
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
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode,  'Assertion Failed');
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
        request.requestUri = '/api/v1/external/saveSigningMethod';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
       
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
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode,  'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test dealer token invalid
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testDealerTokenInvalid(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/saveSigningMethod';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
       
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
            System.assertEquals(ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, RestContext.response.statusCode,  'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test request body blank
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testRequestBodyBlank(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/saveSigningMethod';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');

        request.requestBody = Blob.valueOf(JSON.serialize(''));
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
    * @description : Method to test invalid application status for signing method
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testInvalidAppStatus(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestUri = '/api/v1/external/saveSigningMethod';
        request.httpMethod = 'POST';
        request.addHeader(ExternalConstants.DEALER_CIF_KEY, '102555');
        request.addHeader(ExternalConstants.DEALER_TOKEN_KEY, 'testd001');
        genesis__Applications__c applicationObj = getApplication();
        applicationObj.genesis__Status__c = 'ACTIVE';
        Database.update(applicationObj,true);

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
}