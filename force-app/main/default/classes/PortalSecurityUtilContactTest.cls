/**
 * @description       : This is a test class for PortalSecutityUtil covers the Contact related methods
 * @author            : Suraj Kumar 
 * @createdDate       : 09-03-2024
 * @group             : 
 * @last modified on  : 12-01-2025
 * @last modified by  : Soumik Pattanayak
**/
@IsTest
private with sharing class PortalSecurityUtilContactTest {
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

        Dealer_Applicant_Relationship__c borrowerRelationObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(borrowerContactObj,dealerAccountObj.Id);
        Dealer_Applicant_Relationship__c coBorrowerRelationObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(principalContactObj,dealerAccountObj.Id);
        Database.insert(new List<Dealer_Applicant_Relationship__c>{borrowerRelationObj, coBorrowerRelationObj}, true);

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
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 12-01-2025 
    * @return genesis__Applications__c 
    **/
    private static genesis__Applications__c getApplication(){
        return [SELECT Id, 
                    genesis__Status__c,
                    Sales_Agent__c,
                    genesis__Contact__c
                FROM genesis__Applications__c 
                WHERE genesis__Loan_Number__c = '300023456'][0];
    }

    /**
    * @description 
    * @author Soumik Pattanayak | 12-01-2025 
    * @return User 
    **/
    private static User getUser(){
        return [SELECT Id, Name, AccountId, contactId, Account.ParentId FROM User WHERE UserName='ross.geller@yopmail.com'][0];
    }

    /**
    * @description : Method to test validateUserBorrowerContactByApplication Blank app Id
    * @author Suraj Kumar | 09-03-2024 
    **/
    @IsTest
    private static void testValidateUserBorrowerContactByApplicationBlankAppId() { 
        User objCertifiedLenderUser = getUser();
        Contact contactObj = [SELECT Id, Name, LastName, FirstName, Email FROM Contact WHERE Email='jasmin.albin@yopmail.com'][0];

        System.runAs(objCertifiedLenderUser) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateUserBorrowerContactByApplication('', contactObj.Id);
            System.assertEquals(false, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateUserBorrowerContactByApplication contact id blank
    * @author Suraj Kumar | 09-03-2024 
    **/
    @IsTest
    private static void testValidateUserBorrowerContactByApplicationContIdBlank() { 
        User objCertifiedLenderUser = getUser();
        genesis__Applications__c applicationObj = getApplication();

        System.runAs(objCertifiedLenderUser) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateUserBorrowerContactByApplication(applicationObj.Id, '');
            System.assertEquals(false, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test validateUserBorrowerContactByApplication as a guest user
    * @author Suraj Kumar | 09-03-2024 
    **/
    @IsTest
    private static void testValidateUserBorrowerContactByApplicationGuestUser() { 
        User guestUserObj = [SELECT Id, Name, AccountId, Account.ParentId FROM User WHERE Profile.Name ='Growmark Dealer Portal Profile'];
        Contact contactObj = [SELECT Id, Name, LastName, FirstName, Email FROM Contact WHERE Email='jasmin.albin@yopmail.com'][0];
        genesis__Applications__c applicationObj = getApplication();

        System.runAs(guestUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateUserBorrowerContactByApplication(applicationObj.Id, contactObj.Id);
            System.assertEquals(false, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateUserBorrowerContactByApplication for Other contact ID
    * @author Suraj Kumar | 09-03-2024 
    **/
    @IsTest
    private static void testValidateUserBorrowerContactByApplicationOtherCont() { 
        User clUserObj = getUser();
        genesis__Applications__c applicationObj = getApplication();

        System.runAs(clUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateUserBorrowerContactByApplication(applicationObj.Id, clUserObj.ContactId);
            System.assertEquals(false, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validatePrincipalContact
    * @author Suraj Kumar | 09-03-2024 
    **/
    @IsTest
    private static void testValidatePrincipalContact() { 
        User clUserObj = getUser();
        genesis__Applications__c applicationObj = getApplication();
        List<clcommon__Party__c> applicationParties = [SELECT Id,
                                                                clcommon__Contact__c
                                                            FROM clcommon__Party__c
                                                            WHERE genesis__Application__c = :applicationObj.Id
                                                            AND clcommon__Type__r.Name =: PortalConstants.PRINCIPAL_PARTY_NAME];

        System.runAs(clUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validatePrincipalContact(applicationObj.Id, applicationParties[0].clcommon__Contact__c);
            System.assertEquals(true, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }
    /**
    * @description : Method to test validatePrincipalContact for other contact 
    * @author Suraj Kumar | 09-03-2024 
    **/
    @IsTest
    private static void testValidatePrincipalContactOther() { 
        User clUserObj = getUser();
        genesis__Applications__c applicationObj = getApplication();

        System.runAs(clUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validatePrincipalContact(applicationObj.Id, clUserObj.ContactId);
            System.assertEquals(false, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validatePrincipalContact as a guest user
    * @author Suraj Kumar | 09-03-2024 
    **/
    @IsTest
    private static void testValidatePrincipalContactGuestUser() { 
        User guestUserObj = [SELECT Id, Name, AccountId, Account.ParentId FROM User WHERE Profile.Name ='Growmark Dealer Portal Profile'];
        genesis__Applications__c applicationObj = getApplication();
        List<clcommon__Party__c> applicationParties = [SELECT Id,
                                                                clcommon__Contact__c
                                                            FROM clcommon__Party__c
                                                            WHERE genesis__Application__c = :applicationObj.Id
                                                            AND clcommon__Type__r.Name =: PortalConstants.PRINCIPAL_PARTY_NAME];

        System.runAs(guestUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validatePrincipalContact(applicationObj.Id, applicationParties[0].clcommon__Contact__c);
            System.assertEquals(false, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validatePrincipalContact Contact id blank
    * @author Suraj Kumar | 09-03-2024 
    **/
    @IsTest
    private static void testValidatePrincipalContactIdBlank() { 
        User clUserObj = getUser();
        genesis__Applications__c applicationObj = getApplication();

        System.runAs(clUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validatePrincipalContact(applicationObj.Id, '');
            System.assertEquals(false, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validatePrincipalContact AppId blank
    * @author Suraj Kumar | 09-03-2024 
    **/
    @IsTest
    private static void testValidatePrincipalContactAppIdBlank() { 
        User clUserObj = getUser();
        genesis__Applications__c applicationObj = getApplication();
        List<clcommon__Party__c> applicationParties = [SELECT Id,
                                                                clcommon__Contact__c
                                                            FROM clcommon__Party__c
                                                            WHERE genesis__Application__c = :applicationObj.Id
                                                            AND clcommon__Type__r.Name =: PortalConstants.PRINCIPAL_PARTY_NAME];

        System.runAs(clUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validatePrincipalContact('', applicationParties[0].clcommon__Contact__c);
            System.assertEquals(false, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description : Method to validateCoApplicantContact
    * @author Suraj Kumar | 09-03-2024 
    **/
    @IsTest
    private static void testValidateCoApplicantContact() {
        User clUserObj = getUser();
        Contact contactObj = [SELECT Id FROM Contact WHERE Name = 'Jasmine Albin'][0];
        clcommon__Party__c partyObj = [SELECT Id FROM clcommon__Party__c][0];
        Map<Id,clcommon__Party__c> contactIdvsPartyMap = new Map<Id, clcommon__party__c>();
        contactIdvsPartyMap.put(contactObj.Id, partyObj);

        System.runAs(clUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateCoApplicantContact(contactObj.Id, contactIdvsPartyMap);
            System.assertEquals(true, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }
    /**
    * @description : Method to validateCoApplicantContact for party don't belongs to that contact
    * @author Suraj Kumar | 09-03-2024 
    **/
    @IsTest
    private static void testValidateCoApplicantContactOther() {
        User clUserObj = getUser();
        Contact contactObj = [SELECT Id FROM Contact WHERE Name = 'Jasmine Albin'][0];
        clcommon__Party__c partyObj = [SELECT Id FROM clcommon__Party__c][0];
        Map<Id,clcommon__Party__c> contactIdvsPartyMap = new Map<Id, clcommon__party__c>();
        contactIdvsPartyMap.put(clUserObj.Id, partyObj);

        System.runAs(clUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateCoApplicantContact(contactObj.Id, contactIdvsPartyMap);
            System.assertEquals(false, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }
    /**
    * @description : Method to validateCoApplicantContact as a guest user
    * @author Suraj Kumar | 09-03-2024 
    **/
    @IsTest
    private static void testValidateCoApplicantContactGuestUser() {
        User guestUserObj = [SELECT Id, Name, AccountId, Account.ParentId FROM User WHERE Profile.Name ='Growmark Dealer Portal Profile'];
        Contact contactObj = [SELECT Id FROM Contact WHERE Name = 'Jasmine Albin'][0];
        clcommon__Party__c partyObj = [SELECT Id FROM clcommon__Party__c][0];
        Map<Id,clcommon__Party__c> contactIdvsPartyMap = new Map<Id, clcommon__party__c>();
        contactIdvsPartyMap.put(contactObj.Id, partyObj);

        System.runAs(guestUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateCoApplicantContact(contactObj.Id, contactIdvsPartyMap);
            System.assertEquals(false, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description : Method to validateCoApplicantContact for contact Id null
    * @author Suraj Kumar | 09-03-2024 
    **/
    @IsTest
    private static void testValidateCoApplicantContactIdNull() {
        User clUserObj = getUser();
        Contact contactObj = [SELECT Id FROM Contact WHERE Name = 'Jasmine Albin'][0];
        clcommon__Party__c partyObj = [SELECT Id FROM clcommon__Party__c][0];
        Map<Id,clcommon__Party__c> contactIdvsPartyMap = new Map<Id, clcommon__party__c>();
        contactIdvsPartyMap.put(contactObj.Id, partyObj);

        System.runAs(clUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateCoApplicantContact('', contactIdvsPartyMap);
            System.assertEquals(false, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }
    /**
    * @description : Method to validateCoApplicantContact for contactIdvsPartyMap null
    * @author Suraj Kumar | 09-03-2024 
    **/
    @IsTest
    private static void testValidateCoApplicantContactMapNull() {
        User clUserObj = getUser();
        Contact contactObj = [SELECT Id FROM Contact WHERE Name = 'Jasmine Albin'][0];
        Map<Id,clcommon__Party__c> contactIdvsPartyMap = new Map<Id, clcommon__party__c>();

        System.runAs(clUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateCoApplicantContact(contactObj.Id, contactIdvsPartyMap);
            System.assertEquals(false, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateGrowerWithDealer , where contact id null
    * @author Suraj Kumar | 09-03-2024 
    **/
    @IsTest
    private static void testvalidateGrowerWithDealerContactIdNull() {
        String result;
        User clUserObj = getUser();
        
        System.runAs(clUserObj) {
            Test.startTest();
            // Calling  the API
            try{
                PortalSecurityUtil.validateGrowerWithDealer('');
            }catch(Exception exceptionObj){
                result = exceptionObj.getMessage();
            }
            System.assertEquals(PortalConstants.USER_NOT_AUTHORISED, result, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : Method to test validateGrowerWithDealer
    * @author Suraj Kumar | 09-03-2024 
    **/
    @IsTest
    private static void testvalidateGrowerWithDealer() {
        String result;
        User clUserObj = getUser();
        Contact contactObj = [SELECT Id FROM Contact WHERE Account.Name = 'Jasmine Albin'][0];

        System.runAs(clUserObj) {
            Test.startTest();
            // Calling  the API
            try{
                PortalSecurityUtil.validateGrowerWithDealer(contactObj.Id);
            }catch(Exception exceptionObj){
                result = exceptionObj.getMessage();
            }
            System.assertEquals(null, result, PortalConstants.ASSERTION_FAILED);
            Test.stopTest();
        }
    }

    /**
    * @description : test validatePrincipalParty 
    * @author Suraj Kumar | 09-07-2024 
    **/
    @IsTest
    private static void testValidatePrincipalParty() {
        User clUserObj = getUser();
        genesis__Applications__c applicationObj = getApplication();
        clcommon__Party__c partyObj = [SELECT Id, 
                                                Name 
                                            FROM clcommon__Party__c 
                                            WHERE genesis__Application__c =:applicationObj.Id 
                                            AND clcommon__Type__r.Name =: PortalConstants.PRINCIPAL_PARTY_NAME
                                           ][0];

        System.runAs(clUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validatePrincipalParty(applicationObj.Id, partyObj.Id);
            System.assertEquals(true, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description : test validatePrincipalParty for party is not of principal type
    * @author Suraj Kumar | 09-07-2024 
    **/
    @IsTest
    private static void testNotPrincipalParty() {
        User clUserObj = getUser();
        genesis__Applications__c applicationObj = getApplication();
        clcommon__Party__c partyObj = [SELECT Id, 
                                                Name 
                                            FROM clcommon__Party__c 
                                            WHERE genesis__Application__c =:applicationObj.Id 
                                            AND clcommon__Type__r.Name !=: PortalConstants.PRINCIPAL_PARTY_NAME
                                           ][0];

        System.runAs(clUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validatePrincipalParty(applicationObj.Id, partyObj.Id);
            System.assertEquals(false, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }
    /**
    * @description : test validatePrincipalParty for app id blank
    * @author Suraj Kumar | 09-07-2024 
    **/
    @IsTest
    private static void testPrincipalPartyAppIdBlank() {
        User clUserObj = getUser();
        genesis__Applications__c applicationObj = getApplication();
        clcommon__Party__c partyObj = [SELECT Id, Name FROM clcommon__Party__c WHERE genesis__Application__c =:applicationObj.Id][0];

        System.runAs(clUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validatePrincipalParty(null, partyObj.Id);
            System.assertEquals(false, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }
    /**
    * @description : test validatePrincipalParty for party id blank
    * @author Suraj Kumar | 09-07-2024 
    **/
    @IsTest
    private static void testValidatePrincipalPartyIdBlank() {
        User clUserObj = getUser();
        genesis__Applications__c applicationObj = getApplication();

        System.runAs(clUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validatePrincipalParty(applicationObj.Id, null);
            System.assertEquals(false, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }
    /**
    * @description : test validatePrincipalParty as a guest user
    * @author Suraj Kumar | 09-07-2024 
    **/
    @IsTest
    private static void testValidatePrincipalPartyGuestUser() {
        User guestUserObj = [SELECT Id, Name, AccountId, Account.ParentId FROM User WHERE Profile.Name ='Growmark Dealer Portal Profile'];
        genesis__Applications__c applicationObj = getApplication();
        clcommon__Party__c partyObj = [SELECT Id, 
                                                Name 
                                            FROM clcommon__Party__c 
                                            WHERE genesis__Application__c =:applicationObj.Id 
                                            AND clcommon__Type__r.Name =: PortalConstants.PRINCIPAL_PARTY_NAME
                                           ][0];

        System.runAs(guestUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validatePrincipalParty(applicationObj.Id, partyObj.Id);
            System.assertEquals(false, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }
    /**
    * @description : method to test validateCoApplicantParty
    * @author Suraj Kumar | 09-07-2024 
    **/
    @IsTest 
    private static void testValidateCoApplicantParty(){
        User clUserObj = getUser();
        clcommon__Party__c partyObj = [SELECT Id FROM clcommon__Party__c][0];
        Map<Id,clcommon__Party__c> partyIdvsPartyMap = new Map<Id, clcommon__Party__c>{
            partyObj.Id => partyObj
        };
        System.runAs(clUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateCoApplicantParty(partyObj.Id, partyIdvsPartyMap);
            System.assertEquals(true, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }
    /**
    * @description : method to test validateCoApplicantParty for not matching party id
    * @author Suraj Kumar | 09-07-2024 
    **/
    @IsTest 
    private static void testValidateCoApplicantPartyNotExist(){
        User clUserObj = getUser();
        clcommon__Party__c partyObj = [SELECT Id FROM clcommon__Party__c][0];
        System.runAs(clUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateCoApplicantParty(partyObj.Id, null);
            System.assertEquals(false, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description : method to test validateCoApplicantParty for blank party id
    * @author Suraj Kumar | 09-07-2024 
    **/
    @IsTest 
    private static void testValidateCoApplicantPartyIdBlank(){
        User clUserObj = getUser();
        clcommon__Party__c partyObj = [SELECT Id FROM clcommon__Party__c][0];
        Map<Id,clcommon__Party__c> partyIdvsPartyMap = new Map<Id, clcommon__Party__c>{
            partyObj.Id => partyObj
        };
        System.runAs(clUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateCoApplicantParty(null, partyIdvsPartyMap);
            System.assertEquals(false, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }
    /**
    * @description : method to test validateCoApplicantParty as a guest user
    * @author Suraj Kumar | 09-07-2024 
    **/
    @IsTest 
    private static void testValidateCoApplicantPartyGuestUser(){
        User guestUserObj = [SELECT Id, Name, AccountId, Account.ParentId FROM User WHERE Profile.Name ='Growmark Dealer Portal Profile'];
        clcommon__Party__c partyObj = [SELECT Id FROM clcommon__Party__c][0];
        Map<Id,clcommon__Party__c> partyIdvsPartyMap = new Map<Id, clcommon__Party__c>{
            partyObj.Id => partyObj
        };
        System.runAs(guestUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateCoApplicantParty(partyObj.Id, partyIdvsPartyMap);
            System.assertEquals(false, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }

    /**
    * @description : method to test validateCoApplicantParty as a std user
    * @author Suraj Kumar | 09-07-2024 
    **/
    @IsTest 
    private static void testValidateCoApplicantPartyStdUser(){
        User stdUserObj = [SELECT Id FROM User WHERE UserName='std.user@yopmail.com'];
        clcommon__Party__c partyObj = [SELECT Id FROM clcommon__Party__c][0];
        Map<Id,clcommon__Party__c> partyIdvsPartyMap = new Map<Id, clcommon__Party__c>{
            stdUserObj.Id => partyObj
        };
        System.runAs(stdUserObj) {
            Test.startTest();
            // Calling  the API
            Boolean res = PortalSecurityUtil.validateCoApplicantParty(partyObj.Id, partyIdvsPartyMap);
            System.assertEquals(true, res, PortalConstants.ASSERTION_FAILED); 
            Test.stopTest();
        }
    }
}