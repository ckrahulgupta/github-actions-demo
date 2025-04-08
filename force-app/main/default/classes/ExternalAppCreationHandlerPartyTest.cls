/**
 * @description       : Test class for ExternalApplicationCreationHandler
 * @author            : Suraj Kumar | 12-09-2024
 * @group             : 
 * @last modified on  : 01-11-2025
 * @last modified by  : Suraj Kumar
**/
@IsTest
public with sharing class ExternalAppCreationHandlerPartyTest {
    /**
    * @description : test setup method for test data
    * @author Suraj Kumar | 12-09-2024 
    **/
    @testSetup
    static void setup(){
        clcommon__CL_Product__c clProductObj = ExternalAPITestHelper.createCLProductForApplication();
        Database.insert(clProductObj,true);

        clcommon__CL_Purpose__c clPurposeObj = ExternalAPITestHelper.createCLPurposeForApplication();
        Database.insert(clPurposeObj, true);

        genesis__Business_Information__c dealerBusinessInfoObj = ExternalAPITestHelper.createBusinessInfoForDealer();
        Database.insert(dealerBusinessInfoObj,true);

        Account dealerAccountObj = ExternalAPITestHelper.createDealerAccount(dealerBusinessInfoObj.id);
        Database.insert(dealerAccountObj,true);

        Account clAccountObj = ExternalAPITestHelper.createCLAccount(dealerBusinessInfoObj.id,dealerAccountObj.id);
        clAccountObj.ParentId = dealerAccountObj.Id;
        Database.insert(clAccountObj,true);

        Contact clContactObj = ExternalAPITestHelper.createCLContact(clAccountObj.id);
        Database.insert(clContactObj,true);

        User userObj = ExternalAPITestHelper.createCLUser(clContactObj.id);
        Database.insert(userObj,true);

        clcommon__Reciprocal_Role__c clRole = ExternalAPITestHelper.createCertifiedLenderRole();
        Database.insert(clRole,true);

        clcommon__Relationship__c clRelationship = ExternalAPITestHelper.createCLDealerRelationship(clRole,dealerAccountObj.Id,clAccountObj.id);
        Database.insert(clRelationship,true);

        Map<String, clcommon__Legal_Entity__c> legalEntityMap = ExternalAPITestHelper.createMultipleLegalEntity();
        // Creating Legal Entity
        List<clcommon__Legal_Entity__c> legalEntityList = new List<clcommon__Legal_Entity__c>{
            legalEntityMap.get(ExternalConstants.SOLE_PROP_ENTITY)
        };
        Database.Insert(legalEntityList, true);

        Account borrowerAccountObj = ExternalAPITestHelper.createSolePropAccount(legalEntityMap.get(ExternalConstants.SOLE_PROP_ENTITY), dealerBusinessInfoObj.Id);
        borrowerAccountObj.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Grower').getRecordTypeId();
        Database.insert(borrowerAccountObj,true);

        Contact borrowerContactObj = ExternalAPITestHelper.createBorrowerContact(borrowerAccountObj.Id);
        Database.insert(borrowerContactObj,true);

        clcommon__Party_Type__c borrowerPartyTypeObj = ExternalAPITestHelper.createPartyType('BORROWER');

        Database.insert(new List<clcommon__Party_Type__c>{
            ExternalAPITestHelper.createPartyType(ExternalConstants.FIELD_STAFF_AGENT_PARTY),
            ExternalAPITestHelper.createPartyType(ExternalConstants.CERTIFIED_LENDER_PARTY),
            ExternalAPITestHelper.createPartyType(ExternalConstants.CERTIFIED_LENDER_PLUS_PARTY),
            ExternalAPITestHelper.createPartyType(ExternalConstants.INQUIRY_PARTY),
            ExternalAPITestHelper.createPartyType(ExternalConstants.INQUIRY_PLUS_PARTY),
            ExternalAPITestHelper.createPartyType(ExternalConstants.PAYMENT_ADMINISTRATOR_PARTY),
            ExternalAPITestHelper.createPartyType('PRINCIPAL'),
            borrowerPartyTypeObj
        },true);

        Map<String,Id> paramForApplicationMap = new Map<String,Id>{
            'dealerAccountId' => dealerAccountObj.Id,
            'clProductId' => clProductObj.Id,
            'clPurposeId' => clPurposeObj.Id,
            'borrowerAccountId' => borrowerAccountObj.Id,
            'borrowerContactId' => borrowerContactObj.Id,
            'certifiedLender' =>  clAccountObj.Id
        };
        genesis__Applications__c applicationObj = ExternalAPITestHelper.createCurrCropYearApplication(paramForApplicationMap);
        Database.insert(applicationObj, true);

        clcommon__document_category__c docCategoryObj = ExternalAPITestHelper.createDocCategory(applicationObj.id,'Signed Credit Agreement');
        Database.insert(docCategoryObj,true);

        // Creating Principal Party for current application
        Map<String,Id> paramForborrowerPartyMap = new Map<String,Id>{
            'accountId' => borrowerAccountObj.Id,
            'contactId' => borrowerContactObj.Id,
            'partyTypeId' => borrowerPartyTypeObj.Id,
            'applicationId' => applicationObj.Id
        };

        clcommon__Party__c borrowerPartyObj = ExternalAPITestHelper.createParty(paramForborrowerPartyMap);
        Database.insert(borrowerPartyObj,true);

        // Creating department for task
        genesis__Department__c departmentObj = ExternalAPITestHelper.createDepartment('Credit');
        Database.insert(departmentObj,true);

        Task taskObj = ExternalAPITestHelper.createTask(applicationObj.id, 'Signed Credit Agreement');
        Database.insert(taskObj,true);

        CFA_Configuration__c cifNumber = ExternalAPITestHelper.createCIFNumber();
        Database.insert(cifNumber,true);

        genesis__Task_Setup__c taskSetupObj = ExternalAPITestHelper.createTaskSetup('Entity Documents');
        Database.insert(taskSetupObj,true);
    }

    /**
    * @description : Test method to test linkDealerPartyToApplication
    * @author Suraj Kumar | 12-06-2024 
    **/
    @isTest 
    private static void testLinkDealerPartyToApplication(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c newApplicationObj = new genesis__Applications__c();
        List<Account> dealerAccountList = [SELECT Id FROM Account WHERE Name = 'Kisan Loan' LIMIT 1];
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicationCreationHandler.linkDealerPartyToApplication(newApplicationObj, dealerAccountList[0]);
            List<clcommon__Party__c> dealerPartyList = [SELECT Id
                                                                FROM clcommon__Party__c
                                                                WHERE clcommon__Account__c =: dealerAccountList[0].Id];
            System.assert(dealerPartyList.size()>0, 'Assertion Failed');
            Test.stopTest();
        }
    }
    /**
    * @description : Test method to test linkDealerPartyToApplication without dealer relationship
    * @author Suraj Kumar | 12-06-2024 
    **/
    @isTest 
    private static void testLinkDealerPartyWithoutRelationship(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c newApplicationObj = new genesis__Applications__c();
        List<Account> dealerAccountList = [SELECT Id FROM Account WHERE Name = 'Kisan Loan' LIMIT 1];
        List<clcommon__Relationship__c> relationshipList = [SELECT Id FROM clcommon__Relationship__c];
        Database.delete(relationshipList,true);
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationCreationHandler.linkDealerPartyToApplication(newApplicationObj, dealerAccountList[0]);
            } catch (Exception exceptionObj) {
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.SOMETHING_WENT_WRONG, exceptionObj.getMessage(), 'Assertion Failed');
            }
            System.assertEquals(true, isExceptionThrown, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test linkDealerPartyToApplication, createDealerRelationParties,createDealerRelationSharingRecords for FSA relationship
    * @author Suraj Kumar | 12-06-2024 
    **/
    @isTest 
    private static void testLinkDealerFSAParty(){
        List<User> userList = ExternalAPITestHelper.getSystemAdminUser();
        List<genesis__Applications__c> newApplicationList = [SELECT Id FROM genesis__Applications__c LIMIT 1];
        List<Account> dealerAccountList = [SELECT Id FROM Account WHERE Name = 'Kisan Loan' LIMIT 1];
        List<clcommon__Reciprocal_Role__c> roleList = [SELECT Id, Name FROM clcommon__Reciprocal_Role__c LIMIT 1];
        roleList[0].Name = ExternalConstants.FIELD_STAFF_AGENT;
        Database.update(roleList[0],true);
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicationCreationHandler.linkDealerPartyToApplication(newApplicationList[0], dealerAccountList[0]);
            List<clcommon__Party__c> fsaPartyList = [SELECT Id
                                                            FROM clcommon__Party__c
                                                            WHERE clcommon__Type__r.name =: ExternalConstants.FIELD_STAFF_AGENT_PARTY];
            List<genesis__Applications__Share> appShareList = [SELECT Id FROM genesis__Applications__Share];
            List<clcommon__Document_Category__Share> docCategoryShareList = [SELECT Id FROM clcommon__Document_Category__Share];
            System.assert(appShareList.size()>0, 'Assertion Failed');
            System.assert(docCategoryShareList.size()>0, 'Assertion Failed');
            System.assert(fsaPartyList.size()>0, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test linkDealerPartyToApplication, createDealerRelationParties,createDealerRelationSharingRecords for CL relationship
    * @author Suraj Kumar | 12-06-2024 
    **/
    @isTest 
    private static void testLinkDealerCLParty(){
        List<User> userList = ExternalAPITestHelper.getSystemAdminUser();
        List<genesis__Applications__c> newApplicationList = [SELECT Id FROM genesis__Applications__c LIMIT 1];
        List<Account> dealerAccountList = [SELECT Id FROM Account WHERE Name = 'Kisan Loan' LIMIT 1];
        List<clcommon__Reciprocal_Role__c> roleList = [SELECT Id, Name FROM clcommon__Reciprocal_Role__c LIMIT 1];
        roleList[0].Name = ExternalConstants.CERTIFIED_LENDER;
        Database.update(roleList[0],true);
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicationCreationHandler.linkDealerPartyToApplication(newApplicationList[0], dealerAccountList[0]);
            List<clcommon__Party__c> clPartyList = [SELECT Id
                                                            FROM clcommon__Party__c
                                                            WHERE clcommon__Type__r.name =: ExternalConstants.CERTIFIED_LENDER_PARTY];
            List<genesis__Applications__Share> appShareList = [SELECT Id FROM genesis__Applications__Share];
            List<clcommon__Document_Category__Share> docCategoryShareList = [SELECT Id FROM clcommon__Document_Category__Share];
            System.assert(appShareList.size()>0, 'Assertion Failed');
            System.assert(docCategoryShareList.size()>0, 'Assertion Failed');
            System.assert(clPartyList.size()>0, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test linkDealerPartyToApplication, createDealerRelationParties,createDealerRelationSharingRecords for CL Plus relationship
    * @author Suraj Kumar | 12-06-2024 
    **/
    @isTest 
    private static void testLinkDealerCLPlusParty(){
        List<User> userList = ExternalAPITestHelper.getSystemAdminUser();
        List<genesis__Applications__c> newApplicationList = [SELECT Id FROM genesis__Applications__c LIMIT 1];
        List<Account> dealerAccountList = [SELECT Id FROM Account WHERE Name = 'Kisan Loan' LIMIT 1];
        List<clcommon__Reciprocal_Role__c> roleList = [SELECT Id, Name FROM clcommon__Reciprocal_Role__c LIMIT 1];
        roleList[0].Name = ExternalConstants.CERTIFIED_LENDER_PLUS;
        Database.update(roleList[0],true);
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicationCreationHandler.linkDealerPartyToApplication(newApplicationList[0], dealerAccountList[0]);
            List<clcommon__Party__c> clPlusPartyList = [SELECT Id
                                                            FROM clcommon__Party__c
                                                            WHERE clcommon__Type__r.name =: ExternalConstants.CERTIFIED_LENDER_PLUS_PARTY];
            List<genesis__Applications__Share> appShareList = [SELECT Id FROM genesis__Applications__Share];
            List<clcommon__Document_Category__Share> docCategoryShareList = [SELECT Id FROM clcommon__Document_Category__Share];
            System.assert(appShareList.size()>0, 'Assertion Failed');
            System.assert(docCategoryShareList.size()>0, 'Assertion Failed');
            System.assert(clPlusPartyList.size()>0, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test linkDealerPartyToApplication, createDealerRelationParties,createDealerRelationSharingRecords for Inquiry relationship
    * @author Suraj Kumar | 12-06-2024 
    **/
    @isTest 
    private static void testLinkDealerInquiryParty(){
        List<User> userList = ExternalAPITestHelper.getSystemAdminUser();
        List<genesis__Applications__c> newApplicationList = [SELECT Id FROM genesis__Applications__c LIMIT 1];
        List<Account> dealerAccountList = [SELECT Id FROM Account WHERE Name = 'Kisan Loan' LIMIT 1];
        List<clcommon__Reciprocal_Role__c> roleList = [SELECT Id, Name FROM clcommon__Reciprocal_Role__c LIMIT 1];
        roleList[0].Name = ExternalConstants.INQUIRY;
        Database.update(roleList[0],true);
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicationCreationHandler.linkDealerPartyToApplication(newApplicationList[0], dealerAccountList[0]);
            List<clcommon__Party__c> inqPartyList = [SELECT Id
                                                            FROM clcommon__Party__c
                                                            WHERE clcommon__Type__r.name =: ExternalConstants.INQUIRY_PARTY];
            List<genesis__Applications__Share> appShareList = [SELECT Id FROM genesis__Applications__Share];
            List<clcommon__Document_Category__Share> docCategoryShareList = [SELECT Id FROM clcommon__Document_Category__Share];
            System.assert(appShareList.size()>0, 'Assertion Failed');
            System.assert(docCategoryShareList.size()>0, 'Assertion Failed');
            System.assert(inqPartyList.size()>0, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test linkDealerPartyToApplication, createDealerRelationParties,createDealerRelationSharingRecords for Inquiry plus relationship
    * @author Suraj Kumar | 12-06-2024 
    **/
    @isTest 
    private static void testLinkDealerInquiryPlusParty(){
        List<User> userList = ExternalAPITestHelper.getSystemAdminUser();
        List<genesis__Applications__c> newApplicationList = [SELECT Id FROM genesis__Applications__c LIMIT 1];
        List<Account> dealerAccountList = [SELECT Id FROM Account WHERE Name = 'Kisan Loan' LIMIT 1];
        List<clcommon__Reciprocal_Role__c> roleList = [SELECT Id, Name FROM clcommon__Reciprocal_Role__c LIMIT 1];
        roleList[0].Name = ExternalConstants.INQUIRY_PLUS;
        Database.update(roleList[0],true);
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicationCreationHandler.linkDealerPartyToApplication(newApplicationList[0], dealerAccountList[0]);
            List<clcommon__Party__c> inqPlusPartyList = [SELECT Id
                                                            FROM clcommon__Party__c
                                                            WHERE clcommon__Type__r.name =: ExternalConstants.INQUIRY_PLUS_PARTY];
            List<genesis__Applications__Share> appShareList = [SELECT Id FROM genesis__Applications__Share];
            List<clcommon__Document_Category__Share> docCategoryShareList = [SELECT Id FROM clcommon__Document_Category__Share];
            System.assert(appShareList.size()>0, 'Assertion Failed');
            System.assert(docCategoryShareList.size()>0, 'Assertion Failed');
            System.assert(inqPlusPartyList.size()>0, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test linkDealerPartyToApplication, createDealerRelationParties, createDealerRelationSharingRecords for Payment Admin relationship
    * @author Suraj Kumar | 12-06-2024 
    **/
    @isTest 
    private static void testLinkDealerPAParty(){
        List<User> userList = ExternalAPITestHelper.getSystemAdminUser();
        List<genesis__Applications__c> newApplicationList = [SELECT Id FROM genesis__Applications__c LIMIT 1];
        List<Account> dealerAccountList = [SELECT Id FROM Account WHERE Name = 'Kisan Loan' LIMIT 1];
        List<clcommon__Reciprocal_Role__c> roleList = [SELECT Id, Name FROM clcommon__Reciprocal_Role__c LIMIT 1];
        roleList[0].Name = ExternalConstants.PAYMENT_ADMINISTRATOR;
        Database.update(roleList[0],true);
        List<Account> paAccountList = [SELECT Id, RecordTypeId FROM Account WHERE Name = 'Ross Geller' LIMIT 1];
        paAccountList[0].RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get(ExternalConstants.PAYMENT_ADMINISTRATOR).getRecordTypeId();
        Database.update(paAccountList[0],true);
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicationCreationHandler.linkDealerPartyToApplication(newApplicationList[0], dealerAccountList[0]);
            List<clcommon__Party__c> paPartyList = [SELECT Id
                                                            FROM clcommon__Party__c
                                                            WHERE clcommon__Type__r.name =: ExternalConstants.PAYMENT_ADMINISTRATOR_PARTY];
            List<genesis__Applications__Share> appShareList = [SELECT Id FROM genesis__Applications__Share];
            List<clcommon__Document_Category__Share> docCategoryShareList = [SELECT Id FROM clcommon__Document_Category__Share];
            System.assert(appShareList.size()==0, 'Assertion Failed');
            System.assert(docCategoryShareList.size()==0, 'Assertion Failed');
            System.assert(paPartyList.size()>0, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test createDealerRelationParties for Sales Agent relationship
    * @author Suraj Kumar | 12-06-2024 
    **/
    @isTest 
    private static void testLinkDealerSAParty(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        List<genesis__Applications__c> newApplicationList = [SELECT Id FROM genesis__Applications__c LIMIT 1];
        List<Account> dealerAccountList = [SELECT Id FROM Account WHERE Name = 'Kisan Loan' LIMIT 1];
        List<clcommon__Reciprocal_Role__c> roleList = [SELECT Id, Name FROM clcommon__Reciprocal_Role__c LIMIT 1];
        roleList[0].Name = ExternalConstants.SALES_AGENT;
        Database.update(roleList[0],true);
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicationCreationHandler.linkDealerPartyToApplication(newApplicationList[0], dealerAccountList[0]);
            List<clcommon__Party__c> saPartyList = [SELECT Id
                                                            FROM clcommon__Party__c
                                                            WHERE clcommon__Type__r.name =: ExternalConstants.SALES_AGENT_PARTY];
            System.assert(saPartyList.size()==0, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test createPrincipalParty
    * @author Suraj Kumar | 12-06-2024 
    **/
    @isTest 
    private static void testCreatePrincipalParty(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        List<genesis__Applications__c> applicationList = [SELECT Id FROM genesis__Applications__c LIMIT 1];
        List<Contact> contactList = [SELECT Id, AccountId FROM Contact WHERE Account.Name = 'Ross Geller' LIMIT 1];
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicationCreationHandler.createPrincipalParty(applicationList[0], contactList[0]);
            List<clcommon__Party__c> partyList = [SELECT Id FROM clcommon__Party__c WHERE clcommon__Contact__c =:contactList[0].Id];
            System.assertEquals(1,partyList.size(), 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test createPrincipalParty having three parameters
    * @author Suraj Kumar | 12-06-2024 
    **/
    @isTest 
    private static void testCreatePrincipalPartyOverload(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        List<genesis__Applications__c> applicationList = [SELECT Id FROM genesis__Applications__c LIMIT 1];
        List<Account> principalAccountList = [SELECT Id FROM Account WHERE Name = 'Jasmine Albin' LIMIT 1];
        List<Contact> principalContactList = [SELECT Id FROM Contact WHERE AccountId = :principalAccountList[0].Id];
        Map<String,Object> paramMap = new Map<String,Object>{
            ExternalConstants.HOME_PHONE_KEY => '1234567890',
            ExternalConstants.PHONE_NUMBER_KEY => '1111111111',
            ExternalConstants.WORK_PHONE_KEY => '2222222222',
            ExternalConstants.PRINCIPAL_ACCOUNT_ID => principalAccountList[0].Id,
            ExternalConstants.PRINCIPAL_CONTACT_ID => principalContactList[0].Id
        };
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicationCreationHandler.createPrincipalParty(applicationList[0], paramMap, new Dealer_Applicant_Relationship__c());
            List<clcommon__Party__c> partyList = [SELECT Id, 
                                                            Home_Number__c, 
                                                            Mobile_Number__c,
                                                            Work_Number__c
                                                        FROM clcommon__Party__c 
                                                        WHERE clcommon__Type__r.Name =: ExternalConstants.PRINCIPAL_PARTY 
                                                        AND genesis__Application__c =: applicationList[0].Id];
            System.assertEquals('1111111111',partyList[0].Mobile_Number__c, 'Assertion Failed');
            System.assertEquals('2222222222',partyList[0].Work_Number__c, 'Assertion Failed');
            System.assertEquals('1234567890',partyList[0].Home_Number__c, 'Assertion Failed');
            Test.stopTest();
        }
    }
}