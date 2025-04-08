/**
 * @description       : Test class for NLSXMLImportPayOffCalloutBatch
 * @author            : Simran
 * @group             : 
 * @last modified on  : 01-28-2025
 * @last modified by  : Kabir Pramanik
**/
@isTest(seeAllData=true)
public with sharing class NLSXMLImportPayOffCalloutBatchTest { 
    /**
    * @description       : This class implements a interface method which return mock response of NLS
    * @author            : Kabir Pramanik
    * @last modified on  : 01-28-2025
    * @last modified by  : Kabir Pramanik
    **/
    public class NLSXMLImportHttpCalloutMock implements HttpCalloutMock {
        /**
        * @description : method to get mock response of NLS
        * @author Kabir Pramanik | 09-10-2024 
        * @param request 
        * @return HTTPResponse 
        **/
        public HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setStatus('SUCCESS');
            response.setHeader('Content-Type', 'application/json');
            if(request.getEndpoint().contains('token')){
                String token = '{"access_token":"eyJhbGciOiJSUzI1NiIsI","expires_in":300,"token_type":"Bearer"}';
                response.setBody(token);
            }
            else{
                response.setBody('{"status":{"code":200,"message":"Success"},"payload":{"data":""}}');
            }
            return response;
        }
    }

     /**
    * @description       : Setting up the Mock Response of FAILED status for access token generation callout
    * @author            : Kabir Pramanik
    * @last modified on  : 01-28-2025
    * @last modified by  : Kabir Pramanik
    **/
    public class NLSXMLImportAccessTokenFailureMock implements HttpCalloutMock {
        /**
        * @description : return the mock response of FAILED status
        * @author Kabir Pramanik | 12-17-2024
        * @param request 
        * @return HTTPResponse 
        **/
        public HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            response.setStatusCode(400);
            response.setStatus('FAILED');
            response.setHeader('Content-Type', 'application/json');
            return response;
        }
    }
    /**
    * @description       :Setting up the Mock Response of Bad Request
    * @author            : Kabir Pramanik
    * @last modified on  : 01-28-2025
    * @last modified by  : Kabir Pramanik
    **/
    public class NLSXMLImportHttpCalloutFailureMock implements HttpCalloutMock {
        /**
        * @description : method to get mock response of NLS
        * @author Kabir Pramanik | 01-09-2025
        * @param request 
        * @return HTTPResponse 
        **/
        public HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            if(request.getEndpoint().contains('token')){
                String token = '{"access_token":"eyJhbGciOiJSUzI1NiIsI","expires_in":300,"token_type":"Bearer"}';
                response.setStatusCode(200);
                response.setStatus('SUCCESS');
                response.setBody(token);
            }
            else{
                response.setStatusCode(400);
                response.setStatus('FAILED');
                response.setBody('{"status":{"code":400,"message":"Validation Error"},"payload":{"data":""}}');
            }
            return response;
        }
    }

    /**
    * @description       : Setting up the Mock Response for Unauthorized Access status
    * @author            : Kabir Pramanik
    * @last modified on  : 01-28-2025
    * @last modified by  : Kabir Pramanik
    **/
    public class NLSXMLImportUnauthorizedAccessMock implements HttpCalloutMock {
        
        /**
        * @description : method to get mock response of NLS
        * @author Kabir Pramanik | 09-10-2024 
        * @param request 
        * @return HTTPResponse 
        **/
        public HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            if(request.getEndpoint().contains('token')){
                String token = '';
                response.setBody(token);
                response.setStatusCode(200);
                response.setStatus('SUCCESS');
            }
            else{
                response.setStatusCode(401);
                response.setStatus('FAILED');
                response.setBody('{"status":{"code":401,"message":"Authorization has been denied for this request.","executionTime": 5}}');
            }
            return response;
        }
    }

    /**
    * @description create the test datas for testing as it will be common for all the test methods
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
        Database.insert(new List<clcommon__Payment_Mode__c> {
            paymentModeMap.get(ConstantValues.PAYMENT)
        }, true);

        //Creating funding txns for Payment
        createFundingTransactions(new Map<String, Object> {
            'applicationId' => applicationObj.Id,
            'paymentModeId' => paymentModeMap.get(ConstantValues.PAYMENT).Id,
            'pricingDetailsList' => pricingDetailsObjList
        });
    }

    /**
    * @description creating funding transactions along with funding txn properties and invoices
    * @author Kabir Pramanik | 01-10-2025 
    * @param paramMap 
    **/
    private static void createFundingTransactions(Map<String, Object> paramMap){
        Id applicationId = (Id) paramMap.get('applicationId');
        Id paymentModeId = (Id) paramMap.get('paymentModeId');
        List<genesis__Application_Pricing_Detail__c> pricingDetailsList = 
                (List<genesis__Application_Pricing_Detail__c>) paramMap.get('pricingDetailsList');
        //Creating Funding Transactions Properties batch
        Map<String, clcommon__Funding_Transactions_Properties__c> fundingTraxPropMap = LoanServicingTestHelper.createFundingTransactionProperties();
        Database.insert(fundingTraxPropMap.get(ConstantValues.PRODUCT_RETURN), true);

        //Create invoices 
        clcommon__Consolidated_Invoice__c paymentInvoiceObj = LoanServicingTestHelper.createInvoice(applicationId, paymentModeId);
        paymentInvoiceObj.clcommon__Status__c = ConstantValues.STATUS_INITIATED;
        Database.insert(paymentInvoiceObj, true);

        genesis__Funding_Transaction__c payOffObj = LoanServicingTestHelper.createFundingTransaction(paymentModeId, fundingTraxPropMap.get(ConstantValues.PRODUCT_RETURN).ID,applicationId);
        payOffObj.Pricing_Detail__c = pricingDetailsList[0].Id;
        payOffObj.genesis__Cleared__c = ConstantValues.TRUE_VALUE;
        payOffObj.Posted_to_NLS__c = ConstantValues.FALSE_VALUE;
        payOffObj.Invoice__c = paymentInvoiceObj.Id;
        genesis__Funding_Transaction__c payOffObjTwo = LoanServicingTestHelper.createFundingTransaction(paymentModeId, fundingTraxPropMap.get(ConstantValues.PRODUCT_RETURN).Id,applicationId);
        payOffObjTwo.Pricing_Detail__c = pricingDetailsList[1].Id;
        payOffObjTwo.genesis__Cleared__c = ConstantValues.TRUE_VALUE;
        payOffObjTwo.Posted_to_NLS__c = ConstantValues.FALSE_VALUE;
        payOffObjTwo.Pay_Off__c = 'Yes';
        payOffObjTwo.Invoice__c = paymentInvoiceObj.Id;
        Database.insert(new List<genesis__Funding_Transaction__c> {payOffObj, payOffObjTwo}, true);
    }
    /**
    * @description : Test payoff callout posting to nls success scenario for CFA
    * @author Kabir Pramanik | 12-17-2024 
    **/
    @isTest
    private static void testNlsXmlPayOffCalloutSuccessForCFA() {
        //call the method to create test data
        createTestData();
        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.setMock(HttpCalloutMock.class, new NLSXMLImportHttpCalloutMock());
            Test.startTest();
            NLSXMLImportPayOffCalloutBatch obj = new NLSXMLImportPayOffCalloutBatch();
            DataBase.executeBatch(obj);     
            Test.stopTest(); 
            List<genesis__Funding_Transaction__c> paymentFundingTxnList = [SELECT Id,
                                                                                Posted_to_NLS__c,
                                                                                Invoice__c
                                                                        FROM genesis__Funding_Transaction__c 
                                                                        WHERE genesis__application__r.Dealer_Name__r.Name = 'Kisan Loan'
                                                                        AND genesis__application__r.Dealer_Name__r.Phone = '1234567890'
                                                                        AND CreatedDate = Today];
            System.AssertEquals(ConstantValues.TRUE_VALUE, paymentFundingTxnList[0].Posted_to_NLS__c , 'All PAYMENT should get posted');
            List<clcommon__Consolidated_Invoice__c> invoiceObjList = [SELECT Id,
                                                                            clcommon__Status__c
                                                                        FROM clcommon__Consolidated_Invoice__c
                                                                        WHERE Id = :paymentFundingTxnList[0].Invoice__c
                                                                        LIMIT 1];
            System.assertEquals(ConstantValues.STATUS_POSTED, invoiceObjList[0].clcommon__Status__c, 'Invoice status should be updated to Posted');
        }
    }
    /**
    * @description Test payoff callout posting to nls success scenario for GMK
    * @author Kabir Pramanik | 01-10-2025 
    **/
    @isTest
    private static void testNlsXmlPayOffCalloutSuccessForGMK() {
        //call the method to create test data
        createTestData();
        List<Account> dealerAccountObj = [SELECT Id 
                                            FROM Account 
                                            WHERE RecordType.Name = :ConstantValues.DEALER
                                            AND Name = 'Kisan Loan'
                                            AND Phone = '1234567890'
                                            AND CreatedDate = Today
                                            LIMIT 1];
        If(!dealerAccountObj.isEmpty()){
            dealerAccountObj[0].Coop_Type__c = ConstantValues.GROWMARK_COOP_TYPE;
            dealerAccountObj[0].CFA_Partner_Program__c = null;
            Database.update(dealerAccountObj, true);
        }

        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.setMock(HttpCalloutMock.class, new NLSXMLImportHttpCalloutMock());
            Test.startTest();
            NLSXMLImportPayOffCalloutBatch calloutBatchObj = new NLSXMLImportPayOffCalloutBatch();
            DataBase.executeBatch(calloutBatchObj);     
            Test.stopTest(); 
            List<genesis__Funding_Transaction__c> paymentFundingTxnList = [SELECT Id,
                                                                                Posted_to_NLS__c,
                                                                                Invoice__c
                                                                        FROM genesis__Funding_Transaction__c 
                                                                        WHERE genesis__application__r.Dealer_Name__r.Name = 'Kisan Loan'
                                                                        AND genesis__application__r.Dealer_Name__r.Phone = '1234567890'
                                                                        AND genesis__application__r.Dealer_Name__r.Coop_Type__c = :ConstantValues.GROWMARK_COOP_TYPE
                                                                        AND CreatedDate = Today];
            System.AssertEquals(ConstantValues.TRUE_VALUE, paymentFundingTxnList[0].Posted_to_NLS__c , 'All PAYMENT should get posted');
            List<clcommon__Consolidated_Invoice__c> invoiceObjList = [SELECT Id,
                                                                            clcommon__Status__c
                                                                        FROM clcommon__Consolidated_Invoice__c
                                                                        WHERE Id = :paymentFundingTxnList[0].Invoice__c
                                                                        LIMIT 1];
            System.assertEquals(ConstantValues.STATUS_POSTED, invoiceObjList[0].clcommon__Status__c, 'Invoice status should be updated to Posted');
        }
    }
    /**
    * @description Test payoff callout posting to nls success scenario for Landus
    * @author Kabir Pramanik | 01-10-2025 
    **/
    @isTest
    private static void testNlsXmlPayOffCalloutSuccessForLandus() {
        //call the method to create test data
        createTestData();
        List<Account> dealerAccountObj = [SELECT Id 
                                            FROM Account 
                                            WHERE RecordType.Name = :ConstantValues.DEALER
                                            AND Name = 'Kisan Loan'
                                            AND Phone = '1234567890'
                                            AND CreatedDate = Today
                                            LIMIT 1];
        If(!dealerAccountObj.isEmpty()){
            dealerAccountObj[0].Coop_Type__c = ConstantValues.LANDUS_COOP_TYPE;
            Database.update(dealerAccountObj, true);
        }

        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.setMock(HttpCalloutMock.class, new NLSXMLImportHttpCalloutMock());
            Test.startTest();
            NLSXMLImportPayOffCalloutBatch calloutBatchObj = new NLSXMLImportPayOffCalloutBatch();
            DataBase.executeBatch(calloutBatchObj);     
            Test.stopTest(); 
            List<genesis__Funding_Transaction__c> paymentFundingTxnList = [SELECT Id,
                                                                                Posted_to_NLS__c,
                                                                                Invoice__c
                                                                        FROM genesis__Funding_Transaction__c 
                                                                        WHERE genesis__application__r.Dealer_Name__r.Name = 'Kisan Loan'
                                                                        AND genesis__application__r.Dealer_Name__r.Phone = '1234567890'
                                                                        AND genesis__application__r.Dealer_Name__r.Coop_Type__c = :ConstantValues.LANDUS_COOP_TYPE
                                                                        AND CreatedDate = Today];
            System.AssertEquals(ConstantValues.TRUE_VALUE, paymentFundingTxnList[0].Posted_to_NLS__c , 'All PAYMENT should get posted');
            List<clcommon__Consolidated_Invoice__c> invoiceObjList = [SELECT Id,
                                                                            clcommon__Status__c
                                                                        FROM clcommon__Consolidated_Invoice__c
                                                                        WHERE Id = :paymentFundingTxnList[0].Invoice__c
                                                                        LIMIT 1];
            System.assertEquals(ConstantValues.STATUS_POSTED, invoiceObjList[0].clcommon__Status__c, 'Invoice status should be updated to Posted');
        }
    }
    
    /**
    * @description : test callout failure exception for access token generation 
    * @author Kabir Pramanik | 12-17-2024 
    **/
    @isTest
    private static void testAccessTokenCalloutFailureException() {
        //calling this method to create test data
        createTestData();
        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.setMock(HttpCalloutMock.class, new NLSXMLImportAccessTokenFailureMock());
            Test.startTest();
            NLSXMLImportPayOffCalloutBatch obj = new NLSXMLImportPayOffCalloutBatch();
            DataBase.executeBatch(obj);     
            Test.stopTest();
            List<clcommon__Log__c> logList = [SELECT Id
                                                FROM clcommon__Log__c
                                                WHERE Name = :NLSXMLImportAdapter.class.getName()
                                                ORDER BY CreatedDate DESC 
                                                LIMIT 1]; 
            System.assertEquals(ConstantValues.FALSE_VALUE,logList.isEmpty(), 'Exception should be thrown for access token callout failure');
        }
    }
    /**
    * @description : test payoff callout failure for payoff posting to NLS
    * @author Kabir Pramanik | 12-17-2024 
    **/
    @isTest
    private static void testNlsXmlPayOffCalloutFailureException() {
        //call the method to create test data
        createTestData();
        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.setMock(HttpCalloutMock.class, new NLSXMLImportHttpCalloutFailureMock());
            Test.startTest();
            NLSXMLImportPayOffCalloutBatch obj = new NLSXMLImportPayOffCalloutBatch();
            DataBase.executeBatch(obj);     
            Test.stopTest(); 
            List<clcommon__Log__c> logList = [SELECT Id
                                                FROM clcommon__Log__c
                                                WHERE Name = :NLSXMLImportAdapter.class.getName()
                                                ORDER BY CreatedDate DESC 
                                                LIMIT 1]; 
            System.assertEquals(ConstantValues.FALSE_VALUE,logList.isEmpty(), 'Exception should be thrown for PAYMENT post callout failure');
        }
    }
}