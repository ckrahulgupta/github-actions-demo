/**
 * @description       : Test class for ExternalApplicationValidationUtil
 * @author            : Krishanu Chinya
 * @group             : 
 * @last modified on  : 04-02-2025
 * @last modified by  : Rakesh Saraf
**/
@IsTest
public with sharing class ExternalApplicationValidationUtilTest {

    /**
    * @description : Setup method to create test data
    * @author Suraj Kumar | 12-17-2024 
    **/
    @TestSetup
    static void setup(){
        // Creating Business Information
        genesis__Business_Information__c dealerBusinessInfoObj = ExternalAPITestHelper.createBusinessInfoForDealer();
        Database.insert(dealerBusinessInfoObj,true);

        // Creating Account for Dealer
        Account dealerAccountObj = ExternalAPITestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        dealerAccountObj.Unique_Id__c = 'testd001';
        dealerAccountObj.CIF_Number__c = '102555';
        Database.insert(dealerAccountObj, true);

        Map<String, clcommon__Legal_Entity__c> legalEntityMap = ExternalAPITestHelper.createMultipleLegalEntity();
        // Creating Legal Entity
        List<clcommon__Legal_Entity__c> legalEntityList = new List<clcommon__Legal_Entity__c>{
            legalEntityMap.get(ExternalConstants.INDIVIDUAL_ENTITY),
            legalEntityMap.get(ExternalConstants.SOLE_PROP_ENTITY),
            legalEntityMap.get(ExternalConstants.CORPORATION),
            legalEntityMap.get(ExternalConstants.LIMITED_LIABILITY_COMPANY),
            legalEntityMap.get(ExternalConstants.GENERAL_PARTNERSHIP),
            legalEntityMap.get(ExternalConstants.LIMITED_PARTNERSHIP),
            legalEntityMap.get(ExternalConstants.JOINT_VENTURE),
            legalEntityMap.get(ExternalConstants.TRUST)
        };
        Database.Insert(legalEntityList, true);
    }

    /**
    * @description : Method to get borrower detail map
    * @author Suraj Kumar | 01-11-2025 
    * @return Map<String, Object> 
    **/
    private static Map<String, Object> getSolePropBorrowerDetailMap(){
        return new Map<String, Object>{
            ExternalConstants.ENTITY_TYPE => ExternalConstants.SOLE_PROP_ENTITY,
            ExternalConstants.LAST_NAME_KEY => 'Doe',
            ExternalConstants.SSN_KEY => '123456789',
            ExternalConstants.CONFIRM_SSN_KEY => '123456789',
            ExternalConstants.EMAIL_KEY => 'test@example.com',
            ExternalConstants.CONFIRM_EMAIL_KEY => 'test@example.com',
            ExternalConstants.PHONE_NUMBER_KEY => '1234567890',
            ExternalConstants.HOME_PHONE_KEY => '1234567890',
            ExternalConstants.WORK_PHONE_KEY => '1234567890',
            ExternalConstants.USER_ID_KEY => '872823'
        };
    }
    /**
    * @description : Method to get principal detail map
    * @author Suraj Kumar | 01-11-2025 
    * @return Map<String, Object> 
    **/
    private static Map<String, Object> getPrincipalDetailMap(){
        return new Map<String, Object>{
            ExternalConstants.FIRST_NAME_KEY => 'James',
            ExternalConstants.LAST_NAME_KEY => 'Doe',
            ExternalConstants.SSN_KEY => '123456789',
            ExternalConstants.CONFIRM_SSN_KEY => '123456789',
            ExternalConstants.USER_ID_KEY => '12345',
            ExternalConstants.EMAIL_KEY => 'test@example.com',
            ExternalConstants.CONFIRM_EMAIL_KEY => 'test@example.com',
            ExternalConstants.PHONE_NUMBER_KEY => '1234567890',
            ExternalConstants.HOME_PHONE_KEY => '1234567890',
            ExternalConstants.WORK_PHONE_KEY => '1234567890'
        };
    }

    /**
    * @description : Method to get Corporation Borrower detail map
    * @author Suraj Kumar | 01-11-2025 
    * @return Map<String, Object> 
    **/
    private static Map<String, Object> getCorpBorrowerDetailMap(){
        return new Map<String, Object>{
            ExternalConstants.ENTITY_TYPE => ExternalConstants.CORPORATION,
            ExternalConstants.NAME_KEY => 'Doe Enterprise',
            ExternalConstants.TAX_ID_KEY => '123456789',
            ExternalConstants.CONFIRM_TAX_ID_KEY => '123456789',
            ExternalConstants.USER_ID_KEY => '89768'
        };
    }

    /**
    * @description : Method to get application detail map
    * @author Suraj Kumar | 01-11-2025 
    * @return Map<String, Object> 
    **/
    private static Map<String,Object> getApplicationDetailMap(){
        return new Map<String, Object>{
            ExternalConstants.LOAN_AMOUNT_KEY => 1000
        };
    }

    /**
    * @description : Method to get dealer detail map
    * @author Suraj Kumar | 01-11-2025 
    * @return Map<String, Object> 
    **/
    private static Map<String,Object> getDealerDetailsMap(){
        return new Map<String,Object>{
            ExternalConstants.DEALER_CIF_KEY => '102555',
            ExternalConstants.DEALER_TOKEN_KEY => 'testd001'
        };
    }
    

    /**
    * @description : method to test valid legal entity
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testValidLegalEntity() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.checkForValidLegalEntityType(ExternalConstants.SOLE_PROP_ENTITY);
            } catch (CustomException e) {
                isExpectionThrown = true;
            }
            System.assertEquals(false, isExpectionThrown, 'Assertion Failed');
            Test.stopTest();
        }
    }


    /**
    * @description : Method to test invalid legal entity
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testInvalidLegalEntity() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.checkForValidLegalEntityType('InvalidLegalEntity');
            } catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.INVALID_LEGAL_ENTITY_TYPE, e.getMessage(), 'Assertion Failed');
            }
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test valid loan amount
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testValidLoanAmount() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.validateLoanAmount(1000);
            } catch (CustomException e) {
                isExpectionThrown = true;
            }
            System.assertEquals(false, isExpectionThrown, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateLoanAmount for null amount
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testNullLoanAmount() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.validateLoanAmount(null);
            } catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.INVALID_LOAN_AMOUNT, e.getMessage(), 'Assertion Failed');
            }
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');
            Test.stopTest();
        }
    }


    /**
    * @description : Method to test validateLoanAmount for negative amount
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testNegativeLoanAmount() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.validateLoanAmount(-1000);
            } catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.INVALID_LOAN_AMOUNT, e.getMessage(), 'Assertion Failed');
            }
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateApplicationData for application detail Null
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testAppDetailNull() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        Map<String, Object> requestMap = new Map<String, Object>{
            ExternalConstants.BORROWER_DETAIL_KEY => getSolePropBorrowerDetailMap()
        };
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.validateApplicationData(requestMap);
            } catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.APPLICATION_DETAILS_MISSING, e.getMessage(), 'Assertion Failed');
            }
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateApplicationData for borrower detail Null
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testBorrowerDetailNull() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        Map<String, Object> requestMap = new Map<String, Object>{
            ExternalConstants.APPLICATION_DETAIL_KEY => getApplicationDetailMap()
        };
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.validateApplicationData(requestMap);
            } catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.BORROWER_DETAILS_MISSING, e.getMessage(), 'Assertion Failed');
            }
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateApplicationData for loan amount null
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testLoanAmountNull() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        Map<String, Object> requestMap = new Map<String, Object>{
            ExternalConstants.APPLICATION_DETAIL_KEY => new Map<String, Object>{
                ExternalConstants.LOAN_AMOUNT_KEY => null
            },
            ExternalConstants.BORROWER_DETAIL_KEY => getSolePropBorrowerDetailMap()
        };
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.validateApplicationData(requestMap);
            } catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.INVALID_LOAN_AMOUNT, e.getMessage(), 'Assertion Failed');
            }
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateApplicationData for entity type missing
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testEntityTypeMissing() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        Map<String, Object> requestMap = new Map<String, Object>{
            ExternalConstants.APPLICATION_DETAIL_KEY => getApplicationDetailMap(),
            ExternalConstants.BORROWER_DETAIL_KEY => new Map<String, Object>{
                ExternalConstants.LAST_NAME_KEY => 'Doe',
                ExternalConstants.SSN_KEY => '123456789',
                ExternalConstants.CONFIRM_SSN_KEY => '123456789',
                ExternalConstants.EMAIL_KEY => 'test@example.com',
                ExternalConstants.CONFIRM_EMAIL_KEY => 'test@example.com',
                ExternalConstants.PHONE_NUMBER_KEY => '1234567890',
                ExternalConstants.HOME_PHONE_KEY => '1234567890',
                ExternalConstants.WORK_PHONE_KEY => '1234567890',
                ExternalConstants.USER_ID_KEY => '872823'
            }
        };
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.validateApplicationData(requestMap);
            } catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.REQUIRED_PARAMETERS_MISSING, e.getMessage(), 'Assertion Failed');
            }
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateApplicationData for entity type invalid
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testEntityTypeInvalid() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        Map<String, Object> requestMap = new Map<String, Object>{
            ExternalConstants.APPLICATION_DETAIL_KEY => getApplicationDetailMap(),
            ExternalConstants.BORROWER_DETAIL_KEY => new Map<String, Object>{
                ExternalConstants.ENTITY_TYPE => 'invalidEntity',
                ExternalConstants.LAST_NAME_KEY => 'Doe',
                ExternalConstants.SSN_KEY => '123456789',
                ExternalConstants.CONFIRM_SSN_KEY => '123456789',
                ExternalConstants.EMAIL_KEY => 'test@example.com',
                ExternalConstants.CONFIRM_EMAIL_KEY => 'test@example.com',
                ExternalConstants.PHONE_NUMBER_KEY => '1234567890',
                ExternalConstants.HOME_PHONE_KEY => '1234567890',
                ExternalConstants.WORK_PHONE_KEY => '1234567890',
                ExternalConstants.USER_ID_KEY => '872823'
            }
        };
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.validateApplicationData(requestMap);
            } catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.INVALID_LEGAL_ENTITY_TYPE, e.getMessage(), 'Assertion Failed');
            }
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateApplicationData for user id null
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testUserIdNull() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        Map<String, Object> requestMap = new Map<String, Object>{
            ExternalConstants.APPLICATION_DETAIL_KEY => getApplicationDetailMap(),
            ExternalConstants.BORROWER_DETAIL_KEY => new Map<String, Object>{
                ExternalConstants.ENTITY_TYPE => ExternalConstants.SOLE_PROP_ENTITY,
                ExternalConstants.LAST_NAME_KEY => 'Doe',
                ExternalConstants.SSN_KEY => '123456789',
                ExternalConstants.CONFIRM_SSN_KEY => '123456789',
                ExternalConstants.EMAIL_KEY => 'test@example.com',
                ExternalConstants.CONFIRM_EMAIL_KEY => 'test@example.com',
                ExternalConstants.PHONE_NUMBER_KEY => '1234567890',
                ExternalConstants.HOME_PHONE_KEY => '1234567890',
                ExternalConstants.WORK_PHONE_KEY => '1234567890'
            }
        };
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.validateApplicationData(requestMap);
            } catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.BORROWER_USER_ID_MISSING, e.getMessage(), 'Assertion Failed');
            }
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateApplicationData for last name missing, sole prop entity
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testSolePropLastNameMissing() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        Map<String, Object> requestMap = new Map<String, Object>{
            ExternalConstants.APPLICATION_DETAIL_KEY => getApplicationDetailMap(),
            ExternalConstants.BORROWER_DETAIL_KEY => new Map<String, Object>{
                ExternalConstants.ENTITY_TYPE => ExternalConstants.SOLE_PROP_ENTITY,
                ExternalConstants.SSN_KEY => '123456789',
                ExternalConstants.CONFIRM_SSN_KEY => '123456789',
                ExternalConstants.EMAIL_KEY => 'test@example.com',
                ExternalConstants.CONFIRM_EMAIL_KEY => 'test@example.com',
                ExternalConstants.PHONE_NUMBER_KEY => '1234567890',
                ExternalConstants.HOME_PHONE_KEY => '1234567890',
                ExternalConstants.WORK_PHONE_KEY => '1234567890',
                ExternalConstants.USER_ID_KEY => '872823'
            }
        };
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.validateApplicationData(requestMap);
            } catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.APPLICANT_NAME_MISSING, e.getMessage(), 'Assertion Failed');
            }
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateApplicationData for invalid ssn, sole prop entity
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testSolePropInvalidSSN() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        Map<String, Object> requestMap = new Map<String, Object>{
            ExternalConstants.APPLICATION_DETAIL_KEY => getApplicationDetailMap(),
            ExternalConstants.BORROWER_DETAIL_KEY => new Map<String, Object>{
                ExternalConstants.ENTITY_TYPE => ExternalConstants.SOLE_PROP_ENTITY,
                ExternalConstants.LAST_NAME_KEY => 'Doe',
                ExternalConstants.SSN_KEY => '1234567890',
                ExternalConstants.CONFIRM_SSN_KEY => '123456789',
                ExternalConstants.EMAIL_KEY => 'test@example.com',
                ExternalConstants.CONFIRM_EMAIL_KEY => 'test@example.com',
                ExternalConstants.PHONE_NUMBER_KEY => '1234567890',
                ExternalConstants.HOME_PHONE_KEY => '1234567890',
                ExternalConstants.WORK_PHONE_KEY => '1234567890',
                ExternalConstants.USER_ID_KEY => '872823'
            }
        };
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.validateApplicationData(requestMap);
            } catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.INVALID_SSN, e.getMessage(), 'Assertion Failed');
            }
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateApplicationData for invalid email, sole prop entity
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testSolePropInvalidEmail() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        Map<String, Object> requestMap = new Map<String, Object>{
            ExternalConstants.APPLICATION_DETAIL_KEY => getApplicationDetailMap(),
            ExternalConstants.BORROWER_DETAIL_KEY => new Map<String, Object>{
                ExternalConstants.ENTITY_TYPE => ExternalConstants.SOLE_PROP_ENTITY,
                ExternalConstants.LAST_NAME_KEY => 'Doe',
                ExternalConstants.SSN_KEY => '123456789',
                ExternalConstants.CONFIRM_SSN_KEY => '123456789',
                ExternalConstants.EMAIL_KEY => 'test@examplecom',
                ExternalConstants.CONFIRM_EMAIL_KEY => 'test@example.com',
                ExternalConstants.PHONE_NUMBER_KEY => '1234567890',
                ExternalConstants.HOME_PHONE_KEY => '1234567890',
                ExternalConstants.WORK_PHONE_KEY => '1234567890',
                ExternalConstants.USER_ID_KEY => '872823'
            }
        };
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.validateApplicationData(requestMap);
            } catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.INVALID_EMAIL, e.getMessage(), 'Assertion Failed');
            }
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateApplicationData for phone number missing, sole prop entity
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testSolePropPhoneNoMissing() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        Map<String, Object> requestMap = new Map<String, Object>{
            ExternalConstants.APPLICATION_DETAIL_KEY => getApplicationDetailMap(),
            ExternalConstants.BORROWER_DETAIL_KEY => new Map<String, Object>{
                ExternalConstants.ENTITY_TYPE => ExternalConstants.SOLE_PROP_ENTITY,
                ExternalConstants.LAST_NAME_KEY => 'Doe',
                ExternalConstants.SSN_KEY => '123456789',
                ExternalConstants.CONFIRM_SSN_KEY => '123456789',
                ExternalConstants.EMAIL_KEY => 'test@example.com',
                ExternalConstants.CONFIRM_EMAIL_KEY => 'test@example.com',
                ExternalConstants.USER_ID_KEY => '872823'
            }
        };
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.validateApplicationData(requestMap);
            } catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.PHONE_NUMBER_MISSING, e.getMessage(), 'Assertion Failed');
            }
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateApplicationData for phone number invalid, sole prop entity
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testSolePropPhoneNoInvalid() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        Map<String, Object> requestMap = new Map<String, Object>{
            ExternalConstants.APPLICATION_DETAIL_KEY => getApplicationDetailMap(),
            ExternalConstants.BORROWER_DETAIL_KEY => new Map<String, Object>{
                ExternalConstants.ENTITY_TYPE => ExternalConstants.SOLE_PROP_ENTITY,
                ExternalConstants.LAST_NAME_KEY => 'Doe',
                ExternalConstants.SSN_KEY => '123456789',
                ExternalConstants.CONFIRM_SSN_KEY => '123456789',
                ExternalConstants.EMAIL_KEY => 'test@example.com',
                ExternalConstants.CONFIRM_EMAIL_KEY => 'test@example.com',
                ExternalConstants.PHONE_NUMBER_KEY => '12345678910',
                ExternalConstants.USER_ID_KEY => '872823'
            }
        };
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.validateApplicationData(requestMap);
            } catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.INVALID_PHONE_NUMBER, e.getMessage(), 'Assertion Failed');
            }
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateApplicationData for principal detail null, Corporation
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testCorpPrincipalDetailNull() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        Map<String, Object> requestMap = new Map<String, Object>{
            ExternalConstants.APPLICATION_DETAIL_KEY => getApplicationDetailMap(),
            ExternalConstants.BORROWER_DETAIL_KEY => getCorpBorrowerDetailMap()
        };
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.validateApplicationData(requestMap);
            } catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.PRINCIPAL_DETAILS_MISSING, e.getMessage(), 'Assertion Failed');
            }
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateApplicationData for borrower name missing, Corporation
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testCorpBorrowerNameMissing() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        Map<String, Object> requestMap = new Map<String, Object>{
            ExternalConstants.APPLICATION_DETAIL_KEY => getApplicationDetailMap(),
            ExternalConstants.BORROWER_DETAIL_KEY => new Map<String, Object>{
                ExternalConstants.ENTITY_TYPE => ExternalConstants.CORPORATION,
                ExternalConstants.TAX_ID_KEY => '123456789',
                ExternalConstants.CONFIRM_TAX_ID_KEY => '123456789',
                ExternalConstants.USER_ID_KEY => '89768'
            },
            ExternalConstants.PRINCIPAL_DETAIL_KEY => getPrincipalDetailMap()
        };
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.validateApplicationData(requestMap);
            } catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.APPLICANT_NAME_MISSING, e.getMessage(), 'Assertion Failed');
            }
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateApplicationData for principal last name missing, Corporation
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testPrincipalLastNameMissing() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        Map<String, Object> requestMap = new Map<String, Object>{
            ExternalConstants.APPLICATION_DETAIL_KEY => getApplicationDetailMap(),
            ExternalConstants.BORROWER_DETAIL_KEY => getCorpBorrowerDetailMap(),
            ExternalConstants.PRINCIPAL_DETAIL_KEY => new Map<String, Object>{
                ExternalConstants.FIRST_NAME_KEY => 'James',
                ExternalConstants.SSN_KEY => '123456789',
                ExternalConstants.CONFIRM_SSN_KEY => '123456789',
                ExternalConstants.USER_ID_KEY => '12345',
                ExternalConstants.EMAIL_KEY => 'test@example.com',
                ExternalConstants.CONFIRM_EMAIL_KEY => 'test@example.com',
                ExternalConstants.PHONE_NUMBER_KEY => '1234567890',
                ExternalConstants.HOME_PHONE_KEY => '1234567890',
                ExternalConstants.WORK_PHONE_KEY => '1234567890'
            }
        };
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.validateApplicationData(requestMap);
            } catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.PRINCIPAL_NAME_MISSING, e.getMessage(), 'Assertion Failed');
            }
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateApplicationData for principal invalid ssn, Corporation
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testPrincipalSSNInvalid() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        Map<String, Object> requestMap = new Map<String, Object>{
            ExternalConstants.APPLICATION_DETAIL_KEY => getApplicationDetailMap(),
            ExternalConstants.BORROWER_DETAIL_KEY => getCorpBorrowerDetailMap(),
            ExternalConstants.PRINCIPAL_DETAIL_KEY => new Map<String, Object>{
                ExternalConstants.FIRST_NAME_KEY => 'James',
                ExternalConstants.LAST_NAME_KEY => 'Doe',
                ExternalConstants.SSN_KEY => '1234567890',
                ExternalConstants.CONFIRM_SSN_KEY => '123456789',
                ExternalConstants.USER_ID_KEY => '12345',
                ExternalConstants.EMAIL_KEY => 'test@example.com',
                ExternalConstants.CONFIRM_EMAIL_KEY => 'test@example.com',
                ExternalConstants.PHONE_NUMBER_KEY => '1234567890',
                ExternalConstants.HOME_PHONE_KEY => '1234567890',
                ExternalConstants.WORK_PHONE_KEY => '1234567890'
            }
        };
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.validateApplicationData(requestMap);
            } catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.INVALID_SSN, e.getMessage(), 'Assertion Failed');
            }
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateApplicationData for principal user id missing, Corporation
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testPrincipalUserIdMissing() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        Map<String, Object> requestMap = new Map<String, Object>{
            ExternalConstants.APPLICATION_DETAIL_KEY => getApplicationDetailMap(),
            ExternalConstants.BORROWER_DETAIL_KEY => getCorpBorrowerDetailMap(),
            ExternalConstants.PRINCIPAL_DETAIL_KEY => new Map<String, Object>{
                ExternalConstants.FIRST_NAME_KEY => 'James',
                ExternalConstants.LAST_NAME_KEY => 'Doe',
                ExternalConstants.SSN_KEY => '123456789',
                ExternalConstants.CONFIRM_SSN_KEY => '123456789',
                ExternalConstants.EMAIL_KEY => 'test@example.com',
                ExternalConstants.CONFIRM_EMAIL_KEY => 'test@example.com',
                ExternalConstants.PHONE_NUMBER_KEY => '1234567890',
                ExternalConstants.HOME_PHONE_KEY => '1234567890',
                ExternalConstants.WORK_PHONE_KEY => '1234567890'
            }
        };
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.validateApplicationData(requestMap);
            } catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.PRINCIPAL_USER_ID_MISSING, e.getMessage(), 'Assertion Failed');
            }
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateApplicationData for principal email invalid, Corporation
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testPrincipalEmailInvalid() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        Map<String, Object> requestMap = new Map<String, Object>{
            ExternalConstants.APPLICATION_DETAIL_KEY => getApplicationDetailMap(),
            ExternalConstants.BORROWER_DETAIL_KEY => getCorpBorrowerDetailMap(),
            ExternalConstants.PRINCIPAL_DETAIL_KEY => new Map<String, Object>{
                ExternalConstants.FIRST_NAME_KEY => 'James',
                ExternalConstants.LAST_NAME_KEY => 'Doe',
                ExternalConstants.SSN_KEY => '123456789',
                ExternalConstants.CONFIRM_SSN_KEY => '123456789',
                ExternalConstants.USER_ID_KEY => '12345',
                ExternalConstants.EMAIL_KEY => 'test@examplecom',
                ExternalConstants.CONFIRM_EMAIL_KEY => 'test@example.com',
                ExternalConstants.PHONE_NUMBER_KEY => '1234567890',
                ExternalConstants.HOME_PHONE_KEY => '1234567890',
                ExternalConstants.WORK_PHONE_KEY => '1234567890'
            }
        };
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.validateApplicationData(requestMap);
            } catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.INVALID_EMAIL, e.getMessage(), 'Assertion Failed');
            }
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateApplicationData for principal phone number missing, Corporation
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testPrincipalPhoneNoMissing() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        Map<String, Object> requestMap = new Map<String, Object>{
            ExternalConstants.APPLICATION_DETAIL_KEY => getApplicationDetailMap(),
            ExternalConstants.BORROWER_DETAIL_KEY => getCorpBorrowerDetailMap(),
            ExternalConstants.PRINCIPAL_DETAIL_KEY => new Map<String, Object>{
                ExternalConstants.FIRST_NAME_KEY => 'James',
                ExternalConstants.LAST_NAME_KEY => 'Doe',
                ExternalConstants.SSN_KEY => '123456789',
                ExternalConstants.CONFIRM_SSN_KEY => '123456789',
                ExternalConstants.USER_ID_KEY => '12345',
                ExternalConstants.EMAIL_KEY => 'test@example.com',
                ExternalConstants.CONFIRM_EMAIL_KEY => 'test@example.com'
            }
        };
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.validateApplicationData(requestMap);
            } catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.PHONE_NUMBER_MISSING, e.getMessage(), 'Assertion Failed');
            }
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateApplicationData for principal phone number invalid, Corporation
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testPrincipalPhoneNoInvalid() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        Map<String, Object> requestMap = new Map<String, Object>{
            ExternalConstants.APPLICATION_DETAIL_KEY => getApplicationDetailMap(),
            ExternalConstants.BORROWER_DETAIL_KEY => getCorpBorrowerDetailMap(),
            ExternalConstants.PRINCIPAL_DETAIL_KEY => new Map<String, Object>{
                ExternalConstants.FIRST_NAME_KEY => 'James',
                ExternalConstants.LAST_NAME_KEY => 'Doe',
                ExternalConstants.SSN_KEY => '123456789',
                ExternalConstants.CONFIRM_SSN_KEY => '123456789',
                ExternalConstants.USER_ID_KEY => '12345',
                ExternalConstants.EMAIL_KEY => 'test@example.com',
                ExternalConstants.CONFIRM_EMAIL_KEY => 'test@example.com',
                ExternalConstants.PHONE_NUMBER_KEY => '12345678901'
            }
        };
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.validateApplicationData(requestMap);
            } catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.INVALID_PHONE_NUMBER, e.getMessage(), 'Assertion Failed');
            }
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateApplicationData for Borrower TIN missing, Corporation
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testBorrowerTinMissing() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        Map<String, Object> requestMap = new Map<String, Object>{
            ExternalConstants.APPLICATION_DETAIL_KEY => getApplicationDetailMap(),
            ExternalConstants.BORROWER_DETAIL_KEY => new Map<String, Object>{
                ExternalConstants.ENTITY_TYPE => ExternalConstants.CORPORATION,
                ExternalConstants.NAME_KEY => 'Doe Enterprise',
                ExternalConstants.CONFIRM_TAX_ID_KEY => '123456789',
                ExternalConstants.USER_ID_KEY => '89768'
            },
            ExternalConstants.PRINCIPAL_DETAIL_KEY => getPrincipalDetailMap()
        };
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.validateApplicationData(requestMap);
            } catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.TIN_MISSING, e.getMessage(), 'Assertion Failed');
            }
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateApplicationData for Borrower TIN Invalid, Corporation
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testBorrowerTinInvalid() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        Map<String, Object> requestMap = new Map<String, Object>{
            ExternalConstants.APPLICATION_DETAIL_KEY => getApplicationDetailMap(),
            ExternalConstants.BORROWER_DETAIL_KEY => new Map<String, Object>{
                ExternalConstants.ENTITY_TYPE => ExternalConstants.CORPORATION,
                ExternalConstants.NAME_KEY => 'Doe Enterprise',
                ExternalConstants.TAX_ID_KEY => '1234567890',
                ExternalConstants.CONFIRM_TAX_ID_KEY => '123456789',
                ExternalConstants.USER_ID_KEY => '89768'
            },
            ExternalConstants.PRINCIPAL_DETAIL_KEY => getPrincipalDetailMap()
        };
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.validateApplicationData(requestMap);
            } catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.INVALID_TIN, e.getMessage(), 'Assertion Failed');
            }
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');
            Test.stopTest();
        }
    }


    /**
    * @description : Method to test validateApplicationData for sole prop
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testValidateApplicationDataSoleProp() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        Map<String, Object> requestMap = new Map<String, Object>{
            ExternalConstants.APPLICATION_DETAIL_KEY => getApplicationDetailMap(),
            ExternalConstants.BORROWER_DETAIL_KEY => getSolePropBorrowerDetailMap()
        };
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.validateApplicationData(requestMap);
            } catch (CustomException e) {
                isExpectionThrown = true;
            }
            System.assertEquals(false, isExpectionThrown, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateApplicationData for corporation
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testValidateApplicationDataCorporation() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        Map<String, Object> requestMap = new Map<String, Object>{
            ExternalConstants.APPLICATION_DETAIL_KEY => getApplicationDetailMap(),
            ExternalConstants.BORROWER_DETAIL_KEY => getCorpBorrowerDetailMap(),
            ExternalConstants.PRINCIPAL_DETAIL_KEY => getPrincipalDetailMap()
        };
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.validateApplicationData(requestMap);
            } catch (CustomException e) {
                isExpectionThrown = true;
            }
            System.assertEquals(false, isExpectionThrown, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateStateOfIncorporation for valid state of incorporation
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testValidStateOfIncorporation() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.validateStateOfIncorporation('AL');
            } catch (Exception e) {
                isExpectionThrown = true;
            }
            System.assertEquals(false, isExpectionThrown, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateStateOfIncorporation for invalid state of incorporation
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testInvalidStateOfIncorporation() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.validateStateOfIncorporation('InvalidState');
            } catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.INVALID_STATE_INCORPORATION, e.getMessage(), 'Assertion Failed');
            }
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateStateOfIncorporation for null state of incorporation
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testEmptyStateOfIncorporation() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.validateStateOfIncorporation('');
            } catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.INVALID_STATE_INCORPORATION, e.getMessage(), 'Assertion Failed');
            }
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateMaritalStatus for valid marital status
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testValidMaritalStatus() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.validateMaritalStatus('Married');
            } catch (Exception e) {
                System.assert(false, 'Unexpected exception: ' + e.getMessage());
            }
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateMaritalStatus for invalid marital status
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testInvalidMaritalStatus() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.validateMaritalStatus('InvalidStatus');
            } catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.INVALID_MARITAL_STATUS, e.getMessage(), 'Assertion Failed');
            }
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateMaritalStatus for null marital status
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testEmptyMaritalStatus() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.validateMaritalStatus('');
            } catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.INVALID_MARITAL_STATUS, e.getMessage(), 'Assertion Failed');
            }
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateSuffix for valid suffix
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testValidSuffix() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.validateSuffix('Sr.');
            } catch (Exception e) {
                isExpectionThrown = true;
            }
            System.assertEquals(false, isExpectionThrown, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateSuffix for invalid suffix
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testInvalidSuffix() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.validateSuffix('InvalidSuffix');
            } catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.INVALID_SUFFIX, e.getMessage(), 'Assertion Failed');
            }
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateSuffix for null suffix
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testEmptySuffix() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.validateSuffix('');
            } catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.INVALID_SUFFIX, e.getMessage(), 'Assertion Failed');
            }
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');
            Test.stopTest();
        }
    }


    /**
    * @description : Method to test validateApplicantInfoData for null request map
    * @author Suraj Kumar | 12-18-2024 
    **/
    @isTest
    private static void testApplicantInfoDataRequestMapNull() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.validateApplicantInfoData(null, ExternalConstants.SOLE_PROP_ENTITY);
            } catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.BORROWER_DETAILS_MISSING, e.getMessage(), 'Assertion Failed');
            }
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateApplicantInfoData for invalid email
    * @author Suraj Kumar | 12-18-2024 
    **/
    @isTest
    private static void testApplicantInfoDataInvalidEmail() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        String reqString = '{ "user_id": "test00085","email": "daniel.jamesyopmail.com",  "confirm_email": "daniel.james@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }  } ';
        Map<String,Object> requestMap = (Map<String,Object>)JSON.deserializeUntyped(reqString);
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.validateApplicantInfoData(requestMap, ExternalConstants.SOLE_PROP_ENTITY);
            } catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.INVALID_EMAIL, e.getMessage(), 'Assertion Failed');
            }
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateApplicantInfoData for invalid phone
    * @author Suraj Kumar | 12-18-2024 
    **/
    @isTest
    private static void testApplicantInfoDataInvalidPhone() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        String reqString = '{ "user_id": "test00085","email": "daniel.james@yopmail.com",  "confirm_email": "daniel.james@yopmail.com",   "phone_number": "73546378431",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }  } ';
        Map<String,Object> requestMap = (Map<String,Object>)JSON.deserializeUntyped(reqString);
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.validateApplicantInfoData(requestMap, ExternalConstants.SOLE_PROP_ENTITY);
            } catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.INVALID_PHONE_NUMBER, e.getMessage(), 'Assertion Failed');
            }
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateApplicantInfoData for user id null
    * @author Suraj Kumar | 12-18-2024 
    **/
    @isTest
    private static void testApplicantInfoDataUserIdNull() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        String reqString = '{ "user_id": "","email": "daniel.james@yopmail.com",  "confirm_email": "daniel.james@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }  } ';
        Map<String,Object> requestMap = (Map<String,Object>)JSON.deserializeUntyped(reqString);
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.validateApplicantInfoData(requestMap, ExternalConstants.SOLE_PROP_ENTITY);
            } catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.USER_ID_MISSING, e.getMessage(), 'Assertion Failed');
            }
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateApplicantInfoData for invalid total asset
    * @author Suraj Kumar | 12-18-2024 
    **/
    @isTest
    private static void testApplicantInfoDataTotalAssetInvalid() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        String reqString = '{ "user_id": "test00085","email": "daniel.james@yopmail.com",  "confirm_email": "daniel.james@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": -1000000, "total_liabilities": 90000 }  } ';
        Map<String,Object> requestMap = (Map<String,Object>)JSON.deserializeUntyped(reqString);
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.validateApplicantInfoData(requestMap, ExternalConstants.SOLE_PROP_ENTITY);
            } catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.TOTAL_ASSETS_MISSING, e.getMessage(), 'Assertion Failed');
            }
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateApplicantInfoData for invalid total libalities
    * @author Suraj Kumar | 12-18-2024 
    **/
    @isTest
    private static void testApplicantInfoDataTotalLibalitiesInvalid() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        String reqString = '{ "user_id": "test00085","email": "daniel.james@yopmail.com",  "confirm_email": "daniel.james@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": -90000 }  } ';
        Map<String,Object> requestMap = (Map<String,Object>)JSON.deserializeUntyped(reqString);
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.validateApplicantInfoData(requestMap, ExternalConstants.SOLE_PROP_ENTITY);
            } catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.TOTAL_LIABILITIES_MISSING, e.getMessage(), 'Assertion Failed');
            }
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateApplicantInfoData for postal code missing
    * @author Suraj Kumar | 12-18-2024 
    **/
    @isTest
    private static void testApplicantInfoDataPostalCodeMissing() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        String reqString = '{ "user_id": "test00085","email": "daniel.james@yopmail.com",  "confirm_email": "daniel.james@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }  } ';
        Map<String,Object> requestMap = (Map<String,Object>)JSON.deserializeUntyped(reqString);
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.validateApplicantInfoData(requestMap, ExternalConstants.SOLE_PROP_ENTITY);
            } catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.POSTAL_CODE_MISSING, e.getMessage(), 'Assertion Failed');
            }
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateApplicantInfoData for postal code invalid
    * @author Suraj Kumar | 12-18-2024 
    **/
    @isTest
    private static void testApplicantInfoDataPostalCodeInvalid() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        String reqString = '{ "user_id": "test00085","email": "daniel.james@yopmail.com",  "confirm_email": "daniel.james@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "100369", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }  } ';
        Map<String,Object> requestMap = (Map<String,Object>)JSON.deserializeUntyped(reqString);
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.validateApplicantInfoData(requestMap, ExternalConstants.SOLE_PROP_ENTITY);
            } catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.POSTAL_CODE_INVALID, e.getMessage(), 'Assertion Failed');
            }
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateApplicantInfoData for state missing
    * @author Suraj Kumar | 12-18-2024 
    **/
    @isTest
    private static void testApplicantInfoDataStateMissing() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        String reqString = '{ "user_id": "test00085","email": "daniel.james@yopmail.com",  "confirm_email": "daniel.james@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }  } ';
        Map<String,Object> requestMap = (Map<String,Object>)JSON.deserializeUntyped(reqString);
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.validateApplicantInfoData(requestMap, ExternalConstants.SOLE_PROP_ENTITY);
            } catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.STATE_MISSING, e.getMessage(), 'Assertion Failed');
            }
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateApplicantInfoData for state invalid
    * @author Suraj Kumar | 12-18-2024 
    **/
    @isTest
    private static void testApplicantInfoDataStateInvalid() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        String reqString = '{ "user_id": "test00085","email": "daniel.james@yopmail.com",  "confirm_email": "daniel.james@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "ILL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }  } ';
        Map<String,Object> requestMap = (Map<String,Object>)JSON.deserializeUntyped(reqString);
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.validateApplicantInfoData(requestMap, ExternalConstants.SOLE_PROP_ENTITY);
            } catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.STATE_INVALID, e.getMessage(), 'Assertion Failed');
            }
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateApplicantInfoData for street missing
    * @author Suraj Kumar | 12-18-2024 
    **/
    @isTest
    private static void testApplicantInfoDataStreetMissing() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        String reqString = '{ "user_id": "test00085","email": "daniel.james@yopmail.com",  "confirm_email": "daniel.james@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }  } ';
        Map<String,Object> requestMap = (Map<String,Object>)JSON.deserializeUntyped(reqString);
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.validateApplicantInfoData(requestMap, ExternalConstants.SOLE_PROP_ENTITY);
            } catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.STREET_MISSING, e.getMessage(), 'Assertion Failed');
            }
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test validateApplicantInfoData for city missing
    * @author Suraj Kumar | 12-18-2024 
    **/
    @isTest
    private static void testApplicantInfoDataCityMissing() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        String reqString = '{ "user_id": "test00085","email": "daniel.james@yopmail.com",  "confirm_email": "daniel.james@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }  } ';
        Map<String,Object> requestMap = (Map<String,Object>)JSON.deserializeUntyped(reqString);
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.validateApplicantInfoData(requestMap, ExternalConstants.SOLE_PROP_ENTITY);
            } catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.CITY_MISSING, e.getMessage(), 'Assertion Failed');
            }
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateApplicantInfoData for County missing
    * @author Suraj Kumar | 12-18-2024 
    **/
    @isTest
    private static void testApplicantInfoDataCountyMissing() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        String reqString = '{ "user_id": "test00085","email": "daniel.james@yopmail.com",  "confirm_email": "daniel.james@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "total_assets": 1000000, "total_liabilities": 90000 }  } ';
        Map<String,Object> requestMap = (Map<String,Object>)JSON.deserializeUntyped(reqString);
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.validateApplicantInfoData(requestMap, ExternalConstants.SOLE_PROP_ENTITY);
            } catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.COUNTY_MISSING, e.getMessage(), 'Assertion Failed');
            }
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateApplicantInfoData for birthdate missing
    * @author Suraj Kumar | 12-18-2024 
    **/
    @isTest
    private static void testApplicantInfoDataBirthdateMissing() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        String reqString = '{ "user_id": "test00085","email": "daniel.james@yopmail.com",  "confirm_email": "daniel.james@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }  } ';
        Map<String,Object> requestMap = (Map<String,Object>)JSON.deserializeUntyped(reqString);
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.validateApplicantInfoData(requestMap, ExternalConstants.SOLE_PROP_ENTITY);
            } catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.BIRTHDATE_MISSING, e.getMessage(), 'Assertion Failed');
            }
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateApplicantInfoData for birthdate invalid
    * @author Suraj Kumar | 12-18-2024 
    **/
    @isTest
    private static void testApplicantInfoDataBirthdateInvalid() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        String reqString = '{ "user_id": "test00085","email": "daniel.james@yopmail.com",  "confirm_email": "daniel.james@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-189", "marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }  } ';
        Map<String,Object> requestMap = (Map<String,Object>)JSON.deserializeUntyped(reqString);
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.validateApplicantInfoData(requestMap, ExternalConstants.SOLE_PROP_ENTITY);
            } catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.INVALID_BIRTHDATE, e.getMessage(), 'Assertion Failed');
            }
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateApplicantInfoData for marital status missing
    * @author Suraj Kumar | 12-18-2024 
    **/
    @isTest
    private static void testApplicantInfoDataMaritalStatusMissing() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        String reqString = '{ "user_id": "test00085","email": "daniel.james@yopmail.com",  "confirm_email": "daniel.james@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }  } ';
        Map<String,Object> requestMap = (Map<String,Object>)JSON.deserializeUntyped(reqString);
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.validateApplicantInfoData(requestMap, ExternalConstants.SOLE_PROP_ENTITY);
            } catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.MARITAL_STATUS_MISSING, e.getMessage(), 'Assertion Failed');
            }
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateApplicantInfoData for marital status invalid
    * @author Suraj Kumar | 12-18-2024 
    **/
    @isTest
    private static void testApplicantInfoDataMaritalStatusInvalid() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        String reqString = '{ "user_id": "test00085","email": "daniel.james@yopmail.com",  "confirm_email": "daniel.james@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "marital_status": "Unmarrieddd", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }  } ';
        Map<String,Object> requestMap = (Map<String,Object>)JSON.deserializeUntyped(reqString);
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.validateApplicantInfoData(requestMap, ExternalConstants.SOLE_PROP_ENTITY);
            } catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.INVALID_MARITAL_STATUS, e.getMessage(), 'Assertion Failed');
            }
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateApplicantInfoData for suffix invalid
    * @author Suraj Kumar | 12-18-2024 
    **/
    @isTest
    private static void testApplicantInfoDataSuffixInvalid() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        String reqString = '{ "user_id": "test00085","email": "daniel.james@yopmail.com",  "confirm_email": "daniel.james@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "marital_status": "Unmarried", "suffix": "Srrr", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }  } ';
        Map<String,Object> requestMap = (Map<String,Object>)JSON.deserializeUntyped(reqString);
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.validateApplicantInfoData(requestMap, ExternalConstants.SOLE_PROP_ENTITY);
            } catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.INVALID_SUFFIX, e.getMessage(), 'Assertion Failed');
            }
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateApplicantInfoData for State of incorporation missing for corporation
    * @author Suraj Kumar | 12-18-2024 
    **/
    @isTest
    private static void testApplicantInfoDataSOIMissing() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        String reqString = '{ "user_id": "test00085", "street": "650 Capitol Mall",  "city": "Kansas",  "state": "IL",  "postal_code": "78364",  "county": "New York",  "email": "daniel.james@yopmail.com",  "confirm_email": "daniel.james@yopmail.com", "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "total_assets": 1000000, "total_liabilities": 90000 } } ';
        Map<String,Object> requestMap = (Map<String,Object>)JSON.deserializeUntyped(reqString);
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.validateApplicantInfoData(requestMap, ExternalConstants.CORPORATION);
            } catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.SOI_MISSING, e.getMessage(), 'Assertion Failed');
            }
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateApplicantInfoData for State of incorporation invalid for corporation
    * @author Suraj Kumar | 12-18-2024 
    **/
    @isTest
    private static void testApplicantInfoDataSOIInvalid() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        String reqString = '{ "user_id": "test00085", "street": "650 Capitol Mall",  "city": "Kansas",  "state": "IL",  "postal_code": "78364",  "county": "New York",  "email": "daniel.james@yopmail.com",  "confirm_email": "daniel.james@yopmail.com", "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "state_of_incorporation": "AZZZ", "total_assets": 1000000, "total_liabilities": 90000 } } ';
        Map<String,Object> requestMap = (Map<String,Object>)JSON.deserializeUntyped(reqString);
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.validateApplicantInfoData(requestMap, ExternalConstants.CORPORATION);
            } catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.INVALID_STATE_INCORPORATION, e.getMessage(), 'Assertion Failed');
            }
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateApplicantInfoData for sole prop success
    * @author Suraj Kumar | 12-18-2024 
    **/
    @isTest
    private static void testApplicantInfoDataSoleProp() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        String reqString = '{ "user_id": "test00085","email": "daniel.james@yopmail.com",  "confirm_email": "daniel.james@yopmail.com",   "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "birthdate": "1999-08-18", "marital_status": "Unmarried", "suffix": "Sr.", "middle_name": "H.", "street": "256 Walls Street", "city": "Kansas", "state": "IL", "postal_code": "10036", "county": "New York County", "total_assets": 1000000, "total_liabilities": 90000 }  } ';
        Map<String,Object> requestMap = (Map<String,Object>)JSON.deserializeUntyped(reqString);
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.validateApplicantInfoData(requestMap, ExternalConstants.SOLE_PROP_ENTITY);
            } catch (CustomException e) {
                isExpectionThrown = true;
            }
            System.assertEquals(false, isExpectionThrown, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateApplicantInfoData for Corporation success
    * @author Suraj Kumar | 12-18-2024 
    **/
    @isTest
    private static void testApplicantInfoDataCorporation() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        String reqString = '{ "user_id": "test00085", "street": "650 Capitol Mall",  "city": "Kansas",  "state": "IL",  "postal_code": "78364",  "county": "New York",  "email": "daniel.james@yopmail.com",  "confirm_email": "daniel.james@yopmail.com", "phone_number": "7354637843",  "home_phone_number": "9984637475",  "work_phone_number": "9364527364", "state_of_incorporation": "AZ", "total_assets": 1000000, "total_liabilities": 90000 } } ';
        Map<String,Object> requestMap = (Map<String,Object>)JSON.deserializeUntyped(reqString);
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.validateApplicantInfoData(requestMap, ExternalConstants.CORPORATION);
            } catch (CustomException e) {
                isExpectionThrown = true;
            }
            System.assertEquals(false, isExpectionThrown, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateApplicantContactInfo
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testValidateApplicantContactInfo() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.validateApplicantContactInfo(new Contact(Email = 'test@yopmail.com', MobilePhone = '1234567890'));
            } catch (CustomException e) {
                isExpectionThrown = true;
            }
            System.assertEquals(false, isExpectionThrown, 'Assertion Failed');
            Test.stopTest();
        }                    
    }

    /**
    * @description : Method to test validateApplicantContactInfo for null email
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testValidateApplicantContactInfoNoEmail() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        Contact contactObj=new Contact();
        contactObj.LastName='Albon';
        contactObj.Phone='1234567890';
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.validateApplicantContactInfo(contactObj);
            } catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.EMAIL_FIELD_MISSING, e.getMessage(),'Assertion Failed');
            }
            System.assertEquals(false, isExpectionThrown, 'Assertion Failed');
            Test.stopTest();
        }                    
    }

    /**
    * @description : Method to test validateApplicantContactInfo for null phone
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testValidateApplicantContactInfoNoPhone() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationValidationUtil.validateApplicantContactInfo(new Contact(Email = 'test@yopmail.com'));
            } catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.CONTACT_NUMBER_MISSING, e.getMessage(),'Assertion Failed');
            }  
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');          
            Test.stopTest();
        }                    
    }

    /**
    * @description : Method to test validateDealerDetails for valid dealer details
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testValidateDealerDetails() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Map<String,Object> dealerDetailsMap = getDealerDetailsMap();
        System.runAs(userList[0]){
            Test.startTest();
            Account dealerAcc = ExternalApplicationValidationUtil.validateDealerDetails(dealerDetailsMap);
            System.assertEquals('102555', dealerAcc.CIF_Number__c,'Assertion Failed');          
            Test.stopTest();
        }                    
    }

    /**
    * @description : Method to test validateDealerDetails for invalid dealer token
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testValidateDealerTokenInvalid() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        Map<String,Object> dealerDetailsMap = new Map<String,Object>{
            ExternalConstants.DEALER_CIF_KEY => '102555',
            ExternalConstants.DEALER_TOKEN_KEY => 'testd'
        };
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalApplicationValidationUtil.validateDealerDetails(dealerDetailsMap);  
            }catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.DEALER_TOKEN_INVALID, e.getMessage(),'Assertion Failed');
            }        
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');          
            Test.stopTest();
        }                    
    }

    /**
    * @description : Method to test validateDealerDetails for dealer cif missing
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testValidateDealerCifMissing() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        Map<String,Object> dealerDetailsMap = new Map<String,Object>{
            ExternalConstants.DEALER_TOKEN_KEY => 'testd'
        };
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalApplicationValidationUtil.validateDealerDetails(dealerDetailsMap);  
            }catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.DEALER_CIF_MISSING, e.getMessage(),'Assertion Failed');
            }        
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');          
            Test.stopTest();
        }                    
    }

    /**
    * @description : Method to test validateDealerDetails for dealer cif Blank
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testValidateDealerCifBlank() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        Map<String,Object> dealerDetailsMap = new Map<String,Object>{
            ExternalConstants.DEALER_CIF_KEY => '',
            ExternalConstants.DEALER_TOKEN_KEY => 'testd'
        };
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalApplicationValidationUtil.validateDealerDetails(dealerDetailsMap);  
            }catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.DEALER_CIF_MISSING, e.getMessage(),'Assertion Failed');
            }        
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');          
            Test.stopTest();
        }                    
    }

    /**
    * @description : Method to test validateDealerDetails for dealer cif invalid
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testValidateDealerCifInvalid() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        Map<String,Object> dealerDetailsMap = new Map<String,Object>{                                               
            ExternalConstants.DEALER_CIF_KEY => '123456',
            ExternalConstants.DEALER_TOKEN_KEY => 'testd'
        };                                         
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalApplicationValidationUtil.validateDealerDetails(dealerDetailsMap);  
            }catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.DEALER_CIF_INVALID, e.getMessage(),'Assertion Failed');
            }        
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');          
            Test.stopTest();
        }                    
    }

    /**
    * @description : Method to test validateDealerDetails for dealer token Blank
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testValidateDealerTokenBlank() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        Map<String,Object> dealerDetailsMap = new Map<String,Object>{
            ExternalConstants.DEALER_CIF_KEY => '102555',
            ExternalConstants.DEALER_TOKEN_KEY => ''
        };
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalApplicationValidationUtil.validateDealerDetails(dealerDetailsMap);  
            }catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.DEALER_TOKEN_MISSING, e.getMessage(),'Assertion Failed');
            }        
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');          
            Test.stopTest();
        }                    
    }

    /**
    * @description : Method to test validateDealerDetails for dealer token Missing
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testValidateDealerTokenMissing() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        Map<String,Object> dealerDetailsMap = new Map<String,Object>{
            ExternalConstants.DEALER_CIF_KEY => '102555'
        };
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalApplicationValidationUtil.validateDealerDetails(dealerDetailsMap);  
            }catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.DEALER_TOKEN_MISSING, e.getMessage(),'Assertion Failed');
            }        
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');          
            Test.stopTest();
        }                    
    }


    /**
    * @description : Method to test validateTotalAssets for null total assets
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testValidateTotalAssetsNull() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalApplicationValidationUtil.validateTotalAssets(null);  
            }catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.TOTAL_ASSETS_MISSING, e.getMessage(),'Assertion Failed');
            }        
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');          
            Test.stopTest();
        }                    
    }

    /**
    * @description : Method to test validateTotalAssets for negative total assets
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testValidateTotalAssetsNegative() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalApplicationValidationUtil.validateTotalAssets(-100);  
            }catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.TOTAL_ASSETS_MISSING, e.getMessage(),'Assertion Failed');
            }        
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');          
            Test.stopTest();
        }                    
    }

    /**
    * @description : Method to test validateTotalAssets for valid total asset
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testValidateTotalAssetsPositive() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalApplicationValidationUtil.validateTotalAssets(100);  
            }catch (CustomException e) {
                isExpectionThrown = true;
            }        
            System.assertEquals(false, isExpectionThrown, 'Assertion Failed');          
            Test.stopTest();
        }                    
    }

    /**
    * @description : Method to test validateTotalLiabilities for null total libalities
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testValidateTotalLiabilitiesNull() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalApplicationValidationUtil.validateTotalLiabilities(null);  
            }catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.TOTAL_LIABILITIES_MISSING, e.getMessage(),'Assertion Failed');
            }        
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');          
            Test.stopTest();
        }                    
    }

    /**
    * @description : Method to test validateTotalLiabilities for negative total libalities
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testValidateTotalLiabilitiesNegative() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalApplicationValidationUtil.validateTotalLiabilities(-100);  
            }catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.TOTAL_LIABILITIES_MISSING, e.getMessage(),'Assertion Failed');
            }        
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');          
            Test.stopTest();
        }                    
    }

    /**
    * @description : Method to test validateTotalLiabilities for valid total libalities
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testValidateTotalLiabilitiesPositive() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalApplicationValidationUtil.validateTotalLiabilities(100);  
            }catch (CustomException e) {
                isExpectionThrown = true;
            }        
            System.assertEquals(false, isExpectionThrown, 'Assertion Failed');          
            Test.stopTest();
        }                    
    }

    /**
    * @description : Method to test validateTitle for title missing
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testValidateTitleForTitleMissing() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalApplicationValidationUtil.validateTitle('',ExternalConstants.CORPORATION);  
            }catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.TITLE_MISSING, e.getMessage(),'Assertion Failed');
            }        
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');          
            Test.stopTest();
        }                    
    }

    /**
    * @description : Method to test validateTitle for invalid title corporation
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testValidateTitleInvalidCorporation() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalApplicationValidationUtil.validateTitle('Invalid',ExternalConstants.CORPORATION);  
            }catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.INVALID_TITLE, e.getMessage(),'Assertion Failed');
            }        
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');          
            Test.stopTest();
        }                    
    }

    /**
    * @description : Method to test validateTitle for valid title corporation
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testValidateTitleValidCorporation() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalApplicationValidationUtil.validateTitle(ExternalConstants.PRESIDENT,ExternalConstants.CORPORATION);  
            }catch (CustomException e) {
                isExpectionThrown = true;
            }        
            System.assertEquals(false, isExpectionThrown, 'Assertion Failed');          
            Test.stopTest();
        }                    
    }

    /**
    * @description : Method to test validateTitle for invalid title general partnership
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testValidateTitleInvalidGP() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalApplicationValidationUtil.validateTitle('Invalid',ExternalConstants.GENERAL_PARTNERSHIP);  
            }catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.INVALID_TITLE, e.getMessage(),'Assertion Failed');
            }        
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');          
            Test.stopTest();
        }                    
    }

    /**
    * @description : Method to test validateTitle for valid title general partnership
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testValidateTitleValidGP() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalApplicationValidationUtil.validateTitle(ExternalConstants.PARTNER,ExternalConstants.GENERAL_PARTNERSHIP);  
            }catch (CustomException e) {
                isExpectionThrown = true;
            }        
            System.assertEquals(false, isExpectionThrown, 'Assertion Failed');          
            Test.stopTest();
        }                    
    }

    /**
    * @description : Method to test validateTitle for invalid title, limited partnership
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testValidateTitleInvalidLP() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalApplicationValidationUtil.validateTitle('Invalid',ExternalConstants.LIMITED_PARTNERSHIP);  
            }catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.INVALID_TITLE, e.getMessage(),'Assertion Failed');
            }        
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');          
            Test.stopTest();
        }                    
    }

    /**
    * @description : Method to test validateTitle for valid title, limited partnership
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testValidateTitleValidLP() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalApplicationValidationUtil.validateTitle(ExternalConstants.PARTNER,ExternalConstants.LIMITED_PARTNERSHIP);  
            }catch (CustomException e) {
                isExpectionThrown = true;
            }        
            System.assertEquals(false, isExpectionThrown, 'Assertion Failed');          
            Test.stopTest();
        }                    
    }

     /**
    * @description : Method to test validateTitle for invalid title, Joint Ventures
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testValidateTitleInvalidJV() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalApplicationValidationUtil.validateTitle('Invalid',ExternalConstants.JOINT_VENTURE);  
            }catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.INVALID_TITLE, e.getMessage(),'Assertion Failed');
            }        
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');          
            Test.stopTest();
        }                    
    }

    /**
    * @description : Method to test validateTitle for valid title, Joint Ventures
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testValidateTitleValidJV() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalApplicationValidationUtil.validateTitle(ExternalConstants.MEMBER,ExternalConstants.JOINT_VENTURE);  
            }catch (CustomException e) {
                isExpectionThrown = true;
            }        
            System.assertEquals(false, isExpectionThrown, 'Assertion Failed');          
            Test.stopTest();
        }                    
    }

    /**
    * @description : Method to test validateTitle for invalid title, LLC
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testValidateTitleInvalidLLC() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalApplicationValidationUtil.validateTitle('Invalid',ExternalConstants.LIMITED_LIABILITY_COMPANY);  
            }catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.INVALID_TITLE, e.getMessage(),'Assertion Failed');
            }        
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');          
            Test.stopTest();
        }                    
    }

    /**
    * @description : Method to test validateTitle for valid title, LLC
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testValidateTitleValidLLC() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalApplicationValidationUtil.validateTitle(ExternalConstants.MANAGER,ExternalConstants.LIMITED_LIABILITY_COMPANY);  
            }catch (CustomException e) {
                isExpectionThrown = true;
            }        
            System.assertEquals(false, isExpectionThrown, 'Assertion Failed');          
            Test.stopTest();
        }                    
    }

    /**
    * @description : Method to test validateTitle for invalid title, Trust
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testValidateTitleInvalidTrust() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalApplicationValidationUtil.validateTitle('Invalid',ExternalConstants.TRUST);  
            }catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.INVALID_TITLE, e.getMessage(),'Assertion Failed');
            }        
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');          
            Test.stopTest();
        }                    
    }

    /**
    * @description : Method to test validateTitle for valid title, Trust
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testValidateTitleValidTrust() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalApplicationValidationUtil.validateTitle(ExternalConstants.TRUSTEE,ExternalConstants.TRUST);  
            }catch (CustomException e) {
                isExpectionThrown = true;
            }        
            System.assertEquals(false, isExpectionThrown, 'Assertion Failed');          
            Test.stopTest();
        }                    
    }

    /**
    * @description : Method to test validateTitle for invalid title, sole prop
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testValidateTitleInvalidSoleProp() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalApplicationValidationUtil.validateTitle('Invalid',ExternalConstants.SOLE_PROP_ENTITY);  
            }catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.INVALID_TITLE, e.getMessage(),'Assertion Failed');
            }        
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');          
            Test.stopTest();
        }                    
    }

    /**
    * @description : Method to test validateTitle for valid title, sole prop
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testValidateTitleValidSoleProp() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalApplicationValidationUtil.validateTitle(ExternalConstants.CO_APPLICANT,ExternalConstants.SOLE_PROP_ENTITY);  
            }catch (CustomException e) {
                isExpectionThrown = true;
            }        
            System.assertEquals(false, isExpectionThrown, 'Assertion Failed');          
            Test.stopTest();
        }                    
    }

    /**
    * @description : Method to test validateTitle for invalid title, DBA
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testValidateTitleInvalidDBA() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalApplicationValidationUtil.validateTitle('Invalid',ExternalConstants.INDIVIDUAL_ENTITY);  
            }catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.INVALID_TITLE, e.getMessage(),'Assertion Failed');
            }        
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');          
            Test.stopTest();
        }                    
    }

    /**
    * @description : Method to test validateTitle for valid title, DBA
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testValidateTitleValidDBA() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalApplicationValidationUtil.validateTitle(ExternalConstants.CO_APPLICANT,ExternalConstants.INDIVIDUAL_ENTITY);  
            }catch (CustomException e) {
                isExpectionThrown = true;
            }        
            System.assertEquals(false, isExpectionThrown, 'Assertion Failed');          
            Test.stopTest();
        }                    
    }

    /**
    * @description : Method to test validatePartyContactInfo for email missing
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testValidatePartyContactInfoEmailMissing() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        Contact contactObj=new Contact();
        contactObj.LastName='albon';
        contactObj.Phone='1234567890';

        clcommon__party__c partyObj=new clcommon__party__c();
        partyObj.Mobile_Number__c='1234567890';
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalApplicationValidationUtil.validatePartyContactInfo(contactObj,partyObj );  
            }catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.EMAIL_FIELD_MISSING, e.getMessage(),'Assertion Failed');
            }        
            System.assertEquals(false, isExpectionThrown, 'Assertion Failed');          
            Test.stopTest();
        }                    
    }

    /**
    * @description : Method to test validatePartyContactInfo for mobile phone missing missing
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testValidatePartyContactInfoPhoneMissing() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalApplicationValidationUtil.validatePartyContactInfo(new Contact(Email = 'test@yopmail.com'), new clcommon__party__c());  
            }catch (CustomException e) {
                isExpectionThrown = true;
                System.assertEquals(ExternalConstants.CONTACT_NUMBER_MISSING, e.getMessage(),'Assertion Failed');
            }        
            System.assertEquals(true, isExpectionThrown, 'Assertion Failed');          
            Test.stopTest();
        }                    
    }

    /**
    * @description : Method to test validatePartyContactInfo for Success
    * @author Suraj Kumar | 12-17-2024 
    **/
    @isTest
    private static void testValidatePartyContact() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExpectionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalApplicationValidationUtil.validatePartyContactInfo(new Contact(Email = 'test@yopmail.com'), new clcommon__party__c(Mobile_Number__c = '1234567890'));  
            }catch (CustomException e) {
                isExpectionThrown = true;
            }        
            System.assertEquals(false, isExpectionThrown, 'Assertion Failed');          
            Test.stopTest();
        }                    
    }

    /**
    * @description test method to test validateSSNOfPrincipal
    * @author Rakesh Saraf | 03-19-2025 
    **/
    @isTest
    private static void testValidateSSNOfPrincipal(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Map<String,Object> paramMap=new Map<String,Object>{
            'ssn'=>123123123,
            'confirm_ssn'=>123123123
        };
        System.runAs(userList[0]){
            Test.startTest();
            // try{
            String ssn=ExternalApplicationValidationUtil.validateSSNOfPrincipal(paramMap);  
            // }catch (CustomException e) {
            //     isExpectionThrown = true;
            // }        
            System.assertEquals('123123123', ssn, 'Assertion Failed');          
            Test.stopTest();
        } 
    }
}