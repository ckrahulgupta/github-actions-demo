/**
 * @description       : Test class for NLSBookToCoreCalloutClass and NLSBookToCoreImportAdapter
 * @author            : E. Shalini
 * @group             : 
 * @last modified on  : 01-09-2025
 * @last modified by  : Kabir Pramanik
**/
@IsTest
public without sharing class TestNLSBookToCoreCalloutClass {

    /**
    * @description : Test Setup
    * @author Kabir Pramanik | 12-11-2024 
    **/
    @TestSetup
    static void setup() {
        createIntFrameWorkData(); // for book to core and loan search

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

        //create admin User
        User adminUserObj = ApplicationOriginationTestHelper.createAdminUser('testdealerprodadportfoliomgr@yopmail.com');
        Database.insert(adminUserObj, true);

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
                                                                                     'partnerProgramId' => partnerProgram.Id,
                                                                                     'adminUserId' => adminUserObj.Id});

        //Creating Contact
        Contact cfaDealerContactObj = ApplicationOriginationTestHelper.createDealerContact(accountsMap.get('cfaDealerAccountObj').Id);
        Contact cfaClContactObj = ApplicationOriginationTestHelper.createCLContact(accountsMap.get('cfaClAccountObj').Id);
        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(accountsMap.get('borrowerAccountObj').Id);
        Contact gmkClContactObj = ApplicationOriginationTestHelper.createCLContact(accountsMap.get('gmkClAccountObj').Id);
        borrowerContactObj.genesis__SSN__c = '999111222';        
        borrowerContactObj.Confirm_SSN__c = '999111222';    

        gmkClContactObj.genesis__SSN__c = '937387387';
        gmkClContactObj.Confirm_SSN__c = '937387387';
        Database.insert(new List<Contact>{cfaDealerContactObj, cfaClContactObj, borrowerContactObj, gmkClContactObj}, true);

        //Creating Cl Dealer Relationship
        clcommon__Relationship__c cfaDealerClRelationObj = ApplicationOriginationTestHelper.createCLDealerRelationship(clRoleObj,
                                                                accountsMap.get('cfaDealerAccountObj').Id,
                                                                accountsMap.get('cfaClAccountObj').Id);
        clcommon__Relationship__c gmkDealerClRelationObj = ApplicationOriginationTestHelper.createCLDealerRelationship(clRoleObj,
                                                                accountsMap.get('gmkDealerAccountObj').Id,
                                                                accountsMap.get('gmkClAccountObj').Id);
        Database.insert(new List<clcommon__Relationship__c>{cfaDealerClRelationObj, gmkDealerClRelationObj}, true);

        //Create Rate Card Setup Header
        genesis__Rate_Card_Setup_Header__c cfaRateCardHeaderObj = ApplicationOriginationTestHelper.createRateCardSetupHeader(accountsMap.get('cfaDealerAccountObj'));
        genesis__Rate_Card_Setup_Header__c gmkRateCardHeaderObj = ApplicationOriginationTestHelper.createRateCardSetupHeader(accountsMap.get('gmkDealerAccountObj'));
        cfaRateCardHeaderObj.Crop_Year__c = '2025';
        cfaRateCardHeaderObj.Field_Finance_Rate__c = 12;
        cfaRateCardHeaderObj.CFA_Advantage_Rate__c = 12;
        cfaRateCardHeaderObj.genesis__End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        cfaRateCardHeaderObj.Base_Rate__c = floatingRateIndex.id;
        gmkRateCardHeaderObj.Crop_Year__c = '2025';
        gmkRateCardHeaderObj.FS_Index_Rate__c = 9;
        gmkRateCardHeaderObj.genesis__End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        Database.insert(new List<genesis__Rate_Card_Setup_Header__c> {cfaRateCardHeaderObj, gmkRateCardHeaderObj});

        //Create Rate Card Setup Details
        List<genesis__Rate_Card_Setup_Detail__c> cfaRateCardDetailObjList = ApplicationOriginationTestHelper.createRateCardDetailsForGrayLabel(cfaRateCardHeaderObj.Id);
        List<genesis__Rate_Card_Setup_Detail__c> gmkRateCardDetailObjList = ApplicationOriginationTestHelper.createRateCardDetailsForGrowmark(gmkRateCardHeaderObj.Id);
        Database.insert(cfaRateCardDetailObjList, true);
        Database.insert(gmkRateCardDetailObjList, true);

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
        genesis__Applications__c gmkApplicationObj = ApplicationOriginationTestHelper.createCurrCropYearApplication(new Map<String,Id>{
            'dealerAccountId' => accountsMap.get('gmkDealerAccountObj').Id,
            'clProductId' => clProductObj.Id,
            'clPurposeId' => clPurposeObj.Id,
            'borrowerAccountId' => accountsMap.get('borrowerAccountObj').Id,
            'borrowerContactId' => borrowerContactObj.Id,
            'certifiedLender' =>  accountsMap.get('gmkClAccountObj').Id
        });

        cfaApplicationObj.genesis__Status__c = PortalConstants.PENDING_APPROVAL_APPLICATION_STATUS;
        cfaApplicationObj.genesis__Maturity_Date__c = cfaRateCardHeaderObj.genesis__End_Date__c;
        cfaApplicationObj.My_Program__c = cfaRateCardHeaderObj.Id;
        cfaApplicationObj.Crop_Year__c = cfaRateCardHeaderObj.Crop_Year__c;
        cfaApplicationObj.Guarantee__c = 30;
        cfaApplicationObj.Statement_Code__c = 'COMMITMENT STATEMENT';  
        cfaApplicationObj.genesis__Credit_Rating__c = rating.Id;  
        
        gmkApplicationObj.genesis__Status__c = PortalConstants.PENDING_APPROVAL_APPLICATION_STATUS;
        gmkApplicationObj.genesis__Maturity_Date__c = gmkRateCardHeaderObj.genesis__End_Date__c;
        gmkApplicationObj.My_Program__c = gmkRateCardHeaderObj.Id;
        gmkApplicationObj.Crop_Year__c = gmkRateCardHeaderObj.Crop_Year__c;
        gmkApplicationObj.Guarantee__c = 30;
        gmkApplicationObj.Statement_Code__c = 'COMMITMENT STATEMENT';
        gmkApplicationObj.genesis__Credit_Rating__c = rating.Id;
        Database.insert(new List<genesis__Applications__c>{gmkApplicationObj, cfaApplicationObj}, true);   
        
        //Create Party Types
        Map<String, clcommon__Party_Type__c> partyTypeMap = ApplicationOriginationTestHelper.createMultiplePartyType();
        List<clcommon__Party_Type__c> partyTypeList = new List<clcommon__Party_Type__c>{
            partyTypeMap.get(PortalConstants.BORROWER_PARTY_NAME),
            partyTypeMap.get(PortalConstants.PRINCIPAL_PARTY_NAME),
            partyTypeMap.get(PortalConstants.CL_PARTY_NAME),
            partyTypeMap.get(PortalConstants.DEALER_PARTY_NAME)
        };
        Database.insert(partyTypeList, true);

        //Create parties for the applications
        createParties(new Map<String, Map<String, Id>> {
            'paramForCfaCLPartyMap' => new Map<String,Id>{
                                            'accountId' => accountsMap.get('cfaClAccountObj').Id,
                                            'contactId' => cfaClContactObj.Id,
                                            'partyTypeId' => partyTypeMap.get(PortalConstants.CL_PARTY_NAME).Id,
                                            'applicationId' => cfaApplicationObj.Id
                                        },
            'paramForGmkCLPartyMap' => new Map<String,Id>{
                                            'accountId' => accountsMap.get('gmkClAccountObj').Id,
                                            'contactId' => gmkClContactObj.Id,
                                            'partyTypeId' => partyTypeMap.get(PortalConstants.CL_PARTY_NAME).Id,
                                            'applicationId' => gmkApplicationObj.Id
                                        },
            'cfaBorrowerPartyMap' => new Map<String,Id>{
                                            'accountId' => accountsMap.get('borrowerAccountObj').Id,
                                            'contactId' => borrowerContactObj.Id,
                                            'partyTypeId' => partyTypeMap.get(PortalConstants.BORROWER_PARTY_NAME).Id,
                                            'applicationId' => cfaApplicationObj.Id
                                        },
            'gmkBorrowerPartyMap' => new Map<String,Id>{
                                            'accountId' => accountsMap.get('borrowerAccountObj').Id,
                                            'contactId' => borrowerContactObj.Id,
                                            'partyTypeId' => partyTypeMap.get(PortalConstants.BORROWER_PARTY_NAME).Id,
                                            'applicationId' => gmkApplicationObj.Id
                                        },
            'cfaPrincipalPartyMap' => new Map<String,Id>{
                                            'accountId' => accountsMap.get('borrowerAccountObj').Id,
                                            'contactId' => borrowerContactObj.Id,
                                            'partyTypeId' => partyTypeMap.get(PortalConstants.PRINCIPAL_PARTY_NAME).Id,
                                            'applicationId' => cfaApplicationObj.Id
                                        },
            'gmkPrincipalPartyMap' => new Map<String,Id>{
                                            'accountId' => accountsMap.get('borrowerAccountObj').Id,
                                            'contactId' => borrowerContactObj.Id,
                                            'partyTypeId' => partyTypeMap.get(PortalConstants.PRINCIPAL_PARTY_NAME).Id,
                                            'applicationId' => gmkApplicationObj.Id
                                        }
        });

        List<genesis__Application_Pricing_Detail__c> cfaApplicationPricings = IntegrationTestInitHelper.createSeedDataForPricingDetail(cfaApplicationObj);
        List<genesis__Application_Pricing_Detail__c> gmkApplicationPricings =  IntegrationTestInitHelper.createSeedDataForPricingDetail(gmkApplicationObj);
        Database.insert(cfaApplicationPricings, true);
        Database.insert(gmkApplicationPricings, true);

        //create different users
        createUsers(new Map<String, Id> {'cfaClContactObjId' => cfaClContactObj.Id, 
                                         'gmkClContactObjId' => gmkClContactObj.id });

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
    * @description create users
    * @author Kabir Pramanik | 12-24-2024 
    * @param objIdMap 
    **/
    private static void createUsers(Map<String, Id> objIdMap){
        User cfaAdminUserObj = ApplicationOriginationTestHelper.createAdminUser('cfaadminuser@yopmail.com');
        User cfaClUserObj = ApplicationOriginationTestHelper.createCLUser(objIdMap.get('cfaClContactObjId'));
        cfaClUserObj.UserName = 'marry.lamb@yopmail.com';
        User gmkClUserObj = ApplicationOriginationTestHelper.createCLUser(objIdMap.get('gmkClContactObjId'));
        Database.insert(new List<User> {cfaAdminuserObj, cfaClUserObj, gmkClUserObj}, true);
    }

    /**
    * @description create parties for the applications
    * @author Kabir Pramanik | 12-24-2024 
    * @param partyMap 
    **/
    private static void createParties(Map<String, Map<String, Id>> partyMap){
        List<clcommon__Party__c> partyObjList = new List<clcommon__Party__c> {
            ApplicationOriginationTestHelper.createParty(partyMap.get('paramForCfaCLPartyMap')),
            ApplicationOriginationTestHelper.createParty(partyMap.get('paramForGmkCLPartyMap')),
            ApplicationOriginationTestHelper.createParty(partyMap.get('cfaBorrowerPartyMap')),
            ApplicationOriginationTestHelper.createParty(partyMap.get('gmkBorrowerPartyMap')),
            ApplicationOriginationTestHelper.createParty(partyMap.get('cfaPrincipalPartyMap')),
            ApplicationOriginationTestHelper.createParty(partyMap.get('gmkPrincipalPartyMap'))
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
            'borrowerBusinessInfoObj' => ApplicationOriginationTestHelper.createBusinessInfoForBorrower('122334556'),
            'gmkClBusinessInfoObj' => ApplicationOriginationTestHelper.createBusinessInfoForDealer()
        };
        Database.insert(new List<genesis__Business_Information__c>{ businessInfoObjMap.get('cfaDealerBusinessInfoObj'), 
                                                                    businessInfoObjMap.get('clBusinessinformationObj'), 
                                                                    businessInfoObjMap.get('borrowerBusinessInfoObj'), 
                                                                    businessInfoObjMap.get('gmkClBusinessInfoObj')
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
        Id adminUserId = (Id)paramMap.get('adminUserId');
        Account cfaDealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(businessInfoObjMap.get('cfaDealerBusinessInfoObj').Id, partnerProgramId);
        Account gmkDealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(businessInfoObjMap.get('cfaDealerBusinessInfoObj').Id);
        cfaDealerAccountObj.PortfolioManager__c = adminUserId;
        cfaDealerAccountObj.CIF_Number__c = '897685';
        cfaDealerAccountObj.Production_Ag_Loan_Officer__c = adminUserId;
        gmkDealerAccountObj.Coop_Type__c = 'Growmark';
        gmkDealerAccountObj.PortfolioManager__c = adminUserId;
        gmkDealerAccountObj.Production_Ag_Loan_Officer__c = adminUserId;

        Database.insert(new List<Account>{cfaDealerAccountObj, gmkDealerAccountObj}, true);

        Account cfaClAccountObj = ApplicationOriginationTestHelper.createCLAccount(businessInfoObjMap.get('clBusinessinformationObj').Id, cfaDealerAccountObj.Id);
        Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(legalEntityMap.get(ExternalConstants.SOLE_PROP_ENTITY), (Id) businessInfoObjMap.get('borrowerBusinessInfoObj').Id);
        Account gmkClAccountObj = ApplicationOriginationTestHelper.createCLAccount(businessInfoObjMap.get('gmkClBusinessInfoObj').Id, gmkDealerAccountObj.Id);
        borrowerAccountObj.CIF_Number__c = '332211';
        borrowerAccountObj.Name = 'Green Goblin';
        gmkClAccountObj.Name = 'Jenny Lane';
        Database.insert(new List<Account>{cfaClAccountObj, borrowerAccountObj, gmkClAccountObj}, true);
        return new Map<String, Account> {   'cfaDealerAccountObj' => cfaDealerAccountObj,
                                            'gmkDealerAccountObj' => gmkDealerAccountObj,
                                            'cfaClAccountObj' => cfaClAccountObj,
                                            'borrowerAccountObj' => borrowerAccountObj,
                                            'gmkClAccountObj' => gmkClAccountObj
                                        };
    }

    /**
    * @description : This method is used to update statement code
    * @author  Pritam Roy | 08-12-2024 
    * @param applicationObj 
    * @param coopType 
    **/
    private static void updateStatementCode(genesis__Applications__c applicationObj, String coopType){
        genesis__Applications__c fetchedApplicationObj = [
            SELECT Pricing_Count__c,
                   Statement_Code__c
            FROM genesis__Applications__c
            WHERE Id = :applicationObj.Id
        ];
        String commitmentStetementLabel = String.valueOf(coopType).toUpperCase() + PortalConstants.SPACE_STRING +  'COMMITMENT STATEMENT CODE';
        String monthlyStetementLabel = String.valueOf(coopType).toUpperCase() + PortalConstants.SPACE_STRING + 'MONTHLY STATEMENT CODE';
        String commitStatementCodeObj = (String) [
            SELECT Id, Opt_In_Code__c
            FROM Statement_Code__mdt
            WHERE Label = :commitmentStetementLabel
        ][0].Opt_In_Code__c;

        String monthlyStatementCodeObj = (String) [
            SELECT Id, Opt_In_Code__c
            FROM Statement_Code__mdt
            WHERE Label = :monthlyStetementLabel
        ][0].Opt_In_Code__c;

        if (fetchedApplicationObj.Pricing_Count__c > 1) {
            fetchedApplicationObj.Statement_Code__c = commitStatementCodeObj;
        } else {
            fetchedApplicationObj.Statement_Code__c = monthlyStatementCodeObj;
        }

        Database.update(fetchedApplicationObj, true);
    }

    /**
    * @description : This method is used to create required Integration Framework
    * @author Tuhin Bhunia | 05-07-2024 
    **/
    private static void createIntFrameWorkData(){

        //Inserting Integration Family
        intframework__Integration_Family__c integrationFamily = IntegrationTestInitHelper.getFamilyInst(
            'NLS Integration');
        Database.Insert(integrationFamily, true);
        
        //Inserting Integration API Type
        intframework__Integration_API_Type__c bookToCoreApiType = IntegrationTestInitHelper.getIntegrationAPITypeInst(
            integrationFamily.Id, 'Post Book To Core NLS Integration API Type');

        intframework__Integration_API_Type__c getParentLoanIdAPIType = 
                IntegrationTestInitHelper.getIntegrationAPITypeInst(integrationFamily.Id, ConstantValues.INTEGRATION_API_TYPE_GET_LOANID);

        Database.Insert(new List<intframework__Integration_API_Type__c>{
            bookToCoreApiType,
            getParentLoanIdAPIType
        }, true);

        //Inserting Integration Provider
        intframework__Integration_Provider__c bookToCoreProvider = IntegrationTestInitHelper.getIntegrationProviderInst(
            integrationFamily.Id, 'XML Import');

        intframework__Integration_Provider__c getParentLoanIdProvider = 
                IntegrationTestInitHelper.getIntegrationProviderInst(integrationFamily.Id, 'Search Loans');

        Database.Insert(new List<intframework__Integration_Provider__c>{
            bookToCoreProvider,
            getParentLoanIdProvider
        }, true);

        //Inserting Integration Configurations
        intframework__Integration_Configuration__c bookToCoreConfiguration = IntegrationTestInitHelper.getIntegrationConfigurationInst(
            bookToCoreProvider.Id,'NLS XML Import Integration Configuration','NLS');

        intframework__Integration_Configuration__c getParentLoanIdConfig = 
                IntegrationTestInitHelper.getIntegrationConfigurationInst(getParentLoanIdProvider.Id, 'NLS Search Loans Integration Configuration','NLS');

        Database.Insert(new List<intframework__Integration_Configuration__c>{
            bookToCoreConfiguration,
            getParentLoanIdConfig
        }, true);

        Map<String, String> bookToCoreApiConfigMap = new Map<String, String> {
                    'adapterName' => 'NLSBookToCoreImportAdapter',
                    'method' => 'POST',
                    'endpoint' => '/nls/xml-import',
                    'longRunningOperation' => 'false',
                    'priority' => '1',
                    'contentType' => 'application/json',
                    'requestMappingJSON' => '{"thirdPartySystem":{"name":"test","filters":[{"objectAPI":"genesis__Applications__c","objectAlias":"Application","fields":[{"externalField":"Id","fieldAPI":"Id"},{"externalField":"CoopType","fieldAPI":"Coop_Type__c"},{"externalField":"PricingCount","fieldAPI":"Pricing_Count__c"},{"externalField":"StatementCode","fieldAPI":"Statement_Code__c"},{"externalField":"GrowerCIF","fieldAPI":"genesis__Account__r.CIF_Number__c"},{"externalField":"Tier","fieldAPI":"Dealer_Name__r.Tier__c"},{"externalField":"DealerCIF","fieldAPI":"Dealer_Name__r.CIF_Number__c"},{"externalField":"LoanNumber","fieldAPI":"genesis__Loan_Number__c"},{"externalField":"Entity","fieldAPI":"genesis__Account__r.clcommon__Legal_Entity_Type__r.Name"},{"externalField":"SSN","fieldAPI":"genesis__Contact__r.genesis__SSN__c"},{"externalField":"TaxId","fieldAPI":"genesis__Account__r.genesis__Business_Information__r.genesis__Tax_Identification_Number__c"},{"externalField":"ShortName","fieldAPI":"genesis__Account__r.Short_Name__c"},{"externalField":"AccountName","fieldAPI":"genesis__Account__r.Name"},{"externalField":"FirstName","fieldAPI":"genesis__Contact__r.FirstName"},{"externalField":"LastName","fieldAPI":"genesis__Contact__r.LastName"},{"externalField":"MaturityDate","fieldAPI":"genesis__Maturity_Date__c"},{"externalField":"CropYear","fieldAPI":"Crop_Year__c"},{"externalField":"Guarantee","fieldAPI":"Guarantee__c"},{"externalField":"Name","fieldAPI":"Name"},{"externalField":"LoanAmount","fieldAPI":"genesis__Loan_Amount__c"},{"externalField":"CreditTotalDrawLimit","fieldAPI":"Credit_Total_Draw_Limit__c"},{"externalField":"SigningMethod","fieldAPI":"Signing_Method__c"},{"externalField":"LoanTemplate","fieldAPI":"Flex_Rate_Pricing__c"},{"externalField":"CreditRating","fieldAPI":"genesis__Credit_Rating__r.Name"}],"whereClause":"Id = :applicationId"},{"objectAPI":"clcommon__Address__c","objectAlias":"DealerAddress","fields":[{"externalField":"Id","fieldAPI":"Id"},{"externalField":"DealerAccount","fieldAPI":"clcommon__Account__c"},{"externalField":"DealerCity","fieldAPI":"clcommon__City__c"},{"externalField":"DealerState","fieldAPI":"clcommon__State_Province__c"},{"externalField":"DealerPortfolioManager","fieldAPI":"clcommon__Account__r.PortfolioManager__r.User_Number__c"},{"externalField":"DealerProdAgOfficer","fieldAPI":"clcommon__Account__r.Production_Ag_loan_officer__r.User_Number__c"}],"whereClause":"clcommon__Account__c = :dealerAccount"},{"objectAPI":"genesis__Application_Pricing_Detail__c","objectAlias":"PricingDetailA","fields":[{"externalField":"Id","fieldAPI":"Id"},{"externalField":"LoanNumber","fieldAPI":"Loan_Number__c"},{"externalField":"Description","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Description__c"},{"externalField":"Subsidy","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Participation_Percentage_Dealer_Subsidy__c"},{"externalField":"Premium","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Participation_Percentage_Dealer__c"},{"externalField":"InterestRate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.genesis__Interest_Rate__c"},{"externalField":"InterestType","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Interest_Rate_Type__c"},{"externalField":"CfaParticipation","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Participation_Percentage_CFA__c"},{"externalField":"StartDate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Start_Date__c"},{"externalField":"EndDate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.End_Date__c"},{"externalField":"billingDate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Billing_Date__c"},{"externalField":"hasBillingDate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Has_Billing_Date__c"},{"externalField":"cfaAdvantageRate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.genesis__Rate_Card_Setup_Header__r.CFA_Advantage_Rate__c"},{"externalField":"fieldFinanceRate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.genesis__Rate_Card_Setup_Header__r.Field_Finance_Rate__c"},{"externalField":"fsIndexRate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.genesis__Rate_Card_Setup_Header__r.FS_Index_Rate__c"}],"whereClause":"genesis__Application__c = :applicationId and Loan_Number__c = :loanA order By  genesis__Rate_Card_Setup_Detail__r.Start_Date__c"},{"objectAPI":"genesis__Application_Pricing_Detail__c","objectAlias":"PricingDetailB","fields":[{"externalField":"Id","fieldAPI":"Id"},{"externalField":"LoanNumber","fieldAPI":"Loan_Number__c"},{"externalField":"Description","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Description__c"},{"externalField":"Subsidy","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Participation_Percentage_Dealer_Subsidy__c"},{"externalField":"Premium","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Participation_Percentage_Dealer__c"},{"externalField":"InterestRate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.genesis__Interest_Rate__c"},{"externalField":"InterestType","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Interest_Rate_Type__c"},{"externalField":"CfaParticipation","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Participation_Percentage_CFA__c"},{"externalField":"StartDate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Start_Date__c"},{"externalField":"EndDate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.End_Date__c"},{"externalField":"billingDate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Billing_Date__c"},{"externalField":"hasBillingDate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Has_Billing_Date__c"},{"externalField":"cfaAdvantageRate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.genesis__Rate_Card_Setup_Header__r.CFA_Advantage_Rate__c"},{"externalField":"fieldFinanceRate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.genesis__Rate_Card_Setup_Header__r.Field_Finance_Rate__c"},{"externalField":"fsIndexRate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.genesis__Rate_Card_Setup_Header__r.FS_Index_Rate__c"}],"whereClause":"genesis__Application__c = :applicationId and Loan_Number__c = :loanB order By  genesis__Rate_Card_Setup_Detail__r.Start_Date__c"},{"objectAPI":"genesis__Application_Pricing_Detail__c","objectAlias":"PricingDetailC","fields":[{"externalField":"Id","fieldAPI":"Id"},{"externalField":"LoanNumber","fieldAPI":"Loan_Number__c"},{"externalField":"Description","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Description__c"},{"externalField":"Subsidy","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Participation_Percentage_Dealer_Subsidy__c"},{"externalField":"Premium","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Participation_Percentage_Dealer__c"},{"externalField":"InterestRate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.genesis__Interest_Rate__c"},{"externalField":"InterestType","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Interest_Rate_Type__c"},{"externalField":"CfaParticipation","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Participation_Percentage_CFA__c"},{"externalField":"StartDate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Start_Date__c"},{"externalField":"EndDate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.End_Date__c"},{"externalField":"billingDate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Billing_Date__c"},{"externalField":"hasBillingDate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Has_Billing_Date__c"},{"externalField":"cfaAdvantageRate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.genesis__Rate_Card_Setup_Header__r.CFA_Advantage_Rate__c"},{"externalField":"fieldFinanceRate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.genesis__Rate_Card_Setup_Header__r.Field_Finance_Rate__c"},{"externalField":"fsIndexRate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.genesis__Rate_Card_Setup_Header__r.FS_Index_Rate__c"}],"whereClause":"genesis__Application__c = :applicationId and Loan_Number__c = :loanC order By  genesis__Rate_Card_Setup_Detail__r.Start_Date__c"},{"objectAPI":"genesis__Application_Pricing_Detail__c","objectAlias":"PricingDetailD","fields":[{"externalField":"Id","fieldAPI":"Id"},{"externalField":"LoanNumber","fieldAPI":"Loan_Number__c"},{"externalField":"Description","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Description__c"},{"externalField":"Subsidy","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Participation_Percentage_Dealer_Subsidy__c"},{"externalField":"Premium","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Participation_Percentage_Dealer__c"},{"externalField":"InterestRate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.genesis__Interest_Rate__c"},{"externalField":"InterestType","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Interest_Rate_Type__c"},{"externalField":"CfaParticipation","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Participation_Percentage_CFA__c"},{"externalField":"StartDate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Start_Date__c"},{"externalField":"EndDate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.End_Date__c"},{"externalField":"billingDate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Billing_Date__c"},{"externalField":"hasBillingDate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Has_Billing_Date__c"},{"externalField":"cfaAdvantageRate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.genesis__Rate_Card_Setup_Header__r.CFA_Advantage_Rate__c"},{"externalField":"fieldFinanceRate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.genesis__Rate_Card_Setup_Header__r.Field_Finance_Rate__c"},{"externalField":"fsIndexRate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.genesis__Rate_Card_Setup_Header__r.FS_Index_Rate__c"}],"whereClause":"genesis__Application__c = :applicationId and Loan_Number__c = :loanD order By  genesis__Rate_Card_Setup_Detail__r.Start_Date__c"},{"objectAPI":"genesis__Application_Pricing_Detail__c","objectAlias":"PricingDetailE","fields":[{"externalField":"Id","fieldAPI":"Id"},{"externalField":"LoanNumber","fieldAPI":"Loan_Number__c"},{"externalField":"Description","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Description__c"},{"externalField":"Subsidy","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Participation_Percentage_Dealer_Subsidy__c"},{"externalField":"Premium","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Participation_Percentage_Dealer__c"},{"externalField":"InterestRate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.genesis__Interest_Rate__c"},{"externalField":"InterestType","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Interest_Rate_Type__c"},{"externalField":"CfaParticipation","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Participation_Percentage_CFA__c"},{"externalField":"StartDate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Start_Date__c"},{"externalField":"EndDate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.End_Date__c"},{"externalField":"billingDate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Billing_Date__c"},{"externalField":"hasBillingDate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Has_Billing_Date__c"},{"externalField":"cfaAdvantageRate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.genesis__Rate_Card_Setup_Header__r.CFA_Advantage_Rate__c"},{"externalField":"fieldFinanceRate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.genesis__Rate_Card_Setup_Header__r.Field_Finance_Rate__c"},{"externalField":"fsIndexRate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.genesis__Rate_Card_Setup_Header__r.FS_Index_Rate__c"}],"whereClause":"genesis__Application__c = :applicationId and Loan_Number__c = :loanE order By  genesis__Rate_Card_Setup_Detail__r.Start_Date__c"},{"objectAPI":"genesis__Application_Pricing_Detail__c","objectAlias":"PricingDetailF","fields":[{"externalField":"Id","fieldAPI":"Id"},{"externalField":"LoanNumber","fieldAPI":"Loan_Number__c"},{"externalField":"Description","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Description__c"},{"externalField":"Subsidy","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Participation_Percentage_Dealer_Subsidy__c"},{"externalField":"Premium","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Participation_Percentage_Dealer__c"},{"externalField":"InterestRate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.genesis__Interest_Rate__c"},{"externalField":"InterestType","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Interest_Rate_Type__c"},{"externalField":"CfaParticipation","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Participation_Percentage_CFA__c"},{"externalField":"StartDate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Start_Date__c"},{"externalField":"EndDate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.End_Date__c"},{"externalField":"billingDate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Billing_Date__c"},{"externalField":"hasBillingDate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Has_Billing_Date__c"},{"externalField":"cfaAdvantageRate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.genesis__Rate_Card_Setup_Header__r.CFA_Advantage_Rate__c"},{"externalField":"fieldFinanceRate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.genesis__Rate_Card_Setup_Header__r.Field_Finance_Rate__c"},{"externalField":"fsIndexRate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.genesis__Rate_Card_Setup_Header__r.FS_Index_Rate__c"}],"whereClause":"genesis__Application__c = :applicationId and Loan_Number__c = :loanF order By  genesis__Rate_Card_Setup_Detail__r.Start_Date__c"},{"objectAPI":"genesis__Application_Pricing_Detail__c","objectAlias":"PricingDetailG","fields":[{"externalField":"Id","fieldAPI":"Id"},{"externalField":"LoanNumber","fieldAPI":"Loan_Number__c"},{"externalField":"Description","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Description__c"},{"externalField":"Subsidy","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Participation_Percentage_Dealer_Subsidy__c"},{"externalField":"Premium","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Participation_Percentage_Dealer__c"},{"externalField":"InterestRate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.genesis__Interest_Rate__c"},{"externalField":"InterestType","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Interest_Rate_Type__c"},{"externalField":"CfaParticipation","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Participation_Percentage_CFA__c"},{"externalField":"StartDate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Start_Date__c"},{"externalField":"EndDate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.End_Date__c"},{"externalField":"billingDate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Billing_Date__c"},{"externalField":"hasBillingDate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Has_Billing_Date__c"},{"externalField":"cfaAdvantageRate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.genesis__Rate_Card_Setup_Header__r.CFA_Advantage_Rate__c"},{"externalField":"fieldFinanceRate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.genesis__Rate_Card_Setup_Header__r.Field_Finance_Rate__c"},{"externalField":"fsIndexRate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.genesis__Rate_Card_Setup_Header__r.FS_Index_Rate__c"}],"whereClause":"genesis__Application__c = :applicationId and Loan_Number__c = :loanG order By  genesis__Rate_Card_Setup_Detail__r.Start_Date__c"},{"objectAPI":"genesis__Application_Pricing_Detail__c","objectAlias":"PricingDetailH","fields":[{"externalField":"Id","fieldAPI":"Id"},{"externalField":"LoanNumber","fieldAPI":"Loan_Number__c"},{"externalField":"Description","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Description__c"},{"externalField":"Subsidy","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Participation_Percentage_Dealer_Subsidy__c"},{"externalField":"Premium","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Participation_Percentage_Dealer__c"},{"externalField":"InterestRate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.genesis__Interest_Rate__c"},{"externalField":"InterestType","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Interest_Rate_Type__c"},{"externalField":"CfaParticipation","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Participation_Percentage_CFA__c"},{"externalField":"StartDate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Start_Date__c"},{"externalField":"EndDate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.End_Date__c"},{"externalField":"billingDate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Billing_Date__c"},{"externalField":"hasBillingDate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.Has_Billing_Date__c"},{"externalField":"cfaAdvantageRate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.genesis__Rate_Card_Setup_Header__r.CFA_Advantage_Rate__c"},{"externalField":"fieldFinanceRate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.genesis__Rate_Card_Setup_Header__r.Field_Finance_Rate__c"},{"externalField":"fsIndexRate","fieldAPI":"genesis__Rate_Card_Setup_Detail__r.genesis__Rate_Card_Setup_Header__r.FS_Index_Rate__c"}],"whereClause":"genesis__Application__c = :applicationId and Loan_Number__c = :loanH order By  genesis__Rate_Card_Setup_Detail__r.Start_Date__c"},{"objectAPI":"genesis__Rate_Card_Setup_Header__c","objectAlias":"MyProgramHeader","fields":[{"externalField":"Id","fieldAPI":"Id"},{"externalField":"Name","fieldAPI":"Name"},{"externalField":"closingFee","fieldAPI":"Closing_Fee__c"},{"externalField":"DealerParticipation","fieldAPI":"Dealer_Participate_on_Closing_Fee__c"},{"externalField":"LoanNumberAdvanced","fieldAPI":"Loan_Fee_Advanced_On__c"},{"externalField":"Payer","fieldAPI":"Payer_of_Loan_Closing_Fee__c"},{"externalField":"DealerPortion","fieldAPI":"Portion_of_Fee_to_Cover__c"},{"externalField":"EffectiveDate","fieldAPI":"genesis__Start_Date__c"}],"whereClause":"Id = :myProgId"},{"objectAPI":"clcommon__Floating_Rate_Index__c","objectAlias":"FloatingRateIndex","fields":[{"externalField":"Id","fieldAPI":"Id"},{"externalField":"AdvantageRateName","fieldAPI":"Base_Rate_Name__c"},{"externalField":"AdvantageRateValue","fieldAPI":"Current_Floating_Rate__c"},{"externalField":"AdvantageRateAdjuster","fieldAPI":"Base_Rate_Adjuster__c"}],"whereClause":"Name != null"},{"objectAPI":"CFA_Partner_Program__c","objectAlias":"PartnerProgram","fields":[{"externalField":"Id","fieldAPI":"Id"},{"externalField":"BaseRate","fieldAPI":"Base_Rate__c"},{"externalField":"BaseRateName","fieldAPI":"Base_Rate__r.Base_Rate_Name__c"},{"externalField":"BaseRateValue","fieldAPI":"Base_Rate__r.Current_Floating_Rate__c"},{"externalField":"BaseRateAdjuster","fieldAPI":"Base_Rate__r.Base_Rate_Adjuster__c"},{"externalField":"UserDefined11","fieldAPI":"NLS_User_Defined_Field__c"},{"externalField":"LoanClosingFees","fieldAPI":"Loan_Closing_Fee__c"}],"whereClause":"Name = :coopType"}],"dynamicDataParameters":[{"externalField":"coopType"}]}}',
                    'familyId' => integrationFamily.Id,
                    'apiTypeId' => bookToCoreApiType.Id,
                    'providerId' => bookToCoreProvider.Id,
                    'configId' => bookToCoreConfiguration.Id
                };
        intframework__Integration_API_Configuration__c xmlImportApiConfigObj = IntegrationTestInitHelper.getIntegrationAPIConfigurationInst(bookToCoreApiConfigMap);
        
        Map<String, String> getParentLoanIdApiConfig = new Map<String, String> {
            'adapterName' => 'NLSLoanSearchAdapter',
            'method' => 'POST',
            'endpoint' => '/loans/search',
            'longRunningOperation' => 'false',
            'priority' => '1',
            'contentType' => 'application/json',
            'requestMappingJSON' => '{"thirdPartySystem": {"name": "Test","filters": [],"dynamicDataParameters": [{"externalField": "loanNumber"}]}}',
            'familyId' => integrationFamily.Id,
            'apiTypeId' => getParentLoanIdApiType.Id,
            'providerId' => getParentLoanIdProvider.Id,
            'configId' => getParentLoanIdConfig.Id
        };
        intframework__Integration_API_Configuration__c loanSearchApiConfigObj = IntegrationTestInitHelper.getIntegrationAPIConfigurationInst(getParentLoanIdApiConfig);

        Database.Insert(new List<intframework__Integration_API_Configuration__c>{
            xmlImportApiConfigObj,
            loanSearchApiConfigObj
        }, true);
    }

    /**
    * @description : method to get Landus Application
    * @author Suraj Kumar | 05-04-2024 
    * @return genesis__Applications__c 
    **/
    private static genesis__Applications__c getLandusApplication(){
        genesis__Applications__c applicationObj = [SELECT Id, 
                                                            Dealer_Name__c
                                                        FROM genesis__Applications__c
                                                        WHERE Coop_Type__c = :PortalConstants.CFA_COOP_TYPE
                                                        LIMIT 1];
        Account dealerAccObj = [SELECT Id,  
                                        Coop_Type__c, 
                                        CFA_Partner_Program__c 
                                FROM Account 
                                WHERE Id =: applicationObj.Dealer_Name__c];
        dealerAccObj.Coop_Type__c = PortalConstants.LANDUS_COOP_TYPE;
        Database.update(dealerAccObj,true);
        CFA_Partner_Program__c partnerProgramObj = [SELECT Id FROM CFA_Partner_Program__c WHERE Id = :dealerAccObj.CFA_Partner_Program__c];
        partnerProgramObj.Name = PortalConstants.LANDUS_COOP_TYPE;
        partnerProgramObj.Short_Name__c = PortalConstants.LANDUS_COOP_TYPE;
        Database.update(partnerProgramObj, true);
        updateStatementCode(applicationObj, PortalConstants.LANDUS_COOP_TYPE);
        applicationObj = [SELECT Id, 
                                    genesis__Account__c,
                                    genesis__Contact__c,
                                    Coop_Type__c, 
                                    Dealer_Name__c,
                                    Guarantee__c,
                                    Signing_Method__c,
                                    genesis__Loan_Number__c, 
                                    dealer_name__r.Coop_Type__c,
                                    dealer_name__r.cfa_partner_program__r.name
                        FROM genesis__Applications__c
                        WHERE Dealer_Name__c = :dealerAccObj.Id
                        LIMIT 1];
        return applicationObj;
    }

    
    /**
    * @description : method to get FCSA Application
    * @author Kabir Pramanik | 12-11-2024 
    * @return genesis__Applications__c 
    **/
    private static genesis__Applications__c getFCSAApplication(){
        genesis__Applications__c applicationObj = [SELECT Id,
                                                            Dealer_Name__c
                                                    FROM genesis__Applications__c
                                                    WHERE Coop_Type__c = :PortalConstants.CFA_COOP_TYPE
                                                    LIMIT 1];
        Account dealerAccObj = [SELECT Id,  
                                        CFA_Partner_Program__c 
                                FROM Account 
                                WHERE Id =: applicationObj.Dealer_Name__c];
        dealerAccObj.Coop_Type__c = PortalConstants.FCSA_COOP_TYPE;
        Database.update(dealerAccObj,true);
        CFA_Partner_Program__c partnerProgramObj = [SELECT Id FROM CFA_Partner_Program__c WHERE Id = :dealerAccObj.CFA_Partner_Program__c];
        partnerProgramObj.Name = PortalConstants.FCSA_COOP_TYPE;
        partnerProgramObj.NLS_User_Defined_Field__c = 'FCSA';
        Database.update(partnerProgramObj, true);
        applicationObj = [SELECT Id, 
                                    genesis__Account__c,
                                    genesis__Contact__c,
                                    Coop_Type__c, 
                                    Dealer_Name__c,
                                    Guarantee__c,
                                    Signing_Method__c,
                                    genesis__Loan_Number__c
                        FROM genesis__Applications__c
                        WHERE Dealer_Name__c = :dealerAccObj.Id
                        LIMIT 1];
        return applicationObj;
    }
    
    /**
    * @description       : Setting up the Mock Response of FAILED status
    * @author            : Suraj kumar
    * @last modified on  : 01-09-2025
    * @last modified by  : Kabir Pramanik
    **/
    public class NLSBookToCoreFailuredMock implements HttpCalloutMock {
        // Implement this interface method
        /**
        * @description : return the mock response of FAILED status
        * @author Suraj Kumar | 03-11-2024 
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
    * @description       : Setting up the Mock Response of SUCCESS status
    * @author            : Suraj kumar
    * @last modified on  : 01-09-2025
    * @last modified by  : Kabir Pramanik
    **/
    public class NLSBookToCoreMock implements HttpCalloutMock {

        /**
        * @description : return the mock response of SUCCESS status
        * @author Suraj Kumar | 03-11-2024 
        * @param request 
        * @return HTTPResponse 
        **/
        public HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setStatus('SUCCESS');
            response.setHeader('Content-Type', 'application/json');
            if (request.getEndpoint().contains('token')){
                String token = '{"access_token":"eyJhbGciOiJSUzI1NiIsI","expires_in":300,"token_type":"Bearer"}';
                response.setBody(token);
            } else if (request.getEndpoint().contains('search')) {
                response.setBody('{"status":{"code":200,"message":"Success"},"payload":{"totalCount":1,"count":1,"data":[{"Acctrefno":176614,"Loan_Type":3,"Portfolio_Code_Id":0,"Loan_Number":"34306625001","Cifno":39379,"Loan_Group_No":4,"Shortname":"PARK AVENUE","Name":"PARK AVENUE","Loan_Class1_No":68,"Loan_Class2_No":0,"Risk_Rating_No":3,"Entity":"LIMITED LIABILITY COMPANY","Branch_Cifno":null,"Status_Code_No":0,"Loan_Officer_No":0,"Collection_Officer_No":0,"Dealer_Cifno":null,"Master_Acctrefno":0,"Pool_Acctrefno":0,"Shadow_Loan_Exists":false,"Curr_Maturity_Date":"2023-12-15T00:00:00","Interest_Accrued_Thru_Date":"2022-05-28T00:00:00","Current_Note_Amount":0.00,"Current_Payoff_Balance":0.0000000000,"Days_Past_Due":0,"Closed_Date":null}]}}');
            } else {
                response.setBody('{ "status": { "code": 200, "message": "string" }, "payload": { "data": "string" } }');
            }
            return response;
        }
    }

    /**
    * @description       : Setting up the Mock Response of SUCCESS status
    * @author            : Suraj kumar
    * @last modified on  : 01-09-2025
    * @last modified by  : Kabir Pramanik
    **/
    public class NLSBookToCoreNullDataMock implements HttpCalloutMock {

        /**
        * @description : return the mock response of SUCCESS status
        * @author Suraj Kumar | 03-11-2024 
        * @param request 
        * @return HTTPResponse 
        **/
        public HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setStatus('SUCCESS');
            response.setHeader('Content-Type', 'application/json');
            if (request.getEndpoint().contains('token')){
                String token = '{"access_token":"eyJhbGciOiJSUzI1NiIsI","expires_in":300,"token_type":"Bearer"}';
                response.setBody(token);
            }else if (request.getEndpoint().contains('search')) {
                response.setBody('{"status":{"code":200,"message":"Success"},"payload":{"totalCount":1,"count":1,"data":[{"Acctrefno":"","Loan_Type":3,"Portfolio_Code_Id":0,"Loan_Number":"34306625001","Cifno":39379,"Loan_Group_No":4,"Shortname":"PARK AVENUE","Name":"PARK AVENUE","Loan_Class1_No":68,"Loan_Class2_No":0,"Risk_Rating_No":3,"Entity":"LIMITED LIABILITY COMPANY","Branch_Cifno":null,"Status_Code_No":0,"Loan_Officer_No":0,"Collection_Officer_No":0,"Dealer_Cifno":null,"Master_Acctrefno":0,"Pool_Acctrefno":0,"Shadow_Loan_Exists":false,"Curr_Maturity_Date":"2023-12-15T00:00:00","Interest_Accrued_Thru_Date":"2022-05-28T00:00:00","Current_Note_Amount":0.00,"Current_Payoff_Balance":0.0000000000,"Days_Past_Due":0,"Closed_Date":null}]}}');
            }else {
                response.setBody('{ "status": { "code": 200, "message": "string" }, "payload": { "data": "string" } }');
            }
            return response;
        }
    }


    /**
    * @description : return the admin user
    * @author Suraj Kumar | 03-11-2024 
    * @return User 
    **/
    private static User getAdminUser() {
        return [
            SELECT Id 
            FROM User 
            WHERE Id = :UserInfo.getUserId()
        ][0];
    }

    /**
    * @description : Get the user of CL
    * @author Kabir Pramanik | 12-13-2024 
    * @param coopType 
    * @return User 
    **/
    public static User getClUser(String coopType) {
        if(coopType == PortalConstants.CFA_COOP_TYPE
                || coopType == PortalConstants.LANDUS_COOP_TYPE
                || coopType == PortalConstants.FCSA_COOP_TYPE){
            return [
                SELECT Id
                FROM User
                WHERE UserName = 'marry.lamb@yopmail.com'
            ][0];
        }else if(coopType == PortalConstants.GROWMARK_COOP_TYPE){
            return [
                SELECT Id
                FROM User
                WHERE UserName = 'ross.geller@yopmail.com'
            ][0];
        }
        return null;
    }

    
    /**
    * @description : Test Landus book to core success
    * @author Kabir Pramanik | 12-18-2024 
    **/
    @IsTest
    public static void testCaseLandusBookToCoreSuccess() {
        genesis__Applications__c landusApplicationObj = getLandusApplication();
        landusApplicationObj.Signing_Method__c = PortalConstants.EMAIL_DOCUSIGN;
        Database.update(landusApplicationObj, true);
        System.runAs(getAdminUser()) {
            Test.setMock(HttpCalloutMock.class, new NLSBookToCoreMock());
            Test.startTest();
            String response = NLSBookToCoreCalloutClass.bookToCoreLoanFromBackEnd(landusApplicationObj.Id);
            System.assertEquals('Success', response, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    
    /**
    * @description : Test FCSA book to core success
    * @author Kabir Pramanik | 12-18-2024 
    **/
    @IsTest
    public static void testCaseFCSABookToCoreSuccess() {
        genesis__Applications__c fcsaApplicationObj = getFCSAApplication();
        System.runAs(getAdminUser()) {
            Test.setMock(HttpCalloutMock.class, new NLSBookToCoreMock());
            Test.startTest();
            String response = NLSBookToCoreCalloutClass.bookToCoreLoanFromBackEnd(fcsaApplicationObj.Id);
            System.assertEquals('Success', response, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    // GMK Test Cases -------------------------
    // Variable Interest Rate Type Start ------
    /**
    * @description : Test GMK Single Rate Single Sub-tranche Loan - without billing date, variable interest rate type, Grower Rate = FS Index Rate
    * @author Kabir Pramanik | 12-10-2024 
    **/
    @isTest
    public static void testGMKSingleRateNoBillingVariableZeroParticipationGrowerRateEqualsFSIndexRate(){
        genesis__Applications__c gmkApplicationObj = [
            SELECT Id,
                genesis__Account__c,
                My_Program__c
            FROM genesis__Applications__c
            WHERE Coop_Type__c = :PortalConstants.GROWMARK_COOP_TYPE
            LIMIT 1
        ];
        gmkApplicationObj.Signing_Method__c = PortalConstants.PAPER_SCANNED;
        Database.update(gmkApplicationObj, true);
        clcommon__Legal_Entity__c dBAEntityObj = [SELECT Id
                                                FROM clcommon__Legal_Entity__c 
                                                WHERE Name = :PortalConstants.INDIVIDUAL_ENTITY 
                                                LIMIT 1];
        Account growerAccObj =  [SELECT Id,
                                        clcommon__Legal_Entity_Type__c
                                FROM Account
                                WHERE Id = : gmkApplicationObj.genesis__Account__c];
        growerAccObj.clcommon__Legal_Entity_Type__c = dBAEntityObj.Id;
        Database.update(growerAccObj,true);
        List<genesis__Rate_Card_Setup_Detail__c> rateCardSetupDetailObj =  [SELECT Id
                                                                            FROM genesis__Rate_Card_Setup_Detail__c 
                                                                            WHERE genesis__rate_card_setup_header__c = :gmkApplicationObj.My_Program__c 
                                                                            ORDER BY Special_Term_Reference__c, Start_Date__c
        ];
        rateCardSetupDetailObj[0].billing_date__c = null;
        rateCardSetupDetailObj[0].has_billing_date__c = false;
        rateCardSetupDetailObj[0].Interest_Rate_Type__c = 'Variable';
        rateCardSetupDetailObj[0].genesis__Interest_Rate__c = 9;
        rateCardSetupDetailObj[0].Participation_Percentage_Dealer__c = 0;
        rateCardSetupDetailObj[0].Participation_Percentage_Dealer_Subsidy__c = 0;
        rateCardSetupDetailObj[0].End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        Database.update(rateCardSetupDetailObj[0], true);

        List<genesis__Application_Pricing_Detail__c> pricingsObj = [
                    SELECT Id 
                    FROM genesis__Application_Pricing_Detail__c 
                    WHERE genesis__Application__c = :gmkApplicationObj.Id
                    AND genesis__Application__r.Coop_Type__c = :PortalConstants.GROWMARK_COOP_TYPE
                    ORDER BY genesis__Rate_Card_Setup_Detail__r.Special_Term_Reference__c, genesis__Rate_Card_Setup_Detail__r.Start_Date__c
        ];
        pricingsObj.remove(0);
        Database.delete(pricingsObj, true);
        updateStatementCode(gmkApplicationObj, PortalConstants.GROWMARK_COOP_TYPE );
        System.runAs(getAdminUser()) {
            Test.setMock(HttpCalloutMock.class, new NLSBookToCoreMock());
            Test.startTest();
            String response = NLSBookToCoreCalloutClass.bookToCoreLoanFromBackEnd(gmkApplicationObj.Id);
            System.assertEquals('Success', response, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : Test GMK Single Rate Loan with Single Sub Tranche - without billing date, variable interest type, Grower Rate exceeds Field Finance Rate
    * @author Kabir Pramanik | 12-10-2024 
    **/
    @isTest
    public static void testGMKSingleRateNoBillingVariableGrowerRateExceedsFSIndexRate(){
        genesis__Applications__c gmkApplicationObj = [
            SELECT Id,
                My_Program__c
            FROM genesis__Applications__c
            WHERE Coop_Type__c = :PortalConstants.GROWMARK_COOP_TYPE
            LIMIT 1
        ];
        List<genesis__Rate_Card_Setup_Detail__c> rateCardSetupDetailObj = [SELECT Id
                                                                            FROM genesis__Rate_Card_Setup_Detail__c 
                                                                            WHERE genesis__rate_card_setup_header__c = :gmkApplicationObj.My_Program__c 
                                                                            ORDER BY Special_Term_Reference__c, Start_Date__c
        ];
        rateCardSetupDetailObj[0].billing_date__c = null;
        rateCardSetupDetailObj[0].has_billing_date__c = false;
        rateCardSetupDetailObj[0].Interest_Rate_Type__c = 'Variable';
        rateCardSetupDetailObj[0].genesis__Interest_Rate__c = 14;
        rateCardSetupDetailObj[0].Participation_Percentage_Dealer__c = 5;
        rateCardSetupDetailObj[0].Participation_Percentage_Dealer_Subsidy__c = 0;
        rateCardSetupDetailObj[0].End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        Database.update(rateCardSetupDetailObj[0], true);

        List<genesis__Application_Pricing_Detail__c> pricingsObj = [
                    SELECT Id 
                    FROM genesis__Application_Pricing_Detail__c 
                    WHERE genesis__Application__c = :gmkApplicationObj.Id
                    AND genesis__Application__r.Coop_Type__c = :PortalConstants.GROWMARK_COOP_TYPE 
                    ORDER BY genesis__Rate_Card_Setup_Detail__r.Special_Term_Reference__c, genesis__Rate_Card_Setup_Detail__r.Start_Date__c
        ];
        pricingsObj.remove(0);
        Database.delete(pricingsObj, true);
        updateStatementCode(gmkApplicationObj, PortalConstants.GROWMARK_COOP_TYPE );
        System.runAs(getAdminUser()) {
            Test.setMock(HttpCalloutMock.class, new NLSBookToCoreMock());
            Test.startTest();
            String response = NLSBookToCoreCalloutClass.bookToCoreLoanFromBackEnd(gmkApplicationObj.Id);
            System.assertEquals('Success', response, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : Test GMK Single Rate Loan with Single Sub Tranche - with billing date, variable interest type, Grower Rate is less than FS Index Rate
    * @author Kabir Pramanik | 12-10-2024 
    **/
    @isTest
    public static void testGMKSingleRateWithBillingVariableGrowerRateUnderFSIndexRate(){
        genesis__Applications__c gmkApplicationObj = [
            SELECT Id,
                My_Program__c
            FROM genesis__Applications__c
            WHERE Coop_Type__c = :PortalConstants.GROWMARK_COOP_TYPE
            LIMIT 1
        ];
        List<genesis__Rate_Card_Setup_Detail__c> rateCardSetupDetailObj = [SELECT Id
                                                                            FROM genesis__Rate_Card_Setup_Detail__c 
                                                                            WHERE genesis__rate_card_setup_header__c = :gmkApplicationObj.My_Program__c 
                                                                            ORDER BY Special_Term_Reference__c, Start_Date__c
        ]; 
        rateCardSetupDetailObj[0].billing_date__c = System.today().addMonths(10).toStartOfMonth().addDays(-1);
        rateCardSetupDetailObj[0].has_billing_date__c = true;
        rateCardSetupDetailObj[0].Interest_Rate_Type__c = 'Variable';
        rateCardSetupDetailObj[0].genesis__Interest_Rate__c = 8;
        rateCardSetupDetailObj[0].Participation_Percentage_Dealer__c = 0;
        rateCardSetupDetailObj[0].Participation_Percentage_Dealer_Subsidy__c = 1;
        rateCardSetupDetailObj[0].End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        Database.update(rateCardSetupDetailObj[0], true);

        List<genesis__Application_Pricing_Detail__c> pricingsObj = [
                    SELECT Id 
                    FROM genesis__Application_Pricing_Detail__c 
                    WHERE genesis__Application__c = :gmkApplicationObj.Id
                    AND genesis__Application__r.Coop_Type__c = :PortalConstants.GROWMARK_COOP_TYPE
                    ORDER BY genesis__Rate_Card_Setup_Detail__r.Special_Term_Reference__c, genesis__Rate_Card_Setup_Detail__r.Start_Date__c
        ];
        pricingsObj.remove(0);
        Database.delete(pricingsObj, true);
        updateStatementCode(gmkApplicationObj, PortalConstants.GROWMARK_COOP_TYPE );
        System.runAs(getAdminUser()) {
            Test.setMock(HttpCalloutMock.class, new NLSBookToCoreMock());
            Test.startTest();
            String response = NLSBookToCoreCalloutClass.bookToCoreLoanFromBackEnd(gmkApplicationObj.Id);
            System.assertEquals('Success', response, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description : Test GMK Single Rate Loan with Single Sub Tranche - with billing date, fixed interest rate type, Grower Rate = 0
    * @author Kabir Pramanik | 12-10-2024 
    **/
    @isTest
    public static void testGMKSingleRateWithBillingVariableZeroGrowerRate(){
        genesis__Applications__c gmkApplicationObj = [
            SELECT Id,
                My_Program__c
            FROM genesis__Applications__c
            WHERE Coop_Type__c = :PortalConstants.GROWMARK_COOP_TYPE
            LIMIT 1
        ];
        List<genesis__Rate_Card_Setup_Detail__c> rateCardSetupDetailObj = [SELECT Id
                                                                        FROM genesis__Rate_Card_Setup_Detail__c 
                                                                        WHERE genesis__rate_card_setup_header__c = :gmkApplicationObj.My_Program__c 
                                                                        ORDER BY Special_Term_Reference__c, Start_Date__c
        ];
        rateCardSetupDetailObj[0].billing_date__c = System.today().addMonths(10).toStartOfMonth().addDays(-1);
        rateCardSetupDetailObj[0].has_billing_date__c = true;
        rateCardSetupDetailObj[0].Interest_Rate_Type__c = 'Variable';
        rateCardSetupDetailObj[0].genesis__Interest_Rate__c = 0;
        rateCardSetupDetailObj[0].Participation_Percentage_Dealer__c = 0;
        rateCardSetupDetailObj[0].Participation_Percentage_Dealer_Subsidy__c = 9;
        rateCardSetupDetailObj[0].End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        Database.update(rateCardSetupDetailObj[0], true);

        List<genesis__Application_Pricing_Detail__c> pricingsObj = [
                    SELECT Id 
                    FROM genesis__Application_Pricing_Detail__c 
                    WHERE genesis__Application__c = :gmkApplicationObj.Id
                    AND genesis__Application__r.Coop_Type__c = :PortalConstants.GROWMARK_COOP_TYPE 
                    ORDER BY genesis__Rate_Card_Setup_Detail__r.Special_Term_Reference__c, genesis__Rate_Card_Setup_Detail__r.Start_Date__c
        ];
        pricingsObj.remove(0);
        Database.delete(pricingsObj, true);
        updateStatementCode(gmkApplicationObj, PortalConstants.GROWMARK_COOP_TYPE );
        System.runAs(getAdminUser()) {
            Test.setMock(HttpCalloutMock.class, new NLSBookToCoreMock());
            Test.startTest();
            String response = NLSBookToCoreCalloutClass.bookToCoreLoanFromBackEnd(gmkApplicationObj.Id);
            System.assertEquals('Success', response, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    // Variable Interest Rate Type End ------------

    // Fixed Interest Rate Type Start--------------
    /**
    * @description : Test GMK Single Rate Singl Sub Tranche - without billing date, fixed interet rate type, Grower Rate = FS Index Rate
    * @author Kabir Pramanik | 12-10-2024 
    **/
    @isTest
    public static void testGMKSingleRateNoBillingFixedZeroParticipationGrowerRateEqualsFSIndexRate(){
        genesis__Applications__c gmkApplicationObj = [
            SELECT Id,
                genesis__Account__c,
                My_Program__c
            FROM genesis__Applications__c
            WHERE Coop_Type__c = :PortalConstants.GROWMARK_COOP_TYPE
            LIMIT 1
        ];
        clcommon__Legal_Entity__c corporationEntityObj = [SELECT Id
                                                        FROM clcommon__Legal_Entity__c 
                                                        WHERE Name = :PortalConstants.CORPORATION 
                                                        LIMIT 1];
        Account borrowerAccountObj = [SELECT Id
                                    FROM Account
                                    WHERE Id = :gmkApplicationObj.genesis__Account__c
                                    LIMIT 1];
                                    
        borrowerAccountObj.clcommon__Legal_Entity_Type__c = corporationEntityObj.Id;
        Database.update(borrowerAccountObj, true);
        List<genesis__Rate_Card_Setup_Detail__c> rateCardSetupDetailObj = [SELECT Id
                                                                            FROM genesis__Rate_Card_Setup_Detail__c 
                                                                            WHERE genesis__rate_card_setup_header__c = :gmkApplicationObj.My_Program__c 
                                                                            ORDER BY Special_Term_Reference__c, Start_Date__c
        ];
        rateCardSetupDetailObj[0].billing_date__c = null;
        rateCardSetupDetailObj[0].has_billing_date__c = false;
        rateCardSetupDetailObj[0].Interest_Rate_Type__c = 'Fixed';
        rateCardSetupDetailObj[0].genesis__Interest_Rate__c = 9;
        rateCardSetupDetailObj[0].Participation_Percentage_Dealer__c = 0;
        rateCardSetupDetailObj[0].Participation_Percentage_Dealer_Subsidy__c = 0;
        rateCardSetupDetailObj[0].End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        Database.update(rateCardSetupDetailObj[0], true);

        List<genesis__Application_Pricing_Detail__c> pricingsObj = [
                    SELECT Id 
                    FROM genesis__Application_Pricing_Detail__c 
                    WHERE genesis__Application__c = :gmkApplicationObj.Id
                    AND genesis__Application__r.Coop_Type__c = :PortalConstants.GROWMARK_COOP_TYPE 
                    ORDER BY genesis__Rate_Card_Setup_Detail__r.Special_Term_Reference__c, genesis__Rate_Card_Setup_Detail__r.Start_Date__c
        ];
        pricingsObj.remove(0);
        Database.delete(pricingsObj, true);
        updateStatementCode(gmkApplicationObj, PortalConstants.GROWMARK_COOP_TYPE );
        System.runAs(getAdminUser()) {
            Test.setMock(HttpCalloutMock.class, new NLSBookToCoreMock());
            Test.startTest();
            String response = NLSBookToCoreCalloutClass.bookToCoreLoanFromBackEnd(gmkApplicationObj.Id);
            System.assertEquals('Success', response, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : Test GMK Single Rate Loan with Single Sub Tranche - without billing date, fixed interest type, Grower Rate exceeds FS Index Rate
    * @author Kabir Pramanik | 12-10-2024 
    **/
    @isTest
    public static void testGMKSingleRateNoBillingFixedGrowerRateExceedsFSIndexRate(){
        genesis__Applications__c gmkApplicationObj = [
            SELECT Id,
                My_Program__c
            FROM genesis__Applications__c
            WHERE Coop_Type__c = :PortalConstants.GROWMARK_COOP_TYPE
            LIMIT 1
        ];
        List<genesis__Rate_Card_Setup_Detail__c> rateCardSetupDetailObj = [SELECT Id
                                                                            FROM genesis__Rate_Card_Setup_Detail__c 
                                                                            WHERE genesis__rate_card_setup_header__c = :gmkApplicationObj.My_Program__c 
                                                                            ORDER BY Special_Term_Reference__c, Start_Date__c
        ];
        rateCardSetupDetailObj[0].billing_date__c = null;
        rateCardSetupDetailObj[0].has_billing_date__c = false;
        rateCardSetupDetailObj[0].Interest_Rate_Type__c = 'Fixed';
        rateCardSetupDetailObj[0].genesis__Interest_Rate__c = 12;
        rateCardSetupDetailObj[0].Participation_Percentage_Dealer__c = 3;
        rateCardSetupDetailObj[0].Participation_Percentage_Dealer_Subsidy__c = 0;
        rateCardSetupDetailObj[0].End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        Database.update(rateCardSetupDetailObj[0], true);

        List<genesis__Application_Pricing_Detail__c> pricingsObj = [
                    SELECT Id 
                    FROM genesis__Application_Pricing_Detail__c 
                    WHERE genesis__Application__c = :gmkApplicationObj.Id
                    AND genesis__Application__r.Coop_Type__c = :PortalConstants.GROWMARK_COOP_TYPE 
                    ORDER BY genesis__Rate_Card_Setup_Detail__r.Special_Term_Reference__c, genesis__Rate_Card_Setup_Detail__r.Start_Date__c
        ];
        pricingsObj.remove(0);
        Database.delete(pricingsObj, true);
        updateStatementCode(gmkApplicationObj, PortalConstants.GROWMARK_COOP_TYPE);
        System.runAs(getAdminUser()) {
            Test.setMock(HttpCalloutMock.class, new NLSBookToCoreMock());
            Test.startTest();
            String response = NLSBookToCoreCalloutClass.bookToCoreLoanFromBackEnd(gmkApplicationObj.Id);
            System.assertEquals('Success', response, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : Test GMK Single Rate Loan with Single Sub Tranche - with billing date, variable interest type, Grower Rate is less than FS Index Rate
    * @author Kabir Pramanik | 12-10-2024 
    **/
    @isTest
    public static void testGMKSingleRateWithBillingFixedGrowerRateUnderFSIndexRate(){
        genesis__Applications__c gmkApplicationObj = [
            SELECT Id,
                My_Program__c
            FROM genesis__Applications__c
            WHERE Coop_Type__c = :PortalConstants.GROWMARK_COOP_TYPE
            LIMIT 1
        ];
        List<genesis__Rate_Card_Setup_Detail__c> rateCardSetupDetailObj = [SELECT Id
                                                                            FROM genesis__Rate_Card_Setup_Detail__c 
                                                                            WHERE genesis__rate_card_setup_header__c = :gmkApplicationObj.My_Program__c 
                                                                            ORDER BY Special_Term_Reference__c, Start_Date__c
        ];
        rateCardSetupDetailObj[0].billing_date__c = System.today().addMonths(10).toStartOfMonth().addDays(-1);
        rateCardSetupDetailObj[0].has_billing_date__c = true;
        rateCardSetupDetailObj[0].Interest_Rate_Type__c = 'Fixed';
        rateCardSetupDetailObj[0].genesis__Interest_Rate__c = 8;
        rateCardSetupDetailObj[0].Participation_Percentage_Dealer__c = 0;
        rateCardSetupDetailObj[0].Participation_Percentage_Dealer_Subsidy__c = 1;
        rateCardSetupDetailObj[0].End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        Database.update(rateCardSetupDetailObj[0], true);

        List<genesis__Application_Pricing_Detail__c> pricingsObj = [
                    SELECT Id 
                    FROM genesis__Application_Pricing_Detail__c 
                    WHERE genesis__Application__c = :gmkApplicationObj.Id
                    AND genesis__Application__r.Coop_Type__c = :PortalConstants.GROWMARK_COOP_TYPE 
                    ORDER BY genesis__Rate_Card_Setup_Detail__r.Special_Term_Reference__c, genesis__Rate_Card_Setup_Detail__r.Start_Date__c
        ];
        pricingsObj.remove(0);
        Database.delete(pricingsObj, true);
        updateStatementCode(gmkApplicationObj, PortalConstants.GROWMARK_COOP_TYPE);
        System.runAs(getAdminUser()) {
            Test.setMock(HttpCalloutMock.class, new NLSBookToCoreMock());
            Test.startTest();
            String response = NLSBookToCoreCalloutClass.bookToCoreLoanFromBackEnd(gmkApplicationObj.Id);
            System.assertEquals('Success', response, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : Test GMK Single Rate Loan with Single Sub Tranche - with billing date, variable interest rate type, Grower Rate = 0
    * @author Kabir Pramanik | 12-10-2024 
    **/
    @isTest
    public static void testGMKSingleRateWithBillingFixedZeroGrowerRate(){
        genesis__Applications__c gmkApplicationObj = [
            SELECT Id,
                My_Program__c
            FROM genesis__Applications__c
            WHERE Coop_Type__c = :PortalConstants.GROWMARK_COOP_TYPE
            LIMIT 1
        ];
        List<genesis__Rate_Card_Setup_Detail__c> rateCardSetupDetailObj = [SELECT Id
                                                                            FROM genesis__Rate_Card_Setup_Detail__c 
                                                                            WHERE genesis__rate_card_setup_header__c = :gmkApplicationObj.My_Program__c 
                                                                            ORDER BY Special_Term_Reference__c, Start_Date__c
        ];
        rateCardSetupDetailObj[0].billing_date__c = System.today().addMonths(10).toStartOfMonth().addDays(-1);
        rateCardSetupDetailObj[0].has_billing_date__c = true;
        rateCardSetupDetailObj[0].Interest_Rate_Type__c = 'Fixed';
        rateCardSetupDetailObj[0].genesis__Interest_Rate__c = 0;
        rateCardSetupDetailObj[0].Participation_Percentage_Dealer__c = 0;
        rateCardSetupDetailObj[0].Participation_Percentage_Dealer_Subsidy__c = 9;
        rateCardSetupDetailObj[0].End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        Database.update(rateCardSetupDetailObj[0], true);

        List<genesis__Application_Pricing_Detail__c> pricingsObj = [
                    SELECT Id 
                    FROM genesis__Application_Pricing_Detail__c 
                    WHERE genesis__Application__c = :gmkApplicationObj.Id
                    AND genesis__Application__r.Coop_Type__c = :PortalConstants.GROWMARK_COOP_TYPE 
                    ORDER BY genesis__Rate_Card_Setup_Detail__r.Special_Term_Reference__c, genesis__Rate_Card_Setup_Detail__r.Start_Date__c
        ];
        pricingsObj.remove(0);
        Database.delete(pricingsObj, true);
        updateStatementCode(gmkApplicationObj, PortalConstants.GROWMARK_COOP_TYPE);
        System.runAs(getAdminUser()) {
            Test.setMock(HttpCalloutMock.class, new NLSBookToCoreMock());
            Test.startTest();
            String response = NLSBookToCoreCalloutClass.bookToCoreLoanFromBackEnd(gmkApplicationObj.Id);
            System.assertEquals('Success', response, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    // Fixed Interest Rate Type End -----------------

    /**
    * @description : Test for GMK Single Rate Loan with multiple child loans
    * @author Kabir Pramanik | 12-11-2024 
    **/
    @isTest
    public static void testCaseGMKBookToCoreSingleRateMultipleSubtrancheSuccess(){
        genesis__Applications__c gmkApplicationObj = [
            SELECT Id
            FROM genesis__Applications__c
            WHERE Coop_Type__c = :PortalConstants.GROWMARK_COOP_TYPE
            LIMIT 1
        ];

        List<genesis__Application_Pricing_Detail__c> pricingsObj = [
                    SELECT Id 
                    FROM genesis__Application_Pricing_Detail__c 
                    WHERE genesis__Application__r.Coop_Type__c = :PortalConstants.GROWMARK_COOP_TYPE 
                    AND (NOT Loan_Number__c LIKE '%-A')
                ];

        Database.delete(pricingsObj, true);
        updateStatementCode(gmkApplicationObj, PortalConstants.GROWMARK_COOP_TYPE);
        System.runAs(getAdminUser()) {
            Test.setMock(HttpCalloutMock.class, new NLSBookToCoreMock());
            Test.startTest();
            String response = NLSBookToCoreCalloutClass.bookToCoreLoanFromBackEnd(gmkApplicationObj.Id);
            System.assertEquals('Success', response, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : Test for GMK Multi Rate Loan with Single Sub Tranche on A tranche 
                    (A sub trahche - witout billing date, variable interest rate type, Grower Rate = FS Index Rate)
    * @author Kabir Pramanik | 12-11-2024 
    **/
    @isTest
    public static void testCaseGMKBookToCoreVariableMultiRateATrancheSingleLoanSuccess() {
        genesis__Applications__c growmarkApplicationObj = [
            SELECT Id,
                My_Program__c 
            FROM genesis__Applications__c
            WHERE Coop_Type__c = :PortalConstants.GROWMARK_COOP_TYPE
            LIMIT 1
        ];
        List<genesis__Rate_Card_Setup_Detail__c> rateCardSetupDetailObj = [SELECT Id
                                                                            FROM genesis__Rate_Card_Setup_Detail__c 
                                                                            WHERE genesis__rate_card_setup_header__c = :growmarkApplicationObj.My_Program__c 
                                                                            ORDER BY Special_Term_Reference__c, Start_Date__c
        ];
        rateCardSetupDetailObj[0].billing_date__c = null;
        rateCardSetupDetailObj[0].has_billing_date__c = false;
        rateCardSetupDetailObj[0].Interest_Rate_Type__c = 'Variable';
        rateCardSetupDetailObj[0].genesis__Interest_Rate__c = 9;
        rateCardSetupDetailObj[0].Participation_Percentage_Dealer__c = 0;
        rateCardSetupDetailObj[0].Participation_Percentage_Dealer_Subsidy__c = 0;
        rateCardSetupDetailObj[0].End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        Database.update(rateCardSetupDetailObj[0], true);

        List<genesis__Application_Pricing_Detail__c> pricingsObj = [
                    SELECT Id 
                    FROM genesis__Application_Pricing_Detail__c 
                    WHERE genesis__Application__c = :growmarkApplicationObj.Id
                    AND genesis__Application__r.Coop_Type__c = :PortalConstants.GROWMARK_COOP_TYPE
                    AND (Loan_Number__c LIKE '%-A')
                    ORDER BY genesis__Rate_Card_Setup_Detail__r.Special_Term_Reference__c, genesis__Rate_Card_Setup_Detail__r.Start_Date__c
        ];
        pricingsObj.remove(0);
        Database.delete(pricingsObj, true);
        updateStatementCode(growmarkApplicationObj, PortalConstants.GROWMARK_COOP_TYPE);
        System.runAs(getAdminUser()) {
            Test.setMock(HttpCalloutMock.class, new NLSBookToCoreMock());
            Test.startTest();
            String response = NLSBookToCoreCalloutClass.bookToCoreLoanFromBackEnd(growmarkApplicationObj.Id);  
            System.assertEquals('Success', response, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : Test for GMK Multi Rate Loan with Single Sub Tranche on A tranche 
                    (A sub trahche - with billing date, fixed interest rate type, Grower Rate = FS Index Rate)
    * @author Kabir Pramanik | 12-11-2024 
    **/
    @isTest
    public static void testCaseGMKBookToCoreFixedMultiRateATrancheSingleLoanSuccess() {
        genesis__Applications__c growmarkApplicationObj = [
            SELECT Id,
                My_Program__c 
            FROM genesis__Applications__c
            WHERE Coop_Type__c = :PortalConstants.GROWMARK_COOP_TYPE
            LIMIT 1
        ];
        List<genesis__Rate_Card_Setup_Detail__c> rateCardSetupDetailObj = [SELECT Id,
                                                                            genesis__rate_card_setup_header__c
                                                                        FROM genesis__Rate_Card_Setup_Detail__c 
                                                                        WHERE genesis__rate_card_setup_header__c = :growmarkApplicationObj.My_Program__c 
                                                                        ORDER BY Special_Term_Reference__c, Start_Date__c
        ];
        rateCardSetupDetailObj[0].billing_date__c = System.today().addMonths(10).toStartOfMonth().addDays(-1);
        rateCardSetupDetailObj[0].has_billing_date__c = true;
        rateCardSetupDetailObj[0].Interest_Rate_Type__c = 'Fixed';
        rateCardSetupDetailObj[0].genesis__Interest_Rate__c = 9;
        rateCardSetupDetailObj[0].Participation_Percentage_Dealer__c = 0;
        rateCardSetupDetailObj[0].Participation_Percentage_Dealer_Subsidy__c = 0;
        rateCardSetupDetailObj[0].End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        Database.update(rateCardSetupDetailObj[0], true);

        List<genesis__Application_Pricing_Detail__c> pricingsObj = [
                    SELECT Id 
                    FROM genesis__Application_Pricing_Detail__c 
                    WHERE genesis__Application__c = :growmarkApplicationObj.Id
                    AND genesis__Application__r.Coop_Type__c = :PortalConstants.GROWMARK_COOP_TYPE
                    AND (Loan_Number__c LIKE '%-A')
                    ORDER BY genesis__Rate_Card_Setup_Detail__r.Special_Term_Reference__c, genesis__Rate_Card_Setup_Detail__r.Start_Date__c
        ];
        pricingsObj.remove(0);
        Database.delete(pricingsObj, true);
        updateStatementCode(growmarkApplicationObj, PortalConstants.GROWMARK_COOP_TYPE);
        System.runAs(getAdminUser()) {
            Test.setMock(HttpCalloutMock.class, new NLSBookToCoreMock());
            Test.startTest();
            String response = NLSBookToCoreCalloutClass.bookToCoreLoanFromBackEnd(growmarkApplicationObj.Id);  
            System.assertEquals('Success', response, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : Test GMK Multi Rate Loan Booking
    * @author Kabir Pramanik | 12-11-2024 
    **/
    @isTest
    public static void testCaseGrowmarkBookToCoreMultiRateSuccess(){
        genesis__Applications__c gmkApplicationObj = [
            SELECT Id
            FROM genesis__Applications__c
            WHERE Coop_Type__c = :PortalConstants.GROWMARK_COOP_TYPE
            LIMIT 1
        ];
        updateStatementCode(gmkApplicationObj, PortalConstants.GROWMARK_COOP_TYPE);
        System.runAs(getAdminUser()) {
            Test.setMock(HttpCalloutMock.class, new NLSBookToCoreMock());
            Test.startTest();
            String response = NLSBookToCoreCalloutClass.bookToCoreLoanFromBackEnd(gmkApplicationObj.Id); 
            System.assertEquals('Success', response, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : Testing the adapter class of NLSBookToCoreCalloutClass with queueable call for GMK
    * @author Kabir Pramanik | 12-11-2024 
    **/
    @IsTest
    public static void testCaseGrowmarkBookToCoreQueueableSuccess(){ 
        genesis__Applications__c gmkApplicationObj = [
            SELECT Id
            FROM genesis__Applications__c
            WHERE Coop_Type__c = :PortalConstants.GROWMARK_COOP_TYPE
            LIMIT 1
        ];
        updateStatementCode(gmkApplicationObj, PortalConstants.GROWMARK_COOP_TYPE);
        System.runAs(getClUser(PortalConstants.GROWMARK_COOP_TYPE)) {
            Test.setMock(HttpCalloutMock.class, new NLSBookToCoreMock());
            Test.startTest();
            NLSBookToCoreCalloutClass callout = new NLSBookToCoreCalloutClass(gmkApplicationObj.Id);
            callout.execute(null);
            Test.stopTest();
            List<clcommon__Log__c> logList = [SELECT Id,
                                                    Name 
                                                FROM clcommon__Log__c 
                                                WHERE Name = 'Loan Booked Notification For Grower'
                                                ORDER BY CreatedDate DESC 
                                                LIMIT 1];
            System.assertEquals(0, logList.size(), PortalConstants.ASSERTION_FAILED);
        }
    }

    // CFA test cases ----------------------------------------

    // Variable Interest Rate Type Start -------------
    /**
    * @description : Single Rate singleStepDate - without billing date, variable, CFAParticipation = 0, Grower Rate = Field Finance Rate
    * @author Kabir Pramanik | 12-10-2024 
    **/
    @isTest
    public static void testCFASingleRateNoBillingVariableZeroParticipationGrowerRateEqualsFFRate(){
        genesis__Applications__c cfaApplicationObj = [
            SELECT Id,
                My_Program__c
            FROM genesis__Applications__c
            WHERE Coop_Type__c = :PortalConstants.CFA_COOP_TYPE
            LIMIT 1
        ];
        cfaApplicationObj.Signing_Method__c = PortalConstants.PAPER_SCANNED;
        Database.update(cfaApplicationObj, true); //signing method 
        List<genesis__Rate_Card_Setup_Detail__c> rateCardSetupDetailObj = [SELECT Id
                                                                            FROM genesis__Rate_Card_Setup_Detail__c 
                                                                            WHERE genesis__rate_card_setup_header__c = :cfaApplicationObj.My_Program__c 
                                                                            ORDER BY Special_Term_Reference__c, Start_Date__c
        ];
        rateCardSetupDetailObj[0].billing_date__c = null;
        rateCardSetupDetailObj[0].has_billing_date__c = false;
        rateCardSetupDetailObj[0].Interest_Rate_Type__c = 'Variable';
        rateCardSetupDetailObj[0].genesis__Interest_Rate__c = 12;
        rateCardSetupDetailObj[0].Participation_Percentage_CFA__c = 0;
        rateCardSetupDetailObj[0].Participation_Percentage_Dealer__c = 0;
        rateCardSetupDetailObj[0].Participation_Percentage_Dealer_Subsidy__c = 0;
        rateCardSetupDetailObj[0].End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        Database.update(rateCardSetupDetailObj[0], true);   //loan closing fee paid by dealer
        genesis__Rate_Card_Setup_Header__c rateCardSetupHeaderObj = [SELECT Id FROM genesis__Rate_Card_Setup_Header__c WHERE Id= :cfaApplicationObj.My_Program__c ];
        rateCardSetupHeaderObj.Dealer_Participate_on_Closing_Fee__c = 'Yes';
        rateCardSetupHeaderObj.Payer_of_Loan_Closing_Fee__c = 'Dealer';
        rateCardSetupHeaderObj.Portion_of_Fee_to_Cover__c = 100;
        Database.upsert(rateCardSetupHeaderObj, true);

        List<genesis__Application_Pricing_Detail__c> pricingsObj = [
                    SELECT Id 
                    FROM genesis__Application_Pricing_Detail__c 
                    WHERE genesis__Application__c = :cfaApplicationObj.Id
                    AND genesis__Application__r.Coop_Type__c = :PortalConstants.CFA_COOP_TYPE 
                    ORDER BY genesis__Rate_Card_Setup_Detail__r.Special_Term_Reference__c, genesis__Rate_Card_Setup_Detail__r.Start_Date__c
        ];
        pricingsObj.remove(0);
        Database.delete(pricingsObj, true);
        updateStatementCode(cfaApplicationObj, PortalConstants.CFA_COOP_TYPE );
        System.runAs(getAdminUser()) {
            Test.setMock(HttpCalloutMock.class, new NLSBookToCoreMock());
            Test.startTest();
            String response = NLSBookToCoreCalloutClass.bookToCoreLoanFromBackEnd(cfaApplicationObj.Id);
            System.assertEquals('Success', response, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : Test Single Rate singleStepDate - without billing date, variable interest type, Grower Rate exceeds Field Finance Rate
    * @author Kabir Pramanik | 12-10-2024 
    **/
    @isTest
    public static void testCFASingleRateNoBillingVariableGrowerRateExceedsFFRate(){
        genesis__Applications__c cfaApplicationObj = [
            SELECT Id,
                My_Program__c
            FROM genesis__Applications__c
            WHERE Coop_Type__c = :PortalConstants.CFA_COOP_TYPE
            LIMIT 1
        ];
        List<genesis__Rate_Card_Setup_Detail__c> rateCardSetupDetailObj = [SELECT Id,
                                                                            genesis__rate_card_setup_header__c
                                                                        FROM genesis__Rate_Card_Setup_Detail__c 
                                                                        WHERE genesis__rate_card_setup_header__c = :cfaApplicationObj.My_Program__c 
                                                                        ORDER BY Special_Term_Reference__c, Start_Date__c
        ];
        rateCardSetupDetailObj[0].billing_date__c = null;
        rateCardSetupDetailObj[0].has_billing_date__c = false;
        rateCardSetupDetailObj[0].Interest_Rate_Type__c = 'Variable';
        rateCardSetupDetailObj[0].genesis__Interest_Rate__c = 14;
        rateCardSetupDetailObj[0].Participation_Percentage_CFA__c = 1;
        rateCardSetupDetailObj[0].Participation_Percentage_Dealer__c = 3;
        rateCardSetupDetailObj[0].Participation_Percentage_Dealer_Subsidy__c = 0;
        rateCardSetupDetailObj[0].End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        Database.update(rateCardSetupDetailObj[0], true);

        List<genesis__Application_Pricing_Detail__c> pricingsObj = [
                    SELECT Id 
                    FROM genesis__Application_Pricing_Detail__c 
                    WHERE genesis__Application__c = :cfaApplicationObj.Id
                    AND genesis__Application__r.Coop_Type__c = :PortalConstants.CFA_COOP_TYPE 
                    ORDER BY genesis__Rate_Card_Setup_Detail__r.Special_Term_Reference__c, genesis__Rate_Card_Setup_Detail__r.Start_Date__c
        ];
        pricingsObj.remove(0);
        Database.delete(pricingsObj, true);
        updateStatementCode(cfaApplicationObj, PortalConstants.CFA_COOP_TYPE );
        System.runAs(getAdminUser()) {
            Test.setMock(HttpCalloutMock.class, new NLSBookToCoreMock());
            Test.startTest();
            String response = NLSBookToCoreCalloutClass.bookToCoreLoanFromBackEnd(cfaApplicationObj.Id);
            System.assertEquals('Success', response, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : Test Single Rate singleStepDate - with billing date, variable interest type, Grower Rate is less than Field Finance Rate
    * @author Kabir Pramanik | 12-10-2024 
    **/
    @isTest
    public static void testCFASingleRateWithBillingVariableGrowerRateUnderFFRate(){
        genesis__Applications__c cfaApplicationObj = [
            SELECT Id,
                My_Program__c
            FROM genesis__Applications__c
            WHERE Coop_Type__c = :PortalConstants.CFA_COOP_TYPE
            LIMIT 1
        ];
        List<genesis__Rate_Card_Setup_Detail__c> rateCardSetupDetailObj = [SELECT Id,
                                                                            genesis__rate_card_setup_header__c
                                                                        FROM genesis__Rate_Card_Setup_Detail__c 
                                                                        WHERE genesis__rate_card_setup_header__c = :cfaApplicationObj.My_Program__c 
                                                                        ORDER BY Special_Term_Reference__c, Start_Date__c
        ];
        rateCardSetupDetailObj[0].billing_date__c = System.today().addMonths(10).toStartOfMonth().addDays(-1);
        rateCardSetupDetailObj[0].has_billing_date__c = true;
        rateCardSetupDetailObj[0].Interest_Rate_Type__c = 'Variable';
        rateCardSetupDetailObj[0].genesis__Interest_Rate__c = 8;
        rateCardSetupDetailObj[0].Participation_Percentage_CFA__c = 1;
        rateCardSetupDetailObj[0].Participation_Percentage_Dealer__c = 0;
        rateCardSetupDetailObj[0].Participation_Percentage_Dealer_Subsidy__c = 3;
        rateCardSetupDetailObj[0].End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        Database.update(rateCardSetupDetailObj[0], true);

        List<genesis__Application_Pricing_Detail__c> pricingsObj = [
                    SELECT Id 
                    FROM genesis__Application_Pricing_Detail__c 
                    WHERE genesis__Application__c = :cfaApplicationObj.Id
                    AND genesis__Application__r.Coop_Type__c = :PortalConstants.CFA_COOP_TYPE 
                    ORDER BY genesis__Rate_Card_Setup_Detail__r.Special_Term_Reference__c, genesis__Rate_Card_Setup_Detail__r.Start_Date__c
        ];
        pricingsObj.remove(0);
        Database.delete(pricingsObj, true);
        updateStatementCode(cfaApplicationObj, PortalConstants.CFA_COOP_TYPE );
        System.runAs(getAdminUser()) {
            Test.setMock(HttpCalloutMock.class, new NLSBookToCoreMock());
            Test.startTest();
            String response = NLSBookToCoreCalloutClass.bookToCoreLoanFromBackEnd(cfaApplicationObj.Id);
            System.assertEquals('Success', response, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description : Test Single Rate singleStepDate - with billing date, variable interest type, Grower Rate = 0
    * @author Kabir Pramanik | 12-10-2024 
    **/
    @isTest
    public static void testCFASingleRateWithBillingVariableZeroGrowerRate(){
        genesis__Applications__c cfaApplicationObj = [
            SELECT Id,
                My_Program__c
            FROM genesis__Applications__c
            WHERE Coop_Type__c = :PortalConstants.CFA_COOP_TYPE
            LIMIT 1
        ];
        List<genesis__Rate_Card_Setup_Detail__c> rateCardSetupDetailObj = [SELECT Id,
                                                                            genesis__rate_card_setup_header__c
                                                                        FROM genesis__Rate_Card_Setup_Detail__c 
                                                                        WHERE genesis__rate_card_setup_header__c = :cfaApplicationObj.My_Program__c 
                                                                        ORDER BY Special_Term_Reference__c, Start_Date__c
        ];
        rateCardSetupDetailObj[0].billing_date__c = System.today().addMonths(10).toStartOfMonth().addDays(-1);
        rateCardSetupDetailObj[0].has_billing_date__c = true;
        rateCardSetupDetailObj[0].Interest_Rate_Type__c = 'Variable';
        rateCardSetupDetailObj[0].genesis__Interest_Rate__c = 0;
        rateCardSetupDetailObj[0].Participation_Percentage_CFA__c = 1;
        rateCardSetupDetailObj[0].Participation_Percentage_Dealer__c = 0;
        rateCardSetupDetailObj[0].Participation_Percentage_Dealer_Subsidy__c = 11;
        rateCardSetupDetailObj[0].End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        Database.update(rateCardSetupDetailObj[0], true);

        List<genesis__Application_Pricing_Detail__c> pricingsObj = [
                    SELECT Id 
                    FROM genesis__Application_Pricing_Detail__c 
                    WHERE genesis__Application__c = :cfaApplicationObj.Id
                    AND genesis__Application__r.Coop_Type__c = :PortalConstants.CFA_COOP_TYPE 
                    ORDER BY genesis__Rate_Card_Setup_Detail__r.Special_Term_Reference__c, genesis__Rate_Card_Setup_Detail__r.Start_Date__c
        ];
        pricingsObj.remove(0);
        Database.delete(pricingsObj, true);
        updateStatementCode(cfaApplicationObj, PortalConstants.CFA_COOP_TYPE );
        System.runAs(getAdminUser()) {
            Test.setMock(HttpCalloutMock.class, new NLSBookToCoreMock());
            Test.startTest();
            String response = NLSBookToCoreCalloutClass.bookToCoreLoanFromBackEnd(cfaApplicationObj.Id);
            System.assertEquals('Success', response, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    //Variable Interest Rate Type End ---------------

    // Fixed Interest Rate Type Start----------------
    /**
    * @description : Single Rate singleStepDate - without billing date, variable, CFAParticipation = 0, Grower Rate = Field Finance Rate
    * @author Kabir Pramanik | 12-10-2024 
    **/
    @isTest
    public static void testCFASingleRateNoBillingFixedZeroParticipationGrowerRateEqualsFFRate(){
        genesis__Applications__c cfaApplicationObj = [
            SELECT Id,
                My_Program__c
            FROM genesis__Applications__c
            WHERE Coop_Type__c = :PortalConstants.CFA_COOP_TYPE
            LIMIT 1
        ];
        List<genesis__Rate_Card_Setup_Detail__c> rateCardSetupDetailObj = [SELECT Id,
                                                                            genesis__rate_card_setup_header__c
                                                                        FROM genesis__Rate_Card_Setup_Detail__c 
                                                                        WHERE genesis__rate_card_setup_header__c = :cfaApplicationObj.My_Program__c 
                                                                        ORDER BY Special_Term_Reference__c, Start_Date__c
        ];
        rateCardSetupDetailObj[0].billing_date__c = null;
        rateCardSetupDetailObj[0].has_billing_date__c = false;
        rateCardSetupDetailObj[0].Interest_Rate_Type__c = 'Fixed';
        rateCardSetupDetailObj[0].genesis__Interest_Rate__c = 12;
        rateCardSetupDetailObj[0].Participation_Percentage_CFA__c = 0;
        rateCardSetupDetailObj[0].Participation_Percentage_Dealer__c = 0;
        rateCardSetupDetailObj[0].Participation_Percentage_Dealer_Subsidy__c = 0;
        rateCardSetupDetailObj[0].End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        Database.update(rateCardSetupDetailObj[0], true);

        List<genesis__Application_Pricing_Detail__c> pricingsObj = [
                    SELECT Id 
                    FROM genesis__Application_Pricing_Detail__c 
                    WHERE genesis__Application__c = :cfaApplicationObj.Id
                    AND genesis__Application__r.Coop_Type__c = :PortalConstants.CFA_COOP_TYPE 
                    ORDER BY genesis__Rate_Card_Setup_Detail__r.Special_Term_Reference__c, genesis__Rate_Card_Setup_Detail__r.Start_Date__c
        ];
        pricingsObj.remove(0);
        Database.delete(pricingsObj, true);
        updateStatementCode(cfaApplicationObj, PortalConstants.CFA_COOP_TYPE );
        System.runAs(getAdminUser()) {
            Test.setMock(HttpCalloutMock.class, new NLSBookToCoreMock());
            Test.startTest();
            String response = NLSBookToCoreCalloutClass.bookToCoreLoanFromBackEnd(cfaApplicationObj.Id);
            System.assertEquals('Success', response, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : Test Single Rate Loan with Single Sub Tranche - without billing date, variable interest type, Grower Rate exceeds Field Finance Rate
    * @author Kabir Pramanik | 12-10-2024 
    **/
    @isTest
    public static void testCFASingleRateNoBillingFixedGrowerRateExceedsFFRate(){
        genesis__Applications__c cfaApplicationObj = [
            SELECT Id,
                My_Program__c
            FROM genesis__Applications__c
            WHERE Coop_Type__c = :PortalConstants.CFA_COOP_TYPE
            LIMIT 1
        ];
        List<genesis__Rate_Card_Setup_Detail__c> rateCardSetupDetailObj = [SELECT Id,
                                                                            genesis__rate_card_setup_header__c
                                                                        FROM genesis__Rate_Card_Setup_Detail__c 
                                                                        WHERE genesis__rate_card_setup_header__c = :cfaApplicationObj.My_Program__c 
                                                                        ORDER BY Special_Term_Reference__c, Start_Date__c
        ];
        rateCardSetupDetailObj[0].billing_date__c = null;
        rateCardSetupDetailObj[0].has_billing_date__c = false;
        rateCardSetupDetailObj[0].Interest_Rate_Type__c = 'Fixed';
        rateCardSetupDetailObj[0].genesis__Interest_Rate__c = 14;
        rateCardSetupDetailObj[0].Participation_Percentage_CFA__c = 1;
        rateCardSetupDetailObj[0].Participation_Percentage_Dealer__c = 3;
        rateCardSetupDetailObj[0].Participation_Percentage_Dealer_Subsidy__c = 0;
        rateCardSetupDetailObj[0].End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        Database.update(rateCardSetupDetailObj[0], true);

        List<genesis__Application_Pricing_Detail__c> pricingsObj = [
                    SELECT Id 
                    FROM genesis__Application_Pricing_Detail__c 
                    WHERE genesis__Application__c = :cfaApplicationObj.Id
                    AND genesis__Application__r.Coop_Type__c = :PortalConstants.CFA_COOP_TYPE 
                    ORDER BY genesis__Rate_Card_Setup_Detail__r.Special_Term_Reference__c, genesis__Rate_Card_Setup_Detail__r.Start_Date__c
        ];
        pricingsObj.remove(0);
        Database.delete(pricingsObj, true);
        updateStatementCode(cfaApplicationObj, PortalConstants.CFA_COOP_TYPE );
        System.runAs(getAdminUser()) {
            Test.setMock(HttpCalloutMock.class, new NLSBookToCoreMock());
            Test.startTest();
            String response = NLSBookToCoreCalloutClass.bookToCoreLoanFromBackEnd(cfaApplicationObj.Id);
            System.assertEquals('Success', response, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : Test Single Rate Loan with Single Sub Tranche - with billing date, variable interest type, Grower Rate is less than Field Finance Rate
    * @author Kabir Pramanik | 12-10-2024 
    **/
    @isTest
    public static void testCFASingleRateWithBillingFixedGrowerRateUnderFFRate(){
        genesis__Applications__c cfaApplicationObj = [
            SELECT Id,
                My_Program__c
            FROM genesis__Applications__c
            WHERE Coop_Type__c = :PortalConstants.CFA_COOP_TYPE
            LIMIT 1
        ];
        List<genesis__Rate_Card_Setup_Detail__c> rateCardSetupDetailObj = [SELECT Id,
                                                                            genesis__rate_card_setup_header__c
                                                                        FROM genesis__Rate_Card_Setup_Detail__c 
                                                                        WHERE genesis__rate_card_setup_header__c = :cfaApplicationObj.My_Program__c 
                                                                        ORDER BY Special_Term_Reference__c, Start_Date__c
        ];
        rateCardSetupDetailObj[0].billing_date__c = System.today().addMonths(10).toStartOfMonth().addDays(-1);
        rateCardSetupDetailObj[0].has_billing_date__c = true;
        rateCardSetupDetailObj[0].Interest_Rate_Type__c = 'Fixed';
        rateCardSetupDetailObj[0].genesis__Interest_Rate__c = 8;
        rateCardSetupDetailObj[0].Participation_Percentage_CFA__c = 1;
        rateCardSetupDetailObj[0].Participation_Percentage_Dealer__c = 0;
        rateCardSetupDetailObj[0].Participation_Percentage_Dealer_Subsidy__c = 3;
        rateCardSetupDetailObj[0].End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        Database.update(rateCardSetupDetailObj[0], true);

        List<genesis__Application_Pricing_Detail__c> pricingsObj = [
                    SELECT Id 
                    FROM genesis__Application_Pricing_Detail__c 
                    WHERE genesis__Application__c = :cfaApplicationObj.Id
                    AND genesis__Application__r.Coop_Type__c = :PortalConstants.CFA_COOP_TYPE 
                    ORDER BY genesis__Rate_Card_Setup_Detail__r.Special_Term_Reference__c, genesis__Rate_Card_Setup_Detail__r.Start_Date__c
        ];
        pricingsObj.remove(0);
        Database.delete(pricingsObj, true);
        updateStatementCode(cfaApplicationObj, PortalConstants.CFA_COOP_TYPE );
        System.runAs(getAdminUser()) {
            Test.setMock(HttpCalloutMock.class, new NLSBookToCoreMock());
            Test.startTest();
            String response = NLSBookToCoreCalloutClass.bookToCoreLoanFromBackEnd(cfaApplicationObj.Id);
            System.assertEquals('Success', response, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    /**
    * @description : Test Single Rate Loan with Single Sub Tranche - with billing date, variable interest type, Grower Rate = 0
    * @author Kabir Pramanik | 12-10-2024 
    **/
    @isTest
    public static void testCFASingleRateWithBillingFixedZeroGrowerRate(){
        genesis__Applications__c cfaApplicationObj = [
            SELECT Id,
                My_Program__c
            FROM genesis__Applications__c
            WHERE Coop_Type__c = :PortalConstants.CFA_COOP_TYPE
            LIMIT 1
        ];
        List<genesis__Rate_Card_Setup_Detail__c> rateCardSetupDetailObj = [SELECT Id,
                                                                            genesis__rate_card_setup_header__c
                                                                        FROM genesis__Rate_Card_Setup_Detail__c 
                                                                        WHERE genesis__rate_card_setup_header__c = :cfaApplicationObj.My_Program__c 
                                                                        ORDER BY Special_Term_Reference__c, Start_Date__c
        ];
        rateCardSetupDetailObj[0].billing_date__c = System.today().addMonths(10).toStartOfMonth().addDays(-1);
        rateCardSetupDetailObj[0].has_billing_date__c = true;
        rateCardSetupDetailObj[0].Interest_Rate_Type__c = 'Fixed';
        rateCardSetupDetailObj[0].genesis__Interest_Rate__c = 0;
        rateCardSetupDetailObj[0].Participation_Percentage_CFA__c = 1;
        rateCardSetupDetailObj[0].Participation_Percentage_Dealer__c = 0;
        rateCardSetupDetailObj[0].Participation_Percentage_Dealer_Subsidy__c = 11;
        rateCardSetupDetailObj[0].End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        Database.update(rateCardSetupDetailObj[0], true);

        List<genesis__Application_Pricing_Detail__c> pricingsObj = [
                    SELECT Id 
                    FROM genesis__Application_Pricing_Detail__c 
                    WHERE genesis__Application__c = :cfaApplicationObj.Id
                    AND genesis__Application__r.Coop_Type__c = :PortalConstants.CFA_COOP_TYPE 
                    ORDER BY genesis__Rate_Card_Setup_Detail__r.Special_Term_Reference__c, genesis__Rate_Card_Setup_Detail__r.Start_Date__c
        ];
        pricingsObj.remove(0);
        Database.delete(pricingsObj, true);
        updateStatementCode(cfaApplicationObj, PortalConstants.CFA_COOP_TYPE );
        System.runAs(getAdminUser()) {
            Test.setMock(HttpCalloutMock.class, new NLSBookToCoreMock());
            Test.startTest();
            String response = NLSBookToCoreCalloutClass.bookToCoreLoanFromBackEnd(cfaApplicationObj.Id);
            System.assertEquals('Success', response, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    //  Fixed Rate Interest Type End ------------------

    /**
    * @description :  Test CFA Single Rate Loan with multiple child loans
    * @author Kabir Pramanik | 12-10-2024  
    **/
    @isTest
    public static void testCaseCFABookToCoreSingleRateMultipleSubtrancheSuccess(){
        genesis__Applications__c cfaApplicationObj = [
            SELECT Id
            FROM genesis__Applications__c
            WHERE Coop_Type__c = :PortalConstants.CFA_COOP_TYPE
            LIMIT 1
        ];
        List<genesis__Application_Pricing_Detail__c> pricingsObj = [
                    SELECT Id 
                    FROM genesis__Application_Pricing_Detail__c 
                    WHERE genesis__Application__r.Coop_Type__c = :PortalConstants.CFA_COOP_TYPE 
                    AND (NOT Loan_Number__c LIKE '%-A')
        ];
        Database.delete(pricingsObj, true);
        updateStatementCode(cfaApplicationObj, PortalConstants.CFA_COOP_TYPE );
        System.runAs(getAdminUser()){
            Test.setMock(HttpCalloutMock.class, new NLSBookToCoreMock());
            Test.startTest();
            String response = NLSBookToCoreCalloutClass.bookToCoreLoanFromBackEnd(cfaApplicationObj.Id);
            System.assertEquals('Success', response, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : Test CFA Multi Rate Loan with Single Sub Tranche on A tranche (A sub trahche - variable interest rate type,
                    CFA Participation Rate = 0, Grower Rate = Field Finance Rate)
    * @author Kabir Pramanik | 12-11-2024 
    **/
    @isTest
    public static void testCaseCFABookToCoreVariableMultiRateATrancheSingleLoanSuccess() {
        genesis__Applications__c cfaApplicationObj = [
            SELECT Id,
                My_Program__c 
            FROM genesis__Applications__c
            WHERE Coop_Type__c = :PortalConstants.CFA_COOP_TYPE
            LIMIT 1
        ];
        List<genesis__Rate_Card_Setup_Detail__c> rateCardSetupDetailObj = [SELECT Id,
                                                                            genesis__rate_card_setup_header__c
                                                                        FROM genesis__Rate_Card_Setup_Detail__c 
                                                                        WHERE genesis__rate_card_setup_header__c = :cfaApplicationObj.My_Program__c 
                                                                        ORDER BY Special_Term_Reference__c, Start_Date__c
        ];
        rateCardSetupDetailObj[0].billing_date__c = null;
        rateCardSetupDetailObj[0].has_billing_date__c = false;
        rateCardSetupDetailObj[0].Interest_Rate_Type__c = 'Variable';
        rateCardSetupDetailObj[0].genesis__Interest_Rate__c = 12;
        rateCardSetupDetailObj[0].Participation_Percentage_CFA__c = 0;
        rateCardSetupDetailObj[0].Participation_Percentage_Dealer__c = 0;
        rateCardSetupDetailObj[0].Participation_Percentage_Dealer_Subsidy__c = 0;
        rateCardSetupDetailObj[0].End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        Database.update(rateCardSetupDetailObj[0], true);

        List<genesis__Application_Pricing_Detail__c> pricingsObj = [
                    SELECT Id 
                    FROM genesis__Application_Pricing_Detail__c 
                    WHERE genesis__Application__c = :cfaApplicationObj.Id
                    AND genesis__Application__r.Coop_Type__c = :PortalConstants.CFA_COOP_TYPE 
                    AND (Loan_Number__c LIKE '%-A')
                    ORDER BY genesis__Rate_Card_Setup_Detail__r.Special_Term_Reference__c, genesis__Rate_Card_Setup_Detail__r.Start_Date__c
        ];
        pricingsObj.remove(0);
        Database.delete(pricingsObj, true);
        updateStatementCode(cfaApplicationObj, PortalConstants.CFA_COOP_TYPE );
        System.runAs(getAdminUser()) {
            Test.setMock(HttpCalloutMock.class, new NLSBookToCoreMock());
            Test.startTest();
            String response = NLSBookToCoreCalloutClass.bookToCoreLoanFromBackEnd(cfaApplicationObj.Id);  
            System.assertEquals('Success', response, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : Test CFA Multi Rate Loan with Single Sub Tranche on A tranche (A sub trahche - fixed interest rate type,
                    CFA Participation Rate = 0, Grower Rate = Field Finance Rate)
    * @author Kabir Pramanik | 12-11-2024 
    **/
    @isTest
    public static void testCaseCFABookToCoreFixedMultiRateATrancheSingleLoanSuccess() {
        genesis__Applications__c cfaApplicationObj = [
            SELECT Id,
                My_Program__c 
            FROM genesis__Applications__c
            WHERE Coop_Type__c = :PortalConstants.CFA_COOP_TYPE
            LIMIT 1
        ];
        List<genesis__Rate_Card_Setup_Detail__c> rateCardSetupDetailObj = [SELECT Id,
                                                                            genesis__rate_card_setup_header__c
                                                                        FROM genesis__Rate_Card_Setup_Detail__c 
                                                                        WHERE genesis__rate_card_setup_header__c = :cfaApplicationObj.My_Program__c 
                                                                        ORDER BY Special_Term_Reference__c, Start_Date__c
        ];
        rateCardSetupDetailObj[0].billing_date__c = System.today().addMonths(10).toStartOfMonth().addDays(-1);
        rateCardSetupDetailObj[0].has_billing_date__c = true;
        rateCardSetupDetailObj[0].Interest_Rate_Type__c = 'Fixed';
        rateCardSetupDetailObj[0].genesis__Interest_Rate__c = 12;
        rateCardSetupDetailObj[0].Participation_Percentage_CFA__c = 0;
        rateCardSetupDetailObj[0].Participation_Percentage_Dealer__c = 0;
        rateCardSetupDetailObj[0].Participation_Percentage_Dealer_Subsidy__c = 0;
        rateCardSetupDetailObj[0].End_Date__c = System.today().addYears(1).toStartOfMonth().addDays(15);
        Database.update(rateCardSetupDetailObj[0], true);

        List<genesis__Application_Pricing_Detail__c> pricingsObj = [
                    SELECT Id 
                    FROM genesis__Application_Pricing_Detail__c 
                    WHERE genesis__Application__c = :cfaApplicationObj.Id
                    AND genesis__Application__r.Coop_Type__c = :PortalConstants.CFA_COOP_TYPE 
                    AND (Loan_Number__c LIKE '%-A')
                    ORDER BY genesis__Rate_Card_Setup_Detail__r.Special_Term_Reference__c, genesis__Rate_Card_Setup_Detail__r.Start_Date__c
        ];
        pricingsObj.remove(0);
        updateStatementCode(cfaApplicationObj, PortalConstants.CFA_COOP_TYPE );
        Database.delete(pricingsObj, true);
        System.runAs(getAdminUser()) {
            Test.setMock(HttpCalloutMock.class, new NLSBookToCoreMock());
            Test.startTest();
            String response = NLSBookToCoreCalloutClass.bookToCoreLoanFromBackEnd(cfaApplicationObj.Id);  
            System.assertEquals('Success', response, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : Test CFA Multi Rate Loan Booking
    * @author Kabir Pramanik | 12-11-2024 
    **/
    @isTest
    public static void testCaseCFABookToCoreMultiRateSuccess(){
        genesis__Applications__c cfaApplicationObj = [
            SELECT Id
            FROM genesis__Applications__c
            WHERE Coop_Type__c = :PortalConstants.CFA_COOP_TYPE
            LIMIT 1
        ];
        updateStatementCode(cfaApplicationObj, PortalConstants.CFA_COOP_TYPE );
        System.runAs(getAdminUser()) {
            Test.setMock(HttpCalloutMock.class, new NLSBookToCoreMock());
            Test.startTest();
            String response = NLSBookToCoreCalloutClass.bookToCoreLoanFromBackEnd(cfaApplicationObj.Id); 
            System.assertEquals('Success', response, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : Testing the adapter class of NLSBookToCoreCalloutClass with queueable call
    * @author Kabir Pramanik | 12-10-2024 
    * @param 
    **/
    @isTest
    public static void testCaseCFABookToCoreQueueableSuccess(){
        genesis__Applications__c cfaApplicationObj = [
            SELECT Id,My_Program__c
            FROM genesis__Applications__c
            WHERE Coop_Type__c = :PortalConstants.CFA_COOP_TYPE
            LIMIT 1
        ];

        genesis__Rate_Card_Setup_Detail__c objRateCardSetupDetail = [SELECT Id
                                                                        FROM genesis__Rate_Card_Setup_Detail__c 
                                                                        WHERE genesis__rate_card_setup_header__c =: cfaApplicationObj.My_Program__c LIMIT 1];
        objRateCardSetupDetail.billing_date__c = System.today().addMonths(10).toStartOfMonth().addDays(-1);
        objRateCardSetupDetail.has_billing_date__c = true;
        Database.update(objRateCardSetupDetail, true);
        updateStatementCode(cfaApplicationObj, PortalConstants.CFA_COOP_TYPE );
        System.runAs(getClUser(PortalConstants.CFA_COOP_TYPE)) {
            Test.setMock(HttpCalloutMock.class, new NLSBookToCoreMock());
            Test.startTest();
            NLSBookToCoreCalloutClass callout = new NLSBookToCoreCalloutClass(cfaApplicationObj.Id);
            callout.execute(null);
            Test.stopTest();
            List<clcommon__Log__c> logList = [SELECT Id,
                                                    Name 
                                                FROM clcommon__Log__c 
                                                WHERE Name = 'Loan Booked Notification For Grower'
                                                ORDER BY CreatedDate DESC 
                                                LIMIT 1];
            System.assertEquals(0, logList.size(), PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description : method to test send email to landus grower queueable
    * @author Suraj Kumar | 05-06-2024 
    **/
    @IsTest
    public static void testSendEmailToGrowerQueueable(){
        genesis__Applications__c applicationObj = getLandusApplication();
        System.runAs(getClUser(PortalConstants.LANDUS_COOP_TYPE)) {
            Test.setMock(HttpCalloutMock.class, new NLSBookToCoreMock());
            Test.startTest();
            NLSBookToCoreCalloutClass callout = new NLSBookToCoreCalloutClass(applicationObj.Id);
            callout.execute(null);
            Test.stopTest();
        }
        List<clcommon__Notification__c> notificatioinObj = [SELECT Id,
                                                                Email_Template__c
                                                            FROM clcommon__Notification__c 
                                                            WHERE Email_Template__c = 'Loan Booked Notification For Grower'
                                                            ORDER BY CreatedDate DESC  
                                                            LIMIT 1];
        System.assertEquals(1, notificatioinObj.size(), PortalConstants.ASSERTION_FAILED);
    }

    /**
    * @description : method to test send email to landus grower backend 
    * @author Suraj Kumar | 05-06-2024 
    **/
    @IsTest
    public static void testSendEmailToGrowerBackend() {
        genesis__Applications__c applicationObj = getLandusApplication();

        System.runAs(getAdminUser()) {
            Test.setMock(HttpCalloutMock.class, new NLSBookToCoreMock());
            Test.startTest();
            String response = NLSBookToCoreCalloutClass.bookToCoreLoanFromBackEnd(applicationObj.Id);
            Test.stopTest();
            List<clcommon__Notification__c> notificatioinObj = [SELECT Id,
                                                                    Email_Template__c
                                                                FROM clcommon__Notification__c 
                                                                WHERE Email_Template__c = 'Loan Booked Notification For Grower'
                                                                ORDER BY CreatedDate DESC 
                                                                LIMIT 1];
            System.assertEquals(1, notificatioinObj.size(), PortalConstants.ASSERTION_FAILED);
            System.assertEquals('Success', response, PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description : method to test send email to landus grower without grower email backend (Book to Core)
    * @author Suraj Kumar | 05-06-2024 
    **/
    @IsTest
    public static void testWithoutGrowerEmailBackend() {
        genesis__Applications__c applicationObj = getLandusApplication();
        Contact growerContactObj = [SELECT Id,
                                            Email
                                        FROM Contact
                                        WHERE Id = :applicationObj.genesis__Contact__c];
        growerContactObj.Email = null;
        Database.update(growerContactObj,true);

        System.runAs(getAdminUser()) {
            Test.setMock(HttpCalloutMock.class, new NLSBookToCoreMock());
            Test.startTest();
            String response = NLSBookToCoreCalloutClass.bookToCoreLoanFromBackEnd(applicationObj.Id);
            Test.stopTest();
            List<clcommon__Log__c> notificatioinObj =  [SELECT Id,
                                                                Name
                                                        FROM clcommon__Log__c 
                                                        WHERE Name = 'Loan Booked Notification For Grower'
                                                        ORDER BY CreatedDate DESC 
                                                        LIMIT 1];
            System.assertEquals(1, notificatioinObj.size(), PortalConstants.ASSERTION_FAILED);
            System.assertEquals('Success', response, PortalConstants.ASSERTION_FAILED);
        }
    }
    /**
    * @description : method to test send email to landus grower without grower email queueable
    * @author Suraj Kumar | 05-06-2024 
    **/
    @IsTest
    public static void testWithoutGrowerEmailQueueable() {
        genesis__Applications__c applicationObj = getLandusApplication();
        Contact growerContactObj = [SELECT Id,
                                            Email
                                        FROM Contact
                                        WHERE Id = :applicationObj.genesis__Contact__c];
        growerContactObj.Email = null;
        Database.update(growerContactObj,true);

        System.runAs(getClUser(PortalConstants.LANDUS_COOP_TYPE)) {
            Test.setMock(HttpCalloutMock.class, new NLSBookToCoreMock());
            Test.startTest();
            NLSBookToCoreCalloutClass callout = new NLSBookToCoreCalloutClass(applicationObj.Id);
            callout.execute(null);
            Test.stopTest();
        }
        List<clcommon__Log__c> notificatioinObj =  [SELECT Id,
                                                            Name
                                                    FROM clcommon__Log__c 
                                                    WHERE Name = 'Loan Booked Notification For Grower'
                                                    ORDER BY CreatedDate DESC 
                                                    LIMIT 1];
        System.assertEquals(1, notificatioinObj.size(), PortalConstants.ASSERTION_FAILED);
    }

    /**
    * @description : method to test send email to landus grower without LoanNumber book to core
    * @author Suraj Kumar | 05-06-2024 
    **/
    @IsTest
    public static void testSendEmailWithoutLoanNumberBackend() {
        genesis__Applications__c applicationObj = getLandusApplication();
        applicationObj.genesis__Loan_Number__c = null;
        Database.update(applicationObj,true);
        System.runAs(getAdminUser()) {
            Test.setMock(HttpCalloutMock.class, new NLSBookToCoreFailuredMock());
            Test.startTest();
            String response = NLSBookToCoreCalloutClass.bookToCoreLoanFromBackEnd(applicationObj.Id);
            Test.stopTest();
            List<clcommon__Log__c> logObj =[SELECT Id 
                                                FROM clcommon__Log__c 
                                                WHERE Name = 'Loan Booked Notification For Grower'];
            System.assertEquals(0, logObj.size(), PortalConstants.ASSERTION_FAILED);
            System.assertEquals(true, response != 'Success', PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description : method to test send email to landus grower without LoanNumber queueable
    * @author Suraj Kumar | 05-06-2024 
    **/
    @IsTest
    public static void testSendEmailWithoutLoanNumberQueueable() {
        genesis__Applications__c applicationObj = getLandusApplication();
        applicationObj.genesis__Loan_Number__c = null;
        Database.update(applicationObj,true);
        System.runAs(getClUser(PortalConstants.LANDUS_COOP_TYPE)) {
            Test.setMock(HttpCalloutMock.class, new NLSBookToCoreMock());
            Test.startTest();
            NLSBookToCoreCalloutClass callout = new NLSBookToCoreCalloutClass(applicationObj.Id);
            callout.execute(null);
            Test.stopTest();

            List<clcommon__Notification__c> emailLogList = [SELECT Id,
                                                                    Email_Status__c 
                                                                FROM clcommon__Notification__c];
            List<clcommon__Log__c> logObj =[SELECT Id 
                                                FROM clcommon__Log__c 
                                                WHERE Name = 'Loan Booked Notification For Grower'];
            System.assertEquals(0, emailLogList.size(), PortalConstants.ASSERTION_FAILED);
            System.assertEquals(0, logObj.size(), PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description : method to test send email to landus grower for Dba
    * @author Suraj Kumar | 05-06-2024 
    **/
    @IsTest
    public static void testSendEmailToGrowerDBA() {
        genesis__Applications__c applicationObj = getLandusApplication();
        clcommon__Legal_Entity__c dBAEntityObj = [SELECT Id
                                                        FROM clcommon__Legal_Entity__c 
                                                        WHERE Name = :PortalConstants.INDIVIDUAL_ENTITY 
                                                        LIMIT 1];
        Account growerAccObj = [SELECT Id,
                                        clcommon__Legal_Entity_Type__c
                                    FROM Account
                                    WHERE Id = : applicationObj.genesis__Account__c];
        growerAccObj.clcommon__Legal_Entity_Type__c = dBAEntityObj.Id;
        Database.update(growerAccObj,true);

        System.runAs(getClUser(PortalConstants.LANDUS_COOP_TYPE)) {
            Test.setMock(HttpCalloutMock.class, new NLSBookToCoreMock());
            Test.startTest();
            NLSBookToCoreCalloutClass callout = new NLSBookToCoreCalloutClass(applicationObj.Id);
            callout.execute(null);
            Test.stopTest();
        }
        List<clcommon__Notification__c> emailLogList = [SELECT Id,
                                                                Email_Status__c 
                                                        FROM clcommon__Notification__c
                                                        ORDER BY CreatedDate DESC 
                                                        LIMIT 1];
        System.assertEquals(1, emailLogList.size(), PortalConstants.ASSERTION_FAILED);
    }

    /**
    * @description : method to test send email to landus grower for Corporation
    * @author Suraj Kumar | 05-06-2024 
    **/
    @IsTest
    public static void testSendEmailToGrowerCorporation() {
        genesis__Applications__c applicationObj = getLandusApplication();
        clcommon__Legal_Entity__c corporationEntityObj = [SELECT Id
                                                        FROM clcommon__Legal_Entity__c 
                                                        WHERE Name = :PortalConstants.CORPORATION 
                                                        LIMIT 1];
        Account growerAccObj = [SELECT Id,
                                        clcommon__Legal_Entity_Type__c
                                    FROM Account
                                    WHERE Id = : applicationObj.genesis__Account__c];
        growerAccObj.clcommon__Legal_Entity_Type__c = corporationEntityObj.Id;
        Database.update(growerAccObj,true);

        System.runAs(getClUser(PortalConstants.LANDUS_COOP_TYPE)) {
            Test.setMock(HttpCalloutMock.class, new NLSBookToCoreMock());
            Test.startTest();
            NLSBookToCoreCalloutClass callout = new NLSBookToCoreCalloutClass(applicationObj.Id);
            callout.execute(null);
            Test.stopTest();
        }
        List<clcommon__Notification__c> emailLogList = [SELECT Id,
                                                                Email_Status__c 
                                                        FROM clcommon__Notification__c
                                                        ORDER BY CreatedDate DESC 
                                                        LIMIT 1];
        System.assertEquals(1, emailLogList.size(), PortalConstants.ASSERTION_FAILED);
    }

    /**
    * @description : method to test without grower entity
    * @author Suraj Kumar | 05-06-2024 
    **/
    @IsTest
    public static void testSendEmailToGrowerWithoutEntity() {
        genesis__Applications__c applicationObj = getLandusApplication();
        Account growerAccObj = [SELECT Id,
                                        clcommon__Legal_Entity_Type__c
                                    FROM Account
                                    WHERE Id = : applicationObj.genesis__Account__c];
        growerAccObj.clcommon__Legal_Entity_Type__c = null;
        Database.update(growerAccObj,true);

        System.runAs(getClUser(PortalConstants.LANDUS_COOP_TYPE)) {
            Test.setMock(HttpCalloutMock.class, new NLSBookToCoreMock());
            Test.startTest();
            NLSBookToCoreCalloutClass callout = new NLSBookToCoreCalloutClass(applicationObj.Id);
            callout.execute(null);
            Test.stopTest();
            List<clcommon__Notification__c> emailLogList = [SELECT Id,
                                                                    Email_Status__c 
                                                            FROM clcommon__Notification__c];
            System.assertEquals(0, emailLogList.size(), PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description : method to test send email to landus grower without LoanNumber
    * @author Suraj Kumar | 05-06-2024 
    **/
    @IsTest
    public static void testSendEmailWithoutLoanNumberCorporation() {
        genesis__Applications__c applicationObj = getLandusApplication();
        applicationObj.genesis__Loan_Number__c = null;
        Database.update(applicationObj,true);

        clcommon__Legal_Entity__c corporationEntityObj = [SELECT Id
                                                        FROM clcommon__Legal_Entity__c 
                                                        WHERE Name = :PortalConstants.CORPORATION 
                                                        LIMIT 1];
        Account growerAccObj = [SELECT Id,
                                        clcommon__Legal_Entity_Type__c
                                    FROM Account
                                    WHERE Id = : applicationObj.genesis__Account__c];
        growerAccObj.clcommon__Legal_Entity_Type__c = corporationEntityObj.Id;
        Database.update(growerAccObj,true);

        System.runAs(getAdminUser()) {
            Test.setMock(HttpCalloutMock.class, new NLSBookToCoreFailuredMock());
            Test.startTest();
            String response = NLSBookToCoreCalloutClass.bookToCoreLoanFromBackEnd(applicationObj.Id);
            System.assertEquals(true ,response != 'Success', PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : method to test send email to landus grower without first principal email
    * @author Suraj Kumar | 05-06-2024 
    **/
    @IsTest
    public static void testWithoutFirstPrincipalEmail() {
        genesis__Applications__c applicationObj = getLandusApplication();
        
        clcommon__Legal_Entity__c corporationEntityObj = [SELECT Id
                                                        FROM clcommon__Legal_Entity__c 
                                                        WHERE Name = :PortalConstants.CORPORATION 
                                                        LIMIT 1];
        Account growerAccObj = [SELECT Id,
                                        clcommon__Legal_Entity_Type__c
                                FROM Account
                                WHERE Id = : applicationObj.genesis__Account__c];
        growerAccObj.clcommon__Legal_Entity_Type__c = corporationEntityObj.Id;
        Database.update(growerAccObj,true);

        List<clcommon__Party__c> principalPartyTypeList = [SELECT Id,
                                                                    clcommon__Contact__c,
                                                                    clcommon__Contact__r.Email 
                                                            FROM clcommon__Party__c 
                                                            WHERE genesis__Application__c = :applicationObj.Id
                                                            AND clcommon__Party_Types__c = :PortalConstants.PRINCIPAL_PARTY_NAME
                                                            AND Principal_Number__c = 1];
        Contact growerContactObj = [SELECT Id,
                                            Email
                                        FROM Contact
                                        WHERE Id = :principalPartyTypeList[0].clcommon__Contact__c];
        growerContactObj.Email = null;
        Database.update(growerContactObj,true);

        System.runAs(getAdminUser()) {
            Test.setMock(HttpCalloutMock.class, new NLSBookToCoreMock());
            Test.startTest();
            String response = NLSBookToCoreCalloutClass.bookToCoreLoanFromBackEnd(applicationObj.Id);
            Test.stopTest();
            List<clcommon__Log__c> logObj =[SELECT Id 
                                            FROM clcommon__Log__c 
                                            WHERE Name = 'Loan Booked Notification For Grower'];
            System.assertEquals(1 , logObj.size(), PortalConstants.ASSERTION_FAILED);
            System.assertEquals('Success', response, PortalConstants.ASSERTION_FAILED);
        }
    }

     /**
    * @description : method to test send email to landus grower queueable and loan Id not fetched but app booked
    * @author Suraj Kumar | 05-06-2024 
    **/
    @IsTest
    public static void testLoanBookedIdNotFetched() {
        genesis__Applications__c applicationObj = getLandusApplication();

        System.runAs(getClUser(PortalConstants.LANDUS_COOP_TYPE)) {
            Test.setMock(HttpCalloutMock.class, new NLSBookToCoreNullDataMock());
            Test.startTest();
            NLSBookToCoreCalloutClass callout = new NLSBookToCoreCalloutClass(applicationObj.Id);
            callout.execute(null);
            Test.stopTest();
        }
        List<clcommon__Notification__c> notificatioinObj = [SELECT Id,
                                                                Email_Template__c
                                                            FROM clcommon__Notification__c 
                                                            WHERE Email_Template__c = 'Loan Booked Notification For Grower'
                                                            ORDER BY CreatedDate DESC 
                                                            LIMIT 1];
        System.assertEquals(1, notificatioinObj.size(), PortalConstants.ASSERTION_FAILED);
    }

    /**
    * @description : method to test send email to landus grower queueable , loan booked child loan Id not fetched
    * @author Suraj Kumar | 05-06-2024 
    **/
    @IsTest
    public static void testChildLoanIdNotFetched() {
        genesis__Applications__c applicationObj = getLandusApplication();

        System.runAs(getClUser(PortalConstants.LANDUS_COOP_TYPE)) {
            Test.setMock(HttpCalloutMock.class, new NLSBookToCoreNullDataMock());
            Test.startTest();
            NLSBookToCoreCalloutClass callout = new NLSBookToCoreCalloutClass(applicationObj.Id);
            callout.execute(null);
            Test.stopTest();
        }
        List<clcommon__Notification__c> notificatioinObj = [SELECT Id,
                                                                Email_Template__c
                                                            FROM clcommon__Notification__c 
                                                            WHERE Email_Template__c = 'Loan Booked Notification For Grower'
                                                            ORDER BY CreatedDate DESC 
                                                            LIMIT 1];
        System.assertEquals(1, notificatioinObj.size(), PortalConstants.ASSERTION_FAILED);
    }

    /**
    * @description : method to test send email to landus grower queueable for CFA admin User
    * @author Suraj Kumar | 05-06-2024 
    **/
    @IsTest
    public static void testSendEmailToGrowerCFAAdmin() {
        genesis__Applications__c applicationObj = getLandusApplication();
        user cfaAdminUserObj = [SELECT Id FROM User WHERE UserName='cfaadminuser@yopmail.com' LIMIT 1];
        System.runAs(cfaAdminUserObj) {
            Test.setMock(HttpCalloutMock.class, new NLSBookToCoreMock());
            Test.startTest();
            NLSBookToCoreCalloutClass callout = new NLSBookToCoreCalloutClass(applicationObj.Id);
            callout.execute(null);
            Test.stopTest();                                               
            List<clcommon__Log__c> logList = [SELECT Id,
                                                    Name 
                                                FROM clcommon__Log__c 
                                                WHERE Name = 'Loan Booked Notification For Grower'
                                                ORDER BY CreatedDate DESC 
                                                LIMIT 1];
            System.assertEquals(0, logList.size(), PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description : Method to test Book to Core Queueable for Conduit Coop Type
    * @author Suraj Kumar | 07-10-2024 
    **/
    @IsTest
    private static void testBookToCoreConduit(){
        genesis__Applications__c applicationObj = getLandusApplication();
        Account dealerAccObj = [SELECT Id,  Coop_Type__c, CFA_Partner_Program__c FROM Account WHERE Id =: applicationObj.Dealer_Name__c];
        dealerAccObj.Coop_Type__c = 'Landus-Conduit';
        Database.update(dealerAccObj,true);
        CFA_Partner_Program__c partnerProgramObj = [SELECT Id FROM CFA_Partner_Program__c WHERE Id = :dealerAccObj.CFA_Partner_Program__c];
        partnerProgramObj.Name = 'Landus-Conduit';
        partnerProgramObj.Short_Name__c ='Landus-Conduit';
        Database.update(partnerProgramObj, true);
        user cfaAdminUserObj = [SELECT Id FROM User WHERE UserName='cfaadminuser@yopmail.com' LIMIT 1];
        System.runAs(cfaAdminUserObj) {
            Test.setMock(HttpCalloutMock.class, new NLSBookToCoreMock());
            Test.startTest();
            NLSBookToCoreCalloutClass callout = new NLSBookToCoreCalloutClass(applicationObj.Id);
            callout.execute(null);
            Test.stopTest();                                           
            List<clcommon__Log__c> logList = [SELECT Id,
                                                    Name 
                                                FROM clcommon__Log__c 
                                                WHERE Name = 'Loan Booked Notification For Grower'
                                                ORDER BY CreatedDate DESC 
                                                LIMIT 1];
            System.assertEquals(0, logList.size(), PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description : Method to test Book To Core Backend for Conduit Coop Type
    * @author Suraj Kumar | 07-10-2024 
    **/
    @isTest
    private static void testBookToCoreConduitBackend(){
        genesis__Applications__c applicationObj = getLandusApplication();
        applicationObj.Signing_Method__c = PortalConstants.IN_PERSON_DOCUSIGN;
        Database.update(applicationObj,true);
        Account dealerAccObj = [SELECT Id,  Coop_Type__c, CFA_Partner_Program__c FROM Account WHERE Id =: applicationObj.Dealer_Name__c];
        dealerAccObj.Coop_Type__c = 'Landus-Conduit';
        Database.update(dealerAccObj,true);
        CFA_Partner_Program__c partnerProgramObj = [SELECT Id FROM CFA_Partner_Program__c WHERE Id = :dealerAccObj.CFA_Partner_Program__c];
        partnerProgramObj.Name = 'Landus-Conduit';
        partnerProgramObj.Short_Name__c ='Landus-Conduit';
        Database.update(partnerProgramObj, true);
        user cfaAdminUserObj = [SELECT Id FROM User WHERE UserName='cfaadminuser@yopmail.com' LIMIT 1];
        System.runAs(cfaAdminUserObj) {
            Test.setMock(HttpCalloutMock.class, new NLSBookToCoreMock());
            Test.startTest();
            String response = NLSBookToCoreCalloutClass.bookToCoreLoanFromBackEnd(applicationObj.Id);
            System.assertEquals('Success', response, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();                                           
            
        }
    }

    /**
    * @description : Test No Pricing Detail on Application
    * @author Kabir Pramanik | 12-12-2024 
    **/
    @isTest
    public static void testCasePricingDetailMissing(){
        genesis__Applications__c cfaApplicationObj = [
            SELECT Id
            FROM genesis__Applications__c
            WHERE Coop_Type__c = :PortalConstants.CFA_COOP_TYPE
            LIMIT 1
        ];
        List<genesis__Application_Pricing_Detail__c> pricingsObj = [
                    SELECT Id 
                    FROM genesis__Application_Pricing_Detail__c 
                    WHERE genesis__Application__c = :cfaApplicationObj.Id
                    AND genesis__Application__r.Coop_Type__c = :PortalConstants.CFA_COOP_TYPE 
        ];
        Database.delete(pricingsObj, true);
        System.runAs(getAdminUser()) {
            Test.setMock(HttpCalloutMock.class, new NLSBookToCoreFailuredMock());
            Test.startTest();
            String response = NLSBookToCoreCalloutClass.bookToCoreLoanFromBackEnd(cfaApplicationObj.Id);
            System.assertEquals(CustomMessageConstants.APPLICATION_NOT_SUBMITTED, response, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : Test Dealer tier missing
    * @author Kabir Pramanik | 12-12-2024 
    **/
    @isTest
    public static void testCaseDealerTierMissing(){
        genesis__Applications__c cfaApplicationObj = [
            SELECT Id,
                Dealer_Name__c
            FROM genesis__Applications__c
            WHERE Coop_Type__c = :PortalConstants.CFA_COOP_TYPE
            LIMIT 1
        ];
        Account dealerAccObj = [SELECT Id
                                FROM Account
                                WHERE Id= :cfaApplicationObj.Dealer_Name__c];
        dealerAccObj.Tier__c = null;
        Database.update(dealerAccObj, true);
        System.runAs(getAdminUser()) {
            Test.setMock(HttpCalloutMock.class, new NLSBookToCoreFailuredMock());
            Test.startTest();
            String response = NLSBookToCoreCalloutClass.bookToCoreLoanFromBackEnd(cfaApplicationObj.Id);
            System.assertEquals(CustomMessageConstants.DEALER_PRICING_TIER_MISSING, response, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : Test SSN not of 9 numbers for Sole-Prop
    * @author Kabir Pramanik | 12-13-2024 
    **/
    @isTest
    public static void testCaseSolePropSsnError(){
        genesis__Applications__c cfaApplicationObj = [
            SELECT Id,
                genesis__Contact__c
            FROM genesis__Applications__c
            WHERE Coop_Type__c = :PortalConstants.CFA_COOP_TYPE
            LIMIT 1
        ];
        Contact growerContactObj = [SELECT Id
                                FROM Contact
                                WHERE Id= :cfaApplicationObj.genesis__Contact__c
                                LIMIT 1];
        growerContactObj.genesis__SSN__c = '1234';
        Database.update(growerContactObj, true);
        System.runAs(getAdminUser()) {
            Test.setMock(HttpCalloutMock.class, new NLSBookToCoreFailuredMock());
            Test.startTest();
            String response = NLSBookToCoreCalloutClass.bookToCoreLoanFromBackEnd(cfaApplicationObj.Id);
            System.assertEquals(ConstantValues.SOMETHING_WENT_WRONG, response, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : Test SSN not of 9 numbers for Sole-Prop for GMK
    * @author Kabir Pramanik | 12-13-2024 
    **/
    @isTest
    public static void testCaseGMKSolePropSsnError(){
        genesis__Applications__c gmkApplicationObj = [
            SELECT Id,
                genesis__Contact__c
            FROM genesis__Applications__c
            WHERE Coop_Type__c = :PortalConstants.GROWMARK_COOP_TYPE
            LIMIT 1
        ];
        Contact growerContactObj = [SELECT Id
                                FROM Contact
                                WHERE Id= :gmkApplicationObj.genesis__Contact__c
                                LIMIT 1];
        growerContactObj.genesis__SSN__c = '1234';
        Database.update(growerContactObj, true);
        updateStatementCode(gmkApplicationObj, PortalConstants.GROWMARK_COOP_TYPE);
        System.runAs(getAdminUser()) {
            Test.setMock(HttpCalloutMock.class, new NLSBookToCoreFailuredMock());
            Test.startTest();
            String response = NLSBookToCoreCalloutClass.bookToCoreLoanFromBackEnd(gmkApplicationObj.Id);
            System.assertEquals(ConstantValues.SOMETHING_WENT_WRONG, response, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : Test taxId not of 9 numbers for Corporation
    * @author Kabir Pramanik | 12-13-2024 
    **/
    @isTest
    public static void testCaseCorporationTaxIdError(){
        genesis__Applications__c cfaApplicationObj = [
            SELECT Id,
                genesis__Account__c,
                genesis__Account__r.genesis__Business_Information__c
            FROM genesis__Applications__c
            WHERE Coop_Type__c = :PortalConstants.CFA_COOP_TYPE
            LIMIT 1
        ];
        clcommon__Legal_Entity__c corporationEntityObj = [SELECT Id
                                                        FROM clcommon__Legal_Entity__c 
                                                        WHERE Name = :PortalConstants.CORPORATION 
                                                        LIMIT 1];
        Account borrowerAccountObj = [SELECT Id
                                    FROM Account
                                    WHERE Id = :cfaApplicationObj.genesis__Account__c
                                    LIMIT 1];
                                    
        borrowerAccountObj.clcommon__Legal_Entity_Type__c = corporationEntityObj.Id;
        Database.update(borrowerAccountObj, true);
        genesis__Business_Information__c borrowerBusinessInfoObj = [SELECT Id
                                                                    FROM genesis__Business_Information__c
                                                                    WHERE Id = :cfaApplicationObj.genesis__Account__r.genesis__Business_Information__c
                                                                    LIMIT 1];
        borrowerBusinessInfoObj.genesis__Tax_Identification_Number__c = '1234';
        Database.update(borrowerBusinessInfoObj, true);
        System.runAs(getAdminUser()) {
            Test.setMock(HttpCalloutMock.class, new NLSBookToCoreFailuredMock());
            Test.startTest();
            String response = NLSBookToCoreCalloutClass.bookToCoreLoanFromBackEnd(cfaApplicationObj.Id);
            System.assertEquals(ConstantValues.SOMETHING_WENT_WRONG, response, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : Test taxId not of 9 numbers for Corporation for GMK
    * @author Kabir Pramanik | 12-13-2024 
    **/
    @isTest
    public static void testCaseGMKCorporationTaxIdError(){
        genesis__Applications__c gmkApplicationObj = [
            SELECT Id,
                genesis__Account__c,
                genesis__Account__r.genesis__Business_Information__c
            FROM genesis__Applications__c
            WHERE Coop_Type__c = :PortalConstants.GROWMARK_COOP_TYPE
            LIMIT 1
        ];
        clcommon__Legal_Entity__c corporationEntityObj = [SELECT Id
                                                        FROM clcommon__Legal_Entity__c 
                                                        WHERE Name = :PortalConstants.CORPORATION 
                                                        LIMIT 1];
        Account borrowerAccountObj = [SELECT Id
                                    FROM Account
                                    WHERE Id = :gmkApplicationObj.genesis__Account__c
                                    LIMIT 1];
                                    
        borrowerAccountObj.clcommon__Legal_Entity_Type__c = corporationEntityObj.Id;
        Database.update(borrowerAccountObj, true);
        genesis__Business_Information__c borrowerBusinessInfoObj = [SELECT Id
                                                                    FROM genesis__Business_Information__c
                                                                    WHERE Id = :gmkApplicationObj.genesis__Account__r.genesis__Business_Information__c
                                                                    LIMIT 1];
        borrowerBusinessInfoObj.genesis__Tax_Identification_Number__c = '1234';
        Database.update(borrowerBusinessInfoObj, true);
        updateStatementCode(gmkApplicationObj, PortalConstants.GROWMARK_COOP_TYPE);
        System.runAs(getAdminUser()) {
            Test.setMock(HttpCalloutMock.class, new NLSBookToCoreFailuredMock());
            Test.startTest();
            String response = NLSBookToCoreCalloutClass.bookToCoreLoanFromBackEnd(gmkApplicationObj.Id);
            System.assertEquals(ConstantValues.SOMETHING_WENT_WRONG, response, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    
    /**
    * @description : Test null check for Grower CIF number
    * @author Kabir Pramanik | 12-13-2024 
    **/
    @isTest
    public static void testCaseGrowerCifMissing(){
        genesis__Applications__c cfaApplicationObj = [
            SELECT Id,
                genesis__Account__c
            FROM genesis__Applications__c
            WHERE Coop_Type__c = :PortalConstants.CFA_COOP_TYPE
            LIMIT 1
        ];
        Account growerAccountObj = [SELECT Id
                                FROM Account
                                WHERE Id= :cfaApplicationObj.genesis__Account__c];
        growerAccountObj.CIF_Number__c = null;
        Database.update(growerAccountObj, true);
        System.runAs(getAdminUser()) {
            Test.setMock(HttpCalloutMock.class, new NLSBookToCoreFailuredMock());
            Test.startTest();
            String response = NLSBookToCoreCalloutClass.bookToCoreLoanFromBackEnd(cfaApplicationObj.Id);
            System.assertEquals(CustomMessageConstants.GROWER_CIF_MISSING, response, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : Test null check for dealer cif number
    * @author Kabir Pramanik | 12-13-2024 
    **/
    @isTest
    public static void testCaseDealerCifMissing(){
        genesis__Applications__c cfaApplicationObj = [
            SELECT Id,
                Dealer_Name__c
            FROM genesis__Applications__c
            WHERE Coop_Type__c = :PortalConstants.CFA_COOP_TYPE
            LIMIT 1
        ];
        Account dealerAccountObj = [SELECT Id
                                FROM Account
                                WHERE Id= :cfaApplicationObj.Dealer_Name__c];
        dealerAccountObj.CIF_Number__c = null;
        Database.update(dealerAccountObj, true);
        System.runAs(getAdminUser()) {
            Test.setMock(HttpCalloutMock.class, new NLSBookToCoreFailuredMock());
            Test.startTest();
            String response = NLSBookToCoreCalloutClass.bookToCoreLoanFromBackEnd(cfaApplicationObj.Id);
            System.assertEquals(CustomMessageConstants.DEALER_CIF_MISSING, response, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    
    /**
    * @description :Test null check for loan number of application
    * @author Kabir Pramanik | 12-13-2024 
    **/
    @isTest
    public static void testCaseApplicationLoanNumberMissing(){
        genesis__Applications__c cfaApplicationObj = [
            SELECT Id
            FROM genesis__Applications__c
            WHERE Coop_Type__c = :PortalConstants.CFA_COOP_TYPE
            LIMIT 1
        ];
        cfaApplicationObj.genesis__Loan_Number__c = null;
        Database.update(cfaApplicationObj, true);
        System.runAs(getAdminUser()) {
            Test.setMock(HttpCalloutMock.class, new NLSBookToCoreFailuredMock());
            Test.startTest();
            String response = NLSBookToCoreCalloutClass.bookToCoreLoanFromBackEnd(cfaApplicationObj.Id);
            System.assertEquals(CustomMessageConstants.LOAN_NUMBER_MISSING, response, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : Test null check for tax id of Corporation of application
    * @author Kabir Pramanik | 12-13-2024 
    **/
    @isTest
    public static void testCaseCorporationNullTaxIdError(){
        genesis__Applications__c cfaApplicationObj = [
            SELECT Id,
                genesis__Account__c,
                genesis__Account__r.genesis__Business_Information__c
            FROM genesis__Applications__c
            WHERE Coop_Type__c = :PortalConstants.CFA_COOP_TYPE
            LIMIT 1
        ];
        clcommon__Legal_Entity__c corporationEntityObj =  [SELECT Id
                                                        FROM clcommon__Legal_Entity__c 
                                                        WHERE Name = :PortalConstants.CORPORATION 
                                                        LIMIT 1];
        Account borrowerAccountObj = [SELECT Id
                                    FROM Account
                                    WHERE Id = : cfaApplicationObj.genesis__Account__c
                                    LIMIT 1];
                                    
        borrowerAccountObj.clcommon__Legal_Entity_Type__c = corporationEntityObj.Id;
        Database.update(borrowerAccountObj, true);
        genesis__Business_Information__c borrowerBusinessInfoObj = [SELECT Id
                                                                    FROM genesis__Business_Information__c
                                                                    WHERE Id = : cfaApplicationObj.genesis__Account__r.genesis__Business_Information__c
                                                                    LIMIT 1];
        borrowerBusinessInfoObj.genesis__Tax_Identification_Number__c = null;
        Database.update(borrowerBusinessInfoObj, true);
        System.runAs(getAdminUser()) {
            Test.setMock(HttpCalloutMock.class, new NLSBookToCoreFailuredMock());
            Test.startTest();
            String response = NLSBookToCoreCalloutClass.bookToCoreLoanFromBackEnd(cfaApplicationObj.Id);
            System.assertEquals(CustomMessageConstants.GROWER_TAXID_MISSING, response, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : Test null check for SSN of Sole-Prop of application
    * @author Kabir Pramanik | 12-13-2024 
    **/
    @isTest
    public static void testCaseSolePropNullSsnError(){
        genesis__Applications__c cfaApplicationObj = [
            SELECT Id,
                genesis__Contact__c
            FROM genesis__Applications__c
            WHERE Coop_Type__c = :PortalConstants.CFA_COOP_TYPE
            LIMIT 1
        ];
        Contact growerContactObj = [SELECT Id
                                FROM Contact
                                WHERE Id= :cfaApplicationObj.genesis__Contact__c
                                LIMIT 1];
        growerContactObj.genesis__SSN__c = null;
        Database.update(growerContactObj, true);
        System.runAs(getAdminUser()) {
            Test.setMock(HttpCalloutMock.class, new NLSBookToCoreFailuredMock());
            Test.startTest();
            String response = NLSBookToCoreCalloutClass.bookToCoreLoanFromBackEnd(cfaApplicationObj.Id);
            System.assertEquals(CustomMessageConstants.GROWER_SSN_MISSING, response, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description :Test null check for maturity date of application
    * @author Kabir Pramanik | 12-13-2024 
    **/
    @isTest
    public static void testCaseMaturityDataMissing(){
        genesis__Applications__c cfaApplicationObj = [
            SELECT Id
            FROM genesis__Applications__c
            WHERE Coop_Type__c = :PortalConstants.CFA_COOP_TYPE
            LIMIT 1
        ];
        cfaApplicationObj.genesis__Maturity_Date__c = null;
        Database.update(cfaApplicationObj, true);
        System.runAs(getAdminUser()) {
            Test.setMock(HttpCalloutMock.class, new NLSBookToCoreFailuredMock());
            Test.startTest();
            String response = NLSBookToCoreCalloutClass.bookToCoreLoanFromBackEnd(cfaApplicationObj.Id);
            System.assertEquals(CustomMessageConstants.MATURITY_DATE_MISSING, response, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : Test null check for crop year of application
    * @author Kabir Pramanik | 12-13-2024 
    **/
    @isTest
    public static void testCaseCropYearMissing(){
        genesis__Applications__c cfaApplicationObj = [
            SELECT Id
            FROM genesis__Applications__c
            WHERE Coop_Type__c = :PortalConstants.CFA_COOP_TYPE
            LIMIT 1
        ];
        cfaApplicationObj.Crop_Year__c = null;
        Database.update(cfaApplicationObj, true);
        System.runAs(getAdminUser()) {
            Test.setMock(HttpCalloutMock.class, new NLSBookToCoreFailuredMock());
            Test.startTest();
            String response = NLSBookToCoreCalloutClass.bookToCoreLoanFromBackEnd(cfaApplicationObj.Id);
            System.assertEquals(CustomMessageConstants.CROP_YEAR_MISSING, response, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    
    /**
    * @description : Test null check for gurantee of application
    * @author Kabir Pramanik | 12-13-2024 
    **/
    @isTest
    public static void testCaseGuranteeMissing(){
        genesis__Applications__c cfaApplicationObj = [
            SELECT Id
            FROM genesis__Applications__c
            WHERE Coop_Type__c = :PortalConstants.CFA_COOP_TYPE
            LIMIT 1
        ];
        cfaApplicationObj.Guarantee__c = null;
        Database.update(cfaApplicationObj, true);
        System.runAs(getAdminUser()) {
            Test.setMock(HttpCalloutMock.class, new NLSBookToCoreFailuredMock());
            Test.startTest();
            String response = NLSBookToCoreCalloutClass.bookToCoreLoanFromBackEnd(cfaApplicationObj.Id);
            System.assertEquals(CustomMessageConstants.APPLICATION_GURANTEE_MISSING, response, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    
    /**
    * @description : Test null check for loan amount of application
    * @author Kabir Pramanik | 12-13-2024 
    **/
    @isTest
    public static void testCaseLoanAmountMissing(){
        genesis__Applications__c cfaApplicationObj = [
            SELECT Id
            FROM genesis__Applications__c
            WHERE Coop_Type__c = :PortalConstants.CFA_COOP_TYPE
            LIMIT 1
        ];
        cfaApplicationObj.genesis__Loan_Amount__c = null;
        Database.update(cfaApplicationObj, true);
        System.runAs(getAdminUser()) {
            Test.setMock(HttpCalloutMock.class, new NLSBookToCoreFailuredMock());
            Test.startTest();
            String response = NLSBookToCoreCalloutClass.bookToCoreLoanFromBackEnd(cfaApplicationObj.Id);
            System.assertEquals(CustomMessageConstants.APPLICATION_LOAN_AMOUNT_MISSING, response, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    
    /**
    * @description : Test null check for signing method of application
    * @author Kabir Pramanik | 12-13-2024 
    **/
    @isTest
    public static void testCaseSigningMethodMissing(){
        genesis__Applications__c cfaApplicationObj = [
            SELECT Id
            FROM genesis__Applications__c
            WHERE Coop_Type__c = :PortalConstants.CFA_COOP_TYPE
            LIMIT 1
        ];
        cfaApplicationObj.Signing_Method__c = null;
        Database.update(cfaApplicationObj, true);
        System.runAs(getAdminUser()) {
            Test.setMock(HttpCalloutMock.class, new NLSBookToCoreFailuredMock());
            Test.startTest();
            String response = NLSBookToCoreCalloutClass.bookToCoreLoanFromBackEnd(cfaApplicationObj.Id);
            System.assertEquals(CustomMessageConstants.SIGNING_METHOD_MISSING, response, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : Test null check for child loan number of application
    * @author Kabir Pramanik | 12-13-2024 
    **/
    @isTest
    public static void testCaseChildLoanNumberMissing(){
        genesis__Applications__c cfaApplicationObj = [
            SELECT Id
            FROM genesis__Applications__c
            WHERE Coop_Type__c = :PortalConstants.CFA_COOP_TYPE
            LIMIT 1
        ];
        List<genesis__Application_Pricing_Detail__c> pricingsObj = [
                    SELECT Id 
                    FROM genesis__Application_Pricing_Detail__c 
                    WHERE genesis__Application__c = :cfaApplicationObj.Id
                    AND genesis__Application__r.Coop_Type__c = :PortalConstants.CFA_COOP_TYPE 
                    AND (Loan_Number__c LIKE '%-A')
        ];
        pricingsObj[0].Loan_Number__c = null;
        Database.update(pricingsObj[0], true);
        System.runAs(getAdminUser()) {
            Test.startTest();
            String response = NLSBookToCoreCalloutClass.bookToCoreLoanFromBackEnd(cfaApplicationObj.Id);
            System.assertEquals(true, response != 'Success', PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : Test null check on My Program Descriptoin
    * @author Kabir Pramanik | 12-13-2024 
    **/
    @isTest
    public static void testCaseMyProgramDescriptionMissing(){
        genesis__Applications__c cfaApplicationObj = [
            SELECT Id,
                My_Program__c
            FROM genesis__Applications__c
            WHERE Coop_Type__c = :PortalConstants.CFA_COOP_TYPE
            LIMIT 1
        ];
        genesis__Rate_Card_Setup_Detail__c objRateCardSetupDetail = [SELECT Id
                                                                    FROM genesis__Rate_Card_Setup_Detail__c 
                                                                    WHERE genesis__rate_card_setup_header__c =: cfaApplicationObj.My_Program__c LIMIT 1];
        objRateCardSetupDetail.Description__c = null;
        Database.update(objRateCardSetupDetail, true);
        System.runAs(getAdminUser()) {
            Test.startTest();
            String response = NLSBookToCoreCalloutClass.bookToCoreLoanFromBackEnd(cfaApplicationObj.Id);
            System.assertEquals(CustomMessageConstants.LOAN_DESCRIPTION_MISSING, response, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : Test null check on Intertest Rate
    * @author Kabir Pramanik | 12-13-2024 
    **/
    @isTest
    public static void testCaseLoanInterestRateMissing(){
        genesis__Applications__c cfaApplicationObj = [
            SELECT Id,
                My_Program__c
            FROM genesis__Applications__c
            WHERE Coop_Type__c = :PortalConstants.CFA_COOP_TYPE
            LIMIT 1
        ];
        genesis__Rate_Card_Setup_Detail__c objRateCardSetupDetail = [SELECT Id
                                                                    FROM genesis__Rate_Card_Setup_Detail__c 
                                                                    WHERE genesis__rate_card_setup_header__c =: cfaApplicationObj.My_Program__c LIMIT 1];
        objRateCardSetupDetail.genesis__Interest_Rate__c = null;
        Database.update(objRateCardSetupDetail, true);
        System.runAs(getAdminUser()) {
            Test.startTest();
            String response = NLSBookToCoreCalloutClass.bookToCoreLoanFromBackEnd(cfaApplicationObj.Id);
            System.assertEquals(CustomMessageConstants.INTEREST_RATE_MISSING, response, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    
    /**
    * @description : Test null check on Interest Rate Type
    * @author Kabir Pramanik | 12-13-2024 
    **/
    @isTest
    public static void testCaseLoanInterestRateTypeMissing(){
        genesis__Applications__c cfaApplicationObj = [
            SELECT Id,
                My_Program__c
            FROM genesis__Applications__c
            WHERE Coop_Type__c = :PortalConstants.CFA_COOP_TYPE
            LIMIT 1
        ];
        genesis__Rate_Card_Setup_Detail__c objRateCardSetupDetail = [SELECT Id
                                                                    FROM genesis__Rate_Card_Setup_Detail__c 
                                                                    WHERE genesis__rate_card_setup_header__c =: cfaApplicationObj.My_Program__c LIMIT 1];
        objRateCardSetupDetail.Interest_Rate_Type__c = null;
        Database.update(objRateCardSetupDetail, true);
        System.runAs(getAdminUser()) {
            Test.startTest();
            String response = NLSBookToCoreCalloutClass.bookToCoreLoanFromBackEnd(cfaApplicationObj.Id);
            System.assertEquals(CustomMessageConstants.INTEREST_RATE_TYPE_MISSING, response, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    
    /**
    * @description : Test null check on CFA Participation Rate
    * @author Kabir Pramanik | 12-13-2024 
    **/
    @isTest
    public static void testCaseCfaParticipationRateMissing(){
        genesis__Applications__c cfaApplicationObj = [
            SELECT Id,
                My_Program__c
            FROM genesis__Applications__c
            WHERE Coop_Type__c = :PortalConstants.CFA_COOP_TYPE
            LIMIT 1
        ];
        genesis__Rate_Card_Setup_Detail__c objRateCardSetupDetail = [SELECT Id
                                                                    FROM genesis__Rate_Card_Setup_Detail__c 
                                                                    WHERE genesis__rate_card_setup_header__c =: cfaApplicationObj.My_Program__c LIMIT 1];
        objRateCardSetupDetail.Participation_Percentage_CFA__c = null;
        Database.update(objRateCardSetupDetail, true);
        System.runAs(getAdminUser()) {
            Test.startTest();
            String response = NLSBookToCoreCalloutClass.bookToCoreLoanFromBackEnd(cfaApplicationObj.Id);
            System.assertEquals(CustomMessageConstants.CFA_PARTICIPATION_RATE_MISSING, response, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    
    /**
    * @description : Test null check on Rate Card Setup Detail Start Date
    * @author Kabir Pramanik | 12-13-2024 
    **/
    @isTest
    public static void testCaseLoanStartDateMissing(){
        genesis__Applications__c cfaApplicationObj = [
            SELECT Id,
                My_Program__c
            FROM genesis__Applications__c
            WHERE Coop_Type__c = :PortalConstants.CFA_COOP_TYPE
            LIMIT 1
        ];
        genesis__Rate_Card_Setup_Detail__c objRateCardSetupDetail = [SELECT Id
                                                                    FROM genesis__Rate_Card_Setup_Detail__c 
                                                                    WHERE genesis__rate_card_setup_header__c =: cfaApplicationObj.My_Program__c LIMIT 1];
        objRateCardSetupDetail.Start_Date__c = null;
        Database.update(objRateCardSetupDetail, true);
        System.runAs(getAdminUser()) {
            Test.startTest();
            String response = NLSBookToCoreCalloutClass.bookToCoreLoanFromBackEnd(cfaApplicationObj.Id);
            System.assertEquals(CustomMessageConstants.START_DATE_MISSING, response, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    
    /**
    * @description : Test null check on Rate Card Setup Detail End Date
    * @author Kabir Pramanik | 12-13-2024 
    **/
    @isTest
    public static void testCaseLoanEndDateMissing(){
        genesis__Applications__c cfaApplicationObj = [
            SELECT Id,
                My_Program__c
            FROM genesis__Applications__c
            WHERE Coop_Type__c = :PortalConstants.CFA_COOP_TYPE
            LIMIT 1
        ];
        genesis__Rate_Card_Setup_Detail__c objRateCardSetupDetail = [SELECT Id
                                                                    FROM genesis__Rate_Card_Setup_Detail__c 
                                                                    WHERE genesis__rate_card_setup_header__c =: cfaApplicationObj.My_Program__c LIMIT 1];
        objRateCardSetupDetail.End_Date__c = null;
        Database.update(objRateCardSetupDetail, true);
        System.runAs(getAdminUser()) {
            Test.startTest();
            String response = NLSBookToCoreCalloutClass.bookToCoreLoanFromBackEnd(cfaApplicationObj.Id);
            System.assertEquals(CustomMessageConstants.END_DATE_MISSING, response, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    
    /**
    * @description : Test null check for Payer of Loan CLosing Fee
    * @author Kabir Pramanik | 12-13-2024 
    **/
    @isTest
    public static void testCasePayerOfLoanCLosingFeeMissing(){
        genesis__Applications__c cfaApplicationObj = [
            SELECT Id,
                My_Program__c
            FROM genesis__Applications__c
            WHERE Coop_Type__c = :PortalConstants.CFA_COOP_TYPE
            LIMIT 1
        ];
        genesis__Rate_Card_Setup_Header__c rateCardSetupHeaderObj = [SELECT Id
                                                                    FROM genesis__Rate_Card_Setup_Header__c 
                                                                    WHERE Id =: cfaApplicationObj.My_Program__c LIMIT 1];
        rateCardSetupHeaderObj.Payer_of_Loan_Closing_Fee__c = null;
        Database.update(rateCardSetupHeaderObj, true);
        System.runAs(getAdminUser()) {
            Test.startTest();
            String response = NLSBookToCoreCalloutClass.bookToCoreLoanFromBackEnd(cfaApplicationObj.Id);
            System.assertEquals(CustomMessageConstants.PAYER_MISSING, response, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    
    /**
    * @description : Test null check on Loan Fee Advanced On field if the Loan closing fee payer is Grower
    * @author Kabir Pramanik | 12-13-2024 
    **/
    @isTest
    public static void testCaseLoanFeeAdvancedOnMissing(){
        genesis__Applications__c cfaApplicationObj = [
            SELECT Id,
                My_Program__c
            FROM genesis__Applications__c
            WHERE Coop_Type__c = :PortalConstants.CFA_COOP_TYPE
            LIMIT 1
        ];
        genesis__Rate_Card_Setup_Header__c rateCardSetupHeaderObj = [SELECT Id
                                                                    FROM genesis__Rate_Card_Setup_Header__c 
                                                                    WHERE Id =: cfaApplicationObj.My_Program__c LIMIT 1];
        rateCardSetupHeaderObj.Payer_of_Loan_Closing_Fee__c = 'Grower';
        rateCardSetupHeaderObj.Loan_Fee_Advanced_On__c = null;
        Database.update(rateCardSetupHeaderObj, true);
        System.runAs(getAdminUser()) {
            Test.startTest();
            String response = NLSBookToCoreCalloutClass.bookToCoreLoanFromBackEnd(cfaApplicationObj.Id);
            System.assertEquals(CustomMessageConstants.LOAN_NUMBER_ADVANCED_ON_MISSING, response, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    
    /**
    * @description : Test null check on Dealer City
    * @author Kabir Pramanik | 12-13-2024 
    **/
    @isTest
    public static void testCaseDealerCityMissing(){
        genesis__Applications__c cfaApplicationObj = [
            SELECT Id,
                Dealer_Name__c
            FROM genesis__Applications__c
            WHERE Coop_Type__c = :PortalConstants.CFA_COOP_TYPE
            LIMIT 1
        ];
        clcommon__Address__c  dealerAddress= [SELECT Id
                                FROM clcommon__Address__c
                                WHERE clcommon__Account__c = :cfaApplicationObj.Dealer_Name__c
                                LIMIT 1];
        dealerAddress.clcommon__City__c = null;
        Database.update(dealerAddress, true);
        System.runAs(getAdminUser()) {
            Test.startTest();
            String response = NLSBookToCoreCalloutClass.bookToCoreLoanFromBackEnd(cfaApplicationObj.Id);
            System.assertEquals(CustomMessageConstants.DEALER_CITY_MISSING, response, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    
    /**
    * @description : Test null cheeck on Dealer State
    * @author Kabir Pramanik | 12-13-2024 
    **/
    @isTest
    public static void testCaseDealerStateMissing(){
        genesis__Applications__c cfaApplicationObj = [
            SELECT Id,
                Dealer_Name__c
            FROM genesis__Applications__c
            WHERE Coop_Type__c = :PortalConstants.CFA_COOP_TYPE
            LIMIT 1
        ];
        clcommon__Address__c  dealerAddress= [SELECT Id
                                FROM clcommon__Address__c
                                WHERE clcommon__Account__c = :cfaApplicationObj.Dealer_Name__c
                                LIMIT 1];
        dealerAddress.clcommon__State_Province__c = null;
        Database.update(dealerAddress, true);
        System.runAs(getAdminUser()) {
            Test.startTest();
            String response = NLSBookToCoreCalloutClass.bookToCoreLoanFromBackEnd(cfaApplicationObj.Id);
            System.assertEquals(CustomMessageConstants.DEALER_STATE_MISSING, response, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : Test Landus Application Stetement Code Missing
    * @author Kabir Pramanik | 12-18-2024 
    **/
    @IsTest
    public static void testCaseLandusApplicationStatementCodeMissing() {
        genesis__Applications__c landusApplicationObj = getLandusApplication();
        landusApplicationObj.Statement_Code__c = null;
        Database.update(landusApplicationObj, true);
        System.runAs(getAdminUser()) {
            Test.startTest();
            String response = NLSBookToCoreCalloutClass.bookToCoreLoanFromBackEnd(landusApplicationObj.Id);
            System.assertEquals(CustomMessageConstants.STATEMENT_CODE_ERROR, response, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : Test GMK Application Statement Code missing
    * @author Kabir Pramanik | 12-11-2024 
    **/
    @isTest
    public static void testCaseGrowmarkApplicationStatementCodeMissing(){
        genesis__Applications__c gmkApplicationObj = [
            SELECT Id
            FROM genesis__Applications__c
            WHERE Coop_Type__c = :PortalConstants.GROWMARK_COOP_TYPE
            LIMIT 1
        ];
        gmkApplicationObj.Statement_Code__c = null;
        Database.update(gmkApplicationObj, true);
        System.runAs(getAdminUser()) {
            Test.setMock(HttpCalloutMock.class, new NLSBookToCoreMock());
            Test.startTest();
            String response = NLSBookToCoreCalloutClass.bookToCoreLoanFromBackEnd(gmkApplicationObj.Id); 
            System.assertEquals(CustomMessageConstants.STATEMENT_CODE_ERROR, response, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
}