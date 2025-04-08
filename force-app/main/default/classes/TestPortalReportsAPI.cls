/**
 * @description       : Test class for PortalReportsAPI
 * @author            : Rahul Gupta
 * @group             : 
 * @last modified on  : 12-18-2024
 * @last modified by  : Tuhin Bhunia
**/
@IsTest
public without sharing class TestPortalReportsAPI {

    @TestSetup
    static void setup() {
        
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

        // Creating Party Types
        clcommon__Party_Type__c objDealerPartyType = ApplicationOriginationTestHelper.createPartyType(PortalConstants.DEALER_PARTY_NAME);
        clcommon__Party_Type__c objBorrowerPartyType = ApplicationOriginationTestHelper.createPartyType(PortalConstants.BORROWER_PARTY_NAME);
        clcommon__Party_Type__c objCLPartyType = ApplicationOriginationTestHelper.createPartyType(PortalConstants.CL_PARTY_NAME);
        Database.insert(new List<clcommon__Party_Type__c>{
            objDealerPartyType,
            objBorrowerPartyType,
            objCLPartyType
        }, true);

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

        // Creating Users
        User objCLUser = ApplicationOriginationTestHelper.createCLUser(clContactObj.Id);
        User objBorrowerUser = ApplicationOriginationTestHelper.createBorrowerUser(objBorrowerContact.Id);
        Database.insert(new List<User>{
            objCLUser,
            objBorrowerUser
        }, true);

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

        // Creating Party Data Maps
        Map<String,Id> paramForBorrowerPartyMap = new Map<String,Id>{
            'accountId'=> objBorrowerAccount.Id,
            'contactId'=> objBorrowerContact.Id,
            'partyTypeId'=> objBorrowerPartyType.Id,
            'applicationId'=> objApplication.Id
        };

        Map<String,Id> paramForCLPartyMap = new Map<String,Id>{
            'accountId' => objCLAccount.Id,
            'contactId' => clContactObj.Id,
            'partyTypeId' => objCLPartyType.Id,
            'applicationId' => objApplication.Id
        };

        Map<String,Id> paramForDealerPartyMap = new Map<String,Id>{
            'accountId' => objDealerAccount.Id,
            'partyTypeId' => objDealerPartyType.Id,
            'applicationId' => objApplication.Id
        };

        // Inserting Parties
        Database.insert(new List<clcommon__Party__c>{
            ApplicationOriginationTestHelper.createApplicantParty(paramForBorrowerPartyMap, objBorrowerAccount),
            ApplicationOriginationTestHelper.createParty(paramForCLPartyMap),
            ApplicationOriginationTestHelper.createParty(paramForDealerPartyMap)
        }, true);

        // create rate card and pricing detail
        genesis__Rate_Card_Setup_Header__c rateCardSetupHeaderObj = LoanServicingTestHelper.createPrevYearRateCardHeader(objDealerAccount);
        Database.insert(rateCardSetupHeaderObj, true);

        genesis__Rate_Card_Setup_Detail__c rateCardSetupDetailObj = LoanServicingTestHelper.createRateCardSetupDetailOne(rateCardSetupHeaderObj);
        Database.insert(rateCardSetupDetailObj, true);

        List<genesis__Application_Pricing_Detail__c> appPricingDetailList = new List<genesis__Application_Pricing_Detail__c>();

        genesis__Application_Pricing_Detail__c objAppPricingDetail = LoanServicingTestHelper.createEnabledPricingDetail(objApplication, rateCardSetupDetailObj.Id);
        Database.insert(objAppPricingDetail, true);

        appPricingDetailList.add(objAppPricingDetail);
         
        objAppPricingDetail = LoanServicingTestHelper.createEnabledPricingDetail(objApplication, rateCardSetupDetailObj.Id);
        Database.insert(objAppPricingDetail, true);

        appPricingDetailList.add(objAppPricingDetail);

        //application fee payment
        List<genesis__Application_Fee_Payment__c> appFeePaymentList = LoanServicingTestHelper.createApplicationFeePaymentList(objApplication.Id,appPricingDetailList[0].Id);
        Database.insert(appFeePaymentList, true);
    }


    /**
    * @description 
    * @author Tuhin Bhunia | 12-18-2024 
    **/
    @IsTest
    public static void testActiveLoanReport() {

        User objCertifiedLenderUser = TestClassHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> request = new Map<String, Object>();
        request.put(PortalConstants.KEY_REPORT_TYPE, PortalConstants.ACTIVE_LOAN_REPORT);

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();

                // Calling  the API
                PortalReportsAPI portalReportsAPIInst = new PortalReportsAPI();
                clcommon.Response response = portalReportsAPIInst.invokeAction('', new List<String>(), request);    
                Test.stopTest();
                System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED); 
            }
        }
    }

    /**
    * @description 
    * @author Tuhin Bhunia | 12-18-2024 
    **/
    @IsTest
    public static void testCurrentCropYearReport() {

        User objCertifiedLenderUser = TestClassHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> request = new Map<String, Object>();
        request.put(PortalConstants.KEY_REPORT_TYPE, PortalConstants.CURRENT_CROP_YEAR_REPORT);

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();

                // Calling  the API
                PortalReportsAPI portalReportsAPIInst = new PortalReportsAPI();
                clcommon.Response response = portalReportsAPIInst.invokeAction('', new List<String>(), request);    
                Test.stopTest();
                System.assertEquals(clcommon.Constants.SUCCESS, response.status,PortalConstants.ASSERTION_FAILED); 
            }
        }
    }

    /**
    * @description 
    * @author Tuhin Bhunia | 12-18-2024 
    **/
    @IsTest
    public static void testPreviousCropYearReport() {

        User objCertifiedLenderUser = TestClassHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> request = new Map<String, Object>();
        request.put(PortalConstants.KEY_REPORT_TYPE, 'Previous Crop Year Report');

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalReportsAPI portalReportsAPIInst = new PortalReportsAPI();
                clcommon.Response response = portalReportsAPIInst.invokeAction('', new List<String>(), request);    
                Test.stopTest();
                System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED); 
            }
        }
    }

    /**
    * @description 
    * @author Tuhin Bhunia | 12-18-2024 
    **/
    @IsTest
    public static void testLoanAccountReport() {

        User objCertifiedLenderUser = TestClassHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> request = new Map<String, Object>();
        request.put(PortalConstants.KEY_REPORT_TYPE, 'Loan Account Report');
        request.put(PortalConstants.KEY_REPORT_FILTER, '2022');

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalReportsAPI portalReportsAPIInst = new PortalReportsAPI();
                clcommon.Response response = portalReportsAPIInst.invokeAction('', new List<String>(), request);    
                Test.stopTest();
                System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED); 
            }
        }
    }

    /**
    * @description 
    * @author Tuhin Bhunia | 12-18-2024 
    **/
    @IsTest
    public static void testOnlineUsersReport() {

        User objCertifiedLenderUser = TestClassHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> request = new Map<String, Object>();
        request.put(PortalConstants.KEY_REPORT_TYPE, 'Online Users Report');

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalReportsAPI portalReportsAPIInst = new PortalReportsAPI();
                clcommon.Response response = portalReportsAPIInst.invokeAction('', new List<String>(), request);    
                Test.stopTest();
                System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED); 
            }
        }
    }

    /**
    * @description 
    * @author Tuhin Bhunia | 12-18-2024 
    **/
    @IsTest
    public static void testRateChangeNotificationReport() {

        User objCertifiedLenderUser = TestClassHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> request = new Map<String, Object>();
        request.put(PortalConstants.KEY_REPORT_TYPE, 'Rate Change Notification Report');

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalReportsAPI portalReportsAPIInst = new PortalReportsAPI();
                clcommon.Response response = portalReportsAPIInst.invokeAction('', new List<String>(), request);    
                Test.stopTest();
                System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED); 
            }
        }
    }

    /**
    * @description 
    * @author Tuhin Bhunia | 12-18-2024 
    **/
    @IsTest
    public static void testEndOfYearReportWithReportFilter() {

        User objCertifiedLenderUser = TestClassHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> request = new Map<String, Object>();
        request.put(PortalConstants.KEY_REPORT_TYPE, PortalConstants.EOY_REPORT);
        request.put(PortalConstants.KEY_REPORT_FILTER, '2022');

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalReportsAPI portalReportsAPIInst = new PortalReportsAPI();
                clcommon.Response response = portalReportsAPIInst.invokeAction('', new List<String>(), request);    
                Test.stopTest();
                System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED); 
            }
        }
    }

    /**
    * @description 
    * @author Tuhin Bhunia | 12-18-2024 
    **/
    @IsTest
    public static void testEndOfYearReportWithoutReportFilter() {

        User objCertifiedLenderUser = TestClassHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> request = new Map<String, Object>();
        request.put(PortalConstants.KEY_REPORT_TYPE, PortalConstants.EOY_REPORT);

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalReportsAPI portalReportsAPIInst = new PortalReportsAPI();
                clcommon.Response response = portalReportsAPIInst.invokeAction('', new List<String>(), request);    
                Test.stopTest();
                System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED); 
            }
        }
    }

    /**
    * @description 
    * @author Tuhin Bhunia | 12-18-2024 
    **/
    @IsTest
    public static void testEOMActiveLoanReport() {

        User objCertifiedLenderUser = TestClassHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> request = new Map<String, Object>();
        request.put(PortalConstants.KEY_REPORT_TYPE, 'IFP End Of Month Active Loan Report');
        request.put(PortalConstants.KEY_REPORT_FILTER, String.valueOf(Datetime.now().format('MMMM')) + ' ' + String.valueOf(System.today().year()));

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalReportsAPI portalReportsAPIInst = new PortalReportsAPI();
                clcommon.Response response = portalReportsAPIInst.invokeAction('', new List<String>(), request);    
                Test.stopTest();
                System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED); 
            }
        }
    }

    /**
    * @description 
    * @author Tuhin Bhunia | 12-18-2024 
    **/
    @IsTest
    public static void blankRequestParameterExceptionScenario() {

        User objCertifiedLenderUser = TestClassHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> request = new Map<String, Object>();

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalReportsAPI portalReportsAPIInst = new PortalReportsAPI();
                clcommon.Response response = portalReportsAPIInst.invokeAction('', new List<String>(), request);    
                Test.stopTest();
                System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'ERROR'); 
            }
        }
    }

    /**
    * @description 
    * @author Tuhin Bhunia | 12-18-2024 
    **/
    @IsTest
    public static void invalidReportTypeExceptionScenario() {

        User objCertifiedLenderUser = TestClassHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> request = new Map<String, Object>();
        request.put(PortalConstants.KEY_REPORT_TYPE, true);

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalReportsAPI portalReportsAPIInst = new PortalReportsAPI();
                clcommon.Response response = portalReportsAPIInst.invokeAction('', new List<String>(), request);    
                Test.stopTest();
                System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, 'ERROR'); 
            }
        }
    }


    /**
    * @description 
    * @author Tuhin Bhunia | 12-18-2024 
    **/
    @IsTest
    public static void testEOMSubsidyAccrualReport() {

        User objCertifiedLenderUser = TestClassHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> request = new Map<String, Object>();
        request.put(PortalConstants.KEY_REPORT_TYPE, 'IFP End Of Month Subsidy Accrual Report');
        request.put(PortalConstants.KEY_REPORT_FILTER, 'December 2022');

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalReportsAPI portalReportsAPIInst = new PortalReportsAPI();
                clcommon.Response response = portalReportsAPIInst.invokeAction('', new List<String>(), request);    
                Test.stopTest();
                System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED); 
            }
        }
    }

    /**
    * @description 
    * @author Tuhin Bhunia | 12-18-2024 
    **/
    @IsTest
    public static void testEOMPremiumAccrualReport() {

        User objCertifiedLenderUser = TestClassHelper.getCertifiedLenderUser('Ross Geller');

        Map<String, Object> request = new Map<String, Object>();
        request.put(PortalConstants.KEY_REPORT_TYPE, PortalConstants.EOM_PREMIUM_ACCRUAL_REPORT);
        request.put(PortalConstants.KEY_REPORT_FILTER, 'December 2022');

        if (objCertifiedLenderUser != null) {
            System.runAs(objCertifiedLenderUser) {
                Test.startTest();
    
                // Calling  the API
                PortalReportsAPI portalReportsAPIInst = new PortalReportsAPI();
                clcommon.Response response = portalReportsAPIInst.invokeAction('', new List<String>(), request);    
                Test.stopTest();
                System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED); 
            }
        }
    }  
}