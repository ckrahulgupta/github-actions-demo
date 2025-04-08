/**
 * @description       : Test class for ExternalSigningMethodSavedTrigger
 * @author            : Suraj Kumar : 06-06-2024
 * @group             : 
 * @last modified on  : 10-01-2024
 * @last modified by  : Suraj Kumar
**/
@isTest
public with sharing class ExternalSigningMethodSavedTriggerTest {
    @TestSetup
    static void setup() {
        // Creating Business Information
        genesis__Business_Information__c dealerBusinessInfoObj = ExternalAPITestHelper.createBusinessInfoForDealer();
        Database.insert(dealerBusinessInfoObj, true);

        // Creating Account for Dealer
        Account dealerAccountObj = ExternalAPITestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
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
        borrowerAccountObj.Unique_Id__c = 'TestBorrUniqueId007';
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

        Account coBorrowerAccObj = ExternalAPITestHelper.createSolePropAccount(entityObj, borrowerBusinessInfoObj.Id);
        coBorrowerAccObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CoApplicant').getRecordTypeId();
        coBorrowerAccObj.Unique_Id__c = 'TestCoBorrUniqueId007';
        Database.insert(coBorrowerAccObj,true);

        Contact coBorrowerContactObj = ExternalAPITestHelper.createBorrowerContact(coBorrowerAccObj.Id);
        Database.insert(coBorrowerContactObj,true);

        clcommon__Party_Type__c borrowerPartyTypeObj = ExternalAPITestHelper.createPartyType('BORROWER');
        Database.insert( borrowerPartyTypeObj,true);

        // Creating Principal Party for current application
        Map<String,Id> paramForborrowerPartyMap = new Map<String,Id>{
            'accountId' => borrowerAccountObj.Id,
            'contactId' => borrowerContactObj.Id,
            'partyTypeId' => borrowerPartyTypeObj.Id,
            'applicationId' => applicationObj.Id
        };

        clcommon__Party__c borrowerPartyObj = ExternalAPITestHelper.createParty(paramForborrowerPartyMap);
        Database.insert(borrowerPartyObj,true);

        clcommon__Party_Type__c principalPartyTypeObj = ExternalAPITestHelper.createPartyType('PRINCIPAL');
        Database.insert( principalPartyTypeObj,true);

        // Creating Principal Party for current application
        Map<String,Id> paramForPrincipalPartyMap = new Map<String,Id>{
            'accountId' => coBorrowerAccObj.Id,
            'contactId' => coBorrowerContactObj.Id,
            'partyTypeId' => principalPartyTypeObj.Id,
            'applicationId' => applicationObj.Id
        };
        clcommon__Party__c principalPartyObj = ExternalAPITestHelper.createParty(paramForPrincipalPartyMap);
        principalPartyObj.Principal_Number__c = 1;
        Database.insert(principalPartyObj,true);

        Task taskObj = ExternalAPITestHelper.createTask(applicationObj.id, 'Signed Credit Agreement');
        Database.insert(taskObj,true);

        clcommon__document_category__c docCategoryObj = ExternalAPITestHelper.createDocCategory(applicationObj.id,'Signed Credit Agreement');
        Database.insert(docCategoryObj,true);

        ContentVersion contentVersionObj = ExternalAPITestHelper.createContentVersion('Credit Application Agreement.pdf');
        Database.insert(contentVersionObj,true); 

        ContentDocument contentDocumentObj = [SELECT Id FROM ContentDocument WHERE Title = 'Credit Application Agreement.pdf' LIMIT 1];

        ContentDocumentLink contentDocumentLinkObj = ExternalAPITestHelper.createContentDocumentLink(contentDocumentObj.id,applicationObj.id);
        Database.insert(contentDocumentLinkObj,true);
    }

    /**
    * @description : method to get application obj
    * @author Suraj Kumar | 06-06-2024 
    * @return genesis__Applications__c 
    **/
    private static genesis__Applications__c getApplication(){
        genesis__Applications__c applicationObj = [SELECT Id,
                                                            genesis__Account__c,
                                                            genesis__Account__r.Unique_Id__c
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Number__c = '300023456'
                                                        LIMIT 1];
        return applicationObj;
    }

    /**
    * @description : Method to test In Person Docusign
    * @author Suraj Kumar | 10-01-2024 
    **/
    @isTest
    private static void testInPersonDocusign(){
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        genesis__Applications__c applicationObj = getApplication();
        ExternalSigningMethodSaved__e signingMethodEvent = new ExternalSigningMethodSaved__e();
        signingMethodEvent.Application_Id__c = applicationObj.Id;
        signingMethodEvent.User_Id__c = applicationObj.genesis__Account__r.Unique_Id__c;
        signingMethodEvent.Signing_Method__c = 'In Person - Docusign';

        System.runAs(userObj){
            Test.startTest();
            Database.SaveResult result = EventBus.publish(signingMethodEvent);
            Test.stopTest();
            System.assertEquals(true, result.isSuccess(), 'Failed');
        }
    }
    /**
    * @description : Method to test Email Docusign
    * @author Suraj Kumar | 10-01-2024 
    **/
    @isTest
    private static void testEmailDocusign(){
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        genesis__Applications__c applicationObj = getApplication();
        ExternalSigningMethodSaved__e signingMethodEvent = new ExternalSigningMethodSaved__e();
        signingMethodEvent.Application_Id__c = applicationObj.Id;
        signingMethodEvent.User_Id__c = applicationObj.genesis__Account__r.Unique_Id__c;
        signingMethodEvent.Signing_Method__c = 'Email - Docusign';

        System.runAs(userObj){
            Test.startTest();
            Database.SaveResult result = EventBus.publish(signingMethodEvent);
            Test.stopTest();
            System.assertEquals(true, result.isSuccess(), 'Failed');
        }
    }

    /**
    * @description : Method to test application id null
    * @author Suraj Kumar | 10-01-2024 
    **/
    @isTest
    private static void testAppIdNull(){
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        RestResponse response = new RestResponse();
        genesis__Applications__c applicationObj = getApplication();
        ExternalSigningMethodSaved__e signingMethodEvent = new ExternalSigningMethodSaved__e();
        signingMethodEvent.Application_Id__c = null;
        signingMethodEvent.User_Id__c = applicationObj.genesis__Account__r.Unique_Id__c;
        signingMethodEvent.Signing_Method__c = 'Email - Docusign';
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            EventBus.publish(signingMethodEvent);
            Test.stopTest();
            System.assertEquals(RestContext.response.statusCode, ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, 'Assertion failed');
        }
    }

    /**
    * @description : Method to test signing method null
    * @author Suraj Kumar | 10-01-2024 
    **/
    @isTest
    private static void testSigningMethodNull(){
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        RestResponse response = new RestResponse();
        genesis__Applications__c applicationObj = getApplication();
        ExternalSigningMethodSaved__e signingMethodEvent = new ExternalSigningMethodSaved__e();
        signingMethodEvent.Application_Id__c = applicationObj.Id;
        signingMethodEvent.User_Id__c = applicationObj.genesis__Account__r.Unique_Id__c;
        signingMethodEvent.Signing_Method__c = null;
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            EventBus.publish(signingMethodEvent);
            Test.stopTest();
            System.assertEquals(RestContext.response.statusCode, ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, 'Assertion failed');
        }
    }

    /**
    * @description : Method to test user id null
    * @author Suraj Kumar | 10-01-2024 
    **/
    @isTest
    private static void testUserIdNull(){
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        RestResponse response = new RestResponse();
        genesis__Applications__c applicationObj = getApplication();
        ExternalSigningMethodSaved__e signingMethodEvent = new ExternalSigningMethodSaved__e();
        signingMethodEvent.Application_Id__c = applicationObj.Id;
        signingMethodEvent.User_Id__c = null;
        signingMethodEvent.Signing_Method__c = 'Email - Docusign';
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            EventBus.publish(signingMethodEvent);
            Test.stopTest();
            System.assertEquals(RestContext.response.statusCode, ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, 'Assertion failed');
        }
    }

    /**
    * @description : Method to test failure event
    * @author Suraj Kumar | 10-01-2024 
    **/
    @isTest
    private static void testFailureEvent(){
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        RestResponse response = new RestResponse();
        genesis__Applications__c applicationObj = getApplication();
        ExternalSigningMethodSaved__e signingMethodEvent = new ExternalSigningMethodSaved__e();
        signingMethodEvent.Application_Id__c = applicationObj.Id;
        signingMethodEvent.User_Id__c = applicationObj.genesis__Account__r.Unique_Id__c;
        signingMethodEvent.Signing_Method__c = 'Email - Docusign';
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            EventBus.publish(signingMethodEvent);
            Test.getEventBus().fail();
            Test.stopTest();
            System.assertEquals(RestContext.response.statusCode, null, 'Assertion failed');
        }
    }

    /**
    * @description : Method to test api failure
    * @author Suraj Kumar | 10-01-2024 
    **/
    @isTest
    private static void testApiFailure(){
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        RestResponse response = new RestResponse();
        genesis__Applications__c applicationObj = getApplication();
        ExternalSigningMethodSaved__e signingMethodEvent = new ExternalSigningMethodSaved__e();
        signingMethodEvent.Application_Id__c = applicationObj.Id;
        signingMethodEvent.User_Id__c = applicationObj.genesis__Account__r.Unique_Id__c;
        signingMethodEvent.Signing_Method__c = 'Random Method';
        RestContext.response = response;
        System.runAs(userObj){
            Test.startTest();
            EventBus.publish(signingMethodEvent);
            Test.stopTest();
            System.assertEquals(RestContext.response.statusCode, ExternalConstants.FOUR_HUNDRED_THREE_STATUS_CODE, 'Assertion failed');
        }
    }
    /**
    * @description : Method to test in person docusign with existing URL
    * @author Suraj Kumar | 10-01-2024 
    **/
    @isTest
    private static void testInPersonDocusignWithURLInParty(){
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        genesis__Applications__c applicationObj = getApplication();
        ExternalSigningMethodSaved__e signingMethodEvent = new ExternalSigningMethodSaved__e();
        signingMethodEvent.Application_Id__c = applicationObj.Id;
        signingMethodEvent.User_Id__c = applicationObj.genesis__Account__r.Unique_Id__c;
        signingMethodEvent.Signing_Method__c = 'In Person - Docusign';
        List<clcommon__party__c> partyList = [SELECT Id, DocuSign_URL__c 
                        FROM clcommon__party__c 
                        WHERE genesis__Application__c =:applicationObj.Id];
        
        partyList[0].DocuSign_URL__c = 'https//docusign.com';
        Database.update(partyList,true);

        System.runAs(userObj){
            Test.startTest();
            Database.SaveResult result = EventBus.publish(signingMethodEvent);
            Test.stopTest();
            System.assertEquals(true, result.isSuccess(), 'Failed');
        }
    }
}