/**
 * @description       : Test class for PortalApplicationSubmissionAPI for Throwing Exception
 * @author            : Suraj Kumar
 * @group             : 
 * @last modified on  : 01-26-2025
 * @last modified by  : Ayan Bhowmik
**/
@IsTest
public with sharing class PortalApplicationSubmissionAPIErrorTest {
    /**
    * @description : Setup method to create test data
    * @author Suraj Kumar | 01-16-2025 
    **/
    @TestSetup
    static void setup() {
        
        // Creating floating rate index
        clcommon__Floating_Rate_Index__c floatingRateIndexObj = ApplicationOriginationTestHelper.createFloatingRateIndex(
            New Map<String, Object>{ 'Name' => 'CFA Advantage Rate',
                                        'Base Rate Name' => '4-CFA ADVANTAGE',
                                        'Current Floating Rate' => 11,
                                        'Base Rate Adjuster' => 5.5
        });
        Database.insert(floatingRateIndexObj, true);

        // Creating floating rate
        clcommon__Floating_Rate__c floatingRateObj = ApplicationOriginationTestHelper.createFloatingRate(floatingRateIndexObj);
        Database.insert(floatingRateObj, true);

        // Creating new partnert program
        CFA_Partner_Program__c newPartnerProgramObj = ApplicationOriginationTestHelper.createPartnerProgram(floatingRateIndexObj);
        Database.insert(newPartnerProgramObj, true);
        // Creating Legal Entity for Borrower
        clcommon__Legal_Entity__c entityObj = ApplicationOriginationTestHelper.createSolePropLegalEntity();
        Database.insert(entityObj, true);

        // Creating Business Information
        genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        genesis__Business_Information__c principalBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        genesis__Business_Information__c borrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        Database.insert(new List<genesis__Business_Information__c> {dealerBusinessInfoObj,principalBusinessInfoObj,borrowerBusinessInfoObj}, true);

        // Creating Certified Lender Party Type
        clcommon__Party_Type__c clPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('CERTIFIED LENDER');
        // Create Borrower Party Type
        clcommon__Party_Type__c borrowerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('BORROWER');
        clcommon__Party_Type__c principalPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('PRINCIPAL');
        Database.insert(new List<clcommon__Party_Type__c>{borrowerPartyTypeObj,principalPartyTypeObj,clPartyTypeObj}, true);

        // Creating Account for Dealer
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        dealerAccountObj.CFA_Partner_Program__c = newPartnerProgramObj.Id;
        Database.insert(dealerAccountObj, true);

        // Creating Account for Certified Lender
        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
        // Creating Account for Borrower
        Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(entityObj, borrowerBusinessInfoObj.Id);
        borrowerAccountObj.BillingStreet = 'Action area 1';
        borrowerAccountObj.BillingPostalCode = '10038';
        borrowerAccountObj.Phone = '1111111111';

        Account coBorrowerAccountObj = ApplicationOriginationTestHelper.createCoBorrowerAccount(entityObj,principalBusinessInfoObj.Id);
        coBorrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CoApplicant').getRecordTypeId();
        coBorrowerAccountObj.BillingStreet = 'Action area 1';
        coBorrowerAccountObj.BillingPostalCode = '10038';
        coBorrowerAccountObj.Phone = '1111111111';
        Database.insert(new List<Account> {clAccountObj,borrowerAccountObj,coBorrowerAccountObj}, true);
        

        // Creating Contact for Certified Lender
        Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.Id);
        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.Id);
        borrowerContactObj.Confirm_SSN__c = 'GHFB6766';
        Contact coBorrowerContactObj = ApplicationOriginationTestHelper.createCoBorrowerContact(coBorrowerAccountObj.Id);
        coBorrowerContactObj.Confirm_SSN__c='982983834';
        coBorrowerContactObj.clcommon__Marital_Status__c = 'Married';
        Database.insert(new List<Contact>{clContactObj,borrowerContactObj,coBorrowerContactObj},true);

        List<User> userObjList = new List<User>();

        userObjList.add(ApplicationOriginationTestHelper.createCLUser(clContactObj.Id));

        userObjList.add(ApplicationOriginationTestHelper.createBorrowerUser(borrowerContactObj.Id));
        Database.insert(userObjList,true);

        // Creating CL Purpose of Application
        clcommon__CL_Purpose__c clPurposeObj = ApplicationOriginationTestHelper.createCLPurposeForApplication();
        Database.insert(clPurposeObj, true);

        // Creating Cl Product of Application
        clcommon__CL_Product__c clProductObj = ApplicationOriginationTestHelper.createCLProductForApplication();
        Database.insert(clProductObj, true);
        
        // Creating dealer applicant relationship for borrower and principal
        Dealer_Applicant_Relationship__c dealerApplicantRelObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(borrowerContactObj,dealerAccountObj.Id);
        Dealer_Applicant_Relationship__c dealerCoAppRelObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(coBorrowerContactObj,dealerAccountObj.id);
        Database.insert(new List<Dealer_Applicant_Relationship__c>{dealerCoAppRelObj,dealerApplicantRelObj},true);

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
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createCurrCropYearApplication(paramForApplicationMap);
        applicationObj.Dealer_Applicant_Relationship__c = dealerApplicantRelObj.Id;

        genesis__Applications__c existingApplicationObj = ApplicationOriginationTestHelper.createCurrCropYearApplication(paramForApplicationMap);
        existingApplicationObj.genesis__Loan_Number__c = '116623344';
        existingApplicationObj.Signing_Method__c = 'Paper - Scanned';
        existingApplicationObj.Dealer_Applicant_Relationship__c = dealerApplicantRelObj.Id;

        Database.insert(new List<genesis__Applications__c>{applicationObj,existingApplicationObj}, true);

        // Creating Reciprocal Role 
        clcommon__Reciprocal_Role__c roleObj = ApplicationOriginationTestHelper.createCertifiedLenderRole();
        Database.insert(roleObj, true);

        // Creating Relationship between Dealer and Certified Lender
        clcommon__Relationship__c clDealerRelationshipObj = ApplicationOriginationTestHelper.createCLDealerRelationship(roleObj,dealerAccountObj.Id,clAccountObj.Id);
        Database.insert(clDealerRelationshipObj, true);

        // Creating Certified Lender Party
        Map<String,Id> paramForCLPartyMap = new Map<String,Id>{
            'accountId' => clAccountObj.Id,
            'contactId' => clContactObj.Id,
            'partyTypeId' => clPartyTypeObj.Id,
            'applicationId' => applicationObj.Id
        };

        List<clcommon__Party__c> partyObjList = new List<clcommon__Party__c>();

        partyObjList.add(ApplicationOriginationTestHelper.createParty(paramForCLPartyMap));
        Database.insert(partyObjList,true);

        ApplicationOriginationSetupTestHelper.createSaSaAdminTestData(dealerBusinessInfoObj,dealerAccountObj);
        ApplicationOriginationSetupTestHelper.createAdditionalTestData(applicationObj,dealerAccountObj);
        ApplicationOriginationSetupTestHelper.createAdditionalInfoParty(applicationObj, entityObj,borrowerBusinessInfoObj);

        Map<String,Id> paramForBorrowerPartyMap = new Map<String,Id>{
            'accountId' => borrowerAccountObj.Id,
            'contactId' => borrowerContactObj.Id,
            'partyTypeId' => borrowerPartyTypeObj.Id,
            'applicationId' => applicationObj.Id
        };
        clcommon__party__c borrowerParty = ApplicationOriginationTestHelper.createApplicantParty(paramForBorrowerPartyMap,borrowerAccountObj);
        borrowerParty.Dealer_Applicant_Relationship__c = dealerApplicantRelObj.id;

        // Creating Principal Party for existing application
        Map<String,Id> paramForExistingBorrower = new Map<String,Id>{
            'accountId' => borrowerAccountObj.Id,
            'contactId' => borrowerContactObj.Id,
            'partyTypeId' => borrowerPartyTypeObj.Id,
            'applicationId' => existingApplicationObj.Id
        };

        clcommon__Party__c existingBorrPartyObj = ApplicationOriginationTestHelper.createApplicantParty(paramForExistingBorrower,borrowerAccountObj);
        existingBorrPartyObj.Dealer_Applicant_Relationship__c = dealerApplicantRelObj.id;

        Map<String,Id> paramForPrincipalPartyMap = new Map<String,Id>{
            'accountId' => coBorrowerAccountObj.Id,
            'contactId' => coBorrowerContactObj.Id,
            'partyTypeId' => principalPartyTypeObj.Id,
            'applicationId' => applicationObj.Id
        };

        clcommon__Party__c principalPartyObj = ApplicationOriginationTestHelper.createApplicantParty(paramForPrincipalPartyMap,coBorrowerAccountObj);
        principalPartyObj.Dealer_Applicant_Relationship__c = dealerCoAppRelObj.id;

        // Creating Principal Party for existing application
        Map<String,Id> existingCoAppParamMap = new Map<String,Id>{
            'accountId' => coBorrowerAccountObj.Id,
            'contactId' => coBorrowerContactObj.Id,
            'partyTypeId' => principalPartyTypeObj.Id,
            'applicationId' => existingApplicationObj.Id
        };

        clcommon__Party__c existingCoAppPartyObj = ApplicationOriginationTestHelper.createApplicantParty(existingCoAppParamMap,coBorrowerAccountObj);
        existingCoAppPartyObj.Dealer_Applicant_Relationship__c = dealerCoAppRelObj.id;
        Database.insert(new List<clcommon__Party__c>{borrowerParty,existingBorrPartyObj,principalPartyObj,existingCoAppPartyObj},true);
    }


    /**
    * @description : method to get flex rate pricing details
    * @author Suraj Kumar | 04-08-2024 
    * @return Map<String, Object> 
    **/
    private static Map<String, Object> getFlexRatePricingDetails(){
        Map<String, Object> flexRatePricingDetails = new Map<String, Object> {
            'NoteRate' => new Map<String, Object>(),
            'SpecialTermB' => new Map<String, Object>(),
            'SpecialTermC' => new Map<String, Object>(),
            'SpecialTermD' => new Map<String, Object>{
                'description' => 'Note Rate',
                'interest' => new List<Map<String, Object>> {
                    new Map<String, Object> {
                        'Participation_Percentage_Dealer_Subsidy__c' => 0,
                        'Participation_Percentage_Dealer__c' => 0.5,
                        'Participation_Percentage_CFA__c' => 0,
                        'Start_Date__c' => Date.valueOf('2023-09-19'),
                        'End_Date__c' => Date.valueOf('2025-03-15'),
                        'genesis__Interest_Rate__c' => 12,
                        'Interest_Rate_Type__c' => 'Variable'
                    }
                }
            },

            'SpecialTermE' => new Map<String, Object> {
                'description' => 'Seeds',
                'interest' => new List<Map<String, Object>> {
                    new Map<String, Object> {
                        'Participation_Percentage_Dealer_Subsidy__c' => 0,
                        'Participation_Percentage_Dealer__c' => 0.5,
                        'Participation_Percentage_CFA__c' => 0,
                        'Start_Date__c' => Date.valueOf('2023-09-19'),
                        'End_Date__c' => Date.valueOf('2025-03-15'),
                        'genesis__Interest_Rate__c' => 12,
                        'Interest_Rate_Type__c' => 'Fixed'
                    }
                }
            },
            'SpecialTermF' => new Map<String, Object>(),
            'SpecialTermG' => new Map<String, Object>(),
            'SpecialTermH' => new Map<String, Object>()
        };
        return flexRatePricingDetails;
    }

    /**
    * @description : Testing application submission for without my program without flex rate
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testWithoutRateCardSubmit() {
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 1')[0].Id;
        Database.update(applicationObj, true);

        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('Credit_Application_And_Agreement_Process__c','Proceed with the requirements for the tier');

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };

        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Assertion success!');
            Test.stopTest();
        }
    }

     /**
    * @description : Testing Customized application submission for without my program without flex rate
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testCustAppWithoutRateCardSubmit() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };

        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Assertion success!');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing Is Evergreen for Tier 2 credit rating
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testIsevergreenFailure() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 2')[0].Id;
        applicationObj.Is_Evergreen__c = true;
        Database.update(applicationObj, true);

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCFAMyProgram();

        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('Credit_Application_And_Agreement_Process__c','Proceed with the requirements for the tier');
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };

        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Assertion success!');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing exception for null application record
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testNullAppRecord() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => 'dummy',
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };

        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Assertion success!');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing exception for null application key
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testNullAppKey() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => null,
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };

        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Assertion success!');
            Test.stopTest();
        }
    }

     /**
    * @description : Testing exception for do you recommend app null
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testApplicantRecommendNull() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCFAMyProgram();

        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('Credit_Application_And_Agreement_Process__c','Proceed with the requirements for the tier');
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);
        applicationDetailsMap.put('Do_You_Recommend_This_Applicant__c',null);

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };

        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Assertion success!');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing Flex pricing null for save n exit
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testFlexPricingNullSaveNExit() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();

        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('Credit_Application_And_Agreement_Process__c','Proceed with the requirements for the tier');
        applicationDetailsMap.put('Flex_Rate_Pricing__c',null);
        applicationDetailsMap.put('Do_You_Recommend_This_Applicant__c','No');


        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => false,
            'note' => 'This is a test note!'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assert(response.status!= null, 'Assertion success!');
            Test.stopTest();
        }
    }

     /**
    * @description : Testing Flex pricing null for Submit
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testFlexPricingNullSubmit() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();


        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('Credit_Application_And_Agreement_Process__c','Proceed with the requirements for the tier');
        applicationDetailsMap.put('Flex_Rate_Pricing__c',null);

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Assertion success!');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission for null credit rating and not customized
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testNullCreditRatingSubmit() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCFAMyProgram();

        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('Credit_Application_And_Agreement_Process__c','Proceed with the requirements for the tier');
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Assertion success!');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission for Insufficient Collaterals
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testInsufficientCollaterals() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 3')[0].Id;
        Database.update(applicationObj, true);

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCFAMyProgram();

        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('Credit_Application_And_Agreement_Process__c','Proceed with the requirements for the tier');
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };
        List<clcommon__Collateral__c> collateralObjList = ApplicationOriginationTestHelper.getCollateralList(applicationObj.Id);
        collateralObjList[0].Price__c = 0;
        Database.update(collateralObjList,true);
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Assertion success!');
            Test.stopTest();
        }
    }

     /**
    * @description : Testing Is Evergreen Without Tier
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testIsevergreenWithoutTier() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.Is_Evergreen__c = true;
        Database.update(applicationObj, true);

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCFAMyProgram();

        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('Credit_Application_And_Agreement_Process__c','Proceed with the requirements for the tier');
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };

        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Assertion success!');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission for null coop type
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testNullCoopType() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();

        Account dealerAccObj = ApplicationOriginationTestHelper.getAccountById(applicationObj.Dealer_Name__c);
        dealerAccObj.Coop_Type__c= null;
        Database.update(dealerAccObj,true);

        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('Flex_Rate_Pricing__c',true);

        Map<String, Object> flexRateProgramDetails = ApplicationOriginationTestHelper.getFlexRateProgramDetails();
        Map<String, Object> flexRatePricingDetails = getFlexRatePricingDetails();

        Map<String, Object> flexRateDetails = new Map<String, Object> {
            'flexRateProgram' => flexRateProgramDetails,
            'ratePricing' => flexRatePricingDetails
        };

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!',
            'flexPricing' => JSON.serialize(flexRateDetails)
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Assertion success!');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission for null request map
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testNullRequestMap() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, null);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Assertion success!');
            Test.stopTest();
        }
    }

    /**
    * @description : testing deleting existing ErP Id application
    * @author Suraj Kumar | 04-12-2024 
    **/
    @isTest
    private static void testDeleteExistingERP(){
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 1')[0].Id;
        applicationObj.Signing_Method__c = PortalConstants.IN_PERSON_DOCUSIGN;
        Database.update(applicationObj, true);
        
        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCFAMyProgram();

        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('Credit_Application_And_Agreement_Process__c','Proceed with the requirements for the tier');
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);
        applicationDetailsMap.put('ERP_Id__c',null);

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };

        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Assertion success!');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing Rejected application 
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testRejectedAppSubmit() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCFAMyProgram();

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 1')[0].Id;
        Database.update(applicationObj, true);

        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('Credit_Application_And_Agreement_Process__c','Proceed with the requirements for the tier');
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);
        applicationDetailsMap.put('Do_You_Recommend_This_Applicant__c','No');

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };

        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,  'Assertion success!');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission Sava and Exit for flex rate my program and customized credit rating tier for Growmark
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testFlexRateSavenexitForGrowmark() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();

        Account dealerAccObj = ApplicationOriginationTestHelper.getAccountById(applicationObj.Dealer_Name__c);
        dealerAccObj.Coop_Type__c='Growmark';
        Database.update(dealerAccObj,true);

        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('Flex_Rate_Pricing__c',true);

        Map<String, Object> flexRateProgramDetails = ApplicationOriginationTestHelper.getFlexRateProgramDetails();
        Map<String, Object> flexRatePricingDetails = getFlexRatePricingDetails();

        Map<String, Object> flexRateDetails = new Map<String, Object> {
            'flexRateProgram' => flexRateProgramDetails,
            'ratePricing' => flexRatePricingDetails
        };

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => false,
            'note' => 'This is a test note!',
            'flexPricing' => JSON.serialize(flexRateDetails)
        };

        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion success!');
            Test.stopTest();
        }
    }


    /**
    * @description : Testing application submission without Buyer party
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testWithoutBuyerparty() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 3')[0].Id;
        Database.update(applicationObj, true);

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCFAMyProgram();

        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('Credit_Application_And_Agreement_Process__c','Proceed with the requirements for the tier');
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };
        List<clcommon__Collateral__c> collateralObjList = ApplicationOriginationTestHelper.getCollateralList(applicationObj.Id);
        collateralObjList[0].Price__c = 50000;
        Database.update(collateralObjList,true);

        clcommon__Party__c partyObj = ApplicationOriginationTestHelper.getPartyByTypes(applicationObj.Id,'BUYER');
        partyObj.genesis__Application__c = null;
        Database.update(partyObj,true);
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Assertion success!');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission without Insurance Agent party
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testWithoutIAparty() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 3')[0].Id;
        Database.update(applicationObj, true);

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCFAMyProgram();

        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('Credit_Application_And_Agreement_Process__c','Proceed with the requirements for the tier');
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };
        List<clcommon__Collateral__c> collateralObjList = ApplicationOriginationTestHelper.getCollateralList(applicationObj.Id);
        collateralObjList[0].Price__c = 50000;
        Database.update(collateralObjList,true);

        clcommon__Party__c partyObj = ApplicationOriginationTestHelper.getPartyByTypes(applicationObj.Id,'INSURANCE AGENT');
        partyObj.genesis__Application__c = null;
        Database.update(partyObj,true);

        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Assertion success!');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission without Lamdowner  party
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testWithoutLoparty() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 3')[0].Id;
        Database.update(applicationObj, true);

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCFAMyProgram();

        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('Credit_Application_And_Agreement_Process__c','Proceed with the requirements for the tier');
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };
        List<clcommon__Collateral__c> collateralObjList = ApplicationOriginationTestHelper.getCollateralList(applicationObj.Id);
        collateralObjList[0].Price__c = 50000;
        Database.update(collateralObjList,true);

        clcommon__Party__c partyObj = ApplicationOriginationTestHelper.getPartyByTypes(applicationObj.Id,'LANDOWNER');
        partyObj.genesis__Application__c = null;
        Database.update(partyObj,true);

        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Assertion success!');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission without Spouse party
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testWithoutSpparty() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 3')[0].Id;
        Database.update(applicationObj, true);

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCFAMyProgram();

        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('Credit_Application_And_Agreement_Process__c','Proceed with the requirements for the tier');
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };
        List<clcommon__Collateral__c> collateralObjList = ApplicationOriginationTestHelper.getCollateralList(applicationObj.Id);
        collateralObjList[0].Price__c = 50000;
        Database.update(collateralObjList,true);

        Contact borrowerContactObj = ApplicationOriginationTestHelper.getContactByAccId(applicationObj.genesis__Account__c);
        borrowerContactObj.clcommon__Marital_Status__c = 'Married';
        Database.update(borrowerContactObj,true);
        
        clcommon__Party__c partyObj = ApplicationOriginationTestHelper.getPartyByTypes(applicationObj.Id,'SPOUSE');
        partyObj.genesis__Application__c = null;
        Database.update(partyObj,true);
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Assertion success!');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission  for flex rate my program and customized credit rating tier for Growmark
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testFlexRateSubmitForGrowmark() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.Signing_Method__c = 'Paper - Scanned';
        Database.update(applicationObj,true);

        List<genesis__Application_Pricing_Detail__c> pricingDetList = [SELECT Id 
                                                                    FROM  genesis__Application_Pricing_Detail__c 
                                                                    WHERE genesis__Application__c = :applicationObj.Id];
        Database.delete(pricingDetList,true);

        Account dealerAccObj = ApplicationOriginationTestHelper.getAccountById(applicationObj.Dealer_Name__c);
        dealerAccObj.Coop_Type__c='Growmark';
        Database.update(dealerAccObj,true);

        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('Flex_Rate_Pricing__c',true);

        Map<String, Object> flexRateProgramDetails = ApplicationOriginationTestHelper.getFlexRateProgramDetails();
        Map<String, Object> flexRatePricingDetails = getFlexRatePricingDetails();

        Map<String, Object> flexRateDetails = new Map<String, Object> {
            'flexRateProgram' => flexRateProgramDetails,
            'ratePricing' => flexRatePricingDetails
        };

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!',
            'flexPricing' => JSON.serialize(flexRateDetails)
        };

        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion success!');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission without borrower party
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testWithoutBorrowerparty() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 3')[0].Id;
        Database.update(applicationObj, true);

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCFAMyProgram();

        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('Credit_Application_And_Agreement_Process__c','Proceed with the requirements for the tier');
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };
        List<clcommon__Collateral__c> collateralObjList = ApplicationOriginationTestHelper.getCollateralList(applicationObj.Id);
        collateralObjList[0].Price__c = 50000;
        Database.update(collateralObjList,true);

        Contact borrowerContactObj = ApplicationOriginationTestHelper.getContactByAccId(applicationObj.genesis__Account__c);
        borrowerContactObj.clcommon__Marital_Status__c = 'Married';
        Database.update(borrowerContactObj,true);

        clcommon__Party__c partyObj = ApplicationOriginationTestHelper.getPartyByTypes(applicationObj.Id,'BORROWER');
        partyObj.genesis__Application__c = null;
        Database.update(partyObj,true);
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Assertion success!');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission without borrower Account
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testWithoutPrincipalAcc() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 3')[0].Id;
        Database.update(applicationObj, true);

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCFAMyProgram();

        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('Credit_Application_And_Agreement_Process__c','Proceed with the requirements for the tier');
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };
        List<clcommon__Collateral__c> collateralObjList = ApplicationOriginationTestHelper.getCollateralList(applicationObj.Id);
        collateralObjList[0].Price__c = 50000;
        Database.update(collateralObjList,true);

        Contact borrowerContactObj = ApplicationOriginationTestHelper.getContactByAccId(applicationObj.genesis__Account__c);
        borrowerContactObj.clcommon__Marital_Status__c = 'Married';
        Database.update(borrowerContactObj,true);
        List<Account> principalAccObjList = [SELECT Id FROM Account WHERE Name = 'Mike Johnson'];
        Database.delete(principalAccObjList,true);

        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Assertion success!');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing Not autobook application submission 
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testNotAutoBookforNewApplicant() {
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 1')[0].Id;
        applicationObj.Signing_Method__c = 'Paper - Scanned';
        Database.update(applicationObj, true);

        List<Task> entityTaskList = [SELECT Id,
                                            Status
                                        FROM Task 
                                        WHERE Subject = :PortalConstants.ENTITY_DOC_TASK
                                        AND genesis__Application__c = :applicationObj.Id];
        entityTaskList[0].Status = PortalConstants.OPEN_TASK_STATUS;
        Database.update(entityTaskList[0], true);

        List<genesis__Applications__c> existingAppList = [SELECT Id, 
                                                            genesis__Status__c 
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Number__c = '116623344'];
        existingAppList[0].genesis__Status__c = 'NEW - SCORECARD GENERATED';
        Database.update(existingAppList[0],true);
        
        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCFAMyProgram();

        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('Credit_Application_And_Agreement_Process__c','Proceed with the requirements for the tier');
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };

        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion success!');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing Not autobook application submission 
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testNotAutoBookForExistingApplicant() {
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 1')[0].Id;
        applicationObj.Signing_Method__c = PortalConstants.IN_PERSON_DOCUSIGN;
        applicationObj.Agreement_Sign__c = true;
        Database.update(applicationObj, true);

        List<Task> entityTaskList = [SELECT Id,
                                        Status
                                    FROM Task 
                                    WHERE Subject = :PortalConstants.ENTITY_DOC_TASK
                                    AND genesis__Application__c = :applicationObj.Id];

        entityTaskList[0].Status = PortalConstants.OPEN_TASK_STATUS;
        Database.update(entityTaskList[0], true);

        List<genesis__Applications__c> existingAppList = [SELECT Id 
                                                            FROM genesis__Applications__c 
                                                            WHERE genesis__Loan_Number__c = '116623344'];

        clcommon__Party__c partyObj = ApplicationOriginationTestHelper.getPartyByTypes(existingAppList[0].Id,'PRINCIPAL');
        Database.delete(partyObj,true);
        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCFAMyProgram();

        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('Credit_Application_And_Agreement_Process__c','Proceed with the requirements for the tier');
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };

        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion success!');
            Test.stopTest();
        }
    }

     /**
    * @description : Testing application submission for Insufficient Collaterals
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testWithoutCollaterals() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 3')[0].Id;
        Database.update(applicationObj, true);

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCFAMyProgram();

        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('Credit_Application_And_Agreement_Process__c','Proceed with the requirements for the tier');
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };
        List<clcommon__Collateral__c> collateralObjList = ApplicationOriginationTestHelper.getCollateralList(applicationObj.Id);
        Database.delete(collateralObjList,true);

        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Assertion success!');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission for Unauthorize user
    **/
    @IsTest
    private static void testUnAuthorizeUser() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 3')[0].Id;
        Database.update(applicationObj, true);

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCFAMyProgram();

        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('Credit_Application_And_Agreement_Process__c','Proceed with the requirements for the tier');
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };
        clcommon__Party__c partyObj = ApplicationOriginationTestHelper.getPartyByTypes(applicationObj.Id,'CERTIFIED LENDER');
        partyObj.genesis__Application__c = null;
        Database.update(partyObj,true);

        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Assertion success!');
            Test.stopTest();
        }
    }
     /**
    * @description : Testing application submission for missing partner program
    **/
    @IsTest
    private static void testMissingPartnerProgram() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 3')[0].Id;
        Database.update(applicationObj, true);

        Account dealerAccObj = ApplicationOriginationTestHelper.getAccountById(applicationObj.Dealer_Name__c);
        dealerAccObj.CFA_Partner_Program__c = null;
        Database.update(dealerAccObj, true);

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCFAMyProgram();

        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('Credit_Application_And_Agreement_Process__c','Proceed with the requirements for the tier');
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };
        clcommon__Party__c partyObj = ApplicationOriginationTestHelper.getPartyByTypes(applicationObj.Id,'CERTIFIED LENDER');
        partyObj.genesis__Application__c = null;
        Database.update(partyObj,true);
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Assertion success!');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission with my program having only rate card header , not rate card setup details.
    * @author Suraj Kumar | 01-15-2025 
    **/
    @IsTest
    private static void testSubmitWithoutRateCardSetupDetails() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 1')[0].Id;
        Database.update(applicationObj, true);

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCFAMyProgram();
        
        List<genesis__Rate_Card_Setup_Detail__c> rateCardSetupDetailList = [SELECT Id,
                                                                                    genesis__Rate_Card_Setup_Header__c
                                                                                FROM genesis__Rate_Card_Setup_Detail__c 
                                                                                WHERE Description__c = 'This is a test rate card setup detail for a test my porgram of a test Account'];
        Database.delete(rateCardSetupDetailList,true);
        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('Credit_Application_And_Agreement_Process__c','Proceed with the requirements for the tier');
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Assertion success!');
            Test.stopTest();
        }
    }

     /**
    * @description : Testing application submission for Years_Of_Business_With_Applicant__c is blank
    * @author Suraj Kumar | 01-15-2025 
    **/
    @IsTest
    private static void testSubmitWithoutYearOfBussiness() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Expected_Start_Date__c=System.today();
        Database.update(applicationObj,true);

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCFAMyProgram();
        rateCardObj.genesis__Start_Date__c =System.today().addMonths(1).toStartOfMonth();
        Database.update(rateCardObj,true);

        List<genesis__Rate_Card_Setup_Detail__c> rateCardSetupDetailList = [SELECT Id,Start_Date__c FROM genesis__Rate_Card_Setup_Detail__c WHERE Description__c = 'This is a test rate card setup detail for a test my porgram of a test Account'];
        rateCardSetupDetailList[0].Start_Date__c =System.today().addMonths(1).toStartOfMonth();
        Database.update(rateCardSetupDetailList[0], true);
        
        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);
        applicationDetailsMap.put('Years_Of_Business_With_Applicant__c', '');

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };

        
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Assertion success!');
            Test.stopTest();
        }
        
    }

    /**
    * @description : Testing application submission with my program and Credit_Application_And_Agreement_Process__c Customized , secured, first Lien , Other document without additional Requirement
    * @author Suraj Kumar | 01-15-2025 
    **/
    @IsTest
    private static void testSubmitFirstLienWithoutAddRequirement() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Expected_Start_Date__c=System.today();
        Database.update(applicationObj,true);

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCFAMyProgram();
        rateCardObj.genesis__Start_Date__c =System.today().addMonths(1).toStartOfMonth();
        Database.update(rateCardObj,true);

        List<genesis__Rate_Card_Setup_Detail__c> rateCardSetupDetailList = [SELECT Id,Start_Date__c FROM genesis__Rate_Card_Setup_Detail__c WHERE Description__c = 'This is a test rate card setup detail for a test my porgram of a test Account'];
        rateCardSetupDetailList[0].Start_Date__c =System.today().addMonths(1).toStartOfMonth();
        Database.update(rateCardSetupDetailList[0], true);
        
        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);
        applicationDetailsMap.put('Crops_Lien__c', 'First Lien');
        applicationDetailsMap.put('Lien_Position__c', 'Crops');
        applicationDetailsMap.put('Other_Additional_Requirements_Needed__c',true);

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Assertion success!');
            Test.stopTest();
        }
    }

     /**
    * @description : Testing application submission with my program and Credit_Application_And_Agreement_Process__c Customized , secured, Second Lien , Other document without additional Requirement
    * @author Suraj Kumar | 01-15-2025 
    **/
    @IsTest
    private static void testSubmitSecondLienWithoutAddRequirement() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Expected_Start_Date__c=System.today();
        Database.update(applicationObj,true);

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCFAMyProgram();
        rateCardObj.genesis__Start_Date__c =System.today().addMonths(1).toStartOfMonth();
        Database.update(rateCardObj,true);

        List<genesis__Rate_Card_Setup_Detail__c> rateCardSetupDetailList = [SELECT Id,Start_Date__c FROM genesis__Rate_Card_Setup_Detail__c WHERE Description__c = 'This is a test rate card setup detail for a test my porgram of a test Account'];
        rateCardSetupDetailList[0].Start_Date__c =System.today().addMonths(1).toStartOfMonth();
        Database.update(rateCardSetupDetailList[0], true);
        
        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);
        applicationDetailsMap.put('Lien_Position__c', 'Crops');
        applicationDetailsMap.put('Other_Additional_Requirements_Needed__c',true);

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Assertion success!');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission with my program and Credit_Application_And_Agreement_Process__c Customized , secured, Best Lien , Other document without additional Requirement
    * @author Suraj Kumar | 01-15-2025 
    **/
    @IsTest
    private static void testSubmitBestLienWithoutAddRequirement() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Expected_Start_Date__c=System.today();
        Database.update(applicationObj,true);

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCFAMyProgram();
        rateCardObj.genesis__Start_Date__c =System.today().addMonths(1).toStartOfMonth();
        Database.update(rateCardObj,true);

        List<genesis__Rate_Card_Setup_Detail__c> rateCardSetupDetailList = [SELECT Id,Start_Date__c FROM genesis__Rate_Card_Setup_Detail__c WHERE Description__c = 'This is a test rate card setup detail for a test my porgram of a test Account'];
        rateCardSetupDetailList[0].Start_Date__c =System.today().addMonths(1).toStartOfMonth();
        Database.update(rateCardSetupDetailList[0], true);
        
        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);
        applicationDetailsMap.put('Crops_Lien__c', 'Best Lien');
        applicationDetailsMap.put('Lien_Position__c', 'Crops');
        applicationDetailsMap.put('Other_Additional_Requirements_Needed__c',true);

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Assertion success!');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission with my program and Credit_Application_And_Agreement_Process__c Customized , secured, Blanket Lien ,Blanket_Lien__c as second lien Other document without additional Requirement
    * @author Suraj Kumar | 01-15-2025 
    **/
    @IsTest
    private static void testBlanketLienSecondWithoutAddRequirement() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Expected_Start_Date__c=System.today();
        Database.update(applicationObj,true);

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCFAMyProgram();
        rateCardObj.genesis__Start_Date__c =System.today().addMonths(1).toStartOfMonth();
        Database.update(rateCardObj,true);

        List<genesis__Rate_Card_Setup_Detail__c> rateCardSetupDetailList = [SELECT Id,Start_Date__c FROM genesis__Rate_Card_Setup_Detail__c WHERE Description__c = 'This is a test rate card setup detail for a test my porgram of a test Account'];
        rateCardSetupDetailList[0].Start_Date__c =System.today().addMonths(1).toStartOfMonth();
        Database.update(rateCardSetupDetailList[0], true);
        
        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);
        applicationDetailsMap.put('Blanket_Lien__c', 'Second Lien');
        applicationDetailsMap.put('Lien_Position__c', 'Blanket');
        applicationDetailsMap.put('Other_Additional_Requirements_Needed__c',true);

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Assertion success!');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission with my program and Credit_Application_And_Agreement_Process__c Customized , secured, Blanket Lien ,Blanket_Lien__c as Best lien Other document without additional Requirement
    * @author Suraj Kumar | 01-15-2025 
    **/
    @IsTest
    private static void testBlanketLienBestWithoutAddRequirement() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Expected_Start_Date__c=System.today();
        Database.update(applicationObj,true);

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCFAMyProgram();
        rateCardObj.genesis__Start_Date__c =System.today().addMonths(1).toStartOfMonth();
        Database.update(rateCardObj,true);

        List<genesis__Rate_Card_Setup_Detail__c> rateCardSetupDetailList = [SELECT Id,Start_Date__c FROM genesis__Rate_Card_Setup_Detail__c WHERE Description__c = 'This is a test rate card setup detail for a test my porgram of a test Account'];
        rateCardSetupDetailList[0].Start_Date__c =System.today().addMonths(1).toStartOfMonth();
        Database.update(rateCardSetupDetailList[0], true);
        
        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);
        applicationDetailsMap.put('Blanket_Lien__c', 'Best Lien');
        applicationDetailsMap.put('Lien_Position__c', 'Blanket');
        applicationDetailsMap.put('Other_Additional_Requirements_Needed__c',true);

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Assertion success!');
            Test.stopTest();
        }
    }

    /**
    * @description The purpose of this method is to test for a no score applicant. When the application with a no score primary applicant is scored, the fico score on the application is null. Hence when the cl not chooses request second look in the credit agreement and application process, the additional info must be required.
    * @author Suraj Kumar | 01-15-2025 
    **/
    @IsTest
    private static void testTierThreeAppSubmitNoScoreApplicant() {
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 3')[0].Id;
        Database.update(applicationObj, true);

        Account principalAccount=ApplicationOriginationTestHelper.getPrincipalAccount();
        principalAccount.Score_1__c='9002';
        Database.update(principalAccount,true);

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCFAMyProgram();

        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('Credit_Application_And_Agreement_Process__c','Proceed with the requirements for the tier');
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };
        List<clcommon__Collateral__c> collateralObjList = ApplicationOriginationTestHelper.getCollateralList(applicationObj.Id);
        Database.delete(collateralObjList,true);
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI submissionApi = new PortalApplicationSubmissionAPI();
            clcommon.Response response = submissionApi.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Assertion success!');
            Test.stopTest();
        }
        
    }

     /**
    * @description : Testing application save and exit without selecting Do you recommend the approval of this application
    * @author Suraj Kumar | 01-15-2025 
    **/
    @IsTest
    private static void testSaveAndExitWithoutSelectingDoYouRecommend() {
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Expected_Start_Date__c=System.today();
        Database.update(applicationObj,true);

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCFAMyProgram();
        rateCardObj.genesis__Start_Date__c =System.today().addMonths(1).toStartOfMonth();
        Database.update(rateCardObj,true);

        List<genesis__Rate_Card_Setup_Detail__c> rateCardSetupDetailList = [SELECT Id,Start_Date__c FROM genesis__Rate_Card_Setup_Detail__c WHERE Description__c = 'This is a test rate card setup detail for a test my porgram of a test Account'];
        rateCardSetupDetailList[0].Start_Date__c =System.today().addMonths(1).toStartOfMonth();
        Database.update(rateCardSetupDetailList[0], true);
        
        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);
        applicationDetailsMap.remove('Do_You_Recommend_This_Applicant__c');

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Assertion success!');
            Test.stopTest();
        }
    }
}