/**
 * @description       : Test class for CreateRecordsForHistoricalDataBatch
 * @author            : Sk Minsar
 * @group             : 
 * @last modified on  : 04-07-2025
 * @last modified by  : Sk Minsar
**/
@isTest
public with sharing class CreateRecordsForHistoricalDataBatchTest {

    private static final Integer BATCH_SIZE = 40;
    private static final Integer RECORDS_COUNT = 10;
    private static final String OPERATION_TYPE = 'Dealer_Applicant_Relationship__c';
    private static final String ASSERTION_FAILED = 'Assertion Failed';
    private static final String KEY_APPLICATION_LIST = 'applicationList';
    private static final String KEY_PARTY_LIST = 'partyList';
    private static final String PROFILE_CFA_USER = 'CFA User';
    private static final String INDIVIDUAL_ENTITY = 'Individual(s) with DBA';
    private static final String CORPORATION = 'Corporation';
    private static final String CLASS_NAME = CreateRecordsForHistoricalDataBatch.class.getName();
    private static final String BATCH_JOB_COMPLETED_STATUS = 'Completed';
    
    /**
    * @description - Creating test data
    * @author Sk Minsar | 03-11-2025 
    **/
    @TestSetup
    static void makeData() {

        Map<String, Id> partyTypeMap = new Map<String, Id>();
        
        //Creating application, party, roles, relationships ---------------------------------------------------------------------------------------------
        ApplicationOriginationSetupTestHelper.createTestSetup();

        List<genesis__Applications__c> applicationList = [SELECT Id, genesis__CL_Product__c, genesis__CL_Purpose__c, genesis__Account__c, genesis__Contact__c, Dealer_Name__c, Certified_Lender__c, Dealer_Applicant_Relationship__c FROM genesis__Applications__c WHERE genesis__Account__r.clcommon__Legal_Entity_Type__r.name = :ConstantValues.SOLE_PROP_ENTITY LIMIT :RECORDS_COUNT];
        List<Contact> dbaContactList = [SELECT id, name, accountId FROM Contact WHERE Account.clcommon__Legal_Entity_Type__r.name = :INDIVIDUAL_ENTITY LIMIT :RECORDS_COUNT];
        List<clcommon__Party_Type__c> partyTypeList = [SELECT id, name FROM clcommon__Party_Type__c WHERE Name In (:ConstantValues.BORROWER_PARTY, :ConstantValues.PRINCIPAL_PARTY) LIMIT :RECORDS_COUNT];
        for(clcommon__Party_Type__c partyType: partyTypeList){
            partyTypeMap.put(partyType.name, partyType.Id);
        }

        //Creating dealer applicant relationship ---------------------------------------------------------------------------------------------
        Dealer_Applicant_Relationship__c relationObj = ApplicationOriginationTestHelper.createDealerApplicantRelationship(dbaContactList[0], applicationList[0].Dealer_Name__c);
        Database.insert(relationObj,true);

        //Creating application ---------------------------------------------------------------------------------------------
        genesis__Applications__c applicationObj = ApplicationOriginationTestHelper.createApplication(new Map<String,Id>{
            'dealerAccountObjId' => applicationList[0].Dealer_Name__c,
            'clProductObjId' => applicationList[0].genesis__CL_Product__c,
            'clPurposeObjId' => applicationList[0].genesis__CL_Purpose__c,
            'borrowerAccountObjId' => dbaContactList[0].AccountId,
            'borrowerContactObjId' => dbaContactList[0].Id,
            'clAccountObjId' => applicationList[0].Certified_Lender__c,
            'dealerApplicantRelationshipId' => relationObj.Id
        });
        applicationObj.Dealer_Applicant_Relationship__c = relationObj.Id;
        Database.insert(applicationObj, true);

        //Creating required party --------------------------------------------------------------------------------------------- 
        clcommon__Party__c borrowerPartyObj = ApplicationOriginationTestHelper.createParty(new Map<String,Id>{
            'accountId' => dbaContactList[0].AccountId,
            'contactId' =>dbaContactList[0].Id,
            'partyTypeId' => partyTypeMap.get(ConstantValues.BORROWER_PARTY),
            'applicationId' =>applicationObj.Id,
            'dealerApplicantRelationshipId' => relationObj.Id
        });
        clcommon__Party__c principalPartyObj = ApplicationOriginationTestHelper.createParty(new Map<String,Id>{
            'accountId' => applicationList[0].genesis__Account__c,
            'contactId' => applicationList[0].genesis__Contact__c,
            'partyTypeId' => partyTypeMap.get(ConstantValues.PRINCIPAL_PARTY),
            'applicationId' =>applicationObj.Id,
            'dealerApplicantRelationshipId' => applicationList[0].Dealer_Applicant_Relationship__c
        });
        Database.insert(new List<clcommon__Party__c>{borrowerPartyObj, principalPartyObj}, true);

        //Creating Users ---------------------------------------------------------------------------------------------
        User adminUser = LoanServicingTestHelper.createUserByProfileName(ConstantValues.PROFILE_ADMIN, 'testadminuser445@yopmail.com')[0];
        User cfaUser = LoanServicingTestHelper.createUserByProfileName(PROFILE_CFA_USER, 'test1cfa.user112@yopmail.com')[0];
        User executiveUser = LoanServicingTestHelper.createUserByProfileName(ConstantValues.PROFILE_EXECUTIVE, 'test2cfa.user113@yopmail.com')[0];
        User fieldStaffUser = LoanServicingTestHelper.createUserByProfileName(ConstantValues.PROFILE_FIELD_STAFF, 'test3cfa.user114@yopmail.com')[0];
        User creditUser = LoanServicingTestHelper.createUserByProfileName(ConstantValues.PROFILE_CREDIT, 'test4cfa.user115@yopmail.com')[0];
        User masterCreditUser = LoanServicingTestHelper.createUserByProfileName(ConstantValues.PROFILE_MASTER_CREDIT, 'test6cfa.user117@yopmail.com')[0];
        User loanAccountingUser = LoanServicingTestHelper.createUserByProfileName(ConstantValues.PROFILE_LOAN_ACCOUNTING, 'test8cfa.user119@yopmail.com')[0];
        User cfaAdminUser = LoanServicingTestHelper.createUserByProfileName(ConstantValues.PROFILE_CFA_ADMIN, 'test01cfa.user103@yopmail.com')[0];
        Database.insert(new List<User>{cfaUser, executiveUser, fieldStaffUser, creditUser, masterCreditUser, loanAccountingUser, cfaAdminUser, adminUser}, true);

    }
    
    /**
    * @description - This method queries and returns all the necessary data
    * @author Sk Minsar | 03-24-2025 
    * @param entityTypeList 
    * @return Map<String, Object> 
    **/
    private static Map<String, Object> getDataMap(List<String> entityTypeList){
        List<genesis__Applications__c> applicationList = [SELECT Id, genesis__Contact__c,genesis__Account__c, Dealer_Applicant_Relationship__c FROM genesis__Applications__c WHERE genesis__Account__r.clcommon__Legal_Entity_Type__r.name In :entityTypeList LIMIT: RECORDS_COUNT];
        List<clcommon__Party__c> partyList = [SELECT Id,
                                                    clcommon__Contact__c,
                                                    clcommon__Account__c,
                                                    clcommon__Account__r.clcommon__Legal_Entity_Type__r.Name,
                                                    clcommon__Account__r.Is_Individual__c,
                                                    clcommon__Party_Types__c, 
                                                    City__c,
                                                    State__c, 
                                                    County__c, 
                                                    Street__c, 
                                                    Postal_Code__c,
                                                    Suffix__c,
                                                    Title__c,
                                                    Marital_Status__c,
                                                    Gross_Farm_Income__c,
                                                    Home_Number__c,
                                                    Work_Number__c,
                                                    Mobile_Number__c,
                                                    genesis__Application__r.genesis__Account__r.clcommon__Legal_Entity_Type__r.Name,
                                                    clcommon__Contact__r.Email,
                                                    clcommon__Account__r.Kyc_Verified__c,
                                                    clcommon__Contact__r.MailingStreet,
                                                    clcommon__Contact__r.MailingCity,
                                                    clcommon__Contact__r.MailingState,
                                                    clcommon__Contact__r.MailingPostalCode,
                                                    clcommon__Contact__r.Mailing_County__c,
                                                    clcommon__Contact__r.Title,
                                                    clcommon__Contact__r.Suffix__c,
                                                    clcommon__Contact__r.clcommon__Marital_Status__c,
                                                    clcommon__Account__r.genesis__Business_Information__r.Gross_Farm_Income__c,
                                                    clcommon__Contact__r.HomePhone,
                                                    clcommon__Contact__r.Phone,
                                                    clcommon__Contact__r.MobilePhone,
                                                    clcommon__Account__r.BillingStreet,
                                                    clcommon__Account__r.BillingCity,
                                                    clcommon__Account__r.BillingState,
                                                    clcommon__Account__r.BillingPostalCode,
                                                    clcommon__Account__r.Billing_County__c,
                                                    clcommon__Account__r.Work_Number__c,
                                                    clcommon__Account__r.Home_Number__c,
                                                    clcommon__Account__r.Phone,
                                                    Dealer_Applicant_Relationship__c
                                                FROM clcommon__Party__c WHERE clcommon__Party_Types__c In (:ConstantValues.BORROWER_PARTY, :ConstantValues.PRINCIPAL_PARTY) AND genesis__Application__c In :applicationList];

        return new Map<String, Object>{
            KEY_APPLICATION_LIST => applicationList,
            KEY_PARTY_LIST => partyList
        };
    }

    /**
    * @description - This method makes Dealer_Applicant_Relationship__c null for list of application & party
    * @author Sk Minsar | 03-24-2025 
    * @param applicationList 
    * @param partyList 
    * @param shouldDelete 
    **/
    private static void nullifyDAR(List<genesis__Applications__c> applicationList, List<clcommon__Party__c> partyList, Boolean shouldDelete){
        Set<Id> dealerAppRelSet = new Set<Id>();
        if(!applicationList.isEmpty()){
            for(genesis__Applications__c application : applicationList){
                dealerAppRelSet.add(application.Dealer_Applicant_Relationship__c);
                application.Dealer_Applicant_Relationship__c = null;
            }
            Database.update(applicationList, true);
        }
        if(!partyList.isEmpty()){
            for(clcommon__Party__c party : partyList){
                dealerAppRelSet.add(party.Dealer_Applicant_Relationship__c);
                party.Street__c = null;
                party.City__c = null;
                party.State__c = null;
                party.Postal_Code__c = null;
                party.County__c = null;
                party.Title__c = null;
                party.Suffix__c = null;
                party.Marital_Status__c = null;
                party.Gross_Farm_Income__c = null;
                party.Work_Number__c = null;
                party.Home_Number__c = null;
                party.Mobile_Number__c = null;
                party.Dealer_Applicant_Relationship__c = null;
            }
            Database.update(partyList, true);
        }
        if(!dealerAppRelSet.isEmpty() && shouldDelete){
            Database.delete(new List<Id>(dealerAppRelSet), true);
        }
    }

    /**
    * @description - This method is used to validate Party 
    * @author Sk Minsar | 03-26-2025 
    * @param partyList 
    **/
    private static void validatePartyRecords(List<clcommon__Party__c> partyList){
        for(clcommon__Party__c party: partyList){
            System.assertEquals(ConstantValues.TRUE_VALUE, party.Dealer_Applicant_Relationship__c!=null, ASSERTION_FAILED);
            System.assertEquals(party.clcommon__Contact__r.Title, party.Title__c, ASSERTION_FAILED);
            System.assertEquals(party.clcommon__Contact__r.Title, party.Title__c, ASSERTION_FAILED);
            System.assertEquals(party.clcommon__Contact__r.Suffix__c, party.Suffix__c, ASSERTION_FAILED);
            System.assertEquals(party.clcommon__Account__r.genesis__Business_Information__r.Gross_Farm_Income__c, party.Gross_Farm_Income__c, ASSERTION_FAILED);
            System.assertEquals(party.clcommon__Contact__r.clcommon__Marital_Status__c, party.Marital_Status__c, ASSERTION_FAILED);

            if(party.clcommon__Account__r.clcommon__Legal_Entity_Type__r.Name == ConstantValues.SOLE_PROP_ENTITY){
                System.assertEquals(party.clcommon__Contact__r.MailingStreet, party.Street__c, ASSERTION_FAILED);
                System.assertEquals(party.clcommon__Contact__r.MailingCity, party.City__c, ASSERTION_FAILED);
                System.assertEquals(party.clcommon__Contact__r.MailingState, party.State__c, ASSERTION_FAILED);
                System.assertEquals(party.clcommon__Contact__r.MailingPostalCode, party.Postal_Code__c, ASSERTION_FAILED);
                System.assertEquals(party.clcommon__Contact__r.Mailing_County__c, party.County__c, ASSERTION_FAILED);
                System.assertEquals(party.clcommon__Contact__r.HomePhone, party.Home_Number__c, ASSERTION_FAILED);
                System.assertEquals(party.clcommon__Contact__r.Phone, party.Work_Number__c, ASSERTION_FAILED);
                System.assertEquals(party.clcommon__Contact__r.MobilePhone, party.Mobile_Number__c, ASSERTION_FAILED);
            }else {
                System.assertEquals(party.clcommon__Account__r.BillingStreet, party.Street__c, ASSERTION_FAILED);
                System.assertEquals(party.clcommon__Account__r.BillingCity, party.City__c, ASSERTION_FAILED);
                System.assertEquals(party.clcommon__Account__r.BillingState, party.State__c, ASSERTION_FAILED);
                System.assertEquals(party.clcommon__Account__r.BillingPostalCode, party.Postal_Code__c, ASSERTION_FAILED);
                System.assertEquals(party.clcommon__Account__r.Billing_County__c, party.County__c, ASSERTION_FAILED);
                System.assertEquals(party.clcommon__Account__r.Work_Number__c, party.Work_Number__c, ASSERTION_FAILED);
                System.assertEquals(party.clcommon__Account__r.Home_Number__c, party.Home_Number__c, ASSERTION_FAILED);
                System.assertEquals(party.clcommon__Account__r.Phone, party.Mobile_Number__c, ASSERTION_FAILED);
            }
        }
    }

    /**
    * @description - Return AysncApexJobList
    * @author Sk Minsar | 03-24-2025 
    * @return List<AsyncApexJob> 
    **/
    private static List<AsyncApexJob> getAsyncJobList(){
        List<ApexClass> calloutBatchList = [SELECT Id FROM ApexClass WHERE Name = :CLASS_NAME LIMIT 1];
        return [SELECT Id, ApexClassId, Status FROM AsyncApexJob WHERE ApexClassId =:calloutBatchList[0].Id LIMIT 1];
    }

    /**
    * @description - Test CreateRecordsForHistoricalDataBatch for sole prop without Dealer_Applicant_Relationship__c
    * @author Sk Minsar | 03-21-2025 
    **/
    @isTest
    public static void testForSolePropApplicationWithoutDAR() {
        Map<String, Object> dataMap = getDataMap(new List<String>{ConstantValues.SOLE_PROP_ENTITY});
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        List<clcommon__Party__c> partyList = (List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST);
        nullifyDAR(applicationList, partyList, ConstantValues.TRUE_VALUE);
        System.runAs(LoanServicingTestHelper.getUserByProfileName(ConstantValues.PROFILE_ADMIN)[0]) {
            Test.startTest();
                CreateRecordsForHistoricalDataBatch recordBatch = new CreateRecordsForHistoricalDataBatch(OPERATION_TYPE, null);
                Database.executeBatch(recordBatch , BATCH_SIZE);
            Test.stopTest();
            dataMap = getDataMap(new List<String>{ConstantValues.SOLE_PROP_ENTITY});
            applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
            partyList = (List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST);
            System.assertEquals(ConstantValues.TRUE_VALUE, applicationList[0].Dealer_Applicant_Relationship__c!=null, ASSERTION_FAILED);
            validatePartyRecords(partyList);
        }
    }

    /**
    * @description - Test CreateRecordsForHistoricalDataBatch for sole prop with Dealer_Applicant_Relationship__c
    * @author Sk Minsar | 03-21-2025 
    **/
    @isTest
    public static void testForSolePropApplicationWithDAR() {
        Map<String, Object> dataMap = getDataMap(new List<String>{ConstantValues.SOLE_PROP_ENTITY});
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        List<clcommon__Party__c> partyList = (List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST);
        nullifyDAR(applicationList, partyList, ConstantValues.FALSE_VALUE);
        System.runAs(LoanServicingTestHelper.getUserByProfileName(ConstantValues.PROFILE_ADMIN)[0]) {
            Test.startTest();
                CreateRecordsForHistoricalDataBatch recordBatch = new CreateRecordsForHistoricalDataBatch(OPERATION_TYPE, null);
                Database.executeBatch(recordBatch , BATCH_SIZE);
            Test.stopTest();
            dataMap = getDataMap(new List<String>{ConstantValues.SOLE_PROP_ENTITY});
            applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
            partyList = (List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST);
            System.assertEquals(ConstantValues.TRUE_VALUE, applicationList[0].Dealer_Applicant_Relationship__c!=null, ASSERTION_FAILED);
            validatePartyRecords(partyList);
        }
    }

    /**
    * @description - Test CreateRecordsForHistoricalDataBatch for sole prop with null application's Dealer_Applicant_Relationship__c
    * @author Sk Minsar | 03-21-2025 
    **/
    @isTest
    public static void testForSolePropApplicationNullAppDAR() {
        Map<String, Object> dataMap = getDataMap(new List<String>{ConstantValues.SOLE_PROP_ENTITY});
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        List<clcommon__Party__c> partyList = (List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST);
        nullifyDAR(applicationList, new List<clcommon__Party__c>(), ConstantValues.FALSE_VALUE);
        System.runAs(LoanServicingTestHelper.getUserByProfileName(ConstantValues.PROFILE_ADMIN)[0]) {
            Test.startTest();
                CreateRecordsForHistoricalDataBatch recordBatch = new CreateRecordsForHistoricalDataBatch(OPERATION_TYPE, null);
                Database.executeBatch(recordBatch , BATCH_SIZE);
            Test.stopTest();
            dataMap = getDataMap(new List<String>{ConstantValues.SOLE_PROP_ENTITY});
            applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
            partyList = (List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST);
            System.assertEquals(ConstantValues.TRUE_VALUE, applicationList[0].Dealer_Applicant_Relationship__c!=null, ASSERTION_FAILED);
            validatePartyRecords(partyList);
        }
    }

    /**
    * @description - Test CreateRecordsForHistoricalDataBatch for corporation without Dealer_Applicant_Relationship__c
    * @author Sk Minsar | 03-21-2025 
    **/
    @isTest
    public static void testBusinessApplicationWithoutDAR() {
        Map<String, Object> dataMap = getDataMap(new List<String>{CORPORATION});
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        List<clcommon__Party__c> partyList = (List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST);
        nullifyDAR(applicationList, partyList, ConstantValues.TRUE_VALUE);
        System.runAs(LoanServicingTestHelper.getUserByProfileName(ConstantValues.PROFILE_ADMIN)[0]) {
            Test.startTest();
                CreateRecordsForHistoricalDataBatch recordBatch = new CreateRecordsForHistoricalDataBatch(OPERATION_TYPE, null);
                Database.executeBatch(recordBatch , BATCH_SIZE);
            Test.stopTest();
            dataMap = getDataMap(new List<String>{CORPORATION});
            applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
            partyList = (List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST);
            System.assertEquals(ConstantValues.TRUE_VALUE, applicationList[0].Dealer_Applicant_Relationship__c!=null, ASSERTION_FAILED);
            validatePartyRecords(partyList);
        }
    }

    /**
    * @description - Test CreateRecordsForHistoricalDataBatch for corporation with Dealer_Applicant_Relationship__c
    * @author Sk Minsar | 03-21-2025 
    **/
    @isTest
    public static void testBusinessApplicationWithDAR() {
        Map<String, Object> dataMap = getDataMap(new List<String>{CORPORATION});
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        List<clcommon__Party__c> partyList = (List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST);
        nullifyDAR(applicationList, partyList, ConstantValues.FALSE_VALUE);
        System.runAs(LoanServicingTestHelper.getUserByProfileName(ConstantValues.PROFILE_ADMIN)[0]) {
            Test.startTest();
                CreateRecordsForHistoricalDataBatch recordBatch = new CreateRecordsForHistoricalDataBatch(OPERATION_TYPE, null);
                Database.executeBatch(recordBatch , BATCH_SIZE);
            Test.stopTest();
            dataMap = getDataMap(new List<String>{CORPORATION});
            applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
            partyList = (List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST);
            System.assertEquals(ConstantValues.TRUE_VALUE, applicationList[0].Dealer_Applicant_Relationship__c!=null, ASSERTION_FAILED);
            validatePartyRecords(partyList);
        }
    }

    /**
    * @description - Test CreateRecordsForHistoricalDataBatch for DBA without Dealer_Applicant_Relationship__c
    * @author Sk Minsar | 03-21-2025 
    **/
    @isTest
    public static void testDBAApplicationWithoutDAR() {
        Map<String, Object> dataMap = getDataMap(new List<String>{INDIVIDUAL_ENTITY});
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        List<clcommon__Party__c> partyList = (List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST);
        nullifyDAR(applicationList, partyList, ConstantValues.TRUE_VALUE);
        System.runAs(LoanServicingTestHelper.getUserByProfileName(ConstantValues.PROFILE_ADMIN)[0]) {
            Test.startTest();
                CreateRecordsForHistoricalDataBatch recordBatch = new CreateRecordsForHistoricalDataBatch(OPERATION_TYPE, null);
                Database.executeBatch(recordBatch , BATCH_SIZE);
            Test.stopTest();
            dataMap = getDataMap(new List<String>{INDIVIDUAL_ENTITY});
            applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
            partyList = (List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST);
            System.assertEquals(ConstantValues.TRUE_VALUE, applicationList[0].Dealer_Applicant_Relationship__c!=null, ASSERTION_FAILED);
            validatePartyRecords(partyList);
        }
    }

    /**
    * @description - Test CreateRecordsForHistoricalDataBatch for DBA with Dealer_Applicant_Relationship__c
    * @author Sk Minsar | 03-21-2025 
    **/
    @isTest
    public static void testDBAApplicationWithDAR() {
        Map<String, Object> dataMap = getDataMap(new List<String>{INDIVIDUAL_ENTITY});
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        List<clcommon__Party__c> partyList = (List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST);
        nullifyDAR(applicationList, partyList, ConstantValues.FALSE_VALUE);
        System.runAs(LoanServicingTestHelper.getUserByProfileName(ConstantValues.PROFILE_ADMIN)[0]) {
            Test.startTest();
                CreateRecordsForHistoricalDataBatch recordBatch = new CreateRecordsForHistoricalDataBatch(OPERATION_TYPE, null);
                Database.executeBatch(recordBatch , BATCH_SIZE);
            Test.stopTest();
            dataMap = getDataMap(new List<String>{INDIVIDUAL_ENTITY});
            applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
            partyList = (List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST);
            System.assertEquals(ConstantValues.TRUE_VALUE, applicationList[0].Dealer_Applicant_Relationship__c!=null, ASSERTION_FAILED);
            validatePartyRecords(partyList);
        }
    }

    /**
    * @description - Test CreateRecordsForHistoricalDataBatch for multiple application without Dealer_Applicant_Relationship__c
    * @author Sk Minsar | 03-21-2025 
    **/
    @isTest
    public static void testForMultipleApplicationWithoutDAR() {
        Map<String, Object> dataMap = getDataMap(new List<String>{ConstantValues.SOLE_PROP_ENTITY, CORPORATION, INDIVIDUAL_ENTITY});
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        List<clcommon__Party__c> partyList = (List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST);
        nullifyDAR(applicationList, partyList, ConstantValues.TRUE_VALUE);
        System.runAs(LoanServicingTestHelper.getUserByProfileName(ConstantValues.PROFILE_ADMIN)[0]) {
            Test.startTest();
                CreateRecordsForHistoricalDataBatch recordBatch = new CreateRecordsForHistoricalDataBatch(OPERATION_TYPE, null);
                Database.executeBatch(recordBatch , BATCH_SIZE);
            Test.stopTest();
            dataMap = getDataMap(new List<String>{ConstantValues.SOLE_PROP_ENTITY, CORPORATION, INDIVIDUAL_ENTITY});
            applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
            partyList = (List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST);
            System.assertEquals(ConstantValues.TRUE_VALUE, applicationList[0].Dealer_Applicant_Relationship__c!=null, ASSERTION_FAILED);
            validatePartyRecords(partyList);
        }
    }

    /**
    * @description - Test CreateRecordsForHistoricalDataBatch for multiple application with Dealer_Applicant_Relationship__c
    * @author Sk Minsar | 03-21-2025 
    **/
    @isTest
    public static void testForMultipleApplicationWithDAR() {
        Map<String, Object> dataMap = getDataMap(new List<String>{ConstantValues.SOLE_PROP_ENTITY, CORPORATION, INDIVIDUAL_ENTITY});
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        List<clcommon__Party__c> partyList = (List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST);
        nullifyDAR(applicationList, partyList, ConstantValues.FALSE_VALUE);
        System.runAs(LoanServicingTestHelper.getUserByProfileName(ConstantValues.PROFILE_ADMIN)[0]) {
            Test.startTest();
                CreateRecordsForHistoricalDataBatch recordBatch = new CreateRecordsForHistoricalDataBatch(OPERATION_TYPE, null);
                Database.executeBatch(recordBatch , BATCH_SIZE);
            Test.stopTest();
            dataMap = getDataMap(new List<String>{ConstantValues.SOLE_PROP_ENTITY, CORPORATION, INDIVIDUAL_ENTITY});
            applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
            partyList = (List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST);
            System.assertEquals(ConstantValues.TRUE_VALUE, applicationList[0].Dealer_Applicant_Relationship__c!=null, ASSERTION_FAILED);
            validatePartyRecords(partyList);
        }
    }

    /**
    * @description - Test CreateRecordsForHistoricalDataBatch for specific application with Dealer_Applicant_Relationship__c
    * @author Sk Minsar | 03-21-2025 
    **/
    @isTest
    public static void testForSepecificApplicationsWithDAR() {
        List<Id> applicationIdList = new List<Id>();
        Map<String, Object> dataMap = getDataMap(new List<String>{ConstantValues.SOLE_PROP_ENTITY, CORPORATION, INDIVIDUAL_ENTITY});
        List<clcommon__Party__c> partyList = (List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST);
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        for(genesis__Applications__c application: applicationList){
            applicationIdList.add(application.Id);
        }
        nullifyDAR(applicationList, partyList, ConstantValues.FALSE_VALUE);
        System.runAs(LoanServicingTestHelper.getUserByProfileName(ConstantValues.PROFILE_ADMIN)[0]) {
            Test.startTest();
                CreateRecordsForHistoricalDataBatch recordBatch = new CreateRecordsForHistoricalDataBatch(OPERATION_TYPE, applicationIdList);
                Database.executeBatch(recordBatch , BATCH_SIZE);
            Test.stopTest();
            dataMap = getDataMap(new List<String>{ConstantValues.SOLE_PROP_ENTITY, CORPORATION, INDIVIDUAL_ENTITY});
            applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
            partyList = (List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST);
            System.assertEquals(ConstantValues.TRUE_VALUE, applicationList[0].Dealer_Applicant_Relationship__c!=null, ASSERTION_FAILED);
            validatePartyRecords(partyList);
        }
    }

    /**
    * @description - Test CreateRecordsForHistoricalDataBatch for specific applications without Dealer_Applicant_Relationship__c
    * @author Sk Minsar | 03-21-2025 
    **/
    @isTest
    public static void testForSpecificApplicationsWithoutDAR() {
        List<Id> applicationIdList = new List<Id>();
        Map<String, Object> dataMap = getDataMap(new List<String>{ConstantValues.SOLE_PROP_ENTITY, CORPORATION, INDIVIDUAL_ENTITY});
        List<clcommon__Party__c> partyList = (List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST);
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        for(genesis__Applications__c application: applicationList){
            applicationIdList.add(application.Id);
        }
        nullifyDAR(applicationList, partyList, ConstantValues.TRUE_VALUE);
        System.runAs(LoanServicingTestHelper.getUserByProfileName(ConstantValues.PROFILE_ADMIN)[0]) {
            Test.startTest();
                CreateRecordsForHistoricalDataBatch recordBatch = new CreateRecordsForHistoricalDataBatch(OPERATION_TYPE, applicationIdList);
                Database.executeBatch(recordBatch , BATCH_SIZE);
            Test.stopTest();
            dataMap = getDataMap(new List<String>{ConstantValues.SOLE_PROP_ENTITY, CORPORATION, INDIVIDUAL_ENTITY});
            applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
            partyList = (List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST);
            System.assertEquals(ConstantValues.TRUE_VALUE, applicationList[0].Dealer_Applicant_Relationship__c!=null, ASSERTION_FAILED);
            validatePartyRecords(partyList);
        }
    }

    /**
    * @description - Test CreateRecordsForHistoricalDataBatch for sole prop without Dealer_Applicant_Relationship__c with Executive profile
    * @author Sk Minsar | 03-21-2025 
    **/
    @isTest
    public static void testWithExecutiveUser() {
        Boolean isExceptionThrown = ConstantValues.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap(new List<String>{ConstantValues.SOLE_PROP_ENTITY});
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        List<clcommon__Party__c> partyList = (List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST);
        nullifyDAR(applicationList, partyList, ConstantValues.TRUE_VALUE);
        System.runAs(LoanServicingTestHelper.getUserByProfileName(ConstantValues.PROFILE_EXECUTIVE)[0]) {
            Test.startTest();
                try{
                    CreateRecordsForHistoricalDataBatch recordBatch = new CreateRecordsForHistoricalDataBatch(OPERATION_TYPE, null);
                    Database.executeBatch(recordBatch , BATCH_SIZE);
                } catch(Exception e){
                    isExceptionThrown = ConstantValues.TRUE_VALUE;
                } 
            Test.stopTest();
            List<AsyncApexJob> asyncJobList = getAsyncJobList();
            System.assertEquals(BATCH_JOB_COMPLETED_STATUS, asyncJobList[0].Status, ASSERTION_FAILED);
            System.assertEquals(ConstantValues.FALSE_VALUE, isExceptionThrown, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test CreateRecordsForHistoricalDataBatch for sole prop without Dealer_Applicant_Relationship__c with Loan Accounting profile
    * @author Sk Minsar | 03-21-2025 
    **/
    @isTest
    public static void testWithLoanAccountingUser() {
        Boolean isExceptionThrown = ConstantValues.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap(new List<String>{ConstantValues.SOLE_PROP_ENTITY});
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        List<clcommon__Party__c> partyList = (List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST);
        nullifyDAR(applicationList, partyList, ConstantValues.TRUE_VALUE);
        System.runAs(LoanServicingTestHelper.getUserByProfileName(ConstantValues.PROFILE_LOAN_ACCOUNTING)[0]) {
            Test.startTest();
                try{
                    CreateRecordsForHistoricalDataBatch recordBatch = new CreateRecordsForHistoricalDataBatch(OPERATION_TYPE, null);
                    Database.executeBatch(recordBatch , BATCH_SIZE);
                } catch(Exception e){
                    isExceptionThrown = ConstantValues.TRUE_VALUE;
                } 
            Test.stopTest();
            List<AsyncApexJob> asyncJobList = getAsyncJobList();
            System.assertEquals(BATCH_JOB_COMPLETED_STATUS, asyncJobList[0].Status, ASSERTION_FAILED);
            System.assertEquals(ConstantValues.FALSE_VALUE, isExceptionThrown, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test CreateRecordsForHistoricalDataBatch for sole prop without Dealer_Applicant_Relationship__c with Field Staff profile
    * @author Sk Minsar | 03-21-2025 
    **/
    @isTest
    public static void testWithFieldStaffUser() {
        Boolean isExceptionThrown = ConstantValues.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap(new List<String>{ConstantValues.SOLE_PROP_ENTITY});
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        List<clcommon__Party__c> partyList = (List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST);
        nullifyDAR(applicationList, partyList, ConstantValues.TRUE_VALUE);
        System.runAs(LoanServicingTestHelper.getUserByProfileName(ConstantValues.PROFILE_FIELD_STAFF)[0]) {
            Test.startTest();
                try{
                    CreateRecordsForHistoricalDataBatch recordBatch = new CreateRecordsForHistoricalDataBatch(OPERATION_TYPE, null);
                    Database.executeBatch(recordBatch , BATCH_SIZE);
                } catch(Exception e){
                    isExceptionThrown = ConstantValues.TRUE_VALUE;
                } 
            Test.stopTest();
            List<AsyncApexJob> asyncJobList = getAsyncJobList();
            System.assertEquals(BATCH_JOB_COMPLETED_STATUS, asyncJobList[0].Status, ASSERTION_FAILED);
            System.assertEquals(ConstantValues.FALSE_VALUE, isExceptionThrown, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test CreateRecordsForHistoricalDataBatch for sole prop without Dealer_Applicant_Relationship__c with CFA User profile
    * @author Sk Minsar | 03-21-2025 
    **/
    @isTest
    public static void testWithCFAUser() {
        Boolean isExceptionThrown = ConstantValues.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap(new List<String>{ConstantValues.SOLE_PROP_ENTITY});
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        List<clcommon__Party__c> partyList = (List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST);
        nullifyDAR(applicationList, partyList, ConstantValues.TRUE_VALUE);
        System.runAs(LoanServicingTestHelper.getUserByProfileName(PROFILE_CFA_USER)[0]) {
            Test.startTest();
                try{
                    CreateRecordsForHistoricalDataBatch recordBatch = new CreateRecordsForHistoricalDataBatch(OPERATION_TYPE, null);
                    Database.executeBatch(recordBatch , BATCH_SIZE);
                } catch(Exception e){
                    isExceptionThrown = ConstantValues.TRUE_VALUE;
                } 
            Test.stopTest();
            List<AsyncApexJob> asyncJobList = getAsyncJobList();
            System.assertEquals(BATCH_JOB_COMPLETED_STATUS, asyncJobList[0].Status, ASSERTION_FAILED);
            System.assertEquals(ConstantValues.FALSE_VALUE, isExceptionThrown, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test CreateRecordsForHistoricalDataBatch for sole prop without Dealer_Applicant_Relationship__c with CFA Admin profile
    * @author Sk Minsar | 03-21-2025 
    **/
    @isTest
    public static void testWithCFAAdminUser() {
        Boolean isExceptionThrown = ConstantValues.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap(new List<String>{ConstantValues.SOLE_PROP_ENTITY});
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        List<clcommon__Party__c> partyList = (List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST);
        nullifyDAR(applicationList, partyList, ConstantValues.TRUE_VALUE);
        System.runAs(LoanServicingTestHelper.getUserByProfileName(ConstantValues.PROFILE_CFA_ADMIN)[0]) {
            Test.startTest();
                try{
                    CreateRecordsForHistoricalDataBatch recordBatch = new CreateRecordsForHistoricalDataBatch(OPERATION_TYPE, null);
                    Database.executeBatch(recordBatch , BATCH_SIZE);
                } catch(Exception e){
                    isExceptionThrown = ConstantValues.TRUE_VALUE;
                } 
            Test.stopTest();
            List<AsyncApexJob> asyncJobList = getAsyncJobList();
            System.assertEquals(BATCH_JOB_COMPLETED_STATUS, asyncJobList[0].Status, ASSERTION_FAILED);
            System.assertEquals(ConstantValues.FALSE_VALUE, isExceptionThrown, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test CreateRecordsForHistoricalDataBatch for sole prop without Dealer_Applicant_Relationship__c with Credit profile
    * @author Sk Minsar | 03-21-2025 
    **/
    @isTest
    public static void testWithCreditUser() {
        Boolean isExceptionThrown = ConstantValues.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap(new List<String>{ConstantValues.SOLE_PROP_ENTITY});
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        List<clcommon__Party__c> partyList = (List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST);
        nullifyDAR(applicationList, partyList, ConstantValues.TRUE_VALUE);
        System.runAs(LoanServicingTestHelper.getUserByProfileName(ConstantValues.PROFILE_CREDIT)[0]) {
            Test.startTest();
                try{
                    CreateRecordsForHistoricalDataBatch recordBatch = new CreateRecordsForHistoricalDataBatch(OPERATION_TYPE, null);
                    Database.executeBatch(recordBatch , BATCH_SIZE);
                } catch(Exception e){
                    isExceptionThrown = ConstantValues.TRUE_VALUE;
                } 
            Test.stopTest();
            List<AsyncApexJob> asyncJobList = getAsyncJobList();
            System.assertEquals(BATCH_JOB_COMPLETED_STATUS, asyncJobList[0].Status, ASSERTION_FAILED);
            System.assertEquals(ConstantValues.FALSE_VALUE, isExceptionThrown, ASSERTION_FAILED);
        }
    }

    /**
    * @description - Test CreateRecordsForHistoricalDataBatch for sole prop without Dealer_Applicant_Relationship__c with Master Credit profile
    * @author Sk Minsar | 03-21-2025 
    **/
    @isTest
    public static void testWithMasterCreditUser() {
        Boolean isExceptionThrown = ConstantValues.FALSE_VALUE;
        Map<String, Object> dataMap = getDataMap(new List<String>{ConstantValues.SOLE_PROP_ENTITY});
        List<genesis__Applications__c> applicationList = (List<genesis__Applications__c>)dataMap.get(KEY_APPLICATION_LIST);
        List<clcommon__Party__c> partyList = (List<clcommon__Party__c>)dataMap.get(KEY_PARTY_LIST);
        nullifyDAR(applicationList, partyList, ConstantValues.TRUE_VALUE);
        System.runAs(LoanServicingTestHelper.getUserByProfileName(ConstantValues.PROFILE_MASTER_CREDIT)[0]) {
            Test.startTest();
                try{
                    CreateRecordsForHistoricalDataBatch recordBatch = new CreateRecordsForHistoricalDataBatch(OPERATION_TYPE, null);
                    Database.executeBatch(recordBatch , BATCH_SIZE);
                } catch(Exception e){
                    isExceptionThrown = ConstantValues.TRUE_VALUE;
                } 
            Test.stopTest();
            List<AsyncApexJob> asyncJobList = getAsyncJobList();
            System.assertEquals(BATCH_JOB_COMPLETED_STATUS, asyncJobList[0].Status, ASSERTION_FAILED);
            System.assertEquals(ConstantValues.FALSE_VALUE, isExceptionThrown, ASSERTION_FAILED);
        }
    }

}