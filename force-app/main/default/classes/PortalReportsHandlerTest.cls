/**
 * @description       : 
 * @author            : Tuhin Bhunia
 * @group             : 
 * @last modified on  : 20-01-2025
 * @last modified by  : Soumik Pattanayak
**/
@isTest
private without sharing class PortalReportsHandlerTest {
    @TestSetup
    static void setup() {
        
        // Creating CL Product for Application
        clcommon__CL_Product__c clProductObj = ApplicationOriginationTestHelper.createCLProductForApplication();
        Database.insert(clProductObj, true);

        // Creating CL Purpose for Application
        clcommon__CL_Purpose__c clPurposeObj = ApplicationOriginationTestHelper.createCLPurposeForApplication();
        Database.insert(clPurposeObj, true);

        // Creating Floating Rate Index
        clcommon__Floating_Rate_Index__c floatingRateIndexObj = ApplicationOriginationTestHelper.createFloatingRateIndex(
            new Map<String, Object>{ 'Name' => 'CFA Advantage Rate',
                                        'Base Rate Name' => '4-CFA ADVANTAGE',
                                        'Current Floating Rate' => 11,
                                        'Base Rate Adjuster' => 5.5
            });
        Database.Insert(floatingRateIndexObj, true);

        // Creating Floating rate
        Database.Insert(ApplicationOriginationTestHelper.createFloatingRate(floatingRateIndexObj), true);

        // Creating New Partner Program
        CFA_Partner_Program__c newPartnerProgramObj = ApplicationOriginationTestHelper.createPartnerProgram(floatingRateIndexObj);
        Database.Insert(newPartnerProgramObj, true);
        
        // creating business information
        genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        genesis__Business_Information__c borrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        Database.insert(new List<genesis__Business_Information__c>{
            dealerBusinessInfoObj,
            borrowerBusinessInfoObj
        }, true);

        clcommon__Legal_Entity__c entityObj = ApplicationOriginationTestHelper.createLegalEntity(PortalConstants.SOLE_PROP_ENTITY);
        Database.insert(entityObj, true);

        // Creating Accounts
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.Id, newPartnerProgramObj.Id);
        Database.insert(dealerAccountObj, true);

        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
        Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(entityObj, borrowerBusinessInfoObj.Id);
        Database.insert(new List<Account>{
            clAccountObj,
            borrowerAccountObj
        }, true);

        // Creating Contacts
        Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.Id);
        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.Id);    
        Database.insert(new List<Contact>{
            clContactObj,
            borrowerContactObj
        }, true);

        // Creating Users
        User clUserObj = ApplicationOriginationTestHelper.createCLUser(clContactObj.Id);
        User borrowerUserObj = ApplicationOriginationTestHelper.createBorrowerUser(borrowerContactObj.Id);
        Database.insert(new List<User>{
            clUserObj,
            borrowerUserObj
        }, true);

        // Creating Dealer Applicant Relationship
        Dealer_Applicant_Relationship__c dealerAppRelationshipObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(borrowerContactObj, dealerAccountObj.Id);
        Database.Insert(dealerAppRelationshipObj, true);

        // Creating Roles
        clcommon__Reciprocal_Role__c clRoleObj = ApplicationOriginationTestHelper.createReciprocalRole(PortalConstants.CERTIFIED_LENDER);
        Database.insert(clRoleObj, true);

        // Creating Relationships
        Database.insert(ApplicationOriginationTestHelper.createCLDealerRelationship(clRoleObj, 
                                                                    dealerAccountObj.Id, 
                                                                    clAccountObj.Id), true);

        // Creating Application
        Map<String,Id> paramForApplicationMap = new Map<String,Id>{
            'dealerAccountId'=> dealerAccountObj.Id,
            'clProductId'=> clProductObj.Id,
            'clPurposeId'=> clPurposeObj.Id,
            'borrowerAccountId'=> borrowerAccountObj.Id,
            'borrowerContactId'=> borrowerContactObj.Id,
            'clAccountId'=> clAccountObj.Id
        };

        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createCurrCropYearApplication(paramForApplicationMap);
        applicationObj.OwnerId = clUserObj.Id;
        Database.insert(applicationObj, true);

        // Creating Party Types
        clcommon__Party_Type__c dealerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType(PortalConstants.DEALER_PARTY_NAME);
        dealerPartyTypeObj.OwnerId = clUserObj.Id;
        clcommon__Party_Type__c borrowerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType(PortalConstants.BORROWER_PARTY_NAME);
        borrowerPartyTypeObj.OwnerId = clUserObj.Id;
        clcommon__Party_Type__c clPartyTypeObj = ApplicationOriginationTestHelper.createPartyType(PortalConstants.CL_PARTY_NAME);
        clPartyTypeObj.OwnerId = clUserObj.Id;
        Database.insert(new List<clcommon__Party_Type__c>{
            dealerPartyTypeObj,
            borrowerPartyTypeObj,
            clPartyTypeObj
        }, true);

        // Creating Party Data Maps
        Map<String,Id> paramForBorrowerPartyMap = new Map<String,Id>{
            'accountId'=> borrowerAccountObj.Id,
            'contactId'=> borrowerContactObj.Id,
            'partyTypeId'=> borrowerPartyTypeObj.Id,
            'applicationId'=> applicationObj.Id
        };
        clcommon__party__c borrowerPartyObj = ApplicationOriginationTestHelper.createApplicantParty(paramForBorrowerPartyMap, borrowerAccountObj);
        borrowerPartyObj.OwnerId = clUserObj.Id;

        Map<String,Id> paramForCLPartyMap = new Map<String,Id>{
            'accountId' => clAccountObj.Id,
            'contactId' => clContactObj.Id,
            'partyTypeId' => clPartyTypeObj.Id,
            'applicationId' => applicationObj.Id
        };
        clcommon__party__c clPartyObj = ApplicationOriginationTestHelper.createParty(paramForCLPartyMap);
        clPartyObj.OwnerId = clUserObj.Id;

        Map<String,Id> paramForDealerPartyMap = new Map<String,Id>{
            'accountId' => dealerAccountObj.Id,
            'partyTypeId' => dealerPartyTypeObj.Id,
            'applicationId' => applicationObj.Id
        };
        clcommon__party__c dealerPartyObj = ApplicationOriginationTestHelper.createParty(paramForDealerPartyMap);
        dealerPartyObj.OwnerId = clUserObj.Id;

        // Inserting Parties
        Database.insert(new List<clcommon__Party__c>{
            borrowerPartyObj,
            clPartyObj,
            dealerPartyObj
        }, true);
        
        // Creating Loan Journey Data :- My Program, Tranches, Pricings, Payment Mode, Funding Transactions, Application Fee Payments.
        createLoanSpecificData(dealerAccountObj, applicationObj, clUserObj.Id);
        
    }

    /**
    * @description : This method is used to Insert Loan Servicing Data like My Program, Tranches, Pricings, 
    *                Payment Mode, Funding Transactions, Application Fee Payments. 
    * @author Tuhin Bhunia | 01-12-2025 
    * @param dealerAccountObj 
    * @param applicationObj 
    * @param ownerId 
    **/
    private static void createLoanSpecificData(Account dealerAccountObj, genesis__Applications__c applicationObj, Id ownerId){
        // create rate card and pricing detail
        genesis__Rate_Card_Setup_Header__c rateCardSetupHeaderObj = LoanServicingTestHelper.createPrevYearRateCardHeader(dealerAccountObj);
        rateCardSetupHeaderObj.OwnerID = ownerId;
        Database.insert(rateCardSetupHeaderObj, true);

        genesis__Rate_Card_Setup_Detail__c rateCardSetupDetailObj = LoanServicingTestHelper.createRateCardSetupDetailOne(rateCardSetupHeaderObj);
        rateCardSetupDetailObj.Participation_Percentage_Dealer_Subsidy__c = 2.5;
        Database.insert(rateCardSetupDetailObj, true);

        genesis__Application_Pricing_Detail__c enabledAppPricingObj = LoanServicingTestHelper.createEnabledPricingDetail(applicationObj, rateCardSetupDetailObj.Id);
        Database.insert(enabledAppPricingObj, true);

         
        enabledAppPricingObj = LoanServicingTestHelper.createEnabledPricingDetail(applicationObj, rateCardSetupDetailObj.Id);
        Database.insert(enabledAppPricingObj, true);

        genesis__Application_Pricing_Detail__c disabledAppPricingObj = LoanServicingTestHelper.createDisabledPricingDetail(applicationObj, rateCardSetupDetailObj.Id);
        disabledAppPricingObj.Loan_Number__c = applicationObj.genesis__Loan_Number__c;
        Database.insert(disabledAppPricingObj, true);


        //application fee payment
        List<genesis__Application_Fee_Payment__c> appFeePaymentList = LoanServicingTestHelper.createApplicationFeePaymentList(applicationObj.Id, enabledAppPricingObj.Id);
        for(genesis__Application_Fee_Payment__c feePaymentObj : appFeePaymentList){
            feePaymentObj.OwnerId = ownerId;
        }
        Database.insert(appFeePaymentList, true);

        // Creating Payment Modes
        clcommon__Payment_Mode__c paymentModeACHObj = LoanServicingTestHelper.createPaymentMode().get(PortalConstants.ACH);
        paymentModeACHObj.OwnerID = ownerId;
        clcommon__Payment_Mode__c paymentModeDraftObj = LoanServicingTestHelper.createPaymentMode().get(PortalConstants.DRAFT);
        paymentModeDraftObj.OwnerID = ownerId;
        Database.insert(new List<clcommon__Payment_Mode__c>{
            paymentModeACHObj,
            paymentModeDraftObj
        }, true);

        // Creating Funding Transactions Properties
        clcommon__Funding_Transactions_Properties__c fundingTransacPropACHObj = LoanServicingTestHelper.createFundingTransactionProperty('ACH - 07-09-2022');
        fundingTransacPropACHObj.OwnerID = ownerId;
        Database.insert(fundingTransacPropACHObj, true);

        // Creating Funding Transactions
        Map<String, Id> achFundingTransacParamMap = new Map<String, Id>{
            'applicationId'=> applicationObj.Id,
            'pricingDetailId'=> enabledAppPricingObj.Id,
            'paymentModeId'=> paymentModeACHObj.Id,
            'fundingTransactionPropertyId'=> fundingTransacPropACHObj.Id
        };
        genesis__Funding_Transaction__c achFundingTransactionObj = LoanServicingTestHelper.createACHFundingTransaction(achFundingTransacParamMap);
        achFundingTransactionObj.OwnerID = ownerId;

        Map<String, Id> draftFundingTransParamMap = new Map<String, Id>{
            'applicationId'=> applicationObj.Id,
            'pricingDetailId'=> enabledAppPricingObj.Id,
            'paymentModeId'=> paymentModeDraftObj.Id
        };
        genesis__Funding_Transaction__c draftFundingTransObj = LoanServicingTestHelper.createDraftFundingTransaction(draftFundingTransParamMap);
        draftFundingTransObj.OwnerID = ownerId;

        Database.insert(new List<genesis__Funding_Transaction__c>{
            achFundingTransactionObj,
            draftFundingTransObj
        }, true);
    }

    /**
    * @description - This method Roundup the input value upto 2 places 
    * @author Sk Minsar | 11-03-2023 
    * @param value 
    * @return Object 
    **/
    private static Decimal getRoundedValue(Decimal value){
        return (value!=null) ? value.setScale(2): 0;
    }

    /**
    * @description : This method is used to test the Success sceanario of getActiveLoanReport method in PortalReportsHandler
    * @author Tuhin Bhunia | 12-10-2024 
    **/
    @isTest
    private static void testGetActiveLoanReport(){
        User clUserObj = LoanServicingTestHelper.getCertifiedLenderUser('Ross Geller');
               
        Integer month = System.today().month();
        String cropYear;
        if(month >= 6){
            cropYear = String.valueOf(System.today().addYears(1).year());
        } else {
            cropYear = String.valueOf(System.today().year());
        }
        if (clUserObj != null) {
            System.runAs(clUserObj) {
                Test.startTest();
                // Calling  the API
                List<genesis__Applications__c> result = PortalReportsHandler.getActiveLoanReport(cropYear);
                System.assertEquals(1, result.size(), PortalConstants.ASSERTION_FAILED); 
                Test.stopTest();
            }
        }
    }

    /**
    * @description : This method is used to test the Success sceanario of getEndOfMonthActiveLoanReport method in PortalReportsHandler
    * @author Tuhin Bhunia | 12-10-2024 
    **/
    @isTest
    private static void testGetEndOfMonthActiveLoanReport(){
        User clUserObj = LoanServicingTestHelper.getCertifiedLenderUser('Ross Geller');
        String reportFilter = String.valueOf(Datetime.now().format('MMMM')) + ' ' + String.valueOf(System.today().year());
        if (clUserObj != null) {
            System.runAs(clUserObj) {
                Test.startTest();
                // Calling  the API
                List<Map<String, Object>> result = PortalReportsHandler.getEndOfMonthActiveLoanReport(reportFilter);
                System.assert(result.size() >= 1, PortalConstants.ASSERTION_FAILED); 
                Test.stopTest();
            }
        }
    }

    /**
    * @description : This method is used to test the Success sceanario of getRateChangeNotificationReport method in PortalReportsHandler
    * @author Tuhin Bhunia | 12-10-2024 
    **/
    @isTest
    private static void testGetRateChangeNotificationReport(){
        User clUserObj = LoanServicingTestHelper.getCertifiedLenderUser('Ross Geller');
        
        List<Account> dealerAccountList = [SELECT Id, name, OwnerId FROM Account WHERE RecordType.Name =: PortalConstants.DEALER_PROFILE];
        dealerAccountList[0].OwnerId = clUserObj.Id;
        Database.update(dealerAccountList, true);
        if (clUserObj != null) {
            System.runAs(clUserObj) {
                Test.startTest();
                // Calling  the API
                List<Map<String, Object>> result = PortalReportsHandler.getRateChangeNotificationReport();
                System.assert(result.size() != 1, PortalConstants.ASSERTION_FAILED); 
                Test.stopTest();
            }
        }
    }

    /**
    * @description : This method is used to test the Success sceanario of getEndOfYearReport method in PortalReportsHandler
    * @author Tuhin Bhunia | 12-13-2024 
    **/
    @isTest
    private static void testGetEndOfYearReport(){
        User clUserObj = LoanServicingTestHelper.getCertifiedLenderUser('Ross Geller');
        
        Integer year = System.today().year();
        if (clUserObj != null) {
            System.runAs(clUserObj) {
                Test.startTest();
                // Calling  the API
                List<Map<String, Object>> result = PortalReportsHandler.getEndOfYearReport(String.valueOf(year));
                System.assert(result.size() >= 1, PortalConstants.ASSERTION_FAILED); 
                Test.stopTest();
            }
        }
    }

    /**
    * @description : This method is used to test the Success sceanario of getOnlineUsersReport method in PortalReportsHandler
    * @author Tuhin Bhunia | 12-13-2024 
    **/
    @isTest
    private static void testGetOnlineUsersReport(){
        User clUserObj = LoanServicingTestHelper.getCertifiedLenderUser('Ross Geller');
        

        if (clUserObj != null) {
            System.runAs(clUserObj) {
                Test.startTest();
                // Calling  the API
                List<Map<String, Object>> result = PortalReportsHandler.getOnlineUsersReport();
                System.assert(result.size() >= 1, PortalConstants.ASSERTION_FAILED); 
                Test.stopTest();
            }
        }
    }

    /**
    * @description : This method is used to test the Success sceanario of getCurrentCropYearReport method in PortalReportsHandler
    * @author Tuhin Bhunia | 12-13-2024 
    **/
    @isTest
    private static void testGetCurrentCropYearReport(){
        User clUserObj = LoanServicingTestHelper.getCertifiedLenderUser('Ross Geller');
        

        if (clUserObj != null) {
            System.runAs(clUserObj) {
                Test.startTest();
                // Calling  the API
                List<genesis__Applications__c> result = PortalReportsHandler.getCurrentCropYearReport();
                System.assert(result.size() >= 1, PortalConstants.ASSERTION_FAILED); 
                Test.stopTest();
            }
        }
    }

    /**
    * @description : This method is used to test the Success sceanario of getPriorCropYearReport method in PortalReportsHandler
    * @author Tuhin Bhunia | 01-06-2025 
    **/
    @isTest
    private static void testGetPriorCropYearReport(){
        User clUserObj = LoanServicingTestHelper.getCertifiedLenderUser('Ross Geller');
        Integer month = System.today().month();
        Integer year = System.today().year();
        if (month < 6) {
            year -= 1;
        }
        List<genesis__Applications__c> applicationObjList = [SELECT id, Crop_Year__c
                                                   FROM genesis__Applications__c
                                                   LIMIT 1];
        applicationObjList[0].Crop_Year__c = String.valueOf(year);
        Database.Update(applicationObjList, true);
        

        if (clUserObj != null) {
            System.runAs(clUserObj) {
                Test.startTest();
                // Calling  the API
                List<genesis__Applications__c> result = PortalReportsHandler.getPriorCropYearReport();
                System.assert(result.size() >= 1, PortalConstants.ASSERTION_FAILED); 
                Test.stopTest();
            }
        }
    }

    /**
    * @description : This method is used to test the Success sceanario of getSubsidyAccrualReport method in PortalReportsHandler
    * @author Tuhin Bhunia | 01-06-2025 
    **/
    @isTest
    private static void testGetSubsidyAccrualReport(){
        User clUserObj = LoanServicingTestHelper.getCertifiedLenderUser('Ross Geller');
        String reportFilter = String.valueOf(Datetime.now().format('MMMM')) + ' ' + String.valueOf(System.today().year());

        List<genesis__Application_Fee_Payment__c> resultList = [SELECT id, 
                                                                        Dealer_Monthly_Interest__c,
                                                                        Interest_Earned__c
                                                                FROM genesis__Application_Fee_Payment__c
                                                                WHERE Record_Type__c = :PortalConstants.PARTICIPANT_DAILY];

        resultList[0].Interest_Earned__c = -10; 
        resultList[0].Dealer_Monthly_Interest__c = -10;     
        Database.update(resultList, true);                                            
        
        if (clUserObj != null) {
            System.runAs(clUserObj) {
                Test.startTest();
                // Calling  the API
                List<genesis__Application_Fee_Payment__c> result = PortalReportsHandler.getSubsidyAccrualReport(reportFilter);
                System.assert(result.size() >= 1, PortalConstants.ASSERTION_FAILED); 
                Test.stopTest();
            }
        }
    }

    /**
    * @description : This method is used to test the Success sceanario of getPremiumAccrualReport method in PortalReportsHandler
    * @author Tuhin Bhunia | 01-06-2025 
    **/
    @isTest
    private static void testGetPremiumAccrualReport(){
        User clUserObj = LoanServicingTestHelper.getCertifiedLenderUser('Ross Geller');
        String reportFilter = String.valueOf(Datetime.now().format('MMMM')) + ' ' + String.valueOf(System.today().year());

        List<genesis__Application_Fee_Payment__c> resultList = [SELECT id, 
                                                                        Dealer_Monthly_Interest__c,
                                                                        Interest_Earned__c
                                                                FROM genesis__Application_Fee_Payment__c
                                                                WHERE Record_Type__c = :PortalConstants.PARTICIPANT_DAILY];

        resultList[0].Interest_Earned__c = -10; 
        resultList[0].Dealer_Monthly_Interest__c = -10;     
        Database.update(resultList, true);  
        
        if (clUserObj != null) {
            System.runAs(clUserObj) {
                Test.startTest();
                // Calling  the API
                List<genesis__Application_Fee_Payment__c> result = PortalReportsHandler.getPremiumAccrualReport(reportFilter);
                System.assert(result.size() >= 1, PortalConstants.ASSERTION_FAILED); 
                Test.stopTest();
            }
        }
    }

    /**
    * @description : This method is used to test the Success sceanario of getLoanAccountReport method in PortalReportsHandler
    * @author Tuhin Bhunia | 01-06-2025 
    **/
    @isTest
    private static void testGetLoanAccountReport(){
        User clUserObj = LoanServicingTestHelper.getCertifiedLenderUser('Ross Geller');
        Integer month = System.today().month();
        String year;
        if(month >= 6){
            year = String.valueOf(System.today().addYears(1).year());
        } else {
            year = String.valueOf(System.today().year());
        }
        
        if (clUserObj != null) {
            System.runAs(clUserObj) {
                Test.startTest();
                // Calling  the API
                List<Map<String, Object>> result = PortalReportsHandler.getLoanAccountReport(String.valueOf(year));
                System.assert(result.size() >= 1, PortalConstants.ASSERTION_FAILED); 
                Test.stopTest();
            }
        }
    }

    /**
    * @description : This method is used to test the Success sceanario of getACHBatchHistoryReport method in PortalReportsHandler
    * @author Tuhin Bhunia | 01-06-2025 
    **/
    @isTest
    private static void testGetACHBatchHistoryReport(){
        User clUserObj = LoanServicingTestHelper.getCertifiedLenderUser('Ross Geller');
        List<clcommon__Funding_Transactions_Properties__c> batchList = [SELECT Id 
                                                                FROM clcommon__Funding_Transactions_Properties__c 
                                                                WHERE Name = 'ACH - 07-09-2022'];

        List<Account> dealerAccountList = [SELECT Id, name, OwnerId FROM Account WHERE RecordType.Name =: PortalConstants.DEALER_PROFILE];
        dealerAccountList[0].OwnerId = clUserObj.Id;
        Database.update(dealerAccountList, true);

        if (clUserObj != null) {
            System.runAs(clUserObj) {
                Test.startTest();
                // Calling  the API
                List<genesis__funding_transaction__c> result = PortalReportsHandler.getACHBatchHistoryReport(batchList[0].Id);
                System.assert(result.size() == 1, PortalConstants.ASSERTION_FAILED); 
                Test.stopTest();
            }
        }
    }

    /**
    * @description : This method is used to test the Success sceanario of getDraftHistoryReport method in PortalReportsHandler
    * @author Tuhin Bhunia | 01-06-2025 
    **/
    @isTest
    private static void testGetDraftHistoryReport(){
        User clUserObj = LoanServicingTestHelper.getCertifiedLenderUser('Ross Geller');
        List<Account> dealerAccountList = [SELECT Id, name, OwnerId FROM Account WHERE RecordType.Name =: PortalConstants.DEALER_PROFILE];
        dealerAccountList[0].OwnerId = clUserObj.Id;
        Database.update(dealerAccountList, true);

        if (clUserObj != null) {
            System.runAs(clUserObj) {
                Test.startTest();
                // Calling  the API
                List<genesis__funding_transaction__c> result = PortalReportsHandler.getDraftHistoryReport();
                System.assert(result.size() == 1, PortalConstants.ASSERTION_FAILED); 
                Test.stopTest();
            }
        }
    }

    /**
    * @description This method is used to test the Success sceanario of getResponseDataFromList for genesis__Applications__c method in PortalReportsHandler
    * @author Soumik Pattanayak | 20-01-2025 
    **/
    @isTest
    private static void testGetResponseDataFromListApplication(){
        User clUserObj = LoanServicingTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Applications__c> applicationList = [SELECT Id FROM genesis__Applications__c WHERE OwnerId = :clUserObj.Id];

        if (clUserObj != null) {
            System.runAs(clUserObj) {
                Test.startTest();
                // Calling  the API
                List<clcommon.PortalCustomRemoteActionRecord> result = PortalReportsHandler.getResponseDataFromList(applicationList);
                System.assert(result.size() == 1, PortalConstants.ASSERTION_FAILED); 
                Test.stopTest();
            }
        }
    }

    /**
    * @description This method is used to test the Success sceanario of getResponseDataFromList for genesis__Application_Fee_Payment__c method in PortalReportsHandler
    * @author Soumik Pattanayak | 20-01-2025 
    **/
    @isTest
    private static void testGetResponseDataFromListAppFeePayment(){
        User clUserObj = LoanServicingTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Application_Fee_Payment__c> appFeePaymentList = [SELECT Id FROM genesis__Application_Fee_Payment__c WHERE OwnerId = :clUserObj.Id];

        if (clUserObj != null) {
            System.runAs(clUserObj) {
                Test.startTest();
                // Calling  the API
                List<clcommon.PortalCustomRemoteActionRecord> result = PortalReportsHandler.getResponseDataFromList(appFeePaymentList);
                System.assert(result.size() >= 1, PortalConstants.ASSERTION_FAILED); 
                Test.stopTest();
            }
        }
    }
    
    /**
    * @description This method is used to test the Success sceanario of getResponseDataFromList method for genesis__Application_Fee_Payment__c object map in PortalReportsHandler
    * @author Soumik Pattanayak | 20-01-2025 
    **/
    @isTest
    private static void testGetResponseDataFromListAppFeePaymentObj(){
        User clUserObj = LoanServicingTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__Application_Fee_Payment__c> appFeePaymentList = [SELECT Id,
                                                                                genesis__Application__r.Certified_Lender__r.Name, 
                                                                                genesis__Application__r.Sales_Agent__r.Name, 
                                                                                genesis__Application__r.genesis__Credit_Rating__r.Name, 
                                                                                genesis__Application__r.Note_Date__c,
                                                                                Pricing_Detail__r.Loan_Number__c,
                                                                                genesis__Application__r.genesis__Loan_Number__c,
                                                                                genesis__Application__r.genesis__Loan_Amount__c,
                                                                                genesis__Application__r.genesis__Maturity_Date__c,
                                                                                genesis__Application__r.genesis__Status__c,
                                                                                genesis__Application__r.genesis__Account__r.Name,
                                                                                genesis__Application__r.Current_Principal_Balance__c,
                                                                                genesis__Application__r.Total_Interest__c,
                                                                                genesis__Application__r.Total_Interest_Per_Diem__c,
                                                                                genesis__Application__r.Total_Fees__c,
                                                                                genesis__Application__c,
                                                                                genesis__Application__r.Pricing_Count__c,
                                                                                Pricing_Detail__r.genesis__Application__c,
                                                                                Pricing_Detail__r.genesis__Interest_Rate__c,
                                                                                Pricing_Detail__r.Principal_Advanced__c,
                                                                                Interest_Earned__c,
                                                                                Principal_Balance__c,
                                                                                Per_Diem__c,
                                                                                Fees__c,
                                                                                Interest_Rate__c,
                                                                                Pricing_Detail__r.Interest_Per_Diem__c,
                                                                                Pricing_Detail__r.Fees__c,
                                                                                Pricing_Detail__c,
                                                                                Past_Due_Balance__c,
                                                                                Pricing_Detail__r.genesis__Rate_Card_Setup_Detail__r.Description__c,
                                                                                genesis__Application__r.Crop_Year__c,
                                                                                genesis__Application__r.Internal_Reference_Code__c,
                                                                                genesis__Application__r.Growmark_Unique_Identifier__c,
                                                                                genesis__Application__r.Guarantee__c,
                                                                                genesis__Application__r.Available__c,
                                                                                genesis__Application__r.Reserved_Amount__c,
                                                                                genesis__Application__r.Past_Due_Amount__c,
                                                                                genesis__Application__r.CreatedDate
                                                                        FROM genesis__Application_Fee_Payment__c 
                                                                        WHERE OwnerId = :clUserObj.Id];

        List<Map<String, Object>> childLoanList = new List<Map<String, Object>>();

         for (genesis__Application_Fee_Payment__c objApplicationFeePayment : appFeePaymentList) {
            Map<String, Object> objMap = new Map<String, Object>();
            objMap.put('loan_id', objApplicationFeePayment.Id);
            
            // parent loan
            objMap.put('loan_number', objApplicationFeePayment.genesis__Application__r.genesis__Loan_Number__c);
            objMap.put('principal', 0);
            objMap.put('per_diem', 0);
            objMap.put('fees', 0);
            objMap.put('interest', 0);
            objMap.put('loan_amount', objApplicationFeePayment.genesis__Application__r.genesis__Loan_Amount__c);
            objMap.put('available', objApplicationFeePayment.genesis__Application__r.Available__c);
            objMap.put('reserved', objApplicationFeePayment.genesis__Application__r.Reserved_Amount__c);

            objMap.put('maturity_date', objApplicationFeePayment.genesis__Application__r.genesis__Maturity_Date__c);
            objMap.put('certified_lender', objApplicationFeePayment.genesis__Application__r.Certified_Lender__r.Name);
            objMap.put('sales_agent', objApplicationFeePayment.genesis__Application__r.Sales_Agent__r.Name);
            objMap.put('credit_rating', objApplicationFeePayment.genesis__Application__r.genesis__Credit_Rating__r.Name);
            objMap.put('note_date', objApplicationFeePayment.genesis__Application__r.Note_Date__c);
            objMap.put('status', objApplicationFeePayment.genesis__Application__r.genesis__Status__c);
            objMap.put('grower_name', objApplicationFeePayment.genesis__Application__r.genesis__Account__r.Name);
            objMap.put('purpose', objApplicationFeePayment.Pricing_Detail__r.genesis__Rate_Card_Setup_Detail__r.Description__c);
            objMap.put('crop_year', objApplicationFeePayment.genesis__Application__r.Crop_Year__c);
            objMap.put('irc', objApplicationFeePayment.genesis__Application__r.Internal_Reference_Code__c);
            objMap.put('Growmark_Unique_Identifier__c', objApplicationFeePayment.genesis__Application__r.Growmark_Unique_Identifier__c);
            objMap.put('guaranty', objApplicationFeePayment.genesis__Application__r.Guarantee__c);
            objMap.put('past_due', objApplicationFeePayment.Past_Due_Balance__c);
            objMap.put('created_date', objApplicationFeePayment.genesis__Application__r.CreatedDate);
        
            childLoanList.add(objMap);
        }

        if (clUserObj != null) {
            System.runAs(clUserObj) {
                Test.startTest();
                // Calling  the API
                List<clcommon.PortalCustomRemoteActionRecord> result = PortalReportsHandler.getResponseDataFromList(childLoanList);
                System.assert(result.size() >= 1, PortalConstants.ASSERTION_FAILED); 
                Test.stopTest();
            }
        }
    }

}