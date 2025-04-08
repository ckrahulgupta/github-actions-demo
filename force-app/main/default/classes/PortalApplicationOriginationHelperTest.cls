/*************************************************************
 * @description       : 
 * @author            : Subham Nandi
 * @group             : 
 * @last modified on  : 03-26-2025
**************************************************************/
@isTest
global without sharing class PortalApplicationOriginationHelperTest {
    
    /**
    * @description - Creating Test Data
    * @author Sk Minsar | 01-22-2025 
    **/
    @TestSetup
    static void makeData(){

        // Creating CL Product for Application
        clcommon__CL_Product__c clProductObj = ApplicationOriginationTestHelper.createCLProductForApplication();
        Database.insert(clProductObj, true);

        // Creating CL Purpose for Application
        clcommon__CL_Purpose__c clPurposeObj = ApplicationOriginationTestHelper.createCLPurposeForApplication();
        Database.insert(clPurposeObj, true);

        clcommon__Floating_Rate_Index__c floatingRateIndex = ApplicationOriginationTestHelper.createFloatingRateIndex('CFA_Advantage_Rate',11);
        Database.insert(floatingRateIndex, true);

        CFA_Partner_Program__c partnerProgram = ApplicationOriginationTestHelper.createPartnerProgram('Landus',floatingRateIndex);
        partnerProgram.Short_Name__c = 'CFA';
        Database.insert(partnerProgram, true);

        //Creating business information
        genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        genesis__Business_Information__c borrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        Database.insert(new List<genesis__Business_Information__c>{borrowerBusinessInfoObj, dealerBusinessInfoObj}, true);
        

        //CREATING REQUIRED LEGAL ENTITIES --------------------------------------------------------------------------------------
        clcommon__Legal_Entity__c corporationEntityObj = ApplicationOriginationTestHelper.createCorporationLegalEntity();
        Database.insert(new List<clcommon__Legal_Entity__c>{ApplicationOriginationTestHelper.createSolePropLegalEntity(), corporationEntityObj, ApplicationOriginationTestHelper.createDBALegalEntity()}, true);

        //CREATING REQUIRED ACCOUNTS ---------------------------------------------------------------------------------------------
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.Id, partnerProgram.id);
        Database.insert(dealerAccountObj, true);
        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
        Account saAccountObj = ApplicationOriginationTestHelper.createSalesAgentAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
        Account saAdminAccObj = ApplicationOriginationTestHelper.createSAAdminAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
        Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(corporationEntityObj,dealerBusinessInfoObj.Id);
        Account principalAccount = ApplicationOriginationTestHelper.createAccount();
        borrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Grower').getRecordTypeId();
        borrowerAccountObj.BillingStreet = 'Kolkata';
        borrowerAccountObj.BillingPostalCode = '12345';
        borrowerAccountObj.Home_Number__c = '1234567890';
        borrowerAccountObj.Phone = '123467890';
        principalAccount.genesis__Business_Information__c = borrowerBusinessInfoObj.Id;
        Database.insert(new List<Account>{clAccountObj, saAccountObj, saAdminAccObj, borrowerAccountObj, principalAccount}, true);

        //CREATING REQUIRED CONTACTS ---------------------------------------------------------------------------------------------
        Contact dealerContactObj = ApplicationOriginationTestHelper.createDealerContact(dealerAccountObj.Id);
        Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.Id);
        Contact saContactObj = ApplicationOriginationTestHelper.createSalesAgentContact(saAccountObj.Id);
        Contact saAdminContactObj=ApplicationOriginationTestHelper.createSAAdminContact(saAdminAccObj.Id);
        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.Id);    
        Contact principalContact = ApplicationOriginationTestHelper.createContact();
        principalContact.AccountId = principalAccount.Id;
        Database.insert(new List<Contact>{dealerContactObj, clContactObj, saContactObj, saAdminContactObj, borrowerContactObj,  principalContact},true);

        createUserAndRole(new Map<String, Id>{
            'clContactId' => clContactObj.Id,
            'saContactId' => saContactObj.Id,
            'saAdminContactId' => saAdminContactObj.Id,
            'borrowerContactId' => borrowerContactObj.Id,
            'dealerContactId' => dealerContactObj.Id,
            'saAdminAccId' => saAdminAccObj.Id,
            'saAccountId' => saAccountObj.Id,
            'dealerAccountId' => dealerAccountObj.Id,
            'clAccountId' => clAccountObj.Id
        });

        // Create Dealer Relationships 
        Dealer_Applicant_Relationship__c borrowerRealtionObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(borrowerContactObj,dealerAccountObj.Id);
        Dealer_Applicant_Relationship__c principalRealtionObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(principalContact,dealerAccountObj.Id);
        Database.insert(new List<Dealer_Applicant_Relationship__c>{borrowerRealtionObj, principalRealtionObj});
        
        //CREATING APPLICATION ---------------------------------------------------------------------------------------------
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createCurrCropYearApplication(new Map<String,Id>{
            'dealerAccountId' => dealerAccountObj.Id,
            'clProductId' => clProductObj.Id,
            'clPurposeId' => clPurposeObj.Id,
            'borrowerAccountId' => borrowerAccountObj.Id,
            'borrowerContactId' => borrowerContactObj.Id,
            'clAccountId' => clAccountObj.Id,
            'dealerApplicantRelationshipId' => borrowerRealtionObj.id
        });
        genesis__Applications__c applicationExistingObj = ApplicationOriginationTestHelper.createCurrCropYearApplication(new Map<String,Id>{
            'dealerAccountId' => dealerAccountObj.Id,
            'clProductId' => clProductObj.Id,
            'clPurposeId' => clPurposeObj.Id,
            'borrowerAccountId' => borrowerAccountObj.Id,
            'borrowerContactId' => borrowerContactObj.Id,
            'clAccountId' => clAccountObj.Id,
            'dealerApplicantRelationshipId' => borrowerRealtionObj.id
        });
        applicationExistingObj.genesis__Loan_Number__c = '300023457';
        Database.insert(new List<genesis__Applications__c>{applicationObj, applicationExistingObj}, true);

        //CREATING REQUIRED PARTY TYPES --------------------------------------------------------------------------------------------- 
        clcommon__Party_Type__c borrowerPartyType = ApplicationOriginationTestHelper.createPartyType('BORROWER');
        clcommon__Party_Type__c principalPartyType = ApplicationOriginationTestHelper.createPartyType('PRINCIPAL');
        clcommon__Party_Type__c clPartyType = ApplicationOriginationTestHelper.createPartyType('CERTIFIED LENDER');
        clcommon__Party_Type__c dealerPartyType = ApplicationOriginationTestHelper.createPartyType('DEALER');
        clcommon__Party_Type__c saPartyType = ApplicationOriginationTestHelper.createPartyType('SALES AGENT');
        clcommon__Party_Type__c saAdminPartyType = ApplicationOriginationTestHelper.createPartyType('SALES AGENT ADMIN');
        clcommon__Party_Type__c spousePartyType = ApplicationOriginationTestHelper.createPartyType('SPOUSE');
        clcommon__Party_Type__c landownerPartyType = ApplicationOriginationTestHelper.createPartyType('LANDOWNER');
        clcommon__Party_Type__c insuranceAgentPartyType = ApplicationOriginationTestHelper.createPartyType('INSURANCE AGENT');
        clcommon__Party_Type__c buyerPartyType = ApplicationOriginationTestHelper.createPartyType('BUYER');
        Database.insert(new List<clcommon__Party_Type__c>{borrowerPartyType, principalPartyType, clPartyType, dealerPartyType, saPartyType, spousePartyType, landownerPartyType, insuranceAgentPartyType, buyerPartyType, saAdminPartyType}, true);

        //CREATING REQUIRED PARTY --------------------------------------------------------------------------------------------- 
        clcommon__Party__c borrowerPartyObj = ApplicationOriginationTestHelper.createParty(new Map<String,Id>{
            'accountId' => borrowerAccountObj.Id,
            'contactId' => borrowerContactObj.Id,
            'partyTypeId' => borrowerPartyType.Id,
            'applicationId' => applicationObj.Id,
            'dealerApplicantRelationshipId' => borrowerRealtionObj.Id
        });
        clcommon__Party__c principalPartyObj = ApplicationOriginationTestHelper.createParty(new Map<String,Id>{
            'accountId' => principalAccount.Id,
            'contactId' => principalContact.Id,
            'partyTypeId' => principalPartyType.Id,
            'applicationId' => applicationObj.Id,
            'dealerApplicantRelationshipId' => principalRealtionObj.Id
        });
        clcommon__Party__c certifiedLenderPartyObj = ApplicationOriginationTestHelper.createParty(new Map<String,Id>{
            'accountId' => clAccountObj.Id,
            'contactId' => clContactObj.Id,
            'partyTypeId' => clPartyType.Id,
            'applicationId' => applicationObj.Id
        });
        clcommon__Party__c dealerPartyObj = ApplicationOriginationTestHelper.createParty(new Map<String,Id>{
            'accountId' => dealerAccountObj.Id,
            'contactId' => dealerContactObj.Id,
            'partyTypeId' => dealerPartyType.Id,
            'applicationId' => applicationObj.Id
        });
        clcommon__Party__c saPartyObj = ApplicationOriginationTestHelper.createParty(new Map<String,Id>{
            'accountId' => saAccountObj.Id,
            'contactId' => saContactObj.Id,
            'partyTypeId' => saPartyType.Id,
            'applicationId' => applicationObj.Id
        });
        clcommon__Party__c exAppBorrowerParty = ApplicationOriginationTestHelper.createParty(new Map<String, Id>{
            'accountId' => borrowerAccountObj.Id,
            'contactId' => borrowerContactObj.Id,
            'partyTypeId' => borrowerPartyType.Id,
            'applicationId' => applicationExistingObj.Id,
            'dealerApplicantRelationshipId' => borrowerRealtionObj.Id
        });
        clcommon__Party__c exAppCLPartyObj = ApplicationOriginationTestHelper.createParty(new Map<String,Id>{
            'accountId' => clAccountObj.Id,
            'contactId' => clContactObj.Id,
            'partyTypeId' => clPartyType.Id,
            'applicationId' => applicationExistingObj.Id
        });
        clcommon__Party__c exAppDealerPartyObj = ApplicationOriginationTestHelper.createParty(new Map<String,Id>{
            'accountId' => dealerAccountObj.Id,
            'contactId' => dealerContactObj.Id,
            'partyTypeId' => dealerPartyType.Id,
            'applicationId' => applicationExistingObj.Id
        });
        borrowerPartyObj.genesis__Application__c = applicationObj.Id;
        borrowerPartyObj.City__c = 'Kolkata';
        borrowerPartyObj.State__c = 'WA';
        borrowerPartyObj.County__c = 'fghu';
        borrowerPartyObj.Work_Number__c = '098765678';
        borrowerPartyObj.Street__c = 'Kolkata';
        borrowerPartyObj.Postal_Code__c = '12345';
        borrowerPartyObj.Home_Number__c = '1234567890';
        borrowerPartyObj.Mobile_Number__c = '123467890';
        exAppBorrowerParty.genesis__Application__c = applicationExistingObj.Id;
        Database.insert(new List<clcommon__Party__c>{borrowerPartyObj, principalPartyObj, certifiedLenderPartyObj, dealerPartyObj, saPartyObj, exAppBorrowerParty, exAppCLPartyObj, exAppDealerPartyObj}, true);

        createApplicationRelatedData(applicationObj, floatingRateIndex.Id, dealerAccountObj);
    }

    
    /**
    * @description - This method is used to create users and role and relationships
    * @author Sk Minsar | 01-23-2025 
    * @param mapOfId 
    **/
    private static void createUserAndRole(Map<String, Id> mapOfId){

         //CREATING REQUIRED USERS ---------------------------------------------------------------------------------------------
         User clUser = ApplicationOriginationTestHelper.createCLUser(mapOfId.get('clContactId'));
         User borrowerUserObj = ApplicationOriginationTestHelper.createBorrowerUser(mapOfId.get('borrowerContactId'));
         User dealerUserObj = ApplicationOriginationTestHelper.createBorrowerUser(mapOfId.get('dealerContactId'));
         dealerUserObj.UserName = 'joseph.marlo@yopmail.com';
         Database.insert(new List<User>{clUser, borrowerUserObj, dealerUserObj}, true);
 
         //CREATING REQUIRED ROLES ---------------------------------------------------------------------------------------------
         clcommon__Reciprocal_Role__c clRoleObj = ApplicationOriginationTestHelper.createCertifiedLenderRole();
         clcommon__Reciprocal_Role__c rsaRoleObj = ApplicationOriginationTestHelper.createReciprocalRole(PortalConstants.RELATED_SALES_AGENT);
         Database.insert(new List<clcommon__Reciprocal_Role__c>{clRoleObj, rsaRoleObj}, true);
 
         //CREATING REQUIRED RELATIONSHIPS --------------------------------------------------------------------------------------------- 
         clcommon__Relationship__c relationshipObject = ApplicationOriginationTestHelper.createRelWithDealer(rsaRoleObj,mapOfId.get('saAdminAccId'),mapOfId.get('saAccountId'));
         clcommon__Relationship__c relationshipObj = ApplicationOriginationTestHelper.createCLDealerRelationship(clRoleObj,mapOfId.get('dealerAccountId'),mapOfId.get('clAccountId'));
         Database.insert(new List<clcommon__Relationship__c>{relationshipObject, relationshipObj}, true);
    }

    /**
    * @description - Create application related data
    * @author Sk Minsar | 01-23-2025 
    * @param applicationObj 
    * @param floatingRateIndexId 
    * @param dealerAccountObj 
    **/
    private static void createApplicationRelatedData(genesis__Applications__c applicationObj, Id floatingRateIndexId, Account dealerAccountObj){
        
        //creating document catagory
        clcommon__document_category__c docCatagoryObj = ApplicationOriginationTestHelper.createDocCategory(applicationObj.Id, 'license');
        Database.insert(docCatagoryObj, true);

        //creating content version
        ContentVersion objContent=ApplicationOriginationTestHelper.createContentVersion();
        Database.insert(objContent, true);

        //creating content document link
        Id conDocId =[SELECT ContentDocumentId FROM ContentVersion WHERE Id =:objContent.Id].ContentDocumentId;  
        ContentDocumentLink cdl = ApplicationOriginationTestHelper.createContentDocumentLink(conDocId, applicationObj.genesis__Account__c);
        Database.insert(cdl, true);

        //Inserting Collateral
        clcommon__Collateral_Category__c collateralCategoryObj = ApplicationOriginationTestHelper.createCollateralCategory();
        Database.insert(collateralCategoryObj,true);

        //Creating collateral 
        clcommon__collateral__c collateralObj = ApplicationOriginationTestHelper.createCollateral(new Map<String,String>{
            'collateralCategoryId' => String.valueOf(collateralCategoryObj.Id),
            'insurancePlan' => 'YP',
            'percentCoverageLevel' => '50%'
        });
        collateralObj.genesis__Application__c = applicationObj.id;
        Database.insert(collateralObj,true);

        genesis__Application_Collateral__c appCollateralObj = new genesis__Application_Collateral__c(genesis__Collateral__c=collateralObj.Id, genesis__Application__c=applicationObj.Id);
        Database.insert(appCollateralObj);

        genesis__Rate_Card_Setup_Header__c rateCardHeaderObj = ApplicationOriginationTestHelper.createRateCardSetupHeader(dealerAccountObj);
        rateCardHeaderObj.Base_Rate__c = floatingRateIndexId;
        Database.insert(rateCardHeaderObj,true);

        //Create rate card setup details
        genesis__Rate_Card_Setup_Detail__c arateCardSetupDetails =  ApplicationOriginationTestHelper.createNewRateCardSetupDetail(rateCardHeaderObj);
        genesis__Rate_Card_Setup_Detail__c brateCardSetupDetails =  ApplicationOriginationTestHelper.createNewRateCardSetupDetail(rateCardHeaderObj);
        genesis__Rate_Card_Setup_Detail__c rateCard =  ApplicationOriginationTestHelper.createNewRateCardSetupDetail(rateCardHeaderObj);
        genesis__Rate_Card_Setup_Detail__c rateCardOnDescription =  ApplicationOriginationTestHelper.createNewRateCardSetupDetail(rateCardHeaderObj);
        genesis__Rate_Card_Setup_Detail__c crateCardSetupDetails =  ApplicationOriginationTestHelper.createNewRateCardSetupDetail(rateCardHeaderObj);
        arateCardSetupDetails.Special_Term_Reference__c = PortalConstants.SPECIAL_TERM_A;
        brateCardSetupDetails.Special_Term_Reference__c = PortalConstants.SPECIAL_TERM_B;
        rateCard.Special_Term_Reference__c = PortalConstants.SPECIAL_TERM_B;
        rateCard.Start_Date__c = (brateCardSetupDetails.Start_Date__c).addDays(-1);
        rateCard.End_Date__c = (brateCardSetupDetails.End_Date__c).addDays(1);
        rateCardOnDescription.Special_Term_Reference__c = PortalConstants.SPECIAL_TERM_B;
        rateCardOnDescription.End_Date__c = (brateCardSetupDetails.End_Date__c).addDays(1);
        rateCardOnDescription.genesis__Enabled_flag__c = PortalConstants.FALSE_VALUE;
        crateCardSetupDetails.Special_Term_Reference__c = 'Special Term Sub-Tranche (C)';
        Database.insert(new List<genesis__Rate_Card_Setup_Detail__c>{arateCardSetupDetails, brateCardSetupDetails, rateCard, rateCardOnDescription, crateCardSetupDetails}, true);

        //Create bank account
        clcommon__Bank_Account__c bankAccount = ApplicationOriginationTestHelper.createBankAccount();
        bankAccount.clcommon__Account__c = applicationObj.genesis__Account__c;
        bankAccount.clcommon__Contact__c = applicationObj.genesis__Contact__c;
        Database.insert(bankAccount,true);

        //Create Credit rating matrix
        List<genesis__Credit_Rating_Matrix__c> creditRatingMatrixList = ApplicationOriginationTestHelper.createCreditRatingMatrix();
        Database.insert(creditRatingMatrixList,true);

        //Create pricing
        genesis__Application_Pricing_Detail__c pricingDeailsObj = ApplicationOriginationTestHelper.createPricingDetail(applicationObj.Id);
        Database.insert(pricingDeailsObj, true);
        
        //Create task
        Task objTask = ApplicationOriginationTestHelper.createTask(applicationObj.Id);
        Database.insert(objTask, true);
    }

    /**
    * @description - This method queries and returns all necessary data
    * @author Sk Minsar | 01-23-2025 
    * @return Map<String, Object> 
    **/
    private static Map<String, Object> getDataMap(){
        List<genesis__Applications__c> objApplicationList = [SELECT Id, 
                                                        genesis__Account__c,
                                                        genesis__Account__r.clcommon__Legal_Entity_Type__c,
                                                        genesis__Contact__c,
                                                        genesis__Account__r.clcommon__Legal_Entity_Type__r.Name,
                                                        genesis__Contact__r.Name,
                                                        genesis__Contact__r.Id,
                                                        Sales_Agent__c,
                                                        Name, 
                                                        genesis__Status__c,
                                                        genesis__Account__r.Name,
                                                        Is_First_Application__c,
                                                        genesis__Account__r.clcommon__Email__c,
                                                        genesis__Loan_Number__c,
                                                        genesis__Account__r.BillingCity,
                                                        genesis__Account__r.BillingState,
                                                        genesis__Contact__r.MailingCity,
                                                        genesis__Contact__r.MailingState,
                                                        Does_Applicant_Feed_Above_Collaterals__c,
                                                        genesis__Credit_Rating__c,
                                                        genesis__Account__r.CIF_Number__c,
                                                        genesis__Credit_Rating__r.Name,
                                                        Credit_Application_And_Agreement_Process__c,
                                                        Submitted_to_CFA__c,
                                                        Dealer_Name__c,
                                                        Dealer_Name__r.Coop_type__c,
                                                        My_program__c,
                                                        (SELECT Id,
                                                                City__c,
                                                                State__c
                                                        FROM genesis__Parties__r
                                                        WHERE clcommon__Party_Types__c = :PortalConstants.BORROWER_PARTY_NAME)
                                                        FROM genesis__Applications__c 
                                                        WHERE genesis__Loan_Number__c = '300023456' LIMIT 1];
        List<Account> accountList = [SELECT Id, 
                                            BillingCity,
                                            BillingState,
                                            Billing_County__c,
                                            Work_Number__c,
                                            BillingStreet,
                                            BillingPostalCode,
                                            Home_Number__c,
                                            Phone,
                                            clcommon__Email__c,
                                            Confirm_Email__c,
                                            Year_Began_Farming__c,
                                            genesis__Business_Information__c,
                                            Has_Past_Due__c,
                                            Non_Accrual__c,
                                            Is_Evergreen_Allowed__c,
                                            clcommon__Legal_Entity_Type__c
                                    FROM Account 
                                    WHERE Id = :objApplicationList[0].genesis__Account__c];

        List<Contact> contactList = [SELECT Id, 
                                            Phone,
                                            MobilePhone,
                                            HomePhone,
                                            FirstName,
                                            ints__Middle_Name__c,
                                            MailingStreet,
                                            MailingCity,
                                            MailingState,
                                            MailingPostalCode,
                                            Mailing_County__c,
                                            Suffix__c,
                                            clcommon__Marital_Status__c,
                                            Email,
                                            Confirm_Email__c,
                                            genesis__SSN__c,
                                            Confirm_SSN__c,
                                            AccountId,
                                            LastName
                                    FROM Contact 
                                    WHERE Id = :objApplicationList[0].genesis__Contact__c];

        List<clcommon__Party__c> partyList = [SELECT Id,
                                                    clcommon__Contact__c,
                                                    clcommon__Account__c,
                                                    clcommon__Account__r.clcommon__Legal_Entity_Type__r.Name,
                                                    clcommon__Account__r.Is_Individual__c,
                                                    clcommon__Party_Types__c, 
                                                    City__c,
                                                    State__c, 
                                                    County__c, 
                                                    Street__c, 
                                                    Postal_Code__c,
                                                    genesis__Application__r.genesis__Account__r.clcommon__Legal_Entity_Type__r.Name,
                                                    clcommon__Contact__r.Email,
                                                    clcommon__Account__r.Kyc_Verified__c
                                                FROM clcommon__Party__c 
                                                WHERE genesis__Application__c =: objApplicationList[0].Id];

        List<genesis__Business_Information__c> businessInfoList = [SELECT Id,
                                                                        genesis__Total_Assets__c,
                                                                        genesis__Total_Liabilities__c,
                                                                        genesis__Tax_Identification_Number__c,
                                                                        Confirm_Tax_Identification_Number__c,
                                                                        genesis__State_of_Incorporation__c,
                                                                        Gross_Farm_Income__c
                                                          FROM genesis__Business_Information__c
                                                          WHERE Id = :accountList[0].genesis__Business_Information__c
                                                          LIMIT 1];

        List<clcommon__Document_Category__c> docCatagoryName = [SELECT id, clcommon__Category_Name__c FROM clcommon__document_category__c WHERE clcommon__Category_Name__c='license'];

        List<clcommon__Legal_Entity__c> solePropLegalEntityList = [SELECT Id,
                                                                            Name,
                                                                            clcommon__Legal_Entity_Type__c 
                                                                FROM clcommon__Legal_Entity__c 
                                                                WHERE clcommon__Legal_Entity_Type__c =:PortalConstants.SOLE_PROP_ENTITY LIMIT 1];

        List<clcommon__Collateral__c> objCollateralList = [SELECT Id,
                                                        clcommon__Collateral_Category__c, 
                                                        Total_Acres__c,
                                                        Producer_Share_Percent__c,
                                                        Approved_Yield__c,
                                                        Percent_Fed__c,
                                                        Percent_Coverage_Level__c,
                                                        Insurance_Plan__c,
                                                        Price__c 
                                                        FROM clcommon__Collateral__c 
                                                        WHERE genesis__Application__c = :objApplicationList[0].Id];
        return new Map<String, Object>{
            'objApplication' => objApplicationList[0],
            'objAccount' => accountList[0],
            'contactList' => contactList[0],
            'partyList' => partyList,
            'businessInfoList' => businessInfoList,
            'docCatagoryName' => docCatagoryName,
            'solePropLegalEntity' => solePropLegalEntityList[0],
            'objCollateralList' => objCollateralList
        };
    }

    /**
    * @description - Get partyTypeList by party name
    * @author Sk Minsar | 01-24-2025 
    * @param partyName 
    * @return List<clcommon__Party_Type__c> 
    **/
    private static List<clcommon__Party_Type__c> getPartyTypeList(String partyName){
        return [SELECT Id, Name FROM clcommon__Party_Type__c WHERE NAME =:partyName LIMIT 1];
    }

    /**
    * @description - This method used to query the partyRecordType
    * @author Sk Minsar | 01-24-2025 
    * @param partyName 
    * @return List<RecordType> 
    **/
    private static List<RecordType> getPartyRecordTypeList(String partyName){
        return [ SELECT Id,
                        SobjectType,
                        Name
                        FROM RecordType
                        WHERE Name = :partyName LIMIT 1];
    }

    /**
    * @description - Get Account by RecrodType
    * @author Sk Minsar | 01-24-2025 
    * @param recordTypeName 
    * @return Account 
    **/
    private static Account getAccountByRecordType(String recordTypeName){
        return [SELECT Id, Name, clcommon__Email__c, BillingStreet, BillingCity, BillingPostalCode,  Coop_Type__c, BillingState, Billing_County__c,Confirm_Email__c FROM Account WHERE RecordType.Name = :recordTypeName LIMIT 1];
    }

    /**
    * @description - Get Profile by profile name
    * @author Sk Minsar | 01-24-2025 
    * @param profileName 
    * @return List<Profile> 
    **/
    private static List<Profile> getProfileList(String profileName){
        return [SELECT Id FROM Profile WHERE Name =:profileName LIMIT 1];
    }

    /**
    * @description - Return RateCardList
    * @author Sk Minsar | 01-24-2025 
    * @return List<genesis__rate_card_setup_header__c> 
    **/
    private static List<genesis__rate_card_setup_header__c> getRateCardHeaderList(){
        return [SELECT Id, genesis__Start_Date__c, genesis__End_Date__c, Crop_Year__c FROM genesis__rate_card_setup_header__c WHERE genesis__Product_Type__c = :PortalConstants.PRODUCT_TYPE_FOR_MY_PROGRAM LIMIT 1];
    }

    /**
    * @description - Return partyList by account Id
    * @author Sk Minsar | 01-26-2025 
    * @param accountId 
    * @return List<clcommon__Party__c> 
    **/
    private static List<clcommon__Party__c> getPartyList(Id accountId){
        return [SELECT Id, City__c, State__c, County__c, Street__c, Postal_Code__c, clcommon__Party_Types__c, clcommon__Account__c, clcommon__Contact__c, clcommon__Contact__r.Email, genesis__Application__r.genesis__Account__r.clcommon__Legal_Entity_Type__r.Name FROM clcommon__Party__c WHERE clcommon__Account__c = :accountId LIMIT 1];
    }

    /**
    * @description - This method used to return the genesis__Rate_Card_Setup_Detail__c List
    * @author Sk Minsar | 01-26-2025 
    * @param rateCardHeaderId 
    * @return List<genesis__Rate_Card_Setup_Detail__c> 
    **/
    private static List<genesis__Rate_Card_Setup_Detail__c> getRateCardSetupDetails(Id rateCardHeaderId){
        return [SELECT Id,
                        genesis__Enabled_flag__c,
                        genesis__rate_card_setup_header__c,
                        Special_Term_Reference__c,
                        Start_Date__c,
                        End_Date__c,
                        Participation_Percentage_Dealer_Subsidy__c,
                        Participation_Percentage_CFA__c,
                        Participation_Percentage_Dealer__c,
                        genesis__Rate_Card_Setup_Header__r.genesis__End_Date__c,
                        genesis__Rate_Card_Setup_Header__r.FS_Index_Rate__c,
                        genesis__Rate_Card_Setup_Header__r.CFA_Advantage_Rate__c,
                        genesis__Rate_Card_Setup_Header__r.Field_Finance_Rate__c,
                        genesis__Rate_Card_Setup_Header__r.Crop_Year__c,
                        genesis__rate_card_setup_header__r.Account__r.Coop_Type__c,
                        genesis__Interest_Rate__c,
                        Special_Term_Order__c
                FROM genesis__Rate_Card_Setup_Detail__c 
                WHERE genesis__rate_card_setup_header__c = :rateCardHeaderId];
    }

    /**
    * @description - Get Contact by name
    * @author Sk Minsar | 01-29-2025 
    * @param contactName 
    * @return Contact 
    **/
    private static Contact getContactByName(String contactName){
        return [SELECT Id, Name FROM Contact WHERE NAME =:contactName];
    }

    /**
    * @description - Get rateCardDetailList for specific rateCardList
    * @author Sk Minsar | 01-29-2025 
    * @param rateCardDetailList 
    * @return List<genesis__Rate_Card_Setup_Detail__c> 
    **/
    private static List<genesis__Rate_Card_Setup_Detail__c> getRateCardDetailListByRateCard(List<genesis__Rate_Card_Setup_Detail__c> rateCardDetailList){
        return [SELECT  Id,
                        Start_Date__c,
                        End_Date__c,
                        genesis__Rate_Card_Setup_Header__r.CFA_Advantage_Rate__c,
                        genesis__Rate_Card_Setup_Header__r.Field_Finance_Rate__c
                FROM genesis__Rate_Card_Setup_Detail__c
                WHERE genesis__rate_card_setup_header__c = :rateCardDetailList[0].genesis__rate_card_setup_header__c
                AND Special_Term_Reference__c = :rateCardDetailList[0].Special_Term_Reference__c
                AND genesis__Enabled_flag__c = :PortalConstants.FALSE_VALUE
                ORDER BY Start_Date__c ];
    }


    /**
    * @description - Get bank account list account name
    * @author Sk Minsar | 01-29-2025 
    * @param accountId 
    * @return List<clcommon__Bank_Account__c> 
    **/
    private static List<clcommon__Bank_Account__c> getBankAccountByAccountList(String accountId){
        return [SELECT Id,ownerId,clcommon__Contact__c,clcommon__Account__c FROM clcommon__Bank_Account__c WHERE clcommon__Account__c= :accountId LIMIT 1];
    }
    /**
    * @description - Test getCoopType success for CFA
    * @author Soumik Pattanayak | 16-01-2025 
    **/
    @isTest 
    public static void testGetCoopTypeSuccess(){
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> dataMap = getDataMap();
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');
        System.runAs(clUserObj){
            Test.startTest();
                String coopType = PortalApplicationOriginationHelper.getCoopType(objApplication.Id);
                System.assertEquals(PortalConstants.CFA_COOP_TYPE, coopType, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();   
        }
    }

    /**
    * @description - Test getCoopType for null coop type
    * @author Soumik Pattanayak | 16-01-2025 
    **/
    @isTest 
    public static void testGetCoopTypeEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> dataMap = getDataMap();
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');
        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.getCoopType(objApplication.Id);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();   
        }
    }

    /**
    * @description - UploadDocumentOnDocCategory success
    * @author Soumik Pattanayak | 16-01-2025 
    **/
    @isTest 
    public static void testUploadDocumentOnDocCategory(){
        Map<String, Object> dataMap = getDataMap();
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');
        List<clcommon__Document_Category__c> docCatagoryName = (List<clcommon__Document_Category__c>)dataMap.get('docCatagoryName');
        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                PortalApplicationOriginationHelper.uploadDocumentOnDocCategory(objApplication.Id,'license');
                Integer size = [SELECT id FROM clcommon__Category_Attachment_Association__c WHERE clcommon__Document_Category__c = :docCatagoryName[0].id].size();
                System.assertEquals(PortalConstants.TRUE_VALUE, size>0, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Success with Grower for UploadDocumentOnDocCategory
    * @author Sk Minsar | 01-24-2025 
    **/
    @isTest 
    public static void testUploadDocumentOnDocCategoryWithGrower(){
        Map<String, Object> dataMap = getDataMap();
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User borrowerUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');
        System.runAs(borrowerUser){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.uploadDocumentOnDocCategory(objApplication.Id,'license');
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Success for spouse party
    * @author Soumik Pattanayak | 15-01-2025 
    **/
    @isTest 
    public static void testSaveAdditionalInfoDetailsSpouse(){
        Map<String, Object> dataMap = getDataMap();
        User objUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');
        Map<String, Object> response =new Map<String, Object>();
        response.put('clcommon__Contact__r.FirstName', 'Shivani');
        response.put('clcommon__Contact__r.LastName', 'Kumari');
        response.put('clcommon__Contact__r.Email', 'shivani87@yopmail.com');
        response.put('clcommon__Account__r.Name', 'Kisan Loan');
        response.put('clcommon__Account__r.clcommon__Email__c', 'kisan34@yopmail.com');
        response.put('clcommon__Account__r.Phone', '0123456789');
        response.put('clcommon__Account__r.BillingStreet', '2423 6th Avenue');
        response.put('clcommon__Account__r.BillingCity', 'Frankenmouth');
        response.put('clcommon__Account__r.BillingState', 'Michigan');
        response.put('clcommon__Account__r.BillingPostalCode', '61232');
        response.put('clcommon__Account__r.Billing_County__c', 'Erie');
        response.put('clcommon__Account__c', objUser.AccountId);
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');
        Map<String, RecordType> partyRecordTypeMap = new Map<String, RecordType>();
        Map<String, clcommon__Party_Type__c> partyTypeMap = new Map<String, clcommon__Party_Type__c>();
        Map<String, Object> containsPartyRecordMap = new Map<String, Object>();
        List<RecordType> partyRecordTypeList = getPartyRecordTypeList(PortalConstants.SPOUSE_PARTY_NAME);
        partyRecordTypeMap.put(PortalConstants.SPOUSE_PARTY_NAME, partyRecordTypeList[0]);
        List<clcommon__Party_Type__c> partyTypeObjList = getPartyTypeList(PortalConstants.SPOUSE_PARTY_NAME);
        partyTypeMap.put(PortalConstants.SPOUSE_PARTY_NAME, partyTypeObjList[0]);
        containsPartyRecordMap.put('applicationId', objApplication.Id);
        containsPartyRecordMap.put('recordTypeMap', partyRecordTypeMap);
        containsPartyRecordMap.put('partyTypeMap', partyTypeMap);

        System.runAs(objUser){
            Test.startTest();
                PortalApplicationOriginationHelper.saveAdditionalInfoDetails(response, containsPartyRecordMap, PortalConstants.SPOUSE_PARTY_NAME);
                clcommon__Party__c partyObj = [SELECT id, genesis__Application__c FROM clcommon__party__c WHERE clcommon__Type__r.name =:PortalConstants.SPOUSE_PARTY_NAME LIMIT 1];
                System.assertEquals(objApplication.Id, partyObj.genesis__Application__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Success for Land Owner party
    * @author Soumik Pattanayak | 15-01-2025 
    **/
    @isTest 
    public static void testSaveAdditionalInfoDetailsLandOwner(){
        Map<String, Object> dataMap = getDataMap();
        User objUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');
        Map<String, Object> response =new Map<String, Object>();
        response.put('clcommon__Contact__r.FirstName', 'Shivani');
        response.put('clcommon__Contact__r.LastName', 'Kumari');
        response.put('clcommon__Contact__r.Email', 'shivani87@yopmail.com');
        response.put('clcommon__Account__r.Name', 'Kisan Loan');
        response.put('clcommon__Account__r.clcommon__Email__c', 'kisan34@yopmail.com');
        response.put('clcommon__Account__r.Phone', '0123456789');
        response.put('clcommon__Account__r.BillingStreet', '2423 6th Avenue');
        response.put('clcommon__Account__r.BillingCity', 'Frankenmouth');
        response.put('clcommon__Account__r.BillingState', 'Michigan');
        response.put('clcommon__Account__r.BillingPostalCode', '61232');
        response.put('clcommon__Account__r.Billing_County__c', 'Erie');
        response.put('clcommon__Account__c', objUser.AccountId);
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');
        Map<String, RecordType> partyRecordTypeMap = new Map<String, RecordType>();
        Map<String, clcommon__Party_Type__c> partyTypeMap = new Map<String, clcommon__Party_Type__c>();
        Map<String, Object> containsPartyRecordMap = new Map<String, Object>();
        List<RecordType> recordTypeList = getPartyRecordTypeList(PortalConstants.LANDOWNER_PARTY_NAME);
        partyRecordTypeMap.put(PortalConstants.LANDOWNER_PARTY_NAME, recordTypeList[0]);
        List<clcommon__Party_Type__c> partyTypeObjList = getPartyTypeList(PortalConstants.LANDOWNER_PARTY_NAME);
        partyTypeMap.put(PortalConstants.LANDOWNER_PARTY_NAME, partyTypeObjList[0]);
        containsPartyRecordMap.put('applicationId', objApplication.Id);
        containsPartyRecordMap.put('recordTypeMap', partyRecordTypeMap);
        containsPartyRecordMap.put('partyTypeMap', partyTypeMap);

        System.runAs(objUser){
            Test.startTest();
                PortalApplicationOriginationHelper.saveAdditionalInfoDetails(response, containsPartyRecordMap, PortalConstants.LANDOWNER_PARTY_NAME);
                clcommon__Party__c partyObj = [SELECT id, genesis__Application__c FROM clcommon__party__c WHERE clcommon__Type__r.name =:PortalConstants.LANDOWNER_PARTY_NAME LIMIT 1];
                System.assertEquals(objApplication.Id, partyObj.genesis__Application__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    
    /**
    * @description - Success for Insurance Agent party
    * @author Soumik Pattanayak | 15-01-2025 
    **/
    @isTest 
    public static void testSaveAdditionalInfoDetailsInsuranceAgent(){
        Map<String, Object> dataMap = getDataMap();
        User objUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');
        Map<String, Object> response =new Map<String, Object>();
        response.put('clcommon__Contact__r.FirstName', 'Shivani');
        response.put('clcommon__Contact__r.LastName', 'Kumari');
        response.put('clcommon__Contact__r.Email', 'shivani87@yopmail.com');
        response.put('clcommon__Account__r.Name', 'Kisan Loan');
        response.put('clcommon__Account__r.clcommon__Email__c', 'kisan34@yopmail.com');
        response.put('clcommon__Account__r.Phone', '0123456789');
        response.put('clcommon__Account__r.BillingStreet', '2423 6th Avenue');
        response.put('clcommon__Account__r.BillingCity', 'Frankenmouth');
        response.put('clcommon__Account__r.BillingState', 'Michigan');
        response.put('clcommon__Account__r.BillingPostalCode', '61232');
        response.put('clcommon__Account__r.Billing_County__c', 'Erie');
        response.put('clcommon__Account__c', objUser.accountId);
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');
        Map<String, RecordType> partyRecordTypeMap = new Map<String, RecordType>();
        Map<String, clcommon__Party_Type__c> partyTypeMap = new Map<String, clcommon__Party_Type__c>();
        Map<String, Object> containsPartyRecordMap = new Map<String, Object>();
        List<RecordType> recordTypeList = getPartyRecordTypeList(PortalConstants.INSURANCE_AGENT_PARTY_NAME); 
        partyRecordTypeMap.put(PortalConstants.INSURANCE_AGENT_PARTY_NAME, recordTypeList[0]);
        List<clcommon__Party_Type__c> partyTypeObjList = getPartyTypeList(PortalConstants.INSURANCE_AGENT_PARTY_NAME);
        partyTypeMap.put(PortalConstants.INSURANCE_AGENT_PARTY_NAME, partyTypeObjList[0]);
        containsPartyRecordMap.put('applicationId', objApplication.Id);
        containsPartyRecordMap.put('recordTypeMap', partyRecordTypeMap);
        containsPartyRecordMap.put('partyTypeMap', partyTypeMap);

        System.runAs(objUser){
            Test.startTest();
                PortalApplicationOriginationHelper.saveAdditionalInfoDetails(response, containsPartyRecordMap, PortalConstants.INSURANCE_AGENT_PARTY_NAME);
                clcommon__party__c partyObj = [SELECT id, genesis__Application__c FROM clcommon__party__c WHERE clcommon__Type__r.name =:PortalConstants.INSURANCE_AGENT_PARTY_NAME LIMIT 1];
                System.assertEquals(objApplication.Id, partyObj.genesis__Application__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Success for Buyers party
    * @author Soumik Pattanayak | 15-01-2025 
    **/
    @isTest 
    public static void testSaveAdditionalInfoDetailsBuyers(){
        Map<String, Object> dataMap = getDataMap();
        User objUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');
        Map<String, Object> response =new Map<String, Object>();
        response.put('clcommon__Contact__r.FirstName', 'Shivani');
        response.put('clcommon__Contact__r.LastName', 'Kumari');
        response.put('clcommon__Contact__r.Email', 'shivani87@yopmail.com');
        response.put('clcommon__Account__r.Name', 'Kisan Loan');
        response.put('clcommon__Account__r.clcommon__Email__c', 'kisan34@yopmail.com');
        response.put('clcommon__Account__r.Phone', '0123456789');
        response.put('clcommon__Account__r.BillingStreet', '2423 6th Avenue');
        response.put('clcommon__Account__r.BillingCity', 'Frankenmouth');
        response.put('clcommon__Account__r.BillingState', 'Michigan');
        response.put('clcommon__Account__r.BillingPostalCode', '61232');
        response.put('clcommon__Account__r.Billing_County__c', 'Erie');
        response.put('clcommon__Account__c', objUser.AccountId);
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');
        Map<String, RecordType> partyRecordTypeMap = new Map<String, RecordType>();
        Map<String, clcommon__Party_Type__c> partyTypeMap = new Map<String, clcommon__Party_Type__c>();
        Map<String, Object> containsPartyRecordMap = new Map<String, Object>();
        List<RecordType> recordTypeList = getPartyRecordTypeList(PortalConstants.BUYER_PARTY_NAME);
        partyRecordTypeMap.put(PortalConstants.BUYER_PARTY_NAME, recordTypeList[0]);
        List<clcommon__Party_Type__c> partyTypeObjList = getPartyTypeList(PortalConstants.BUYER_PARTY_NAME);
        partyTypeMap.put(PortalConstants.BUYER_PARTY_NAME, partyTypeObjList[0]);
        containsPartyRecordMap.put('applicationId', objApplication.Id);
        containsPartyRecordMap.put('recordTypeMap', partyRecordTypeMap);
        containsPartyRecordMap.put('partyTypeMap', partyTypeMap);

        System.runAs(objUser){
            Test.startTest();
                PortalApplicationOriginationHelper.saveAdditionalInfoDetails(response, containsPartyRecordMap, PortalConstants.BUYER_PARTY_NAME);
                clcommon__Party__c partyObj = [SELECT id, genesis__Application__c FROM clcommon__Party__c WHERE clcommon__Type__r.name =:PortalConstants.BUYER_PARTY_NAME LIMIT 1];
                System.assertEquals(objApplication.Id, partyObj.genesis__Application__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Success for Buyers party with null Id
    * @author Sk Minsar | 01-24-2025 
    **/
    @isTest 
    public static void testSaveAdditionalInfoDetailsBuyersWithNullId(){
        Map<String, Object> dataMap = getDataMap();
        User objUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');
        Map<String, Object> response =new Map<String, Object>();
        response.put('clcommon__Contact__r.FirstName', 'Shivani');
        response.put('clcommon__Contact__r.LastName', 'Kumari');
        response.put('clcommon__Contact__r.Email', 'shivani87@yopmail.com');
        response.put('clcommon__Account__r.Name', 'Kisan Loan');
        response.put('clcommon__Account__r.clcommon__Email__c', 'kisan34@yopmail.com');
        response.put('clcommon__Account__r.Phone', '0123456789');
        response.put('clcommon__Account__r.BillingStreet', '2423 6th Avenue');
        response.put('clcommon__Account__r.BillingCity', 'Frankenmouth');
        response.put('clcommon__Account__r.BillingState', 'Michigan');
        response.put('clcommon__Account__r.BillingPostalCode', '61232');
        response.put('clcommon__Account__r.Billing_County__c', 'Erie');
        response.put('clcommon__Account__c', objUser.AccountId);
        response.put('id', null);
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');
        Map<String, RecordType> partyRecordTypeMap = new Map<String, RecordType>();
        Map<String, clcommon__Party_Type__c> partyTypeMap = new Map<String, clcommon__Party_Type__c>();
        Map<String, Object> containsPartyRecordMap = new Map<String, Object>();
        List<RecordType> recordTypeList = getPartyRecordTypeList(PortalConstants.BUYER_PARTY_NAME);
        partyRecordTypeMap.put(PortalConstants.BUYER_PARTY_NAME, recordTypeList[0]);
        List<clcommon__Party_Type__c> partyTypeObjList = getPartyTypeList(PortalConstants.BUYER_PARTY_NAME);
        partyTypeMap.put(PortalConstants.BUYER_PARTY_NAME, partyTypeObjList[0]);
        containsPartyRecordMap.put('applicationId', objApplication.Id);
        containsPartyRecordMap.put('recordTypeMap', partyRecordTypeMap);
        containsPartyRecordMap.put('partyTypeMap', partyTypeMap);

        System.runAs(objUser){
            Test.startTest();
                PortalApplicationOriginationHelper.saveAdditionalInfoDetails(response, containsPartyRecordMap, PortalConstants.BUYER_PARTY_NAME);
                clcommon__Party__c partyObj = [SELECT id, genesis__Application__c FROM clcommon__Party__c WHERE clcommon__Type__r.name =:PortalConstants.BUYER_PARTY_NAME LIMIT 1];
                System.assertEquals(objApplication.Id, partyObj.genesis__Application__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Success for Buyers party with buyer party Id
    * @author Sk Minsar | 01-24-2025 
    **/
    @isTest 
    public static void testSaveAdditionalInfoDetailsBuyersWithId(){
        Map<String, Object> dataMap = getDataMap();
        Id buyerPartyId = null;
        User objUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');
        List<clcommon__Party__c> objPartyList = (List<clcommon__Party__c>)dataMap.get('partyList');
        for(clcommon__Party__c objParty: objPartyList){
            if(objParty.clcommon__Party_Types__c.equalsIgnoreCase(PortalConstants.PRINCIPAL_PARTY_NAME)){
                objParty.clcommon__Party_Types__c = PortalConstants.BUYER_PARTY_NAME;
                buyerPartyId = objParty.Id;
                break;
            }
        }
        Database.update(objPartyList, true);
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');
        Map<String, Object> response =new Map<String, Object>();
        response.put('clcommon__Contact__r.FirstName', 'Shivani');
        response.put('clcommon__Contact__r.LastName', 'Kumari');
        response.put('clcommon__Contact__r.Email', 'shivani87@yopmail.com');
        response.put('clcommon__Account__r.Name', 'Kisan Loan');
        response.put('clcommon__Account__r.clcommon__Email__c', 'kisan34@yopmail.com');
        response.put('clcommon__Account__r.Phone', '0123456789');
        response.put('clcommon__Account__r.BillingStreet', '2423 6th Avenue');
        response.put('clcommon__Account__r.BillingCity', 'Frankenmouth');
        response.put('clcommon__Account__r.BillingState', 'Michigan');
        response.put('clcommon__Account__r.BillingPostalCode', '61232');
        response.put('clcommon__Account__r.Billing_County__c', 'Erie');
        response.put('clcommon__Contact__c', String.valueOf(objApplication.genesis__Contact__r.Id));
        response.put('clcommon__Account__c', String.valueOf(objUser.AccountId));
        response.put('id', String.valueOf(buyerPartyId));
        Map<String, RecordType> partyRecordTypeMap = new Map<String, RecordType>();
        Map<String, clcommon__Party_Type__c> partyTypeMap = new Map<String, clcommon__Party_Type__c>();
        Map<String, Object> containsPartyRecordMap = new Map<String, Object>();
        List<RecordType> recordTypeList = getPartyRecordTypeList(PortalConstants.BUYER_PARTY_NAME);
        partyRecordTypeMap.put(PortalConstants.BUYER_PARTY_NAME, recordTypeList[0]);
        List<clcommon__Party_Type__c> partyTypeObjList = getPartyTypeList(PortalConstants.BUYER_PARTY_NAME);
        partyTypeMap.put(PortalConstants.BUYER_PARTY_NAME, partyTypeObjList[0]);
        containsPartyRecordMap.put('applicationId', objApplication.Id);
        containsPartyRecordMap.put('recordTypeMap', partyRecordTypeMap);
        containsPartyRecordMap.put('partyTypeMap', partyTypeMap);

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                PortalApplicationOriginationHelper.saveAdditionalInfoDetails(response, containsPartyRecordMap, PortalConstants.BUYER_PARTY_NAME);
                clcommon__Party__c partyObj = [SELECT id, genesis__Application__c FROM clcommon__Party__c WHERE clcommon__Type__r.name =:PortalConstants.BUYER_PARTY_NAME LIMIT 1];
                System.assertEquals(objApplication.Id, partyObj.genesis__Application__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test addSalesAgentParty success
    * @author Soumik Pattanayak | 16-01-2025 
    **/
    @isTest 
    public static void testAddSalesAgentParty(){
        Map<String, Object> dataMap = getDataMap();
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');
        Account accountObj = getAccountByRecordType('Sales Agent');
        objApplication.Sales_Agent__c = accountObj.Id;
        Database.update(objApplication, true);

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.addSalesAgentParty(objApplication,new Map<String,Id>());
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test addSalesAgentParty success
    * @author Soumik Pattanayak | 16-01-2025 
    **/
    @isTest 
    public static void testAddSalesAgentPartyContanctNull(){
        Map<String, Object> dataMap = getDataMap();
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');
        objApplication.Sales_Agent__c = null;
        Database.update(objApplication, true);

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.addSalesAgentParty(objApplication,new Map<String,Id>());
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test addSalesAgentParty success
    * @author Soumik Pattanayak | 16-01-2025 
    **/
    @isTest 
    public static void testAddSalesAgentPartySaAdminPartyExist(){
        Map<String, Object> dataMap = getDataMap();
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');
        Account accountObj = getAccountByRecordType('Sales Agent');
        objApplication.Sales_Agent__c = accountObj.Id;
        Database.update(objApplication, true);
        List<clcommon__Party__c> objPartyList = (List<clcommon__Party__c>)dataMap.get('partyList');
        for(clcommon__Party__c objParty: objPartyList){
            if(objParty.clcommon__Party_Types__c.equalsIgnoreCase(PortalConstants.PRINCIPAL_PARTY_NAME)){
                objParty.clcommon__Party_Types__c = PortalConstants.SALES_AGENT_ADMIN_PARTY;
                break;
            }
        }
        Database.update(objPartyList, true);

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.addSalesAgentParty(objApplication,new Map<String,Id>());
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test addSalesAgentParty Exception
    * @author Soumik Pattanayak | 16-01-2025 
    **/
    @isTest 
    public static void testAddSalesAgentPartyWithNoSaContact(){
        Map<String, Object> dataMap = getDataMap();
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');
        Account accountObj = getAccountByRecordType('Sales Agent');
        objApplication.Sales_Agent__c = accountObj.Id;
        Database.update(objApplication, true);
        Contact saContact = getContactByName('Tim Couper');
        Database.delete(saContact, true);

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.addSalesAgentParty(objApplication,new Map<String,Id>());
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.TRUE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test no salesagent
    * @author Soumik Pattanayak | 16-01-2025 
    **/
    @isTest 
    public static void testAddSalesAgentPartyWithNoSa(){
        Map<String, Object> dataMap = getDataMap();
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');
        Account accountObj = getAccountByRecordType('Sales Agent');
        objApplication.Sales_Agent__c = accountObj.Id;
        Database.update(objApplication, true);
        Contact saContact = getContactByName('Tony Stark');
        Database.delete(saContact, true);

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.addSalesAgentParty(objApplication,new Map<String,Id>());
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.TRUE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test addSalesAgentParty Exception
    * @author Soumik Pattanayak | 16-01-2025 
    **/
    @isTest 
    public static void testAddSalesAgentPartySaAdminPartyContactNull(){
        Map<String, Object> dataMap = getDataMap();
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');
        Account accountObj = getAccountByRecordType('Sales Agent');
        objApplication.Sales_Agent__c = accountObj.Id;
        Database.update(objApplication, true);
        Contact saContact = getContactByName('Tim Couper');
        Database.delete(saContact, true);
        List<clcommon__Party__c> objPartyList = (List<clcommon__Party__c>)dataMap.get('partyList');
        for(clcommon__Party__c objParty: objPartyList){
            if(objParty.clcommon__Party_Types__c.equalsIgnoreCase(PortalConstants.PRINCIPAL_PARTY_NAME)){
                objParty.clcommon__Party_Types__c = PortalConstants.SALES_AGENT_ADMIN_PARTY;
                break;
            }
        }
        Database.update(objPartyList, true);

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.addSalesAgentParty(objApplication, new Map<String,Id>());
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.TRUE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

     /**
    * @description - Test addSalesAgentParty success
    * @author Soumik Pattanayak | 16-01-2025 
    **/
    @isTest 
    public static void testAddSalesAgentPartySaAdminRelPartyExist(){
        Map<String, Object> dataMap = getDataMap();
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');
        Account accountObj = getAccountByRecordType('Sales Agent');
        objApplication.Sales_Agent__c = accountObj.Id;
        Database.update(objApplication, true);
        Account saAdminAcountObj = getAccountByRecordType('Sales Agent Admin');
        List<clcommon__Party__c> objPartyList = (List<clcommon__Party__c>)dataMap.get('partyList');
        for(clcommon__Party__c objParty: objPartyList){
            if(objParty.clcommon__Party_Types__c.equalsIgnoreCase(PortalConstants.PRINCIPAL_PARTY_NAME)){
                objParty.clcommon__Party_Types__c = PortalConstants.SALES_AGENT_ADMIN_PARTY;
                objParty.clcommon__Account__c = saAdminAcountObj.Id;
                objParty.genesis__Application__c = objApplication.Id;
                break;
            }
        }
        Database.update(objPartyList, true);

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.addSalesAgentParty(objApplication,new Map<String,Id>());
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Success for add address
    * @author Sk Minsar | 01-24-2025 
    **/
    @isTest
    public static void testAddDBAAdressSuccess(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> dataMap = getDataMap();
        Account objAccount = (Account) dataMap.get('objAccount');
        List<clcommon__Party__c> partyList = (List<clcommon__Party__c>) dataMap.get('partyList');
        List<Map<String, Object>> coApplicants = new List<Map<String, Object>>{ new Map<String, Object>{
            PortalConstants.ID_KEY => objAccount.Id,
            PortalConstants.STREET_KEY => objAccount.BillingStreet,
            PortalConstants.CITY_KEY => objAccount.BillingStreet,
            PortalConstants.POSTAL_CODE_KEY => objAccount.BillingPostalCode,
            PortalConstants.STATE_KEY => objAccount.BillingState,
            PortalConstants.COUNTY_KEY => objAccount.Billing_County__c
        }};
        System.runAs(userObj){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.addDBAAdress(coApplicants, objAccount, partyList[0]);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();   
        }
    }

    /**
    * @description - Test addDefaultValuesToApplication success
    * @author Soumik Pattanayak | 16-01-2025 
    **/
    @isTest 
    public static void testAddDefaultValuesToApplication(){
        Map<String, Object> dataMap = getDataMap();
        User objUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');
        objApplication.genesis__Term__c = null;
        objApplication.genesis__Interest_Rate__c = null;
        objApplication.genesis__Pricing_Method__c = null;
        objApplication.genesis__Product_Type__c = null;

        System.runAs(objUser){
            Test.startTest();
                genesis__Applications__c resultApplication = PortalApplicationOriginationHelper.addDefaultValuesToApplication(objApplication);
                System.assertEquals(PortalConstants.TERM,resultApplication.genesis__Term__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test copyAdditionalPartyDetails success
    * @author Soumik Pattanayak | 16-01-2025 
    **/
    @isTest 
    public static void testCopyAdditionalPartyDetails(){
        Map<String, Object> dataMap = getDataMap();
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');
        Account objAccount = (Account) dataMap.get('objAccount');

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                PortalApplicationOriginationHelper.copyAdditionalPartyDetails(objApplication,objAccount);
                List<clcommon__Party__c> resultList = [SELECT Id,
                                                            clcommon__Account__c 
                                                            FROM clcommon__Party__c 
                                                            WHERE genesis__Application__c =: objApplication.Id];
                System.assertEquals(objAccount.Id, resultList[0].clcommon__Account__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
        
    }
    
    /**
    * @description - Test copyAdditionalPartyDetails success
    * @author Soumik Pattanayak | 16-01-2025 
    **/
    @isTest
    public static void testCopyAdditionalPartyDetailsforActiveApplication(){
        Map<String, Object> dataMap = getDataMap();
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');
        Account objAccount = (Account) dataMap.get('objAccount');

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                PortalApplicationOriginationHelper.copyAdditionalPartyDetails(objApplication,objAccount);
                List<clcommon__Party__c> resultList = [SELECT Id,
                                                            clcommon__Account__c 
                                                            FROM clcommon__Party__c 
                                                            WHERE genesis__Application__c =: objApplication.Id];
                System.assertEquals(objAccount.Id, resultList[0].clcommon__Account__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
        
    }
    
    /**
    * @description - Test createPrimaryApplicantParty success
    * @author Soumik Pattanayak | 16-01-2025 
    **/
    @isTest 
    public static void testCreatePrimaryApplicantsParty(){
        Map<String, Object> dataMap = getDataMap();
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');
        Contact objContact = (Contact)dataMap.get('contactList');
        clcommon__Legal_Entity__c solePropLegalEntity = (clcommon__Legal_Entity__c)dataMap.get('solePropLegalEntity');
        Account accountObj = (Account) dataMap.get('objAccount');                    
        accountObj.clcommon__Legal_Entity_Type__c = solePropLegalEntity.Id;
        Database.update(accountObj, true);
        Map<String, Id> mapOfpartyType = new Map<String, Id>();
        List<clcommon__Party_Type__c> objPrincipalPartyList = getPartyTypeList(PortalConstants.PRINCIPAL_PARTY_NAME);
        mapOfpartyType.put(PortalConstants.PRINCIPAL_PARTY_NAME,objPrincipalPartyList[0].Id);

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                PortalApplicationOriginationHelper.createPrimaryApplicantParty(objApplication,objContact,mapOfpartyType);
                List<clcommon__Party__c> resultList = [SELECT Id,
                                                            clcommon__Contact__c 
                                                            FROM clcommon__Party__c 
                                                            WHERE genesis__Application__c =: objApplication.Id ];
                System.assertEquals(objContact.Id, resultList[0].clcommon__Contact__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    
    /**
    * @description - Test createPrimaryApplicantParty success
    * @author Soumik Pattanayak | 16-01-2025 
    **/
    @isTest 
    public static void testCreatePrimaryApplicantsPartyNewContact(){
        Map<String, Object> dataMap = getDataMap();
        User objUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');
        Contact objContact = ApplicationOriginationTestHelper.createCoBorrowerContact(null);
        Map<String, Id> mapOfpartyType = new Map<String, Id>();
        List<clcommon__Party_Type__c> objPrincipalPartyList = getPartyTypeList(PortalConstants.PRINCIPAL_PARTY_NAME);
        mapOfpartyType.put(PortalConstants.PRINCIPAL_PARTY_NAME,objPrincipalPartyList[0].Id);

        System.runAs(objUser){
            Test.startTest();
                PortalApplicationOriginationHelper.createPrimaryApplicantParty(objApplication,objContact,mapOfpartyType);
                System.assertEquals(objContact.Id, objContact.Id, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test createPrimaryApplicantParty for null email
    * @author Soumik Pattanayak | 16-01-2025 
    **/
    @isTest 
    public static void testCreatePrimaryApplicantsPartyNullEmail(){
        Map<String, Object> dataMap = getDataMap();
        User objUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');
        Contact objContact = ApplicationOriginationTestHelper.createCoBorrowerContact(null);
        objContact.Email = null;
        Map<String, Id> mapOfpartyType = new Map<String, Id>();
        List<clcommon__Party_Type__c> objPrincipalPartyList = getPartyTypeList(PortalConstants.PRINCIPAL_PARTY_NAME);
        mapOfpartyType.put(PortalConstants.PRINCIPAL_PARTY_NAME,objPrincipalPartyList[0].Id);

        System.runAs(objUser){
            Test.startTest();
                PortalApplicationOriginationHelper.createPrimaryApplicantParty(objApplication,objContact,mapOfpartyType);
                System.assertEquals(objContact.Id, objContact.Id, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test populateDBAApplicant success
    * @author Soumik Pattanayak | 16-01-2025 
    **/
    @isTest 
    public static void testPopulateDBAApplicant(){
        Map<String, Object> dataMap = getDataMap();
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Account objAccount = getAccountByRecordType('Sales Agent');
        Contact objContact = (Contact)dataMap.get('contactList');
        objContact.Confirm_Email__c = objContact.Email;

        System.runAs(userObj){
            Test.startTest();
                PortalApplicationOriginationHelper.populateDBAApplicant(objAccount,objContact, objContact);
                System.assertEquals(PortalConstants.FALSE_VALUE, objAccount.Is_Individual__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test createSharingRecords success
    * @author Soumik Pattanayak | 16-01-2025 
    **/
    @isTest 
    public static void testCreateSharingRecords(){
        Map<String, Object> dataMap = getDataMap();
        User objCertifiedLenderUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                PortalApplicationOriginationHelper.createSharingRecords(objCertifiedLenderUser,objApplication);
                Integer sharingRecordSize = [SELECT id FROM genesis__Applications__Share].size();
                System.assertEquals(PortalConstants.TRUE_VALUE, sharingRecordSize>0, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Success for nullifyContactNumbers
    * @author Sk Minsar | 01-24-2025 
    **/
    @isTest
    public static void testNullifyContactNumbersSuccess(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> dataMap = getDataMap();
        Account objAccount = (Account) dataMap.get('objAccount');
        Contact objContact = (Contact) dataMap.get('contactList');
        objContact.MobilePhone = null;
        objContact.Phone = null;
        objAccount.Work_Number__c = null;
        objAccount.Home_Number__c = null;
        objAccount.Phone = null;

        System.runAs(userObj){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.nullifyContactNumbers(objAccount, objContact);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();   
        }
    }

    /**
    * @description - Test updatePrincipalCoopType with success
    * @author Soumik Pattanayak | 16-01-2025 
    **/
    @isTest 
    public static void testUpdatePrincipalCoopType(){
        Map<String, Object> dataMap = getDataMap();
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                PortalApplicationOriginationHelper.updatePrincipalCoopType(objApplication.Id);
                List<Account> resultList = [SELECT Id,Coop_Type__c FROM Account WHERE Id = :objApplication.genesis__Account__c ];
                System.assertEquals(null, resultList[0].Coop_Type__c, PortalConstants.ASSERTION_FAILED);
            Test.stopTest(); 
        }
    }

    /**
    * @description - Success for setNullIfEmpty account
    * @author Sk Minsar | 01-24-2025 
    **/
    @isTest
    public static void testSetNullIfEmptySuccess(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> dataMap = getDataMap();
        Account objAccount = (Account) dataMap.get('objAccount');
        clcommon__Legal_Entity__c objSolePropLegalEntity = (clcommon__Legal_Entity__c)dataMap.get('solePropLegalEntity');
        objAccount.clcommon__Legal_Entity_Type__c=objSolePropLegalEntity.id;
        objAccount.Confirm_Email__c = 'jasmin.albin@yopmail.com';
        objAccount.Year_Began_Farming__c = '2000';
        Database.update(objAccount, true);

        System.runAs(userObj){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.setNullIfEmpty(objAccount, PortalConstants.CFA_COOP_TYPE);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();   
        }
    }

    /**
    * @description - Success for setNullIfEmpty account for null email
    * @author Sk Minsar | 01-24-2025 
    **/
    @isTest
    public static void testSetNullIfEmptyEmailNull(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> dataMap = getDataMap();
        Account objAccount = (Account) dataMap.get('objAccount');
        clcommon__Legal_Entity__c objSolePropLegalEntity = (clcommon__Legal_Entity__c)dataMap.get('solePropLegalEntity');
        objAccount.clcommon__Legal_Entity_Type__c=objSolePropLegalEntity.id;
        objAccount.clcommon__Email__c = null;
        objAccount.Confirm_Email__c = 'jasmin.albin@yopmail.com';
        objAccount.Year_Began_Farming__c = '2000';
        Database.update(objAccount, true);

        System.runAs(userObj){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.setNullIfEmpty(objAccount, PortalConstants.CFA_COOP_TYPE);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();   
        }
    }

    /**
    * @description - Success for setNullIfEmpty account for null confirm email
    * @author Sk Minsar | 01-24-2025 
    **/
    @isTest
    public static void testSetNullIfEmptyConfirmEmailNull(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> dataMap = getDataMap();
        Account objAccount = (Account) dataMap.get('objAccount');
        clcommon__Legal_Entity__c objSolePropLegalEntity=(clcommon__Legal_Entity__c)dataMap.get('solePropLegalEntity');
        objAccount.Confirm_Email__c = null;
        objAccount.Year_Began_Farming__c = '2000';
        objAccount.clcommon__Legal_Entity_Type__c=objSolePropLegalEntity.id;
        Database.update(objAccount, true);

        System.runAs(userObj){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.setNullIfEmpty(objAccount, PortalConstants.CFA_COOP_TYPE);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();   
        }
    }

    /**
    * @description - Success for setNullIfEmpty account for null year began farming
    * @author Sk Minsar | 01-24-2025 
    **/
    @isTest
    public static void testSetNullIfEmptyYBFNull(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> dataMap = getDataMap();
        Account objAccount = (Account) dataMap.get('objAccount');
        clcommon__Legal_Entity__c objSolePropLegalEntity=(clcommon__Legal_Entity__c)dataMap.get('solePropLegalEntity');
        objAccount.clcommon__Legal_Entity_Type__c=objSolePropLegalEntity.id;
        objAccount.Confirm_Email__c = null;
        objAccount.Year_Began_Farming__c = '2000';
        Database.update(objAccount, true);

        System.runAs(userObj){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.setNullIfEmpty(objAccount, PortalConstants.CFA_COOP_TYPE);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();   
        }
    }

    /**
    * @description - Success for returnEmptyStringForField 
    * @author Sk Minsar | 01-24-2025 
    **/
    @isTest
    public static void testEmptyStringForFieldSuccess(){
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        System.runAs(userObj){
            Test.startTest();
                String result = PortalApplicationOriginationHelper.returnEmptyStringForField('');
                System.assertEquals(PortalConstants.EMPTY_STRING, result, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();   
        }
    }

    /**
    * @description - Success for setNullIfEmpty contact
    * @author Sk Minsar | 01-24-2025 
    **/
    @isTest
    public static void testSetNullIfEmptyContactSuccess(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> dataMap = getDataMap();
        List<Contact> contactList = new List<Contact>{(Contact) dataMap.get('contactList')};
        contactList[0].ints__Middle_Name__c = 'jon';
        contactList[0].Suffix__c = 'Jr';
        contactList[0].clcommon__Marital_Status__c = 'Separated';
        contactList[0].Confirm_Email__c = 'jasmin.albin@yopmail.com';
        contactList[0].Birthdate = Date.valueOf(datetime.newInstance(2000, 1, 1));

        System.runAs(userObj){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.setNullIfEmpty(contactList[0], PortalConstants.CFA_COOP_TYPE);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();   
        }
    }

    /**
    * @description - Success for setNullIfEmpty contact for Growmark
    * @author Sk Minsar | 01-24-2025 
    **/
    @isTest
    public static void testSetNullIfEmptyContactGmkSuccess(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> dataMap = getDataMap();
        Contact contactObj = (Contact) dataMap.get('contactList');
        contactObj.ints__Middle_Name__c = 'jon';
        contactObj.Suffix__c = 'Jr';
        contactObj.clcommon__Marital_Status__c = 'Separated';
        contactObj.Confirm_Email__c = 'jasmin.albin@yopmail.com';
        contactObj.Birthdate = Date.valueOf(datetime.newInstance(2000, 1, 1));

        System.runAs(userObj){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.setNullIfEmpty(contactObj, PortalConstants.GROWMARK_COOP_TYPE);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();   
        }
    }

    /**
    * @description - Success for setNullIfEmpty Business
    * @author Sk Minsar | 01-24-2025 
    **/
    @isTest
    public static void testSetNullIfEmptyBusinessSuccess(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Business_Information__c> businessInfoList = (List<genesis__Business_Information__c>) dataMap.get('businessInfoList');
        businessInfoList[0].genesis__State_of_Incorporation__c = 'Mo';
        businessInfoList[0].Gross_Farm_Income__c = 123456.55;

        System.runAs(userObj){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.setNullIfEmpty(businessInfoList[0], PortalConstants.CFA_COOP_TYPE);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();   
        }
    }

    /**
    * @description - Success for setNullIfEmpty Business for Growmark
    * @author Sk Minsar | 01-24-2025 
    **/
    @isTest
    public static void testSetNullIfEmptyBusinessGmkSuccess(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Business_Information__c> businessInfoList = (List<genesis__Business_Information__c>) dataMap.get('businessInfoList');
        businessInfoList[0].genesis__State_of_Incorporation__c = 'Mo';
        businessInfoList[0].Gross_Farm_Income__c = 123456.55;

        System.runAs(userObj){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.setNullIfEmpty(businessInfoList[0], PortalConstants.GROWMARK_COOP_TYPE);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();   
        }
    }

    /**
    * @description - Success for checkEmailDetails
    * @author Sk Minsar | 01-24-2025 
    **/
    @isTest
    public static void testCheckEmailDetailsSuccess(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> objApplicationList = new List<genesis__Applications__c>{(genesis__Applications__c)dataMap.get('objApplication')};
        List<clcommon__Party__c> partyList = (List<clcommon__Party__c>) dataMap.get('partyList');

        System.runAs(userObj){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.checkEmailDetails(objApplicationList, partyList,  PortalConstants.PAPER_SCANNED);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();   
        }
    }

    /**
    * @description - Success for party having null id checkEmailDetails
    * @author Sk Minsar | 01-24-2025 
    **/
    @isTest
    public static void testCheckEmailDetailsPartyNotNullId(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> dataMap = getDataMap();
        List<Map<String, String>> applicantDetails = new List<Map<String, String>>();
        List<clcommon__Party__c> partyList = (List<clcommon__Party__c>) dataMap.get('partyList');
        for(clcommon__Party__c party:partyList){
            applicantDetails.add(new Map<String, String>{
                'id' => String.valueOf(party.Id),
                'clcommon__Contact__r.Email' => String.valueOf(party.clcommon__Contact__r.Email)
            });
        }
        partyList[0].Id = null;

        System.runAs(userObj){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.checkEmailDetails(applicantDetails, partyList,  PortalConstants.PAPER_SCANNED);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();   
        }
    }

    /**
    * @description - Exception for checkEmailDetails
    * @author Sk Minsar | 01-24-2025 
    **/
    @isTest
    public static void testCheckEmailDetailsEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> dataMap = getDataMap();
        List<genesis__Applications__c> objApplicationList = new List<genesis__Applications__c>{(genesis__Applications__c)dataMap.get('objApplication')};
        List<clcommon__Party__c> partyList = (List<clcommon__Party__c>) dataMap.get('partyList');

        System.runAs(userObj){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.checkEmailDetails(objApplicationList, partyList,  PortalConstants.EMAIL_DOCUSIGN);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.TRUE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();   
        }
    }

    /**
    * @description - Success for checkSignAgreementTask paper-scanned
    * @author Sk Minsar | 01-24-2025 
    **/
    @isTest
    public static void testCheckSignAgreementTaskSuccess(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> dataMap = getDataMap();
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');

        System.runAs(userObj){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.checkSignAgreementTask(PortalConstants.PAPER_SCANNED, objApplication.Id);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();   
        }
    }

    /**
    * @description - Test checkSignAgreementTask in-person docusign
    * @author Sk Minsar | 01-24-2025 
    **/
    @isTest
    public static void testCheckSignAgreementTask(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> dataMap = getDataMap();
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');

        System.runAs(userObj){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.checkSignAgreementTask(PortalConstants.IN_PERSON_DOCUSIGN, objApplication.Id);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();   
        }
    }

    /**
    * @description - Success for checkCoApplicant
    * @author Sk Minsar | 01-24-2025 
    **/
    @isTest
    public static void testCheckCoApplicantContact(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> dataMap = getDataMap();
        List<clcommon__Party__c> partyList = (List<clcommon__Party__c>) dataMap.get('partyList');

        System.runAs(userObj){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.checkCoApplicant(new List<clcommon__Party__c>{partyList[0]});
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.TRUE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();   
        }
    }

    /**
    * @description - Exception for checkAssetAndLiability total asset null
    * @author Sk Minsar | 01-24-2025 
    **/
    @isTest
    public static void testCheckAssetAndLiabilityEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> dataMap = getDataMap();
        List<clcommon__Party__c> partyList = (List<clcommon__Party__c>) dataMap.get('partyList');
        partyList[0].Total_Assets__c = null;

        System.runAs(userObj){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.checkAssetAndLiability(partyList[0]);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.TRUE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();   
        }
    }

    /**
    * @description - Exception for checkAssetAndLiability total liabilities null
    * @author Sk Minsar | 01-24-2025 
    **/
    @isTest
    public static void testCheckAssetAndLiabilityLiabNullEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, Object> dataMap = getDataMap();
        List<clcommon__Party__c> partyList = (List<clcommon__Party__c>) dataMap.get('partyList');
        partyList[0].Total_Assets__c = 12345;
        partyList[0].Total_Liabilities__c = null;

        System.runAs(userObj){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.checkAssetAndLiability(partyList[0]);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.TRUE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();   
        }
    }

    /**
    * @description - Exception for checkEmptyList
    * @author Sk Minsar | 01-24-2025 
    **/
    @isTest
    public static void testCheckEmptyListEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        System.runAs(userObj){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.checkEmptyList(new List<Object>(), PortalConstants.REQUIRED_PARAMETERS_MISSING);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.TRUE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();   
        }
    }

    /**
    * @description - Exception for checkValidUser
    * @author Sk Minsar | 01-24-2025 
    **/
    @isTest
    public static void testCheckValidUserEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        System.runAs(userObj){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.checkValidUser(PortalConstants.FALSE_VALUE);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.TRUE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();   
        }
    }

    /**
    * @description - Success for fetchSAAdmin
    * @author Sk Minsar | 01-24-2025 
    **/
    @isTest
    public static void testFetchSAAdminSuccess(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Account accountObj = getAccountByRecordType('Sales Agent');

        System.runAs(userObj){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.fetchSAAdmin(accountObj.Id);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();   
        }
    }

    /**
    * @description - Test deleteObjparty success
    * @author Sk Minsar | 01-22-2025 
    **/
    @isTest
    public static void testDeleteObjParty(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');
        List<clcommon__Party__c> objParty = (List<clcommon__Party__c>)dataMap.get('partyList');

        System.runAs(userObj){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.deleteObjparty(objApplication.Id, objParty[0].Id,'clcommon__Party__c');
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test deleteObjparty success
    * @author Sk Minsar | 01-22-2025 
    **/
    @isTest
    public static void testDeleteObjPartyInsuranceAgent(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        clcommon__Party__c partyToDelete = new clcommon__Party__c();
        Map<String, Object> dataMap = getDataMap();
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');
        List<clcommon__Party__c> objPartyList = (List<clcommon__Party__c>)dataMap.get('partyList');
        for(clcommon__Party__c objParty: objPartyList){
            if(objParty.clcommon__Party_Types__c.equalsIgnoreCase(PortalConstants.PRINCIPAL_PARTY_NAME)){
                objParty.clcommon__Party_Types__c = PortalConstants.INSURANCE_AGENT_PARTY_NAME;
                partyToDelete = objParty;
                break;
            }
        }
        Database.update(objPartyList, true);

        System.runAs(userObj){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.deleteObjparty(objApplication.Id, partyToDelete.Id,'clcommon__Party__c');
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test deleteObjparty success
    * @author Sk Minsar | 01-22-2025 
    **/
    @isTest
    public static void testDeleteObjPartyPrincipal(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        clcommon__Party__c partyToDelete = new clcommon__Party__c();
        Map<String, Object> dataMap = getDataMap();
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');
        List<clcommon__Party__c> objPartyList = (List<clcommon__Party__c>)dataMap.get('partyList');
        for(clcommon__Party__c objParty: objPartyList){
            if(objParty.clcommon__Party_Types__c.equalsIgnoreCase(PortalConstants.PRINCIPAL_PARTY_NAME)){
                objParty.clcommon__Party_Types__c = PortalConstants.PRINCIPAL_PARTY_NAME;
                partyToDelete = objParty;
                break;
            }
        }
        Database.update(objPartyList, true);

        System.runAs(userObj){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.deleteObjparty(objApplication.Id, partyToDelete.Id,'clcommon__Party__c');
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test deleteObjparty success
    * @author Sk Minsar | 01-22-2025 
    **/
    @isTest
    public static void testDeleteObjPartyBuyer(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        clcommon__Party__c partyToDelete = new clcommon__Party__c();
        Map<String, Object> dataMap = getDataMap();
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');
        List<clcommon__Party__c> objPartyList = (List<clcommon__Party__c>)dataMap.get('partyList');
        for(clcommon__Party__c objParty: objPartyList){
            if(objParty.clcommon__Party_Types__c.equalsIgnoreCase(PortalConstants.PRINCIPAL_PARTY_NAME)){
                objParty.clcommon__Party_Types__c = PortalConstants.BUYER_PARTY_NAME;
                partyToDelete = objParty;
                break;
            }
        }
        Database.update(objPartyList, true);

        System.runAs(userObj){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.deleteObjparty(objApplication.Id, partyToDelete.Id,'clcommon__Party__c');
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test deletePrincipalParty success
    * @author Soumik Pattanayak | 15-01-2025 
    **/
    @isTest
    public static void testDeletePrincipalParty(){
        Map<String, Object> dataMap = getDataMap();
        clcommon__Party__c partyToDelete = new clcommon__Party__c();
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');
        genesis__Applications__c appObj = (genesis__Applications__c)dataMap.get('objApplication');
        List<clcommon__party__c> objPartyList = (List<clcommon__party__c>)dataMap.get('partyList');
        for(clcommon__Party__c objParty: objPartyList){
            if(objParty.clcommon__Party_Types__c.equalsIgnoreCase(PortalConstants.BORROWER_PARTY_NAME)){
                partyToDelete = objParty;
                break;
            }
        }

        System.runAs(userObj){
            Test.startTest();
                PortalApplicationOriginationHelper.deletePrincipalParty(partyToDelete,appObj.id);
                List<clcommon__party__c> objUpdatedPartyList = [SELECT Id,clcommon__Account__c FROM clcommon__Party__c WHERE clcommon__Account__c =: appObj.genesis__Account__c];
                System.assertEquals(PortalConstants.TRUE_VALUE, objUpdatedPartyList.size()==0,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test deletePrincipalAndOther success for principal party
    * @author Sk Minsar | 01-22-2025 
    **/
    @isTest
    public static void testDeletePrincipalAndOtherSingleApp(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        clcommon__Party__c partyToDelete = new clcommon__Party__c();
        Map<String, Object> dataMap = getDataMap();
        User objUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');
        List<clcommon__party__c> objPartyList = (List<clcommon__party__c>)dataMap.get('partyList');
        for(clcommon__Party__c objParty: objPartyList){
            if(objParty.clcommon__Party_Types__c.equalsIgnoreCase(PortalConstants.PRINCIPAL_PARTY_NAME)){
                partyToDelete = objParty;
                break;
            }
        }

        System.runAs(objUser){
            Test.StartTest();
                try{
                    PortalApplicationOriginationHelper.deletePrincipalAndOther(partyToDelete);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test deletePrincipalAndOther success
    * @author Sk Minsar | 01-22-2025 
    **/
    @isTest
    public static void testDeletePrincipalAndOtherMultiApp(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        clcommon__Party__c partyToDelete = new clcommon__Party__c();
        Map<String, Object> dataMap = getDataMap();
        User objUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');
        List<clcommon__party__c> objPartyList = (List<clcommon__party__c>)dataMap.get('partyList');
        for(clcommon__Party__c objParty: objPartyList){
            if(objParty.clcommon__Party_Types__c.equalsIgnoreCase(PortalConstants.BORROWER_PARTY_NAME)){
                partyToDelete = objParty;
                break;
            }
        }

        System.runAs(objUser){
            Test.StartTest();
                try{
                    PortalApplicationOriginationHelper.deletePrincipalAndOther(partyToDelete);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.TRUE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test deletePrincipalAndOther success
    * @author Sk Minsar | 01-22-2025 
    **/
    @isTest
    public static void testDeletePrincipalAndOtherMultiAppContact(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        clcommon__Party__c partyToDelete = new clcommon__Party__c();
        Map<String, Object> dataMap = getDataMap();
        User objUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');
        List<clcommon__party__c> objPartyList = (List<clcommon__party__c>)dataMap.get('partyList');
        for(clcommon__Party__c objParty: objPartyList){
            if(objParty.clcommon__Party_Types__c.equalsIgnoreCase(PortalConstants.BORROWER_PARTY_NAME)){
                objParty.clcommon__Contact__c = null;
                partyToDelete = objParty;
                break;
            }
        }

        System.runAs(objUser){
            Test.StartTest();
                try{
                    PortalApplicationOriginationHelper.deletePrincipalAndOther(partyToDelete);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.TRUE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    
    /**
    * @description - Test deletePrincipalAndOther success
    * @author Sk Minsar | 01-22-2025 
    **/
    @isTest
    public static void testDeletePrincipalAndOtherWithoutSoleProp(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        User objUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');
        List<clcommon__Party__c> objParty =[SELECT Id,
                                                clcommon__Party_Types__c,
                                                clcommon__Account__c,
                                                clcommon__Contact__c,
                                                genesis__Application__r.genesis__Account__r.clcommon__Legal_Entity_Type__r.Name
                                                FROM clcommon__Party__c
                                                WHERE genesis__Application__c =:objApplication.Id
                                                AND clcommon__Party_Types__c = 'PRINCIPAL'
                                                AND genesis__Application__r.genesis__Account__r.clcommon__Legal_Entity_Type__r.Name != 'Individual(s) - Sole Proprietorship'
                                                ORDER BY CreatedDate ASC ];

        System.runAs(objUser){
            Test.StartTest();
                try{
                    PortalApplicationOriginationHelper.deletePrincipalAndOther(objParty[0]);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test deleteCollateral success
    * @author Sk Minsar | 01-22-2025 
    **/
    @isTest
    public static void testDeleteCollateral(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        User objUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');
        List<clcommon__Collateral__c> objCollateralList = (List<clcommon__Collateral__c>)dataMap.get('objCollateralList');

        System.runAs(objUser){
            Test.StartTest();
                try{
                    PortalApplicationOriginationHelper.deleteCollateral(objApplication.Id, objCollateralList[0].Id);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    
    /**
    * @description - Test deleteRateCardHeader success
    * @author Sk Minsar | 01-22-2025 
    **/
    @isTest
    public static void testDeleteRateCardHeader() {
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__rate_card_setup_header__c> rateCardList = getRateCardHeaderList();

        System.runAs(userObj) {
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.deleteRateCardHeader(String.valueOf(rateCardList[0].Id));
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test deleteRateCardHeader delete RateCardHeader with diff dealer
    * @author Sk Minsar | 01-22-2025 
    **/
    @isTest
    public static void testDeleteRateCardHeaderDiffDealer() {
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__rate_card_setup_header__c> rateCardList = getRateCardHeaderList();
        Account accountObj = getAccountByRecordType('Sales Agent');
        rateCardList[0].Account__c = accountObj.Id;
        Database.update(rateCardList, true);

        System.runAs(userObj) {
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.deleteRateCardHeader(String.valueOf(rateCardList[0].Id));
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.TRUE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Success for getDealerId
    * @author Sk Minsar | 01-24-2025 
    **/
    @isTest
    public static void testGetDealerId(){
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        System.runAs(userObj){
            Test.startTest();
                String result = PortalApplicationOriginationHelper.getDealerId();
                System.assertEquals(PortalConstants.TRUE_VALUE, result!=null, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();   
        }
    }

    /**
    * @description - Test deleteRateCardDetail Exception
    * @author Sk Minsar | 01-22-2025 
    **/
    @isTest
    public static void testDeleteRateCardDetailTermA() {
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__rate_card_setup_header__c> rateCardList = getRateCardHeaderList();
        List<genesis__Rate_Card_Setup_Detail__c> rateCardDetailList = getRateCardSetupDetails(rateCardList[0].Id);
        rateCardDetailList[0].genesis__Enabled_flag__c = PortalConstants.FALSE_VALUE;
        rateCardDetailList[0].Special_Term_Reference__c = PortalConstants.SPECIAL_TERM_A;
        Database.update(rateCardDetailList[0],true);

        System.runAs(userObj){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.deleteRateCardDetail(rateCardDetailList[0].Id);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.TRUE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }

    }

    /**
    * @description - Test deleteRateCardDetail success
    * @author Sk Minsar | 01-22-2025 
    **/
    @isTest
    public static void testDeleteRateCardDetail() {
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__rate_card_setup_header__c> rateCardList = getRateCardHeaderList();
        List<genesis__Rate_Card_Setup_Detail__c> rateCardDetailList = getRateCardSetupDetails(rateCardList[0].Id);
        rateCardDetailList[0].genesis__Enabled_flag__c = PortalConstants.FALSE_VALUE;
        rateCardDetailList[0].Special_Term_Reference__c = PortalConstants.SPECIAL_TERM_B;
        Database.update(rateCardDetailList[0],true);

        System.runAs(userObj){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.deleteRateCardDetail(rateCardDetailList[0].Id);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }

    }

    /**
    * @description - Test deleteRateCardDetail Exception scenario
    * @author Sk Minsar | 01-22-2025 
    **/
    @isTest
    public static void testDeleteRateCardDetailHeaderNull() {
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        System.runAs(userObj){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.deleteRateCardDetail(null);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.TRUE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }

    }

    /**
    * @description - Test deleteRateCardDetail success 
    **/
    @isTest
    public static void testDeleteRateCardSingleDescription() {
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        List<genesis__Rate_Card_Setup_Detail__c> rateCardListToDelete = new List<genesis__Rate_Card_Setup_Detail__c>();
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__rate_card_setup_header__c> rateCardList = getRateCardHeaderList();
        List<genesis__Rate_Card_Setup_Detail__c> rateCardDetailList = getRateCardSetupDetails(rateCardList[0].Id);
        rateCardDetailList[0].genesis__Enabled_flag__c = PortalConstants.FALSE_VALUE;
        rateCardDetailList[0].Special_Term_Reference__c = PortalConstants.SPECIAL_TERM_B;
        Database.update(rateCardDetailList,true);
        List<genesis__Rate_Card_Setup_Detail__c> rateCardDetailsList = getRateCardDetailListByRateCard(rateCardDetailList);
        for(Integer index = 1;index<rateCardDetailsList.size(); index++){
            rateCardListToDelete.add(rateCardDetailsList.get(index));
        }
        Database.delete(rateCardListToDelete,true);

        System.runAs(userObj){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.deleteRateCardDetail(rateCardDetailList[0].Id);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test deleteRateCardDetail for SingleDescription spercial term A success
    **/
    @isTest
    public static void testDeleteRateCardSingleDescriptionA() {
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        List<genesis__Rate_Card_Setup_Detail__c> rateCardListToDelete = new List<genesis__Rate_Card_Setup_Detail__c>();
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__rate_card_setup_header__c> rateCardList = getRateCardHeaderList();
        List<genesis__Rate_Card_Setup_Detail__c> rateCardDetailList = getRateCardSetupDetails(rateCardList[0].Id);
        rateCardDetailList[0].genesis__Enabled_flag__c = PortalConstants.FALSE_VALUE;
        rateCardDetailList[0].Special_Term_Reference__c = PortalConstants.SPECIAL_TERM_A;
        rateCardDetailList[0].End_Date__c = Date.valueOf(rateCardList[0].genesis__End_Date__c.addDays(-2));
        Database.update(rateCardDetailList,true);
        List<genesis__Rate_Card_Setup_Detail__c> rateCardDetailsList = getRateCardDetailListByRateCard(rateCardDetailList);
        for(Integer index = 1;index<rateCardDetailsList.size(); index++){
            rateCardListToDelete.add(rateCardDetailsList.get(index));
        }
        Database.delete(rateCardListToDelete,true);

        System.runAs(userObj){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.deleteRateCardDetail(rateCardDetailList[0].Id);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.TRUE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test deleteRateCardDetail for coopRateCardDetail rate card detail & rate card header start date different
    **/
    @isTest
    public static void testDeleteRateCardSingleDescriptionC() {
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        List<genesis__Rate_Card_Setup_Detail__c> rateCardListToDelete = new List<genesis__Rate_Card_Setup_Detail__c>();
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__rate_card_setup_header__c> rateCardList = getRateCardHeaderList();
        List<genesis__Rate_Card_Setup_Detail__c> rateCardDetailList = getRateCardSetupDetails(rateCardList[0].Id);
        rateCardDetailList[0].genesis__Enabled_flag__c = PortalConstants.FALSE_VALUE;
        rateCardDetailList[0].Special_Term_Reference__c = PortalConstants.SPECIAL_TERM_C;
        rateCardDetailList[0].End_Date__c = Date.valueOf(rateCardList[0].genesis__End_Date__c.addDays(-2));
        rateCardDetailList[0].Start_Date__c = Date.valueOf(rateCardList[0].genesis__Start_Date__c.addDays(2));
        Database.update(rateCardDetailList,true);
        List<genesis__Rate_Card_Setup_Detail__c> rateCardDetailsList = getRateCardDetailListByRateCard(rateCardDetailList);
        for(Integer index = 1;index<rateCardDetailsList.size(); index++){
            rateCardListToDelete.add(rateCardDetailsList.get(index));
        }
        Database.delete(rateCardListToDelete,true);

        System.runAs(userObj){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.deleteRateCardDetail(rateCardDetailList[0].Id);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown ,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test deleteRateCardDetail for SingleDescription spercial term A success scenario for Growmark
    **/
    @isTest
    public static void testDeleteRateCardSingleDescriptionAGmk() {
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        List<genesis__Rate_Card_Setup_Detail__c> rateCardListToDelete = new List<genesis__Rate_Card_Setup_Detail__c>();
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__rate_card_setup_header__c> rateCardList = getRateCardHeaderList();
        List<genesis__Rate_Card_Setup_Detail__c> rateCardDetailList = getRateCardSetupDetails(rateCardList[0].Id);
        rateCardDetailList[0].genesis__Enabled_flag__c = PortalConstants.FALSE_VALUE;
        rateCardDetailList[0].Special_Term_Reference__c = PortalConstants.SPECIAL_TERM_A;
        rateCardDetailList[0].End_Date__c = Date.valueOf(rateCardList[0].genesis__End_Date__c.addDays(-2));
        Database.update(rateCardDetailList,true);
        List<genesis__Rate_Card_Setup_Detail__c> rateCardDetailsList = getRateCardDetailListByRateCard(rateCardDetailList);
        for(Integer index = 1;index<rateCardDetailsList.size(); index++){
            rateCardListToDelete.add(rateCardDetailsList.get(index));
        }
        Database.delete(rateCardListToDelete,true);
        System.runAs(userObj){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.deleteRateCardDetail(rateCardDetailList[0].Id);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.TRUE_VALUE, isExceptionThrown ,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test deleteBankAccount success
    * @author Sk Minsar | 01-22-2025 
    **/
    @isTest
    public static void testBankAccountDeletion() {
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User objUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');
        List<clcommon__Bank_Account__c> bankAccountList = getBankAccountByAccountList(String.valueOf(objUser.accountId));

        System.runAs(objUser){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.deleteBankAccount(bankAccountList[0].Id);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown ,'Bank Account deletion failed');
            Test.stopTest();
        }
    }

    /**
    * @description - Test deleteBankAccount Exception scenario for unauthorized user
    * @author Sk Minsar | 01-22-2025 
    **/
    @isTest
    public static void testBankAccountDeletionUnAuthorizedUser() {
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User objUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');
        Account objAccount = getAccountByRecordType('Sales Agent');
        List<clcommon__Bank_Account__c> bankAccountList = getBankAccountByAccountList(String.valueOf(objUser.accountId));
        bankAccountList[0].clcommon__Account__c = objAccount.Id;
        Database.update(bankAccountList, true);

        System.runAs(objUser){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.deleteBankAccount(bankAccountList[0].Id);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.TRUE_VALUE, isExceptionThrown ,'Bank Account deletion failed');
            Test.stopTest();
        }
    }

    /**
    * @description - Test sendEmailToGrower success
    * @author Sk Minsar | 01-24-2025 
    **/
    @isTest
    public static void testSendEmailToGrower(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');
        Account objAccount = (Account) dataMap.get('objAccount');

        System.runAs(userObj){
            Test.StartTest();
                try{
                    PortalApplicationOriginationHelper.sendEmailToGrower(objAccount.id,'ravi@yopmail.com', objApplication);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE,isExceptionThrown,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test sendEmailToGrower for Growmark dealer success
    * @author Sk Minsar | 01-24-2025 
    **/
    @isTest
    public static void testSendEmailToGrowerGmk(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');
        Account objAccount = (Account) dataMap.get('objAccount');
        Account dealerAccountObj = getAccountByRecordType('DEALER');
        dealerAccountObj.Coop_Type__c = 'Growmark';  
        Database.update(dealerAccountObj, true);

        System.runAs(userObj){
            Test.StartTest();
                try{
                    PortalApplicationOriginationHelper.sendEmailToGrower(objAccount.id,'ravi@yopmail.com', objApplication);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE,isExceptionThrown,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test sendEmailToGrower success for invalid user
    * @author Sk Minsar | 01-24-2025 
    **/
    @isTest
    public static void testsendEmailToGrowerInvalidUser(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');
        Account accountObj = getAccountByRecordType('Sales Agent Admin');

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.StartTest();
                try{
                    PortalApplicationOriginationHelper.sendEmailToGrower(accountObj.Id,'ravi@yopmail.com', objApplication);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE,isExceptionThrown,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test populateCorporationCoApplicant success
    * @author Soumik Pattanayak | 16-01-2025 
    **/
    @isTest 
    public static void testPopulateCorporationCoApplicant(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Account objAccount = getAccountByRecordType('Sales Agent');
        objAccount.Confirm_Email__c=objAccount.clcommon__Email__c;
        Contact objContact = (Contact)dataMap.get('contactList');
        objContact.Confirm_Email__c = objContact.Email;

        System.runAs(userObj){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.populateCorporationCoApplicant(objAccount,objContact, objContact);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }     
    }

    /**
    * @description - Test updateBorrowerParty
    * @author Soumik Pattanayak | 16-01-2025 
    **/
    @isTest 
    public static void testUpdateBorrowerParty(){
        Map<String, Object> dataMap = getDataMap();
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                PortalApplicationOriginationHelper.updateBorrowerParty(objApplication.Id);
                List<Contact> resultList = [SELECT Id,AccountId FROM Contact WHERE Id = :objApplication.genesis__Contact__c ];
                System.assertEquals(objApplication.genesis__Account__c, resultList[0].AccountId, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        } 
    }

    /**
    * @description - Test updateBorrowerParty
    * @author Soumik Pattanayak | 16-01-2025 
    **/
    @isTest 
    public static void testCreateBorrowerParty(){
        Map<String, Object> dataMap = getDataMap();
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');
        List<clcommon__party__c> objBorrowerPartyList = getPartyList(objApplication.genesis__Account__c); 
        objBorrowerPartyList[0].genesis__Application__c = null;
        Database.update(objBorrowerPartyList,true);

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                PortalApplicationOriginationHelper.updateBorrowerParty(objApplication.Id);
                List<Contact> resultList = [SELECT Id,AccountId FROM Contact WHERE Id = :objApplication.genesis__Contact__c ];
                System.assertEquals(objApplication.genesis__Account__c, resultList[0].AccountId, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

   
     /**
    * @description - Test addDBAAdress
    * @author Soumik Pattanayak | 16-01-2025 
    **/
    @isTest 
    public static void testAddDBAAdress(){
        Map<String, Object> dataMap = getDataMap();
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');
        List<Map<String, Object>> objCoApplicant = new List<Map<String, Object>>();
        Account objAccount = (Account) dataMap.get('objAccount');
        List<clcommon__party__c> objBorrowerPartyList = getPartyList(objApplication.genesis__Account__c); 

        System.runAs(userObj){
            Test.startTest();
                Account accountObj = PortalApplicationOriginationHelper.addDBAAdress(objCoApplicant, objAccount, objBorrowerPartyList[0]);
                System.assertEquals(objBorrowerPartyList[0].City__c, accountObj.BillingCity, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test gmkRateCardDetail success
    * @author Sk Minsar | 01-24-2025 
    **/
    @isTest
    public static void testNoGmkRateCardDetail() {
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Account dealerAccountObj = getAccountByRecordType('DEALER');
        dealerAccountObj.Coop_Type__c = 'Growmark';  
        Database.update(dealerAccountObj, true);
        List<genesis__rate_card_setup_header__c> rateCardList = getRateCardHeaderList();
        List<genesis__Rate_Card_Setup_Detail__c> rateCardDetailObjList = getRateCardSetupDetails(rateCardList[0].Id);

        System.runAs(userObj){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.gmkRateCardDetail(rateCardDetailObjList);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }

    }

    /**
    * @description - Test gmkRateCardDetail Exception
    * @author Sk Minsar | 01-24-2025 
    **/
    @isTest
    public static void testNoGmkRateCardDetailEx() {
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Account dealerAccountObj = getAccountByRecordType('DEALER');
        dealerAccountObj.Coop_Type__c = 'Growmark';  
        Database.update(dealerAccountObj, true);

        System.runAs(userObj){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.gmkRateCardDetail(null);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.TRUE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }

    }

    /**
    * @description - Test updateRateCardNoteRate success
    * @author Sk Minsar | 01-24-2025 
    **/
    @isTest
    public static void testUpdateRateCardNoteRateGmk() {
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__rate_card_setup_header__c> rateCardList = getRateCardHeaderList();
        List<genesis__Rate_Card_Setup_Detail__c> rateCardDetailObjList = getRateCardSetupDetails(rateCardList[0].Id);
        Map<String, Object>paramMap = new Map<String, Object>{
            'cropYear' => 2024,
            'coopType' => 'Growmark'
        };

        System.runAs(userObj){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.updateRateCardNoteRate(rateCardDetailObjList,rateCardDetailObjList,paramMap);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test updateRateCardNoteRate
    * @author Sk Minsar | 01-24-2025 
    **/
    @isTest
    public static void testUpdateRateCardNoteRateCFA() {
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        List<genesis__rate_card_setup_header__c> rateCardList = getRateCardHeaderList();
        List<genesis__Rate_Card_Setup_Detail__c> rateCardDetailObjList = getRateCardSetupDetails(rateCardList[0].Id);
        Map<String, Object>paramMap = new Map<String, Object>{
            'cropYear' => 2023,
            'coopType' => 'CFA'
        };

        System.runAs(userObj){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.updateRateCardNoteRate(rateCardDetailObjList,rateCardDetailObjList,paramMap);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test updateRateCardNoteRate
    * @author Sk Minsar | 01-24-2025 
    **/
    @isTest
    public static void testUpdateRateCardNoteRateLandus() {
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User objUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');
        List<genesis__rate_card_setup_header__c> rateCardList = getRateCardHeaderList();
        List<genesis__Rate_Card_Setup_Detail__c> rateCardDetailObjList = getRateCardSetupDetails(rateCardList[0].Id);
        Map<String, Object>paramMap = new Map<String, Object>{
            'cropYear' => 2024,
            'coopType' => 'Landus'
        };

        System.runAs(objUser){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.updateRateCardNoteRate(rateCardDetailObjList,rateCardDetailObjList,paramMap);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test addDBAAdress
    * @author Sk Minsar | 01-24-2025 
    **/
    @isTest
    public static void testDBAAdress() {
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String,Object> coApplicantsMap = new Map<String,Object>{
            'Id' => '123456789012345678',
            'clcommon__Contact__r.MailingStreet' => 'Salt Lake',
            'clcommon__Contact__r.MailingCity' => 'Kolkata',
            'clcommon__Contact__r.MailingPostalCode' => '10038',
            'clcommon__Contact__r.MailingState' => 'WB',
            'clcommon__Contact__r.Mailing_County__c' => 'India'
        };
        List<Map<String, Object>> coApplicants = new List<Map<String, Object>>();
        coApplicants.add(coApplicantsMap);
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');
        Account dealerAccountObj = getAccountByRecordType('DEALER');
        List<clcommon__Party__c> borrowerParty = getPartyList(objApplication.genesis__Account__c);

        System.runAs(userObj){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.addDBAAdress(coApplicants,dealerAccountObj, borrowerParty[0]);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }

    }

     /**
    * @description - Test addDBAAdress id null
    * @author Sk Minsar | 01-24-2025 
    **/
    @isTest
    public static void testDBAAdressNullId() {
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String,Object> coApplicantsMap = new Map<String,Object>{
            'Id' => null,
            'clcommon__Contact__r.MailingStreet' => 'Salt Lake',
            'clcommon__Contact__r.MailingCity' => 'Kolkata',
            'clcommon__Contact__r.MailingPostalCode' => '10038',
            'clcommon__Contact__r.MailingState' => 'WB',
            'clcommon__Contact__r.Mailing_County__c' => 'India'
        };
        List<Map<String, Object>> coApplicants = new List<Map<String, Object>>();
        coApplicants.add(coApplicantsMap);
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');
        Account dealerAccountObj = getAccountByRecordType('DEALER');
        List<clcommon__Party__c> borrowerParty = getPartyList(objApplication.genesis__Account__c);

        System.runAs(userObj){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.addDBAAdress(coApplicants,dealerAccountObj, borrowerParty[0]);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }

    }

    /**
    * @description - Test getLoggedInUser
    * @author Sk Minsar | 01-24-2025 
    **/
    @isTest
    static void testGetLoggedInUser(){
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        System.runAs(userObj){
            Test.startTest();
                List<User> resultUserList = PortalApplicationOriginationHelper.getLoggedInUser();
                System.assertEquals(userObj.id, resultUserList[0].id,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    
    }

    /**
    * @description - Test isLoanAmountAdjustment
    * @author Sk Minsar | 01-24-2025 
    **/
    @isTest
    public static void testIsLoanAmountAdjustment(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User objUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');
        Map<String, Object> response =new Map<String, Object>();
        List<genesis__Credit_Rating_Matrix__c> creditRatingMatrixList = [SELECT Id, Name 
                                                                            FROM genesis__Credit_Rating_Matrix__c 
                                                                            WHERE Name = 'Tier 4'];
        Map<String, Object> dataMap = getDataMap();
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');
        objApplication.genesis__Credit_Rating__c = creditRatingMatrixList[0].id;
        objApplication.Credit_Application_And_Agreement_Process__c = 'Proceed with the requirements for the tier';
        Database.update(objApplication,true);
        dataMap = getDataMap();
        objApplication = (genesis__Applications__c)dataMap.get('objApplication');

        System.runAs(objUser){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.isLoanAmountAdjustment(objApplication, response);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test persistCollaterals
    * @author Sk Minsar | 01-24-2025 
    **/
    @IsTest 
    public static void testPersistCollaterals(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        User objUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');
        List<clcommon__Collateral__c> objCollateralList = (List<clcommon__Collateral__c>)dataMap.get('objCollateralList');

        System.runAs(objUser){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.persistCollaterals(objCollateralList, objApplication.Id);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test persistCollaterals empty collateral
    * @author Sk Minsar | 01-24-2025 
    **/
    @IsTest 
    public static void testPersistCollateralsEmptyCollateral(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        User objUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');

        System.runAs(objUser){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.persistCollaterals(new List<clcommon__Collateral__c>{}, objApplication.Id);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test persistCollaterals
    * @author Sk Minsar | 01-24-2025 
    **/
    @IsTest 
    public static void testPersistCollateralsForInsurancePlanARH(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        User objUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');
        List<clcommon__Collateral__c> objCollateralList = (List<clcommon__Collateral__c>)dataMap.get('objCollateralList');
        for(clcommon__Collateral__c objCollateral: objCollateralList){
            objCollateral.Insurance_Plan__c = 'ARH';
        }
        List<genesis__Application_Collateral__c> applicationCollaterals = [SELECT Id, 
                                                                                    genesis__Collateral__c, 
                                                                                    genesis__Application__c 
                                                                                FROM genesis__Application_Collateral__c
                                                                                WHERE genesis__Application__c = :objApplication.Id];
        Database.delete(applicationCollaterals, true);

        System.runAs(objUser){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.persistCollaterals(objCollateralList, objApplication.Id);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    
    /**
    * @description - Test isCollateralBlank
    * @author Sk Minsar | 01-24-2025 
    **/
    @IsTest
    public static void testIsCollateralBlank(){
        Map<String, Object> dataMap = getDataMap();
        User objUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');
        List<clcommon__Collateral__c> objCollateralList = (List<clcommon__Collateral__c>)dataMap.get('objCollateralList');
        objCollateralList[0].Total_Acres__c = null;
        objCollateralList[0].Producer_Share_Percent__c = null;
        objCollateralList[0].Approved_Yield__c = null;
        objCollateralList[0].Percent_Fed__c = null;
        objCollateralList[0].clcommon__Collateral_Category__c = null;
        objCollateralList[0].Insurance_Plan__c = null;
        objCollateralList[0].Percent_Coverage_Level__c = null;

        System.runAs(objUser){
            Test.startTest();
                Boolean res = PortalApplicationOriginationHelper.isCollateralBlank(objCollateralList[0], objApplication);
                System.assertEquals(PortalConstants.TRUE_VALUE, res,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    
    /**
    * @description - Test isCollateralBlank
    * @author Sk Minsar | 01-24-2025 
    **/
    @IsTest
    public static void testIsCollateralBlankFeedCollaterals(){
        Map<String, Object> dataMap = getDataMap();
        User objUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');
        objApplication.Does_Applicant_Feed_Above_Collaterals__c = PortalConstants.TRUE_VALUE;
        Database.update(objApplication,true);
        List<clcommon__Collateral__c> objCollateralList = (List<clcommon__Collateral__c>)dataMap.get('objCollateralList');

        System.runAs(objUser){
            Test.startTest();
                Boolean res = PortalApplicationOriginationHelper.isCollateralBlank(objCollateralList[0], objApplication);
                System.assertEquals(PortalConstants.FALSE_VALUE, res, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test isCollateralBlank
    * @author Sk Minsar | 01-24-2025 
    **/
    @IsTest
    public static void testIsCollateralBlankFeedCollateralsNullCoverage(){
        Map<String, Object> dataMap = getDataMap();
        User objUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');
        objApplication.Does_Applicant_Feed_Above_Collaterals__c = PortalConstants.TRUE_VALUE;
        Database.update(objApplication,true);
        List<clcommon__Collateral__c> objCollateralList = (List<clcommon__Collateral__c>)dataMap.get('objCollateralList');
        objCollateralList[0].Percent_Coverage_Level__c = null;
        objCollateralList[0].Total_Acres__c = null;
        objCollateralList[0].Producer_Share_Percent__c = null;
        objCollateralList[0].Approved_Yield__c = null;
        objCollateralList[0].Percent_Fed__c = null;
        objCollateralList[0].clcommon__Collateral_Category__c = null;
        objCollateralList[0].Insurance_Plan__c = null;

        System.runAs(objUser){
            Test.startTest();
                Boolean res = PortalApplicationOriginationHelper.isCollateralBlank(objCollateralList[0], objApplication);
                System.assertEquals(PortalConstants.TRUE_VALUE, res, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    
    /**
    * @description - Test totalCollateralPrice for Percent_Coverage_Level__c null
    * @author Sk Minsar | 01-24-2025 
    **/
    @IsTest 
    public static void testTotalCollateralPrice(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        User objUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');
        List<clcommon__Collateral__c> objCollateralList = (List<clcommon__Collateral__c>)dataMap.get('objCollateralList');
        objCollateralList[0].Percent_Coverage_Level__c = null;

        System.runAs(objUser){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.totalCollateralPrice(objApplication.Id);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test totalCollateralPrice
    * @author Sk Minsar | 01-24-2025 
    **/
    @IsTest 
    public static void testTotalCollateralPriceSuccss(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        User objUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');

        System.runAs(objUser){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.totalCollateralPrice(objApplication.Id);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test isLoanAmountZero
    * @author Sk Minsar | 01-24-2025 
    **/
    @IsTest 
    public static void testIsLoanAmountZero(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User objUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');

        System.runAs(objUser){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.isLoanAmountZero(10, new Map<String, Object>());
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

     /**
    * @description - Test isLoanAmountZero for 0 sum total collateral price
    * @author Sk Minsar | 01-24-2025 
    **/
    @IsTest 
    public static void testIsLoanAmountZeroExactZero(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User objUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');

        System.runAs(objUser){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.isLoanAmountZero(0, new Map<String, Object>());
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateUser 
    * @author Sk Minsar | 01-24-2025 
    **/
    @IsTest 
    public static void testValidateUser(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        User objUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');

        System.runAs(objUser){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.validateUser(objApplication.Id);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateUser exception
    * @author Sk Minsar | 01-24-2025 
    **/
    @IsTest 
    public static void testValidateUserException(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User objUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');

        System.runAs(objUser){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.validateUser(null);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.TRUE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateRequestParam
    * @author Sk Minsar | 01-24-2025 
    **/
    @IsTest 
    public static void testValidateRequestParam(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User objUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');
        Map<String, Object> request = new Map<String, Object>{
            'cropDetails' => 'Corn',
            'landownersDetails' => 'Ayan',
            'spouseDetails' => 'Sunita',
            'applicationId' => '1278970',
            'feedCollateral' => PortalConstants.TRUE_VALUE
        };

        System.runAs(objUser){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.validateRequestParam(request);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateRequestParam exception scenario
    * @author Sk Minsar | 01-24-2025 
    **/
    @IsTest 
    public static void testValidateRequestParamEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User objUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');
        Map<String, Object> request = new Map<String, Object>{
            'landownersDetails' => 'Ayan',
            'spouseDetails' => 'Sunita',
            'applicationId' => '1278970',
            'feedCollateral' => PortalConstants.TRUE_VALUE
        };

        System.runAs(objUser){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.validateRequestParam(request);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.TRUE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateRequestParam Succss
    * @author Sk Minsar | 01-24-2025 
    **/
    @IsTest 
    public static void testValidateRequestParamSuccess(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User objUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');
        Map<String, Object> request = new Map<String, Object>{
            'cropDetails' => 'Corn',
            'landownersDetails' => 'Ayan',
            'spouseDetails' => 'Sunita',
            'applicationId' => '1278970',
            'feedCollateral' => PortalConstants.TRUE_VALUE
        };

        System.runAs(objUser){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.validateRequestParam(request);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateInsuranceAgentDetails
    * @author Sk Minsar | 01-24-2025 
    **/
    @IsTest 
    public static void testValidateInsuranceAgentDetails(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User objUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');
        Map<String, Object> request = new Map<String, Object>{
            'clcommon__Account__r.Name' => 'Ayan',
            'clcommon__Account__r.BillingStreet' => 'Philips more',
            'clcommon__Account__r.BillingCity' => 'Kolkata',
            'clcommon__Account__r.BillingState' => 'Wb',
            'clcommon__Account__r.BillingPostalCode' => '10038'
        };

        System.runAs(objUser){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.validateInsuranceAgentDetails(request);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateInsuranceAgentDetails Exception
    * @author Sk Minsar | 01-24-2025 
    **/
    @IsTest 
    public static void testValidateInsuranceAgentDetailsEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User objUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');
        Map<String, Object> request = new Map<String, Object>{
            'clcommon__Account__r.Name' => 'Ayan',
            'clcommon__Account__r.BillingStreet' => 'Philips more',
            'clcommon__Account__r.BillingCity' => 'Kolkata',
            'clcommon__Account__r.BillingState' => 'Wb',
            'clcommon__Account__r.BillingPostalCode' => null
        };

        System.runAs(objUser){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.validateInsuranceAgentDetails(request);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.TRUE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateBuyersDetails Success
    * @author Soumik Pattanayak | 15-01-2025 
    **/
    @IsTest 
    public static void testValidateBuyersDetails(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User objUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');
        Map<String, Object> request = new Map<String, Object>{
            'clcommon__Account__r.Name' => 'Ayan',
            'clcommon__Account__r.BillingStreet' => 'Philips more',
            'clcommon__Account__r.BillingCity' => 'Kolkata',
            'clcommon__Account__r.BillingState' => 'Wb',
            'clcommon__Account__r.BillingPostalCode' => '10038'
        };

        System.runAs(objUser){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.validateBuyersDetails(request);
                }Catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateBuyersDetails Exception
    * @author Soumik Pattanayak | 15-01-2025 
    **/
    @IsTest 
    public static void testValidateBuyersDetailsEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User objUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');
        Map<String, Object> request = new Map<String, Object>{
            'clcommon__Account__r.Name' => 'Ayan',
            'clcommon__Account__r.BillingStreet' => 'Philips more',
            'clcommon__Account__r.BillingCity' => 'Kolkata',
            'clcommon__Account__r.BillingState' => 'Wb',
            'clcommon__Account__r.BillingPostalCode' => null
        };

        System.runAs(objUser){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.validateBuyersDetails(request);
                }Catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.TRUE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test processSpouseDetails
    * @author Sk Minsar | 01-24-2025 
    **/
    @isTest 
    public static void testProcessSpouseDetails(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        User objUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');
        Map<String, RecordType> partyRecordTypeMap = new Map<String, RecordType>();
        Map<String, clcommon__Party_Type__c> partyTypeMap = new Map<String, clcommon__Party_Type__c>();
        Map<String, Object> containsPartyRecordMap = new Map<String, Object>();
        List<RecordType> recordTypeList = getPartyRecordTypeList(PortalConstants.SPOUSE_PARTY_NAME);
        partyRecordTypeMap.put(PortalConstants.SPOUSE_PARTY_NAME, recordTypeList[0]);
        List<clcommon__Party_Type__c> partyTypeObjList = getPartyTypeList(PortalConstants.SPOUSE_PARTY_NAME);
        partyTypeMap.put(PortalConstants.SPOUSE_PARTY_NAME, partyTypeObjList[0]);
        containsPartyRecordMap.put('applicationId', objApplication.Id);
        containsPartyRecordMap.put('recordTypeMap', partyRecordTypeMap);
        containsPartyRecordMap.put('partyTypeMap', partyTypeMap);
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put('clcommon__Contact__r.LastName','deb');
        requestMap.put('clcommon__Contact__r.FirstName','Tamojit');
        List<Object> spouseDetailsList = new List<Object>();
        spouseDetailsList.add(requestMap);

        System.runAs(objUser){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.processSpouseDetails(spouseDetailsList, containsPartyRecordMap, objApplication);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test processSpouseDetails exception
    * @author Sk Minsar | 01-24-2025 
    **/
    @isTest 
    public static void testProcessSpouseDetailsEmptyNameEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        User objUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');
        Map<String, RecordType> partyRecordTypeMap = new Map<String, RecordType>();
        Map<String, clcommon__Party_Type__c> partyTypeMap = new Map<String, clcommon__Party_Type__c>();
        Map<String, Object> containsPartyRecordMap = new Map<String, Object>();
        List<RecordType> recordTypeList = getPartyRecordTypeList(PortalConstants.SPOUSE_PARTY_NAME);
        partyRecordTypeMap.put(PortalConstants.SPOUSE_PARTY_NAME, recordTypeList[0]);
        List<clcommon__Party_Type__c> partyTypeObjList = getPartyTypeList(PortalConstants.SPOUSE_PARTY_NAME);
        partyTypeMap.put(PortalConstants.SPOUSE_PARTY_NAME, partyTypeObjList[0]);
        containsPartyRecordMap.put('applicationId', objApplication.Id);
        containsPartyRecordMap.put('recordTypeMap', partyRecordTypeMap);
        containsPartyRecordMap.put('partyTypeMap', partyTypeMap);
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put('clcommon__Contact__r.LastName','deb');
        requestMap.put('clcommon__Contact__r.FirstName',null);
        List<Object> spouseDetailsList = new List<Object>();
        spouseDetailsList.add(requestMap);

        System.runAs(objUser){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.processSpouseDetails(spouseDetailsList, containsPartyRecordMap, objApplication);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.TRUE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test processAdditionalCropDetails
    * @author Sk Minsar | 01-24-2025 
    **/
    @isTest 
    public static void testProcessAdditionalCropDetails(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');
        Map<String, RecordType> partyRecordTypeMap = new Map<String, RecordType>();
        Map<String, clcommon__Party_Type__c> partyTypeMap = new Map<String, clcommon__Party_Type__c>();
        Map<String, Object> containsPartyRecordMap = new Map<String, Object>();
        List<RecordType> recordTypeList = getPartyRecordTypeList(PortalConstants.LANDOWNER_PARTY_NAME);
        partyRecordTypeMap.put(PortalConstants.LANDOWNER_PARTY_NAME, recordTypeList[0]);
        List<clcommon__Party_Type__c> partyTypeObjList = getPartyTypeList(PortalConstants.LANDOWNER_PARTY_NAME);
        partyTypeMap.put(PortalConstants.LANDOWNER_PARTY_NAME, partyTypeObjList[0]);
        containsPartyRecordMap.put('applicationId', objApplication.Id);
        containsPartyRecordMap.put('recordTypeMap', partyRecordTypeMap);
        containsPartyRecordMap.put('partyTypeMap', partyTypeMap);
        containsPartyRecordMap.put('shouldValidate', PortalConstants.TRUE_VALUE);
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put('clcommon__Account__r.Name','deb');
        requestMap.put('clcommon__Account__r.Billing_County__c','Tamojit');
        List<Object> additionalCropList = new List<Object>();
        additionalCropList.add(requestMap);
        
        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.processAdditionalCropDetails(additionalCropList, containsPartyRecordMap, objApplication);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test processAdditionalCropDetails exception
    * @author Sk Minsar | 01-24-2025 
    **/
    @isTest 
    public static void testProcessAdditionalCropDetailsNameNull(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');
        Map<String, RecordType> partyRecordTypeMap = new Map<String, RecordType>();
        Map<String, clcommon__Party_Type__c> partyTypeMap = new Map<String, clcommon__Party_Type__c>();
        Map<String, Object> containsPartyRecordMap = new Map<String, Object>();
        List<RecordType> recordTypeList = getPartyRecordTypeList(PortalConstants.LANDOWNER_PARTY_NAME);
        partyRecordTypeMap.put(PortalConstants.LANDOWNER_PARTY_NAME, recordTypeList[0]);
        List<clcommon__Party_Type__c> partyTypeObjList = getPartyTypeList(PortalConstants.LANDOWNER_PARTY_NAME);
        partyTypeMap.put(PortalConstants.LANDOWNER_PARTY_NAME, partyTypeObjList[0]);
        containsPartyRecordMap.put('applicationId', objApplication.Id);
        containsPartyRecordMap.put('recordTypeMap', partyRecordTypeMap);
        containsPartyRecordMap.put('partyTypeMap', partyTypeMap);
        containsPartyRecordMap.put('shouldValidate', PortalConstants.TRUE_VALUE);
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put('clcommon__Account__r.Name', null);
        requestMap.put('clcommon__Account__r.Billing_County__c','Tamojit');
        List<Object> additionalCropList = new List<Object>();
        additionalCropList.add(requestMap);
        getDataMap();
        objApplication = (genesis__Applications__c)dataMap.get('objApplication');

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.processAdditionalCropDetails(additionalCropList, containsPartyRecordMap, objApplication);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.TRUE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    
    /**
    * @description - Test processPotentialBuyers
    * @author Sk Minsar | 01-24-2025 
    **/
    @isTest 
    public static void testProcessPotentialBuyers(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        User objUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');
        Map<String, RecordType> partyRecordTypeMap = new Map<String, RecordType>();
        Map<String, clcommon__Party_Type__c> partyTypeMap = new Map<String, clcommon__Party_Type__c>();
        Map<String, Object> containsPartyRecordMap = new Map<String, Object>();
        List<RecordType> recordTypeList = getPartyRecordTypeList(PortalConstants.BUYER_PARTY_NAME);
        partyRecordTypeMap.put(PortalConstants.BUYER_PARTY_NAME, recordTypeList[0]);
        List<clcommon__Party_Type__c> partyTypeObjList = getPartyTypeList(PortalConstants.BUYER_PARTY_NAME);
        partyTypeMap.put(PortalConstants.BUYER_PARTY_NAME, partyTypeObjList[0]);
        containsPartyRecordMap.put('applicationId', objApplication.Id);
        containsPartyRecordMap.put('recordTypeMap', partyRecordTypeMap);
        containsPartyRecordMap.put('partyTypeMap', partyTypeMap);
        containsPartyRecordMap.put('shouldValidate', PortalConstants.TRUE_VALUE);
        Map<String, Object> requestMap = new Map<String, Object>{
            'clcommon__Account__r.Name' => 'Ayan',
            'clcommon__Account__r.BillingStreet' => 'Philips more',
            'clcommon__Account__r.BillingCity' => 'Kolkata',
            'clcommon__Account__r.BillingState' => 'Wb',
            'clcommon__Account__r.BillingPostalCode' => '10038'
        };
        List<Object> buyersDetailsMap = new List<Object>();
        buyersDetailsMap.add(requestMap);

        System.runAs(objUser){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.processPotentialBuyers(buyersDetailsMap, containsPartyRecordMap, objApplication);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test processPotentialBuyers exception
    * @author Sk Minsar | 01-24-2025 
    **/
    @isTest 
    public static void testProcessPotentialBuyersNameNull(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        User objUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');
        Map<String, RecordType> partyRecordTypeMap = new Map<String, RecordType>();
        Map<String, clcommon__Party_Type__c> partyTypeMap = new Map<String, clcommon__Party_Type__c>();
        Map<String, Object> containsPartyRecordMap = new Map<String, Object>();
        List<RecordType> recordTypeList = getPartyRecordTypeList(PortalConstants.BUYER_PARTY_NAME);
        partyRecordTypeMap.put(PortalConstants.BUYER_PARTY_NAME, recordTypeList[0]);
        List<clcommon__Party_Type__c> partyTypeObjList = getPartyTypeList(PortalConstants.BUYER_PARTY_NAME);
        partyTypeMap.put(PortalConstants.BUYER_PARTY_NAME, partyTypeObjList[0]);
        containsPartyRecordMap.put('applicationId', objApplication.Id);
        containsPartyRecordMap.put('recordTypeMap', partyRecordTypeMap);
        containsPartyRecordMap.put('partyTypeMap', partyTypeMap);
        containsPartyRecordMap.put('shouldValidate', PortalConstants.TRUE_VALUE);
        Map<String, Object> requestMap = new Map<String, Object>{
            'clcommon__Account__r.Name' => null,
            'clcommon__Account__r.BillingStreet' => 'Philips more',
            'clcommon__Account__r.BillingCity' => 'Kolkata',
            'clcommon__Account__r.BillingState' => 'Wb',
            'clcommon__Account__r.BillingPostalCode' => '10038'
        };
        List<Object> buyersDetailsMap = new List<Object>();
        buyersDetailsMap.add(requestMap);

        System.runAs(objUser){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.processPotentialBuyers(buyersDetailsMap, containsPartyRecordMap, objApplication);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.TRUE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test processCropInsuranceDetails 
    * @author Sk Minsar | 01-24-2025 
    **/
    @isTest 
    public static void testProcessCropInsuranceDetails(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        User objUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');
        Map<String, RecordType> partyRecordTypeMap = new Map<String, RecordType>();
        Map<String, clcommon__Party_Type__c> partyTypeMap = new Map<String, clcommon__Party_Type__c>();
        Map<String, Object> containsPartyRecordMap = new Map<String, Object>();
        List<RecordType> recordTypeList = getPartyRecordTypeList(PortalConstants.INSURANCE_AGENT_PARTY_NAME);
        partyRecordTypeMap.put(PortalConstants.INSURANCE_AGENT_PARTY_NAME, recordTypeList[0]);
        List<clcommon__Party_Type__c> partyTypeObjList = getPartyTypeList(PortalConstants.INSURANCE_AGENT_PARTY_NAME);
        partyTypeMap.put(PortalConstants.INSURANCE_AGENT_PARTY_NAME, partyTypeObjList[0]);
        containsPartyRecordMap.put('applicationId', objApplication.Id);
        containsPartyRecordMap.put('recordTypeMap', partyRecordTypeMap);
        containsPartyRecordMap.put('partyTypeMap', partyTypeMap);
        containsPartyRecordMap.put('shouldValidate', PortalConstants.TRUE_VALUE);
        Map<String, Object> requestMap = new Map<String, Object>{
            'clcommon__Account__r.Name' => 'Ayan',
            'clcommon__Account__r.BillingStreet' => 'Philips more',
            'clcommon__Account__r.BillingCity' => 'Kolkata',
            'clcommon__Account__r.BillingState' => 'Wb',
            'clcommon__Account__r.BillingPostalCode' => '10038'
        };
        List<Object> insuranceDetailsList = new List<Object>();
        insuranceDetailsList.add(requestMap);

        System.runAs(objUser){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.processCropInsuranceDetails(insuranceDetailsList, containsPartyRecordMap, objApplication);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test processCropInsuranceDetails exception
    * @author Sk Minsar | 01-24-2025 
    **/
    @isTest 
    public static void testProcessCropInsuranceDetailsNameNull(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        User objUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');
        Map<String, RecordType> partyRecordTypeMap = new Map<String, RecordType>();
        Map<String, clcommon__Party_Type__c> partyTypeMap = new Map<String, clcommon__Party_Type__c>();
        Map<String, Object> containsPartyRecordMap = new Map<String, Object>();
        List<RecordType> recordTypeList = getPartyRecordTypeList(PortalConstants.INSURANCE_AGENT_PARTY_NAME);
        partyRecordTypeMap.put(PortalConstants.INSURANCE_AGENT_PARTY_NAME, recordTypeList[0]);
        List<clcommon__Party_Type__c> partyTypeObjList = getPartyTypeList(PortalConstants.INSURANCE_AGENT_PARTY_NAME);
        partyTypeMap.put(PortalConstants.INSURANCE_AGENT_PARTY_NAME, partyTypeObjList[0]);
        containsPartyRecordMap.put('applicationId', objApplication.Id);
        containsPartyRecordMap.put('recordTypeMap', partyRecordTypeMap);
        containsPartyRecordMap.put('partyTypeMap', partyTypeMap);
        containsPartyRecordMap.put('shouldValidate', PortalConstants.TRUE_VALUE);
        Map<String, Object> requestMap = new Map<String, Object>{
            'clcommon__Account__r.Name' => null,
            'clcommon__Account__r.BillingStreet' => 'Philips more',
            'clcommon__Account__r.BillingCity' => 'Kolkata',
            'clcommon__Account__r.BillingState' => 'Wb',
            'clcommon__Account__r.BillingPostalCode' => '10038'
        };
        List<Object> insuranceDetailsList = new List<Object>();
        insuranceDetailsList.add(requestMap);

        System.runAs(objUser){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.processCropInsuranceDetails(insuranceDetailsList, containsPartyRecordMap, objApplication);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.TRUE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateAdditionalInfoDetails
    * @author Soumik Pattanayak | 15-01-2025 
    **/
    @isTest 
    public static void testValidateAdditionalInfoDetails(){
        Map<String, Object> dataMap = getDataMap();
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User objUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');
        Map<String,String> additionalInfoMap = new Map<String,String>();
        additionalInfoMap.put('shouldValidate', String.valueOf(PortalConstants.TRUE_VALUE));
        additionalInfoMap.put('applicationId', objApplication.Id);
        additionalInfoMap.put('potentialBuyerdetails', '[{\"clcommon__Account__r.Name\":\"Rimpa Deb\",\"clcommon__Account__r.BillingStreet\":\"asad\",\"clcommon__Account__r.BillingState\":\"swds\",\"clcommon__Account__r.clcommon__Email__c\":\"rimpa1232123@mailinator.com\",\"clcommon__Account__r.BillingCity\":\"sdwded\",\"clcommon__Account__r.Phone\":\"9876543210\",\"clcommon__Account__r.BillingPostalCode\":\"12312\"}]');
        additionalInfoMap.put('cropInsuranceDetails', '[{\"clcommon__Account__r.Name\":\"Ayush Agarwal\",\"clcommon__Account__r.BillingStreet\":\"asas\",\"clcommon__Account__r.BillingState\":\"as\",\"clcommon__Account__r.clcommon__Email__c\":\"ayush18775562@mailinator.com\",\"clcommon__Account__r.BillingCity\":\"asas\",\"clcommon__Account__r.Phone\":\"9876123409\",\"clcommon__Account__r.BillingPostalCode\":\"23231\"}]');
        additionalInfoMap.put('additionalCropDetails', '[{\"clcommon__Account__r.Name\":\"Pinaki deb\",\"clcommon__Account__r.BillingState\":\"us\",\"clcommon__Account__r.Billing_County__c\":\"hjtghj\"}]');
        additionalInfoMap.put('spouseDetails', '[{\"clcommon__Contact__r.LastName\":\"deb\",\"clcommon__Contact__r.FirstName\":\"Tamojit\",\"clcommon__Contact__r.Email\":\"a@mailinator.com\",\"clcommon__Contact__r.genesis__SSN__c\":\"111212\"}]');

        System.runAs(objUser){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.validateAdditionalInfoDetails(additionalInfoMap);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test saveEmailLog
    * @author Soumik Pattanayak | 15-01-2025 
    **/
    @isTest
    public static void testSaveEmailLog(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        Map<String, String> paramMap = new Map<String,String>();
        paramMap.put('eamilTemplate','Email For Existing Members');
        paramMap.put('senderEmail','ravisingh993100@yopmail.com');
        paramMap.put('receiverEmail','ravi.ranjan@yopmail.com');

        System.runAs(userObj){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.saveEmailLog(paramMap);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

     /**
     * @description - Test getOrgWideEmailAddress
     * @author Sk Minsar | 01-24-2025 
     **/
    @isTest
     public static void testGetOrgWideEmailAddress(){
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        OrgWideEmailAddress orgEmailAddress = [SELECT ID, Address, DisplayName, Purpose FROM OrgWideEmailAddress WHERE DisplayName = 'FIELD FINANCE'];

        System.runAs(userObj){
                Test.startTest();
                List<OrgWideEmailAddress> objEmailList = PortalApplicationOriginationHelper.getOrgWideEmailAddress(orgEmailAddress.DisplayName);
                System.assertEquals(PortalConstants.TRUE_VALUE, objEmailList!=null, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    
     /**
     * @description - Test getGrowerDetails
     * @author Soumik Pattanayak | 15-01-2025 
     **/
     @isTest
     public static void testGetGrowerDetailsCorporation(){
        Map<String, Object> dataMap = getDataMap();
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');
        genesis__Applications__c appObj = (genesis__Applications__c)dataMap.get('objApplication');

        System.runAs(userObj){
            Test.startTest();
                Map<String,String> contactObjMap = PortalApplicationOriginationHelper.getGrowerDetails(appObj);
                System.assertEquals(appObj.genesis__Account__r.Name, contactObjMap.get('growerName'), PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
     }

     /**
     * @description - Test getGrowerDetails
     * @author Soumik Pattanayak | 15-01-2025 
     **/
     @isTest
     public static void testGetGrowerDetailsSoleProp(){
        Map<String, Object> dataMap = getDataMap();
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');
        clcommon__Legal_Entity__c legalEntityObj = (clcommon__Legal_Entity__c)dataMap.get('solePropLegalEntity');
        Account accObj = (Account) dataMap.get('objAccount');
        accObj.clcommon__Legal_Entity_Type__c = legalEntityObj.Id;
        Database.update(accObj,true);
        genesis__Applications__c appObj = (genesis__Applications__c)dataMap.get('objApplication');
        appObj.genesis__Account__c = accObj.Id;

        System.runAs(userObj){
            Test.startTest();
                Map<String,String> contactObjMap = PortalApplicationOriginationHelper.getGrowerDetails(appObj);
                System.assertEquals(appObj.genesis__Account__r.Name, contactObjMap.get('growerName'),PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
     }

     /**
     * @description - Test getGrowerDetails
     * @author Soumik Pattanayak | 15-01-2025 
     **/
    @isTest
    public static void testGetGrowerDetailsIndividual(){
       Map<String, Object> dataMap = getDataMap();
       clcommon__Legal_Entity__c legalEntityObj = (clcommon__Legal_Entity__c)dataMap.get('solePropLegalEntity');
       legalEntityObj.Name = 'Individual';
       Database.update(legalEntityObj, true);
       Account accObj = (Account) dataMap.get('objAccount');
       accObj.clcommon__Legal_Entity_Type__c = legalEntityObj.Id;
       Database.update(accObj,true);
       Contact borrowerContact = (Contact)dataMap.get('contactList');
       borrowerContact.MailingCity = 'Kolkata';
       borrowerContact.MailingState = 'WB';
       Database.update(borrowerContact, true);
       dataMap = getDataMap();
       genesis__Applications__c appObj = (genesis__Applications__c)dataMap.get('objApplication');
       appObj.genesis__Account__c = accObj.Id;

       System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
           Test.startTest();
               Map<String,String> contactObjMap = PortalApplicationOriginationHelper.getGrowerDetails(appObj);
               System.assertEquals(appObj.genesis__Account__r.Name, contactObjMap.get('growerName'), PortalConstants.ASSERTION_FAILED);
           Test.stopTest();
       }
    }

    /**
     * @description - Test getGrowerDetails for corporation with city & state null
     * @author Soumik Pattanayak | 15-01-2025 
     **/
    @isTest
    public static void testGetGrowerDetailsNullAddress(){
       Map<String, Object> dataMap = getDataMap();
       User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');
       clcommon__Legal_Entity__c legalEntityObj = (clcommon__Legal_Entity__c)dataMap.get('solePropLegalEntity');
       legalEntityObj.Name = 'Corporation';
       Database.update(legalEntityObj, true);
       Account accObj = (Account) dataMap.get('objAccount');
       accObj.clcommon__Legal_Entity_Type__c = legalEntityObj.Id;
       Database.update(accObj,true);
       Contact borrowerContact = (Contact)dataMap.get('contactList');
       borrowerContact.MailingCity = '';
       borrowerContact.MailingState = '';
       Database.update(borrowerContact, true);
       dataMap = getDataMap();
       genesis__Applications__c appObj = (genesis__Applications__c)dataMap.get('objApplication');
       appObj.genesis__Account__c = accObj.Id;

       System.runAs(userObj){
           Test.startTest();
               Map<String,String> contactObjMap = PortalApplicationOriginationHelper.getGrowerDetails(appObj);
               System.assertEquals(appObj.genesis__Account__r.Name, contactObjMap.get('growerName'),PortalConstants.ASSERTION_FAILED);
           Test.stopTest();
       }
    }

     /**
     * @description - Test updateLoanNumber
     * @author Soumik Pattanayak | 15-01-2025 
     **/
     @isTest
     public static void testUpdateLoanNumber(){
        Map<String, Object> dataMap = getDataMap();
        Map<String, Id> mapOfpartyType = new Map<String, Id>();
        mapOfpartyType = PortalHelper.getPartyTypeMap();
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');
        genesis__Applications__c appObj = (genesis__Applications__c)dataMap.get('objApplication');
        appObj.genesis__Status__c = 'Active';
        Database.upsert(appObj,true);

        System.runAs(userObj){
            Test.startTest();
                String newLoanNumber = PortalApplicationOriginationHelper.updateLoanNumber(appObj, 'newApplicant',mapOfpartyType);
                System.assertEquals(PortalConstants.TRUE_VALUE, newLoanNumber!= null, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
     * @description - Test updateLoanNumber for Existing
     * @author Soumik Pattanayak | 15-01-2025 
     **/
    @isTest
    public static void testUpdateLoanNumberExsisting(){
       Map<String, Object> dataMap = getDataMap();
       Map<String, Id> mapOfpartyType = new Map<String, Id>();
       mapOfpartyType = PortalHelper.getPartyTypeMap();
       User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');
       genesis__Applications__c appObj = (genesis__Applications__c)dataMap.get('objApplication');
       appObj.genesis__Status__c = 'Active';
       appObj.Submitted_to_CFA__c = Date.valueOf(DateTime.now());
       Database.upsert(appObj,true);

       System.runAs(userObj){
           Test.startTest();
               String newLoanNumber = PortalApplicationOriginationHelper.updateLoanNumber(appObj, 'Existing',mapOfpartyType);
               System.assertEquals(PortalConstants.TRUE_VALUE, newLoanNumber!= null, PortalConstants.ASSERTION_FAILED);
           Test.stopTest();
       }
   }

    /**
    * @description - Test disableApplicantFields
    * @author Soumik Pattanayak | 15-01-2025 
    **/
    @isTest
    public static void testDisableApplicantFields(){
        Map<String, Object> dataMap = getDataMap();
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');
        genesis__Applications__c appObj = (genesis__Applications__c)dataMap.get('objApplication');
        appObj.genesis__Status__c = 'Active';
        Database.upsert(appObj,true);
        Account borrowerAccount = (Account) dataMap.get('objAccount');

        System.runAs(userObj){
            Test.startTest();
                genesis__Applications__c updatedApp = PortalApplicationOriginationHelper.disableApplicantFields(appObj,borrowerAccount);
                System.assertEquals(PortalConstants.TRUE_VALUE, updatedApp.Is_First_Application__c!=null, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    
    }
    
    /**
    * @description - Test setAccountName
    * @author Soumik Pattanayak | 15-01-2025 
    **/
    @isTest
    public static void testSetAccountName(){
        Map<String, Object> dataMap = getDataMap();
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');
        Account borrowerAccount = (Account) dataMap.get('objAccount');
        Contact borrowerContact = (Contact)dataMap.get('contactList');
        borrowerContact.ints__Middle_Name__c = 'Collins';
        borrowerContact.firstName = 'Jack';
        borrowerContact.lastName = 'Alberto';
        Database.upsert(borrowerContact,true);

        System.runAs(userObj){
            Test.startTest();
                Account updatedName = PortalApplicationOriginationHelper.setAccountName(borrowerAccount,borrowerContact);
                System.assertEquals(PortalConstants.TRUE_VALUE, updatedName!=null, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test setAccountName
    * @author Soumik Pattanayak | 15-01-2025 
    **/
    @isTest
    public static void testSetAccountNameEmptyMiddleName(){
        Map<String, Object> dataMap = getDataMap();
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');
        Account borrowerAccount = (Account) dataMap.get('objAccount');
        Contact borrowerContact = (Contact)dataMap.get('contactList');
        borrowerContact.ints__Middle_Name__c = '';
        borrowerContact.firstName = 'Jack';
        borrowerContact.lastName = 'Alberto';
        Database.upsert(borrowerContact,true);

        System.runAs(userObj){
            Test.startTest();
                Account updatedName = PortalApplicationOriginationHelper.setAccountName(borrowerAccount,borrowerContact);
                System.assertEquals(PortalConstants.TRUE_VALUE, updatedName!=null, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test setAccountName
    * @author Soumik Pattanayak | 15-01-2025 
    **/
    @isTest
    public static void testSetAccountNameEmptyFristName(){
        Map<String, Object> dataMap = getDataMap();
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');
        Account borrowerAccount = (Account) dataMap.get('objAccount');
        Contact borrowerContact = (Contact)dataMap.get('contactList');
        borrowerContact.ints__Middle_Name__c = 'Collins';
        borrowerContact.firstName = '';
        borrowerContact.lastName = 'Alberto';
        Database.upsert(borrowerContact,true);

        System.runAs(userObj){
            Test.startTest();
                Account updatedName = PortalApplicationOriginationHelper.setAccountName(borrowerAccount,borrowerContact);
                System.assertEquals(PortalConstants.TRUE_VALUE, updatedName!=null, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    
    /**
    * @description - Test getLoggedInAccount
    * @author Soumik Pattanayak | 15-01-2025 
    **/
    @isTest
    public static void testgetLoggedInAccount(){
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');
        
        System.runAs(userObj){
            Test.startTest();
                Account objLoggedInAccount = PortalApplicationOriginationHelper.getLoggedInAccount();
                System.assertEquals(PortalConstants.TRUE_VALUE, objLoggedInAccount!=null, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }

    }
    
    /**
    * @description - Test getLegalEntityByAccount
    * @author Soumik Pattanayak | 15-01-2025 
    **/
    @isTest
    public static void testGetLegalEntityByAcc(){
        Map<String, Object> dataMap = getDataMap();
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');
        Account borrowerAccount = (Account) dataMap.get('objAccount');

        System.runAs(userObj){
            Test.startTest();
                String legalEntityName = PortalApplicationOriginationHelper.getLegalEntityByAccount(borrowerAccount);
                System.assertEquals(PortalConstants.TRUE_VALUE, legalEntityName!=null, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }

    }
    
    /**
    * @description - Test getProfileByName
    * @author Soumik Pattanayak | 15-01-2025 
    **/
    @isTest
    public static void testGetProfileByName(){
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');
        List<Profile> profileList = getProfileList('Grower');

        System.runAs(userObj){
            Test.startTest();
                List<Profile> pofileObj = PortalApplicationOriginationHelper.getProfileByName('Grower');
                System.assertEquals(profileList, pofileObj, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test checkGrowerUserExistance
    * @author Soumik Pattanayak | 15-01-2025 
    **/
    @isTest
    public static void testcheckGrowerUserExistance(){
        Map<String, Object> dataMap = getDataMap();
        User userObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Jasmine Albin');
        Contact objContact = (Contact)dataMap.get('contactList');

        System.runAs(userObj){
            Test.startTest();
                List<User> userList = PortalApplicationOriginationHelper.checkGrowerUserExistance(new List<Contact>{objContact});
                System.assertEquals(1, userList.size(), PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test testcheckBlankParameter for null paramters passed
    * @author Rakesh Saraf | 11-11-2024 
    **/
    @isTest
    public static void testCheckBlankParameter(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()) {
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.checkBlankParameter(PortalConstants.EMPTY_STRING, 'Empty parameter list');
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.TRUE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test checkIfNullObject for null paramters passed
    * @author Rakesh Saraf | 11-11-2024 
    **/
    @isTest
    public static void testCheckIfNullObject(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()) {
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.checkIfNullObject(null, 'Empty parameter list');
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.TRUE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
    
    /**
    * @description - Test validateCropDetails success
    * @author Soumik Pattanayak | 16-01-2025 
    **/
    @isTest 
    public static void testValidateCropDetailsSuccess(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.validateCropDetails(PortalConstants.EMPTY_STRING);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.TRUE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();   
        }
    }

    /**
    * @description - Test getPartyTypeMap success
    * @author Soumik Pattanayak | 16-01-2025 
    **/
    @isTest 
    public static void testGetPartyTypeMapSuccess(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.getPartyTypeMap();
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();   
        }
    }

    /**
    * @description - Test checkForBlankParameter Exception
    * @author Soumik Pattanayak | 16-01-2025 
    **/
    @isTest 
    public static void testCheckForBlankParameterEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.checkForBlankParameter(PortalConstants.EMPTY_STRING);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.TRUE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();   
        }
    }

    /**
    * @description - Test throwErrorIfFalse Exception
    * @author Soumik Pattanayak | 16-01-2025 
    **/
    @isTest 
    public static void testThrowErrorIfFalseEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.throwErrorIfFalse(PortalConstants.FALSE_VALUE, PortalConstants.REQUIRED_PARAMETERS_MISSING);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.TRUE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();   
        }
    }

    /**
    * @description - Test throwErrorIfTrue Exception scenario
    * @author Soumik Pattanayak | 16-01-2025 
    **/
    @isTest 
    public static void testThrowErrorIfTrueEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.throwErrorIfTrue(PortalConstants.TRUE_VALUE, PortalConstants.REQUIRED_PARAMETERS_MISSING);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.TRUE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();   
        }
    }

    /**
    * @description - Test generateChildLoans
    * @author Soumik Pattanayak | 16-01-2025 
    **/
    @isTest 
    public static void testGenerateChildLoans(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');
        List<genesis__rate_card_setup_header__c> rateCardList = getRateCardHeaderList();
        List<genesis__Rate_Card_Setup_Detail__c> rateCardDetailList = getRateCardSetupDetails(rateCardList[0].Id);
        for(genesis__Rate_Card_Setup_Detail__c rateCard:rateCardDetailList){
            rateCard.genesis__Enabled_Flag__c = PortalConstants.TRUE_VALUE;
        }
        objApplication.My_program__c = rateCardList[0].Id;
        Database.update(objApplication, true);
        Database.update(rateCardDetailList, true);

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.generateChildLoans(objApplication.Id);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals( PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();   
        }
    }

    /**
    * @description - Test getDealerSpecificGrowerDetails Exception
    * @author Soumik Pattanayak | 16-01-2025 
    **/
    @isTest 
    public static void testGetDealerSpecificGrowerDetails(){
        Map<String,Object> dataMap = getDataMap();
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');
        Account objAccount = (Account) dataMap.get('objAccount');
        clcommon__Legal_Entity__c objSolePropLegalEntity=(clcommon__Legal_Entity__c)dataMap.get('solePropLegalEntity');
        objAccount.clcommon__Legal_Entity_Type__c=objSolePropLegalEntity.id;
        Database.update(objAccount, true);

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.getDealerSpecificGrowerDetails(objApplication);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();   
        }
    }

    /**
    * @description - Test getDealerSpecificGrowerDetails for Corporation
    * @author Soumik Pattanayak | 16-01-2025 
    **/
    @isTest 
    public static void testGetDealerSpecificGrowerDetailsCorp(){
        Map<String,Object> dataMap = getDataMap();
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');
        clcommon__Legal_Entity__c objSolePropLegalEntity=(clcommon__Legal_Entity__c)dataMap.get('solePropLegalEntity');
        objSolePropLegalEntity.Name = 'Corporation';
        Database.update(objSolePropLegalEntity, true);
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');
        
        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.getDealerSpecificGrowerDetails(objApplication);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();   
        }
    }

    /**
    * @description - Test getDealerSpecificGrowerDetails for Individual
    * @author Soumik Pattanayak | 16-01-2025 
    **/
    @isTest 
    public static void testGetDealerSpecificGrowerDetailsInd(){
        Map<String,Object> dataMap = getDataMap();
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        clcommon__Legal_Entity__c objSolePropLegalEntity=(clcommon__Legal_Entity__c)dataMap.get('solePropLegalEntity');
        objSolePropLegalEntity.Name = 'Individual';
        Database.update(objSolePropLegalEntity, true);
        Account objAccount = (Account) dataMap.get('objAccount');
        objAccount.clcommon__Legal_Entity_Type__c=objSolePropLegalEntity.id;
        Database.update(objAccount, true);
        dataMap = getDataMap();
        genesis__Applications__c objApplication = (genesis__Applications__c)dataMap.get('objApplication');
        
        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.getDealerSpecificGrowerDetails(objApplication);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();   
        }
    }

    /**
    * @description - Test updateApplicantDetailsSpecificToDealer Success
    * @author Soumik Pattanayak | 16-01-2025 
    **/
    @isTest 
    public static void testUpdateApplicantDetailsSpecificToDealer(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        Account objAccount = (Account) dataMap.get('objAccount');
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        System.runAs(clUserObj){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.updateApplicantDetailsSpecificToDealer(new Map<String, Object>{
                        PortalConstants.ACCOUNT_OBJ_KEY => objAccount,
                        PortalConstants.APPLICANT_DEALER_RELATION_KEY => new Dealer_Applicant_Relationship__c()
                    });
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();   
        }
    }

    /**
    * @description - Test checkFieldInMap Success
    * @author Soumik Pattanayak | 16-01-2025 
    **/
    @isTest 
    public static void testCheckFieldInMap(){
        User clUserObj = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        System.runAs(clUserObj){
            Test.startTest();
                String result = PortalApplicationOriginationHelper.checkFieldInMap(new Map<String,Object>{
                        PortalConstants.APPLICATION_ID => '123456789012345678'
                    }, PortalConstants.APPLICATION_ID);
                System.assertEquals(PortalConstants.TRUE_VALUE, result != null, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();   
        }
    }

    /**
    * @description - Test deactivateUser for dealer user
    * @author Soumik Pattanayak | 16-01-2025 
    **/
    @isTest 
    public static void testDeactivateDealerUser(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Account dealerAccountObj = getAccountByRecordType('DEALER');

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.deactivateUser(dealerAccountObj.Id);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();   
        }
    }

    /**
    * @description - Test deleteRateCrdFrmDatabase for Growmark
    * @author Soumik Pattanayak | 16-01-2025 
    **/
    @isTest 
    public static void testDealeteRateCardGmk(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        List<genesis__rate_card_setup_header__c> rateCardList = getRateCardHeaderList();
        List<genesis__Rate_Card_Setup_Detail__c> rateCardDetailList = getRateCardSetupDetails(rateCardList[0].Id);

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.deleteRateCrdFrmDatabase(PortalConstants.GROWMARK_COOP_TYPE, rateCardDetailList, rateCardDetailList);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();   
        }
    }

    /**
    * @description - Test checkUserAuthorization Exception
    * @author Soumik Pattanayak | 16-01-2025 
    **/
    @isTest 
    public static void testCheckUserAuthorizationEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.checkUserAuthorization(null, new List<genesis__Rate_Card_Setup_Detail__c>());
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.TRUE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();   
        }
    }

    /**
    * @description - Test updateCollateralPrice for collateral category null
    * @author Soumik Pattanayak | 16-01-2025 
    **/
    @isTest 
    public static void testUpdateCollateralPriceNullCatagory(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        List<clcommon__Collateral__c> objCollateralList = (List<clcommon__Collateral__c>)dataMap.get('objCollateralList');
        objCollateralList[0].clcommon__Collateral_Category__c = null;

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.updateCollateralPrice(objCollateralList[0], new Map<Object, clcommon__Collateral_Category__c>());
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();   
        }
    }

    /**
    * @description - Test isValidProducerShare for producer share null
    * @author Soumik Pattanayak | 16-01-2025 
    **/
    @isTest 
    public static void testValidProducerShareShareNull(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap();
        List<clcommon__Collateral__c> objCollateralList = (List<clcommon__Collateral__c>)dataMap.get('objCollateralList');
        objCollateralList[0].Producer_Share_Percent__c = null;

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.isValidProducerShare(objCollateralList[0]);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();   
        }
    }

    /**
    * @description - Test processSpouseDetails for empty spouse details map
    * @author Sk Minsar | 01-24-2025 
    **/
    @isTest 
    public static void testProcessSpouseDetailsEmptyMap(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> requestMap = new Map<String, Object>();
        List<Object> spouseDetailsList = new List<Object>();
        spouseDetailsList.add(requestMap);

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.processSpouseDetails(spouseDetailsList, new  Map<String, Object>(), new genesis__Applications__c());
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test processAdditionalCropDetails for empty additional crop details map
    * @author Sk Minsar | 01-24-2025 
    **/
    @isTest 
    public static void testProcessAdditionalCropDetailsEmptyMap(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> requestMap = new Map<String, Object>();
        List<Object> additionalCropDetailsList = new List<Object>();
        additionalCropDetailsList.add(requestMap);

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.processAdditionalCropDetails(additionalCropDetailsList, new  Map<String, Object>{'shouldValidate' => PortalConstants.TRUE_VALUE}, new genesis__Applications__c());
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test processAdditionalCropDetails for county null
    * @author Sk Minsar | 01-24-2025 
    **/
    @isTest 
    public static void testProcessAdditionalCropDetailsCountyNull(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> requestMap = new Map<String, Object>();
        List<Object> additionalCropDetailsList = new List<Object>();
        requestMap.put('clcommon__Account__r.Name', 'Kisan Loan');
        requestMap.put('clcommon__Account__r.Billing_County__c', null);
        additionalCropDetailsList.add(requestMap);
        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.processAdditionalCropDetails(additionalCropDetailsList, new  Map<String, Object>{'shouldValidate' => PortalConstants.TRUE_VALUE}, new genesis__Applications__c());
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.TRUE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test processPotentialBuyers for empty poetential buyers details map
    * @author Sk Minsar | 01-24-2025 
    **/
    @isTest 
    public static void testProcessPotentialBuyersEmptyMap(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> requestMap = new Map<String, Object>();
        List<Object> potentialBuyersList = new List<Object>();
        potentialBuyersList.add(requestMap);

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.processPotentialBuyers(potentialBuyersList,  new  Map<String, Object>{'shouldValidate' => PortalConstants.TRUE_VALUE}, new genesis__Applications__c());
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test processCropInsuranceDetails for empty crop insurance details map
    * @author Sk Minsar | 01-24-2025 
    **/
    @isTest 
    public static void testProcessCropInsuranceDetailsEmptyMap(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> requestMap = new Map<String, Object>();
        List<Object> cropInsuranceDetailsList = new List<Object>();
        cropInsuranceDetailsList.add(requestMap);

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.processCropInsuranceDetails(cropInsuranceDetailsList,  new  Map<String, Object>{'shouldValidate' => PortalConstants.TRUE_VALUE}, new genesis__Applications__c());
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateSpouseDetails for empty spouse details map
    * @author Sk Minsar | 01-24-2025 
    **/
    @isTest 
    public static void testValidateSpouseDetailsEmptyMap(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> requestMap = new Map<String, Object>();
        List<Object> validateSpouseDetailsList = new List<Object>();
        validateSpouseDetailsList.add(requestMap);

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.validateSpouseDetails(validateSpouseDetailsList);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateSpouseDetails for contact FirstName null
    * @author Sk Minsar | 01-24-2025 
    **/
    @isTest 
    public static void testValidateSpouseDetailsNameNull(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> requestMap = new Map<String, Object>();
        List<Object> validateSpouseDetailsList = new List<Object>();
        requestMap.put('clcommon__Contact__r.FirstName', null);
        validateSpouseDetailsList.add(requestMap);

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.validateSpouseDetails(validateSpouseDetailsList);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.TRUE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateAdditionalCropDetails for empty additional crop details map
    * @author Sk Minsar | 01-24-2025 
    **/
    @isTest 
    public static void testValidateAdditionalCropDetailsEmptyMap(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> requestMap = new Map<String, Object>();
        List<Object> additionalCropDetailsList = new List<Object>();
        additionalCropDetailsList.add(requestMap);

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.validateAdditionalCropDetails(additionalCropDetailsList, PortalConstants.TRUE_VALUE);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateAdditionalCropDetails for null account name
    * @author Sk Minsar | 01-24-2025 
    **/
    @isTest 
    public static void testValidateAdditionalCropDetailsNameNull(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> requestMap = new Map<String, Object>();
        List<Object> additionalCropDetailsList = new List<Object>();
        requestMap.put('clcommon__Account__r.Name', null);
        additionalCropDetailsList.add(requestMap);

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.validateAdditionalCropDetails(additionalCropDetailsList, PortalConstants.TRUE_VALUE);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.TRUE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateAdditionalCropForSaveAndContinue Exception
    * @author Sk Minsar | 01-24-2025 
    **/
    @isTest 
    public static void testCropForSaveAndContinueEx(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> requestMap = new Map<String, Object>();
        requestMap.put('clcommon__Account__r.Name', null);

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.validateAdditionalCropForSaveAndContinue(requestMap, PortalConstants.TRUE_VALUE);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.TRUE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test validatePotentialBuyersDetails for empty potential buyers details map
    * @author Sk Minsar | 01-24-2025 
    **/
    @isTest 
    public static void testValidatePotentialBuyersDetailsEmptyMap(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> requestMap = new Map<String, Object>();
        List<Object> buyersDetailsList = new List<Object>();
        buyersDetailsList.add(requestMap);

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.validatePotentialBuyersDetails(buyersDetailsList, PortalConstants.TRUE_VALUE);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test validatePotentialBuyersDetails for null account name
    * @author Sk Minsar | 01-24-2025 
    **/
    @isTest 
    public static void testValidatePotentialBuyersDetailsNameNull(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> requestMap = new Map<String, Object>();
        List<Object> buyersDetailsList = new List<Object>();
        requestMap.put('clcommon__Account__r.Name', null);
        buyersDetailsList.add(requestMap);

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.validatePotentialBuyersDetails(buyersDetailsList, PortalConstants.TRUE_VALUE);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.TRUE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateCropInsuranceDetails for empty crop insurance details map
    * @author Sk Minsar | 01-24-2025 
    **/
    @isTest 
    public static void testValidateCropInsuranceDetailsEmptyMap(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> requestMap = new Map<String, Object>();
        List<Object> cropInsuranceDetailsList = new List<Object>();
        cropInsuranceDetailsList.add(requestMap);

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.validateCropInsuranceDetails(cropInsuranceDetailsList, PortalConstants.TRUE_VALUE);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test validateCropInsuranceDetails for null account name
    * @author Sk Minsar | 01-24-2025 
    **/
    @isTest 
    public static void testValidateCropInsuranceDetailsNameNull(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        Map<String, Object> requestMap = new Map<String, Object>();
        List<Object> cropInsuranceDetailsList = new List<Object>();
        requestMap.put('clcommon__Account__r.Name', null);
        cropInsuranceDetailsList.add(requestMap);

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.validateCropInsuranceDetails(cropInsuranceDetailsList, PortalConstants.TRUE_VALUE);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.TRUE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test getLegalEntityMap
    * @author Sk Minsar | 01-24-2025 
    **/
    @isTest 
    public static void testGetLegalEntityMap(){
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.getLegalEntityMap();
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.FALSE_VALUE, isExceptionThrown, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test coopRateCardDetail rate card detail & rate card header start date different
    **/
    @isTest
    public static void testCoopRateCardDetailC() {
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        List<genesis__rate_card_setup_header__c> rateCardList = getRateCardHeaderList();
        List<genesis__Rate_Card_Setup_Detail__c> rateCardDetailList = getRateCardSetupDetails(rateCardList[0].Id);
        for(genesis__Rate_Card_Setup_Detail__c rateCard:rateCardDetailList){
            rateCard.genesis__Enabled_flag__c = PortalConstants.FALSE_VALUE;
            rateCard.Special_Term_Reference__c = PortalConstants.SPECIAL_TERM_C;
            rateCard.End_Date__c = rateCardList[0].genesis__End_Date__c.addDays(-5);
            rateCard.Start_Date__c = rateCardList[0].genesis__Start_Date__c;
        }
        rateCardDetailList[0].genesis__Enabled_flag__c = PortalConstants.FALSE_VALUE;
        rateCardDetailList[0].Special_Term_Reference__c = PortalConstants.SPECIAL_TERM_C;
        rateCardDetailList[0].End_Date__c = rateCardList[0].genesis__End_Date__c.addDays(-3);
        rateCardDetailList[0].Start_Date__c = rateCardList[0].genesis__End_Date__c.addDays(-3);
        Database.update(rateCardDetailList,true);

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.coopRateCardDetail(new Map<String, Object>{
                        'startDateRange' => rateCardList[0].genesis__End_Date__c.addDays(-4),
                        'endDateRange'  => rateCardList[0].genesis__End_Date__c.addDays(-2),
                        'cropYear' => Integer.valueOf(rateCardDetailList[0].genesis__rate_card_setup_header__r.Crop_Year__c),
                        'coopType' => (String) rateCardDetailList[0].genesis__rate_card_setup_header__r.Account__r.Coop_Type__c
                    }, rateCardDetailList);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.TRUE_VALUE, isExceptionThrown ,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description - Test coopRateCardDetail rate card detail & rate card header start date different for gmk
    **/
    @isTest
    public static void testCoopRateCardDetailCGmk() {
        Boolean isExceptionThrown = PortalConstants.FALSE_VALUE;
        List<genesis__rate_card_setup_header__c> rateCardList = getRateCardHeaderList();
        List<genesis__Rate_Card_Setup_Detail__c> rateCardDetailList = getRateCardSetupDetails(rateCardList[0].Id);
        for(genesis__Rate_Card_Setup_Detail__c rateCard:rateCardDetailList){
            rateCard.genesis__Enabled_flag__c = PortalConstants.FALSE_VALUE;
            rateCard.Special_Term_Reference__c = PortalConstants.SPECIAL_TERM_C;
            rateCard.End_Date__c = rateCardList[0].genesis__End_Date__c.addDays(-5);
            rateCard.Start_Date__c = rateCardList[0].genesis__Start_Date__c;
        }
        rateCardDetailList[0].genesis__Enabled_flag__c = PortalConstants.FALSE_VALUE;
        rateCardDetailList[0].Special_Term_Reference__c = PortalConstants.SPECIAL_TERM_C;
        rateCardDetailList[0].End_Date__c = rateCardList[0].genesis__End_Date__c.addDays(-3);
        rateCardDetailList[0].Start_Date__c = rateCardList[0].genesis__End_Date__c.addDays(-3);
        Database.update(rateCardDetailList,true);

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            Test.startTest();
                try{
                    PortalApplicationOriginationHelper.coopRateCardDetail(new Map<String, Object>{
                        'startDateRange' => rateCardList[0].genesis__End_Date__c.addDays(-4),
                        'endDateRange'  => rateCardList[0].genesis__End_Date__c.addDays(-2),
                        'cropYear' => Integer.valueOf(rateCardDetailList[0].genesis__rate_card_setup_header__r.Crop_Year__c),
                        'coopType' => PortalConstants.GROWMARK_COOP_TYPE
                    }, rateCardDetailList);
                }catch(Exception e){
                    isExceptionThrown = PortalConstants.TRUE_VALUE;
                }
                System.assertEquals(PortalConstants.TRUE_VALUE, isExceptionThrown ,PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description test if the correct record type is populated for a applicant who is neiter a co-applicant nor a grower
    * @author Rakesh Saraf | 03-26-2025 
    **/
    @isTest
    private static void testSetRecordTypeForPrincipal(){
        Account accountObj=new Account();
        accountObj.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get(PortalConstants.SPOUSE).getRecordTypeId();

        Id coAppRecordId=Schema.SObjectType.Account.getRecordTypeInfosByName().get(PortalConstants.CO_APPLICATION_RECORD_TYPE).getRecordTypeId();

        System.runAs(ApplicationOriginationTestHelper.getSystemAdminUser()){
            PortalApplicationOriginationHelper.setRecordTypeForPrincipal(accountObj);
            System.assertEquals(accountObj.RecordTypeId, coAppRecordId ,PortalConstants.ASSERTION_FAILED);
        }
    }
}