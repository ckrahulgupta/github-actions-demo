/**
 * @description       : test class for ExternalApplicationOriginationUtil
 * @author            : Krishanu Chinya
 * @group             : 
 * @last modified on  : 04-02-2025
 * @last modified by  : Rakesh Saraf
**/
@isTest
public with sharing class ExternalApplicationOriginationUtilTest {
    @testSetup
    static void setup(){
        genesis__Business_Information__c dealerBusinessInfoObj = ApplicationOriginationTestHelper.createBusinessInfoForDealer();
        Database.insert(dealerBusinessInfoObj,true);

        Account dealerAccountObj = ApplicationOriginationTestHelper.createDealerAccount(dealerBusinessInfoObj.id);
        dealerAccountObj.CIF_Number__c = '102555';
        dealerAccountObj.Enable_ERP_Id__c = true;
        dealerAccountObj.Unique_Id__c = 'abc@123';
        Database.insert(dealerAccountObj,true);

        Account clAccountObj = ApplicationOriginationTestHelper.createCLAccount(dealerBusinessInfoObj.id,dealerAccountObj.id);
        Database.insert(clAccountObj,true);

        Contact clContactObj = ApplicationOriginationTestHelper.createCLContact(clAccountObj.id);
        Database.insert(clContactObj,true);

        User userObj = ApplicationOriginationTestHelper.createCLUser(clContactObj.id);
        Database.insert(userObj,true);

        clcommon__Party_Type__c clPartyType = ApplicationOriginationTestHelper.createPartyType('CERTIFIED LENDER');
        Database.insert(clPartyType,true);

        Map<String, clcommon__Legal_Entity__c> legalEntityMap = ExternalAPITestHelper.createMultipleLegalEntity();
        // Creating Legal Entity
        List<clcommon__Legal_Entity__c> legalEntityList = new List<clcommon__Legal_Entity__c>{
            legalEntityMap.get(ExternalConstants.INDIVIDUAL_ENTITY),
            legalEntityMap.get(ExternalConstants.SOLE_PROP_ENTITY),
            legalEntityMap.get(ExternalConstants.CORPORATION),
            legalEntityMap.get(ExternalConstants.LIMITED_LIABILITY_COMPANY),
            legalEntityMap.get(ExternalConstants.GENERAL_PARTNERSHIP),
            legalEntityMap.get(ExternalConstants.LIMITED_PARTNERSHIP),
            legalEntityMap.get(ExternalConstants.JOINT_VENTURE),
            legalEntityMap.get(ExternalConstants.TRUST)
        };
        Database.Insert(legalEntityList, true);

        clcommon__Legal_Entity__c entityObj = [SELECT Id, Name FROM clcommon__Legal_Entity__c WHERE Name = 'Individual(s) - Sole Proprietorship'];
        
        //creating business info for borrower
        genesis__Business_Information__c borrowerBusinessInfoObj = ExternalAPITestHelper.createBusinessInfoForBorrower();
        Database.insert(borrowerBusinessInfoObj,true);

        // Creating Account for Borrower
        Account borrowerAccountObj = ExternalAPITestHelper.createSolePropAccount(entityObj, borrowerBusinessInfoObj.Id);
        borrowerAccountObj.Unique_Id__c = 'cfa-test-001';
        Database.insert(borrowerAccountObj, true);
    }

    @isTest
    public static void testGetLoggedInUser (){
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];

        System.runAs(userObj) {
            Test.startTest();
            User loggedInUser = ExternalApplicationOriginationUtil.getLoggedInUser();
            System.assertEquals(userObj.Id, loggedInUser.Id, 'Assertion Failed');
            Test.stopTest();
        }
    }

    @isTest
    private static void testGetPartyTypeMap() {
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];

        List<clcommon__Party_Type__c> partyTypeList = [SELECT Id, 
                                                                Name
                                                        FROM clcommon__Party_Type__c
                                                        WHERE Name = 'CERTIFIED LENDER'];

        System.runAs(userObj) {
            Test.startTest();
            Map<String, Id> partyTypeMap = ExternalApplicationOriginationUtil.getPartyTypeMap();
            System.assertEquals(partyTypeList[0].Id, partyTypeMap.get('CERTIFIED LENDER'), 'Assertion Failed');
            Test.stopTest();
        }
    }

    @isTest
    private static void testGetLegalEntityMap() {
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];

        List<clcommon__Legal_Entity__c> legalEntityList = [SELECT Id, 
                                                                Name
                                                        FROM clcommon__Legal_Entity__c
                                                        WHERE Name = 'Individual(s) - Sole Proprietorship'];

        System.runAs(userObj) {
            Test.startTest();
            Map<String, Id> legalEntityMap = ExternalApplicationOriginationUtil.getLegalEntityMap();
            System.assertEquals(legalEntityList[0].Id, legalEntityMap.get('Individual(s) - Sole Proprietorship'), 'Assertion Failed');
            Test.stopTest();
        }
    }

    @isTest
    private static void testGetLegalEntityByName() {
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];

        List<clcommon__Legal_Entity__c> legalEntityList = [SELECT Id, 
                                                                    Name
                                                            FROM clcommon__Legal_Entity__c
                                                            WHERE Name = 'Individual(s) - Sole Proprietorship'];

        System.runAs(userObj) {
            Test.startTest();
            String legalEntityId = ExternalApplicationOriginationUtil.getLegalEntityByName('Individual(s) - Sole Proprietorship');
            System.assertEquals(legalEntityList[0].Id, legalEntityId, 'Assertion Failed');
            Test.stopTest();
        }
    }

    @isTest
    private static void testGetLegalEntityById() {
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];

        List<clcommon__Legal_Entity__c> legalEntityList = [SELECT Id, 
                                                                    Name
                                                            FROM clcommon__Legal_Entity__c
                                                            WHERE Name = 'Individual(s) - Sole Proprietorship'];

        System.runAs(userObj) {
            Test.startTest();
            String legalEntityName = ExternalApplicationOriginationUtil.getLegalEntityById(legalEntityList[0].Id);
            System.assertEquals(legalEntityList[0].Name, legalEntityName, 'Assertion Failed');
            Test.stopTest();
        }
    }

    @isTest
    static void testCheckEmptyListEmptyList() {
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];

        String exceptionNameString = 'Test Exception';
        System.runAs(userObj){
            Test.startTest();
            try {
                ExternalApplicationOriginationUtil.checkEmptyList(new List<Object>(), exceptionNameString);
            } catch (CustomException e) {
                System.assertEquals(exceptionNameString, e.getMessage(), 'Assertion Failed');
            }
            Test.stopTest();
        }
    }

    @isTest
    static void testCheckEmptyListNonEmptyList() {
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];

        String exceptionNameString = 'Test Exception';

        // Call the method with a non-empty list
        List<Object> nonEmptyList = new List<Object>{ 'Test' };
        System.runAs(userObj){
            Test.startTest();
            ExternalApplicationOriginationUtil.checkEmptyList(nonEmptyList, exceptionNameString);
            System.assertEquals('', '', 'Assertion Failed');
            Test.stopTest();
        }
    }

    @isTest
    static void testCheckForBlankParameterBlankParameter() {
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];

        String exceptionNameString = ExternalConstants.REQUIRED_PARAMETERS_MISSING;
        System.runAs(userObj){
            Test.startTest();
            try {
                ExternalApplicationOriginationUtil.checkForBlankParameter('');
            } catch (CustomException e) {
                System.assertEquals(exceptionNameString, e.getMessage(), 'Assertion Failed');
            }
        Test.stopTest();
        }
    }

    @isTest
    static void testCheckForEmptyStringEmptyString() {
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];

        String exceptionNameString = 'Test Exception';
        System.runAs(userObj){
            Test.startTest();
            try {
                ExternalApplicationOriginationUtil.checkForEmptyString('', exceptionNameString);
            } catch (CustomException e) {
                System.assertEquals(exceptionNameString, e.getMessage(),'Assertion Failed');
            }
            Test.stopTest();
        }
    }

    @isTest
    static void testCheckForNullObject() {
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];

        String exceptionNameString = 'Test Exception';
        Map<String,Object> principalDetailsMap;
        System.runAs(userObj){
            Test.startTest();
            try {
                ExternalApplicationOriginationUtil.checkForNullObject(principalDetailsMap, exceptionNameString);
            } catch (CustomException e) {
                System.assertEquals(exceptionNameString, e.getMessage(),'Assertion Failed');
            }
            Test.stopTest();
        }
    }


    @isTest
    static void testGetPossibleLegalEntityList() {
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];

        System.runAs(userObj){

            Test.startTest();
            List<String> result = ExternalApplicationOriginationUtil.getPossibleLegalEntityList();
            Test.stopTest();
            System.assertEquals(8, result.size(), 'Assertion Failed');
        }
    }

    @isTest
    static void testGetPicklistValues() {
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        Schema.DescribeSObjectResult objectDescribe = Schema.getGlobalDescribe().get('Account').getDescribe();
        
        // Retrieve the field's schema
        Schema.DescribeFieldResult fieldDescribe = objectDescribe.fields.getMap().get('Coop_Type__c').getDescribe();
        
        List<Schema.PicklistEntry> picklistEntries = fieldDescribe.getPicklistValues();

        System.runAs(userObj){

            Test.startTest();
            // Test when the field is a picklist
            List<String> picklistValues = ExternalApplicationOriginationUtil.getPicklistValues('Account', 'Coop_Type__c');
            System.assertEquals(picklistEntries.size(), picklistValues.size(), 'Assertion Failed');
            
            // Test when the field is not a picklist
            List<String> notPicklistValues = ExternalApplicationOriginationUtil.getPicklistValues('Account', 'Name');
            System.assertEquals(0, notPicklistValues.size(), 'Assertion Failed');
            Test.stopTest();
        }
    }

    @isTest
    static void testGetLegalEntityByUniqueId() {
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        System.runAs(userObj){

            Test.startTest();
                // Call the method being tested
                String legalEntityType = ExternalApplicationOriginationUtil.getLegalEntityByUniqueId('cfa-test-001');
                System.assertEquals(ExternalConstants.SOLE_PROP_ENTITY, legalEntityType, 'Legal Entity Type should match');
            Test.stopTest();
        }
    }

    /**
    * @description : method to test scenario no dealer found 
    * @author Kabir Pramanik | 09-13-2024 
    **/
    @isTest
    static void testGetDealerInfoForExternalUserNoData() {
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        System.runAs(userObj){

            Test.startTest();
            try {
                ExternalApplicationOriginationUtil.getDealerInfoForExternalUser('6787678');
            } catch (CustomException e) {
                System.assertEquals(ExternalConstants.DEALER_CIF_INVALID, e.getMessage(), 'Assertion Failed');
            }
            Test.stopTest();
        }
    }

    /**
    * @description : method to test scenario dealer found
    * @author Kabir Pramanik | 09-13-2024 
    **/
    @isTest
    static void testGetDealerInfoForExternalUser() {
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        System.runAs(userObj){

            Test.startTest();
            Account  dealerAccObj = ExternalApplicationOriginationUtil.getDealerInfoForExternalUser('102555');
            System.assertEquals('102555', dealerAccObj.Cif_number__c, 'Assertion Failed');
            Test.stopTest();
        }
    }

    /**
    * @description test for assignDecimalValueIfEmpty
    * @author Rakesh Saraf | 03-20-2025 
    **/
    @isTest
    private static void testAssignDecimalValueIfEmpty(){
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        Decimal value;
        System.runAs(userObj){

            Test.startTest();
            Decimal  valueObj = ExternalApplicationOriginationUtil.assignDecimalValueIfEmpty(value,123);
            System.assertEquals(123, valueObj, 'Assertion Failed');
        }
           
    }

    /**
    * @description test for assignMaritalStatus
    * @author Rakesh Saraf | 03-20-2025 
    **/
    @isTest
    private static void testAssignMaritalStatus(){
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        System.runAs(userObj){

            Test.startTest();
            String  valueObj = ExternalApplicationOriginationUtil.assignMaritalStatus('','Married');
            System.assertEquals('Married', valueObj, 'Assertion Failed');
        }
           
    }

    /**
    * @description test for assignValuesAfterKycCheck
    * @author Rakesh Saraf | 03-20-2025 
    **/
    @isTest
    private static void testAssignValuesAfterKycCheck(){
        User userObj = [SELECT Id FROM User WHERE Profile.name = 'System Administrator' AND isActive = true LIMIT 1];
        System.runAs(userObj){

            Test.startTest();
            String  valueObj = ExternalApplicationOriginationUtil.assignValuesAfterKycCheck(false,'','abc');
            System.assertEquals('abc', valueObj, 'Assertion Failed');
        }
           
    }
    
}