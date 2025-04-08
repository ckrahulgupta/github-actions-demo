/**
 * @description       : Test class for ExternalValidationUtil
 * @author            : Krishanu Chinya
 * @group             : 
 * @last modified on  : 03-19-2025
 * @last modified by  : Rakesh Saraf
**/
@IsTest
public with sharing class ExternalValidationUtilTest {
    /**
    * @description : setup method to create test data
    * @author Suraj Kumar | 12-27-2024 
    **/
    @testSetup
    static void setup(){
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

        // Creating Business Information
        genesis__Business_Information__c dealerBusinessInfoObj = ExternalAPITestHelper.createBusinessInfoForDealer();
        genesis__Business_Information__c borrowerBusinessInfoObj = ExternalAPITestHelper.createBusinessInfoForBorrower();
        borrowerBusinessInfoObj.genesis__Tax_Identification_Number__c = '6354637';

        Database.insert(new List<genesis__Business_Information__c>{dealerBusinessInfoObj,borrowerBusinessInfoObj},true);

        List<clcommon__Legal_Entity__c> solePropEntityList = [SELECT Id, Name FROM clcommon__Legal_Entity__c WHERE Name = :ExternalConstants.SOLE_PROP_ENTITY];

        // Creating Account for Dealer
        Account dealerAccountObj = ExternalAPITestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        dealerAccountObj.CIF_Number__c = '102555';
        dealerAccountObj.Enable_ERP_Id__c = true;
        dealerAccountObj.Unique_Id__c = 'testd001';
        Database.insert(dealerAccountObj, true);

        // Creating Account for Certified Lender
        Account clAccountObj = ExternalAPITestHelper.createCLAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
        // Creating Account for Borrower
        Account borrowerAccountObj = ExternalAPITestHelper.createSolePropAccount(solePropEntityList[0], borrowerBusinessInfoObj.Id);
        borrowerAccountObj.Unique_Id__c = 'testUniqueId';
        Database.insert(new List<Account>{clAccountObj,borrowerAccountObj}, true);

         // Creating Contact
        Contact clContactObj = ExternalAPITestHelper.createCLContact(clAccountObj.Id);
        Contact borrowerContactObj = ExternalAPITestHelper.createBorrowerContact(borrowerAccountObj.Id);
        borrowerContactObj.genesis__SSN__c = '786354624';
        
        Database.insert(new List<Contact>{clContactObj,borrowerContactObj},true);

        Dealer_Applicant_Relationship__c borrowerDealerRelObj = ExternalAPITestHelper.createApplicantDealerRelationship(borrowerAccountObj, borrowerContactObj, dealerAccountObj);
        Database.insert(borrowerDealerRelObj,true);

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
        applicationObj.Dealer_Applicant_Relationship__c = borrowerDealerRelObj.Id;
        Database.insert(applicationObj, true);

        // Creating Reciprocal Role 
        clcommon__Reciprocal_Role__c roleObj = ExternalAPITestHelper.createCertifiedLenderRole();
        Database.insert(roleObj, true);

        // Creating Relationship between Dealer and Certified Lender
        clcommon__Relationship__c clDealerRelationshipObj = ExternalAPITestHelper.createCLDealerRelationship(roleObj,dealerAccountObj.Id,clAccountObj.Id);
        Database.insert(clDealerRelationshipObj, true);

        clcommon__Party_Type__c borrowerPartyTypeObj = ExternalAPITestHelper.createPartyType('BORROWER');
        Database.insert(borrowerPartyTypeObj,true);
         // Creating borrower Party for current application
         Map<String,Id> paramForborrowerPartyMap = new Map<String,Id>{
            'accountId' => borrowerAccountObj.Id,
            'contactId' => borrowerContactObj.Id,
            'partyTypeId' => borrowerPartyTypeObj.Id,
            'applicationId' => applicationObj.Id,
            'dealerApplicantRelId' => borrowerDealerRelObj.Id
        };

        clcommon__Party__c borrowerPartyObj = ExternalAPITestHelper.createApplicantParty(paramForborrowerPartyMap);
        Database.insert(borrowerPartyObj,true);
    }

    /**
    * @description : Method to get Borrower Account
    * @author Suraj Kumar | 01-09-2025 
    * @return Account 
    **/
    private static Account getBorrowerAccount(){
        List<Account> accountList = [SELECT Id, 
                                            Coop_Type__c,
                                            clcommon__Legal_Entity_Type__c
                                        FROM Account 
                                        WHERE Unique_Id__c = 'testUniqueId'];
        return accountList[0];
    }

    /**
    * @description : Method to get corporation legal entity
    * @author Suraj Kumar | 01-09-2025 
    * @return clcommon__Legal_Entity__c 
    **/
    private static clcommon__Legal_Entity__c getCorporationEntity(){
        List<clcommon__Legal_Entity__c> corpEntityList = [SELECT Id, 
                                                                    Name 
                                                                FROM clcommon__Legal_Entity__c
                                                                WHERE Name = :ExternalConstants.CORPORATION];
        return corpEntityList[0];
    }
    /**
    * @description : Method to get applications
    * @author Suraj Kumar | 01-10-2025 
    * @return List<genesis__Applications__c> 
    **/
    private static List<genesis__Applications__c> getApplication(){
        List<genesis__Applications__c> applicationList = [SELECT Id
                                                                FROM genesis__Applications__c 
                                                                WHERE genesis__Loan_Number__c = '300023456'
                                                                LIMIT 1];
        return applicationList;
    }
    /**
    * @description : Method to get validateDuplicateIndividual for existing SSN in Growmark
    * @author Suraj Kumar | 12-26-2024 
    **/
    @isTest
    private static void testValidateDuplicateIndividualGMK() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Account accountObj = getBorrowerAccount();
        accountObj.Coop_Type__c = 'Growmark';
        Database.update(accountObj, true);
        System.runAs(userList[0]){
            Test.startTest();
            Map<String, Object> duplicateMap = ExternalValidationUtil.validateDuplicateIndividual( '786354624');
            System.assertEquals(true, duplicateMap.get('duplicateFound'), 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to get validateDuplicateIndividual for existing SSN in GL
    * @author Suraj Kumar | 12-26-2024 
    **/
    @isTest
    private static void testvalidateDuplicateIndividualGL() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Account accountObj = getBorrowerAccount();
        accountObj.Coop_Type__c = 'CFA';
        Database.update(accountObj, true);
        System.runAs(userList[0]){
            Test.startTest();
            Map<String, Object> duplicateMap = ExternalValidationUtil.validateDuplicateIndividual( '786354624');
            System.assertEquals(true, duplicateMap.get('duplicateFound'), 'Assertion Failed');
            Test.stopTest();
        }
    }

     /**
    * @description : Method to get validateDuplicateIndividual for balnk ssn
    * @author Suraj Kumar | 12-26-2024 
    **/
    @isTest
    private static void testvalidateDuplicateIndividualNullSSN() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        System.runAs(userList[0]){
            Test.startTest();
            Map<String, Object> duplicateMap = ExternalValidationUtil.validateDuplicateIndividual('');
            System.assertEquals(false, duplicateMap.get('duplicateFound'), 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to get validateDuplicateIndividual for New ssn
    * @author Suraj Kumar | 12-26-2024 
    **/
    @isTest
    private static void testvalidateDuplicateIndividualNewlSSN() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        System.runAs(userList[0]){
            Test.startTest();
            Map<String, Object> duplicateMap = ExternalValidationUtil.validateDuplicateIndividual('123123123');
            System.assertEquals(false, duplicateMap.get('duplicateFound'), 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method validateDuplicateCorporation for existing tax id in gmk
    * @author Suraj Kumar | 12-27-2024 
    **/
    @isTest
    private static void testvalidateDuplicateCorporationGMK() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Account accountObj = getBorrowerAccount();
        accountObj.Coop_Type__c = 'Growmark';
        accountObj.clcommon__Legal_Entity_Type__c = getCorporationEntity().Id;
        Database.update(accountObj, true);
        System.runAs(userList[0]){
            Test.startTest();
            Map<String, Object> duplicateMap = ExternalValidationUtil.validateDuplicateCorporation( '6354637',getCorporationEntity().Id);
            System.assertEquals(true, duplicateMap.get('duplicateFound'), 'Assertion Failed');
            Test.stopTest();
        }
    }

     /**
    * @description : Method validateDuplicateCorporation for existing tax id in GL
    * @author Suraj Kumar | 12-27-2024 
    **/
    @isTest
    private static void testvalidateDuplicateCorporationGL() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Account accountObj = getBorrowerAccount();
        accountObj.Coop_Type__c = 'Landus';
        accountObj.clcommon__Legal_Entity_Type__c = getCorporationEntity().Id;
        Database.update(accountObj, true);
        System.runAs(userList[0]){
            Test.startTest();
            Map<String, Object> duplicateMap = ExternalValidationUtil.validateDuplicateCorporation( '6354637',getCorporationEntity().Id);
            System.assertEquals(true, duplicateMap.get('duplicateFound'), 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method validateDuplicateCorporation for existing tax id in different entity
    * @author Suraj Kumar | 12-27-2024 
    **/
    @isTest
    private static void testvalidateDuplicateCorporationDiffEntity() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        System.runAs(userList[0]){
            Test.startTest();
            Map<String, Object> duplicateMap = ExternalValidationUtil.validateDuplicateCorporation( '6354637',getCorporationEntity().Id);
            System.assertEquals(true, duplicateMap.get('duplicateFound'), 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method validateDuplicateCorporation for new tax id 
    * @author Suraj Kumar | 12-27-2024 
    **/
    @isTest
    private static void testvalidateDuplicateCorporationNewTaxId() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        System.runAs(userList[0]){
            Test.startTest();
            Map<String, Object> duplicateMap = ExternalValidationUtil.validateDuplicateCorporation( '6354612',getCorporationEntity().Id);
            System.assertEquals(false, duplicateMap.get('duplicateFound'), 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method validateDuplicateCorporation for blank tax id 
    * @author Suraj Kumar | 12-27-2024 
    **/
    @isTest
    private static void testvalidateDuplicateCorporationBlankTaxId() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        System.runAs(userList[0]){
            Test.startTest();
            Map<String, Object> duplicateMap = ExternalValidationUtil.validateDuplicateCorporation( '',getCorporationEntity().Id);
            System.assertEquals(false, duplicateMap.get('duplicateFound'), 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validatePhoneNum for Blank Phone number
    * @author Suraj Kumar | 12-26-2024 
    **/
    @isTest
    private static void testValidatePhoneNumBlank() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalValidationUtil.validatePhoneNum('');
            } catch (CustomException e) {
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.INVALID_PHONE_NUMBER, e.getMessage(),'Assertion Failed');
            }
            System.assertEquals(false, isExceptionThrown,'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validatePhoneNum for Invalid length
    * @author Suraj Kumar | 12-26-2024 
    **/
    @isTest
    private static void testValidatePhoneNumInvalidLength() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalValidationUtil.validatePhoneNum('123456789');
            } catch (CustomException e) {
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.INVALID_PHONE_NUMBER, e.getMessage(),'Assertion Failed');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Failed');
            Test.stopTest();
        }
    }

     /**
    * @description : Method to test validatePhoneNum for Invalid format
    * @author Suraj Kumar | 12-26-2024 
    **/
    @isTest
    private static void testValidatePhoneNumInvalidFormat() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalValidationUtil.validatePhoneNum('1234567abc');
            } catch (CustomException e) {
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.INVALID_PHONE_NUMBER, e.getMessage(),'Assertion Failed');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validatePhoneNum for valid
    * @author Suraj Kumar | 12-26-2024 
    **/
    @isTest
    private static void testValidatePhoneNumValidFormat() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalValidationUtil.validatePhoneNum('1234567890');
            } catch (CustomException e) {
                isExceptionThrown = true;
            }
            System.assertEquals(false, isExceptionThrown,'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateEmailAddress for Blank email
    * @author Suraj Kumar | 12-26-2024 
    **/
    @isTest
    private static void testBlankEmail() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalValidationUtil.validateEmailAddress('','');
            } catch (CustomException e) {
                isExceptionThrown = true;
            }
            System.assertEquals(false, isExceptionThrown,'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateEmailAddress for Invalid email
    * @author Suraj Kumar | 12-26-2024 
    **/
    @isTest
    private static void testInvalidEmail() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalValidationUtil.validateEmailAddress('invalidemail', '');
            } catch (CustomException e) {
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.INVALID_EMAIL, e.getMessage(), 'Assertion Failed');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateEmailAddress for confirm email blank
    * @author Suraj Kumar | 12-26-2024 
    **/
    @isTest
    private static void testBlankConfirmEmail() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalValidationUtil.validateEmailAddress('test@yopmail.com', '');
            } catch (CustomException e) {
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.EMAIL_CONFIRM_EMAIL_MISMATCH, e.getMessage(), 'Assertion Failed');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateEmailAddress for confirm email mismatch
    * @author Suraj Kumar | 12-26-2024 
    **/
    @isTest
    private static void testEmailConfirmEmailMismatch() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalValidationUtil.validateEmailAddress('test@yopmail.com', 'valid@yopmail.com');
            } catch (CustomException e) {
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.EMAIL_CONFIRM_EMAIL_MISMATCH, e.getMessage(), 'Assertion Failed');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateEmailAddress for valid email and confirm email
    * @author Suraj Kumar | 12-26-2024 
    **/
    @isTest
    private static void testValidEmailAndConfirmEmail() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalValidationUtil.validateEmailAddress('test@yopmail.com', 'test@yopmail.com');
            } catch (CustomException e) {
                isExceptionThrown = true;
            }
            System.assertEquals(false, isExceptionThrown,'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateSSN for blank SSN
    * @author Suraj Kumar | 12-26-2024 
    **/
    @isTest
    private static void testBlankSSN() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalValidationUtil.validateSSN('', '');
            } catch (CustomException e) {
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.SSN_MISSING, e.getMessage(), 'Assertion Failed');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Failed');
            Test.stopTest();
        }
    }

     /**
    * @description : Method to test validateSSN for Invalid SSN Length
    * @author Suraj Kumar | 12-26-2024 
    **/
    @isTest
    private static void testInvalidSSNLength() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalValidationUtil.validateSSN('12345678', '');
            } catch (CustomException e) {
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.INVALID_SSN, e.getMessage(), 'Assertion Failed');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Failed');
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test validateSSN for Confirm SSN Mismatch
    * @author Suraj Kumar | 12-26-2024 
    **/
    @isTest
    private static void testSSNConfirmSSNMismatch() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalValidationUtil.validateSSN('123456789', '987654321');
            } catch (CustomException e) {
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.SSN_CONFIRM_SSN_MISMATCH, e.getMessage(), 'Assertion Failed');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Failed');
            Test.stopTest();
        }
    }

     /**
    * @description : Method to test validateSSN for valid ssn and confirm ssn
    * @author Suraj Kumar | 12-26-2024 
    **/
    @isTest
    private static void testValidSSNAndConfirmSSN() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalValidationUtil.validateSSN('123456789', '123456789');
            } catch (CustomException e) {
                isExceptionThrown = true;
            }
            System.assertEquals(false, isExceptionThrown,'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : method to test validateTIN for blank tin
    * @author Suraj Kumar | 12-26-2024 
    **/
    @isTest
    private static void testBlankTIN() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalValidationUtil.validateTIN('', '');
            } catch (CustomException e) {
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.TIN_MISSING, e.getMessage(), 'Incorrect exception message for blank TIN.');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Failed');
            Test.stopTest();
        }
    }

     /**
    * @description : method to test validateTIN for invalid tin length
    * @author Suraj Kumar | 12-26-2024 
    **/
    @isTest
    private static void testInvalidTINLength() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalValidationUtil.validateTIN('12345678', '');
            } catch (CustomException e) {
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.INVALID_TIN, e.getMessage(), 'Incorrect exception message for invalid TIN length.');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : method to test validateTIN for tin , confirm tin mismatch
    * @author Suraj Kumar | 12-26-2024 
    **/
    @isTest
    private static void testTINConfirmTINMismatch() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalValidationUtil.validateTIN('123456789', '987654321');
            } catch (CustomException e) {
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.TIN_CONFIRM_TIN_MISMATCH, e.getMessage(), 'Incorrect exception message for TIN and confirm TIN mismatch.');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : method to test validateTIN for valid tin and confirm tin
    * @author Suraj Kumar | 12-26-2024 
    **/
    @isTest
    private static void testValidTINAndConfirmTIN() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalValidationUtil.validateTIN('123456789', '123456789');
            } catch (CustomException e) {
                isExceptionThrown = true;
            }
            System.assertEquals(false, isExceptionThrown,'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validatePostalCode for invalid length
    * @author Suraj Kumar | 12-26-2024 
    **/
    @isTest
    private static void testInvalidPostalCodeLength() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalValidationUtil.validatePostalCode('1234');
            } catch (CustomException e) {
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.POSTAL_CODE_INVALID, e.getMessage(), 'Assertion Failed');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validatePostalCode for invalid format
    * @author Suraj Kumar | 12-26-2024 
    **/
    @isTest
    private static void testInvalidPostalCodeFormat() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalValidationUtil.validatePostalCode('123ab');
            } catch (CustomException e) {
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.POSTAL_CODE_INVALID, e.getMessage(), 'Assertion Failed');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validatePostalCode for valid length 5
    * @author Suraj Kumar | 12-26-2024 
    **/
    @isTest
    private static void testValidPostalCodeLengthFive() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalValidationUtil.validatePostalCode('12345');
            } catch (CustomException e) {
                isExceptionThrown = true;
            }
            System.assertEquals(false, isExceptionThrown,'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validatePostalCode for valid length 9
    * @author Suraj Kumar | 12-26-2024 
    **/
    @isTest
    private static void testValidPostalCodeLengthNine() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalValidationUtil.validatePostalCode('123456789');
            } catch (CustomException e) {
                isExceptionThrown = true;
            }
            System.assertEquals(false, isExceptionThrown,'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateBirthDate for valid 
    * @author Suraj Kumar | 12-26-2024 
    **/
    @isTest
    private static void testValidBirthdate() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            String validBirthdate = '1999-08-18';
            try {
                ExternalValidationUtil.validateBirthDate(validBirthdate);
            } catch (CustomException e) {
                isExceptionThrown = true;
            }
            System.assertEquals(false, isExceptionThrown,'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateBirthDate for Invalid
    * @author Suraj Kumar | 12-26-2024 
    **/
    @isTest
    private static void testInvalidBirthdate() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            Date invalidBirthdate = Date.today().addYears(-17);
            try {
                ExternalValidationUtil.validateBirthDate(invalidBirthdate.format());
            } catch (CustomException e) {
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.INVALID_BIRTHDATE, e.getMessage(),'Assertion Failed');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateBirthDate for Invalid date string
    * @author Suraj Kumar | 12-26-2024  
    **/
    @isTest
    private static void testInvalidDateString() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalValidationUtil.validateBirthDate('invalid_date');
            } catch (CustomException e) {
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.INVALID_BIRTHDATE, e.getMessage(),'Assertion Failed');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Failed');
            Test.stopTest();
        }

    }

    /**
    * @description : Method to test checkLoanAmount for valid amount
    * @author Suraj Kumar | 12-26-2024 
    **/
    @isTest
    private static void testValidLoanAmount() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        System.runAs(userList[0]){
            Test.startTest();
            Boolean isValid = ExternalValidationUtil.checkLoanAmount('1000.00');
            System.assertEquals(true, isValid,'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test checkLoanAmount for Invalid amount format
    * @author Suraj Kumar | 12-26-2024 
    **/
    @isTest
    private static void testInvalidLoanAmountFormat() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        System.runAs(userList[0]){
            Test.startTest();
            Boolean isValid = ExternalValidationUtil.checkLoanAmount('One thousand');
            System.assertEquals(false, isValid,'Assertion Failed');
            Test.stopTest();
        }
    }


    /**
    * @description : Method to test validateState for valid states
    * @author Suraj Kumar | 12-26-2024 
    **/
    @isTest
    private static void testValidState() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalValidationUtil.validateState('IL');
            } catch (CustomException e) {
                isExceptionThrown = true;
            }
            System.assertEquals(false, isExceptionThrown,'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateState for Invalid states
    * @author Suraj Kumar | 12-26-2024 
    **/
    @isTest
    private static void testInvalidState() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalValidationUtil.validateState('XYZ');
            } catch (CustomException e) {
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.STATE_INVALID, e.getMessage(),'Assertion Failed');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test checkForDuplicateCoapplicant for existing party
    * @author Suraj Kumar | 12-26-2024 
    **/
    @isTest
    private static void testCheckForExistingCoapplicant() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        List<genesis__Applications__c> applicationList = getApplication();
        List<clcommon__Party__c> partyList = [SELECT Id,
                                                        clcommon__Contact__c,
                                                        clcommon__Account__r.Unique_Id__c
                                                    FROM clcommon__Party__c
                                                    WHERE genesis__Application__r.Id=:applicationList[0].Id];
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalValidationUtil.checkForDuplicateCoapplicant(new List<Id>{partyList[0].clcommon__Contact__c}, applicationList[0].Id);
            } catch (CustomException e) {
                isExceptionThrown = true;
                System.assertEquals(partyList[0].clcommon__Account__r.Unique_Id__c  + ExternalConstants.COAPPLICANT_ALREADY_ADDED, e.getMessage(),'Assertion Failed');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test checkForDuplicateCoapplicant for existing party
    * @author Suraj Kumar | 12-26-2024 
    **/
    @isTest
    private static void testCheckForNewCoapplicant() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        List<genesis__Applications__c> applicationList = getApplication();
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalValidationUtil.checkForDuplicateCoapplicant(new List<Id>{applicationList[0].id}, applicationList[0].Id);
            } catch (CustomException e) {
                isExceptionThrown = true;
            }
            System.assertEquals(false, isExceptionThrown,'Assertion Failed');
            Test.stopTest();
        }
    }
    
    /**
    * @description : Method to test validateAppForScoring with no signing method
    * @author Krishanu Chinya | 03-01-2025 
    **/
    @isTest
    public static void testScoringWithNoSigningMethod() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        List<genesis__Applications__c> applicationList = getApplication();
        applicationList[0].signing_method__c = '';
        applicationList[0].genesis__Status__c = 'ACTIVE';
        Database.update(applicationList, true);
        
        System.runAs(userList[0]){
            try {
                Test.startTest();
                ExternalValidationUtil.validateAppForScoring(applicationList[0]);
                Test.stopTest();
            } catch (CustomException e) {
                System.assertEquals(ExternalConstants.NO_SIGNING_METHOD, e.getMessage(), 'Assertion Failed');
            }
        }
    }

    /**
    * @description : Method to test validateAppForScoring with invalid application status
    * @author Krishanu Chinya | 03-01-2025 
    **/
    @isTest
    public static void testScoringWithWrongAppStatus() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        List<genesis__Applications__c> applicationList = getApplication();
        applicationList[0].genesis__Status__c = 'ACTIVE';
        applicationList[0].signing_method__c = ExternalConstants.IN_PERSON_HYBRID;
        Database.update(applicationList, true);
        System.runAs(userList[0]){ 
            try {
                Test.startTest();
                ExternalValidationUtil.validateAppForScoring(applicationList[0]);
                Test.stopTest();
            } catch (CustomException e) {
                System.assertEquals(ExternalConstants.APP_IS_NOT_READY_FOR_SCORING, e.getMessage(), 'Assertion Failed');
            }
        }
    }

}