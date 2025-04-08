/**
 * @description       : Test class to cover NLSClearACHSchedule
 * @author            : Subham Nandi
 * @last modified on  : 01-28-2025
 * @last modified by  : Kabir Pramanik
**/
@isTest
public with sharing class TestNLSClearACHSchedule {
    
    /**
    * @description : This method is to prepare data for the test class
    * @author Sk Minsar | 12-18-2024 
    **/
    @TestSetup
    private static void makeData(){
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
        Account saAccObj = LoanServicingTestHelper.createSalesAgentAccount(dealerBusinessInfoObj.Id,dealerAccountObj.Id);
        Database.insert(new List<Account> {clAccountObj,borrowerAccountObj, saAccObj}, true);

        // Creating Contacts
        Contact clContactObj = LoanServicingTestHelper.createCLContact(clAccountObj.Id);
        Contact borrowerContactObj = LoanServicingTestHelper.createBorrowerContact(borrowerAccountObj.Id);
        Contact saContactObj=LoanServicingTestHelper.createSalesAgentContact(saAccObj.Id);
        Database.insert(new List<Contact> {clContactObj,borrowerContactObj, saContactObj},true);

        //Creating users
        User clUserObj = LoanServicingTestHelper.createCLUser(clContactObj.Id);
        User borrowerUserObj = LoanServicingTestHelper.createBorrowerUser(borrowerContactObj.Id);
        User saUserObj = LoanServicingTestHelper.createSalesAgentUser(saContactObj.Id);
        Database.insert(new List<User> {clUserObj,borrowerUserObj, saUserObj}, true);

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

        // Creating map for Application
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
            'dealerApplicantRelationshipId' => dealerApplRelationshipObj.Id
        };

        clcommon__Party__c clPartyObj = LoanServicingTestHelper.createParty(paramForCLPartyMap);
        clcommon__Party__c borrowerPartyObj = LoanServicingTestHelper.createParty(paramForBorrowerPartyMap);
        Database.insert(new List<clcommon__Party__c> {clPartyObj,borrowerPartyObj}, true);

        List<genesis__Application_Pricing_Detail__c> pricingDetailsObjList = LoanServicingTestHelper.createSeedDataForPricingDetail(applicationObj);
        Database.insert(pricingDetailsObjList,true);

        //Create Payment Modes
        Map<String, clcommon__Payment_Mode__c> paymentModeMap = LoanServicingTestHelper.createPaymentMode();
        Database.insert(new List<clcommon__Payment_Mode__c> {
            paymentModeMap.get(ConstantValues.ACH)
        }, true);

        //Creating Funding Txns
        createFundingTransactions(new Map<String, Object> {
            'applicationId' => applicationObj.Id,
            'paymentModeId' => paymentModeMap.get(ConstantValues.ACH).Id,
            'pricingDetailsList' => pricingDetailsObjList
        });
    }
    /**
    * @description creating funding transactions and invoices
    * @author Kabir Pramanik | 01-13-2025 
    * @param paramMap 
    **/
    private static void createFundingTransactions(Map<String, Object> paramMap){
        Id applicationId = (Id) paramMap.get('applicationId');
        Id paymentModeId = (Id) paramMap.get('paymentModeId');
        List<genesis__Application_Pricing_Detail__c> pricingDetailsObjList = 
                (List<genesis__Application_Pricing_Detail__c>) paramMap.get('pricingDetailsList');

        //Create invoices 
        clcommon__Consolidated_Invoice__c achInvoiceObj = LoanServicingTestHelper.createInvoice(applicationId, paymentModeId);
        achInvoiceObj.clcommon__Status__c = ConstantValues.STATUS_PENDING;
        Database.insert(achInvoiceObj, true);

        genesis__Funding_Transaction__c achFundingTxnObj = LoanServicingTestHelper.createFundingTransaction(paymentModeId, null, applicationId);
        achFundingTxnObj.Pricing_Detail__c = pricingDetailsObjList[0].Id;
        achFundingTxnObj.genesis__Cleared__c = ConstantValues.FALSE_VALUE;
        achFundingTxnObj.Posted_to_NLS__c = ConstantValues.FALSE_VALUE;
        achFundingTxnObj.Invoice__c = achInvoiceObj.Id;
        genesis__Funding_Transaction__c achFundingTxnSecondObj = LoanServicingTestHelper.createFundingTransaction(paymentModeId, null, applicationId);
        achFundingTxnSecondObj.Pricing_Detail__c = pricingDetailsObjList[0].Id;
        achFundingTxnSecondObj.genesis__Cleared__c = ConstantValues.FALSE_VALUE;
        achFundingTxnSecondObj.Posted_to_NLS__c = ConstantValues.FALSE_VALUE;
        achFundingTxnSecondObj.Invoice__c = achInvoiceObj.Id;
        Database.insert(new List<genesis__Funding_Transaction__c> {achFundingTxnObj, achFundingTxnSecondObj}, true);

        //Update invoice total amount
        achInvoiceObj.Total_Amount__c = achFundingTxnObj.genesis__Amount__c + achFundingTxnSecondObj.genesis__Amount__c;
        Database.update(achInvoiceObj, true);
    }
    /**
    * @description - Test successful clearance of ACH from NLSClearACHSchedule for CFA
    * @author Sk Minsar | 12-18-2024 
    **/
    @isTest
    private static void testACHClearedSuccessForCFA(){
        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.startTest();
            String jobId = System.schedule('testNLSClearACHSchedule','0 55 * * * ? *', new NLSClearACHSchedule());
            Test.stopTest();
            System.assertEquals(ConstantValues.TRUE_VALUE, jobId != null, 'Job is not scheduled');
            List<genesis__Funding_Transaction__c> fundingTransactionList = [SELECT Id
                                                                                FROM genesis__Funding_Transaction__c
                                                                                WHERE genesis__Cleared__c = :ConstantValues.TRUE_VALUE];
            System.assertEquals(ConstantValues.TWO_VALUE, fundingTransactionList.size(), 'All ACHs are not cleared');
            //checking if any error occured after ach status is set to true
            List<clcommon__Log__c> logList = [SELECT Id FROM clcommon__Log__c WHERE Name = :NLSClearACHSchedule.class.getName()];
            System.assertEquals(ConstantValues.TRUE_VALUE, logList.isEmpty(), 'Error occured while sending emails');
            //as all the ACHs are cleared, consolidated invoice status should be updated to Initiated
            List<clcommon__Consolidated_Invoice__c> invoiceObjList = [SELECT Id,
                                                                            clcommon__Status__c
                                                                        FROM clcommon__Consolidated_Invoice__c];
            List<clcommon__Funding_Transactions_Properties__c> fundingTxnPropBatch = [SELECT Id,
                                                                                            Batch_Total_Amount__c
                                                                                        FROM clcommon__Funding_Transactions_Properties__c 
                                                                                        WHERE Status__c = :ConstantValues.INITIATED_STATUS
                                                                                        AND Payment_Mode__c = :ConstantValues.ACH];
            System.assertEquals(2000, fundingTxnPropBatch[0].Batch_Total_Amount__c, 'funding transaction batch total amound does not match');
            System.assertEquals(ConstantValues.STATUS_INITIATED, invoiceObjList[0].clcommon__Status__c, 'Invoice status should be updated to Initiated');
        }
    }
    /**
    * @description - Test ACH invocable method call success
    * @author Sk Minsar | 12-18-2024 
    **/
    @isTest
    private static void testACHInvocableCallSuccess(){
        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.startTest();
            NLSClearACHSchedule.clearAllACH();
            Test.stopTest();
            List<genesis__Funding_Transaction__c> fundingTransactionList = [SELECT Id,
                                                                            genesis__Cleared__c
                                                                        FROM genesis__Funding_Transaction__c
                                                                        WHERE genesis__Cleared__c = :ConstantValues.TRUE_VALUE];
            System.assertEquals(ConstantValues.TWO_VALUE, fundingTransactionList.size(), 'All ACHs are not cleared');
            List<clcommon__Log__c> logList = [SELECT Id FROM clcommon__Log__c WHERE Name = :NLSClearACHSchedule.class.getName()];
            System.assertEquals(ConstantValues.TRUE_VALUE, logList.isEmpty(), 'Error occured while sending emails');
            List<clcommon__Consolidated_Invoice__c> invoiceObjList = [SELECT Id,
                                                                            clcommon__Status__c
                                                                        FROM clcommon__Consolidated_Invoice__c
                                                                        LIMIT 1];
            List<clcommon__Funding_Transactions_Properties__c> fundingTxnPropBatch = [SELECT Id,
                                                                                            Batch_Total_Amount__c
                                                                                        FROM clcommon__Funding_Transactions_Properties__c 
                                                                                        WHERE Status__c = :ConstantValues.INITIATED_STATUS
                                                                                        AND Payment_Mode__c = :ConstantValues.ACH];
            System.assertEquals(2000, fundingTxnPropBatch[0].Batch_Total_Amount__c, 'funding transaction batch total amound does not match');
            System.assertEquals(ConstantValues.STATUS_INITIATED, invoiceObjList[0].clcommon__Status__c, 'Invoice status should be updated to Initiated');
        }
    }

    /**
    * @description - Test ACH not getting cleared for having pricing details of funding txn as null
    * @author Sk Minsar | 12-18-2024 
    **/
    @isTest
    private static void testACHPricingDetailsNullException(){
        List<genesis__Funding_Transaction__c> fundingTransactionList = [SELECT Id
                                                                        FROM genesis__Funding_Transaction__c];
        fundingTransactionList[0].Pricing_Detail__c = null;
        Database.update(fundingTransactionList, ConstantValues.TRUE_VALUE);
        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.startTest();
            NLSClearACHSchedule.clearAllACH();
            Test.stopTest();
            fundingTransactionList = [SELECT Id,
                                            genesis__Cleared__c
                                        FROM genesis__Funding_Transaction__c
                                        WHERE genesis__Cleared__c = :ConstantValues.TRUE_VALUE];
            System.assertEquals(ConstantValues.ONE_VALUE, fundingTransactionList.size(), 'Only one ACH should be cleared');
        }
    }

    /**
    * @description Test successful clearance of ACH from NLSClearACHSchedule for Growmark
    * @author Kabir Pramanik | 01-08-2025 
    **/
    @isTest
    private static void testACHClearedSuccessForGMK(){
        List<Account> dealerAccountObj = [SELECT Id FROM Account WHERE RecordType.Name = :ConstantValues.DEALER LIMIT 1];
        dealerAccountObj[0].Coop_Type__c = ConstantValues.GROWMARK_COOP_TYPE;
        dealerAccountObj[0].CFA_Partner_Program__c = null;
        Database.update(dealerAccountObj, ConstantValues.TRUE_VALUE);
        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.startTest();
            System.schedule('testNLSClearACHSchedule','0 55 * * * ? *', new NLSClearACHSchedule());
            Test.stopTest();
            List<genesis__Funding_Transaction__c> fundingTransactionList = [SELECT Id
                                                                                FROM genesis__Funding_Transaction__c
                                                                                WHERE genesis__Cleared__c = :ConstantValues.TRUE_VALUE];
            System.assertEquals(ConstantValues.TWO_VALUE, fundingTransactionList.size(), 'All ACHs are not cleared');
            List<clcommon__Log__c> logList = [SELECT Id FROM clcommon__Log__c WHERE Name = :NLSClearACHSchedule.class.getName()];
            System.assertEquals(ConstantValues.TRUE_VALUE, logList.isEmpty(), 'Error occured while sending emails');
            List<clcommon__Consolidated_Invoice__c> invoiceObjList = [SELECT Id,
                                                                            clcommon__Status__c
                                                                        FROM clcommon__Consolidated_Invoice__c];
            List<clcommon__Funding_Transactions_Properties__c> fundingTxnPropBatch = [SELECT Id,
                                                                                            Batch_Total_Amount__c
                                                                                        FROM clcommon__Funding_Transactions_Properties__c 
                                                                                        WHERE Status__c = :ConstantValues.INITIATED_STATUS
                                                                                        AND Payment_Mode__c = :ConstantValues.ACH];
            System.assertEquals(2000, fundingTxnPropBatch[0].Batch_Total_Amount__c, 'funding transaction batch total amound does not match');
            System.assertEquals(ConstantValues.STATUS_INITIATED, invoiceObjList[0].clcommon__Status__c, 'Invoice status should be updated to Initiated');
        }
    }
    /**
    * @description Test successful clearance of ACH from NLSClearACHSchedule for Growmark
    * @author Kabir Pramanik | 01-08-2025 
    **/
    @isTest
    private static void testACHClearedSuccessForLandus(){
        List<Account> dealerAccountObj = [SELECT Id FROM Account WHERE RecordType.Name = :ConstantValues.DEALER LIMIT 1];
        dealerAccountObj[0].Coop_Type__c = ConstantValues.LANDUS_COOP_TYPE;
        Database.update(dealerAccountObj, ConstantValues.TRUE_VALUE);        
        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.startTest();
            System.schedule('testNLSClearACHSchedule','0 55 * * * ? *', new NLSClearACHSchedule());
            Test.stopTest();
            List<genesis__Funding_Transaction__c> fundingTransactionList = [SELECT Id
                                                                                FROM genesis__Funding_Transaction__c
                                                                                WHERE genesis__Cleared__c = :ConstantValues.TRUE_VALUE];
            System.assertEquals(ConstantValues.TWO_VALUE, fundingTransactionList.size(), 'All ACHs are not cleared');
            List<clcommon__Log__c> logList = [SELECT Id FROM clcommon__Log__c WHERE Name = :NLSClearACHSchedule.class.getName()];
            System.assertEquals(ConstantValues.TRUE_VALUE, logList.isEmpty(), 'Error occured while sending emails');
            List<clcommon__Consolidated_Invoice__c> invoiceObjList = [SELECT Id,
                                                                            clcommon__Status__c
                                                                        FROM clcommon__Consolidated_Invoice__c];
            List<clcommon__Funding_Transactions_Properties__c> fundingTxnPropBatch = [SELECT Id,
                                                                                            Batch_Total_Amount__c
                                                                                        FROM clcommon__Funding_Transactions_Properties__c 
                                                                                        WHERE Status__c = :ConstantValues.INITIATED_STATUS
                                                                                        AND Payment_Mode__c = :ConstantValues.ACH];
            System.assertEquals(2000, fundingTxnPropBatch[0].Batch_Total_Amount__c, 'funding transaction batch total amound does not match');
            System.assertEquals(ConstantValues.STATUS_INITIATED, invoiceObjList[0].clcommon__Status__c, 'Invoice status should be updated to Initiated');
        }
    }

    /**
    * @description test the invoice status not get updated for all txns under this are not cleared
    * @author Kabir Pramanik | 01-08-2025 
    **/
    @isTest
    private static void testACHCInvoiceStatusNotUpdated(){
        List<genesis__Funding_Transaction__c> fundingTxnObjList = [SELECT Id FROM genesis__Funding_Transaction__c];
        fundingTxnObjList[0].Status__c = ConstantValues.VOIDED_STATUS;
        Database.update(fundingTxnObjList[0], true);
        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.startTest();
            System.schedule('testNLSClearACHSchedule','0 55 * * * ? *', new NLSClearACHSchedule());
            Test.stopTest();
            List<genesis__Funding_Transaction__c> fundingTransactionList = [SELECT Id
                                                                                FROM genesis__Funding_Transaction__c
                                                                                WHERE genesis__Cleared__c = :ConstantValues.TRUE_VALUE];
            System.assertEquals(ConstantValues.ONE_VALUE, fundingTransactionList.size(), 'All ACHs are not cleared');
            //invoice staus would remain Pending as all achs with the invoice id are not cleared
            List<clcommon__Consolidated_Invoice__c> invoiceObjList = [SELECT Id,
                                                                            clcommon__Status__c
                                                                        FROM clcommon__Consolidated_Invoice__c];
            List<clcommon__Funding_Transactions_Properties__c> fundingTxnPropBatch = [SELECT Id,
                                                                                            Batch_Total_Amount__c
                                                                                        FROM clcommon__Funding_Transactions_Properties__c 
                                                                                        WHERE Status__c = :ConstantValues.INITIATED_STATUS
                                                                                        AND Payment_Mode__c = :ConstantValues.ACH];
            System.assertEquals(1000, fundingTxnPropBatch[0].Batch_Total_Amount__c, 'funding transaction batch total amound does not match');
            System.assertEquals(ConstantValues.STATUS_PENDING, invoiceObjList[0].clcommon__Status__c, 'Invoice status should be Pending');
        }
    }
    /**
    * @description test object insufficient permission exception scenario
    * @author Kabir Pramanik | 01-13-2025 
    **/
    @isTest
    private static void testACHInsufficientPermissionException(){
        List<User> userObjList = [SELECT Id 
                                    FROM USER 
                                    WHERE Profile.Name = :ConstantValues.SALES_AGENT 
                                    AND UserName = 'tony.stark@yopmail.com' 
                                    AND isActive = true
                                    LIMit 1];
        System.runAs(userObjList[0]){
            Test.startTest();
            System.schedule('testNLSClearACHSchedule','0 55 * * * ? *', new NLSClearACHSchedule());
            Test.stopTest();
            List<clcommon__Log__c> logList = [SELECT Id FROM clcommon__Log__c WHERE Name = :NLSClearACHSchedule.class.getName() LIMIT 1];
            System.assertEquals(ConstantValues.FALSE_VALUE, logList.isEmpty(), 'Exception should be thrown for insufficient permission access');
        }
    }
    
}