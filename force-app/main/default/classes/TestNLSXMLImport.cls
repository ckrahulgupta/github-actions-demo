/**
 * @description       : Test class for NLSXMLImportAdapter
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 01-27-2025
 * @last modified by  : Kabir Pramanik
**/

@isTest
public with sharing class TestNLSXMLImport {
    /**
    * @description creating test data
    * @author Kabir Pramanik | 12-30-2024 
    **/
    @testSetup
    private static void setup() {
        //Creating Integration Framework
        createIntFrameWorkData();

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

        //Create different funding transactions
        createFundingTransactions(applicationObj.Id, pricingDetailsObjList[0].Id);

    }


    
    /**
    * @description Create Funding transactions along with funding batch and payment methods
    * @author Kabir Pramanik | 01-15-2025 
    * @param applicationId 
    * @param pricingId 
    **/
    private static void createFundingTransactions(Id applicationId, Id pricingId){
        //Create Payment Modes
        Map<String, clcommon__Payment_Mode__c> paymentModeMap = LoanServicingTestHelper.createPaymentMode();
        Database.insert(new List<clcommon__Payment_Mode__c> {
            paymentModeMap.get(ConstantValues.ACH),
            paymentModeMap.get(ConstantValues.DRAFT),
            paymentModeMap.get(ConstantValues.MOBILE_DEPOSIT),
            paymentModeMap.get(ConstantValues.PRODUCT_RETURN)
        }, true);

        //Create funding transaction properties 
        Map<String, clcommon__Funding_Transactions_Properties__c> fundingTraxPropMap = LoanServicingTestHelper.createFundingTransactionProperties();
        Database.insert(new List<clcommon__Funding_Transactions_Properties__c> {
            fundingTraxPropMap.get(ConstantValues.ACH),
            fundingTraxPropMap.get(ConstantValues.DRAFT),
            fundingTraxPropMap.get(ConstantValues.MOBILE_DEPOSIT),
            fundingTraxPropMap.get(ConstantValues.PRODUCT_RETURN)
        }, true);

        genesis__Funding_Transaction__c achFundingTransacObj = LoanServicingTestHelper.createFundingTransaction(paymentModeMap.get(ConstantValues.ACH).id, fundingTraxPropMap.get(ConstantValues.ACH).id, applicationId);
        achFundingTransacObj.Pricing_Detail__c = pricingId;
        achFundingTransacObj.genesis__Cleared__c = ConstantValues.TRUE_VALUE;
        achFundingTransacObj.Posted_to_NLS__c = ConstantValues.FALSE_VALUE;
        genesis__Funding_Transaction__c draftFundingTxnObj = LoanServicingTestHelper.createFundingTransaction(paymentModeMap.get(ConstantValues.DRAFT).id, fundingTraxPropMap.get(ConstantValues.DRAFT).Id, applicationId);
        draftFundingTxnObj.Pricing_Detail__c = pricingId;
        draftFundingTxnObj.genesis__Cleared__c = ConstantValues.FALSE_VALUE;
        draftFundingTxnObj.Posted_to_NLS__c = ConstantValues.FALSE_VALUE;
        genesis__Funding_Transaction__c pdtReturnFundingTxnObj = LoanServicingTestHelper.createFundingTransaction(paymentModeMap.get(ConstantValues.PRODUCT_RETURN).id, fundingTraxPropMap.get(ConstantValues.PRODUCT_RETURN).id, applicationId);
        pdtReturnFundingTxnObj.Pricing_Detail__c = pricingId;
        pdtReturnFundingTxnObj.genesis__Cleared__c = ConstantValues.TRUE_VALUE;
        pdtReturnFundingTxnObj.Posted_to_NLS__c = ConstantValues.FALSE_VALUE;
        genesis__Funding_Transaction__c mdtFundingTxnObj = LoanServicingTestHelper.createFundingTransaction(paymentModeMap.get(ConstantValues.MOBILE_DEPOSIT).id, fundingTraxPropMap.get(ConstantValues.MOBILE_DEPOSIT).id, applicationId);
        mdtFundingTxnObj.Pricing_Detail__c = pricingId;
        mdtFundingTxnObj.genesis__Cleared__c = ConstantValues.TRUE_VALUE;
        mdtFundingTxnObj.Posted_to_NLS__c = ConstantValues.FALSE_VALUE;
        Database.insert(new List<genesis__Funding_Transaction__c> {achFundingTransacObj, draftFundingTxnObj, pdtReturnFundingTxnObj, mdtFundingTxnObj}, true);
    }

    /**
    * @description create integration framework
    * @author Kabir Pramanik | 01-03-2025 
    **/
    private static void createIntFrameWorkData(){
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
     * @description       : Setting up the Mock Response of FAILED status for access token generation
     * @author            : Suraj kumar
     * @last modified on  : 01-27-2025
     * @last modified by  : Kabir Pramanik
    **/
    public class NLSGetNullAccessTokenMock implements HttpCalloutMock {
        // Implement this interface method
        /**
        * @description : returns the Mock Response of FAILED status
        * @author Suraj Kumar | 03-14-2024 
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
     * @description       : Setting up the FAILED status for posting transactions to NLS
     * @author            : Kabir Pramanik
     * @last modified on  : 01-27-2025
     * @last modified by  : Kabir Pramanik
    **/
    public class NLSXMLImportHttpCalloutFailureMock implements HttpCalloutMock {
        /**
        * @description : returns the Mock Response of Failure status
        * @author Kabir Pramanik | 01-02-2025
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
                response.setStatusCode(200);
                response.setStatus('SUCCESS');
                String token = '{"access_token":"eyJhbGciOiJSUzI1NiIsI","expires_in":300,"token_type":"Bearer"}';
                response.setBody(token);
            }
            else{
                response.setStatusCode(400);
                response.setStatus('FAILED');
                response.setBody('{"status":{"code":400,"message":""}}');
            }
            return response;
        }
    }
    /**
    * @description       : Setting up the Mock Response of SUCCESS status 
    * @author            : Suraj kumar
    * @last modified on  : 01-27-2025
    * @last modified by  : Kabir Pramanik
    **/
    public class NLSXMLImportHttpCalloutMock implements HttpCalloutMock {
        // Implement this interface method
        /**
        * @description : returns the Mock Response of SUCCESS status
        * @author Suraj Kumar | 03-14-2024 
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
    * @description test acces token failure
    * @author Kabir Pramanik | 01-02-2025 
    **/
    @isTest 
    private static void testAccessTokenFailure(){
        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.setMock(HttpCalloutMock.class, new NLSGetNullAccessTokenMock());
            Test.startTest();
            NLSXMLImportACHCalloutBatch obj = new NLSXMLImportACHCalloutBatch();
            DataBase.executeBatch(obj);
            Test.stopTest();
            List<clcommon__log__c> logList = [SELECT Id FROM clcommon__log__c WHERE Name = :NLSXMLImportAdapter.class.getName()];
            System.assertEquals(ConstantValues.FALSE_VALUE, logList.isEMpty() , 'Assertion Failed');
            List<genesis__Funding_Transaction__c> fundingTransactions = [SELECT Id,
                                                                                Posted_to_NLS__c
                                                                        FROM genesis__Funding_Transaction__c
                                                                        WHERE genesis__Payment_Mode__r.Name =: ConstantValues.ACH];
            System.assertEquals(ConstantValues.FALSE_VALUE, fundingTransactions[0].Posted_to_NLS__c, 'Assertion Failed');
        }
    }
    /**
     * @description test adapter for ACH post success
    * @author Kabir Pramanik | 12-30-2024 
    **/
    @isTest 
    private static void testAdapterForACHSuccess(){
        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.setMock(HttpCalloutMock.class, new NLSXMLImportHttpCalloutMock());
            Test.startTest();
            NLSXMLImportACHCalloutBatch obj = new NLSXMLImportACHCalloutBatch();
            DataBase.executeBatch(obj);
            Test.stopTest();
            List<genesis__Funding_Transaction__c> fundingTransactions = [SELECT Id,
                                                                                Posted_to_NLS__c
                                                                        FROM genesis__Funding_Transaction__c
                                                                        WHERE genesis__Payment_Mode__r.Name =: ConstantValues.ACH];
            System.assertEquals(ConstantValues.TRUE_VALUE, fundingTransactions[0].Posted_to_NLS__c, 'Assertion Failed');
        }
    }
    /**
    * @description test adapter for ACH post failure
    * @author Kabir Pramanik | 12-30-2024 
    **/
    @isTest 
    private static void testAdapterForACHFailure(){
        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.setMock(HttpCalloutMock.class, new NLSXMLImportHttpCalloutFailureMock());
            Test.startTest();
            NLSXMLImportACHCalloutBatch obj = new NLSXMLImportACHCalloutBatch();
            DataBase.executeBatch(obj);
            Test.stopTest();
            List<genesis__Funding_Transaction__c> fundingTransactions = [SELECT Id,
                                                                                Posted_to_NLS__c
                                                                        FROM genesis__Funding_Transaction__c
                                                                        WHERE genesis__Payment_Mode__r.Name =: ConstantValues.ACH];
            System.assertEquals(ConstantValues.FALSE_VALUE, fundingTransactions[0].Posted_to_NLS__c, 'Assertion Failed');
            List<clcommon__log__c> logList = [SELECT Id FROM clcommon__log__c WHERE Name = :NLSXMLImportAdapter.class.getName()];
            System.assertEquals(ConstantValues.FALSE_VALUE, logList.isEmpty() , 'Assertion Failed');
        }
    }
    /**
    * @description test adapter for Product Return post success
    * @author Kabir Pramanik | 12-30-2024 
    **/
    @isTest 
    private static void testAdapterForProductReturnSuccess(){
        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.setMock(HttpCalloutMock.class, new NLSXMLImportHttpCalloutMock());
            Test.startTest();
            NLSXMLImportProductReturnCalloutBatch obj = new NLSXMLImportProductReturnCalloutBatch();
            Database.executeBatch(obj);
            Test.stopTest();
            List<genesis__Funding_Transaction__c> fundingTransactions = [SELECT Id,
                                                                                Posted_to_NLS__c
                                                                        FROM genesis__Funding_Transaction__c
                                                                        WHERE genesis__Payment_Mode__r.Name =: ConstantValues.PRODUCT_RETURN];
            System.assertEquals(ConstantValues.TRUE_VALUE, fundingTransactions[0].Posted_to_NLS__c, 'Assertion Failed');
        }
    }
    /**
    * @description test adapter for Product Return post failure
    * @author Kabir Pramanik | 12-30-2024 
    **/
    @isTest 
    private static void testAdapterForProductReturnFailure(){
        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.setMock(HttpCalloutMock.class, new NLSXMLImportHttpCalloutFailureMock());
            Test.startTest();
            NLSXMLImportProductReturnCalloutBatch obj = new NLSXMLImportProductReturnCalloutBatch();
            Database.executeBatch(obj);
            Test.stopTest();
            List<genesis__Funding_Transaction__c> fundingTransactions = [SELECT Id,
                                                                                Posted_to_NLS__c
                                                                        FROM genesis__Funding_Transaction__c
                                                                        WHERE genesis__Payment_Mode__r.Name =: ConstantValues.PRODUCT_RETURN];
            System.assertEquals(ConstantValues.FALSE_VALUE, fundingTransactions[0].Posted_to_NLS__c, 'Assertion Failed');
            List<clcommon__log__c> logList = [SELECT Id FROM clcommon__log__c WHERE Name = :NLSXMLImportAdapter.class.getName()];
            System.assertEquals(ConstantValues.FALSE_VALUE, logList.isEmpty() , 'Assertion Failed');
        }
    }
    /**
    * @description test adapter for mobile deposit success
    * @author Kabir Pramanik | 12-30-2024 
    **/
    @isTest 
    private static void testAdapterForMobileDepositSuccess(){
        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.setMock(HttpCalloutMock.class, new NLSXMLImportHttpCalloutMock());
            Test.startTest();
            NLSXMLImportMobileDepositCalloutBatch obj = new NLSXMLImportMobileDepositCalloutBatch();
            Database.executeBatch(obj);
            Test.stopTest();
            List<genesis__Funding_Transaction__c> fundingTransactions = [SELECT Id,
                                                                                Posted_to_NLS__c
                                                                        FROM genesis__Funding_Transaction__c
                                                                        WHERE genesis__Payment_Mode__r.Name =: ConstantValues.MOBILE_DEPOSIT];
            System.assertEquals(ConstantValues.TRUE_VALUE, fundingTransactions[0].Posted_to_NLS__c, 'Assertion Failed');
        }
    }
    /**
    * @description test adapter for mobile deposit failure
    * @author Kabir Pramanik | 12-30-2024 
    **/
    @isTest 
    private static void testAdapterForMobileDepositFailure(){
        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.setMock(HttpCalloutMock.class, new NLSXMLImportHttpCalloutFailureMock());
            Test.startTest();
            NLSXMLImportMobileDepositCalloutBatch obj = new NLSXMLImportMobileDepositCalloutBatch();
            Database.executeBatch(obj);
            Test.stopTest();
            List<genesis__Funding_Transaction__c> fundingTransactions = [SELECT Id,
                                                                                Posted_to_NLS__c
                                                                        FROM genesis__Funding_Transaction__c
                                                                        WHERE genesis__Payment_Mode__r.Name =: ConstantValues.MOBILE_DEPOSIT];
            System.assertEquals(ConstantValues.FALSE_VALUE, fundingTransactions[0].Posted_to_NLS__c, 'Assertion Failed');
            List<clcommon__log__c> logList = [SELECT Id FROM clcommon__log__c WHERE Name = :NLSXMLImportAdapter.class.getName()];
            System.assertEquals(ConstantValues.FALSE_VALUE, logList.isEmpty() , 'Assertion Failed');
        }
    }

    /**
     * @description test adapter for draft post success
    * @author Kabir Pramanik | 12-30-2024 
    **/
    @isTest 
    private static void testAdapterForDraftSuccess(){
        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.setMock(HttpCalloutMock.class, new NLSXMLImportHttpCalloutMock());
            Test.startTest();
            NLSXMLImportDraftCalloutBatch obj = new NLSXMLImportDraftCalloutBatch();
            Database.executeBatch(obj);
            Test.stopTest();
            List<genesis__Funding_Transaction__c> fundingTransactions = [SELECT Id,
                                                                                Posted_to_NLS__c
                                                                        FROM genesis__Funding_Transaction__c
                                                                        WHERE genesis__Payment_Mode__r.Name =: ConstantValues.DRAFT];
            System.assertEquals(ConstantValues.TRUE_VALUE, fundingTransactions[0].Posted_to_NLS__c, 'Assertion Failed');
        }
    }
    /**
    * @description test adapter for draft post failure
    * @author Kabir Pramanik | 12-30-2024
    **/
    @isTest 
    private static void testAdapterForDRAFTFailure(){
        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.setMock(HttpCalloutMock.class, new NLSXMLImportHttpCalloutFailureMock());
            Test.startTest();
            NLSXMLImportDraftCalloutBatch obj = new NLSXMLImportDraftCalloutBatch();
            Database.executeBatch(obj);
            Test.stopTest();
            List<genesis__Funding_Transaction__c> fundingTransactions = [SELECT Id,
                                                                                Posted_to_NLS__c
                                                                        FROM genesis__Funding_Transaction__c
                                                                        WHERE genesis__Payment_Mode__r.Name =: ConstantValues.DRAFT];
            System.assertEquals(ConstantValues.FALSE_VALUE, fundingTransactions[0].Posted_to_NLS__c, 'Assertion Failed');
        }
    }
}