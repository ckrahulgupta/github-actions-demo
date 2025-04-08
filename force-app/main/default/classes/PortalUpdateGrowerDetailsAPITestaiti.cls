/**
 * @description       : test class for PortalUpdateGrowerDetailsAPI
 * @author            : Sk Minsar
 * @group             : 
 * @last modified on  : 07-24-2024
 * @last modified by  : Tuhin Bhunia
**/
@isTest
global without sharing class PortalUpdateGrowerDetailsAPITestaiti{
    @testSetup
    static void setup(){
        // creating business information
        genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        Database.insert(dealerBusinessInfoObj, true);
       
        // Creating floating rate inadex
        clcommon__Floating_Rate_Index__c floatingRateIndexObj = ApplicationOriginationTestHelper.createFloatingRateIndex(
            New Map<String, Object>{ 'Name' => 'CFA Advantage Rate',
                                        'Base Rate Name' => '4-CFA ADVANTAGE',
                                        'Current Floating Rate' => 11,
                                        'Base Rate Adjuster' => 5.5
        });
        Database.insert(floatingRateIndexObj, true);

        // Creating floating rate
        clcommon__Floating_Rate__c floatingRateObj = ApplicationOriginationTestHelper.createFloatingRate(floatingRateIndexObj);
        Database.insert(floatingRateObj, true);

        // Creating new partner program
        CFA_Partner_Program__c newPartnerProgramObj = ApplicationOriginationTestHelper.createPartnerProgram(floatingRateIndexObj);
        Database.insert(newPartnerProgramObj, true);
    
        // Creating Account for Dealer
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        dealerAccountObj.CFA_Partner_Program__c = newPartnerProgramObj.Id;
        Database.insert(dealerAccountObj, true);
    
        // creating Account for Certified Lender
        Account clAccountObj = TestClassHelper.createCLAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
        Database.insert(clAccountObj, true);

        // Creating Contact for Certified Lender
        Contact clContactObj = TestClassHelper.createCLContact(clAccountObj.Id);
        Database.insert(clContactObj, true);

        // creating user for certified lender
        User clUser = TestClassHelper.createCLUser(clContactObj.Id);
        Database.insert(clUser, true);

        clcommon__Reciprocal_Role__c clRole = ApplicationOriginationTestHelper.createCertifiedLenderRole();
        Database.insert(clRole,true);

        clcommon__Relationship__c clRelationship = ApplicationOriginationTestHelper.createCLDealerRelationship(clRole,dealerAccountObj.id,clAccountObj.id);
        Database.insert(clRelationship,true);

        clcommon__Legal_Entity__c legalEntityObj  = ApplicationOriginationTestHelper.createSolePropLegalEntity();
        Database.insert(legalEntityObj,true);

        genesis__Business_Information__c borrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        Database.insert(borrowerBusinessInfoObj,true);

        Account borrowerAccountObj = ApplicationOriginationTestHelper.createSolePropAccount(legalEntityObj,borrowerBusinessInfoObj.id);
        borrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Grower').getRecordTypeId();
        borrowerAccountObj.CIF_Number__c = '123456';
        borrowerAccountObj.ParentId = dealerAccountObj.Id;
        borrowerAccountObj.Coop_Type__c = 'CFA';
        Database.insert(borrowerAccountObj,true);

        clcommon__CL_Product__c clProductObj = ApplicationOriginationTestHelper.createCLProductForApplication();
        Database.insert(clProductObj,true);

        clcommon__CL_Purpose__c  clPurposeObj = ApplicationOriginationTestHelper.createCLPurpose();
        Database.insert(clPurposeObj,true);


        Contact borrowerContactObj = ApplicationOriginationTestHelper.createBorrowerContact(borrowerAccountObj.id);
        Database.insert(borrowerContactObj,true);

        Map<String,Id> applicationDataMap = new Map<String,Id>{
            'dealerAccountObjId' => dealerAccountObj.id,
            'clProductObjId' => clProductObj.id,
            'clPurposeObjId' => clPurposeObj.id,
            'borrowerAccountObjId' => borrowerAccountObj.id,
            'borrowerContactObjId' => borrowerContactObj.id,
            'clAccountObjId' => clAccountObj.id
        };
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createApplication(applicationDataMap);
        applicationObj.genesis__Product_Type__c ='Package';
        applicationObj.Crop_Year__c = String.valueOf(System.today().year());
        Database.insert(applicationObj,true); 

        clcommon__Party_Type__c clPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('CERTIFIED LENDER');
        Database.insert(clPartyTypeObj,true);

        clcommon__Party_Type__c borrowerPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('BORROWER');
        Database.insert(borrowerPartyTypeObj,true);


        Map<String,Id> partyParamMap = new Map<String,Id>{
            'accountId' => borrowerAccountObj.id,
            'contactId' => borrowerContactObj.id,
            'partyTypeId' => borrowerPartyTypeObj.id,
            'applicationId' => applicationObj.id
        };
        clcommon__Party__c partyObj = ApplicationOriginationTestHelper.createParty(partyParamMap);
        Database.insert(partyObj,true);

        Map<String,Id> clpartyParamMap = new Map<String,Id>{
            'accountId' => clAccountObj.id,
            'contactId' => clContactObj.id,
            'partyTypeId' => clPartyTypeObj.id,
            'applicationId' => applicationObj.id
        };
        clcommon__Party__c clPartyObj = ApplicationOriginationTestHelper.createParty(clpartyParamMap);
        clPartyObj.clcommon__Party_Types__c = PortalConstants.CERTIFIED_LENDER;
        Database.insert(clPartyObj,true);

        //creating corporation account, contact
        genesis__Business_Information__c corpBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        Database.insert(corpBusinessInfoObj,true);

        clcommon__Legal_Entity__c corpLegalEntityObj  = ApplicationOriginationTestHelper.createCorporationLegalEntity();
        Database.insert(corpLegalEntityObj,true);

        Account corporationAccount = ApplicationOriginationTestHelper.createCorporationAccount(corpLegalEntityObj, corpBusinessInfoObj.Id, dealerAccountObj.Id);
        Database.insert(corporationAccount,true);

        Contact corporationContact = ApplicationOriginationTestHelper.createCorporationContact(corporationAccount.Id);
        Database.insert(corporationContact,true);

        genesis__Applications__c corporationApp = ApplicationOriginationTestHelper.createApplication(new Map<String,Id>{
                                        'dealerAccountObjId' => dealerAccountObj.id,
                                        'clProductObjId' => clProductObj.id,
                                        'clPurposeObjId' => clPurposeObj.id,
                                        'borrowerAccountObjId' => corporationAccount.id,
                                        'borrowerContactObjId' => corporationContact.id,
                                        'clAccountObjId' => clAccountObj.id
                                    });
                                    corporationApp.genesis__Product_Type__c ='Package';
        Database.insert(corporationApp,true); 

        clcommon__Party__c borrowerPartyObj = ApplicationOriginationTestHelper.createParty(new Map<String,Id>{
            'accountId' => corporationAccount.id,
            'contactId' => corporationContact.id,
            'partyTypeId' => borrowerPartyTypeObj.id,
            'applicationId' => corporationApp.id
        });
        Database.insert(borrowerPartyObj,true);


        clPartyObj = ApplicationOriginationTestHelper.createParty(new Map<String,Id>{
            'accountId' => clAccountObj.id,
            'contactId' => clContactObj.id,
            'partyTypeId' => clPartyTypeObj.id,
            'applicationId' => corporationApp.id
        });
        clPartyObj.clcommon__Party_Types__c = PortalConstants.CERTIFIED_LENDER;
        Database.insert(clPartyObj,true);

        //create parties 
        createCoBorrowerParty(legalEntityObj,applicationObj);

        CFA_Configuration__c credentialParameter = ApplicationOriginationTestHelper.createEmailChangeDecryptionConfig();
        Database.insert(credentialParameter,true);
    }

    /**
    * @description - This method is used to help 
    * @author Sk Minsar | 05-17-2024 
    * @param legalEntityObj 
    * @param applicationObj 
    **/
    private static void createCoBorrowerParty(clcommon__Legal_Entity__c legalEntityObj, genesis__Applications__c applicationObj){
        // Creating CoBorrower
        genesis__Business_Information__c coBorrowerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForBorrower();
        Database.insert(coBorrowerBusinessInfoObj,true);
        Account coBorrowerAccountObj = ApplicationOriginationTestHelper.createCoBorrowerAccount(legalEntityObj,coBorrowerBusinessInfoObj.id);
        coBorrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('CoApplicant').getRecordTypeId();
        Database.insert(coBorrowerAccountObj,true);
        Contact coBorrowerContactObj = ApplicationOriginationTestHelper.createCoBorrowerContact(coBorrowerAccountObj.id);
        Database.insert(coBorrowerContactObj,true);
        clcommon__Party_Type__c prPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('PRINCIPAL');
        Database.insert(prPartyTypeObj,true);
        Map<String,Id> principalPartyParamMap = new Map<String,Id>{
            'accountId' => coBorrowerAccountObj.id,
            'contactId' => coBorrowerContactObj.id,
            'partyTypeId' => prPartyTypeObj.id,
            'applicationId' => applicationObj.id
        };
        clcommon__Party__c principalPartyObj = ApplicationOriginationTestHelper.createParty(principalPartyParamMap);
        Database.insert(principalPartyObj,true);
    }
    
    /**
    * @description  : trying to change email of a grower from CFA coop type
    * @author Krishanu Chinya | 04-10-2024 
    **/
    @isTest
    static void testChangeEmailofIndividualCFA() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        // Test data setup
        Contact testContact = [SELECT Id
                                    FROM Contact
                                    WHERE genesis__SSN__c = 'GHFB6766'];
        Account testAccount = [SELECT Id, Coop_Type__c
                                FROM Account
                                WHERE Id =: testContact.AccountId];
        testAccount.Coop_Type__c = 'CFA';
        Database.update(testAccount);

        Map<String, Object> argumentsFromPortal = new Map<String, Object>{
            'newEmail' => 'new@example.com',
            'contactId' => testContact.Id,
            'updateRequest' => 'Email'
        };

        // Test action invocation
        System.runAs(clUser) {
            Test.startTest();
            PortalUpdateGrowerDetailsAPI api = new PortalUpdateGrowerDetailsAPI();
            clcommon.Response response = api.invokeAction('componentStrName', new String[]{}, argumentsFromPortal);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description  : trying to change email of a grower from growmark coop type
    * @author Krishanu Chinya | 04-10-2024 
    **/
    @isTest
    static void testChangeEmailofIndividualGMK() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        // Test data setup
        Contact testContact = [SELECT Id,
                                        AccountId
                                    FROM Contact
                                    WHERE genesis__SSN__c = 'GHFB6766'];
        Account testAccount = [SELECT Id,
                                        Coop_Type__c
                                FROM Account
                                WHERE Id =: testContact.AccountId];
        testAccount.Coop_Type__c = 'Growmark';
        Database.update(testAccount);

        Map<String, Object> argumentsFromPortal = new Map<String, Object>{
            'newEmail' => 'new@example.com',
            'contactId' => testContact.Id,
            'updateRequest' => 'Email'
        };

        // Test action invocation
        System.runAs(clUser) {
            Test.startTest();
            PortalUpdateGrowerDetailsAPI api = new PortalUpdateGrowerDetailsAPI();
            clcommon.Response response = api.invokeAction('componentStrName', new String[]{}, argumentsFromPortal);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
        }
    }

    // /**
    // * @description : trying to change email of a grower from landus coop type
    // * @author Krishanu Chinya | 04-10-2024 
    // **/
    // //@isTest
    // static void testChangeEmailofIndividualLandus() {
    //     User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

    //     // Test data setup
    //     Contact testContact = [SELECT Id,
    //                                     AccountId
    //                                 FROM Contact
    //                                 WHERE genesis__SSN__c = 'GHFB6766'];
    //     Account testAccount = [SELECT Id,
    //                                     Coop_Type__c
    //                             FROM Account
    //                             WHERE Id =: testContact.AccountId];
    //     testAccount.Coop_Type__c = 'Landus';
    //     Database.update(testAccount);

    //     Map<String, Object> argumentsFromPortal = new Map<String, Object>{
    //         'newEmail' => 'new@example.com',
    //         'contactId' => testContact.Id,
    //         'updateRequest' => 'Email'
    //     };

    //     // Test action invocation
    //     System.runAs(clUser) {
    //         Test.startTest();
    //         PortalUpdateGrowerDetailsAPI api = new PortalUpdateGrowerDetailsAPI();
    //         clcommon.Response response = api.invokeAction('componentStrName', new String[]{}, argumentsFromPortal);
    //         Test.stopTest();
    //         System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
    //     }
    // }

    /**
    * @description : trying to change email of a grower who didn't have an email earlier
    * @author Krishanu Chinya | 04-10-2024 
    **/
    @isTest
    static void testWhenPrevEmailEmpty() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        // Test data setup
        Contact testContact = [SELECT Id,
                                        AccountId
                                    FROM Contact
                                    WHERE genesis__SSN__c = 'GHFB6766'];
        testContact.Email = null;
        Database.update(testContact, true);

        Map<String, Object> argumentsFromPortal = new Map<String, Object>{
            'newEmail' => 'new@example.com',
            'contactId' => testContact.Id,
            'updateRequest' => 'Email'
        };

        // Test action invocation
        System.runAs(clUser) {
            Test.startTest();
            PortalUpdateGrowerDetailsAPI api = new PortalUpdateGrowerDetailsAPI();
            clcommon.Response response = api.invokeAction('componentStrName', new String[]{}, argumentsFromPortal);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description : tyring to change email of a grower and new email address is same as old email address
    * @author Krishanu Chinya | 04-10-2024 
    **/
    @isTest
    static void testWithSameNewAndOldEmail() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        // Test data setup
        Contact testContact = [SELECT Id,
                                        Email
                                    FROM Contact
                                    WHERE genesis__SSN__c = 'GHFB6766'];

        Map<String, Object> argumentsFromPortal = new Map<String, Object>{
            'newEmail' => testContact.Email,
            'contactId' => testContact.Id,
            'updateRequest' => 'Email'
        };

        // Test action invocation
        System.runAs(clUser) {
            Test.startTest();
            PortalUpdateGrowerDetailsAPI api = new PortalUpdateGrowerDetailsAPI();
            clcommon.Response response = api.invokeAction('componentStrName', new String[]{}, argumentsFromPortal);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description - test with No Params
    * @author Sk Minsar | 05-16-2024 
    **/
    @isTest
    static void testWithNoParam() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        Map<String, Object> argumentsFromPortal = new Map<String, Object>{};

        // Test action invocation
        System.runAs(clUser) {
            Test.startTest();
            PortalUpdateGrowerDetailsAPI api = new PortalUpdateGrowerDetailsAPI();
            clcommon.Response response = api.invokeAction('componentStrName', new String[]{}, argumentsFromPortal);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description : trying to change email of a grower whose account does not exist
    * @author Krishanu Chinya | 04-10-2024 
    **/
    @isTest
    static void testWithNoAccountID() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        // Test data setup
        Contact testContact = [SELECT Id,
                                        AccountId
                                    FROM Contact
                                    WHERE genesis__SSN__c = 'GHFB6766'];
        testContact.AccountId = null;
        Database.update(testContact, true);

        Map<String, Object> argumentsFromPortal = new Map<String, Object>{
            'newEmail' => 'new@example.com',
            'contactId' => testContact.Id,
            'updateRequest' => 'Email'
        };

        // Test action invocation
        System.runAs(clUser) {
            Test.startTest();
            PortalUpdateGrowerDetailsAPI api = new PortalUpdateGrowerDetailsAPI();
            clcommon.Response response = api.invokeAction('componentStrName', new String[]{}, argumentsFromPortal);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description : trying to initiate email change of a grower who doesn't have an SSN
    * @author Krishanu Chinya | 04-11-2024 
    **/
    @isTest
    static void testWithIndividualWithNoSSN() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        // Test data setup
        Contact testContact = [SELECT Id,
                                        genesis__SSN__c,
                                        AccountId
                                    FROM Contact
                                    WHERE genesis__SSN__c = 'GHFB6766'];
        testContact.genesis__SSN__c = null;
        Database.update(testContact, true);
        Account testAccount = [SELECT Id,
                                        Coop_Type__c
                                FROM Account
                                WHERE Id =: testContact.AccountId];
        testAccount.Coop_Type__c = 'Growmark';
        Database.update(testAccount);

        Map<String, Object> argumentsFromPortal = new Map<String, Object>{
            'newEmail' => 'new@example.com',
            'contactId' => testContact.Id,
            'updateRequest' => 'Email'
        };

        // Test action invocation
        System.runAs(clUser) {
            Test.startTest();
            PortalUpdateGrowerDetailsAPI api = new PortalUpdateGrowerDetailsAPI();
            clcommon.Response response = api.invokeAction('componentStrName', new String[]{}, argumentsFromPortal);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description : trying to initiate email change of a grower who doesn't have an SSN
    * @author Krishanu Chinya | 04-11-2024 
    **/
    @isTest
    static void testWithCorporationWithNoSSN() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        // Test data setup
        Contact testContact = [SELECT Id,
                                        genesis__SSN__c,
                                        Account.genesis__Business_Information__c,
                                        AccountId
                                    FROM Contact
                                    WHERE Email = 'green.crops@yopmail.com'];
        genesis__Business_Information__c testAccBusinessInfo = [SELECT Id,
                                                                    genesis__Tax_Identification_Number__c
                                                                    FROM genesis__Business_Information__c
                                                                    WHERE Id =: testContact.Account.genesis__Business_Information__c];
        testAccBusinessInfo.genesis__Tax_Identification_Number__c = null;
        Database.update(testAccBusinessInfo, true);
        Map<String, Object> argumentsFromPortal = new Map<String, Object>{
            'newEmail' => 'new@example.com',
            'contactId' => testContact.Id,
            'updateRequest' => 'Email'
        };

        // Test action invocation
        System.runAs(clUser) {
            Test.startTest();
            PortalUpdateGrowerDetailsAPI api = new PortalUpdateGrowerDetailsAPI();
            clcommon.Response response = api.invokeAction('componentStrName', new String[]{}, argumentsFromPortal);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test with Allowed for CFA
    * @author Sk Minsar | 05-15-2024 
    **/
    @isTest
    static void testEEToAllowedforIndividualCFA() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        // Test data setup
        Contact testContact = [SELECT Id,
                                    AccountId
                                    FROM Contact
                                    WHERE genesis__SSN__c = 'GHFB6766'];
        Account testAccount = [SELECT Id,
                                        Coop_Type__c,
                                        Is_Evergreen_Allowed__c
                                FROM Account
                                WHERE Id =: testContact.AccountId];
        testAccount.Is_Evergreen_Allowed__c = false;
        Database.update(testAccount);
        Map<String, Object> argumentsFromPortal = new Map<String, Object>{
            'contactId' => testContact.Id,
            'updateRequest' => 'Evergreen Eligibility',
            'isEvergreenAllowed' => 'Allowed'
        };

        // Test action invocation
        System.runAs(clUser) {
            Test.startTest();
            PortalUpdateGrowerDetailsAPI api = new PortalUpdateGrowerDetailsAPI();
            clcommon.Response response = api.invokeAction('componentStrName', new String[]{}, argumentsFromPortal);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
        }
    }
    /**
    * @description - Test with Allowed for CoBorrower for CFA
    * @author Sk Minsar | 05-15-2024 
    **/
    @isTest
    static void testEEToAllowedforCoBorrowerCFA() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        // Test data setup
        Contact testContact = [SELECT Id,
                                    AccountId
                                    FROM Contact
                                    WHERE Email='mike.johnson@yopmail.com' LIMIT 1];
        Account coBorrowerAccount  = [SELECT Id,
                                        Coop_Type__c,
                                        Is_Evergreen_Allowed__c
                                        FROM Account
                                        WHERE clcommon__Email__c = 'mike.johnson@yopmail.com'];
        coBorrowerAccount.Is_Evergreen_Allowed__c = false;
        Database.update(coBorrowerAccount);
        Map<String, Object> argumentsFromPortal = new Map<String, Object>{
            'contactId' => testContact.Id,
            'updateRequest' => 'Evergreen Eligibility',
            'isEvergreenAllowed' => 'Allowed'
        };

        // Test action invocation
        System.runAs(clUser) {
            Test.startTest();
            PortalUpdateGrowerDetailsAPI api = new PortalUpdateGrowerDetailsAPI();
            clcommon.Response response = api.invokeAction('componentStrName', new String[]{}, argumentsFromPortal);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
        }
    }
    /**
    * @description - Test with Allowed for CoBorrower for Growmark
    * @author Sk Minsar | 05-15-2024 
    **/
    @isTest
    static void testEEToAllowedforCoBorrowerGMK() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        // Test data setup
        Contact testContact = [SELECT Id,
                                    AccountId
                                    FROM Contact
                                    WHERE Email='mike.johnson@yopmail.com' LIMIT 1];
        Account coBorrowerAccount  = [SELECT Id,
                                        Coop_Type__c,
                                        Is_Evergreen_Allowed__c
                                        FROM Account
                                        WHERE clcommon__Email__c = 'mike.johnson@yopmail.com' LIMIT 1];
        coBorrowerAccount.Coop_Type__c = 'Growmark';                                     
        coBorrowerAccount.Is_Evergreen_Allowed__c = false;
        Database.update(coBorrowerAccount);
        Map<String, Object> argumentsFromPortal = new Map<String, Object>{
            'contactId' => testContact.Id,
            'updateRequest' => 'Evergreen Eligibility',
            'isEvergreenAllowed' => 'Allowed'
        };

        // Test action invocation
        System.runAs(clUser) {
            Test.startTest();
            PortalUpdateGrowerDetailsAPI api = new PortalUpdateGrowerDetailsAPI();
            clcommon.Response response = api.invokeAction('componentStrName', new String[]{}, argumentsFromPortal);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
        }
    }
    /**
    * @description - Test with Allowed for CoBorrower for Landus
    * @author Sk Minsar | 05-15-2024 
    **/
    @isTest
    static void testEEToAllowedforCoBorrowerLandus() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        // Test data setup
        Contact testContact = [SELECT Id,
                                    AccountId
                                    FROM Contact
                                    WHERE Email='mike.johnson@yopmail.com' LIMIT 1];
        Account coBorrowerAccount  = [SELECT Id,
                                        Coop_Type__c,
                                        Is_Evergreen_Allowed__c
                                        FROM Account
                                        WHERE clcommon__Email__c = 'mike.johnson@yopmail.com'];
        coBorrowerAccount.Is_Evergreen_Allowed__c = false;
        coBorrowerAccount.Coop_Type__c = 'Landus';
        Database.update(coBorrowerAccount);
        Map<String, Object> argumentsFromPortal = new Map<String, Object>{
            'contactId' => testContact.Id,
            'updateRequest' => 'Evergreen Eligibility',
            'isEvergreenAllowed' => 'Allowed'
        };

        // Test action invocation
        System.runAs(clUser) {
            Test.startTest();
            PortalUpdateGrowerDetailsAPI api = new PortalUpdateGrowerDetailsAPI();
            clcommon.Response response = api.invokeAction('componentStrName', new String[]{}, argumentsFromPortal);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
        }
    }
    /**
    * @description - Test with Not Allowed for CoBorrower for CFA
    * @author Sk Minsar | 05-15-2024 
    **/
    @isTest
    static void testEEToNotAllowedforCoBorrowerCFA() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        // Test data setup
        Contact testContact = [SELECT Id,
                                    AccountId
                                    FROM Contact
                                    WHERE Email='mike.johnson@yopmail.com' LIMIT 1];
        Account coBorrowerAccount  = [SELECT Id,
                                        Coop_Type__c,
                                        Is_Evergreen_Allowed__c
                                        FROM Account
                                        WHERE clcommon__Email__c = 'mike.johnson@yopmail.com'];
        coBorrowerAccount.Is_Evergreen_Allowed__c = true;
        Database.update(coBorrowerAccount);
        Map<String, Object> argumentsFromPortal = new Map<String, Object>{
            'contactId' => testContact.Id,
            'updateRequest' => 'Evergreen Eligibility',
            'isEvergreenAllowed' => 'Not Allowed'
        };

        // Test action invocation
        System.runAs(clUser) {
            Test.startTest();
            PortalUpdateGrowerDetailsAPI api = new PortalUpdateGrowerDetailsAPI();
            clcommon.Response response = api.invokeAction('componentStrName', new String[]{}, argumentsFromPortal);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
        }
    }
    /**
    * @description - Test with Not Allowed for CoBorrower for Growmark
    * @author Sk Minsar | 05-15-2024 
    **/
    @isTest
    static void testEEToNotAllowedforCoBorrowerGMK() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        // Test data setup
        Contact testContact = [SELECT Id,
                                    AccountId
                                    FROM Contact
                                    WHERE Email='mike.johnson@yopmail.com' LIMIT 1];
        Account coBorrowerAccount  = [SELECT Id,
                                        Coop_Type__c,
                                        Is_Evergreen_Allowed__c
                                        FROM Account
                                        WHERE clcommon__Email__c = 'mike.johnson@yopmail.com'];
        coBorrowerAccount.Coop_Type__c = 'Growmark';                                        
        coBorrowerAccount.Is_Evergreen_Allowed__c = true;
        Database.update(coBorrowerAccount);
        Map<String, Object> argumentsFromPortal = new Map<String, Object>{
            'contactId' => testContact.Id,
            'updateRequest' => 'Evergreen Eligibility',
            'isEvergreenAllowed' => 'Not Allowed'
        };

        // Test action invocation
        System.runAs(clUser) {
            Test.startTest();
            PortalUpdateGrowerDetailsAPI api = new PortalUpdateGrowerDetailsAPI();
            clcommon.Response response = api.invokeAction('componentStrName', new String[]{}, argumentsFromPortal);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
        }
    }
    /**
    * @description - Test with Not Allowed for CoBorrower for Landus
    * @author Sk Minsar | 05-15-2024 
    **/
    @isTest
    static void testEEToNotAllowedforCoBorrowerLandus() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        // Test data setup
        Contact testContact = [SELECT Id,
                                    AccountId
                                    FROM Contact
                                    WHERE Email='mike.johnson@yopmail.com' LIMIT 1];
        Account coBorrowerAccount  = [SELECT Id,
                                        Coop_Type__c,
                                        Is_Evergreen_Allowed__c
                                        FROM Account
                                        WHERE clcommon__Email__c = 'mike.johnson@yopmail.com'];
        coBorrowerAccount.Is_Evergreen_Allowed__c = true;
        coBorrowerAccount.Coop_Type__c = 'Landus';
        Database.update(coBorrowerAccount);
        Map<String, Object> argumentsFromPortal = new Map<String, Object>{
            'contactId' => testContact.Id,
            'updateRequest' => 'Evergreen Eligibility',
            'isEvergreenAllowed' => 'Not Allowed'
        };

        // Test action invocation
        System.runAs(clUser) {
            Test.startTest();
            PortalUpdateGrowerDetailsAPI api = new PortalUpdateGrowerDetailsAPI();
            clcommon.Response response = api.invokeAction('componentStrName', new String[]{}, argumentsFromPortal);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
        }
    }
    /**
    * @description - Test with Allowed for CFA
    * @author Sk Minsar | 05-15-2024 
    **/
    @isTest
    static void testEEToAllowedforCorporationCFA() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        // Test data setup
        Contact testContact = [SELECT Id,
                                        genesis__SSN__c,
                                        Account.genesis__Business_Information__c,
                                        AccountId
                                    FROM Contact
                                    WHERE Email='mike.johnson@yopmail.com' LIMIT 1];
        genesis__Business_Information__c testAccBusinessInfo = [SELECT Id,
                                                                    genesis__Tax_Identification_Number__c
                                                                    FROM genesis__Business_Information__c
                                                                    WHERE Id =: testContact.Account.genesis__Business_Information__c];
        testAccBusinessInfo.genesis__Tax_Identification_Number__c = null;
        Database.update(testAccBusinessInfo, true);

        Account testAccount = [SELECT Id,
                                        Coop_Type__c,
                                        Is_Evergreen_Allowed__c
                                FROM Account
                                WHERE Id =: testContact.AccountId];
        testAccount.Is_Evergreen_Allowed__c = false;
        Database.update(testAccount);

        Map<String, Object> argumentsFromPortal = new Map<String, Object>{
            'contactId' => testContact.Id,
            'updateRequest' => 'Evergreen Eligibility',
            'isEvergreenAllowed' => 'Allowed'
        };

        // Test action invocation
        System.runAs(clUser) {
            Test.startTest();
            PortalUpdateGrowerDetailsAPI api = new PortalUpdateGrowerDetailsAPI();
            clcommon.Response response = api.invokeAction('componentStrName', new String[]{}, argumentsFromPortal);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test with Not Allowed for CFA
    **/
    @isTest
    static void testEEToNotAllowedforIndividualCFA() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        // Test data setup
        Contact testContact = [SELECT Id,
                                    AccountId
                                    FROM Contact
                                    WHERE genesis__SSN__c = 'GHFB6766'];
        Account testAccount = [SELECT Id,
                                        Is_Evergreen_Allowed__c,
                                        Coop_Type__c
                                FROM Account
                                WHERE Id =: testContact.AccountId];
        testAccount.Is_Evergreen_Allowed__c = true;
        Database.update(testAccount);

        Map<String, Object> argumentsFromPortal = new Map<String, Object>{
            'contactId' => testContact.Id,
            'updateRequest' => 'Evergreen Eligibility',
            'isEvergreenAllowed' => 'Not Allowed'
        };

        // Test action invocation
        System.runAs(clUser) {
            Test.startTest();
            PortalUpdateGrowerDetailsAPI api = new PortalUpdateGrowerDetailsAPI();
            clcommon.Response response = api.invokeAction('componentStrName', new String[]{}, argumentsFromPortal);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test with Not Allowed for CFA
    **/
    @isTest
    static void testEEToNotAllowedforCorporationCFA() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        // Test data setup
        Contact testContact = [SELECT Id,
                                        genesis__SSN__c,
                                        Account.genesis__Business_Information__c,
                                        AccountId
                                    FROM Contact
                                    WHERE Email = 'green.crops@yopmail.com'];
        genesis__Business_Information__c testAccBusinessInfo = [SELECT Id,
                                                                    genesis__Tax_Identification_Number__c
                                                                    FROM genesis__Business_Information__c
                                                                    WHERE Id =: testContact.Account.genesis__Business_Information__c];
        testAccBusinessInfo.genesis__Tax_Identification_Number__c = null;
        Database.update(testAccBusinessInfo, true);

        Account testAccount = [SELECT Id,
                                        Is_Evergreen_Allowed__c,
                                        Coop_Type__c
                                FROM Account
                                WHERE Id =: testContact.AccountId];
        testAccount.Is_Evergreen_Allowed__c = true;
        Database.update(testAccount);

        Map<String, Object> argumentsFromPortal = new Map<String, Object>{
            'contactId' => testContact.Id,
            'updateRequest' => 'Evergreen Eligibility',
            'isEvergreenAllowed' => 'Not Allowed'
        };

        // Test action invocation
        System.runAs(clUser) {
            Test.startTest();
            PortalUpdateGrowerDetailsAPI api = new PortalUpdateGrowerDetailsAPI();
            clcommon.Response response = api.invokeAction('componentStrName', new String[]{}, argumentsFromPortal);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test with Duplicate Exception
    **/
    @isTest
    static void testEEDuplicateValofIndividualCFA() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        // Test data setup
        Contact testContact = [SELECT Id,
                                        AccountId
                                    FROM Contact
                                    WHERE genesis__SSN__c = 'GHFB6766'];
        Account testAccount = [SELECT Id,
                                        Coop_Type__c,
                                        Is_Evergreen_Allowed__c
                                FROM Account
                                WHERE Id =: testContact.AccountId];
        testAccount.Is_Evergreen_Allowed__c = false;
        Database.update(testAccount);

        Map<String, Object> argumentsFromPortal = new Map<String, Object>{
            'contactId' => testContact.Id,
            'updateRequest' => 'Evergreen Eligibility',
            'isEvergreenAllowed' => 'Not Allowed'
        };

        // Test action invocation
        System.runAs(clUser) {
            Test.startTest();
            PortalUpdateGrowerDetailsAPI api = new PortalUpdateGrowerDetailsAPI();
            clcommon.Response response = api.invokeAction('componentStrName', new String[]{}, argumentsFromPortal);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test with Duplicate Exception
    **/
    @isTest
    static void testEEDuplicateValofCorporationCFA() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        // Test data setup
        Contact testContact = [SELECT Id,
                                        genesis__SSN__c,
                                        Account.genesis__Business_Information__c,
                                        AccountId
                                    FROM Contact
                                    WHERE Email = 'green.crops@yopmail.com'];
        genesis__Business_Information__c testAccBusinessInfo = [SELECT Id,
                                                                    genesis__Tax_Identification_Number__c
                                                                    FROM genesis__Business_Information__c
                                                                    WHERE Id =: testContact.Account.genesis__Business_Information__c];
        testAccBusinessInfo.genesis__Tax_Identification_Number__c = null;
        Database.update(testAccBusinessInfo, true);
        Account testAccount = [SELECT Id,
                                        Coop_Type__c,
                                        Is_Evergreen_Allowed__c
                                FROM Account
                                WHERE Id =: testContact.AccountId];
        testAccount.Is_Evergreen_Allowed__c = false;
        Database.update(testAccount);

        Map<String, Object> argumentsFromPortal = new Map<String, Object>{
            'contactId' => testContact.Id,
            'updateRequest' => 'Evergreen Eligibility',
            'isEvergreenAllowed' => 'Not Allowed'
        };

        // Test action invocation
        System.runAs(clUser) {
            Test.startTest();
            PortalUpdateGrowerDetailsAPI api = new PortalUpdateGrowerDetailsAPI();
            clcommon.Response response = api.invokeAction('componentStrName', new String[]{}, argumentsFromPortal);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test for Allowed for Growmark
    **/
    @isTest
    static void testEEToAllowedofIndividualGMK() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        // Test data setup
        Contact testContact = [SELECT Id,
                                        AccountId
                                    FROM Contact
                                    WHERE genesis__SSN__c = 'GHFB6766'];
        Account testAccount = [SELECT Id,
                                        Coop_Type__c
                                FROM Account
                                WHERE Id =: testContact.AccountId];
        testAccount.Coop_Type__c = 'Growmark';
        testAccount.Is_Evergreen_Allowed__c = true;
        Database.update(testAccount);

        Map<String, Object> argumentsFromPortal = new Map<String, Object>{
            'contactId' => testContact.Id,
            'updateRequest' => 'Evergreen Eligibility',
            'isEvergreenAllowed' => 'Not Allowed'
        };

        // Test action invocation
        System.runAs(clUser) {
            Test.startTest();
            PortalUpdateGrowerDetailsAPI api = new PortalUpdateGrowerDetailsAPI();
            clcommon.Response response = api.invokeAction('componentStrName', new String[]{}, argumentsFromPortal);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test Not Allowed for Growmark
    **/
    @isTest
    static void testEEToNotAllowedofIndividualGMK() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        // Test data setup
        Contact testContact = [SELECT Id,
                                        AccountId
                                    FROM Contact
                                    WHERE genesis__SSN__c = 'GHFB6766'];
        Account testAccount = [SELECT Id,
                                        Coop_Type__c
                                FROM Account
                                WHERE Id =: testContact.AccountId];
        testAccount.Is_Evergreen_Allowed__c = true;                                
        testAccount.Coop_Type__c = 'Growmark';
        Database.update(testAccount);

        Map<String, Object> argumentsFromPortal = new Map<String, Object>{
            'contactId' => testContact.Id,
            'updateRequest' => 'Evergreen Eligibility',
            'isEvergreenAllowed' => 'Not Allowed'
        };

        // Test action invocation
        System.runAs(clUser) {
            Test.startTest();
            PortalUpdateGrowerDetailsAPI api = new PortalUpdateGrowerDetailsAPI();
            clcommon.Response response = api.invokeAction('componentStrName', new String[]{}, argumentsFromPortal);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test with allowed for Landus
    **/
    @isTest
    static void testEEToAllowedofIndividualLandus() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        // Test data setup
        Contact testContact = [SELECT Id,
                                        AccountId
                                    FROM Contact
                                    WHERE genesis__SSN__c = 'GHFB6766'];
        Account testAccount = [SELECT Id,
                                        Coop_Type__c
                                FROM Account
                                WHERE Id =: testContact.AccountId];
        testAccount.Is_Evergreen_Allowed__c = true;
        testAccount.Coop_Type__c = 'Landus';
        Database.update(testAccount);

        Map<String, Object> argumentsFromPortal = new Map<String, Object>{
            'contactId' => testContact.Id,
            'updateRequest' => 'Evergreen Eligibility',
            'isEvergreenAllowed' => 'Not Allowed'
        };

        // Test action invocation
        System.runAs(clUser) {
            Test.startTest();
            PortalUpdateGrowerDetailsAPI api = new PortalUpdateGrowerDetailsAPI();
            clcommon.Response response = api.invokeAction('componentStrName', new String[]{}, argumentsFromPortal);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test with Non Allowed for Landus
    **/
    @isTest
    static void testEEToNotAllowedofIndividualLandus() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        // Test data setup
        Contact testContact = [SELECT Id,
                                        AccountId
                                    FROM Contact
                                    WHERE genesis__SSN__c = 'GHFB6766'];
        Account testAccount = [SELECT Id,
                                        Coop_Type__c
                                FROM Account
                                WHERE Id =: testContact.AccountId];
        testAccount.Coop_Type__c = 'Landus';
        testAccount.Is_Evergreen_Allowed__c = true;
        Database.update(testAccount);

        Map<String, Object> argumentsFromPortal = new Map<String, Object>{
            'contactId' => testContact.Id,
            'updateRequest' => 'Evergreen Eligibility',
            'isEvergreenAllowed' => 'Not Allowed'
        };

        // Test action invocation
        System.runAs(clUser) {
            Test.startTest();
            PortalUpdateGrowerDetailsAPI api = new PortalUpdateGrowerDetailsAPI();
            clcommon.Response response = api.invokeAction('componentStrName', new String[]{}, argumentsFromPortal);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test with Allowed for DBA
    * @author Sk Minsar | 05-15-2024 
    **/
    @isTest
    static void testEEToAllowedforDBA() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        // Test data setup
        Contact testContact = [SELECT Id,
                                        genesis__SSN__c,
                                        Account.genesis__Business_Information__c,
                                        AccountId
                                    FROM Contact
                                    WHERE Email='mike.johnson@yopmail.com' LIMIT 1];
        genesis__Business_Information__c testAccBusinessInfo = [SELECT Id,
                                                                    genesis__Tax_Identification_Number__c
                                                                    FROM genesis__Business_Information__c
                                                                    WHERE Id =: testContact.Account.genesis__Business_Information__c];
        testAccBusinessInfo.genesis__Tax_Identification_Number__c = null;
        Database.update(testAccBusinessInfo, true);

        Account testAccount = [SELECT Id,
                                        Coop_Type__c,
                                        clcommon__Legal_Entity_Type__c,
                                        Is_Evergreen_Allowed__c
                                FROM Account
                                WHERE Id =: testContact.AccountId];
        testAccount.Is_Evergreen_Allowed__c = false;
        Database.update(testAccount);
        if(testAccount.clcommon__Legal_Entity_Type__c != NULL){
            clcommon__Legal_Entity__c legalEntity = [SELECT Id, Name 
                                                    FROM clcommon__Legal_Entity__c 
                                                    WHERE Id = :testAccount.clcommon__Legal_Entity_Type__c 
                                                    LIMIT 1];

            legalEntity.Name = 'Individual(s) with DBA';
            Database.update(legalEntity, true);
        }
        Map<String, Object> argumentsFromPortal = new Map<String, Object>{
            'contactId' => testContact.Id,
            'updateRequest' => 'Evergreen Eligibility',
            'isEvergreenAllowed' => 'Allowed'
        };

        // Test action invocation
        System.runAs(clUser) {
            Test.startTest();
            PortalUpdateGrowerDetailsAPI api = new PortalUpdateGrowerDetailsAPI();
            clcommon.Response response = api.invokeAction('componentStrName', new String[]{}, argumentsFromPortal);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
        }
    }
    /**
    * @description - Test with Not Allowed for DBA
    **/
    @isTest
    static void testEEToNotAllowedforDBA() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        // Test data setup
        Contact testContact = [SELECT Id,
                                        genesis__SSN__c,
                                        Account.genesis__Business_Information__c,
                                        AccountId
                                    FROM Contact
                                    WHERE Email = 'green.crops@yopmail.com'];
        genesis__Business_Information__c testAccBusinessInfo = [SELECT Id,
                                                                    genesis__Tax_Identification_Number__c
                                                                    FROM genesis__Business_Information__c
                                                                    WHERE Id =: testContact.Account.genesis__Business_Information__c];
        testAccBusinessInfo.genesis__Tax_Identification_Number__c = null;
        Database.update(testAccBusinessInfo, true);

        Account testAccount = [SELECT Id,
                                        Is_Evergreen_Allowed__c,
                                        clcommon__Legal_Entity_Type__c,
                                        Coop_Type__c
                                FROM Account
                                WHERE Id =: testContact.AccountId];
        testAccount.Is_Evergreen_Allowed__c = true;
        Database.update(testAccount);
        if(testAccount.clcommon__Legal_Entity_Type__c != NULL){
            clcommon__Legal_Entity__c legalEntity = [SELECT Id, Name 
                                                    FROM clcommon__Legal_Entity__c 
                                                    WHERE Id = :testAccount.clcommon__Legal_Entity_Type__c 
                                                    LIMIT 1];

            legalEntity.Name = 'Individual(s) with DBA';
            Database.update(legalEntity, true);
        }
        Map<String, Object> argumentsFromPortal = new Map<String, Object>{
            'contactId' => testContact.Id,
            'updateRequest' => 'Evergreen Eligibility',
            'isEvergreenAllowed' => 'Not Allowed'
        };

        // Test action invocation
        System.runAs(clUser) {
            Test.startTest();
            PortalUpdateGrowerDetailsAPI api = new PortalUpdateGrowerDetailsAPI();
            clcommon.Response response = api.invokeAction('componentStrName', new String[]{}, argumentsFromPortal);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
        }
    }
/**
    * @description  : trying to change email of a grower from CFA coop type
    * @author Krishanu Chinya | 04-10-2024 
    **/
    @isTest
    static void test() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        // Test data setup
        Contact testContact = [SELECT Id
                                    FROM Contact
                                    WHERE genesis__SSN__c = 'GHFB6766'];
        Account testAccount = [SELECT Id, Coop_Type__c
                                FROM Account
                                WHERE Id =: testContact.AccountId];
        testAccount.Coop_Type__c = 'CFA';
        Database.update(testAccount);

        Map<String, Object> argumentsFromPortal = new Map<String, Object>{
            'newEmail' => 'new@example.com',
            'contactId' => testContact.Id,
            'updateRequest' => 'Email'
        };
        
        // Test action invocation
        System.runAs(clUser) {
            Test.startTest();
            PortalUpdateGrowerDetailsAPI api = new PortalUpdateGrowerDetailsAPI();
            clcommon.Response response = api.invokeAction('componentStrName', new String[]{}, argumentsFromPortal);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
        }
    }

}