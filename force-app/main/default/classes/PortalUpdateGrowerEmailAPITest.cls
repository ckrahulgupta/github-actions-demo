/**
 * @description       : test class for PortalUpdateGrowerEmailAPI
 * @author            : Krishanu Chinya
 * @group             : 
 * @last modified on  : 05-21-2024
 * @last modified by  : Ayush Kumar Singh
**/
@isTest
global without sharing class PortalUpdateGrowerEmailAPITest {
    @testSetup
    static void setup(){
        // creating business information
        genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        Database.insert(dealerBusinessInfoObj, true);
    
        // Creating Account for Dealer
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
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

        CFA_Configuration__c credentialParameter = ApplicationOriginationTestHelper.createEmailChangeDecryptionConfig();
        Database.insert(credentialParameter,true);

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

        Map<String, Object> argumentsFromPortal = new Map<String, Object>{
            'newEmail' => 'new@example.com',
            'contactId' => testContact.Id
        };

        // Test action invocation
        System.runAs(clUser) {
            Test.startTest();
            PortalUpdateGrowerEmailAPI api = new PortalUpdateGrowerEmailAPI();
            clcommon.Response response = api.invokeAction('componentStrName', new String[]{}, argumentsFromPortal);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
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
            'contactId' => testContact.Id
        };

        // Test action invocation
        System.runAs(clUser) {
            Test.startTest();
            PortalUpdateGrowerEmailAPI api = new PortalUpdateGrowerEmailAPI();
            clcommon.Response response = api.invokeAction('componentStrName', new String[]{}, argumentsFromPortal);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
        }
    }

    /**
    * @description : trying to change email of a grower from landus coop type
    * @author Krishanu Chinya | 04-10-2024 
    **/
    @isTest
    static void testChangeEmailofIndividualLandus() {
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
        Database.update(testAccount);

        Map<String, Object> argumentsFromPortal = new Map<String, Object>{
            'newEmail' => 'new@example.com',
            'contactId' => testContact.Id
        };

        // Test action invocation
        System.runAs(clUser) {
            Test.startTest();
            PortalUpdateGrowerEmailAPI api = new PortalUpdateGrowerEmailAPI();
            clcommon.Response response = api.invokeAction('componentStrName', new String[]{}, argumentsFromPortal);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.SUCCESS, response.status, PortalConstants.ASSERTION_FAILED);
        }
    }

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
            'contactId' => testContact.Id
        };

        // Test action invocation
        System.runAs(clUser) {
            Test.startTest();
            PortalUpdateGrowerEmailAPI api = new PortalUpdateGrowerEmailAPI();
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
            'contactId' => testContact.Id
        };

        // Test action invocation
        System.runAs(clUser) {
            Test.startTest();
            PortalUpdateGrowerEmailAPI api = new PortalUpdateGrowerEmailAPI();
            clcommon.Response response = api.invokeAction('componentStrName', new String[]{}, argumentsFromPortal);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, PortalConstants.ASSERTION_FAILED);
        }
    }

    @isTest
    static void testWithNoParam() {
        User clUser = ApplicationOriginationTestHelper.getCertifiedLenderUser('Ross Geller');

        Map<String, Object> argumentsFromPortal = new Map<String, Object>{};

        // Test action invocation
        System.runAs(clUser) {
            Test.startTest();
            PortalUpdateGrowerEmailAPI api = new PortalUpdateGrowerEmailAPI();
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
            'contactId' => testContact.Id
        };

        // Test action invocation
        System.runAs(clUser) {
            Test.startTest();
            PortalUpdateGrowerEmailAPI api = new PortalUpdateGrowerEmailAPI();
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
            'contactId' => testContact.Id
        };

        // Test action invocation
        System.runAs(clUser) {
            Test.startTest();
            PortalUpdateGrowerEmailAPI api = new PortalUpdateGrowerEmailAPI();
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
            'contactId' => testContact.Id
        };

        // Test action invocation
        System.runAs(clUser) {
            Test.startTest();
            PortalUpdateGrowerEmailAPI api = new PortalUpdateGrowerEmailAPI();
            clcommon.Response response = api.invokeAction('componentStrName', new String[]{}, argumentsFromPortal);
            Test.stopTest();
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status, PortalConstants.ASSERTION_FAILED);
        }
    }
    
}