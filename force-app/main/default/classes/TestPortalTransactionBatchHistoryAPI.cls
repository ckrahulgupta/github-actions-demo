/**
 * @description       : Test class of PortalTransactionBatchHistoryAPI
 * @author            : Rahul Gupta | 18-07-2022
 * @group             : 
 * @last modified on  : 01-13-2025
 * @last modified by  : Tuhin Bhunia
**/

@isTest
public class TestPortalTransactionBatchHistoryAPI {

    @TestSetup
    static void makeData() {

        // Creating CL Product for Application
        clcommon__CL_Product__c objCLProduct = ApplicationOriginationTestHelper.createCLProductForApplication();
        Database.insert(objCLProduct, true);

        // Creating CL Purpose for Application
        clcommon__CL_Purpose__c objCLPurpose = ApplicationOriginationTestHelper.createCLPurposeForApplication();
        Database.insert(objCLPurpose, true);

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
        Contact objBorrowerContact = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.Id);    
        Database.insert(new List<Contact>{
            clContactObj,
            objBorrowerContact
        }, true);
        
        // Creating Users
        User objCLUser = ApplicationOriginationTestHelper.createCLUser(clContactObj.Id);
        Database.insert(new List<User>{
            objCLUser
        }, true);

        // Creating Dealer Applicant Relationship
        Dealer_Applicant_Relationship__c objDealerAppRelationship = ApplicationOriginationTestHelper.createDealerApplicantRelationship(objBorrowerContact, dealerAccountObj.Id);
        Database.Insert(objDealerAppRelationship, true);

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
            'clProductId'=> objCLProduct.Id,
            'clPurposeId'=> objCLPurpose.Id,
            'borrowerAccountId'=> borrowerAccountObj.Id,
            'borrowerContactId'=> objBorrowerContact.Id,
            'clAccountId'=> clAccountObj.Id
        };

        genesis__Applications__c objApplication = ApplicationOriginationTestHelper.createCurrCropYearApplication(paramForApplicationMap);
        Database.insert(objApplication, true);

        // Creating Party Types
        clcommon__Party_Type__c objDealerPartyType = ApplicationOriginationTestHelper.createPartyType(PortalConstants.DEALER_PARTY_NAME);
        clcommon__Party_Type__c objBorrowerPartyType = ApplicationOriginationTestHelper.createPartyType(PortalConstants.BORROWER_PARTY_NAME);
        clcommon__Party_Type__c objCLPartyType = ApplicationOriginationTestHelper.createPartyType(PortalConstants.CL_PARTY_NAME);
        Database.insert(new List<clcommon__Party_Type__c>{
            objDealerPartyType,
            objBorrowerPartyType,
            objCLPartyType
        }, true);

        // Creating Party Data Maps
        Map<String,Id> paramForBorrowerPartyMap = new Map<String,Id>{
            'accountId'=> borrowerAccountObj.Id,
            'contactId'=> objBorrowerContact.Id,
            'partyTypeId'=> objBorrowerPartyType.Id,
            'applicationId'=> objApplication.Id
        };
        clcommon__party__c objBorrowerParty = ApplicationOriginationTestHelper.createApplicantParty(paramForBorrowerPartyMap, borrowerAccountObj);

        Map<String,Id> paramForCLPartyMap = new Map<String,Id>{
            'accountId' => clAccountObj.Id,
            'contactId' => clContactObj.Id,
            'partyTypeId' => objCLPartyType.Id,
            'applicationId' => objApplication.Id
        };
        clcommon__party__c objCLParty = ApplicationOriginationTestHelper.createParty(paramForCLPartyMap);

        Map<String,Id> paramForDealerPartyMap = new Map<String,Id>{
            'accountId' => dealerAccountObj.Id,
            'partyTypeId' => objDealerPartyType.Id,
            'applicationId' => objApplication.Id
        };
        clcommon__party__c objDealerParty = ApplicationOriginationTestHelper.createParty(paramForDealerPartyMap);

        // Inserting Parties
        Database.insert(new List<clcommon__Party__c>{
            objBorrowerParty,
            objCLParty,
            objDealerParty
        }, true);

        // create rate card and pricing detail
        genesis__Rate_Card_Setup_Header__c rateCardSetupHeaderObj = LoanServicingTestHelper.createPrevYearRateCardHeader(dealerAccountObj);
        rateCardSetupHeaderObj.OwnerID = objCLUser.Id;
        Database.insert(rateCardSetupHeaderObj, true);

        genesis__Rate_Card_Setup_Detail__c objRateCardSetupDetail = LoanServicingTestHelper.createRateCardSetupDetailOne(rateCardSetupHeaderObj);
        objRateCardSetupDetail.Participation_Percentage_Dealer_Subsidy__c = 2.5;
        Database.insert(objRateCardSetupDetail, true);

        genesis__Application_Pricing_Detail__c objAppPricingDetail = LoanServicingTestHelper.createEnabledPricingDetail(objApplication, objRateCardSetupDetail.Id);
        Database.insert(objAppPricingDetail, true);
         
        objAppPricingDetail = LoanServicingTestHelper.createEnabledPricingDetail(objApplication, objRateCardSetupDetail.Id);
        Database.insert(objAppPricingDetail, true);

        // Creating Payment Modes
        clcommon__Payment_Mode__c objPaymentModeACH = LoanServicingTestHelper.createPaymentMode().get(PortalConstants.ACH);
        clcommon__Payment_Mode__c objPaymentModeDraft = LoanServicingTestHelper.createPaymentMode().get(PortalConstants.DRAFT);
        Database.insert(new List<clcommon__Payment_Mode__c>{
            objPaymentModeACH,
            objPaymentModeDraft
        }, true);

        // Creating Funding Transactions Properties
        clcommon__Funding_Transactions_Properties__c objFundingTransacPropACH = LoanServicingTestHelper.createFundingTransactionProperty('ACH-2022-06-17 11:30:01');
        objFundingTransacPropACH.Batch_Total_Amount__c = 1000;
        objFundingTransacPropACH.Status__c = 'Recorded';
        Database.insert(objFundingTransacPropACH, true);

        // Creating Funding Transactions
        Map<String, Id> achFundingTransacParamMap = new Map<String, Id>{
            'applicationId'=> objApplication.Id,
            'pricingDetailId'=> objAppPricingDetail.Id,
            'paymentModeId'=> objPaymentModeACH.Id,
            'fundingTransactionPropertyId'=> objFundingTransacPropACH.Id
        };
        genesis__Funding_Transaction__c achFundingTransactionObj = LoanServicingTestHelper.createACHFundingTransaction(achFundingTransacParamMap);

        Map<String, Id> draftFundingTransParamMap = new Map<String, Id>{
            'applicationId'=> objApplication.Id,
            'pricingDetailId'=> objAppPricingDetail.Id,
            'paymentModeId'=> objPaymentModeDraft.Id
        };
        genesis__Funding_Transaction__c draftFundingTransObj = LoanServicingTestHelper.createDraftFundingTransaction(draftFundingTransParamMap);

        Database.insert(new List<genesis__Funding_Transaction__c>{
            achFundingTransactionObj,
            draftFundingTransObj
        }, true);
    }

    
    /**
    * @description : Purpose of this method is to return the user
    * @author Tuhin Bhunia | 01-13-2025 
    * @param userName 
    * @return User 
    **/
    private static User getCertifiedLenderUser(String userName) {
        User objCLUser;
        // Fetching CL user
        List<User> clUserList = [SELECT Id, Name, Email, ProfileId, UserName, Account.ParentId
                                FROM USER 
                                WHERE UserName = :userName
                                LIMIT 1];
        for(User user : clUserList){
            objCLUser = user;
        }                       
        if (objCLUser != null) {
            return objCLUser;
        } 
        return null;
    }

    /**
    * @description : : Success Scenario - Export ACH history
    * @author Tuhin Bhunia | 12-16-2024 
    **/
    @isTest
    private static void achHistorySuccessScenario() {

        User objCertifiedLenderUser = getCertifiedLenderUser('ross.geller@yopmail.com');
        PortalTransactionBatchHistoryAPI transBatchHistoryAPIInst = new PortalTransactionBatchHistoryAPI();

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
                clcommon.Response response = transBatchHistoryAPIInst.invokeAction(null, null, new Map<String, Object>{
                    PortalConstants.KEY_PAYMENT_MODE => PortalConstants.ACH
                });
                System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED); 
                Test.stopTest();
            }
        }
    }

    /**
    * @description : Success Scenario - Export draft history
    * @author Tuhin Bhunia | 12-16-2024 
    **/
    @isTest
    private static void draftHistorySuccessScenario() {

        User objCertifiedLenderUser = getCertifiedLenderUser('ross.geller@yopmail.com');
        PortalTransactionBatchHistoryAPI transBatchHistoryAPIInst = new PortalTransactionBatchHistoryAPI();

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
                clcommon.Response response = transBatchHistoryAPIInst.invokeAction(null, null, new Map<String, Object>{
                    PortalConstants.KEY_PAYMENT_MODE => PortalConstants.DRAFT
                });
                System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED); 
                Test.stopTest();
            }
        }
    }

    /**
    * @description : Exception scenario - passing payment mode as null in the parameters
    * @author Tuhin Bhunia | 12-16-2024 
    **/
    @isTest
    private static void paymentModeNullExceptionScenario() {

        User objCertifiedLenderUser = getCertifiedLenderUser('ross.geller@yopmail.com');
        PortalTransactionBatchHistoryAPI transBatchHistoryAPIInst = new PortalTransactionBatchHistoryAPI();

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
                clcommon.Response response = transBatchHistoryAPIInst.invokeAction(null, null, new Map<String, Object>{
                    PortalConstants.KEY_PAYMENT_MODE => null
                });
                System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, PortalConstants.ASSERTION_FAILED); 
                Test.stopTest();
            }
        }
    }

    /**
    * @description : Exception Scenario - passing invalid param value of payment mode
    * @author Tuhin Bhunia | 12-16-2024 
    **/
    @isTest
    private static void invalidPaymentModeExceptionScenario() {

        User objCertifiedLenderUser = getCertifiedLenderUser('ross.geller@yopmail.com');
        PortalTransactionBatchHistoryAPI transBatchHistoryAPIInst = new PortalTransactionBatchHistoryAPI();

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
                clcommon.Response response = transBatchHistoryAPIInst.invokeAction(null, null, new Map<String, Object>{
                    PortalConstants.KEY_PAYMENT_MODE => 'randomString'
                });
                System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, PortalConstants.ASSERTION_FAILED);                 
                Test.stopTest();
            }
        }
    }

    /**
    * @description : this method is to test any unexpected exception scenario
    * @author Tuhin Bhunia | 12-16-2024 
    **/
    @isTest
    private static void unexpectedExceptionScenario() {

        User objCertifiedLenderUser = getCertifiedLenderUser('ross.geller@yopmail.com');
        PortalTransactionBatchHistoryAPI transBatchHistoryAPIInst = new PortalTransactionBatchHistoryAPI();

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
                clcommon.Response response = transBatchHistoryAPIInst.invokeAction(null, null, new Map<String, Object>{
                    PortalConstants.KEY_PAYMENT_MODE => true
                });
                System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, PortalConstants.ASSERTION_FAILED); 
                Test.stopTest();
            }
        }
    }
    
}