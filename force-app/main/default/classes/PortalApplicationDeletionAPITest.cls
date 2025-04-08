/**
 * @description       :  Test Class for PortalApplicationDeletionAPI
 * @author            :  Pritam Roy
 * @group             : 
 * @last modified on  : 06-12-2024
 * @last modified by  :  Pritam Roy
**/
@isTest
public with sharing class PortalApplicationDeletionAPITest{
    /**
    * @description : Create Test Data
    * @author  Pritam Roy | 06-11-2024 
    **/
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
        clcommon__Legal_Entity__c legalEntityDbaObj  = ApplicationOriginationTestHelper.createDBALegalEntity();
        Database.insert(legalEntityDbaObj,true);
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

        Map<String,Object> applicationDataMap = new Map<String,Object>{
            'dealerAccountObjId' => dealerAccountObj.id,
            'clProductObjId' => clProductObj.id,
            'clPurposeObjId' => clPurposeObj.id,
            'borrowerAccountObjId' => borrowerAccountObj.id,
            'borrowerContactObjId' => borrowerContactObj.id,
            'saAccountObjId' => accountObj.id
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
        User userObj = ApplicationOriginationTestHelper.createCLUser(clContactObj.id);
        Database.insert(userObj,true);

        //Creating Standard User
        User objStandardUser = ApplicationOriginationTestHelper.createStandardUser();
        Database.insert(objStandardUser, true);

        Map<String,Id> borrowerPartyParamMap = new Map<String,Id>{
            'accountId' => borrowerAccountObj.id,
            'contactId' => borrowerContactObj.id,
            'partyTypeId' => boPartyTypeObj.id,
            'applicationId' => applicationObj.id
        };
        clcommon__Party__c borrowerPartyObj = ApplicationOriginationTestHelper.createParty(borrowerPartyParamMap);
        Database.insert(borrowerpartyObj,true);

        Map<String,Id> principalPartyParamMap = new Map<String,Id>{
            'accountId' => coBorrowerAccountObj.id,
            'contactId' => coBorrowerContactObj.id,
            'partyTypeId' => prPartyTypeObj.id,
            'applicationId' => applicationObj.id
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
    }
    /**
    * @description : Updates legal entity
    * @param entityType 
    * @param objBorrowerAccount 
    **/
    private static void updateLegalEntity(String entityType, Account objBorrowerAccount){
        clcommon__Legal_Entity__c objEntity = [SELECT Id FROM clcommon__Legal_Entity__c WHERE name =: entityType];
        objBorrowerAccount.clcommon__Legal_Entity_Type__c = objEntity.id;
        Database.update(objBorrowerAccount, true);
    }
    /**
    * @description : Application Deletion Success
    * @author  Pritam Roy | 06-11-2024 
    **/
    @isTest
    public static void testApplicationDeletionSuccess() {
        Map<String, Object> requestMap = new Map<String, Object>();
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                            Certified_Lender__c
                                                            FROM genesis__Applications__c LIMIT 1];
        List<User> userList = [SELECT Id,
                                        IsActive 
                                    FROM User 
                                    WHERE Contact.AccountId =: applicationList[0].Certified_Lender__c 
                                    LIMIT 1];                                                    
        requestMap.put('applicationId',applicationList[0].id);
        Test.startTest();
        System.runAs(userList[0]){
            PortalApplicationDeletionAPI objTestApi = new PortalApplicationDeletionAPI();
            clcommon.Response response = objTestApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Application is not Deleted');
        }
        Test.stopTest();
    }
    /**
    * @description : Null Application Id exception
    * @author  Pritam Roy | 06-11-2024 
    **/
    @isTest
    public static void testApplicationDeletionException() {
        Map<String, Object> requestMap = new Map<String, Object>();
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                            Certified_Lender__c
                                                            FROM genesis__Applications__c LIMIT 1];
        List<User> userList = [SELECT Id,
                                        IsActive 
                                    FROM User 
                                    WHERE Contact.AccountId =: applicationList[0].Certified_Lender__c 
                                    LIMIT 1];                                                    
        requestMap.put('applicationId',NULL);
        Test.startTest();
        System.runAs(userList[0]){
            PortalApplicationDeletionAPI objTestApi = new PortalApplicationDeletionAPI();
            clcommon.Response response = objTestApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
        }
        Test.stopTest();
    }
    /**
    * @description : Wrong Application Id Exception
    * @author  Pritam Roy | 06-11-2024 
    **/
    @isTest
    public static void testDeletionNoArgumentsException() {
        Map<String, Object> requestMap = new Map<String, Object>();
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                            Certified_Lender__c
                                                            FROM genesis__Applications__c LIMIT 1];
        List<User> userList = [SELECT Id,
                                        IsActive 
                                    FROM User 
                                    WHERE Contact.AccountId =: applicationList[0].Certified_Lender__c 
                                    LIMIT 1];
        List<Account> dealerAccountList = [SELECT Id,Coop_Type__c FROM Account WHERE RecordType.Name = 'Dealer' LIMIT 1];
                                                                                
        requestMap.put('applicationId',dealerAccountList[0].id);
        Test.startTest();
        System.runAs(userList[0]){
            PortalApplicationDeletionAPI objTestApi = new PortalApplicationDeletionAPI();
            clcommon.Response response = objTestApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.API_EXCEPTION, response.status,'Assertion Failed');
        }
        Test.stopTest();
    }
    /**
    * @description : Application Deletion Evergreen Success
    * @author  Pritam Roy | 06-11-2024 
    **/
    @isTest
    public static void testApplicationDeletionEvergreenSuccess() {
        Map<String, Object> requestMap = new Map<String, Object>();
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                            Certified_Lender__c
                                                            FROM genesis__Applications__c LIMIT 1];
        applicationList[0].Is_evergreen__c = true;
        Database.update(applicationList, true);
        List<User> userList = [SELECT Id,
                                        IsActive 
                                    FROM User 
                                    WHERE Contact.AccountId =: applicationList[0].Certified_Lender__c 
                                    LIMIT 1];                                                    
        requestMap.put('applicationId',applicationList[0].id);
        Test.startTest();
        System.runAs(userList[0]){
            PortalApplicationDeletionAPI objTestApi = new PortalApplicationDeletionAPI();
            clcommon.Response response = objTestApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Application is not Deleted');
        }
        Test.stopTest();
    }
    /**
    * @description : Application Deletion Evergreen Individual(s) with DBA Success
    * @author  Pritam Roy | 06-11-2024 
    **/
    @isTest
    public static void testApplicationDeletionEvergreenDBASuccess() {
        Map<String, Object> requestMap = new Map<String, Object>();
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                            Certified_Lender__c
                                                            FROM genesis__Applications__c LIMIT 1];
        applicationList[0].Is_evergreen__c = true;
        Database.update(applicationList, true);
        List<Account> borrowerAccountObj = [SELECT Id FROM Account WHERE Name = 'Jasmine Albin'];
        updateLegalEntity('Individual(s) with DBA', borrowerAccountObj[0]);
        List<User> userList = [SELECT Id,
                                        IsActive 
                                    FROM User 
                                    WHERE Contact.AccountId =: applicationList[0].Certified_Lender__c 
                                    LIMIT 1];                                                    
        requestMap.put('applicationId',applicationList[0].id);
        Test.startTest();
        System.runAs(userList[0]){
            PortalApplicationDeletionAPI objTestApi = new PortalApplicationDeletionAPI();
            clcommon.Response response = objTestApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Application is not Deleted');
        }
        Test.stopTest();
    }
    /**
    * @description : Application Deletion Evergreen Corporation Success
    * @author  Pritam Roy | 06-11-2024 
    **/
    @isTest
    public static void testApplicationDeletionEvergreenCorpSuccess() {
        Map<String, Object> requestMap = new Map<String, Object>();
        List<genesis__Applications__c> applicationList = [SELECT Id,
                                                            Certified_Lender__c
                                                            FROM genesis__Applications__c LIMIT 1];
        applicationList[0].Is_evergreen__c = true;
        Database.update(applicationList, true);
        List<Account> borrowerAccountObj = [SELECT Id FROM Account WHERE Name = 'Jasmine Albin'];
        updateLegalEntity('Corporation', borrowerAccountObj[0]);
        List<User> userList = [SELECT Id,
                                        IsActive 
                                    FROM User 
                                    WHERE Contact.AccountId =: applicationList[0].Certified_Lender__c 
                                    LIMIT 1];                                                    
        requestMap.put('applicationId',applicationList[0].id);
        Test.startTest();
        System.runAs(userList[0]){
            PortalApplicationDeletionAPI objTestApi = new PortalApplicationDeletionAPI();
            clcommon.Response response = objTestApi.invokeAction('', new List<String>(), requestMap);
            System.assertEquals(clcommon.Constants.SUCCESS, response.status,'Application is not Deleted');
        }
        Test.stopTest();
    }
}