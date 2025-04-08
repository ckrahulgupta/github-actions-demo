/**
 * @description       : Test class for UpdateDealerRelationAPI
 * @author            : Simran
 * @group             : 
 * @last modified on  : 04-17-2024
 * @last modified by  : Ayan Bhowmik
**/
@isTest
public with sharing class UpdateDealerRelationAPITest {
    @TestSetup
    static void makeData() {
        // creating business information
        genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        Database.insert(dealerBusinessInfoObj, true);

        // Creating Account for Dealer
        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.Id);
        Database.insert(dealerAccountObj, true);
 
        // Creating Contact for Dealer
        Contact dealerContactObj = ApplicationOriginationTestHelper.createDealerContact(dealerAccountObj.Id);
        Database.insert(dealerContactObj, true);

        // Creating Account for Dealer
        Account gmkDealerAccountObj = TestClassHelper.createGMKDealerAccount(dealerBusinessInfoObj.Id);
        Database.insert(gmkDealerAccountObj, true);

        // Creating Contact for Dealer
        Contact gmkDealerContactObj = TestClassHelper.createGMKDealerContact(gmkDealerAccountObj.Id);
        Database.insert(gmkDealerContactObj, true);

        // creating Account for Certified Lender
        Account fsAccountObj = TestClassHelper.createFSAgentAccount(dealerBusinessInfoObj.Id, gmkDealerAccountObj.Id);
        Database.insert(fsAccountObj, true);

        // Creating Contact for Certified Lender
        Contact fsContactObj = TestClassHelper.createFSAgentContact(fsAccountObj.Id);
        Database.insert(fsContactObj, true);

        // creating relationship of certified lender
        clcommon__Reciprocal_Role__c fsRoleObj = TestClassHelper.createReciprocalRole('Field Staff Agent');
        Database.insert(fsRoleObj, true);
        clcommon__Relationship__c fsRelationship = TestClassHelper.createCLDealerRelationship(fsRoleObj, 
                                                                                                    gmkDealerAccountObj.Id, 
                                                                                                    fsAccountObj.Id);
        Database.insert(fsRelationship, true);

        // Creating Field Staff Agent Party Type
        clcommon__Party_Type__c fsPartyTypeObj = ApplicationOriginationTestHelper.createPartyType('FIELD STAFF AGENT');
        Database.insert(fsPartyTypeObj, true);

        Account dummyGMKDealer = new Account(Name='Advend Arora',Coop_Type__c='Growmark');
        Database.insert(dummyGMKDealer,true);

        // creating Account for Certified Lender
        Account clAccountObj = TestClassHelper.createCLAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
        Database.insert(clAccountObj, true);

        // Creating Contact for Certified Lender
        Contact clContactObj = TestClassHelper.createCLContact(clAccountObj.Id);
        Database.insert(clContactObj, true);

        // Creating User for Certified Lender
        User clUser = TestClassHelper.createCLUser(clContactObj.Id);
        Database.insert(clUser, true);

        //creating a sales agent admin
        Account saAdminAccObj = ApplicationOriginationTestHelper.createSAAdminAccount(dealerBusinessInfoObj.Id, dealerAccountObj.Id);
        Database.insert(saAdminAccObj, true);
 
        //createing sa admin contact
        Contact saAdminContactObj=ApplicationOriginationTestHelper.createSAAdminContact(saAdminAccObj.Id);
        Database.insert(saAdminContactObj, true);

        //creating a sales agent 
        Account saAccObj = ApplicationOriginationTestHelper.createSalesAgentAccount(dealerBusinessInfoObj.Id,dealerAccountObj.Id);
        Database.insert(saAccObj, true);
  
        //createing sa contact
        Contact saContactObj=ApplicationOriginationTestHelper.createSalesAgentContact(saAccObj.Id);
        Database.insert(saContactObj, true);

        //creating related sales agent  role
        clcommon__Reciprocal_Role__c rsaRoleObj = ApplicationOriginationTestHelper.createReciprocalRole(PortalConstants.RELATED_SALES_AGENT);
        Database.insert(rsaRoleObj, true);

        //creating related sales agent  relationship
        clcommon__Relationship__c relationshipObject = ApplicationOriginationTestHelper.createRelWithDealer(rsaRoleObj,saAdminAccObj.Id,saAccObj.Id);
        Database.insert(relationshipObject, true);

        // creating relationship of certified lender
        clcommon__Reciprocal_Role__c clRoleObj = TestClassHelper.createReciprocalRole('Certified Lender');
        Database.insert(clRoleObj, true);
        clcommon__Relationship__c objRelationship = TestClassHelper.createCLDealerRelationship(clRoleObj, 
                                                                                                    dealerAccountObj.Id, 
                                                                                                    clAccountObj.Id);
        Database.insert(objRelationship, true);

        List<clcommon__Reciprocal_Role__c> roleList = new List<clcommon__Reciprocal_Role__c>{
            TestClassHelper.createReciprocalRole('Authorized Person'),
            TestClassHelper.createReciprocalRole('AgriBusiness'),
            TestClassHelper.createReciprocalRole('Primary Contact'),
            TestClassHelper.createReciprocalRole('General Manager'),
            TestClassHelper.createReciprocalRole('Certified Lender Plus'),
            TestClassHelper.createReciprocalRole('Inquiry'),
            TestClassHelper.createReciprocalRole('Inquiry Plus'),
            TestClassHelper.createReciprocalRole('Sales Agent'),
            TestClassHelper.createReciprocalRole('Sales Agent Plus'),
            TestClassHelper.createReciprocalRole('Sales Agent Admin'),
            TestClassHelper.createReciprocalRole('Payment Administrator'),
            TestClassHelper.createReciprocalRole('Related Sales Agent')
        };
        Database.insert(roleList, true);
    }

    /**
    * @description Return RecordType Id.
    * @author Ayan Bhowmik | 04-14-2024 
    * @param nameList 
    * @return Id 
    **/
    private static Id getRecordTypeId(List<String> nameList) {
        return [SELECT Id,
                        Name 
                    FROM RecordType 
                    WHERE Name IN :nameList
                    AND sObjectType =: ConstantValues.ACCOUNT].Id;
    }
    /**
    * @description Return Reciprocal Id From Name
    * @author Ayan Bhowmik | 04-14-2024 
    * @param name 
    * @return Id 
    **/
    private static Id getReciprocalRoleId(String name) {
        return [SELECT Id
                FROM clcommon__Reciprocal_Role__c
                WHERE Name =: name
                LIMIT 1].Id;
    }

    /**
    * @description Get Account From Name.
    * @author Ayan Bhowmik | 04-14-2024 
    * @param name 
    * @return Account 
    **/
    private static Account getAccount(String name) {
        return [SELECT Id,
                    ParentId
                FROM Account
                WHERE Name =: name
                LIMIT 1];
    }
    /**
    * @description Get Relationship From Related Entity.
    * @author Ayan Bhowmik | 04-14-2024 
    * @param relatedAccountId 
    * @return clcommon__Relationship__c 
    **/
    private static clcommon__Relationship__c getRelationship(Id relatedAccountId) {
        return [SELECT Id,
                        clcommon__Entity__c,
                        clcommon__Related_Entity__c,
                        clcommon__Relationship__c
                    FROM clcommon__Relationship__c
                    WHERE clcommon__Related_Entity__c =: relatedAccountId];
    }
    @IsTest
    private static void testGetDealerAccount(){
        List<Account> dealerAccountList = new List<Account>();
        User systemUserObj = ApplicationOriginationTestHelper.getSystemAdminUser();
        System.runAs(systemUserObj) {
            Test.startTest();
            dealerAccountList = UpdateDealerRelationAPI.getDealerAccount();
            Test.stopTest();
            System.assertEquals(true, dealerAccountList.size() > 0, 'Dealer Account Fetch Failed');
        }
    }
    @IsTest
    private static void testGetAccountName() {
        Account accountObj = getAccount('Ross Geller');
        Account userAccountObj = new Account();
        User systemUserObj = ApplicationOriginationTestHelper.getSystemAdminUser();
        System.runAs(systemUserObj) {
            Test.startTest();
            userAccountObj = UpdateDealerRelationAPI.getAccountName(accountObj.Id);
            Test.stopTest();
            System.assertEquals('Ross Geller', userAccountObj.Name, 'Account Name Fetch Failed');
        }
    }
    @IsTest
    private static void testGetEntityRoleList() {
        Account accountObj = getAccount('Ross Geller');
        List<RecordType> recordTypeList = new List<RecordType>();
        User systemUserObj = ApplicationOriginationTestHelper.getSystemAdminUser();
        System.runAs(systemUserObj) {
            Test.startTest();
            recordTypeList = UpdateDealerRelationAPI.getEntityRole(accountObj.Id);
            Test.stopTest();
            System.assertEquals(14, recordTypeList.size(), 'Entity Role Fetch Failed');
        } 
    }
    @IsTest
    private static void testFetchExistingRelationshipForGMK() {
        Account accountObj = getAccount('Ross FieldStaff');
        List<RecordType> recordTypeList = new List<RecordType>();
        User systemUserObj = ApplicationOriginationTestHelper.getSystemAdminUser();
        System.runAs(systemUserObj) {
            Test.startTest();
            recordTypeList = UpdateDealerRelationAPI.fetchExistingRelationships(accountObj.Id);
            Test.stopTest();
            System.assertEquals('Field Staff Agent', recordTypeList[0].Name, 'Entity Role Fetch Failed');
        } 
    }
    @IsTest
    private static void testFetchExistingRelationship() {
        Account accountObj = getAccount('Ross Geller');
        List<RecordType> recordTypeList = new List<RecordType>();
        User systemUserObj = ApplicationOriginationTestHelper.getSystemAdminUser();
        System.runAs(systemUserObj) {
            Test.startTest();
            recordTypeList = UpdateDealerRelationAPI.fetchExistingRelationships(accountObj.Id);
            Test.stopTest();
            System.assertEquals('Certified Lender', recordTypeList[0].Name, 'Entity Role Fetch Failed');
        } 
    }
    @IsTest
    private static void testDeleteCLPlus() {
        Id abRoleId = getReciprocalRoleId('Certified Lender Plus');
        Account accountObj = getAccount('Ross Geller');
        clcommon__Relationship__c existingRelationshipObj = getRelationship(accountObj.Id);
        existingRelationshipObj.clcommon__Relationship__c = abRoleId;
        Database.update(existingRelationshipObj, true);
        User systemUserObj = ApplicationOriginationTestHelper.getSystemAdminUser();
        System.runAs(systemUserObj) {
            Test.startTest();
            UpdateDealerRelationAPI.deleteDealerRelation(accountObj.Id);
            Test.stopTest();
            List<clcommon__Relationship__c> oldRelationshipList = [SELECT Id,
                                                                        clcommon__Relationship__r.Name
                                                                    FROM clcommon__Relationship__c
                                                                    WHERE clcommon__Related_Entity__c =: accountObj.Id
                                                                    AND clcommon__Relationship__c =: abRoleId];
            System.assertEquals(0, oldRelationshipList.size(), 'Relationship Deletion Failed');

            List<clcommon__Relationship__c> dummyRelationshipList = [SELECT Id,
                                                                        Previous_Dealer__c,
                                                                        Previous_Dealer_Contact__c,
                                                                        Previous_Dealer_Contact_Role__c
                                                                    FROM clcommon__Relationship__c
                                                                    WHERE Previous_Dealer_Contact__c =: accountObj.Id];

            System.assertEquals('Certified Lender Plus', dummyRelationshipList[0].Previous_Dealer_Contact_Role__c, 'Dummy Relationship Creation Failed');
        } 
    }   
    @IsTest
    private static void testDeleteCL() {
        Id abRoleId = getReciprocalRoleId('Certified Lender');
        Account accountObj = getAccount('Ross Geller');
        clcommon__Relationship__c existingRelationshipObj = getRelationship(accountObj.Id);
        existingRelationshipObj.clcommon__Relationship__c = abRoleId;
        Database.update(existingRelationshipObj, true);
        User systemUserObj = ApplicationOriginationTestHelper.getSystemAdminUser();
        System.runAs(systemUserObj) {
            Test.startTest();
            UpdateDealerRelationAPI.deleteDealerRelation(accountObj.Id);
            Test.stopTest();
            List<clcommon__Relationship__c> oldRelationshipList = [SELECT Id,
                                                                        clcommon__Relationship__r.Name
                                                                    FROM clcommon__Relationship__c
                                                                    WHERE clcommon__Related_Entity__c =: accountObj.Id
                                                                    AND clcommon__Relationship__c =: abRoleId];
            System.assertEquals(0, oldRelationshipList.size(), 'Relationship Deletion Failed');

            List<clcommon__Relationship__c> dummyRelationshipList = [SELECT Id,
                                                                        Previous_Dealer__c,
                                                                        Previous_Dealer_Contact__c,
                                                                        Previous_Dealer_Contact_Role__c
                                                                    FROM clcommon__Relationship__c
                                                                    WHERE Previous_Dealer_Contact__c =: accountObj.Id];

            System.assertEquals('Certified Lender', dummyRelationshipList[0].Previous_Dealer_Contact_Role__c, 'Dummy Relationship Creation Failed');
        } 
    }   
    @IsTest
    private static void testDeleteAB() {
        Id abRoleId = getReciprocalRoleId('AgriBusiness');
        Account accountObj = getAccount('Ross Geller');
        clcommon__Relationship__c existingRelationshipObj = getRelationship(accountObj.Id);
        existingRelationshipObj.clcommon__Relationship__c = abRoleId;
        Database.update(existingRelationshipObj, true);
        User systemUserObj = ApplicationOriginationTestHelper.getSystemAdminUser();
        System.runAs(systemUserObj) {
            Test.startTest();
            UpdateDealerRelationAPI.deleteDealerRelation(accountObj.Id);
            Test.stopTest();
            List<clcommon__Relationship__c> oldRelationshipList = [SELECT Id,
                                                                        clcommon__Relationship__r.Name
                                                                    FROM clcommon__Relationship__c
                                                                    WHERE clcommon__Related_Entity__c =: accountObj.Id
                                                                    AND clcommon__Relationship__c =: abRoleId];
            System.assertEquals(0, oldRelationshipList.size(), 'Relationship Deletion Failed');

            List<clcommon__Relationship__c> dummyRelationshipList = [SELECT Id,
                                                                        Previous_Dealer__c,
                                                                        Previous_Dealer_Contact__c,
                                                                        Previous_Dealer_Contact_Role__c
                                                                    FROM clcommon__Relationship__c
                                                                    WHERE Previous_Dealer_Contact__c =: accountObj.Id];

            System.assertEquals('AgriBusiness', dummyRelationshipList[0].Previous_Dealer_Contact_Role__c, 'Dummy Relationship Creation Failed');
        } 
    }   
    @IsTest
    private static void testDeleteAP() {
        Id abRoleId = getReciprocalRoleId('Authorized Person');
        Account accountObj = getAccount('Ross Geller');
        clcommon__Relationship__c existingRelationshipObj = getRelationship(accountObj.Id);
        existingRelationshipObj.clcommon__Relationship__c = abRoleId;
        Database.update(existingRelationshipObj, true);
        User systemUserObj = ApplicationOriginationTestHelper.getSystemAdminUser();
        System.runAs(systemUserObj) {
            Test.startTest();
            UpdateDealerRelationAPI.deleteDealerRelation(accountObj.Id);
            Test.stopTest();
            List<clcommon__Relationship__c> oldRelationshipList = [SELECT Id,
                                                                        clcommon__Relationship__r.Name
                                                                    FROM clcommon__Relationship__c
                                                                    WHERE clcommon__Related_Entity__c =: accountObj.Id
                                                                    AND clcommon__Relationship__c =: abRoleId];
            System.assertEquals(0, oldRelationshipList.size(), 'Relationship Deletion Failed');

            List<clcommon__Relationship__c> dummyRelationshipList = [SELECT Id,
                                                                        Previous_Dealer__c,
                                                                        Previous_Dealer_Contact__c,
                                                                        Previous_Dealer_Contact_Role__c
                                                                    FROM clcommon__Relationship__c
                                                                    WHERE Previous_Dealer_Contact__c =: accountObj.Id];

            System.assertEquals('Authorized Person', dummyRelationshipList[0].Previous_Dealer_Contact_Role__c, 'Dummy Relationship Creation Failed');
        } 
    }   
    @IsTest
    private static void testDeleteGM() {
        Id abRoleId = getReciprocalRoleId('General Manager');
        Account accountObj = getAccount('Ross Geller');
        clcommon__Relationship__c existingRelationshipObj = getRelationship(accountObj.Id);
        existingRelationshipObj.clcommon__Relationship__c = abRoleId;
        Database.update(existingRelationshipObj, true);
        User systemUserObj = ApplicationOriginationTestHelper.getSystemAdminUser();
        System.runAs(systemUserObj) {
            Test.startTest();
            UpdateDealerRelationAPI.deleteDealerRelation(accountObj.Id);
            Test.stopTest();
            List<clcommon__Relationship__c> oldRelationshipList = [SELECT Id,
                                                                        clcommon__Relationship__r.Name
                                                                    FROM clcommon__Relationship__c
                                                                    WHERE clcommon__Related_Entity__c =: accountObj.Id
                                                                    AND clcommon__Relationship__c =: abRoleId];
            System.assertEquals(0, oldRelationshipList.size(), 'Relationship Deletion Failed');

            List<clcommon__Relationship__c> dummyRelationshipList = [SELECT Id,
                                                                        Previous_Dealer__c,
                                                                        Previous_Dealer_Contact__c,
                                                                        Previous_Dealer_Contact_Role__c
                                                                    FROM clcommon__Relationship__c
                                                                    WHERE Previous_Dealer_Contact__c =: accountObj.Id];

            System.assertEquals('General Manager', dummyRelationshipList[0].Previous_Dealer_Contact_Role__c, 'Dummy Relationship Creation Failed');
        } 
    }   
    @IsTest
    private static void testDeletePC() {
        Id abRoleId = getReciprocalRoleId('Primary Contact');
        Account accountObj = getAccount('Ross Geller');
        clcommon__Relationship__c existingRelationshipObj = getRelationship(accountObj.Id);
        existingRelationshipObj.clcommon__Relationship__c = abRoleId;
        Database.update(existingRelationshipObj, true);
        User systemUserObj = ApplicationOriginationTestHelper.getSystemAdminUser();
        System.runAs(systemUserObj) {
            Test.startTest();
            UpdateDealerRelationAPI.deleteDealerRelation(accountObj.Id);
            Test.stopTest();
            List<clcommon__Relationship__c> oldRelationshipList = [SELECT Id,
                                                                        clcommon__Relationship__r.Name
                                                                    FROM clcommon__Relationship__c
                                                                    WHERE clcommon__Related_Entity__c =: accountObj.Id
                                                                    AND clcommon__Relationship__c =: abRoleId];
            System.assertEquals(0, oldRelationshipList.size(), 'Relationship Deletion Failed');

            List<clcommon__Relationship__c> dummyRelationshipList = [SELECT Id,
                                                                        Previous_Dealer__c,
                                                                        Previous_Dealer_Contact__c,
                                                                        Previous_Dealer_Contact_Role__c
                                                                    FROM clcommon__Relationship__c
                                                                    WHERE Previous_Dealer_Contact__c =: accountObj.Id];

            System.assertEquals('Primary Contact', dummyRelationshipList[0].Previous_Dealer_Contact_Role__c, 'Dummy Relationship Creation Failed');
        } 
    }   
    @IsTest
    private static void testDeleteInq() {
        Id abRoleId = getReciprocalRoleId('Inquiry');
        Account accountObj = getAccount('Ross Geller');
        clcommon__Relationship__c existingRelationshipObj = getRelationship(accountObj.Id);
        existingRelationshipObj.clcommon__Relationship__c = abRoleId;
        Database.update(existingRelationshipObj, true);
        User systemUserObj = ApplicationOriginationTestHelper.getSystemAdminUser();
        System.runAs(systemUserObj) {
            Test.startTest();
            UpdateDealerRelationAPI.deleteDealerRelation(accountObj.Id);
            Test.stopTest();
            List<clcommon__Relationship__c> oldRelationshipList = [SELECT Id,
                                                                        clcommon__Relationship__r.Name
                                                                    FROM clcommon__Relationship__c
                                                                    WHERE clcommon__Related_Entity__c =: accountObj.Id
                                                                    AND clcommon__Relationship__c =: abRoleId];
            System.assertEquals(0, oldRelationshipList.size(), 'Relationship Deletion Failed');

            List<clcommon__Relationship__c> dummyRelationshipList = [SELECT Id,
                                                                        Previous_Dealer__c,
                                                                        Previous_Dealer_Contact__c,
                                                                        Previous_Dealer_Contact_Role__c
                                                                    FROM clcommon__Relationship__c
                                                                    WHERE Previous_Dealer_Contact__c =: accountObj.Id];

            System.assertEquals('Inquiry', dummyRelationshipList[0].Previous_Dealer_Contact_Role__c, 'Dummy Relationship Creation Failed');
        } 
    }   
    @IsTest
    private static void testDeleteInqPlus() {
        Id abRoleId = getReciprocalRoleId('Inquiry Plus');
        Account accountObj = getAccount('Ross Geller');
        clcommon__Relationship__c existingRelationshipObj = getRelationship(accountObj.Id);
        existingRelationshipObj.clcommon__Relationship__c = abRoleId;
        Database.update(existingRelationshipObj, true);
        User systemUserObj = ApplicationOriginationTestHelper.getSystemAdminUser();
        System.runAs(systemUserObj) {
            Test.startTest();
            UpdateDealerRelationAPI.deleteDealerRelation(accountObj.Id);
            Test.stopTest();
            List<clcommon__Relationship__c> oldRelationshipList = [SELECT Id,
                                                                        clcommon__Relationship__r.Name
                                                                    FROM clcommon__Relationship__c
                                                                    WHERE clcommon__Related_Entity__c =: accountObj.Id
                                                                    AND clcommon__Relationship__c =: abRoleId];
            System.assertEquals(0, oldRelationshipList.size(), 'Relationship Deletion Failed');

            List<clcommon__Relationship__c> dummyRelationshipList = [SELECT Id,
                                                                        Previous_Dealer__c,
                                                                        Previous_Dealer_Contact__c,
                                                                        Previous_Dealer_Contact_Role__c
                                                                    FROM clcommon__Relationship__c
                                                                    WHERE Previous_Dealer_Contact__c =: accountObj.Id];

            System.assertEquals('Inquiry Plus', dummyRelationshipList[0].Previous_Dealer_Contact_Role__c, 'Dummy Relationship Creation Failed');
        } 
    }   
    @IsTest
    private static void testDeleteSA() {
        Id abRoleId = getReciprocalRoleId('Sales Agent');
        Account accountObj = getAccount('Ross Geller');
        clcommon__Relationship__c existingRelationshipObj = getRelationship(accountObj.Id);
        existingRelationshipObj.clcommon__Relationship__c = abRoleId;
        Database.update(existingRelationshipObj, true);
        User systemUserObj = ApplicationOriginationTestHelper.getSystemAdminUser();
        System.runAs(systemUserObj) {
            Test.startTest();
            UpdateDealerRelationAPI.deleteDealerRelation(accountObj.Id);
            Test.stopTest();
            List<clcommon__Relationship__c> oldRelationshipList = [SELECT Id,
                                                                        clcommon__Relationship__r.Name
                                                                    FROM clcommon__Relationship__c
                                                                    WHERE clcommon__Related_Entity__c =: accountObj.Id
                                                                    AND clcommon__Relationship__c =: abRoleId];
            System.assertEquals(0, oldRelationshipList.size(), 'Relationship Deletion Failed');

            List<clcommon__Relationship__c> dummyRelationshipList = [SELECT Id,
                                                                        Previous_Dealer__c,
                                                                        Previous_Dealer_Contact__c,
                                                                        Previous_Dealer_Contact_Role__c
                                                                    FROM clcommon__Relationship__c
                                                                    WHERE Previous_Dealer_Contact__c =: accountObj.Id];

            System.assertEquals('Sales Agent', dummyRelationshipList[0].Previous_Dealer_Contact_Role__c, 'Dummy Relationship Creation Failed');
        } 
    }   
    @IsTest
    private static void testDeleteSAPlus() {
        Id abRoleId = getReciprocalRoleId('Sales Agent Plus');
        Account accountObj = getAccount('Ross Geller');
        clcommon__Relationship__c existingRelationshipObj = getRelationship(accountObj.Id);
        existingRelationshipObj.clcommon__Relationship__c = abRoleId;
        Database.update(existingRelationshipObj, true);
        User systemUserObj = ApplicationOriginationTestHelper.getSystemAdminUser();
        System.runAs(systemUserObj) {
            Test.startTest();
            UpdateDealerRelationAPI.deleteDealerRelation(accountObj.Id);
            Test.stopTest();
            List<clcommon__Relationship__c> oldRelationshipList = [SELECT Id,
                                                                        clcommon__Relationship__r.Name
                                                                    FROM clcommon__Relationship__c
                                                                    WHERE clcommon__Related_Entity__c =: accountObj.Id
                                                                    AND clcommon__Relationship__c =: abRoleId];
            System.assertEquals(0, oldRelationshipList.size(), 'Relationship Deletion Failed');

            List<clcommon__Relationship__c> dummyRelationshipList = [SELECT Id,
                                                                        Previous_Dealer__c,
                                                                        Previous_Dealer_Contact__c,
                                                                        Previous_Dealer_Contact_Role__c
                                                                    FROM clcommon__Relationship__c
                                                                    WHERE Previous_Dealer_Contact__c =: accountObj.Id];

            System.assertEquals('Sales Agent Plus', dummyRelationshipList[0].Previous_Dealer_Contact_Role__c, 'Dummy Relationship Creation Failed');
        } 
    }   
    @IsTest
    private static void testDeleteSAA() {
        Id abRoleId = getReciprocalRoleId('Sales Agent Admin');
        Account accountObj = getAccount('Ross Geller');
        clcommon__Relationship__c existingRelationshipObj = getRelationship(accountObj.Id);
        existingRelationshipObj.clcommon__Relationship__c = abRoleId;
        Database.update(existingRelationshipObj, true);
        User systemUserObj = ApplicationOriginationTestHelper.getSystemAdminUser();
        System.runAs(systemUserObj) {
            Test.startTest();
            UpdateDealerRelationAPI.deleteDealerRelation(accountObj.Id);
            Test.stopTest();
            List<clcommon__Relationship__c> oldRelationshipList = [SELECT Id,
                                                                        clcommon__Relationship__r.Name
                                                                    FROM clcommon__Relationship__c
                                                                    WHERE clcommon__Related_Entity__c =: accountObj.Id
                                                                    AND clcommon__Relationship__c =: abRoleId];
            System.assertEquals(0, oldRelationshipList.size(), 'Relationship Deletion Failed');

            List<clcommon__Relationship__c> dummyRelationshipList = [SELECT Id,
                                                                        Previous_Dealer__c,
                                                                        Previous_Dealer_Contact__c,
                                                                        Previous_Dealer_Contact_Role__c
                                                                    FROM clcommon__Relationship__c
                                                                    WHERE Previous_Dealer_Contact__c =: accountObj.Id];

            System.assertEquals('Sales Agent Admin', dummyRelationshipList[0].Previous_Dealer_Contact_Role__c, 'Dummy Relationship Creation Failed');
        } 
    }   
    @IsTest
    private static void testDeletePA() {
        Id abRoleId = getReciprocalRoleId('Payment Administrator');
        Account accountObj = getAccount('Ross Geller');
        clcommon__Relationship__c existingRelationshipObj = getRelationship(accountObj.Id);
        existingRelationshipObj.clcommon__Relationship__c = abRoleId;
        Database.update(existingRelationshipObj, true);
        User systemUserObj = ApplicationOriginationTestHelper.getSystemAdminUser();
        System.runAs(systemUserObj) {
            Test.startTest();
            UpdateDealerRelationAPI.deleteDealerRelation(accountObj.Id);
            Test.stopTest();
            List<clcommon__Relationship__c> oldRelationshipList = [SELECT Id,
                                                                        clcommon__Relationship__r.Name
                                                                    FROM clcommon__Relationship__c
                                                                    WHERE clcommon__Related_Entity__c =: accountObj.Id
                                                                    AND clcommon__Relationship__c =: abRoleId];
            System.assertEquals(0, oldRelationshipList.size(), 'Relationship Deletion Failed');

            List<clcommon__Relationship__c> dummyRelationshipList = [SELECT Id,
                                                                        Previous_Dealer__c,
                                                                        Previous_Dealer_Contact__c,
                                                                        Previous_Dealer_Contact_Role__c
                                                                    FROM clcommon__Relationship__c
                                                                    WHERE Previous_Dealer_Contact__c =: accountObj.Id];

            System.assertEquals('Payment Administrator', dummyRelationshipList[0].Previous_Dealer_Contact_Role__c, 'Dummy Relationship Creation Failed');
        } 
    }   
    @IsTest
    private static void testCreateAccountShareRecord() {
        Id abRoleId = getReciprocalRoleId('AgriBusiness');
        Id clRecordTypeId = getRecordTypeId(new List<String>{'Certified Lender'});
        User clUser = TestClassHelper.getCertifiedLenderUser('Ross Geller');
        Account accountObj = getAccount('Ross Geller');
        Account dealerAccountObj = getAccount('Kisan Lessy');
        clcommon__Relationship__c existingRelationshipObj = getRelationship(accountObj.Id);
        existingRelationshipObj.clcommon__Relationship__c = abRoleId;
        Database.update(existingRelationshipObj, true);
        User systemUserObj = ApplicationOriginationTestHelper.getSystemAdminUser();
        System.runAs(systemUserObj) {
            Test.startTest();
            UpdateDealerRelationAPI.updateDealerRelation(accountObj.Id, dealerAccountObj.Id, new List<String>{clRecordTypeId});
            Test.stopTest();
            List<AccountShare> clAccountShare = [SELECT Id
                                                    FROM AccountShare
                                                    WHERE UserOrGroupId =: clUser.Id];
            System.assertEquals(1, clAccountShare.size(), 'Account Sharing Record Creation Failed');
        } 
    }
    @IsTest
    private static void testDeleteAccountShareRecord() {
        Id abRoleId = getReciprocalRoleId('Certified Lender');
        Id clRecordTypeId = getRecordTypeId(new List<String>{'Inquiry Plus'});
        User clUser = TestClassHelper.getCertifiedLenderUser('Ross Geller');
        Account accountObj = getAccount('Ross Geller');
        Account dealerAccountObj = getAccount('Kisan Loan');
        AccountShare accShareObj = new AccountShare(AccountAccessLevel = ConstantValues.ACCESS_LABEL_EDIT,
                                                    AccountId = accountObj.Id,
                                                    UserOrGroupId = clUser.Id,
                                                    OpportunityAccessLevel = ConstantValues.OPPORTUNITY_ACCESS_LEVEL);
        Database.insert(accShareObj, true);
        clcommon__Relationship__c existingRelationshipObj = getRelationship(accountObj.Id);
        existingRelationshipObj.clcommon__Relationship__c = abRoleId;
        Database.update(existingRelationshipObj, true);
        User systemUserObj = ApplicationOriginationTestHelper.getSystemAdminUser();
        System.runAs(systemUserObj) {
            Test.startTest();
            UpdateDealerRelationAPI.updateDealerRelation(accountObj.Id, dealerAccountObj.Id, new List<String>{clRecordTypeId});
            Test.stopTest();
            List<AccountShare> clAccountShare = [SELECT Id
                                                    FROM AccountShare
                                                    WHERE UserOrGroupId =: clUser.Id];
            System.assertEquals(0, clAccountShare.size(), 'Account Sharing Record Deletion Failed');
        } 
    }
    @IsTest
    private static void testDeleteExistingRelationship() {
        Id abRoleId = getReciprocalRoleId('Certified Lender');
        Id clRecordTypeId = getRecordTypeId(new List<String>{'Inquiry Plus'});
        Account accountObj = getAccount('Ross Geller');
        Account dealerAccountObj = getAccount('Kisan Lessy');
        clcommon__Relationship__c existingRelationshipObj = getRelationship(accountObj.Id);
        existingRelationshipObj.clcommon__Relationship__c = abRoleId;
        Database.update(existingRelationshipObj, true);
        User systemUserObj = ApplicationOriginationTestHelper.getSystemAdminUser();
        System.runAs(systemUserObj) {
            Test.startTest();
            UpdateDealerRelationAPI.updateDealerRelation(accountObj.Id, dealerAccountObj.Id, new List<String>{clRecordTypeId});
            Test.stopTest();
            List<clcommon__Relationship__c> oldRelationshipList = [SELECT Id,
                                                                        clcommon__Relationship__r.Name
                                                                    FROM clcommon__Relationship__c
                                                                    WHERE clcommon__Related_Entity__c =: accountObj.Id
                                                                    AND clcommon__Relationship__c =: abRoleId];
            System.assertEquals(0, oldRelationshipList.size(), 'Relationship Deletion Failed');
        }
    }
    @IsTest
    private static void testDeleteRelationshipSAAndSAAdmin() {
        Id abRoleId = getReciprocalRoleId('Sales Agent');
        Id clRecordTypeId = getRecordTypeId(new List<String>{'Sales Agent Plus'});
        Account accountObj = getAccount('Ross Geller');
        Account dealerAccountObj = getAccount('Kisan Lessy');
        clcommon__Relationship__c existingRelationshipObj = getRelationship(accountObj.Id);
        existingRelationshipObj.clcommon__Relationship__c = abRoleId;
        Database.update(existingRelationshipObj, true);
        User systemUserObj = ApplicationOriginationTestHelper.getSystemAdminUser();
        System.runAs(systemUserObj) {
            Test.startTest();
            UpdateDealerRelationAPI.updateDealerRelation(accountObj.Id, dealerAccountObj.Id, new List<String>{clRecordTypeId});
            Test.stopTest();
            List<clcommon__Relationship__c> saAdminRelationship = [SELECT Id,
                                                                        clcommon__Relationship__r.Name
                                                                    FROM clcommon__Relationship__c
                                                                    WHERE (clcommon__Related_Entity__c =: accountObj.Id
                                                                            OR clcommon__Entity__c =: accountObj.Id)
                                                                    AND clcommon__Relationship__r.Name = 'Related Sales Agent'];
            System.assertEquals(0, saAdminRelationship.size(), 'SA Admin Relationship Update Failed');
        }
    }
    @IsTest
    private static void testCreateRelationship() {
        Id abRoleId = getReciprocalRoleId('Certified Lender');
        Id clRecordTypeId = getRecordTypeId(new List<String>{'Inquiry Plus'});
        Account accountObj = getAccount('Ross Geller');
        Account dealerAccountObj = getAccount('Kisan Lessy');
        clcommon__Relationship__c existingRelationshipObj = getRelationship(accountObj.Id);
        existingRelationshipObj.clcommon__Relationship__c = abRoleId;
        Database.update(existingRelationshipObj, true);
        User systemUserObj = ApplicationOriginationTestHelper.getSystemAdminUser();
        System.runAs(systemUserObj) {
            Test.startTest();
            UpdateDealerRelationAPI.updateDealerRelation(accountObj.Id, dealerAccountObj.Id, new List<String>{clRecordTypeId});
            Test.stopTest();
            List<clcommon__Relationship__c> newRelationshipList = [SELECT Id,
                                                                        clcommon__Relationship__r.Name
                                                                    FROM clcommon__Relationship__c
                                                                    WHERE clcommon__Related_Entity__c =: accountObj.Id];
            System.assertEquals('Inquiry Plus', newRelationshipList[0].clcommon__Relationship__r.Name, 'Relationship Update Failed');
        }
    }
    @IsTest
    private static void testCreateDummyRelationship() {
        Id abRoleId = getReciprocalRoleId('Authorized Person');
        Id clRecordTypeId = getRecordTypeId(new List<String>{'Inquiry Plus'});
        Account accountObj = getAccount('Tony Stark');
        Account dealerAccountObj = getAccount('Kisan Lessy');
        clcommon__Relationship__c existingRelationshipObj = getRelationship(accountObj.Id);
        existingRelationshipObj.clcommon__Relationship__c = abRoleId;
        Database.update(existingRelationshipObj, true);
        User systemUserObj = ApplicationOriginationTestHelper.getSystemAdminUser();
        System.runAs(systemUserObj) {
            Test.startTest();
            UpdateDealerRelationAPI.updateDealerRelation(accountObj.Id, dealerAccountObj.Id, new List<String>{clRecordTypeId});
            Test.stopTest();
            List<clcommon__Relationship__c> dummyRelationshipList = [SELECT Id,
                                                                            Previous_Dealer__c,
                                                                            Previous_Dealer_Contact__c,
                                                                            Previous_Dealer_Contact_Role__c
                                                                        FROM clcommon__Relationship__c
                                                                        WHERE Previous_Dealer_Contact__c =: accountObj.Id];

            System.assertEquals('Authorized Person', dummyRelationshipList[0].Previous_Dealer_Contact_Role__c, 'Dummy Relationship Creation Failed');
        }
    }
    @IsTest
    private static void testEmailNotFoundException() {
        Id abRoleId = getReciprocalRoleId('Authorized Person');
        Id clRecordTypeId = getRecordTypeId(new List<String>{'Inquiry Plus'});
        Account accountObj = getAccount('Tony Stark');
        Contact contactObj = [SELECT Id,
                                    Email
                                FROM Contact
                                WHERE AccountId =: accountObj.Id];
        contactObj.Email = null;
        Database.update(contactObj, true);
        Account dealerAccountObj = getAccount('Kisan Lessy');
        clcommon__Relationship__c existingRelationshipObj = getRelationship(accountObj.Id);
        existingRelationshipObj.clcommon__Relationship__c = abRoleId;
        Database.update(existingRelationshipObj, true);
        User systemUserObj = ApplicationOriginationTestHelper.getSystemAdminUser();
        System.runAs(systemUserObj) {
            Test.startTest();
            try{
                UpdateDealerRelationAPI.updateDealerRelation(accountObj.Id, dealerAccountObj.Id, new List<String>{clRecordTypeId});
            }catch(AuraHandledException exceptionObj){
                System.assertEquals(ConstantValues.EMAIL_NOT_FOUND, exceptionObj.getMessage(), 'Assertion Failed');
            }
            Test.stopTest();
        }
    }
    @IsTest
    private static void testFSAException() {
        Id abRoleId = getReciprocalRoleId('Authorized Person');
        Id clRecordTypeId = getRecordTypeId(new List<String>{'Field Staff Agent'});
        Account accountObj = getAccount('Tony Stark');
        Account dealerAccountObj = getAccount('Kisan Loan');
        clcommon__Relationship__c existingRelationshipObj = getRelationship(accountObj.Id);
        existingRelationshipObj.clcommon__Relationship__c = abRoleId;
        Database.update(existingRelationshipObj, true);
        User systemUserObj = ApplicationOriginationTestHelper.getSystemAdminUser();
        System.runAs(systemUserObj) {
            Test.startTest();
            try{
                UpdateDealerRelationAPI.updateDealerRelation(accountObj.Id, dealerAccountObj.Id, new List<String>{clRecordTypeId});
            }catch(AuraHandledException exceptionObj){
                System.assertEquals(ConstantValues.SELECT_GMK_DEALER, exceptionObj.getMessage(), 'Assertion Failed');
            }
            Test.stopTest();
        }
    }
    @IsTest
    private static void testNoUpdationHappen() {
        Id abRoleId = getReciprocalRoleId('Authorized Person');
        Id clRecordTypeId = getRecordTypeId(new List<String>{'Authorized Person'});
        Account accountObj = getAccount('Tony Stark');
        Account dealerAccountObj = getAccount('Kisan Loan');
        clcommon__Relationship__c existingRelationshipObj = getRelationship(accountObj.Id);
        existingRelationshipObj.clcommon__Relationship__c = abRoleId;
        Database.update(existingRelationshipObj, true);
        User systemUserObj = ApplicationOriginationTestHelper.getSystemAdminUser();
        System.runAs(systemUserObj) {
            Test.startTest();
            UpdateDealerRelationAPI.updateDealerRelation(accountObj.Id, dealerAccountObj.Id, new List<String>{clRecordTypeId});
            Test.stopTest();
            List<clcommon__Relationship__c> dummyRelationshipList = [SELECT Id,
                                                                            Previous_Dealer__c,
                                                                            Previous_Dealer_Contact__c,
                                                                            Previous_Dealer_Contact_Role__c
                                                                        FROM clcommon__Relationship__c
                                                                        WHERE Previous_Dealer_Contact__c =: accountObj.Id];

            System.assertEquals(0, dummyRelationshipList.size(), 'Dummy Relationship Creation Passed');
        }
    }
}