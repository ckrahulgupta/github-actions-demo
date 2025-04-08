/**
 * @description       : Test class for PortalApplicationSubmissionAPI for Dba Entity Type
 * @author            : Suraj Kumar
 * @group             : 
 * @last modified on  : 01-26-2025
 * @last modified by  : Ayan Bhowmik
**/
@IsTest
public without sharing class PortalApplicationSubmissionAPIDbaTest {
    @TestSetup
    static void setup() {
        
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
        Database.insert(new List<genesis__Business_Information__c>{dealerBusinessInfoObj, borrowerBusinessInfoObj,principalBusinessInfoObj},true);

        // Creating Account for Dealer
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        dealerAccountObj.CFA_Partner_Program__c = newPartnerProgramObj.Id;
        Database.insert(dealerAccountObj, true);

        // Creating Account for Certified Lender
        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
        Database.insert(clAccountObj, true);

        // Creating Contact for Certified Lender
        Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.Id);
        Database.insert(clContactObj,true);

        List<User> userObjList = new List<User>();

        userObjList.add(ApplicationOriginationTestHelper.createCLUser(clContactObj.Id));

        // Creating Legal Entity for Borrower
        clcommon__Legal_Entity__c entityObj = ApplicationOriginationTestHelper.createDBALegalEntity();
        Database.insert(entityObj, true);

        // Creating Account for Borrower
        Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(entityObj, borrowerBusinessInfoObj.Id);
        borrowerAccountObj.BillingStreet = 'Action area 1';
        Database.insert(borrowerAccountObj, true);

        // Creating Contact for Borrower
        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.Id);
        borrowerContactObj.Confirm_SSN__c = 'GHFB6766';
        Database.insert(borrowerContactObj,true);

        userObjList.add(ApplicationOriginationTestHelper.createBorrowerUser(borrowerContactObj.Id));
        Database.insert(userObjList,true);

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
        applicationObj.Signing_Method__c = 'Paper - Scanned';
        Database.insert(applicationObj, true);

        // Creating Reciprocal Role 
        clcommon__Reciprocal_Role__c roleObj = ApplicationOriginationTestHelper.createCertifiedLenderRole();
        Database.insert(roleObj, true);

        // Creating Relationship between Dealer and Certified Lender
        clcommon__Relationship__c clDealerRelationshipObj = ApplicationOriginationTestHelper.createCLDealerRelationship(roleObj,dealerAccountObj.Id,clAccountObj.Id);
        Database.insert(clDealerRelationshipObj, true);

        // Creating Certified Lender Party Type
        clcommon__Party_Type__c clPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('CERTIFIED LENDER');
        //Database.insert(clPartyTypeObj, true);

        // Create Borrower Party Type
        clcommon__Party_Type__c borrowerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('BORROWER');
        clcommon__Party_Type__c principalPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('PRINCIPAL');
        Database.insert(new List<clcommon__Party_Type__c> {clPartyTypeObj,borrowerPartyTypeObj,principalPartyTypeObj}, true);

        // Creating Certified Lender Party
        Map<String,Id> paramForCLPartyMap = new Map<String,Id>{
        'accountId' => clAccountObj.Id,
        'contactId' => clContactObj.Id,
        'partyTypeId' => clPartyTypeObj.Id,
        'applicationId' => applicationObj.Id
        };

        List<clcommon__Party__c> partyObjList = new List<clcommon__Party__c>();

        partyObjList.add(ApplicationOriginationTestHelper.createParty(paramForCLPartyMap));


        Map<String,Id> paramForBorrowerPartyMap = new Map<String,Id>{
        'accountId' => borrowerAccountObj.Id,
        'contactId' => borrowerContactObj.Id,
        'partyTypeId' => borrowerPartyTypeObj.Id,
        'applicationId' => applicationObj.Id
        };

        partyObjList.add(ApplicationOriginationTestHelper.createApplicantParty(paramForBorrowerPartyMap,borrowerAccountObj));

        ApplicationOriginationSetupTestHelper.createSaSaAdminTestData(dealerBusinessInfoObj,dealerAccountObj);
        ApplicationOriginationSetupTestHelper.createAdditionalTestData(applicationObj,dealerAccountObj);

        genesis__Applications__c existingApplicationObj = ApplicationOriginationTestHelper.createCurrCropYearApplication(paramForApplicationMap);
        existingApplicationObj.genesis__Loan_Number__c = '116623344';
        Database.insert(existingApplicationObj,true);

        Map<String,Id> paramForExistingBorrower = new Map<String,Id>{
        'accountId' => borrowerAccountObj.Id,
        'contactId' => borrowerContactObj.Id,
        'partyTypeId' => borrowerPartyTypeObj.Id,
        'applicationId' => existingApplicationObj.Id
        };

        partyObjList.add(ApplicationOriginationTestHelper.createApplicantParty(paramForExistingBorrower, borrowerAccountObj));
        Database.insert(partyObjList,true);

        Account coBorrowerAccountObj = ApplicationOriginationTestHelper.createCoBorrowerAccount(entityObj,principalBusinessInfoObj.Id);
        coBorrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CoApplicant').getRecordTypeId();
        coBorrowerAccountObj.BillingStreet = 'Action area 1';
        coBorrowerAccountObj.BillingPostalCode = '10038';
        coBorrowerAccountObj.Phone = '1111111111';
        Database.insert(coBorrowerAccountObj,true);

        //Creating Co-Applicant contact
        Contact coBorrowerContactObj = ApplicationOriginationTestHelper.createCoBorrowerContact(coBorrowerAccountObj.Id);
        coBorrowerContactObj.Confirm_SSN__c='982983834';
        Database.insert(coBorrowerContactObj,true);

        Dealer_Applicant_Relationship__c dealerCoAppRelObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(coBorrowerContactObj,dealerAccountObj.id);
        Database.insert(dealerCoAppRelObj,true);

        ApplicationOriginationSetupTestHelper.createAdditionalInfoParty(applicationObj, entityObj,borrowerBusinessInfoObj);

        Map<String,Id> paramMapForCoBorrower = new Map<String,Id>{
        'accountId' => coBorrowerAccountObj.Id,
        'contactId' => coBorrowerContactObj.Id,
        'partyTypeId' => principalPartyTypeObj.Id,
        'applicationId' => applicationObj.Id
        };

        clcommon__Party__c coBorrowerPartyObj = ApplicationOriginationTestHelper.createApplicantParty(paramMapForCoBorrower,coBorrowerAccountObj);
        coBorrowerPartyObj.Dealer_Applicant_Relationship__c = dealerCoAppRelObj.id;
        //Database.insert(coBorrowerPartyObj,true);

        Map<String,Id> existingAppParamMap = new Map<String,Id>{
        'accountId' => coBorrowerAccountObj.Id,
        'contactId' => coBorrowerContactObj.Id,
        'partyTypeId' => principalPartyTypeObj.Id,
        'applicationId' => existingApplicationObj.Id
        };

        clcommon__Party__c existingAppPartyObj = ApplicationOriginationTestHelper.createApplicantParty(existingAppParamMap,coBorrowerAccountObj);
        existingAppPartyObj.Dealer_Applicant_Relationship__c = dealerCoAppRelObj.id;
        Database.insert(new List<clcommon__Party__c>{coBorrowerPartyObj,existingAppPartyObj},true);
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
                        'Start_Date__c' => Date.valueOf('2023-09-19'),
                        'End_Date__c' => Date.valueOf('2025-03-15'),
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
                        'Start_Date__c' => Date.valueOf('2023-09-19'),
                        'End_Date__c' => Date.valueOf('2025-03-15'),
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
    * @description : Testing application submission with my program and Credit_Application_And_Agreement_Process__c Customized for CFA
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testCustomizedAppSubmitDba() {

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
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion success!');
            Test.stopTest();
        }
        
    }

    /**
    * @description : Testing application save and exit with my program and Credit_Application_And_Agreement_Process__c Customized for CFA
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testCustomizedAppSaveAndExitDba() {

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
            'shouldValidate' => false,
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
    * @description : Testing application submission for Tier 1 credit rating
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testTierOneAppSubmitDba() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Credit_Rating_Matrix__c tier = [SELECT Id FROM genesis__Credit_Rating_Matrix__c WHERE Name = 'Tier 1'];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = tier.Id;
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
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion success!');
            Test.stopTest();
        }
        
    }

    /**
    * @description : Testing application Save and Exit for Tier 1 credit rating
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testTierOneAppSaveAndExitDba() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Credit_Rating_Matrix__c tier = [SELECT Id FROM genesis__Credit_Rating_Matrix__c WHERE Name = 'Tier 1'];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = tier.Id;
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
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion success!');
            Test.stopTest();
        }
        
    }

    /**
    * @description : Testing application submission for Tier 2 credit rating
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testTierTwoAppSubmitDba() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Credit_Rating_Matrix__c tier = [SELECT Id FROM genesis__Credit_Rating_Matrix__c WHERE Name = 'Tier 2'];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = tier.Id;
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
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion success!');
            Test.stopTest();
        }
        
    }

    /**
    * @description : Testing application Save and Exit for Tier 2 credit rating
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testTierTwoAppSaveAndExitDba() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Credit_Rating_Matrix__c tier = [SELECT Id FROM genesis__Credit_Rating_Matrix__c WHERE Name = 'Tier 2'];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = tier.Id;
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
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion success!');
            Test.stopTest();
        }
        
    }

    /**
    * @description : Testing application submission for Tier 3 credit rating
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testTierThreeAppSubmitDba() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Credit_Rating_Matrix__c tier = [SELECT Id FROM genesis__Credit_Rating_Matrix__c WHERE Name = 'Tier 3'];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = tier.Id;
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
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion success!');
            Test.stopTest();
        }
       
    }

    /**
    * @description : Testing application Save and Exit for Tier 3 credit rating
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testTierThreeAppSaveAndExitDba() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Credit_Rating_Matrix__c tier = [SELECT Id FROM genesis__Credit_Rating_Matrix__c WHERE Name = 'Tier 3'];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = tier.Id;
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
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion success!');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing application submission for Tier 1 credit rating
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testTierOneWithFlexRateSubmitDba() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Credit_Rating_Matrix__c tier = [SELECT Id FROM genesis__Credit_Rating_Matrix__c WHERE Name = 'Tier 1'];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = tier.Id;
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
    private static void testTierOneWithFlexRateSaveAndExitDba() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Credit_Rating_Matrix__c tier = [SELECT Id FROM genesis__Credit_Rating_Matrix__c WHERE Name = 'Tier 1'];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = tier.Id;
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
    private static void testTierTwoWithFlexRateSubmitDba() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Credit_Rating_Matrix__c tier = [SELECT Id FROM genesis__Credit_Rating_Matrix__c WHERE Name = 'Tier 2'];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = tier.Id;
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
    * @description : Testing application submission for Tier 3 credit rating
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testTierThreeWithFlexRateSubmitDba() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Credit_Rating_Matrix__c tier = [SELECT Id FROM genesis__Credit_Rating_Matrix__c WHERE Name = 'Tier 3'];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = tier.Id;
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
    * @description : Testing application submission for without my program without flex rate
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testWithoutRateCardSubmitDba() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Credit_Rating_Matrix__c tier = [SELECT Id FROM genesis__Credit_Rating_Matrix__c WHERE Name = 'Tier 1'];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = tier.Id;
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
    * @description : Testing application Save and Exit for without my program without flex rate
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testWithoutRateCardSaveNExitDba() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Credit_Rating_Matrix__c tier = [SELECT Id FROM genesis__Credit_Rating_Matrix__c WHERE Name = 'Tier 1'];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = tier.Id;
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
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion success!');
            Test.stopTest();
        }
    }

    /**
    * @description : Testing autobook application submission 
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testAutoBookForDba() {
        // NLSBookToCoreCIFCalloutClass.doChainJob = false;

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Credit_Rating_Matrix__c tier = [SELECT Id FROM genesis__Credit_Rating_Matrix__c WHERE Name = 'Tier 1'];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = tier.Id;
        applicationObj.Signing_Method__c = PortalConstants.IN_PERSON_DOCUSIGN;
        applicationObj.Agreement_Sign__c = true;
        Database.update(applicationObj, true);

        Task entityTaskObj = [SELECT Id,
                                    Status
                                FROM Task 
                                WHERE Subject = :PortalConstants.ENTITY_DOC_TASK
                                AND genesis__Application__c = :applicationObj.Id];

        entityTaskObj.Status = PortalConstants.OPEN_TASK_STATUS;
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
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion success!');
            Test.stopTest();
        }
    }


    /**
    * @description : Testing Flex pricing null for Submit
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testFlexPricingNullSubmitDba() {

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
    private static void testNullCreditRatingSubmitDba() {

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
    private static void testInsufficientCollateralsDba() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Credit_Rating_Matrix__c tier = [SELECT Id FROM genesis__Credit_Rating_Matrix__c WHERE Name = 'Tier 3'];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = tier.Id;
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
    private static void testIsevergreenWithoutTierDba() {

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
    * @description : Testing Rejected application 
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testRejectedAppSubmitDba() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCFAMyProgram();

        genesis__Credit_Rating_Matrix__c tier = [SELECT Id FROM genesis__Credit_Rating_Matrix__c WHERE Name = 'Tier 1'];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = tier.Id;
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
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion success!');
            Test.stopTest();
        }
    }

    /**
    * @description : testing deleting existing sales agent and IRC to application
    * @author Suraj Kumar | 04-12-2024 
    **/
    @isTest
    private static void testDeleteExistingSaIrcDba(){
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Credit_Rating_Matrix__c tier = [SELECT Id FROM genesis__Credit_Rating_Matrix__c WHERE Name = 'Tier 1'];
        Account saAccountObj = [SELECT Id 
                                        FROM Account 
                                        WHERE Name = 'Tony Stark'
                                        LIMIT 1];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = tier.Id;
        applicationObj.Signing_Method__c = PortalConstants.IN_PERSON_DOCUSIGN;
        applicationObj.Sales_Agent__c = saAccountObj.Id;
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
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion success!');
            Test.stopTest();
        }
    }

    /**
    * @description : testing deleting existing ErP Id application
    * @author Suraj Kumar | 04-12-2024 
    **/
    @isTest
    private static void testDeleteExistingERPDba(){
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Credit_Rating_Matrix__c tier = [SELECT Id FROM genesis__Credit_Rating_Matrix__c WHERE Name = 'Tier 1'];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = tier.Id;
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
    * @description : testing Updating existing Sa , IRC, ErP Id application
    * @author Suraj Kumar | 04-12-2024 
    **/
    @isTest
    private static void testUpdateSaIrcErpDba(){
        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Credit_Rating_Matrix__c tier = [SELECT Id FROM genesis__Credit_Rating_Matrix__c WHERE Name = 'Tier 1'];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = tier.Id;
        applicationObj.Signing_Method__c = PortalConstants.IN_PERSON_DOCUSIGN;
        applicationObj.Internal_Reference_Code__c = '3412';
        applicationObj.Agreement_Sign__c = true;
        Database.update(applicationObj, true);
        
        genesis__Rate_Card_Setup_Header__c rateCardObj = ApplicationOriginationTestHelper.getCFAMyProgram();

        Account saAccountObj = [SELECT Id 
                                        FROM Account 
                                        WHERE Name = 'Tony Stark'
                                        LIMIT 1];

        Map<String, Object> applicationDetailsMap = ApplicationOriginationTestHelper.getApplicationDetails();
        applicationDetailsMap.put('Id',applicationObj.Id);
        applicationDetailsMap.put('Credit_Application_And_Agreement_Process__c','Proceed with the requirements for the tier');
        applicationDetailsMap.put('My_Program__c',rateCardObj.Id);
        applicationDetailsMap.put('ERP_Id__c','8712');
        applicationDetailsMap.put('Internal_Reference_Code__c', '8912');
        applicationDetailsMap.put('Sales_Agent__c', saAccountObj.Id);


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
    * @description : Testing application submission without  Spouse
    * @author Suraj Kumar | 04-08-2024 
    **/
    @IsTest
    private static void testWithoutSpouseParty() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Credit_Rating_Matrix__c tier = [SELECT Id FROM genesis__Credit_Rating_Matrix__c WHERE Name = 'Tier 3'];
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = tier.Id;
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
        collateralObjList[0].Price__c = 50000;
        Database.update(collateralObjList,true);

        Account principalAccObj = [SELECT Id FROM Account WHERE Name = 'Mike Johnson'];
        clcommon__Party__c principalPartyObj = [SELECT Id, Marital_Status__c 
                                                    FROM clcommon__Party__c 
                                                    WHERE clcommon__Account__c = :principalAccObj.id 
                                                    AND genesis__Application__c =: applicationObj.id ];

        principalPartyObj.Marital_Status__c = 'Married';
        Database.update(principalPartyObj,true);

        clcommon__Party__c partyObj = [SELECT Id,

                                                genesis__Application__c
                                            FROM clcommon__Party__c 
                                            WHERE genesis__Application__c = :applicationObj.Id
                                            AND clcommon__Party_Types__c = 'SPOUSE' LIMIT 1];
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
    * @description Thhe purpose of this method is to test for a no score applicant. When the application with a no score primary applicant is scored for a dba, the fico score on the application is null. Hence when the cl chooses request second look in the credit agreement and application process, the additional info must not be required.
    * @author Rakesh Saraf | 10-16-2024 
    **/
    @IsTest
    private static void testTierThreeAppSubmitDbaNoScoreApplicant() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Credit_Rating_Matrix__c tier = [SELECT Id FROM genesis__Credit_Rating_Matrix__c WHERE Name = 'Tier 3'];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = tier.Id;
        Database.update(applicationObj, true);

        Account principalAccount=ApplicationOriginationTestHelper.getPrincipalAccount();
        principalAccount.Score_1__c='9002';
        Database.update(principalAccount,true);

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

            System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'Assertion success!');
            Test.stopTest();
        }
        
    }
    /**
    * @description Thhe purpose of this method is to test for a no score applicant. When the application with a no score primary applicant is scored for a dba, the fico score on the application is null. Hence when the cl chooses request second look in the credit agreement and application process, the additional info must not be required.
    * @author Ayush Kuamr Singh | 10-16-2024 
    **/
    @IsTest
    private static void testTierThreeAppSubmitDbaForInsufficientCollateral() {

        User clUserObj =  ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        genesis__Credit_Rating_Matrix__c tier = [SELECT Id FROM genesis__Credit_Rating_Matrix__c WHERE Name = 'Tier 3'];

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = tier.Id;
        Database.update(applicationObj, true);

        Account principalAccount=ApplicationOriginationTestHelper.getPrincipalAccount();
        principalAccount.Score_1__c='610';
        Database.update(principalAccount,true);

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
            System.assertEquals(String.valueOf(PortalConstants.INSUFFICIENT_COLLATERALS).replace(' to match the loan amount', ''), responseObj.errorMessage, 'Assertion success!');
            Test.stopTest();
        }
        
    }
}