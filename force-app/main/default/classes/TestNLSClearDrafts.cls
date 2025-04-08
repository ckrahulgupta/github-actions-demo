/**
 * @description       : Test class to cover the NLSClearDrafts class
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 01-27-2025
 * @last modified by  : Kabir Pramanik
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   14-06-2022   Subham Nandi   Initial Version
**/
@isTest
public with sharing class TestNLSClearDrafts {
    /**
    * @description creating test data
    * @author Kabir Pramanik | 01-08-2025 
    **/
    @TestSetup
    private static void setup(){
        //Creating floating rate index 
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

        // Creating Business Information
        genesis__Business_Information__c dealerBusinessInfoObj = LoanServicingTestHelper.createBusinessInfoForDealer();
        genesis__Business_Information__c borrowerBusinessInfoObj = LoanServicingTestHelper.createBusinessInfoForBorrower();
        Database.insert(new List<genesis__Business_Information__c> {dealerBusinessInfoObj,borrowerBusinessInfoObj}, true);

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
        dealer_applicant_relationship__c borrowerRelationObj = LoanServicingTestHelper.createDealerApplicantRelationship(borrowerContactObj, dealerAccountObj.Id);
        Database.insert(borrowerRelationObj, true);

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

        // Creating map for Application
        Map<String,Id> paramForApplicationMap = new Map<String,Id>{
            'dealerAccountId' => dealerAccountObj.Id,
            'clProductId' => clProductObj.Id,
            'clPurposeId' => clPurposeObj.Id,
            'borrowerAccountId' => borrowerAccountObj.Id,
            'borrowerContactId' => borrowerContactObj.Id,
            'clAccountId' => clAccountObj.Id,
            'dealerApplicantRelationshipId' => borrowerRelationObj.Id
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

        // Creating Certified Lender Party map
        Map<String,Id> paramForCLPartyMap = new Map<String,Id>{
            'accountId' => clAccountObj.Id,
            'contactId' => clContactObj.Id,
            'partyTypeId' => clPartyTypeObj.Id,
            'applicationId' => applicationObj.Id
        };

        // Creating Borrower Party map
        Map<String,Id> paramForBorrowerPartyMap = new Map<String,Id>{
            'accountId' => borrowerAccountObj.Id,
            'contactId' => borrowerContactObj.Id,
            'partyTypeId' => borrowerPartyTypeObj.Id,
            'applicationId' => applicationObj.Id,
            'dealerApplicantRelationshipId' => borrowerRelationObj.Id
        };

        clcommon__Party__c clPartyObj = LoanServicingTestHelper.createParty(paramForCLPartyMap);
        clcommon__Party__c borrowerPartyObj = LoanServicingTestHelper.createParty(paramForBorrowerPartyMap);
        Database.insert(new List<clcommon__Party__c> {clPartyObj,borrowerPartyObj}, true);

        List<genesis__Application_Pricing_Detail__c> pricingDetailsObjList = LoanServicingTestHelper.createSeedDataForPricingDetail(applicationObj);
        Database.insert(pricingDetailsObjList,true);

        //Create Payment Modes
        Map<String, clcommon__Payment_Mode__c> paymentModeMap = LoanServicingTestHelper.createPaymentMode();
        Database.insert(new List<clcommon__Payment_Mode__c> {
            paymentModeMap.get(ConstantValues.DRAFT)
        }, true);

        //Creating Funding Txns
        createFundingTransactions(new Map<String, Object> {
            'applicationId' => applicationObj.Id,
            'paymentModeId' => paymentModeMap.get(ConstantValues.DRAFT).Id,
            'pricingDetailsList' => pricingDetailsObjList
        });
    }
    /**
    * @description create Draft Funding Txns
    * @author Kabir Pramanik | 01-13-2025 
    * @param paramMap 
    **/
    private static void createFundingTransactions(Map<String, Object> paramMap){
        Id applicationId = (Id) paramMap.get('applicationId');
        Id paymentModeId = (Id) paramMap.get('paymentModeId');
        List<genesis__Application_Pricing_Detail__c> pricingDetailsList = 
                (List<genesis__Application_Pricing_Detail__c>) paramMap.get('pricingDetailsList');

        genesis__Funding_Transaction__c draftTxnObj = LoanServicingTestHelper.createFundingTransaction(paymentModeId, null, applicationId);
        draftTxnObj.Pricing_Detail__c = pricingDetailsList[0].Id;
        draftTxnObj.genesis__Cleared__c = false;
        draftTxnObj.Posted_to_NLS__c = false;

        genesis__Funding_Transaction__c draftTxnObjTwo = LoanServicingTestHelper.createFundingTransaction(paymentModeId, null, applicationId);
        draftTxnObjTwo.Pricing_Detail__c = pricingDetailsList[0].Id;
        draftTxnObjTwo.genesis__Cleared__c = false;
        draftTxnObjTwo.Posted_to_NLS__c = false;
        Database.insert(new List<genesis__Funding_Transaction__c> {draftTxnObj, draftTxnObjTwo}, true);
    }
    /**
    * @description test Success scenario of drafts getting cleared for CFA
    * @author Kabir Pramanik | 01-08-2025 
    **/
    @isTest
    private static void testDraftInvocableForCFA(){
        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.startTest();
            NLSClearDrafts.clearAllDRAFTS();
            List<genesis__Funding_Transaction__c> draftObjList = [SELECT Id
                                                                    FROM genesis__Funding_Transaction__c
                                                                    WHERE genesis__Payment_Mode__r.Name =:ConstantValues.DRAFT
                                                                    AND genesis__Cleared__c = :ConstantValues.TRUE_VALUE];
            System.assertEquals(ConstantValues.TWO_VALUE, draftObjList.size(), 'All Drafts should be cleared');
            List<clcommon__Funding_Transactions_Properties__c> fundingTxnPropBatchObj = [SELECT Id, Batch_Total_Amount__c FROM clcommon__Funding_Transactions_Properties__c LIMIT 1];
            System.assertEquals(2000, fundingTxnPropBatchObj[0].Batch_Total_Amount__c, 'Total amount of batch should be same with total Draft amounts');
            Test.stopTest();
        }
    }
    /**
    * @description test Success scenario of drafts getting cleared for GMK
    * @author Kabir Pramanik | 01-08-2025 
    **/
    @isTest
    private static void testDraftInvocableForGMK(){
        //making changes on test data for GMK
        List<Account> dealerAccountObj = [SELECT Id FROM Account WHERE RecordType.Name = :ConstantValues.DEALER LIMIT 1];
        dealerAccountObj[0].Coop_Type__c = ConstantValues.GROWMARK_COOP_TYPE;
        dealerAccountObj[0].CFA_Partner_Program__c = null;
        Database.update(dealerAccountObj, ConstantValues.TRUE_VALUE);
        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.startTest();
            NLSClearDrafts.clearAllDRAFTS();
            List<genesis__Funding_Transaction__c> draftObjList = [SELECT Id
                                                                    FROM genesis__Funding_Transaction__c
                                                                    WHERE genesis__Payment_Mode__r.Name =:ConstantValues.DRAFT
                                                                    AND genesis__Cleared__c = :ConstantValues.TRUE_VALUE];
            System.assertEquals(ConstantValues.TWO_VALUE, draftObjList.size(), 'All Drafts should be cleared');
            List<clcommon__Funding_Transactions_Properties__c> fundingTxnPropBatchObj = [SELECT Id, Batch_Total_Amount__c FROM clcommon__Funding_Transactions_Properties__c LIMIT 1];
            System.assertEquals(2000, fundingTxnPropBatchObj[0].Batch_Total_Amount__c, 'Total amount of batch should be same with total Draft amounts');
            Test.stopTest();
        }
    }
    /**
    * @description test Success scenario of drafts getting cleared for GMK
    * @author Kabir Pramanik | 01-08-2025 
    **/
    @isTest
    private static void testDraftInvocableForLandus(){
        //making changes on test data for GMK
        List<Account> dealerAccountObj = [SELECT Id FROM Account WHERE RecordType.Name = :ConstantValues.DEALER LIMIT 1];
        dealerAccountObj[0].Coop_Type__c = ConstantValues.LANDUS_COOP_TYPE;
        Database.update(dealerAccountObj, ConstantValues.TRUE_VALUE);
        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.startTest();
            NLSClearDrafts.clearAllDRAFTS();
            List<genesis__Funding_Transaction__c> draftObjList = [SELECT Id
                                                                    FROM genesis__Funding_Transaction__c
                                                                    WHERE genesis__Payment_Mode__r.Name =:ConstantValues.DRAFT
                                                                    AND genesis__Cleared__c = :ConstantValues.TRUE_VALUE];
            System.assertEquals(ConstantValues.TWO_VALUE, draftObjList.size(), 'All Drafts should be cleared');
            List<clcommon__Funding_Transactions_Properties__c> fundingTxnPropBatchObj = [SELECT Id, Batch_Total_Amount__c FROM clcommon__Funding_Transactions_Properties__c LIMIT 1];
            System.assertEquals(2000, fundingTxnPropBatchObj[0].Batch_Total_Amount__c, 'Total amount of batch should be same with total Draft amounts');
            Test.stopTest();
        }
    }
    /**
    * @description test invocable call to clear drafts when no Draft is present that comes under the conditions
    * @author Kabir Pramanik | 01-08-2025 
    **/
    @isTest
    private static void testNoDraftAvailableToClearSuccess(){
        Boolean isExceptionThrown = ConstantValues.FALSE_VALUE;
        List<genesis__Funding_Transaction__c> draftObjList = [SELECT  Id
                                                                FROM genesis__Funding_Transaction__c
                                                                WHERE genesis__Cleared__c = false
                                                                AND Posted_to_NLS__c = false
                                                                AND genesis__Payment_Mode__r.Name =:ConstantValues.DRAFT];
        if(!draftObjList.isEmpty()){
            Database.delete(draftObjList, ConstantValues.TRUE_VALUE);
        }
        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.startTest();
            try{
                NLSClearDrafts.clearAllDRAFTS();
            }catch(Exception ex){
                isExceptionThrown = ConstantValues.TRUE_VALUE;
            }
            System.assertEquals(ConstantValues.FALSE_VALUE, isExceptionThrown, 'No exception should be thrown');
            Test.stopTest();
        }
    }
}