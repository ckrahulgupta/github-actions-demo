/**********************************************************************************************************************
 * @description       : This is a test class for ScheduleMobileDepositReportDocument
 * @author            : Sanjana De
 * @group             : 
 * @last modified on  : 01-27-2025
 * @last modified by  : Kabir Pramanik
**********************************************************************************************************************/
@isTest(seeAllData = true)
public with sharing class TestScheduleMobileDepositReportDocument {
    /**
    * @description create the test datas for testing(cannot have @TestSetup)
    * @author Kabir Pramanik | 01-10-2025 
    **/
    private static void createTestData(){
        clcommon__Floating_Rate_Index__c floatingRateIndexObj = LoanServicingTestHelper.createFloatingRateIndex(
            New Map<String, Object>{'Name' => 'Field Finance Rate',
                                    'Base Rate Name' => '4-CFA ADVANTAGE',
                                    'Current Floating Rate' => 11,
                                    'Base Rate Adjuster' => 5.5
            });
        Database.insert(floatingRateIndexObj, true);

        // Creating new partnert program
        CFA_Partner_Program__c newPartnerProgramObj = LoanServicingTestHelper.createPartnerProgram(floatingRateIndexObj);
        Database.insert(newPartnerProgramObj, true);

        //Creating business infos
        genesis__Business_Information__c dealerBusinessInfoObj = LoanServicingTestHelper.createBusinessInfoForDealer();
        genesis__Business_Information__c borrowerBusinessInfoObj = LoanServicingTestHelper.createBusinessInfoForBorrower();
        Database.insert(new List<genesis__Business_Information__c> {dealerBusinessInfoObj , borrowerBusinessInfoObj}, true);

        // Creating Legal Entity for Borrower
        clcommon__Legal_Entity__c entityObj = LoanServicingTestHelper.createLegalEntity(ConstantValues.SOLE_PROP_ENTITY);
        Database.insert(entityObj, true);

        // Creating Accounts
        Account dealerAccountObj = LoanServicingTestHelper.createDealerAccount(dealerBusinessInfoObj.Id, newPartnerProgramObj.Id);
        Database.insert(dealerAccountObj, true);
        Account clAccountObj = LoanServicingTestHelper.createCLAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
        Account borrowerAccountObj = LoanServicingTestHelper.createSolePropAccount(entityObj, borrowerBusinessInfoObj.Id);
        borrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Grower').getRecordTypeId();
        Database.insert(new List<Account> {clAccountObj,borrowerAccountObj}, true);

        // Creating Contacts
        Contact clContactObj = LoanServicingTestHelper.createCLContact(clAccountObj.Id);
        Contact borrowerContactObj = LoanServicingTestHelper.createBorrowerContact(borrowerAccountObj.Id);
        Database.insert(new List<Contact> {clContactObj,borrowerContactObj},true);

        //Creating users
        User clUserObj = LoanServicingTestHelper.createCLUser(clContactObj.Id);
        User borrowerUserObj = LoanServicingTestHelper.createBorrowerUser(borrowerContactObj.Id);
        Database.insert(new List<User> {clUserObj,borrowerUserObj}, true);

        // Creating CL Purpose of Application
        clcommon__CL_Purpose__c clPurposeObj = LoanServicingTestHelper.createCLPurposeForApplication();
        Database.insert(clPurposeObj, true);

        // Creating Cl Product of Application
        clcommon__CL_Product__c clProductObj = LoanServicingTestHelper.createCLProductForApplication();
        Database.insert(clProductObj, true);

        //creating dealer_applicant_relationship__c
        dealer_applicant_relationship__c dealerApplRelationshipObj = LoanServicingTestHelper.createDealerApplicantRelationship(borrowerContactObj, dealerAccountObj.Id);
        Database.insert(dealerApplRelationshipObj, true);

        genesis__Rate_Card_Setup_Header__c rateCardHeaderObj = LoanServicingTestHelper.createRateCardHeader(dealerAccountObj);
        rateCardHeaderObj.genesis__Start_Date__c = System.today();
        rateCardHeaderObj.genesis__End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        Database.insert(rateCardHeaderObj,true);

        genesis__Rate_Card_Setup_Detail__c specialTermAA =  LoanServicingTestHelper.createRateCardSetupDetail(rateCardHeaderObj);
        specialTermAA.Special_Term_Reference__c = 'Special Term Sub-Tranche (A)';
        specialTermAA.Start_Date__c = System.Today();
        specialTermAA.End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);

        genesis__Rate_Card_Setup_Detail__c specialTermBA =  LoanServicingTestHelper.createRateCardSetupDetail(rateCardHeaderObj);
        specialTermBA.Special_Term_Reference__c = 'Special Term Sub-Tranche (B)';
        specialTermBA.Start_Date__c = System.Today();
        specialTermBA.End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);

        Database.insert(new List<genesis__Rate_Card_Setup_Detail__c> {specialTermAA,specialTermBA},true);

        // // Creating map for Application
        Map<String,Id> paramForApplicationMap = new Map<String,Id>{
            'dealerAccountId' => dealerAccountObj.Id,
            'clProductId' => clProductObj.Id,
            'clPurposeId' => clPurposeObj.Id,
            'borrowerAccountId' => borrowerAccountObj.Id,
            'borrowerContactId' => borrowerContactObj.Id,
            'clAccountId' => clAccountObj.Id,
            'dealerApplicantRelationshipId' => dealerApplRelationshipObj.Id
        };

        // Creating Application
        genesis__Applications__c applicationObj = LoanServicingTestHelper.createCurrCropYearApplication(paramForApplicationMap);
        applicationObj.My_Program__c = rateCardHeaderObj.Id;
        Database.insert(applicationObj, true);

        // Creating Reciprocal Role 
        clcommon__Reciprocal_Role__c roleObj = LoanServicingTestHelper.createReciprocalRole(ConstantValues.CERTIFIED_LENDER);
        Database.insert(roleObj, true);

        // Creating Relationship between Dealer and Certified Lender
        clcommon__Relationship__c clDealerRelationshipObj = LoanServicingTestHelper.createCLDealerRelationship(roleObj, dealerAccountObj.Id, clAccountObj.Id);
        Database.insert(clDealerRelationshipObj, true);

        // Creating party types
        clcommon__Party_Type__c clPartyTypeObj = LoanServicingTestHelper.createPartyType(ConstantValues.CL_PARTY_NAME);
        clcommon__Party_Type__c borrowerPartyTypeObj = LoanServicingTestHelper.createPartyType(ConstantValues.BORROWER_PARTY);
        Database.insert(new List<clcommon__Party_Type__c> {clPartyTypeObj, borrowerPartyTypeObj}, true);

        // // Creating Certified Lender Party map
        Map<String,Id> paramForCLPartyMap = new Map<String,Id>{
            'accountId' => clAccountObj.Id,
            'contactId' => clContactObj.Id,
            'partyTypeId' => clPartyTypeObj.Id,
            'applicationId' => applicationObj.Id
        };

        // // Creating Borrower Party map
        Map<String,Id> paramForBorrowerPartyMap = new Map<String,Id>{
            'accountId' => borrowerAccountObj.Id,
            'contactId' => borrowerContactObj.Id,
            'partyTypeId' => borrowerPartyTypeObj.Id,
            'applicationId' => applicationObj.Id,
            'dealerApplicantRelationshipId' => dealerApplRelationshipObj.Id
        };

        clcommon__Party__c clPartyObj = LoanServicingTestHelper.createParty(paramForCLPartyMap);
        clcommon__Party__c borrowerPartyObj = LoanServicingTestHelper.createParty(paramForBorrowerPartyMap);
        Database.insert(new List<clcommon__Party__c> {clPartyObj,borrowerPartyObj}, true);

        List<genesis__Application_Pricing_Detail__c> pricingDetailsObjList = LoanServicingTestHelper.createSeedDataForPricingDetail(applicationObj);
        Database.insert(pricingDetailsObjList,true);

        //Create Payment Modes
        Map<String, clcommon__Payment_Mode__c> paymentModeMap = LoanServicingTestHelper.createPaymentMode();
        Database.insert(paymentModeMap.get(ConstantValues.MOBILE_DEPOSIT), true);

        //Creating funding txns for Payment
        createFundingTransactions(new Map<String, Object> {
            'applicationId' => applicationObj.Id,
            'paymentModeId' => paymentModeMap.get(ConstantValues.MOBILE_DEPOSIT).Id,
            'pricingDetailsList' => pricingDetailsObjList
        });
    }
    /**
    * @description creating funding transactions along with invoices
    * @author Kabir Pramanik | 01-10-2025 
    * @param paramMap 
    **/
    private static void createFundingTransactions(Map<String, Object> paramMap){
        Id applicationId = (Id) paramMap.get('applicationId');
        Id paymentModeId = (Id) paramMap.get('paymentModeId');
        List<genesis__Application_Pricing_Detail__c> pricingDetailsList = 
                (List<genesis__Application_Pricing_Detail__c>) paramMap.get('pricingDetailsList');

        //Create invoices 
        clcommon__Consolidated_Invoice__c mobileDepositInvoiceObj = LoanServicingTestHelper.createInvoice(applicationId, paymentModeId);
        mobileDepositInvoiceObj.clcommon__Status__c = ConstantValues.STATUS_PENDING;
        Database.insert(mobileDepositInvoiceObj, true);

        genesis__Funding_Transaction__c mobileDepositObj = LoanServicingTestHelper.createFundingTransaction(paymentModeId, null,applicationId);
        mobileDepositObj.Pricing_Detail__c = pricingDetailsList[0].Id;
        mobileDepositObj.genesis__Cleared__c = ConstantValues.FALSE_VALUE;
        mobileDepositObj.Posted_to_NLS__c = ConstantValues.FALSE_VALUE;
        mobileDepositObj.Invoice__c = mobileDepositInvoiceObj.Id;
        genesis__Funding_Transaction__c mobileDepositObjTwo = LoanServicingTestHelper.createFundingTransaction(paymentModeId, null,applicationId);
        mobileDepositObjTwo.Pricing_Detail__c = pricingDetailsList[0].Id;
        mobileDepositObjTwo.genesis__Cleared__c = ConstantValues.FALSE_VALUE;
        mobileDepositObjTwo.Posted_to_NLS__c = ConstantValues.FALSE_VALUE;
        mobileDepositObjTwo.Invoice__c = mobileDepositInvoiceObj.Id;
        Database.insert(new List<genesis__Funding_Transaction__c> {mobileDepositObj, mobileDepositObjTwo}, true);
    }
    /**
    * @description - Test ScheduleMobileDepositReportDocument scheduling success
    * @author Sk Minsar | 12-21-2024 
    **/
    @isTest
    private static void testScheduleClearingJobSuccess() {
        //Creating test data
        createTestData();
        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.startTest();
            String jobId = System.schedule('TestScheduleMobileDepositReportDocument Job','0 55 * * * ? *', new ScheduleMobileDepositReportDocument());
            Test.stopTest();
            System.assertEquals(ConstantValues.TRUE_VALUE, jobId != null,'Failed to Schedule job for clearing mobile deposit');
        } 
    }
    /**
    * @description - Test scheduling of job with incorrect cron expression 
    * @author Sk Minsar | 12-21-2024 
    **/
    @isTest
    private static void testIncorrectCronExpScheduleClearingJobFailure() {
        //Creating test data
        createTestData();
        Boolean isExceptionThrown = ConstantValues.FALSE_VALUE;
        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.startTest();
            try{
                System.schedule('TestScheduleMobileDepositReportDocument Job','60 55 * * * ? *', new ScheduleMobileDepositReportDocument());
            }catch (Exception exceptionObj){
                isExceptionThrown = ConstantValues.TRUE_VALUE;
            }
            System.assertEquals(ConstantValues.TRUE_VALUE, isExceptionThrown,'Exception should be thrown for incorrect cron expression');
            Test.stopTest();
        } 
    }
    /**
    * @description - Test scheduling of job with null cron expression 
    * @author Sk Minsar | 12-21-2024 
    **/
    @isTest
    private static void testNullCronExpScheduleClearingJobFailure() {
        //Creating test data
        createTestData();
        Boolean isExceptionThrown = ConstantValues.FALSE_VALUE;
        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.startTest();
            try{
                System.schedule('TestScheduleMobileDepositReportDocument Job',null, new ScheduleMobileDepositReportDocument());
            }catch (Exception exceptionObj){
                isExceptionThrown = ConstantValues.TRUE_VALUE;
            }
            System.assertEquals(ConstantValues.TRUE_VALUE, isExceptionThrown,'Exception should be thrown for null cron expression');
            Test.stopTest();
        } 
    }
    /**
    * @description - Test callMobileDepositReportGeneration invocable call success
    * @author Sk Minsar | 12-18-2024 
    **/
    @isTest
    private static void testInvocableCallMobileDepositReportGeneration() {
        Boolean isExceptionThrown = ConstantValues.FALSE_VALUE;
        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.startTest();
            try{
                ScheduleMobileDepositReportDocument.callMobileDepositReportGeneration();
            }catch (Exception e){
                isExceptionThrown = ConstantValues.TRUE_VALUE;
            }
            System.assertEquals(ConstantValues.FALSE_VALUE, isExceptionThrown, 'Assertion failed');
            Test.stopTest();
        }
    }
}