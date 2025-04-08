/**
 * @description       : Test class for PortalApplicationSubmissionAPI
 * @author            : iAyush
 * @group             : 
 * @last modified on  : 01-27-2025
**/
@IsTest
public with sharing class TestPortalApplicationSubmissionAPI {

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

        // Creating Business Information
        genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();

        //creating business info for borrower
        genesis__Business_Information__c borrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        genesis__Business_Information__c principalBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        Database.insert(new List<genesis__Business_Information__c>{
        dealerBusinessInfoObj,
        borrowerBusinessInfoObj,
        principalBusinessInfoObj
        }, true);

        // Creating Account for Dealer
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        dealerAccountObj.CFA_Partner_Program__c = newPartnerProgramObj.Id;
        Database.insert(dealerAccountObj, true);

        // Creating Legal Entity for Borrower
        clcommon__Legal_Entity__c entityObj = ApplicationOriginationTestHelper.createSolePropLegalEntity();
        Database.insert(entityObj, true);

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

        Database.insert(new List<Account>{
            clAccountObj,
            borrowerAccountObj,
            coBorrowerAccountObj
        }, true);

        // Creating Contact for Certified Lender
        Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.Id);

        // Creating Contact for Borrower
        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.Id);
        borrowerContactObj.Confirm_SSN__c = 'GHFB6766';
        //Creating Co-Applicant contact
        Contact coBorrowerContactObj = ApplicationOriginationTestHelper.createCoBorrowerContact(coBorrowerAccountObj.Id);

        Database.insert(new List<Contact>{
            clContactObj,
            borrowerContactObj,
            coBorrowerContactObj
        },true);

        User clUserObj = ApplicationOriginationTestHelper.createCLUser(clContactObj.Id);
        User borrowerUserObj = ApplicationOriginationTestHelper.createBorrowerUser(borrowerContactObj.Id);
        Database.insert(new List<User>{
            clUserObj,
            borrowerUserObj
        },true);

        Dealer_Applicant_Relationship__c dealerApplicantRelObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(borrowerContactObj,dealerAccountObj.Id);
        Dealer_Applicant_Relationship__c dealerCoAppRelObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(coBorrowerContactObj,dealerAccountObj.id);

        Database.insert(new List<Dealer_Applicant_Relationship__c>{dealerCoAppRelObj,dealerApplicantRelObj},true);

        // Creating CL Purpose of Application
        clcommon__CL_Purpose__c clPurposeObj = ApplicationOriginationTestHelper.createCLPurposeForApplication();
        Database.insert(clPurposeObj, true);

        // Creating Cl Product of Application
        clcommon__CL_Product__c clProductObj = ApplicationOriginationTestHelper.createCLProductForApplication();
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
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createCurrCropYearApplication(paramForApplicationMap);
        applicationObj.Agreement_Sign__c = true;
        Database.insert(applicationObj, true);

        // Creating Reciprocal Role 
        clcommon__Reciprocal_Role__c roleObj = ApplicationOriginationTestHelper.createCertifiedLenderRole();
        Database.insert(roleObj, true);

        // Creating Relationship between Dealer and Certified Lender
        clcommon__Relationship__c clDealerRelationshipObj = ApplicationOriginationTestHelper.createCLDealerRelationship(roleObj,dealerAccountObj.Id,clAccountObj.Id);
        Database.insert(clDealerRelationshipObj, true);

        // Creating Certified Lender Party Type
        clcommon__Party_Type__c clPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('CERTIFIED LENDER');

        // Create Borrower Party Type
        clcommon__Party_Type__c borrowerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('BORROWER');
        Database.insert(new List<clcommon__Party_Type__c>{
            clPartyTypeObj,
            borrowerPartyTypeObj
        }, true);

        // Creating Certified Lender Party
        Map<String,Id> paramForCLPartyMap = new Map<String,Id>{
            'accountId' => clAccountObj.Id,
            'contactId' => clContactObj.Id,
            'partyTypeId' => clPartyTypeObj.Id,
            'applicationId' => applicationObj.Id
        };


        clcommon__party__c clParty = ApplicationOriginationTestHelper.createParty(paramForCLPartyMap);

        Map<String,Id> paramForBorrowerPartyMap = new Map<String,Id>{
            'accountId' => borrowerAccountObj.Id,
            'contactId' => borrowerContactObj.Id,
            'partyTypeId' => borrowerPartyTypeObj.Id,
            'applicationId' => applicationObj.Id
        };

        clcommon__party__c borrowerParty = ApplicationOriginationTestHelper.createApplicantParty(paramForBorrowerPartyMap,borrowerAccountObj);
        borrowerParty.Dealer_Applicant_Relationship__c = dealerApplicantRelObj.id;

        ApplicationOriginationSetupTestHelper.createSaSaAdminTestData(dealerBusinessInfoObj,dealerAccountObj);
        ApplicationOriginationSetupTestHelper.createAdditionalTestData(applicationObj,dealerAccountObj);

        genesis__Applications__c existingApplicationObj = ApplicationOriginationTestHelper.createCurrCropYearApplication(paramForApplicationMap);
        existingApplicationObj.genesis__Loan_Number__c = '116623344';
        existingApplicationObj.Signing_Method__c = 'Paper - Scanned';
        Database.insert(existingApplicationObj,true);

        Map<String,Id> paramForExistingBorrower = new Map<String,Id>{
            'accountId' => borrowerAccountObj.Id,
            'contactId' => borrowerContactObj.Id,
            'partyTypeId' => borrowerPartyTypeObj.Id,
            'applicationId' => existingApplicationObj.Id
        };

        clcommon__party__c existingBorrowerParty = ApplicationOriginationTestHelper.createApplicantParty(paramForExistingBorrower,borrowerAccountObj);
        existingBorrowerParty.Dealer_Applicant_Relationship__c = dealerApplicantRelObj.id;

        ApplicationOriginationSetupTestHelper.createAdditionalInfoParty(applicationObj, entityObj,borrowerBusinessInfoObj);

        // Creating Principal party type
        clcommon__Party_Type__c principalPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('PRINCIPAL');
        Database.insert(principalPartyTypeObj, true);

        Map<String,Id> paramForExistingCoBorr = new Map<String,Id>{
            'accountId' => coBorrowerAccountObj.Id,
            'contactId' => coBorrowerContactObj.Id,
            'partyTypeId' => principalPartyTypeObj.Id,
            'applicationId' => existingApplicationObj.Id
        };

        clcommon__party__c existingCoBorrowerParty = ApplicationOriginationTestHelper.createApplicantParty(paramForExistingCoBorr,coBorrowerAccountObj);
        existingBorrowerParty.Dealer_Applicant_Relationship__c = dealerCoAppRelObj.id;
        Database.insert(new List<clcommon__party__c>{existingCoBorrowerParty,existingBorrowerParty,borrowerParty,clParty},true);
        

    }

    /**
    * @description : method to get flex rate pricing details
    * @author Suraj Kumar | 04-08-2024 
    * @return Map<String, Object> 
    **/
    private static Map<String, Object> getFlexRatePricingDetails(){
        Map<String, Object> flexRatePricingDetails = new Map<String, Object> {
            'NoteRate' => new Map<String, Object> {
                'description' => 'Note Rate',
                'interest' => new List<Map<String, Object>> {
                    new Map<String, Object> {
                        'Participation_Percentage_Dealer_Subsidy__c' => 0,
                        'Participation_Percentage_Dealer__c' => 0.5,
                        'Participation_Percentage_CFA__c' => 0,
                        'Start_Date__c' => Date.valueOf('2024-07-19'),
                        'End_Date__c' => Date.valueOf('2025-04-15'),
                        'genesis__Interest_Rate__c' => 12,
                        'Interest_Rate_Type__c' => 'Variable'
                    }
                }
            },

            'SpecialTermB' => new Map<String, Object> {
                'description' => 'Seeds',
                'interest' => new List<Map<String, Object>> {
                    new Map<String, Object> {
                        'Participation_Percentage_Dealer_Subsidy__c' => 0,
                        'Participation_Percentage_Dealer__c' => 0.5,
                        'Participation_Percentage_CFA__c' => 0,
                        'Start_Date__c' => Date.valueOf('2024-07-19'),
                        'End_Date__c' => Date.valueOf('2025-04-15'),
                        'genesis__Interest_Rate__c' => 12,
                        'Interest_Rate_Type__c' => 'Fixed'
                    }
                }
            },

            'SpecialTermC' => new Map<String, Object>(),
            'SpecialTermD' => new Map<String, Object>(),
            'SpecialTermE' => new Map<String, Object>(),
            'SpecialTermF' => new Map<String, Object>(),
            'SpecialTermG' => new Map<String, Object>(),
            'SpecialTermH' => new Map<String, Object>()
        };
        return flexRatePricingDetails;
    }

    /**
    * @description : method to get flex rate pricing details
    * @author Pritam Roy | 04-08-2024 
    * @return Map<String, Object> 
    **/
    private static Map<String, Object> getFlexRatePricing(){
        Map<String, Object> flexRatePricingDetails = new Map<String, Object> {
            'NoteRate' => new Map<String, Object> (),

            'SpecialTermB' => new Map<String, Object> (),
            'SpecialTermC' => new Map<String, Object>(),
            'SpecialTermD' => new Map<String, Object>(),
            'SpecialTermE' => new Map<String, Object>(),
            'SpecialTermF' => new Map<String, Object>(),
            'SpecialTermG' => new Map<String, Object>(),
            'SpecialTermH' => new Map<String, Object>()
        };
        return flexRatePricingDetails;
    }

    /**
    * @description : Testing application submission with my program and Credit_Application_And_Agreement_Process__c Customized for CFA
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testCustomizedAppSubmit() {
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Expected_Start_Date__c=System.today();
        Database.update(applicationObj,true);

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCFAMyProgram();
        rateCardObj.genesis__Start_Date__c =System.today().addMonths(1).toStartOfMonth();
        Database.update(rateCardObj,true);

        genesis__Rate_Card_Setup_Detail__c rateCardSetupDetailObj = [SELECT Id,Start_Date__c FROM genesis__Rate_Card_Setup_Detail__c WHERE Description__c = 'This is a test rate card setup detail for a test my porgram of a test Account'];
        rateCardSetupDetailObj.Start_Date__c =System.today().addMonths(1).toStartOfMonth();
        Database.update(rateCardSetupDetailObj, true);
        
        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
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
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion unsuccessful!');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application save and exit with my program and Credit_Application_And_Agreement_Process__c Customized for CFA
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testCustomizedAppSaveAndExit() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Expected_Start_Date__c=System.today();
        Database.update(applicationObj,true);

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCFAMyProgram();
        rateCardObj.genesis__Start_Date__c =System.today().addMonths(1).toStartOfMonth();
        Database.update(rateCardObj,true);

        genesis__Rate_Card_Setup_Detail__c rateCardSetupDetailObj = [SELECT Id,Start_Date__c FROM genesis__Rate_Card_Setup_Detail__c WHERE Description__c = 'This is a test rate card setup detail for a test my porgram of a test Account'];
        rateCardSetupDetailObj.Start_Date__c =System.today().addMonths(1).toStartOfMonth();
        Database.update(rateCardSetupDetailObj, true);

        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);
        applicationDetailsMap.put('Lien_Options__c',PortalConstants.UNSECURED_LIEN);

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => false,
            'note' => 'This is a test note!'
        };

        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion unsuccessful!');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission success for flex rate my program and customized credit rating tier
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testCustomizedAppForFlexRateSubmit() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();

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
            System.assert(response != null, 'Response is null');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission success for flex rate my program and customized credit rating tier
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testCustomizedAppForFlexRateSubmission() {
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();

        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('Flex_Rate_Pricing__c',true);

        Map<String, Object> flexRateProgramDetails = ApplicationOriginationTestHelper.getFlexRateProgramDetails();
        Map<String, Object> flexRatePricingDetails = getFlexRatePricing();

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
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion failed!');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission Save and Exit for flex rate my program and customized credit rating tier
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testCustomizedAppForFlexRateSaveAndExit() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();

        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('Flex_Rate_Pricing__c',true);

        Map<String, Object> flexRateProgramDetails = ApplicationOriginationTestHelper.getFlexRateProgramDetails();
        Map<String, Object> flexRatePricingDetails = getFlexRatePricing();

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
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion unsuccessful!');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission for Tier 1 credit rating
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testTierOneAppSubmit() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        List<genesis__Credit_Rating_Matrix__c> tier = [SELECT Id 
                                                                FROM genesis__Credit_Rating_Matrix__c 
                                                                WHERE Name = 'Tier 1'];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = tier[0].Id;
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
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion unsuccessful!');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application Save and Exit for Tier 1 credit rating
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testTierOneAppSaveAndExit() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        List<genesis__Credit_Rating_Matrix__c> tier = [SELECT Id 
                                                                FROM genesis__Credit_Rating_Matrix__c 
                                                                WHERE Name = 'Tier 1'];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = tier[0].Id;
        Database.update(applicationObj, true);

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCFAMyProgram();

        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('Credit_Application_And_Agreement_Process__c','Proceed with the requirements for the tier');
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => false,
            'note' => 'This is a test note!'
        };

        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion unsuccessful!');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission for Tier 2 credit rating
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testTierTwoAppSubmit() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        List<genesis__Credit_Rating_Matrix__c> tier = [SELECT Id 
                                                                FROM genesis__Credit_Rating_Matrix__c 
                                                                WHERE Name = 'Tier 2'];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = tier[0].Id;
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
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion unsuccessful!');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application Save and Exit for Tier 2 credit rating
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testTierTwoAppSaveAndExit() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        List<genesis__Credit_Rating_Matrix__c> tier = [SELECT Id 
                                                                FROM genesis__Credit_Rating_Matrix__c 
                                                                WHERE Name = 'Tier 2'];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = tier[0].Id;
        Database.update(applicationObj, true);

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCFAMyProgram();

        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('Credit_Application_And_Agreement_Process__c','Proceed with the requirements for the tier');
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => false,
            'note' => 'This is a test note!'
        };

        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion unsuccessful!');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission for Tier 3 credit rating
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testTierThreeAppSubmit() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        List<genesis__Credit_Rating_Matrix__c> tier = [SELECT Id 
                                                                FROM genesis__Credit_Rating_Matrix__c 
                                                                WHERE Name = 'Tier 3'];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = tier[0].Id;
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
        List<clcommon__Collateral__c> collateralObjList = [SELECT Id,
                                                                    Price__c
                                                                FROM clcommon__Collateral__c 
                                                                WHERE genesis__Application__c =:applicationObj.Id];
        collateralObjList[0].Price__c = 5000;
        Database.update(collateralObjList,true);
        
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion unsuccessful!');
            Test.stopTest();
        }
        
    }

    /**
    * @description : Testing application Save and Exit for Tier 3 credit rating
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testTierThreeAppSaveAndExit() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        List<genesis__Credit_Rating_Matrix__c> tier = [SELECT Id 
                                                                FROM genesis__Credit_Rating_Matrix__c 
                                                                WHERE Name = 'Tier 1'];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = tier[0].Id;
        Database.update(applicationObj, true);

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCFAMyProgram();

        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('Credit_Application_And_Agreement_Process__c','Proceed with the requirements for the tier');
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => false,
            'note' => 'This is a test note!'
        };
        List<clcommon__Collateral__c> collateralObjList = [SELECT Id,
                                                                    Price__c
                                                                FROM clcommon__Collateral__c 
                                                                WHERE genesis__Application__c =:applicationObj.Id];
        collateralObjList[0].Price__c = 5000;
        Database.update(collateralObjList,true);
        
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion unsuccessful!');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission for Tier 1 credit rating
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testTierOneWithFlexRateSubmit() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        List<genesis__Credit_Rating_Matrix__c> tier = [SELECT Id 
                                                                FROM genesis__Credit_Rating_Matrix__c 
                                                                WHERE Name = 'Tier 1'];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = tier[0].Id;
        Database.update(applicationObj, true);

        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('Flex_Rate_Pricing__c',true);
        applicationDetailsMap.put('Credit_Application_And_Agreement_Process__c','Proceed with the requirements for the tier');

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
            System.assert(response != null, 'Response is null');
            Test.stopTest();
        }
        
    }

    /**
    * @description : Testing application Save and Exit for Tier 1 credit rating
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testTierOneWithFlexRateSaveAndExit() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        List<genesis__Credit_Rating_Matrix__c> tier = [SELECT Id 
                                                                FROM genesis__Credit_Rating_Matrix__c 
                                                                WHERE Name = 'Tier 1'];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = tier[0].Id;
        Database.update(applicationObj, true);

        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('Flex_Rate_Pricing__c',true);
        applicationDetailsMap.put('Credit_Application_And_Agreement_Process__c','Proceed with the requirements for the tier');

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
            System.assert(response != null, 'Response is null');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission for Tier 2 credit rating
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testTierTwoWithFlexRateSubmit() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        List<genesis__Credit_Rating_Matrix__c> tier = [SELECT Id 
                                                                FROM genesis__Credit_Rating_Matrix__c 
                                                                WHERE Name = 'Tier 2'];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = tier[0].Id;
        Database.update(applicationObj, true);

        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('Flex_Rate_Pricing__c',true);
        applicationDetailsMap.put('Credit_Application_And_Agreement_Process__c','Proceed with the requirements for the tier');

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
            System.assert(response != null, 'Response is null');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application Save and Exit for Tier 2 credit rating
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testTierTwoWithFlexRateSaveAndExit() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        List<genesis__Credit_Rating_Matrix__c> tier = [SELECT Id 
                                                                FROM genesis__Credit_Rating_Matrix__c 
                                                                WHERE Name = 'Tier 2'];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = tier[0].Id;
        Database.update(applicationObj, true);

        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('Flex_Rate_Pricing__c',true);
        applicationDetailsMap.put('Credit_Application_And_Agreement_Process__c','Proceed with the requirements for the tier');

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
            System.assert(response != null, 'Response is null');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission for Tier 3 credit rating
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testTierThreeWithFlexRateSubmit() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        List<genesis__Credit_Rating_Matrix__c> tier = [SELECT Id 
                                                                FROM genesis__Credit_Rating_Matrix__c 
                                                                WHERE Name = 'Tier 3'];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = tier[0].Id;
        Database.update(applicationObj, true);

        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('Flex_Rate_Pricing__c',true);
        applicationDetailsMap.put('Credit_Application_And_Agreement_Process__c','Proceed with the requirements for the tier');

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
        List<clcommon__Collateral__c> collateralObjList = [SELECT Id,
                                                                    Price__c
                                                                FROM clcommon__Collateral__c 
                                                                WHERE genesis__Application__c =:applicationObj.Id];
        collateralObjList[0].Price__c = 5000;
        Database.update(collateralObjList,true);
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assert(response != null, 'Response is null');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application Save and Exit for Tier 3 credit rating
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testTierThreeWithFlexRateSaveNExit() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        List<genesis__Credit_Rating_Matrix__c> tier = [SELECT Id 
                                                                FROM genesis__Credit_Rating_Matrix__c 
                                                                WHERE Name = 'Tier 3'];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = tier[0].Id;
        Database.update(applicationObj, true);

        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('Flex_Rate_Pricing__c',true);
        applicationDetailsMap.put('Credit_Application_And_Agreement_Process__c','Proceed with the requirements for the tier');

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
        List<clcommon__Collateral__c> collateralObjList = [SELECT Id,
                                                                    Price__c
                                                                FROM clcommon__Collateral__c 
                                                                WHERE genesis__Application__c =:applicationObj.Id];
        collateralObjList[0].Price__c = 5000;
        Database.update(collateralObjList,true);
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assert(response != null, 'Response is null');
            Test.stopTest();
        }
       
    }


     /**
    * @description : Testing application Save and Exit for without my program without flex rate
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testWithoutRateCardSaveNExit() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        List<genesis__Credit_Rating_Matrix__c> tier = [SELECT Id 
                                                                FROM genesis__Credit_Rating_Matrix__c 
                                                                WHERE Name = 'Tier 1'];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = tier[0].Id;
        Database.update(applicationObj, true);

        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('Credit_Application_And_Agreement_Process__c','Proceed with the requirements for the tier');

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => false,
            'note' => 'This is a test note!'
        };

        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion unsuccessful!');
            Test.stopTest();
        }
    }


    /**
    * @description : Testing Customized application Save and Exit for without my program without flex rate
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testCustAppWithoutRateCardSaveNExit() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();

        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => false,
            'note' => 'This is a test note!'
        };

        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion unsuccessful!');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing request second look application submission for Tier 3 credit rating 
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testReqScndLookAppSubmit() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

         List<genesis__Credit_Rating_Matrix__c> tier = [SELECT Id 
                                                                FROM genesis__Credit_Rating_Matrix__c 
                                                                WHERE Name = 'Tier 3'];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = tier[0].Id;
        Database.update(applicationObj, true);

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCFAMyProgram();

        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('Credit_Application_And_Agreement_Process__c','Request second look');
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);
        applicationDetailsMap.put('Do_You_Recommend_Second_Look__c',true);

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };
        List<clcommon__Collateral__c> collateralObjList = [SELECT Id,
                                                                    Price__c
                                                                FROM clcommon__Collateral__c 
                                                                WHERE genesis__Application__c =:applicationObj.Id];
        collateralObjList[0].Price__c = 5000;
        Database.update(collateralObjList,true);
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion unsuccessful!');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing autobook application submission 
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testAutoBookForExistingApplicant() {
        // NLSBookToCoreCIFCalloutClass.doChainJob = false;

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Credit_Rating_Matrix__c> tier = [SELECT Id 
                                                                FROM genesis__Credit_Rating_Matrix__c 
                                                                WHERE Name = 'Tier 1'];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = tier[0].Id;
        applicationObj.Signing_Method__c = PortalConstants.IN_PERSON_DOCUSIGN;
        applicationObj.Agreement_Sign__c = true;
        Database.update(applicationObj, true);

        List<Task> entityTaskObj = [SELECT Id,
                                    Status
                                FROM Task 
                                WHERE Subject = :PortalConstants.ENTITY_DOC_TASK
                                AND genesis__Application__c = :applicationObj.Id];

        entityTaskObj[0].Status = PortalConstants.OPEN_TASK_STATUS;
        Database.update(entityTaskObj, true);

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
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion unsuccessful!');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing autobook application submission 
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testAutoBookForNewApplicant() {
        // NLSBookToCoreCIFCalloutClass.doChainJob = false;

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        List<genesis__Credit_Rating_Matrix__c> tier = [SELECT Id 
                                                                FROM genesis__Credit_Rating_Matrix__c 
                                                                WHERE Name = 'Tier 1'];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = tier[0].Id;
        applicationObj.Signing_Method__c = PortalConstants.IN_PERSON_DOCUSIGN;
        applicationObj.Agreement_Sign__c = true;
        Database.update(applicationObj, true);

        List<Task> entityTaskObj = [SELECT Id,
                                    Status
                                FROM Task 
                                WHERE Subject = :PortalConstants.ENTITY_DOC_TASK
                                AND genesis__Application__c = :applicationObj.Id];

        entityTaskObj[0].Status = PortalConstants.OPEN_TASK_STATUS;
        Database.update(entityTaskObj, true);

        List<genesis__Applications__c> existingAppList = [SELECT Id, 
                                                            genesis__Status__c 
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Number__c = '116623344'];
        existingAppList[0].genesis__Status__c = 'NEW - SCORECARD GENERATED';
        Database.update(existingAppList,true);
        
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
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion unsuccessful!');
            Test.stopTest();
        }
    }

    

    /**
    * @description : Testing application submission success for flex rate my program and customized credit rating tier for Growmark
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testFlexRateSubmitForGrowmark() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();

        List<Account> dealerAccList =[SELECT Id,
                                            Coop_Type__c 
                                        FROM Account 
                                        WHERE Id=:applicationObj.Dealer_Name__c];
        dealerAccList[0].Coop_Type__c='Growmark';
        Database.update(dealerAccList,true);

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
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion unsuccessful!');
            Test.stopTest();
        }
    }

    /**
    * @description : testing deleting existing sales agent and IRC to application
    * @author Suraj Kumar | 04-12-2024 
    **/
    @isTest
    private static void testDeleteExistingSaIrc(){
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        List<genesis__Credit_Rating_Matrix__c> tier = [SELECT Id 
                                                                FROM genesis__Credit_Rating_Matrix__c 
                                                                WHERE Name = 'Tier 1'];
        List<Account> saAccountList = [SELECT Id 
                                            FROM Account 
                                            WHERE Name = 'Tony Stark'
                                            LIMIT 1];
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = tier[0].Id;
        applicationObj.Signing_Method__c = PortalConstants.IN_PERSON_DOCUSIGN;
        applicationObj.Sales_Agent__c = saAccountList[0].Id;
        applicationObj.Internal_Reference_Code__c = '7656';
        applicationObj.Agreement_Sign__c = true;
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
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion unsuccessful!');
            Test.stopTest();
        }
    }

    /**
    * @description : testing Updating existing Sa , IRC, ErP Id application
    * @author Suraj Kumar | 04-12-2024 
    **/
    @isTest
    private static void testUpdateSaIrcErp(){
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        List<genesis__Credit_Rating_Matrix__c> tier = [SELECT Id 
                                                                FROM genesis__Credit_Rating_Matrix__c 
                                                                WHERE Name = 'Tier 1'];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = tier[0].Id;
        applicationObj.Signing_Method__c = PortalConstants.IN_PERSON_DOCUSIGN;
        applicationObj.Internal_Reference_Code__c = '3412';
        applicationObj.Agreement_Sign__c = true;
        Database.update(applicationObj, true);
        
        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCFAMyProgram();

        List<Account> saAccountList = [SELECT Id 
                                        FROM Account 
                                        WHERE Name = 'Tony Stark'
                                        LIMIT 1];

        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('Credit_Application_And_Agreement_Process__c','Proceed with the requirements for the tier');
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);
        applicationDetailsMap.put('ERP_Id__c','8712');
        applicationDetailsMap.put('Internal_Reference_Code__c', '8912');
        applicationDetailsMap.put('Sales_Agent__c', saAccountList[0].Id);


        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };
        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response response = api.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion unsuccessful!');
            Test.stopTest();
        }
    }

    /**
    * @description : Purpose of this method is to ensure '-A' is not appended with loan no for the single child loans
    * @author Tuhin Bhunia | 05-01-2024 
    **/
    @isTest
    private static void testSingleChildLoanCheck(){
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();

        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('Flex_Rate_Pricing__c',true);

        Map<String, Object> flexRateProgramDetails = ApplicationOriginationTestHelper.getFlexRateProgramDetails();
        Map<String, Object> flexRatePricingDetails = getFlexRatePricingDetails();
        flexRatePricingDetails.put('SpecialTermB', new Map<String, Object>());

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
            System.assert(response != null, 'Response is null');
            Test.stopTest();
        }
    }

    /**
    * @description The purpose of this method is to test for a no score applicant. When we score an application with a no score applicant, te score of the applicant is wither 9002 or 9003. So the application is tier three and should not require additional info when the cl chooses request second look for the credit application and agreement process
    * @author Rakesh Saraf | 10-16-2024 
    **/
    @IsTest
    private static void testTierThreeAppSubmitWithNoScoreApplicant() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        List<genesis__Credit_Rating_Matrix__c> tier = [SELECT Id FROM genesis__Credit_Rating_Matrix__c WHERE Name = 'Tier 3'];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = tier[0].Id;
        Database.update(applicationObj, true);

        Account borrowerAccount=ApplicationOriginationTestHelper.getBorrowerAccount();
        borrowerAccount.Score_1__c='9002';

        Account principalAccount=ApplicationOriginationTestHelper.getprincipalAccount();
        principalAccount.Score_1__c='9002';

        Database.update(new List<Account>{borrowerAccount,principalAccount},true);

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCFAMyProgram();

        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('Credit_Application_And_Agreement_Process__c','Request Second Look');
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };
        List<clcommon__Collateral__c> collateralObjList = [SELECT Id,
                                                                    Price__c
                                                                FROM clcommon__Collateral__c 
                                                                WHERE genesis__Application__c =:applicationObj.Id];
        
        Database.delete(collateralObjList,true);

        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI submissionApi = new PortalApplicationSubmissionAPI();
            clcommon.Response response = submissionApi.invokeAction(null, null, requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS,response.status,  'Assertion unsuccessful!');
            Test.stopTest();
        }
    }

     /**
    * @description The purpose of this method is to test for a no score applicant. When we score an application with a no score applicant, te score of the applicant is wither 9002 or 9003. So the application is tier three and should not require additional info when the cl chooses request second look for the credit application and agreement process
    * @author Ayush Kumar Singh | 10-16-2024 
    **/
    @IsTest
    private static void testTierThreeAppSubmitForInsufficientCollateralError() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        List<genesis__Credit_Rating_Matrix__c> tier = [SELECT Id FROM genesis__Credit_Rating_Matrix__c WHERE Name = 'Tier 3'];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = tier[0].Id;
        Database.update(applicationObj, true);

        Account borrowerAccount=ApplicationOriginationTestHelper.getBorrowerAccount();
        borrowerAccount.Score_1__c='610';

        Account principalAccount=ApplicationOriginationTestHelper.getprincipalAccount();
        principalAccount.Score_1__c='610';

        Database.update(new List<Account>{borrowerAccount,principalAccount},true);

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCFAMyProgram();

        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('Credit_Application_And_Agreement_Process__c','Request Second Look');
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);

        Map<String, Object> requestMap = new Map<String, Object> {
            'application' => JSON.serialize(applicationDetailsMap),
            'shouldValidate' => true,
            'note' => 'This is a test note!'
        };
        List<clcommon__Collateral__c> collateralObjList = [SELECT Id,
                                                                    Price__c
                                                                FROM clcommon__Collateral__c 
                                                                WHERE genesis__Application__c =:applicationObj.Id];
        
        Database.delete(collateralObjList,true);

        System.runAs(clUserObj) {
            Test.startTest();
            PortalApplicationSubmissionAPI api = new PortalApplicationSubmissionAPI();
            clcommon.Response responseObj = api.invokeAction(null, null, requestMap);
            System.assertEquals(String.valueOf(PortalConstants.INSUFFICIENT_COLLATERALS).replace(' to match the loan amount', ''), responseObj.errorMessage, 'Assertion unsuccessful!');
            Test.stopTest();
        }
    }
}