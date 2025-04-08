/**
 * @description       : Test class for PortalExportPendingACHReportAPI 
 * @author            : Suraj Kumar
 * @group             : 
 * @last modified on  : 12-17-2024
 * @last modified by  : Sk Minsar
**/
@isTest
public with sharing class PortalExportPendingACHReportAPITest {

    /**
    * @description - Creating test data
    * @author Sk Minsar | 12-17-2024 
    **/
    @TestSetup
    static void setup() {
        // Creating Business information
        genesis__Business_Information__c dealerBusinessInfoObj = LoanServicingTestHelper.createBusinessInfoForDealer();
        Database.insert(dealerBusinessInfoObj,true);
        // Creating dealer account
        Account dealerAccountObj = LoanServicingTestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        Database.insert(dealerAccountObj, true);

        // creating legal entity 
        clcommon__Legal_Entity__c entityObj= LoanServicingTestHelper.createLegalEntity('Individual(s) with DBA');
        Database.insert(entityObj,true);

         // creating Accounts
         Account clAccountObj = LoanServicingTestHelper.createCLAccount(dealerBusinessInfoObj.Id,dealerAccountObj.Id);
         Account borrowerAccountObj=LoanServicingTestHelper.createSolePropAccount(entityObj,LoanServicingTestHelper.createBusinessInfoForBorrower().Id);
         Database.insert(new List<Account>{clAccountObj, borrowerAccountObj}, true);

        // Creating Contact 
        Contact dealerContactObj = LoanServicingTestHelper.createDealerContact(dealerAccountObj);
        Contact clContactObj = LoanServicingTestHelper.createCLContact(clAccountObj.Id);
        Contact borrowerContactObj=LoanServicingTestHelper.createBorrowerContact(borrowerAccountObj.Id);
        Database.insert(new List<Contact>{dealerContactObj, clContactObj, borrowerContactObj},true);

        // creating cl User
        User clUserObj = LoanServicingTestHelper.createCLUser(clContactObj.Id);
        User borrowerUserObj = LoanServicingTestHelper.createBorrowerUser(borrowerContactObj.Id);
        Database.insert(new List<User>{borrowerUserObj, clUserObj},true);

        // creating Reciprocal role
        clcommon__Reciprocal_Role__c roleObj = LoanServicingTestHelper.createReciprocalRole('Certified Lender');
        Database.insert(roleObj,true);

        // Creating Relationship between Dealer and Certified Lender
        clcommon__Relationship__c clDealerRelationshipObj = LoanServicingTestHelper.createCLDealerRelationship(roleObj,dealerAccountObj.Id,clAccountObj.Id);
        Database.insert(clDealerRelationshipObj, true);

        // creating cl product
        clcommon__CL_Product__c clProductObj=LoanServicingTestHelper.createCLProductForApplication();
        Database.insert(clProductObj,true);
        // creating cl purpose
        clcommon__CL_Purpose__c clPurposeObj=LoanServicingTestHelper.createCLPurposeForApplication();
        Database.insert(clPurposeObj,true);
        

        //creating application
        genesis__Applications__c applicationObj = LoanServicingTestHelper.createCurrCropYearApplication(new Map<String,Id>{
            'dealerAccountId' => dealerAccountObj.Id,
            'clProductId' => clProductObj.Id,
            'clPurposeId' => clPurposeObj.Id,
            'borrowerAccountId' => borrowerAccountObj.Id,
            'borrowerContactId' => borrowerContactObj.Id,
            'clAccountId' => clAccountObj.Id
        });
        Database.insert(applicationObj,true);


        // Creating Party Type
        clcommon__Party_Type__c borrowerPartyTypeObj = LoanServicingTestHelper.createPartyType('BORROWER');
        clcommon__Party_Type__c clPartyTypeObj = LoanServicingTestHelper.createPartyType('CERTIFIED LENDER');
        clcommon__Party_Type__c dealerPartyTypeObj = LoanServicingTestHelper.createPartyType('DEALER');
        Database.insert(new List<clcommon__Party_Type__c>{dealerPartyTypeObj, borrowerPartyTypeObj, clPartyTypeObj }, true);

        //Create party
        clcommon__Party__c borrowerPartyObj = LoanServicingTestHelper.createParty( new Map<String,Id>{
            'accountId' => borrowerAccountObj.Id,
            'contactId' => borrowerContactObj.Id,
            'partyTypeId' => borrowerPartyTypeObj.Id,
            'applicationId' => applicationObj.Id
            });
        clcommon__Party__c clPartyObj = LoanServicingTestHelper.createParty(new Map<String,Id>{
            'accountId' => clAccountObj.Id,
            'contactId' => clContactObj.Id,
            'partyTypeId' => clPartyTypeObj.Id,
            'applicationId' => applicationObj.Id});
        clcommon__Party__c dealerPartyObj = LoanServicingTestHelper.createParty( new Map<String,Id>{
            'accountId' => dealerAccountObj.Id,
            'contactId' => dealerContactObj.Id,
            'partyTypeId' => dealerPartyTypeObj.Id,
            'applicationId' => applicationObj.Id});
        Database.insert(new List<clcommon__Party__c>{borrowerPartyObj, clPartyObj, dealerPartyObj},true);


        Map<String, clcommon__Payment_Mode__c> paymentModeMap = LoanServicingTestHelper.createPaymentMode();

        // Create ACH Payment Mode
        clcommon__Payment_Mode__c achPaymentModeObj = paymentModeMap.get('ACH');
        Database.insert(achPaymentModeObj,true);

        clcommon__Consolidated_Invoice__c achInvoiceObj = LoanServicingTestHelper.createInvoice(applicationObj.Id, achPaymentModeObj.Id);
        Database.insert(achInvoiceObj, true);

        // Creating ACH funding transaction properties
        clcommon__Funding_Transactions_Properties__c achfundingPropertiesObj = LoanServicingTestHelper.createAchFundingTransactionProperties();
        Database.insert(achfundingPropertiesObj,true);

        // Creating ACH funding transaction
        genesis__Funding_Transaction__c achfundingTransactionObj = LoanServicingTestHelper.createFundingTransaction(achPaymentModeObj.Id, achfundingPropertiesObj.Id, applicationObj.Id);
        achfundingTransactionObj.Invoice__c = achInvoiceObj.Id;
        Database.insert(achfundingTransactionObj,true);

        // Creating Rate card setup header
        genesis__Rate_Card_Setup_Header__c rateCardHeaderObj = LoanServicingTestHelper.createRateCardHeader(borrowerAccountObj);
        Database.insert(rateCardHeaderObj,true);

        // Creating rate card setup detail
        genesis__Rate_Card_Setup_Detail__c rateCardDetailObj = LoanServicingTestHelper.createRateCardSetupDetail(rateCardHeaderObj);
        Database.insert(rateCardDetailObj,true);

        // Creating pricing detail
        genesis__Application_Pricing_Detail__c pricingDetailsObj = LoanServicingTestHelper.createEnabledPricingDetail(applicationObj,rateCardDetailObj.Id);
        Database.insert(pricingDetailsObj,true);

        //Updating total amount in invoice
        achInvoiceObj.Total_Amount__c = achfundingTransactionObj.genesis__Amount__c;
        Database.update(achInvoiceObj, true);
    }


    /**
    * @description - Get Certified lender User
    * @author Sk Minsar | 12-17-2024 
    * @return User 
    **/
    private static User getCertifiedLenderUser(){
        return [SELECT Id FROM User WHERE UserName='ross.geller@yopmail.com' LIMIT 1];
    }
    /**
    * @description - Test export ACH report CSV success
    * @author Sk Minsar | 12-17-2024 
    **/
    @isTest
    public static void testExportPendingAchCsvReport(){
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put('exportType', 'csv');
        System.runAs(getCertifiedLenderUser()){
            Test.startTest();
            PortalExportPendingACHReportAPI saveApi = new PortalExportPendingACHReportAPI();
            clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }                                                                        
    }

    /**
    * @description - Test PDF export succcess
    * @author Sk Minsar | 12-17-2024 
    **/
    @isTest
    public static void testExportPendingAchPdfReport(){
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put('exportType', 'pdf');
        System.runAs(getCertifiedLenderUser()){
            Test.startTest();
            PortalExportPendingACHReportAPI saveApi = new PortalExportPendingACHReportAPI();
            clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }                                                                        
    }

    /**
    * @description - Test Required param exception
    * @author Sk Minsar | 12-17-2024 
    **/
    @isTest
    public static void testCustomExceptionRequiredParameterMissing(){
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put('exportType', '');
        System.runAs(getCertifiedLenderUser()){
            Test.startTest();
            PortalExportPendingACHReportAPI saveApi = new PortalExportPendingACHReportAPI();
            clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }                                                                        
    }

    /**
    * @description - Test Required param exception
    * @author Sk Minsar | 12-17-2024 
    **/
    @isTest
    public static void testCustomExceptionKeyMissing(){
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put('', 'csv');
        System.runAs(getCertifiedLenderUser()){
            Test.startTest();
            PortalExportPendingACHReportAPI saveApi = new PortalExportPendingACHReportAPI();
            clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }                                                                        
    }

    /**
    * @description - Test no data to export excetion
    * @author Sk Minsar | 12-17-2024 
    **/
    @isTest
    public static void testCustomExceptionNoDataToExport(){
        User borrowerUserObj = [SELECT Id 
                                        FROM User 
                                        WHERE UserName='jasmine.albin@yopmail.com' 
                                        LIMIT 1];
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put('exportType', 'csv');
        System.runAs(borrowerUserObj){
            Test.startTest();
            PortalExportPendingACHReportAPI saveApi = new PortalExportPendingACHReportAPI();
            clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }                                                                        
    }

    /**
    * @description - Test Failure API Exception
    * @author Sk Minsar | 12-17-2024 
    **/
    @isTest
    public static void testApiFailure(){
        Map<String, Object> requestMap = null;
        System.runAs(getCertifiedLenderUser()){
            Test.startTest();
            PortalExportPendingACHReportAPI saveApi = new PortalExportPendingACHReportAPI();
            clcommon.Response response = saveApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }                                                                        
    }
}