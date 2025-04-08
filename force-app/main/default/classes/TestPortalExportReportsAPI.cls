/**
 * @description       : Test class for PortalExportReportsAPI
 * @author            : Rahul Gupta
 * @group             : 
 * @last modified on  : 03-14-2024
 * @last modified by  : Suraj Kumar
**/

@IsTest
public without sharing class TestPortalExportReportsAPI {
    
    @TestSetup
    static void setup() {

        // creating business information
        genesis__Business_Information__c dealerBusinessInformationObj = TestClassHelper.createBusinessInfoForDealer();
        Database.insert(dealerBusinessInformationObj, true);

        // Creating Account for Dealer
        Account dealerAccountObj = TestClassHelper.createDealerAccount(dealerBusinessInformationObj.Id);
        Database.insert(dealerAccountObj, true);

        // Creating Contact for Dealer
        Contact dealerContactObj = TestClassHelper.createDealerContact(dealerAccountObj.Id);
        Database.insert(dealerContactObj, true);

        // creating Account for Certified Lender
        Account clAccountObj = TestClassHelper.createCLAccount(dealerBusinessInformationObj.Id, dealerAccountObj.Id);
        Database.insert(clAccountObj, true);

        // Creating Contact for Certified Lender
        Contact clContactObj = TestClassHelper.createCLContact(clAccountObj.Id);
        Database.insert(clContactObj, true);

        // creating user for certified lender
        User clUser = TestClassHelper.createCLUser(clContactObj.Id);
        Database.insert(clUser, true);

        // creating relationship of certified lender
        clcommon__Reciprocal_Role__c clRoleObj = TestClassHelper.createReciprocalRole('Certified Lender');
        Database.insert(clRoleObj, true);
        clcommon__Relationship__c objRelationship = TestClassHelper.createCLDealerRelationship(clRoleObj,
                                                                                                    dealerAccountObj.Id, 
                                                                                                    clAccountObj.Id);
        Database.insert(objRelationship, true);
                
        // creating borrower
        clcommon__Legal_Entity__c entityObj = TestClassHelper.createLegalEntity(PortalConstants.SOLE_PROP_ENTITY);
        Database.insert(entityObj, true);
        Account borrowerAccountObj = TestClassHelper.createSolePropAccount(entityObj,dealerBusinessInformationObj.Id);
        Database.insert(borrowerAccountObj, true);
        Contact borrowerContactObj = TestClassHelper.createBorrowerContact(borrowerAccountObj.Id);    
        Database.insert(borrowerContactObj, true);
        User borrowerUserObj = TestClassHelper.createBorrowerUser(borrowerContactObj.Id);
        Database.insert(borrowerUserObj, true);

        // Creating CL Product for Application
        clcommon__CL_Product__c clProductObj = TestClassHelper.createCLProductForApplication();
        Database.insert(clProductObj, true);

        // Creating CL Purpose for Application
        clcommon__CL_Purpose__c clPurposeObj = TestClassHelper.createCLPurposeForApplication();
        Database.insert(clPurposeObj, true);

        //creating application
        Map<String,Id> paramForApplicationMap = new Map<String,Id>();
        paramForApplicationMap.put('dealerAccountId', dealerAccountObj.Id);
        paramForApplicationMap.put('clProductId', clProductObj.Id);
        paramForApplicationMap.put('clPurposeId', clPurposeObj.Id);
        paramForApplicationMap.put('borrowerAccountId', borrowerAccountObj.Id);
        paramForApplicationMap.put('borrowerContactId', borrowerContactObj.Id);
        paramForApplicationMap.put('clAccountId', clAccountObj.Id);
        genesis__Applications__c applicationObj = TestClassHelper.createCurrCropYearApplication(paramForApplicationMap);
        applicationObj.Entity_Documents_Task_Pending__c = true;
        applicationObj.AOI_Task_Pending__c = true;
        applicationObj.Collateral_Report_Task_Pending__c = true;
        applicationObj.Payoff_Confirmation_Task_Pending__c = true;
        applicationObj.Lien_Search_Task_Pending__c = true;
        applicationObj.Lien_Subordination_Task_Pending__c = true;
        applicationObj.Security_Notice_Task_Pending__c = true;
        applicationObj.CNS_Task_Pending__c = true;
        applicationObj.Signed_Agreement_Task_Pending__c = true;
        applicationObj.Spousal_Consent_Task_Pending__c = true;
        applicationObj.UCC_Amendment_Task_Pending__c = true;
        applicationObj.UCC_Filing_Task_Pending__c = true;
        applicationObj.Customized_Approval_Task_Pending__c = true;
        Database.insert(applicationObj, true);

        //creating tasks
        Task taskObj = TestClassHelper.createTask(applicationObj.Id, 'Assignment of Insurance');
        Database.insert(taskObj, true);

        taskObj = TestClassHelper.createTask(applicationObj.Id, 'Collateral Report');
        Database.insert(taskObj, true);

        taskObj = TestClassHelper.createTask(applicationObj.Id, 'Entity Documents');
        Database.insert(taskObj, true);

        taskObj = TestClassHelper.createTask(applicationObj.Id, 'Confirmation of Payoff (CFA Action)');
        Database.insert(taskObj, true);

        taskObj = TestClassHelper.createTask(applicationObj.Id, 'Lien Search (CFA Action)');
        Database.insert(taskObj, true);

        taskObj = TestClassHelper.createTask(applicationObj.Id, 'Lien Subordination');
        Database.insert(taskObj, true);

        taskObj = TestClassHelper.createTask(applicationObj.Id, 'Notice of Security Interest (CFA Action)');
        Database.insert(taskObj, true);

        taskObj = TestClassHelper.createTask(applicationObj.Id, 'Signed Central Notification System (CNS) Form');
        Database.insert(taskObj, true);

        taskObj = TestClassHelper.createTask(applicationObj.Id, 'Signed Credit Agreement');
        Database.insert(taskObj, true);

        taskObj = TestClassHelper.createTask(applicationObj.Id, 'Spousal Consent');
        Database.insert(taskObj, true);

        taskObj = TestClassHelper.createTask(applicationObj.Id, 'UCC Amendment (CFA Action)');
        Database.insert(taskObj, true);

        taskObj = TestClassHelper.createTask(applicationObj.Id, 'UCC Filing (CFA Action)');
        Database.insert(taskObj, true);

        taskObj = TestClassHelper.createTask(applicationObj.Id, 'Customized Loan Approval');
        Database.insert(taskObj, true);

        //create borrower party
        clcommon__Party_Type__c borrowerPartyType = TestClassHelper.createPartyType('BORROWER');
        Database.insert(borrowerPartyType, true);
        Map<String,Id> paramForBorrowerPartyMap = new Map<String,Id>();
        paramForBorrowerPartyMap.put('accountId', borrowerAccountObj.Id);
        paramForBorrowerPartyMap.put('contactId', borrowerContactObj.Id);
        paramForBorrowerPartyMap.put('partyTypeId', borrowerPartyType.Id);
        paramForBorrowerPartyMap.put('applicationId', applicationObj.Id);
        clcommon__Party__c borrowerPartyObj = TestClassHelper.createParty(paramForBorrowerPartyMap);
        borrowerPartyObj.genesis__Application__c = applicationObj.Id;
        Database.insert(borrowerPartyObj, true);
        
        // create certified lender party
        clcommon__Party_Type__c clPartyType = TestClassHelper.createPartyType('CERTIFIED LENDER');
        Database.insert(clPartyType, true);
        Map<String,Id> paramForCLPartyMap = new Map<String,Id>();
        paramForCLPartyMap.put('accountId', clAccountObj.Id);
        paramForCLPartyMap.put('contactId', clContactObj.Id);
        paramForCLPartyMap.put('partyTypeId', clPartyType.Id);
        paramForCLPartyMap.put('applicationId', applicationObj.Id);
        clcommon__Party__c certifiedLenderPartyObj = TestClassHelper.createParty(paramForCLPartyMap);
        Database.insert(certifiedLenderPartyObj, true);
    
        // create Dealer party
        clcommon__Party_Type__c dealerPartyType = TestClassHelper.createPartyType('CERTIFIED LENDER');
        Database.insert(dealerPartyType, true);
        Map<String,Id> paramForDealerPartyMap = new Map<String,Id>();
        paramForDealerPartyMap.put('accountId', dealerAccountObj.Id);
        paramForDealerPartyMap.put('contactId', dealerContactObj.Id);
        paramForDealerPartyMap.put('partyTypeId', dealerPartyType.Id);
        paramForDealerPartyMap.put('applicationId', applicationObj.Id);
        clcommon__Party__c dealerPartyObj = TestClassHelper.createParty(paramForDealerPartyMap);
        Database.insert(dealerPartyObj, true);

        // create rate card and pricing detail
        genesis__Rate_Card_Setup_Header__c rateCardSetupHeaderObj = TestClassHelper.createCurrYearRateCardHeader(dealerAccountObj);
        Database.insert(rateCardSetupHeaderObj, true);
        genesis__Rate_Card_Setup_Detail__c rateCardSetupDetailObj = TestClassHelper.createRateCardSetupDetailOne(rateCardSetupHeaderObj);
        Database.insert(rateCardSetupDetailObj, true);
        genesis__Application_Pricing_Detail__c applicationPricingDetailObj = TestClassHelper.createEnabledPricingDetail(applicationObj, rateCardSetupDetailObj.Id);
        Database.insert(applicationPricingDetailObj, true);

        //Create Application Fee Payment record
        genesis__Application_Fee_Payment__c applicationFeePaymentPremium = TestClassHelper.createApplicationFeePayment(applicationObj.Id, applicationPricingDetailObj.Id);
        Database.insert(applicationFeePaymentPremium, true);

        // creating rate card and pricing detail
        rateCardSetupDetailObj = TestClassHelper.createRateCardSetupDetailTwo(rateCardSetupHeaderObj);
        Database.insert(rateCardSetupDetailObj, true);
        applicationPricingDetailObj = TestClassHelper.createDisabledPricingDetail(applicationObj, rateCardSetupDetailObj.Id);
        Database.insert(applicationPricingDetailObj, true);

        genesis__Application_Fee_Payment__c applicationFeePaymentSubsidyObj = TestClassHelper.createApplicationFeePaymentSubsidy(applicationObj.Id, applicationPricingDetailObj.Id);
        Database.insert(applicationFeePaymentSubsidyObj, true);

        // create payment mode
        clcommon__Payment_Mode__c achPaymentModeObj = TestClassHelper.createPaymentMode().get('ACH');
        Database.insert(achPaymentModeObj, true);

        clcommon__Payment_Mode__c draftPaymentModeObj = TestClassHelper.createPaymentMode().get('DRAFT');
        Database.insert(draftPaymentModeObj, true);

        clcommon__Funding_Transactions_Properties__c achFundingTransactionPropertiesObj = TestClassHelper.createFundingTransactionProperty('ACH - 07-09-2022');
        Database.insert(achFundingTransactionPropertiesObj, true);

        // creating ach funding transaction
        Map<String, Id> paramForACHFundingTransactionMap = new Map<String, Id>();
        paramForACHFundingTransactionMap.put('applicationId', applicationObj.Id);
        paramForACHFundingTransactionMap.put('pricingDetailId', applicationPricingDetailObj.Id);
        paramForACHFundingTransactionMap.put('paymentModeId', achPaymentModeObj.Id);
        paramForACHFundingTransactionMap.put('fundingTransactionPropertyId', achFundingTransactionPropertiesObj.Id);

        genesis__Funding_Transaction__c achFundingTransactionObj = TestClassHelper.createACHFundingTransaction(paramForACHFundingTransactionMap);
        Database.insert(achFundingTransactionObj, true);

        // creating draft funding transaction
        Map<String, Id> paramForDraftFundingTransactionMap = new Map<String, Id>();
        paramForDraftFundingTransactionMap.put('applicationId', applicationObj.Id);
        paramForDraftFundingTransactionMap.put('pricingDetailId', applicationPricingDetailObj.Id);
        paramForDraftFundingTransactionMap.put('paymentModeId', draftPaymentModeObj.Id);

        genesis__Funding_Transaction__c objDraftFundingTransaction = TestClassHelper.createDraftFundingTransaction(paramForDraftFundingTransactionMap);
        Database.insert(objDraftFundingTransaction, true);

        //creating previous crop year application
        applicationObj = TestClassHelper.createPrevCropYearApplication(paramForApplicationMap);
        Database.insert(applicationObj, true);

    }


    @IsTest
    private static void testActiveLoanReport() {
        Integer month = System.today().month();
        User objCertifiedLenderUser = TestClassHelper.getCertifiedLenderUser('Ross Geller');

        Map<String, Object> request = new Map<String, Object>();
        request.put('reportType', 'IFP Active Loan Report');

        if(month >= 6){
            request.put('filter', String.valueOf(System.today().addYears(1).year()));
        }
        else{
            request.put('filter', String.valueOf(String.valueOf(System.today().year())));
        }
        request.put('exportType', 'csv');

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalExportReportsAPI portalReportsApi = new PortalExportReportsAPI();
                clcommon.Response response = portalReportsApi.invokeAction('', new List<String>(), request);    
                Test.stopTest();
                System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'SUCCESS'); 
            }
        }
    }

    //pdf report type is not used currently

    // @IsTest
    // private static void testCase2() {
    //     Integer month = System.today().month();
    //     User objCertifiedLenderUser = TestClassHelper.getCertifiedLenderUser('Ross Geller');
    //     Map<String, Object> request = new Map<String, Object>();

    //     request.put('reportType', 'IFP Active Loan Report');
    //     if(month >= 6){
    //         request.put('filter', String.valueOf(System.today().addYears(1).year()));
    //     }
    //     else{
    //         request.put('filter', String.valueOf(String.valueOf(System.today().year())));
    //     }
    //     request.put('exportType', 'pdf');

    //     if (objCertifiedLenderUser != null) {
    //         System.runAs(objCertifiedLenderUser) {
    //             Test.startTest();
    
    //             // Calling  the API
    //             PortalExportReportsAPI portalReportsApi = new PortalExportReportsAPI();
    //             clcommon.Response response = portalReportsApi.invokeAction('', new List<String>(), request);
    //             Test.stopTest();
    //             System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'SUCCESS'); 
    //         }
    //     }
    // }

    @IsTest
    private static void testRateChangeNotificationReport() {
        User objCertifiedLenderUser = TestClassHelper.getCertifiedLenderUser('Ross Geller');

        Map<String, Object> request = new Map<String, Object>();
        request.put('reportType', 'Rate Change Notification Report');
        request.put('exportType', 'csv');

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalExportReportsAPI portalReportsApi = new PortalExportReportsAPI();
                clcommon.Response response = portalReportsApi.invokeAction('', new List<String>(), request);
                Test.stopTest();
                System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'SUCCESS'); 
            }
        }
    }

    //pdf report type is not used currently

    // @IsTest
    // private static void testCase4() {
    //     User objCertifiedLenderUser = TestClassHelper.getCertifiedLenderUser('Ross Geller');
    //     Map<String, Object> request = new Map<String, Object>();
    //     request.put('reportType', 'Rate Change Notification Report');
    //     request.put('exportType', 'pdf');

    //     if (objCertifiedLenderUser != null) {
    //         System.runAs(objCertifiedLenderUser) {
    //             Test.startTest();
    
    //             // Calling  the API
    //             PortalExportReportsAPI portalReportsApi = new PortalExportReportsAPI();
    //             clcommon.Response response = portalReportsApi.invokeAction('', new List<String>(), request);
    //             Test.stopTest();
    //             System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'SUCCESS'); 
    //         }
    //     }
    // }

    @IsTest
    private static void testOnlineUsersReport() {
        User objCertifiedLenderUser = TestClassHelper.getCertifiedLenderUser('Ross Geller');

        Map<String, Object> request = new Map<String, Object>();
        request.put('reportType', 'Online Users Report');
        request.put('exportType', 'csv');

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalExportReportsAPI portalReportsApi = new PortalExportReportsAPI();
                clcommon.Response response = portalReportsApi.invokeAction('', new List<String>(), request);
                Test.stopTest();
                System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'SUCCESS'); 
            }
        }
    }

    //pdf report type is not used currently

    // @IsTest
    // private static void testCase6() {
    //     User objCertifiedLenderUser = TestClassHelper.getCertifiedLenderUser('Ross Geller');

    //     Map<String, Object> request = new Map<String, Object>();
    //     request.put('reportType', 'Online Users Report');
    //     request.put('exportType', 'pdf');

    //     if (objCertifiedLenderUser != null) {
    //         System.runAs(objCertifiedLenderUser) {
    //             Test.startTest();
    
    //             // Calling  the API
    //             PortalExportReportsAPI portalReportsApi = new PortalExportReportsAPI();
    //             clcommon.Response response = portalReportsApi.invokeAction('', new List<String>(), request);
    //             Test.stopTest();
    //             System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'SUCCESS'); 
    //         }
    //     }
    // }

    @IsTest
    private static void testCurrentCropYearReport() {
        User objCertifiedLenderUser = TestClassHelper.getCertifiedLenderUser('Ross Geller');

        Map<String, Object> request = new Map<String, Object>();
        request.put('reportType', 'Current Crop Year Loans Report');
        request.put('exportType', 'csv');

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalExportReportsAPI portalReportsApi = new PortalExportReportsAPI();
                clcommon.Response response = portalReportsApi.invokeAction('', new List<String>(), request);
                Test.stopTest();
                System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'SUCCESS'); 
            }
        }
    }

    //pdf report type is not used currently

    // @IsTest
    // private static void testCase8() {
    //     User objCertifiedLenderUser = TestClassHelper.getCertifiedLenderUser('Ross Geller');

    //     Map<String, Object> request = new Map<String, Object>();
    //     request.put('reportType', 'Current Crop Year Loans Report');
    //     request.put('exportType', 'pdf');

    //     if (objCertifiedLenderUser != null) {
    //         System.runAs(objCertifiedLenderUser) {
    //             Test.startTest();
    
    //             // Calling  the API
    //             PortalExportReportsAPI portalReportsApi = new PortalExportReportsAPI();
    //             clcommon.Response response = portalReportsApi.invokeAction('', new List<String>(), request);    
    //             Test.stopTest();
    //             System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'SUCCESS'); 
    //         }
    //     }
    // }

    @IsTest
    private static void testPreviousCropYearReport() {
        User objCertifiedLenderUser = TestClassHelper.getCertifiedLenderUser('Ross Geller');

        Map<String, Object> request = new Map<String, Object>();
        request.put('reportType', 'Previous Crop Year Loans Report');
        request.put('exportType', 'csv');

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalExportReportsAPI portalReportsApi = new PortalExportReportsAPI();
                clcommon.Response response = portalReportsApi.invokeAction('', new List<String>(), request);    
                Test.stopTest();
                System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'SUCCESS'); 
            }
        }
    }

    //pdf report type is not used currently

    // @IsTest
    // private static void testCase10() {
    //     User objCertifiedLenderUser = TestClassHelper.getCertifiedLenderUser('Ross Geller');

    //     Map<String, Object> request = new Map<String, Object>();
    //     request.put('reportType', 'Previous Crop Year Loans Report');
    //     request.put('exportType', 'pdf');

    //     if (objCertifiedLenderUser != null) {
    //         System.runAs(objCertifiedLenderUser) {
    //             Test.startTest();
    
    //             // Calling  the API
    //             PortalExportReportsAPI portalReportsApi = new PortalExportReportsAPI();
    //             clcommon.Response response = portalReportsApi.invokeAction('', new List<String>(), request);    
    //             Test.stopTest();
    //             System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'SUCCESS'); 
    //         }
    //     }
    // }

    @IsTest
    private static void testLoanAccountReport() {
        Integer month = System.today().month();
        User objCertifiedLenderUser = TestClassHelper.getCertifiedLenderUser('Ross Geller');

        Map<String, Object> request = new Map<String, Object>();
        request.put('reportType', 'Loan Account Report');

        if(month >= 6){
            request.put('filter', String.valueOf(System.today().addYears(1).year()));
        }
        else{
            request.put('filter', String.valueOf(String.valueOf(System.today().year())));
        }
        request.put('exportType', 'csv');

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalExportReportsAPI portalReportsApi = new PortalExportReportsAPI();
                clcommon.Response response = portalReportsApi.invokeAction('', new List<String>(), request);    
                Test.stopTest();
                System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'SUCCESS'); 
            }
        }
    }
    
    //pdf report type is not used currently

    // @IsTest
    // private static void testCase12() {
    //     Integer month = System.today().month();
    //     User objCertifiedLenderUser = TestClassHelper.getCertifiedLenderUser('Ross Geller');

    //     Map<String, Object> request = new Map<String, Object>();
    //     request.put('reportType', 'Loan Account Report');

    //     if(month >= 6){
    //         request.put('filter', String.valueOf(System.today().addYears(1).year()));
    //     }
    //     else{
    //         request.put('filter', String.valueOf(String.valueOf(System.today().year())));
    //     }
    //     request.put('exportType', 'pdf');

    //     if (objCertifiedLenderUser != null) {
    //         System.runAs(objCertifiedLenderUser) {
    //             Test.startTest();
    
    //             // Calling  the API
    //             PortalExportReportsAPI portalReportsApi = new PortalExportReportsAPI();
    //             clcommon.Response response = portalReportsApi.invokeAction('', new List<String>(), request);    
    //             Test.stopTest();
    //             System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'SUCCESS'); 
    //         }
    //     }
    // }

    @IsTest
    private static void testIFPActiveLoanReport() {
        Integer month = System.today().month();
        User objCertifiedLenderUser = TestClassHelper.getCertifiedLenderUser('Ross Geller');

        Map<String, Object> request = new Map<String, Object>();
        request.put('reportType', 'IFP Active Loan Report');

        if(month >= 6){
            request.put('filter', String.valueOf(System.today().addYears(1).year()));
        }
        else{
            request.put('filter', String.valueOf(String.valueOf(System.today().year())));
        }
        request.put('exportType', 'csv');

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalExportReportsAPI portalReportsApi = new PortalExportReportsAPI();
                clcommon.Response response = portalReportsApi.invokeAction('', new List<String>(), request);
                Test.stopTest();
                System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'SUCCESS'); 
            }
        }
    }

    //pdf report type is not used currently

    // @IsTest
    // private static void testCase14() {
    //     Integer month = System.today().month();
    //     User objCertifiedLenderUser = TestClassHelper.getCertifiedLenderUser('Ross Geller');

    //     Map<String, Object> request = new Map<String, Object>();
    //     request.put('reportType', 'IFP Active Loan Report');

    //     if(month >= 6){
    //         request.put('filter', String.valueOf(System.today().addYears(1).year()));
    //     }
    //     else{
    //         request.put('filter', String.valueOf(String.valueOf(System.today().year())));
    //     }
    //     request.put('exportType', 'pdf');

    //     if (objCertifiedLenderUser != null) {
    //         System.runAs(objCertifiedLenderUser) {
    //             Test.startTest();
    
    //             // Calling  the API
    //             PortalExportReportsAPI portalReportsApi = new PortalExportReportsAPI();
    //             clcommon.Response response = portalReportsApi.invokeAction('', new List<String>(), request);    
    //             Test.stopTest();
    //             System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'SUCCESS'); 
    //         }
    //     }
    // }

    @IsTest
    private static void testEOMActiveLoanReport() {
        Integer month = System.today().month();
        User objCertifiedLenderUser = TestClassHelper.getCertifiedLenderUser('Ross Geller');

        Map<String, Object> request = new Map<String, Object>();
        request.put('reportType', 'IFP End Of Month Active Loan Report');

        if(month >= 6){
            request.put('filter', String.valueOf(System.today().addYears(1).year()));
        }
        else{
            request.put('filter', String.valueOf(String.valueOf(System.today().year())));
        }
        request.put('exportType', 'csv');

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalExportReportsAPI portalReportsApi = new PortalExportReportsAPI();
                clcommon.Response response = portalReportsApi.invokeAction('', new List<String>(), request);
                Test.stopTest();
                System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'ERROR'); 
            }
        }
    }

    //pdf report type is not used currently

    // @IsTest
    // private static void testCase16() {
    //     Integer month = System.today().month();
    //     User objCertifiedLenderUser = TestClassHelper.getCertifiedLenderUser('Ross Geller');

    //     Map<String, Object> request = new Map<String, Object>();
    //     request.put('reportType', 'IFP End Of Month Active Loan Report');

    //     if(month >= 6){
    //         request.put('reportFilter', String.valueOf(System.today().addYears(1).year()));
    //     }
    //     else{
    //         request.put('reportFilter', String.valueOf(String.valueOf(System.today().year())));
    //     }
    //     request.put('exportType', 'pdf');

    //     if (objCertifiedLenderUser != null) {
    //         System.runAs(objCertifiedLenderUser) {
    //             Test.startTest();
    
    //             // Calling  the API
    //             PortalExportReportsAPI portalReportsApi = new PortalExportReportsAPI();
    //             clcommon.Response response = portalReportsApi.invokeAction('', new List<String>(), request);    
    //             Test.stopTest();
    //             System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'ERROR'); 
    //         }
    //     }
    // }

    @IsTest
    private static void testIFPEndOfYearReport() {
        User objCertifiedLenderUser = TestClassHelper.getCertifiedLenderUser('Ross Geller');

        Map<String, Object> request = new Map<String, Object>();

        request.put('reportType', 'IFP End Of Year Report');
        request.put('exportType', 'csv');
        request.put('filter', '2022');

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalExportReportsAPI portalReportsApi = new PortalExportReportsAPI();
                clcommon.Response response = portalReportsApi.invokeAction('', new List<String>(), request);
                Test.stopTest();
                System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'Success'); 
            }
        }
    }

    //pdf report type is not used currently

    // @IsTest
    // private static void testCase18() {
    //     User objCertifiedLenderUser = TestClassHelper.getCertifiedLenderUser('Ross Geller');

    //     Map<String, Object> request = new Map<String, Object>();

    //     request.put('reportType', 'IFP End Of Year Report');
    //     request.put('exportType', 'pdf');

    //     if (objCertifiedLenderUser != null) {
    //         System.runAs(objCertifiedLenderUser) {
    //             Test.startTest();
    
    //             // Calling  the API
    //             PortalExportReportsAPI portalReportsApi = new PortalExportReportsAPI();
    //             clcommon.Response response = portalReportsApi.invokeAction('', new List<String>(), request);
    //             Test.stopTest();
    //             System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'ERROR'); 
    //         }
    //     }
    // }

    @IsTest
    private static void testIFPSubsidyAccrualReport() {
        User objCertifiedLenderUser = TestClassHelper.getCertifiedLenderUser('Ross Geller');

        Map<String, Object> request = new Map<String, Object>();

        request.put('reportType', 'IFP Subsidy Accrual Report');
        request.put('exportType', 'csv');

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalExportReportsAPI portalReportsApi = new PortalExportReportsAPI();
                clcommon.Response response = portalReportsApi.invokeAction('', new List<String>(), request);    
                Test.stopTest();
                System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'SUCCESS'); 
            }
        }
    }

    //pdf report type is not used currently

    // @IsTest
    // private static void testCase20() {
    //     User objCertifiedLenderUser = TestClassHelper.getCertifiedLenderUser('Ross Geller');

    //     Map<String, Object> request = new Map<String, Object>();

    //     request.put('reportType', 'IFP Subsidy Accrual Report');
    //     request.put('exportType', 'pdf');

    //     if (objCertifiedLenderUser != null) {
    //         System.runAs(objCertifiedLenderUser) {
    //             Test.startTest();
    
    //             // Calling  the API
    //             PortalExportReportsAPI portalReportsApi = new PortalExportReportsAPI();
    //             clcommon.Response response = portalReportsApi.invokeAction('', new List<String>(), request);    
    //             Test.stopTest();
    //             System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'SUCCESS'); 
    //         }
    //     }
    // }

    @IsTest
    private static void testIFPPremiumAccrualReport() {
        User objCertifiedLenderUser = TestClassHelper.getCertifiedLenderUser('Ross Geller');

        Map<String, Object> request = new Map<String, Object>();

        request.put('reportType', 'IFP Premium Accrual Report');
        request.put('exportType', 'csv');

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalExportReportsAPI portalReportsApi = new PortalExportReportsAPI();
                clcommon.Response response = portalReportsApi.invokeAction('', new List<String>(), request);    
                Test.stopTest();
                System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'SUCCESS'); 
            }
        }
    }

    //pdf report type is not used currently

    // @IsTest
    // private static void testCase22() {
    //     User objCertifiedLenderUser = TestClassHelper.getCertifiedLenderUser('Ross Geller');

    //     Map<String, Object> request = new Map<String, Object>();

    //     request.put('reportType', 'IFP Premium Accrual Report');
    //     request.put('exportType', 'pdf');

    //     if (objCertifiedLenderUser != null) {
    //         System.runAs(objCertifiedLenderUser) {
    //             Test.startTest();
    
    //             // Calling  the API
    //             PortalExportReportsAPI portalReportsApi = new PortalExportReportsAPI();
    //             clcommon.Response response = portalReportsApi.invokeAction('', new List<String>(), request);    
    //             Test.stopTest();
    //             System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'SUCCESS'); 
    //         }
    //     }
    // }

    @IsTest
    private static void testDraftHistoryReport() {
        User objCertifiedLenderUser = TestClassHelper.getCertifiedLenderUser('Ross Geller');

        Map<String, Object> request = new Map<String, Object>();

        request.put('reportType', 'DRAFT History Report');
        request.put('exportType', 'csv');

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalExportReportsAPI portalReportsApi = new PortalExportReportsAPI();
                clcommon.Response response = portalReportsApi.invokeAction('', new List<String>(), request);    
                Test.stopTest();
                System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'SUCCESS'); 
            }
        }
    }

    //pdf report type is not used currently

    // @IsTest
    // private static void testCase24() {
    //     User objCertifiedLenderUser = TestClassHelper.getCertifiedLenderUser('Ross Geller');

    //     Map<String, Object> request = new Map<String, Object>();

    //     request.put('reportType', 'DRAFT History Report');
    //     request.put('exportType', 'pdf');

    //     if (objCertifiedLenderUser != null) {
    //         System.runAs(objCertifiedLenderUser) {
    //             Test.startTest();
    
    //             // Calling  the API
    //             PortalExportReportsAPI portalReportsApi = new PortalExportReportsAPI();
    //             clcommon.Response response = portalReportsApi.invokeAction('', new List<String>(), request);    
    //             Test.stopTest();
    //             System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'SUCCESS'); 
    //         }
    //     }
    // }

    @IsTest
    private static void testACHBatchHistoryReport() {
        User objCertifiedLenderUser = TestClassHelper.getCertifiedLenderUser('Ross Geller');

        Map<String, Object> request = new Map<String, Object>();

        clcommon__Funding_Transactions_Properties__c objBatch = [SELECT Id 
                                                                FROM clcommon__Funding_Transactions_Properties__c 
                                                                WHERE Name = 'ACH - 07-09-2022'];

        request.put('reportType', 'ACH Batch History Report');
        request.put('batchId', objBatch.Id);
        request.put('exportType', 'csv');

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalExportReportsAPI portalReportsApi = new PortalExportReportsAPI();
                clcommon.Response response = portalReportsApi.invokeAction('', new List<String>(), request);    
                Test.stopTest();
                System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'SUCCESS'); 
            }
        }
    }

    //pdf report type is not used currently

    // @IsTest
    // private static void testCase26() {
    //     User objCertifiedLenderUser = TestClassHelper.getCertifiedLenderUser('Ross Geller');

    //     Map<String, Object> request = new Map<String, Object>();

    //     clcommon__Funding_Transactions_Properties__c objBatch = [SELECT Id 
    //                                                             FROM clcommon__Funding_Transactions_Properties__c 
    //                                                             WHERE Name = 'ACH - 07-09-2022'];

    //     request.put('reportType', 'ACH Batch History Report');
    //     request.put('batchId', objBatch.Id);
    //     request.put('exportType', 'pdf');

    //     if (objCertifiedLenderUser != null) {
    //         System.runAs(objCertifiedLenderUser) {
    //             Test.startTest();
    
    //             // Calling  the API
    //             PortalExportReportsAPI portalReportsApi = new PortalExportReportsAPI();
    //             clcommon.Response response = portalReportsApi.invokeAction('', new List<String>(), request);    
    //             Test.stopTest();
    //             System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'SUCCESS'); 
    //         }
    //     }
    // }

    

    @IsTest
    private static void testError() {
        User objCertifiedLenderUser = TestClassHelper.getCertifiedLenderUser('Ross Geller');

        Map<String, Object> request = new Map<String, Object>();

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalExportReportsAPI portalReportsApi = new PortalExportReportsAPI();
                clcommon.Response response = portalReportsApi.invokeAction('', new List<String>(), request);    
                Test.stopTest();
                System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'ERROR'); 
            }
        }
    }

    @IsTest
    private static void testPendingTaskReportCSV() {
        User objCertifiedLenderUser = TestClassHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> request = new Map<String, Object>();

        request.put('reportType', 'Pending Task Report');
        request.put('exportType', 'csv');

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalExportReportsAPI portalReportsApi = new PortalExportReportsAPI();
                clcommon.Response response = portalReportsApi.invokeAction('', new List<String>(), request);    
                Test.stopTest();
                System.assertEquals(clcommon.Constants.SUCCESS, response.status,'SUCCESS'); 
            }
        }
    }

    @IsTest
    private static void testPendingTaskReportPDF() {
        User objCertifiedLenderUser = TestClassHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> request = new Map<String, Object>();

        request.put('reportType', 'Pending Task Report');
        request.put('exportType', 'pdf');

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalExportReportsAPI portalReportsApi = new PortalExportReportsAPI();
                clcommon.Response response = portalReportsApi.invokeAction('', new List<String>(), request);    
                Test.stopTest();
                System.assertEquals(clcommon.Constants.SUCCESS, response.status,'SUCCESS'); 
            }
        }
    }

//pdf report type is not used currently

    // @IsTest
    // private static void testCase29() {
    //     User objCertifiedLenderUser = TestClassHelper.getCertifiedLenderUser('Ross Geller');

    //     Map<String, Object> request = new Map<String, Object>();

    //     request.put('reportType', 'Pending Task Report');
    //     request.put('exportType', 'pdf');

    //     if (objCertifiedLenderUser != null) {
    //         System.runAs(objCertifiedLenderUser) {
    //             Test.startTest();
    
    //             // Calling  the API
    //             PortalExportReportsAPI portalReportsApi = new PortalExportReportsAPI();
    //             clcommon.Response response = portalReportsApi.invokeAction('', new List<String>(), request);    
    //             Test.stopTest();
    //             System.assertEquals(clcommon.Constants.SUCCESS, response.status, 'SUCCESS'); 
    //         }
    //     }
    // }
}