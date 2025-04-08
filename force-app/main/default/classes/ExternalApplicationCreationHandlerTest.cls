/**
 * @description       : Test class for ExternalApplicationCreationHandler
 * @author            : Suraj Kumar | 12-06-2024
 * @group             : 
 * @last modified on  : 03-25-2025
 * @last modified by  : Rakesh Saraf
**/
@IsTest
public with sharing class ExternalApplicationCreationHandlerTest {

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
    * @description : Method to get applications
    * @author Suraj Kumar | 01-11-2025 
    * @return genesis__Applications__c 
    **/
    private static genesis__Applications__c getApplication(){
        List<genesis__Applications__c> applicationList = [SELECT Id, 
                                                                genesis__Account__c, 
                                                                genesis__Contact__c, 
                                                                Dealer_Name__c 
                                                            FROM genesis__Applications__c 
                                                            LIMIT 1];
        return applicationList[0];
    }

    /**
    * @description : Test method to test addDefaultValuesToApplication
    * @author Suraj Kumar | 12-06-2024 
    **/
    @isTest 
    private static void testAddDefaultValuesToApplication(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c newApplicationObj = new genesis__Applications__c();
        List<clcommon__Cl_Product__c> clProductList = [SELECT Id
                                                            FROM clcommon__Cl_Product__c 
                                                            WHERE clcommon__Product_Name__c =: ExternalConstants.SIMPLIFY_TYPE];
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicationCreationHandler.addDefaultValuesToApplication(newApplicationObj);
            System.assertEquals(ExternalConstants.TERM, newApplicationObj.genesis__Term__c, 'Assertion Failed');
            System.assertEquals(ExternalConstants.INTEREST_RATE, newApplicationObj.genesis__Interest_Rate__c, 'Assertion Failed');
            System.assertEquals(ExternalConstants.RATE_CARD_STRING, newApplicationObj.genesis__Pricing_Method__c, 'Assertion Failed');
            System.assertEquals(ExternalConstants.LOAN_TYPE, newApplicationObj.genesis__Product_Type__c, 'Assertion Failed');
            System.assertEquals(clProductList[0].Id, newApplicationObj.genesis__CL_Product__c, 'Assertion Failed');
            Test.stopTest();
        }
    }

     /**
    * @description : Test method to test addDefaultValuesToApplication with genesis__Term__c and genesis__Interest_Rate__c
    * @author Suraj Kumar | 12-06-2024 
    **/
    @isTest 
    private static void testAppWithDefaultTermAndInterest(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c newApplicationObj = new genesis__Applications__c();
        newApplicationObj.genesis__Term__c = 10;
        newApplicationObj.genesis__Interest_Rate__c = 8;
        List<clcommon__Cl_Product__c> clProductList = [SELECT Id
                                                            FROM clcommon__Cl_Product__c 
                                                            WHERE clcommon__Product_Name__c =: ExternalConstants.SIMPLIFY_TYPE];
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicationCreationHandler.addDefaultValuesToApplication(newApplicationObj);
            System.assert(ExternalConstants.TERM != newApplicationObj.genesis__Term__c, 'Assertion Failed');
            System.assert(ExternalConstants.INTEREST_RATE != newApplicationObj.genesis__Interest_Rate__c, 'Assertion Failed');
            System.assertEquals(ExternalConstants.RATE_CARD_STRING, newApplicationObj.genesis__Pricing_Method__c, 'Assertion Failed');
            System.assertEquals(ExternalConstants.LOAN_TYPE, newApplicationObj.genesis__Product_Type__c, 'Assertion Failed');
            System.assertEquals(clProductList[0].Id, newApplicationObj.genesis__CL_Product__c, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test addDefaultValuesToApplication without clcommon__Cl_Product__c
    * @author Suraj Kumar | 12-06-2024 
    **/
    @isTest 
    private static void testAppWithoutClProduct(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        List<clcommon__Cl_Product__c> clProductList = [SELECT Id
                                                            FROM clcommon__Cl_Product__c];
        Database.delete(clProductList,true);
        genesis__Applications__c newApplicationObj = new genesis__Applications__c();
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationCreationHandler.addDefaultValuesToApplication(newApplicationObj);
            } catch(Exception exceptionObj){
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.SOMETHING_WENT_WRONG, exceptionObj.getMessage(), 'Assertion Failed');
            }
            System.assertEquals(true, isExceptionThrown, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test createDealerRelationParties without dealer relationship accountId list
    * @author Suraj Kumar | 12-06-2024 
    **/
    @isTest 
    private static void testCreateDealerRelationParties(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Boolean isExceptionThrown = false;
        System.runAs(userList[0]){
            Test.startTest();
            try {
                ExternalApplicationCreationHandler.createDealerRelationParties(new Map<String,Object>{
                    'dealerRelationAccIdList' => new List<String>()
                });
            } catch (Exception exceptionObj) {
                isExceptionThrown = true;
                System.assertEquals(ExternalConstants.SOMETHING_WENT_WRONG, exceptionObj.getMessage(), 'Assertion Failed');
            }
            System.assertEquals(true, isExceptionThrown, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test setPartyType for same relationship type 
    * @author Suraj Kumar | 12-06-2024 
    **/
    @isTest 
    private static void testSetPartyTypeSameRelationship(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        clcommon__party__c partyObj = new clcommon__party__c();
        Map<String,Object> paramMap = new Map<String,Object>{
            'dealerRelationshipName' => ExternalConstants.CERTIFIED_LENDER,
            'relationshipName' => ExternalConstants.CERTIFIED_LENDER,
            'partyTypeName' => ExternalConstants.CERTIFIED_LENDER_PARTY,
            'relationParty' => partyObj
        };
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicationCreationHandler.setPartyType(paramMap);
            System.assertEquals(ExternalConstants.CERTIFIED_LENDER_PARTY, partyObj.clcommon__Party_Types__c, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test setPartyType for different relationship type 
    * @author Suraj Kumar | 12-06-2024 
    **/
    @isTest 
    private static void testSetPartyTypeDiffRelationship(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        clcommon__party__c partyObj = new clcommon__party__c();
        Map<String,Object> paramMap = new Map<String,Object>{
            'dealerRelationshipName' => ExternalConstants.SALES_AGENT,
            'relationshipName' => ExternalConstants.CERTIFIED_LENDER,
            'partyTypeName' => ExternalConstants.CERTIFIED_LENDER_PARTY,
            'relationParty' => partyObj
        };
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicationCreationHandler.setPartyType(paramMap);
            System.assertEquals(null, partyObj.clcommon__Party_Types__c, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test createDealerRelationSharingRecords for Different dealerRelationAccIdList
    * @author Suraj Kumar | 12-06-2024 
    **/
    @isTest 
    private static void testSharingRecordsMismatchAccId(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicationCreationHandler.createDealerRelationSharingRecords(applicationObj.Id, new List<String>{'testd'});
            List<genesis__Applications__Share> appShareList = [SELECT Id FROM genesis__Applications__Share];
            List<clcommon__Document_Category__Share> docCategoryShareList = [SELECT Id FROM clcommon__Document_Category__Share];
            System.assertEquals(0,appShareList.size(), 'Assertion Failed');
            System.assertEquals(0,docCategoryShareList.size(), 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test createDealerRelationSharingRecords for Different dealerRelationAccout
    * @author Suraj Kumar | 12-06-2024 
    **/
    @isTest 
    private static void testSharingRecordsMismatchRecordType(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        List<Account> clAccountList = [SELECT Id, RecordTypeId FROM Account WHERE Name = 'Ross Geller' LIMIT 1];
        clAccountList[0].RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByName().get(ExternalConstants.PAYMENT_ADMINISTRATOR).getRecordTypeId();
        Database.update(clAccountList[0],true);
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicationCreationHandler.createDealerRelationSharingRecords(applicationObj.Id, new List<String>{clAccountList[0].Id});
            List<genesis__Applications__Share> appShareList = [SELECT Id FROM genesis__Applications__Share];
            List<clcommon__Document_Category__Share> docCategoryShareList = [SELECT Id FROM clcommon__Document_Category__Share];
            System.assertEquals(0,appShareList.size(), 'Assertion Failed');
            System.assertEquals(0,docCategoryShareList.size(), 'Assertion Failed');
            Test.stopTest();
        }
    }
    /**
    * @description : Test method to test createDealerRelationSharingRecords without clcommon__Document_Category__c
    * @author Suraj Kumar | 12-06-2024 
    **/
    @isTest 
    private static void testSharingRecordsWithoutDocCategory(){
        List<User> userList = ExternalAPITestHelper.getSystemAdminUser();
        genesis__Applications__c applicationObj = getApplication();
        List<Account> clAccountList = [SELECT Id, RecordTypeId FROM Account WHERE Name = 'Ross Geller' LIMIT 1];
        List<clcommon__Document_Category__c> documentCategoriesList = [SELECT Id 
                                                                            FROM clcommon__Document_Category__c 
                                                                            WHERE genesis__Application__c = :applicationObj.Id];
        Database.delete(documentCategoriesList,true);
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicationCreationHandler.createDealerRelationSharingRecords(applicationObj.Id, new List<String>{clAccountList[0].Id});
            List<genesis__Applications__Share> appShareList = [SELECT Id FROM genesis__Applications__Share];
            List<clcommon__Document_Category__Share> docCategoryShareList = [SELECT Id FROM clcommon__Document_Category__Share];
            System.assert(appShareList.size()>0, 'Assertion Failed');
            System.assertEquals(0,docCategoryShareList.size(), 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test updateBorrowerDetails having existing borrower party
    * @author Suraj Kumar | 12-06-2024 
    **/
    @isTest 
    private static void testExistingBorrowerParty(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        Map<String,Object> paramMap = new Map<String,Object>{
            ExternalConstants.HOME_PHONE_KEY => '1234567890',
            ExternalConstants.PHONE_NUMBER_KEY => '1111111111',
            ExternalConstants.WORK_PHONE_KEY => '2222222222'
        };
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicationCreationHandler.updateBorrowerDetails(applicationObj, paramMap, new Dealer_Applicant_Relationship__c());
            List<clcommon__Party__c> partyList = [SELECT Id, 
                                                            Home_Number__c, 
                                                            Mobile_Number__c,
                                                            Work_Number__c
                                                        FROM clcommon__Party__c 
                                                        WHERE clcommon__Type__r.Name =: ExternalConstants.BORROWER_PARTY 
                                                        AND genesis__Application__c =: applicationObj.Id];
            System.assertEquals('1111111111',partyList[0].Mobile_Number__c, 'Assertion Failed');
            System.assertEquals('2222222222',partyList[0].Work_Number__c, 'Assertion Failed');
            System.assertEquals('1234567890',partyList[0].Home_Number__c, 'Assertion Failed');
            Test.stopTest();
        }
    }

     /**
    * @description : Test method to test updateBorrowerDetails not having borrower party
    * @author Suraj Kumar | 12-06-2024 
    **/
    @isTest 
    private static void testUpdateBorrowerDetails(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        List<clcommon__Party__c> borrowerPartyList = [SELECT Id, 
                                                        genesis__Application__c
                                                    FROM clcommon__Party__c 
                                                    WHERE clcommon__Type__r.Name =: ExternalConstants.BORROWER_PARTY 
                                                    AND genesis__Application__c =: applicationObj.Id];
        borrowerPartyList[0].genesis__Application__c = null;
        Database.update(borrowerPartyList,true);
        Map<String,Object> paramMap = new Map<String,Object>{
            ExternalConstants.HOME_PHONE_KEY => '1234567890',
            ExternalConstants.PHONE_NUMBER_KEY => '1111111111',
            ExternalConstants.WORK_PHONE_KEY => '2222222222'
        };
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicationCreationHandler.updateBorrowerDetails(applicationObj, paramMap, new Dealer_Applicant_Relationship__c());
            List<clcommon__Party__c> partyList = [SELECT Id, 
                                                            Home_Number__c, 
                                                            Mobile_Number__c,
                                                            Work_Number__c
                                                        FROM clcommon__Party__c 
                                                        WHERE clcommon__Type__r.Name =: ExternalConstants.BORROWER_PARTY 
                                                        AND genesis__Application__c =: applicationObj.Id];
            System.assertEquals('1111111111',partyList[0].Mobile_Number__c, 'Assertion Failed');
            System.assertEquals('2222222222',partyList[0].Work_Number__c, 'Assertion Failed');
            System.assertEquals('1234567890',partyList[0].Home_Number__c, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test updateCifForAccount for new account
    * @author Suraj Kumar | 12-06-2024 
    **/ 
    @isTest 
    private static void testUpdateCifNewAccount(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Account accountObj = new Account();
        accountObj.Name = 'Test Account';
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicationCreationHandler.updateCifForAccount(accountObj, 'CFA');
            System.assert(accountObj.CIF_Number__c != null, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test updateCifForAccount for existing account having CIF
    * @author Suraj Kumar | 12-06-2024 
    **/ 
    @isTest 
    private static void testUpdateCifExistingAccount(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        List<Account> accountList = [SELECT Id FROM Account WHERE Name = 'Kisan Loan' LIMIT 1];
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicationCreationHandler.updateCifForAccount(accountList[0], 'CFA');
            System.assert(accountList[0].CIF_Number__c != null, 'Assertion Failed');
            Test.stopTest();
        }
    }

     /**
    * @description : Test method to test updateCifForAccount for existing account having CIF null
    * @author Suraj Kumar | 12-06-2024 
    **/ 
    @isTest 
    private static void testUpdateAccountHavingNullCif(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        List<Account> accountList = [SELECT Id, CIF_Number__c FROM Account WHERE Name = 'Kisan Loan' LIMIT 1];
        accountList[0].CIF_Number__c = null;
        Database.update(accountList[0],true);
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicationCreationHandler.updateCifForAccount(accountList[0], 'CFA');
            System.assert(accountList[0].CIF_Number__c != null, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test assignNewCIF for Growmark
    * @author Suraj Kumar | 12-06-2024 
    **/ 
    @isTest 
    private static void testAssignNewCIFGrowmark(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        List<CFA_Configuration__c> latestCIFList = [SELECT CIF_Number__c,
                                                    Growmark_CIF_Number__c
                                              FROM CFA_Configuration__c LIMIT 1];
        Account accountObj = new Account();
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicationCreationHandler.assignNewCIF(accountObj, 'Growmark',latestCIFList[0]);
            System.assert(accountObj.CIF_Number__c != null, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test assignNewCIF for CFA
    * @author Suraj Kumar | 12-06-2024 
    **/ 
    @isTest 
    private static void testAssignNewCIFCFA(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        List<CFA_Configuration__c> latestCIFList = [SELECT CIF_Number__c,
                                                    Growmark_CIF_Number__c
                                              FROM CFA_Configuration__c LIMIT 1];
        Account accountObj = new Account();
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicationCreationHandler.assignNewCIF(accountObj, 'CFA',latestCIFList[0]);
            System.assert(accountObj.CIF_Number__c != null, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test assignCIFtoCoapplicants for Growmark new coapplicant
    * @author Suraj Kumar | 12-06-2024 
    **/ 
    @isTest 
    private static void testAssignCIFtoNewCoappGrowmark(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Account accountObj = new Account();
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicationCreationHandler.assignCIFtoCoapplicants(new List<Account>{accountObj}, 'Growmark');
            System.assert(accountObj.CIF_Number__c != null, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test assignCIFtoCoapplicants for Growmark coapplicant having cif null
    * @author Suraj Kumar | 12-06-2024 
    **/ 
    @isTest 
    private static void testExistingCoappHavingNullCIFGrowmark(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        List<Account> accountList = [SELECT Id, CIF_Number__c FROM Account WHERE Name = 'Kisan Loan' LIMIT 1];
        accountList[0].CIF_Number__c = null;
        Database.update(accountList[0],true);
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicationCreationHandler.assignCIFtoCoapplicants(new List<Account>{accountList[0]}, 'Growmark');
            System.assert(accountList[0].CIF_Number__c != null, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test assignCIFtoCoapplicants for Growmark coapplicant having cif blank
    * @author Suraj Kumar | 12-06-2024 
    **/ 
    @isTest 
    private static void testExistingCoappHavingBlankCIFGrowmark(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        List<Account> accountList = [SELECT Id, CIF_Number__c FROM Account WHERE Name = 'Kisan Loan' LIMIT 1];
        accountList[0].CIF_Number__c = '';
        Database.update(accountList[0],true);
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicationCreationHandler.assignCIFtoCoapplicants(new List<Account>{accountList[0]}, 'Growmark');
            System.assert(accountList[0].CIF_Number__c != null, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test assignCIFtoCoapplicants for CFA new coapplicant
    * @author Suraj Kumar | 12-06-2024 
    **/ 
    @isTest 
    private static void testAssignCIFtoNewCoappCFA(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Account accountObj = new Account();
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicationCreationHandler.assignCIFtoCoapplicants(new List<Account>{accountObj}, 'CFA');
            System.assert(accountObj.CIF_Number__c != null, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test assignCIFtoCoapplicants for CFA coapplicant having cif null
    * @author Suraj Kumar | 12-06-2024 
    **/ 
    @isTest 
    private static void testExistingCoappHavingNullCIFCFA(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        List<Account> accountList = [SELECT Id, CIF_Number__c FROM Account WHERE Name = 'Kisan Loan' LIMIT 1];
        accountList[0].CIF_Number__c = null;
        Database.update(accountList[0],true);
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicationCreationHandler.assignCIFtoCoapplicants(new List<Account>{accountList[0]}, 'CFA');
            System.assert(accountList[0].CIF_Number__c != null, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test assignCIFtoCoapplicants for CFA coapplicant having cif blank
    * @author Suraj Kumar | 12-06-2024 
    **/ 
    @isTest 
    private static void testExistingCoappHavingBlankCIFCFA(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        List<Account> accountList = [SELECT Id, CIF_Number__c FROM Account WHERE Name = 'Kisan Loan' LIMIT 1];
        accountList[0].CIF_Number__c = '';
        Database.update(accountList[0],true);
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicationCreationHandler.assignCIFtoCoapplicants(new List<Account>{accountList[0]}, 'CFA');
            System.assert(accountList[0].CIF_Number__c != null, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test assignCoapplicantRecordType for CFA new coapplicant
    * @author Suraj Kumar | 12-06-2024 
    **/ 
    @isTest 
    private static void testAssignNewCoAppRecordType(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        Account accountObj = new Account();
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicationCreationHandler.assignCoapplicantRecordType(accountObj);
            System.assert(accountObj.RecordTypeId != null, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test assignCoapplicantRecordType for CFA existing borrower
    * @author Suraj Kumar | 12-06-2024 
    **/ 
    @isTest 
    private static void testAssignExistingCoAppRecordType(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        List<Account> accountList = [SELECT Id, RecordTypeId, RecordType.Name FROM Account WHERE Name = 'Jasmine Albin' LIMIT 1];
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicationCreationHandler.assignCoapplicantRecordType(accountList[0]);
            System.assertEquals('Grower',accountList[0].RecordType.Name, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test createTasks
    * @author Suraj Kumar | 12-06-2024 
    **/ 
    @isTest 
    private static void testCreateTask(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        List<Task> taskList = [SELECT Id 
                                        FROM Task 
                                        WHERE genesis__Application__c = :applicationObj.id];
        Database.delete(taskList,true);
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicationCreationHandler.createTasks(applicationObj.Id);
            List<Task> applicationTasks = [SELECT Id 
                                                FROM Task 
                                                WHERE genesis__Application__c = :applicationObj.id];
            System.assert(applicationTasks.size()>0, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test createTasks for existing
    * @author Suraj Kumar | 12-06-2024 
    **/ 
    @isTest 
    private static void testCreateTaskExisting(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        genesis__Applications__c applicationObj = getApplication();
        List<Task> taskList = [SELECT Id 
                                        FROM Task 
                                        WHERE genesis__Application__c = :applicationObj.id];
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicationCreationHandler.createTasks(applicationObj.Id);
            List<Task> updatedTaskList = [SELECT Id 
                                                FROM Task 
                                                WHERE genesis__Application__c = :applicationObj.id];
            System.assertEquals(updatedTaskList.size(),taskList.size(), 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description : Test method to test createNewApplicantDealerRelationship
    * @author Suraj Kumar | 12-06-2024 
    **/ 
    @isTest 
    private static void testCreateNewApplicantDealerRelationship(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();
        List<Account> dealerAccountList = [SELECT Id FROM Account WHERE Name = 'Kisan Loan' LIMIT 1];
        List<Account> applicantAccountList = [SELECT Id FROM Account WHERE Name = 'Jasmine Albin' LIMIT 1];
        List<Contact> applicantContactList = [SELECT Id FROM Contact WHERE AccountId = :applicantAccountList[0].Id];
        System.runAs(userList[0]){
            Test.startTest();
            ExternalApplicationCreationHandler.createNewApplicantDealerRelationship(applicantAccountList[0],applicantContactList[0],dealerAccountList[0]);
            List<Dealer_Applicant_Relationship__c> applicantDealerRelList = [SELECT Id 
                                                                                    FROM Dealer_Applicant_Relationship__c 
                                                                                    WHERE Applicant__c = :applicantAccountList[0].Id];
            System.assert(applicantDealerRelList.size()>0, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description method to test populateNewPartyDetails
    * @author Rakesh Saraf | 03-25-2025 
    **/
    @isTest
    private static void testPopulateNewPartyDetails(){
        List<User> userList = ExternalAPITestHelper.getExternalAPIUser();

        Map<String,Object> paramMap=new Map<String,Object>{
                                                            ExternalConstants.WORK_PHONE_KEY=>'1234567890',
                                                            ExternalConstants.HOME_PHONE_KEY=>'1234567890',
                                                            ExternalConstants.PHONE_NUMBER_KEY=>'1234567890',
                                                            ExternalConstants.STREET_KEY=>'123 Street',
                                                            ExternalConstants.CITY_KEY=>'Illinois',
                                                            ExternalConstants.STATE_KEY=>'NY',
                                                            ExternalConstants.POSTAL_CODE_KEY=>'12345',
                                                            ExternalConstants.COUNTY_KEY=>'Kings',
                                                            ExternalConstants.SUFFIX_KEY=>'Jr.',
                                                            ExternalConstants.MARITAL_STATUS_KEY=>'Married',
                                                            ExternalConstants.TITLE_KEY=>'Member'
                                                        };

        System.runAs(userList[0]){
            Test.startTest();
            clcommon__Party__c partyObj=ExternalApplicationCreationHandler.populateNewPartyDetails(paramMap);
            
            System.assertEquals(partyObj.Street__c,(String)paramMap.get(ExternalConstants.STREET_KEY) ,'Assertion Failed');
            Test.stopTest();
        }
    }
}