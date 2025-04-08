/**
 * @description       : Test class for NLSGetChildLoanDetailsSchedule, NLSChildPayoffDetailsCalloutBatch, NLSGetChildLoanCalloutBatch, NLSGetChildLoanPayoffViaMailBatch, NLSParticipantsGetChildLoanCalloutBatch, NLSClosedChildPayoffCalloutBatch, NLSClosedChildLoanCalloutBatch
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 01-27-2025
 * @last modified by  : Ayush Kumar Singh
 * Modifications Log 
 * Ver   Date         Author         Modification
 * 1.0   31-05-2022   Subham Nandi   Initial Version
**/
@isTest
public with sharing class TestNLSGetChildLoanBatch {
    @testSetup
    static void setup(){        
        // Creating floating rate index
            //Creating Reciprocal Role
        clcommon__Reciprocal_Role__c clRoleObj = ApplicationOriginationTestHelper.createReciprocalRole(PortalConstants.CERTIFIED_LENDER);
        Database.insert(clRoleObj, true);

        //Creating Cl Product
        clcommon__CL_Product__c clProductObj = ApplicationOriginationTestHelper.createCLProductForApplication();
        Database.insert(clProductObj, true);

        // Creating CL Purpose of Application
        clcommon__CL_Purpose__c clPurposeObj = ApplicationOriginationTestHelper.createCLPurposeForApplication();
        Database.insert(clPurposeObj, true);

        //Create different legal entity types
        Map<String, clcommon__Legal_Entity__c> legalEntityMap = createLegalEntities();

        //Creating Floating Rate Index
        clcommon__Floating_Rate_Index__c floatingRateIndex = ApplicationOriginationTestHelper.createFloatingRateIndex(new Map<String, Object> { 'Name' => 'CFA_Advantage_Rate',
                                                                                                                                                'Base Rate Name' => '7-FIELD FINANCE',
                                                                                                                                                'Base Rate Adjuster' => 5.5,
                                                                                                                                                'Current Floating Rate' => 12});
        Database.insert(floatingRateIndex, true);

        //Creating Partner Program
        CFA_Partner_Program__c partnerProgram = ApplicationOriginationTestHelper.createPartnerProgram(floatingRateIndex);
        Database.insert(partnerProgram, true);

        //create business informations
        Map<String, genesis__Business_Information__c> businessInfoObjMap = createBusinessInformations();

        Map<String, Account> accountsMap = createAccounts(new Map<String, Object> { 'businessInfoObjMap' => businessInfoObjMap,
                                                                                    'legalEntityMap' => legalEntityMap,
                                                                                     'partnerProgramId' => partnerProgram.Id
                                                                                     });

        //Creating Contact
        Contact cfaDealerContactObj = ApplicationOriginationTestHelper.createDealerContact(accountsMap.get('cfaDealerAccountObj').Id);
        Contact cfaClContactObj = ApplicationOriginationTestHelper.createCLContact(accountsMap.get('cfaClAccountObj').Id);
        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(accountsMap.get('borrowerAccountObj').Id);
        borrowerContactObj.genesis__SSN__c = '999111222';        
        borrowerContactObj.Confirm_SSN__c = '999111222';    
        Database.insert(new List<Contact>{cfaDealerContactObj, cfaClContactObj, borrowerContactObj}, true);

        //Creating Cl Dealer Relationship
        clcommon__Relationship__c cfaDealerClRelationObj = ApplicationOriginationTestHelper.createCLDealerRelationship(clRoleObj,
                                                                accountsMap.get('cfaDealerAccountObj').Id,
                                                                accountsMap.get('cfaClAccountObj').Id);
        Database.insert(new List<clcommon__Relationship__c>{cfaDealerClRelationObj}, true);

        //Create Rate Card Setup Header
        genesis__Rate_Card_Setup_Header__c cfaRateCardHeaderObj = ApplicationOriginationTestHelper.createRateCardSetupHeader(accountsMap.get('cfaDealerAccountObj'));
        cfaRateCardHeaderObj.Crop_Year__c = '2025';
        cfaRateCardHeaderObj.Field_Finance_Rate__c = 12;
        cfaRateCardHeaderObj.CFA_Advantage_Rate__c = 12;
        cfaRateCardHeaderObj.genesis__End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        cfaRateCardHeaderObj.Base_Rate__c = floatingRateIndex.id;
        Database.insert(new List<genesis__Rate_Card_Setup_Header__c> {cfaRateCardHeaderObj});

        //Create Rate Card Setup Details
        List<genesis__Rate_Card_Setup_Detail__c> cfaRateCardDetailObjList = ApplicationOriginationTestHelper.createRateCardDetailsForGrayLabel(cfaRateCardHeaderObj.Id);
        Database.insert(cfaRateCardDetailObjList, true);

        //Create credit rating matrix
        genesis__Credit_Rating_Matrix__c rating = new genesis__Credit_Rating_Matrix__c(Name='Tier 1');
        Database.insert(rating, true);

        //create applications
        genesis__Applications__c cfaApplicationObj = ApplicationOriginationTestHelper.createCurrCropYearApplication(new Map<String,Id>{
            'dealerAccountId' => accountsMap.get('cfaDealerAccountObj').Id,
            'clProductId' => clProductObj.Id,
            'clPurposeId' => clPurposeObj.Id,
            'borrowerAccountId' => accountsMap.get('borrowerAccountObj').Id,
            'borrowerContactId' => borrowerContactObj.Id,
            'certifiedLender' =>  accountsMap.get('cfaClAccountObj').Id
        });
        cfaApplicationObj.genesis__Status__c = PortalConstants.PENDING_APPROVAL_APPLICATION_STATUS;
        cfaApplicationObj.genesis__Maturity_Date__c = cfaRateCardHeaderObj.genesis__End_Date__c;
        cfaApplicationObj.My_Program__c = cfaRateCardHeaderObj.Id;
        cfaApplicationObj.Crop_Year__c = cfaRateCardHeaderObj.Crop_Year__c;
        cfaApplicationObj.Guarantee__c = 30;
        cfaApplicationObj.Statement_Code__c = 'COMMITMENT STATEMENT';  
        cfaApplicationObj.genesis__Credit_Rating__c = rating.Id;  

        Database.insert(new List<genesis__Applications__c>{cfaApplicationObj}, true);   
        
        //Create Party Types
        Map<String, clcommon__Party_Type__c> partyTypeMap = ApplicationOriginationTestHelper.createMultiplePartyType();
        List<clcommon__Party_Type__c> partyTypeList = new List<clcommon__Party_Type__c>{
            partyTypeMap.get(PortalConstants.BORROWER_PARTY_NAME),
            partyTypeMap.get(PortalConstants.PRINCIPAL_PARTY_NAME),
            partyTypeMap.get(PortalConstants.CL_PARTY_NAME),
            partyTypeMap.get(PortalConstants.DEALER_PARTY_NAME)
        };
        Database.insert(partyTypeList, true);

        Dealer_Applicant_Relationship__c dealerApplicantRel = ApplicationOriginationTestHelper.createDealerApplicantRelationship(borrowerContactObj,accountsMap.get('cfaDealerAccountObj').Id);
        Database.insert(dealerApplicantRel,true);
        //Create parties for the applications
        createParties(new Map<String, Map<String, Id>> {
            'paramForCfaCLPartyMap' => new Map<String,Id>{
                                            'accountId' => accountsMap.get('cfaClAccountObj').Id,
                                            'contactId' => cfaClContactObj.Id,
                                            'partyTypeId' => partyTypeMap.get(PortalConstants.CL_PARTY_NAME).Id,
                                            'applicationId' => cfaApplicationObj.Id
                                        },
            'cfaBorrowerPartyMap' => new Map<String,Id>{
                                            'accountId' => accountsMap.get('borrowerAccountObj').Id,
                                            'contactId' => borrowerContactObj.Id,
                                            'partyTypeId' => partyTypeMap.get(PortalConstants.BORROWER_PARTY_NAME).Id,
                                            'applicationId' => cfaApplicationObj.Id,
                                            'dealerApplicantRelationshipId' => dealerApplicantRel.id
                                        }
                                    
        }, accountsMap.get('borrowerAccountObj'));

        List<genesis__Application_Pricing_Detail__c> cfaApplicationPricings = ApplicationOriginationTestHelper.createPricingDetailsForApplication(cfaApplicationObj);
        Integer loanId = 176605;
        for(genesis__Application_Pricing_Detail__c pricing : cfaApplicationPricings){
            loanId +=1;
            pricing.Loan_Id__c = String.valueOf(loanId);
        }
        Database.insert(cfaApplicationPricings, true);

        createIntegrationFrameworkForGetChildLoan();
        
    }

    /**
     * @description 
     */
    private static void createIntegrationFrameworkForGetChildLoan(){
         //Setting up the Integration Framework to fetch the Child loan details
            
        intframework__Integration_Family__c family = IntegrationTestInitHelper.getFamily('NLS Integration');
        intframework__Integration_API_Type__c getChildLoanAPIType = IntegrationTestInitHelper.getIntegrationAPIType(
            family.Id, 'Get Child Loan Integration API Type');
        intframework__Integration_Provider__c getChildLoanProvider = IntegrationTestInitHelper.getIntegrationProvider(
            family.Id, 'Get Loan');
        intframework__Integration_Configuration__c getLoanDetailsConfig = IntegrationTestInitHelper.getIntegrationConfiguration(
            getChildLoanProvider.Id,'NLS Get Loan Integration Configuration','NLS');
        intframework__Integration_API_Configuration__c getChildLoanApiConfig = IntegrationTestInitHelper.getIntegrationAPIConfiguration(
            family.Id,
            getChildLoanAPIType.Id,
            getChildLoanProvider.Id,
            getLoanDetailsConfig.Id,
            false,
            'NLSGetChildLoanAdapter',
            'GET',
            'NLS',
            'loans/loanId',
            '{ "thirdPartySystem": {  "name": "Get Child Loan",  "filters": [   {    "objectAPI": "genesis__Application_Pricing_Detail__c",    "objectAlias": "Pricing Details",    "fields": [     {      "externalField": "ID",      "fieldAPI": "Id"     },     {      "externalField": "loanId",      "fieldAPI": "Loan_Id__c"     }    ],    "whereClause": "Id IN :applicationIdList"   }  ] }}',
            'application/json',
            1);


        intframework__Integration_API_Type__c getPayoffDetailsAPIType = IntegrationTestInitHelper.getIntegrationAPIType(
            family.Id, 'Get Child Payoff Details Integration API Type');
        intframework__Integration_Provider__c getPayoffDetailsProvider = IntegrationTestInitHelper.getIntegrationProvider(
            family.Id, 'Payoff Details');
        intframework__Integration_Configuration__c getPayoffDetailsConfig = IntegrationTestInitHelper.getIntegrationConfiguration(
            getPayoffDetailsProvider.Id,'NLS Payoff Details Integration Configuration','NLS');
        intframework__Integration_API_Configuration__c getPayoffDetailsApiConfig = IntegrationTestInitHelper.getIntegrationAPIConfiguration(
            family.Id,
            getPayoffDetailsAPIType.Id,
            getPayoffDetailsProvider.Id,
            getPayoffDetailsConfig.Id,
            false,
            'NLSChildPayoffDetailsAdapter',
            'GET',
            'NLS',
            'loans/loanId/payoff-details?payoffDate=',
            '{ "thirdPartySystem": {  "name": "Payoff Details",  "filters": [   {    "objectAPI": "genesis__Application_Pricing_Detail__c",    "objectAlias": "Pricing Details",    "fields": [     {      "externalField": "ID",      "fieldAPI": "Id"     },     {      "externalField": "loanId",      "fieldAPI": "Loan_Id__c"     }    ],    "whereClause": "Id IN :applicationIdList"   }  ] }}',
            'application/json',
            1);

        //Setting up the Integration Framework to fetch the Payoff Via Mail Rates
        intframework__Integration_API_Type__c getPayoffViaMailAPIType = IntegrationTestInitHelper.getIntegrationAPIType(family.Id, 
                                                                                                                    'NLS Get Child Loan Payoff Mail API Type');
        // //Int Family family
        //Int Provider getChildPayoffDetailsProvider
        //Int Config getChildPayoffDetailsConfig
        intframework__Integration_API_Configuration__c getPayoffViaMailApiConfig = IntegrationTestInitHelper.getIntegrationAPIConfiguration(
            family.Id,
            getPayoffViaMailAPIType.Id,
            getPayoffDetailsProvider.Id,
            getPayoffDetailsConfig.Id,
            false,
            'NLSGetChildLoanPayoffViaMailAdapter',
            'GET',
            'NLS',
            'loans/loanId/payoff-details?payoffDate=',
            '{ "thirdPartySystem": {  "name": "Payoff Details",  "filters": [   {    "objectAPI": "genesis__Application_Pricing_Detail__c",    "objectAlias": "Pricing Details",    "fields": [     {      "externalField": "ID",      "fieldAPI": "Id"     },     {      "externalField": "loanId",      "fieldAPI": "Loan_Id__c"     }    ],    "whereClause": "Id IN :applicationIdList"   }  ] }}',
            'application/json',
            1);

        intframework__Integration_API_Type__c getParticipantRateAPIType = IntegrationTestInitHelper.getIntegrationAPIType(family.Id, 
                                                                                                                'Participants Get Loan Integration API Type');
        //Int Family family
        //Int Provider getChildPayoffDetailsProvider
        //Int Config getChildPayoffDetailsConfig
        intframework__Integration_API_Configuration__c getParticipantAPIConfig = IntegrationTestInitHelper.getIntegrationAPIConfiguration(
            family.Id,
            getParticipantRateAPIType.Id,
            getChildLoanProvider.Id,
            getLoanDetailsConfig.Id,
            false,
            'NLSParticipantsGetLoanAdapter',
            'GET',
            'NLS',
            'loans/loanId/participants',
            '{"thirdPartySystem":{"name":"p","filters":[{"objectAPI":"genesis__Application_Pricing_Detail__c","objectAlias":"pricing","fields":[{"externalField":"Id","fieldAPI":"Id"},{"externalField":"loanId","fieldAPI":"Loan_Id__c"}],"whereClause":"Id IN :pricingId"}]}}',
            'application/json',
            1);

            Database.upsert(new List<intframework__Integration_API_Configuration__c> {getChildLoanApiConfig,getParticipantAPIConfig,getPayoffViaMailApiConfig,getPayoffDetailsApiConfig},true);
    }
    
    /**
    * @description Create legal entities
    * @author Kabir Pramanik | 12-23-2024 
    * @return Map<String, clcommon__Legal_Entity__c> 
    **/
    private static Map<String, clcommon__Legal_Entity__c> createLegalEntities(){
        Map<String, clcommon__Legal_Entity__c> legalEntityMap = ApplicationOriginationTestHelper.createMultipleLegalEntity();
        List<clcommon__Legal_Entity__c> legalEntityList = new List<clcommon__Legal_Entity__c>{
            legalEntityMap.get(ExternalConstants.INDIVIDUAL_ENTITY),
            legalEntityMap.get(ExternalConstants.SOLE_PROP_ENTITY),
            legalEntityMap.get(ExternalConstants.CORPORATION)
        };
        Database.Insert(legalEntityList, true);
        return legalEntityMap;
    }

   /**
    * @description create parties for the applications
    * @param partyMap 
    * @param borrowerAccount 
    */
    private static void createParties(Map<String, Map<String, Id>> partyMap, Account borrowerAccount){
        clcommon__Party__c borrowerParty = ApplicationOriginationTestHelper.createApplicantParty(partyMap.get('cfaBorrowerPartyMap'),borrowerAccount);
        borrowerParty.Dealer_Applicant_Relationship__C = partyMap.get('cfaBorrowerPartyMap').get('dealerApplicantRelationshipId');
        
        List<clcommon__Party__c> partyObjList = new List<clcommon__Party__c> {
            ApplicationOriginationTestHelper.createParty(partyMap.get('paramForCfaCLPartyMap')),
            borrowerParty
        };
        Database.insert(partyObjList,true);
    }

    /**
    * @description create business informations
    * @author Kabir Pramanik | 12-24-2024 
    * @return Map<String, genesis__Business_Information__c> 
    **/
    private static Map<String, genesis__Business_Information__c> createBusinessInformations(){
        Map<String, genesis__Business_Information__c> businessInfoObjMap = new Map<String, genesis__Business_Information__c> {
            'cfaDealerBusinessInfoObj' => ApplicationOriginationTestHelper.createBusinessInfoForDealer(),
            'clBusinessinformationObj' => ApplicationOriginationTestHelper.createBusinessInfoForDealer(),
            'borrowerBusinessInfoObj' => ApplicationOriginationTestHelper.createBusinessInfoForBorrower('122334556')
        };
        Database.insert(new List<genesis__Business_Information__c>{ businessInfoObjMap.get('cfaDealerBusinessInfoObj'), 
                                                                    businessInfoObjMap.get('clBusinessinformationObj'), 
                                                                    businessInfoObjMap.get('borrowerBusinessInfoObj')
                                                                    }, true);
        return businessInfoObjMap;
    }
   
    /**
    * @description create Accounts
    * @author Kabir Pramanik | 12-24-2024 
    * @param paramMap 
    * @return Map<String, Account> 
    **/
    private static Map<String, Account> createAccounts(Map<String,Object> paramMap){
        
        Map<String, genesis__Business_Information__c> businessInfoObjMap = (Map<String, genesis__Business_Information__c>)paramMap.get('businessInfoObjMap');
        Map<String, clcommon__Legal_Entity__c> legalEntityMap = (Map<String, clcommon__Legal_Entity__c>)paramMap.get('legalEntityMap');
        Id partnerProgramId = (Id)paramMap.get('partnerProgramId');
        Account cfaDealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(businessInfoObjMap.get('cfaDealerBusinessInfoObj').Id, partnerProgramId);
        cfaDealerAccountObj.CIF_Number__c = '897685';
        Database.insert(new List<Account>{cfaDealerAccountObj}, true);

        Account cfaClAccountObj = ApplicationOriginationTestHelper.createCLAccount(businessInfoObjMap.get('clBusinessinformationObj').Id, cfaDealerAccountObj.Id);
        Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(legalEntityMap.get(ExternalConstants.SOLE_PROP_ENTITY), (Id) businessInfoObjMap.get('borrowerBusinessInfoObj').Id);
        borrowerAccountObj.CIF_Number__c = '332211';
        borrowerAccountObj.Name = 'Green Goblin';
        Database.insert(new List<Account>{cfaClAccountObj, borrowerAccountObj}, true);
        return new Map<String, Account> {   'cfaDealerAccountObj' => cfaDealerAccountObj,
                                            'cfaClAccountObj' => cfaClAccountObj,
                                            'borrowerAccountObj' => borrowerAccountObj
                                        };
    }

/**
 * @description       : Setting up the Mock Response of SUCCESS status for NLSGetChildLoanCalloutBatch, NLSClosedChildLoanCalloutBatch
 * @author            : Suraj kumar
 * @last modified on  : 01-27-2025
 * @last modified by  : Ayush Kumar Singh
**/
    public class NLSGetChildLoanHttpCalloutMock implements HttpCalloutMock {
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
                response.setBody('{"status":{"code":200,"message":"Success"},'+
                                '"payload":{"data":{"Acctrefno":176605,"Loan_Type":3,"Portfolio_Code_Id":0,'+
                                '"Loan_Group_No":4,"Master_Acctrefno":0,"Pool_Acctrefno":0,"Restructured_Acctrefno":0,'+
                                '"Shadow_Loan_Exists":false,"Cifno":39368,"Loan_Class1_No":68,"Name":"BOOKINGTOCORELLC",'+
                                '"Loan_Class2_No":0,"Shortname":"BOOKINGTOCORELLC","Risk_Rating_No":3,"Loan_Number":"343066028",'+
                                '"Tin":"21-3129381","Entity":"LIMITED LIABILITY COMPANY","Input_Date":"2022-05-16T00:00:00","Loan_Officer_No":0,'+
                                '"Open_Date":"2022-05-16T00:00:00","Collection_Officer_No":0,"Curr_Date":"2022-05-16T00:00:00","Open_Maturity_Date":"2023-05-15T00:00:00",'+
                                '"Curr_Maturity_Date":"2023-05-15T00:00:00","Payoff_Date":null,"Last_Activity_Date":null,"Processing_Start_Date":"2022-05-16T00:00:00",'+
                                '"Interest_Paid_Thru_Date":"2022-05-15T00:00:00","Principal_Paid_Thru_Date":"2022-05-15T00:00:00","Interest_Accrued_Thru_Date":"2022-05-15T00:00:00",'+
                                '"Original_Note_Amount":0.00,"Current_Note_Amount":0.00,"Current_Principal_Balance":0.00,"Current_Interest_Balance":0.0000000000,'+
                                '"Current_Fees_Balance":0.00000,"Current_Def_Interest_Balance":0.0000000000,"Current_Late_Charge_Balance":0.00,'+
                                '"Current_Payoff_Balance":0.0000000000,"Current_Udf1_Balance":0.00000,"Current_Perdiem":0.0000000000,'+
                                '"Current_Suspense":0.00,"Current_Udf2_Balance":0.00000,"Current_Interest_Rate":0.00000000,"Current_Udf3_Balance":0.00000,'+
                                '"Total_Past_Due_Balance":3.00,"Current_Udf4_Balance":0.00000,"Total_Current_Due_Balance":0.00,"Current_Udf5_Balance":0.00000,'+
                                '"Current_Udf6_Balance":0.00000,"Starting_Interest_Rate":0.00000000,"Times_Renewed":0,"Current_Def_Perdiem":0.0000000000,'+
                                '"Current_Impound_Balance":0.00,"Current_Ol1_Balance":0.00000,"Current_Udf7_Balance":0.00000,"Current_Ol2_Balance":0.00000,'+
                                '"Starting_Year_Interest_Rate":0.00000000,"Current_Ol3_Balance":0.00000,"Current_Udf8_Balance":0.00000,"Last_Rate_Change_Date":null,'+
                                '"Current_Udf9_Balance":0.00000,"Times_Extended":0,"Current_Udf10_Balance":0.00000,"Next_Rate_Change_Date":null,'+
                                '"Next_Interest_Step_Date":null,"Default_Interest_Indicator":0,"Addonint_Total":0.0000000000,"Addonint_Remaining":0.0000000000,'+
                                '"Starting_Year_Def_Int_Rate":0.00000000,"Starting_Def_Interest_Rate":0.00000000,"Next_Rate_Change_Notice_Date":null,'+
                                '"Compound_Interest_Balance":0.0000000000,"Current_Def_Interest_Rate":0.00000000,"Next_Accrual_Cutoff":"2022-06-15T00:00:00",'+
                                '"Last_Def_Rate_Change_Date":null,"Next_Def_Rate_Change_Date":null,"Next_Billing_Date":"2022-06-01T00:00:00",'+
                                '"Next_Recurring_Trans_Date":null,"Next_Def_Interest_Step_Date":null,"Next_Statement1_Date":"2022-05-31T00:00:00",'+
                                '"Next_Def_Rate_Change_Notice":null,"Days_In_Current_Period":31,"Default_Def_Interest_Indicator":0,"Next_Statement2_Date":null,'+
                                '"Next_Amort_Fees_Date":null,"Amortized_Fees_Eim_Flag":false,"Days_Past_Due":0,"Compound_Def_Interest_Balance":0.0000000000,'+
                                '"Compound_Interest_Indicator":0,"Compound_Def_Int_Indicator":0,"Current_Servicing_Balance":0.00,"Current_Reserve_Balance":0.00,'+
                                '"Dealer_Cifno":null,"SAC_Expiration_Date":null,"SAC_Ineligible_Date":null,"Closed_Date":null,"Input_Gl_Date":"2022-05-16T00:00:00",'+
                                '"CurrencyID":0,"Intro_Interest_Expiration":null,"Intro_Def_Interest_Expiration":null,"Tin_Hash":"q6z8gyeRoMvE1V24218xCwvPkodCnO7cUr0QRo7ZZh8=",'+
                                '"Current_Adb_Interest_Balance":0.0000000000,"Branch_Cifno":null,"Statement1_Billing_End_Date":"2022-05-15T00:00:00",'+
                                '"Statement2_Billing_End_Date":null,"Current_TierRateNo":0,"Current_Def_TierRateNo":0,"Non_Accrual_Start_Date":null,'+
                                '"Charge_Off_Start_Date":null,"Status_Code_No":0,"Last_Billing_Date":"2022-05-15T00:00:00","LCGUID":null,"LCGUIDDate":null,'+
                                '"Funded_Date":null,"Borrower_Loan_Nickname":null,"ContractualJurisdiction":""}}}');
            }
            return response;
        }
    }
/**
 * @description       : Setting up the Mock Response of SUCCESS status for NLSChildPayoffDetailsCalloutBatch, NLSGetChildLoanPayoffViaMailBatch, NLSClosedChildPayoffCalloutBatch
 * @author            : Suraj kumar
 * @last modified on  : 01-27-2025
 * @last modified by  : Ayush Kumar Singh
**/
    public class NLSGetChildPayOffHttpCalloutMock implements HttpCalloutMock {
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
                response.setBody('{"status":{"code":200,"message":"Success"},'+
                '"payload":{"data":{"LoanNumber":"343066041-A","ShortName":"BOOKINGTOCORELLC",'+
                    '"LoanGroup":"INPUT","InterestPaidThrough":"05/18/2022","PrincipalPaidThrough":"05/18/2022",'+
                    '"LoanDate":"05/19/2022","FeesDue":0.0,"LateCharges":0.0,"MaturityDate":"05/15/2023","PayoffDate":"06/10/2022",'+
                    '"InterestRate":7.0,"PerDiem":0.8166666667,"PrincipalBalance":4200.0,"AccruedInterest":15.51,"PayoffAmount":4215.51,'+
                    '"Suspense":0.0,"ServicingFee":0.0,"UserDefinedLoanBalances":{"UserDefinedLoanBalance1":0.0,"UserDefinedLoanBalance2":0.0,'+
                        '"UserDefinedLoanBalance3":0.0,"UserDefinedLoanBalance4":0.0,"UserDefinedLoanBalance5":0.0,"UserDefinedLoanBalance6":0.0,'+
                        '"UserDefinedLoanBalance7":0.0,"UserDefinedLoanBalance8":0.0,"UserDefinedLoanBalance9":0.0,"UserDefinedLoanBalance10":0.0}}}}');
            }
            return response;
        }
    }

    /**
 * @description       : Setting up the Mock Response of SUCCESS status for NLSChildPayoffDetailsCalloutBatch, NLSGetChildLoanPayoffViaMailBatch, NLSClosedChildPayoffCalloutBatch
 * @author            : Suraj kumar
 * @last modified on  : 01-27-2025
 * @last modified by  : Ayush Kumar Singh
**/
public class NLSGetChildPayOffDetailViaMobileHttpCalloutMock implements HttpCalloutMock {
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
            response.setBody('{"status": {"code": 200,"message": "Success","executionTime": 854},'+
            '"payload": {"data": {"LoanNumber": "1001282002","ShortName": "MCCHAD, CHRIS",'+
            '"LoanGroup": "PARTICIPATION","InterestPaidThrough": "11/21/2023","PrincipalPaidThrough": "11/21/2023",'+
            '"LoanDate": "11/22/2023","FeesDue": 0.0,"LateCharges": 0.0,"MaturityDate": "12/15/2024","PayoffDate": "02/08/2024",'+
            '"InterestRate": 16.0,"PerDiem": 0.0401555556,"PrincipalBalance": 90.35,"AccruedInterest": 2.57,"PayoffAmount": 92.92,"Suspense": 0.0,"ServicingFee": 0.0,'+
            '"UserDefinedLoanBalances": {"UserDefinedLoanBalance1": 0.0,"UserDefinedLoanBalance2": 0.0,"UserDefinedLoanBalance3": 0.0,"UserDefinedLoanBalance4": 0.0,"UserDefinedLoanBalance5": 0.0,'+
            '"UserDefinedLoanBalance6": 0.0,"UserDefinedLoanBalance7": 0.0,"UserDefinedLoanBalance8": 0.0,"UserDefinedLoanBalance9": 0.0,"UserDefinedLoanBalance10": 0.0}}}}');
        }
        return response;
    }
}


    //Setting up the Mock Response for the Participants Callout - Dealer Rates::
    /**
 * @description       : Setting up the Mock Response of SUCCESS status for NLSParticipantsGetChildLoanCalloutBatch
 * @author            : Suraj kumar
 * @last modified on  : 01-27-2025
 * @last modified by  : Ayush Kumar Singh
**/
    public class NLSGetParticipantsHttpCalloutMock implements HttpCalloutMock {
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
                response.setBody('{"status":{"code":200,"message":"string"},'+
                '"payload":'+
                    '{"totalCount":0,"count":0,"data":'+
                        '[{"Participantrefno":0,"Loan_Group_No":0,"Participant_Type":1,"Participant_Number":"string",'+
                        '"Cifno":0,"Shortname":"string","Name":"string","Input_Date":"2022-09-27T05:16:32.067Z","Status_Code_No":0,'+
                        '"Last_Activity_Date":"2022-09-27T05:16:32.067Z","Original_Note_Amount":0,"Current_Note_Amount":0,'+
                        '"Current_Principal_Balance":0,"Current_Interest_Balance":5,"Current_Def_Interest_Balance":0,'+
                        '"Current_Late_Charge_Balance":0,"Current_Payoff_Balance":0,"Current_Perdiem":1,"Current_Suspense":0,'+
                        '"Current_Interest_Rate":0,"Compound_Interest_Balance":0,"Current_Impound_Balance":0,"Current_Servicing_Balance":0,'+
                        '"Vendor_Id":0,"Next_Recurring_Trans_Date":"2022-09-27T05:16:32.067Z","Current_Reserve_Balance":0,'+
                        '"Addonint_Remaining":0,"Addonint_Total":0,"Current_TierRateNo":0}]}}');
            }
            return response;
        }
    }

    /**
    * @description : Get the logs for NLSGetChildLoanAdapter
    * @return  `List<clcommon__Log__c>`
    */
    private static List<clcommon__Log__c> getExceptionLog(){
        List<clcommon__Log__c> exceptionLogsList = [SELECT Id, clcommon__Message__c 
                                                    FROM clcommon__Log__c 
                                                    WHERE Name IN ('NLSGetChildLoanAdapter')];
        if(exceptionLogsList.isEmpty()){
            return new List<clcommon__Log__c>();
        }
        return exceptionLogsList;
   }


    @isTest
    private static void testGetChildLoanSchedule(){
        List<User> userObj = ApplicationOriginationTestHelper.getAdminUser();
        List<genesis__Credit_Rating_Matrix__c> tierOneMatrix = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 1');
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = tierOneMatrix[0].Id;
        applicationObj.Signing_Method__c = PortalConstants.IN_PERSON_DOCUSIGN;
        applicationObj.Agreement_Sign__c = true;
        applicationObj.genesis__Status__c = 'ACTIVE';
        Database.update(applicationObj, true); 

        System.runAs(userObj[0]){
            Test.setMock(HttpCalloutMock.class, new NLSGetChildPayOffHttpCalloutMock());
            Test.startTest();
            NLSGetChildLoanDetailsSchedule childLoanDetails = new NLSGetChildLoanDetailsSchedule();
            String cronExpression = '0 0 23 * * ?';
            String jobId = System.schedule('Test Get Child Loan', cronExpression, childLoanDetails);
            System.assertEquals(true, jobId != null,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    @isTest
    private static void testGetChildLoanForIndividual() {
        List<User> userObj = ApplicationOriginationTestHelper.getAdminUser();
       
        List<genesis__Credit_Rating_Matrix__c> tierOneMatrix = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 1');
 
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = tierOneMatrix[0].Id;
        applicationObj.Signing_Method__c = PortalConstants.IN_PERSON_DOCUSIGN;
        applicationObj.Agreement_Sign__c = true;
        applicationObj.genesis__Status__c = 'ACTIVE';
        Database.update(applicationObj, true); 

        System.runAs(userObj[0]){
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new NLSGetChildLoanHttpCalloutMock());
                NLSGetChildLoanCalloutBatch getChildPayOff = new NLSGetChildLoanCalloutBatch();
                Database.executeBatch(getChildPayOff , 200);
            Test.stopTest();
            List<clcommon__Log__c> exceptionLogsList = getExceptionLog();
            System.assertEquals(true, exceptionLogsList.size()==0,PortalConstants.ASSERTION_FAILED);
            
        }
    }
 
    @isTest
    private static void testGetChildLoanForCorporation() {
         List<User> userObj = ApplicationOriginationTestHelper.getAdminUser();
         
         List<genesis__Credit_Rating_Matrix__c> tierOneMatrix = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 1');
 
         genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
         applicationObj.genesis__Credit_Rating__c = tierOneMatrix[0].Id;
         applicationObj.Signing_Method__c = PortalConstants.IN_PERSON_DOCUSIGN;
         applicationObj.Agreement_Sign__c = true;
         applicationObj.genesis__Status__c = 'ACTIVE';
         Database.update(applicationObj, true); 
 
         List<clcommon__Legal_Entity__c> corpLegalEntityList  = [SELECT Id 
                                                                         FROM clcommon__Legal_Entity__c 
                                                                         WHERE clcommon__Legal_Entity_Type__c = :PortalConstants.CORPORATION];
 
         List<Account> borrowerAccountList = [SELECT Id, 
                                                     clcommon__Legal_Entity_Type__c 
                                                 FROM Account 
                                                 WHERE id = :applicationObj.genesis__Account__c];
         borrowerAccountList[0].clcommon__Legal_Entity_Type__c = corpLegalEntityList[0].id;
         Database.update(borrowerAccountList, true);
 
         System.runAs(userObj[0]){
             Test.startTest();
                Test.setMock(HttpCalloutMock.class, new NLSGetChildLoanHttpCalloutMock());
                NLSGetChildLoanCalloutBatch getChildPayOff = new NLSGetChildLoanCalloutBatch();
                Database.executeBatch(getChildPayOff , 200);
            Test.stopTest();
            List<clcommon__Log__c> exceptionLogsList = getExceptionLog();
            System.assertEquals(true, exceptionLogsList.size()==0,PortalConstants.ASSERTION_FAILED);
            
        }
    }
 
    @isTest
    private static void testGetChildLoanForDBA() {
         List<User> userObj = ApplicationOriginationTestHelper.getAdminUser();
         
         List<genesis__Credit_Rating_Matrix__c> tierOneMatrix = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 1');
 
         genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
         applicationObj.genesis__Credit_Rating__c = tierOneMatrix[0].Id;
         applicationObj.Signing_Method__c = PortalConstants.IN_PERSON_DOCUSIGN;
         applicationObj.Agreement_Sign__c = true;
         applicationObj.genesis__Status__c = 'ACTIVE';
         Database.update(applicationObj, true); 
 
         List<clcommon__Legal_Entity__c> dbaLegalEntityList  = [SELECT Id 
                                                                         FROM clcommon__Legal_Entity__c 
                                                                         WHERE clcommon__Legal_Entity_Type__c = :PortalConstants.INDIVIDUAL_ENTITY];
 
         List<Account> borrowerAccountList = [SELECT Id, 
                                                     clcommon__Legal_Entity_Type__c 
                                                 FROM Account 
                                                 WHERE id = :applicationObj.genesis__Account__c];
         borrowerAccountList[0].clcommon__Legal_Entity_Type__c = dbaLegalEntityList[0].id;
         Database.update(borrowerAccountList, true);
 
         System.runAs(userObj[0]){
             Test.startTest();
                Test.setMock(HttpCalloutMock.class, new NLSGetChildLoanHttpCalloutMock());
                NLSGetChildLoanCalloutBatch getChildPayOff = new NLSGetChildLoanCalloutBatch();
                Database.executeBatch(getChildPayOff , 200);
             Test.stopTest();
             List<clcommon__Log__c> exceptionLogsList = getExceptionLog();
             System.assertEquals(true, exceptionLogsList.size()==0,PortalConstants.ASSERTION_FAILED);
            
        }
    }

    @isTest
    private static void testClosedChildLoanForIndividual() {
        List<User> userObj = ApplicationOriginationTestHelper.getAdminUser();
       
        List<genesis__Credit_Rating_Matrix__c> tierOneMatrix = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 1');
 
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = tierOneMatrix[0].Id;
        applicationObj.Signing_Method__c = PortalConstants.IN_PERSON_DOCUSIGN;
        applicationObj.Agreement_Sign__c = true;
        applicationObj.genesis__Status__c = 'CLOSED';
        Database.update(applicationObj, true); 

        System.runAs(userObj[0]){
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new NLSGetChildLoanHttpCalloutMock());
                NLSClosedChildLoanCalloutBatch getChildLoanbatch = new NLSClosedChildLoanCalloutBatch();
                Database.executeBatch(getChildLoanbatch , 40);
            Test.stopTest();
            List<clcommon__Log__c> exceptionLogsList = getExceptionLog();
            System.assertEquals(true, exceptionLogsList.size()==0,PortalConstants.ASSERTION_FAILED);
            
        }
    }
    @isTest
    private static void testGetChildLoanForWithoutAccessTokenException() {
        List<User> userObj = ApplicationOriginationTestHelper.getAdminUser();
       
        List<genesis__Credit_Rating_Matrix__c> tierOneMatrix = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 1');
 
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = tierOneMatrix[0].Id;
        applicationObj.Signing_Method__c = PortalConstants.IN_PERSON_DOCUSIGN;
        applicationObj.Agreement_Sign__c = true;
        applicationObj.genesis__Status__c = 'ACTIVE';
        Database.update(applicationObj, true); 

        System.runAs(userObj[0]){
            Test.startTest();
                NLSGetChildLoanCalloutBatch getChildPayOff = new NLSGetChildLoanCalloutBatch();
                Database.executeBatch(getChildPayOff , 200);
            Test.stopTest();
            List<clcommon__Log__c> exceptionLogsList = getExceptionLog();
            System.assertEquals(true, exceptionLogsList.size()==1,PortalConstants.ASSERTION_FAILED);
            
        }
    }

    @isTest
   private static void testGetParticpantsForChildLoanBatch() {
       List<User> userObj = ApplicationOriginationTestHelper.getAdminUser();
      
       List<genesis__Credit_Rating_Matrix__c> tierOneMatrix = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 1');

       genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
       applicationObj.genesis__Credit_Rating__c = tierOneMatrix[0].Id;
       applicationObj.Signing_Method__c = PortalConstants.IN_PERSON_DOCUSIGN;
       applicationObj.Agreement_Sign__c = true;
       applicationObj.genesis__Status__c = 'ACTIVE';
       Database.update(applicationObj, true); 

       System.runAs(userObj[0]){
           Test.startTest();
               Test.setMock(HttpCalloutMock.class, new NLSGetParticipantsHttpCalloutMock());
               NLSParticipantsGetChildLoanCalloutBatch getChildPayOff = new NLSParticipantsGetChildLoanCalloutBatch();
               Database.executeBatch(getChildPayOff , 200);
           Test.stopTest();
           List<genesis__Application_Pricing_Detail__c> pricingList = [SELECT ID,
                                                                            Dealer_Interest_Accrued__c,
                                                                            Dealer_Interest_Per_Diem__c
                                                                        FROM genesis__Application_Pricing_Detail__c
                                                                        WHERE Loan_Id__c =: '176606'];
           System.assertEquals(5, pricingList[0].Dealer_Interest_Accrued__c,PortalConstants.ASSERTION_FAILED);
           System.assertEquals(1, pricingList[0].Dealer_Interest_Per_Diem__c,PortalConstants.ASSERTION_FAILED);
       }
   }

   @isTest
   private static void testChildPayoffDetailsViaMailBatch() {
       List<User> userObj = ApplicationOriginationTestHelper.getAdminUser();
      
       List<genesis__Credit_Rating_Matrix__c> tierOneMatrix = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 1');

       genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
       applicationObj.genesis__Credit_Rating__c = tierOneMatrix[0].Id;
       applicationObj.Signing_Method__c = PortalConstants.IN_PERSON_DOCUSIGN;
       applicationObj.Agreement_Sign__c = true;
       applicationObj.genesis__Status__c = 'ACTIVE';
       Database.update(applicationObj, true); 

       System.runAs(userObj[0]){
           Test.startTest();
               Test.setMock(HttpCalloutMock.class, new NLSGetChildPayOffDetailViaMobileHttpCalloutMock());
               NLSGetChildLoanPayoffViaMailBatch getChildPayOff = new NLSGetChildLoanPayoffViaMailBatch();
               Database.executeBatch(getChildPayOff , 200);
           Test.stopTest();
           List<genesis__Application_Pricing_Detail__c> pricingList = [SELECT ID,
                                                                            Payoff_Amount_via_US_Mail__c
                                                                        FROM genesis__Application_Pricing_Detail__c
                                                                        WHERE Loan_Id__c =: '176606'];
           System.assertEquals(92.92, pricingList[0].Payoff_Amount_via_US_Mail__c,PortalConstants.ASSERTION_FAILED);
       }
   }


    @isTest
    private static void testClosedChildLoanPayoffDetailsBatch() {
        List<User> userObj = ApplicationOriginationTestHelper.getAdminUser();
       
        List<genesis__Credit_Rating_Matrix__c> tierOneMatrix = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 1');
 
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = tierOneMatrix[0].Id;
        applicationObj.Signing_Method__c = PortalConstants.IN_PERSON_DOCUSIGN;
        applicationObj.Agreement_Sign__c = true;
        applicationObj.genesis__Status__c = 'CLOSED';
        Database.update(applicationObj, true); 

        System.runAs(userObj[0]){
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new NLSGetChildPayOffHttpCalloutMock());
                NLSClosedChildPayoffCalloutBatch getChildLoans = new NLSClosedChildPayoffCalloutBatch();
                Database.executeBatch(getChildLoans, 40);
            Test.stopTest();
            List<genesis__Application_Pricing_Detail__c> pricingList = [SELECT ID,
                                                                            Payoff_Amount_via_Mobile__c,
                                                                            Fees__c,
                                                                            Accrued_Interest__c
                                                                        FROM genesis__Application_Pricing_Detail__c
                                                                        WHERE Loan_Id__c =: '176606'];
            System.assertEquals(0.0, pricingList[0].Fees__c,PortalConstants.ASSERTION_FAILED);
            System.assertEquals(4215.51, pricingList[0].Payoff_Amount_via_Mobile__c,PortalConstants.ASSERTION_FAILED);
            System.assertEquals(15.51, pricingList[0].Accrued_Interest__c,PortalConstants.ASSERTION_FAILED);
        }
    }
    @isTest
    private static void testChildPayoffDetailsBatch() {
        List<User> userObj = ApplicationOriginationTestHelper.getAdminUser();
       
        List<genesis__Credit_Rating_Matrix__c> tierOneMatrix = ApplicationOriginationTestHelper.getCreditRatingMatrixForTier('Tier 1');
 
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.getCFAApplication();
        applicationObj.genesis__Credit_Rating__c = tierOneMatrix[0].Id;
        applicationObj.Signing_Method__c = PortalConstants.IN_PERSON_DOCUSIGN;
        applicationObj.Agreement_Sign__c = true;
        applicationObj.genesis__Status__c = 'ACTIVE';
        Database.update(applicationObj, true); 

        System.runAs(userObj[0]){
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new NLSGetChildPayOffHttpCalloutMock());
                NLSChildPayoffDetailsCalloutBatch getChildPayOff = new NLSChildPayoffDetailsCalloutBatch();
                Database.executeBatch(getChildPayOff , 200);
            Test.stopTest();
            List<genesis__Application_Pricing_Detail__c> pricingList = [SELECT ID,
                                                                            Payoff_Amount_via_Mobile__c,
                                                                            Fees__c,
                                                                            Accrued_Interest__c
                                                                        FROM genesis__Application_Pricing_Detail__c
                                                                        WHERE Loan_Id__c =: '176606'];
            System.assertEquals(0.0, pricingList[0].Fees__c,PortalConstants.ASSERTION_FAILED);
            System.assertEquals(4215.51, pricingList[0].Payoff_Amount_via_Mobile__c,PortalConstants.ASSERTION_FAILED);
            System.assertEquals(15.51, pricingList[0].Accrued_Interest__c,PortalConstants.ASSERTION_FAILED);
        }
    }
 
}