/**
 * @description       : Test class of ExternalSaveSigningMethodValidationUtil
 * @author            : Suraj Kumar | 06-07-2024
 * @group             : 
 * @last modified on  : 02-27-2025
 * @last modified by  : Krishanu Chinya
**/
@isTest
public with sharing class ExternalSaveSigningMethodValidationTest {
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
                                                                genesis__Account__r.Unique_Id__c,
                                                                genesis__Loan_Amount__c,
                                                                genesis__Contact__c,
                                                                Stage__c,
                                                                genesis__Account__r.genesis__Business_information__c
                                                            FROM genesis__Applications__c 
                                                            WHERE genesis__Loan_Number__c = '300023456'
                                                            LIMIT 1];
        return applicationList[0];
    }
    
    /**
    * @description : Method to get the borrower partyList
    * @author Suraj Kumar | 12-25-2024 
    * @return List<clcommon__Party__c> 
    **/
    private static List<clcommon__Party__c> getBorrowerParty(){
        genesis__Applications__c applicationObj = getApplication();
        List<clcommon__Party__c> borrowerPartyList = [SELECT Id, 
                                                            clcommon__Account__c,
                                                            clcommon__Account__r.clcommon__Legal_Entity_Type__r.Name,
                                                            clcommon__Account__r.Name,
                                                            clcommon__Account__r.clcommon__Email__c,
                                                            clcommon__Contact__c,
                                                            clcommon__Contact__r.FirstName,
                                                            clcommon__Contact__r.LastName,
                                                            clcommon__Contact__r.genesis__SSN__c,
                                                            clcommon__Contact__r.Confirm_SSN__c,
                                                            clcommon__Contact__r.Birthdate,
                                                            clcommon__Contact__r.Email,
                                                            clcommon__Account__r.genesis__Business_information__c,
                                                            clcommon__Account__r.genesis__Business_information__r.genesis__Total_Assets__c,
                                                            clcommon__Account__r.genesis__Business_information__r.genesis__Total_Liabilities__c,
                                                            clcommon__Account__r.genesis__Business_information__r.genesis__Tax_Identification_Number__c,
                                                            clcommon__Type__r.Name,
                                                            Total_Assets__c,
                                                            Total_Liabilities__c,
                                                            DocuSign_URL__c,
                                                            Sent_Url__c,
                                                            marital_status__c,
                                                            DocuSign_Generation_Time__c,
                                                            DocuSign_Signing_Status__c,
                                                            Street__c,
                                                            City__c,
                                                            State__c,
                                                            Postal_Code__c,
                                                            County__c,
                                                            Mobile_Number__c,
                                                            Work_Number__c,
                                                            Home_Number__c
                                                        FROM clcommon__Party__c
                                                        WHERE genesis__Application__r.Id=:applicationObj.id 
                                                        AND clcommon__Type__r.Name =: ExternalConstants.BORROWER_PARTY];
        return borrowerPartyList;
    }

    /**
    * @description : Method to get the principal partyList
    * @author Suraj Kumar | 12-25-2024 
    * @return List<clcommon__Party__c> 
    **/
    private static List<clcommon__Party__c> getPrincipalParty(){
        genesis__Applications__c applicationObj = getApplication();
        List<clcommon__Party__c> principalPartyList = [SELECT Id, 
                                                            clcommon__Account__c,
                                                            clcommon__Account__r.clcommon__Legal_Entity_Type__r.Name,
                                                            clcommon__Account__r.Name,
                                                            clcommon__Account__r.clcommon__Email__c,
                                                            clcommon__Contact__c,
                                                            clcommon__Contact__r.FirstName,
                                                            clcommon__Contact__r.LastName,
                                                            clcommon__Contact__r.genesis__SSN__c,
                                                            clcommon__Contact__r.Confirm_SSN__c,
                                                            clcommon__Contact__r.Birthdate,
                                                            clcommon__Contact__r.Email,
                                                            clcommon__Account__r.genesis__Business_information__c,
                                                            clcommon__Account__r.genesis__Business_information__r.genesis__Total_Assets__c,
                                                            clcommon__Account__r.genesis__Business_information__r.genesis__Total_Liabilities__c,
                                                            clcommon__Account__r.genesis__Business_information__r.genesis__Tax_Identification_Number__c,
                                                            clcommon__Type__r.Name,
                                                            Total_Assets__c,
                                                            Total_Liabilities__c,
                                                            DocuSign_URL__c,
                                                            Sent_Url__c,
                                                            marital_status__c,
                                                            DocuSign_Generation_Time__c,
                                                            DocuSign_Signing_Status__c,
                                                            Street__c,
                                                            City__c,
                                                            State__c,
                                                            Postal_Code__c,
                                                            County__c,
                                                            Mobile_Number__c,
                                                            Work_Number__c,
                                                            Home_Number__c
                                                        FROM clcommon__Party__c
                                                        WHERE genesis__Application__r.Id=:applicationObj.id 
                                                        AND clcommon__Type__r.Name =: ExternalConstants.PRINCIPAL_PARTY];
        return principalPartyList;
    }

    /**
    * @description ; Method to get contact
    * @author Suraj Kumar | 01-11-2025 
    * @param contactId 
    * @return Contact 
    **/
    private static Contact getContact(String contactId){
        List<Contact> contactList = [SELECT Id, 
                                            Email,
                                            FirstName, 
                                            genesis__SSN__c, 
                                            Confirm_SSN__c, 
                                            Birthdate
                                        FROM Contact 
                                        WHERE Id = :contactId];
        return contactList[0];
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
    * @description : Method to test invalid signing method
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testValidateSigningMethodInvalid(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.validateSigningMethod('Paper - Scanned');
            }catch(Exception ex){
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.SIGNING_METHOD_INVALID, ex.getMessage(),'Assertion Fail');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateSigningMethod for valid signing method 
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testDSHybridValid(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.validateSigningMethod(ExternalConstants.IN_PERSON_HYBRID);
            }catch(Exception ex){
                isExceptionThrown = true;
            }
            System.assertEquals(false, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateSigningMethod for valid signing method
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testDSEmailValid(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.validateSigningMethod(ExternalConstants.EMAIL_DOCUSIGN);
            }catch(Exception ex){
                isExceptionThrown = true;
            }
            System.assertEquals(false, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test total asset missing
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testTotalAssetNull(){
        List<clcommon__Party__c> partyList = getBorrowerParty();
        partyList[0].Total_Assets__c = null;
        Database.update(partyList[0],true);
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.validateAssetAndLiability(partyList[0]);
            }catch(Exception ex){
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.APPL_TOTAL_ASSETS_MISSING, ex.getMessage(),'Assertion Fail');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateAssetAndLiability for total asset negative
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testTotalAssetNegative(){
        List<clcommon__Party__c> partyList = getBorrowerParty();
        partyList[0].Total_Assets__c = -10;
        Database.update(partyList[0],true);
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.validateAssetAndLiability(partyList[0]);
            }catch(Exception ex){
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.APPL_TOTAL_ASSETS_INVALID, ex.getMessage(),'Assertion Fail');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateAssetAndLiability for total asset positive
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testTotalAssetPositive(){
        List<clcommon__Party__c> partyList = getBorrowerParty();
        partyList[0].Total_Assets__c = 10;
        Database.update(partyList[0],true);
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.validateAssetAndLiability(partyList[0]);
            }catch(Exception ex){
                isExceptionThrown = true;
            }
            System.assertEquals(false, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test validateAssetAndLiability for total libalities null
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testTotalLiabilitiesNull(){
        List<clcommon__Party__c> partyList = getBorrowerParty();
        partyList[0].Total_Liabilities__c = null;
        Database.update(partyList[0],true);
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.validateAssetAndLiability(partyList[0]);
            }catch(Exception ex){
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.APPL_TOTAL_LIABILITIES_MISSING, ex.getMessage(),'Assertion Fail');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test validateAssetAndLiability for total libalities negative
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testTotalLiabilitiesNegative(){
        List<clcommon__Party__c> partyList = getBorrowerParty();
        partyList[0].Total_Liabilities__c = -1;
        Database.update(partyList[0],true);
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.validateAssetAndLiability(partyList[0]);
            }catch(Exception ex){
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.APPL_TOTAL_LIABILITIES_INVALID, ex.getMessage(),'Assertion Fail');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateAssetAndLiability for total libalities positive
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testTotalLiabilitiesPositive(){
        List<clcommon__Party__c> partyList = getBorrowerParty();
        partyList[0].Total_Liabilities__c = 10;
        Database.update(partyList[0],true);
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.validateAssetAndLiability(partyList[0]);
            }catch(Exception ex){
                isExceptionThrown = true;
            }
            System.assertEquals(false, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateCoApplicant for coapplicant missing
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testValidateCoApplicantMissing(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        clcommon__Legal_Entity__c entityObj = getEntityType();
        entityObj.clcommon__Legal_Entity_Type__c = 'Corporation';
        entityObj.Name = 'Corporation';
        Database.update(entityObj,true);
        List<clcommon__Party__c> borrowerPartyList = getBorrowerParty();
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.validateCoApplicant(borrowerPartyList);
            }catch(Exception ex){
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.CO_APPLICANT_MISSING, ex.getMessage(),'Assertion Fail');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateCoApplicant for valid coapplicant
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testValidateCoApplicantSuccess(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        clcommon__Legal_Entity__c entityObj = getEntityType();
        entityObj.clcommon__Legal_Entity_Type__c = 'Corporation';
        entityObj.Name = 'Corporation';
        Database.update(entityObj,true);
        genesis__Applications__c applicationObj = getApplication();
        List<clcommon__Party__c> partyList = [SELECT Id, 
                                                        genesis__Application__c
                                                    FROM clcommon__Party__c
                                                    WHERE genesis__Application__r.Id=:applicationObj.Id];
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.validateCoApplicant(partyList);
            }catch(Exception ex){
                isExceptionThrown = true;
            }
            System.assertEquals(false, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test isValidApplicationCreation for loan amount invalid
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testLoanAmountNegative(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        applicationObj.genesis__Loan_Amount__c = -10;
        Database.update(applicationObj,true);
        List<clcommon__Party__c> borrowerPartyList = getBorrowerParty();
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.isValidApplicationCreation(applicationObj,borrowerPartyList);
            }catch(Exception ex){
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.LOAN_AMOUNT_MISSING, ex.getMessage(),'Assertion Fail');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test isValidApplicationCreation for loan amount null
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testLoanAmountNull(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        applicationObj.genesis__Loan_Amount__c = null;
        Database.update(applicationObj,true);
        List<clcommon__Party__c> borrowerPartyList = getBorrowerParty();
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.isValidApplicationCreation(applicationObj,borrowerPartyList);
            }catch(Exception ex){
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.LOAN_AMOUNT_MISSING, ex.getMessage(),'Assertion Fail');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test borrower email missing
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testBorrowerAccountEmailMissingSoleProp(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        List<Account> accountList = [SELECT Id,
                                        clcommon__Email__c
                                    FROM Account
                                    WHERE Id=:applicationObj.genesis__Account__c];
        accountList[0].clcommon__Email__c = null;
        Database.update(accountList[0],true);
        List<clcommon__Party__c> borrowerPartyList = getBorrowerParty();
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.isValidApplicationCreation(applicationObj,borrowerPartyList);
            }catch(Exception ex){
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.EMAIL_FIELD_MISSING, ex.getMessage(),'Assertion Fail');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test borrower Name missing
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testBorrowerAccountNameMissingSoleProp(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        List<clcommon__Party__c> borrowerPartyList = getBorrowerParty();
        borrowerPartyList[0].clcommon__Account__r.Name = null;
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.isValidApplicationCreation(applicationObj,borrowerPartyList);
            }catch(Exception ex){
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.APPL_NAME_MISSING, ex.getMessage(),'Assertion Fail');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test borrower party state missing
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testBorrowerStateMissing(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        List<clcommon__Party__c> borrowerPartyList = getBorrowerParty();
        borrowerPartyList[0].State__c = null;
        Database.update(borrowerPartyList[0],true);
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.isValidApplicationCreation(applicationObj,borrowerPartyList);
            }catch(Exception ex){
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.APPL_STATE_MISSING, ex.getMessage(),'Assertion Fail');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test borrower party street missing
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testBorrowerStreetMissing(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        List<clcommon__Party__c> borrowerPartyList = getBorrowerParty();
        borrowerPartyList[0].Street__c = null;
        Database.update(borrowerPartyList[0],true);
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.isValidApplicationCreation(applicationObj,borrowerPartyList);
            }catch(Exception ex){
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.APPL_ADDRESS_MISSING, ex.getMessage(),'Assertion Fail');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test borrower party city missing
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testBorrowerCityMissing(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        List<clcommon__Party__c> borrowerPartyList = getBorrowerParty();
        borrowerPartyList[0].City__c = null;
        Database.update(borrowerPartyList[0],true);
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.isValidApplicationCreation(applicationObj,borrowerPartyList);
            }catch(Exception ex){
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.APPL_CITY_MISSING, ex.getMessage(),'Assertion Fail');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test borrower party postal code missing
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testBorrowerPostalCodeMissing(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        List<clcommon__Party__c> borrowerPartyList = getBorrowerParty();
        borrowerPartyList[0].Postal_Code__c = null;
        Database.update(borrowerPartyList[0],true);
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.isValidApplicationCreation(applicationObj,borrowerPartyList);
            }catch(Exception ex){
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.APPL_ZIP_CODE_MISSING, ex.getMessage(),'Assertion Fail');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test borrower party county missing
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testBorrowerCountyMissing(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        List<clcommon__Party__c> borrowerPartyList = getBorrowerParty();
        borrowerPartyList[0].County__c = null;
        Database.update(borrowerPartyList[0],true);
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.isValidApplicationCreation(applicationObj,borrowerPartyList);
            }catch(Exception ex){
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.APPL_COUNTY_MISSING, ex.getMessage(),'Assertion Fail');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test borrower party phone number missing
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testBorrowerNumberMissing(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        List<clcommon__Party__c> borrowerPartyList = getBorrowerParty();
        borrowerPartyList[0].Work_Number__c = null;
        borrowerPartyList[0].Home_Number__c = null;
        borrowerPartyList[0].Mobile_Number__c = null;
        Database.update(borrowerPartyList[0],true);
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.isValidApplicationCreation(applicationObj,borrowerPartyList);
            }catch(Exception ex){
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.APPL_MOBILE_MISSING, ex.getMessage(),'Assertion Fail');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test borrower postal code invalid
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testBorrowerPostalCodeInvalid(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        List<clcommon__Party__c> borrowerPartyList = getBorrowerParty();
        borrowerPartyList[0].Postal_Code__c = '1234';
        Database.update(borrowerPartyList[0],true);
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.isValidApplicationCreation(applicationObj,borrowerPartyList);
            }catch(Exception ex){
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.POSTAL_CODE_INVALID, ex.getMessage(),'Assertion Fail');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test borrower contact email missing
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testBorrowerContactEmailMissingSoleProp(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        Contact contactObj = getContact(applicationObj.genesis__Contact__c);
        contactObj.Email = null;
        Database.update(contactObj,true);
        List<clcommon__Party__c> borrowerPartyList = getBorrowerParty();
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.isValidApplicationCreation(applicationObj,borrowerPartyList);
            }catch(Exception ex){
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.EMAIL_FIELD_MISSING, ex.getMessage(),'Assertion Fail');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test borrower contact firstName missing
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testBorrowerContactFNameMissingSoleProp(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        Contact contactObj = getContact(applicationObj.genesis__Contact__c);
        contactObj.FirstName = null;
        Database.update(contactObj,true);
        List<clcommon__Party__c> borrowerPartyList = getBorrowerParty();
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.isValidApplicationCreation(applicationObj,borrowerPartyList);
            }catch(Exception ex){
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.APPL_FIRST_NAME_MISSING, ex.getMessage(),'Assertion Fail');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test borrower contact SSN missing 
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testBorrowerContactSSNMissingSoleProp(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        Contact contactObj = getContact(applicationObj.genesis__Contact__c);
        contactObj.genesis__SSN__c = null;
        Database.update(contactObj,true);
        List<clcommon__Party__c> borrowerPartyList = getBorrowerParty();
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.isValidApplicationCreation(applicationObj,borrowerPartyList);
            }catch(Exception ex){
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.APPL_SSN_MISSING, ex.getMessage(),'Assertion Fail');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test borrower contact confirm ssn  missing 
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testBorrowerContactCSSNMissingSoleProp(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        Contact contactObj = getContact(applicationObj.genesis__Contact__c);
        contactObj.Confirm_SSN__c = null;
        Database.update(contactObj,true);
        List<clcommon__Party__c> borrowerPartyList = getBorrowerParty();
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.isValidApplicationCreation(applicationObj,borrowerPartyList);
            }catch(Exception ex){
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.APPL_CONFIRM_SSN_MISSING, ex.getMessage(),'Assertion Fail');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test borrower contact Birthdate missing 
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testBorrowerContactBdateMissingSoleProp(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        Contact contactObj = getContact(applicationObj.genesis__Contact__c);
        contactObj.Birthdate = null;
        Database.update(contactObj,true);
        List<clcommon__Party__c> borrowerPartyList = getBorrowerParty();
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.isValidApplicationCreation(applicationObj,borrowerPartyList);
            }catch(Exception ex){
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.APPL_DATE_OF_BIRTH_MISSING, ex.getMessage(),'Assertion Fail');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test borrower contact Email invalid
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testBorrowerContactEmailInvalidSoleProp(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        List<clcommon__Party__c> borrowerPartyList = getBorrowerParty();
        borrowerPartyList[0].clcommon__Contact__r.Email = 'test.com';
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.isValidApplicationCreation(applicationObj,borrowerPartyList);
            }catch(Exception ex){
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.INVALID_EMAIL, ex.getMessage(),'Assertion Fail');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test borrower contact ssn invalid
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testBorrowerContactSSNInvalidSoleProp(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        Contact contactObj = getContact(applicationObj.genesis__Contact__c);
        contactObj.genesis__SSN__c = '12334';
        Database.update(contactObj,true);
        List<clcommon__Party__c> borrowerPartyList = getBorrowerParty();
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.isValidApplicationCreation(applicationObj,borrowerPartyList);
            }catch(Exception ex){
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.INVALID_SSN, ex.getMessage(),'Assertion Fail');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test borrower contact SSN confirm ssn mismatch
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testBorrowerContactSSNMismatchSoleProp(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        Contact contactObj = getContact(applicationObj.genesis__Contact__c);
        contactObj.Confirm_SSN__c = '1234';
        Database.update(contactObj,true);
        List<clcommon__Party__c> borrowerPartyList = getBorrowerParty();
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.isValidApplicationCreation(applicationObj,borrowerPartyList);
            }catch(Exception ex){
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.SSN_CONFIRM_SSN_MISMATCH, ex.getMessage(),'Assertion Fail');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }


    /**
    * @description : Method to test borrower account name missing for DBA
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testBorrowerAccNameMissingDBA(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        clcommon__Legal_Entity__c entityObj = getEntityType();
        entityObj.clcommon__Legal_Entity_Type__c = ExternalConstants.INDIVIDUAL_ENTITY;
        entityObj.Name = ExternalConstants.INDIVIDUAL_ENTITY;
        Database.update(entityObj,true);
      
        genesis__Applications__c applicationObj = getApplication();

        List<clcommon__Party__c> borrowerPartyList = getBorrowerParty();
        borrowerPartyList[0].clcommon__Account__r.Name = null;
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.isValidApplicationCreation(applicationObj,borrowerPartyList);
            }catch(Exception ex){
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.APPL_NAME_MISSING, ex.getMessage(),'Assertion Fail');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test borrower account name missing for Corporation
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testBorrowerAccNameMissingCorporation(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        clcommon__Legal_Entity__c entityObj = getEntityType();
        entityObj.clcommon__Legal_Entity_Type__c = 'Corporation';
        entityObj.Name = 'Corporation';
        Database.update(entityObj,true);
    
        genesis__Applications__c applicationObj = getApplication();

        List<clcommon__Party__c> borrowerPartyList = getBorrowerParty();
        borrowerPartyList[0].clcommon__Account__r.name = null;
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.isValidApplicationCreation(applicationObj,borrowerPartyList);
            }catch(Exception ex){
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.APPL_NAME_MISSING, ex.getMessage(),'Assertion Fail');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test borrower party state missing for corporation
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testBorrowerStateMissingCorporation(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        clcommon__Legal_Entity__c entityObj = getEntityType();
        entityObj.clcommon__Legal_Entity_Type__c = 'Corporation';
        entityObj.Name = 'Corporation';
        Database.update(entityObj,true);
        genesis__Applications__c applicationObj = getApplication();
        List<clcommon__Party__c> borrowerPartyList = getBorrowerParty();
        borrowerPartyList[0].State__c = null;
        Database.update(borrowerPartyList[0],true);
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.isValidApplicationCreation(applicationObj,borrowerPartyList);
            }catch(Exception ex){
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.APPL_STATE_MISSING, ex.getMessage(),'Assertion Fail');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test borrower party street missing for corporation
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testBorrowerStreetMissingCorporation(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        clcommon__Legal_Entity__c entityObj = getEntityType();
        entityObj.clcommon__Legal_Entity_Type__c = 'Corporation';
        entityObj.Name = 'Corporation';
        Database.update(entityObj,true);
        genesis__Applications__c applicationObj = getApplication();
        List<clcommon__Party__c> borrowerPartyList = getBorrowerParty();
        borrowerPartyList[0].Street__c = null;
        Database.update(borrowerPartyList[0],true);
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.isValidApplicationCreation(applicationObj,borrowerPartyList);
            }catch(Exception ex){
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.APPL_ADDRESS_MISSING, ex.getMessage(),'Assertion Fail');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test borrower party city missing for corporation
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testBorrowerCityMissingCorporation(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        clcommon__Legal_Entity__c entityObj = getEntityType();
        entityObj.clcommon__Legal_Entity_Type__c = 'Corporation';
        entityObj.Name = 'Corporation';
        Database.update(entityObj,true);
        genesis__Applications__c applicationObj = getApplication();
        List<clcommon__Party__c> borrowerPartyList = getBorrowerParty();
        borrowerPartyList[0].City__c = null;
        Database.update(borrowerPartyList[0],true);
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.isValidApplicationCreation(applicationObj,borrowerPartyList);
            }catch(Exception ex){
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.APPL_CITY_MISSING, ex.getMessage(),'Assertion Fail');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test borrower party postal code missing for corporation
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testBorrowerPostalCodeMissingCorporation(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        clcommon__Legal_Entity__c entityObj = getEntityType();
        entityObj.clcommon__Legal_Entity_Type__c = 'Corporation';
        entityObj.Name = 'Corporation';
        Database.update(entityObj,true);
        genesis__Applications__c applicationObj = getApplication();
        List<clcommon__Party__c> borrowerPartyList = getBorrowerParty();
        borrowerPartyList[0].Postal_Code__c = null;
        Database.update(borrowerPartyList[0],true);
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.isValidApplicationCreation(applicationObj,borrowerPartyList);
            }catch(Exception ex){
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.APPL_ZIP_CODE_MISSING, ex.getMessage(),'Assertion Fail');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test borrower party county missing for corporation
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testBorrowerCountyMissingCorporation(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        clcommon__Legal_Entity__c entityObj = getEntityType();
        entityObj.clcommon__Legal_Entity_Type__c = 'Corporation';
        entityObj.Name = 'Corporation';
        Database.update(entityObj,true);
        genesis__Applications__c applicationObj = getApplication();
        List<clcommon__Party__c> borrowerPartyList = getBorrowerParty();
        borrowerPartyList[0].County__c = null;
        Database.update(borrowerPartyList[0],true);
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.isValidApplicationCreation(applicationObj,borrowerPartyList);
            }catch(Exception ex){
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.APPL_COUNTY_MISSING, ex.getMessage(),'Assertion Fail');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }

     /**
    * @description : Method to test borrower party phone number missing for corporation
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testBorrowerNumberMissingCorporation(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        clcommon__Legal_Entity__c entityObj = getEntityType();
        entityObj.clcommon__Legal_Entity_Type__c = 'Corporation';
        entityObj.Name = 'Corporation';
        Database.update(entityObj,true);
        genesis__Applications__c applicationObj = getApplication();
        List<clcommon__Party__c> borrowerPartyList = getBorrowerParty();
        borrowerPartyList[0].Work_Number__c = null;
        borrowerPartyList[0].Home_Number__c = null;
        borrowerPartyList[0].Mobile_Number__c = null;
        Database.update(borrowerPartyList[0],true);
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.isValidApplicationCreation(applicationObj,borrowerPartyList);
            }catch(Exception ex){
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.APPL_MOBILE_MISSING, ex.getMessage(),'Assertion Fail');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test borrower postal code invalid for corporation
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testBorrowerPostalCodeInvalidCorporation(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        clcommon__Legal_Entity__c entityObj = getEntityType();
        entityObj.clcommon__Legal_Entity_Type__c = 'Corporation';
        entityObj.Name = 'Corporation';
        Database.update(entityObj,true);
        genesis__Applications__c applicationObj = getApplication();
        List<clcommon__Party__c> borrowerPartyList = getBorrowerParty();
        borrowerPartyList[0].Postal_Code__c = '1234';
        Database.update(borrowerPartyList[0],true);
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.isValidApplicationCreation(applicationObj,borrowerPartyList);
            }catch(Exception ex){
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.POSTAL_CODE_INVALID, ex.getMessage(),'Assertion Fail');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test borrower TIN Missing for corporation
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testBorrowerTINMisiingCorporation(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        clcommon__Legal_Entity__c entityObj = getEntityType();
        entityObj.clcommon__Legal_Entity_Type__c = 'Corporation';
        entityObj.Name = 'Corporation';
        Database.update(entityObj,true);
        genesis__Applications__c applicationObj = getApplication();
        List<genesis__Business_Information__c> borrowerBInfoList = [SELECT Id, 
                                                                        genesis__Tax_Identification_Number__c 
                                                                    FROM genesis__Business_Information__c 
                                                                    WHERE Id = :applicationObj.genesis__Account__r.genesis__Business_information__c];
        borrowerBInfoList[0].genesis__Tax_Identification_Number__c = null;
        Database.update(borrowerBInfoList[0],true);
        List<clcommon__Party__c> borrowerPartyList = getBorrowerParty();
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.isValidApplicationCreation(applicationObj,borrowerPartyList);
            }catch(Exception ex){
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.APPL_TAX_ID_MISSING, ex.getMessage(),'Assertion Fail');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test borrower total asset for corporation
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testBorrowerTotalAssetMisiingCorporation(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        List<genesis__Business_Information__c> borrowerBInfoList = [SELECT Id, 
                                                                        genesis__Total_Assets__c 
                                                                    FROM genesis__Business_Information__c 
                                                                    WHERE Id = :applicationObj.genesis__Account__r.genesis__Business_information__c];
        borrowerBInfoList[0].genesis__Total_Assets__c = -10;
        Database.update(borrowerBInfoList[0],true);
        List<clcommon__Party__c> borrowerPartyList = getBorrowerParty();
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.isValidApplicationCreation(applicationObj,borrowerPartyList);
            }catch(Exception ex){
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.APPL_TOTAL_ASSETS_INVALID, ex.getMessage(),'Assertion Fail');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test borrower total libalities for corporation
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testBorrowerTotalLibalitiesMisiingCorporation(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        List<genesis__Business_Information__c> borrowerBInfoList = [SELECT Id, 
                                                                        genesis__Total_Liabilities__c 
                                                                    FROM genesis__Business_Information__c 
                                                                    WHERE Id = :applicationObj.genesis__Account__r.genesis__Business_information__c];
        borrowerBInfoList[0].genesis__Total_Liabilities__c = -10;
        Database.update(borrowerBInfoList[0],true);
        List<clcommon__Party__c> borrowerPartyList = getBorrowerParty();
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.isValidApplicationCreation(applicationObj,borrowerPartyList);
            }catch(Exception ex){
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.APPL_TOTAL_LIABILITIES_INVALID, ex.getMessage(),'Assertion Fail');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validate corporation application
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testValidAppCorporation(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        clcommon__Legal_Entity__c entityObj = getEntityType();
        entityObj.clcommon__Legal_Entity_Type__c = 'Corporation';
        entityObj.Name = 'Corporation';
        Database.update(entityObj,true);
        genesis__Applications__c applicationObj = getApplication();

        List<clcommon__Party__c> borrowerPartyList = getBorrowerParty();
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.isValidApplicationCreation(applicationObj,borrowerPartyList);
            }catch(Exception ex){
                isExceptionThrown = true;
            }
            Test.stopTest();
            System.assertEquals(false, isExceptionThrown,'Assertion Fail');
        }
    }

    /**
    * @description : Method to test isValidCoApplicantCreation for principal without email 
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testValidCoAppWithoutEmail(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        List<clcommon__Party__c> principalPartyList = getPrincipalParty();
        Contact contactObj = getContact(principalPartyList[0].clcommon__Contact__c);
        contactObj.Email = null;
        Database.update(contactObj,true);
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.isValidCoApplicantCreation(getPrincipalParty());
            }catch(Exception ex){
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.EMAIL_FIELD_MISSING, ex.getMessage(),'Assertion Fail');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test isValidCoApplicantCreation for principal without LastName 
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testValidCoAppWithoutLastName(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        List<clcommon__Party__c> principalPartyList = getPrincipalParty();
        
        principalPartyList[0].clcommon__Contact__r.LastName = null;
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.isValidCoApplicantCreation(principalPartyList);
            }catch(Exception ex){
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.CO_APPL_LAST_NAME_MISSING, ex.getMessage(),'Assertion Fail');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test isValidCoApplicantCreation for principal without firstName 
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testValidCoAppWithoutFirstName(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        List<clcommon__Party__c> principalPartyList = getPrincipalParty();
        Contact contactObj = getContact(principalPartyList[0].clcommon__Contact__c);
        contactObj.FirstName = null;
        Database.update(contactObj,true);
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.isValidCoApplicantCreation(getPrincipalParty());
            }catch(Exception ex){
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.CO_APPL_FIRST_NAME_MISSING, ex.getMessage(),'Assertion Fail');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test isValidCoApplicantCreation for principal without Name 
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testValidCoAppWithoutName(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        List<clcommon__Party__c> principalPartyList = getPrincipalParty();
        
        principalPartyList[0].clcommon__Account__r.Name = null;
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.isValidCoApplicantCreation(principalPartyList);
            }catch(Exception ex){
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.CO_APPL_LAST_NAME_MISSING, ex.getMessage(),'Assertion Fail');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test isValidCoApplicantCreation for principal party street missing 
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testValidCoAppWithoutPrincipalStreet(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        List<clcommon__Party__c> principalPartyList = getPrincipalParty();
        principalPartyList[0].Street__c = null;
        Database.update(principalPartyList[0],true);
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.isValidCoApplicantCreation(principalPartyList);
            }catch(Exception ex){
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.CO_APPL_ADDRESS_MISSING, ex.getMessage(),'Assertion Fail');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test isValidCoApplicantCreation for principal party City missing 
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testValidCoAppWithoutPrincipalCity(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        List<clcommon__Party__c> principalPartyList = getPrincipalParty();
        principalPartyList[0].City__c = null;
        Database.update(principalPartyList[0],true);
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.isValidCoApplicantCreation(principalPartyList);
            }catch(Exception ex){
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.CO_APPL_CITY_MISSING, ex.getMessage(),'Assertion Fail');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test isValidCoApplicantCreation for principal party state missing 
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testValidCoAppWithoutPrincipalState(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        List<clcommon__Party__c> principalPartyList = getPrincipalParty();
        principalPartyList[0].State__c = null;
        Database.update(principalPartyList[0],true);
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.isValidCoApplicantCreation(principalPartyList);
            }catch(Exception ex){
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.CO_APPL_STATE_MISSING, ex.getMessage(),'Assertion Fail');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test isValidCoApplicantCreation for principal party county missing 
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testValidCoAppWithoutPrincipalCounty(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        List<clcommon__Party__c> principalPartyList = getPrincipalParty();
        principalPartyList[0].County__c = null;
        Database.update(principalPartyList[0],true);
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.isValidCoApplicantCreation(principalPartyList);
            }catch(Exception ex){
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.CO_APPL_COUNTY_MISSING, ex.getMessage(),'Assertion Fail');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }

     /**
    * @description : Method to test isValidCoApplicantCreation for principal party postal code missing 
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testValidCoAppWithoutPrincipalPostalCode(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        List<clcommon__Party__c> principalPartyList = getPrincipalParty();
        principalPartyList[0].Postal_Code__c = null;
        Database.update(principalPartyList[0],true);
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.isValidCoApplicantCreation(principalPartyList);
            }catch(Exception ex){
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.CO_APPL_ZIP_CODE_MISSING, ex.getMessage(),'Assertion Fail');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test isValidCoApplicantCreation for principal party postal code Invalid 
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testValidCoAppPrincipalPostalCodeInvalid(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        List<clcommon__Party__c> principalPartyList = getPrincipalParty();
        principalPartyList[0].Postal_Code__c = '1234';
        Database.update(principalPartyList[0],true);
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.isValidCoApplicantCreation(principalPartyList);
            }catch(Exception ex){
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.POSTAL_CODE_INVALID, ex.getMessage(),'Assertion Fail');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test isValidCoApplicantCreation for principal without ssn 
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testValidCoAppWithoutSSN(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        List<clcommon__Party__c> principalPartyList = getPrincipalParty();
        Contact contactObj = getContact(principalPartyList[0].clcommon__Contact__c);
        contactObj.genesis__SSN__c = null;
        Database.update(contactObj,true);
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.isValidCoApplicantCreation(getPrincipalParty());
            }catch(Exception ex){
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.CO_APPL_SSN_MISSING, ex.getMessage(),'Assertion Fail');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test isValidCoApplicantCreation for principal without BirthDate 
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testValidCoAppWithoutBirthdate(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        List<clcommon__Party__c> principalPartyList = getPrincipalParty();
        Contact contactObj = getContact(principalPartyList[0].clcommon__Contact__c);
        contactObj.BirthDate = null;
        Database.update(contactObj,true);
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.isValidCoApplicantCreation(getPrincipalParty());
            }catch(Exception ex){
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.CO_APPL_DATE_OF_BIRTH_MISSING, ex.getMessage(),'Assertion Fail');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test isValidCoApplicantCreation for principal total asset negative
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testValidCoAppTotalAssetNegative(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        List<clcommon__Party__c> principalPartyList = getPrincipalParty();
        List<genesis__Business_Information__c> principalBInfoList = [SELECT Id, 
                                                                        genesis__Total_Assets__c 
                                                                    FROM genesis__Business_Information__c 
                                                                    WHERE Id = :principalPartyList[0].clcommon__Account__r.genesis__Business_information__c];
        principalBInfoList[0].genesis__Total_Assets__c = -10;
        Database.update(principalBInfoList[0],true);
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.isValidCoApplicantCreation(getPrincipalParty());
            }catch(Exception ex){
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.CO_APPL_TOTAL_ASSETS_INVALID, ex.getMessage(),'Assertion Fail');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test isValidCoApplicantCreation for principal total libalities negative
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testValidCoAppTotalLibalitiesNegative(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        List<clcommon__Party__c> principalPartyList = getPrincipalParty();
        List<genesis__Business_Information__c> principalBInfoList = [SELECT Id, 
                                                                        genesis__Total_Liabilities__c 
                                                                    FROM genesis__Business_Information__c 
                                                                    WHERE Id = :principalPartyList[0].clcommon__Account__r.genesis__Business_information__c];
        principalBInfoList[0].genesis__Total_Liabilities__c = -10;
        Database.update(principalBInfoList[0],true);
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.isValidCoApplicantCreation(getPrincipalParty());
            }catch(Exception ex){
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.CO_APPL_TOTAL_LIABILITIES_INVALID, ex.getMessage(),'Assertion Fail');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }

     /**
    * @description : Method to test isValidCoApplicantCreation for principal contact number missing
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testValidCoAppWithoutPhoneNumber(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        List<clcommon__Party__c> principalPartyList = getPrincipalParty();
        principalPartyList[0].Mobile_Number__c = null;
        principalPartyList[0].Home_Number__c = null;
        principalPartyList[0].Work_Number__c = null;
        Database.update(principalPartyList[0],true);
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.isValidCoApplicantCreation(principalPartyList);
            }catch(Exception ex){
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.APPL_MOBILE_MISSING, ex.getMessage(),'Assertion Fail');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test isValidCoApplicantCreation for principal email invalid
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testValidCoAppEmailInvalid(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        List<clcommon__Party__c> principalPartyList = getPrincipalParty();
   
        principalPartyList[0].clcommon__Contact__r.Email = 'test';
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.isValidCoApplicantCreation(principalPartyList);
            }catch(Exception ex){
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.INVALID_EMAIL, ex.getMessage(),'Assertion Fail');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test isValidCoApplicantCreation for principal SSN invalid
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testValidCoAppSSNInvalid(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        List<clcommon__Party__c> principalPartyList = getPrincipalParty();
        Contact contactObj = getContact(principalPartyList[0].clcommon__Contact__c);
        contactObj.genesis__SSN__c = '1234';
        Database.update(contactObj,true);
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.isValidCoApplicantCreation(getPrincipalParty());
            }catch(Exception ex){
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.INVALID_SSN, ex.getMessage(),'Assertion Fail');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }

     /**
    * @description : Method to test isValidCoApplicantCreation for principal SSN mismatch
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testValidCoAppSSNMismatch(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        List<clcommon__Party__c> principalPartyList = getPrincipalParty();
        Contact contactObj = getContact(principalPartyList[0].clcommon__Contact__c);
        contactObj.Confirm_SSN__c = '1234';
        Database.update(contactObj,true);
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.isValidCoApplicantCreation(getPrincipalParty());
            }catch(Exception ex){
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.SSN_CONFIRM_SSN_MISMATCH, ex.getMessage(),'Assertion Fail');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test isValidCoApplicantCreation for principal Account Email Missing
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testValidCoAppAccEmailMissing(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        List<clcommon__Party__c> principalPartyList = getPrincipalParty();
        List<Account> accoutList = [SELECT Id, clcommon__Email__c FROM Account WHERE Id = :principalPartyList[0].clcommon__Account__c];
        accoutList[0].clcommon__Email__c = null;
        Database.update(accoutList[0],true);
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.isValidCoApplicantCreation(getPrincipalParty());
            }catch(Exception ex){
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.EMAIL_FIELD_MISSING, ex.getMessage(),'Assertion Fail');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }


    /**
    * @description : Method to test validate co-app 
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testValidCoAppCreation(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.isValidCoApplicantCreation(getPrincipalParty());
            }catch(Exception ex){
                isExceptionThrown = true;
            }
            System.assertEquals(false, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test checkContactNumber for valid
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testContactNumberValid(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.checkContactNumber('1234567890', '1234560987', '2345678901');
            }catch(Exception ex){
                isExceptionThrown = true;
            }
            System.assertEquals(false, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }

      /**
    * @description : Method to test checkContactNumber for Invalid
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testContactNumberInValid(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.checkContactNumber('', '', '');
            }catch(Exception ex){
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.APPL_MOBILE_MISSING, ex.getMessage(),'Assertion Fail');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }

     /**
    * @description : Method to test checkAmountLessThanZero for negative amount
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testLoanAmountLessThanZero(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.checkAmountLessThanZero(-10, 'Invalid Loan Amount' );
            }catch(Exception ex){
                isExceptionThrown = true;
                System.assertEquals('Invalid Loan Amount', ex.getMessage(),'Assertion Fail');
            }
            System.assertEquals(true, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test checkAmountLessThanZero for positive amount
    * @author Suraj Kumar | 09-30-2024 
    **/
    @isTest
    private static void testLoanAmountPostive(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try{
                ExternalSaveSigningMethodValidationUtil.checkAmountLessThanZero(10, 'Invalid Loan Amount' );
            }catch(Exception ex){
                isExceptionThrown = true;
            }
            System.assertEquals(false, isExceptionThrown,'Assertion Fail');
            Test.stopTest();
        }
    }

    /**
    * @description : Test a valid marital status string (not blank and not equal to the constant)
    * @author Krishanu Chinya | 02-27-2025 
    **/
    @isTest
    public static void testValidMaritalStatus() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        String validStatus = 'Married';
        System.runAs(userList[0]){
            Test.startTest();
            ExternalSaveSigningMethodValidationUtil.checkMaritalStatus(validStatus, ExternalConstants.APPL_MARITAL_STATUS_MISSING);
            Test.stopTest();
        }
    }

    /**
    * @description : Test an empty marital status string
    * @author Krishanu Chinya | 02-27-2025 
    **/
    @isTest
    public static void testBlankMaritalStatus() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        String blankStatus = '';
        System.runAs(userList[0]){
            try {
                Test.startTest();
                ExternalSaveSigningMethodValidationUtil.checkMaritalStatus(blankStatus, ExternalConstants.APPL_MARITAL_STATUS_MISSING);
                Test.stopTest();
                System.assert(false, 'Expected CustomException to be thrown');
            } catch (CustomException e) {
                System.assertEquals(ExternalConstants.APPL_MARITAL_STATUS_MISSING, e.getMessage(), 'Assertion Failed');
            }
        }
    }

    /**
    * @description : Test the NOT_PROVIDED_MARITAL_STATUS constant value
    * @author Krishanu Chinya | 02-27-2025 
    **/
    @isTest
    public static void testNotProvidedMaritalStatus() {
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        String notProvidedStatus = ExternalConstants.NOT_PROVIDED_MARITAL_STATUS;
        System.runAs(userList[0]){
            try {
                Test.startTest();
                ExternalSaveSigningMethodValidationUtil.checkMaritalStatus(notProvidedStatus, ExternalConstants.APPL_MARITAL_STATUS_MISSING);
                Test.stopTest();
                System.assert(false, 'Expected CustomException to be thrown');
            } catch (CustomException e) {
                System.assertEquals(ExternalConstants.APPL_MARITAL_STATUS_MISSING, e.getMessage(), 'Assertion Failed');
            }
        }
    }

}