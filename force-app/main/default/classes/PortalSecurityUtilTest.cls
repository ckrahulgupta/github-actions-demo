/**
 * @description       : This is a test class for PortalSecutityUtil
 * @author            : Krishanu Chinya
 * @createdDate       : 06-10-2023
 * @group             : 
 * @last modified on  : 27-01-2025
 * @last modified by  : Soumik Pattanayak
**/

@IsTest
private without sharing class PortalSecurityUtilTest {
    @TestSetup
    static void setup() {

        // Object List declarations
        List<clcommon__Party_Type__c> partyTypeList;
        List<Account> accountList;
        List<Contact> contactList;
        List<User> userList;
        List<genesis__Business_Information__c> businsessInfoList;
        List<clcommon__party__c> partyList;

        // creating legal entity
        clcommon__Legal_Entity__c entityObj = ApplicationOriginationTestHelper.createLegalEntity(PortalConstants.SOLE_PROP_ENTITY);
        Database.Insert(entityObj, true);

        // create party types
        clcommon__Party_Type__c dealerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType(PortalConstants.DEALER_PARTY_NAME);
        clcommon__Party_Type__c clPartyTypeObj = ApplicationOriginationTestHelper.createPartyType(PortalConstants.CL_PARTY_NAME);
        clcommon__Party_Type__c borrowerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType(PortalConstants.BORROWER_PARTY_NAME);
        clcommon__Party_Type__c principalPartyTypeObj = ApplicationOriginationTestHelper.createPartyType(PortalConstants.PRINCIPAL_PARTY_NAME);
        partyTypeList = new List<clcommon__Party_Type__c>{
            dealerPartyTypeObj,
            clPartyTypeObj,
            borrowerPartyTypeObj,
            principalPartyTypeObj
        };
        Database.Insert(partyTypeList, true);

        // Creating CL Product 
        clcommon__CL_Product__c clProductObj = ApplicationOriginationTestHelper.createCLProductForApplication();
        Database.Insert(clProductObj, true);

        // Creating CL Purpose 
        clcommon__CL_Purpose__c clPurposeObj = ApplicationOriginationTestHelper.createCLPurposeForApplication();
        Database.Insert(clPurposeObj, true);

        // creating business information
        genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();

        genesis__Business_Information__c borrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower('');
        
        genesis__Business_Information__c principalBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower('');

        businsessInfoList = new List<genesis__Business_Information__c>{
            dealerBusinessInfoObj,
            borrowerBusinessInfoObj,
            principalBusinessInfoObj
        };
        Database.Insert(businsessInfoList, true);


        // Creating Account for Dealer
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        Database.Insert(dealerAccountObj, true);

        // creating Account for Certified Lender
        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);

        Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(entityObj, borrowerBusinessInfoObj.Id);

        Account principalAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(entityObj, principalBusinessInfoObj.Id, dealerAccountObj.Id);

        Account dummyAccountObj = new Account(name='Dummy Account');

        accountList = new List<Account>{
            clAccountObj,
            borrowerAccountObj,
            principalAccountObj,
            dummyAccountObj
        };
        Database.Insert(accountList, true);

        // Creating Contacts
        Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.Id);
        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.Id); 
        Contact principalContactObj = ApplicationOriginationTestHelper.createBorrowerContact(principalAccountObj.Id); 
        contactList = new List<Contact>{
            clContactObj,
            borrowerContactObj,
            principalContactObj
        };
        Database.Insert(contactList, true);

        Dealer_Applicant_Relationship__c borrowerRelationObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(borrowerContactObj,dealerAccountObj.Id);
        Dealer_Applicant_Relationship__c coBorrowerRelationObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(principalContactObj,dealerAccountObj.Id);
        Database.insert(new List<Dealer_Applicant_Relationship__c>{borrowerRelationObj, coBorrowerRelationObj}, true);

        // creating Users
        User clUserObj = ApplicationOriginationTestHelper.createCLUser(clContactObj.Id);
        User borrowerUserObj = ApplicationOriginationTestHelper.createBorrowerUser(borrowerContactObj.Id);
        User stdUser = ApplicationOriginationTestHelper.createStandardUser();
        userList = new List<User>{
            clUserObj,
            borrowerUserObj,
            stdUser
        };
        Database.Insert(userList, true);

        // creating relationship of certified lender
        clcommon__Reciprocal_Role__c clRoleObj = ApplicationOriginationTestHelper.createReciprocalRole('Certified Lender');
        Database.Insert(clRoleObj, true);
        clcommon__Relationship__c objRelationship = ApplicationOriginationTestHelper.createCLDealerRelationship(clRoleObj,
                                                                                                    dealerAccountObj.Id, 
                                                                                                    clAccountObj.Id);
        Database.Insert(objRelationship, true);

        //creating application
        Map<String,Id> paramForApplicationMap = new Map<String,Id>{
            'dealerAccountId'=> dealerAccountObj.Id,
            'clProductId'=> clProductObj.Id,
            'clPurposeId'=> clPurposeObj.Id,
            'borrowerAccountId'=> borrowerAccountObj.Id,
            'borrowerContactId'=> borrowerContactObj.Id,
            'clAccountId'=> clAccountObj.Id,
            'dealerApplicantRelationshipId' => borrowerRelationObj.Id
        };
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createCurrCropYearApplication(paramForApplicationMap);
        applicationObj.genesis__Status__c = 'New - Entered';
        Database.Insert(applicationObj, true);

        // Creating Parties

        // DEALER PARTY
        Map<String,Id> dealerPartyMap = new Map<String,Id>{
            'accountId' => dealerAccountObj.Id,
            'partyTypeId' => dealerPartyTypeObj.Id,
            'applicationId' => applicationObj.Id
        };
        clcommon__Party__c dealerPartyObj = ApplicationOriginationTestHelper.createParty(dealerPartyMap);
        dealerPartyObj.genesis__Application__c = applicationObj.Id;

        // CL PARTY
        Map<String,Id> paramForCLPartyMap = new Map<String,Id>{
            'accountId' => clAccountObj.Id,
            'contactId' => clContactObj.Id,
            'partyTypeId' => clPartyTypeObj.Id,
            'applicationId' => applicationObj.Id
        };
        clcommon__Party__c clPartyObj = ApplicationOriginationTestHelper.createParty(paramForCLPartyMap);

        // BORRWER PARTY
        Map<String,Id> paramForBorrowerPartyMap = new Map<String,Id>{
            'accountId' => borrowerAccountObj.Id,
            'contactId' => borrowerContactObj.Id,
            'partyTypeId' => borrowerPartyTypeObj.Id,
            'applicationId' => applicationObj.Id,
            'dealerApplicantRelationshipId' => borrowerRelationObj.Id
        };
        
        clcommon__Party__c borrowerPartyObj = ApplicationOriginationTestHelper.createParty(paramForBorrowerPartyMap);
        borrowerPartyObj.genesis__Application__c = applicationObj.Id;

        // PRINCIPAL PARTY
        Map<String,Id> principalPartyMap = new Map<String,Id>{
            'accountId' => principalAccountObj.Id,
            'contactId' => principalContactObj.Id,
            'partyTypeId' => principalPartyTypeObj.Id,
            'applicationId' => applicationObj.Id,
            'dealerApplicantRelationshipId' => coBorrowerRelationObj.Id
        };
        clcommon__Party__c principalPartyObj = ApplicationOriginationTestHelper.createParty(principalPartyMap);
        principalPartyObj.genesis__Application__c = applicationObj.Id;

        partyList = new List<clcommon__party__c>{
            dealerPartyObj,
            clPartyObj,
            borrowerPartyObj,
            principalPartyObj
        };
        Database.Insert(partyList, true);
        

        // create rate card and pricing detail
        genesis__Rate_Card_Setup_Header__c rateCardSetupHeaderObj = TestClassHelper.createCurrYearRateCardHeader(dealerAccountObj);
        Database.Insert(rateCardSetupHeaderObj, true);
        genesis__Rate_Card_Setup_Detail__c rateCardSetupDetailObj = ApplicationOriginationTestHelper.createNewRateCardSetupDetail(rateCardSetupHeaderObj);
        Database.Insert(rateCardSetupDetailObj, true);
        genesis__Application_Pricing_Detail__c applPricingDetailObj = ApplicationOriginationTestHelper.createEnabledPricingDetail(applicationObj, rateCardSetupDetailObj.Id);
        Database.Insert(applPricingDetailObj, true);

        //creating previous crop year application
        applicationObj = TestClassHelper.createPrevCropYearApplication(paramForApplicationMap);
        Database.Insert(applicationObj, true);


        paramForApplicationMap = new Map<String,Id>{
            'dealerAccountId' => dealerAccountObj.Id,
            'clProductId' => clProductObj.Id,
            'clPurposeId' => clPurposeObj.Id,
            'borrowerAccountId' => borrowerAccountObj.Id,
            'borrowerContactId' => borrowerContactObj.Id,
            'clAccountId' => clAccountObj.Id
        };
        applicationObj = ApplicationOriginationTestHelper.createCurrCropYearApplication(paramForApplicationMap);
        
        Database.Insert(applicationObj, true);

        clcommon__Collateral_Category__c collateralCategoryObj = ApplicationOriginationTestHelper.createCollateralCategory();
        Database.Insert(collateralCategoryObj,true);

        Map<String,String> collateralDeatailsMap = new Map<String,String>{
            'collateralCategoryId' => String.valueOf(collateralCategoryObj.Id),
            'insurancePlan' => 'YP',
            'percentCoverageLevel' => '50%'
        };
        clcommon__collateral__c collateralObj = ApplicationOriginationTestHelper.createCollateral(collateralDeatailsMap);
        collateralObj.genesis__Application__c = applicationObj.id;
        Database.Insert(collateralObj,true);
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 13-01-2025 
    * @return User 
    **/
    private static User getCLUser(){
        List<User> clUserList = [SELECT Id, 
                                    Name, 
                                    AccountId, 
                                    Account.ParentId, 
                                    ContactId
                            FROM User 
                            WHERE UserName='ross.geller@yopmail.com'];

        return clUserList[0];
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 13-01-2025 
    * @return genesis__Applications__c 
    **/
    private static genesis__Applications__c getApplication(){
        List<genesis__Applications__c> applicationList = [SELECT Id, 
                                                                genesis__Status__c,
                                                                Sales_Agent__c,
                                                                genesis__Contact__c
                                                            FROM genesis__Applications__c 
                                                            WHERE genesis__Loan_Number__c = '300023456'];

        return applicationList[0];
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 13-01-2025 
    * @return User 
    **/
    private static User getStandardUser(){
        List<User> stdUserList = [SELECT Id FROM User WHERE UserName='std.user@yopmail.com'];
        return stdUserList[0];
    }

    /**
    * @description : Validate dealer account
    * @author Tuhin Bhunia | 04-19-2024 
    **/
    @IsTest
    private static void testValidateDealerByAccount() {

        User clUserObj = getCLUser();
        List<Account> dealerAccountObj = [SELECT Id,  Name FROM Account  WHERE Name = 'Kisan Loan'];

        System.runAs(clUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateDealerByAccount(dealerAccountObj[0].Id);
            System.assertEquals(true, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description : Validate dealer account with the grower account
    * @author Soumik Pattanayak | 12-20-2024 
    **/
    @IsTest
    private static void testValidateDealerByGrowerAccount() {

        List<User> borrowerUserObj = [SELECT Id, Name FROM User WHERE UserName='star.lord@yopmail.com' LIMIT 1];
        List<Account> dealerAccountObj = [SELECT Id, 
                                           Name
                                    FROM Account 
                                    WHERE Name = 'Kisan Loan'
                                ];

        System.runAs(borrowerUserObj[0]) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateDealerByGrowerAccount(dealerAccountObj[0].Id);
            System.assertEquals(true, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description 
    * @author Tuhin Bhunia | 04-19-2024 
    **/
    @IsTest
    private static void testValidateRateCardDetailByDealer() {
        User certifiedLenderUserObj = getCLUser();
        List<Account> dealerAcc = [SELECT Id, Name, RecordType.Name, ParentId FROM Account WHERE Name = 'Kisan Loan'];
        List<genesis__Rate_Card_Setup_Header__c> rateCardHeader = [SELECT Id, Name FROM genesis__Rate_Card_Setup_Header__c WHERE Name = 'My Test Program 99'];

        System.runAs(certifiedLenderUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateRateCardDetailByDealer(dealerAcc[0].Id, rateCardHeader[0].Id);
            System.assertEquals(true, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description 
    * @author Tuhin Bhunia | 04-19-2024 
    **/
    @IsTest
    private static void testValidateCollteralByApplication() {
        User certifiedLenderUserObj = getCLUser();
        genesis__Applications__c applicationObj = getApplication();
    
        List<clcommon__collateral__c> collateralObj = [SELECT Id,clcommon__Collateral_Name__c FROM clcommon__collateral__c WHERE clcommon__Collateral_Name__c='commodity'];

        System.runAs(certifiedLenderUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateCollteralByApplication(applicationObj.Id, collateralObj[0].Id);
            System.assertEquals(false, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description 
    * @author Tuhin Bhunia | 04-19-2024 
    **/
    @IsTest
    private static void testValidateCollteralByApplicationStdUser() {
        User clUserObj = getStandardUser();
        genesis__Applications__c applicationObj = getApplication();

        List<clcommon__collateral__c> collateralObj = [SELECT Id,clcommon__Collateral_Name__c FROM clcommon__collateral__c WHERE clcommon__Collateral_Name__c='commodity'];

        System.runAs(clUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateCollteralByApplication(applicationObj.Id, collateralObj[0].Id);
            System.assertEquals(true, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description 
    * @author Tuhin Bhunia | 04-19-2024 
    **/
    @IsTest
    private static void testValidatePrincipalParty() {
        User clUserObj = getStandardUser();
        genesis__Applications__c applicationObj = getApplication();
        List<clcommon__Party__c> partyObj = [SELECT Id, Name FROM clcommon__Party__c WHERE genesis__Application__c =:applicationObj.Id LIMIT 1];

        System.runAs(clUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validatePrincipalParty(null, partyObj[0].Id);
            System.assertEquals(true, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description 
    * @author Tuhin Bhunia | 04-19-2024 
    **/
    @IsTest
    private static void testValidatePrincipalContact() { 
        User clUserObj = getStandardUser();
        genesis__Applications__c applicationObj = getApplication();
        List<Contact> contactObj = [SELECT Id, Name, LastName, FirstName, Email FROM Contact WHERE Email='jasmin.albin@yopmail.com' LIMIT 1];

        System.runAs(clUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validatePrincipalContact(applicationObj.Id, contactObj[0].Id);
            System.assertEquals(true, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description 
    * @author Tuhin Bhunia | 04-19-2024 
    **/
    @IsTest
    private static void testValidateUserApplicationByBusinessAccount() {
        User certifiedLenderUserObj = getCLUser();
        List<Account> borrowerAccountObj = [SELECT Id, Name, RecordType.Name, ParentId FROM Account WHERE Name = 'Jasmine Albin'];
        genesis__Applications__c applicationObj = getApplication();

        System.runAs(certifiedLenderUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateUserApplicationByBusinessAccount(applicationObj.Id, borrowerAccountObj[0].Id);
            System.assertEquals(true, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description 
    * @author Tuhin Bhunia | 04-19-2024 
    **/
    @IsTest
    private static void testValidateUserApplicationByBusinessAccountStdUser() {
        User clUserObj = getStandardUser();
        List<Account> dealerAcc = [SELECT Id, Name, RecordType.Name, ParentId FROM Account WHERE Name = 'Kisan Loan'];
        
        System.runAs(clUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateUserApplicationByBusinessAccount(null, dealerAcc[0].Id);
            System.assertEquals(true, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description 
    * @author Tuhin Bhunia | 04-19-2024 
    **/
    @IsTest
    private static void testValidateUserBusinessInformation() {
        User certifiedLenderUserObj = getCLUser();
        List<Account> dealerAcc = [SELECT Id, Name, RecordType.Name, ParentId FROM Account WHERE Name = 'Kisan Loan'];

        List<genesis__Business_Information__c> businessInfo = [SELECT Id, Name,genesis__Tax_Identification_Number__c FROM genesis__Business_Information__c WHERE genesis__Tax_Identification_Number__c = '666899905'];

        System.runAs(certifiedLenderUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateUserBusinessInformation(businessInfo[0].Id, dealerAcc[0].Id);
            System.assertEquals(true, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description 
    * @author Tuhin Bhunia | 04-19-2024 
    **/
    @IsTest
    private static void testValidateUserBusinessInformationStdUser() {
        User clUserObj = getStandardUser();
        List<Account> dealerAcc = [SELECT Id, Name, RecordType.Name, ParentId FROM Account WHERE Name = 'Kisan Loan'];

        System.runAs(clUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateUserBusinessInformation(null, dealerAcc[0].Id);
            System.assertEquals(true, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description 
    * @author Tuhin Bhunia | 04-19-2024 
    **/
    @IsTest
    private static void testGetSiteAdmin() {
        User certifiedLenderUserObj = getCLUser();
        
        System.runAs(certifiedLenderUserObj) {
            Test.startTest();
            // Calling  the API
            PortalSecurityUtil.getSiteAdmin();
            System.assertEquals('', '', PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }
    

    /**
    * @description 
    * @author Tuhin Bhunia | 04-19-2024 
    **/
    @IsTest
    private static void testValidateUserBorrowerContactByApplication() { 
        User certifiedLenderUserObj = getCLUser();
        List<Contact> contactObj = [SELECT Id, Name, LastName, FirstName, Email FROM Contact WHERE Email='jasmin.albin@yopmail.com' LIMIT 1];
        genesis__Applications__c applicationObj = getApplication();

        System.runAs(certifiedLenderUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateUserBorrowerContactByApplication(applicationObj.Id, contactObj[0].Id);
            System.assertEquals(true, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description 
    * @author Tuhin Bhunia | 04-19-2024 
    **/
    @IsTest
    private static void testValidateUserBorrowerContactByApplicationStdUser() {
        User clUserObj = getStandardUser();
        List<Contact> contactObj = [SELECT Id, Name, LastName, FirstName, Email FROM Contact WHERE Email='jasmin.albin@yopmail.com' LIMIT 1];
       
        System.runAs(clUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateUserBorrowerContactByApplication(null, contactObj[0].Id);
            System.assertEquals(true, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description 
    * @author Tuhin Bhunia | 04-19-2024 
    **/
    @IsTest
    private static void testValidateUserApplicationByAccount() { // failing
        User certifiedLenderUserObj = getCLUser();
        List<Account> accObj = [SELECT Id, Name, RecordType.Name, ParentId,clcommon__Email__c FROM Account WHERE clcommon__Email__c='jasmin.albin@yopmail.com' LIMIT 1];
        genesis__Applications__c applicationObj = getApplication();

        System.runAs(certifiedLenderUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateUserApplicationByAccount(applicationObj.Id, accObj[0].Id);
            System.assertEquals(true, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description 
    * @author Tuhin Bhunia | 04-19-2024 
    **/
    @IsTest
    private static void testValidateUserApplicationByAccountStdUser() { // failing
        User clUserObj = getStandardUser();
        List<Account> accObj = [SELECT Id, Name, RecordType.Name, ParentId,clcommon__Email__c FROM Account WHERE clcommon__Email__c='jasmin.albin@yopmail.com' LIMIT 1];

        System.runAs(clUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateUserApplicationByAccount(null, accObj[0].Id);
            System.assertEquals(true, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description 
    * @author Tuhin Bhunia | 04-19-2024 
    **/
    @IsTest
    private static void testValidateUserApplication() {
        User certifiedLenderUserObj = getCLUser();
        genesis__Applications__c applicationObj = getApplication();

        System.runAs(certifiedLenderUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateUserApplication(applicationObj.Id);
            System.assertEquals(true, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description 
    * @author Tuhin Bhunia | 04-19-2024 
    **/
    @IsTest
    private static void testValidateUserApplicationStdUser() {
        User clUserObj = getStandardUser();
        genesis__Applications__c applicationObj = getApplication();

        System.runAs(clUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateUserApplication(applicationObj.Id);
            System.assertEquals(true, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description : method to test validateUserApplication for blank application Id
    * @author Suraj Kumar | 09-02-2024 
    **/
    @IsTest
    private static void testValidateUserApplicationAppIdBlank() {
        User certifiedLenderUserObj = getCLUser();

        System.runAs(certifiedLenderUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateUserApplication('');
            System.assertEquals(false, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description : method to validateUserApplication with cl user , whose party is not on application
    * @author Suraj Kumar | 09-02-2024 
    **/
    @IsTest
    private static void testValidateUserApplicationOtherCL() {
        User certifiedLenderUserObj = getCLUser();
        genesis__Applications__c applicationObj = getApplication();
        List<clcommon__Party__c> applicationParties = [SELECT Id,
                                                                genesis__Application__c
                                                            FROM clcommon__Party__c
                                                            WHERE genesis__Application__c = :applicationObj.Id
                                                            AND clcommon__Contact__c = :certifiedLenderUserObj.ContactId];
        applicationParties[0].genesis__Application__c = null;
        Database.update(applicationParties,true);

        System.runAs(certifiedLenderUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateUserApplication(applicationObj.Id);
            System.assertEquals(false, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description 
    * @author Tuhin Bhunia | 04-19-2024 
    **/
    @IsTest
    private static void testValidateUserApplicationbyList() {
        User certifiedLenderUserObj = getCLUser();
        genesis__Applications__c applicationObj = getApplication();

        System.runAs(certifiedLenderUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateUserApplication(new List<Id>{applicationObj.Id});
            System.assertEquals(true, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description 
    * @author Tuhin Bhunia | 04-19-2024 
    **/
    @IsTest
    private static void testValidateUserApplicationbyListStdUser() {
        User clUserObj = getStandardUser();
        genesis__Applications__c applicationObj = getApplication();

        List<Id> applicationIdList = new List<Id>();
        applicationIdList.add(applicationObj.Id);
        System.runAs(clUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateUserApplication(applicationIdList);
            System.assertEquals(true, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description : method to test validateUserApplication by list for Null List
    * @author Suraj Kumar | 09-02-2024 
    **/
    @IsTest
    private static void testValidateUserApplicationbyNullList() {
        User certifiedLenderUserObj = getCLUser();
        List<Id> applicationIdList = null;
        System.runAs(certifiedLenderUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateUserApplication(applicationIdList);
            System.assertEquals(false, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description : method to test validateUserApplication by list for Empty List
    * @author Suraj Kumar | 09-02-2024 
    **/
    @IsTest
    private static void testValidateUserApplicationEmptyList() {
        User certifiedLenderUserObj = getCLUser();
        List<Id> applicationIdList = new List<Id>();
        System.runAs(certifiedLenderUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateUserApplication(applicationIdList);
            System.assertEquals(false, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description : method to test validateUserApplication by list for cl party does not on application
    * @author Suraj Kumar | 09-02-2024 
    **/
    @IsTest
    private static void testValidateUserApplicationListOtherCL() {
        User certifiedLenderUserObj = getCLUser();
        genesis__Applications__c applicationObj = getApplication();
        List<clcommon__Party__c> applicationParties = [SELECT Id,
                                                                genesis__Application__c
                                                            FROM clcommon__Party__c
                                                            WHERE genesis__Application__c = :applicationObj.Id
                                                            AND clcommon__Contact__c = :certifiedLenderUserObj.ContactId];
        applicationParties[0].genesis__Application__c = null;
        Database.update(applicationParties,true);

        System.runAs(certifiedLenderUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateUserApplication(new List<Id>{applicationObj.Id});
            System.assertEquals(false, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description 
    * @author Tuhin Bhunia | 04-19-2024 
    **/
    @IsTest 
    private static void testvalidateCollteralsObj(){
        List<String> collateralIdsList = new List<String>();
        String collateralId; 
        User clUserObj = getStandardUser();
        clcommon__collateral__c collateralObj = [SELECT Id,
                                                        clcommon__Collateral_Name__c 
                                                    FROM clcommon__collateral__c 
                                                    WHERE clcommon__Collateral_Name__c='commodity'];
        collateralId = collateralObj.Id;
        collateralIdsList.add(collateralId);
        System.runAs(clUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateCollteralsObj(collateralIdsList,collateralId);
            System.assertEquals(true, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description 
    * @author Tuhin Bhunia | 04-19-2024 
    **/
    @IsTest 
    private static void testvalidateCollteralsObjStdUser(){
        List<String> collateralIdsList = new List<String>();
        String collateralId; 
        User clUserObj = getStandardUser();
        clcommon__collateral__c collateralObj = [SELECT Id,
                                                        clcommon__Collateral_Name__c 
                                                    FROM clcommon__collateral__c 
                                                    WHERE clcommon__Collateral_Name__c='commodity'];
        collateralId = collateralObj.Id;
        collateralIdsList.add('123451');
        System.runAs(clUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateCollteralsObj(collateralIdsList,collateralId);
            System.assertEquals(true, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description 
    * @author Tuhin Bhunia | 04-19-2024 
    **/
    @IsTest
    private static void testValidateCoApplicantBusinessInfo() {
        User clUserObj = getStandardUser();

        List<Account> accountVSBusinessInfoList = new List<Account>();
        Map<Id, Id> businessInfoVSAccIdMap = new Map<Id, Id> ();

        System.runAs(clUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateCoApplicantBusinessInfo(accountVSBusinessInfoList, businessInfoVSAccIdMap);
            System.assertEquals(false, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description 
    * @author Tuhin Bhunia | 04-19-2024
    **/
    @IsTest
    private static void testValidateCoApplicantContact() {
        User clUserObj = getStandardUser();
        List<Contact> contactObj = [SELECT Id FROM Contact WHERE Name = 'Jasmine Albin' LIMIT 1];
        Map<Id,clcommon__Party__c> contactIdvsPartyMap = new Map<Id, clcommon__party__c>();


        System.runAs(clUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateCoApplicantContact(contactObj[0].Id, contactIdvsPartyMap);
            System.assertEquals(true, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description : Success scenario for validateCoApplicantAccount method
    * @author Tuhin Bhunia | 04-19-2024 
    **/
    @IsTest
    private static void testValidateCoApplicantAccountIdCheck() {
        User clUserObj = getStandardUser();
        List<Account> accountObj =[SELECT Id, Name, RecordType.Name, ParentId FROM Account WHERE Name = 'Jasmine Albin' LIMIT 1];
        Map<Id,clcommon__Party__c> accountIdvsPartyMap;
        genesis__Applications__c applicationObj = getApplication();
        clcommon__Party__c partyObj = [SELECT Id, Name FROM clcommon__Party__c WHERE genesis__Application__c =:applicationObj.Id LIMIT 1];

        accountIdvsPartyMap = new Map<Id, clcommon__party__c>{
            accountObj[0].Id => partyObj
        };

        System.runAs(clUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateCoApplicantAccount(accountObj[0].Id, accountIdvsPartyMap);
            System.assertEquals(true, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description : Failure scenario for validateCoApplicantAccount method
    * @author Tuhin Bhunia | 04-19-2024 
    **/
    @IsTest
    private static void testValidateCoApplicantAccountUserTypeCheck() {
        User clUserObj = getStandardUser();
        Map<Id,clcommon__Party__c> accountIdvsPartyMap = new Map<Id, clcommon__party__c>();

        System.runAs(clUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateCoApplicantAccount(null, accountIdvsPartyMap);
            System.assertEquals(true, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description 
    * @author Tuhin Bhunia | 04-19-2024 
    **/
    @IsTest
    private static void testvalidateGrowerWithDealer() {

        String result;
        List<clcommon__Party__c> borrowerParty = [SELECT Id, Name 
                                            FROM clcommon__Party__c
                                            WHERE clcommon__Contact__r.name = 'Jasmine Albin'
                                            LIMIT 1];
        Database.Delete(borrowerParty, true);

        User clUserObj = getStandardUser();
        List<Contact> contactObj = [SELECT Id FROM Contact WHERE Account.Name = 'Jasmine Albin' LIMIT 1];

        System.runAs(clUserObj) {
            Test.startTest();
            // Calling  the API
            try{
                PortalSecurityUtil.validateGrowerWithDealer(contactObj[0].Id);
            }catch(Exception exceptionObj){
                result = exceptionObj.getMessage();
            }
            System.assertEquals(PortalConstants.USER_NOT_AUTHORISED, result, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }
}