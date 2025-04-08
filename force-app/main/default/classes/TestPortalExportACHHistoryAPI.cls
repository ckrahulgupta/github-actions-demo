/**
 * @description       : Test class of PortalExportACHHistoryAPI 91%
 * @author            : Ayush Kumar Singh
 * @group             : 
 * @last modified on  : 01-13-2025
 * @last modified by  : Tuhin Bhunia
**/
@isTest
global without sharing class TestPortalExportACHHistoryAPI {

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
        Account objDealerAccount = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.Id, newPartnerProgramObj.Id);
        Database.insert(objDealerAccount, true);

        Account objCLAccount = ApplicationOriginationTestHelper.createCLAccount(dealerBusinessInfoObj.Id, objDealerAccount.Id);
        Account objBorrowerAccount = ApplicationOriginationTestHelper.createSolePropAccount(entityObj, borrowerBusinessInfoObj.Id);
        Database.insert(new List<Account>{
            objCLAccount,
            objBorrowerAccount
        }, true);
        
        // Creating Contacts
        Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(objCLAccount.Id);
        Contact objBorrowerContact = ApplicationOriginationTestHelper.createBorrowerContact(objBorrowerAccount.Id);    
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
        Dealer_Applicant_Relationship__c objDealerAppRelationship = ApplicationOriginationTestHelper.createDealerApplicantRelationship(objBorrowerContact, objDealerAccount.Id);
        Database.Insert(objDealerAppRelationship, true);

        // Creating Roles
        clcommon__Reciprocal_Role__c clRoleObj = ApplicationOriginationTestHelper.createReciprocalRole(PortalConstants.CERTIFIED_LENDER);
        Database.insert(clRoleObj, true);

        // Creating Relationships
        Database.insert(ApplicationOriginationTestHelper.createCLDealerRelationship(clRoleObj, 
                                                                    objDealerAccount.Id, 
                                                                    objCLAccount.Id), true);

        // Creating Application
        Map<String,Id> paramForApplicationMap = new Map<String,Id>{
            'dealerAccountId'=> objDealerAccount.Id,
            'clProductId'=> objCLProduct.Id,
            'clPurposeId'=> objCLPurpose.Id,
            'borrowerAccountId'=> objBorrowerAccount.Id,
            'borrowerContactId'=> objBorrowerContact.Id,
            'clAccountId'=> objCLAccount.Id
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
            'accountId'=> objBorrowerAccount.Id,
            'contactId'=> objBorrowerContact.Id,
            'partyTypeId'=> objBorrowerPartyType.Id,
            'applicationId'=> objApplication.Id
        };
        clcommon__party__c objBorrowerParty = ApplicationOriginationTestHelper.createApplicantParty(paramForBorrowerPartyMap, objBorrowerAccount);

        Map<String,Id> paramForCLPartyMap = new Map<String,Id>{
            'accountId' => objCLAccount.Id,
            'contactId' => clContactObj.Id,
            'partyTypeId' => objCLPartyType.Id,
            'applicationId' => objApplication.Id
        };
        clcommon__party__c objCLParty = ApplicationOriginationTestHelper.createParty(paramForCLPartyMap);

        Map<String,Id> paramForDealerPartyMap = new Map<String,Id>{
            'accountId' => objDealerAccount.Id,
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
        genesis__Rate_Card_Setup_Header__c rateCardSetupHeaderObj = LoanServicingTestHelper.createPrevYearRateCardHeader(objDealerAccount);
        // rateCardSetupHeaderObj.OwnerID = objCLUser.Id;
        Database.insert(rateCardSetupHeaderObj, true);

        genesis__Rate_Card_Setup_Detail__c objRateCardSetupDetail = LoanServicingTestHelper.createRateCardSetupDetailOne(rateCardSetupHeaderObj);
        objRateCardSetupDetail.Participation_Percentage_Dealer_Subsidy__c = 2.5;
        Database.insert(objRateCardSetupDetail, true);

        List<genesis__Application_Pricing_Detail__c> appPricingDetailList = new List<genesis__Application_Pricing_Detail__c>();

        genesis__Application_Pricing_Detail__c objAppPricingDetail = LoanServicingTestHelper.createEnabledPricingDetail(objApplication, objRateCardSetupDetail.Id);
        Database.insert(objAppPricingDetail, true);

        appPricingDetailList.add(objAppPricingDetail);
         
        objAppPricingDetail = LoanServicingTestHelper.createEnabledPricingDetail(objApplication, objRateCardSetupDetail.Id);
        Database.insert(objAppPricingDetail, true);

        appPricingDetailList.add(objAppPricingDetail);

        // Creating Payment Modes
        clcommon__Payment_Mode__c objPaymentModeACH = LoanServicingTestHelper.createPaymentMode().get(PortalConstants.ACH);
        Database.insert(new List<clcommon__Payment_Mode__c>{
            objPaymentModeACH
        }, true);

        // Creating Funding Transactions Properties
        clcommon__Funding_Transactions_Properties__c objFundingTransacPropACH = LoanServicingTestHelper.createFundingTransactionProperty('ACH-2022-06-17 11:30:01');
        objFundingTransacPropACH.Batch_Total_Amount__c = 1000;
        objFundingTransacPropACH.Status__c = 'Recorded';
        objFundingTransacPropACH.Recorded_Date__c  = Date.today().addDays(-1);
        Database.insert(objFundingTransacPropACH, true);

        // Creating Funding Transactions
        Map<String, Id> achFundingTransacParamMap = new Map<String, Id>{
            'applicationId'=> objApplication.Id,
            'pricingDetailId'=> objAppPricingDetail.Id,
            'paymentModeId'=> objPaymentModeACH.Id,
            'fundingTransactionPropertyId'=> objFundingTransacPropACH.Id
        };
        genesis__Funding_Transaction__c achFundingTransactionObj = LoanServicingTestHelper.createACHFundingTransaction(achFundingTransacParamMap);
        Database.insert(new List<genesis__Funding_Transaction__c>{
            achFundingTransactionObj
        }, true);
    }

    /**
    * @description : return the certified lender user
    * @author Suraj Kumar | 03-11-2024 
    * @return User 
    **/
    private static User getCertifiedLenderUser() {
        User objCLUser;
        // Fetching CL user
        List<User> clUserList = [SELECT Id, Name, Email, ProfileId, UserName, Account.ParentId
                                FROM USER 
                                WHERE UserName = 'ross.geller@yopmail.com'
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
    * @description : Success scenario - export type pdf
    * @author Tuhin Bhunia | 12-16-2024 
    **/
    @isTest
    private static void exportTypePDFSuccessScenario() {

        User clUser = getCertifiedLenderUser();
        PortalExportACHHistoryAPI exportACHHistoryAPIInst = new PortalExportACHHistoryAPI();
        System.runAs(clUser) {
            Test.startTest();
            clcommon.Response response = exportACHHistoryAPIInst.invokeAction('', new List<String>(), new Map<String, Object>{
                PortalConstants.KEY_EXPORT_TYPE => 'pdf'
            });
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description : Success scenario - export type csv
    * @author Tuhin Bhunia | 12-16-2024 
    **/
    @isTest
    private static void exportTypeCSVSuccessScenario() {

        User clUser = getCertifiedLenderUser();
        PortalExportACHHistoryAPI exportACHHistoryAPIInst = new PortalExportACHHistoryAPI();
        System.runAs(clUser) {
            Test.startTest();
            clcommon.Response response = exportACHHistoryAPIInst.invokeAction('', new List<String>(), new Map<String, Object>{
                PortalConstants.KEY_EXPORT_TYPE => 'csv'
            });
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description : Covers the Unexpected exception scenario
    * @author Tuhin Bhunia | 12-16-2024 
    **/
    @isTest
    private static void unexpectedExceptionScenario() {

        User clUser = getCertifiedLenderUser();
        PortalExportACHHistoryAPI exportACHHistoryAPIInst = new PortalExportACHHistoryAPI();
        System.runAs(clUser) {
            Test.startTest();
            clcommon.Response response = exportACHHistoryAPIInst.invokeAction('', new List<String>(), new Map<String, Object>{
                PortalConstants.KEY_EXPORT_TYPE => true // invalid data type
            });
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description : Exception scenario - passing export type as blank
    * @author Tuhin Bhunia | 12-16-2024 
    **/
    @isTest
    private static void exportTypeBlankExceptionScenario() {

        User clUser = getCertifiedLenderUser();
        PortalExportACHHistoryAPI exportACHHistoryAPIInst = new PortalExportACHHistoryAPI();
        System.runAs(clUser) {
            Test.startTest();
            clcommon.Response response = exportACHHistoryAPIInst.invokeAction('', new List<String>(), new Map<String, Object>{
                PortalConstants.KEY_EXPORT_TYPE => PortalConstants.EMPTY_STRING
            });
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description : Exception scenario - No data to export
    * @author Tuhin Bhunia | 12-16-2024 
    **/
    @isTest
    private static void noDataToExportExceptionScenario() {
        
        List<genesis__Funding_Transaction__c> fundingTransactionList = [SELECT Id FROM genesis__Funding_Transaction__c];
        Database.Delete(fundingTransactionList, true);
        User clUser = getCertifiedLenderUser();
        PortalExportACHHistoryAPI exportACHHistoryAPIInst = new PortalExportACHHistoryAPI();
        System.runAs(clUser) {
            Test.startTest();
            clcommon.Response response = exportACHHistoryAPIInst.invokeAction('', new List<String>(), new Map<String, Object>{
                PortalConstants.KEY_EXPORT_TYPE => 'pdf'
            });
            System.assertEquals(PortalConstants.NO_DATA_TO_EXPORT, response.errorMessage, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description : Code coverage if csv table data rows are null
    * @author Tuhin Bhunia | 12-16-2024 
    **/
    @isTest
    private static void testcreateCSVTableRowNullValue(){
        User clUser = getCertifiedLenderUser();
        List<clcommon__Funding_Transactions_Properties__c> fundingTransacPropList = [SELECT Id, Status__c 
                                                                                     FROM clcommon__Funding_Transactions_Properties__c 
                                                                                     WHERE Name = 'ACH-2022-06-17 11:30:01'];
        for(clcommon__Funding_Transactions_Properties__c objFundingTransacProp : fundingTransacPropList){
            objFundingTransacProp.Status__c = null;
        }
        Database.Update(fundingTransacPropList, true);
        PortalExportACHHistoryAPI exportACHHistoryAPIInst = new PortalExportACHHistoryAPI();
        System.runAs(clUser) {
            Test.startTest();
            clcommon.Response response = exportACHHistoryAPIInst.invokeAction('', new List<String>(), new Map<String, Object>{
                PortalConstants.KEY_EXPORT_TYPE => 'csv'
            });
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }
    
    /**
    * @description : Code coverage if pdf table data rows are null
    * @author Tuhin Bhunia | 12-16-2024 
    **/
    @isTest
    private static void testcreatePDFTableRowNullValue(){
        User clUser = getCertifiedLenderUser();
        List<clcommon__Funding_Transactions_Properties__c> fundingTransacPropList = [SELECT Id, Status__c 
                                                                                     FROM clcommon__Funding_Transactions_Properties__c 
                                                                                     WHERE Name = 'ACH-2022-06-17 11:30:01'];
        for(clcommon__Funding_Transactions_Properties__c objFundingTransacProp : fundingTransacPropList){
            objFundingTransacProp.Status__c = null;
        }
        Database.Update(fundingTransacPropList, true);
        PortalExportACHHistoryAPI exportACHHistoryAPIInst = new PortalExportACHHistoryAPI();
        System.runAs(clUser) {
            Test.startTest();
            clcommon.Response response = exportACHHistoryAPIInst.invokeAction('', new List<String>(), new Map<String, Object>{
                PortalConstants.KEY_EXPORT_TYPE => 'pdf'
            });
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }
}