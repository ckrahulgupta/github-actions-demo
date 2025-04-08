/**
 * @description       : Test Class for UpdateStatementCodeCalloutBatch and UpdateStatementCodeAdapter class
 * @author            : Kabir Pramanik
 * @group             : 
 * @last modified on  : 01-28-2025
 * @last modified by  : Kabir Pramanik
**/
@isTest
public with sharing class UpdateStatementCodeCalloutBatchTest {
    /**
     * @description       : Class to create mock response for Success status for access token and statement code callout
     * @author            : Kabir Pramanik
     * @group             : 
     * @last modified on  : 01-28-2025
     * @last modified by  : Kabir Pramanik
    **/
    public class XMLImportCalloutSuccessMock implements HttpCalloutMock {
        /**
        * @description Method to get the mock response
        * @author Kabir Pramanik | 01-23-2025 
        * @param request 
        * @return HTTPResponse 
        **/
        public HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setStatus('SUCCESS');
            response.setHeader('Content-Type', 'application/json');
            if (request.getEndpoint().contains('token')) {
                String token = '{"access_token":"eyJhbGciOiJSUzI1NiIsI","expires_in":300,"token_type":"Bearer"}';
                response.setBody(token);
            }
            else {
                response.setBody('{"status":{"code":200,"message":"string"},"payload":{"totalCount":0,"count":0,"data":[{"Row_Id":0,"Year_Number":2022,"Master_Record":0,"Principal_Advanced":0,"Month_Number":202206,"Principal_Advanced_Num":0,"Principal_Advanced_Average":0,"Principal_Paid":0,"Interest_Earned":120,"Interest_Paid":100.00,"Interest_Waived":0,"Late_Charges_Earned":0,"Late_Charges_Paid":0,"Def_Interest_Earned":0,"Late_Charges_Waived":0,"Def_Interest_Paid":0,"Def_Interest_Waived":0,"Fees_Earned":0,"Fees_Paid":0,"Fees_Waived":0,"Escrow_Interest_Earned":0,"Escrow_Interest_Paid":0,"Loan_Balance_Total":0,"Loan_Balance_Days":0,"Loan_Balance_Average":0,"Loan_Balance_High":0,"Loan_Balance_Low":0,"Days_Late_10":0,"Days_Late_30":0,"Days_Late_60":0,"Days_Late_90":0,"Days_Late_Over":0,"Nsf_Payments":0,"User_Defined_1":0,"User_Defined_2":0,"User_Defined_3":0,"User_Defined_4":0,"User_Defined_5":0,"User_Defined_6":0,"User_Defined_7":0,"User_Defined_8":0,"User_Defined_9":0,"User_Defined_10":0,"User_Defined_11":0,"User_Defined_12":0,"User_Defined_13":0,"User_Defined_14":0,"User_Defined_15":0,"User_Defined_16":0,"User_Defined_17":0,"User_Defined_18":0,"User_Defined_19":0,"User_Defined_20":0,"User_Defined_21":0,"User_Defined_22":0,"User_Defined_23":0,"User_Defined_24":0,"User_Defined_25":0,"Kept_Promise_Counter":0,"Broken_Promise_Counter":0,"Made_Promise_Counter":0,"Actuarial_Interest_Earned":0,"Servicing_Fee_Earned":0,"Servicing_Fee_Paid":0,"Acctrefno":0,"Deferred_Payments_Counter":0}]}}');
            }
            return response;
        }
    }
    /**
     * @description       : Class to create mock response for Bad Request (status code 400)
     * @author            : Kabir Pramanik
     * @group             : 
     * @last modified on  : 01-28-2025
     * @last modified by  : Kabir Pramanik
    **/
    public class XMLImportCalloutFailureMock implements HttpCalloutMock {
        /**
        * @description Method to get the mock response
        * @author Kabir Pramanik | 01-23-2025 
        * @param request 
        * @return HTTPResponse 
        **/
        public HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            if (request.getEndpoint().contains('token')) {
                String token = '{"access_token":"eyJhbGciOiJSUzI1NiIsI","expires_in":300,"token_type":"Bearer"}';
                response.setBody(token);
                response.setStatusCode(200);
                response.setStatus('SUCCESS');
            }
            else {
                response.setStatusCode(400);
                response.setStatus('FAILED');
                response.setBody('{"status":{"code":400,"message":"string"}');
            }
            return response;
        }
    }
    /**
     * @description       : Class to create mock response for Access Token callout failure (status code 400)
     * @author            : Kabir Pramanik
     * @group             : 
     * @last modified on  : 01-28-2025
     * @last modified by  : Kabir Pramanik
    **/
    public class XMLImportAccessTokenFailureMock implements HttpCalloutMock {
        /**
        * @description Method to get the mock response
        * @author Kabir Pramanik | 01-23-2025 
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
     * @description       : lass to create mock response for unauthorized access (response status 401)
     * @author            : Kabir Pramanik
     * @group             : 
     * @last modified on  : 01-28-2025
     * @last modified by  : Kabir Pramanik
    **/
    public class XMLImportUnauthorizedAccessMock implements HttpCalloutMock {
        /**
        * @description Method to get the mock response
        * @author Kabir Pramanik | 01-23-2025 
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
                response.setStatusCode(401);
                response.setStatus('FAILED');
                response.setBody('{"status":{"code":401,"message":"Authorization has been denied for this request.","executionTime": 5}}');
            }
            return response;
        }
    }
    /**
    * @description Creating test setup for test data
    * @author Kabir Pramanik | 01-22-2025 
    **/
    @TestSetup
    private static void makeData() {
        //Create integration framework data
        createIntegrationFrameworkData();

        // Creating floating rate index
        clcommon__Floating_Rate_Index__c floatingRateIndexObj = LoanServicingTestHelper.createFloatingRateIndex(
            New Map<String, Object>{ 'Name' => 'Field Finance Rate',
                                        'Base Rate Name' => '4-CFA ADVANTAGE',
                                        'Current Floating Rate' => 11,
                                        'Base Rate Adjuster' => 5.5
        });
        Database.insert(floatingRateIndexObj, true);

        // Creating floating rate
        clcommon__Floating_Rate__c floatingRateObj = LoanServicingTestHelper.createFloatingRate(floatingRateIndexObj);
        Database.insert(floatingRateObj, true);

        // Creating new partnert program
        CFA_Partner_Program__c cfaPartnerProgramObj = LoanServicingTestHelper.createPartnerProgram(floatingRateIndexObj);
        cfaPartnerProgramObj.Name = 'CFA';
        cfaPartnerProgramObj.Statement_Code_Multi_Rate_Opt_In__c = 'COMMITMENT STATEMENT';
        cfaPartnerProgramObj.Statement_Code_Multi_Rate_Opt_Out__c = 'COMMITMENT-OPT OUT';
        cfaPartnerProgramObj.Statement_Code_Single_Rate_Opt_In__c = 'MONTHLY STATEMENT';
        cfaPartnerProgramObj.Statement_Code_Single_Rate_Opt_Out__c = 'MONTHLY-OPT OUT';

        // Creating new partnert program
        CFA_Partner_Program__c landusPartnerProgramObj = LoanServicingTestHelper.createPartnerProgram(floatingRateIndexObj);
        landusPartnerProgramObj.Name = 'Landus';
        landusPartnerProgramObj.Statement_Code_Multi_Rate_Opt_In__c = '102555-LANDUS';
        landusPartnerProgramObj.Statement_Code_Multi_Rate_Opt_Out__c = '102555-LANDUS-OPT OUT';
        landusPartnerProgramObj.Statement_Code_Single_Rate_Opt_In__c = 'MONTHLY STATEMENT-LANDUS';
        landusPartnerProgramObj.Statement_Code_Single_Rate_Opt_Out__c = 'MONTHLY-OPT OUT-LANDUS';
        Database.insert(new List<CFA_Partner_Program__c> {cfaPartnerProgramObj,landusPartnerProgramObj}, true);
        
        clcommon__Reciprocal_Role__c clRole = LoanServicingTestHelper.createReciprocalRole(ConstantValues.CERTIFIED_LENDER);
        Database.insert(clRole, true);

        // creating dealer business info
        genesis__Business_Information__c dealerBusinessInfoObj = LoanServicingTestHelper.createBusinessInfoForDealer();
        genesis__Business_Information__c borrowerBusinessInfoObj = LoanServicingTestHelper.createBusinessInfoForBorrower();
        Database.insert(new List<genesis__Business_Information__c> {dealerBusinessInfoObj, borrowerBusinessInfoObj}, true);

        // Creating Legal Entity for Borrower
        clcommon__Legal_Entity__c entityObj = LoanServicingTestHelper.createLegalEntity(ConstantValues.SOLE_PROP_ENTITY);
        Database.insert(entityObj, true);
        
        // creating dealer account for all coop
        Account cfaDealerAccount = LoanServicingTestHelper.createDealerAccount(dealerBusinessInfoObj.Id, cfaPartnerProgramObj.Id);
        Account landusDealerAccount = LoanServicingTestHelper.createDealerAccount(dealerBusinessInfoObj.Id, landusPartnerProgramObj.Id);
        landusDealerAccount.Coop_Type__c = ConstantValues.LANDUS_COOP_TYPE;
        landusDealerAccount.Name = 'Lucy Binge';
        Account gmkDealerAccount = LoanServicingTestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        gmkDealerAccount.Coop_Type__c = ConstantValues.GROWMARK_COOP_TYPE;
        gmkDealerAccount.Name = 'Robi Hood';
        Database.insert(new List<Account> {cfaDealerAccount, landusDealerAccount, gmkDealerAccount}, true);

        // creating cl account for all dealer
        Account cfaClAccount = LoanServicingTestHelper.createCLAccount(dealerBusinessInfoObj.Id, cfaDealerAccount.Id);
        Account landusClAccount = LoanServicingTestHelper.createCLAccount(dealerBusinessInfoObj.Id, landusDealerAccount.Id);
        landusClAccount.Name = 'Jenny Lane';
        Account gmkClAccount = LoanServicingTestHelper.createCLAccount(dealerBusinessInfoObj.Id, gmkDealerAccount.Id);
        gmkClAccount.Name = 'William David';
        Account borrowerAccountObj = LoanServicingTestHelper.createSolePropAccount(entityObj, borrowerBusinessInfoObj.Id);
        borrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Grower').getRecordTypeId();
        Database.insert(new List<Account> {cfaClAccount, landusClAccount, gmkClAccount, borrowerAccountObj}, true);

        // creating cl contact for all dealer
        Contact cfaClContact = LoanServicingTestHelper.createCLContact(cfaClAccount.Id);
        Contact landusClContact = LoanServicingTestHelper.createCLContact(landusClAccount.Id);
        landusClContact.FirstName = 'Jenny';
        landusClContact.LastName = 'Lane';
        Contact gmkClContact = LoanServicingTestHelper.createCLContact(gmkClAccount.Id);
        gmkClContact.FirstName = 'William';
        gmkClContact.LastName = 'David';
        Contact borrowerContactObj = LoanServicingTestHelper.createBorrowerContact(borrowerAccountObj.Id);
        Database.insert(new List<Contact> {cfaClContact, landusClContact, gmkClContact, borrowerContactObj}, true);

        // creaating realtionship between dealer and cl for all coop
        clcommon__Relationship__c cfaDealerClRelation = LoanServicingTestHelper.createCLDealerRelationship(clRole,
                                                                cfaDealerAccount.Id,
                                                                cfaClAccount.Id);
        clcommon__Relationship__c landusDealerClRelation = LoanServicingTestHelper.createCLDealerRelationship(clRole,
                                                                landusDealerAccount.Id,
                                                                landusClAccount.Id);
                                                       
        clcommon__Relationship__c gmkDealerClRelation = LoanServicingTestHelper.createCLDealerRelationship(clRole,
                                                                gmkDealerAccount.Id,
                                                                gmkClAccount.Id);
        Database.insert(new List<clcommon__Relationship__c> {cfaDealerClRelation, landusDealerClRelation, gmkDealerClRelation}, true);

        // Creating CL Purpose of Application
        clcommon__CL_Purpose__c clPurposeObj = LoanServicingTestHelper.createCLPurposeForApplication();
        Database.insert(clPurposeObj, true);

        // Creating Cl Product of Application
        clcommon__CL_Product__c clProductObj = LoanServicingTestHelper.createCLProductForApplication();
        Database.insert(clProductObj, true);

        //creating single rate and multi rate my programs for different coops
        Map<String, Id> myProgIdMap = createMyProgForDiffCoops(
            new Map<String, Account> {
                'cfaDealerAccObj' => cfaDealerAccount,
                'landusDealerAccObj' => landusDealerAccount,
                'gmkDealerAccObj' => gmkDealerAccount
            }
        );

        //create all rate card setup details for the my programs
        createRateCardDetailsForMyPrograms(myProgIdMap);

        //creating dealer_applicant_relationship__c
        dealer_applicant_relationship__c cfaDealerBorrowerRelObj = LoanServicingTestHelper.createDealerApplicantRelationship(borrowerContactObj, cfaDealerAccount.Id);
        dealer_applicant_relationship__c landusBorrowerRelObj = LoanServicingTestHelper.createDealerApplicantRelationship(borrowerContactObj, landusDealerAccount.Id);
        dealer_applicant_relationship__c gmkDealerBorrowerRelObj = LoanServicingTestHelper.createDealerApplicantRelationship(borrowerContactObj, gmkDealerAccount.Id);
        Database.insert(new List<dealer_applicant_relationship__c> {cfaDealerBorrowerRelObj, landusBorrowerRelObj, gmkDealerBorrowerRelObj}, true);

        List<genesis__Applications__c> applicationObjList = new List<genesis__Applications__c>();
        applicationObjList.addAll(createApplicationsForMultiRateMyProg(new Map<String, Id> {
                                'clProductId' => clProductObj.Id,
                                'clPurposeId' => clPurposeObj.Id,
                                'dealerAccountId' => cfaDealerAccount.Id,
                                'clAccountId' => cfaClAccount.Id,
                                'borrowerAccountId' => borrowerAccountObj.Id,
                                'borrowerContactId' => borrowerContactObj.Id,
                                'borrowerRelationId' => cfaDealerBorrowerRelObj.Id,
                                'multiRateMyProgId' =>  myProgIdMap.get('cfaMultiRateMyProgramId')
                            }, ConstantValues.CFA_COOP_TYPE)
        );
        applicationObjList.addAll(createApplicationsForSingleRateMyProg(new Map<String, Id> {
                                'clProductId' => clProductObj.Id,
                                'clPurposeId' => clPurposeObj.Id,
                                'dealerAccountId' => cfaDealerAccount.Id,
                                'clAccountId' => cfaClAccount.Id,
                                'borrowerAccountId' => borrowerAccountObj.Id,
                                'borrowerContactId' => borrowerContactObj.Id,
                                'borrowerRelationId' => cfaDealerBorrowerRelObj.Id,
                                'singleRateMyProgId' => myProgIdMap.get('cfaSingleRateMyProgramId')
                            }, ConstantValues.CFA_COOP_TYPE)
        );
        applicationObjList.addAll(createApplicationsForMultiRateMyProg(new Map<String, Id> {
                                'clProductId' => clProductObj.Id,
                                'clPurposeId' => clPurposeObj.Id,
                                'dealerAccountId' => landusDealerAccount.Id,
                                'borrowerAccountId' => borrowerAccountObj.Id,
                                'borrowerContactId' => borrowerContactObj.Id,
                                'borrowerRelationId' => landusBorrowerRelObj.Id,
                                'multiRateMyProgId' =>  myProgIdMap.get('landusMultiRateMyProgramId')
                            }, ConstantValues.LANDUS_COOP_TYPE)
        );
        applicationObjList.addAll(createApplicationsForSingleRateMyProg(new Map<String, Id> {
                                'clProductId' => clProductObj.Id,
                                'clPurposeId' => clPurposeObj.Id,
                                'dealerAccountId' => landusDealerAccount.Id,
                                'borrowerAccountId' => borrowerAccountObj.Id,
                                'borrowerContactId' => borrowerContactObj.Id,
                                'borrowerRelationId' => landusBorrowerRelObj.Id,
                                'singleRateMyProgId' =>  myProgIdMap.get('landusSingleRateMyProgramId')
                            }, ConstantValues.LANDUS_COOP_TYPE)
        );
        applicationObjList.addAll(createApplicationsForMultiRateMyProg(new Map<String, Id> {
                                'clProductId' => clProductObj.Id,
                                'clPurposeId' => clPurposeObj.Id,
                                'dealerAccountId' => gmkDealerAccount.Id,
                                'clAccountId' => gmkClAccount.Id,
                                'borrowerAccountId' => borrowerAccountObj.Id,
                                'borrowerContactId' => borrowerContactObj.Id,
                                'borrowerRelationId' => landusBorrowerRelObj.Id,
                                'multiRateMyProgId' => myProgIdMap.get('gmkMultiRateMyProgramId')
                            }, ConstantValues.GROWMARK_COOP_TYPE)
        );
        applicationObjList.addAll(createApplicationsForSingleRateMyProg(new Map<String, Id> {
                                'clProductId' => clProductObj.Id,
                                'clPurposeId' => clPurposeObj.Id,
                                'dealerAccountId' => gmkDealerAccount.Id,
                                'clAccountId' => gmkClAccount.Id,
                                'borrowerAccountId' => borrowerAccountObj.Id,
                                'borrowerContactId' => borrowerContactObj.Id,
                                'borrowerRelationId' => gmkDealerBorrowerRelObj.Id,
                                'singleRateMyProgId' => myProgIdMap.get('gmkSingleRateMyProgramId')
                            }, ConstantValues.GROWMARK_COOP_TYPE)
        );
        Database.insert(applicationObjList, true);
        List<genesis__Application_Pricing_Detail__c> pricingDetailsList = new List<genesis__Application_Pricing_Detail__c>();
        for(genesis__Applications__c applicationObj: applicationObjList){
            pricingDetailsList.addAll(LoanServicingTestHelper.createSeedDataForPricingDetail(applicationObj));
        }
        //update the enabled flag according to dates
        for(genesis__Application_Pricing_Detail__c individualPricing: pricingDetailsList){
            if(individualPricing.genesis__Rate_Card_Setup_Detail__c != null &&
                individualPricing.genesis__Rate_Card_Setup_Detail__r.Start_date__c != null &&
                    (individualPricing.genesis__Rate_Card_Setup_Detail__r.Start_date__c > System.today() || 
                    individualPricing.genesis__Rate_Card_Setup_Detail__r.End_date__c < System.today() )){
                        individualPricing.genesis__Enabled_Flag__c = false;
            }
        }
        Database.insert(pricingDetailsList, true);
        System.debug('--------> pricing details list ' + pricingDetailsList);
        List<genesis__applications__c> appList = new List<genesis__Applications__c>();
        appList = [SELECT Id, Pricing_Count__c, Loan_Id__c, Coop_Type__c FROM genesis__Applications__c];
        System.debug('--------> application list ' + appList);
    }

    /**
    * @description This method creates integration framework data
    * @author Kabir Pramanik | 01-22-2025 
    **/
    private static void createIntegrationFrameworkData(){
        // setup integration family
        intframework__Integration_Family__c integrationFamilyObj = IntegrationTestInitHelper.getFamilyInst('NLS Integration');
        Database.insert(integrationFamilyObj, true);

        // setup integration API type
        intframework__Integration_API_Type__c apiTypeObj = 
                        IntegrationTestInitHelper.getIntegrationAPITypeInst(
                                integrationFamilyObj.Id, 
                                'Statement Code API Type'
                            );
        Database.insert(apiTypeObj, true);

        // setup integration provider
        intframework__Integration_Provider__c integrationProviderObj = 
                        IntegrationTestInitHelper.getIntegrationProviderInst(
                                integrationFamilyObj.Id, 
                                'Statement Code Integration Provider'
                            );
        Database.insert(integrationProviderObj, true);

        // setup integration configration
        intframework__Integration_Configuration__c integrationConfigObj = 
                        IntegrationTestInitHelper.getIntegrationConfigurationInst(
                                integrationProviderObj.Id,
                                'Statement Code Configuration',
                                'NLS'
                            );
        Database.insert(integrationConfigObj, true);
                           
        Map<String, String> integrationApiConfigMap = new Map<String, String> {
            'adapterName' => 'UpdateStatementCodeAdapter',
            'method' => 'POST',
            'endpoint' => '/nls/xml-import',
            'longRunningOperation' => 'false',
            'priority' => '1',
            'contentType' => 'application/json',
            'requestMappingJSON' => '{"thirdPartySystem": {"name": "Get Loan","filters": [{"objectAPI": "genesis__Applications__c","objectAlias": "loans","fields": [{"externalField": "id","fieldAPI": "Id"},{"externalField": "loanNumber","fieldAPI": "genesis__Loan_Number__c"},{"externalField": "pricingCount","fieldAPI": "Pricing_Count__c"},{"externalField": "statementCode","fieldAPI": "Statement_Code__c"},{"externalField": "coopType","fieldAPI": "Coop_Type__c"},{"externalField": "PartnerProgram","fieldAPI": "Dealer_Name__r.CFA_Partner_program__r.Name"},{"externalField": "PartnerProgramId","fieldAPI": "Dealer_Name__r.CFA_Partner_program__c"}],"whereClause": "Id IN :loanIdList"}]}}',
            'familyId' => integrationFamilyObj.Id,
            'apiTypeId' => apiTypeObj.Id,
            'providerId' => integrationProviderObj.Id,
            'configId' => integrationConfigObj.Id
        };
        intframework__Integration_API_Configuration__c statementCodeApiConfigObj = IntegrationTestInitHelper.getIntegrationAPIConfigurationInst(integrationApiConfigMap);
        Database.insert(statementCodeApiConfigObj, true);
    }
    
    /**
    * @description Creating applications with multi rate my programs
    * @author Kabir Pramanik | 01-22-2025 
    * @param paramMap 
    * @param coopType 
    * @return List<genesis__Applications__c> 
    **/
    private static List<genesis__Applications__c> createApplicationsForMultiRateMyProg(Map<String, Id> paramMap, String coopType){
        
        //Creating Application with multi rate my program
        genesis__Applications__c applicationOneObj = LoanServicingTestHelper.createCurrCropYearApplication(new Map<String,Id>{
            'dealerAccountId' => paramMap.get('dealerAccountId'),
            'clProductId' => paramMap.get('clProductId'),
            'clPurposeId' => paramMap.get('clPurposeId'),
            'borrowerAccountId' => paramMap.get('borrowerAccountId'),
            'borrowerContactId' => paramMap.get('borrowerContactId'),
            'clAccountId' => paramMap.get('clAccountId'),
            'dealerApplicantRelationshipId' => paramMap.get('borrowerRelationId')
        });
        applicationOneObj.My_Program__c = paramMap.get('multiRateMyProgId');
        applicationOneObj.genesis__Maturity_Date__c = Date.valueOf('2026-03-15');
        applicationOneObj.genesis__Status__c = 'ACTIVE';
        if(coopType == ConstantValues.CFA_COOP_TYPE){
            applicationOneObj.genesis__Loan_Number__c = '111111';
            applicationOneObj.Loan_Id__c = '1111';
            applicationOneObj.Statement_Code__c = 'COMMITMENT-OPT OUT';
        }else if(coopType == ConstantValues.LANDUS_COOP_TYPE){
            applicationOneObj.genesis__Loan_Number__c = '222111';
            applicationOneObj.Loan_Id__c = '2211';
            applicationOneObj.Statement_Code__c = '102555-LANDUS-OPT OUT';
        }else if(coopType == ConstantValues.GROWMARK_COOP_TYPE){
            applicationOneObj.genesis__Loan_Number__c = '333111';
            applicationOneObj.Loan_Id__c = '3311';
            applicationOneObj.Statement_Code__c = 'COMMITMENT-GROWMARK';
        }

        //creating application with multi rate my program
        genesis__Applications__c applicationTwoObj = LoanServicingTestHelper.createCurrCropYearApplication(new Map<String,Id>{
            'dealerAccountId' => paramMap.get('dealerAccountId'),
            'clProductId' => paramMap.get('clProductId'),
            'clPurposeId' => paramMap.get('clPurposeId'),
            'borrowerAccountId' => paramMap.get('borrowerAccountId'),
            'borrowerContactId' => paramMap.get('borrowerContactId'),
            'clAccountId' => paramMap.get('clAccountId'),
            'dealerApplicantRelationshipId' => paramMap.get('borrowerRelationId')
        });
        applicationTwoObj.My_Program__c = paramMap.get('multiRateMyProgId');
        applicationTwoObj.genesis__Maturity_Date__c = Date.valueOf('2026-03-15');
        applicationTwoObj.genesis__Status__c = 'ACTIVE';
        if(coopType == ConstantValues.CFA_COOP_TYPE){
            applicationTwoObj.genesis__Loan_Number__c = '111222';
            applicationTwoObj.Loan_Id__c = '1122';
            applicationTwoObj.Statement_Code__c = 'COMMITMENT STATEMENT';
        }else if(coopType == ConstantValues.LANDUS_COOP_TYPE){
            applicationTwoObj.genesis__Loan_Number__c = '222222';
            applicationTwoObj.Loan_Id__c = '2222';
            applicationTwoObj.Statement_Code__c = '102555-LANDUS';
        }else if(coopType == ConstantValues.GROWMARK_COOP_TYPE){
            applicationTwoObj.genesis__Loan_Number__c = '333222';
            applicationTwoObj.Loan_Id__c = '3322';
            applicationTwoObj.Statement_Code__c = 'COMMITMENT-GROWMARK';
        }
        return new List<genesis__Applications__c> {applicationOneObj, applicationTwoObj};
    }
    
    /**
    * @description Creating applications with single rate my programs
    * @author Kabir Pramanik | 01-22-2025 
    * @param paramMap 
    * @param coopType 
    * @return List<genesis__Applications__c> 
    **/
    private static List<genesis__Applications__c> createApplicationsForSingleRateMyProg(Map<String, Id> paramMap, String coopType){
        //creating application with single rate my program
        genesis__Applications__c applicationOneObj = LoanServicingTestHelper.createCurrCropYearApplication(new Map<String,Id>{
            'dealerAccountId' => paramMap.get('dealerAccountId'),
            'clProductId' => paramMap.get('clProductId'),
            'clPurposeId' => paramMap.get('clPurposeId'),
            'borrowerAccountId' => paramMap.get('borrowerAccountId'),
            'borrowerContactId' => paramMap.get('borrowerContactId'),
            'clAccountId' => paramMap.get('clAccountId'),
            'dealerApplicantRelationshipId' => paramMap.get('borrowerRelationId')
        });
        applicationOneObj.My_Program__c = paramMap.get('singleRateMyProgId');
        applicationOneObj.genesis__Maturity_Date__c = Date.valueOf('2026-03-15');
        applicationOneObj.genesis__Status__c = 'ACTIVE';
        if(coopType == ConstantValues.CFA_COOP_TYPE){
            applicationOneObj.genesis__Loan_Number__c = '111333';
            applicationOneObj.Loan_Id__c = '1133';
            applicationOneObj.Statement_Code__c = 'MONTHLY-OPT OUT';
        }else if(coopType == ConstantValues.LANDUS_COOP_TYPE){
            applicationOneObj.genesis__Loan_Number__c = '222333';
            applicationOneObj.Loan_Id__c = '2233';
            applicationOneObj.Statement_Code__c = 'MONTHLY-OPT OUT-LANDUS';
        }else if(coopType == ConstantValues.GROWMARK_COOP_TYPE){
            applicationOneObj.genesis__Loan_Number__c = '333333';
            applicationOneObj.Loan_Id__c = '3333';
            applicationOneObj.Statement_Code__c = 'MONTHLY STATEMENT-GMK';
        }

        //creating application with single rate my program
        genesis__Applications__c applicationTwoObj = LoanServicingTestHelper.createCurrCropYearApplication(new Map<String,Id>{
            'dealerAccountId' => paramMap.get('dealerAccountId'),
            'clProductId' => paramMap.get('clProductId'),
            'clPurposeId' => paramMap.get('clPurposeId'),
            'borrowerAccountId' => paramMap.get('borrowerAccountId'),
            'borrowerContactId' => paramMap.get('borrowerContactId'),
            'clAccountId' => paramMap.get('clAccountId'),
            'dealerApplicantRelationshipId' => paramMap.get('borrowerRelationId')
        });
        applicationTwoObj.My_Program__c = paramMap.get('singleRateMyProgId');
        applicationTwoObj.genesis__Maturity_Date__c = Date.valueOf('2026-03-15');
        applicationTwoObj.genesis__Status__c = 'ACTIVE';
        if(coopType == ConstantValues.CFA_COOP_TYPE){
            applicationTwoObj.genesis__Loan_Number__c = '111444';
            applicationTwoObj.Loan_Id__c = '1144';
            applicationTwoObj.Statement_Code__c = 'MONTHLY STATEMENT';
        }else if(coopType == ConstantValues.LANDUS_COOP_TYPE){
            applicationTwoObj.genesis__Loan_Number__c = '222444';
            applicationTwoObj.Loan_Id__c = '2244';
            applicationTwoObj.Statement_Code__c = 'MONTHLY STATEMENT-LANDUS';
        }else if(coopType == ConstantValues.GROWMARK_COOP_TYPE){
            applicationTwoObj.genesis__Loan_Number__c = '333444';
            applicationTwoObj.Loan_Id__c = '3344';
            applicationTwoObj.Statement_Code__c = 'MONTHLY STATEMENT-GMK';
        }

        //creating application with single rate my program and random statement code
        genesis__Applications__c applicationThreeObj = LoanServicingTestHelper.createCurrCropYearApplication(new Map<String,Id>{
            'dealerAccountId' => paramMap.get('dealerAccountId'),
            'clProductId' => paramMap.get('clProductId'),
            'clPurposeId' => paramMap.get('clPurposeId'),
            'borrowerAccountId' => paramMap.get('borrowerAccountId'),
            'borrowerContactId' => paramMap.get('borrowerContactId'),
            'clAccountId' => paramMap.get('clAccountId'),
            'dealerApplicantRelationshipId' => paramMap.get('borrowerRelationId')
        });
        applicationThreeObj.My_Program__c = paramMap.get('singleRateMyProgId');
        applicationThreeObj.genesis__Maturity_Date__c = Date.valueOf('2026-03-15');
        applicationThreeObj.genesis__Status__c = 'ACTIVE';
        applicationThreeObj.genesis__Loan_Number__c = '888888';
        applicationThreeObj.Loan_Id__c = '8888';
        applicationThreeObj.Statement_Code__c = 'OTHER STATEMENT';
        return new List<genesis__Applications__c> {applicationOneObj, applicationTwoObj, applicationThreeObj};
    }

    /**
    * @description Creating single rate and multi rate my program header for different coops
    * @author Kabir Pramanik | 01-22-2025 
    * @param dealerAccountObjMap 
    * @return Map<String, Account> 
    **/
    private static Map<String, Id> createMyProgForDiffCoops(Map<String, Account> dealerAccountObjMap){
        //rate card header for cfa
        genesis__Rate_Card_Setup_Header__c cfaMyProgObj = LoanServicingTestHelper.createRateCardHeader(dealerAccountObjMap.get('cfaDealerAccObj'));
        cfaMyProgObj.genesis__Start_Date__c = System.today();
        cfaMyProgObj.genesis__End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        genesis__Rate_Card_Setup_Header__c cfaMyProgTwoObj = LoanServicingTestHelper.createRateCardHeader(dealerAccountObjMap.get('cfaDealerAccObj'));
        cfaMyProgTwoObj.genesis__Start_Date__c = System.today();
        cfaMyProgTwoObj.genesis__End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);

        //rate card header for landus
        genesis__Rate_Card_Setup_Header__c landusMyProgObj = LoanServicingTestHelper.createRateCardHeader(dealerAccountObjMap.get('landusDealerAccObj'));
        landusMyProgObj.genesis__Start_Date__c = System.today();
        landusMyProgObj.genesis__End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        genesis__Rate_Card_Setup_Header__c landusMyProgTwoObj = LoanServicingTestHelper.createRateCardHeader(dealerAccountObjMap.get('landusDealerAccObj'));
        landusMyProgTwoObj.genesis__Start_Date__c = System.today();
        landusMyProgTwoObj.genesis__End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        
        //rate card header for Gmk
        genesis__Rate_Card_Setup_Header__c gmkMyProgObj = LoanServicingTestHelper.createRateCardHeader(dealerAccountObjMap.get('gmkDealerAccObj'));
        gmkMyProgObj.genesis__Start_Date__c = System.today();
        gmkMyProgObj.genesis__End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        genesis__Rate_Card_Setup_Header__c gmkMyProgTwoObj = LoanServicingTestHelper.createRateCardHeader(dealerAccountObjMap.get('gmkDealerAccObj'));
        gmkMyProgTwoObj.genesis__Start_Date__c = System.today();
        gmkMyProgTwoObj.genesis__End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);

        Database.insert(new List<genesis__Rate_Card_Setup_Header__c> {cfaMyProgObj, cfaMyProgTwoObj, landusMyProgObj, landusMyProgTwoObj, gmkMyProgObj, gmkMyProgTwoObj},true);
        
        return new Map<String, Id> {
            'cfaSingleRateMyProgramId' => cfaMyProgObj.Id,
            'cfaMultiRateMyProgramId' => cfaMyProgTwoObj.Id,
            'landusSingleRateMyProgramId' => landusMyProgObj.Id,
            'landusMultiRateMyProgramId' => landusMyProgTwoObj.Id,
            'gmkSingleRateMyProgramId' => gmkMyProgObj.Id,
            'gmkMultiRateMyProgramId' => gmkMyProgTwoObj.Id
        };
    }

    /**
    * @description Creating rate card setup details for all the my programs
    * @author Kabir Pramanik | 01-28-2025 
    * @param myProgIdMap 
    **/
    private static void createRateCardDetailsForMyPrograms(Map<String, Id> myProgIdMap){
        List<genesis__Rate_Card_Setup_Detail__c> rateCardSetupDetailsList = new List<genesis__Rate_Card_Setup_Detail__c>();
        rateCardSetupDetailsList.addAll(
            createSingleRateCardSetupDetails(myProgIdMap.get('cfaSingleRateMyProgramId'))
        );
        rateCardSetupDetailsList.addAll(
            createMultipleRateCardSetupDetails(myProgIdMap.get('cfaMultiRateMyProgramId'))
        );
        rateCardSetupDetailsList.addAll(
            createSingleRateCardSetupDetails(myProgIdMap.get('landusSingleRateMyProgramId'))
        );
        rateCardSetupDetailsList.addAll(
            createMultipleRateCardSetupDetails(myProgIdMap.get('landusMultiRateMyProgramId'))
        );
        rateCardSetupDetailsList.addAll(
            createSingleRateCardSetupDetails(myProgIdMap.get('gmkSingleRateMyProgramId'))
        );
        rateCardSetupDetailsList.addAll(
            createMultipleRateCardSetupDetails(myProgIdMap.get('gmkMultiRateMyProgramId'))
        );
        Database.insert(rateCardSetupDetailsList, true);
    }
    
    

    /**
    * @description Creating one rate card setup details with given myProgram Id
    * @author Kabir Pramanik | 01-28-2025 
    * @param rateCardHeaderId 
    * @return genesis__Rate_Card_Setup_Detail__c 
    **/
    private static List<genesis__Rate_Card_Setup_Detail__c> createSingleRateCardSetupDetails(Id rateCardHeaderId){
        genesis__Rate_Card_Setup_Detail__c specialTermAA = new genesis__Rate_Card_Setup_Detail__c(); 
        specialTermAA.Start_Date__c = System.today();
        specialTermAA.End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        specialTermAA.billing_date__c = null;
        specialTermAA.has_billing_date__c = false;
        specialTermAA.Participation_Percentage_Dealer_Subsidy__c = 0;
        specialTermAA.Participation_Percentage_Dealer__c = 2;
        specialTermAA.Participation_Percentage_CFA__c = 1;
        specialTermAA.genesis__Interest_Rate__c = 13;
        specialTermAA.Interest_Rate_Type__c = 'Variable';
        specialTermAA.Description__c = 'Note Rate';
        specialTermAA.genesis__Rate_Card_Setup_Header__c = rateCardHeaderId;
        specialTermAA.Special_Term_Order__c = 1;
        specialTermAA.Special_Term_Reference__c = 'Special Term Sub-Tranche (A)';

        return new List<genesis__Rate_Card_Setup_Detail__c>{specialTermAA};
    }

    /**
    * @description Creating two rate card setup details for two different tranch with given myProgram Id
    * @author Kabir Pramanik | 01-28-2025 
    * @param rateCardHeaderId 
    * @return List<genesis__Rate_Card_Setup_Detail__c> 
    **/
    private static List<genesis__Rate_Card_Setup_Detail__c> createMultipleRateCardSetupDetails(Id rateCardHeaderId){
        genesis__Rate_Card_Setup_Detail__c specialTermAA = new genesis__Rate_Card_Setup_Detail__c(); 
        specialTermAA.Start_Date__c = System.today();
        specialTermAA.End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        specialTermAA.billing_date__c = null;
        specialTermAA.has_billing_date__c = false;
        specialTermAA.Participation_Percentage_Dealer_Subsidy__c = 0;
        specialTermAA.Participation_Percentage_Dealer__c = 2;
        specialTermAA.Participation_Percentage_CFA__c = 1;
        specialTermAA.genesis__Interest_Rate__c = 13;
        specialTermAA.Interest_Rate_Type__c = 'Variable';
        specialTermAA.Description__c = 'Note Rate';
        specialTermAA.genesis__Rate_Card_Setup_Header__c = rateCardHeaderId;
        specialTermAA.Special_Term_Order__c = 1;
        specialTermAA.Special_Term_Reference__c = 'Special Term Sub-Tranche (A)';

        genesis__Rate_Card_Setup_Detail__c specialTermBA = new genesis__Rate_Card_Setup_Detail__c();
        specialTermBA.Start_Date__c = System.today();
        specialTermBA.End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        specialTermAA.billing_date__c = null;
        specialTermBA.has_billing_date__c = false;
        specialTermBA.Participation_Percentage_Dealer_Subsidy__c = 0;
        specialTermBA.Participation_Percentage_Dealer__c = 1;
        specialTermBA.Participation_Percentage_CFA__c = 1;
        specialTermBA.genesis__Interest_Rate__c = 12;
        specialTermBA.Interest_Rate_Type__c = 'Fixed';
        specialTermBA.Description__c = 'Millet Seeds';
        specialTermBA.genesis__Rate_Card_Setup_Header__c = rateCardHeaderId;
        specialTermBA.Special_Term_Order__c = 2;
        specialTermBA.Special_Term_Reference__c = 'Special Term Sub-Tranche (B)';

        return new List<genesis__Rate_Card_Setup_Detail__c> {specialTermAA,specialTermBA};
    }

    /**
    * @description Success scenario for updating statement code 
    * @author Ravi Ranjan | 04-17-2024 
    **/
    @isTest
    private static void testStatementCodeUpdateSuccessForCfa() {
        List<genesis__applications__c> appListToDelete = [SELECT Id FROM genesis__Applications__c where Loan_Id__c Not In ('1111','1133')];
        Database.delete(appListToDelete, true);
        System.runAs(LoanServicingTestHelper.getAdminUser()) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new XMLImportCalloutSuccessMock());
            UpdateStatementCodeCalloutBatch batchInstance = new UpdateStatementCodeCalloutBatch(Date.valueOf('2026-03-15'));
            Database.executeBatch(batchInstance, 50);
            Test.stopTest();
            List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                    Loan_Id__c,
                                                                    Statement_Code__c
                                                                FROM genesis__Applications__c 
                                                                WHERE Loan_Id__c In ('1111',
                                                                                     '1133')
                                                            ];
            for(genesis__Applications__c appObj: applicationList){
                if(appObj.Loan_Id__c == '1111'){
                    System.assertEquals('COMMITMENT STATEMENT', appObj.Statement_Code__c, 'Assertion Failed');
                }
                if(appObj.Loan_Id__c == '1133'){
                    System.assertEquals('MONTHLY STATEMENT', appObj.Statement_Code__c, 'Assertion Failed');
                }
            }
        }
    }
    /**
    * @description Success scenario for updating statement code for Landus
    * @author Ravi Ranjan | 04-17-2024 
    **/
    @isTest
    private static void testStatementCodeUpdateSuccessForLandus() {
        System.runAs(LoanServicingTestHelper.getAdminUser()) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new XMLImportCalloutSuccessMock());
            UpdateStatementCodeCalloutBatch batchInstance = new UpdateStatementCodeCalloutBatch(Date.valueOf('2026-03-15'));
            Database.executeBatch(batchInstance, 50);
            Test.stopTest();
            List<genesis__Applications__c> applicationList = [SELECT Id,
                                                                    Loan_Id__c,
                                                                    Statement_Code__c
                                                                FROM genesis__Applications__c 
                                                                WHERE Loan_Id__c In ('2211',
                                                                                     '2233')
                                                            ];
            for(genesis__Applications__c appObj: applicationList){
                if(appObj.Loan_Id__c == '2211'){
                    System.assertEquals('102555-LANDUS', appObj.Statement_Code__c, 'Assertion Failed');
                }
                if(appObj.Loan_Id__c == '2233'){
                    System.assertEquals('MONTHLY STATEMENT-LANDUS', appObj.Statement_Code__c, 'Assertion Failed');
                }
            }
        }
    }
    /**
    * @description Success scenario for updating statement code for closed application.It will not update for closed application
    * @author Ravi Ranjan | 04-17-2024 
    **/
    @isTest
    private static void testStatementCodeUpdateForClosedLoan() {
        //making the two CFA application's status as CLOSED
        List<genesis__Applications__c> applicationList = [SELECT Id
                                                            FROM genesis__Applications__c 
                                                            WHERE genesis__Status__c = :ConstantValues.ACTIVE
                                                            AND Loan_Id__c In ('1111', '1133')];
        for(genesis__Applications__c appObj :applicationList){
            appObj.genesis__Status__c = ConstantValues.CLOSED;
        }
        Database.update(applicationList, true);
        System.runAs(LoanServicingTestHelper.getAdminUser()) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new XMLImportCalloutSuccessMock());
            UpdateStatementCodeCalloutBatch batchInstance = new UpdateStatementCodeCalloutBatch(Date.valueOf('2026-03-15'));
            Database.executeBatch(batchInstance, 50);
            Test.stopTest();
            List<genesis__Applications__c> updatedAppList = [SELECT Id
                                                                FROM genesis__Applications__c 
                                                                WHERE Loan_Id__c In ('1111', '1133')
                                                                AND Statement_Code__c In ('COMMITMENT STATEMENT', 'MONTHLY STATEMENT')];
            System.assertEquals(ConstantValues.TRUE_VALUE,updatedAppList.isEmpty(), 'Asserion Failed');
        }
    }
    /**
    * @description Success scenario for updating statement when there is no loan under particular maturity date
    * @author Ravi Ranjan | 04-17-2024 
    **/
    @isTest
    private static void testStatementCodeUpdateWithNoMaturityMatched() {
        List<genesis__Applications__c> appList = [SELECT Id
                                                    FROM genesis__Applications__c
                                                    WHERE genesis__Status__c = :ConstantValues.ACTIVE
                                                    AND Statement_Code__c In ('COMMITMENT STATEMENT', 'MONTHLY STATEMENT')];
        //deleting existing opt in applications of CFA
        Database.delete(appList, true);
        System.runAs(LoanServicingTestHelper.getAdminUser()) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new XMLImportCalloutSuccessMock());
            UpdateStatementCodeCalloutBatch batchInstance = new UpdateStatementCodeCalloutBatch(Date.valueOf('2026-01-15'));
            Database.executeBatch(batchInstance, 50);
            Test.stopTest();
            List<genesis__Applications__c> updatedAppList = [SELECT Id
                                                                FROM genesis__Applications__c
                                                                WHERE genesis__Status__c = :ConstantValues.ACTIVE
                                                                AND Statement_Code__c In ('COMMITMENT STATEMENT', 'MONTHLY STATEMENT')];
            //checking no application is newly updated with opt in statement code                                                   
            System.assertEquals(0 , updatedAppList.size(), 'Asserion Failed');
        }
    }
     /**
    * @description Updating statement code whose coop is null. Exception should be thrown
    * @author Ravi Ranjan | 04-17-2024 
    **/
    @isTest
    private static void testNullCoopStatementCodeUpdateException() {
        List<Account> dealerAccList = [SELECT Id, 
                                                Coop_Type__c
                                        FROM Account 
                                        WHERE RecordType.Name = :ConstantValues.DEALER];
       for(Account eachDealerObj :dealerAccList){
            eachDealerObj.Coop_Type__c = null;
       }
        Database.update(dealerAccList, true);
        List<genesis__Applications__c> applicationList = [SELECT Id 
                                                            FROM genesis__Applications__c 
                                                            WHERE genesis__Status__c = :ConstantValues.ACTIVE];
        Database.update(applicationList, true);
        for(genesis__Applications__c application: applicationList){
            System.runAs(LoanServicingTestHelper.getAdminUser()) {
                Test.startTest();
                Test.setMock(HttpCalloutMock.class, new XMLImportCalloutSuccessMock());
                UpdateStatementCodeCalloutBatch batchInstance = new UpdateStatementCodeCalloutBatch(Date.valueOf('2026-03-15'));
                Database.executeBatch(batchInstance, 50);
                Test.stopTest();
                List<clcommon__Log__c> logList = [SELECT Id FROM clcommon__Log__c WHERE Name = :UpdateStatementCodeAdapter.class.getName()];
                System.assertEquals(ConstantValues.FALSE_VALUE, logList.isEmpty(), 'Assertion Failed');
            }
        }
    }
    /**
    * @description Test update satement code callout with 400 status code response
    * @author Ravi Ranjan | 04-17-2024 
    **/
    @isTest
    private static void testCaseUpdateStatementCodeFailure() {
        System.runAs(LoanServicingTestHelper.getAdminUser()) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new XMLImportCalloutFailureMock());
            UpdateStatementCodeCalloutBatch batchInstance = new UpdateStatementCodeCalloutBatch(Date.valueOf('2026-03-15'));
            Database.executeBatch(batchInstance, 50);
            Test.stopTest();
            List<clcommon__Log__c> logList = [SELECT Id FROM clcommon__Log__c WHERE Name = :UpdateStatementCodeAdapter.class.getName()];
            System.assertEquals(ConstantValues.FALSE_VALUE, logList.isEmpty(), 'Assertion Failed');
            //loans with opt out statement code will remain same and not get updated to opt in
            List<genesis__Applications__c> applicationList = [SELECT Id 
                                                                 FROM genesis__Applications__c 
                                                                 WHERE Statement_Code__c In ('COMMITMENT-OPT OUT', 'MONTHLY-OPT OUT')];
            System.assertEquals(ConstantValues.FALSE_VALUE, applicationList.isEmpty() , 'Assertion Failed');
        }
    }
    /**
    * @description Test exception when integration family is deleted
    * @author Ravi Ranjan | 04-17-2024 
    **/
    @isTest
    private static void testUpdateStatementCodeIntFrameworkMissingFailure() {
        Database.delete([SELECT Id FROM intframework__Integration_Family__c], true);
        System.runAs(LoanServicingTestHelper.getAdminUser()) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new XMLImportCalloutSuccessMock());
            UpdateStatementCodeCalloutBatch batchInstance = new UpdateStatementCodeCalloutBatch(Date.valueOf('2026-03-15'));
            Database.executeBatch(batchInstance, 50);
            Test.stopTest();
            System.assertEquals(true, true, 'Assertion Failed');
        }
    }
}