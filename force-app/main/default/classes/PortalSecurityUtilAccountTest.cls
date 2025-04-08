/**
 * @description       : This is a test class for PortalSecutityUtil covers the account related methods
 * @author            : Suraj Kumar 
 * @createdDate       : 09-03-2024
 * @group             : 
 * @last modified on  : 27-01-2025
 * @last modified by  : Soumik Pattanayak
**/
@IsTest
public with sharing class PortalSecurityUtilAccountTest {
    @TestSetup
    static void setup() {

        // Object List declarations
        List<clcommon__Party_Type__c> partyTypeList;
        List<Account> accountList;
        List<Contact> contactList;
        List<User> userList;
        List<Dealer_Applicant_Relationship__c> relationList;
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


        Dealer_Applicant_Relationship__c borrowerRelationObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(borrowerContactObj, dealerAccountObj.Id);
        Dealer_Applicant_Relationship__c principalRelationObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(principalContactObj, dealerAccountObj.Id);
        relationList = new List<Dealer_Applicant_Relationship__c>{
            borrowerRelationObj,
            principalRelationObj
        };
        Database.Insert(relationList, true);

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
            'dealerApplicantRelationshipId' => principalRelationObj.Id
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
    * @author Soumik Pattanayak | 11-01-2025 
    * @return User 
    **/
    private static User getCLUser(){
        return [SELECT Id, 
                        Name, 
                        AccountId, 
                        Account.ParentId 
                FROM User 
                WHERE UserName='ross.geller@yopmail.com'][0];
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 11-01-2025 
    * @return genesis__Applications__c 
    **/
    private static genesis__Applications__c getApplication(){
        return [SELECT Id, 
                        genesis__Status__c,
                        Sales_Agent__c,
                        genesis__Contact__c
                FROM genesis__Applications__c 
                WHERE genesis__Loan_Number__c = '300023456'
                LIMIT 1][0];
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 11-01-2025 
    * @return User 
    **/
    private static User getGuestUser(){
        return [SELECT Id, Name, AccountId, Account.ParentId FROM User WHERE Profile.Name = 'Growmark Dealer Portal Profile'][0];
    }

    /**
    * @description : method to test validateUserApplicationByAccount , passing application id as null
    * @author Suraj Kumar | 09-03-2024 
    **/
    @IsTest
    private static void testValidateUserApplicationByAccountNullAppId() { 
        User certifiedLenderUserObj = getCLUser();
        Account accObj = [SELECT Id, Name, RecordType.Name, ParentId,clcommon__Email__c FROM Account WHERE clcommon__Email__c='jasmin.albin@yopmail.com' LIMIT 1];

        System.runAs(certifiedLenderUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateUserApplicationByAccount(null, accObj.Id);
            System.assertEquals(false, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description : method to test validateUserApplicationByAccount , passing account id as null
    * @author Suraj Kumar | 09-03-2024 
    **/
    @IsTest
    private static void testValidateUserApplicationByAccountIdNull() { 
        User certifiedLenderUserObj = getCLUser();
        genesis__Applications__c applicationObj = getApplication();

        System.runAs(certifiedLenderUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateUserApplicationByAccount(applicationObj.Id, null);
            System.assertEquals(false, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description : method to test validateUserApplicationByAccount having no party of that account on application
    * @author Suraj Kumar | 09-03-2024 
    **/
    @IsTest
    private static void testValidateUserApplicationByAccountPartyNull() { 
        User certifiedLenderUserObj = getCLUser();
        Account accObj = [SELECT Id, Name, RecordType.Name, ParentId,clcommon__Email__c FROM Account WHERE clcommon__Email__c='jasmin.albin@yopmail.com' LIMIT 1];
        genesis__Applications__c applicationObj = getApplication();
        List<clcommon__Party__c> applicationParties = [SELECT Id,
                                                                genesis__Application__c
                                                            FROM clcommon__Party__c
                                                            WHERE genesis__Application__c = :applicationObj.Id
                                                            AND clcommon__Account__c = :accObj.Id];
        applicationParties[0].genesis__Application__c = null;
        Database.update(applicationParties,true);

        System.runAs(certifiedLenderUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateUserApplicationByAccount(applicationObj.Id, accObj.Id);
            System.assertEquals(false, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description : method to test validateUserApplicationByAccount as a guest user
    * @author Suraj Kumar | 09-03-2024 
    **/
    @IsTest
    private static void testValidateUserApplicationByAccountGuestUser() { 
        User guestUserObj = getGuestUser();
        Account accObj = [SELECT Id, Name, RecordType.Name, ParentId,clcommon__Email__c FROM Account WHERE clcommon__Email__c='jasmin.albin@yopmail.com' LIMIT 1];
        genesis__Applications__c applicationObj = getApplication();

        System.runAs(guestUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateUserApplicationByAccount(applicationObj.Id, accObj.Id);
            System.assertEquals(false, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateUserBusinessInformation where Business Info id is blank
    * @author Suraj Kumar | 09-03-2024 
    **/
    @IsTest
    private static void testValidateUserBInfoBlank() {
        User certifiedLenderUserObj = getCLUser();
        Account dealerAcc = [SELECT Id, Name, RecordType.Name, ParentId FROM Account WHERE Name = 'Kisan Loan'];

        System.runAs(certifiedLenderUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateUserBusinessInformation('', dealerAcc.Id);
            System.assertEquals(false, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateUserBusinessInformation where account id is blank
    * @author Suraj Kumar | 09-03-2024 
    **/
    @IsTest
    private static void testValidateUserBInfoAccIdBlank() {
        User certifiedLenderUserObj = getCLUser();
        genesis__Business_Information__c businessInfo = [SELECT Id, Name,genesis__Tax_Identification_Number__c FROM genesis__Business_Information__c WHERE genesis__Tax_Identification_Number__c = '666899905'];

        System.runAs(certifiedLenderUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateUserBusinessInformation(businessInfo.Id, '');
            System.assertEquals(false, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateUserBusinessInformation as a guest user
    * @author Suraj Kumar | 09-03-2024 
    **/
    @IsTest
    private static void testValidateUserBInfoGuestUser() {
        User guestUserObj = getGuestUser();
        Account dealerAcc = [SELECT Id, Name, RecordType.Name, ParentId FROM Account WHERE Name = 'Kisan Loan'];
        genesis__Business_Information__c businessInfo = [SELECT Id, Name,genesis__Tax_Identification_Number__c FROM genesis__Business_Information__c WHERE genesis__Tax_Identification_Number__c = '666899905'];

        System.runAs(guestUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateUserBusinessInformation(businessInfo.Id, dealerAcc.Id);
            System.assertEquals(false, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateUserBusinessInformation where Business Info does not belongs to that account
    * @author Suraj Kumar | 09-03-2024 
    **/
    @IsTest
    private static void testValidateUserBInfoOtherAcc() {
        User certifiedLenderUserObj = getCLUser();
        genesis__Business_Information__c businessInfo = [SELECT Id, Name,genesis__Tax_Identification_Number__c FROM genesis__Business_Information__c WHERE genesis__Tax_Identification_Number__c = '666899905'];

        System.runAs(certifiedLenderUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateUserBusinessInformation(businessInfo.Id, null);
            System.assertEquals(false, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description : method to test validateUserApplicationByBusinessAccount for other application id blank
    * @author Suraj Kumar | 09-03-2024 
    **/
    @IsTest
    private static void testValidateUserAppByBAccAppIdBlank() {
        User certifiedLenderUserObj = getCLUser();
        Account borrowerAccountObj = [SELECT Id, Name, RecordType.Name, ParentId FROM Account WHERE Name = 'Jasmine Albin' LIMIT 1];

        System.runAs(certifiedLenderUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateUserApplicationByBusinessAccount('', borrowerAccountObj.Id);
            System.assertEquals(false, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }
    /**
    * @description : method to test validateUserApplicationByBusinessAccount for other account id blank
    * @author Suraj Kumar | 09-03-2024 
    **/
    @IsTest
    private static void testValidateUserAppByBAccIdBlank() {
        User certifiedLenderUserObj = getCLUser();
        genesis__Applications__c applicationObj = getApplication();

        System.runAs(certifiedLenderUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateUserApplicationByBusinessAccount(applicationObj.Id, '');
            System.assertEquals(false, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }
    /**
    * @description : method to test validateUserApplicationByBusinessAccount as a guest user
    * @author Suraj Kumar | 09-03-2024 
    **/
    @IsTest
    private static void testValidateUserAppByBAccGuestUser() {
        User guestUserObj = getGuestUser();
        Account borrowerAccountObj = [SELECT Id, Name, RecordType.Name, ParentId FROM Account WHERE Name = 'Jasmine Albin' LIMIT 1];
        genesis__Applications__c applicationObj = getApplication();

        System.runAs(guestUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateUserApplicationByBusinessAccount(applicationObj.Id, borrowerAccountObj.Id);
            System.assertEquals(false, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }
    /**
    * @description : method to test validateUserApplicationByBusinessAccount for other account id
    * @author Suraj Kumar | 09-03-2024 
    **/
    @IsTest
    private static void testValidateUserAppByBAccOther() {
        User certifiedLenderUserObj = getCLUser();
        genesis__Applications__c applicationObj = getApplication();

        System.runAs(certifiedLenderUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateUserApplicationByBusinessAccount(applicationObj.Id, certifiedLenderUserObj.AccountId);
            System.assertEquals(false, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description : method to test validateDealerByAccount for blank account id
    * @author Suraj Kumar | 09-03-2024 
    **/
    @IsTest
    private static void testValidateDealerByAccountIdBlank() {
        User clUserObj = getCLUser();

        System.runAs(clUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateDealerByAccount(null);
            System.assertEquals(false, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description : method to test validateDealerByAccount for login user does not have relationship with dealer
    * @author Suraj Kumar | 09-03-2024 
    **/
    @IsTest
    private static void testValidateDealerByAccountOther() {
        User guestUserObj = getGuestUser();
        Account dealerAccountObj = [SELECT Id, 
                                           Name
                                    FROM Account 
                                    WHERE Name = 'Kisan Loan'];

        System.runAs(guestUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateDealerByAccount(dealerAccountObj.Id);
            System.assertEquals(false, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test for validateRateCardDetailByDealer for blank dealer id
    * @author Suraj Kumar | 09-03-2024 
    **/
    @IsTest
    private static void testValidateRateCardDetailByDealerIdBlank() {
        User certifiedLenderUserObj = getCLUser();
        genesis__Rate_Card_Setup_Header__c rateCardHeader = [SELECT Id, Name FROM genesis__Rate_Card_Setup_Header__c WHERE Name = 'My Test Program 99'];

        System.runAs(certifiedLenderUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateRateCardDetailByDealer('', rateCardHeader.Id);
            System.assertEquals(false, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test for validateRateCardDetailByDealer for blank my program id
    * @author Suraj Kumar | 09-03-2024 
    **/
    @IsTest
    private static void testValidateRateCardDetailByMyProgIdBlank() {
        User certifiedLenderUserObj = getCLUser();
        Account dealerAcc = [SELECT Id, Name, RecordType.Name, ParentId FROM Account WHERE Name = 'Kisan Loan'];

        System.runAs(certifiedLenderUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateRateCardDetailByDealer(dealerAcc.Id, '');
            System.assertEquals(false, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test validateRateCardDetailByDealer for other dealer 
    * @author Suraj Kumar | 09-03-2024 
    **/
    @IsTest
    private static void testValidateRateCardDetailByOtherDealer() {
        User certifiedLenderUserObj = getCLUser();
        genesis__Rate_Card_Setup_Header__c rateCardHeader = [SELECT Id, Name FROM genesis__Rate_Card_Setup_Header__c WHERE Name = 'My Test Program 99'];

        System.runAs(certifiedLenderUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateRateCardDetailByDealer('1234', rateCardHeader.Id);
            System.assertEquals(false, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateCoApplicantBusinessInfo
    * @author Suraj Kumar | 09-03-2024 
    **/
    @IsTest
    private static void testValidateCoApplicantBusinessInfo() {
        User certifiedLenderUserObj = getCLUser();

        Account accountObj = [SELECT Id, Name, genesis__Business_Information__r.Id FROM Account WHERE Name = 'Kisan Loan'];
        List<Account> accountVSBusinessInfoList = new List<Account>{accountObj};
        Map<Id, Id> businessInfoVSAccIdMap = new Map<Id, Id> ();
        businessInfoVSAccIdMap.put(accountObj.genesis__Business_Information__r.Id,accountObj.Id);

        System.runAs(certifiedLenderUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateCoApplicantBusinessInfo(accountVSBusinessInfoList, businessInfoVSAccIdMap);
            System.assertEquals(true, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateCoApplicantBusinessInfo, businessInfoVSAccIdMap empty
    * @author Suraj Kumar | 09-03-2024 
    **/
    @IsTest
    private static void testValidateCoApplicantBInfoMapEmpty() {
        User certifiedLenderUserObj = getCLUser();

        Account accountObj = [SELECT Id, Name, RecordType.Name, ParentId FROM Account WHERE Name = 'Kisan Loan'];

        List<Account> accountVSBusinessInfoList = new List<Account>{accountObj};
        Map<Id, Id> businessInfoVSAccIdMap = new Map<Id, Id> ();

        System.runAs(certifiedLenderUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateCoApplicantBusinessInfo(accountVSBusinessInfoList, businessInfoVSAccIdMap);
            System.assertEquals(false, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateCoApplicantBusinessInfo, as a Guest user
    * @author Suraj Kumar | 09-03-2024 
    **/
    @IsTest
    private static void testValidateCoApplicantBInfoGuestUser() {
        User guestUserObj = getGuestUser();

        Account accountObj = [SELECT Id, Name, RecordType.Name, ParentId FROM Account WHERE Name = 'Kisan Loan'];
        genesis__Business_Information__c businessInfoObj = [SELECT Id, Name,genesis__Tax_Identification_Number__c FROM genesis__Business_Information__c WHERE genesis__Tax_Identification_Number__c = '666899905'];

        List<Account> accountVSBusinessInfoList = new List<Account>{accountObj};
        Map<Id, Id> businessInfoVSAccIdMap = new Map<Id, Id> ();
        businessInfoVSAccIdMap.put(businessInfoObj.Id,accountObj.Id);

        System.runAs(guestUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateCoApplicantBusinessInfo(accountVSBusinessInfoList, businessInfoVSAccIdMap);
            System.assertEquals(false, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test validateCoApplicantBusinessInfo, as a standard user
    * @author Suraj Kumar | 09-03-2024 
    **/
    @IsTest
    private static void testValidateCoApplicantBInfoStdUser() {
        User stdUserObj = [SELECT Id FROM User WHERE UserName='std.user@yopmail.com'];

        Account accountObj = [SELECT Id, Name,genesis__Business_Information__r.Id FROM Account WHERE Name = 'Kisan Loan'];

        List<Account> accountVSBusinessInfoList = new List<Account>{accountObj};
        Map<Id, Id> businessInfoVSAccIdMap = new Map<Id, Id> ();
        businessInfoVSAccIdMap.put(accountObj.genesis__Business_Information__r.Id,accountObj.Id);

        System.runAs(stdUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateCoApplicantBusinessInfo(accountVSBusinessInfoList, businessInfoVSAccIdMap);
            System.assertEquals(true, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateCoApplicantBusinessInfo, Business Info does not belongs to that account
    * @author Suraj Kumar | 09-03-2024 
    **/
    @IsTest
    private static void testValidateCoApplicantBInfoOher() {
        User certifiedLenderUserObj = getCLUser();

        Account accountObj = [SELECT Id, Name, RecordType.Name, ParentId FROM Account WHERE Name = 'Kisan Loan'];
        genesis__Business_Information__c businessInfoObj = [SELECT Id, Name,genesis__Tax_Identification_Number__c FROM genesis__Business_Information__c WHERE genesis__Tax_Identification_Number__c = '666899905'];

        List<Account> accountVSBusinessInfoList = new List<Account>{accountObj};
        Map<Id, Id> businessInfoVSAccIdMap = new Map<Id, Id> ();
        businessInfoVSAccIdMap.put(businessInfoObj.Id,certifiedLenderUserObj.AccountId);

        System.runAs(certifiedLenderUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateCoApplicantBusinessInfo(accountVSBusinessInfoList, businessInfoVSAccIdMap);
            System.assertEquals(false, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateCoApplicantAccount, account id null
    * @author Suraj Kumar | 09-03-2024 
    **/
    @IsTest
    private static void testValidateCoAppAccIdNull() {
        User certifiedLenderUserObj = getCLUser();
        Account accountObj =[SELECT Id, Name, RecordType.Name, ParentId FROM Account WHERE Name = 'Jasmine Albin' LIMIT 1];
        Map<Id,clcommon__Party__c> accountIdvsPartyMap;
        genesis__Applications__c applicationObj = getApplication();
        clcommon__Party__c partyObj = [SELECT Id, Name FROM clcommon__Party__c WHERE genesis__Application__c =:applicationObj.Id LIMIT 1];

        accountIdvsPartyMap = new Map<Id, clcommon__party__c>{
            accountObj.Id => partyObj
        };

        System.runAs(certifiedLenderUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateCoApplicantAccount('', accountIdvsPartyMap);
            System.assertEquals(false, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test validateCoApplicantAccount, accountIdvsPartyMap empty
    * @author Suraj Kumar | 09-03-2024 
    **/
    @IsTest
    private static void testValidateCoAppAccMapEmpty() {
        User certifiedLenderUserObj = getCLUser();
        Account accountObj =[SELECT Id, Name, RecordType.Name, ParentId FROM Account WHERE Name = 'Jasmine Albin' LIMIT 1];
        Map<Id,clcommon__Party__c> accountIdvsPartyMap = new Map<Id, clcommon__party__c>();

        System.runAs(certifiedLenderUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateCoApplicantAccount(accountObj.Id, accountIdvsPartyMap);
            System.assertEquals(false, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }
    /**
    * @description ; Method to test validateCoApplicantAccount, as a guest user
    * @author Suraj Kumar | 09-03-2024 
    **/
    @IsTest
    private static void testValidateCoAppAccGuestUser() {
        User guestUserObj = getGuestUser();
        Account accountObj =[SELECT Id, Name, RecordType.Name, ParentId FROM Account WHERE Name = 'Jasmine Albin' LIMIT 1];
        Map<Id,clcommon__Party__c> accountIdvsPartyMap;
        genesis__Applications__c applicationObj = getApplication();
        clcommon__Party__c partyObj = [SELECT Id, Name FROM clcommon__Party__c WHERE genesis__Application__c =:applicationObj.Id LIMIT 1];

        accountIdvsPartyMap = new Map<Id, clcommon__party__c>{
            accountObj.Id => partyObj
        };

        System.runAs(guestUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateCoApplicantAccount(accountObj.Id, accountIdvsPartyMap);
            System.assertEquals(false, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateCoApplicantAccount, account id not belongs to map
    * @author Suraj Kumar | 09-03-2024 
    **/
    @IsTest
    private static void testValidateCoAppAccOther() {
        User certifiedLenderUserObj = getCLUser();
        Account accountObj =[SELECT Id, Name, RecordType.Name, ParentId FROM Account WHERE Name = 'Jasmine Albin' LIMIT 1];
        Map<Id,clcommon__Party__c> accountIdvsPartyMap;
        genesis__Applications__c applicationObj = getApplication();
        clcommon__Party__c partyObj = [SELECT Id, Name FROM clcommon__Party__c WHERE genesis__Application__c =:applicationObj.Id LIMIT 1];

        accountIdvsPartyMap = new Map<Id, clcommon__party__c>{
            certifiedLenderUserObj.Id => partyObj
        };

        System.runAs(certifiedLenderUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateCoApplicantAccount(accountObj.Id, accountIdvsPartyMap);
            System.assertEquals(false, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateCollteralByApplication 
    * @author Suraj Kumar | 09-07-2024 
    **/
    @IsTest
    private static void testValidateCollteralByApplication() {
        User certifiedLenderUserObj = getCLUser();
        genesis__Applications__c applicationObj = getApplication();
    
        
        clcommon__collateral__c collateralObj = [SELECT Id,clcommon__Collateral_Name__c FROM clcommon__collateral__c WHERE genesis__Application__c= :applicationObj.Id];

        System.runAs(certifiedLenderUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateCollteralByApplication(applicationObj.Id, collateralObj.Id);
            System.assertEquals(true, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test validateCollteralByApplication for Blank Application Id
    * @author Suraj Kumar | 09-07-2024 
    **/
    @IsTest
    private static void testValidateCollteralAppIdBlank() {
        User certifiedLenderUserObj = getCLUser();
        genesis__Applications__c applicationObj = getApplication();
    
        
        clcommon__collateral__c collateralObj = [SELECT Id,clcommon__Collateral_Name__c FROM clcommon__collateral__c WHERE genesis__Application__c= :applicationObj.Id];

        System.runAs(certifiedLenderUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateCollteralByApplication(null, collateralObj.Id);
            System.assertEquals(false, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateCollteralByApplication for Blank Collateral Id
    * @author Suraj Kumar | 09-07-2024 
    **/
    @IsTest
    private static void testValidateCollteralIdBlank() {
        User certifiedLenderUserObj = getCLUser();
        genesis__Applications__c applicationObj = getApplication();

        System.runAs(certifiedLenderUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateCollteralByApplication(applicationObj.Id, null);
            System.assertEquals(false, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateCollteralByApplication as a guest user
    * @author Suraj Kumar | 09-07-2024 
    **/
    @IsTest
    private static void testValidateCollteralByApplicationGuestUser() {
        User guestUserObj = getGuestUser();
        genesis__Applications__c applicationObj = getApplication();
    
        
        clcommon__collateral__c collateralObj = [SELECT Id,clcommon__Collateral_Name__c FROM clcommon__collateral__c WHERE genesis__Application__c= :applicationObj.Id];

        System.runAs(guestUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateCollteralByApplication(applicationObj.Id, collateralObj.Id);
            System.assertEquals(false, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test validateCollteralsObj for not matching Collateral Id
    * @author Suraj Kumar | 09-07-2024 
    **/
    @IsTest 
    private static void testvalidateCollteralsObjNotExist(){
        List<String> collateralIdsList = new List<String>();
        String collateralId; 
        User clUserObj = getCLUser();
        clcommon__collateral__c collateralObj = [SELECT Id,
                                                        clcommon__Collateral_Name__c 
                                                    FROM clcommon__collateral__c 
                                                    WHERE clcommon__Collateral_Name__c='commodity'];
        collateralId = collateralObj.Id;
        System.runAs(clUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateCollteralsObj(collateralIdsList,collateralId);
            System.assertEquals(false, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateCollteralsObj for Collateral Id blank
    * @author Suraj Kumar | 09-07-2024 
    **/
    @IsTest 
    private static void testvalidateCollteralsObjIdBlank(){
        List<String> collateralIdsList = new List<String>();
        String collateralId; 
        User clUserObj = getCLUser();
        clcommon__collateral__c collateralObj = [SELECT Id,
                                                        clcommon__Collateral_Name__c 
                                                    FROM clcommon__collateral__c 
                                                    WHERE clcommon__Collateral_Name__c='commodity'];
        collateralId = collateralObj.Id;
        collateralIdsList.add(collateralId);
        System.runAs(clUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateCollteralsObj(collateralIdsList,null);
            System.assertEquals(false, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description : Method to validateCollteralsObj as a guest user
    * @author Suraj Kumar | 09-07-2024 
    **/
    @IsTest 
    private static void testvalidateCollteralsObjGuestUser(){
        List<String> collateralIdsList = new List<String>();
        String collateralId; 
        User guestUserObj = getGuestUser();
        clcommon__collateral__c collateralObj = [SELECT Id,
                                                        clcommon__Collateral_Name__c 
                                                    FROM clcommon__collateral__c 
                                                    WHERE clcommon__Collateral_Name__c='commodity'];
        collateralId = collateralObj.Id;
        collateralIdsList.add(collateralId);
        System.runAs(guestUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateCollteralsObj(collateralIdsList,collateralId);
            System.assertEquals(false, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }
}