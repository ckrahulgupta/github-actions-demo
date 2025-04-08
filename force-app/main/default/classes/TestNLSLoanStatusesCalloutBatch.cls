/**
 * @description       : Test Class to cover NLSLoanStatusesCalloutBatch
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 01-27-2025
 * @last modified by  : Kabir Pramanik
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   16-01-2023   Subham Nandi   Initial Version
**/
@isTest
public with sharing class TestNLSLoanStatusesCalloutBatch {
    /**
    * @description creating test data
    * @author Kabir Pramanik | 01-02-2025 
    **/
    @TestSetup
    private static void makeData(){
        //Creating the integration framework
        createIntFrameWorkData();

        // Creating Business Information
        genesis__Business_Information__c dealerBusinessInfoObj = LoanServicingTestHelper.createBusinessInfoForDealer();
        genesis__Business_Information__c borrowerBusinessInfoObj =LoanServicingTestHelper.createBusinessInfoForBorrower();
        Database.insert(new List<genesis__Business_Information__c> {dealerBusinessInfoObj,borrowerBusinessInfoObj}, true);

        // Creating Legal Entity for Borrower
        clcommon__Legal_Entity__c entityObj = LoanServicingTestHelper.createLegalEntity(ConstantValues.SOLE_PROP_ENTITY);
        Database.insert(entityObj, true);

        // Creating Accounts
        Account dealerAccountObj = LoanServicingTestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        Database.insert(dealerAccountObj, true);
        Account clAccountObj = LoanServicingTestHelper.createCLAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
        Account borrowerAccountObj = LoanServicingTestHelper.createSolePropAccount(entityObj, borrowerBusinessInfoObj.Id);
        borrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Grower').getRecordTypeId();
        Account coBorrowerAccountObj = LoanServicingTestHelper.createSolePropAccount(entityObj, borrowerBusinessInfoObj.Id);
        coBorrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CoApplicant').getRecordTypeId();
        Database.insert(new List<Account> {clAccountObj,borrowerAccountObj, coBorrowerAccountObj}, true);

        // Creating Contacts
        Contact clContactObj = LoanServicingTestHelper.createCLContact(clAccountObj.Id);
        Contact borrowerContactObj = LoanServicingTestHelper.createBorrowerContact(borrowerAccountObj.Id);
        Contact coBorrowerContactObj = LoanServicingTestHelper.createCoBorrowerContact(coBorrowerAccountObj.Id);
        Database.insert(new List<Contact> {clContactObj,borrowerContactObj, coBorrowerContactObj},true);

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
        dealer_applicant_relationship__c dealerPrincipalRelObj = LoanServicingTestHelper.createDealerApplicantRelationship(coBorrowerContactObj, dealerAccountObj.Id);
        Database.insert(new List<dealer_applicant_relationship__c> {dealerApplRelationshipObj,dealerPrincipalRelObj}, true);

        genesis__Rate_Card_Setup_Header__c rateCardHeaderObj = LoanServicingTestHelper.createRateCardHeader(dealerAccountObj);
        rateCardHeaderObj.genesis__Start_Date__c = System.today();
        rateCardHeaderObj.genesis__End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        Database.insert(rateCardHeaderObj,true);

        genesis__Rate_Card_Setup_Detail__c specialTermAA =  LoanServicingTestHelper.createRateCardSetupDetail(rateCardHeaderObj);
        specialTermAA.Special_Term_Reference__c = 'Special Term Sub-Tranche (A)';
        specialTermAA.Special_Term_Order__c = ConstantValues.ONE_VALUE;
        specialTermAA.Start_Date__c = System.Today();
        specialTermAA.End_Date__c = System.today().addMonths(3).toStartOfMonth().addDays(-1);

        genesis__Rate_Card_Setup_Detail__c specialTermBA =  LoanServicingTestHelper.createRateCardSetupDetail(rateCardHeaderObj);
        specialTermBA.Special_Term_Reference__c = 'Special Term Sub-Tranche (B)';
        specialTermBA.Special_Term_Order__c = ConstantValues.TWO_VALUE;
        specialTermBA.Start_Date__c = System.Today();
        specialTermBA.End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        Database.insert(new List<genesis__Rate_Card_Setup_Detail__c> {specialTermAA, specialTermBA},true);

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
        applicationObj.Non_Accrual__c = ConstantValues.FALSE_VALUE;
        Database.insert(applicationObj, true);

        // Creating Reciprocal Role 
        clcommon__Reciprocal_Role__c roleObj = LoanServicingTestHelper.createReciprocalRole(ConstantValues.CERTIFIED_LENDER);
        Database.insert(roleObj, true);

        // Creating Relationship between Dealer and Certified Lender
        clcommon__Relationship__c clDealerRelationshipObj = LoanServicingTestHelper.createCLDealerRelationship(roleObj,dealerAccountObj.Id,clAccountObj.Id);
        Database.insert(clDealerRelationshipObj, true);

        // Creating party types
        clcommon__Party_Type__c clPartyTypeObj = LoanServicingTestHelper.createPartyType(ConstantValues.CL_PARTY_NAME);
        clcommon__Party_Type__c borrowerPartyTypeObj = LoanServicingTestHelper.createPartyType(ConstantValues.BORROWER_PARTY);
        clcommon__Party_Type__c principalPartyTypeObj = LoanServicingTestHelper.createPartyType(ConstantValues.PRINCIPAL_PARTY);
        Database.insert(new List<clcommon__Party_Type__c> {clPartyTypeObj, borrowerPartyTypeObj, principalPartyTypeObj}, true);

        //Create Parties
        createParties(new Map<String, Object> {
            'paramClMap' => new Map<String,Id>{
                            'accountId' => clAccountObj.Id,
                            'contactId' => clContactObj.Id,
                            'partyTypeId' => clPartyTypeObj.Id,
                            'applicationId' => applicationObj.Id
                        },
            'paramBorrowerMap' => new Map<String,Id>{
                            'accountId' => borrowerAccountObj.Id,
                            'contactId' => borrowerContactObj.Id,
                            'partyTypeId' => borrowerPartyTypeObj.Id,
                            'applicationId' => applicationObj.Id,
                            'dealerApplicantRelationshipId' => dealerApplRelationshipObj.Id
                        },
            'paramPrincipalMap' => new Map<String,Id>{
                        'accountId' => coBorrowerAccountObj.Id,
                        'contactId' => coBorrowerContactObj.Id,
                        'partyTypeId' => principalPartyTypeObj.Id,
                        'applicationId' => applicationObj.Id,
                        'dealerApplicantRelationshipId' => dealerPrincipalRelObj.Id
                    }
        });

        List<genesis__Application_Pricing_Detail__c> pricingDetailsObjList = LoanServicingTestHelper.createSeedDataForPricingDetail(applicationObj);
        Database.insert(pricingDetailsObjList,true);

        //Create Payment Modes
        Map<String, clcommon__Payment_Mode__c> paymentModeMap = LoanServicingTestHelper.createPaymentMode();
        Database.insert(paymentModeMap.get(ConstantValues.ACH), true);

        genesis__Funding_Transaction__c achTxnObj = LoanServicingTestHelper.createFundingTransaction(paymentModeMap.get(ConstantValues.ACH).id, null, applicationObj.Id);
        achTxnObj.Pricing_Detail__c = pricingDetailsObjList[0].Id;
        achTxnObj.genesis__Cleared__c = ConstantValues.TRUE_VALUE;
        achTxnObj.Posted_to_NLS__c = ConstantValues.TRUE_VALUE;
        Database.insert(achTxnObj,true);
    }
    /**
    * @description Create Parties for the application
    * @author Kabir Pramanik | 01-15-2025 
    * @param paramMapforParties 
    **/
    private static void createParties(Map<String, Object> paramMapforParties){
        Map<String, Id> paramForCLPartyMap = (Map<String, Id>)paramMapforParties.get('paramClMap');
        Map<String, Id> paramForBorrowerPartyMap = (Map<String, Id>)paramMapforParties.get('paramBorrowerMap');
        Map<String, Id> paramForPrincipalPartyMap = (Map<String, Id>)paramMapforParties.get('paramPrincipalMap');

        clcommon__Party__c clPartyObj = LoanServicingTestHelper.createParty(paramForCLPartyMap);
        clcommon__Party__c borrowerPartyObj = LoanServicingTestHelper.createParty(paramForBorrowerPartyMap);
        clcommon__Party__c principalPartyObj = LoanServicingTestHelper.createParty(paramForPrincipalPartyMap);
        Database.insert(new List<clcommon__Party__c> {clPartyObj,borrowerPartyObj,principalPartyObj}, true);
    }
    /**
    * @description Creating the integration framework
    * @author Kabir Pramanik | 01-02-2025 
    **/
    private static void createIntFrameWorkData(){
        //Inserting Integration Family
        intframework__Integration_Family__c family = IntegrationTestInitHelper.getFamilyInst('NLS Integration');
        Database.Insert(family, true);

        //Inserting Integration API Type
        intframework__Integration_API_Type__c getLoanApiType = IntegrationTestInitHelper.getIntegrationAPITypeInst(
            family.Id, 'NLSGetLoanStatusesAPIType');
        Database.Insert(getLoanApiType, true);

        //Inserting Integration Provider
        intframework__Integration_Provider__c getLoanProvider = IntegrationTestInitHelper.getIntegrationProviderInst(
            family.Id, 'Loan Statuses');
        Database.Insert(getLoanProvider, true);

        //Inserting Integration Configuration
        intframework__Integration_Configuration__c getLoanConfig = IntegrationTestInitHelper.getIntegrationConfigurationInst(
            getLoanProvider.Id, 'NLS Loan Statuses Integration Configuration','NLS');
        Database.Insert(getLoanConfig, true);

        //Inserting Integration API Configuration
        Map<String, Object> apiConfigMap = new Map<String, Object>{
            'familyId' => family.Id,
            'apiTypeId' => getLoanApiType.Id,
            'providerId' => getLoanProvider.Id,
            'configId' => getLoanConfig.Id,
            'longRunningOperation' => false,
            'adapterName' => 'NLSGetLoanStatusesAdapter',
            'method' => 'GET',
            'apiNamedCred' => 'NLS',
            'endpoint' => 'loans/loanId/statuses',
            'requestMappingJSON' =>'{"thirdPartySystem":{"name":"Get Loan","filters":[{"objectAPI":"genesis__Applications__c","objectAlias":"Application","fields":[{"externalField":"ID","fieldAPI":"Id"},{"externalField":"loanId","fieldAPI":"Loan_Id__c"}],"whereClause":"Id IN :applicationIdList"}]}}',
            'contentType' => 'application/json',
            'priority' => 1
        };

        intframework__Integration_API_Configuration__c xmlImportApiConfig = IntegrationTestInitHelper.getIntegrationAPIConfigurationInst(apiConfigMap);
        Database.Insert(xmlImportApiConfig, true);
    }
    
    /**
     * @description       : Setting up the Mock Response for Non accrual status
     * @author            : Suraj kumar
     * @last modified on  : 01-27-2025
     * @last modified by  : Kabir Pramanik
    **/
    public class NLSGetLoanStatusNonAccrualHttpCalloutMock implements HttpCalloutMock {
       
        /**
        * @description method to get mock response of NLS
        * @author Suraj Kumar | 02-21-2024 
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
                response.setBody('{"status":{"code":200,"message":"string","executionTime": 111},'+
                '"payload":'+
                    '{"totalCount":1,"count":1,"data":'+
                        '[{'+
                            '"Row_Id": 0,'+
                            '"Effective_Date": "2023-01-14T05:55:21.075Z",'+
                            '"Entry_Date": "2023-01-14T05:55:21.075Z",'+
                            '"Acctrefno": 0,'+
                            '"Status_Code_No": 18'+
                          '}]}}');
            }
            return response;
        }
    }

    /**
     * @description       : Setting up the Mock Response For Accrual Status
     * @author            : Suraj kumar
     * @last modified on  : 01-27-2025
     * @last modified by  : Kabir Pramanik
    **/
    public class NLSGetLoanStatusAccrualHttpCalloutMock implements HttpCalloutMock {
      
        /**
        * @description method to get mock response of NLS
        * @author Suraj Kumar | 02-21-2024 
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
                response.setBody('{"status":{"code":200,"message":"string", "executionTime": 111},'+
                '"payload":'+
                    '{"totalCount":1,"count":1,"data":'+
                        '[{}]}}');
            }
            return response;
        }
    }
    /**
     * @description       : Setting up the Mock Response for null access token
     * @author            : Kabir Pramanik
     * @last modified on  : 01-27-2025
     * @last modified by  : Kabir Pramanik
    **/
    public class NLSNullAccessTokenHttpCalloutMock implements HttpCalloutMock {
        
        /**
        * @description returns the mock response
        * @author Kabir Pramanik | 01-02-2025 
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
    * @description test status update of applcation having non accrual status to true on NLS
    * @author Kabir Pramanik | 01-02-2025 
    **/
    @isTest
    private static void testForNonAccrualStatusSuccess(){
        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.setMock(HttpCalloutMock.class, new NLSGetLoanStatusNonAccrualHttpCalloutMock());
            Test.startTest();
            NLSLoanStatusesCalloutBatch getLoanStatus = new NLSLoanStatusesCalloutBatch();
            Database.executeBatch(getLoanStatus);
            Test.stopTest();
            List<genesis__Application_Pricing_Detail__c> childLoanList = [SELECT Id,
                                                                                genesis__Enabled_Flag__c,
                                                                                genesis__Application__r.Non_Accrual__c,
                                                                                genesis__Application__r.Is_Evergreen_Eligible__c,
                                                                                genesis__Application__r.genesis__Loan_Number__c
                                                                            FROM genesis__Application_Pricing_Detail__c
                                                                            WHERE genesis__Application__r.Loan_Id__c = '139000'
                                                                            AND genesis__Rate_Card_Setup_Detail__r.Special_Term_Order__c != 1];
            System.assertEquals('9300023456', childLoanList[0].genesis__Application__r.genesis__Loan_Number__c,'Application loan number should start with 9');
            System.assertEquals(ConstantValues.TRUE_VALUE, childLoanList[0].genesis__Application__r.Non_Accrual__c,'Application should be non accrual');
            System.assertEquals(ConstantValues.FALSE_VALUE, childLoanList[0].genesis__Application__r.Is_Evergreen_Eligible__c,'Application should not be evergreen eligible');
            System.assertEquals(ConstantValues.FALSE_VALUE, childLoanList[0].genesis__Enabled_Flag__c, 'Child loan other than first tranche should be disabled');
            List<clcommon__Party__c> nonAccrualAppPartyList = [SELECT Id,
                                                                        Dealer_Applicant_Relationship__r.Is_Non_Accrual__c
                                                                FROM clcommon__Party__c 
                                                                WHERE clcommon__Party_Types__c IN (:ConstantValues.BORROWER_PARTY, :ConstantValues.PRINCIPAL_PARTY)
                                                                AND genesis__Application__r.Non_Accrual__c = True
                                                                AND genesis__Application__r.Loan_Id__c = '139000'];
            for(clcommon__Party__c partyObj: nonAccrualAppPartyList){
                System.assertEquals(ConstantValues.TRUE_VALUE, partyObj.Dealer_Applicant_Relationship__r.Is_Non_Accrual__c, 'Dealer Relation non accrual status should be true');
            }
        }
    }

    /**
    * @description test status of loan whose non accrual status is false on NLS
    * @author Kabir Pramanik | 01-02-2025 
    **/
    @isTest
    private static void testForAccrualStatusSuccess(){
        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.setMock(HttpCalloutMock.class, new NLSGetLoanStatusAccrualHttpCalloutMock());
            Test.startTest();
            NLSLoanStatusesCalloutBatch getLoanStatus = new NLSLoanStatusesCalloutBatch();
            Database.executeBatch(getLoanStatus);
            Test.stopTest();
            List<genesis__Applications__c> applicationObjList = [SELECT Id, 
                                                                    Non_Accrual__c
                                                                FROM genesis__Applications__c 
                                                                WHERE Loan_Id__c = '139000'
                                                                LIMIT 1];
            System.assertEquals(ConstantValues.FALSE_VALUE, applicationObjList[0].Non_Accrual__c,'Application should not be non accrual');
        }
    }

    /**
    * @description test acces token failure exception
    * @author Kabir Pramanik | 01-02-2025 
    **/
    @isTest 
    private static void testAccessTokenCalloutFailureException(){
        System.runAs(LoanServicingTestHelper.getAdminUser()){
            Test.setMock(HttpCalloutMock.class, new NLSNullAccessTokenHttpCalloutMock());
            Test.startTest();
            NLSLoanStatusesCalloutBatch getLoanStatus = new NLSLoanStatusesCalloutBatch();
            Database.executeBatch(getLoanStatus);
            Test.stopTest();
            List<clcommon__log__c> logList = [SELECT Id FROM clcommon__log__c WHERE Name = :NLSGetLoanStatusesAdapter.class.getName()];
            System.assertEquals(ConstantValues.FALSE_VALUE, logList.isEmpty() , 'Exception should be thrown for access token callout failure');
            List<genesis__Applications__c> applicationObjList = [SELECT Id, 
                                                                    Non_Accrual__c
                                                                FROM genesis__Applications__c 
                                                                WHERE Loan_Id__c = '139000'
                                                                LIMIT 1];
            System.assertEquals(ConstantValues.FALSE_VALUE, applicationObjList[0].Non_Accrual__c,'Non accrual status should not change');
        }
    }
}