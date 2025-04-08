/**
 * @description       : Test class for NLSXMLImportDraftCalloutBatch
 * @author            : Simran
 * @group             : 
 * @last modified on  : 01-27-2025
 * @last modified by  : Kabir Pramanik
**/
@isTest
public with sharing class NLSXMLImportDraftCalloutBatchTest {
    /**
    * @description       : Setting up the Mock Response of SUCCESS status for both access token and draft post callout
    * @author            : Kabir Pramanik
    * @last modified on  : 01-27-2025
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
    * @last modified on  : 01-27-2025
    * @last modified by  : Kabir Pramanik
    **/
    public class NLSXMLImportAccessTokenFailureMock implements HttpCalloutMock {
        // Implement this interface method
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
    * @description       : Setting up the Mock Response for Unauthorized Access status
    * @author            : Kabir Pramanik
    * @last modified on  : 01-27-2025
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
    * @description       : Setting up the Mock Response of Bad Request
    * @author            : Kabir Pramanik
    * @last modified on  : 01-27-2025
    * @last modified by  : Kabir Pramanik
    **/
    public class NLSXMLImportHttpCalloutFailureMock implements HttpCalloutMock {
        
        /**
        * @description : method to get mock response of NLS
        * @author Kabir Pramanik | 01-07-2025
        * @param request 
        * @return HTTPResponse 
        **/
        public HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            if(request.getEndpoint().contains('token')){
                String token = '{"access_token":"eyJhbGciOiJSUzI1NiIsI","expires_in":300,"token_type":"Bearer"}';
                response.setBody(token);
                response.setStatusCode(200);
                response.setStatus('SUCCESS');
            }
            else{
                response.setStatusCode(400);
                response.setStatus('FAILED');
                response.setBody('{"status":{"code":400,"message":"Validation Error","executionTime":193},'
                                    +'"errors":[{"path":"Body","code":100,"message":"","data":null}],');
            }
            return response;
        }
    }
    /**
    * @description Test setup
    * @author Kabir Pramanik | 12-16-2024 
    **/
    @TestSetup
    private static void setup(){
        //Creating Integration Framework
        createIntegrationFramework();

        //Creating business infos
        genesis__Business_Information__c dealerBusinessInfoObj = LoanServicingTestHelper.createBusinessInfoForDealer();
        genesis__Business_Information__c borrowerBusinessInfoObj = LoanServicingTestHelper.createBusinessInfoForBorrower();
        Database.insert(new List<genesis__Business_Information__c> {dealerBusinessInfoObj , borrowerBusinessInfoObj}, true);

        // Creating Legal Entity for Borrower
        clcommon__Legal_Entity__c entityObj = LoanServicingTestHelper.createLegalEntity(ConstantValues.SOLE_PROP_ENTITY);
        Database.insert(entityObj, true);

        // Creating Accounts
        Account dealerAccountObj = LoanServicingTestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        Database.insert(dealerAccountObj, true);

        Account clAccountObj = LoanServicingTestHelper.createCLAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
        Account borrowerAccountObj = LoanServicingTestHelper.createSolePropAccount(entityObj, borrowerBusinessInfoObj.Id);
        borrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Grower').getRecordTypeId();
        Account saAccountObj = LoanServicingTestHelper.createSalesAgentAccount(dealerBusinessInfoObj.Id,dealerAccountObj.Id);
        Database.insert(new List<Account> {clAccountObj,borrowerAccountObj, saAccountObj}, true);

        // Creating Contacts
        Contact clContactObj = LoanServicingTestHelper.createCLContact(clAccountObj.Id);
        Contact borrowerContactObj = LoanServicingTestHelper.createBorrowerContact(borrowerAccountObj.Id);
        Contact saContactObj=LoanServicingTestHelper.createSalesAgentContact(saAccountObj.Id);
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
        Database.insert(paymentModeMap.get(ConstantValues.DRAFT), true);

        //Creating funding txns for Draft
        createFundingTransactions(new Map<String, Object> {
            'applicationId' => applicationObj.Id,
            'paymentModeId' => paymentModeMap.get(ConstantValues.DRAFT).Id,
            'pricingDetailsList' => pricingDetailsObjList
        });
    }

    /**
    * @description - Create integration framework
    * @author Sk Minsar | 12-18-2024 
    **/
    private static void createIntegrationFramework(){
        //Inserting Integration Family
        intframework__Integration_Family__c family = IntegrationTestInitHelper.getFamilyInst('NLS Integration');
        Database.Insert(family, true);

        //Inserting Integration API Type
        intframework__Integration_API_Type__c xmlImportApiType = IntegrationTestInitHelper.getIntegrationAPITypeInst(
            family.Id, ConstantValues.INTEGRATION_API_TYPE_XML_IMPORT);
        Database.Insert(xmlImportApiType, true);

        //Inserting Integration Provider
        intframework__Integration_Provider__c xmlImportProvider = IntegrationTestInitHelper.getIntegrationProviderInst(
            family.Id, 'XML Import');
        Database.Insert(xmlImportProvider, true);

        //Inserting Integration Configuration
        intframework__Integration_Configuration__c xmlImportConfig = IntegrationTestInitHelper.getIntegrationConfigurationInst(
            xmlImportProvider.Id, 'NLS Search Loans Integration Configuration','NLS');
        Database.Insert(xmlImportConfig, true);

        //Inserting Integration API Configuration
        Map<String, Object> apiConfigMap = new Map<String, Object>{
            'familyId' => family.Id,
            'apiTypeId' => xmlImportApiType.Id,
            'providerId' => xmlImportProvider.Id,
            'configId' => xmlImportConfig.Id,
            'longRunningOperation' => false,
            'adapterName' => 'NLSXMLImportAdapter',
            'method' => 'POST',
            'apiNamedCred' => 'NLS',
            'endpoint' => 'nls/xml-import',
            'requestMappingJSON' =>'{"thirdPartySystem":{"name":"test","filters":[{"objectAPI":"genesis__Funding_Transaction__c","objectAlias":"FundingTransaction","fields":[{"externalField":"Id","fieldAPI":"Id"},{"externalField":"Amount","fieldAPI":"genesis__Amount__c"},{"externalField":"LoanNumber","fieldAPI":"Pricing_Detail__r.Loan_Number__c"},{"externalField":"Reference","fieldAPI":"genesis__Reference__c"},{"externalField":"EffectiveDate","fieldAPI":"genesis__Funding_Date__c"},{"externalField":"GrowerName","fieldAPI":"Grower_Name__c"},{"externalField":"DealerName","fieldAPI":"genesis__Application__r.Dealer_Name__r.Name"},{"externalField":"CoopType","fieldAPI":"genesis__Application__r.Coop_Type__c"},{"externalField":"ParentLoanNumber","fieldAPI":"genesis__Application__r.genesis__Loan_Number__c"},{"externalField":"Payee","fieldAPI":"Payee__c"},{"externalField":"DraftNumber","fieldAPI":"Draft_Number__c"},{"externalField":"Total","fieldAPI":"Total__c"},{"externalField":"ApplicationId","fieldAPI":"genesis__Application__r.Id"},{"externalField":"IsPayOff","fieldAPI":"Pay_Off__c"},{"externalField":"IsClearingSuspense","fieldAPI":"Is_Clearing_Suspense__c"},{"externalField":"PrincipalPaid","fieldAPI":"Principal_Paid__c"},{"externalField":"InterestPaid","fieldAPI":"Interest_Paid__c"},{"externalField":"FeesPaid","fieldAPI":"Fees_Paid__c"},{"externalField":"InvoiceId","fieldAPI":"Invoice__c"}],"whereClause":"Id IN :approvedList"}],"dynamicDataParameters":[{"externalField":"paymentType"}]}}',
            'contentType' => 'application/xml',
            'priority' => 1
        };

        intframework__Integration_API_Configuration__c xmlImportApiConfig = IntegrationTestInitHelper.getIntegrationAPIConfigurationInst(apiConfigMap);
        Database.Insert(xmlImportApiConfig, true);
    }
    
    /**
    * @description creating Draft funding transactions and associated records
    * @author Kabir Pramanik | 01-13-2025 
    * @param paramMap 
    **/
    private static void createFundingTransactions(Map<String, Object> paramMap){
        Id applicationId = (Id) paramMap.get('applicationId');
        Id paymentModeId = (Id) paramMap.get('paymentModeId');
        List<genesis__Application_Pricing_Detail__c> pricingDetailsList = 
                (List<genesis__Application_Pricing_Detail__c>) paramMap.get('pricingDetailsList');
        //Creating Funding Transactions Properties batch
        Map<String, clcommon__Funding_Transactions_Properties__c> fundingTraxPropMap = LoanServicingTestHelper.createFundingTransactionProperties();
        Database.insert(fundingTraxPropMap.get(ConstantValues.DRAFT), true);

        //Create invoices 
        clcommon__Consolidated_Invoice__c draftInvoiceObj = LoanServicingTestHelper.createInvoice(applicationId, paymentModeId);
        draftInvoiceObj.clcommon__Status__c = ConstantValues.STATUS_INITIATED;
        Database.insert(draftInvoiceObj, true);

        genesis__Funding_Transaction__c draftTxnObj = LoanServicingTestHelper.createFundingTransaction(paymentModeId, fundingTraxPropMap.get(ConstantValues.DRAFT).Id,applicationId);
        draftTxnObj.Pricing_Detail__c = pricingDetailsList[0].Id;
        draftTxnObj.genesis__Amount__c = 200;
        draftTxnObj.genesis__Cleared__c = ConstantValues.TRUE_VALUE;
        draftTxnObj.Posted_to_NLS__c = ConstantValues.FALSE_VALUE;
        draftTxnObj.Is_Clearing_Suspense__c = true;
        draftTxnObj.Batch__c = fundingTraxPropMap.get(ConstantValues.DRAFT).Id;
        draftTxnObj.Invoice__c = draftInvoiceObj.Id;
        genesis__Funding_Transaction__c draftTxnObjTwo = LoanServicingTestHelper.createFundingTransaction(paymentModeId, fundingTraxPropMap.get(ConstantValues.DRAFT).Id,applicationId);
        draftTxnObjTwo.Pricing_Detail__c = pricingDetailsList[1].Id;
        draftTxnObjTwo.genesis__Amount__c = 200;
        draftTxnObjTwo.genesis__Cleared__c = ConstantValues.TRUE_VALUE;
        draftTxnObjTwo.Posted_to_NLS__c = ConstantValues.FALSE_VALUE;
        draftTxnObjTwo.Batch__c = fundingTraxPropMap.get(ConstantValues.DRAFT).Id;
        draftTxnObjTwo.Invoice__c = draftInvoiceObj.Id;
        Database.insert(new List<genesis__Funding_Transaction__c> {draftTxnObj, draftTxnObjTwo}, true);
    }
    /**
    * @description test draft post success for CFA
    * @author Kabir Pramanik | 12-16-2024 
    **/
    @isTest
    private static void testDraftCalloutBatchSuccessForCFA() {
        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.setMock(HttpCalloutMock.class, new NLSXMLImportHttpCalloutMock());
            Test.startTest();
            NLSXMLImportDraftCalloutBatch obj = new NLSXMLImportDraftCalloutBatch();
            Database.executeBatch(obj);    
            Test.stopTest(); 
            List<genesis__Funding_Transaction__c> fundingTraxObjList = [SELECT Id, 
                                                                                Posted_to_NLS__c
                                                                                FROM genesis__Funding_Transaction__c
                                                                                WHERE Posted_to_NLS__c = true];
            System.assertEquals(2, fundingTraxObjList.size(), 'All DRAFTs status should be changed to posted');
            List<clcommon__Consolidated_Invoice__c> invoiceObjList = [SELECT Id,
                                                                            clcommon__Status__c
                                                                        FROM clcommon__Consolidated_Invoice__c
                                                                        LIMIT 1];
            System.assertEquals(ConstantValues.STATUS_POSTED, invoiceObjList[0].clcommon__Status__c, 'Invoice status should be updated to Posted');
        }
    }
    /**
    * @description test draft post success for GMK
    * @author Kabir Pramanik | 12-16-2024 
    **/
    @isTest
    private static void testDraftCalloutSuccessForGMK() {
        List<Account> dealerAccountObj = [SELECT Id FROM Account WHERE RecordType.Name = :ConstantValues.DEALER LIMIT 1];
        dealerAccountObj[0].Coop_Type__c = ConstantValues.GROWMARK_COOP_TYPE;
        dealerAccountObj[0].CFA_Partner_Program__c = null;
        Database.update(dealerAccountObj, ConstantValues.TRUE_VALUE);
        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.setMock(HttpCalloutMock.class, new NLSXMLImportHttpCalloutMock());
            Test.startTest();
            NLSXMLImportDraftCalloutBatch calloutBatchObj = new NLSXMLImportDraftCalloutBatch();
            Database.executeBatch(calloutBatchObj);    
            Test.stopTest();
            List<genesis__Funding_Transaction__c> fundingTraxObjList = [SELECT Id, 
                                                                                Posted_to_NLS__c
                                                                            FROM genesis__Funding_Transaction__c
                                                                            WHERE Posted_to_NLS__c = true];
            System.assertEquals(2, fundingTraxObjList.size(), 'All DRAFTs status should be changed to posted');
            List<clcommon__Consolidated_Invoice__c> invoiceObjList = [SELECT Id,
                                                                            clcommon__Status__c
                                                                        FROM clcommon__Consolidated_Invoice__c
                                                                        LIMIT 1];
            System.assertEquals(ConstantValues.STATUS_POSTED, invoiceObjList[0].clcommon__Status__c, 'Invoice status should be updated to Posted');
        }
    }
    /**
    * @description test draft post success for Landus
    * @author Kabir Pramanik | 12-16-2024 
    **/
    @isTest
    private static void testDraftCalloutSuccessForLandus() {
        List<Account> dealerAccountObj = [SELECT Id FROM Account WHERE RecordType.Name = :ConstantValues.DEALER LIMIT 1];
        dealerAccountObj[0].Coop_Type__c = ConstantValues.LANDUS_COOP_TYPE;
        Database.update(dealerAccountObj, ConstantValues.TRUE_VALUE);
        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.setMock(HttpCalloutMock.class, new NLSXMLImportHttpCalloutMock());
            Test.startTest();
            NLSXMLImportDraftCalloutBatch calloutBatchObj = new NLSXMLImportDraftCalloutBatch();
            Database.executeBatch(calloutBatchObj);    
            Test.stopTest();
            List<genesis__Funding_Transaction__c> fundingTraxObjList = [SELECT Id, 
                                                                                Posted_to_NLS__c
                                                                            FROM genesis__Funding_Transaction__c
                                                                            WHERE Posted_to_NLS__c = true];
            System.assertEquals(2, fundingTraxObjList.size(), 'All DRAFTs status should be changed to posted');
            List<clcommon__Consolidated_Invoice__c> invoiceObjList = [SELECT Id,
                                                                            clcommon__Status__c
                                                                        FROM clcommon__Consolidated_Invoice__c
                                                                        LIMIT 1];
            System.assertEquals(ConstantValues.STATUS_POSTED, invoiceObjList[0].clcommon__Status__c, 'Invoice status should be updated to Posted');
        }
    }
    
    /**
    * @description test draft callout failure exception
    * @author Kabir Pramanik | 01-13-2025 
    **/
    @isTest
    private static void testDraftCalloutFailureException() {
        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.setMock(HttpCalloutMock.class, new NLSXMLImportHttpCalloutFailureMock());
            Test.startTest();
            NLSXMLImportDraftCalloutBatch obj = new NLSXMLImportDraftCalloutBatch();
            Database.executeBatch(obj);    
            Test.stopTest();
            List<clcommon__Log__c> logList = [SELECT Id
                                                FROM clcommon__Log__c 
                                                WHERE Name = :NLSXMLImportAdapter.class.getName()]; 
            System.assertEquals(ConstantValues.FALSE_VALUE,logList.isEmpty(), 'Exception should be thrown for nls Draft callout failure');
        }
    }
    /**
    * @description test access token callout failure exception 
    * @author Kabir Pramanik | 01-07-2025 
    **/
    @isTest
    private static void testAccessTokenCalloutFailureException(){
        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.setMock(HttpCalloutMock.class, new NLSXMLImportAccessTokenFailureMock());
            Test.startTest();
            NLSXMLImportDraftCalloutBatch obj = new NLSXMLImportDraftCalloutBatch();
            Database.executeBatch(obj);
            Test.stopTest(); 
            List<clcommon__Log__c> logList = [SELECT Id
                                                    FROM clcommon__Log__c 
                                                    WHERE Name = :NLSXMLImportAdapter.class.getName()]; 
            System.assertEquals(ConstantValues.FALSE_VALUE,logList.isEmpty(), 'Exception should be thrown for access token callout failure');
        }
    }
    /**
    * @description test callout failure for draft amount more than the loan amount
    * @author Kabir Pramanik | 01-07-2025 
    **/
    @isTest
    private static void testDraftAmoutExceedsLoanAmountException() {
        List<genesis__Funding_Transaction__c> fundingTraxObjList = [SELECT Id FROM genesis__Funding_Transaction__c LIMIT 1];
        fundingTraxObjList[0].genesis__Amount__c = 1000000;
        Database.update(fundingTraxObjList[0], true);
        System.runAS(LoanServicingTestHelper.getAdminUser()){
            Test.setMock(HttpCalloutMock.class, new NLSXMLImportHttpCalloutFailureMock());
            Test.startTest();
            NLSXMLImportDraftCalloutBatch obj = new NLSXMLImportDraftCalloutBatch();
            Database.executeBatch(obj);
            Test.stopTest();
            List<clcommon__Log__c> logList = [SELECT Id
                                                FROM clcommon__Log__c 
                                                WHERE Name = :NLSXMLImportAdapter.class.getName()];
            System.assertEquals(ConstantValues.FALSE_VALUE, logList.isEmpty() , 'Exception should be thrown for draft amount being more than loan amount');
        }     
    }
    /**
    * @description test exception scenario for absense of integration api configuration
    * @author Kabir Pramanik | 01-07-2025 
    **/
    @isTest
    private static void testIntegratioFrameworkMissingException(){
        List<intframework__Integration_API_Configuration__c> apiConfigurationObjList = [SELECT Id FROM intframework__Integration_API_Configuration__c WHERE intframework__API_Endpoint__c = 'nls/xml-import' LIMIT 1];
        if(!apiConfigurationObjList.isEmpty()){
            Database.delete(apiConfigurationObjList, true);
        }
        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.setMock(HttpCalloutMock.class, new NLSXMLImportHttpCalloutFailureMock());
            Test.startTest();
            NLSXMLImportDraftCalloutBatch obj = new NLSXMLImportDraftCalloutBatch();
            Database.executeBatch(obj);
            Test.stopTest(); 
            List<clcommon__Log__c> logList = [SELECT Id
                                                    FROM clcommon__Log__c 
                                                    WHERE Name = :NLSXMLImportDraftCalloutBatch.class.getName()]; 
            System.assertEquals(ConstantValues.FALSE_VALUE,logList.isEmpty(), 'Exception should be thrown for absense of integration api configuration');
        }
    }
}