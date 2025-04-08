/**********************************************************************************************************************
 * @description       : 
 * @author            : Arka Jyoti Deb
 * @group             : 
 * @last modified on  : 27-01-2025
 * @last modified by  : Soumik Pattanayak
**********************************************************************************************************************/

@isTest
public with sharing class TestPortalGenericDeleteAPI {
    @TestSetup
    static void makeData(){
        genesis__Business_Information__c businessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        Database.insert(businessInfoObj,true);
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(businessInfoObj.id);
        Database.insert(dealerAccountObj,true);
        clcommon__CL_Product__c clProductObj = ApplicationOriginationTestHelper.createCLProduct();
        Database.insert(clProductObj,true);
        clcommon__CL_Purpose__c  clPurposeObj = ApplicationOriginationTestHelper.createCLPurpose();
        Database.insert(clPurposeObj,true);
        clcommon__Legal_Entity__c legalEntityObj  = ApplicationOriginationTestHelper.createSolePropLegalEntity();
        Database.insert(legalEntityObj,true);
        clcommon__Legal_Entity__c corpLegalEntityObj  = ApplicationOriginationTestHelper.createCorporationLegalEntity();
        Database.insert(corpLegalEntityObj,true);
        genesis__Business_Information__c borrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        Database.insert(borrowerBusinessInfoObj,true);
        Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(legalEntityObj,borrowerBusinessInfoObj.id);
        borrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Grower').getRecordTypeId();
        Database.insert(borrowerAccountObj,true);
        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.id);
        Database.insert(borrowerContactObj,true);
        Account accountObj = ApplicationOriginationTestHelper.createSalesAgentAccount(businessInfoObj.id,dealerAccountObj.id);
        Database.insert(accountObj,true);
        Contact contactObj = ApplicationOriginationTestHelper.createSalesAgentContact(accountObj.id);
        Database.insert(contactObj,true);
        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(businessInfoObj.id,dealerAccountObj.id);
        Database.insert(clAccountObj,true);
        Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.id);
        Database.insert(clContactObj,true);
        genesis__Business_Information__c coBorrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        Database.insert(coBorrowerBusinessInfoObj,true);
        Account coBorrowerAccountObj = ApplicationOriginationTestHelper.createCoBorrowerAccount(legalEntityObj,coBorrowerBusinessInfoObj.id);
        coBorrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CoApplicant').getRecordTypeId();
        Database.insert(coBorrowerAccountObj,true);
        Contact coBorrowerContactObj = ApplicationOriginationTestHelper.createCoBorrowerContact(coBorrowerAccountObj.id);
        Database.insert(coBorrowerContactObj,true);

        Dealer_Applicant_Relationship__c borrowerRealtionObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(borrowerContactObj,dealerAccountObj.Id);
        Dealer_Applicant_Relationship__c principalRealtionObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(coBorrowerContactObj,dealerAccountObj.Id);
        Database.insert(new List<Dealer_Applicant_Relationship__c>{borrowerRealtionObj, principalRealtionObj});

        Map<String,Object> applicationDataMap = new Map<String,Object>{
            'dealerAccountObjId' => dealerAccountObj.id,
            'clProductObjId' => clProductObj.id,
            'clPurposeObjId' => clPurposeObj.id,
            'borrowerAccountObjId' => borrowerAccountObj.id,
            'borrowerContactObjId' => borrowerContactObj.id,
            'saAccountObjId' => accountObj.id,
            'dealerApplicantRelationshipId' => borrowerRealtionObj.id
        };
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createApplication(applicationDataMap);
        applicationObj.Certified_Lender__c = clAccountObj.id;
        Database.insert(applicationObj,true); 
        clcommon__Party_Type__c clPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('CERTIFIED LENDER');
        Database.insert(clPartyTypeObj,true);
        clcommon__Party_Type__c prPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('PRINCIPAL');
        Database.insert(prPartyTypeObj,true);
        clcommon__Party_Type__c boPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('BORROWER');
        Database.insert(boPartyTypeObj,true);
        createAdditionalInfoParties(accountObj, contactObj, applicationObj);

        Map<String,Id> borrowerPartyParamMap = new Map<String,Id>{
            'accountId' => borrowerAccountObj.id,
            'contactId' => borrowerContactObj.id,
            'partyTypeId' => boPartyTypeObj.id,
            'applicationId' => applicationObj.id,
            'dealerApplicantRelationshipId' => borrowerRealtionObj.id
        };
        clcommon__Party__c borrowerPartyObj = ApplicationOriginationTestHelper.createParty(borrowerPartyParamMap);
        Database.insert(borrowerpartyObj,true);

        Map<String,Id> principalPartyParamMap = new Map<String,Id>{
            'accountId' => coBorrowerAccountObj.id,
            'contactId' => coBorrowerContactObj.id,
            'partyTypeId' => prPartyTypeObj.id,
            'applicationId' => applicationObj.id,
            'dealerApplicantRelationshipId' => principalRealtionObj.id
        };
        clcommon__Party__c principalPartyObj = ApplicationOriginationTestHelper.createParty(principalPartyParamMap);
        Database.insert(principalPartyObj,true);

        Map<String,Id> clpartyParamMap = new Map<String,Id>{
            'accountId' => clAccountObj.id,
            'contactId' => clContactObj.id,
            'partyTypeId' => clPartyTypeObj.id,
            'applicationId' => applicationObj.id
        };
        clcommon__Party__c clPartyObj = ApplicationOriginationTestHelper.createParty(clpartyParamMap);
        Database.insert(clPartyObj,true);
        createRateCardSetup(applicationObj, dealerAccountObj);

        clcommon__Bank_Account__c bankAccount = ApplicationOriginationTestHelper.createBankAccount();
        bankAccount.clcommon__Account__c = clAccountObj.id;
        bankAccount.clcommon__Contact__c = clContactObj.id;
        Database.insert(bankAccount,true);
        createFundingTransactions(applicationObj);
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 10-01-2025 
    * @param accountObj 
    * @param contactObj 
    * @param applicationObj 
    **/
    private static void createAdditionalInfoParties(Account accountObj, Contact contactObj, genesis__Applications__c applicationObj){
        clcommon__Party_Type__c spPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('SPOUSE');
        Database.insert(spPartyTypeObj,true);
        clcommon__Party_Type__c loPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('LANDOWNER');
        Database.insert(loPartyTypeObj,true);
        clcommon__Party_Type__c iaPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('INSURANCE AGENT');
        Database.insert(iaPartyTypeObj,true);
        clcommon__Party_Type__c buPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('BUYER');
        Database.insert(buPartyTypeObj,true);
        Contact clContactObj = [SELECT id FROM Contact WHERE email = 'ross.geller@yopmail.com'];
        User userObj = ApplicationOriginationTestHelper.createCLUser(clContactObj.id);
        Database.insert(userObj,true);

        Map<String,Id> spousePartyParamMap = new Map<String,Id>{
            'accountId' => accountObj.id,
            'contactId' => contactObj.id,
            'partyTypeId' => spPartyTypeObj.id,
            'applicationId' => applicationObj.id
        };
        clcommon__Party__c spousePartyObj = ApplicationOriginationTestHelper.createParty(spousePartyParamMap);
        Database.insert(spousePartyObj,true);

        Map<String,Id> landOwnerPartyParamMap = new Map<String,Id>{
            'accountId' => accountObj.id,
            'contactId' => contactObj.id,
            'partyTypeId' => loPartyTypeObj.id,
            'applicationId' => applicationObj.id
        };
        clcommon__Party__c landOwnerPartyObj = ApplicationOriginationTestHelper.createParty(landOwnerPartyParamMap);
        Database.insert(landOwnerPartyObj,true);

        Map<String,Id> iaParamMap = new Map<String,Id>{
            'accountId' => accountObj.id,
            'contactId' => contactObj.id,
            'partyTypeId' => iaPartyTypeObj.id,
            'applicationId' => applicationObj.id
        };
        clcommon__Party__c iaPartyObj = ApplicationOriginationTestHelper.createParty(iaParamMap);
        Database.insert(iaPartyObj,true);

        Map<String,Id> buyerParamMap = new Map<String,Id>{
            'accountId' => accountObj.id,
            'contactId' => contactObj.id,
            'partyTypeId' => buPartyTypeObj.id,
            'applicationId' => applicationObj.id
        };
        clcommon__Party__c buyerPartyObj = ApplicationOriginationTestHelper.createParty(buyerParamMap);
        Database.insert(buyerPartyObj,true);
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 10-01-2025 
    * @param applicationObj 
    * @param dealerAccountObj 
    **/
    private static void createRateCardSetup(genesis__Applications__c applicationObj, Account dealerAccountObj){
        clcommon__Collateral_Category__c collateralCategoryObj = ApplicationOriginationTestHelper.createCollateralCategory();
        Database.insert(collateralCategoryObj,true);

        Map<String,String> collateralDeatailsMap = new Map<String,String>{
            'collateralCategoryId' => String.valueOf(collateralCategoryObj.Id),
            'insurancePlan' => 'YP',
            'percentCoverageLevel' => '50%'
        };
        clcommon__collateral__c collateralObj = ApplicationOriginationTestHelper.createCollateral(collateralDeatailsMap);
        collateralObj.genesis__Application__c = applicationObj.id;
        Database.insert(collateralObj,true);

        genesis__Rate_Card_Setup_Header__c rateCardHeaderObj = ApplicationOriginationTestHelper.createRateCardSetupHeader(dealerAccountObj);
        Database.insert(rateCardHeaderObj,true);
        genesis__Rate_Card_Setup_Detail__c arateCardSetupDetails =  ApplicationOriginationTestHelper.createNewRateCardSetupDetail(rateCardHeaderObj);
        arateCardSetupDetails.Special_Term_Reference__c = PortalConstants.SPECIAL_TERM_A;
        Database.insert(arateCardSetupDetails,true);

        genesis__Rate_Card_Setup_Detail__c brateCardSetupDetails =  ApplicationOriginationTestHelper.createNewRateCardSetupDetail(rateCardHeaderObj);
        brateCardSetupDetails.Special_Term_Reference__c = PortalConstants.SPECIAL_TERM_B;
        Database.insert(brateCardSetupDetails,true);

        genesis__Rate_Card_Setup_Detail__c rateCard =  ApplicationOriginationTestHelper.createNewRateCardSetupDetail(rateCardHeaderObj);
        rateCard.Special_Term_Reference__c = PortalConstants.SPECIAL_TERM_B;
        rateCard.Start_Date__c = (brateCardSetupDetails.Start_Date__c).addDays(-1);
        rateCard.End_Date__c = (brateCardSetupDetails.End_Date__c).addDays(1);
        Database.insert(rateCard,true);

        genesis__Rate_Card_Setup_Detail__c rateCardOnDescription =  ApplicationOriginationTestHelper.createNewRateCardSetupDetail(rateCardHeaderObj);
        rateCardOnDescription.Special_Term_Reference__c = PortalConstants.SPECIAL_TERM_B;
        rateCardOnDescription.End_Date__c = (brateCardSetupDetails.End_Date__c).addDays(1);
        rateCardOnDescription.genesis__Enabled_flag__c = false;
        Database.insert(rateCardOnDescription,true);

        genesis__Rate_Card_Setup_Detail__c crateCardSetupDetails =  ApplicationOriginationTestHelper.createNewRateCardSetupDetail(rateCardHeaderObj);
        crateCardSetupDetails.Special_Term_Reference__c = 'Special Term Sub-Tranche (C)';
        Database.insert(crateCardSetupDetails,true);
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 10-01-2025 
    * @param applicationObj 
    **/
    private static void createFundingTransactions(genesis__Applications__c applicationObj){
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        System.runAs(userObj){
            genesis__Application_Pricing_Detail__c pricingDetailsObj = ApplicationOriginationTestHelper.createPricingDetail(applicationObj.id);
            Database.insert(pricingDetailsObj,true);
            clcommon__Payment_Mode__c achPaymentMode = ApplicationOriginationTestHelper.createPaymentMode('ACH');
            Database.insert(achPaymentMode,true);
            clcommon__Payment_Mode__c paymentMode = ApplicationOriginationTestHelper.createPaymentMode('PAYMENT');
            Database.insert(paymentMode,true);
            clcommon__Consolidated_Invoice__c invoice = ApplicationOriginationTestHelper.createInvoice(applicationObj.id);
            invoice.Payment_Mode__c = paymentMode.Id;
            Database.insert(invoice,true);
            genesis__Funding_Transaction__c fundingTransacObj = ApplicationOriginationTestHelper.createFundingTransaction(paymentMode.id,pricingDetailsObj.id,applicationObj.id);
            fundingTransacObj.Posted_to_NLS__c = false;
            fundingTransacObj.genesis__Cleared__c = false;
            fundingTransacObj.genesis__Application__c = applicationObj.Id;
            fundingTransacObj.Invoice__c = invoice.id;
            fundingTransacObj.genesis__Payment_Mode__c = paymentMode.Id;
            fundingTransacObj.genesis__Application__c = applicationObj.Id;
            fundingTransacObj.Status__c = 'Pending';
            Database.insert(fundingTransacObj,true);  
            genesis__Funding_Transaction__c fundingTransactionObj = ApplicationOriginationTestHelper.createFundingTransaction(paymentMode.Id,pricingDetailsObj.id,applicationObj.id);
            fundingTransactionObj.genesis__Payment_Mode__c = paymentMode.Id;
            fundingTransactionObj.Posted_to_NLS__c = false;
            fundingTransactionObj.genesis__Cleared__c = false;
            fundingTransactionObj.genesis__Application__c = applicationObj.Id;
            fundingTransactionObj.Invoice__c = invoice.id;
            fundingTransactionObj.Status__c = 'Pending';
            Database.insert(fundingTransactionObj,true); 
            invoice.Total_Amount__c = fundingTransactionObj.genesis__Amount__c + fundingTransacObj.genesis__Amount__c;
            Database.update(invoice,true); 
        }
    }

    /**
    * @description test co applicant deletion
    * @author Soumik Pattanayak | 23-12-2024 
    **/
    @isTest
    public static void testCoApplicantDeletion() {
        Map<String, Object> requestMap = new Map<String, Object>();
        genesis__Applications__c applicationObj;
        clcommon__Party__c partyObj;
        User userObj;
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                            Certified_Lender__c
                                                            FROM genesis__Applications__c LIMIT 1];
        
        applicationObj = applicationList[0];
        List<User> userList = [SELECT Id,IsActive FROM User WHERE Contact.AccountId =: applicationObj.Certified_Lender__c LIMIT 1];
        userObj = userList[0];
        List<clcommon__Party__c> partyList = [SELECT Id,
                                                    clcommon__User__c
                                                FROM clcommon__Party__c 
                                                WHERE genesis__Application__c =: applicationObj.id AND clcommon__Type__r.Name = 'PRINCIPAL' LIMIT 1];
        partyObj = partyList[0];
        partyObj.clcommon__User__c = userObj.id;
        Database.update(partyObj,true);
        requestMap.put('objectName', 'party');
        requestMap.put('applicationId', String.valueOf(applicationObj.Id));
        requestMap.put('recordId', String.valueOf(partyObj.Id));
        System.runAs(userObj) {
            Test.startTest();
            PortalGenericDeleteAPI testApi = new PortalGenericDeleteAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'CoApplicant is not deleted');
            Test.stopTest();
        }
    }
    /**
    * @description  test dealer applicant relationship deletion
    * @author Soumik Pattanayak | 23-12-2024 
    **/
    @isTest
    public static void testDealerApplicantRelationDeletion() {
        Map<String, Object> requestMap = new Map<String, Object>();
        genesis__Applications__c applicationObj;
        clcommon__Party__c partyObj;
        User userObj;
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                            Certified_Lender__c
                                                            FROM genesis__Applications__c LIMIT 1];
        applicationObj = applicationList[0];
        
        List<User> userList = [SELECT Id,IsActive FROM User WHERE Contact.AccountId =: applicationObj.Certified_Lender__c LIMIT 1];
        userObj = userList[0];
        
        List<clcommon__Party__c> partyList = [SELECT Id,
                                                    clcommon__User__c
                                                FROM clcommon__Party__c 
                                                WHERE genesis__Application__c =: applicationObj.id AND clcommon__Type__r.Name = 'PRINCIPAL' LIMIT 1];
        partyObj = partyList[0];
        partyObj.clcommon__User__c = userObj.id;
        Database.update(partyObj,true);
        requestMap.put('objectName', 'party');
        requestMap.put('applicationId', String.valueOf(applicationObj.Id));
        requestMap.put('recordId', String.valueOf(partyObj.Id));
        System.runAs(userObj) {
            Test.startTest();
            PortalGenericDeleteAPI testApi = new PortalGenericDeleteAPI();
            testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(0, [SELECT id FROM Dealer_Applicant_Relationship__c].size(),'Dealer Applicant Relation is not deleted');
            Test.stopTest();
        }
    }
    /**
    * @description  test exception
    * @author Soumik Pattanayak | 23-12-2024 
    **/
    @isTest
    public static void testRequestMapParameterMissingException() {
        Map<String, Object> requestMap = new Map<String, Object>();

        genesis__Applications__c applicationObj;
        clcommon__Party__c partyObj;
        User userObj;
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                            Certified_Lender__c
                                                            FROM genesis__Applications__c LIMIT 1];
        applicationObj = applicationList[0];
        
        List<User> userList = [SELECT Id FROM User WHERE Contact.AccountId =: applicationObj.Certified_Lender__c LIMIT 1];
        userObj = userList[0];
        
        List<clcommon__Party__c> partyList = [SELECT Id,
                                                    clcommon__User__c
                                                FROM clcommon__Party__c 
                                                WHERE genesis__Application__c =: applicationObj.id AND clcommon__Type__r.Name = 'PRINCIPAL' LIMIT 1];
        partyObj = partyList[0];
        partyObj.clcommon__User__c = userObj.id;
        Database.update(partyObj,true);
        requestMap.put('objectName', 'party');
        requestMap.put('applicationId', String.valueOf(applicationObj.Id));
        System.runAs(userObj) {
            Test.startTest();
            PortalGenericDeleteAPI testApi = new PortalGenericDeleteAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Party is succesfully deleted');
            Test.stopTest();
        }
    }
    /**
    * @description  test exception
    * @author Soumik Pattanayak | 23-12-2024 
    **/
    @isTest 
    public static void testValidDeletion() {
        Map<String, Object> requestMap = new Map<String, Object>();
        User userObj;
        List<User> userList = [SELECT Id,IsActive FROM User WHERE Profile.Name = 'Certified Lender' AND IsActive = true LIMIT 1];
        userObj = userList[0];
        
        requestMap.put('objectName', 'account');
        requestMap.put('applicationId', '1234567');
        requestMap.put('recordId', '12345654321');
        System.runAs(userObj) {
            Test.startTest();
            PortalGenericDeleteAPI testApi = new PortalGenericDeleteAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Account deleted succesfully');
            Test.stopTest();
        }
    }
    /**
    * @description  test collatral deletion
    * @author Soumik Pattanayak | 23-12-2024 
    **/
    @isTest
    public static void testCollateralDeletion() {
        Map<String, Object> requestMap = new Map<String, Object>();
        genesis__Applications__c applicationObj;
        User userObj;
        clcommon__collateral__c collateralObj ;
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                            Certified_Lender__c
                                                            FROM genesis__Applications__c LIMIT 1];
        applicationObj = applicationList[0];
        
        List<User> userList = [SELECT Id FROM User WHERE Contact.AccountId =: applicationObj.Certified_Lender__c LIMIT 1];
        userObj = userList[0];
        
        List<clcommon__collateral__c> collateralList = [SELECT Id FROM clcommon__collateral__c WHERE genesis__Application__c =: applicationObj.id LIMIT 1];
        collateralObj = collateralList[0];
        
        requestMap.put('objectName', 'collateral');
        requestMap.put('applicationId', String.valueOf(applicationObj.Id));
        requestMap.put('recordId', String.valueOf(collateralObj.Id));
        System.runAs(userObj) {
            Test.startTest();
            PortalGenericDeleteAPI testApi = new PortalGenericDeleteAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Collateral is not deleted');
            Test.stopTest();
        }
    }

    /**
    * @description test spouse deletion
    * @author Soumik Pattanayak | 23-12-2024 
    **/
    @isTest
    public static void testSpouseDeletion() {
        Map<String, Object> requestMap = new Map<String, Object>();

        genesis__Applications__c applicationObj;
        clcommon__Party__c partyObj;
        User userObj;
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                            Certified_Lender__c
                                                            FROM genesis__Applications__c LIMIT 1];
        applicationObj = applicationList[0];
        
        List<User> userList = [SELECT Id FROM User WHERE Contact.AccountId =: applicationObj.Certified_Lender__c LIMIT 1];
        userObj = userList[0];
        
        List<clcommon__Party__c> partyList = [SELECT Id,
                                                    clcommon__User__c
                                                FROM clcommon__Party__c 
                                                WHERE genesis__Application__c =: applicationObj.id AND clcommon__Type__r.Name = 'SPOUSE' LIMIT 1];
        partyObj = partyList[0];
        partyObj.clcommon__User__c = userObj.id;
        
        Database.update(partyObj,true);
        requestMap.put('objectName', 'party');
        requestMap.put('applicationId', String.valueOf(applicationObj.Id));
        requestMap.put('recordId', String.valueOf(partyObj.Id));
        System.runAs(userObj) {
            Test.startTest();
            PortalGenericDeleteAPI testApi = new PortalGenericDeleteAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Spouse is not deleted');
            Test.stopTest();
        }
    }
    /**
    * @description test land owner deletion
    * @author Soumik Pattanayak | 23-12-2024 
    **/
    @isTest
    public static void testLandownerDeletion() {
        Map<String, Object> requestMap = new Map<String, Object>();

        genesis__Applications__c applicationObj;
        clcommon__Party__c partyObj;
        User userObj;
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                            Certified_Lender__c
                                                            FROM genesis__Applications__c LIMIT 1];
        applicationObj = applicationList[0];
        
        List<User> userList = [SELECT Id FROM User WHERE Contact.AccountId =: applicationObj.Certified_Lender__c LIMIT 1];
        userObj = userList[0];
        
        List<clcommon__Party__c> partyList = [SELECT Id,
                                                    clcommon__User__c
                                                FROM clcommon__Party__c 
                                                WHERE genesis__Application__c =: applicationObj.id AND clcommon__Type__r.Name = 'LANDOWNER' LIMIT 1];
        partyObj = partyList[0];
        partyObj.clcommon__User__c = userObj.id;
        
        Database.update(partyObj,true);
        requestMap.put('objectName', 'party');
        requestMap.put('applicationId', String.valueOf(applicationObj.Id));
        requestMap.put('recordId', String.valueOf(partyObj.Id));
        System.runAs(userObj) {
            Test.startTest();
            PortalGenericDeleteAPI testApi = new PortalGenericDeleteAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Landowner party deletion failed');
            Test.stopTest();
        }
    }
    /**
    * @description test insurance agent deletion
    * @author Soumik Pattanayak | 23-12-2024 
    **/
    @isTest
    public static void testInsuranceAgentDeletion() {
        Map<String, Object> requestMap = new Map<String, Object>();

        genesis__Applications__c applicationObj;
        clcommon__Party__c partyObj;
        User userObj;
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                            Certified_Lender__c
                                                            FROM genesis__Applications__c LIMIT 1];
        applicationObj = applicationList[0];
        
        List<User> userList = [SELECT Id FROM User WHERE Contact.AccountId =: applicationObj.Certified_Lender__c LIMIT 1];
        userObj = userList[0];
        
        List<clcommon__Party__c> partyList = [SELECT Id,
                                                    clcommon__User__c
                                                FROM clcommon__Party__c 
                                                WHERE genesis__Application__c =: applicationObj.id AND clcommon__Type__r.Name = 'INSURANCE AGENT' LIMIT 1];
        partyObj = partyList[0];
        partyObj.clcommon__User__c = userObj.id;
        
        Database.update(partyObj,true);
        requestMap.put('objectName', 'party');
        requestMap.put('applicationId', String.valueOf(applicationObj.Id));
        requestMap.put('recordId', String.valueOf(partyObj.Id));
        System.runAs(userObj) {
            Test.startTest();
            PortalGenericDeleteAPI testApi = new PortalGenericDeleteAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Insurance Agent deletion failed');
            Test.stopTest();
        }
    }
   
    /**
    * @description test buyer deletion
    * @author Soumik Pattanayak | 23-12-2024 
    **/
    @isTest
    public static void testBuyerDeletion() {
        Map<String, Object> requestMap = new Map<String, Object>();


        genesis__Applications__c applicationObj;
        clcommon__Party__c partyObj;
        User userObj;
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                            Certified_Lender__c
                                                            FROM genesis__Applications__c LIMIT 1];
        applicationObj = applicationList[0];
        
        List<User> userList = [SELECT Id FROM User WHERE Contact.AccountId =: applicationObj.Certified_Lender__c LIMIT 1];
        userObj = userList[0];
        
        List<clcommon__Party__c> partyList = [SELECT Id,
                                                    clcommon__User__c
                                                FROM clcommon__Party__c 
                                                WHERE genesis__Application__c =: applicationObj.id AND clcommon__Type__r.Name = 'BUYER' LIMIT 1];
        partyObj = partyList[0];
        partyObj.clcommon__User__c = userObj.id;
        
        Database.update(partyObj,true);
        requestMap.put('objectName', 'party');
        requestMap.put('applicationId', String.valueOf(applicationObj.Id));
        requestMap.put('recordId', String.valueOf(partyObj.Id));
        System.runAs(userObj) {
            Test.startTest();
            PortalGenericDeleteAPI testApi = new PortalGenericDeleteAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Buyer deletion failed');
            Test.stopTest();
        }
    }
    /**
    * @description test rate card deletion
    * @author Soumik Pattanayak | 23-12-2024 
    **/
    @isTest
    public static void testRateCardDeletion() {
        Map<String, Object> requestMap = new Map<String, Object>();
        Account accountObj;
        User userObj;
        genesis__rate_card_setup_header__c  rateCardObj;
        List<Account> accountList = [SELECT Id FROM Account WHERE RecordType.Name = 'CERTIFIED LENDER' LIMIT 1];
        if(accountList.size()==1){
            accountObj = accountList[0];
        }
        List<User> userList = [SELECT Id,IsActive FROM User WHERE Contact.AccountId =: accountObj.id LIMIT 1];
        userObj = userList[0];
        
        List<genesis__rate_card_setup_header__c> rateCardList = [SELECT Id FROM genesis__rate_card_setup_header__c LIMIT 1];
        rateCardObj = rateCardList[0];
        
        requestMap.put('objectName', 'myProgram');
        requestMap.put('recordId', String.valueOf(rateCardObj.Id));
        System.runAs(userObj) {
            Test.startTest();
            PortalGenericDeleteAPI testApi = new PortalGenericDeleteAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Rate Card deletion failed');
            Test.stopTest();
        }
    }
    /**
    * @description test rate card detail deletion
    * @author Soumik Pattanayak | 23-12-2024 
    **/
    @isTest
    public static void testRateCardDetailsTermReferenceADeletion() {
        Map<String, Object> requestMap = new Map<String, Object>();

        Account accountObj;
        User userObj;
        genesis__rate_card_setup_header__c  rateCardObj;
        genesis__Rate_Card_Setup_Detail__c rateCardDetailsObj;
        Account dealerAccount;
        List<Account> dealerAccountList = [SELECT Id,Coop_Type__c FROM Account WHERE RecordType.Name = 'Dealer' LIMIT 1];
        dealerAccount = dealerAccountList[0];
        dealerAccount.Coop_Type__c = PortalConstants.GROWMARK_COOP_TYPE;
        
        Database.update(dealerAccount,true);
        List<Account> accountList = [SELECT Id FROM Account WHERE RecordType.Name = 'CERTIFIED LENDER' LIMIT 1];
        if(accountList.size()==1){
            accountObj = accountList[0];
        }
        List<User> userList = [SELECT Id FROM User WHERE Contact.AccountId =: accountObj.id LIMIT 1];
        userObj = userList[0];
        
        List<genesis__rate_card_setup_header__c> rateCardList = [SELECT Id FROM genesis__rate_card_setup_header__c LIMIT 1];
        for(genesis__rate_card_setup_header__c rObj : rateCardList){
            rateCardObj = rObj;
        }
        List<genesis__Rate_Card_Setup_Detail__c> rateCardDetails = [SELECT Id FROM genesis__Rate_Card_Setup_Detail__c WHERE genesis__Rate_Card_Setup_Header__c =: rateCardObj.id AND Special_Term_Reference__c = :PortalConstants.SPECIAL_TERM_A LIMIT 1];
        for(genesis__Rate_Card_Setup_Detail__c rObj : rateCardDetails){
            rateCardDetailsObj = rObj;
        }
        requestMap.put('objectName', 'specialTermInterest');
        requestMap.put('recordId', String.valueOf(rateCardDetailsObj.Id));
        System.runAs(userObj) {
            Test.startTest();
            PortalGenericDeleteAPI testApi = new PortalGenericDeleteAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Rate card details deletion failed');
            Test.stopTest();
        }
    }

    //Deleting Rate Card on B for covering the shift validation
    @isTest
    public static void testRateCardDetailsTermReferenceBDeletion() {
        Map<String, Object> requestMap = new Map<String, Object>();

        Account accountObj;
        User userObj;
        genesis__rate_card_setup_header__c  rateCardObj;
        genesis__Rate_Card_Setup_Detail__c rateCardDetailsObj;
        List<Account> accountList = [SELECT Id FROM Account WHERE RecordType.Name = 'CERTIFIED LENDER' LIMIT 1];
        if(accountList.size()==1){
            accountObj = accountList[0];
        }
        List<User> userList = [SELECT Id FROM User WHERE Contact.AccountId =: accountObj.id LIMIT 1];
        userObj = userList[0];
        
        List<genesis__rate_card_setup_header__c> rateCardList = [SELECT Id FROM genesis__rate_card_setup_header__c LIMIT 1];
        for(genesis__rate_card_setup_header__c rObj : rateCardList){
            rateCardObj = rObj;
        }
        List<genesis__Rate_Card_Setup_Detail__c> rateCardDetails = [SELECT Id,Special_Term_Reference__c FROM genesis__Rate_Card_Setup_Detail__c WHERE genesis__Rate_Card_Setup_Header__c =: rateCardObj.id AND Special_Term_Reference__c = :PortalConstants.SPECIAL_TERM_B LIMIT 1];
        for(genesis__Rate_Card_Setup_Detail__c rObj : rateCardDetails){
            rateCardDetailsObj = rObj;
        }
        requestMap.put('objectName', 'specialTermInterest');
        requestMap.put('recordId', String.valueOf(rateCardDetailsObj.Id));
        System.runAs(userObj) {
            Test.startTest();
            PortalGenericDeleteAPI testApi = new PortalGenericDeleteAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Rate card details deletion failed');
            Test.stopTest();
        }
    }
    /**
    * @description test bank account deletion
    * @author Soumik Pattanayak | 23-12-2024 
    **/
    @isTest
    public static void testBankAccountDeletion() {
        
         Map<String, Object> requestMap = new Map<String, Object>();
         clcommon__Bank_Account__c bankAccountObj;
         User userObj;
         Account accountObj;
         List<Account> accountList = [SELECT Id FROM Account WHERE RecordType.Name = 'CERTIFIED LENDER' LIMIT 1];
        if(accountList.size()==1){
            accountObj = accountList[0];
        }
        List<User> userList = [SELECT Id FROM User WHERE Contact.AccountId =: accountObj.id LIMIT 1];
        userObj = userList[0];
        
        List<clcommon__Bank_Account__c> bankAccountList = [SELECT Id FROM clcommon__Bank_Account__c LIMIT 1];
        if(bankAccountList.size()==1){
            bankAccountObj = bankAccountList[0];
        }

        requestMap.put('objectName', 'bankAccount');
        requestMap.put('recordId', String.valueOf(bankAccountObj.Id));
        System.runAs(userObj){
            Test.startTest();
            PortalGenericDeleteAPI testApi = new PortalGenericDeleteAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Bank Account deletion failed');
            Test.stopTest();
        }
    }
    /**
    * @description test funding transaction deletion
    * @author Soumik Pattanayak | 23-12-2024 
    **/
    @isTest
    public static void testFundingTransactionDeletion() {
        Account accountObj;
        Map<String, Object> requestMap = new Map<String, Object>();
        User userObj;
        genesis__Funding_Transaction__c fundingTransactionObj;
        List<Account> accountList = [SELECT Id FROM Account WHERE RecordType.Name = 'CERTIFIED LENDER' LIMIT 1];
        if(accountList.size()==1){
            accountObj = accountList[0];
        }
        List<User> userList = [SELECT Id FROM User WHERE Contact.AccountId =: accountObj.id LIMIT 1];
        userObj = userList[0];
        
        List<genesis__Funding_Transaction__c> fundingTransactionList = [SELECT Id FROM genesis__Funding_Transaction__c LIMIT 1 ];
        for(genesis__Funding_Transaction__c fundingTransac : fundingTransactionList){
            fundingTransactionObj = fundingTransac;
        }
        requestMap.put('objectName', 'fundingTransaction');
        requestMap.put('recordId', fundingTransactionObj.Id);
        userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        System.runAs(userObj){
            Test.startTest();
            PortalGenericDeleteAPI testApi = new PortalGenericDeleteAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Funding Transaction deletion failed');
            Test.stopTest();
        }
        
    }

    //Test Deleting Payments
    @isTest
    public static void testPaymentDeletion() {
        Map<String, Object> requestMap = new Map<String, Object>();
        User userObj;
        genesis__Applications__c applicationObj;
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                            Certified_Lender__c
                                                            FROM genesis__Applications__c LIMIT 1];
        applicationObj = applicationList[0];
        
        List<User> userList = [SELECT Id FROM User WHERE Contact.AccountId =: applicationObj.Certified_Lender__c LIMIT 1];
        userObj = userList[0];
        
        //Database.update(fundingTransactionList,true);
        requestMap.put('objectName', 'fundingTransaction');
        requestMap.put('multipleDelete',True);
        requestMap.put('applicationId',applicationObj.Id);
        requestMap.put('recordId', 'PAYMENT');
        userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        //System.debug('---->'+applicationObj.id+' '+paymentModeObj.Name);
        System.runAs(userObj){
            Test.startTest();
            PortalGenericDeleteAPI testApi = new PortalGenericDeleteAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Payment deletion failed');
            Test.stopTest();
        }
    }
    /**
    * @description test collateral deletion
    * @author Soumik Pattanayak | 23-12-2024 
    **/
    @isTest
    public static void testCollateralDelete() {
       
        Map<String, Object> requestMap = new Map<String, Object>();
        clcommon__collateral__c collateralObj;
        User userObj;
        genesis__Applications__c applicationObj;
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                            Certified_Lender__c
                                                            FROM genesis__Applications__c LIMIT 1];
        applicationObj = applicationList[0];
        
        List<User> userList = [SELECT Id FROM User WHERE Contact.AccountId =: applicationObj.Certified_Lender__c LIMIT 1];
        userObj = userList[0];
        
        List<clcommon__collateral__c> collateralList = [SELECT Id FROM clcommon__collateral__c WHERE genesis__Application__c =: applicationObj.id  LIMIT 1];
        for(clcommon__collateral__c coObj : collateralList){
            collateralObj = coObj;
        }
        requestMap.put('objectName', 'collateral');
        requestMap.put('recordId', collateralObj.Id);
        System.runAs(userObj){
            Test.startTest();
            PortalGenericDeleteAPI testApi = new PortalGenericDeleteAPI();
            clcommon.Response response = testApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Collateral deletion failed');
            Test.stopTest();
        }
    }
}